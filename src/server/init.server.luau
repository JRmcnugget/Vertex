local event = Instance.new("RemoteFunction")
event.Parent = game.ReplicatedStorage
event.Name = "RespawnService"

function loadCharacter(player)
    player:LoadCharacterAsync()
end

event.OnServerInvoke = loadCharacter
