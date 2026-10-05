local React = require(game.ReplicatedStorage.Packages.React)
local FruitSkills = require(game.ReplicatedStorage.FruitSkills)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
require(game.ReplicatedStorage.React.Util)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local useViewportSize = require(game.ReplicatedStorage.React.Hooks.useViewportSize)
local useMoveList = require(game.ReplicatedStorage.React.Hooks.Item.useMoveList)
local lerped = CONSTANTS.COLOR.PANEL.BACKGROUND:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.5)
local SUBTLE = CONSTANTS.ALPHA.SUBTLE
local BLACK = CONSTANTS.COLOR.PALETTE.BLACK
local REGULAR = CONSTANTS.THICKNESS.OUTLINE.REGULAR
local OPAQUE = CONSTANTS.ALPHA.OPAQUE
local DISPLAY_LIGHT = CONSTANTS.FONT.FACE.DISPLAY_LIGHT
local WHITE = CONSTANTS.COLOR.PALETTE.WHITE
local BLACK2 = CONSTANTS.COLOR.PALETTE.BLACK
local uDim = UDim2.fromScale(0.255, 1.32)
local uDim2 = UDim2.fromScale(0.7225, 0.8075)
local v = {
	Image = "rbxassetid://113701888044237",
	ImageRectOffset = Vector2.zero,
	ImageRectSize = Vector2.zero
}

local function getDefaultPosition(point: Vector2, point2: Vector2)
	return UDim2.fromOffset(point.X + 12, point.Y + 12 + point2.Y * 0.15)
end

local function isSkillRow(list)
	return typeof(list) == "table" and typeof(list[2]) == "number" and typeof(list[3]) == "string"
end

local function appendSkillRows(list, list2)
	for _, v2 in ipairs(list2) do
		local v3

		if typeof(v2) == "table" and typeof(v2[2]) == "number" then
			v3 = typeof(v2[3]) == "string"
		else
			v3 = false
		end

		if v3 then
			table.insert(list, {
				level = v2[2],
				name = v2[3],
				order = #list + 1
			})
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sortSkillRows(list)
	table.sort(list, function(a, b)
		if a.level == b.level then
			return a.order < b.order
		end

		return a.level < b.level
	end)
	return list
end

local function getSkillRows(itemName: string)
	local fruitSkill = FruitSkills[itemName]

	if typeof(fruitSkill) ~= "table" then
		return {}
	end

	local v2 = {}
	local v3 = fruitSkill[1]
	local v4

	if typeof(v3) == "table" and typeof(v3[2]) == "number" then
		v4 = typeof(v3[3]) == "string"
	else
		v4 = false
	end

	if v4 then
		appendSkillRows(v2, fruitSkill)
	elseif typeof(fruitSkill[1]) == "table" then
		appendSkillRows(v2, fruitSkill[1])
	end

	return sortSkillRows(v2)
end

local function getMovesetSkillRows(list)
	if typeof(list) ~= "table" then
		return nil
	end

	local v2 = {}

	for _, v3 in ipairs(list) do
		if not (typeof(v3) == "table" and typeof(v3.Mastery) == "number" and typeof(v3.Name) == "string") then
			continue
		end

		table.insert(v2, {
			level = v3.Mastery,
			name = v3.Name,
			order = #v2 + 1
		})
	end

	if #v2 == 0 then
		return nil
	end

	return sortSkillRows(v2)
end

local function getItemName(props)
	if typeof(props.itemName) == "string" and props.itemName ~= "" then
		return props.itemName
	end

	if typeof(props.subtitle) == "string" and props.subtitle ~= "" then
		return props.subtitle
	end

	if typeof(props.dialogueSubtitle) == "string" and props.dialogueSubtitle ~= "" then
		return props.dialogueSubtitle
	end

	if typeof(props.title) == "string" and FruitSkills[props.title] then
		return props.title
	end

	if typeof(props.dialogueTitle) == "string" and FruitSkills[props.dialogueTitle] then
		return props.dialogueTitle
	end

	return nil
end

local function getItemConfig(itemName: string)
	for _, v2 in { "PhysicalMoveset", "Moveset", "Accessory" } do
		local nullable = ItemConfig.match(itemName, v2):asNullable()

		if nullable then
			return nullable
		end
	end

	return nil
end

local function TextStroke(p)
	return React.createElement("UIStroke", {
		Color = p.color,
		Thickness = p.thickness or 2
	})
end

local function SkillRow(props)
	local zIndex = props.zIndex
	return React.createElement("Frame", {
		BackgroundColor3 = lerped,
		BackgroundTransparency = SUBTLE,
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		Size = UDim2.fromScale(1, props.rowHeight),
		ZIndex = zIndex
	}, {
		uICorner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0.12, 0)
		}),
		uIStroke = React.createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = BLACK,
			Thickness = REGULAR,
			Transparency = OPAQUE
		}),
		name = React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			FontFace = DISPLAY_LIGHT,
			Position = UDim2.fromScale(0.035, 0.14),
			Size = UDim2.fromScale(0.66, 0.72),
			Text = props.skill.name,
			TextColor3 = WHITE,
			TextScaled = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = (zIndex or 1) + 1
		}, {
			textStroke = React.createElement(TextStroke, {
				color = BLACK2,
				thickness = 1.5
			})
		}),
		mastery = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.71, 0.1),
			Size = UDim2.fromScale(0.25, 0.8),
			ZIndex = (zIndex or 1) + 1
		}, {
			starIcon = React.createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				AutomaticSize = Enum.AutomaticSize.None,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = v.Image,
				ImageColor3 = WHITE,
				ImageRectOffset = v.ImageRectOffset,
				ImageRectSize = v.ImageRectSize,
				ImageTransparency = 0,
				Position = UDim2.fromScale(0, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = uDim2,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				ZIndex = (zIndex or 1) + 2
			}),
			label = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				FontFace = DISPLAY_LIGHT,
				Position = UDim2.fromScale(0.53, 0.53),
				Size = UDim2.fromScale(0.47, 0.72),
				Text = FormatUtil.commaInteger(props.skill.level),
				TextColor3 = WHITE,
				TextScaled = true,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = (zIndex or 1) + 2
			}, {
				textStroke = React.createElement(TextStroke, {
					color = BLACK2,
					thickness = 1.5
				})
			})
		})
	})
end

local function MoveList(p)
	local children = {
		uIListLayout = React.createElement("UIListLayout", {
			Padding = UDim.new(0.045, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top
		}),
		uIPadding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0.025, 0),
			PaddingRight = UDim.new(0.025, 0)
		})
	}
	local v2 = math.max(#p.skills, 1)
	local rowHeight = math.clamp((1 - math.max(v2 - 1, 0) * 0.045) / v2, 0.14, 0.22)

	for i, skill in ipairs(p.skills) do
		children[`move{i}`] = React.createElement(SkillRow, {
			skill = skill,
			layoutOrder = i,
			rowHeight = rowHeight,
			zIndex = p.zIndex
		})
	end

	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = p.zIndex
	}, children)
end

local function ItemPurchaseSkillPreview(props)
	local v2 = useViewportSize()
	local ref = React.useRef(nil)
	local state, setState = React.useState(getDefaultPosition(Vector2.zero, v2))
	React.useEffect(function()
		if props.position ~= nil then
			return
		end

		local current = ref.current
		local parent = current and current.Parent

		if not (parent and parent:IsA("GuiObject")) then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			setState(getDefaultPosition(Vector2.new(-parent.AbsolutePosition.X, -parent.AbsolutePosition.Y), v2))
		end

		update() -- equivalent call inferred; original call site unknown
		local v3 = {
			parent:GetPropertyChangedSignal("AbsolutePosition"):Connect(update),
			parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		}
		return function()
			for _, connection in v3 do
				connection:Disconnect()
			end
		end
	end, { props.position ~= nil, v2 })
	local itemName = getItemName(props)
	local v3

	if itemName then
		v3 = getItemConfig(itemName)
	end

	local v5

	if v3 then
		v5 = v3.Index.ItemId
	end

	local v6 = useMoveList(v5)

	if props.optionsVisible == false or props.interactive == false or not itemName then
		return nil
	end

	local skills = getMovesetSkillRows(v6) or getSkillRows(itemName)

	if #skills == 0 then
		return nil
	end

	local zIndex = props.zIndex or 3
	return React.createElement("Frame", {
		ref = ref,
		AnchorPoint = props.anchorPoint or Vector2.zero,
		AutoLocalize = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		Position = props.position or state,
		Size = props.size or uDim,
		Visible = props.visible ~= false,
		ZIndex = zIndex
	}, {
		moveList = React.createElement(MoveList, {
			skills = skills,
			zIndex = zIndex
		})
	})
end

return ItemPurchaseSkillPreview