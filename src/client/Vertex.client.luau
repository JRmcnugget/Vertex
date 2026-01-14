--Vertex v0.03
-- by JRmcnugget

--Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

    print('ok done')
    print(self)
end

function VertexManager:Cleanup()

end

function VertexManager:changeState()
    --todo
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