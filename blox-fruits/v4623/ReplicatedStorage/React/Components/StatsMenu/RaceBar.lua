local React = require(game.ReplicatedStorage.Packages.React)
local Button = require(script.Parent.Button)
local useRace = require(game.ReplicatedStorage.React.Hooks.Player.useRace)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useIsDungeon = require(game.ReplicatedStorage.React.Hooks.useIsDungeon)
require(game.ReplicatedStorage.React.Components.StatsMenu.Types)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local v = useRace()
	local v3

	if v then
		v3 = v.ItemId or nil
	end

	local v4 = useMatch(v3)
	local text

	if v4 and v and v.Level then
		text = `Race: {v4.Display.Name or v4.Index.StorageKey} V{v.Level}`
	else
		text = not v4 and "Race: " or `Race: {v4.Display.Name or v4.Index.StorageKey}`
	end

	local v6 = useIsDungeon()
	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, p)
	local v9 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = CONSTANTS.SPACING.PADDING.SCALE.MD,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		Race = createElement("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC),
			LayoutOrder = 1,
			Position = UDim2.fromScale(0.0175929, 0.025),
			Size = UDim2.fromScale(0, 1),
			Text = text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		RerollButton = 0
	}
	local rerollButton

	if not v6 then
		rerollButton = createElement(Button, {
			AnchorPoint = Vector2.new(0, 0.5),
			Icon = "rbxassetid://138787594167133",
			IconScaleType = Enum.ScaleType.Fit,
			LayoutOrder = 2,
			Position = UDim2.fromScale(0.534305, 0.5),
			Size = UDim2.fromScale(0.11, 1.15),
			Variant = "Yellow",
			[React.Event.Activated] = p.OnClick
		})
	end

	v9.RerollButton = rerollButton
	return createElement("Frame", mergeFrame, v9)
end