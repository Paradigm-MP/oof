IdPool = class()

function IdPool:__init()
    self.current_id = 0
end

function IdPool:GetNextId()
    self.current_id = self.current_id + 1
    return self.current_id
end