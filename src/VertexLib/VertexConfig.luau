local VertexConfig = {
    initalState = "Grounded",
    RenderPriority = Enum.RenderPriority.Camera.Value + 1,
    printWarnings = true,
    enableDebugging = false,
    stateFolder = game.ReplicatedStorage.VertexLib:FindFirstChild('States'),
    componentFolder = game.ReplicatedStorage.VertexLib:FindFirstChild('Components')
}

return VertexConfig