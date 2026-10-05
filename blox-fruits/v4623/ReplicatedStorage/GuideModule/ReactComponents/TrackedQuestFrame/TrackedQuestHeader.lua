local React = require(game.ReplicatedStorage.Packages.React)
local Util = require(script.Parent.Util)
local AbandonQuestButton = require(script.Parent.AbandonQuestButton)
local OutlinedText = require(script.Parent.OutlinedText)

local function TrackedQuestHeader(props)
	local templates = props.Templates or {}
	local title = templates.Title or OutlinedText
	local abandonQuestButton = templates.AbandonQuestButton or AbandonQuestButton
	local createElement = React.createElement
	local mergeProps = Util.mergeProps({
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.5,
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.492208, 0),
		Size = UDim2.fromScale(0.993882, 0.273368)
	}, props.RootProps)
	local v2 = {
		textLabel = React.createElement(title, Util.mergeProps({
			Layered = true,
			Position = UDim2.fromScale(0.03, 0.55),
			Size = UDim2.fromScale(0.642258, 0.767029),
			Text = props.Title,
			TextColor = Color3.new(),
			FrontTextColor = Color3.new(1, 1, 1)
		}, props.TitleProps)),
		uIGradient = React.createElement("UIGradient", Util.mergeProps({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.339975, 0),
				NumberSequenceKeypoint.new(0.729763, 0.4875),
				NumberSequenceKeypoint.new(1, 1)
			})
		}, props.GradientProps)),
		abandonQuestButton = 0
	}
	local abandonQuestButton2

	if Util.valueOrDefault(props.ShowAbandonButton, true) then
		abandonQuestButton2 = React.createElement(abandonQuestButton, Util.mergeProps({
			OnActivated = props.OnAbandonQuest
		}, props.AbandonQuestButtonProps))
	end

	v2.abandonQuestButton = abandonQuestButton2
	return createElement("Frame", mergeProps, v2)
end

return React.memo(TrackedQuestHeader)