local mq = require('mq')
local Write = require('lib/Write')
local priest = require('eqaddict/classutils/priest')

Cleric = {}
Cleric.new = function(name, class)
    local self = Priest.new(name, class)

    local abilitiesTable = {

        -- Travel stuff
        GroupInvis = "Group Perfected Invisibility to Undead",

        -- Group buffs
        GroupHP = self.getSpells({name = "Unified Hand of", category = "HP Buffs", subcategory = "Aegolism"}),

        -- Group cures
        GroupCureAA1 = "Radiant Cure",
        GroupCureAA2 = "Group Purify Soul",
        GroupCureAA3 = "Ward of Purity",

        -- Single target cures
        PurifySoul = "Purify Soul",

        -- Self buffs
        SaintsUnity = "Saint's Unity",
--        Armor = "Armor of the Ardent",

        -- Self utility
        SelfCureAA = "Purified Spirits",
        SelfInvis = "Innate Invis to Undead",
        SingleFade1 = "Divine Peace",
        SingleFade2 = "Sanctuary",
        ForcefulRejuvenation = "Forceful Rejuvenation",

        -- Spells in gems
        Sound = self.getSpells({name = "Sound", category = "Direct Damage", subcategory = "Stun"}),
        Contravention = self.getSpells({name = "Contravention", category = "Heals", subcategory = "Misc"}),
        Fortress = self.getSpells({name = "Shining", category = "Utility Beneficial", subcategory = "Melee Guard"}),
        Ward = self.getSpells({name = "Ward", category = "Utility Beneficial", subcategory = "Melee Guard"}),
        Promised = self.getSpells({name = "Promised", category = "Heals", subcategory = "Delayed"}),
        Remedy1 = self.getSpells({name = "Remedy", category = "Heals", subcategory = "Quick Heal", index = 1}),
        Remedy2 = self.getSpells({name = "Remedy", category = "Heals", subcategory = "Quick Heal", index = 2}),
        Remedy3 = self.getSpells({name = "Remedy", category = "Heals", subcategory = "Quick Heal", index = 3}),
        Intervention1 = self.getSpells({name = "Intervention", category = "Heals", subcategory = "Misc", index = 1}),
        Intervention2 = self.getSpells({name = "Intervention", category = "Heals", subcategory = "Misc", index = 2}),
        Intervention3 = self.getSpells({name = "Intervention", category = "Heals", subcategory = "Misc", index = 3}),
        Syllable = self.getSpells({name = "Syllable", category = "Heals", subcategory = "Heals"}),
        Word = self.getSpells({name = "Word", category = "Heals", subcategory = "Heals"}),

        -- Items
        BP = mq.TLO.Me.Inventory(17).Name(),

        -- Offensive AAs
        CelestialHammer = "Celestial Hammer",
        TurnUndead = "Turn Undead",
        
        
        -- Offensive misc
        BattleFrenzy = "Battle Frenzy",
        DivineAvatar = "Divine Avatar",
        Yaulp = "Yaulp",

        -- Burns
        SilentCasting = "Silent Casting",
        ExquisiteBenediction = "Exquisite Benediction", -- aoe heal aura
        SpireOfTheVicar = "Spire Of The Vicar",

        -- CC
        Root = "Blessed Chains",


        -- Rezz
        SingleRezz1 = "Divine Resurrection",
        SingleRezz2 = "Blessing of Resurrection",
        CombatRezz = "Call of the Herald",
        GroupRezz = self.getSpells({name = "Reviviscence", category = "Heals", subcategory = "Resurrection"}),

        -- AA heal
        BeaconOfLife = "Beacon of Life", -- 100 radius aoe
        BlessingOfSanctuary = "Blessing of Sanctuary", -- other than Tank heal (wipes aggro)
        BurstOfLife = "Burst of Life", -- 3 min cooldown!
        CelestialRegeneration = "Celestial Regeneration", -- aoe regane 200 feet
        DivineArbitration = "Divine Arbitration",  -- balance group HP
        FocusedCelestialRegeneration = "Focused Celestial Regeneration", -- single target regen 5 min recast
        QuietPrayer = "Quiet Prayer", -- trash... cost 30k mana to give 30k hp and 30k mana


        -- AA healing buff
        HealingFrenzy = "Healing Frenzy", -- more heal crits
        CelestialRapidity = "Celestial Rapidity", -- faster heals and nukes
        ChannelingTheDivine = "Channeling the Divine", -- twincast healings
        FlurryOfLife = "Flurry of Life", -- insta healing buff


        -- Utility
        Gate = "Gate",
        Leap = "Holy Step",
        DivineGuardian = "Divine Guardian", -- for tank
        TwinCast = "Improved Twincast",
        DivineRetribution = "Divine Retribution", -- Self tanking
        RepelTheWicked = "Repel The Wicked", -- Push target back and they forget attackers
        Perseverance = "Veturika's Perseverance",


        -- Aura
        Aura1 = self.getSpells({name = "Aura", category = "Auras", subcategory = "Melee Guard"}),
        Aura2 = self.getSpells({name = "Aura", category = "Auras", subcategory = "HP Buffs"}),
    }
    

    local function loadSpells()
        self.originalSpellSet = {
            [1] = self.Common.Remedy3,
            [2] = self.Common.Remedy2,
            [3] = self.Common.Remedy1,
            [4] = self.Common.Intervention1,
            [5] = self.Common.Intervention2,
            [6] = self.Common.Intervention3,
            [7] = self.Common.Promised,
            [8] = self.Common.Syllable,
            [9] = self.Common.Word,
            [10] = self.Common.Sound,
            [11] = self.Common.Contravention,
            [12] = self.Common.Fortress,
            [13] = self.Common.Ward
        }
        for k,v in pairs(self.originalSpellSet) do
            self.loadSpellGem(v, k)
        end
    end

    local function mapAbilities()

        self.Offensive = {
            [1] = {[self.Common.Yaulp] = function() return true end},
            [2] = {[self.Common.TwinCast] = function()
                local worstHurtID = self.getHealTarget(75)
                local targetType = mq.TLO.Target.Type() or "PC"

                if worstHurtID == 0 then
                    if targetType == "NPC" then
                        return true 
                    end
                end
                return false
            end},
            [3] = {[self.Common.TurnUndead] = function() 
                local targetID = mq.TLO.Target.ID() or 0

                if targetID > 0 then
                    if mq.TLO.Target.Type() == "NPC" and mq.TLO.Target.Body.Name() == "Undead" then
                        return true
                    end
                end
                return false
            end},
            [4] = {[self.Common.BattleFrenzy] = function() return true end},
            [5] = {[self.Common.DivineAvatar] = function() return true end},
            [6] = {[self.Common.CelestialHammer] = function() return true end},
            [7] = {[self.Common.Sound] = function()
                local worstHurtID = self.getHealTarget(75)
                local targetType = mq.TLO.Target.Type() or "PC"

                if worstHurtID == 0 then
                    if targetType == "NPC" then
                        return true 
                    end
                end
                return false
            end},
            [8] = {[self.Common.Contravention] = function()
                local worstHurtID = self.getHealTarget(75)
                local targetType = mq.TLO.Target.Type() or "PC"

                if worstHurtID == 0 then
                    if targetType == "NPC" then
                        return true 
                    end
                end
                return false
            end},
        }

        self.SingleHeals = {
            [1] = {[self.Common.BurstOfLife] = function()
                local worstHurtID = self.getHealTarget(80)

                if worstHurtID > 0 then
                    self.setTargetID(worstHurtID)
                    mq.cmdf('/target id %d', worstHurtID)
                    mq.delay(200)
                    return true 
                end
                return false
            end},
            [2] = {[self.Common.Remedy1] = function()
                local worstHurtID = self.getHealTarget(80)

                if worstHurtID > 0 then
                    if not mq.TLO.Me.SpellReady(self.Common.Remedy1)() then
                        self.activatePreCast(self.Common.ForcefulRejuvenation)
                    end
                    self.setTargetID(worstHurtID)
                    mq.cmdf('/target id %d', worstHurtID)
                    mq.delay(200)
                    return true 
                end
                return false
            end},
            [3] = {[self.Common.Remedy2] = function()
                local worstHurtID = self.getHealTarget(80)

                if worstHurtID > 0 then
                    self.setTargetID(worstHurtID)
                    mq.cmdf('/target id %d', worstHurtID)
                    mq.delay(200)
                    return true 
                end
                return false
            end},
            [4] = {[self.Common.Remedy3] = function()
                local worstHurtID = self.getHealTarget(80)

                if worstHurtID > 0 then
                    self.setTargetID(worstHurtID)
                    mq.cmdf('/target id %d', worstHurtID)
                    mq.delay(200)
                    return true 
                end
                return false
            end},
            [5] = {[self.Common.BlessingOfSanctuary] = function()
                -- other than Tank heal (wipes aggro)
                local tankID = mq.TLO.Group.MainTank.ID() or 0
                local worstHurtID = self.getHealTarget(80)

                if mq.TLO.Me.XTarget() > 0 then
                    if worstHurtID > 0 and mq.TLO.Spawn("id " .. worstHurtID).ID() ~= tankID then
                        self.setTargetID(worstHurtID)
                        mq.cmdf('/target id %d', worstHurtID)
                        mq.delay(200)
                        return true
                    end
                end
                return false
            end},
            [6] = {[self.Common.Intervention1] = function()
                local worstHurtID = self.getHealTarget(80)

                if worstHurtID > 0 then
                    self.setTargetID(worstHurtID)
                    mq.cmdf('/target id %d', worstHurtID)
                    mq.delay(200)
                    return true 
                end
                return false
            end},
            [7] = {[self.Common.Intervention2] = function()
                local worstHurtID = self.getHealTarget(80)

                if worstHurtID > 0 then
                    self.setTargetID(worstHurtID)
                    mq.cmdf('/target id %d', worstHurtID)
                    mq.delay(200)
                    return true 
                end
                return false
            end},
            [8] = {[self.Common.Intervention3] = function()
                local worstHurtID = self.getHealTarget(80)

                if worstHurtID > 0 then
                    self.setTargetID(worstHurtID)
                    mq.cmdf('/target id %d', worstHurtID)
                    mq.delay(200)
                    return true 
                end
                return false
            end},
            [9] = {[self.Common.Promised] = function()
                local worstHurtID = self.getHealTarget(95)

                if mq.TLO.Me.XTarget() > 0 then
                    if mq.TLO.Spawn("id " .. worstHurtID).ID() == mq.TLO.Group.MainTank.ID() then
                        if mq.TLO.Spawn("id " .. worstHurtID).PctHPs() > 70 then
                            self.setTargetID(worstHurtID)
                            mq.cmdf('/target id %d', worstHurtID)
                            mq.delay(200)
                            return true 
                        end
                    end
                end
                return false
            end},
            [10] = {[self.Common.FocusedCelestialRegeneration] = function()
                -- single target regen 5 min recast
                local tankID = mq.TLO.Group.MainTank.ID() or 0
                local tankPctHps = mq.TLO.Spawn("id " .. tankID).PctHPs() or 100
                local tankPctHpsThreshold = 95

                if tankID > 0 then
                    if tankPctHps < tankPctHpsThreshold then
                        self.setTargetID(tankID)
                        mq.cmdf('/target id %d', tankID)
                        mq.delay(200)
                        return true
                    end
                end
                return false
            end},
        }

        self.GroupHeals = {
            [1] = {[self.Common.BP] = function()
                local hurtCount = self.getGroupHealCount(90, 1, 200)

                if mq.TLO.Me.XTarget() > 0 then
                    if hurtCount > 0 then
                        return true
                    end
                end
                return false
            end},
            [2] = {[self.Common.BeaconOfLife] = function()
                local hurtCountLimit = 3
                local hurtCount = self.getGroupHealCount(60, hurtCountLimit, 100)

                if hurtCount > hurtCountLimit then
                    return true
                end
                return false
            end},
            [3] = {[self.Common.Syllable] = function()
                local hurtCountLimit = 3
                local hurtCount = self.getGroupHealCount(60, hurtCountLimit, 100)

                if hurtCount > hurtCountLimit then
                    return true
                end
                return false
            end},
            [4] = {[self.Common.Word] = function()
                local hurtCountLimit = 3
                local hurtCount = self.getGroupHealCount(60, hurtCountLimit, 100)

                if hurtCount > hurtCountLimit then
                    return true
                end
                return false
            end},
            [5] = {[self.Common.CelestialRegeneration] = function()
                local hurtCountLimit = 3
                local hurtCount = self.getGroupHealCount(80, hurtCountLimit, 200)

                if hurtCount > hurtCountLimit then
                    return true
                end
                return false
            end},
            [6] = {[self.Common.DivineArbitration] = function()
                local hurtCountLimit = 3
                local hurtCount = self.getGroupHealCount(80, hurtCountLimit, 200)

                if hurtCount > hurtCountLimit then
                    return true
                end
                return false
            end}
        }

        self.PullsTag = {
            [1] = {[self.Common.Sound] = function() return true end},
        }

        self.groupBuffs = {
            [1] = {[self.Common.GroupHP] = function() return true end},
        }
        
        -- missing self cast armor buff!
        -- go buy saints unity spell
        self.selfBuffs = {
            [1] = {[self.Common.SaintsUnity] = function() return true end},
 --[[
            [2] = {[self.Common.Armor] = function() 
                if mq.TLO.Group() then
                    for i=1, tonumber(mq.TLO.Group()) do
                        if mq.TLO.Group.Member(i).Class.ShortName() == "SHM" then 
                            return false
                        end
                    end
                end

                return true end
            },
]]
            [2] = {[self.Common.Aura1] = function() return true end},
            [3] = {[self.Common.Aura2] = function() return true end},
        }


        self.Utility = {
            [1] = {[self.Common.ExquisiteBenediction] = function()
                local targetID = self.getXTargetNamedID()
                
                if targetID > 0 then
                    return true
                end
                return false
            end},
            [2] = {[self.Common.SpireOfTheVicar] = function()
                local targetID = self.getXTargetNamedID()
                
                if targetID > 0 then
                    return true
                end
                return false
            end},
            [3] = {[self.Common.SilentCasting] = function()
                local targetID = self.getXTargetNamedID()
                
                if targetID > 0 then
                    return true
                end
                return false
            end},
            [4] = {[self.Common.DivineRetribution] = function()
                -- self only tanking aa
                local targetID = self.getXTargetNamedID()
                
                if mq.TLO.Me.XTarget() > 0 then
                    if targetID > 0 then
                        return true
                    end
                    if mq.TLO.Me.PctHPs() < 40 then
                        return true
                    end
                end
                return false
            end},
            [5] = {[self.Common.SelfCureAA] = function()
                if selfValidateDebuffs() then return true end
                return false
            end},
            [6] = {[self.Common.Perseverance] = function()
                if mq.TLO.Me.PctMana() < 60 then
                    return true
                end
                return false
            end},
            [7] = {[self.Common.HealingFrenzy] = function()
                -- more heal crits
                local targetID = self.getXTargetNamedID()
                
                if targetID > 0 then
                    return true
                end
                return false
            end},
            [8] = {[self.Common.CelestialRapidity] = function()
                -- faster heals and nukes
                local targetID = self.getXTargetNamedID()
                
                if targetID > 0 then
                    return true
                end
                return false
            end},
            [9] = {[self.Common.ChannelingTheDivine] = function()
                -- twincast healings
                local targetID = self.getXTargetNamedID()
                
                if targetID > 0 then
                    return true
                end
                return false
            end},
            [10] = {[self.Common.FlurryOfLife] = function()
                -- insta healing buff
                local targetID = self.getXTargetNamedID()
                
                if targetID > 0 then
                    return true
                end
                return false
            end},
            [11] = {[self.Common.PurifySoul] = function()
                local value

                for k,v in ipairs(self.priestObserverCureTable) do
                    value = mq.TLO.DanNet(k).O(v)() or 0
                    if value > 0 then
                        targetID = mq.TLO.Spawn(k).ID()
                        self.setTargetID(targetID)
                        mq.cmdf('/target id %d', targetID)
                        mq.delay(200)
                        return true 
                    end
                end
                return false
            end},
            [12] = {[self.Common.DivineGuardian] = function()
                local targetID = self.getXTargetNamedID()
                local tankID = mq.TLO.Group.MainTank.ID() or 0

                if mq.TLO.Me.XTarget() > 2 or targetID > 0 then
                    if tankID > 0 then
                        self.setTargetID(tankID)
                        mq.cmdf('/target id %d', tankID)
                        mq.delay(200)
                        return true
                    end
                end
                return false
            end},
            [13] = {[self.Common.SingleFade1] = function()
                if mq.TLO.Me.XTarget() > 0 then
                    if mq.TLO.SpawnCount("pccorpse radius 150")() >= 3 then
                        return true
                    end
                end
                return false
            end},
            [14] = {[self.Common.SingleFade2] = function()
                if mq.TLO.Me.XTarget() > 0 then
                    if mq.TLO.SpawnCount("pccorpse radius 150")() >= 3 then
                        return true
                    end
                end
                return false
            end},

            -- QuietPrayer = "Quiet Prayer", -- trash... cost 30k mana to give 30k hp and 30k mana
        }

        self.tankBuffs = {
            [1] = {[self.Common.Fortress] = function() 
                local targetID = mq.TLO.Target.ID() or 0
                local tankID = mq.TLO.Group.MainTank.ID() or 0
                local tankHPs = mq.TLO.Spawn("id " .. targetID).PctHPs() or 100

                if tankID > 0 then
                    if tankHPs > 85 then
                        if targetID ~= tankID then
                            mq.cmdf('/target id %d', tankID)
                            mq.delay(200)
                        end
                        self.setTargetID(tankID)
                        return true
                    end
                end

                return false
            end},
            [2] = {[self.Common.Ward] = function() 
                local targetID = mq.TLO.Target.ID() or 0
                local tankID = mq.TLO.Group.MainTank.ID() or 0

                if tankID > 0 then
                    if targetID ~= tankID then
                        mq.cmdf('/target id %d', tankID)
                        mq.delay(200)
                        targetID = tankID
                    end
                    if mq.TLO.Spawn("id " .. targetID).PctHPs() > 85 then
                        self.setTargetID(tankID)
                        return true
                    end
                end

                return false
            end},
        }

        self.Rezz = {
            [1] = {[self.Common.SingleRezz1] = function()
                local targetID = mq.TLO.Target.ID() or 0

                if mq.TLO.Me.XTarget() > 0 then return false end

                if mq.TLO.SpawnCount("pccorpse radius 150")() > 0 and mq.TLO.SpawnCount("pccorpse radius 150")() <= 2 then
                    self.loadSpellGem(self.Common.SingleRezz, 8)
                    
                    local corpseID = mq.TLO.NearestSpawn(1, "pccorpse radius 150").ID()
                    local corpseDist = mq.TLO.NearestSpawn(1, "pccorpse radius 25").ID() or 0

                    if targetID ~= corpeID then mq.cmdf("/target %d", corpseID) mq.delay(500) end
                    if corpseDist == 0 then mq.cmdf("/corpse") end

                    return true
                end

                return false
            end},
            [2] = {[self.Common.SingleRezz2] = function()
                local targetID = mq.TLO.Target.ID() or 0

                if mq.TLO.Me.XTarget() > 0 then return false end

                if mq.TLO.SpawnCount("pccorpse radius 150")() > 0 and mq.TLO.SpawnCount("pccorpse radius 150")() <= 2 then
                    self.loadSpellGem(self.Common.SingleRezz, 8)
                    
                    local corpseID = mq.TLO.NearestSpawn(1, "pccorpse radius 150").ID()
                    local corpseDist = mq.TLO.NearestSpawn(1, "pccorpse radius 25").ID() or 0

                    if targetID ~= corpeID then mq.cmdf("/target %d", corpseID) mq.delay(500) end
                    if corpseDist == 0 then mq.cmdf("/corpse") end

                    return true
                end

                return false
            end},
            [3] = {[self.Common.CombatRezz] = function()
                local targetID = mq.TLO.Target.ID() or 0

                if mq.TLO.Me.XTarget() == 0 then return false end

                if mq.TLO.SpawnCount("pccorpse radius 150")() > 0 then

                    local corpseID = mq.TLO.NearestSpawn(1, "pccorpse radius 150").ID()
                    local corpseDist = mq.TLO.NearestSpawn(1, "pccorpse radius 25").ID() or 0

                    if targetID ~= corpeID then mq.cmdf("/target %d", corpseID) mq.delay(500) end
                    if corpseDist == 0 then mq.cmdf("/corpse") end

                    return true
                end

                return false
            end},
            [4] = {[self.Common.GroupRezz] = function()
                local targetID = mq.TLO.Target.ID() or 0
                local corpseDist
                local corpseID

                if mq.TLO.Me.XTarget() > 0 then return false end

                if mq.TLO.SpawnCount("pccorpse radius 150")() > 2 then

                    for i=1, mq.TLO.SpawnCount("pccorpse radius 150")() do
                        corpseID = mq.TLO.NearestSpawn(i, "pccorpse radius 150").ID()
                        if targetID ~= corpeID then mq.cmdf("/target %d", corpseID) mq.delay(500) end
                        corpseDist = mq.TLO.NearestSpawn(i, "pccorpse radius 25").ID() or 0
                        if corpseDist == 0 then mq.cmdf("/corpse") end
                        mq.delay(500)
                    end

                    return true
                end

                return false
            end},
        }

        self.GroupCures = {
            [1] = {[self.Common.GroupCureAA1] = function()
                local value

                for k,v in ipairs(self.priestObserverCureTable) do
                    value = mq.TLO.DanNet(k).O(v)() or 0
                    if value > 0 then
                        return true
                    end
                end
                return false
            end},
            [2] = {[self.Common.GroupCureAA2] = function()
                local value

                for k,v in ipairs(self.priestObserverCureTable) do
                    value = mq.TLO.DanNet(k).O(v)() or 0
                    if value > 0 then
                        return true
                    end
                end
                return false
            end},
            [3] = {[self.Common.GroupCureAA3] = function()
                local value

                for k,v in ipairs(self.priestObserverCureTable) do
                    value = mq.TLO.DanNet(k).O(v)() or 0
                    if value > 0 then
                        return true
                    end
                end
                return false
            end},
        }
    
    end

    function self.setAbilities()
        self.setAllAbilities(abilitiesTable)
        loadSpells()
        mapAbilities()

        self.setCureObservers()
        self.setTankBuffObservers()
        self.setGroupBuffObservers()
        self.setPullingObservers()

        self.setAssistAt(98)
        self.setupMeleeSkills()
    end

    return self
end

-- And coroutines are useful for saving state, executing code asynch, then going back to that state
-- You can do neat things with them, but you can also completely ignore them

--[[
        -- Travel stuff
        GroupInvis = "Group Perfected Invisibility to Undead",


        -- Self utility
        SelfInvis = "Innate Invis to Undead",


        -- CC
        Root = "Blessed Chains",


        -- Utility
        Gate = "Gate",
        Leap = "Holy Step",
        RepelTheWicked = "Repel The Wicked", -- Push target back and they forget attackers

]]