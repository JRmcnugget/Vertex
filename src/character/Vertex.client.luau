--Vertex v0.02
-- by JRmcnugget

-- TODO: move to starterplayer to prevent unnessecary cpu util upon character reinitalize

--Roblox Services
local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TutorialService = game:GetService("TutorialService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local VertexLib = replicatedStorage:WaitForChild('VertexLib')

--player variables
local char = script.Parent
local player = game.Players:GetPlayerFromCharacter(char)
local humanoid = char:WaitForChild("Humanoid")
local humanoidRootPart = char:WaitForChild("HumanoidRootPart")

-- Script Manager
local VertexManager = {}

-- Configuration
VertexManager.Config = require(VertexLib:WaitForChild('VertexConfig'))
VertexManager.States = {}
VertexManager.Components = {}
VertexManager.updateFunctions = {}
VertexManager.ActiveState = nil

-- GlobalState // variables shared across all systems
VertexManager.GlobalState = {
    player = player,
    char = char,
    humanoid = humanoid,
    humanoidRootPart = humanoidRootPart
}

-- BaseState // default values/capabilities for a state to inheret upon loading
VertexManager.BaseState = {
    updateMoveDir = true,
    updateLookDir = true,
    canJump = false,
    canCrouch = false
}
VertexManager.BaseState.__index = VertexManager.BaseState

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
    print(self)
end

function VertexManager:loadComponents()
    --todo
end

function VertexManager:changeState()
    --todo
end

function VertexManager:InputHandler()
    --todo
end

function VertexManager:update(dt)
    --update loop, todo
end
runService.RenderStepped:Connect(VertexManager.update)

VertexManager:loadStates()