local Component = {}
Component.__index = Component

function Component.new(Manager)
    local self = {
        Name = "MovementComponent",
        bindableEvents = {
            requestJump = {"requestJump", {Enum.KeyCode.Space, Enum.KeyCode.Q}}
        }
    }
    return setmetatable(self, Component)
end

function Component:onUpdate()

end

function Component:requestJump(inputType)
    print('vleh')
end

return Component