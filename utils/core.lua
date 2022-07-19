local mq = require('mq')
local Write = require('lib/Write')
local events = require('eqaddict/utils/events')
local dannet = require('eqaddict/dannet/helpers')

-- if you end the line with () you get the datatype its meant to return

NoAutoAttackBuffs = {
    'Sarnak Finesse'
}

NoCastBuffs = {
    'Partial Shadow'
}

-- Enums
Modes = {
    MANUAL = "Manual",
    TRAVEL = "Travel",
    CAMP = "Camp",
    MISSION = "Mission"
}

State = {
    PULL = "Pulling",
    TAG = "Tagging",
    MEDITATE = "Meditating",
    MOVE = "Moving",
    BURN = "Burning",
    GETOUT = "PC came too close",

    BUFF = "Buffing",
    
    TANKTARGET = "Tank targeting",
    MATARGET = "Assisting MA",
    MEMBERTARGET = "Targeting",
    
    DEFENSECOMBAT = "Defensives",
    RANGEDCOMBAT = "Ranged Combat",
    MELEECOMBAT = "Melee Combat",

    DESTROYCAMPFIRE = "Destroying Campfire",
    CREATECAMPFIRE = "Creating Campfire",
    
    REZZ = "Rezzing"
}

 -- Base class
 baseCharacter = {}
 baseCharacter.new = function(name, class)
    -- Encapsulate what a base character is
    local self = {
        name = name or nil,
        class = class or nil
    }
    local mode
    local targetID
    local targetName

    local immuneTable = {}
    local abilityDelay = 250
    local abilityDelayVariance = 50

    self.state = "Starting"

    self.Common = {}
    
    self.Debuffs = {}
    self.Offensive = {}

    self.Downtime = {}
    self.Rezz = {}

    self.PullsMove = {}
    self.PullsTag = {}
    self.PullsDefensive = {}

    self.Utility = {}
    self.Travel = {}

    self.GroupCures = {}
    self.Defensive = {}

    -- Getter base methods
    function self.getName() return self.name end
    function self.getClass() return self.class end
    function self.getMode() return self.mode end
    function self.getTargetID() if self.targetID == nil then return 0 else return self.targetID end end
    function self.getTargetName() return self.targetName end
    function self.getState() return self.state end

    local function handleEventImmune(skill)
        mq.doevents("immune")
        mq.delay(100)
        if ISIMMUNE then
            immuneTable[self.getTargetID()] = skill
        end
        ISIMMUNE = false
    end

    local function handleEventFizzle()
        CASTFIZZLED = false
        mq.doevents("fizzle")
        mq.delay(100)
        return CASTFIZZLED
    end

    local function handleEventInterrupt()
        ISINTERRUPTED = false
        mq.doevents("interrupt")
        mq.delay(100)
        return ISINTERRUPTED
    end

    local function activate(command, skill, castTime)
        local casting = true
        local fizzled = false
        local interrupted = false
        local i = 0

        -- clear queues
        handleEventInterrupt()
        handleEventFizzle()

        if castTime > 0 then
            if mq.TLO.Stick.Active() then 
                mq.cmd('/stick off')
                mq.delay(200, function() return not mq.TLO.Stick.Active() end)
            end
            while casting do

                -- Wait until we are not moving
                while mq.TLO.Me.Moving() do mq.delay(500, function() return not mq.TLO.Me.Moving() end) end

                -- Stand if we got knocked down during cast loop
                if not mq.TLO.Me.Standing() then mq.cmd('/stand') end
                
                -- Actually trigger the cast
                mq.cmdf(command, skill)
                mq.delay(1000, function() return mq.TLO.Me.Casting.ID() ~= nil end)

                -- If I am not casting anymore then get me out
                while mq.TLO.Me.Casting.ID() ~= nil or mq.TLO.Window["CastingWindow"].Open() do mq.delay(250) end
                if mq.TLO.Me.Casting.ID() == nil then casting = false end

                -- Handle event globals and their results
                handleEventImmune(skill)
                fizzled = handleEventFizzle()
                interrupted = handleEventInterrupt()

                -- Just in case to get us out of here
                i = i + 1
                if i >= 6 then break end
                if fizzled or interrupted then casting = true end
            end
        else
            mq.cmdf(command, skill)
        end
        if self.getState() ~= State.TAG and self.getState() ~= State.PULL then mq.delay(mq.TLO.Spell(skill).RecoveryTime()) end
    end

    local function delaySelfBuffsToShowOnBuffWindow(skill)
        if mq.TLO.Spell(skill).SpellType() == "Beneficial" and mq.TLO.Spell(skill).TargetType() == "Self" then
            mq.delay(1000, function()
                    local songCheck = mq.TLO.Me.Song(skill).ID() or 0
                    local triggerSongCheck = mq.TLO.Me.Song(mq.TLO.Spell(skill).Trigger(1)()).ID() or 0
                    local buffCheck = mq.TLO.Me.Buff(skill).ID() or 0
                    local triggerBuffCheck = mq.TLO.Me.Buff(mq.TLO.Spell(skill).Trigger(1)()).ID() or 0
                    local discCheck = mq.TLO.Me.CombatAbility(mq.TLO.Me.CombatAbility(skill)).ID() or 0
                    local activeDiscID = mq.TLO.Me.ActiveDisc.ID() or 0
                    local checker = false
                    if songCheck > 0 or triggerSongCheck > 0 or buffCheck > 0 or triggerBuffCheck > 0 or discCheck == activeDiscID then
                        checker = true
                    end
                    if not checker then Write.Debug("Delaying for \ao" .. skill .. " \awto be registered") end
                    return checker
                end
            )
        end
    end

    local function validateCommonActivate(name)
        local targetID = mq.TLO.Target.ID()
        local myMana = mq.TLO.Me.CurrentMana() or 0
        local myEndurance = mq.TLO.Me.CurrentEndurance()
        
        local enduranceCost = mq.TLO.Spell(name).EnduranceCost() or 0
        local manaCost = mq.TLO.Spell(name).Mana() or 0

        if myMana < manaCost or myEndurance < enduranceCost then return false end

        if name == nil then return false end
        if mq.TLO.Me.Invis() then return false end

        if mq.TLO.Me.Dead() then return false end
        if mq.TLO.Me.Stunned() then return false end
        if mq.TLO.Me.Charmed.ID() ~= nil then return false end
        if mq.TLO.Me.Invulnerable.ID() ~= nil then return false end
        if mq.TLO.Me.State() == "HOVER" then return false end
        
        -- SpellType
        -- AERange
        -- https://docs.macroquest.org/macroquest/data-types-and-top-level-objects/data-types/datatype-spell
        if mq.TLO.Spell(name).TargetType() == "Group v1" then return true end
        if mq.TLO.Spell(name).TargetType() == "Group v2" then return true end
        if mq.TLO.Spell(name).TargetType() == "PB AE" then return true end
        if mq.TLO.Spell(name).TargetType() == "Self" then return true end
        if mq.TLO.Spell(name).TargetType() == "Summoned" then return true end
        if mq.TLO.Spell(name).TargetType() == "Unknown" then return true end
        
        if targetID ~= self.getTargetID() then return false end

        if self.getState() ~= State.TAG and self.getState() ~= State.PULL then
            if mq.TLO.Spell(name).SpellType() ~= "Beneficial" then
                if not mq.TLO.Spawn("id " .. self.getTargetID()).LineOfSight() then return false end
                if mq.TLO.Spawn("id " .. self.getTargetID()).PctHPs() == nil then return false end
            end
        end

        if mq.TLO.Spell(name).MyRange() ~= nil then
            if mq.TLO.Spell(name).MyRange() > 0 then
                if mq.TLO.Spell(name).MyRange() < mq.TLO.Spawn("id " .. self.getTargetID()).Distance3D() then return false end
            end
        end

        if next(immuneTable) then
            for k,v in pairs(immuneTable) do
                if k == self.getTargetID() then
                    return false
                end
            end
        end

        return true
    end

    local function activateAA(aaName)
        if not validateCommonActivate(aaName) then return end
        if not mq.TLO.Me.AltAbilityReady(aaName)() then return end
        castTime = mq.TLO.Spell(mq.TLO.Me.AltAbility(aaName).Name()).MyCastTime() or 0
        Write.Info("Using AA \ao" .. aaName .. " \awwith cast time " .. castTime)
        activate('/alt act %d', mq.TLO.Me.AltAbility(aaName).ID(), castTime)
        delaySelfBuffsToShowOnBuffWindow(aaName)
    end

    local function activateSpell(spellName)
        if not validateCommonActivate(spellName) then return end
        if not mq.TLO.Me.SpellReady(spellName)() then return end
        castTime = mq.TLO.Spell(spellName).MyCastTime() or 0
        Write.Info("Using spell \ao" .. spellName .. " \awwith cast time " .. castTime)
        activate('/cast %d', mq.TLO.Me.Gem(spellName)(), castTime)
        delaySelfBuffsToShowOnBuffWindow(spellName)
    end

    local function activateDisc(discName)
        if not validateCommonActivate(discName) then return end
        if not mq.TLO.Me.CombatAbilityReady(discName)() then return end
        castTime = mq.TLO.Spell(discName).MyCastTime() or 0
        Write.Info("Using disc \ao" .. discName .. " \awwith cast time " .. castTime)
        activate('/disc %d', mq.TLO.Me.CombatAbility(mq.TLO.Me.CombatAbility(discName)).ID(), castTime)
        delaySelfBuffsToShowOnBuffWindow(discName)
    end

    local function activateAbility(abilityName)
        if not validateCommonActivate(abilityName) then return end
        if not mq.TLO.Me.AbilityReady(abilityName)() then return end
        Write.Info("Using ablity \ao" .. abilityName)
        mq.cmd('/doability ' .. '\"'.. abilityName .. '\"')
    end

    local function activateItem(itemName)
        if not validateCommonActivate(itemName) then return end
        if mq.TLO.FindItem(itemName)() == nil then return end
        if mq.TLO.FindItem(itemName).Timer.TotalSeconds() > 0 or not mq.TLO.Me.ItemReady(itemName)() then return end
        castTime = mq.TLO.FindItem(itemName).CastTime() or 0
        Write.Info("Using item \ao" .. itemName .. " \awwith cast time " .. castTime)
        activate('/useitem %s', itemName, castTime)
        delaySelfBuffsToShowOnBuffWindow(itemName)
    end

    function self.activateRotation(rotation)
        if rotation == nil then return end
        for key, value in ipairs(rotation) do
            for k,v in pairs(value) do
                if value[k]() then
                    activateAA(k)
                    activateDisc(k)
                    activateSpell(k)
                    activateAbility(k)
                    activateItem(k)
                    mq.delay(math.random(abilityDelay - abilityDelayVariance, abilityDelay + abilityDelayVariance))
                end
            end
        end
    end

    function self.setAllAbilities(abilitiesTable)
        local spellCheck
        for k,v in pairs(abilitiesTable) do
            spellCheck = mq.TLO.Spell(v).RankName()
            if mq.TLO.Me.AltAbility(v).ID() ~= nil then
                self.Common[k] = v
                Write.Debug("Set \aoAA\aw " .. k .. " --> " .. v)
            elseif spellCheck ~= nil then 
                if mq.TLO.Me.Book(spellCheck) ~= nil then
                    self.Common[k] = mq.TLO.Spell(v).RankName()
                    Write.Debug("Set \aoSpell\aw " .. k .. " --> " .. v)
                end
            elseif mq.TLO.FindItem(v).ID() ~= nil then
                self.Common[k] = v
                Write.Debug("Set \aoItem\aw " .. k .. " --> " .. v)
            elseif mq.TLO.Me.AbilityReady(v)() ~= nil then
                self.Common[k] = v
                Write.Debug("Set \aoAbility\aw " .. k .. " --> " .. v)
            else
                self.Common[k] = "None"
                Write.Debug("\arFailed to set " .. k .. " --> " .. v)
            end
        end
    end

    function self.activatePreCast(aa)
        if mq.TLO.Me.AltAbilityReady(aa)() then
            Write.Info("Using Precast AA \ao" .. aa)
            mq.cmd('/alt act %d', mq.TLO.Me.AltAbility(aa).ID())
            mq.delay(125)
        end
    end

    function self.rezzRotation()
        if mq.TLO.SpawnCount("pccorpse radius 150")() > 0 then
            self.setState(State.REZZ)
            if next(self.Rezz) then
                self.activateRotation(self.Rezz)
            end
        end
    end

    function self.meditate()

        if mq.TLO.Me.Hovering() then return end

        self.setTargetID(0)

        -- have I been knocked down?
        if mq.TLO.Me.State() == "FEIGN" then mq.cmd("/stand") end

        -- should I be in battle?
        if mq.TLO.Me.XTarget() > 0 then return end

        -- am I moving?
        if mq.TLO.Me.Moving() then return end

        -- if stick is on we can turn it off
        if mq.TLO.Stick.Status() == "ON" then mq.cmd("/stick off") end

        -- turn autoattack off
        if not mq.TLO.Me.Combat() then mq.cmd('/attack off') end

        -- check pet
        if mq.TLO.Me.Pet.ID() and mq.TLO.Me.Pet.Combat() then mq.cmd("/pet back off") end

        -- am I casting?
        if mq.TLO.Me.Casting.ID() ~= nil and mq.TLO.Me.Class.ShortName() ~= "BRD" then return end

        if mq.TLO.Me.Standing() and ((mq.TLO.Me.PctMana() < 95 and mq.TLO.Me.PctMana() > 0) or mq.TLO.Me.PctEndurance() < 95 or mq.TLO.Me.PctHPs() < 95) then mq.cmd("/sit") end

    end

    function self.dead()
        while mq.TLO.Me.Hovering() do
            mq.delay(1000)
        end
        while mq.TLO.Me.Zoning() do
            mq.delay(1000)
        end
    end

    -- Nav and movement shared methods
    function self.navToID(ID)
        mq.cmdf('/nav id %d', ID)
        while mq.TLO.Navigation.Active() do
            mq.delay(1000) -- equivalent to '1s'
        end
    end

    function self.navToCoords(x, y, z)
        if x == nil then
            Write.Debug("Privided x is " .. x)
            return false
        end
        if y == nil then
            Write.Debug("Privided y is " .. y)
            return false
        end
        if z == nil then
            Write.Debug("Privided z is  " .. z)
            return false
        end
        Write.Debug("Running to " .. x .. " " .. y .. " ".. z)
        mq.cmdf('/nav locxyz %d %d %d', x, y, z)
        while mq.TLO.Navigation.Active() do
            mq.delay(1000) -- equivalent to '1s'
        end
    end

    function self.nudgeForward()
        mq.cmd('/keypress forward hold')
        mq.delay(500)
        mq.cmd('/keypress forward')
        mq.delay(500)
    end

    function self.doorClick()
        if not mq.TLO.Me.Zoning() then
            mq.cmd('/doortarget')
            mq.delay(1000)
            mq.cmd('/click left door')
            mq.delay(2500)
        end
        while mq.TLO.Me.Zoning() do
            mq.delay(1000)
        end
    end

    -- Setter base methods

    function self.setState(state)
        if self.state ~= state then
--            Write.Debug("Setting state from \a-g" .. self.state .. " \awto \a-t" .. state) 
            self.state = state
        end
    end

    function self.setMode(mode)
        if self.mode ~= mode then
            Write.Info("Setting mode to \ag" .. mode)
            self.mode = mode
        end
    end

    function self.setTargetID(ID)

        if ID ~= nil then
            if ID == 0 then 
                self.targetID = ID
                self.targetName = "None"
            elseif self.targetID == ID then 
                return
            elseif mq.TLO.Spawn("id " .. ID).DisplayName() ~= nil then
                self.targetID = ID
                self.targetName = mq.TLO.Spawn("id " .. ID).DisplayName()
            else
                Write.Debug("Cannot set targetID to nil")
                mq.cmd("/target clear")
            end
        else
            Write.Debug("Cannot set targetID to nil")
            mq.cmd("/target clear")
        end
    end

    -- Abstract methods
    function self.offensiveSpamRotation() error("offensiveSpamRotation is an abstract function!") end
    function self.offensiveDiscPairingRotation() error("offensiveDiscPairingRotation is an abstract function!") end
    function self.defensiveRotation() error("defensiveRotation is an abstract function!") end
    function self.healingRotation() error("defensiveRotation is an abstract function!") end
    function self.utilityRotation() error("utilityRotation is an abstract function!") end
    function self.groupbuffRotation() error("groupBuffRotation is an abstract function!") end
    function self.selfBuffRotation() error("selfBuffRotation is an abstract function!") end
    function self.pullRoutine() error("pullToCamp is an abstract function!") end
    function self.getTarget() error("getTarget is an abstract function!") end
    
    return self
end

