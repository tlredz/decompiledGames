local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.usePuzzle)
require(game.ReplicatedStorage.React.Components.WorldTeleporter.Types)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local PALETTE = CONSTANTS.COLOR.PALETTE
local hex = PALETTE.BLUE_400:ToHex()
local hex2 = PALETTE.GREY_450:ToHex()
local hex3 = PALETTE.GOLD_500:ToHex()
local hex4 = PALETTE.WHITE:ToHex()
local createElement = React.createElement

-- equivalent calls inferred from this helper; original call sites unknown
local function getName(p)
	return p.Display.Name or p.Index.Key
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getStatusLine(data)
	local puzzle = data.Puzzle

	if data.IsGolden then
		return "SOLVED - GOLDEN"
	end

	if data.IsEveryIslandUnlocked then
		return (`STEP {#puzzle.Chain}/{#puzzle.Order} - ORBITING {#puzzle.Orbit}/{data.TotalCount}`)
	end

	return "DISABLED - UNLOCK EVERY ISLAND"
end

local function getOrderLines(puzzle, isGolden: boolean)
	local result = {}
	local v

	if isGolden then
		v = #puzzle.Order
	else
		v = #puzzle.Chain
	end

	local v2 = not puzzle.IsActive and 0 or v + 1

	for k, v3 in puzzle.Order do
		local v4 = puzzle.Chain[k]
		local names = {}

		if v4 then
			table.insert(names, getName(v4))
		else
			for _, v5 in v3 do
				table.insert(names, getName(v5))
			end
		end

		local v5 = k <= v and "[x]" or k == v2 and "[>]" or "[ ]"
		local v6

		if k <= v then
			v6 = hex2
		elseif k == v2 then
			v6 = hex3
		else
			v6 = hex4
		end

		table.insert(result, (`<font color="#{v6}">{v5} {k}. {table.concat(names, " / ")}</font>`))
	end

	return result
end

return function(data)
	local orderLines = getOrderLines(data.Puzzle, data.IsGolden)
	table.insert(orderLines, 1, (("<font color=\"#%*\"><b>%*</b></font>"):format(hex, getStatusLine(data))))
	return createElement("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.LIGHT,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromOffset(0, 0),
		FontFace = CONSTANTS.FONT.FACE.BODY,
		RichText = true,
		Text = table.concat(orderLines, "\n"),
		TextColor3 = PALETTE.WHITE,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = CONSTANTS.LAYER.OVERLAY
	}, {
		UIPadding = createElement("UIPadding", {
			PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.MD,
			PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.MD,
			PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.MD,
			PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.MD
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.PADDING.OFFSET.MD
		})
	})
end