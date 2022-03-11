
-- Camper class
--- Holds state about camping in a user defined spot

local mq = require('mq')
local Write = require('lib/Write')
local utils = require('eqaddict/utils/utils')
local core = require('eqaddict/utils/puller')

extendingCamper = {}
extendingCamper.new = function(name, class)
    local self = extendingPuller.new(name, class)

    local autoCampRadius = 30
    local tankRadius = 35
    local xCampCoord
    local yCampCoord
    local zCampCoord

    function self.setCampSpot(xCoord, yCoord, zCoord)
        xCampCoord = xCoord
        yCampCoord = yCoord
        zCampCoord = zCoord
        if mq.TLO.Me.Pet.ID() then mq.cmd("/pet guard") end
    end

    function self.setAutoCampRadius(radius) autoCampRadius = radius end
    function self.setTankRadius(radius) tankRadius = radius end

    function self.getTankRadius() return tankRadius end
    function self.getAutoCampRadius() return autoCampRadius end
    function self.getCampSpot() return xCampCoord, yCampCoord, zCampCoord end
    function self.getXCampCoord() return xCampCoord end
    function self.getYCampCoord() return yCampCoord end
    function self.getZCampCoord() return zCampCoord end

    function self.createCampfire()	
        local nearMe = mq.TLO.SpawnCount("pc group radius 50")() or 0

        if mq.TLO.Group() == nil then return end
        if tonumber(mq.TLO.Group()) >= 2 then 
            if mq.TLO.Me.ID() ~= mq.TLO.Group.Leader.ID() then
                return 
            end
        end
        if nearMe < 3 then return end
    
        if mq.TLO.Me.XTarget() > 0 then return end
        if mq.TLO.Navigation.Active() then return end
        if mq.TLO.Zone.ID() == 202 then return end
        if mq.TLO.Zone.ID() == 344 then return end
        if mq.TLO.Zone.ID() == 345 then return end
        if mq.TLO.Me.Fellowship.Members() == 0 then return end
        
        if mq.TLO.Zone.Name() == mq.TLO.Me.Fellowship.CampfireZone() then
            if distance3D(self.getXCampCoord(), self.getYCampCoord(), self.getZCampCoord(), mq.TLO.Me.Fellowship.CampfireY(), mq.TLO.Me.Fellowship.CampfireX(), mq.TLO.Me.Fellowship.CampfireZ()) < 2000 then
                if tonumber(mq.TLO.Me.Fellowship.CampfireDuration()) > 600 then
                    return
                end
            end
        end
    

        -- Destroy old campfire
        if mq.TLO.Me.Fellowship.Campfire() then
            Write.Info("Destroying old campfire")
            while mq.TLO.Me.Fellowship.Campfire() do
                self.setState(State.DESTROYCAMPFIRE)
                while not mq.TLO.Window("FellowshipWnd").Open() do
                    mq.cmd("/windowstate FellowshipWnd open")
                end
    
                while mq.TLO.Window("FellowshipWnd").Open() do
                    if mq.TLO.Window["FellowshipWnd"].Open() then mq.cmd("/nomodkey /notify FellowshipWnd FP_Subwindows tabselect 2") end
                    mq.delay(500)
                    if mq.TLO.Window["FellowshipWnd"].Open() then mq.cmd("/nomodkey /notify FellowshipWnd FP_RefreshList leftmouseup") end
                    mq.delay(500)
                    if mq.TLO.Window["FellowshipWnd"].Open() then mq.cmd("/nomodkey /notify FellowshipWnd FP_CampsiteKitList listselect 1") end
                    mq.delay(500)
                    if mq.TLO.Window["FellowshipWnd"].Open() then mq.cmd("/nomodkey /notify FellowshipWnd FP_DestroyCampsite leftmouseup") end
                    mq.delay(500)
                    if mq.TLO.Window("ConfirmationDialogBox").Open() then break end
                end
               
                while mq.TLO.Window("ConfirmationDialogBox").Open() do
                    if mq.TLO.Window("ConfirmationDialogBox").Open() then mq.cmd("/nomodkey /notify ConfirmationDialogBox CD_Yes_Button leftmouseup") end
                    mq.delay(500)
                    if mq.TLO.Window("ConfirmationDialogBox").Open() then mq.cmd("/notify ConfirmationDialogBox Yes_Button leftmouseup") end
                    mq.delay(500)
                    if mq.TLO.Window("ConfirmationDialogBox").Open() then mq.cmd("/notify ConfirmationDialogBox Confirm_Button leftmouseup") end
                    mq.delay(500)
                end
            end
        end
    
        -- Create new campfire
        Write.Info("Creating new campfire")
        while not mq.TLO.Me.Fellowship.Campfire() do
            self.setState(State.CREATECAMPFIRE)
            if not mq.TLO.Window("FellowshipWnd").Open() then mq.cmd("/windowstate FellowshipWnd open") end
            mq.delay(500)
            if mq.TLO.Window("FellowshipWnd").Open() then mq.cmd("/nomodkey /notify FellowshipWnd FP_Subwindows tabselect 2") end
            mq.delay(500)
            if mq.TLO.Window("FellowshipWnd").Open() then mq.cmd("/nomodkey /notify FellowshipWnd FP_RefreshList leftmouseup") end
            mq.delay(500)
            if mq.TLO.Window("FellowshipWnd").Open() then mq.cmd("/nomodkey /notify FellowshipWnd FP_CampsiteKitList listselect 1") end
            mq.delay(500)
            if mq.TLO.Window("FellowshipWnd").Open() then mq.cmd("/nomodkey /notify FellowshipWnd FP_CreateCampsite leftmouseup") end
            mq.delay(500)
            if mq.TLO.Window("FellowshipWnd").Open() and not mq.TLO.Me.Fellowship.Campfire() then mq.cmd("/nomodkey /notify FellowshipWnd FP_CreateCampsite leftmouseup") end
            mq.delay(500)
            if mq.TLO.Window("FellowshipWnd").Open() then mq.cmd("/windowstate FellowshipWnd close") end
        end
        mq.delay(500)
        if mq.TLO.Window("FellowshipWnd").Open() then mq.cmd("/windowstate FellowshipWnd close") end
    end

    function self.returnToCamp(X, Y, Z)
        --[[
        Scenarios
            1. Target is fleeing then we don't want to return to camp as melees
            2. We don't have line of sight on out group memebers ex: we are fighting behind a tree
            3. If we are melee with a short camp radius we don't want to run back and forth
            4. If we are main tank we want to pull mob to camp if it is not fleeing and is too far away
            5. We don't want to move to camp if we are casting a heal
            6. If we get knocked away from camp we want to run back
            ]]
            
        local radius = self.getAutoCampRadius()
            
        local x = X or self.getXCampCoord() 
        local y = Y or self.getYCampCoord()
        local z = Z or self.getZCampCoord()
        local theta, r, newX, newY

        if x == 0 and y == 0 and z == 0 then return end

        -- Get random spot in camp circle
        r = radius * math.sqrt(math.random(0, 1))
        theta = math.random(0, 1) * 2 * math.pi
        newX = x + r * math.cos(theta)
        newY = y + r * math.sin(theta)

        -- Does path exist to our new spot in circle? (Think Stratos etc where it might not...)
        if mq.TLO.Navigation.PathExists("loc " .. newY .. " " .. newX .. " " .. z)() then
            x = newX
            y = newY
        end

        -- If we are moving then return
        if mq.TLO.Navigation.Active() then mq.cmd('/nav off') end

        -- If casting return
        if mq.TLO.Me.Casting.ID() ~= nil then return end

        -- Don't move to camp if target is low on health and running away
        if mq.TLO.Target.ID() ~= nil and mq.TLO.Target.ID() > 0 then
            if mq.TLO.Target.Type() == "NPC" then
                -- if target is fleeing
                if mq.TLO.Target.Fleeing() and mq.TLO.Target.PctHPs() < 25 then return end
                -- if tank is still on target
                if mq.TLO.Group.MainTank.ID() ~= nil then
                    if not mq.TLO.SpawnCount("loc " .. mq.TLO.Spawn("id " .. mq.TLO.Group.MainTank.ID()).X() .. " " .. mq.TLO.Spawn("id " .. mq.TLO.Group.MainTank.ID()).Y() .. " radius 70 zradius 50 npc targetable noalert 1") then return end
                end
            end
        end

        -- Melee are sticking to target so no need to move to camp
        if mq.TLO.Me.XTarget() > 0 then
            if mq.TLO.Group.MainTank.ID() ~= mq.TLO.Me.ID() then
                if mq.TLO.Select(mq.TLO.Me.Class.ShortName(),"WAR","SHD","PAL","BER","BRD","ROG","MNK","BST") then radius = self.getTankRadius() * 5 end
            else
                radius = self.getTankRadius() * 3
            end
        end

        -- If we have engaged then stick off
        if mq.TLO.Stick.Status() == "ON" then mq.cmd('/stick off') end
        mq.delay(200, function() return not mq.TLO.Stick.Active() end)

        -- If we are at camp then return
        if distance3D(mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z(), x, y, z) <= radius then return end

        -- Run to camp
        Write.Debug("Return to spot " .. x .. " " .. y .. " " .. z)
        while distance3D(mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z(), x, y, z) > radius do
            if not mq.TLO.Me.Standing() then mq.cmd('/stand') end
            if not mq.TLO.Navigation.Active() then mq.cmdf('/nav locxyz %d %d %d', x, y, z) end
            if mq.TLO.Me.Pet.ID() and mq.TLO.Me.Pet.Combat() then mq.cmd('/pet back') end
            mq.delay(250)
        end
        if mq.TLO.Navigation.Active() then mq.cmd('/nav stop') end
    end

    return self
end


--[[
local mq = require('mq')

local function dropcampfire()
    if not mq.TLO.Me.Fellowship.Campfire() then
            mq.cmd('/windowstate FellowshipWnd open')
            mq.delay(1500)
            mq.cmd('/nomodkey /notify FellowshipWnd FP_Subwindows tabselect 2')
            mq.delay(1500)
            mq.cmd('/nomodkey /notify FellowshipWnd FP_RefreshList leftmouseup')
            mq.delay(1500)
            mq.cmd('/nomodkey /notify FellowshipWnd FP_CampsiteKitList listselect 1')
            mq.delay(1500)
            mq.cmd('/nomodkey /notify FellowshipWnd FP_CreateCampsite leftmouseup')
            mq.delay(1500)
            mq.cmd('/windowstate FellowshipWnd close')
            mq.delay(1500)
            mq.cmd.echo('\agDropped a Campfire')
    end
end

local function checkcamp()
    if mq.TLO.Me.Fellowship.CampfireZone() ~= mq.TLO.Zone.Name() and mq.TLO.Me.Fellowship.Campfire() and mq.TLO.FindItem("Fellowship Registration Insignia").TimerReady() == 0 then
        mq.cmd("/useitem Fellowship Registration Insignia")
        mq.delay(2000)
        mq.cmd.echo('\ayClicking back to camp!')
    end
end

while true do
    dropcampfire()
    mq.delay(3000)
    checkcamp()
    mq.delay(3000)
end
]]