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