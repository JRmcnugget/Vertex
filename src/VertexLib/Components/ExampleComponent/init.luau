local Component = {}
Component.__index = Component

-- returns the components's local variables as identified in self. if updateFrequency ~= nil, Component.accumlator is required
function Component.new(Manager)
    local self = {
        Manager = Manager,
        Name = "ExampleComponent",
        updateFrequency = nil,
        accumulator = 0,
    }
    return self
end

function Component:onUpdate(dt)
    
end

function Component:OneExampleEvent(newState)
    
end

return Component