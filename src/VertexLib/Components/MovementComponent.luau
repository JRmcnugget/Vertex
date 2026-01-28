local Component = {}
Component.__index = Component

function Component.new(Manager)
    local self = {
        Manager = Manager,
        Name = "MovementComponent",
        updateFrequency = 30,
        accumulator = 0,
        bindableEvents = {
            ["Jump"] = {functionName = "requestJump", keybinds = {Enum.KeyCode.Space, Enum.KeyCode.Q}, mobileButton = true}
        },
        jumpImpulse = Vector3.new(0,250,0)
    }
    return self
end

function Component:onUpdate()
    local moveDir = self.Manager.Shared.humanoid.MoveDirection
    self.Manager.Shared.inputDirection = moveDir
    if self.Manager.Shared.char.Hitbox.LocalTransparencyModifier == 1 then
        self.Manager.Shared.lookDirection = self.Manager.Shared.cam.CFrame.LookVector
    else
        self.Manager.Shared.lookDirection = moveDir
    end
end

function Component:requestJump(inputType, inputObj)
    if inputType == Enum.UserInputState.Begin then
        self.Manager.Shared.humanoidRoot:ApplyImpulse(self.jumpImpulse)
        self.Manager:changeState("Airborne", false)
    end
end

return Component