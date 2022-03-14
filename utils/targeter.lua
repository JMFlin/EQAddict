-- Engager class
--- Holds state about who to engage and attack

local mq = require('mq')
local Write = require('lib/Write')
local core = require('eqaddict/utils/core')

extendingTargeter = {}
extendingTargeter.new = function(name, class)
    local self = baseCharacter.new(name, class)

    local exclude = {}

    self.targetNamedFirst = false

    function self.getXTargetNamedID()
        local namedTargetID = 0

        for i=1, mq.TLO.Me.XTarget() do

            -- If named
            if mq.TLO.Me.XTarget(i).Named() then

                -- Then set is as prefered
                targetID = mq.TLO.Me.XTarget(i).ID()
                return namedTargetID
            end
        end
        return namedTargetID
    end

    local function getClosestTarget()
        local distanceLimit = 999
        local closestTargetID = 0
        local mobDist, mobID

        for i=1, mq.TLO.Me.XTarget() do

            -- If the hp of the current is higher than a previous specified target then continue loop
            mobDist = mq.TLO.Me.XTarget(i).Distance3D() or 999
            mobID = mq.TLO.Me.XTarget(i).ID() or 0
            if mobDist <= distanceLimit then 

                -- If the hp of the current is lower than a previous specified target then set that as prefered target
                distanceLimit = mobDist
                closestTargetID = mobID
            end
        end
        return closestTargetID
    end

    local function getLowestHPTarget()
        local hpLimit = 999
        local lowestHPTargetID = 0
        local mobHP, mobID

        for i=1, mq.TLO.Me.XTarget() do

            -- If the hp of the current is higher than a previous specified target then continue loop
            mobHP = mq.TLO.Me.XTarget(i).PctHPs() or 999
            if mobHP < hpLimit then 

                -- If the hp of the current is lower than a previous specified target then set that as prefered target
                hpLimit = mobHP
                lowestHPTargetID = mq.TLO.Me.XTarget(i).ID() or 0
            end
        end
        return lowestHPTargetID
    end

    local function setMemberTarget(whotoassist)
        Write.Debug('Assisting ' .. whotoassist.Name())
        mq.cmd("/assist " .. whotoassist.Name())
        mq.delay(500, function() return mq.TLO.Me.AssistComplete() or false end)
        if mq.TLO.Target.PctHPs() ~= nil then self.setTargetID(mq.TLO.Target.ID()) end
        if mq.TLO.Target.Type() ~= "NPC" then
            Write.Debug('MA is targeting an NPC, taking lowest HP target')
            local targetID = getLowestHPTarget()
            self.setTargetID(targetID)
            mq.cmdf('/mqtarget id %d', self.getTargetID())
            mq.delay(500, function() return self.getTargetID() == targetID end)
        end
    end

    local function getTargetMA()
        -- Group main assist logic
        local targetID = 0
        local currentTargetID = self.getTargetID() or 0

        if not self.targetNamedFirst then
            targetID = getLowestHPTarget()

            if mq.TLO.Spawn("id " .. targetID).PctHPs() >= 99 then
                targetID = getClosestTarget()
            end
        end
        -- Do I prefer named or add?
        if self.targetNamedFirst then
            targetID = self.getXTargetNamedID()
        end

        self.setTargetID(targetID)
        mq.cmdf('/mqtarget id %d', self.getTargetID())
        mq.delay(500, function() return self.getTargetID() == targetID end)

        -- If we got a target
        if self.getTargetID() > 0 then

            -- Turn off melee stick on target change
            if self.getTargetID() ~= currentTargetID then
                if mq.TLO.Navigation.Active() then mq.cmd("/nav stop") end
                if mq.TLO.Stick.Active() then mq.cmd("/stick off") end
            end
        end
    end

    local function getTargetMember()
        local currentTargetID = self.getTargetID() or 0
        local maID = mq.TLO.Group.MainAssist.ID() or 0

        if maID > 0 and mq.TLO.Spawn("id " .. maID .. " pccorpse radius 100").ID() == 0 then
            setMemberTarget(mq.TLO.Group.MainAssist)
        else
            local targetID = getLowestHPTarget()
            self.setTargetID(targetID)
            mq.cmdf('/mqtarget id %d', self.getTargetID())
            mq.delay(500, function() return self.getTargetID() == targetID end)
        end

        -- If we got a target
        if self.getTargetID() > 0 then

            -- Turn off melee stick on target change
            if self.getTargetID() ~= currentTargetID then
                if mq.TLO.Navigation.Active() then mq.cmd("/nav stop") end
                if mq.TLO.Stick.Active() then mq.cmd("/stick off") end
            end
        end
    end

    local function getTargetTank()
        -- Group tank logic

        for i=1, mq.TLO.Me.XTarget() do
            if mq.TLO.Me.XTarget(i).Distance() <= self.assistRange + 50 then
                if mq.TLO.Me.XTarget(i).PctAggro() < 100 then
                    self.setTargetID(mq.TLO.Me.XTarget(i).ID())
                    mq.cmdf('/mqtarget id %d', self.getTargetID())
                    mq.delay(500, function() return self.getTargetID() == mq.TLO.Me.XTarget(i).ID() end)
                    break
                end
            end
            if i == mq.TLO.Me.XTarget() then getTargetMember() end
        end
    end

    function self.getOffensiveTarget()

        -- is there a target to be had?
        if mq.TLO.Me.XTarget() > 0 then
            if not mq.TLO.Me.Standing() then mq.cmd('/stand') end
            
            -- If only one target then just get that
            if mq.TLO.Me.XTarget() == 1 then
                self.setState(State.MEMBERTARGET)
                self.setTargetID(mq.TLO.Me.XTarget(1).ID())
                mq.cmdf('/mqtarget id %d', self.getTargetID())
                mq.delay(500, function() return self.getTargetID() == mq.TLO.Me.XTarget(1).ID() end)
            elseif mq.TLO.Me.ID() == mq.TLO.Group.MainAssist.ID() then
                self.setState(State.MATARGET)
                getTargetMA()
            elseif mq.TLO.Me.ID() == mq.TLO.Group.MainTank.ID() then
                self.setState(State.TANKTARGET)
                getTargetTank()
            else
                self.setState(State.MEMBERTARGET)
                getTargetMember()
            end
        end
    end

    return self
end
