local Formatter = require(script.Parent.Formatter)
local TextMetrics = require(script.Parent.TextMetrics)
local Theme = require(script.Parent.Theme)
local LayoutMetrics = {
	RowGapPx = 5,
	RowVerticalGapPx = 4,
	LinePadXPx = 8,
	LinePadYPx = 3,
	ButtonPadXPx = 22,
	CheckboxExtraWidthPx = 43,
	ComboExtraWidthPx = 42,
	TableExtraWidthPx = 42,
	TooltipWidthPx = 20,
	PrefixBadgePadXPx = 2,
	DefaultStructuredWidthPx = 520
}

local function fontKey(p)
	return p.Name
end

local v = {}
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function longestWordCacheKey(p: string, p2: number, p3)
	return (`{p3.Name}|{p2}|{p}`)
end

local function tableEntryCount(items)
	local count2 = 0

	for _ in items do
		count2 += 1
	end

	return count2
end

function LayoutMetrics.tableSummary(items)
	local count2 = 0

	for _ in items do
		count2 += 1
	end

	return (`Table ({count2})`)
end

function LayoutMetrics.textWidth(p: string, p2: number, p3)
	return (math.ceil(TextMetrics.measureRich(p, p2, p3).X))
end

function LayoutMetrics.plainTextWidth(p: string, p2: number, p3)
	return (math.ceil(TextMetrics.measurePlain(p, p2, p3).X))
end

function LayoutMetrics.longestWordWidth(p: string, p2: number, p3)
	local v2 = longestWordCacheKey(p, p2, p3) -- equivalent call inferred; original call site unknown
	local v3 = v[v2]

	if v3 then
		return v3
	end

	local stripRichText = TextMetrics.stripRichText(p)
	local selected = 0

	for k in string.gmatch(stripRichText, "%S+") do
		selected = math.max(selected, LayoutMetrics.plainTextWidth(k, p2, p3))
	end

	if selected <= 0 then
		selected = LayoutMetrics.plainTextWidth(stripRichText, p2, p3)
	end

	if count >= 1000 then
		table.clear(v)
		count = 0
	end

	v[v2] = selected
	count += 1
	return selected
end

function LayoutMetrics.wrappedTextHeight(p: string, p2: number, p3, p4: number)
	local rich = TextMetrics.measureRich(p, p2, p3, (math.max(1, p4)))
	return (math.max(p2 + 2, (math.ceil(rich.Y))))
end

function LayoutMetrics.controlTextHeight(p: string, p2, p3: number)
	return (math.max(Theme.ControlHeight, LayoutMetrics.wrappedTextHeight(p, Theme.ControlTextSize, p2, p3) + 4))
end

function LayoutMetrics.scaledWidth(value: number?, p: number?)
	local v2 = typeof(value) ~= "number" and 1 or math.clamp(value, 0.05, 1)
	local v3 = p or LayoutMetrics.DefaultStructuredWidthPx
	return (math.max(Theme.ControlHeight, (math.floor(v3 * v2 - Theme.AlignedGroupInset + 0.5))))
end

function LayoutMetrics.expandedScaledWidth(p: number?, p2: number?, value: number?)
	local scaledWidth = LayoutMetrics.scaledWidth(p, p2)
	local v2 = typeof(value) ~= "number" and 0 or math.ceil(value)
	return LayoutMetrics.constrainWidth(math.max(scaledWidth, v2), p2)
end

function LayoutMetrics.fullWidth(p: number?)
	return (math.max(Theme.ControlHeight, (math.floor((p or LayoutMetrics.DefaultStructuredWidthPx) + 0.5))))
end

function LayoutMetrics.constrainWidth(p: number, p2: number?)
	if p2 and not (p2 <= 0) then
		return (math.max(1, (math.min(math.ceil(p), (math.floor(p2))))))
	end

	return (math.max(1, (math.ceil(p))))
end

function LayoutMetrics.comboLargestLabelWidth(list, p, p2: string)
	local textWidth = LayoutMetrics.textWidth(Formatter.toText(list[4], p) or p2, Theme.ControlTextSize, Theme.FontBold)
	local v2 = list[5]

	if list[3] == "</combochild>" and typeof(v2) == "Instance" then
		for _, child in v2:GetChildren() do
			textWidth = math.max(textWidth, LayoutMetrics.textWidth(child.Name, Theme.ControlTextSize, Theme.FontBold))
		end
	elseif typeof(v2) == "table" then
		for _, item in v2 do
			local v3 = Formatter.toText(item, p) or tostring(item)
			textWidth = math.max(textWidth, LayoutMetrics.textWidth(v3, Theme.ControlTextSize, Theme.FontBold))
		end
	end

	return textWidth
end

function LayoutMetrics.controlPartWidth(list, p)
	local v2 = list[3]

	if v2 == "</btn>" then
		return LayoutMetrics.textWidth(Formatter.toText(list[4], p) or "Button", Theme.ControlTextSize, Theme.FontBold) + LayoutMetrics.ButtonPadXPx
	elseif v2 == "</chk>" then
		return LayoutMetrics.textWidth(
			Formatter.toText(list[4], p) or "Checkbox",
			Theme.ControlTextSize,
			Theme.FontBold
		) + LayoutMetrics.CheckboxExtraWidthPx
	elseif v2 == "</cmbo>" then
		return LayoutMetrics.comboLargestLabelWidth(list, p, "Select") + LayoutMetrics.ComboExtraWidthPx
	elseif v2 == "</combochild>" then
		return LayoutMetrics.comboLargestLabelWidth(list, p, "Select") + LayoutMetrics.ComboExtraWidthPx
	elseif v2 == "</tree>" then
		return LayoutMetrics.textWidth(Formatter.toText(list[1], p) or "Tree", Theme.ControlTextSize, Theme.FontBold) + 42
	end

	return LayoutMetrics.textWidth(LayoutMetrics.tableSummary(list), Theme.ControlTextSize, Theme.FontBold) + LayoutMetrics.TableExtraWidthPx
end

return LayoutMetrics