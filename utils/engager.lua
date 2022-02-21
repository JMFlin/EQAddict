-- Engager class
--- Holds state about who to engage and attack

local mq = require('mq')
local Write = require('lib/Write')
local targeter = require('eqaddict/utils/targeter')

extendingEngager = {}
extendingEngager.new = function(name, class)
    local self = extendingTargeter.new(name, class)

    self.assistRange = 80
    self.assistAt = 98
    self.stick = '!front'
    self.attackHow = 'melee'


    function self.setAssistAt(value) self.assistAt = value end

    function self.validateTargetBuffs()
        for key, value in pairs(NoAutoAttackBuffs) do
            if mq.TLO.Spawn("id " .. self.getTargetID()).Buff(value).ID() then
                Write.Info("Not auto attacking because target has debuff \ar" .. value)
                return false
            end
        end
        return true
    end

    function self.validateCombat()
        if mq.TLO.Me.XTarget() == 0 then return false end
        if mq.TLO.Target.Type() ~= "NPC" then return false end
        if mq.TLO.Target.Type() == "Corpse" then return false end
        if mq.TLO.Spawn("id " .. self.getTargetID()).PctHPs() ~= nil then
            if mq.TLO.Me.ID() ~= mq.TLO.Group.MainTank.ID() and mq.TLO.Spawn("id " .. self.getTargetID()).PctHPs() > self.assistAt then return false end
        end

        if not mq.TLO.Navigation.PathExists('id ' .. self.getTargetID())() then
            if mq.TLO.Stick.Active() then mq.cmd('/stick off') return false end
        end

        if mq.TLO.Navigation.PathLength("id " .. self.getTargetID())() < 300 and mq.TLO.Navigation.PathLength("id " .. self.getTargetID())() > 150 then
            if mq.TLO.Target.ID() ~= nil then mq.cmd('/face') end
        end

        if mq.TLO.Navigation.PathLength("id " .. self.getTargetID())() > self.assistRange then 
            if mq.TLO.Stick.Active() then mq.cmd('/stick off') end
            if mq.TLO.Navigation.Active() then mq.cmd('/nav stop') end
            return false 
        end

        if not mq.TLO.Spawn('id ' .. self.getTargetID()).LineOfSight() then return false end

        if mq.TLO.Navigation.Active() then mq.cmd('/nav stop') end

        return true
    end

    function self.petAttack()
        if mq.TLO.Me.Pet.ID() then
            if mq.TLO.Me.Pet.Target.ID() ~= self.getTargetID() then mq.cmd('/pet attack') end
            mq.delay(100)
            if mq.TLO.Me.Pet.Target.ID() ~= self.getTargetID() then  mq.cmd('/pet swarm') end
            mq.delay(100)
            if mq.TLO.Group.MainTank.ID() ~= nil then
                if mq.TLO.Me.XTarget() > 0 then
                    if mq.TLO.Spawn("id " .. mq.TLO.Group.MainTank.ID() .. " pccorpse radius 100").ID() > 0 and not mq.TLO.Me.Pet.Taunt() then
                        mq.cmd('/pet taunt on')
                        mq.delay(100)
                        self.activateAA("Companion's Fortification")
                    end
                end
                if not mq.TLO.Spawn("id " .. mq.TLO.Group.MainTank.ID() .. " pccorpse radius 100").ID() and mq.TLO.Me.Pet.Taunt() then mq.cmd('/pet taunt off') end
            end
        end
    end

    function self.engageMeleeOffensive()
        error("engageMeleeOffensive is an abstract function!")
    end


    function self.engageRangeOffensive()
        error("engageRangeOffensive is an abstract function!")
    end

    function self.engageDefensive()
        error("engageDefensive is an abstract function!")
    end

    return self
end