local mq = require('mq')
local Write = require('lib/Write')
local traveler = require('eqaddict/utils/traveler')

local AddictCharacter
local classutils

math.randomseed(os.time())

-- Write config
Write.prefix = function() return '\ax['..mq.TLO.Time()..'] [\agAddict\ax] ' end
Write.loglevel = 'debug'
Write.usecolors = false

-- "global" setup
if mq.TLO.Me.Class.ShortName() == "SHM" then
    classutils = require('eqaddict/classutils/shmutils')
    AddictCharacter = Shaman.new()
elseif mq.TLO.Me.Class.ShortName() == "MNK" then
    classutils = require('eqaddict/classutils/mnkutils')
    AddictCharacter = Monk.new()
elseif mq.TLO.Me.Class.ShortName() == "WAR" then
    classutils = require('eqaddict/classutils/warutils')
    AddictCharacter = Warrior.new()
elseif mq.TLO.Me.Class.ShortName() == "CLR" then
    classutils = require('eqaddict/classutils/clrutils')
    AddictCharacter = Cleric.new()
end

Traveler = extendingTraveler.new()

local enabled = true

-- globals for events
local CASTFIZZLED = false
local CANTSEETARGET = false
local ISIMMUNE = false
local ISINTERRUPTED = false
local CANTCASTONTARGET = false

-- globals for skill rotations via dannet
if mq.TLO.Defined("ALLIANCETURN") then mq.cmd("/deletevar ALLIANCETURN") end
mq.cmd('/declare ALLIANCETURN bool outer FALSE')

if mq.TLO.Defined("AMIREADY") then mq.cmd("/deletevar AMIREADY") end
mq.cmd('/declare AMIREADY bool outer FALSE')

-- script functions
local function print_usage_addict()
    Write.Info('\agAvailable Commands - ')
    Write.Info('\a-g/addict on|off\a-t - Toggle addict on/off.')
    Write.Info('\a-g/addict setpullradius\a-t - Set the x, y and z pull radius for pull camp mode. NOT DONE')
end

local function print_usage_mode()
    Write.Info('\a-g/setmode <type> \a-t - Set the mode for the specific character.')
    print("")
end

-- binds
local function bind_addict(cmd, val1, val2)
    -- usage
    if cmd == nil then 
        print_usage_addict() 
    end

    -- on/off
    if cmd == 'on' then
        enabled = true
        Write.Info('\ayAddict enabled.')
    elseif cmd == 'off' then 
        enabled = false
        mq.cmd('/nav stop')
        mq.cmd('/stick off')
        AddictCharacter.setMode(Modes.MANUAL)
        Write.Info('\ayAddict disabled.')
    end
end

local function bind_setmode(cmd)
    -- usage
    if cmd == nil then 
        print_usage_mode() 
    end

    -- modes
    if cmd == 'travel' then
        AddictCharacter.setMode(Modes.TRAVEL)
        Write.Info('\aySet mode to ' .. Modes.TRAVEL)
    elseif cmd == 'manual' then
        AddictCharacter.setMode(Modes.MANUAL)
        Write.Info('\aySet mode to ' .. Modes.MANUAL)
    elseif cmd == 'camp' then
        AddictCharacter.setMode(Modes.CAMP)
        Write.Info('\aySet mode to ' .. Modes.CAMP)
    end
end

local function check_plugins()
    -- unload mq2autoloot
    if mq.TLO.Plugin('mq2autoloot')() ~= nil then
        mq.cmdf('/plugin mq2autoloot unload noauto')
        Write.Info('\agUnloading mq2autoloot.')
    end
    -- bitch about dannet
    if mq.TLO.Plugin('mq2dannet')() == nil then
        mq.cmdf('/plugin mq2dannet load noauto')
        Write.Info('\agLoading mq2dannet.')
    end
    mq.cmdf('/nav Reload')
end

local function setup()
    AddictCharacter.setMode(Modes.TRAVEL)
    AddictCharacter.setAbilities()
    AddictCharacter.setPuller()
    if mq.TLO.Group.Leader.ID() == mq.TLO.Me.ID() then setGroupRoles() end
    check_plugins()

    -- register binds
    mq.bind('/setmode', bind_setmode)
    mq.bind('/addict', bind_addict)
    
    Write.Info('\agAutomations by Addict')

    print_usage_addict()
    print_usage_mode()

    if mq.TLO.Me.Class.ShortName() == "SHM" then AddictCharacter.activateRotation(AddictCharacter.GroupShrink) end
end

local function in_game() return mq.TLO.MacroQuest.GameState() == 'INGAME' end

local function main()
    while enabled do
        while AddictCharacter.getMode() == Modes.MANUAL and in_game() do mq.delay(1000) end
        while AddictCharacter.getMode() == Modes.TRAVEL and in_game() do
            Traveler.followTheLeader()
            AddictCharacter.dead()
            mq.delay(500)
        end
        if AddictCharacter.getMode() == Modes.CAMP then
            if mq.TLO.Me.Class.ShortName() == "SHM" then AddictCharacter.activateRotation(AddictCharacter.GroupShrink) end
            AddictCharacter.setCampSpot(mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z())
            while AddictCharacter.getMode() == Modes.CAMP and in_game() do
                AddictCharacter.returnToCamp()
                AddictCharacter.buffRotation()
                AddictCharacter.rezzRotation()
                AddictCharacter.pullRoutine()
                AddictCharacter.getOffensiveTarget()
                AddictCharacter.engageRangeOffensive()
                AddictCharacter.engageMeleeOffensive()
                AddictCharacter.engageDefensive()

                -- downtime
                AddictCharacter.createCampfire()
                AddictCharacter.meditate()
                AddictCharacter.dead()
                mq.delay(500)
            end
        end
    end
end

setup()
main()


-- Tank to use ability and scan for adds with coroutines
-- https://gist.github.com/torus/141352


-- baseCharacter -> traveler -> priest -> class
-- baseCharacter -> targeter -> engager -> puller -> camper -> priest -> class -> missioner



-- This below requires state transition tables for minor states
-- baseCharacter -> targeter -> player
-- baseCharacter -> engager -> player
-- baseCharacter -> puller -> priest -> class -> player
-- baseCharacter -> camper -> player


--state transitions within a class and a class decides what state is next.



--[[
    ${Me.Heading.DegreesCCW} gets your degrees you are facing
so anything over your heading +- 45 would be outside of a 90 degree cone infront of you?
]]


-- SHOULD setTargetID also target??? If so then Pulling has to be done by internal local variable

-- get out and come back
-- alliance
-- Tank should scan near group to see if mobs coming in (need to do noalert in an event)





--gui
----mode
----state
----own hp
----own %end %mana
----target
----target %hp
----Zone
----closet other player
---- https://www.dropbox.com/home/eq?preview=MQ2HUD.ini

-- Things marked with ----- are examples of methods using them


-- Helper Methods
--- Nav to spot
---- pullCamping
---- goToWaypoint
---- dodgeEmote (go to spot, range only, come back to spot)

--- Nav to npc
---- pullFoundTarget
---- startMission
---- engageNPC

--- Nav to pc
---- followTheLeader
---- comeToMe

-- waitForInvis

-- Toggles
--- assist %
--- mode (ofc)
--- see cwtn image


-- OTHER NOTES

-- Firewalker's Precision Strike does not share timer with Doomwalker's, you can use both (and also Icewalker's Precision Strike when you get there)

-- While running to spots, healers need to check that hps are ok and tanks need to check aggro