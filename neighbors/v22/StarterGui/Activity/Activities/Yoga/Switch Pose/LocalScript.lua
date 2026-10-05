local Network = require(game.ReplicatedStorage.Modules.Network)
script.Parent.MouseButton1Click:Connect(function()
	Network:fire("YogaClick")
end)