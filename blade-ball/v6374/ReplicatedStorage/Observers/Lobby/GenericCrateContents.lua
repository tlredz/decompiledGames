local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage.Common.Utils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local GenericCrateData = require(ReplicatedStorage.Shared.GenericCrateData)
local _ = game.Players.LocalPlayer.PlayerGui
local v = {}

for _, reward in GenericCrateData.Rewards do
	table.insert(v, {
		Reward = reward.Reward,
		Chance = reward.Chance
	})
end

table.sort(v, function(a, b)
	return a.Chance > b.Chance
end)
return Observers.observeTag("GenericCrateContents", function(p)
	local content = p.Rates.Content

	for childName, v2 in v do
		local child = content:FindFirstChild(childName)

		if not child then
			continue
		end

		child.Title.Text = v2.Reward.DisplayName
		child.Percent.Text = `{v2.Chance}%`
		child.Icon.Image = v2.Reward.Icon or ""
	end

	return nil
end)