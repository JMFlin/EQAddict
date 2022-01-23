-- Engager class
--- Holds state about who to engage and attack

local mq = require('mq')
local core = require('eqaddict/core')
local Write = require('lib/Write')

extendingEngager = {}
extendingEngager.new = function(name, class)
    local self = baseCharacter.new(name, class)
    
    local abilityDelay = 200

    self.assistRange = 80
    self.assistAt = 98
    self.targetName = ""
    self.stick = '!front'
    self.targetNamedFirst = false

    local function tablePairs(t, ...)
        local i, a, k, v = 1, {...}
        return
          function()
            repeat
              k, v = next(t, k)
              if k == nil then
                i, t = i + 1, a[i]
              end
            until k ~= nil or not t
            return k, v
          end
      end

    local function offensiveSpamRotation()
        for key, value in tablePairs(Debuffs,Offensive,Defensive,Utility) do
            for k,v in pairs(value) do
                if not self.validateCommonActivate(k) then return end
                if value[k]() then
                    self.activateAA(k)
                    self.activateDisc(k)
                    self.activateSpell(k)
                    self.activateAbility(k)
                    self.activateItem(k)
                    mq.delay(abilityDelay)
                end
            end
        end
    end

    local  function offensiveDiscPairingRotation(rotation)
        for key, value in ipairs(rotation) do
            if not self.validateCommonActivate(k) then return end
            for k,v in pairs(value) do
                if value[k]() then
                    self.activateAA(k)
                    self.activateDisc(k)
                    self.activateSpell(k)
                    self.activateAbility(k)
                    self.activateItem(k)
                    mq.delay(abilityDelay)
                end
            end
        end
    end

    local function defensiveRotation()
        print("defensiveRotation is not implemented yet for " .. self.class)
    end

    local function selfBuffRotation()
        print("selfBuffRotation is not implemented yet for " .. self.class)
    end

    local function validateTargetBuffs()
        for key, value in pairs(NoAutoAttackBuffs) do
            if mq.TLO.Spawn("id " .. self.targetID).Buff(value).ID() then
                Write.Info("Not auto attacking because target has debuff \ar" .. value)
                return false
            end
        end
        return true
    end

    function self.engage(targetID)
        --[[
            1. Casters should engage when mob is in camp and below threshold
            2. Melee should engage when mob is in camp and below threshold
        ]]

        self.setTarget(targetID)

        if self.targetID == 0 then return end
        if mq.TLO.Target.Type() == "Corpse" then return end
        if mq.TLO.Me.ID() ~= mq.TLO.Group.MainTank.ID() and mq.TLO.Spawn("id " .. self.targetID).PctHPs() > self.assistAt then return end
        if mq.TLO.Navigation.PathLength("id " .. self.targetID)() > self.assistRange then 
            if mq.TLO.Stick.Active() then mq.cmd('/stick off') end
            if mq.TLO.Navigation.Active() then mq.cmd('/nav stop') end
            self.targetID = 0
            return
        end

        if not mq.TLO.Navigation.PathExists('id ' .. self.targetID)() then
            if mq.TLO.Stick.Active() then mq.cmd('/stick off') return end
        end

        if mq.TLO.Navigation.Active() then mq.cmd('/nav stop') end
        if mq.TLO.Target.ID() ~= nil then mq.cmd('/face') end

        if mq.TLO.Me.ID() == mq.TLO.Group.MainTank.ID() then
            if not mq.TLO.Stick.Active() then mq.cmd('/stick 12 moveback loose') end
        end

        if mq.TLO.Me.ID() ~= mq.TLO.Group.MainTank.ID() then
            if not mq.TLO.Stick.Active() then mq.cmdf('/stick 12 hold moveback %s loose', self.stick) end
        end

        if validateTargetBuffs() then
            mq.cmd('/attack off')
            mq.delay(100)
            if mq.TLO.Me.Pet.ID() then
                mq.cmd('/pet attack')
                mq.delay(100)
                mq.cmd('/pet swarm')
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
            offensiveSpamRotation()
            -- offensiveDiscPairingRotation(Rotation1)
        else
            mq.cmd('/attack off')
            mq.delay(100)
            mq.cmd('/pet back off')
            mq.delay(100)
        end
    end

    return self
end