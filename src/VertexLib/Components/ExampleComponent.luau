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
        }
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
    print(self)
end

return Component