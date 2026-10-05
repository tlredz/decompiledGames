local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local Formatter = require(script.Parent.Formatter)
local InputUtils = require(script.Parent.InputUtils)
local LayoutMetrics = require(script.Parent.LayoutMetrics)
local LogText = require(script.Parent.LogText)
local Motion = require(script.Parent.Motion)
local Popout = require(script.Parent.Popout)
local RichText = require(script.Parent.RichText)
local TextMetrics = require(script.Parent.TextMetrics)
local Theme = require(script.Parent.Theme)
local createElement = React.createElement
local Controls = {}
local v = {
	Punctuation = Theme.TextSubtle,
	Key = Theme.TextMuted,
	Table = Theme.Accent,
	String = Color3.fromRGB(230, 168, 108),
	Number = Color3.fromRGB(96, 165, 250),
	Boolean = Color3.fromRGB(196, 181, 253),
	Nil = Color3.fromRGB(248, 113, 113),
	Function = Color3.fromRGB(244, 114, 182),
	Thread = Color3.fromRGB(148, 163, 184),
	Instance = Color3.fromRGB(125, 211, 252),
	Userdata = Color3.fromRGB(203, 213, 225),
	Cycle = Color3.fromRGB(251, 191, 36)
}
local v2 = {
	["</font>"] = true,
	["</text>"] = true,
	["</br>"] = true,
	["</tree>"] = true,
	["</div>"] = true,
	["</cdiv>"] = true,
	["</center>"] = true,
	["</sizegroup>"] = true,
	["</agrid>"] = true,
	["</alist>"] = true,
	["</bubble>"] = true,
	["</btn>"] = true,
	["</chk>"] = true,
	["</cmbo>"] = true,
	["</combochild>"] = true,
	["</srvst>"] = true,
	["</stay>"] = true,
	["</tip>"] = true,
	["</robj>"] = true,
	["</ilog>"] = true
}

local function activate(part, context, ...)
	local onControl = context.OnControl

	if onControl then
		onControl(part, ...)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function plainControlText(p, context, p2: string)
	local v3 = Formatter.toText(p, context) or p2
	return TextMetrics.stripRichText(v3)
end

local function measureControlTextWidth(p: string, p2)
	return (math.ceil(TextMetrics.measurePlain(p, Theme.ControlTextSize, p2).X))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wrapControlWidth(p: string, fontBold, p2: number)
	local v3 = math.ceil(TextMetrics.measurePlain(p, Theme.ControlTextSize, fontBold).X) + p2
	return (math.max(Theme.ControlHeight, (math.min(v3, Theme.ControlWrapMaxWidth))))
end

local function shouldWrapControlText(p: string, p2, p3: number)
	return p3 > 0 and p3 < math.ceil(TextMetrics.measurePlain(p, Theme.ControlTextSize, p2).X)
end

local function wrappedControlHeight(p: string, p2, p3: number)
	return LayoutMetrics.controlTextHeight(p, p2, (math.max(1, p3)))
end

local function clampScale(value: number?, p: number)
	if typeof(value) == "number" then
		return (math.clamp(value, 0.05, 1))
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fixedControlWidth(sizePx: number?)
	if typeof(sizePx) == "number" and not (sizePx <= 0) then
		return (math.floor(sizePx + 0.5))
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isLogValueTable(list)
	return typeof(list) == "table" and v2[list[3]] == true
end

local function isInspectableTable(list)
	return typeof(list) == "table" and not isLogValueTable(list)
end

local function tableEntryCount(items)
	local count = 0

	for _ in items do
		count += 1
	end

	return count
end

local function tableSummary(items)
	local count = 0

	for _ in items do
		count += 1
	end

	return (`Table ({count})`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tableReferenceLabel(p: string)
	local stripRichText = TextMetrics.stripRichText(p)

	if string.match(stripRichText, "^<Table>%s*%(%s*table:%s*0x%x+%s*%)$") or string.match(
		stripRichText,
		"^table:%s*0x%x+$"
	) then
		return "<Table>"
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formattedLogValueText(list, p)
	return TextMetrics.stripRichText(Formatter.toText(list, p) or "")
end

local function keyText(list, p)
	local typeName = typeof(list)
	local v3

	if typeof(list) == "table" then
		v3 = v2[list[3]] == true
	else
		v3 = false
	end

	if v3 then
		local v4 = formattedLogValueText(list, p) -- equivalent call inferred; original call site unknown
		return tableReferenceLabel(v4) or v4
	elseif typeName == "table" then
		local count = 0

		for _ in list do
			count += 1
		end

		return (`Table ({count})`)
	else
		if typeName == "string" then
			return tableReferenceLabel(list) or list
		elseif typeName == "number" then
			return (tostring(list))
		end

		if typeName == "boolean" then
		end

		return (tostring(list))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function colorText(p: string, color: Color3)
	return (`<font color="rgb({math.floor(color.R * 255 + 0.5)},{math.floor(color.G * 255 + 0.5)},{math.floor(color.B * 255 + 0.5)})">{RichText.escapeLiteral(p)}</font>`)
end

local function quotedString(p: string)
	local success, result = pcall(function()
		return string.format("%q", p)
	end)

	if success and typeof(result) == "string" then
		return result
	end

	return (`"{p}"`)
end

local function prettyKeyText(key, p)
	local typeName = typeof(key)

	if typeName == "string" then
		local v3 = tableReferenceLabel(key) -- equivalent call inferred; original call site unknown

		if v3 then
			return v3
		end

		local success, result = pcall(function()
			return string.format("%q", key)
		end)

		if success and typeof(result) == "string" then
			return result
		end

		return (`"{key}"`)
	else
		local v3

		if typeof(key) == "table" then
			v3 = v2[key[3]] == true
		else
			v3 = false
		end

		if v3 then
			local v4 = formattedLogValueText(key, p) -- equivalent call inferred; original call site unknown
			local v5 = tableReferenceLabel(v4) -- equivalent call inferred; original call site unknown

			if v5 then
				return v5
			end

			local success, result = pcall(function()
				return string.format("%q", v4)
			end)

			if success and typeof(result) == "string" then
				return result
			end

			return (`"{v4}"`)
		else
			if typeName ~= "table" then
				return (keyText(key, p))
			end

			local count = 0

			for _ in key do
				count += 1
			end

			return (`Table ({count})`)
		end
	end
end

local function primitivePrettyText(list, p)
	local typeName = typeof(list)

	if typeName == "string" then
		local success, result = pcall(function()
			return string.format("%q", list)
		end)

		if not success or typeof(result) ~= "string" then
			result = `"{list}"`
		end

		return result, v.String
	else
		if typeName == "number" then
			return tostring(list), v.Number
		elseif typeName == "boolean" then
			return tostring(list), v.Boolean
		elseif typeName == "nil" then
			return "nil", v.Nil
		elseif typeName == "function" then
			return "function", v.Function
		elseif typeName == "thread" then
			return "thread", v.Thread
		elseif typeName == "Instance" then
			return tostring(list), v.Instance
		end

		local v3

		if typeof(list) == "table" then
			v3 = v2[list[3]] == true
		else
			v3 = false
		end

		if v3 then
			local v4 = formattedLogValueText(list, p) -- equivalent call inferred; original call site unknown
			local success, result = pcall(function()
				return string.format("%q", v4)
			end)

			if not success or typeof(result) ~= "string" then
				result = `"{v4}"`
			end

			return result, v.String
		else
			if typeName ~= "table" then
				return tostring(list), v.Userdata
			end

			local count = 0

			for _ in list do
				count += 1
			end

			return `Table ({count})`, v.Table
		end
	end
end

local function primitiveValueText(value, context)
	local typeName = typeof(value)

	if typeName == "nil" then
		return "nil"
	elseif typeName == "function" then
		return "function"
	elseif typeName == "thread" then
		return "thread"
	end

	local v3

	if typeof(value) == "table" then
		v3 = v2[value[3]] == true
	else
		v3 = false
	end

	if v3 then
		return Formatter.toText(value, context) or ""
	end

	if typeName ~= "table" then
		return Formatter.toText(value, context) or tostring(value)
	end

	local count = 0

	for _ in value do
		count += 1
	end

	return (`Table ({count})`)
end

local function valueSortInfo(list)
	local v3

	if typeof(list) == "table" then
		v3 = not isLogValueTable(list)
	else
		v3 = false
	end

	if v3 then
		return 1, "table"
	end

	local v4

	if typeof(list) == "table" then
		v4 = v2[list[3]] == true
	else
		v4 = false
	end

	if v4 then
		return 2, "string"
	end

	local typeName = typeof(list)

	if typeName == "string" then
		return 2, "string"
	elseif typeName == "number" then
		return 3, "number"
	elseif typeName == "boolean" then
		return 4, "boolean"
	elseif typeName == "nil" then
		return 5, "nil"
	elseif typeName == "function" then
		return 6, "function"
	elseif typeName == "thread" then
		return 7, "thread"
	elseif typeName == "Instance" then
		return 8, "Instance"
	end

	return 9, typeName
end

local function tableKeyRank(p)
	local typeName = typeof(p)

	if typeName == "number" then
		return 1
	end

	if typeName == "string" and tableReferenceLabel(p) == nil then
		return 2
	end

	if typeName == "boolean" then
		return 3
	end

	return 4
end

local function tableEntries(items, p)
	local result = {}

	for k, item in items do
		local v3

		if typeof(item) == "table" then
			v3 = not isLogValueTable(item)
		else
			v3 = false
		end

		local valueSortRank, typeName

		if v3 then
			valueSortRank = 1
			typeName = "table"
		else
			local v5

			if typeof(item) == "table" then
				v5 = v2[item[3]] == true
			else
				v5 = false
			end

			if v5 then
				valueSortRank = 2
				typeName = "string"
			else
				typeName = typeof(item)

				if typeName == "string" then
					valueSortRank = 2
				elseif typeName == "number" then
					valueSortRank = 3
				elseif typeName == "boolean" then
					valueSortRank = 4
				elseif typeName == "nil" then
					valueSortRank = 5
				elseif typeName == "function" then
					valueSortRank = 6
				elseif typeName == "thread" then
					valueSortRank = 7
				elseif typeName == "Instance" then
					valueSortRank = 8
				else
					valueSortRank = 9
				end
			end
		end

		local typeName2 = typeof(k)
		local sortRank

		if typeName2 == "number" then
			sortRank = 1
		elseif typeName2 == "string" then
			if tableReferenceLabel(k) == nil then
				sortRank = 2
			else
				sortRank = "string" == "boolean" and 3 or 4
			end
		else
			sortRank = typeName2 == "boolean" and 3 or 4
		end

		local v5 = {
			Key = k,
			Value = item,
			ValueSortRank = valueSortRank,
			ValueSortText = typeName,
			SortRank = sortRank,
			SortText = string.lower((keyText(k, p)))
		}
		table.insert(result, v5)
	end

	table.sort(result, function(a, b)
		if a.ValueSortRank ~= b.ValueSortRank then
			return a.ValueSortRank < b.ValueSortRank
		end

		if a.ValueSortText ~= b.ValueSortText then
			return a.ValueSortText < b.ValueSortText
		end

		if a.SortRank ~= b.SortRank then
			return a.SortRank < b.SortRank
		end

		if typeof(a.Key) == "number" and typeof(b.Key) == "number" then
			return a.Key < b.Key
		end

		if a.SortText == b.SortText then
			return keyText(a.Key, p) < keyText(b.Key, p)
		end

		return a.SortText < b.SortText
	end)
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isAncestorTable(items, p)
	for _, item in items do
		if item == p then
			return true
		end
	end

	return false
end

local function tablePrettyText(value, context)
	local v3 = {}
	local v4 = {}
	local count = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function push(p: string, p2: string)
		table.insert(v3, p)
		table.insert(v4, p2)
		count += 1
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function indent(count2: number)
		return string.rep("  ", count2)
	end

	local function coloredPrimitive(p)
		local v5, v6 = primitivePrettyText(p, context)
		return
			`<font color="rgb({math.floor(v6.R * 255 + 0.5)},{math.floor(v6.G * 255 + 0.5)},{math.floor(v6.B * 255 + 0.5)})">{RichText.escapeLiteral(v5)}</font>`,
			v5
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function coloredSuffix(value2: string?)
		if not value2 then
			return ""
		end

		local punctuation = v.Punctuation
		return (`<font color="rgb({math.floor(punctuation.R * 255 + 0.5)},{math.floor(punctuation.G * 255 + 0.5)},{math.floor(punctuation.B * 255 + 0.5)})">{RichText.escapeLiteral(value2)}</font>`)
	end

	local formatTable

	formatTable = function(p, count2: number, items, p2: string, p3: string, value2: string?)
		-- equivalent call inferred; original call site unknown
		if isAncestorTable(items, p) then
			local v5 = colorText("<cycle>", v.Cycle) -- equivalent call inferred; original call site unknown
			local v6 = coloredSuffix(value2) -- equivalent call inferred; original call site unknown
			push(p2 .. v5 .. v6, p3 .. "<cycle>" .. (value2 or "")) -- equivalent call inferred; original call site unknown
		elseif count2 >= 24 then
			local v5 = colorText("<max depth>", v.Cycle) -- equivalent call inferred; original call site unknown
			local v6 = coloredSuffix(value2) -- equivalent call inferred; original call site unknown
			push(p2 .. v5 .. v6, p3 .. "<max depth>" .. (value2 or "")) -- equivalent call inferred; original call site unknown
		else
			local v5 = tableEntries(p, context)

			if #v5 == 0 then
				local v6 = colorText("{}", v.Punctuation) -- equivalent call inferred; original call site unknown
				local v7 = coloredSuffix(value2) -- equivalent call inferred; original call site unknown
				push(p2 .. v6 .. v7, p3 .. "{}" .. (value2 or "")) -- equivalent call inferred; original call site unknown
			else
				local punctuation = v.Punctuation
				push(
					p2 .. `<font color="rgb({math.floor(punctuation.R * 255 + 0.5)},{math.floor(punctuation.G * 255 + 0.5)},{math.floor(punctuation.B * 255 + 0.5)})">{RichText.escapeLiteral("{")}</font>`,
					p3 .. "{"
				) -- equivalent call inferred; original call site unknown
				local clone = table.clone(items)
				table.insert(clone, p)

				for _, v8 in v5 do
					local v9 = prettyKeyText(v8.Key, context)
					local v10 = colorText("[", v.Punctuation) -- equivalent call inferred; original call site unknown
					local v11 = colorText(v9, v.Key) -- equivalent call inferred; original call site unknown
					local punctuation3 = v.Punctuation
					local v12 = v10 .. v11 .. `<font color="rgb({math.floor(punctuation3.R * 255 + 0.5)},{math.floor(punctuation3.G * 255 + 0.5)},{math.floor(punctuation3.B * 255 + 0.5)})">{RichText.escapeLiteral("] = ")}</font>`
					local formatted = `[{v9}] = `
					local v13 = count2 + 1
					local v14 = string.rep("  ", v13) .. v12
					local v15 = count2 + 1
					local v16 = string.rep("  ", v15) .. formatted
					local value3 = v8.Value
					local v17

					if typeof(value3) == "table" then
						v17 = not isLogValueTable(value3)
					else
						v17 = false
					end

					if v17 then
						formatTable(v8.Value, count2 + 1, clone, v14, v16, ",")
					else
						local v18, v19 = primitivePrettyText(v8.Value, context)
						local v20 = colorText(v18, v19) -- equivalent call inferred; original call site unknown
						local punctuation4 = v.Punctuation
						push(
							v14 .. v20 .. `<font color="rgb({math.floor(punctuation4.R * 255 + 0.5)},{math.floor(punctuation4.G * 255 + 0.5)},{math.floor(punctuation4.B * 255 + 0.5)})">{RichText.escapeLiteral(",")}</font>`,
							v16 .. v18 .. ","
						) -- equivalent call inferred; original call site unknown
					end
				end

				local v8 = indent(count2) -- equivalent call inferred; original call site unknown
				local v9 = "}" .. (value2 or "")
				local punctuation2 = v.Punctuation
				push(
					v8 .. `<font color="rgb({math.floor(punctuation2.R * 255 + 0.5)},{math.floor(punctuation2.G * 255 + 0.5)},{math.floor(punctuation2.B * 255 + 0.5)})">{RichText.escapeLiteral(v9)}</font>`,
					string.rep("  ", count2) .. "}" .. (value2 or "")
				) -- equivalent call inferred; original call site unknown
			end
		end
	end

	formatTable(value, 0, {}, "", "", nil)
	return table.concat(v3, "\n"), table.concat(v4, "\n"), count
end

function Controls.DropdownOption(props)
	local state, setState = React.useState(false)
	local selected = props.Selected == true
	local hidden = props.Hidden == true
	local buttonHover

	if state then
		buttonHover = Theme.ButtonHover
	elseif selected then
		buttonHover = Theme.ButtonSelected
	else
		buttonHover = Theme.PanelDark
	end

	local textHidden

	if hidden and not (state or selected) then
		textHidden = Theme.TextHidden
	elseif hidden then
		textHidden = Theme.TextSubtle
	elseif state or selected then
		textHidden = Theme.Text
	else
		textHidden = Theme.TextMuted
	end

	return createElement("TextButton", {
		AutomaticSize = Enum.AutomaticSize.Y,
		AutoButtonColor = false,
		BackgroundColor3 = buttonHover,
		BorderSizePixel = 0,
		Font = props.Font or Theme.Font,
		LayoutOrder = props.LayoutOrder,
		RichText = props.RichText == true,
		Selectable = false,
		Size = UDim2.new(1, 0, 0, props.RowHeight or Theme.DropdownRowHeight),
		Text = props.Label,
		TextColor3 = textHidden,
		TextSize = Theme.ControlTextSize,
		TextStrokeTransparency = 1,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = props.ZIndex,
		[React.Event.Activated] = props.OnActivated,
		[React.Event.MouseEnter] = function()
			setState(true)
		end,
		[React.Event.MouseLeave] = function()
			setState(false)
		end
	}, {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerSmall)
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 1)
		})
	})
end

function Controls.ActionButton(props)
	local ref = React.useRef(nil)
	local danger = props.Danger == true
	local disabled = props.Disabled == true
	local selected = props.Selected == true
	local heightPx = props.HeightPx or Theme.ControlHeight
	local panel

	if disabled then
		panel = Theme.Panel
	elseif selected then
		panel = Theme.ButtonSelected
	elseif danger then
		panel = Theme.Danger
	else
		panel = Theme.Button
	end

	local dangerHover

	if danger then
		dangerHover = Theme.DangerHover
	else
		dangerHover = Theme.ButtonHover
	end

	local dangerHover2

	if danger then
		dangerHover2 = Theme.DangerHover
	else
		dangerHover2 = Theme.ButtonSelected
	end

	local v5 = {
		ref = ref,
		AutomaticSize = props.AutomaticSize or Enum.AutomaticSize.None,
		AutoButtonColor = false,
		BackgroundColor3 = panel,
		BackgroundTransparency = disabled and 0.5 or Theme.ControlTransparency,
		BorderSizePixel = 0,
		Font = Theme.FontBold,
		LayoutOrder = props.LayoutOrder,
		RichText = false,
		Selectable = false,
		Size = props.Size or UDim2.fromOffset(props.WidthPx or 0, heightPx),
		Text = props.Text
	}
	local textSubtle

	if disabled then
		textSubtle = Theme.TextSubtle
	elseif danger then
		textSubtle = Theme.DangerText
	else
		textSubtle = Theme.Text
	end

	v5.TextColor3 = textSubtle
	v5.TextSize = Theme.ControlTextSize
	v5.TextStrokeTransparency = 1
	v5.TextXAlignment = Enum.TextXAlignment.Center
	v5.TextYAlignment = Enum.TextYAlignment.Center
	v5.ZIndex = props.ZIndex
	local activated = React.Event.Activated
	local v6

	if not disabled then
		v6 = props.OnActivated
	end

	v5[activated] = v6

	v5[React.Event.MouseEnter] = function()
		if not disabled then
			Motion.to(ref.current, Motion.Hover, {
				BackgroundColor3 = dangerHover
			})
		end
	end

	v5[React.Event.MouseLeave] = function()
		if not disabled then
			Motion.to(ref.current, Motion.Hover, {
				BackgroundColor3 = panel
			})
		end
	end

	v5[React.Event.MouseButton1Down] = function()
		if not disabled then
			Motion.to(ref.current, Motion.Press, {
				BackgroundColor3 = dangerHover2
			})
		end
	end

	v5[React.Event.MouseButton1Up] = function()
		if not disabled then
			Motion.to(ref.current, Motion.Release, {
				BackgroundColor3 = dangerHover
			})
		end
	end

	return createElement("TextButton", v5, {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, props.CornerRadius or Theme.CornerControl)
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 1)
		})
	})
end

function Controls.SettingsRow(props)
	local zIndex = props.ZIndex or 181
	local rightWidthPx = props.RightWidthPx or 0
	local disabled = props.Disabled == true
	local v5 = {
		BackgroundColor3 = Theme.PanelDark,
		BackgroundTransparency = disabled and 0.45 or 0,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, Theme.SettingsPopoutRowHeight),
		ZIndex = zIndex
	}
	local v6 = {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerSmall)
		}),
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 7),
			PaddingTop = UDim.new(0, 1)
		}),
		Label = 0,
		Right = 0
	}
	local v9 = {
		BackgroundTransparency = 1,
		Font = Theme.FontBold,
		LayoutOrder = 1,
		RichText = false,
		Size = UDim2.new(1, -(rightWidthPx + 8), 1, 0),
		Text = props.Label,
		TextColor3 = 0,
		TextSize = 0,
		TextStrokeTransparency = 1,
		TextTruncate = 0,
		TextXAlignment = 0,
		TextYAlignment = 0,
		ZIndex = 0
	}
	local textColor

	if disabled then
		textColor = Theme.TextSubtle
	else
		textColor = Theme.Text
	end

	v9.TextColor3 = textColor
	v9.TextSize = Theme.ControlTextSize
	v9.TextTruncate = Enum.TextTruncate.AtEnd
	v9.TextXAlignment = Enum.TextXAlignment.Left
	v9.TextYAlignment = Enum.TextYAlignment.Center
	v9.ZIndex = zIndex + 1
	v6.Label = createElement("TextLabel", v9)
	v6.Right = createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Size = UDim2.fromOffset(rightWidthPx, Theme.SettingsPopoutRowHeight),
		ZIndex = zIndex + 1
	}, props.children)
	return createElement("Frame", v5, v6)
end

function Controls.CheckRow(props)
	local ref = React.useRef(nil)
	local selected = props.Selected == true
	local disabled = props.Disabled == true
	local zIndex = props.ZIndex or 181
	local buttonSelected

	if selected then
		buttonSelected = Theme.ButtonSelected
	else
		buttonSelected = Theme.PanelDark
	end

	local v5 = {
		ref = ref,
		AutoButtonColor = false,
		BackgroundColor3 = buttonSelected,
		BackgroundTransparency = disabled and 0.45 or 0,
		BorderSizePixel = 0,
		Font = Theme.FontBold,
		LayoutOrder = props.LayoutOrder,
		RichText = false,
		Selectable = false,
		Size = UDim2.new(1, 0, 0, Theme.SettingsPopoutRowHeight),
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = Theme.ControlTextSize,
		TextStrokeTransparency = 1,
		ZIndex = zIndex
	}
	local activated = React.Event.Activated
	local v6

	if not disabled then
		v6 = props.OnActivated
	end

	v5[activated] = v6

	v5[React.Event.MouseEnter] = function()
		if not disabled then
			Motion.to(ref.current, Motion.Hover, {
				BackgroundColor3 = Theme.ButtonHover
			})
		end
	end

	v5[React.Event.MouseLeave] = function()
		if not disabled then
			Motion.to(ref.current, Motion.Hover, {
				BackgroundColor3 = buttonSelected
			})
		end
	end

	local v7 = {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerSmall)
		}),
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 7),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 7),
			PaddingRight = UDim.new(0, 7),
			PaddingTop = UDim.new(0, 1)
		}),
		Box = 0,
		Label = 0
	}
	local v10 = {
		BackgroundColor3 = Theme.PanelDarker,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Size = UDim2.fromOffset(16, 16),
		ZIndex = zIndex + 1
	}
	local v11 = {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerSmall)
		}),
		Icon = 0
	}
	local icon

	if selected then
		icon = createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "rbxassetid://126491458606904",
			ImageColor3 = Theme.Success,
			Position = UDim2.fromOffset(1, 1),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.new(1, -2, 1, -2),
			ZIndex = zIndex + 2
		})
	end

	v11.Icon = icon
	v7.Box = createElement("Frame", v10, v11)
	local v15 = {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Font = Theme.FontBold,
		LayoutOrder = 2,
		RichText = false,
		Size = UDim2.fromOffset(0, 0),
		Text = props.Label,
		TextColor3 = 0,
		TextSize = 0,
		TextStrokeTransparency = 1,
		TextXAlignment = 0,
		TextYAlignment = 0,
		ZIndex = 0
	}
	local textColor

	if disabled then
		textColor = Theme.TextSubtle
	else
		textColor = Theme.Text
	end

	v15.TextColor3 = textColor
	v15.TextSize = Theme.ControlTextSize
	v15.TextXAlignment = Enum.TextXAlignment.Left
	v15.TextYAlignment = Enum.TextYAlignment.Center
	v15.ZIndex = zIndex + 1
	v7.Label = createElement("TextLabel", v15)
	return createElement("TextButton", v5, v7)
end

function Controls.TooltipPopout(props)
	local zIndex = props.ZIndex
	return createElement(Popout, {
		Open = props.Open,
		AnchorRef = props.AnchorRef,
		WidthPx = props.WidthPx,
		HeightPx = props.HeightPx,
		OffsetY = props.OffsetY,
		HorizontalAlign = props.HorizontalAlign,
		ZIndex = zIndex
	}, {
		Text = createElement("TextLabel", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Theme.Font,
			RichText = false,
			Size = UDim2.fromScale(1, 1),
			Text = props.Text,
			TextColor3 = Theme.Text,
			TextSize = Theme.SecondaryTextSize,
			TextStrokeTransparency = 1,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = zIndex + 1
		}, {
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 7),
				PaddingLeft = UDim.new(0, 9),
				PaddingRight = UDim.new(0, 9),
				PaddingTop = UDim.new(0, 7)
			})
		})
	})
end

function Controls.ColorSwatchButton(props)
	local disabled = props.Disabled == true
	local zIndex = props.ZIndex or 1
	local v5 = {
		ref = props.ButtonRef,
		AutoButtonColor = false,
		BackgroundColor3 = props.Color,
		BackgroundTransparency = disabled and 0.35 or 0,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Selectable = false,
		Size = UDim2.fromOffset(props.SizePx, props.SizePx),
		Text = "",
		ZIndex = zIndex
	}
	local activated = React.Event.Activated
	local v6

	if not disabled then
		v6 = props.OnActivated
	end

	v5[activated] = v6
	local v7 = {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerSmall)
		}),
		UIStroke = 0,
		DefaultSlash = 0
	}
	local color

	if props.Open or props.Selected then
		color = Theme.AccentBright
	else
		color = Theme.ButtonStroke
	end

	v7.UIStroke = createElement("UIStroke", {
		Color = color,
		Thickness = (props.Open or props.Selected or props.StrongStroke) and 2 or 1,
		Transparency = disabled and 0.4 or 0
	})
	local defaultSlash

	if props.Default then
		defaultSlash = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.PanelDarker,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = -45,
			Size = UDim2.new(1, 4, 0, 2),
			ZIndex = zIndex + 1
		})
	end

	v7.DefaultSlash = defaultSlash
	return createElement("TextButton", v5, v7)
end

function Controls.PopoutScroller(props)
	local zIndex = props.ZIndex
	local scrollerZIndex = props.ScrollerZIndex or zIndex + 1
	local headerHeightPx = props.HeaderHeightPx
	local v3 = {}

	if props.Padding then
		v3.UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, Theme.TreeResizeHandleSize + 4),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8)
		})
	end

	if typeof(props.children) == "table" then
		for k, v4 in props.children do
			v3[k] = v4
		end
	else
		v3.Content = props.children
	end

	return createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = zIndex
	}, {
		Header = props.Header,
		Scroller = createElement("ScrollingFrame", {
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			BottomImage = "",
			CanvasSize = UDim2.new(),
			MidImage = "",
			Position = UDim2.fromOffset(0, headerHeightPx),
			ScrollBarImageColor3 = Theme.ButtonStroke,
			ScrollBarImageTransparency = 0.15,
			ScrollBarThickness = 5,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Size = UDim2.new(1, 0, 1, -headerHeightPx),
			TopImage = "",
			ZIndex = scrollerZIndex
		}, v3)
	})
end

function Controls.useInlinePopoutState(callback, callback2)
	local state, setState = React.useState(false)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(false)
	local ref3 = React.useRef(false)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function close()
		if callback2 then
			callback2()
		end

		setState(false)
	end

	local function setOpen(flag: boolean)
		setState(flag)
	end

	local function activate2()
		if ref3.current and not state then
			return
		end

		local current = ref2.current
		ref2.current = false

		if state or current then
			ref3.current = true
			task.delay(0.15, function()
				ref3.current = false
			end)
			close() -- equivalent call inferred; original call site unknown
		elseif callback() then
			setState(true)
		end
	end

	local function headerInputBegan(_, p)
		if InputUtils.isPrimaryPointer(p) then
			ref2.current = state
		end
	end

	return {
		Opened = state,
		AnchorRef = ref,
		SetOpened = setOpen,
		Close = close,
		Activate = activate2,
		HeaderInputBegan = headerInputBegan
	}
end

function Controls.Chevron(props)
	local function bar(p: number, rotation: number)
		return createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = props.Color,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(p, 4),
			Rotation = rotation,
			Size = UDim2.fromOffset(7, 2),
			ZIndex = props.ZIndex
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(1, 0)
			})
		})
	end

	return createElement("Frame", {
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		Rotation = props.Rotation or 0,
		Size = UDim2.fromOffset(13, 8),
		ZIndex = props.ZIndex
	}, {
		Left = bar(4, 45),
		Right = bar(9, -45)
	})
end

local TableValueRow

TableValueRow = function(props)
	local state, setState = React.useState(false)
	local state2, setState2 = React.useState(false)
	local state3, setState3 = React.useState(false)
	local ref = React.useRef(nil)
	local value = props.Value
	local v3

	if typeof(value) == "table" then
		v3 = not isLogValueTable(value)
	else
		v3 = false
	end

	if v3 then
		local count = 0
		v3 = false

		for _ in value do
			count += 1
		end

		if count > 0 then
			if props.Depth < 8 then
				local flag = true
				local v4

				for _, ancestor in props.Ancestors do
					if ancestor ~= value then
						continue
					end

					v4 = true
					flag = false
					break
				end

				if flag then
					v4 = false
				end

				v3 = not v4
			else
				v3 = false
			end
		end
	end

	local v4

	if typeof(value) == "table" then
		v4 = not isLogValueTable(value)
	else
		v4 = false
	end

	if v4 then
		local flag = true

		for _, ancestor in props.Ancestors do
			if ancestor ~= value then
				continue
			end

			v4 = true
			flag = false
			break
		end

		if flag then
			v4 = false
		end
	end

	local sizePx = math.max(Theme.TableKeyMinWidth, props.KeyWidthPx - props.Depth * Theme.TableIndentWidth)
	local heightPx = Theme.TableRowHeight - 4
	local buttonHover

	if state2 then
		buttonHover = Theme.ButtonHover
	elseif props.LayoutOrder and props.LayoutOrder % 2 == 0 then
		buttonHover = Theme.Panel
	else
		buttonHover = Theme.PanelDark
	end

	local text = v4 and "<cycle>" or primitiveValueText(value, props.Context)
	local entryKey = props.EntryKey
	local v8

	if typeof(entryKey) == "table" then
		v8 = not isLogValueTable(entryKey)
	else
		v8 = false
	end

	local function toggleExpanded()
		setState(not state)
	end

	local function beginKeyResize(p)
		if not InputUtils.isPrimaryPointer(p) then
			return
		end

		local current = ref.current
		local X

		if current then
			X = current.AbsoluteSize.X
		else
			X = Theme.TablePopoutWidth
		end

		local tableKeyMinWidth = Theme.TableKeyMinWidth
		local v9 = math.max(tableKeyMinWidth, X - Theme.TableValueMinWidth)
		local v10 = InputUtils.x(p)
		local keyWidthPx = props.KeyWidthPx
		local inputEndedConnection = nil
		local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			if not InputUtils.isPointerMove(input) then
				return
			end

			local v11 = keyWidthPx + (InputUtils.x(input) - v10)
			props.OnKeyWidthChanged((math.clamp(v11, tableKeyMinWidth, v9)))
		end)
		inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= p.UserInputType then
				return
			end

			if inputChangedConnection then
				inputChangedConnection:Disconnect()
			end

			if inputEndedConnection then
				inputEndedConnection:Disconnect()
			end
		end)
	end

	local v9 = {
		ref = ref,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = buttonHover,
		BackgroundTransparency = state2 and 0 or 0.22,
		BorderSizePixel = 0,
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, Theme.TableRowHeight),
		ZIndex = 171,
		[React.Event.MouseEnter] = function()
			setState2(true)
		end,
		[React.Event.MouseLeave] = function()
			setState2(false)
		end
	}
	local toggleExpandedsByActivated = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Size = UDim2.fromOffset(12, heightPx),
		ZIndex = 172
	}

	if v3 then
		toggleExpandedsByActivated.AutoButtonColor = false
		toggleExpandedsByActivated.Selectable = false
		toggleExpandedsByActivated.Text = ""
		toggleExpandedsByActivated[React.Event.Activated] = toggleExpanded
	end

	local font

	if v3 then
		font = Theme.FontBold
	else
		font = Theme.Font
	end

	local toggleExpandedsByActivated2 = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = font,
		LayoutOrder = 4,
		RichText = true,
		Size = UDim2.new(1, -(sizePx + Theme.TableKeyDividerWidth + 30), 0, heightPx),
		Text = text,
		TextColor3 = 0,
		TextSize = 0,
		TextStrokeTransparency = 1,
		TextTruncate = 0,
		TextXAlignment = 0,
		TextYAlignment = 0,
		ZIndex = 172
	}
	local textColor

	if v3 then
		textColor = Theme.Accent
	else
		textColor = Theme.Text
	end

	toggleExpandedsByActivated2.TextColor3 = textColor
	toggleExpandedsByActivated2.TextSize = Theme.SecondaryTextSize
	toggleExpandedsByActivated2.TextTruncate = Enum.TextTruncate.AtEnd
	toggleExpandedsByActivated2.TextXAlignment = Enum.TextXAlignment.Left
	toggleExpandedsByActivated2.TextYAlignment = Enum.TextYAlignment.Center

	if v3 then
		toggleExpandedsByActivated2.AutoButtonColor = false
		toggleExpandedsByActivated2.Selectable = false
		toggleExpandedsByActivated2[React.Event.Activated] = toggleExpanded
	end

	local v14 = v3 and not v8 and "TextButton" or "TextLabel"
	local toggleExpandedsByActivated3 = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Theme.FontBold,
		LayoutOrder = 2,
		RichText = false,
		Size = UDim2.fromOffset(sizePx, heightPx),
		Text = keyText(props.EntryKey, props.Context),
		TextColor3 = 0,
		TextSize = 0,
		TextStrokeTransparency = 1,
		TextTruncate = 0,
		TextXAlignment = 0,
		TextYAlignment = 0,
		ZIndex = 172
	}
	local textColor2

	if state2 then
		textColor2 = Theme.Text
	else
		textColor2 = Theme.TextMuted
	end

	toggleExpandedsByActivated3.TextColor3 = textColor2
	toggleExpandedsByActivated3.TextSize = Theme.SecondaryTextSize
	toggleExpandedsByActivated3.TextTruncate = Enum.TextTruncate.AtEnd
	toggleExpandedsByActivated3.TextXAlignment = Enum.TextXAlignment.Left
	toggleExpandedsByActivated3.TextYAlignment = Enum.TextYAlignment.Center

	if v3 and not v8 then
		toggleExpandedsByActivated3.AutoButtonColor = false
		toggleExpandedsByActivated3.Selectable = false
		toggleExpandedsByActivated3[React.Event.Activated] = toggleExpanded
	end

	local v18 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 6 + props.Depth * Theme.TableIndentWidth),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 2)
		}),
		ChevronSlot = 0,
		Key = 0,
		Divider = 0,
		Value = 0
	}
	local chevron2

	if v3 then
		local chevron = Controls.Chevron
		local color

		if state2 then
			color = Theme.Text
		else
			color = Theme.TextSubtle
		end

		chevron2 = createElement(chevron, {
			Color = color,
			Rotation = state and 0 or -90,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ZIndex = 173
		})
	end

	v18.ChevronSlot = createElement(v3 and "TextButton" or "Frame", toggleExpandedsByActivated, {
		Chevron = chevron2
	})
	local v22

	if v8 then
		v22 = createElement("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,
			Size = UDim2.fromOffset(sizePx, heightPx),
			ZIndex = 172
		}, {
			Explorer = createElement(Controls.TableExplorer, {
				Value = props.EntryKey,
				Context = props.Context,
				Minimal = props.MinimalTables,
				HeightPx = heightPx,
				SizePx = sizePx,
				TextSize = Theme.SecondaryTextSize,
				ZIndex = 172
			})
		})
	else
		v22 = createElement(v14, toggleExpandedsByActivated3)
	end

	v18.Key = v22
	local v25 = {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 3,
		Selectable = false,
		Size = UDim2.fromOffset(Theme.TableKeyDividerWidth, heightPx),
		Text = "",
		ZIndex = 173,
		[React.Event.InputBegan] = function(_, p)
			beginKeyResize(p)
		end,
		[React.Event.MouseEnter] = function()
			setState3(true)
		end,
		[React.Event.MouseLeave] = function()
			setState3(false)
		end
	}
	local v29 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = 0,
		BorderSizePixel = 0,
		Position = 0,
		Size = 0,
		ZIndex = 174
	}
	local backgroundColor

	if state3 then
		backgroundColor = Theme.Accent
	else
		backgroundColor = Theme.Divider
	end

	v29.BackgroundColor3 = backgroundColor
	v29.Position = UDim2.fromScale(0.5, 0.5)
	v29.Size = UDim2.fromOffset(2, heightPx)
	v18.Divider = createElement("TextButton", v25, {
		Line = createElement("Frame", v29)
	})
	v18.Value = createElement(v3 and "TextButton" or "TextLabel", toggleExpandedsByActivated2)
	local children = {
		Row = createElement("Frame", v9, v18)
	}

	if state and v3 then
		local clone = table.clone(props.Ancestors)
		table.insert(clone, value)

		for k, v31 in tableEntries(value, props.Context) do
			children[`Child{k}`] = createElement(TableValueRow, {
				EntryKey = v31.Key,
				Value = v31.Value,
				Context = props.Context,
				LayoutOrder = k,
				Depth = props.Depth + 1,
				Ancestors = clone,
				KeyWidthPx = props.KeyWidthPx,
				OnKeyWidthChanged = props.OnKeyWidthChanged,
				MinimalTables = props.MinimalTables
			})
		end
	end

	return createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, 0),
		ZIndex = 171
	}, {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Content = createElement(React.Fragment, {}, children)
	})
end

function Controls.PrefixBadge(p)
	return createElement("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Theme.MonoFont,
		LayoutOrder = p.LayoutOrder,
		RichText = true,
		Size = UDim2.fromOffset(0, Theme.PrefixBadgeHeight),
		Text = p.Text,
		TextColor3 = Theme.PrefixBadgeText,
		TextSize = Theme.RawTextSize,
		TextStrokeTransparency = 1,
		TextWrapped = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center
	}, {
		UIPadding = createElement("UIPadding", {
			PaddingRight = UDim.new(0, 2)
		})
	})
end

function Controls.Button(props)
	local ref = React.useRef(nil)
	local text = props.Text

	if not text then
		text = plainControlText(props.Part[4], props.Context, "Button")
	end

	local v3 = props.TextOverflowMode == "wrap"
	local v4 = fixedControlWidth(props.SizePx) -- equivalent call inferred; original call site unknown
	local v5 = v4 ~= nil or v3
	local v6

	if v4 then
		v6 = v4
	elseif v3 then
		v6 = wrapControlWidth(text, Theme.FontBold, 22)
	else
		v6 = 0
	end

	local v7 = math.max(1, v6 - 22)
	local textWrapped

	if v5 then
		local fontBold = Theme.FontBold

		if v7 > 0 then
			textWrapped = v7 < math.ceil(TextMetrics.measurePlain(text, Theme.ControlTextSize, fontBold).X)
		else
			textWrapped = false
		end
	else
		textWrapped = v5
	end

	local controlHeight

	if textWrapped then
		local fontBold = Theme.FontBold
		controlHeight = LayoutMetrics.controlTextHeight(text, fontBold, (math.max(1, v7)))
	else
		controlHeight = Theme.ControlHeight
	end

	local danger

	if props.Danger then
		danger = Theme.Danger
	else
		danger = Theme.Button
	end

	local dangerHover

	if props.Danger then
		dangerHover = Theme.DangerHover
	else
		dangerHover = Theme.ButtonHover
	end

	local dangerHover2

	if props.Danger then
		dangerHover2 = Theme.DangerHover
	else
		dangerHover2 = Theme.ButtonSelected
	end

	local v11 = {
		ref = ref
	}
	local automaticSize

	if v5 then
		automaticSize = Enum.AutomaticSize.None
	else
		automaticSize = Enum.AutomaticSize.XY
	end

	v11.AutomaticSize = automaticSize
	v11.AutoButtonColor = false
	v11.BackgroundColor3 = danger
	v11.BorderSizePixel = 0
	v11.Font = Theme.FontBold
	v11.LayoutOrder = props.LayoutOrder
	v11.RichText = false
	v11.Selectable = false
	local size

	if v5 then
		size = UDim2.fromOffset(v6, controlHeight)
	else
		size = UDim2.fromOffset(0, Theme.ControlHeight)
	end

	v11.Size = size
	v11.Text = v5 and "" or text
	local textColor

	if props.Danger then
		textColor = Theme.DangerText
	else
		textColor = Theme.Text
	end

	v11.TextColor3 = textColor
	v11.TextSize = Theme.ControlTextSize
	v11.TextStrokeTransparency = 1
	local textTruncate

	if v5 or textWrapped then
		textTruncate = Enum.TextTruncate.None
	else
		textTruncate = Enum.TextTruncate.AtEnd
	end

	v11.TextTruncate = textTruncate

	if v5 then
		textWrapped = false
	end

	v11.TextWrapped = textWrapped
	v11.TextYAlignment = Enum.TextYAlignment.Center

	v11[React.Event.Activated] = function()
		activate(props.Part, props.Context)
	end

	v11[React.Event.MouseEnter] = function()
		Motion.to(ref.current, Motion.Hover, {
			BackgroundColor3 = dangerHover
		})
	end

	v11[React.Event.MouseLeave] = function()
		Motion.to(ref.current, Motion.Hover, {
			BackgroundColor3 = danger
		})
	end

	v11[React.Event.MouseButton1Down] = function()
		Motion.to(ref.current, Motion.Press, {
			BackgroundColor3 = dangerHover2
		})
	end

	v11[React.Event.MouseButton1Up] = function()
		Motion.to(ref.current, Motion.Release, {
			BackgroundColor3 = dangerHover
		})
	end

	local v16 = {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerControl)
		}),
		UIPadding = 0,
		Label = 0,
		SizeConstraint = 0
	}
	local uIPadding

	if not v5 then
		uIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 11),
			PaddingRight = UDim.new(0, 11),
			PaddingTop = UDim.new(0, 1)
		})
	end

	v16.UIPadding = uIPadding
	local label

	if v5 then
		local v21 = {
			BackgroundTransparency = 1,
			Font = Theme.FontBold,
			Position = UDim2.fromOffset(11, 1),
			RichText = false,
			Size = UDim2.new(1, -22, 1, -2),
			Text = text,
			TextColor3 = 0,
			TextSize = 0,
			TextStrokeTransparency = 1,
			TextTruncate = 0,
			TextWrapped = 0,
			TextXAlignment = 0,
			TextYAlignment = 0
		}
		local textColor2

		if props.Danger then
			textColor2 = Theme.DangerText
		else
			textColor2 = Theme.Text
		end

		v21.TextColor3 = textColor2
		v21.TextSize = Theme.ControlTextSize
		local textTruncate2

		if textWrapped then
			textTruncate2 = Enum.TextTruncate.None
		else
			textTruncate2 = Enum.TextTruncate.AtEnd
		end

		v21.TextTruncate = textTruncate2
		v21.TextWrapped = textWrapped
		v21.TextXAlignment = Enum.TextXAlignment.Center
		local textYAlignment

		if textWrapped then
			textYAlignment = Enum.TextYAlignment.Top
		else
			textYAlignment = Enum.TextYAlignment.Center
		end

		v21.TextYAlignment = textYAlignment
		label = createElement("TextLabel", v21)
	end

	v16.Label = label
	local sizeConstraint

	if v3 and not v4 then
		sizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(Theme.ControlWrapMaxWidth, 1000)
		})
	end

	v16.SizeConstraint = sizeConstraint
	return createElement("TextButton", v11, v16)
end

function Controls.Checkbox(props)
	local v3 = typeof(props.Part[5]) == "boolean"
	local state, setState = React.useState(false)

	if v3 then
		state = props.Part[5] == true
	end

	local ref = React.useRef(nil)
	local scale, v5 = Motion.useNumberMotion(state and 1 or 0)
	local text = plainControlText(props.Part[4], props.Context, "Checkbox") -- equivalent call inferred; original call site unknown
	local v8 = props.TextOverflowMode == "wrap"
	local v9 = fixedControlWidth(props.SizePx) -- equivalent call inferred; original call site unknown
	local v10

	if v8 then
		local fontBold = Theme.FontBold
		v10 = math.max(1, wrapControlWidth(text, fontBold, 43) - 43)
	else
		v10 = not v9 and 0 or math.max(1, v9 - 43)
	end

	local v11 = v9 or not v8 and 0 or v10 + 43
	local textWrapped

	if v9 == nil and not v8 then
		textWrapped = v8
	else
		local fontBold = Theme.FontBold

		if v10 > 0 then
			textWrapped = v10 < math.ceil(TextMetrics.measurePlain(text, Theme.ControlTextSize, fontBold).X)
		else
			textWrapped = false
		end
	end

	local controlHeight

	if textWrapped then
		local fontBold = Theme.FontBold
		controlHeight = LayoutMetrics.controlTextHeight(text, fontBold, (math.max(1, v10)))
	else
		controlHeight = Theme.ControlHeight
	end

	React.useEffect(function()
		local v15

		if state then
			v15 = Motion.Pop
		else
			v15 = Motion.Press
		end

		v5(state and 1 or 0, v15)
	end, { state })
	local v15 = {
		ref = ref
	}
	local automaticSize

	if v9 or v8 then
		automaticSize = Enum.AutomaticSize.None
	else
		automaticSize = Enum.AutomaticSize.XY
	end

	v15.AutomaticSize = automaticSize
	v15.AutoButtonColor = false
	v15.BackgroundColor3 = Theme.Button
	v15.BorderSizePixel = 0
	v15.Font = Theme.FontBold
	v15.LayoutOrder = props.LayoutOrder
	v15.RichText = false
	v15.Selectable = false
	local size

	if v9 or v8 then
		size = UDim2.fromOffset(v11, controlHeight)
	else
		size = UDim2.fromOffset(0, Theme.ControlHeight)
	end

	v15.Size = size
	v15.Text = ""
	v15.TextColor3 = Theme.Text
	v15.TextSize = Theme.ControlTextSize
	v15.TextStrokeTransparency = 1

	v15[React.Event.Activated] = function()
		local v18 = not state

		if not v3 then
			setState(v18)
		end

		activate(props.Part, props.Context, v18)
	end

	v15[React.Event.MouseEnter] = function()
		Motion.to(ref.current, Motion.Hover, {
			BackgroundColor3 = Theme.ButtonHover
		})
	end

	v15[React.Event.MouseLeave] = function()
		Motion.to(ref.current, Motion.Hover, {
			BackgroundColor3 = Theme.Button
		})
	end

	local v18 = {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerControl)
		}),
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 7),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 9),
			PaddingRight = UDim.new(0, 11),
			PaddingTop = UDim.new(0, 1)
		}),
		Box = 0,
		Label = 0,
		SizeConstraint = 0
	}
	local backgroundColor

	if state then
		backgroundColor = Theme.PositiveBg
	else
		backgroundColor = Theme.PanelDarker
	end

	v18.Box = createElement("Frame", {
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Size = UDim2.fromOffset(16, 16)
	}, {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerSmall)
		}),
		Icon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://126491458606904",
			ImageColor3 = Theme.Success,
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.new(1, -2, 1, -2)
		}, {
			Scale = createElement("UIScale", {
				Scale = scale
			})
		})
	})
	local automaticSize2

	if v9 or v8 then
		automaticSize2 = Enum.AutomaticSize.None
	else
		automaticSize2 = Enum.AutomaticSize.XY
	end

	local v25 = {
		AutomaticSize = automaticSize2,
		BackgroundTransparency = 1,
		Font = Theme.FontBold,
		LayoutOrder = 2,
		RichText = false,
		Size = 0,
		Text = 0,
		TextColor3 = 0,
		TextSize = 0,
		TextStrokeTransparency = 1,
		TextTruncate = 0,
		TextWrapped = 0,
		TextXAlignment = 0,
		TextYAlignment = 0
	}
	local size2

	if v9 or v8 then
		size2 = UDim2.fromOffset(v10, controlHeight)
	else
		size2 = UDim2.fromOffset(0, 0)
	end

	v25.Size = size2
	v25.Text = text
	v25.TextColor3 = Theme.Text
	v25.TextSize = Theme.ControlTextSize
	local textTruncate

	if textWrapped then
		textTruncate = Enum.TextTruncate.None
	else
		textTruncate = Enum.TextTruncate.AtEnd
	end

	v25.TextTruncate = textTruncate
	v25.TextWrapped = textWrapped
	v25.TextXAlignment = Enum.TextXAlignment.Left
	local textYAlignment

	if textWrapped then
		textYAlignment = Enum.TextYAlignment.Top
	else
		textYAlignment = Enum.TextYAlignment.Center
	end

	v25.TextYAlignment = textYAlignment
	v18.Label = createElement("TextLabel", v25)
	local sizeConstraint

	if v8 and not v9 then
		sizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(Theme.ControlWrapMaxWidth, 1000)
		})
	end

	v18.SizeConstraint = sizeConstraint
	return createElement("TextButton", v15, v18)
end

function Controls.Combo(props)
	local state, setState = React.useState(nil)
	local text

	if state then
		text = state
	else
		text = plainControlText(props.Part[4], props.Context, "Select")
	end

	local v4 = props.TextOverflowMode == "wrap"
	local fontBold = Theme.FontBold
	local v5 = math.ceil(TextMetrics.measurePlain(text, Theme.ControlTextSize, fontBold).X) + 42
	local v6 = fixedControlWidth(props.SizePx) -- equivalent call inferred; original call site unknown
	local v7

	if v6 then
		v7 = v6
	elseif v4 then
		v7 = math.max(Theme.ControlHeight, (math.min(v5, Theme.ControlWrapMaxWidth)))
	else
		v7 = math.max(Theme.ControlHeight, v5)
	end

	local v8 = math.max(1, v7 - 34)
	local v9

	if v6 == nil and not v4 then
		v9 = v4
	else
		local fontBold2 = Theme.FontBold

		if v8 > 0 then
			v9 = v8 < math.ceil(TextMetrics.measurePlain(text, Theme.ControlTextSize, fontBold2).X)
		else
			v9 = false
		end
	end

	local controlHeight

	if v9 then
		local fontBold2 = Theme.FontBold
		controlHeight = LayoutMetrics.controlTextHeight(text, fontBold2, (math.max(1, v8)))
	else
		controlHeight = Theme.ControlHeight
	end

	local v10 = {}
	local v11 = props.Part[5]

	if props.FromChildren and typeof(v11) == "Instance" then
		for _, child in v11:GetChildren() do
			table.insert(v10, child)
		end
	elseif typeof(v11) == "table" then
		for _, item in v11 do
			table.insert(v10, item)
		end
	end

	local v12 = Controls.useInlinePopoutState(function()
		return #v10 > 0
	end)
	local opened = v12.Opened

	local function renderSelector(ref, flag: boolean)
		local zIndex = flag and 162 or nil
		local controlHeight2

		if flag then
			controlHeight2 = Theme.ControlHeight
		else
			controlHeight2 = controlHeight
		end

		local textWrapped = not flag and v9
		local buttonHover

		if flag or opened then
			buttonHover = Theme.ButtonHover
		else
			buttonHover = Theme.Button
		end

		local v17 = {
			ref = ref,
			AutomaticSize = Enum.AutomaticSize.None,
			AutoButtonColor = false,
			BackgroundColor3 = buttonHover,
			BorderSizePixel = 0,
			Font = Theme.FontBold,
			LayoutOrder = 1,
			RichText = false,
			Selectable = false
		}
		local size

		if flag then
			size = UDim2.new(1, 0, 0, Theme.ControlHeight)
		else
			size = UDim2.fromOffset(v7, controlHeight2)
		end

		v17.Size = size
		v17.Text = ""
		v17.TextColor3 = Theme.Text
		v17.TextSize = Theme.ControlTextSize
		v17.TextStrokeTransparency = 1
		v17.TextWrapped = false
		v17.ZIndex = zIndex
		v17[React.Event.Activated] = v12.Activate
		v17[React.Event.InputBegan] = v12.HeaderInputBegan

		v17[React.Event.MouseEnter] = function()
			Motion.to(ref and ref.current, Motion.Hover, {
				BackgroundColor3 = Theme.ButtonHover
			})
		end

		v17[React.Event.MouseLeave] = function()
			Motion.to(ref and ref.current, Motion.Hover, {
				BackgroundColor3 = buttonHover
			})
		end

		local uICorner

		if not flag then
			uICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerControl)
			})
		end

		local v23 = {
			BackgroundTransparency = 1,
			Font = Theme.FontBold,
			Position = UDim2.fromOffset(11, 0),
			RichText = false,
			Size = UDim2.new(1, -34, 1, 0),
			Text = text,
			TextColor3 = Theme.Text,
			TextSize = Theme.ControlTextSize,
			TextStrokeTransparency = 1,
			TextTruncate = 0,
			TextWrapped = 0,
			TextXAlignment = 0,
			TextYAlignment = 0,
			ZIndex = 0
		}
		local textTruncate

		if textWrapped then
			textTruncate = Enum.TextTruncate.None
		else
			textTruncate = Enum.TextTruncate.AtEnd
		end

		v23.TextTruncate = textTruncate
		v23.TextWrapped = textWrapped
		v23.TextXAlignment = Enum.TextXAlignment.Left
		local textYAlignment

		if textWrapped then
			textYAlignment = Enum.TextYAlignment.Top
		else
			textYAlignment = Enum.TextYAlignment.Center
		end

		v23.TextYAlignment = textYAlignment
		v23.ZIndex = zIndex
		local v19 = {
			UICorner = uICorner,
			Label = createElement("TextLabel", v23),
			Chevron = 0,
			SizeConstraint = 0
		}
		local chevron

		if not (opened and not flag) then
			chevron = createElement(Controls.Chevron, {
				Color = Theme.TextSubtle,
				Rotation = flag and 0 or -90,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -11, 0.5, 0),
				ZIndex = zIndex
			})
		end

		v19.Chevron = chevron
		local sizeConstraint

		if v4 and not (v6 or flag) then
			sizeConstraint = createElement("UISizeConstraint", {
				MaxSize = Vector2.new(Theme.ControlWrapMaxWidth, 1000)
			})
		end

		v19.SizeConstraint = sizeConstraint
		return createElement("TextButton", v17, v19)
	end

	local options

	if opened then
		local children = {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			UIPadding = createElement("UIPadding", {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4)
			})
		}

		for k, v14 in v10 do
			local label = plainControlText(v14, props.Context, tostring(v14)) -- equivalent call inferred; original call site unknown
			local v18 = v14
			children[`Option{k}`] = createElement(Controls.DropdownOption, {
				Label = label,
				Selected = label == state,
				LayoutOrder = k,
				ZIndex = 162,
				OnActivated = function()
					setState(label)
					v12.Close()
					activate(props.Part, props.Context, v18)
				end
			})
		end

		local v14 = math.max(Theme.DropdownRowHeight, #v10 * (Theme.DropdownRowHeight + 2) + 4)
		local widthPx = math.max(Theme.ComboDropdownWidth, v7)
		options = createElement(Popout, {
			Open = opened,
			AnchorRef = v12.AnchorRef,
			WidthPx = widthPx,
			HeightPx = Theme.ControlHeight + v14,
			InitialVisibleHeightPx = controlHeight,
			ConstrainHeightToViewportBottom = true,
			OffsetY = -controlHeight + 1,
			OnOutsideInput = v12.Close,
			ZIndex = 160
		}, {
			Surface = createElement(Controls.PopoutScroller, {
				Header = renderSelector(nil, true),
				HeaderHeightPx = Theme.ControlHeight,
				ZIndex = 161
			}, {
				Rows = createElement("Frame", {
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					ZIndex = 162
				}, children)
			})
		})
	end

	return createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromOffset(0, 0)
	}, {
		Button = renderSelector(v12.AnchorRef, false),
		Options = options
	})
end

function Controls.Tooltip(p)
	local state, setState = React.useState(false)
	local ref = React.useRef(nil)
	local stripRichText = TextMetrics.stripRichText(p.Text)
	return createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		LayoutOrder = p.LayoutOrder,
		Size = UDim2.fromOffset(0, 0)
	}, {
		Mark = createElement("TextLabel", {
			ref = ref,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = Theme.FontBold,
			RichText = false,
			Size = UDim2.fromOffset(0, Theme.ControlHeight),
			Text = "ⓘ",
			TextColor3 = Theme.TextSubtle,
			TextSize = Theme.ControlTextSize,
			TextStrokeTransparency = 1,
			[React.Event.MouseEnter] = function()
				setState(true)
				Motion.to(ref.current, Motion.Hover, {
					TextColor3 = Theme.Accent
				})
			end,
			[React.Event.MouseLeave] = function()
				setState(false)
				Motion.to(ref.current, Motion.Hover, {
					TextColor3 = Theme.TextSubtle
				})
			end
		}),
		Bubble = createElement(Controls.TooltipPopout, {
			Open = state,
			AnchorRef = ref,
			Text = stripRichText,
			WidthPx = Theme.TooltipWidth,
			HeightPx = Theme.TooltipHeight,
			OffsetY = 3,
			ZIndex = 170
		})
	})
end

function Controls.Divider(props)
	local state, setState = React.useState(false)
	local v3 = Motion.useMeasuredCollapse(true, {
		UnmountWhenClosed = props.Collapsable == true
	})
	local controlHeight = Theme.ControlHeight
	local v4 = math.floor(controlHeight / 2)
	local v5 = props.Collapsable and 18 or 0
	local label = props.Label
	local fontBold = Theme.FontBold
	local v6 = math.ceil(TextMetrics.measurePlain(label, Theme.ControlTextSize, fontBold).X) + v5 + 16 + 8
	local v7 = math.ceil(v6 / 2)
	local v8 = v6 + 10
	local labelCentered = props.LabelCentered == true
	local accent

	if props.Collapsable and state then
		accent = Theme.Accent
	else
		accent = Theme.ButtonStroke
	end

	local text

	if props.Collapsable and state then
		text = Theme.Text
	else
		text = Theme.TextMuted
	end

	local v9 = props.Collapsable and "TextButton" or "TextLabel"
	local clipped

	if props.Collapsable == true then
		clipped = v3.Clipped
	else
		clipped = false
	end

	local v10 = not props.Collapsable or v3.BodyMounted
	local anchorPoint

	if labelCentered then
		anchorPoint = Vector2.new(0.5, 0)
	else
		anchorPoint = Vector2.new(0, 0)
	end

	local v11 = {
		AnchorPoint = anchorPoint,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Theme.FontBold,
		Position = 0,
		RichText = false,
		Size = 0,
		Text = "",
		TextColor3 = 0,
		TextSize = 0,
		TextStrokeTransparency = 1,
		ZIndex = 4
	}
	local position

	if labelCentered then
		position = UDim2.fromScale(0.5, 0)
	else
		position = UDim2.fromOffset(10, 0)
	end

	v11.Position = position
	v11.Size = UDim2.fromOffset(0, controlHeight)
	v11.TextColor3 = text
	v11.TextSize = Theme.ControlTextSize

	if props.Collapsable then
		v11.AutoButtonColor = false
		v11[React.Event.Activated] = v3.Toggle

		v11[React.Event.MouseEnter] = function()
			setState(true)
		end

		v11[React.Event.MouseLeave] = function()
			setState(false)
		end
	end

	local v16 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, 0)
	}
	local v17 = {
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, Theme.DividerOuterPaddingY),
			PaddingTop = UDim.new(0, Theme.DividerOuterPaddingY)
		}),
		Inner = 0
	}
	local v20 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, controlHeight)
	}
	local v24 = {
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, v4),
		Size = 0,
		ZIndex = 1
	}
	local size

	if labelCentered then
		size = UDim2.new(0.5, -v7, 0, 1)
	else
		size = UDim2.fromOffset(10, 1)
	end

	v24.Size = size
	local v21 = {
		TopLineLeft = createElement("Frame", v24),
		TopLineRight = 0,
		Box = 0,
		Label = 0
	}
	local position2

	if labelCentered then
		position2 = UDim2.new(0.5, v7, 0, v4)
	else
		position2 = UDim2.new(0, v8, 0, v4)
	end

	local size2

	if labelCentered then
		size2 = UDim2.new(0.5, -v7, 0, 1)
	else
		size2 = UDim2.new(1, -v8, 0, 1)
	end

	v21.TopLineRight = createElement("Frame", {
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
		Position = position2,
		Size = size2,
		ZIndex = 1
	})
	local box

	if v10 then
		local automaticSize

		if clipped then
			automaticSize = Enum.AutomaticSize.None
		else
			automaticSize = Enum.AutomaticSize.Y
		end

		local v34 = {
			AutomaticSize = automaticSize,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = props.Collapsable == true,
			Position = UDim2.fromOffset(0, v4),
			Size = 0,
			ZIndex = 2
		}
		local size3

		if clipped then
			size3 = v3.Height:map(function(p)
				return UDim2.new(1, 0, 0, (math.max(0, p)))
			end)
		else
			size3 = UDim2.new(1, 0, 0, 0)
		end

		v34.Size = size3
		box = createElement("Frame", v34, {
			LeftLine = createElement("Frame", {
				BackgroundColor3 = accent,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.new(0, 1, 1, 0),
				ZIndex = 1
			}),
			RightLine = createElement("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = accent,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.new(0, 1, 1, 0),
				ZIndex = 1
			}),
			BottomLine = createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = accent,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 1),
				ZIndex = 1
			}),
			Measure = createElement("Frame", {
				ref = v3.MeasureRef,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.new(1, 0, 0, 0),
				ZIndex = 2
			}, {
				UIPadding = createElement("UIPadding", {
					PaddingBottom = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, v4 + 6)
				}),
				Content = props.RenderBody()
			})
		})
	end

	v21.Box = box
	local v33 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		UIPadding = createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8)
		}),
		Chevron = 0,
		Text = 0
	}
	local chevron

	if props.Collapsable then
		chevron = createElement(Controls.Chevron, {
			Color = text,
			LayoutOrder = 1,
			Rotation = v3.ChevronAngle,
			ZIndex = 5
		})
	end

	v33.Chevron = chevron
	v33.Text = createElement("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Font = Theme.FontBold,
		LayoutOrder = 2,
		RichText = false,
		Size = UDim2.fromOffset(0, 0),
		Text = props.Label,
		TextColor3 = text,
		TextSize = Theme.ControlTextSize,
		TextStrokeTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 5
	})
	v21.Label = createElement(v9, v11, v33)
	v17.Inner = createElement("Frame", v20, v21)
	return createElement("Frame", v16, v17)
end

function Controls.CollapsableDivider(props)
	return createElement(Controls.Divider, {
		Label = props.Label,
		LayoutOrder = props.LayoutOrder,
		Collapsable = true,
		LabelCentered = props.LabelCentered,
		RenderBody = props.RenderBody
	})
end

Controls.CollapsibleDivider = Controls.CollapsableDivider

function Controls.BubbleFrame(props)
	local scaleX = props.ScaleX
	local v3 = typeof(scaleX) ~= "number" and 1 or math.clamp(scaleX, 0.05, 1)
	local scaleY = props.ScaleY
	local v4 = typeof(scaleY) ~= "number" and 0.12 or math.clamp(scaleY, 0.05, 1)
	local v5 = fixedControlWidth(props.SizePx) -- equivalent call inferred; original call site unknown
	local v6 = math.max(Theme.AlignedCellMinHeight, (math.floor(v4 * Theme.BubbleFrameHeightReference)))
	local v9 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.BubbleFrame,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Size = 0
	}
	local size

	if v5 then
		size = UDim2.fromOffset(v5, v6)
	else
		size = UDim2.new(v3, -Theme.AlignedGroupInset, 0, v6)
	end

	v9.Size = size
	return createElement("Frame", v9, {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0, Theme.CornerPanel)
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, Theme.BubbleFramePadding),
			PaddingLeft = UDim.new(0, Theme.BubbleFramePadding),
			PaddingRight = UDim.new(0, Theme.BubbleFramePadding),
			PaddingTop = UDim.new(0, Theme.BubbleFramePadding)
		}),
		Content = createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0)
		}, {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			Body = props.RenderBody()
		}),
		MinHeight = createElement("UISizeConstraint", {
			MinSize = Vector2.new(0, v6)
		})
	})
end

function Controls.AlignedCell(props)
	local alignedCellPadding = Theme.AlignedCellPadding
	local automaticSize

	if props.FixedHeight then
		automaticSize = Enum.AutomaticSize.None
	else
		automaticSize = Enum.AutomaticSize.Y
	end

	local v5 = {
		AutomaticSize = automaticSize,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
		LayoutOrder = props.LayoutOrder,
		Size = 0,
		ZIndex = 0
	}
	local size

	if props.FixedHeight then
		size = UDim2.fromScale(1, 1)
	else
		size = UDim2.new(1, 0, 0, Theme.AlignedCellMinHeight)
	end

	v5.Size = size
	v5.ZIndex = props.ZIndex
	return createElement("Frame", v5, {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, alignedCellPadding),
			PaddingLeft = UDim.new(0, alignedCellPadding),
			PaddingRight = UDim.new(0, alignedCellPadding),
			PaddingTop = UDim.new(0, alignedCellPadding)
		}),
		Content = createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 0),
			ZIndex = props.ZIndex
		}, props.children)
	})
end

function Controls.AlignedGrid(props)
	local scaleX = props.ScaleX
	local v3 = typeof(scaleX) ~= "number" and 1 or math.clamp(scaleX, 0.05, 1)
	local scaleY = props.ScaleY
	local v4 = typeof(scaleY) ~= "number" and 0.1 or math.clamp(scaleY, 0.05, 1)
	local v5 = fixedControlWidth(props.SizePx) -- equivalent call inferred; original call site unknown
	local v6 = math.max(Theme.AlignedCellMinHeight, (math.floor(v4 * Theme.AlignedGridHeightReference)))
	local v7 = math.max(1, (math.floor(1 / v3 + 0.5)))
	local v8 = 1 / v7
	local children = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 0),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	}
	local children2 = {}

	for k, item in props.Items do
		local v9 = math.floor((k - 1) / v7) + 1
		local layoutOrder = (k - 1) % v7 + 1
		local children3 = children2[v9]

		if not children3 then
			children3 = {
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Top
				})
			}
			children2[v9] = children3
		end

		children3[`Cell{layoutOrder}`] = createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
			Size = UDim2.new(v8, -1, 0, v6)
		}, {
			Inner = createElement(Controls.AlignedCell, {
				LayoutOrder = 1
			}, {
				Content = item
			}),
			MinHeight = createElement("UISizeConstraint", {
				MinSize = Vector2.new(0, v6)
			})
		})
	end

	for k, v9 in children2 do
		children[`Row{k}`] = createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = k,
			Size = UDim2.new(1, 0, 0, 0)
		}, v9)
	end

	local v11 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = 0
	}
	local size

	if v5 then
		size = UDim2.fromOffset(v5, 0)
	else
		size = UDim2.new(v3, -Theme.AlignedGroupInset, 0, 0)
	end

	v11.Size = size
	return createElement("Frame", v11, children)
end

function Controls.AlignedList(props)
	local scaleX = props.ScaleX
	local v3 = typeof(scaleX) ~= "number" and 1 or math.clamp(scaleX, 0.05, 1)
	local v4 = fixedControlWidth(props.SizePx) -- equivalent call inferred; original call site unknown
	local children = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 0),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	}

	for k, item in props.Items do
		children[`Cell{k}`] = createElement(Controls.AlignedCell, {
			LayoutOrder = k
		}, {
			Content = item
		})
	end

	local v7 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = 0
	}
	local size

	if v4 then
		size = UDim2.fromOffset(v4, 0)
	else
		size = UDim2.new(v3, -Theme.AlignedGroupInset, 0, 0)
	end

	v7.Size = size
	return createElement("Frame", v7, children)
end

function Controls.TableExplorer(props)
	local state, setState = React.useState(false)
	local count = 0

	for _ in props.Value do
		count += 1
	end

	local formatted = `Table ({count})`
	local count2 = 0

	for _ in props.Value do
		count2 += 1
	end

	local v3 = count2 > 0
	local heightPx = props.HeightPx or Theme.ControlHeight
	local textSize = props.TextSize or Theme.ControlTextSize
	local minimal = props.Minimal == true
	local state2, setState2 = React.useState(Theme.TableKeyWidth)
	local v4 = Controls.useInlinePopoutState(function()
		return true
	end, function()
		setState(false)
	end)
	local opened = v4.Opened
	local text, text2, v7

	if minimal then
		text, text2, v7 = tablePrettyText(props.Value, props.Context)
	else
		v7 = 0
		text2 = ""
		text = ""
	end

	React.useEffect(function()
		if state and not (opened and minimal) then
			setState(false)
		end
	end, { opened, minimal, state })

	local function setClampedKeyWidth(p: number)
		setState2((math.clamp(math.floor(p + 0.5), Theme.TableKeyMinWidth, Theme.TableKeyMaxWidth)))
	end

	local function renderHeader(ref, flag: boolean)
		local zIndex = flag and 167 or props.ZIndex
		local v9

		if not flag then
			local sizePx = props.SizePx

			if typeof(sizePx) == "number" and not (sizePx <= 0) then
				v9 = math.floor(sizePx + 0.5)
			end
		end

		local v10 = flag or v9 ~= nil
		local buttonHover

		if flag or opened then
			buttonHover = Theme.ButtonHover
		else
			buttonHover = Theme.Button
		end

		local v11 = flag and minimal and 124 or 34
		local v14 = {
			ref = ref
		}
		local automaticSize

		if v10 then
			automaticSize = Enum.AutomaticSize.None
		else
			automaticSize = Enum.AutomaticSize.XY
		end

		v14.AutomaticSize = automaticSize
		v14.AutoButtonColor = false
		v14.BackgroundColor3 = buttonHover
		v14.BorderSizePixel = 0
		v14.LayoutOrder = 1
		v14.Selectable = false
		local uDim

		if flag then
			uDim = UDim2.new(1, 0, 0, heightPx)
		elseif v9 then
			uDim = UDim2.fromOffset(v9, heightPx)
		else
			uDim = UDim2.fromOffset(0, heightPx)
		end

		v14.Size = uDim
		v14.Text = ""
		v14.ZIndex = zIndex
		v14[React.Event.Activated] = v4.Activate
		v14[React.Event.InputBegan] = v4.HeaderInputBegan

		v14[React.Event.MouseEnter] = function()
			Motion.to(ref and ref.current, Motion.Hover, {
				BackgroundColor3 = Theme.ButtonHover
			})
		end

		v14[React.Event.MouseLeave] = function()
			Motion.to(ref and ref.current, Motion.Hover, {
				BackgroundColor3 = buttonHover
			})
		end

		local uICorner

		if not flag then
			uICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerControl)
			})
		end

		local uIListLayout

		if not v10 then
			uIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			})
		end

		local uIPadding

		if not v10 then
			uIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 1),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 12),
				PaddingTop = UDim.new(0, 1)
			})
		end

		local automaticSize2

		if v10 then
			automaticSize2 = Enum.AutomaticSize.None
		else
			automaticSize2 = Enum.AutomaticSize.XY
		end

		local v22 = {
			AutomaticSize = automaticSize2,
			BackgroundTransparency = 1,
			Font = Theme.FontBold,
			LayoutOrder = not v10 and 1 or nil,
			Position = 0,
			RichText = false,
			Size = 0,
			Text = 0,
			TextColor3 = 0,
			TextSize = 0,
			TextStrokeTransparency = 1,
			TextTruncate = 0,
			TextWrapped = false,
			TextXAlignment = 0,
			TextYAlignment = 0,
			ZIndex = 0
		}
		local position

		if v10 then
			position = UDim2.fromOffset(11, 0)
		end

		v22.Position = position
		local size

		if v10 then
			size = UDim2.new(1, -v11, 1, 0)
		else
			size = UDim2.fromOffset(0, 0)
		end

		v22.Size = size
		v22.Text = formatted
		v22.TextColor3 = Theme.Text
		v22.TextSize = textSize
		v22.TextTruncate = Enum.TextTruncate.AtEnd
		v22.TextXAlignment = Enum.TextXAlignment.Left
		v22.TextYAlignment = Enum.TextYAlignment.Center
		v22.ZIndex = zIndex
		local v16 = {
			UICorner = uICorner,
			UIListLayout = uIListLayout,
			UIPadding = uIPadding,
			Label = createElement("TextLabel", v22),
			ChevronCell = 0,
			Chevron = 0
		}
		local chevronCell

		if not (v10 or opened) then
			chevronCell = createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Size = UDim2.fromOffset(12, heightPx),
				ZIndex = zIndex
			}, {
				Inner = createElement(Controls.Chevron, {
					Color = Theme.TextMuted,
					Rotation = opened and 0 or -90,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					ZIndex = zIndex
				})
			})
		end

		v16.ChevronCell = chevronCell
		local chevron

		if v10 and (flag or not opened) then
			chevron = createElement(Controls.Chevron, {
				Color = Theme.TextMuted,
				Rotation = opened and 0 or -90,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -11, 0.5, 0),
				ZIndex = zIndex
			})
		end

		v16.Chevron = chevron
		return createElement("TextButton", v14, v16)
	end

	local children = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	}

	if v3 then
		local ancestors = { props.Value }

		for k, v9 in tableEntries(props.Value, props.Context) do
			children[`Row{k}`] = createElement(TableValueRow, {
				EntryKey = v9.Key,
				Value = v9.Value,
				Context = props.Context,
				LayoutOrder = k,
				Depth = 0,
				Ancestors = ancestors,
				KeyWidthPx = state2,
				OnKeyWidthChanged = setClampedKeyWidth,
				MinimalTables = props.Minimal
			})
		end
	else
		children.Empty = createElement("TextLabel", {
			BackgroundTransparency = 1,
			Font = Theme.Font,
			LayoutOrder = 1,
			RichText = false,
			Size = UDim2.new(1, 0, 0, Theme.TableRowHeight),
			Text = "Empty table",
			TextColor3 = Theme.TextSubtle,
			TextSize = Theme.SecondaryTextSize,
			TextStrokeTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 168
		})
	end

	local v10 = {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromOffset(0, 0)
	}
	local v11 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Header = renderHeader(v4.AnchorRef, false),
		Body = 0
	}
	local v14 = {
		Open = opened,
		AnchorRef = v4.AnchorRef,
		WidthPx = Theme.TablePopoutWidth,
		HeightPx = Theme.TablePopoutHeight,
		InitialVisibleHeightPx = heightPx,
		OffsetY = -heightPx + 1,
		Resizable = true,
		MinWidthPx = Theme.TablePopoutMinWidth,
		MinHeightPx = Theme.TablePopoutMinHeight,
		ResizeHandleSize = Theme.TreeResizeHandleSize,
		OnOutsideInput = v4.Close,
		ZIndex = 165
	}
	local v18 = {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 166
	}
	local v19 = {
		Header = renderHeader(nil, true),
		ExportToggle = 0,
		Scroller = 0
	}
	local exportToggle

	if minimal then
		local v23 = {
			AnchorPoint = Vector2.new(1, 0),
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Font = Theme.FontBold,
			Position = UDim2.new(1, -8, 0, 4),
			RichText = false,
			Selectable = false,
			Size = UDim2.fromOffset(86, (math.max(Theme.ControlHeight - 6, heightPx - 8))),
			Text = "",
			TextColor3 = Theme.Text,
			TextSize = Theme.SecondaryTextSize,
			TextStrokeTransparency = 1,
			ZIndex = 169,
			[React.Event.Activated] = function()
				setState(not state)
			end
		}
		local v24 = {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			UIPadding = createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4)
			}),
			Box = 0,
			Label = 0
		}
		local backgroundColor

		if state then
			backgroundColor = Theme.PositiveBg
		else
			backgroundColor = Theme.PanelDarker
		end

		local v27 = {
			BackgroundColor3 = backgroundColor,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.fromOffset(15, 15),
			ZIndex = 170
		}
		local v29 = {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerSmall)
			}),
			Icon = 0
		}
		local icon

		if state then
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = "rbxassetid://126491458606904",
				ImageColor3 = Theme.Success,
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.new(1, -2, 1, -2),
				ZIndex = 171
			})
		end

		v29.Icon = icon
		v24.Box = createElement("Frame", v27, v29)
		v24.Label = createElement("TextLabel", {
			BackgroundTransparency = 1,
			Font = Theme.FontBold,
			LayoutOrder = 2,
			RichText = false,
			Size = UDim2.new(1, -25, 1, 0),
			Text = "Export",
			TextColor3 = Theme.Text,
			TextSize = Theme.SecondaryTextSize,
			TextStrokeTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			ZIndex = 170
		})
		exportToggle = createElement("TextButton", v23, v24)
	end

	v19.ExportToggle = exportToggle
	local v23 = {
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		BottomImage = "",
		CanvasSize = UDim2.new(),
		ClipsDescendants = true,
		MidImage = "",
		Position = UDim2.fromOffset(0, heightPx),
		ScrollBarImageColor3 = Theme.ButtonStroke,
		ScrollBarImageTransparency = 0.15,
		ScrollBarThickness = 5,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollingEnabled = true,
		Size = UDim2.new(1, 0, 1, -heightPx),
		TopImage = "",
		ZIndex = 167
	}
	local v24 = {
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, Theme.TreeResizeHandleSize + 4),
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8)
		}),
		Rows = 0,
		PrettyText = 0
	}
	local rows

	if not minimal then
		rows = createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -16, 0, 0),
			ZIndex = 168
		}, children)
	end

	v24.Rows = rows
	local prettyText

	if minimal then
		local v29 = {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.PanelDarker,
			BackgroundTransparency = 0.08,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.new(1, -16, 0, 0),
			ZIndex = 168
		}
		local v30 = {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerSmall)
			}),
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 8),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8)
			}),
			Text = 0
		}
		local text3

		if state then
			text3 = createElement("TextBox", {
				AutoLocalize = false,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
				Font = Theme.MonoFont,
				LayoutOrder = 1,
				MultiLine = true,
				RichText = false,
				Selectable = true,
				Size = UDim2.new(1, 0, 0, (math.max(18, v7 * 18))),
				Text = text2,
				TextColor3 = Theme.Text,
				TextEditable = false,
				TextSize = 14,
				TextStrokeTransparency = 1,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = 169
			})
		else
			text3 = createElement("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Font = Theme.MonoFont,
				LayoutOrder = 1,
				RichText = true,
				Size = UDim2.new(1, 0, 0, (math.max(18, v7 * 18))),
				Text = text,
				TextColor3 = Theme.Text,
				TextSize = 14,
				TextStrokeTransparency = 1,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = 169
			})
		end

		v30.Text = text3
		prettyText = createElement("Frame", v29, v30)
	end

	v24.PrettyText = prettyText
	v19.Scroller = createElement("ScrollingFrame", v23, v24)
	v11.Body = createElement(Popout, v14, {
		Surface = createElement("Frame", v18, v19)
	})
	return createElement("Frame", v10, v11)
end

function Controls.Tree(props)
	local v3 = fixedControlWidth(props.SizePx) -- equivalent call inferred; original call site unknown
	local v4 = not v3 and 0 or math.max(1, v3 - 34)
	local v5

	if v3 == nil then
		v5 = false
	else
		local label = props.Label
		local fontBold = Theme.FontBold

		if v4 > 0 then
			v5 = v4 < math.ceil(TextMetrics.measurePlain(label, Theme.ControlTextSize, fontBold).X)
		else
			v5 = false
		end
	end

	local controlHeight

	if v5 then
		local label = props.Label
		local fontBold = Theme.FontBold
		controlHeight = LayoutMetrics.controlTextHeight(label, fontBold, (math.max(1, v4)))
	else
		controlHeight = Theme.ControlHeight
	end

	local v6 = Controls.useInlinePopoutState(function()
		return true
	end)
	local opened = v6.Opened

	local function renderHeader(ref, flag: boolean)
		local zIndex = flag and 167 or nil
		local v8

		if not flag then
			v8 = v3
		end

		local v9 = flag or v8 ~= nil
		local controlHeight2

		if flag then
			controlHeight2 = Theme.ControlHeight
		else
			controlHeight2 = controlHeight
		end

		local textWrapped = not flag and v5
		local buttonHover

		if flag or opened then
			buttonHover = Theme.ButtonHover
		else
			buttonHover = Theme.Button
		end

		local v13 = {
			ref = ref
		}
		local automaticSize

		if v9 then
			automaticSize = Enum.AutomaticSize.None
		else
			automaticSize = Enum.AutomaticSize.XY
		end

		v13.AutomaticSize = automaticSize
		v13.AutoButtonColor = false
		v13.BackgroundColor3 = buttonHover
		v13.BorderSizePixel = 0
		v13.LayoutOrder = 1
		local uDim

		if flag then
			uDim = UDim2.new(1, 0, 0, Theme.ControlHeight)
		elseif v8 then
			uDim = UDim2.fromOffset(v8, controlHeight2)
		else
			uDim = UDim2.fromOffset(0, Theme.ControlHeight)
		end

		v13.Size = uDim
		v13.Text = ""
		v13.ZIndex = zIndex
		v13[React.Event.Activated] = v6.Activate
		v13[React.Event.InputBegan] = v6.HeaderInputBegan

		v13[React.Event.MouseEnter] = function()
			Motion.to(ref and ref.current, Motion.Hover, {
				BackgroundColor3 = Theme.ButtonHover
			})
		end

		v13[React.Event.MouseLeave] = function()
			Motion.to(ref and ref.current, Motion.Hover, {
				BackgroundColor3 = buttonHover
			})
		end

		local uICorner

		if not flag then
			uICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0, Theme.CornerControl)
			})
		end

		local uIListLayout

		if not v9 then
			uIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			})
		end

		local uIPadding

		if not v9 then
			uIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 1),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 12),
				PaddingTop = UDim.new(0, 1)
			})
		end

		local automaticSize2

		if v9 then
			automaticSize2 = Enum.AutomaticSize.None
		else
			automaticSize2 = Enum.AutomaticSize.XY
		end

		local v21 = {
			AutomaticSize = automaticSize2,
			BackgroundTransparency = 1,
			Font = Theme.FontBold,
			LayoutOrder = not v9 and 1 or nil,
			Position = 0,
			RichText = false,
			Size = 0,
			Text = 0,
			TextColor3 = 0,
			TextSize = 0,
			TextStrokeTransparency = 1,
			TextTruncate = 0,
			TextWrapped = 0,
			TextXAlignment = 0,
			TextYAlignment = 0,
			ZIndex = 0
		}
		local position

		if v9 then
			position = UDim2.fromOffset(11, 0)
		end

		v21.Position = position
		local size

		if v9 then
			size = UDim2.new(1, -34, 1, 0)
		else
			size = UDim2.fromOffset(0, 0)
		end

		v21.Size = size
		v21.Text = props.Label
		v21.TextColor3 = Theme.Text
		v21.TextSize = Theme.ControlTextSize
		local textTruncate

		if textWrapped then
			textTruncate = Enum.TextTruncate.None
		else
			textTruncate = Enum.TextTruncate.AtEnd
		end

		v21.TextTruncate = textTruncate
		v21.TextWrapped = textWrapped
		v21.TextXAlignment = Enum.TextXAlignment.Left
		local textYAlignment

		if textWrapped then
			textYAlignment = Enum.TextYAlignment.Top
		else
			textYAlignment = Enum.TextYAlignment.Center
		end

		v21.TextYAlignment = textYAlignment
		v21.ZIndex = zIndex
		local v15 = {
			UICorner = uICorner,
			UIListLayout = uIListLayout,
			UIPadding = uIPadding,
			Label = createElement("TextLabel", v21),
			ChevronCell = 0,
			Chevron = 0
		}
		local chevronCell

		if not (v9 or opened) then
			chevronCell = createElement("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Size = UDim2.fromOffset(12, controlHeight2),
				ZIndex = zIndex
			}, {
				Inner = createElement(Controls.Chevron, {
					Color = Theme.TextMuted,
					Rotation = opened and 0 or -90,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					ZIndex = zIndex
				})
			})
		end

		v15.ChevronCell = chevronCell
		local chevron

		if v9 and (flag or not opened) then
			chevron = createElement(Controls.Chevron, {
				Color = Theme.TextMuted,
				Rotation = opened and 0 or -90,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -11, 0.5, 0),
				ZIndex = zIndex
			})
		end

		v15.Chevron = chevron
		return createElement("TextButton", v13, v15)
	end

	return createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromOffset(0, 0)
	}, {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Header = renderHeader(v6.AnchorRef, false),
		Body = createElement(Popout, {
			Open = opened,
			AnchorRef = v6.AnchorRef,
			WidthPx = Theme.TreePopoutWidth,
			HeightPx = Theme.TreePopoutHeight,
			InitialVisibleHeightPx = controlHeight,
			OffsetY = -controlHeight + 1,
			Resizable = true,
			MinWidthPx = Theme.TreePopoutMinWidth,
			MinHeightPx = Theme.TreePopoutMinHeight,
			ResizeHandleSize = Theme.TreeResizeHandleSize,
			OnOutsideInput = v6.Close,
			ZIndex = 165
		}, {
			Surface = createElement(Controls.PopoutScroller, {
				Header = renderHeader(nil, true),
				HeaderHeightPx = Theme.ControlHeight,
				Padding = true,
				ZIndex = 166
			}, {
				Content = createElement("Frame", {
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -16, 0, 0),
					ZIndex = 168
				}, {
					UIListLayout = createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						Padding = UDim.new(0, 4),
						SortOrder = Enum.SortOrder.LayoutOrder
					}),
					Body = props.RenderBody()
				})
			})
		})
	})
end

function Controls.Text(props)
	return createElement(LogText, {
		LayoutOrder = props.LayoutOrder,
		Text = props.Text,
		TextColor3 = props.TextColor3,
		TextSize = props.TextSize,
		TextOverflowMode = props.TextOverflowMode
	})
end

Controls.PrefixBadge = React.memo(Controls.PrefixBadge)
Controls.DropdownOption = React.memo(Controls.DropdownOption)
Controls.ActionButton = React.memo(Controls.ActionButton)
Controls.SettingsRow = React.memo(Controls.SettingsRow)
Controls.CheckRow = React.memo(Controls.CheckRow)
Controls.TooltipPopout = React.memo(Controls.TooltipPopout)
Controls.ColorSwatchButton = React.memo(Controls.ColorSwatchButton)
Controls.PopoutScroller = React.memo(Controls.PopoutScroller)
Controls.Chevron = React.memo(Controls.Chevron)
Controls.Button = React.memo(Controls.Button)
Controls.Checkbox = React.memo(Controls.Checkbox)
Controls.Combo = React.memo(Controls.Combo)
Controls.Tooltip = React.memo(Controls.Tooltip)
Controls.BubbleFrame = React.memo(Controls.BubbleFrame)
Controls.AlignedGrid = React.memo(Controls.AlignedGrid)
Controls.AlignedList = React.memo(Controls.AlignedList)
Controls.TableExplorer = React.memo(Controls.TableExplorer)
Controls.Tree = React.memo(Controls.Tree)
Controls.Text = React.memo(Controls.Text)
return Controls