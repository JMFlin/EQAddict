-- Utility stuff
local mq = require('mq')

function printf(...)
    print(string.format(...))
end

function distance3D(x1, y1, z1, x2, y2, z2) return math.sqrt( (x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2 ) end

function selfValidateDebuffs()
    if mq.TLO.Me.Poisoned.ID() then return true end
    if mq.TLO.Me.Diseased.ID() then return true end
    if mq.TLO.Me.Cursed.ID() then return true end
    if mq.TLO.Me.Corrupted.ID() then return true end
    if mq.TLO.Me.Snared.ID() then return true end
    if mq.TLO.Me.Mezzed.ID() then return true end
    if mq.TLO.Me.Charmed.ID() then return true end
    return false
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

function tablePairs(t, ...)
    local i, a, k, v = 1, {...}
    return
      function()
        repeat
          k, v = next(t, k)
          if k == nil then
            i, t = i + 1, a[i]
          end
        until k ~= nil or not t
        return k, v
    end
end

function deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function setGroupRoles()

    local setTank = true
    local setMA = true
    local setPuller = true

    if mq.TLO.Group() ~= nil then
        for i=0, mq.TLO.Group() do

            if setTank then
                if mq.TLO.Group.Member(i).Class.ShortName() == "WAR" or mq.TLO.Group.Member(i).Class.ShortName() == "SHD" or mq.TLO.Group.Member(i).Class.ShortName() == "PAL" then
                    setTank = false
                    mq.cmdf("/grouproles set %s 1", mq.TLO.Group.Member(i).DisplayName())
                end
            end
            
            if setPuller then
                if mq.TLO.Group.Member(i).Class.ShortName() == "BRD" or mq.TLO.Group.Member(i).Class.ShortName() == "MNK" then
                    setPuller = false
                    mq.cmdf("/grouproles set %s 3", mq.TLO.Group.Member(i).DisplayName())
                end
            elseif setMA then
                if mq.TLO.Group.Member(i).Class.ShortName() == "BER" or mq.TLO.Group.Member(i).Class.ShortName() == "MNK" then
                    setMA = false
                    mq.cmdf("/grouproles set %s 2", mq.TLO.Group.Member(i).DisplayName())
                end
            end
        end
    end
end


function setAllianceTable()
    -- https://www.lua.org/pil/19.3.html
    -- config.inc
    -- NOT DONE
    local indexPosition
    local namePosition

    for i=1, mq.TLO.Group() do
        if mq.TLO.Group.Member(i).Class.ShortName() == mq.TLO.Me.Class.ShortName() then
            indexPosition = i
            namePosition = mq.TLO.Group.Member(i).Name.Lower()
        end
    end
end