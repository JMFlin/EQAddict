local mq = require('mq')
local Write = require('lib/Write')
local enagger = require('eqaddict/utils/camper')
local utils = require('eqaddict/utils/utils')

Fighter = {}
Fighter.new = function(name, class)
    local self = extendingCamper.new(name, class)

    self.OffensiveRotation1 = {}
    self.OffensiveRotation2 = {}
    self.OffensiveRotation3 = {}
    self.OffensiveRotation4 = {}
    self.OffensiveRotation5 = {}
    self.OffensiveRotation6 = {}

    self.DefensiveRotation1 = {}
    self.DefensiveRotation2 = {}
    self.DefensiveRotation3 = {}
    self.DefensiveRotation4 = {}
    self.DefensiveRotation5 = {}
    self.DefensiveRotation6 = {}

    function self.getDiscs(options)
        local tmp = {}
        --local reckless = {}
        local name, index, category, subcategory, timerid, recasttime
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
            if mq.TLO.Me.CombatAbility(i)() ~= nil then
                local bookSpell = mq.TLO.Me.CombatAbility(i)
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
                    local spellRecastTime = mq.TLO.Me.CombatAbility(i).RecastTime()
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
                    Write.Debug("Disc scan found \ag" .. k .. " \ao" .. tmp[k])
                    --reckless[1] = tmp[k]
                    return tmp[k]
                end
                i = i + 1
            end
        end
        Write.Debug("No disc found for options " .. dump(options))
        return "None"
    end

    function self.checkAoEAggro()
        for i=1, mq.TLO.Me.XTarget() do
            if mq.TLO.Me.XTarget(i).Distance() <= self.assistRange + 50 then
                if mq.TLO.Me.XTarget(i).PctAggro() < 100 then
                    return true
                end
            end
        end
        return false
    end

    function self.preCheckDisc(discName)
        local ready = mq.TLO.Me.CombatAbilityReady(discName)()
        local discID = mq.TLO.Me.CombatAbility(mq.TLO.Me.CombatAbility(discName)).ID() or 0
        local activeDiscID = mq.TLO.Me.ActiveDisc.ID() or 0

        if  mq.TLO.Me.XTarget() > 0 then
            if ready and (activeDiscID == discID or discID == 0) then
                return true
            end
        end
        return false
    end

    function self.preCheckHP()
        local isNamed = mq.TLO.Target.Named() or false
        local targetPctHP = mq.TLO.Target.PctHPs() or 0

        if isNamed then
            if targetPctHP >= 5 then
                return true
            end
        elseif targetPctHP >= 50 then
            return true
        end
        return false
    end


    local function selfBuffs(buffsTable)

        local result
        local effectCount
        local spellName
        local effectSPA, x
        local buffsListWithConditions = {}

        for key, value in ipairs(buffsTable) do
            for k,v in pairs(value) do

                if mq.TLO.Me.XTarget() > 0 then break end

                if x ~= k then
                    result = mq.TLO.Me.Buff(k).ID() or 0
                    if result == 0 then if mq.TLO.Me.Aura[1].Name() == k then result = 1 end end
                    if result == 0 then if mq.TLO.Me.Aura[2].Name() == k then result = 1 end end
                    if result == 0 then if mq.TLO.Me.Song(k).ID() then result = 1 end end
                    if result == 0 then if mq.TLO.Me.Buff(mq.TLO.Spell(k).BaseName()).ID() then result = 1 end end
                    if result == 0 then
                        table.insert(buffsListWithConditions, {[k] = v})
                        x = k
                    end
                end
            end
        end

        if next(buffsListWithConditions) then
            self.activateRotation(buffsListWithConditions)
        end
    end

    function self.buffRotation()

        if mq.TLO.Me.XTarget() > 0 then return end
        self.setState(State.BUFF)

        if next(self.selfBuffs) then
            selfBuffs(self.selfBuffs)
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

            if mq.TLO.Me.ID() == mq.TLO.Group.MainTank.ID() or self.validateTargetBuffsMelee() then
                self.petAttack()

                self.combatStick()

                if next(self.Debuffs) then
                    if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.Debuffs) end
                end

                if next(self.Offensive) then
                    if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.Offensive) end
                end

                if next(self.OffensiveRotation1) then
                    if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.OffensiveRotation1) end
                end

                if next(self.OffensiveRotation2) then
                    if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.OffensiveRotation2) end
                end

                if next(self.OffensiveRotation3) then
                    if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.OffensiveRotation3) end
                end

                if next(self.OffensiveRotation4) then
                    if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.OffensiveRotation4) end
                end
            else
                if mq.TLO.Me.Combat() then mq.cmd('/attack off') mq.delay(100) end
                if mq.TLO.Me.Pet.Combat() then mq.cmd('/pet back off') mq.delay(100) end
            end
        end
    end


    function self.engageRangeOffensive()
        --if validateCombat() then
        --    self.setState(State.RANGEDCOMBAT)
        --end
    end

    function self.engageDefensive()
        --[[
            1. Casters should engage when mob is in camp and below threshold
            2. Melee should engage when mob is in camp and below threshold
        ]]
        -- Two classes of melee and ranged that inherit and implement abstractions self.attack()?
            
        self.setState(State.DEFENSECOMBAT)

        if next(self.Defensive) then
            self.activateRotation(self.Defensive)
        end

        if next(self.DefensiveRotation1) then
            if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.DefensiveRotation1) end
        end

        if next(self.DefensiveRotation2) then
            if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.DefensiveRotation2) end
        end

        if next(self.DefensiveRotation3) then
            if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.DefensiveRotation3) end
        end

        if next(self.DefensiveRotation4) then
            if mq.TLO.Me.XTarget() > 0 and mq.TLO.Target.ID() ~= nil then self.activateRotation(self.DefensiveRotation4) end
        end
        
        if next(self.Utility) then
            self.activateRotation(self.Utility)
        end
    end

    return self
end