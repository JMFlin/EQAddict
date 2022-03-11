-- Follower class
--- Holds state about who to follow

local mq = require('mq')
local core = require('eqaddict/utils/core')
--local utils = require('eqaddict/utils/utils')
local Write = require('lib/Write')

extendingTraveler = {}
extendingTraveler.new = function(name, class)
    local self = baseCharacter.new(name, class)

    function self.followTheLeader()
        local groupLeaderPosition

--        if not mq.TLO.Me.Standing() then mq.cmd('/stand') end
        if mq.TLO.Stick.Status() == "ON" then mq.cmd('/stick off') end
        if next(self.Travel) then self.activateRotation(self.Travel) end
        if mq.TLO.Me.Pet.ID() and mq.TLO.Me.Combat() then mq.cmd('/pet back off') end
        if mq.TLO.Me.Pet.Stance() ~= "FOLLOW" then mq.cmd('/pet follow') end
        
        if mq.TLO.Me.Combat() then mq.cmd('/attack off') mq.delay(100) end
        
        -- if (!${Me.XTarget}) /call check_for_corpse FALSE

        if mq.TLO.Group() ~= nil then
            for i=0, mq.TLO.Group() do
                -- Get group leader position in group
                if mq.TLO.Group.Member(i).ID() == mq.TLO.Group.Leader.ID() then
                    groupLeaderPosition = i
                    break
                end
            end
            
            -- If i am not the group leader then nav to leader
            if mq.TLO.Group.Leader.ID() ~= mq.TLO.Me.ID() then
                if mq.TLO.Navigation.MeshLoaded() and not mq.TLO.Group.Member(groupLeaderPosition).OtherZone() then
                    if not mq.TLO.Navigation.Active() and mq.TLO.Navigation.PathLength('id ' .. mq.TLO.Group.Leader.ID())() > 25 then
                        Write.Debug("Navigating to \a-g" .. mq.TLO.Group.Leader.DisplayName())
                        mq.cmdf('/nav id %d', mq.TLO.Group.Leader.ID())
                    end
                end
            end

            if mq.TLO.Group.Member(groupLeaderPosition).OtherZone() then
                for i=1, 2 do
                    self.nudgeForward()
                    self.doorClick()
                end
            end
        end
    end

    while mq.TLO.Me.Hovering() do mq.delay(1000) end
    while mq.TLO.Me.Zoning() do mq.delay(1000) end

    return self
end