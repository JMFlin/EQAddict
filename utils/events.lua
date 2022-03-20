local mq = require('mq')
local Write = require('lib/Write')


local fizzle = function ()
    Write.Info("\arSpell fizzled!")
    CASTFIZZLED = true
end
mq.event('fizzle', "#*#Your spell fizzles#*#", fizzle)
mq.event('fizzle', "#*#You miss a note, bringing your song to a close#*#", fizzle)


local cantSeeTarget = function()
    Write.Info("\arCannot see target!")
    CANTSEETARGET = true
end
mq.event('cantSeeTarget', "#*#You cannot see your target#*#", cantSeeTarget)


local immune = function()
    Write.Info("\arTarget is immune!")
    ISIMMUNE = true
end
mq.event('immune', "Your target is immune to changes in its attack speed#*#", immune)
mq.event('immune', "Your target has no mana to affect#*#", immune)
mq.event('immune', "Your target is immune to changes in its attack speed#*#", immune)
mq.event('immune', "Your target is immune to changes in its run speed#*#", immune)
mq.event('immune', "Your target is immune to snare spells#*#", immune)
mq.event('immune', "Your target cannot be mesmerized#*#", immune)
mq.event('immune', "Your target looks unaffected#*#", immune)


local interrupt = function()
    Write.Info("\arI was interrupted!")
    ISINTERRUPTED = true
end
mq.event('interrupt', "Your spell is interrupted#*#", interrupt)
mq.event('interrupt', "Your casting has been interrupted#*#", interrupt)
mq.event('interrupt', "Your #1# spell is interrupted.", interrupt)

local cantCastOnTarget = function(line, arg1, arg2)
    Write.Info("\arCannot cast on target!")
    CANTCASTONTARGET = true
end
mq.event('cantCastOnTarget', "#*#You cannot cast #1# on #2##*#", cantCastOnTarget)


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
