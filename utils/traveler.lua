-- Follower class
--- Holds state about who to follow

local mq = require('mq')
local core = require('eqaddict/utils/core')
local Write = require('lib/Write')

extendingTraveler = {}
extendingTraveler.new = function(name, class)
    local self = baseCharacter.new(name, class)

    function self.followTheLeader()

        if not mq.TLO.Me.Standing() then mq.cmd('/stand') end
        if mq.TLO.Stick.Status() == "ON" then mq.cmd('/stick off') end
        if next(Travel) then self.activateRotation(Travel) end
        if mq.TLO.Me.Pet.ID() and mq.TLO.Me.Combat() then mq.cmd('/pet back off') end
        if mq.TLO.Me.Pet.Stance() ~= "FOLLOW" then mq.cmd('/pet follow') end
        
        -- How to check if attack is off?
        mq.cmd('/attack off')
        
        -- if (!${Me.XTarget}) /call check_for_corpse FALSE
        
        if mq.TLO.Group() then
            for i=0, mq.TLO.Group() do
                -- Get group leader position in group
                if mq.TLO.Group.Member(i).ID() == mq.TLO.Group.Leader.ID() then
                    groupLeaderPosition = i
                end
            end
            -- If i am not the group leader then nav to leader
            if mq.TLO.Group.Leader.ID() ~= mq.TLO.Me.ID() then
                if mq.TLO.Navigation.MeshLoaded() and not mq.TLO.Group.Member(groupLeaderPosition).OtherZone() then
                    if not mq.TLO.Navigation.Active() and mq.TLO.Navigation.PathLength('id ' .. mq.TLO.Group.Leader.ID())() > 25 then
                        Write.Debug("Navigating to \a-g" .. mq.TLO.Group.Leader.DisplayName())
                        self.navToID(mq.TLO.Group.Leader.ID())
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

    return self
end