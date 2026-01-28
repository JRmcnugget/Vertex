local Component = {}
Component.__index = Component

function Component.new(Manager)
    local self = {
        Manager = Manager,
        Name = "MovementComponent",
        bindableEvents = {
            ["Jump"] = {functionName = "requestJump", keybinds = {Enum.KeyCode.Space, Enum.KeyCode.Q}, mobileButton = true}
        }
    }
    return setmetatable(self, Component)
end

function Component:onUpdate()
    
end

function Component:requestJump(inputType, inputObj)
    
end

return Component