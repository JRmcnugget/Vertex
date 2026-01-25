--Vertex v0.03
-- by JRmcnugget

--Roblox Services
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local VertexLib = replicatedStorage:WaitForChild('VertexLib')

-- THE vertex manager itself
local VertexManager = {}

-- VertexManager Properties
VertexManager.Config = require(VertexLib.VertexConfig)
VertexManager.ActiveState = nil
VertexManager.Player = nil
VertexManager.AwaitingSignal = false
VertexManager.States = {}
VertexManager.Components = {}

-- Shared // variables available for ready access across any State or Component
VertexManager.Shared = {
    char = nil, 
    humanoid = nil,
    humanoidRoot = nil,
    inputDirection = Vector3.new(0,0,0)
}

-- StateDefaults // base variables and/or capabilites of a state to inheret upon loading. 
-- Anything written in the state's .new() will override these
VertexManager.StateDefaults = {
    interruptable = false,
    isEpic = false
}
VertexManager.StateDefaults.__index = VertexManager.StateDefaults

function VertexManager:Init()
    local plrInstance = game.Players.LocalPlayer
    self.Player = plrInstance
    
    self:loadStates()
    self:changeState(self.Config.initalState)
    
    self.Player.CharacterAdded:Connect(function(newModel)
        self.Shared.char = newModel
        task.spawn(function()
            self:updateCharacter(newModel)
        end)
    end)
end

-- apparently there was something simplier than commit e76fd30, my bad, just overengineered to the max 
function VertexManager:updateCharacter(newModel)
    local humanoidInstance = newModel:WaitForChild("Humanoid")
    local humanoidRootInstance = newModel:WaitForChild('HumanoidRootPart')
    self.Shared.humanoid = humanoidInstance
    self.Shared.humanoidRoot = humanoidRootInstance
end

function VertexManager:Cleanup()

end

-- requests VertexManager to switch to a new state, as indicated by the newState variable. 
-- runs each respective state's onEnter() and onExit(), and will ignore state.interruptable if boolean override is true.
-- string (stateName), boolean (true/false)
function VertexManager:changeState(newState, override, dt)
    print(self)
    local requestedState = self.States[newState]
    if requestedState then
        if requestedState ~= self.ActiveState then
            if (self.ActiveState == nil or override) or self.ActiveState.interruptable then
                local previousState = self.ActiveState
                local prevStateName = (previousState ~= nil and previousState.Name) and previousState.Name or tostring(previousState)
                task.spawn(function()
                    print(requestedState)
                    self.AwaitingSignal = true
                    if previousState and previousState.onExit then
                        previousState:onExit(dt)
                    elseif self.Config.printWarnings then
                        warn("State "..prevStateName.." does not have onExit")
                    end
                    
                    self.ActiveState = requestedState
                    local newStateName = requestedState.Name and requestedState.Name or tostring(requestedState)
                    if requestedState and requestedState.onEnter then
                        requestedState:onEnter(dt)
                    elseif self.Config.printWarnings then
                        warn("State"..newStateName.." does not have onEnter")
                    end
                    self.AwaitingSignal = false
                end)
            end
        elseif self.Config.printWarnings then
            warn("State "..tostring(newState).." is already active!")
        end
    elseif self.Config.printWarnings then
        warn("State "..tostring(newState).." does not exist!")
    end
end

function VertexManager:loadStates()
    local moduleList = VertexManager.Config.stateFolder:GetChildren()
    for count, module in pairs(moduleList) do
        if module:IsA("ModuleScript") then
            local stateModule = require(module)
            local stateInstance = stateModule.new(self)
            local stateName = stateInstance.Name and stateInstance.Name or module.Name
            self.States[stateName] = stateInstance
            print(stateInstance.interruptable)
        elseif self.Config.printWarnings then
            warn("Instance "..module.Name.." is not a modulescript, ignoring...")
        end
    end
    return true
end

function VertexManager:loadComponents()
    --todo
end

function VertexManager:InputHandler()
    --todo
end

function VertexManager:update(dt)
    if self.ActiveState ~= nil and not self.AwaitingSignal then
        local StateName = self.ActiveState.Name and self.ActiveState.Name or tostring(self.ActiveState)
        if self.ActiveState.onUpdate then
            self.ActiveState:onUpdate(dt)
        else
            error("State "..StateName.." does not have an onUpdate function!")
        end
    end
end
runService:BindToRenderStep('VertexUpdate', VertexManager.Config.RenderPriority, function(dt)
    VertexManager:update(dt)
end)

VertexManager:Init()