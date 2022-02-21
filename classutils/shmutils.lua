local mq = require('mq')
local Write = require('lib/Write')
local priest = require('eqaddict/classutils/priest')

Shaman = {}
Shaman.new = function(name, class)
    local self = Priest.new(name, class)

    local abilitiesTable = {

        -- Travel stuff
        GroupSpeed = "Communion of the Cheetah",
        GroupInvis = "Group Silent Presence",

        -- Group buffs
        GroupFocus = self.getSpells({name = "Talisman", category = "HP Buffs", subcategory = "Shielding"}),
        GroupHaste = "Talisman of Celerity",
        GroupSpeed = "Lupine Spirit",

        -- Renewal
        
        GroupRenewalHoT = self.getSpells({name = "Renewal", category = "Heals", subcategory = "Duration Heals"}),

        -- Group cures
        
        GroupCureSpell = self.getSpells({name = "Blood", category = "Heals", subcategory = "Cure"}),
        GroupCureAA = "Radiant Cure",

        -- Self buffs
        SelfPreincarnation = "Preincarnation",
        VisionarysUnity = "Visionary's Unity",

        -- Self utility
        SelfCureAA = "Purified Spirits",
        SelfInvis = "Silent Presence",
        SelfLevi = "Perfected Levitation",
        SingleFade = "Inconspicuous Totem",
        ForcefulRejuvenation = "Forceful Rejuvenation",

        -- Spells in gems
--        RecklessHeal1 = "Reckless Rejuvenation",
--        RecklessHeal2 = "Reckless Regeneration",
--        RecklessHeal3 = "Reckless Restoration",
--
--        RecourseHeal = "Eyrzekla's Recourse",
--        InterventionHeal = "Prehistoric Intervention",
--        AoESpiritualHeal = "Spiritual Squall",
--
--        DichoSpell = "Dissident Roar",
--
--        Jinx = "Jinx",
--        Curse = "Erogo's Curse",
--        Pandemic = "Vermistipus's Pandemic",
--        ChaoticPoisonDoT = "Chaotic Poison",

        RecklessHeal1 = self.getSpells({name = "Reckless", category = "Heals", subcategory = "Heals", index = 1}),
        RecklessHeal2 = self.getSpells({name = "Reckless", category = "Heals", subcategory = "Heals", index = 2}),
        RecklessHeal3 = self.getSpells({name = "Reckless", category = "Heals", subcategory = "Heals", index = 3}),

        RecourseHeal = self.getSpells({name = "Recourse", category = "Heals", subcategory = "Heals"}),
        InterventionHeal = self.getSpells({name = "Intervention", category = "Heals", subcategory = "Heals"}),

        DichoSpell = self.getSpells({name = "Roar", category = "Utility Beneficial", subcategory = "Combat Innates"}),

        Jinx = self.getSpells({category = "Damage Over Time", subcategory = "Magic", exclude = "Curse"}),
        Curse = self.getSpells({name = "Curse", category = "Damage Over Time", subcategory = "Magic"}),
        Pandemic = self.getSpells({name = "Pandemic", category = "Damage Over Time", subcategory = "Disease"}),
        ChaoticPoisonDoT = self.getSpells({name = "Chaotic", category = "Damage Over Time", subcategory = "Poison"}),

        -- Tank only buffs
        Incapacity = self.getSpells({category = "Utility Beneficial", subcategory = "Combat Innates", targettype = "Single"}),

        -- Items
        BP = mq.TLO.Me.Inventory(17).Name(),
        Epic = "Blessed Spiritstaff of the Heyokah",

        -- Offensive debuffs
        Malo = "Malaise",
        Slow = "Turgur's Swarm",
        
        -- Offensive aoe debuffs
        AoEMalo = "Wind of Malaise",
        AoESlow = "Turgur's Virulent Swarm",
        
        -- Offensive misc
        Nullify = "Improved Pure Spirit",
        SpiritCall = "Spirit Call",

        -- Burns
        SilentCasting = "Silent Casting",
        Arcanum = "Focus of Arcanum",
        Spire = "Spire of Ancestors",
        RabidBear = "Rabid Bear",
        DampenResistance = "Dampen Resistance",
        AncestralGuard = "Ancestral Guard", -- self only tanking aa

        -- CC
        Root = "Virulent Paralysis",
        ConeRoot = "Spiritual Rebuke",

        -- Pet
        CompanionsDA = "Companion's Intervening Divine Aura",
        CompanionsFort = "Companion's Fortification",
        CompanionsAegis = "Companion's Aegis",

        -- Rezz
        SingleRezz = "Rejuvenation of Spirit",
        CombatRezz = "Call of the Wild",

        -- AA heal
        UnionOfSpirits = "Union of Spirits",
        SpiritGuardian = "Spirit Guardian",
        InterventionAAHeal = "Soothsayer's Intervention",
        CallOfTheAncients = "Call of the Ancients",
        AncestralAid = "Ancestral Aid",

        -- AA healing buff
        FleetingSpirit = "Fleeting Spirit",
        SpiritualBlessing = "Spiritual Blessing",

        -- Utility
        Shrink = "Shrink",
        Gate = "Gate",
        Leap = "Spirit Leap",
        SpiritOfUrgency = "Spirit of Urgency",
        SpiritualChanneling = "Spiritual Channeling",
        GroupShrink = "Group Shrink",
        Canni = "Cannibalization",

        -- Aura
        Aura = "Pact of the Wolf"
    }
    
    --/lua parse mq.TLO.Me.Buff("Wulthan Focusing Rk. II").SpellGroup()
    --/lua parse mq.TLO.Spell("Jinx").SpellGroup()
    --/lua parse mq.TLO.Spell("Erogo's Curse").SpellGroup()
    --/lua parse mq.TLO.Spell("Sraskus' Curse").SpellGroup()

    --/lua parse mq.TLO.Spell("Erogo's Curse").RecastTimerID()
    --/lua parse mq.TLO.Spell("Sraskus' Curse").RecastTimerID()

    --/lua parse mq.TLO.Spell("Lupine Spirit").Category()
    --/lua parse mq.TLO.Spell("Lupine Spirit").SpellGroup()
    --/lua parse mq.TLO.Spell("Lupine Spirit").SpellType()
    --/lua parse mq.TLO.Spell("Lupine Spirit").Subcategory()
    --/lua parse mq.TLO.Spell("Lupine Spirit").SubSpellGroup()
    --/lua parse mq.TLO.Spell("Lupine Spirit"").SPA()
    --/lua parse mq.TLO.Spell(mq.TLO.Me.AltAbility("Lupine Spirit").Name()).GroupID()


    -- THI IS CORRECT
    --mq.TLO.AltAbility("Lupine Spirit").Spell.Trigger(1)
    
    -- the 1 is from
    --mq.TLO.AltAbility("Lupine Spirit").Spell.NumEffects()

    -- combined:
    --/lua parse mq.TLO.AltAbility("Lupine Spirit").Spell.Trigger(mq.TLO.AltAbility("Lupine Spirit").Spell.NumEffects())

    --
    --/lua parse mq.TLO.AltAbility("Lupine Spirit").Spell.NumEffects()
    --/lua parse mq.TLO.Spell("Talisman of the Wulthan").NumEffects()
    --/lua parse mq.TLO.Spell("Talisman of the Wulthan").Attrib(1) -- effectSPA
    --/lua parse mq.TLO.Spell("Talisman of the Wulthan").Trigger(1)

    

--[[

ME:
I could do something like mq.TLO.AltAbility("Lupine Spirit").Spell.Trigger(mq.TLO.AltAbility("Lupine Spirit").Spell.NumEffects()) to get the spell that the AA returns and do a dannetquery to my group members to see if they have it. How generalizable is this? Seem like it should be pretty good to go for all these kinds of AAs. Same logic probably for spells with just different TLO calls... I need to test how this reacts to other spells and AAs

var effectcount = mq.TLO.AltAbility("Lupine Spirit").Spell.NumEffects()
var spellname = nil
for i=1, effectcount do
  var effectSPA = mq.TLO.AltAbility("Lupine Spirit").Spell().Attrib(i)
  if (effectSPA == 470 || effectSPA == 374) //Best in group (470) or Trigger (374) ? How do you comment in LUA!
    spellname = mq.TLO.AltAbility("Lupine Spirit").Spell.Trigger(i)
  end

end
so first for any pspell you want to first see if it has the SPA 470 or 374. If it does, THEN check triggers.

after you for loop, you should have spellname defined (maybe that's a spelltype it's returning?) not sure how it works in lua
so the above psudo code could get be a function you use to check if you have a buff.


the Attrib returns the SPA of that slot.

if it triggers best in group, and that has triggers then you get each trigger from each attribute of the spell, then you can check that to see if you have the buff from each one, in a function that loops through each effect. 
    So instead of checking against a table for every single spell possible, you just ask the spell to give up the goods so you do less typing.
]]



-- Since DPG has unified the spells names starting from 100 (Unified Hand of X, Heel of Z, Vortex of Y) I think I can just loop over my spellbook and take the highest level that matches a string... maybe...
-- I believe I have some code in there to do something similar with timers: https://gitlab.com/redguides/plugins/MQ2FarmTest/-/blob/mqnext/MQ2FarmTest.cpp 1501 line

-- /echo ${Me.Book[1].RecastTimerID}
-- /echo ${Me.Book[1000]}
-- Spells would use spellicon and category and subcategory

-- /echo ${Me.CombatAbility[1]}
-- /echo ${Me.CombatAbility[1].RecastTimerID}



    local function loadSpells()
        self.originalSpellSet = {
            [1] = self.Common.RecklessHeal1,
            [2] = self.Common.RecklessHeal2,
            [3] = self.Common.RecklessHeal3,
            [4] = self.Common.GroupRenewalHoT,
            [5] = self.Common.RecourseHeal,
            [6] = self.Common.InterventionHeal,
            [7] = self.Common.GroupCureSpell,
            [8] = self.Common.DichoSpell,
            [9] = self.Common.Incapacity,
            [10] = self.Common.Jinx,
            [11] = self.Common.Curse,
            [12] = self.Common.Pandemic,
            [13] = self.Common.ChaoticPoisonDoT
        }
        for k,v in pairs(self.originalSpellSet) do
            self.loadSpellGem(v, k)
        end
    end

    local function mapAbilities()

        -- Chaotic Venin -> Bledrek's Pandemic -> Marlek's Curse -> Evil Eye
        self.Offensive = {
            [1] = {[self.Common.Epic] = function() return true end},
            [2] = {[self.Common.Arcanum] = function() return true end},
            [3] = {[self.Common.Spire] = function() return true end},
            [4] = {[self.Common.DichoSpell] = function() return true end},
            [5] = {[self.Common.ChaoticPoisonDoT] = function()
                local targetBuff = mq.TLO.Target.Buff(self.Common.ChaoticPoisonDoT).ID() or 0
                local targetType = mq.TLO.Target.Type() or "PC"

                if targetBuff == 0 and targetType == "NPC" then
                    return true 
                end
                return false
            end},
            [6] = {[self.Common.Pandemic] = function()
                local targetBuff = mq.TLO.Target.Buff(self.Common.Pandemic).ID() or 0
                local targetType = mq.TLO.Target.Type() or "PC"

                if targetBuff == 0 and targetType == "NPC" then
                    return true 
                end
                return false
            end},
            [7] = {[self.Common.Curse] = function()
                local targetBuff = mq.TLO.Target.Buff(self.Common.Curse).ID() or 0
                local targetType = mq.TLO.Target.Type() or "PC"

                if targetBuff == 0 and targetType == "NPC" then
                    return true 
                end
                return false
            end},
            [8] = {[self.Common.Jinx] = function()
                local targetBuff = mq.TLO.Target.Buff(self.Common.Jinx).ID() or 0
                local targetType = mq.TLO.Target.Type() or "PC"

                if targetBuff == 0 and targetType == "NPC" then
                    return true 
                end
                return false
            end},
            [9] = {[self.Common.Nullify] = function()
                local targetBeneficialBuffs = mq.TLO.Target.Beneficial.ID() or 0

                if targetBeneficialBuffs > 0 then
                    return true
                end
                return false
            end},
            [10] = {[self.Common.SpiritCall] = function() return true end},
            [11] = {[self.Common.RabidBear] = function() return true end},
        }

        self.SingleHeals = {
            [1] = {[self.Common.UnionOfSpirits] = function()
                local worstHurtID = self.getHealTarget(85)

                if mq.TLO.Me.XTarget() > 0 then
                    if worstHurtID > 0 then
                        self.setTargetID(worstHurtID)
                        mq.cmdf('/target id %d', worstHurtID)
                        mq.delay(200)
                        return true 
                    end
                end
                return false
            end},
            [2] = {[self.Common.RecklessHeal1] = function()
                local worstHurtID = self.getHealTarget(50)
        
                if worstHurtID > 0 then
                    self.setTargetID(worstHurtID)
                    mq.cmdf('/target id %d', worstHurtID)
                    mq.delay(200)
                    return true 
                end
                return false
            end},
            [3] = {[self.Common.RecklessHeal2] = function()
                local worstHurtID = self.getHealTarget(50)
        
                if worstHurtID > 0 then
                    self.setTargetID(worstHurtID)
                    mq.cmdf('/target id %d', worstHurtID)
                    mq.delay(200)
                    return true 
                end
                return false
            end},
            [4] = {[self.Common.RecklessHeal3] = function()
                local worstHurtID = self.getHealTarget(50)

                if worstHurtID > 0 then
                    self.setTargetID(worstHurtID)
                    mq.cmdf('/target id %d', worstHurtID)
                    mq.delay(200)
                    return true 
                end
                return false
            end},
            [5] = {[self.Common.GroupRenewalHoT] = function()
                local buffID = mq.TLO.Me.Song(self.Common.GroupRenewalHoT).ID() or 0

                if buffID == 0 then
                    return true
                end
                return false
            end},
            [6] = {[self.Common.InterventionHeal] = function()
                local worstHurtID = self.getHealTarget(40)

                if worstHurtID > 0 then
                    if not mq.TLO.Me.SpellReady(self.Common.InterventionHeal)() then
                        self.activatePreCast(self.Common.ForcefulRejuvenation)
                    end
                    return true 
                end
                return false
            end},
            [7] = {[self.Common.InterventionAAHeal] = function()
                local worstHurtID = self.getHealTarget(50)

                if worstHurtID > 0 then
                    self.setTargetID(worstHurtID)
                    mq.cmdf('/target id %d', worstHurtID)
                    mq.delay(200)
                    return true 
                end
                return false
            end},
        }

        self.GroupHeals = {
            [1] = {[self.Common.RecourseHeal] = function()
                local hurtCountLimit = 3
                local hurtCount = self.getGroupHealCount(60, hurtCountLimit, 100)

                if hurtCount > hurtCountLimit then
                    return true 
                end
                return false
            end},
            [2] = {[self.Common.BP] = function()
                local hurtCountLimit = 3
                local hurtCount = self.getGroupHealCount(60, hurtCountLimit, 100)
                local worstHurtID = self.getHealTarget(40)

                if worstHurtID > 0 or hurtCount > hurtCountLimit then
                    return true 
                end
                return false
            end},
            [3] = {[self.Common.CallOfTheAncients] = function()
                local targetID = self.getXTargetNamedID()

                if targetID > 0 then
                    return true 
                end
                return false
            end},
            [4] = {[self.Common.AncestralAid] = function()
                local targetID = self.getXTargetNamedID()

                if targetID > 0 then
                    return true 
                end
                return false
            end}
        }

        self.Debuffs = {
            [1] = {[self.Common.AoEMalo] = function()
                local malosinata = mq.TLO.Target.Buff("Malosinata").ID() or 0
                local malo = mq.TLO.Target.Buff(self.Common.AoEMalo).ID() or 0
                local maloed = mq.TLO.Target.Maloed.ID() or 0
                local targetX = mq.TLO.Target.X() or 0
                local targetY = mq.TLO.Target.Y() or 0
                local targetID = self.getXTargetNamedID()

                if targetID > 0 then
                    self.activatePreCast(self.Common.DampenResistance)
                end

                if mq.TLO.Me.XTarget() >= 2 then
                    if mq.TLO.SpawnCount(string.format('npc targetable loc %d %d radius %d', targetX, targetY, 30))() >= 2 then
                        if malosinata == 0 and malo == 0 and maloed == 0 then
                            return true
                        end
                    end
                end
                return false
            end},
            [2] = {[self.Common.AoESlow] = function()
                local slowed = mq.TLO.Target.Slowed.ID() or 0
                local slow = mq.TLO.Target.Buff(self.Common.AoESlow).ID() or 0
                local targetX = mq.TLO.Target.X() or 0
                local targetY = mq.TLO.Target.Y() or 0
                local targetID = self.getXTargetNamedID()

                if targetID > 0 then
                    self.activatePreCast(self.Common.DampenResistance)
                end

                if mq.TLO.Me.XTarget() >= 2 then
                    if mq.TLO.SpawnCount(string.format('npc targetable loc %d %d radius %d', targetX, targetY, 30))() >= 2 then
                        if slowed == 0 and slow == 0 then
                            return true
                        end
                    end
                end
                return false
            end},
            [3] = {[self.Common.Malo] = function()
                local malosinata = mq.TLO.Target.Buff("Malosinata").ID() or 0
                local malo = mq.TLO.Target.Buff(self.Common.Malo).ID() or 0
                local maloed = mq.TLO.Target.Maloed.ID() or 0
                local targetID = self.getXTargetNamedID()

                if targetID > 0 then
                    self.activatePreCast(self.Common.DampenResistance)
                end
                if malosinata == 0 and malo == 0 and maloed == 0 then
                    return true
                end
                return false
            end},
            [4] = {[self.Common.Slow] = function()
                local slowed = mq.TLO.Target.Slowed.ID() or 0
                local slow = mq.TLO.Target.Buff(self.Common.Slow).ID() or 0
                local targetID = self.getXTargetNamedID()
                
                if targetID > 0 then
                    self.activatePreCast(self.Common.DampenResistance)
                end
                if slowed == 0 and slow == 0 then
                    return true
                end
                return false
            end},
        }

        self.Travel = {
            [1] = {[self.Common.GroupSpeed] = function()
                if not mq.TLO.Me.Invis() then
                    return true
                end
                return false
            end},
            [2] = {[self.Common.GroupInvis] = function()
                if travel_invis then
                    if not mq.TLO.Me.Invis() then
                        return true
                    end
                end
                return false
            end},
        }

        self.PullsTag = {
            [1] = {[self.Common.Malo] = function() return true end},
        }

        self.groupBuffs = {
            [1] = {[self.Common.GroupFocus] = function() return true end},
            [2] = {[self.Common.GroupHaste] = function() return true end},
            [3] = {[self.Common.GroupSpeed] = function() return true end},
        }

        self.selfBuffs = {
            [1] = {[self.Common.SelfPreincarnation] = function() return true end},
            [2] = {[self.Common.VisionarysUnity] = function() return true end},
            [3] = {[self.Common.Aura] = function() return true end},
            [4] = {[self.Common.GroupFocus] = function() return true end},
            [5] = {[self.Common.GroupHaste] = function() return true end},
            [6] = {[self.Common.GroupSpeed] = function() return true end},
        }

        self.Utility = {
            [1] = {[self.Common.Canni] = function()
                if mq.TLO.Me.PctHPs() > 45 and mq.TLO.Me.PctMana() < 80 then
                    return true
                end
                return false
            end},
            [2] = {[self.Common.SpiritualChanneling] = function()
                if mq.TLO.Me.XTarget() > 0 then
                    if mq.TLO.Me.PctHPs() > 20 and mq.TLO.Me.PctMana() < 40 then
                        return true
                    end
                end
                return false
            end},
            [3] = {[self.Common.FleetingSpirit] = function()
                local targetID = self.getXTargetNamedID()
                
                if targetID > 0 then
                    return true
                end
                return false
            end},
            [4] = {[self.Common.CompanionsFort] = function()
                petID = mq.TLO.Me.Pet.ID() or 0

                if petID > 0 then
                    if mq.TLO.Me.Pet.PctHPs() < 50 then
                        return true 
                    end
                end
                return false
            end},
            [5] = {[self.Common.CompanionsAegis] = function()
                petID = mq.TLO.Me.Pet.ID() or 0

                if petID > 0 then
                    if mq.TLO.Me.Pet.PctHPs() < 50 then
                        return true 
                    end
                end
                return false
            end},
            [6] = {[self.Common.SilentCasting] = function()
                local targetID = self.getXTargetNamedID()
                
                if targetID > 0 then
                    return true
                end
                return false
            end},
            [7] = {[self.Common.DampenResistance] = function()
                local targetID = self.getXTargetNamedID()
                
                if targetID > 0 then
                    return true
                end
                return false
            end},
            [8] = {[self.Common.AncestralGuard] = function()
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
            [9] = {[self.Common.SpiritGuardian] = function()
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
            [10] = {[self.Common.SelfCureAA] = function()
                if selfValidateDebuffs() then return true end
                return false
            end},
            [11] = {[self.Common.SingleFade] = function()
                if mq.TLO.Me.XTarget() > 0 then
                    if mq.TLO.SpawnCount("pccorpse radius 150")() >= 3 then
                        return true
                    end
                end
                return false
            end},
        }

        self.tankBuffs = {
            [1] = {[self.Common.Incapacity] = function() 
                local targetID = mq.TLO.Target.ID() or 0
                local tankID = mq.TLO.Group.MainTank.ID() or 0
                
                if mq.TLO.Me.XTarget() == 0 then
                    if tankID > 0 then
                        if targetID ~= tankID then
                            mq.cmdf('/target id %d', tankID)
                            mq.delay(200)
                        end
                        self.setTargetID(tankID)
                    end
                end

                return true
            end},
        }

        self.Rezz = {
            [1] = {[self.Common.SingleRezz] = function()
                local targetID = mq.TLO.Target.ID() or 0

                if mq.TLO.Me.XTarget() > 0 then return false end

                if mq.TLO.SpawnCount("pccorpse radius 150")() > 0 then
                    self.loadSpellGem(self.Common.SingleRezz, 8)
                    
                    local corpseID = mq.TLO.NearestSpawn(1, "pccorpse radius 150").ID()
                    local corpseDist = mq.TLO.NearestSpawn(1, "pccorpse radius 25").ID() or 0

                    if targetID ~= corpeID then mq.cmdf("/target %d", corpseID) mq.delay(500) end
                    if corpseDist == 0 then mq.cmdf("/corpse") end

                    return true
                end

                return false
            end},
            [2] = {[self.Common.CombatRezz] = function()
                local targetID = mq.TLO.Target.ID() or 0

                if mq.TLO.Me.XTarget() == 0 then return false end
                if mq.TLO.Spawn("group cleric").ID() == 0 then return false end

                if mq.TLO.SpawnCount("pccorpse radius 150")() > 0 then

                    local corpseID = mq.TLO.NearestSpawn(1, "pccorpse radius 150").ID()
                    local corpseDist = mq.TLO.NearestSpawn(1, "pccorpse radius 25").ID() or 0

                    if targetID ~= corpeID then mq.cmdf("/target %d", corpseID) mq.delay(500) end
                    if corpseDist == 0 then mq.cmdf("/corpse") end

                    return true
                end

                return false
            end},
        }

        self.GroupCures = {
            [1] = {[self.Common.GroupCureSpell] = function()
                local value

                for k,v in ipairs(self.priestObserverCureTable) do
                    value = mq.TLO.DanNet(k).O(v)() or 0
                    if value > 0 then
                        return true
                    end
                end
                return false
            end},
            [2] = {[self.Common.GroupCureAA] = function()
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

        self.GroupShrink = {
            [1] = {[self.Common.GroupShrink] = function() return true end},
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

        self.setAssistAt(100)
    end

    return self
end

-- And coroutines are useful for saving state, executing code asynch, then going back to that state
-- You can do neat things with them, but you can also completely ignore them

--[[
        

    -- Self utility
    SelfInvis = "Silent Presence",
    SelfLevi = "Perfected Levitation",

    -- CC
    Root = "Virulent Paralysis",
    ConeRoot = "Spiritual Rebuke",

    -- Pet
    CompanionsDA = "Companion's Intervening Divine Aura",

    -- Utility
    Shrink = "Shrink",
    Gate = "Gate",
    Leap = "Spirit Leap",
    GroupFade = "Spirit of Urgency", -- group fade

    -- FADES TO TRAVEL!!

]]
