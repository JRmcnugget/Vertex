local State = {}
State.__index = State

-- returns the state's local variables as identified in self. will inherit any variables from Vertex.StateDefaults 
function State.new(Manager)
    local self = {
        Manager = Manager,
        Name = "ExampleState",
        isEpic = true
    }
    return self
end

-- runs upon being switched to from another state. will yeild State:onUpdate() and Manager:changeState() until returns true.
function State:onEnter(dt)
    
    return true
end

-- runs every frame while Manager.ActiveState = State
function State:onUpdate(dt)
    
end

-- runs upon switching to another state. will yeild State:onUpdate(), preventing the next state's onEnter to begin until returns true.
function State:onExit(dt)
    
    return true
end

return State