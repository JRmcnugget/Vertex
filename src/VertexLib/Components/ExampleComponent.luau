local component = {}
component.__index = component

function component.new(Manager)
    local self = {
        Manager = Manager,
        Name = "MovementComponent",
         bindableEvents = {
            {functionName = "requestJump", keybinds = {Enum.KeyCode.Space, Enum.KeyCode.Q}}
        }
    }
    return setmetatable(self, component)
end

function component:onUpdate()
    print('awdsa')
end

function component:requestJump(inputType)
    print('vleh')
end

return component