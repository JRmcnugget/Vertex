local State = {}
State.__index = State

function State.new(Manager)
    local self = {
        Manager = Manager,
        Name = "Idle",
    }
    local stateInstance = setmetatable(State, Manager.StateDefaults)
    return setmetatable(self, stateInstance)
end

function State:onEnter(dt)
    task.wait(5)
    print('Hi')
    return true
end

function State:onUpdate(dt)
    print(self)
end

function State:onExit(dt)
    print('Hi')
    return true
end

return State