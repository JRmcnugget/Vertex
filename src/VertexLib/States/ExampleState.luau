local State = {}

function State.new(Manager)
    local self = {
        Manager = Manager,
        Name = "Idle",
        onEnter = State.onEnter,
        onUpdate = State.onUpdate,
        onExit = State.onExit
    }
    return setmetatable(self, Manager.StateDefaults)
end

function State:onEnter(dt)
    print('Hi')
    return true
end

function State:onUpdate(dt)

end

function State:onExit(dt)
    print('Hi')
    return true
end

return State