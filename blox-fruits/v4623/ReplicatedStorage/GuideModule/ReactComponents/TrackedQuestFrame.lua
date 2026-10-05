local React = require(game.ReplicatedStorage.Packages.React)
local Util = require(script.Util)
local OutlinedText = require(script.OutlinedText)
local ProgressBar = require(script.ProgressBar)
local Rewards = require(script.Rewards)
local TrackedQuestHeader = require(script.TrackedQuestHeader)
local ObjectiveRow = require(script.ObjectiveRow)
local rbxassetfontsfamiliesHighwayGothicjson = Font.new(
	"rbxasset://fonts/families/HighwayGothic.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)

-- equivalent calls inferred from this helper; original call sites unknown
local function getProgressText(props)
	if props.ProgressText == nil then
		return (`{props.ProgressCurrent or 0}/{props.ProgressMax or 5}`)
	end

	return Util.toText(props.ProgressText)
end

local function getDefaultRewards(props)
	local v = {}

	if Util.valueOrDefault(props.ShowMoneyReward, true) then
		table.insert(v, {
			Key = "money",
			Text = Util.toText(props.MoneyReward, "$30,000"),
			Icon = "rbxassetid://11854849691",
			TextColor = Color3.fromRGB(168, 255, 148),
			AccentColor = Color3.fromRGB(126, 195, 106),
			WidthScale = 0.375791,
			IconProps = {
				Position = UDim2.fromScale(0.03, 0.507),
				Size = UDim2.fromScale(0.269917, 1.047)
			},
			TextProps = {
				Position = UDim2.fromScale(0.34, 0.5),
				Size = UDim2.fromScale(0.626181, 0.75)
			}
		})
	end

	if Util.valueOrDefault(props.ShowExperienceReward, true) then
		table.insert(v, {
			Key = "experience",
			Text = Util.toText(props.ExperienceReward, "100,000,000 EXP"),
			Icon = "rbxassetid://11850730223",
			TextColor = Color3.fromRGB(255, 230, 53),
			AccentColor = Color3.fromRGB(255, 214, 49),
			WidthScale = 0.600063,
			IconProps = {
				Position = UDim2.fromScale(0.015, 0.507),
				Size = UDim2.fromScale(0.211318, 1.047)
			},
			TextProps = {
				Position = UDim2.fromScale(0.2, 0.5),
				Size = UDim2.fromScale(0.763559, 0.75)
			}
		})
	end

	return v
end

local function TrackedQuestFrame(props)
	local templates = props.Templates or {}
	local header = templates.Header or TrackedQuestHeader
	local description = templates.Description or OutlinedText
	local progressText = templates.ProgressText or OutlinedText
	local progressBar = templates.ProgressBar or ProgressBar
	local rewards = templates.Rewards or Rewards
	local progressCurrent = props.ProgressCurrent or 0
	local progressMax = props.ProgressMax or 5
	local rewards2 = props.Rewards or getDefaultRewards(props)
	local v = not props.Objectives and 0 or math.max(0, #props.Objectives - 1) * 0.35
	local v2 = v + 1
	local children = {
		uIGradient = React.createElement("UIGradient", Util.mergeProps({
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.403487, 0),
				NumberSequenceKeypoint.new(0.707347, 0.35625),
				NumberSequenceKeypoint.new(1, 1)
			})
		}, props.GradientProps)),
		header = React.createElement(header, Util.mergeProps({
			Title = props.Title or "Defeat 5 Gorillas",
			ShowAbandonButton = props.ShowAbandonButton,
			OnAbandonQuest = props.OnAbandonQuest,
			Templates = templates,
			RootProps = props.Objectives and {
				Size = UDim2.fromScale(0.993882, 0.273368 / v2)
			} or nil
		}, props.HeaderProps)),
		description = 0,
		bar = 0,
		progress = 0,
		rewards = 0
	}
	local description2

	if not props.Objectives then
		description2 = React.createElement(description, Util.mergeProps({
			Position = UDim2.fromScale(0.0220863, 0.406147),
			Size = UDim2.fromScale(1.04752, 0.171831),
			Text = props.Description or "Defeat bandits terrorizing the town!",
			TextColor = Color3.new(1, 1, 1),
			TextTransparency = 0.25,
			ShowStroke = false
		}, props.DescriptionProps))
	end

	children.description = description2
	local bar

	if not props.Objectives then
		bar = React.createElement(progressBar, Util.mergeProps({
			Current = progressCurrent,
			Max = progressMax,
			Ratio = props.ProgressRatio
		}, props.ProgressBarProps))
	end

	children.bar = bar
	local progress

	if not props.Objectives then
		local createElement = React.createElement
		local mergeProps = Util.mergeProps
		local v6 = {
			FontFace = rbxassetfontsfamiliesHighwayGothicjson,
			Position = UDim2.fromScale(0.0220863, 0.617031),
			Size = UDim2.fromScale(0.107276, 0.171831),
			Text = 0,
			TextColor = 0,
			StrokeProps = 0
		}
		local progressText2 = getProgressText(props) -- equivalent call inferred; original call site unknown
		v6.Text = progressText2
		v6.TextColor = Color3.new(1, 1, 1)
		v6.StrokeProps = {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.06
		}
		progress = createElement(progressText, mergeProps(v6, props.ProgressTextProps))
	end

	children.progress = progress
	children.rewards = React.createElement(rewards, Util.mergeProps({
		Rewards = rewards2,
		ItemTemplate = templates.RewardItem,
		RootProps = props.Objectives and {
			Position = UDim2.fromScale(0.00946554, (v + 0.726378) / v2),
			Size = UDim2.fromScale(0.96233, 0.226505 / v2)
		} or nil
	}, props.RewardsProps))

	for k, objective in props.Objectives or {} do
		children[`objective:{objective.Key}`] = React.createElement(ObjectiveRow, {
			Objective = objective,
			Position = UDim2.fromScale(0.0220863, (0.3 + (k - 1) * 0.35) / v2),
			Size = UDim2.fromScale(0.9, 0.35 / v2)
		})
	end

	if props.Children ~= nil then
		for k, v6 in pairs(props.Children) do
			children[k] = v6
		end
	end

	return React.createElement("Frame", Util.mergeProps({
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.5,
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		Position = props.Position or UDim2.fromScale(0, 0.526),
		Size = props.Size or UDim2.fromScale(0.23219, v2 * 0.166926),
		Visible = Util.valueOrDefault(props.Visible, true),
		ZIndex = props.ZIndex
	}, props.RootProps), children)
end

return React.memo(TrackedQuestFrame)