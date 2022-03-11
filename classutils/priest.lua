local mq = require('mq')
local Write = require('lib/Write')
local enagger = require('eqaddict/utils/camper')
local dannet = require('eqaddict/dannet/helpers')
local utils = require('eqaddict/utils/utils')

Priest = {}
Priest.new = function(name, class)
    local self = extendingCamper.new(name, class)

    local travel_invis = false

    self.groupBuffs = {}
    self.selfBuffs = {}
    self.originalSpellSet = {}

    self.priestObserverCureTable = {}
    self.priestObserverGroupBuffsTable = {}
    self.priestObserverTankBuffsTable = {}
--    self.singleTargetHealThreshold = 70
--    self.groupHealThreshold = 60
--    self.groupHealCountThreshold = 3
--
--    function self.setSingleTargetHealThreshold(value) self.singleTargetHealThreshold = value end
--    function self.setGroupHealThreshold(value) self.groupHealThreshold = value end
--    function self.setGroupHealCountThreshold(value) self.groupHealCountThreshold = value end
--    function self.getSingleTargetHealThreshold() return self.singleTargetHealThreshold end
--    function self.getgroupHealThreshold() return self.groupTargetHealThreshold end
--    function self.getGroupHealCountThreshold() return self.groupHealCountThreshold end

    function self.getSpells(options)
        local tmp = {}
        --local reckless = {}
        local name, index, category, subcategory, timerid
        -- https://www.lua.org/pil/5.3.html
        -- check mandatory options
        index = options.index or 1

        if options.name == nil and options.category == nil and options.subcategory == nil and options.timerid == nil and options.targettype == nil then
            error("At least one search argument has to be given")
        end
        
        name = options.name
        category = options.category
        subcategory = options.subcategory
        timerid = options.timerid
        exclude = options.exclude
        targettype = options.targettype
        recasttime = options.recasttime

        i = 1
        while true do
            if mq.TLO.Me.Book(i)() ~= nil then
                local bookSpell = mq.TLO.Me.Book(i)
                local spellIcon = bookSpell.SpellIcon()
                local spellLevel = bookSpell.Level()

                local nameCheck = true
                local categoryCheck = true
                local subcategoryCheck = true
                local timeridCheck = true
                local excludeCheck = true
                local targettypeCheck = true
                local recasttimeCheck = true

                if name ~= nil then
                    nameCheck, _ = string.find(bookSpell(), name) or 0
                    if nameCheck > 0 then
                        nameCheck = true
                    else
                        nameCheck = false
                    end
                end

                if category ~= nil then
                    local spellCategory = bookSpell.Category()
                    categoryCheck = (category == spellCategory)
                end

                if subcategory ~= nil then
                    local spellSubcategory = bookSpell.Subcategory()
                    subcategoryCheck = (subcategory == spellSubcategory)
                end

                if timerid ~= nil then
                    local spellRecastTimerID = bookSpell.RecastTimerID() or 0
                    timeridCheck = (timerid == spellRecastTimerID)
                end

                if exclude ~= nil then
                    excludeCheck, _ = string.find(bookSpell(), exclude) or 0
                    if excludeCheck > 0 then
                        excludeCheck = false
                    else
                        excludeCheck = true
                    end
                end

                if targettype ~= nil then
                    local spellTargetType = mq.TLO.Me.Spell(bookSpell()).TargetType()
                    targettypeCheck = (targettype == spellTargetType)
                end

                if recasttime ~= nil then
                    local spellRecastTime = mq.TLO.Me.Spell(bookSpell()).RecastTime()
                    recasttimeCheck = (recasttime == spellRecastTime/1000)
                end

                if nameCheck and categoryCheck and subcategoryCheck and timeridCheck and excludeCheck and targettypeCheck and recasttimeCheck then
                    tmp[spellLevel] = bookSpell()
                end
            else 
                break
            end
            i = i + 1
        end

        if next(tmp) then
            local tkeys = {}

            -- populate the table that holds the keys
            for k in pairs(tmp) do table.insert(tkeys, k) end
            
            -- sort the keys
            table.sort(tkeys)

            -- use the keys to retrieve the values in the sorted order
            local i = 0
            local len = tablelength(tmp)
            for _, k in ipairs(tkeys) do 
                if len-i == index  then
                    Write.Debug("Spellbook scan found \ag" .. k .. " \ao" .. tmp[k])
                    --reckless[1] = tmp[k]
                    return tmp[k]
                end
                i = i + 1
            end
        end
        Write.Debug("No spell found for options " .. dump(options))
        return "None"
    end

    function self.getHealTarget(hpLimit)
        local worstHurtID = 0
        local hpLimitTrue = hpLimit

        if mq.TLO.Group() ~= nil then
            for i=0, tonumber(mq.TLO.Group()) do

                if mq.TLO.Group.Member(i).Type() ~= "Corpse" then
                    if not mq.TLO.Group.Member(i).OtherZone() then
                        --if mq.TLO.Group.Member(i).Type == "Mercenary" then
                        --    if mq.TLO.Mercenary.State() == "DEAD" or mq.TLO.Mercenary.State == "SUSPENDED" then /continue
                        --end
                        if mq.TLO.Group.Member(i).Distance() < 200 then
                            if mq.TLO.Group.Member(i).Class.ShortName() == "BER" then
                                hpLimit = 79
                            else
                                hpLimit = hpLimitTrue
                            end

                            if mq.TLO.Group.Member(i).PctHPs() <= hpLimit then
                                worstHurtID = mq.TLO.Group.Member(i).ID()
                                hpLimit = mq.TLO.Group.Member(i).PctHPs()
                            end
                        end
                    end
                end
            end
        end
        return worstHurtID
    end

    function self.getGroupHealCount(hpLimit, countGroupHeal, radius)
        local healRadius = radius or 100
        local hurtCount = 0
        local hpLimitTrue = hpLimit

        if mq.TLO.Group() ~= nil then
            for i=0, mq.TLO.Group() do

                if mq.TLO.Group.Member(i).Type() ~= "Corpse" then
                    if not mq.TLO.Group.Member(i).OtherZone() then

                        if mq.TLO.Group.Member(i).Class.ShortName() == "BER" then
                            hpLimit = 79
                        else
                            hpLimit = hpLimitTrue
                        end

                        if mq.TLO.Group.Member(i).Distance() < healRadius then
                            if mq.TLO.Group.Member(i).PctHPs() <= hpLimit then
                                hurtCount = hurtCount + 1
                            end
                        end
                        if hurtCount >= countGroupHeal then return hurtCount end
                    end
                end
            end
        end
        return hurtCount
    end


    local function getEffectCount(k)
        local effectCount, result, spellName

        effectCount = mq.TLO.AltAbility(k).Spell.NumEffects()
        if effectCount == nil then effectCount = mq.TLO.Spell(k).NumEffects() end

        if effectCount > 1 then
            spellName = mq.TLO.AltAbility(k).Spell.Trigger(1)()
            if spellName ~= nil then
                if spellName == mq.TLO.AltAbility(k).Spell.Trigger(2)() then
                    effectCount = 1
                end
            end

            if spellName == nil then
                if mq.TLO.Spell(k).Trigger(1)() == mq.TLO.Spell(k).Trigger(2)() then
                    effectCount = 1
                end
            end
        end
        return effectCount
    end

    local function getSpellName(k, i)
        local spellName, effectSPA

        effectSPA = mq.TLO.AltAbility(k).Spell.Attrib(i)()
        if effectSPA == nil then effectSPA = mq.TLO.Spell(k).Attrib(i)() end

        if effectSPA == 470 or effectSPA == 374 then --Best in group (470) or Trigger (374)
            spellName = mq.TLO.AltAbility(k).Spell.Trigger(i)()
            if spellName == nil then spellName = mq.TLO.Spell(k).Trigger(i)() end
        else
            spellName = k -- Is this correct ??
            --spellName = mq.TLO.Spell(spellName).BaseName()
        end
        return spellName
    end

    function self.setTankBuffObservers()
        local result, effectCount, spellName, effectSPA, x

        if mq.TLO.Group.MainTank.ID() ~= nil then
            local name = mq.TLO.Group.MainTank.Name()
            for key, value in ipairs(self.tankBuffs) do
                for k,v in pairs(value) do

                    effectCount = getEffectCount(k)

                    for i=1, effectCount do

                        spellName = getSpellName(k, i)
                        
                        if spellName ~= nil and x ~= spellName then
                            table.insert(self.priestObserverTankBuffsTable,  {
                                [mq.TLO.Group.MainTank.Name()] = {
                                        [k] = string.format("Me.Buff[%s].ID", spellName),
                                        ["func"] = v
                                    }
                                }
                            )
                            dannet.observe(name, string.format("Me.Buff[%s].ID", spellName))
                            x = spellName
                        end
                    end
                end
            end
        end
    end

    function self.setGroupBuffObservers()
        local class, name
        local result, effectCount, spellName, effectSPA, x
        -- https://www.redguides.com/community/resources/mq2dannet.322/
        -- access: self.DanNet[<name>].O[<query>]()
        if mq.TLO.Group() == nil then return end
        for i=1, tonumber(mq.TLO.Group()) do

            class = mq.TLO.Group.Member(i).Class.ShortName()
            name = mq.TLO.Group.Member(i).Name()

            if mq.TLO.Group.Member(i).Type() == 'PC' then

                for key, value in ipairs(self.groupBuffs) do
                    for k,v in pairs(value) do

                        effectCount = getEffectCount(k)

                        for i=1, effectCount do

                            spellName = getSpellName(k, i)

                            if spellName ~= nil and x ~= spellName then
                                table.insert(self.priestObserverGroupBuffsTable,  {
                                    [name] = {
                                            [k] = string.format("Me.Buff[%s].ID", spellName),
                                            ["func"] = v
                                        }
                                    }
                                )
                                dannet.observe(name, string.format("Me.Buff[%s].ID", spellName))
                                x = spellName
                            end
                        end
                    end
                end
            end
        end
    end


    function self.setCureObservers()
        local class, name
        local result, effectCount, spellName, effectSPA
        -- https://www.redguides.com/community/resources/mq2dannet.322/
        -- access: self.DanNet[<name>].O[<query>]()

        if mq.TLO.Group() == nil then return end
        for i=1, tonumber(mq.TLO.Group()) do

            class = mq.TLO.Group.Member(i).Class.ShortName()
            name = mq.TLO.Group.Member(i).Name()

            if mq.TLO.Group.Member(i).Type() == 'PC' then
                table.insert(self.priestObserverCureTable, {[name] = "Me.Poisoned.ID"})
                dannet.observe(name, "Me.Poisoned.ID")

                table.insert(self.priestObserverCureTable, {[name] = "Me.Diseased.ID"})
                dannet.observe(name, "Me.Diseased.ID")

                table.insert(self.priestObserverCureTable, {[name] = "Me.Cursed.ID"})
                dannet.observe(name, "Me.Cursed.ID")

                table.insert(self.priestObserverCureTable, {[name] = "Me.Corrupted.ID"})
                dannet.observe(name, "Me.Corrupted.ID")
            end
        end
    end


    function self.loadSpellGem(spell, gem)
        local haveItInGem = false

        if mq.TLO.Me.AltAbility(spell).ID() ~= nil then return end

        if spell == nil then
            Write.Debug("Spell is nil")
            return
        end

        if spell == "None" then
            Write.Debug("Spell is None")
            return
        end

        for i=1, 13 do
            if mq.TLO.Me.Gem(i).Name() == spell then
                haveItInGem = true
            end
        end

        if not haveItInGem then
            if mq.TLO.Me.Gem(gem).Name() == nil or mq.TLO.Me.Gem(gem).Name() ~= spell then
                if mq.TLO.Me.Book(spell)() then
                    if not mq.TLO.Me.Sitting() then mq.cmd('/sit') end
                    Write.Info("Loading spell " .. spell)
                    mq.cmdf('/memspell %d "%s"', gem, spell)
                    mq.delay(500)
                    while mq.TLO.Me.Gem(gem).Name() == nil do mq.delay(500) end
                else
                    Write.Debug("\arCould not find the spell " .. spell .. " in your spell book")
                end
            end
        end
    end

    local function castBuffs(buffsListWithConditions)
        if buffsListWithConditions == nil then return end
        if next(buffsListWithConditions) then            
            Write.Debug("Buffs table has values \a-g" .. dump(buffsListWithConditions))

            for key, value in ipairs(buffsListWithConditions) do
                for k,v in pairs(value) do
                    if mq.TLO.Me.XTarget() > 0 then break end
                    self.loadSpellGem(k, key)
                    while not mq.TLO.Me.SpellReady(mq.TLO.Me.Gem(1).Name())() do mq.delay(500) end
                end
            end
            if mq.TLO.Me.XTarget() == 0 then self.activateRotation(buffsListWithConditions) end
        end

        for k,v in pairs(self.originalSpellSet) do self.loadSpellGem(v, k) end
    end
    
    local function checkBuffsWithoutObserver(buffsTable)
        local result
        local effectCount
        local spellName
        local effectSPA, x
        local buffsListWithConditions = {}

        for key, value in ipairs(buffsTable) do
            for k,v in pairs(value) do

                if mq.TLO.Me.XTarget() > 0 then break end

                effectCount = getEffectCount(k)

                for i=1, effectCount do

                    if mq.TLO.Me.XTarget() > 0 then break end

                    spellName = getSpellName(k, i)

                    if spellName ~= nil and x ~= k then

                        result = mq.TLO.Me.Buff(spellName).ID() or 0
                        if result == 0 then if mq.TLO.Me.Aura[1].Name() == spellName then result = 1 end end
                        if result == 0 then if mq.TLO.Me.Aura[2].Name() == spellName then result = 1 end end
                        if result == 0 then if mq.TLO.Me.Song(spellName).ID() then result = 1 end end
                        if result == 0 then if mq.TLO.Me.Buff(mq.TLO.Spell(spellName).BaseName()).ID() then result = 1 end end

                        if result == 0 then
                            table.insert(buffsListWithConditions, {[k] = v})
                            x = k
                            break
                        end
                    end
                end
            end
        end
        return buffsListWithConditions
    end
    
    local function checkBuffsWithObserver(buffsTable)

        local result, x
        local buffsListWithConditions = {}

        if mq.TLO.Me.XTarget() > 0 then return end
        if mq.TLO.Group() == nil then return end
        if mq.TLO.SpawnCount("pccorpse group radius 150")() > 0 then return end
        if mq.TLO.Group.Member(mq.TLO.Group.MainTank.ID()).OtherZone() then return end

        for key,value in pairs(buffsTable) do
            for name,innerTable in pairs(value) do
                for k,v in pairs(innerTable) do
                    if k ~= "func" then

                        result = tonumber(mq.TLO.DanNet(name).O(innerTable[k])()) or 0

                        -- If no match
                        if result == 0 and x ~= k then
                            Write.Debug(name.." does not have "..innerTable[k].. " adding ".. k .. " to list")
                            table.insert(buffsListWithConditions, {[k] = innerTable["func"]})
                            x = k
                        end
                    end
                end
            end
        end
        return buffsListWithConditions
    end

    function self.buffRotation()

        if mq.TLO.Me.XTarget() > 0 then return end
        self.setState(State.BUFF)

        if next(self.priestObserverGroupBuffsTable) then
            castBuffs(checkBuffsWithObserver(self.priestObserverGroupBuffsTable))
        end

        if next(self.priestObserverTankBuffsTable) then
           castBuffs(checkBuffsWithObserver(self.priestObserverTankBuffsTable))
        end

        if next(self.selfBuffs) then
            castBuffs(checkBuffsWithoutObserver(self.selfBuffs))
        end

    end

    function self.engageMeleeOffensive()
        --[[
            1. Casters should engage when mob is in camp and below threshold
            2. Melee should engage when mob is in camp and below threshold
        ]]
        -- Two classes of melee and ranged that inherit and implement abstractions self.attack()?

        if self.validateCombat() then

            self.setState(State.MELEECOMBAT)

            if mq.TLO.Me.ID() == mq.TLO.Group.MainTank.ID() or self.validateTargetBuffsCaster() then
                self.petAttack()

                if next(self.Debuffs) then
                    if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.Debuffs) end
                end

                self.combatStick()

                if next(self.Offensive) then
                    if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.Offensive) end
                end
            else
                if mq.TLO.Me.Combat() then mq.cmd('/attack off') mq.delay(100) end
                if mq.TLO.Me.Pet.Combat() then mq.cmd('/pet back off') mq.delay(100) end
            end
        end
    end


    function self.engageRangeOffensive()

        if self.validateCombat() then

            if self.validateTargetBuffsCaster() then

                self.setState(State.RANGEDCOMBAT)

                if next(self.Debuffs) then
                    if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.Debuffs) end
                end

                if next(self.Offensive) then
                    if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.Offensive) end
                end

            end

        end
    end

    function self.engageDefensive()

        self.setState(State.DEFENSECOMBAT)

        if next(self.GroupHeals) then
            self.activateRotation(self.GroupHeals)
        end

        if next(self.SingleHeals) then
            self.activateRotation(self.SingleHeals)
        end

        if next(self.GroupCures) then
            self.activateRotation(self.GroupCures)
        end

        if next(self.Utility) then
            self.activateRotation(self.Utility)
        end
    end

    return self
end

    --[[
    for key, value in ipairs(self.groupBuffs) do
        for k,v in pairs(value) do
            
            -- /lua parse mq.TLO.AltAbility("Talisman of the Wulthan").Spell.NumEffects()
            -- /lua parse mq.TLO.Spell("Talisman of the Wulthan").NumEffects()

            effectCount = mq.TLO.AltAbility(k).Spell.NumEffects()
            if effectCount == nil then effectCount = mq.TLO.Spell(k).NumEffects() end
            --print(k, " ", effectCount)
            for i=1, effectCount do
                effectSPA = mq.TLO.AltAbility(k).Spell.Attrib(i)()
                if effectSPA == nil then effectSPA = mq.TLO.Spell(k).Attrib(i)() end
                -- /lua parse mq.TLO.Spell("Talisman of the Wulthan").Attrib(i)()

                if effectSPA == 470 or effectSPA == 374 then --Best in group (470) or Trigger (374)
                    spellName = mq.TLO.AltAbility(k).Spell.Trigger(i)()
                    if spellName == nil then spellName = mq.TLO.Spell(k).Trigger(i)() end
                else
                    spellName = k -- Is this correct ??
                end

                result = tonumber(dannet.query(name, string.format('Me.Buff[%s].ID', spellName))) or 0
                
                -- If no match
                if result == 0 then
                    table.insert(tmp, {[k] = v})
                    break
                end
            end
        end
    end

    if next(tmp) then
        for key, value in ipairs(tmp) do
            for k,v in pairs(value) do
                self.loadSpellGem(k, key)
                while not mq.TLO.Me.SpellReady(mq.TLO.Me.Gem(1).Name())() do mq.delay(500) end
            end
        end
        Write.Debug("Buffs table has values \a-g" .. dump(tmp))
        self.activateRotation(tmp)
    end
    tmp = {}
    ]]

