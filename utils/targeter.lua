-- Engager class
--- Holds state about who to engage and attack

local mq = require('mq')
local core = require('eqaddict/core')
local Write = require('lib/Write')

extendingCharacter = {}
extendingCharacter.new = function(name, class)
    local self = baseCharacter.new(name, class)

    local exclude = {}
    local abilityDelay = 200

    local function setMemberTarget(whotoassist)
        Write.Debug('Assisting ' .. whotoassist.Name())
        mq.cmd("/assist " .. whotoassist.Name())
        mq.delay(250)
        if mq.TLO.Target.PctHPs() ~= nil then self.targetID = mq.TLO.Target.ID() end
    end

    local function getTargetMember()
        
        local currentTargetID = self.targetID or 0

        if mq.TLO.Group.MainAssist.ID() ~= nil and mq.TLO.Spawn("id " .. mq.TLO.Group.MainAssist.ID() .. " pccorpse radius 100").ID() == 0 then
            setMemberTarget(mq.TLO.Group.MainAssist)
        elseif mq.TLO.Group.Puller.ID() ~= nil and mq.TLO.Spawn("id " .. mq.TLO.Group.Puller.ID() .. " pccorpse radius 100").ID() == 0 then
            setMemberTarget(mq.TLO.Group.Puller)
        elseif mq.TLO.Group.MainTank.ID() ~= nil and mq.TLO.Spawn("id " .. mq.TLO.Group.MainTank.ID() .. " pccorpse radius 100").ID() == 0 then
            setMemberTarget(mq.TLO.Group.MainTank)
        else
            mq.cmdf('/target id %d', mq.TLO.Me.XTarget(1).ID())
            mq.delay(250)
            if mq.TLO.Target.PctHPs() ~= nil then self.targetID = mq.TLO.Target.ID() end
        end

        -- If we got a target
        if self.targetID > 0 then

            -- Turn off melee stick on target change
            if self.targetID ~= currentTargetID then
                if mq.TLO.Navigation.Active() then mq.cmd("/nav stop") end
                if mq.TLO.Stick.Active() then mq.cmd("/stick off") end
            end
        end
    end

    local function getClosestTarget()
        local distanceLimit = 999
        local closestTargetID

        for i=1, mq.TLO.Me.XTarget() do

            -- If the hp of the current is higher than a previous specified target then continue loop
            if mq.TLO.Me.XTarget(i).Distance3D() <= distanceLimit then 

                -- If the hp of the current is lower than a previous specified target then set that as prefered target
                distanceLimit = mq.TLO.Me.XTarget(i).Distance3D()
                closestTargetID = mq.TLO.Me.XTarget(i).ID()
            end
        end
        return closestTargetID
    end

    local function getLowestHPTarget()
        local hpLimit = 999
        local lowestHPTargetID

        for i=1, mq.TLO.Me.XTarget() do

            -- If the hp of the current is higher than a previous specified target then continue loop
            if mq.TLO.Me.XTarget(i).PctHPs() < hpLimit then 

                -- If the hp of the current is lower than a previous specified target then set that as prefered target
                hpLimit = mq.TLO.Me.XTarget(i).PctHPs()
                lowestHPTargetID = mq.TLO.Me.XTarget(i).ID()
            end
        end
        return lowestHPTargetID
    end

    local function getTargetMA()
        -- Group main assist logic
        local targetID
        local currentTargetID = self.targetID or 0


        if not self.targetNamedFirst then
            targetID = getLowestHPTarget()

            if mq.TLO.Spawn("id " .. targetID).PctHPs() >= 99 then
                targetID = getClosestTarget()
            end
        end
        -- Do I prefer named or add?
        if self.targetNamedFirst then

            for i=1, mq.TLO.Me.XTarget() do

                -- If named
                if mq.TLO.Me.XTarget(i).Named() then

                    -- Then set is as prefered
                    targetID = mq.TLO.Me.XTarget(i).ID()
                end
            end
        end

        self.targetID = targetID
        mq.cmdf("/target id %d", self.targetID)
        mq.delay(250)

        -- If we got a target
        if self.targetID > 0 then

            -- Turn off melee stick on target change
            if self.targetID ~= currentTargetID then
                if mq.TLO.Navigation.Active() then mq.cmd("/nav stop") end
                if mq.TLO.Stick.Active() then mq.cmd("/stick off") end
            end
        end
    end

    local function getTargetTank()
        -- Group tank logic

        for i=1, mq.TLO.Me.XTarget() do
            if mq.TLO.Me.XTarget(i).Distance() <= self.assistRange then
                if #exclude > 0 then
                    -- exclude Echo'd
                    -- how about just mq.cmd('/squelch /alert add 10 id', .. self.targetID)
                    -- then clear the alert list
                    print("NOT IMPLEMENTED")
                end
                if mq.TLO.Me.XTarget(i).PctAggro() < 100 then
                    self.targetID = mq.TLO.Me.XTarget(i).ID()
                    break
                end
            end
        end
        getTargetMember()
    end

    function self.getOffensiveTarget()

        -- is there a target to be had?
        self.targetID = 0
        if mq.TLO.Me.XTarget() == 0 then return end
        if not mq.TLO.Me.Standing() then mq.cmd('/stand') end
        -- if mq.TLO.Me.XTarget() == 1 then self.targetID = mq.TLO.Me.XTarget(1).ID() return end

        if mq.TLO.Me.ID() == mq.TLO.Group.MainAssist.ID() then 
            getTargetMA()
        elseif mq.TLO.Me.ID() == mq.TLO.Group.MainTank.ID() then
            getTargetTank()
        else
            getTargetMember()
        end
        return self.targetID
    end

    return self
end
