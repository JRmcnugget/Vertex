local State = {}
State.__index = State

function State.new(Manager)
    local self = {
        Manager = Manager,
        Name = "Grounded",
    }
    return self
end

function State:onEnter(dt)
    task.wait(1)
    return true
end

function State:onUpdate(dt)
    self.Manager.Shared.controllerManager.MovingDirection = self.Manager.Shared.inputDirection
    self.Manager.Shared.controllerManager.FacingDirection = self.Manager.Shared.lookDirection
end

function State:onExit(dt)
    print('StateLeft')
    return true
end

return State