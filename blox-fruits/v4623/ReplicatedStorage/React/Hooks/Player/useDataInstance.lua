local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
return function()
	local v2

	if RunService:IsRunning() then
		v2 = Players.LocalPlayer
	end

	return useMatchingChild(v2, function(folder)
		if folder:IsA("Folder") and folder.Name == "Data" then
			return folder
		end

		return nil
	end)
end