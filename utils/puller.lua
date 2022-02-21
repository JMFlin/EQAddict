-- Puller class
--- Holds state on pull target

local mq = require('mq')
local Write = require('lib/Write')
local utils = require('eqaddict/utils/utils')
local events = require('eqaddict/utils/events')
local dannet = require('eqaddict/dannet/helpers')
local engager = require('eqaddict/utils/engager')

-- Base puller class
extendingPuller = {}
extendingPuller.new = function(name, class)
    local self = extendingEngager.new(name, class)

    -- Encapsulate what a base character is
    self.name = name or "Puller"
    self.class = class or "Puller"

    self.pullerObserverResourceTable = {}

    local limitUpper = 80
    local limitLower = 20
    local limit = limitLower
    local hardLimit = limitLower
    local pullerIsPulling = false
    local maxPullRadiusZ = 200
    local maxPullRadiusXY = 1000
    local ignoreList = {
        "Grieving Soul Scent",
        "a wild fire"
    }
    local distance = 100

    function self.setPuller()
        for key,value in pairs(self.PullsTag) do
            for k,v in pairs(value) do
                distance = mq.TLO.Spell(mq.TLO.Me.AltAbility(k).Name()).MyRange() or 0
                if distance == 0 then distance = mq.TLO.Spell(k).MyRange() or 0 end
            end
        end
    end

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
        if mq.TLO.Me.Casting.ID() then return false end
        if mq.TLO.Me.XTarget() > 0 then return false end
        if mq.TLO.Spawn("id " .. self.getTargetID()).Type() == "Corpse" then mq.cmd("/target clear") end

        local ready = false
        for key, value in ipairs(self.PullsTag) do
            for k,v in pairs(value) do
                if not mq.TLO.Me.AltAbilityReady(k)() then ready = true break end
                if not mq.TLO.Me.SpellReady(k)() then ready = true break end
                if not mq.TLO.Me.CombatAbilityReady(k)() then ready = true break end
                if not mq.TLO.Me.AbilityReady(k)() then ready = true break end
                if not mq.TLO.FindItem(k).Timer.TotalSeconds() == 0 or not mq.TLO.Me.ItemReady(k)() then ready = true break end
            end
            if ready == true then break end
        end
        if ready == false then return false end

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
        for i=1, tonumber(mq.TLO.Group()) do
            class = mq.TLO.Group.Member(i).Class.ShortName()
            name = mq.TLO.Group.Member(i).Name()
            
            -- https://www.redguides.com/community/resources/mq2dannet.322/
            if mq.TLO.Group.Member(i).Type() == 'PC' then
                if mq.TLO.Group.Member(i).OtherZone() then return false end
                if mq.TLO.Group.Member(i).Distance3D() > 300 then return false end

                if mq.TLO.Select(class,"CLR","SHM","NEC","ENC","WIZ","MAG","DRU","SHD","PAL","BST")() > 0 then

                    result = tonumber(dannet.query(name, "Me.Casting.ID")) or 0
                    if result > 0 then
                        Write.Debug(name .. " is casting")
                        return false
                    end
                end
            end
        end

        result = tonumber(dannet.query(mq.TLO.Group.MainTank.Name(), "Me.Buff[Resurrection Sickness].ID")) or 0
        if result > 0 then
            Write.Debug("Tank has Resurrection Sickness")
            return false
        end

        for key,value in pairs(self.pullerObserverResourceTable) do
            for k,v in pairs(value) do
                result = tonumber(mq.TLO.DanNet(k).O(v)()) or 0
                if result < limit then
                    Write.Debug(k .. " mana/endurance is below " .. limit)
                    limit = limitUpper
                    return false
                end
            end
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
        local increaseRadius = false

        mq.cmdf('/mapfilter CastRadius %s', radiusXY)
        self.setTargetID(0)

        -- Start scanning area for a target
        while self.getTargetID() == 0 do
            
            -- Return if we get a roamer to camp
            if mq.TLO.Me.XTarget(1).ID() > 0 then self.setTargetID(mq.TLO.Me.XTarget(1).ID()) return end
    
            -- Scan a small area first for potential targets
            mobsInRadius = mq.TLO.SpawnCount(string.format('npc targetable noalert 1 loc %d %d radius %d zradius %d', self.getXCampCoord(), self.getYCampCoord(), radiusXY, maxPullRadiusZ))()
            Write.Debug("Mobs in radius " .. mobsInRadius)

            -- Don't let the area scan radius be higher than the one specified by user
            if radiusXY > maxPullRadiusXY or increaseRadius then
                radiusXY = maxPullRadiusXY
            -- If we are at max radius and no mobs in radius
            elseif (radiusXY == maxPullRadiusXY and mobsInRadius == 0) or increaseRadius then
                Write.Debug("Mobs in radius " .. mobsInRadius)
                break
            elseif (mobsInRadius == 0 and self.getTargetID() == 0) or increaseRadius then
                -- Increase radius by a factor of 1.3 if no targets in current radius
                radiusXY = radiusXY*1.3
                mq.cmdf('/mapfilter CastRadius %s', radiusXY)
                Write.Debug("Radius increased to " .. radiusXY)
                increaseRadius = false
            end

            if mobsInRadius > 0 and self.getTargetID() == 0 then
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
                                self.setTargetID(pullMobID)
                                pathLength = navPathLength
                            else
                                Write.Debug("Found \a-p" .. pullMobName .. "\aw" .. " but it is on the ignore list")
                                mq.cmd('/squelch /alert add 1 id ' .. pullMobID)
                            end
                        else
                            Write.Debug("Found \a-p" .. pullMobName .. "\aw" .. " but path length is longer than current shortest")
                        end
                    else
                        increaseRadius = true
                        pullMobName = mq.TLO.Spawn("id " .. pullMobID).DisplayName()
                        if pullMobName ~= nil then
                            Write.Debug("Navigation.Path does not exist to \a-p" .. pullMobName)
                        end
                    end
                end
            end

            if self.getTargetID() > 0 then
                break
            else
                mq.delay(500)
            end
        end
        Write.Info("Pull target found \a-p" .. self.getTargetName())
    end

    local function navToPullTarget()

        -- Run to pull target
        mq.cmdf('/nav id %d', self.getTargetID())
        while mq.TLO.Navigation.Active() do
            -- Break if we get an XTarget
            if mq.TLO.Me.XTarget() > 0 then
                self.setTargetID(mq.TLO.Me.XTarget(1).ID())
                mq.cmdf('/mqtarget id %d', self.getTargetID())
                if mq.TLO.Navigation.Active() then mq.cmd('/nav stop') end
                break
            end

            -- Break if a mob is near by when running
            addID = mq.TLO.NearestSpawn(1, 'npc targetable noalert 1 radius 70 zradius 70').ID() or 0
            if addID > 0 then
                self.setTargetID(addID)
                mq.cmdf('/mapfilter CastRadius %s', 70)
                mq.cmdf('/mqtarget id %d', self.getTargetID())
                if mq.TLO.Navigation.Active() then mq.cmd('/nav stop') end
                break
            end

            -- If we don't have los or the mob is too far away to pull, continue running at it
            if mq.TLO.Spawn('id ' .. self.getTargetID()).LineOfSight() and mq.TLO.Spawn('id ' .. self.getTargetID()).Distance3D() < distance - 30 then
                mq.cmdf('/mqtarget id %d', self.getTargetID())
                if mq.TLO.Navigation.Active() then mq.cmd('/nav stop') end
            else
                if not mq.TLO.Navigation.Active() then mq.cmdf('/nav id %d', self.getTargetID()) end
            end
            if not mq.TLO.Me.Standing() then mq.cmd('/stand') end
            mq.delay(500)
        end
    end

    local function tagPullTarget()
        local counter = 0

        while mq.TLO.Me.XTarget() == 0 do
            
            self.activateRotation(self.PullsTag)
            mq.delay(500, function() return mq.TLO.Me.XTarget() > 0 end)
            
            if mq.TLO.Me.XTarget() == 0 then
                setPullTarget()
                navToPullTarget()
            end
            
            counter = counter + 1
            if counter == 4 then
                Write.Debug("\a-rAdding \a-p" .. self.getTargetID() .. " \a-rto ignore")
                mq.cmd('/squelch /alert add 1 id ' .. self.getTargetID())
            end

            mq.doevents("cantSeeTarget")
            if CANTSEETARGET then self.nudgeForward() CANTSEETARGET = false end
        end
    end

    local function returnToCamp(X, Y, Z)

        local x = X or self.getXCampCoord() 
        local y = Y or self.getYCampCoord()
        local z = Z or self.getZCampCoord()
        local radius = 10

        -- If we are at camp then return
        if distance3D(mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z(), x, y, z) <= radius then return end

        -- Run to camp
        while distance3D(mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z(), x, y, z) > radius do
            
            -- If we get knocked down the get up
            if not mq.TLO.Me.Standing() then mq.cmd('/stand') end
            
            -- if nav stops for whatever reason then activate again
            if not mq.TLO.Navigation.Active() then mq.cmdf('/nav locxyz %d %d %d', x, y, z) end
            
            -- Pet should not get stuck
            if mq.TLO.Me.Pet.ID() and mq.TLO.Me.Pet.Combat() then mq.cmd('/pet back') end

            -- Do we need to heal or earthforce
            self.activateRotation(self.PullsDefensive)
            
            -- If we lose the target during running back (chokidai fade)
            -- then we need to get a target again
            if mq.TLO.Me.XTarget() == 0 then tagPullTarget() end
            mq.delay(250)
        end
        if mq.TLO.Navigation.Active() then mq.cmd('/nav stop') end
    end

    function self.setPullingObservers()
        local class, name
        -- https://www.redguides.com/community/resources/mq2dannet.322/

        if mq.TLO.Group.Puller.ID() == mq.TLO.Me.ID() then
            
            for i=1, tonumber(mq.TLO.Group()) do

                class = mq.TLO.Group.Member(i).Class.ShortName()
                name = mq.TLO.Group.Member(i).Name()

                if mq.TLO.Group.Member(i).Type() == 'PC' then
                    if mq.TLO.Select(class,"CLR","SHM","NEC","ENC","WIZ","MAG","DRU","SHD","PAL","BST")() > 0 then

                        table.insert(self.pullerObserverResourceTable, {[name] = "Me.PctMana"})
                        dannet.observe(name, "Me.PctMana")

                    elseif mq.TLO.Select(class,"WAR","ROG","BER","MNK")() > 0 then
                        
                        table.insert(self.pullerObserverResourceTable, {[name] = "Me.PctEndurance"})
                        dannet.observe(name, "Me.PctEndurance")

                    end
                end
            end
        end
    end


    function self.pullRoutine()

        -- Empty the queue
        mq.doevents("cantSeeTarget")
        CANTSEETARGET = false

        if not selfValidatePullStart() then return end
        
        self.setState(State.MEDITATE)

        if not groupValidatePullStart() then mq.delay(5000) return end
        
        self.setState(State.PULL)

        Write.Debug("Self and group validations passed!")

        setPullTarget()

        if self.getTargetID() == 0 then mq.delay(5000) return end

        -- Pass target to navigate to target
        if selfValidatePullStart() then navToPullTarget() end

        self.setState(State.TAG)
        -- Pass target to tag logic
        if selfValidatePullStart() then tagPullTarget() end
        
        self.setState(State.PULL)

        if mq.TLO.Group.MainTank.ID() ~= nil and mq.TLO.Group.MainTank.ID() ~= mq.TLO.Me.ID() then
            returnToCamp(mq.TLO.Group.MainTank.X(), mq.TLO.Group.MainTank.Y(), mq.TLO.Group.MainTank.Z())
        else
            returnToCamp()
        end

        while mq.TLO.Me.Moving() do mq.delay(200, function() return not mq.TLO.Me.Moving() end) end
        if mq.TLO.Target.ID() ~= nil then mq.cmd('/face') end

        --[[
        local i = 0
        while mq.TLO.Me.XTarget() > 0 do
            if mq.TLO.Spawn("id " .. self.getTargetID()).Distance3D() > 100 then self.activateRotation(PullsMove) end
            if mq.TLO.Spawn("id " .. self.getTargetID()).Distance3D() < 100 then break end
            if self.getTargetID() ~= mq.TLO.Target.ID() then break end
            mq.delay(1000)
            i = i +1
            if i > 5 then break end
        end
        ]]
        -- /varset PullerIsPulling FALSE
        self.setState(State.MELEECOMBAT)
    end

    return self
end
