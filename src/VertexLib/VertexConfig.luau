local VertexConfig = {
    initalState = "Grounded",
    RenderPriority = Enum.RenderPriority.Camera.Value + 1,
    printWarnings = true,
    stateFolder = game.ReplicatedStorage.VertexLib:FindFirstChild('States'),
    componentFolder = game.ReplicatedStorage.VertexLib:FindFirstChild('Components'),
    componentInputBindPrefix = "On",
    componentDefaultInputContext = "Default",
    componentInputContextDefaultPriority = 2000,
    componentInputContextDefaultSink = false
}

return VertexConfig