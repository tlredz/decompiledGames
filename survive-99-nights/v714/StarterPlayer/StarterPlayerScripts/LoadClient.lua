if not game.Loaded then
	game.Loaded:Wait()
end

local Client = require(script.Parent:WaitForChild("Client"))
Client.Init()
Client:FinishLoading()
print("Client loaded!")