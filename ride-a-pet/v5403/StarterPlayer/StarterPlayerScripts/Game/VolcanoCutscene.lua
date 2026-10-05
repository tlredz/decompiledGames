local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
ReplicatedStorage:WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RE/VolcanoCutscene", 1e999).OnClientEvent:Connect(function()
	if localPlayer:GetAttribute("GameLoaded") ~= true or localPlayer:GetAttribute("TutorialActive") == true then
		return
	end

	task.spawn(function()
		local Volcano = require(ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Cutscenes"):WaitForChild("Volcano"))
		local v, v2 = Volcano.Play({})

		if not v then
			warn("[VolcanoCutscene] " .. tostring(v2 or "Cancelled"))
		end
	end)
end)