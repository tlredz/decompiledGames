local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local localPlayer = Players.LocalPlayer
local flag = false

local function onCharacterAdded(instance)
	if flag then
		flag = false
		ProximityPromptService.Enabled = true
	end

	local humanoid = instance:WaitForChild("Humanoid", 10)

	if humanoid and humanoid:IsA("Humanoid") then
		humanoid.Died:Once(function()
			if localPlayer.Character ~= instance or not ProximityPromptService.Enabled then
				return
			end

			flag = true
			ProximityPromptService.Enabled = false
		end)
	end
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)

if localPlayer.Character then
	task.spawn(onCharacterAdded, localPlayer.Character)
end