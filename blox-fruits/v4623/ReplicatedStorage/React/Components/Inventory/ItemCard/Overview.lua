local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useTemporaryDescription = require(game.ReplicatedStorage.React.Hooks.Inventory.useTemporaryDescription)
local useSelection = require(game.ReplicatedStorage.React.Hooks.Item.useSelection)
local useDynamicDescription = require(game.ReplicatedStorage.React.Hooks.Item.useDynamicDescription)
local useModifiers = require(game.ReplicatedStorage.React.Hooks.Item.Fish.useModifiers)
local useWeight = require(game.ReplicatedStorage.React.Hooks.Item.Fish.useWeight)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local v, v2, _ = useSelection()
	local v3 = useMatch(v)
	local v4 = RarityUtil.tryGetRarity(not v3 and "Common" or v3.Quality.Rarity or "Common")
	local color

	if v4 then
		color = v4.Color
	else
		color = CONSTANTS.COLOR.PALETTE.WHITE
	end

	local description

	if v3 then
		description = v3.Display.Description
	end

	local modifiers = useModifiers(v, v2)
	local weight = useWeight(v, v2)
	local v7, _ = useTemporaryDescription()
	local v8 = useDynamicDescription(v, v3 and v3.Index.IdType == "Fish" and {
		Type = "Fish",
		Modifiers = modifiers,
		Weight = weight
	} or v3 and v3.Index.IdType == "Redeemable" and v3.Index.StorageKey:find("Dragon Token") and {
		Type = "DragonToken"
	} or nil) or description

	if v7 then
		if v8 then
			v8 ..= "\n" .. v7
		else
			v8 = v7
		end
	end

	local text = React.useMemo(function()
		if v7 then
			return v7
		end

		if not v8 then
			return nil
		end

		v8 = v8:gsub("<", FormatUtil.ESCAPE_FORMS["<"])
		v8 = v8:gsub(">", FormatUtil.ESCAPE_FORMS[">"])
		return FormatUtil.italic(v8)
	end, { v8, v7 })
	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, p)
	local v12 = {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, 1)
		}),
		Rarity = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY_LIGHT,
			LineHeight = 0,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 0.15),
			Text = v3 and v3.Quality.Rarity or "",
			TextColor3 = color,
			TextScaled = true,
			TextTruncate = Enum.TextTruncate.AtEnd
		}),
		Description = 0
	}
	local description2

	if text then
		local v16 = {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = 0,
			Position = 0,
			RichText = true,
			Size = 0,
			Text = 0,
			TextColor3 = 0,
			TextScaled = true,
			TextTransparency = 0.2,
			TextYAlignment = 0
		}
		local fontFace

		if v7 then
			fontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		else
			fontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO, Enum.FontWeight.Regular, Enum.FontStyle.Italic)
		end

		v16.FontFace = fontFace
		v16.Position = UDim2.fromScale(0.5, 1)
		v16.Size = UDim2.fromScale(1, 0.85)
		v16.Text = text
		v16.TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE
		v16.TextYAlignment = Enum.TextYAlignment.Top
		description2 = createElement("TextLabel", v16, {
			UISizeConstraint = createElement("UISizeConstraint", {
				MinSize = Vector2.new(0, 50)
			})
		})
	end

	v12.Description = description2
	return createElement("Frame", mergeFrame, v12)
end