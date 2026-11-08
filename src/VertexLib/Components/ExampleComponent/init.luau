local Component = {}
Component.__index = Component

-- returns the components's local variables as identified in self
function Component.new(Manager)
    local self = {
        Manager = Manager,
        Name = "ExampleComponent",
        updateFrequency = nil,
        accumulator = 0,
    }
    return self
end

-- dt: current deltaTime
-- dtComplete: the time passed from the component's last update, only provided if updateFrequency ~= nil
function Component:onUpdate(dt, dtComplete) 
    
end

function Component:OneExampleEvent(newState) -- newState is variable(s) passed when an input action is activated. varies between the different types of inputbindings, see Roblox's IAS documentation
    
end

return Component