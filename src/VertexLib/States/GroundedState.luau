local State = {}
State.__index = State

function State.new(Manager)
    local self = {
        Manager = Manager,
        Name = "Grounded",
        canJump = true,
        canCrouch = true
    }
    return self
end

function State:onEnter(dt)
    self.Manager.Shared.controllerManager.ActiveController = self.Manager.Shared.groundController
    task.wait(0.2)
    return true
end

function State:onUpdate(dt)
    self.Manager.Shared.controllerManager.MovingDirection = self.Manager.Shared.inputDirection
    self.Manager.Shared.controllerManager.FacingDirection = self.Manager.Shared.lookDirection
end

function State:onExit(dt)
    return true
end

return State