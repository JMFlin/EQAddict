local mq = require('mq')

--[[
    - Spams
    Skill pairings
]]
-- Skills tables


local Common = {}

-- Pulling
-- Distant Strike
if mq.TLO.Me.AltAbility("Distant Strike")() then
    Common.PULLABILITY = "Distant Strike"
else 
    Common.PULLABILITY = mq.TLO.Spell("Throw Stone").RankName()
end
if mq.TLO.Me.AltAbility("Moving Mountains")() then
    Common.MOVINGMOUNTAINS = "Moving Mountains"
else 
    Common.MOVINGMOUNTAINS = "None"
end

--AE Echo line
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Echo of Disorientation").RankName()) then 
    Common.AEMEZZ = mq.TLO.Spell("Echo of Disorientation").RankName()
elseif mq.TLO.Me.CombatAbility(mq.TLO.Spell("Echo of Duplicity").RankName()) then
    Common.AEMEZZ = mq.TLO.Spell("Echo of Duplicity").RankName()
else
    Common.AEMEZZ = "None"
end

-- Defensives
-- Reject death
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Reject Death").RankName()) then
    Common.REJECTDEATH = mq.TLO.Spell("Reject Death").RankName()
else
    Common.REJECTDEATH = "None"
end

-- Earhforce line
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Earthforce Discipline").RankName()) then
    Common.EARTHFORCE = mq.TLO.Spell("Earthforce Discipline").RankName()
else
    Common.EARTHFORCE = "None"
end

-- Shaded step line
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Shaded Step").RankName()) then
    Common.SHADEDSTEP = mq.TLO.Spell("Shaded Step").RankName()
else
    Common.SHADEDSTEP = "None"
end


-- Offensive
-- Eye of the storm
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Eye of the Storm").RankName()) then
    Common.EYEOFTHESTORM = mq.TLO.Spell("Eye of the Storm").RankName()
else
    Common.EYEOFTHESTORM = "None"
end

-- Zanfi
if mq.TLO.Me.AltAbility("Zan Fi's Whistle")() then
    Common.ZANFI = "Zan Fi's Whistle"
else
    Common.ZANFI = "None"
end

-- Intimidation
if mq.TLO.Me.Ability("Intimidation")() then
    Common.INTIMIDATION = "Intimidation"
else
    Common.INTIMIDATION = "None"
end

-- Wasp touch
if mq.TLO.Me.AltAbility("Two-Finger Wasp Touch")() then
    Common.TWOFINGERWASPTOUCH = "Two-Finger Wasp Touch"
else
    Common.TWOFINGERWASPTOUCH = "None"
end

-- Synergy Line
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Firewalker's Synergy").RankName()) then
    Common.SYNERGY = mq.TLO.Spell("Firewalker's Synergy").RankName()
else
    Common.SYNERGY = "None"
end

-- Curse Line
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Curse of Fourteen Fists").RankName()) then
    Common.CURSE = mq.TLO.Spell("Curse of Fourteen Fists").RankName()
elseif mq.TLO.Me.CombatAbility(mq.TLO.Spell("Curse of the Thirteen Fingers").RankName()) then
    Common.CURSE = mq.TLO.Spell("Curse of the Thirteen Fingers").RankName()
else
    Common.CURSE = "None"
end

-- Fang Line
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Hoshkar's Fang").RankName()) then
    Common.FANG = mq.TLO.Spell("Hoshkar's Fang").RankName()
else
    Common.FANG = "None"
end

-- Fists Line
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Firestorm of Fists").RankName()) then
    Common.FISTS = mq.TLO.Spell("Firestorm of Fists").RankName()
else
    Common.FISTS = "None"
end

-- Precision Line 
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Firewalker's Precision Strike").RankName()) then
    Common.PRECISIOIN1 = mq.TLO.Spell("Firewalker's Precision Strike").RankName()
    Common.PRECISIOIN2 = mq.TLO.Spell("Doomwalker's Precision Strike").RankName()
    Common.PRECISIOIN3 = "None"
elseif mq.TLO.Me.CombatAbility(mq.TLO.Spell("Doomwalker's Precision Strike").RankName()) then
    Common.PRECISIOIN1 = mq.TLO.Spell("Doomwalker's Precision Strike").RankName()
    Common.PRECISIOIN2 = "None"
    Common.PRECISIOIN3 = "None"
else
    Common.PRECISIOIN1 = "None"
    Common.PRECISIOIN2 = "None"
    Common.PRECISIOIN3 = "None"
end

--[[ ONLY USE DURING BURNS
-- Shuriken Line
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Vigorous Shuriken").RankName()) then
    Common.SHURIKEN = mq.TLO.Spell("Vigorous Shuriken").RankName()
else
    Common.SHURIKEN = "None"
end
]]


-- Crane Line 
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Crane Stance").RankName()) then
    Common.CRANE = mq.TLO.Spell("Crane Stance").RankName()
else
    Common.CRANE = "None"
end

-- Dicho line
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Dissident Form").RankName()) then
    Common.DICHOTOMIC = mq.TLO.Spell("Dissident Form").RankName()
elseif mq.TLO.Me.CombatAbility(mq.TLO.Spell("Dichotomic Form").RankName()) then
    Common.DICHOTOMIC = mq.TLO.Spell("Dichotomic Form").RankName()
else
    Common.DICHOTOMIC = "None"
end


-- Alliance Line
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Firewalker's Covenant").RankName()) then
    Common.ALLIANCE = mq.TLO.Spell("Firewalker's Covenant").RankName()
elseif mq.TLO.Me.CombatAbility(mq.TLO.Spell("Doomwalker's Alliance").RankName()) then
    Common.ALLIANCE = mq.TLO.Spell("Doomwalker's Alliance").RankName()
else
    Common.ALLIANCE = "None"
end

-- DM Line 
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Drunken Monkey Style").RankName()) then
    Common.DRUNKENMONKEYSTYLE = mq.TLO.Spell("Drunken Monkey Style").RankName()
else
    Common.DRUNKENMONKEYSTYLE = "None"
end

-- Ironfist line 
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Ironfist Discipline").RankName()) then
    Common.IRONFIST = mq.TLO.Me.CombatAbility(mq.TLO.Spell("Ironfist Discipline").RankName())
else
    Common.IRONFIST = "None"
end

-- Heel line
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Heel of Zagali").RankName()) then
    Common.HEEL = mq.TLO.Me.CombatAbility(mq.TLO.Spell("Heel of Zagali").RankName())
else
    Common.HEEL = "None"
end

-- Speed line
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Speed Focus Discipline").RankName()) then
    Common.SPEEDFOCUS = mq.TLO.Me.CombatAbility(mq.TLO.Spell("Speed Focus Discipline").RankName())
else
    Common.SPEEDFOCUS = "None"
end

-- Palm line 
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Terrorpalm Discipline").RankName()) then
    Common.TERRORPALM = mq.TLO.Me.CombatAbility(mq.TLO.Spell("Terrorpalm Discipline").RankName())
else
    Common.TERRORPALM = "None"
end

-- Tiger's Poise line
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Tiger's Poise").RankName()) then
    Common.TIGERSPOISE = mq.TLO.Me.CombatAbility(mq.TLO.Spell("Tiger's Poise").RankName())
else
    Common.TIGERSPOISE = "None"
end

-- Utility
-- Fast Endurance regen 
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Breather").RankName()) then
    Common.ENDREGEN = mq.TLO.Spell("Breather").RankName()
elseif mq.TLO.Me.CombatAbility(mq.TLO.Spell("Rest").RankName()) then
    Common.ENDREGEN = mq.TLO.Me.CombatAbility(mq.TLO.Spell("Rest").RankName())
else
    Common.ENDREGEN = "None"
end

-- Nine Breaths 
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Nine Breaths").RankName()) then
    Common.ENDGAIN = mq.TLO.Me.CombatAbility(mq.TLO.Spell("Nine Breaths").RankName())
elseif mq.TLO.Me.CombatAbility(mq.TLO.Spell("Eight Breaths").RankName()) then
    Common.ENDGAIN = mq.TLO.Me.CombatAbility(mq.TLO.Spell("Eight Breaths").RankName())
else
    Common.ENDGAIN = "None"
end

-- Aura 
if mq.TLO.Me.CombatAbility(mq.TLO.Spell("Master's Aura").RankName()) then
    Common.AURA = mq.TLO.Me.CombatAbility(mq.TLO.Spell("Master's Aura").RankName())
else
    Common.AURA = "None"
end

-- FD
if mq.TLO.Me.Ability("Feign Death")() then
    Common.FEIGNDEATH = "Feign Death"
else
    Common.FEIGNDEATH = "None"
end

-- Imitate death
if mq.TLO.Me.AltAbility("Imitate Death") then
    Common.IMITATEDEATH = "Imitate Death"
else
    Common.IMITATEDEATH = "None"
end

-- Mend
if mq.TLO.Me.Ability("Mend")() then
    Common.MEND = "Mend"
else
    Common.MEND = "None"
end

-- Imitate death
if mq.TLO.Me.AltAbility("Purify Body") then
    Common.PURIFYBODY = "Purify Body"
else
    Common.PURIFYBODY = "None"
end

-- BP
Common.BP = mq.TLO.Me.Inventory(17).Name()

-- Five Point Palm
if mq.TLO.Me.AltAbility("Five Point Palm") then
    Common.FIVEPOINTPALM = "Five Point Palm"
else
    Common.FIVEPOINTPALM = "None"
end

-- Vehement Rage
if mq.TLO.Me.AltAbility("Vehement Rage") then
    Common.VEHEMENTRAGE = "Vehement Rage"
else
    Common.VEHEMENTRAGE = "None"
end

-- Transcended Fistwraps of Immortality
-- Miniature Horn of Unity
-- Overflowing Urn of Life
-- Violet Conch of the Tempest
-- Lizardscale Plated Girdle

-- Skills that get spammed
Offensive = {
    [1] = {[Common.ZANFI] = function() return true end},
    [2] = {[Common.VEHEMENTRAGE] = function() return true end},
    [3] = {[Common.INTIMIDATION] = function() return true end},
    [4] = {[Common.EYEOFTHESTORM] = function() 
        if mq.TLO.Me.ActiveDisc.ID() == 0 then
            return true
        end
        return false
    end},
    [5] = {[Common.SYNERGY] = function() return true end},
    [6] = {[Common.CURSE] = function()
        local targetBuff = mq.TLO.Target.Buff(Common.CURSE).ID() or 0

        if targetBuff > 0 then
            return true
        end
        return false
    end},
    [7] = {[Common.FANG] = function() return true end},
    [8] = {[Common.FISTS] = function() return true end},
    [9] = {[Common.PRECISIOIN1] = function() return true end},
    [10] = {[Common.PRECISIOIN2] = function() return true end},
    [11] = {[Common.PRECISIOIN3] = function() return true end},
    [12] = {[Common.BP] = function() return true end},
};

-- Debuffs with conditions
Debuffs = {
    [1] = {[Common.TWOFINGERWASPTOUCH] = function()
        local targetBuff = mq.TLO.Target.Buff(Common.TWOFINGERWASPTOUCH).ID() or 0
        
        if targetBuff > 0 then
            return true
        end
        return false
    end},
}

Defensive = {
    [1] = {[Common.MEND] = function()
        if mq.TLO.Me.PctHPs() < 65 then
            return true
        end
        return false
    end},
    [2] = {[Common.REJECTDEATH] = function()
        if mq.TLO.Me.PctHPs() < 30 then
            return true
        end
    end},
    [3] = {[Common.EARTHFORCE] = function()
        if mq.TLO.Me.PctHPs() < 50 then
            return true
        end
    end},
    [4] = {[Common.PURIFYBODY] = function()
        if mq.TLO.Me.Poisoned.ID() then return true end
        if mq.TLO.Me.Diseased.ID() then return true end
        if mq.TLO.Me.Cursed.ID() then return true end
        if mq.TLO.Me.Corrupted.ID() then return true end
        if mq.TLO.Me.Snared.ID() then return true end
        if mq.TLO.Me.Mezzed.ID() then return true end
        if mq.TLO.Me.Charmed.ID() then return true end
        return false
    end},
    [5] = {[Common.SHADEDSTEP] = function()
        if mq.TLO.Me.PctHPs() < 50 and mq.TLO.ActiveDisc.ID() ~= mq.TLO.Spell(Common.EARTHFORCE).ID() and mq.TLO.ActiveDisc.ID() ~= mq.TLO.Spell(Common.REJECTDEATH).ID() then
            return true
        end
    end},
}

Utility = {
    [1] = {["Feign Death"] = function()
        local mt = mq.TLO.Group.MainTank.ID() or 0

    	if mq.TLO.Me.PctAggro() > 90 or mq.TLO.Me.PctHPs() < 30 then
            if mq.TLO.Spawn("id " .. mt .. " pccorpse radius 60").ID() > 0 then
                return true
            end
        end
        return false
    end},
    [2] = {["Imitate Death"] = function()
        local mt = mq.TLO.Group.MainTank.ID() or 0

    	if mq.TLO.Me.PctAggro() > 90 or mq.TLO.Me.PctHPs() < 30 then
            if not mq.TLO.Me.AbilityReady(Common.FEIGNDEATH)() then
                if mq.TLO.Spawn("id " .. mt .. " pccorpse radius 60").ID() > 0 then
                    return true
                end
            end
        end
        return false
    end},
}
Pulls = {
    PULLABILITY = Common.PULLABILITY,
    MOVEABILITY = Common.MOVINGMOUNTAINS
}
SelfCombatBuffs = {}
Disciplines = {}

Rotation1 = {
    [1] = {[Common.DICHOTOMIC] = function()
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
    end},
    [2] = {[Common.IRONFIST] = function()
        local isNamed = mq.TLO.Target.Named() or false
        local targetPctHP = mq.TLO.Target.PctHPs() or 0

        if mq.TLO.Me.ActiveDisc.ID() ~= nil then 
            if isNamed then
                if targetPctHP >= 5 then
                    return true
                end
            elseif targetPctHP >= 50 then
                return true
            end
        end
        return false
    end},
    [3] = {[Common.FIVEPOINTPALM] = function()
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
    end},
    [4] = {[Common.CRANE] = function()
        local isNamed = mq.TLO.Target.Named() or false
        local targetPctHP = mq.TLO.Target.PctHPs() or 0
        local targetBuff = mq.TLO.Target.Buff(Common.SYNERGY).ID() or 0

        if targetBuff > 0 then
            if isNamed then
                if targetPctHP >= 5 then
                    return true
                end
            elseif targetPctHP >= 50 then
                return true
            end
        end
        return false
    end},
}
