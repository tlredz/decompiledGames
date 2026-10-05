local import = _G.import("romodel")
local import2 = _G.import("viewImports")
local basic = import2:get("basic")
local menu = import2:get("menu")
local react = import2:get("react")
local import3 = _G.import("rewardListData")
local model = import.model(basic.EmptyList, basic.Padding, react.Reactive)

function model.init()
	return {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Padding = UDim.new(0.075, 0),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		PaddingTop = UDim.new(0.05, 0),
		CanvasHeight = 1,
		KeyChains = { "RewardListsClaimed" },
		SavedChanged = function(p, p2)
			local claimButton = p.RewardsList.Inner.ClaimButton
			local group = p2.RewardListsClaimed.Group
			claimButton.Inner.TextLabel.Text = group and "Claimed" or "Claim"
		end
	}, {
		Title = import.make(basic.TextLabel, {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0.125, 0),
			Text = "GROUP REWARDS",
			StrokeWidth = 4
		}),
		RewardsList = import.make(menu.RewardList, {
			LayoutOrder = 2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Rewards = import3.Group.Rewards,
			Id = "Group"
		}),
		Description = import.make(basic.TextLabel, {
			LayoutOrder = 4,
			Size = UDim2.new(0.8, 0, 0.15, 0),
			Text = "Like the game 👍 + Join the group",
			StrokeWidth = 3
		})
	}
end

return {
	Page = model
}