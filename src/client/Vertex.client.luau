--Vertex v0.06
-- by JRmcnugget

--Roblox Services
local ContextActionService = game:GetService("ContextActionService")
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
VertexManager.ActiveThreads = {}
VertexManager.CleanupThread = "None"
VertexManager.BindedEvents = {}

-- Shared // variables available for ready access across any State or Component
VertexManager.Shared = {
    cam = workspace.CurrentCamera,
    char = nil, 
    humanoid = nil,
    humanoidRoot = nil,
    hitbox = nil,
    controllerManager = nil,
    groundSensor = nil,
    airController = nil,
    groundcontroller = nil,
    inputDirection = Vector3.new(0,0,0),
    lookDirection = Vector3.new(0,0,0),
    isCrouched = false,
    crouchInput = false,
    hitboxSize = Vector3.new(2, 5.944, 2),
    hitboxSizeCrouched = Vector3.new(2, 3.95, 2),
    hitboxOffset = {C0 = CFrame.new(0, -1.35, 0), C1 = CFrame.new(0, -0.324, 0)},
    hitboxOffsetCrouched = {C0 = CFrame.new(0, 0.111, 0), C1 = CFrame.new(0, 0.113, 0)},
    groundOffset = 3,
    groundOffsetCrouched = 1,
    safeCheckOffset = 0.3,
    walkSpeed = 25,
    crouchSpeed = 16,
    numJumps = 0,
}
VertexManager.SharedDefault = table.clone(VertexManager.Shared)

-- StateDefaults // base variables and/or capabilites of a state to inheret upon loading. 
-- Anything written in the state's .new() will override these
VertexManager.StateDefaults = {
    interruptable = true,
    isEpic = false,
    canJump = false,
    canCrouch = false
}
VertexManager.StateDefaults.__index = VertexManager.StateDefaults

function VertexManager:Init()
    local plrInstance = game.Players.LocalPlayer
    self.Player = plrInstance
    
    self:loadStates()
    self:loadComponents()
    
    self.Player.CharacterAdded:Connect(function(newModel)
        self.CleanupThread = task.defer(function() -- task.defer must be used here to prevent instability with renderstep and thread desyncs
            self:Cleanup()
            self:updateCharacter(newModel) 
            self:changeState(self.Config.initalState, true)
            self.CleanupThread = nil
        end)
    end)
end

-- kills all running threads to prevent possible desync issues, and resets all variables
function VertexManager:Cleanup()
    for count, thread in pairs(self.ActiveThreads) do
        task.cancel(thread)
        self.ActiveThreads[thread] = nil
    end
    self.ActiveState = nil
    self.AwaitingSignal = false
    self.Shared = table.clone(self.SharedDefault)
end

-- queries the new playermodel for necessary components to be referenced within .Shared
-- add any references as necessary
function VertexManager:updateCharacter(newModel)
    self.Shared.char = newModel
    self.Shared.humanoid = newModel:WaitForChild("Humanoid")
    self.Shared.humanoidRoot = newModel:WaitForChild('HumanoidRootPart')
    self.Shared.hitbox = newModel:WaitForChild('Hitbox')
    self.Shared.groundSensor = self.Shared.humanoidRoot:WaitForChild('GroundSensor')
    self.Shared.controllerManager = newModel:WaitForChild('ControllerManager')
    self.Shared.groundController = self.Shared.controllerManager:WaitForChild('GroundController')
    self.Shared.airController = self.Shared.controllerManager:WaitForChild('AirController')
    self.Shared.respawnService = replicatedStorage:WaitForChild('RespawnService')
    return true
end

-- binds the given function using contextactionservice
-- function, instance, string
function VertexManager:createBinds(func, component, inputAction)

    local bindedEvent = inputAction.StateChanged:Connect(function(newState)
        func(component, newState) -- the returned information varies depending on the input bind type, so we pass it to the function for developer use. the component must have itself passed to it as well in the first variable
    end)
    
    return bindedEvent
end

-- requests VertexManager to switch to a new state, as indicated by the newState variable. 
-- runs each respective state's onEnter() and onExit(), and will ignore state.interruptable if boolean override is true.
-- if a changestate is requested in the middle of another state change, it will interupt the currently ongoing one in favour of the new state
-- string (stateName), boolean (true/false)
function VertexManager:changeState(newState, override, dt)
    local requestedState = self.States[newState]
    local ActiveChange = self.ActiveThreads["ChangeState"]

    if ActiveChange then
        task.cancel(ActiveChange)
        self.ActiveThreads["ChangeState"] = nil
        self.AwaitingSignal = false
    end

    if requestedState then
        if requestedState ~= self.ActiveState then
            if (self.ActiveState == nil or override) or self.ActiveState.interruptable then
                local previousState = self.ActiveState
                local prevStateName = (previousState ~= nil and previousState.Name) and previousState.Name or tostring(previousState)
                
                self.ActiveThreads['ChangeState'] = task.spawn(function()
                    self.AwaitingSignal = true
                    if previousState and previousState.onExit then
                        previousState:onExit(dt)
                    elseif self.Config.printWarnings and self.ActiveState ~= nil then
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
                    self.ActiveThreads["ChangeState"] = nil
                end)

            end
        elseif self.Config.printWarnings then
            warn("State "..tostring(newState).." is already active!")
        end
    elseif self.Config.printWarnings then
        warn("State "..tostring(newState).." does not exist!")
    end
end

-- helper function to remove redundant code, and gather all valid modules
function VertexManager:getModules(parent)
    local modules = {}
    local instanceList = parent:GetChildren()
    for count, instance in pairs(instanceList) do
        if instance:IsA("ModuleScript") then
            table.insert(modules, instance)
        elseif self.Config.printWarnings then
            warn("Instance "..instance.Name.." is not a modulescript, ignoring...")
        end
    end
    return modules
end

-- load all states into VertrexManager.States, and provide metatable inheritance from .StateDefaults
function VertexManager:loadStates()
    local moduleList = self:getModules(self.Config.stateFolder)
    for count, module in pairs(moduleList) do
        local stateModule = require(module)
        local stateMeta = setmetatable(stateModule, self.StateDefaults)
        local stateInstance = stateModule.new(self)
        stateInstance = setmetatable(stateInstance, stateMeta)
        local stateName = stateInstance.Name and stateInstance.Name or module.Name
        self.States[stateName] = stateInstance
    end
    return true
end

-- load components into VertexManager.Components, and binds any functions referenced in the components bindableEvents table
function VertexManager:loadComponents()
    local moduleList = self:getModules(self.Config.componentFolder)
    for count, module in pairs(moduleList) do
        local componentModule = require(module)
        local componentInstance = componentModule.new(self)
        componentInstance = setmetatable(componentInstance, componentModule)
        local componentName = componentInstance.Name and componentInstance.Name or module.Name
        self.Components[componentName] = componentInstance

        local componentChildren = module:GetChildren()
        if #componentChildren > 0 then
            for count, bindInstance in pairs(componentChildren) do
                if bindInstance:IsA("InputAction") then
                    local prefix = self.Config.componentInputBindPrefix and self.Config.componentInputBindPrefix or ""
                    local override = bindInstance:GetAttribute("handlerOverride")
                    local requestEventName = override or (prefix..bindInstance.Name)
                    local requestedEvent = componentInstance[requestEventName]
                    if requestedEvent then
                        self.BindedEvents[componentName.."_"..requestEventName] = self:createBinds(requestedEvent, componentInstance, bindInstance)
                    elseif self.Config.printWarnings then
                        warn("Function "..requestEventName.." of component "..componentName.." does not exist! Did you type the InputAction or Function name correctly?")
                    end
                else
                    if self.Config.printWarnings then
                        warn("Component "..bindInstance.Name.." is not an InputAction, ignoring...")
                    end
                end
            end
        end
    end
    return true
end

-- runs the active state's onUpdate, along with any other components with an onUpdate function
function VertexManager:update(dt)
    if (self.CleanupThread) or self.ActiveState == nil then 
        return 
    end

    if not self.AwaitingSignal then
        local StateName = self.ActiveState.Name and self.ActiveState.Name or tostring(self.ActiveState)
        if self.ActiveState.onUpdate then
            self.ActiveState:onUpdate(dt)
        else
            error("State "..StateName.." does not have an onUpdate function!")
        end
    end
    for count, component in pairs(self.Components) do
        if component.onUpdate then
            local updateInterval = component.updateFrequency and 1/component.updateFrequency or nil
            local componentAccumilate = component.accumulator + dt
            if updateInterval and componentAccumilate then
                if componentAccumilate < updateInterval then
                    component.accumulator = componentAccumilate
                else
                    component:onUpdate(dt)
                    component.accumulator = 0
                end
            else
                component:onUpdate(dt)
            end
        end
    end
end

-- initalizes Vertex, duh. if vertex no begin vertex no exist, so therefore no worky
VertexManager:Init()

-- runservice bind
runService:BindToRenderStep('VertexUpdate', VertexManager.Config.RenderPriority, function(dt)
    VertexManager:update(dt) 
end)