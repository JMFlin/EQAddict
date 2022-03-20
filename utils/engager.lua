-- Engager class
--- Holds state about who to engage and attack

local mq = require('mq')
local Write = require('lib/Write')
local targeter = require('eqaddict/utils/targeter')

extendingEngager = {}
extendingEngager.new = function(name, class)
    local self = extendingTargeter.new(name, class)

    self.assistRange = 120
    self.assistAt = 98
    self.attackHow = 'melee'
    self.stick = '!front'


    function self.setAssistAt(value) self.assistAt = value end


    function self.setupMeleeSkills()

        if mq.TLO.Me.Class.ShortName() == "BRD" or mq.TLO.Me.Class.ShortName() == "RNG" then
            if not mq.TLO.Skill("Kick").Auto() then mq.cmd("/autoskill Kick") end
        end

        if mq.TLO.Me.Class.ShortName() == "BST" then
            if not mq.TLO.Skill("Eagle Strike").Auto() then mq.cmd("/autoskill Eagle Strike") end
            if not mq.TLO.Skill("Round Kick").Auto() then mq.cmd("/autoskill Round Kick") end
        end

        if mq.TLO.Me.Class.ShortName() == "ROG" then
            if not mq.TLO.Skill("Backstab").Auto() then mq.cmd("/autoskill Backstab") end
        end

        if mq.TLO.Me.Class.ShortName() == "BER" then
            if not mq.TLO.Skill("Frenzy").Auto() then mq.cmd("/autoskill Frenzy") end
        end

        if mq.TLO.Me.Class.ShortName() == "MNK" then
            if not mq.TLO.Skill("Tiger Claw").Auto() then mq.cmd("/autoskill Tiger Claw") end
            if not mq.TLO.Skill("Flying Kick").Auto() then mq.cmd("/autoskill Flying Kick") end
        end

        if mq.TLO.Me.Class.ShortName() == "WAR" or mq.TLO.Me.Class.ShortName() == "PAL" or mq.TLO.Me.Class.ShortName() == "SHD" or mq.TLO.Me.Class.ShortName() == "CLR" then
            if not mq.TLO.Skill("Bash").Auto() then mq.cmd("/autoskill Bash") end
        end

    end

    function self.combatStick()
        local stick

        if not mq.TLO.Me.Combat() then 
            mq.cmd('/attack on')
            mq.delay(500, function() return mq.TLO.Me.Combat() end)
        end

        if mq.TLO.Me.ID() == mq.TLO.Group.MainTank.ID() then
            if not mq.TLO.Stick.Active() then
                mq.cmd('/stick 50% moveback loose')
                mq.delay(500, function() return mq.TLO.Stick.Active() end)
            end
        end

        if mq.TLO.Me.ID() ~= mq.TLO.Group.MainTank.ID() then
            if not mq.TLO.Stick.Active() then
                mq.cmd('/stick ' .. math.floor(math.random(35, 65)) .. '% ' .. self.stick .. ' loose')
                mq.delay(500, function() return mq.TLO.Stick.Active() end)
            end
        end
    end

    function self.validateTargetBuffsMelee()
        local buffName

        for i=1, mq.TLO.Target.BuffCount() do
            
            buffName = mq.TLO.Spawn("id " .. self.getTargetID()).Buff(i).Name()
            for i=1, 21 do
                effectSPA = mq.TLO.Spell(buffName).Attrib(i)()
                -- DS: effectSPA == 59
                if effectSPA == 173 then 
                    Write.Info("Not auto attacking because target has riposte SPA \ar" .. effectSPA)
                    return false 
                end
            end
        end
        return true
    end

    function self.validateTargetBuffsCaster()
        local buffName
        local buffsCount = mq.TLO.Target.BuffCount() or 0

        if buffsCount > 0 then
            for i=1, mq.TLO.Target.BuffCount() do
                
                buffName = mq.TLO.Spawn("id " .. self.getTargetID()).Buff(i).Name()
                for i=1, 21 do
                    effectSPA = mq.TLO.Spell(buffName).Attrib(i)()
                    if effectSPA == 158 then 
                        Write.Info("Not casting because target has reflect SPA \ar" .. effectSPA)
                        return false 
                    end
                end
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
        if mq.TLO.Me.Pet.ID() > 0 then
            if mq.TLO.Me.Pet.Target.ID() ~= self.getTargetID() then mq.cmd('/pet attack') end
            if mq.TLO.Me.Pet.Target.ID() ~= self.getTargetID() then  mq.cmd('/pet swarm') end
            if mq.TLO.Me.XTarget() > 0 then
                if ((mq.TLO.Group.MainTank.ID() ~= nil or mq.TLO.Spawn("id " .. mq.TLO.Group.MainTank.ID() .. " pccorpse radius 100").ID() > 0) and not mq.TLO.Me.Pet.Taunt()) then
                    mq.cmd('/pet taunt on')
                end
            end
            if not mq.TLO.Spawn("id " .. mq.TLO.Group.MainTank.ID() .. " pccorpse radius 100").ID() and mq.TLO.Me.Pet.Taunt() then mq.cmd('/pet taunt off') end
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