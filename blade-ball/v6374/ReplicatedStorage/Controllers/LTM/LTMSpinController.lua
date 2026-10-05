local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("PolicyService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2:WaitForChild("UserInputService"))
game:GetService("RunService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local _ = Players.LocalPlayer.PlayerGui
require3(ReplicatedStorage3.ClientGameModules.GuiHandler)
require3(ReplicatedStorage3.Packages.Replion)
require3(ReplicatedStorage3.ClientGameModules.FFlagClient)
require3(ReplicatedStorage3.Common.MarketplaceService)
require3(ReplicatedStorage3.Common.Utils)
local v = require3(ReplicatedStorage3.ServerInfo)
require3(ReplicatedStorage3.Controllers.NotificationController)
require3(ReplicatedStorage3.Shared.UniverseIds)
local v2 = require3(ReplicatedStorage3.Shared.LTM)
local v3 = require3(ReplicatedStorage3.Shared.LTMCrateData)
require3(ReplicatedStorage3.Shared.Policy)
require3(ReplicatedStorage3.Packages.Net)

function onCrateStand(instance)
	if not v.isLTMServer() then
		instance:Destroy()
		return
	end

	local currentLTM = v2.getCurrentLTM()
	local v4 = currentLTM and currentLTM.getGameMode()

	if currentLTM then
		DateTime.fromUnixTimestamp(currentLTM.DateEndTime.UnixTimestamp)
	end

	local v5 = v4 and v3.Profiles[v4]

	if not v5 then
		return
	end

	local halloweenRates = instance:WaitForChild("Thing"):WaitForChild("HalloweenRates"):WaitForChild("HalloweenRates"):WaitForChild("HalloweenRates")
	local total = 0

	for _, v6 in v5.RewardPool do
		total += v6.Probability
	end

	for i = 1, 8 do
		local v6 = v5.RewardPool[i]

		if not v6 then
			continue
		end

		local child = halloweenRates.Rates.Content:FindFirstChild(i)

		if not child then
			continue
		end

		if v6 == nil or v6 and not v6.Reward then
			child.Visible = false
			print("Missing data for LTM item", i)
		else
			child.LayoutOrder = v6 and v6.Probability * 100
			child.Title.Text = v6.Reward.DisplayName or ""
			child.Image = v6.Reward.Icon or ""
			child.Percent.Text = v6 and math.ceil(v6.Probability / total * 10000) / 100 .. "%"
		end
	end
end

return {
	Start = function(_)
		for _, v4 in CollectionService:GetTagged("LTMCrate") do
			task.spawn(onCrateStand, v4)
		end

		CollectionService:GetInstanceAddedSignal("LTMCrate"):Connect(onCrateStand)
		v2.OnModeChange(function(_)
			for _, v4 in CollectionService:GetTagged("LTMCrate") do
				task.spawn(onCrateStand, v4)
			end
		end)
	end
}