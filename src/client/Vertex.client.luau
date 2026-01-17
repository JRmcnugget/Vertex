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
VertexManager.States = {}
VertexManager.Components = {}

-- Shared // variables available for ready access across any State or Component
VertexManager.Shared = {
    char = nil, 
    humanoid = nil,
    humanoidRoot = nil
}

-- StateDefaults // base variables and/or capabilites of a state to inheret upon loading. Anything written in the state's .new() will override these
VertexManager.StateDefaults = {
    interruptable = false,
    isEpic = false
}
VertexManager.StateDefaults.__index = VertexManager.StateDefaults

function VertexManager:Init()
    local plrInstance = script.Parent.Parent
    if not plrInstance:IsA("Player") then
        error("Invalid Player instance! Did you parent Vertex improperly?")
    end
    self.Player = plrInstance
    
    self:loadStates()
    
    local removingCharacter = false
    self.Player.CharacterAdded:Connect(function(newModel)
        self.Shared.Char = newModel
        newModel.ChildAdded:Connect(function(instance)
            self:updateCharacter(removingCharacter, instance)
        end)
    end)

    print('ok done')
    print(self)
end

function VertexManager:Cleanup()

end

function VertexManager:changeState()
    --todo
end

-- this implementation is not fun, but there doesn't appear to be any other way to do this that is less redundant
-- boolean, instance. Used to set new instance variables when a new character is loaded. Will only override if nil. if removingCharacter is false, instance will be ignored and charvalues will be set to nil
function VertexManager:updateCharacter(removingCharacter, instance)
    if (not removingCharacter and not instance) and self.Config.printWarnings then
        error("Invalid variables called to Vertex:updateCharacters! Variables are: removingCharacter = "..tostring(removingCharacter)..", instance = "..tostring(instance)..". Variables should be: boolean, instance")
    end
    local requiredInstances = {"Humanoid", "HumanoidRootPart"} -- instances to look for
    local instanceLinks = {"humanoid", "humanoidRoot"} -- variable names within VertexManager.Shared to override
    if not removingCharacter then
        for count, instance in pairs(requiredInstances) do
            local managerSharedValue = self.Shared[instanceLinks[count]] -- find if the value already exists, if not we can set it
            if instance == requiredInstances[count] and not managerSharedValue then
                self.Shared[instanceLinks[count]] = instance
                break
            end
        end
    else
        for count, instance in ipairs(instanceLinks) do
            self.Shared[instanceLinks[count]] = nil
        end
    end
    print(self)
end

function VertexManager:loadStates()
    local moduleList = VertexManager.Config.stateFolder:GetChildren()
    for count, module in pairs(moduleList) do
        if module:IsA("ModuleScript") then
            local stateModule = require(module)
            local stateInstance = stateModule.new(self)
            local stateName = stateInstance.Name and stateInstance.Name or module.Name
            self.States[stateName] = stateInstance
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

function update(dt)

end
runService:BindToRenderStep('VertexUpdate', VertexManager.Config.RenderPriority, update)

VertexManager:Init()