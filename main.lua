local mq = require('mq')
local Write = require('lib/Write')
local class = require('eqaddict/monk')
local puller = require('eqaddict/pull/pull')
local classutils = require('eqaddict/mnkutils')

local events = require('eqaddict/events')

-- Write config
Write.prefix = function() return '\ax['..mq.TLO.Time()..'] [\agAddict\ax] ' end
Write.loglevel = 'debug'
Write.usecolors = false

-- "global" setup
local targeterInstance = baseCharacter.new()
local engagerInstance = extendingEngager.new()
local pullerInstance = extendingPuller.new()
local AddictCharacter = extendingCharacter.new()
local enabled = true
local amiready = true

-- globals for events
local CAST_FIZZLED = false
local CANTSEETARGET = false

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
        return
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
        return
    end

    -- modes
    if cmd == 'travel' then
        AddictCharacter.setMode(Modes.TRAVEL)
        Write.Info('\aySet mode to ' .. Modes.TRAVEL)
    elseif cmd == 'manual' then
        AddictCharacter.setMode(Modes.MANUAL)
        Write.Info('\aySet mode to ' .. Modes.MANUAL)
    elseif cmd == 'camp' then
        AddictCharacter.setMode(Modes.PULL_CAMP)
        Write.Info('\aySet mode to ' .. Modes.PULL_CAMP)
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
end

local function setup()
    AddictCharacter.setMode(Modes.TRAVEL)
    check_plugins()
    --load_settings()

    -- register binds
    mq.bind('/setmode', bind_setmode)
    mq.bind('/addict', bind_addict)
    
    Write.Info('\agAutomations by Addict')

    print_usage_addict()
    print_usage_mode()
end

local function in_game() return mq.TLO.MacroQuest.GameState() == 'INGAME' end

local function main()
    while true and enabled do
        if in_game() then
            while AddictCharacter.getMode() == Modes.MANUAL do mq.delay(1000) end
            while AddictCharacter.getMode() == Modes.TRAVEL do
                AddictCharacter.followTheLeader()
                mq.delay(1000)
            end
            if AddictCharacter.getMode() == Modes.PULL_CAMP then
                AddictCharacter.setCampSpot(mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z())
                pullerInstance.setCampSpot(mq.TLO.Me.X(), mq.TLO.Me.Y(), mq.TLO.Me.Z())
                while AddictCharacter.getMode() == Modes.PULL_CAMP do
                    pullerInstance.pullRoutine()
                    a = AddictCharacter.getOffensiveTarget()
                    engagerInstance.engage(a)
                    AddictCharacter.returnToCamp()
                    mq.delay(500)
                end
            end
        end
    end
end

-- baseCharacter -> targeter -> engager -> puller -> character

-- baseCharacter -> targeter
-- baseCharacter -> engager -> puller -> character

-- baseCharacter -> FSM -> targeter
-- baseCharacter -> FSM -> engager -> puller  (+ sub state) -> character


-- Finite State Machine to handle state transitions:
--- From main states -> from pulling to engaging
--- From minor states -> pulling-gettarget to pulling-runtotarget

-- Engager class
--- Holds state about who to engage and attack

-- Puller class
--- Holds state on pull target

-- Healer class
--- Holds state on who to heal in group


setup()
AddictCharacter.setMode(Modes.PULL_CAMP)
main()



-- create campfire function
-- cast_rezz to base class as abstract
-- rotations
-- engage

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

--- calculateCoordsBehindMe
--- calculateCoordsBehindTarget
-- ({*}---[*]--HERE) {*} is npc and [*] is tank
-- (HERE--{*}---[*])

-- campAtSpot(x,y,z)
--- (Caster may have to stand back to not be in an aura etc..)

-- waitForInvis

-- Toggles
--- assist %
--- mode (ofc)
--- see cwtn image


-- OTHER NOTES
---engage should have position as a param. engage(targetID: int, position: str, how: str) (position can be back, front, side) (how: range or melee??)
---Range only flag. They only use abilities that can hit from where they are

-- Firewalker's Precision Strike does not share timer with Doomwalker's, you can use both (and also Icewalker's Precision Strike when you get there)

-- While running to spots, healers need to check that hps are ok and tanks need to check aggro