local import = _G.import("romodel")
local import2 = _G.import("afkRewardData")
local import3 = _G.import("iconData")
local import4 = _G.import("rewardData")
local import5 = _G.import("iterUtil")
local import6 = _G.import("viewImports")
local basic = import6:get("basic")
import6:get("react")
local afkRewardPanel = import6:get("afkRewardPanel")
import6:get("item")
game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local model = import.model(basic.ImageLabel)

function model.init(p)
	local reward = p.Reward
	local v = import4[reward.Reward]
	return {
		Size = UDim2.new(0.3, 0, 0.3, 0),
		Image = import3[v.Icon]
	}, {
		AmountLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0.5, 0, 0.1, 0),
			Size = UDim2.new(0.9, 0, 0.4, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Text = v.Amount,
			StrokeWidth = 1
		}),
		ChanceLabel = import.make(basic.TextLabel, {
			Position = UDim2.new(0.5, 0, 0.7, 0),
			Size = UDim2.new(0.9, 0, 0.3, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Text = reward.Chance * 100 .. "%",
			StrokeWidth = 1
		})
	}
end

local model2 = import.model(basic.Ui, basic.EmptyList)

function model2.init()
	return {
		Position = UDim2.new(0.983, 0, 0.945, 0),
		Size = UDim2.new(0.115, 0, 0.2, 0),
		AnchorPoint = Vector2.new(1, 1),
		FillDirection = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0.075)
	}, {
		RewardsFrame = import.make(afkRewardPanel.RewardList, {
			Size = UDim2.new(1.75, 0, 4, 0),
			LayoutOrder = 1,
			Title = "Possible Rewards",
			KeyChains = {},
			SavedChanged = function()
				return nil, import5.toDict(import2, function(p, reward)
					return p, import.make(model, {
						Reward = reward
					})
				end)
			end
		})
	}
end

return {
	BottomRightPanel = model2
}