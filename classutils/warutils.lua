local mq = require('mq')
local Write = require('lib/Write')
local priest = require('eqaddict/classutils/fighter')

-- https://forums.daybreakgames.com/eq/index.php?threads/understanding-warrior-stacking-issues.271938/
-- https://forums.daybreakgames.com/eq/index.php?threads/warrior-guide.266889/
---- https://forums.daybreakgames.com/eq/index.php?threads/tips-on-tov-t2-tanking.264599/#post-3904649
Warrior = {}
Warrior.new = function(name, class)
    local self = Fighter.new(name, class)

    local abilitiesTable = {

        Breather = self.getDiscs({timerid = 13, recasttime = 90}),

        Taunt = "Taunt",

        -- Defensive Disc
        BP = mq.TLO.Me.Inventory(17).Name(), -- SPA451
        Bulwark = self.getDiscs({timerid = 16}), -- SPA451
        Dicho = self.getDiscs({timerid = 20}), -- SPA451

        FinalStand = self.getDiscs({timerid = 2}), -- SPA168

        PDH = self.getDiscs({timerid = 18}), -- SPA162
        BraceForImpact = "Brace For Impact", -- SPA162

        BladeGuardian = "Blade Guardian", -- SPA175
        Spire = "Spire of the Warlord", -- SPA175

        WarlordsBravery = "Warlord's Bravery", -- SPA197
        CoABP = "Gladiator's Plate Chestguard of War", -- SPA197

        ResoluteDefense = self.getDiscs({name = "Defense", timerid = -1}), -- always on if no other disc
        Fortitude = self.getDiscs({timerid = 3}),
        Flash = self.getDiscs({timerid = 11}),


--Because 3 min of PDH + 1 min of Dissident + 48 sec of Guardian Bravery = 4 min 48
--Also, these 3 abilities aren"t equal in term of mitigation power. 
--Your mitigation during PDH will be lesser than Dissident or Bravery, especially as you will have Brace for Impact which will account as SPA 162 ability still while Dissident and Bravery are running. 
--So I would suggest you to use Roaring Shield while under PDH instead of Bravery for example.
--Imperator Command using with Bravery or PDH, and not Dissident, as I have yet a HP boost with Dissident, and Dissident is the best of the 3 tools in mitigation.


        -- Self buffs Disc
        CommandingVoice = self.getDiscs({name = "Commanding Voice", timerid = -1}),
        FieldProtector = self.getDiscs({name = "Field", timerid = -1}),

        -- Spam offensive discs
        ThroatJab = self.getDiscs({name = "Throat Jab", timerid = -1}),
        ShieldTopple = self.getDiscs({timerid = 22}),

        -- Aggro discs
        BitingTongue = self.getDiscs({name = "Tongue", timerid = 4}),
        Bazu = self.getDiscs({timerid = 8, recasttime = 30}),
        Mock = self.getDiscs({timerid = 9, recasttime = 30}),
        RoarOfChallenge = self.getDiscs({timerid = 14}),
        Shout = self.getDiscs({timerid = 17}),
        Phantom = self.getDiscs({timerid = 19}),
        Expanse = self.getDiscs({name = "Expanse", timerid = 21}),
        WadeIntoBattle = self.getDiscs({name = "Wade into Battle", timerid = 12}),

        -- AoE Aggro discs
        Cyclone = self.getDiscs({timerid = 10, recasttime = 45}),

        --Fearless discs
        Fearless = self.getDiscs({name = "Fearless", timerid = 5}),

        -- Taunt AAs
        Attention = self.getDiscs({timerid = 15}), -- hold aggro
        AgelessEnmity = "Ageless Enmity", -- hold aggro
        BlastOfAnger = "Blast of Anger", -- 1 min cooldown

        
        -- AoE Taunt AAs
        AreaTaunt = "Area Taunt",

        -- Aggro AAs
        ProjectionOfFury = "Projection of Fury", -- 5 min cooldown
        RageOfRallosZek = "Rage of Rallos Zek",

        -- Defensive AAs
        ImperatorsCommand = "Imperators Command", -- 3 min cooldown
        MarkOfTheMageHunter = "Mark of the Mage Hunter",
        ResplendentGlory = "Resplendent Glory",
        WarCry = "War Cry", -- immune to fear
        

        -- Self heals AAs
        WarlordsResurgence = "Warlord's Resurgence", -- self heal
        WarlordsTenacity = "Warlord's Tenacity", -- self heal

        -- Offensive AAs
        Rampage = "Rampage",
        VehementRage = "Vehement Rage",
        CallOfChallenge = "Call of Challenge", -- 10 sec coldown
        GutPunch = "Gut Punch",
        KneeStrike = "Knee Strike",
        PressTheAttack = "Press the Attack", -- 14 sec cooldown can stun but does knockback!
        WarlordsFury = "Warlord's Fury" ,-- 1:30 cooldown
        WarlordsGrasp = "Warlord's Grasp", -- pair with press teh attack! pulls towards you 45 sec cooldown
        WarSheolsHeroicBlade = "War Sheol's Heroic Blade",


        -- Self buff AAs
        BattleLeap = "Battle Leap",

        -- Rezz
        SingleRezz = "Token of Resurrection",

        -- Utility AAs
        Leap = "Furious Leap",
        GrapplingStrike = "Grappling Strike", -- small pull towrds
        HowlOfTheWarlord = "Howl of the Warlord", -- fade

        -- Aura
        Aura = self.getDiscs({name = "Aura", timerid = -1}),
    }

    local function mapAbilities()

        -- Two buttons: one for mash (has some aggro)
        -- one for aggro
        -- Ageless Emnity if clr or shm have aggro

        self.Offensive = {
            [1] = {[self.Common.BlastOfAnger] = function() return true end},
            [2] = {[self.Common.Phantom] = function() return true end},
            [3] = {[self.Common.Rampage] = function() return true end},
            [4] = {[self.Common.CallOfChallenge] = function() return true end},
            [5] = {[self.Common.GutPunch] = function() return true end},
            [6] = {[self.Common.KneeStrike] = function() return true end},
            [7] = {[self.Common.Taunt] = function() return true end},
            [8] = {[self.Common.GrapplingStrike] = function() return true end},
            [9] = {[self.Common.ShieldTopple] = function() return true end},
            [10] = {[self.Common.WarlordsGrasp] = function() return true end},
            [11] = {[self.Common.PressTheAttack] = function() return true end},
            [12] = {[self.Common.BattleLeap] = function()
                local buff = mq.TLO.Me.Song("Battle Leap").ID() or 0

                if buff == 0 then
                    return true
                end
                return false
            end},
            [13] = {[self.Common.ThroatJab] = function()
                local targetID = mq.TLO.Target.ID() or 0

                if targetID > 0 then
                    if mq.TLO.Spawn("id " .. targetID).Named() then
                        return true
                    end
                end
                return false
            end},
        }

        self.Aggro = {
            [1] = {[self.Common.Bazu] = function()
                local aggro = mq.TLO.Me.SecondaryPctAggro() or 0

                if aggro > 60 then
                    return true
                end
                return false
            end},
            [2] = {[self.Common.Mock] = function()
                local aggro = mq.TLO.Me.SecondaryPctAggro() or 0

                if aggro > 60 then
                    return true
                end
                return false
            end},
            [3] = {[self.Common.Shout] = function()
                local aggro = mq.TLO.Me.SecondaryPctAggro() or 0

                if aggro > 60 then
                    return true
                end
                return false
            end},
            [4] = {[self.Common.ProjectionOfFury] = function()
                local aggro = mq.TLO.Me.SecondaryPctAggro() or 0

                if aggro > 50 then
                    return true
                end
                return false
            end},
            [5] = {[self.Common.WarlordsFury] = function()
                local aggro = mq.TLO.Me.SecondaryPctAggro() or 0

                if aggro > 50 then
                    return true
                end
                return false
            end},
            [6] = {[self.Common.WadeIntoBattle] = function()
                local aggro = mq.TLO.Me.SecondaryPctAggro() or 0

                if aggro > 30 then
                    return true
                end
                return false
            end},
            [7] = {[self.Common.BitingTongue] = function()
                local targetID = self.getXTargetNamedID()
                
                if targetID > 0 then
                    return true
                end
                return false
            end},
        }

        self.OffensiveRotation1 = {
            [1] = {[self.Common.RageOfRallosZek] = function()
                local targetID = self.getXTargetNamedID()
                
                if targetID > 0 then
                    return true
                end
                return false
            end},
            [2] = {[self.Common.WarSheolsHeroicBlade] = function()
                local targetID = self.getXTargetNamedID()

                if targetID > 0 then
                    return true
                end
                return false
            end},
        }

        self.Defensive = {
            [1] = {[self.Common.Flash] = function()
                local hps = mq.TLO.Me.PctHPs() or 0
                local fortitudeID = mq.TLO.Spell("Fortitude Discipline").ID()
                local activeDisc = mq.TLO.Me.ActiveDisc.ID() or 0

                if activeDisc ~= fortitudeID then
                    if hps < 60 then
                        return true
                    end
                end
                return false
            end},
            [2] = {[self.Common.WarlordsResurgence] = function()
                local hps = mq.TLO.Me.PctHPs() or 0

                if hps < 50 then
                    return true
                end
                return false
            end},
            [3] = {[self.Common.WarlordsTenacity] = function()
                local hps = mq.TLO.Me.PctHPs() or 0

                if hps < 50 then
                    return true
                end
                return false
            end},
            [4] = {[self.Common.Attention] = function()
                local targetID = mq.TLO.Target.ID() or 0
                local aggro = mq.TLO.Me.SecondaryPctAggro() or 0
                local activeDisc = mq.TLO.Me.ActiveDisc.ID() or 0

                if targetID > 0 then
                    if mq.TLO.Spawn("id " .. targetID).Named() and aggro >= 100 then
                        return true
                    elseif mq.TLO.Spawn("id " .. targetID).Named() and activeDisc ~=  mq.TLO.Spell("Fortitude Discipline").ID() then
                        return true
                    end
                end
                return false
            end},
            [5] = {[self.Common.AgelessEnmity] = function()
                local targetID = mq.TLO.Target.ID() or 0
                local aggro = mq.TLO.Me.SecondaryPctAggro() or 0

                if targetID > 0 then
                    if mq.TLO.Spawn("id " .. targetID).Named() and aggro >= 100 then
                        return true
                    end
                end
                return false
            end},
        }

        self.DefensiveRotation1 = {
            [1] = {[self.Common.ResoluteDefense] = function()
                local activeDisc = mq.TLO.Me.ActiveDisc.ID() or 0

                if mq.TLO.Me.XTarget() > 0 and activeDisc == 0 then
                    return true
                end
                return false
            end},
            [2] = {[self.Common.Dicho] = function() -- SPA451
                local PDH = mq.TLO.Me.Buff(self.Common.PDH).ID() or 0
                local WarlordsBravery = mq.TLO.Me.Buff(self.Common.WarlordsBravery).ID() or 0

                if mq.TLO.Me.XTarget() > 0 and PDH == 0 and WarlordsBravery == 0 then
                    return true
                end
                return false
            end},
            [3] = {[self.Common.CoABP] = function() -- SPA197
                local myBuff = mq.TLO.Me.Buff(self.Common.Dicho).ID() or 0

                if mq.TLO.Me.XTarget() > 0 and myBuff > 0 then
                    return true
                end
                return false
            end}, 
        }

        self.DefensiveRotation2 = {
            [1] = {[self.Common.ResoluteDefense] = function()
                local activeDisc = mq.TLO.Me.ActiveDisc.ID() or 0

                if mq.TLO.Me.XTarget() > 0 and activeDisc == 0 then
                    return true
                end
                return false
            end},
            [2] = {[self.Common.PDH] = function() -- SPA162
                local Dicho = mq.TLO.Me.Buff(self.Common.Dicho).ID() or 0
                local WarlordsBravery = mq.TLO.Me.Buff(self.Common.WarlordsBravery).ID() or 0

                if mq.TLO.Me.XTarget() > 0 and Dicho == 0 and WarlordsBravery == 0 then
                    return true
                end
                return false
            end},
            [3] = {[self.Common.BP] = function() -- SPA451
                local myBuff = mq.TLO.Me.Buff(self.Common.PDH).ID() or 0

                if mq.TLO.Me.XTarget() > 0 and myBuff > 0 then
                    return true
                end
                return false
            end},
            [4] = {[self.Common.ImperatorsCommand] = function()
                local myBuff = mq.TLO.Me.Buff(self.Common.PDH).ID() or 0

                if mq.TLO.Me.XTarget() > 0 and myBuff > 0 then
                    return true
                end
                return false
            end},
            [5] = {[self.Common.Spire] = function() -- SPA175
                local myBuff = mq.TLO.Me.Buff(self.Common.PDH).ID() or 0

                if mq.TLO.Me.XTarget() > 0 and myBuff > 0 then
                    return true
                end
                return false
            end},
        }

        self.DefensiveRotation3 = {
            [1] = {[self.Common.ResoluteDefense] = function()
                local activeDisc = mq.TLO.Me.ActiveDisc.ID() or 0

                if mq.TLO.Me.XTarget() > 0 and activeDisc == 0 then
                    return true
                end
                return false
            end},
            [2] = {[self.Common.WarlordsBravery] = function() -- SPA197
                local Dicho = mq.TLO.Me.Buff(self.Common.Dicho).ID() or 0
                local PDH = mq.TLO.Me.Buff(self.Common.PDH).ID() or 0

                if mq.TLO.Me.XTarget() > 0 and Dicho == 0 and PDH == 0 then
                    return true
                end
                return false
            end},
            [3] = {[self.Common.Bulwark] = function() -- SPA451
                local myBuff = mq.TLO.Me.Buff(self.Common.WarlordsBravery).ID() or 0

                if mq.TLO.Me.XTarget() > 0 and myBuff > 0 then
                    return true
                end
                return false
            end},
            [4] = {[self.Common.BraceForImpact] = function() -- SPA162
                local myBuff = mq.TLO.Me.Buff(self.Common.WarlordsBravery).ID() or 0

                if mq.TLO.Me.XTarget() > 0 and myBuff > 0 then
                    return true
                end
                return false
            end},
        }

        self.DefensiveRotation4 = {
            [1] = {[self.Common.Fortitude] = function()
                local targetID = self.getXTargetNamedID()
                local activeDiscID = mq.TLO.Me.ActiveDisc.ID() or 0
                local fort = mq.TLO.Me.CombatAbility(mq.TLO.Me.CombatAbility(self.Common.Fortitude)).ID() or 0
                local main = mq.TLO.Me.CombatAbility(mq.TLO.Me.CombatAbility(self.Common.FinalStand)).ID() or 0

                if activeDiscID > 0 then
                    if activeDiscID ~= fort and activeDiscID ~= main then
                        mq.cmd("/stop disc")
                        mq.delay(250)
                    end
                end

                if targetID > 0 then
                    return true
                end
                return false
            end},
            [2] = {[self.Common.FinalStand] = function() -- SPA168
                local targetID = self.getXTargetNamedID()
                local activeDiscID = mq.TLO.Me.ActiveDisc.ID() or 0
                local fort = mq.TLO.Me.CombatAbility(mq.TLO.Me.CombatAbility(self.Common.Fortitude)).ID() or 0
                local main = mq.TLO.Me.CombatAbility(mq.TLO.Me.CombatAbility(self.Common.FinalStand)).ID() or 0

                if activeDiscID > 0 then
                    if activeDiscID ~= fort and activeDiscID ~= main then
                        mq.cmd("/stop disc")
                        mq.delay(250)
                    end
                end

                if targetID > 0 then
                    return true
                end
                return false
            end},
            [3] = {[self.Common.BladeGuardian] = function()
                local targetID = self.getXTargetNamedID()

                if targetID > 0 then
                    return true
                end
                return false
            end},
            [4] = {[self.Common.MarkOfTheMageHunter] = function()
                local targetID = self.getXTargetNamedID()

                if targetID > 0 then
                    return true
                end
                return false
            end},
            [5] = {[self.Common.ResplendentGlory] = function()
                local targetID = self.getXTargetNamedID()

                if targetID > 0 then
                    return true
                end
                return false
            end},
            [6] = {[self.Common.WarCry] = function() -- immune to fear
                local targetID = self.getXTargetNamedID()

                if targetID > 0 then
                    return true
                end
                return false
            end},
        }


        self.PullsDefensive = deepCopy(self.Defensive)

        self.PullsTag = {
            [1] = {["Throw Stone"] = function() return true end},
        }

        self.PullsMove = {
 
        }

        self.Debuffs = {

        }

        self.AoEAggro = {
            [1] = {[self.Common.RoarOfChallenge] = function()
                local aoeAggro = self.checkAoEAggro()

                if  mq.TLO.Me.XTarget() > 0 and aoeAggro then
                    if mq.TLO.SpawnCount("npc radius 30 zradius 30") > 1 then
                        return true
                    end
                end
                return false
            end},
            [2] = {[self.Common.AreaTaunt] = function()
                local aoeAggro = self.checkAoEAggro()

                if mq.TLO.Me.XTarget() > 0 and aoeAggro then
                    if mq.TLO.SpawnCount("npc radius 40 zradius 40") > 1 then
                        return true
                    end
                end
                return false
            end},
            [3] = {[self.Common.Cyclone] = function()
                local aoeAggro = self.checkAoEAggro()

                if mq.TLO.Me.XTarget() > 0 and aoeAggro then
                    if mq.TLO.SpawnCount("npc radius 50 zradius 50") > 1 then
                        return true
                    end
                end
                return false
            end},
            [4] = {[self.Common.Expanse] = function()

                if mq.TLO.Me.XTarget() > 0 then
                    return true
                end
                return false
            end},
        }

        self.selfBuffs = {
            [1] = {[self.Common.Aura] = function() return true end},
            [2] = {[self.Common.CommandingVoice] = function() return true end},
            [3] = {[self.Common.FieldProtector] = function() return true end},
        }

        self.Utility = {
            [1] = {[self.Common.Breather] = function()
                if mq.TLO.Me.Endurance() < 15 then    
                    if mq.TLO.Me.XTarget() > 0 then
                        return true
                    end
                end
                return false
            end},
        }

        self.Rezz = {
            [1] = {[self.Common.SingleRezz] = function()
                local targetID = mq.TLO.Target.ID() or 0

                if mq.TLO.Me.XTarget() > 0 then return false end
                if mq.TLO.Spawn("group cleric").ID() > 0 then return false end
                if mq.TLO.Spawn("group shaman").ID() > 0 then return false end

                if mq.TLO.SpawnCount("pccorpse radius 150")() > 0 then
                    self.loadSpellGem(self.Common.SingleRezz, 8)
                    
                    local corpseID = mq.TLO.NearestSpawn(1, "pccorpse radius 150").ID()
                    local corpseDist = mq.TLO.NearestSpawn(1, "pccorpse radius 25").ID() or 0

                    if targetID ~= corpeID then mq.cmdf("/target %d", corpseID) mq.delay(500) end
                    if corpseDist == 0 then mq.cmdf("/corpse") end

                    return true
                end

                return false
            end}
        }

        if string.find(mq.TLO.Me.AltAbility(692).Name(), "Disabled") ~= nil and mq.TLO.Me.AltAbilityReady(692) then
            mq.cmdf("/alt act 692")
        end
        if string.find(mq.TLO.Me.AltAbility(684).Name(), "Disabled") and mq.TLO.Me.AltAbilityReady(684) then
            mq.cmdf("/alt act 684")
        end
        if string.find(mq.TLO.Me.AltAbility(1126).Name(), "Disabled") and mq.TLO.Me.AltAbilityReady(1126) then
            mq.cmdf("/alt act 1126")
        end
        if string.find(mq.TLO.Me.AltAbility(2001).Name(), "Disabled") and mq.TLO.Me.AltAbilityReady(2001) then
            mq.cmdf("/alt act 2001")
        end

    end

    function self.setAbilities()
        self.setAllAbilities(abilitiesTable)
        mapAbilities()

        self.setPullingObservers()
        self.setupMeleeSkills()
    end

    return self
end


--[[

    -- Utility AAs
    Leap = "Furious Leap",
    HowlOfTheWarlord = "Howl of the Warlord", -- fade

]]