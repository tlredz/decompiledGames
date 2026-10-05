local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.HourlyWheelData)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Common.Utils)

local function getPlayerOPReward(localPlayer)
	local v4 = nil

	for k, guaranteedReward in v.GuaranteedRewards do
		if v.GuaranteedRewards[k + 1] and v3.RewardInfo.playerOwnsItem(localPlayer, guaranteedReward.Reward) then
			v4 = guaranteedReward
		else
			v4 = guaranteedReward
			break
		end
	end

	if v4 and v4.Replacement then
		local v6 = v2.Client:WaitReplion("Data")

		if not v6 or v4.ShouldUseReplacement(v6) then
			return v4.Replacement
		end
	end

	return v4
end

local BestItem = {
	Hook = function(self, p)
		local v4 = v2.Client:WaitReplion("Data")
		local imageLabel = p.Container:FindFirstChild("ImageLabel")
		local itemName = p.Container:FindFirstChild("ItemName")
		local totalLeft = p.Container:FindFirstChild("TotalLeft")

		local function update()
			local playerOPReward = getPlayerOPReward(Players.LocalPlayer)
			local reward = playerOPReward.Reward
			imageLabel.Image = reward.Icon or ""
			itemName.Text = reward.DisplayName or ""

			if totalLeft then
				totalLeft.Visible = false
			end

			if playerOPReward.LimitedStock and totalLeft then
				totalLeft.Visible = true
				local v5 = v2.Client:WaitReplion("LimitedStockItems")

				if v5 and v5:Get("Loaded") then
					local v6 = v5:Get({ "Stock", "Coral Greatsword" }) or 0
					local v7 = v5:Get({ "InitialStock", "Coral Greatsword" }) or 2500
					totalLeft.Text = `{v3.ValueConvertor:AddCommas(v6)}/{v3.ValueConvertor:AddCommas(v7)} LEFT`
				end
			end
		end

		v4:OnChange("ReceivedHourlyWheelCoralGreatsword", update)
		task.spawn(update)

		for _, guaranteedReward in v.GuaranteedRewards do
			local itemOwnershipState = v3.RewardInfo.getItemOwnershipState(Players.LocalPlayer, guaranteedReward.Reward)

			if itemOwnershipState then
				itemOwnershipState:Connect(update)
			end
		end

		task.spawn(function()
			v2.Client:WaitReplion("LimitedStockItems"):OnDataChange(update)
		end)
	end
}

function BestItem.Init(_, container)
	local v4 = {
		Container = container
	}
	BestItem:Hook(v4)
	return v4
end

return BestItem