local mq = require('mq')
local Write = require('lib/Write')
local priest = require('eqaddict/classutils/fighter')

-- Transcended Fistwraps of Immortality
-- Miniature Horn of Unity
-- Overflowing Urn of Life
-- Violet Conch of the Tempest
-- Lizardscale Plated Girdle
-- "Blood Drinker's Coating"
-- "Diplomatic Papers"

-- Skills that get spammed


Monk = {}
Monk.new = function(name, class)
    local self = Fighter.new(name, class)

    local abilitiesTable = {

        -- Pull Ability
        Echo = self.getDiscs({name = "Echo", timerid = -1}),
        DistantStrike = "Distant Strike",

        MovingMountains = "Moving Mountains",

        VehementRage = "Vehement Rage",
        Fang = self.getDiscs({name = "Fang", timerid = 17}),
        Fists = self.getDiscs({name = "Fists", timerid = 12}),
        Curse = self.getDiscs({name = "Curse", timerid = 10}),
        Precision1 = self.getDiscs({name = "Precision", timerid = -1, index = 1}),
        Precision2 = self.getDiscs({name = "Precision", timerid = -1, index = 2}),
        Precision3 = self.getDiscs({name = "Precision", timerid = -1, index = 3}),
        Synergy = self.getDiscs({name = "Synergy"}),
        Intimidation = "Intimidation",
        ZanFi = "Zan Fi's Whistle",
        WaspTouch = "Two-Finger Wasp Touch",
        EyeOfTheStorm = self.getDiscs({name = "Storm", timerid = 18}),
        BP = mq.TLO.Me.Inventory(17).Name(),

        TigersPoise = self.getDiscs({timerid = 16}),
        TerrorPalm = self.getDiscs({timerid = 3}),
        SpeedFocus = self.getDiscs({timerid = 11}),
        Heel = self.getDiscs({name = "Heel", timerid = 6}),
        Iron = self.getDiscs({timerid = 4}),

        Dichotomic = self.getDiscs({timerid = 20}),
        FivePointPalm = "Five Point Palm",
        CraneStance = self.getDiscs({name = "Stance"}),

        DrunkenMonkeyStyle = self.getDiscs({name = "Drunken Monkey Style"}),
        Alliance = self.getDiscs({timerid = 21}),
        Shuriken = self.getDiscs({name = "Shuriken"}),
        InfusionOfThunder = "Infusion of Thunder",
        FocusedDestructiveForce = "Focused Destructive Force",
        SwiftTail = "Swift Tails' Chant",
        Spire = "Spire of the Sensei",
        TonPo = "Ton Po's Stance",


        Mend = "Mend",
        ShadedStep = self.getDiscs({name = "Step", timerid = 18}),
        EarthForce = self.getDiscs({timerid = 2}),
        RejectDeath = self.getDiscs({name = "Death", timerid = 8}),

        ImitateDeath = "Imitate Death",
        FeignDeath = "Feign Death",

        Breaths = self.getDiscs({name = "Breaths"}),
        Breather = self.getDiscs({timerid = 13, recasttime = 90}),

        SelfCure = "Purify Body",

        Epic = "Transcended Fistwraps of Immortality",

        -- Rezz
        SingleRezz = "Token of Resurrection",

        -- Aura
        Aura = self.getDiscs({name = "Aura"}),   
    }
    
    -- https://forums.daybreakgames.com/eq/index.php?threads/monks-strats-2-0.252592/

        -- Rotation1
        -- Iron
        -- Dichotomic
        -- SwiftTail
        -- FivePointPalm
        -- CraneStance


        -- Rotation2
        -- TerrorPalm
        -- Dichotomic
        -- DrunkenMonkeyStyle
        -- SwiftTail
        -- FocusedDestructiveForce
        -- TigersPoise
        -- FivePointPalm
        -- CraneStance
        -- (ton po conflicts with fdf)
        
        -- Rotation3
        -- Heel
        -- Dichotomic
        -- DrunkenMonkeyStyle
        -- SwiftTail
        -- InfusionOfThunder
        -- Spire

        -- Rotation4
        -- SpeedFocus
        -- Dichotomic
        -- DrunkenMonkeyStyle
        -- SwiftTail
        -- InfusionOfThunder
        -- Spire
        -- TonPo

        -- EarthForce and EyeOfTheStorm in between

    local function mapAbilities()

        self.Offensive = {
            [1] = {[self.Common.ZanFi] = function() return true end},
            [2] = {[self.Common.VehementRage] = function()
                if mq.TLO.Me.Song("Infusion of Thunder").ID() == 0 then
                    return true
                end
                return false
            end},
            [3] = {[self.Common.Intimidation] = function() return true end},
            [4] = {[self.Common.EyeOfTheStorm] = function() 
                if mq.TLO.Me.ActiveDisc.ID() == 0 then
                    return true
                end
                return false
            end},
            [5] = {[self.Common.Synergy] = function() return true end},
            [6] = {[self.Common.Curse] = function()
                local targetBuff = mq.TLO.Target.Buff(self.Common.Curse).ID() or 0
        
                if targetBuff > 0 then
                    return true
                end
                return false
            end},
            [7] = {[self.Common.Fang] = function() return true end},
            [8] = {[self.Common.Fists] = function() return true end},
            [9] = {[self.Common.Precision1] = function() return true end},
            [10] = {[self.Common.Precision2] = function() return true end},
            [11] = {[self.Common.Precision3] = function() return true end},
            [12] = {[self.Common.BP] = function() return true end},
        }

        self.OffensiveRotation1 = {
            [1] = {[self.Common.SwiftTail] = function()
                local myBuff = mq.TLO.Me.Buff(self.Common.SwiftTail).ID() or 0
                local ready = self.preCheckDisc(self.Common.Iron)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck and myBuff == 0 then
                    if mq.TLO.Me.PctEndurance() < 80 then
                        return true
                    end
                end
                return false
            end},
            [1] = {[self.Common.Dichotomic] = function()
                local ready = self.preCheckDisc(self.Common.Iron)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck then
                    return true
                end
                return false
            end},
            [2] = {[self.Common.Iron] = function()
                local ready = self.preCheckDisc(self.Common.Iron)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck then 
                    return true
                end
                return false
            end},
            [3] = {[self.Common.Synergy] = function() return true end},
            [4] = {[self.Common.FivePointPalm] = function()
                local ready = self.preCheckDisc(self.Common.Iron)
                local hpCheck = self.preCheckHP()
        
                if ready and hpCheck then
                    return true
                end
                return false
            end},
            [5] = {[self.Common.CraneStance] = function()
                local ready = self.preCheckDisc(self.Common.Iron)
                local hpCheck = self.preCheckHP()
                local targetBuff = mq.TLO.Target.Buff(self.Common.Synergy).ID() or 0
        
                if ready and hpCheck and targetBuff > 0 then
                    return true
                end
                return false
            end},
        }


        self.OffensiveRotation2 = {
            [1] = {[self.Common.SwiftTail] = function()
                local myBuff = mq.TLO.Me.Buff(self.Common.SwiftTail).ID() or 0
                local ready = self.preCheckDisc(self.Common.TerrorPalm)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck then
                    if myBuff == 0 then
                        if mq.TLO.Me.PctEndurance() < 80 then
                            return true
                        end
                    end
                end
                return false
            end},
            [2] = {[self.Common.Dichotomic] = function()
                local ready = self.preCheckDisc(self.Common.TerrorPalm)
                local hpCheck = self.preCheckHP()
    
                if ready and hpCheck then
                    return true
                end
                return false
            end},
            [3] = {[self.Common.TerrorPalm] = function()
                local hpCheck = self.preCheckHP()
                local ready = self.preCheckDisc(self.Common.TerrorPalm)

                if ready and hpCheck then
                    return true
                end
                return false
            end},
            [4] = {[self.Common.DrunkenMonkeyStyle] = function()
                local myBuff = mq.TLO.Me.Buff(self.Common.DrunkenMonkeyStyle).ID() or 0
                local ready = self.preCheckDisc(self.Common.TerrorPalm)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck then
                    if myBuff == 0 then
                        if mq.TLO.Me.PctEndurance() > 20 then
                            return true
                        end
                    end
                end
                return false
            end},
            [5] = {[self.Common.FocusedDestructiveForce] = function()
                local hpCheck = self.preCheckHP()
                local ready = self.preCheckDisc(self.Common.TerrorPalm)

                if ready and hpCheck then
                    return true
                end
                return false
            end},
            [6] = {[self.Common.TigersPoise] = function()
                local hpCheck = self.preCheckHP()
                local ready = self.preCheckDisc(self.Common.TerrorPalm)

                if ready and hpCheck then
                    return true
                end
                return false
            end},
            [7] = {[self.Common.FivePointPalm] = function()
                local hpCheck = self.preCheckHP()
                local ready = self.preCheckDisc(self.Common.TerrorPalm)
                
                if ready and hpCheck then
                    return true
                end
                return false
            end},
            [8] = {[self.Common.CraneStance] = function()
                local hpCheck = self.preCheckHP()
                local targetBuff = mq.TLO.Target.Buff(self.Common.Synergy).ID() or 0
                local ready = self.preCheckDisc(self.Common.TerrorPalm)
                
                if ready and hpCheck and targetBuff > 0 then
                    return true
                end
                return false
            end},
        }

        self.OffensiveRotation3 = {
            [1] = {[self.Common.SwiftTail] = function()
                local myBuff = mq.TLO.Me.Buff(self.Common.SwiftTail).ID() or 0
                local ready = self.preCheckDisc(self.Common.Heel)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck then
                    if myBuff == 0 then
                        if mq.TLO.Me.PctEndurance() < 80 then
                            return true
                        end
                    end
                end
                return false
            end},
            [2] = {[self.Common.Dichotomic] = function()
                local ready = self.preCheckDisc(self.Common.Heel)
                local hpCheck = self.preCheckHP()
    
                if ready and hpCheck then
                    return true
                end
                return false
            end},
            [3] = {[self.Common.Heel] = function()
                local hpCheck = self.preCheckHP()
                local ready = self.preCheckDisc(self.Common.Heel)

                if ready and hpCheck then
                    return true
                end
                return false
            end},
            [4] = {[self.Common.DrunkenMonkeyStyle] = function()
                local myBuff = mq.TLO.Me.Buff(self.Common.DrunkenMonkeyStyle).ID() or 0
                local ready = self.preCheckDisc(self.Common.Heel)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck then
                    if myBuff == 0 then
                        if mq.TLO.Me.PctEndurance() > 20 then
                            return true
                        end
                    end
                end
                return false
            end},
            [5] = {[self.Common.InfusionOfThunder] = function()
                local ready = self.preCheckDisc(self.Common.Heel)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck then
                    if myBuff == 0 then
                        if mq.TLO.Me.PctEndurance() > 20 then
                            return true
                        end
                    end
                end
                return false
            end},
            [6] = {[self.Common.Spire] = function()
                local ready = self.preCheckDisc(self.Common.Heel)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck then
                    if myBuff == 0 then
                        if mq.TLO.Me.PctEndurance() > 20 then
                            return true
                        end
                    end
                end
                return false
            end},
            [7] = {[self.Common.FivePointPalm] = function()
                local hpCheck = self.preCheckHP()
                local ready = self.preCheckDisc(self.Common.Heel)
                
                if ready and hpCheck then
                    return true
                end
                return false
            end},
            [8] = {[self.Common.CraneStance] = function()
                local hpCheck = self.preCheckHP()
                local targetBuff = mq.TLO.Target.Buff(self.Common.Synergy).ID() or 0
                local ready = self.preCheckDisc(self.Common.Heel)
                
                if ready and hpCheck and targetBuff > 0 then
                    return true
                end
                return false
            end},
        }

        self.OffensiveRotation4 = {
            [1] = {[self.Common.SwiftTail] = function()
                local myBuff = mq.TLO.Me.Buff(self.Common.SwiftTail).ID() or 0
                local ready = self.preCheckDisc(self.Common.SpeedFocus)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck then
                    if myBuff == 0 then
                        if mq.TLO.Me.PctEndurance() < 80 then
                            return true
                        end
                    end
                end
                return false
            end},
            [2] = {[self.Common.Dichotomic] = function()
                local ready = self.preCheckDisc(self.Common.SpeedFocus)
                local hpCheck = self.preCheckHP()
    
                if ready and hpCheck then
                    return true
                end
                return false
            end},
            [3] = {[self.Common.SpeedFocus] = function()
                local hpCheck = self.preCheckHP()
                local ready = self.preCheckDisc(self.Common.SpeedFocus)

                if ready and hpCheck then
                    return true
                end
                return false
            end},
            [4] = {[self.Common.DrunkenMonkeyStyle] = function()
                local myBuff = mq.TLO.Me.Buff(self.Common.DrunkenMonkeyStyle).ID() or 0
                local ready = self.preCheckDisc(self.Common.SpeedFocus)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck then
                    if myBuff == 0 then
                        if mq.TLO.Me.PctEndurance() > 20 then
                            return true
                        end
                    end
                end
                return false
            end},
            [5] = {[self.Common.InfusionOfThunder] = function()
                local ready = self.preCheckDisc(self.Common.SpeedFocus)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck then
                    if myBuff == 0 then
                        if mq.TLO.Me.PctEndurance() > 20 then
                            return true
                        end
                    end
                end
                return false
            end},
            [6] = {[self.Common.Spire] = function()
                local ready = self.preCheckDisc(self.Common.SpeedFocus)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck then
                    if myBuff == 0 then
                        if mq.TLO.Me.PctEndurance() > 20 then
                            return true
                        end
                    end
                end
                return false
            end},
            [7] = {[self.Common.TonPo] = function()
                local ready = self.preCheckDisc(self.Common.SpeedFocus)
                local hpCheck = self.preCheckHP()

                if ready and hpCheck then
                    if myBuff == 0 then
                        if mq.TLO.Me.PctEndurance() > 20 then
                            return true
                        end
                    end
                end
                return false
            end},
            [8] = {[self.Common.FivePointPalm] = function()
                local hpCheck = self.preCheckHP()
                local ready = self.preCheckDisc(self.Common.SpeedFocus)
                
                if ready and hpCheck then
                    return true
                end
                return false
            end},
            [9] = {[self.Common.CraneStance] = function()
                local hpCheck = self.preCheckHP()
                local targetBuff = mq.TLO.Target.Buff(self.Common.Synergy).ID() or 0
                local ready = self.preCheckDisc(self.Common.SpeedFocus)
                
                if ready and hpCheck and targetBuff > 0 then
                    return true
                end
                return false
            end},
        }


        self.Defensive = {
            [1] = {[self.Common.Mend] = function()
                if mq.TLO.Me.PctHPs() < 65 then
                    return true
                end
                return false
            end},
            [2] = {[self.Common.RejectDeath] = function()
                if mq.TLO.Me.PctHPs() < 40 then
                    return true
                end
                return false
            end},
            [3] = {[self.Common.EarthForce] = function()
                if mq.TLO.Me.PctHPs() < 50 then
                    return true
                end
                return false
            end},
            [4] = {[self.Common.SelfCure] = function()
                if mq.TLO.Me.Poisoned.ID() then return true end
                if mq.TLO.Me.Diseased.ID() then return true end
                if mq.TLO.Me.Cursed.ID() then return true end
                if mq.TLO.Me.Corrupted.ID() then return true end
                if mq.TLO.Me.Snared.ID() then return true end
                if mq.TLO.Me.Mezzed.ID() then return true end
                if mq.TLO.Me.Charmed.ID() then return true end
                return false
            end},
            [5] = {[self.Common.ShadedStep] = function()
                if mq.TLO.Me.PctHPs() < 50 and mq.TLO.ActiveDisc.ID() ~= mq.TLO.Spell(self.Common.EarthForce).ID() and mq.TLO.ActiveDisc.ID() ~= mq.TLO.Spell(self.Common.RejectDeath).ID() then
                    return true
                end
                return false
            end},
        }

        self.PullsDefensive = deepCopy(self.Defensive)

        self.PullsTag = {
            [1] = {[self.Common.DistantStrike] = function() return true end},
        }

        self.PullsMove = {
            [1] = {[self.Common.MovingMountains] = function() return true end},
        }

        self.Debuffs = {
            [1] = {[self.Common.WaspTouch] = function()
                local targetBuff = mq.TLO.Target.Buff(self.Common.WaspTouch).ID() or 0
                
                if targetBuff == 0 then
                    return true
                end
                return false
            end},
        }

        self.selfBuffs = {
            [1] = {[self.Common.Aura] = function() return true end},
        }

        self.Utility = {
            [1] = {[self.Common.FeignDeath] = function()
                local mt = mq.TLO.Group.MainTank.ID() or 0
        
                if mq.TLO.Me.PctAggro() > 90 or mq.TLO.Me.PctHPs() < 30 then
                    if mq.TLO.Spawn("id " .. mt .. " pccorpse radius 60").ID() > 0 then
                        return true
                    end
                end
                return false
            end},
            [2] = {[self.Common.ImitateDeath] = function()
                local mt = mq.TLO.Group.MainTank.ID() or 0
        
                if mq.TLO.Me.PctAggro() > 90 or mq.TLO.Me.PctHPs() < 30 then
                    if not mq.TLO.Me.AbilityReady(self.Common.FEIGNDEATH)() then
                        if mq.TLO.Spawn("id " .. mt .. " pccorpse radius 60").ID() > 0 then
                            return true
                        end
                    end
                end
                return false
            end},
            [3] = {[self.Common.Breaths] = function()
                if mq.TLO.Me.XTarget() == 0 then
                    if mq.TLO.Me.Endurance() < 80 then
                        return true
                    end
                end
                return false
            end},
            [4] = {[self.Common.Breather] = function()
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

    end

    function self.setAbilities()
        self.setAllAbilities(abilitiesTable)
        mapAbilities()

        self.setPullingObservers()
        self.setupMeleeSkills()
    end

    return self
end