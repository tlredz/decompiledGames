local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local localPlayer = Players.LocalPlayer
return {
	Start = function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function requestCharacterReset(p)
			Remotes.RigSync.AskRigWipe:FireServer(p)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindCharacter(character)
			character:WaitForChild("Humanoid").Died:Connect(function()
				requestCharacterReset(character) -- equivalent call inferred; original call site unknown
			end)
		end

		localPlayer.CharacterAdded:Connect(bindCharacter)

		if localPlayer.Character then
			bindCharacter(localPlayer.Character) -- equivalent call inferred; original call site unknown
		end
	end
}