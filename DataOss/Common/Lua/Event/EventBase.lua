-- Copyright (c) Cragon. All rights reserved.

---------------------------------------
EventBase = {
    EventName = nil
}

---------------------------------------
function EventBase:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

---------------------------------------
function EventBase:Reset()
end