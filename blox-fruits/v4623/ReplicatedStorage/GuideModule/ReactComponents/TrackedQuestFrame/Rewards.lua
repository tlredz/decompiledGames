local React = require(game.ReplicatedStorage.Packages.React)
local Util = require(script.Parent.Util)
local RewardItem = require(script.Parent.RewardItem)

local function Rewards(props)
	local rewards = props.Rewards or {}
	local count = #rewards
	local v = not (count > 0) and 1 or 1 / count
	local children = {
		uIListLayout = React.createElement("UIListLayout", Util.mergeProps({
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(-0.01, 0),
			SortOrder = Enum.SortOrder.LayoutOrder
		}, props.LayoutProps))
	}
	local itemTemplate = props.ItemTemplate or RewardItem

	for i, reward in ipairs(rewards) do
		local clone = table.clone(reward)
		clone.LayoutOrder = reward.LayoutOrder or i
		clone.WidthScale = reward.WidthScale or v
		local component = reward.Component or itemTemplate
		children[reward.Key or tostring(i)] = React.createElement(component, clone)
	end

	return React.createElement("Frame", Util.mergeProps({
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.00946554, 0.726378),
		Size = UDim2.fromScale(0.96233, 0.226505)
	}, props.RootProps), children)
end

return React.memo(Rewards)