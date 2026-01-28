local State = {}
State.__index = State

function State.new(Manager)
    local self = {
        Manager = Manager,
        Name = "Grounded",
    }
    local stateInstance = setmetatable(State, Manager.StateDefaults)
    return setmetatable(self, stateInstance)
end

function State:onEnter(dt)
    task.wait(5)
    return true
end

function State:onUpdate(dt)
    self.Manager.Shared.controllerManager.MovingDirection = self.Manager.Shared.inputDirection
    self.Manager.Shared.controllerManager.FacingDirection = self.Manager.Shared.lookDirection
end

function State:onExit(dt)
    print('Hi')
    return true
end

return State