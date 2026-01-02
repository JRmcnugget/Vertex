local State = {}
local StateMeta = {__index = State}

function State.new(manager, globalState)
    local self = { -- state configuration
        Manager = manager,
        GlobalState = globalState,
        StateName = "BaseState",
        StateDescriptor = "cooldescriptiongoeshere", -- idk if this is needed, may remove later
        UpdateLook = false,
        UpdateMove = false
    }

    return setmetatable(self, StateMeta)
end

-- State Methods
-- Leave empty for any methods unused
function State:onBegin()
    -- called when the state begins after being set by the state manager

    -- module data pass test, delete me later
    print(self.Name, self.GlobalState.Number)
    self.Manager:amongus()
end

function State:step(dt)
    -- called every frame while state is active
end

function State:onEnd()
    -- called when the state is being switched out for another state
end

return State