-- Puller class
--- Holds state on pull target

local mq = require('mq')
local Write = require('lib/Write')
local events = require('eqaddict/engager')
local mnkutils = require('eqaddict/mnkutils')
local dannet = require('eqaddict/dannet/helpers')

-- Enums
local PullerDefensives = {}
if mq.TLO.Select(mq.TLO.Me.Class.ShortName(),"MNK")() then
    PullerDefensives.DISCDEF1 = Defensive.EARTHFORCE
    PullerDefensives.AADEF1 = Defensive.REJECTDEATH
    PullerDefensives.CURE = "Purify Body"
    PullerDefensives.HEAL1 = "Mend"
end

-- Base puller class
extendingPuller = {}
extendingPuller.new = function(name, class)
    local self = extendingEngager.new(name, class)

    -- Encapsulate what a base character is
    self.name = name or "Puller"
    self.class = class or "Puller"
    self.targetID = 0
    self.targetName = "None"

    local limitUpper = 80
    local limitLower = 20
    local limit = limitLower
    local hardLimit = limitLower
    --local pullDistance = 500
    local pullerIsPulling = false
    local maxPullRadiusZ = 200
    local maxPullRadiusXY = 1000

    local function selfValidatePullStart()
        if mq.TLO.Group.Puller.ID() ~= mq.TLO.Me.ID() then return false end
        if mq.TLO.Me.Song("Restless Ice").ID() then return false end
        if mq.TLO.Me.Buff("Resurrection Sickness").ID() then return false end
        if mq.TLO.Me.Snared.ID() then return false end
        if mq.TLO.Me.Rooted.ID() then return false end
        if mq.TLO.Me.Poisoned.ID() and not mq.TLO.Me.Tashed.ID() then return false end
        if mq.TLO.Me.Diseased.ID() then return false end
        if mq.TLO.Me.Cursed.ID() then return false end
        if mq.TLO.Me.Corrupted.ID() then return false end
        if mq.TLO.Me.XTarget() > 0 then return false end
        if mq.TLO.Spawn("id " .. self.targetID).Type() == "Corpse" then mq.cmd("/target clear") self.setTarget(0) end
        return true
    end

    local function groupValidatePullStart()
        if mq.TLO.Select(mq.TLO.Me.Class.ShortName(),"CLR","SHM","NEC","ENC","WIZ","MAG","DRU","SHD","PAL","BST")() > 0 then
            if mq.TLO.Me.PctMana() < hardLimit and mq.TLO.Me.PctMana() < limit then
                limit = limitUpper
                return false
            end
        else
            if mq.TLO.Me.PctEndurance() < hardLimit and mq.TLO.Me.PctEndurance() < limit then
                limit = limitUpper
                return false
            end
        end

        local class, name, result
        for i=1, mq.TLO.Group() do
            class = mq.TLO.Group.Member(i).Class.ShortName()
            name = mq.TLO.Group.Member(i).Name()

            if mq.TLO.Group.Member(i).Type() == 'PC' then
                if mq.TLO.Group.Member(i).OtherZone() then return false end
                if mq.TLO.Group.Member(i).Distance() > 100 then return false end

                if mq.TLO.Select(class,"CLR","SHM","NEC","ENC","WIZ","MAG","DRU","SHD","PAL","BST")() > 0 then

                    result = tonumber(dannet.query(name, "Me.Casting.ID")) or 1
                    if result > 0 then
                        Write.Debug(name .. " is casting")
                        return false
                    end

                    result = tonumber(dannet.query(name, "Me.PctMana"))
                    if result < limit then
                        Write.Debug(name .. " mana is below " .. limit)
                        limit = limitUpper
                        return false
                    end

                elseif mq.TLO.Select(class,"WAR","ROG","BER","MNK")() > 0 then
                    result = tonumber(dannet.query(name, "Me.PctEndurance"))
                    if result < limit then
                        Write.Debug(class .. " endurance is below " .. limit)
                        limit = limitUpper
                        return false
                    end
                    
                    if mq.TLO.Spawn("group shaman").ID() > 0 then
                        result = tonumber(dannet.query(name, "Me.Hasted.ID")) or 0
                        if result == 0 then
                            Write.Debug(class .. " doesn't have haste")
                            return false
                        end
                    end
                end
                --[[
                result = tonumber(dannet.query(name, "amiready")) or 1
                print(result)
                if result > 0 then
                    Write.Debug(class .. " is not ready")
                    return false
                end
                ]]

                if mq.TLO.Spawn("group shaman").ID() > 0 then
                    result = tonumber(dannet.query(name, "Me.Focus.ID")) or 0
                    if result == 0 then
                        Write.Debug(class .. " doesn't have focus")
                        return false
                    end
                end

                if mq.TLO.Group.Member(i).ID() == mq.TLO.Group.MainTank.ID() then
                    result = tonumber(dannet.query(name, "Me.Buff[Resurrection Sickness].ID")) or 0
                    if result > 0 then
                        Write.Debug(class .. " has Resurrection Sickness")
                        return false
                    end
                end
            end
            mq.delay(250)
        end
        limit = limitLower
        return true
    end

    local function setPullTarget()
        local radiusXY	=   300
        local pathLength =  999

        local mobsInRadius
        local pathExistsCheck, navPathLength, ignoreMobCheck
        local pullMobID
        local pullMobName

        local ignoreList = {
            "Grieving Soul Scent",
            "a wild fire"
        }
        self.targetID = 0
        -- Start scanning area for a target
        while self.targetID == 0 do
            
            -- Return if we get a roamer to camp
            if mq.TLO.Me.XTarget(1).ID() > 0 then self.targetID = mq.TLO.Me.XTarget(1).ID() return end
    
            -- Scan a small area first for potential targets
            mobsInRadius = mq.TLO.SpawnCount(string.format('npc targetable noalert 1 loc %d %d radius %d zradius %d', self.getXCampCoord(), self.getYCampCoord(), radiusXY, maxPullRadiusZ))()
            Write.Debug("Mobs in radius " .. mobsInRadius)

            -- Don't let the area scan radius be higher than the one specified by user
            if radiusXY > maxPullRadiusXY then
                radiusXY = maxPullRadiusXY
            -- If we are at max radius and no mobs in radius
            elseif radiusXY == maxPullRadiusXY and mobsInRadius == 0 then
                Write.Debug("Mobs in radius " .. mobsInRadius)
                break
            elseif mobsInRadius == 0 and self.targetID == 0 then
                -- Increase radius by a factor of 1.3 if no targets in current radius
                radiusXY = radiusXY*1.3
                mq.cmdf('/mapfilter CastRadius %s', radiusXY)
                Write.Debug("Radius increased to " .. radiusXY)
            end

            if mobsInRadius > 0 and self.targetID == 0 then
                -- For mobs found in the area do some sanity checks
                for i=1, mobsInRadius do
                    ignoreMobCheck = true

                    -- Start off with scanning a smaller area and increase it if not adequate mobs are found
                    pullMobID = mq.TLO.NearestSpawn(i, string.format('npc targetable noalert 1 radius %d zradius %d', radiusXY, maxPullRadiusZ)).ID() or 0
                    pullMobName = tostring(mq.TLO.Spawn("id " .. pullMobID).DisplayName())

                    -- Prepare checks
                    pathExistsCheck = mq.TLO.Navigation.PathExists("id " .. pullMobID)()
                    navPathLength = mq.TLO.Navigation.PathLength("id " .. pullMobID)()
                    for key, value in pairs(ignoreList) do if pullMobName == value then ignoreMobCheck = false end end

                    -- Nav path exists check
                    if pathExistsCheck then
                        -- Path length check
                        if pathLength > navPathLength then
                            -- Ignore mob check
                            if ignoreMobCheck then
                                self.targetID = pullMobID
                                self.targetName = pullMobName
                                pathLength = navPathLength
                            else
                                Write.Debug("Found \a-p" .. pullMobName .. "\aw" .. " but it is on the ignore list")
                            end
                        else
                            Write.Debug("Found \a-p" .. pullMobName .. "\aw" .. " but path length is longer than current shortest")
                        end
                    else
                        Write.Debug("Navigation.Path does not exist to \a-p" .. "\aw" .. pullMobName)
                    end
                end
            end

            if self.targetID > 0 then
                break
            else
                mq.delay(500)
            end
        end
        Write.Info("Pull target found \a-p" .. self.targetName)
    end

    local function navToPullTarget()

        -- Run to pull target
        mq.cmdf('/nav id %d', self.targetID)
        while mq.TLO.Navigation.Active() do
            -- Break if we get an XTarget
            if mq.TLO.Me.XTarget() > 0 then
                if self.targetID ~= mq.TLO.Me.XTarget(1).ID() then 
                    self.targetID = mq.TLO.Me.XTarget(1).ID()
                end
                mq.cmdf('/target id %s', self.targetID)
                break
            end

            -- If we don't have los or the mob is too far away to pull, continue running at it
            if mq.TLO.Spawn('id ' .. self.targetID).LineOfSight() then
                if mq.TLO.Spawn('id ' .. self.targetID).Distance() < mq.TLO.Spell(Pulls.PULLABILITY).MyRange() - 30 then
                    mq.cmdf('/target id %s', self.targetID)
                    if mq.TLO.Navigation.Active() then mq.cmd('/nav stop') end
                else
                    if not mq.TLO.Navigation.Active() then mq.cmdf('/nav id %d', self.targetID) end
                end
            else
                if not mq.TLO.Navigation.Active() then mq.cmdf('/nav id %d', self.targetID) end
            end
            if not mq.TLO.Me.Standing() then mq.cmd('/stand') end
            mq.delay(500)
        end
    end

    local function tagPullTarget()
        local counter = 0
        while mq.TLO.Me.XTarget() == 0 do
            self.activateAA(Pulls["PULLABILITY"])
            mq.delay(1000)
            
            if mq.TLO.Me.XTarget() == 0 then
                setPullTarget()
                navToPullTarget()
            end
            
            counter = counter + 1
            if counter > 2 then
                Write.Debug("\a-rAdding \a-p" .. self.targetID .. " \a-rto ignore")
                mq.cmd('/squelch /alert add 1 id ' .. self.targetID)
            end
            
            mq.doevents("cantSeeTarget")
            if CANTSEETARGET then self.nudgeForward() CANTSEETARGET = false end
        end
    end

    -- base class function override
    local function returnToCamp(x, y, z)
        -- Return to camp unless we are there already
        while distance3D(mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z(), x, y, z) >= 25 do
            if not mq.TLO.Me.Standing() then mq.cmd('/stand') end
            if not mq.TLO.Navigation.Active() then mq.cmdf('/nav locxyz %d %d %d', x, y, z) end
            if mq.TLO.Me.Pet.ID() and mq.TLO.Me.Pet.Combat() then mq.cmd('/pet back') end

            --- NEEDS TO BE DONE AGAIN
            --[[
            if mq.TLO.Me.PctHPs() < 65 then self.activateAbility(PullerDefensives.HEAL1) end
            if mq.TLO.Me.PctHPs() < 40 then self.activateDisc(PullerDefensives.AADEF1) end
            if selfValidateDebuffs() then self.activateAA(PullerDefensives.CURE) end
            if mq.TLO.Me.PctHPs() < 60 then
                if mq.TLO.Me.ActiveDisc.ID() and mq.TLO.Me.ActiveDisc.ID() ~= mq.TLO.Spell(PullerDefensives.DISCDEF1).ID() then mq.cmd('/stopdisc') end
                self.activateDisc(PullerDefensives.DISCDEF1)
            end
            ]]

            if mq.TLO.Me.XTarget() == 0 then
                tagPullTarget()
            end
            mq.delay(250)
        end
        if self.targetID > 0 and mq.TLO.Target.ID() ~= nil then mq.cmd('/face') end
    end

    function self.pullRoutine()

        if not selfValidatePullStart() then return end

        if not groupValidatePullStart() then mq.delay(5000) return end

        Write.Debug("Self and group validations passed!")

        setPullTarget()

        if self.targetID == 0 then mq.delay(5000) return end
        self.targetName = mq.TLO.Spawn('id ' .. self.targetID).DisplayName()

        -- Pass target to navigate to target
        if selfValidatePullStart() then navToPullTarget() end

        -- Pass target to tag logic
        if selfValidatePullStart() then tagPullTarget() end

        returnToCamp(self.getXCampCoord(), self.getYCampCoord(), self.getZCampCoord())

        while mq.TLO.Me.XTarget() > 0 do
            if mq.TLO.Spawn("id " .. self.targetID).Distance3D() > 120 and mq.TLO.Spawn("id " .. self.targetID).Distance3D() < mq.TLO.Spell(Pulls.MOVEABILITY).MyRange() then
                self.activateAA(Pulls["MOVEABILITY"])
                break
            end
        end

        -- /varset PullerIsPulling FALSE
    end

    return self
end
