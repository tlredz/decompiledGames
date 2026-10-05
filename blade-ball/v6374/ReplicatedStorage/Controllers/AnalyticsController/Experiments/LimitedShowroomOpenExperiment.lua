local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Types.Analytics)
require3(ReplicatedStorage2.ServerInfo)
require3("@game/ReplicatedStorage/Types/Templates/Lobbies")
return {
	RemoteConfig = "LimitedShowroomOpen",
	DefaultValue = "Prompt",
	TestConfigValues = {
		Prompt = 100,
		Hitbox = 0
	},
	Configs = {
		Hitbox = function(_)
			local limited = workspace:WaitForChild("Spawn", 1000000):WaitForChild("Limited", 60)
			local swordPacks = limited and limited:WaitForChild("SwordPacks", 60)
			local stand = swordPacks and swordPacks:WaitForChild("Stand", 60)

			if not stand then
				return
			end

			stand:SetAttribute("WindowName", "LimitedSword_SwordPacks")
			stand:AddTag("UIPromptNPC")
			local proximityPrompt = stand:FindFirstChildWhichIsA("ProximityPrompt", true)

			if proximityPrompt then
				proximityPrompt.Enabled = false
			end
		end
	}
}