local mq = require('mq')
local Write = require('lib/Write')
local events = require('eqaddict/events')

-- if you end the line with () you get the datatype its meant to return

NoAutoAttackBuffs = {
    'Sarnak Finesse'
}

-- Enums
Modes = {
    MANUAL = "Manual",
    TRAVEL = "Travel",
    PULL_CAMP = "Camp",
    MISSION = "Mission"
 }
 
 -- Base class
 baseCharacter = {}
 baseCharacter.new = function(name, class)
    -- Encapsulate what a base character is
    local self = {
        name = name or nil,
        class = class or nil
    }

    self.autoCampRadius = 30
    self.targetID = 0

    local xCampCoord
    local yCampCoord
    local zCampCoord
    local mode

    function self.setTarget(targetID)

        if targetID ~= nil then
            if self.targetID == targetID then return end
            if mq.TLO.Spawn("id " .. targetID).DisplayName() ~= nil then
                Write.Info("Setting target to \a-p" .. mq.TLO.Spawn("id " .. targetID).DisplayName())
                self.targetID = targetID
            else
                Write.Debug("Cannot set targetID to nil")
            end
        else
            Write.Debug("Cannot set targetID to nil")
        end
    end

    local function activate(command, skill)
        local casting = true
        if not mq.TLO.Me.Standing() then mq.cmd('/stand') end
        if mq.TLO.Spell(skill).MyCastTime.Float() > 0.00 then
            while casting do
                if not mq.TLO.Me.Standing() then mq.cmd('/stand') end
                CAST_FIZZLED = false
                mq.cmdf(command, skill)
                mq.delay(200)
                mq.doevents("fizzle")
                mq.delay(200)
                if CAST_FIZZLED then
                    casting = true
                elseif not mq.TLO.Me.Casting.ID() then
                    casting = false
                end
            end
        else
            mq.cmdf(command, skill)
        end
    end

    function self.activateAA(aaName)
        if not mq.TLO.Me.AltAbilityReady(aaName)() then return end
        Write.Info("Using AA \ao" .. aaName)
        activate('/alt act %d', mq.TLO.Me.AltAbility(aaName).ID())
    end

    function self.activateSpell(spellName)
        if not mq.TLO.Me.SpellReady(spellName)() then return end
        Write.Info("Using spell \ao" .. spellName)
        activate('/cast %d', mq.TLO.Me.Gem(spellName)())
    end

    function self.activateDisc(discName)
        if not mq.TLO.Me.CombatAbilityReady(discName)() then return end
        Write.Info("Using disc \ao" .. discName)
        activate('/disc %d', mq.TLO.Me.CombatAbility(mq.TLO.Me.CombatAbility(discName)).ID())
    end

    function self.activateAbility(abilityName)
        if not mq.TLO.Me.AbilityReady(abilityName)() then return end
        Write.Info("Using ablity \ao" .. abilityName)
        mq.cmd('/doability ' .. '\"'.. abilityName .. '\"')
    end

    function self.activateItem(itemName)
        if mq.TLO.FindItem(itemName)() == nil then return end
        if mq.TLO.FindItem(itemName).Timer.TotalSeconds() > 0 or not mq.TLO.Me.ItemReady(itemName)() then return end
        Write.Info("Using item \ao" .. itemName)
        activate('/useitem %d', mq.TLO.FindItem(itemName).InvSlot())
    end

    function self.validateCommonActivate(name)
        local targetID = mq.TLO.Target.ID()
        
        if name == nil then return false end
        if targetID ~= self.targetID then return false end

        if not mq.TLO.Spawn("id " .. self.targetID).LineOfSight() then return false end
        if mq.TLO.Spawn("id " .. self.targetID).PctHPs() == nil then return false end
        if mq.TLO.Spell(name).MyRange() ~= nil then
            if mq.TLO.Spell(name).MyRange() > 0 then
                if mq.TLO.Spell(name).MyRange() < mq.TLO.Spawn("id " .. self.targetID).Distance() - 10 then return false end
            end
        end
        return true
    end

    -- Nav and movement shared methods
    function self.navToID(targetID)
        mq.cmdf('/nav id %d', targetID)
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

    function self.returnToCamp()
        --[[
        Scenarios
            1. Target is fleeing then we don't want to return to camp as melees
            2. We don't have line of sight on out group memebers ex: we are fighting behind a tree
            3. If we are melee with a short camp radius we don't want to run back and forth
            4. If we are main tank we want to pull mob to camp if it is not fleeing and is too far away
            5. We don't want to move to camp if we are casting a heal
            6. If we get knocked away from camp we want to run back
            ]]

        local radius = self.autoCampRadius
        local tankRadius = 33

        if self.getXCampCoord() == 0 and self.getYCampCoord() == 0 and self.getZCampCoord() == 0 then return end

        -- If we are moving then return
        if mq.TLO.Navigation.Active() then mq.cmd('/nav off') end

        -- If casting return
        if mq.TLO.Me.Casting.ID() ~= nil then return end

        -- Don't move to camp if target is low on health and running away
        if mq.TLO.Target.ID() ~= nil and mq.TLO.Target.ID() > 0 then
            if mq.TLO.Target.Type() == "NPC" then
                -- if target is fleeing
                if mq.TLO.Target.Fleeing() and mq.TLO.Target.PctHPs() < 25 then return end
                -- if tank is still on target
                if mq.TLO.Group.MainTank.ID() ~= nil then
                    if not mq.TLO.SpawnCount("loc " .. mq.TLO.Spawn("id " .. mq.TLO.Group.MainTank.ID()).X() .. " " .. mq.TLO.Spawn("id " .. mq.TLO.Group.MainTank.ID()).Y() .. " radius 50 zradius 40 npc targetable noalert 1") then return end
                end
            end
        end

        -- Melee are sticking to target so no need to move to camp
        if mq.TLO.Me.XTarget() > 0 then
            if mq.TLO.Group.MainTank.ID() ~= mq.TLO.Me.ID() then
                if mq.TLO.Select(mq.TLO.Me.Class.ShortName(),"WAR","SHD","PAL","BER","BRD","ROG","MNK","BST") then radius = tankRadius * 5 end
            else
                radius = tankRadius * 3
            end
        end

        -- If we are at camp then return
        if distance3D(mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z(), self.getXCampCoord(), self.getYCampCoord(), self.getZCampCoord()) <= radius then return end

        -- If we have engaged then stick off
        if mq.TLO.Stick.Status() == "ON" then mq.cmd('/stick off') end

        -- Run to camp
        while distance3D(mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z(), self.getXCampCoord(), self.getYCampCoord(), self.getZCampCoord()) > radius do
            Write.Debug("My distance from camp spot is " .. distance3D(mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z(), self.getXCampCoord(), self.getYCampCoord(), self.getZCampCoord()))
            Write.Debug("Allowed distance is " .. radius)
            if not mq.TLO.Navigation.Active() then mq.cmdf('/nav locxyz %d %d %d', self.getXCampCoord(), self.getYCampCoord(), self.getZCampCoord()) end
            mq.delay(500)
        end
        if mq.TLO.Navigation.Active() then mq.cmd('/nav stop') end
    end
 
    -- Shared base methods
    --[[
        All characters use nav to follow the group leader. 
    ]]
    function self.followTheLeader()
        if self.xCampCoord ~= nil then
            self.xCampCoord = nil
        end
        if self.yCampCoord ~= nil then
            self.yCampCoord = nil
        end
        if self.zCampCoord ~= nil then
            self.zCampCoord = nil
        end

        if not mq.TLO.Me.Standing() then
            mq.cmd('/stand')
        end

        if mq.TLO.Stick.Status() == "ON" then
            mq.cmd('/stick off')
        end

        if mq.TLO.Select(mq.TLO.Me.Class.ShortName,"SHM","DRU")() then
            --/call core_cast2 "${TravelSpell}" FIND ${Me.ID} FALSE
        end

        -- How to check if attack is off?
        mq.cmd('/attack off')

        if mq.TLO.Me.Pet.ID() and mq.TLO.Me.Combat() then
            mq.cmd('/pet back off')
        end

        if mq.TLO.Me.Pet.Stance() ~= "FOLLOW" then
            mq.cmd('/pet follow')
        end

        -- if (!${Me.XTarget}) /call check_for_corpse FALSE
        
        if mq.TLO.Group() then
            for i=0, mq.TLO.Group() do
                -- Get group leader position in group
                if mq.TLO.Group.Member(i).ID() == mq.TLO.Group.Leader.ID() then
                    groupLeaderPosition = i
                end
            end
            -- If i am not the group leader then nav to leader
            if mq.TLO.Group.Leader.ID() ~= mq.TLO.Me.ID() then
                if mq.TLO.Navigation.MeshLoaded() and not mq.TLO.Group.Member(groupLeaderPosition).OtherZone() then
                    if not mq.TLO.Navigation.Active() and mq.TLO.Navigation.PathLength('id ' .. mq.TLO.Group.Leader.ID())() > 30 then
                        Write.Debug("Navigating to \a-g" .. mq.TLO.Group.Leader.DisplayName())
                        self.navToID(mq.TLO.Group.Leader.ID())
                    end
                end
            end

            for i=1, 2 do
                if mq.TLO.Group.Member(groupLeaderPosition).OtherZone() then
                    self.nudgeForward()
                    self.doorClick()
                end
            end
        end
    end

    -- Setters
    function self.setCampSpot(xCoord, yCoord, zCoord)
        if self.xCampCoord ~= xCoord then
            self.xCampCoord = xCoord
        end
        if self.yCampCoord ~= yCoord then
            self.yCampCoord = yCoord
        end
        if self.zCampCoord ~= zCoord then
            self.zCampCoord = zCoord
        end
    end

    function self.setMode(mode)
        Write.Info("Setting mode to \ag" .. mode)
        if self.mode ~= mode then
            self.mode = mode
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

    -- Getter base methods
    function self.getName() return self.name end
    function self.getClass() return self.class end
    function self.getMode() return self.mode end
    function self.getCurrentTarget() return self.target end
    function self.getCampSpot() return self.xCampCoord, self.yCampCoord, self.zCampCoord end
    function self.getXCampCoord() return self.xCampCoord end
    function self.getYCampCoord() return self.yCampCoord end
    function self.getZCampCoord() return self.zCampCoord end
    
    return self
end


-- Utility stuff

function toboolean(x)
    local bool = false
    if tostring(x) == "TRUE" then
        bool = true
    end
    return bool
end

function printf(...)
    print(string.format(...))
end

function distance3D(x1, y1, z1, x2, y2, z2) return math.sqrt( (x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2 ) end

function selfValidateDebuffs()
    if mq.TLO.Me.Poisoned.ID() then return true end
    if mq.TLO.Me.Diseased.ID() then return true end
    if mq.TLO.Me.Cursed.ID() then return true end
    if mq.TLO.Me.Corrupted.ID() then return true end
    if mq.TLO.Me.Snared.ID() then return true end
    if mq.TLO.Me.Mezzed.ID() then return true end
    if mq.TLO.Me.Charmed.ID() then return true end
    return false
end
