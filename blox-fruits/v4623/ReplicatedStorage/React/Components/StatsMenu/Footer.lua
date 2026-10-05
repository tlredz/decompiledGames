local React = require(game.ReplicatedStorage.Packages.React)
local Button = require(script.Parent.Button)
local useStatPoints = require(game.ReplicatedStorage.React.Hooks.Player.useStatPoints)
local useIsDungeon = require(game.ReplicatedStorage.React.Hooks.useIsDungeon)
local useStoredStatRefunds = require(game.ReplicatedStorage.React.Hooks.Player.useStoredStatRefunds)
require(game.ReplicatedStorage.React.Components.StatsMenu.Types)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local v = useStatPoints()
	local v2 = useIsDungeon()
	local v3 = useStoredStatRefunds()
	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE
	}, p)
	local v6 = {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		StatPoints = 0,
		RefundButton = 0
	}
	local statPoints

	if v then
		statPoints = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			TextTransparency = v2 and 0.3 or 0,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC),
			Position = UDim2.fromScale(0.0175929, 0.5),
			Size = UDim2.fromScale(v2 and 1 or 0.385, v2 and 0.5 or 0.6),
			Text = v2 and "Your stats are being overridden by the dungeon." or `Stat Points: {v}`,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}) or nil
	end

	v6.StatPoints = statPoints
	local refundButton

	if not v2 then
		refundButton = createElement(Button, {
			AnchorPoint = Vector2.new(0, 0.5),
			Label = "Refund" .. (not (v3 and v3 > 0) and "" or ` ({v3} Stored)` or ""),
			LabelSize = UDim2.fromScale(0.95, 0.75),
			Position = UDim2.fromScale(0.793 - (v3 and v3 > 0 and 0.05 or 0), 0.5),
			Size = UDim2.fromScale(0.180104 + (v3 and v3 > 0 and 0.05 or 0), 0.7),
			Variant = "Yellow",
			[React.Event.Activated] = function()
				p.OnAction({
					Type = "Refund"
				})
			end
		})
	end

	v6.RefundButton = refundButton
	return createElement("Frame", mergeFrame, v6)
end