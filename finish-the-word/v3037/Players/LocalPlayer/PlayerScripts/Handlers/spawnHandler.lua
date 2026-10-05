local import = _G.import("event")
local import2 = _G.import("global")
local localPlayer = game.Players.LocalPlayer

local function characterAdded(character)
	local playerSave = import2.get("playerSave", localPlayer)
	local playerSession = import2.get("playerSession", localPlayer)
	import.fire("characterAdded", localPlayer, character, playerSave, playerSession)
	character:WaitForChild("Humanoid").Died:Connect(function()
		import.fire("characterDied", localPlayer, character, playerSave, playerSession)
	end)
end

local function setupSpawn()
	localPlayer.CharacterAdded:connect(characterAdded)
	local character = localPlayer.Character

	if character then
		characterAdded(character)
	end
end

return {
	Priority = 2,
	Run = function()
		import.connect("dataLoaded", setupSpawn)
	end
}