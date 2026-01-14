local VertexConfig = {
    initalState = "Idle",
    RenderPriority = Enum.RenderPriority.Camera.Value + 1,
    printWarnings = true,
    enableDebugging = false,
    stateFolder = game.ReplicatedStorage.VertexLib:FindFirstChild('States'),
    componentsFolder = game.ReplicatedStorage.VertexLib:FindFirstChild('Components')
}

return VertexConfig