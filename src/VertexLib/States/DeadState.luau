local State = {}
State.__index = State

function State.new(Manager)
    local self = {
        Manager = Manager,
        Name = "Dead",
        canJump = false,
        canCrouch = false,
        accumlator = 0
    }
    return self
end

function State:onEnter(dt)
    self.Manager.Shared.controllerManager.ActiveController = nil
    return true
end

function State:onUpdate(dt)
    self.accumlator += dt
    if self.accumlator > 2 then
        self.Manager.Shared.respawnService:InvokeServer()
    end
end

function State:onExit(dt)
    return true
end

return State