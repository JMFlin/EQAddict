local mq = require('mq')
local Write = require('lib/Write')

local fizzle = function ()
    Write.Info("\arSpell fizzled!")
    CAST_FIZZLED = true
end

mq.event('fizzle', "#*#Your spell fizzles#*#", fizzle)
mq.event('fizzle', "#*#You miss a note, bringing your song to a close#*#", fizzle)


local cantSeeTarget = function()
    Write.Info("\arCannot see target!")
    CANTSEETARGET = true
end

mq.event('cantSeeTarget', "#*#You cannot see your target#*#", cantSeeTarget)