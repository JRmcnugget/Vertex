--Vertex v0.01 
-- by JRmcnugget
-- Settings begin line 11

--Roblox Services
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local VertexLib = replicatedStorage:WaitForChild('VertexLib')

--Settings
local config = require(VertexLib:WaitForChild('VetexConfig'))
local StateFolder = config.stateFolder

--Modules
local States = StateFolder:GetChildren()
local PhysLib = VertexLib:WaitForChild('PhysicsLib')
local VFXCore = VertexLib:WaitForChild('VFXCore')