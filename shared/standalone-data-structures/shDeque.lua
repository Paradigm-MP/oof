Deque = class()
--[[
    Deque: A double-ended queue implementation
]]

function Deque:__init()
    self.data = {}
    self.data_count = 0
    self.first = 0
    self.last = -1
end

function Deque:PushLeft(value)
    if value == nil then return end

    self.first = self.first - 1
    self.data[self.first] = value
    self.data_count = self.data_count + 1
end

function Deque:PushRight(value)
    if value == nil then return end

    self.last = self.last + 1
    self.data[self.last] = value

    self.data_count = self.data_count + 1
end

function Deque:PopLeft()
    if self.data_count == 0 then return nil end

    local value = self.data[self.first]
    self.data[self.first] = nil
    self.first = self.first + 1
    self.data_count = self.data_count - 1

    return value
end

function Deque:PopRight()
    if self.data_count == 0 then return nil end

    local value = self.data[self.last]
    self.data[self.last] = nil
    self.last = self.last - 1
    self.data_count = self.data_count - 1
    
    return value
end

function Deque:PeekLeft()
    return self.data[self.first]
end

function Deque:PeekRight()
    return self.data[self.last]
end

function Deque:GetCount()
    return self.data_count
end

function Deque:IsEmpty()
    return self.data_count == 0
end

function Deque:ClearValues()
    self.data = {}
    self.data_count = 0
    self.first = 0
    self.last = -1
end