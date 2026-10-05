local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Boot"):display():traceback():build()
local Players = game:GetService("Players")

if Players.LocalPlayer:HasTag("InitClientDebounce") then
	return
end

v.info("starting client boot script")
Players.LocalPlayer:AddTag("InitClientDebounce")
local Loader = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Loader"))
v.info("required loader")
local controllers = game.ReplicatedStorage:WaitForChild("Controllers")
local clientComponents = game.ReplicatedStorage:WaitForChild("ClientComponents")
local sharedComponents = game.ReplicatedStorage:WaitForChild("SharedComponents")
v.info("finished waiting for instances")
local folders = { controllers.UI, clientComponents, sharedComponents }

for _, folder in pairs(clientComponents:GetChildren()) do
	if folder:IsA("Folder") then
		table.insert(folders, folder)
	end
end

v.info("hooking up pre-load modules")
clientComponents.ChildAdded:Connect(function(child)
	Loader.SpawnAll(Loader.LoadChildrenFromLocations({ child }), { "init", "OnStart" })
end)
Loader.SpawnAll(Loader.LoadChildrenFromLocations({ controllers.MapServices }), { "init", "OnStart" })
local childrenFromLocations = Loader.LoadChildrenFromLocations({ controllers })
v.info("completed hooking up pre-load modules")

if not game.Players.LocalPlayer.Character then
	repeat
		task.wait()
	until game.Players.LocalPlayer.Character
end

v.info("character loaded, spawning remaining controllers")
Loader.SpawnAll(childrenFromLocations, { "init", "OnStart" })
Loader.SpawnAll(Loader.LoadChildrenFromLocations(folders), { "init", "OnStart" })
v.info("completed client load")