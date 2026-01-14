--Vertex v0.02
-- by JRmcnugget

--inital player instance validation
local Player = script.Parent
if not Player:IsA('Player') then
    error("Vertex is not parented to a player and will not function! Did you make sure to parent Vertex to StarterPlayerScripts?")
end

--Roblox Services
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local VertexLib = replicatedStorage:WaitForChild('VertexLib')

-- Script Manager
local VertexManager = {}

-- Configuration
VertexManager.Config = require(VertexLib:WaitForChild('VertexConfig'))
VertexManager.States = {}
VertexManager.Components = {}
VertexManager.ActiveState = nil

-- GlobalState // variables shared across all systems
VertexManager.GlobalState = {
    plr = Player 
}

-- BaseState // default values/capabilities for a state to inheret upon loading
VertexManager.BaseState = {
    updateMoveDir = true,
    updateLookDir = true,
    interruptable = false,
    canJump = false,
    canCrouch = false
}
VertexManager.BaseState.__index = VertexManager.BaseState

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
    print(self)
end

function VertexManager:loadComponents()
    --todo
end

function VertexManager:InputHandler()
    --todo
end

function VertexManager:deathCleanup()

end

function VertexManager:update(dt)
    --update loop, todo
end
runService.RenderStepped:Connect(VertexManager.update)


VertexManager:loadStates()