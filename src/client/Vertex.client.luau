--Vertex v0.03
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
VertexManager.BindedEvents = {}

-- Shared // variables available for ready access across any State or Component
VertexManager.Shared = {
    isDead = false,
    cam = workspace.CurrentCamera,
    char = nil, 
    humanoid = nil,
    humanoidRoot = nil,
    controllerManager = nil,
    inputDirection = Vector3.new(0,0,0),
    lookDirection = Vector3.new(0,0,0),
    isCrouched = false
}
VertexManager.SharedDefault = table.clone(VertexManager.Shared)

-- StateDefaults // base variables and/or capabilites of a state to inheret upon loading. 
-- Anything written in the state's .new() will override these
VertexManager.StateDefaults = {
    interruptable = true,
    isEpic = false
}
VertexManager.StateDefaults.__index = VertexManager.StateDefaults

function VertexManager:Init()
    local plrInstance = game.Players.LocalPlayer
    self.Player = plrInstance
    
    self:loadStates()
    self:loadComponents()
    
    self.Player.CharacterAdded:Connect(function(newModel)
        task.spawn(function() -- we dont document the thread here in .ActiveThreads so the thread doesn't kill itself in the process
            self:Cleanup()
            self:updateCharacter(newModel)
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
    self:changeState(self.Config.initalState, true)
    self.Shared = table.clone(self.SharedDefault)
end

-- queries the new playermodel for necessary components to be referenced within .Shared
-- add any references as necessary
function VertexManager:updateCharacter(newModel)
    self.Shared.char = newModel
    self.Shared.humanoid = newModel:WaitForChild("Humanoid")
    self.Shared.humanoidRoot = newModel:WaitForChild('HumanoidRootPart')
    self.Shared.controllerManager = newModel:WaitForChild('ControllerManager')
end

-- binds the given function using contextactionservice
-- function, instance, string, array, boolean
function VertexManager:createBind(func, component, actionName, keycodes, mobileButton)
    local bindedEvent = ContextActionService:BindAction(actionName, function(actionName, inputType, inputObj)
        if inputType == Enum.UserInputState.Begin or inputType == Enum.UserInputState.End then
           func(component, inputType, inputObj) -- function expects a self value as the first variable so we must pass it to it
        end
    end, mobileButton, unpack(keycodes))

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
            if (self.ActiveState == nil or override) or not self.ActiveState.interruptable then
                local previousState = self.ActiveState
                local prevStateName = (previousState ~= nil and previousState.Name) and previousState.Name or tostring(previousState)
                
                self.ActiveThreads['ChangeState'] = task.spawn(function()
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

function VertexManager:loadComponents()
    local moduleList = self:getModules(self.Config.componentFolder)
    for count, module in pairs(moduleList) do
        local componentInstance = require(module).new(self)
        local componentName = componentInstance.Name and componentInstance.Name or module.Name
        self.Components[componentName] = componentInstance
        
        if componentInstance.bindableEvents then
            for count, requestedBind in pairs(componentInstance.bindableEvents) do
                if (requestedBind.functionName and type(requestedBind.functionName) == "string") and requestedBind.keybinds then
                    for count2, keyCode in pairs(requestedBind.keybinds) do
                       if keyCode.EnumType ~= Enum.KeyCode then
                           error(tostring(keyCode).."is not a valid keycode!")
                        end
                    end
                    local requestedEvent = componentInstance[requestedBind.functionName]
                    if requestedEvent then
                        self.BindedEvents[componentName.."_"..requestedBind.functionName] = self:createBind(requestedEvent, componentInstance, requestedBind.functionName, requestedBind.keybinds, false)
                    end
                else
                    error("Arugment invalid for requested bind "..tostring(requestedBind).. "of component"..componentName)
                end
            end
        end
    end
    return true
end

-- runs the active state's onUpdate, along with any other components with an onUpdate function
function VertexManager:update(dt)
    if self.ActiveState ~= nil and not self.AwaitingSignal then
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