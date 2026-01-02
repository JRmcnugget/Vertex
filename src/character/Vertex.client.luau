--Vertex v0.01 
-- by JRmcnugget

local VertexManager = {}

--Roblox Services
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local VertexLib = replicatedStorage:WaitForChild('VertexLib')

--Settings
local config = require(VertexLib:WaitForChild('VetexConfig'))

--Modules
local States = config.stateFolder:GetChildren()
local PhysLib = VertexLib:WaitForChild('PhysicsLib')
local VFXCore = VertexLib:WaitForChild('VFXCore')

--GlobalState // variables shared across all states
local GlobalState = {
    Number = 0
}

-- module data pass test, delete me later
local module = require(VertexLib.States.BaseState)
local state = module.new(VertexManager, GlobalState)
state:onBegin()
function VertexManager:amongus()
    print('VertexManager says hi')
end