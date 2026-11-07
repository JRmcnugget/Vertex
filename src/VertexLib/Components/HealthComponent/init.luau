local Component = {}
Component.__index = Component

function Component.new(Manager)
    local self = {
        Manager = Manager,
        Name = "HealthComponent",
        updateFrequency = 30,
        accumulator = 0,
    }
    return self
end

function Component:onUpdate()
    if self.Manager.ActiveState.Name ~= "Dead" and self.Manager.Shared.humanoid.Health == 0 then
        self.Manager:changeState("Dead", false)
    end
end

return Component