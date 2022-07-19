local mq = require('mq')

--[[
    Anniversary
]]
local steinOne = function()
    mq.cmd("/target galdorin")
    mq.cmd("/say My stinky stein has rough dirty lips,")
end
mq.event('steinOne', "#*#Galdorin Visigothe says, 'My stinky stein has rough dirty lips,'#*#", steinOne)

local steinTwo = function()
    mq.cmd("/target galdorin")
    mq.cmd("/say but she loves a deep carouse.")
end
mq.event('steinTwo', "#*#Galdorin Visigothe says, 'but she loves a deep carouse.'#*#", steinTwo)

local steinThree = function()
    mq.cmd("/target galdorin")
    mq.cmd("/say Beer or ale are her great trips.")
end
mq.event('steinThree', "#*#Galdorin Visigothe says, 'Beer or ale are her great trips.'#*#", steinThree)


local steinFour = function()
    mq.cmd("/target galdorin")
    mq.cmd("/say No matter how many vows")
end
mq.event('steinFour', "#*#Galdorin Visigothe says, 'No matter how many vows'#*#", steinFour)

local steinFive = function()
    mq.cmd("/target galdorin")
    mq.cmd("/say I make or break, my drinking glass")
end
mq.event('steinFive', "#*#Galdorin Visigothe says, 'I make or break, my drinking glass'#*#", steinFive)

local steinSix = function()
    mq.cmd("/target galdorin")
    mq.cmd("/say reminds me of my lovely Brasse.")
end
mq.event('steinSix', "#*#Galdorin Visigothe says, 'reminds me of my lovely Brasse.'#*#", steinSix)


local function in_game() return mq.TLO.MacroQuest.GameState() == 'INGAME' end

local function main()
    while in_game() do
        mq.doevents("steinOne")
        mq.doevents("steinTwo")
        mq.doevents("steinThree")
        mq.doevents("steinFour")
        mq.doevents("steinFive")
        mq.doevents("steinSix")
        mq.delay(500)
    end
end