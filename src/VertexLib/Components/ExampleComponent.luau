local Component = {}
Component.__index = Component

-- returns the components's local variables as identified in self. if updateFrequency ~= nil, Component.accumlator is required
function Component.new(Manager)
    local self = {
        Manager = Manager,
        Name = "ExampleComponent",
        updateFrequency = nil,
        accumulator = 0,
        bindableEvents = {
            ["Example"] = {functionName = "exampleEvent", keybinds = {Enum.KeyCode.Q}, mobileButton = false}
        }
    }
    return self
end

function Component:onUpdate()
    
end

function Component:exampleEvent(inputType, inputObj)
    
end

return Component