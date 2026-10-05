local ScavengerClass = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local flag = false

function ChestPromptAdded(p)
	p.HoldDuration = 4.4
end

function EnableClass()
	if flag then
		return
	end

	flag = true
	Client.Utility.ForAllTagged("ItemChestPrompt", ChestPromptAdded)
end

function ScavengerClass.Init()
	local function check()
		if localPlayer:GetAttribute("Class") == "Scavenger" and (localPlayer:GetAttribute("ClassLevel") or 1) >= 2 then
			EnableClass()
		end

		if Client.Utility.HasTalent(localPlayer, "FasterChest") then
			EnableClass()
		end
	end

	localPlayer:GetAttributeChangedSignal("Class"):Connect(check)
	localPlayer:GetAttributeChangedSignal("ClassLevel"):Connect(check)
	localPlayer:GetAttributeChangedSignal("Talent"):Connect(check)
	check()
end

return ScavengerClass