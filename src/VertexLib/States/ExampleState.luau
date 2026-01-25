local State = {}

function State.new(Manager)
    local self = {
        Manager = Manager,
        Name = "amongus"
    }
    return setmetatable(self, Manager.StateDefaults)
end

function State:onEnter()

end

function State:onUpdate()

end

function State:onExit()

end

return State