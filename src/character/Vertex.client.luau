--Vertex v0.01 
-- by JRmcnugget

--Roblox Services
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
VertexManager.Config = require(VertexLib:WaitForChild('VetexConfig'))
VertexManager.States = {}
VertexManager.Components = {}

-- GlobalState // variables shared across all systems
VertexManager.GlobalState = {
    player = player,
    char = char,
    humanoid = humanoid,
    humanoidRootPart = humanoidRootPart
}


function VertexManager:update()
    --update loop, todo
end
runService.Heartbeat:Connect(VertexManager.update)