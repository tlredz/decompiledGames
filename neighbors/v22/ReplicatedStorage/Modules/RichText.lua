local RichText = {}
local v = {
	red = Color3.fromRGB(255, 0, 0),
	green = Color3.fromRGB(0, 255, 0),
	blue = Color3.fromRGB(0, 0, 255),
	yellow = Color3.fromRGB(255, 255, 0),
	orange = Color3.fromRGB(255, 165, 0),
	purple = Color3.fromRGB(128, 0, 128),
	pink = Color3.fromRGB(255, 192, 203),
	cyan = Color3.fromRGB(0, 255, 255),
	magenta = Color3.fromRGB(255, 0, 255),
	brown = Color3.fromRGB(165, 42, 42),
	gray = Color3.fromRGB(128, 128, 128),
	lightgray = Color3.fromRGB(211, 211, 211),
	darkgray = Color3.fromRGB(169, 169, 169),
	lightblue = Color3.fromRGB(173, 216, 230),
	darkblue = Color3.fromRGB(0, 0, 139),
	lightgreen = Color3.fromRGB(144, 238, 144),
	darkgreen = Color3.fromRGB(0, 100, 0),
	gold = Color3.fromRGB(255, 215, 0),
	silver = Color3.fromRGB(192, 192, 192),
	teal = Color3.fromRGB(0, 128, 128),
	navy = Color3.fromRGB(0, 0, 128),
	maroon = Color3.fromRGB(128, 0, 0),
	olive = Color3.fromRGB(128, 128, 0)
}
local v2 = {
	["<"] = "&lt;",
	[">"] = "&gt;",
	["\""] = "&quot;",
	["'"] = "&apos;",
	["&"] = "&amp;"
}

function RichText:ToRichText(value: string)
	local v3 = value:gsub("%*%*(.-)%*%*", "<b>%1</b>"):gsub("%*(.-)%*", "<i>%1</i>"):gsub("_(.-)_", "<u>%1</u>"):gsub(
		"%-(.-)%-",
		"<s>%1</s>"
	)

	for k, v4 in next, v, nil do
		v3 = v3:gsub(`<{k}>(.-)</{k}>`, (`<font color="#{v4:ToHex()}">%1</font>`))
	end

	return v3
end

function RichText.FromRichText(_, value: string)
	local v3 = value:gsub("<b>(.-)</b>", "**%1**"):gsub("<i>(.-)</i>", "*%1*"):gsub("<u>(.-)</u>", "_%1_"):gsub(
		"<s>(.-)</s>",
		"-%1-"
	)

	for k, v4 in next, v, nil do
		v3 = v3:gsub(`<font color="{v4:ToHex()}">(.-)</font>`, (`<{k}>%1</{k}>`))
	end

	return v3
end

function RichText.GetTextContent(_, p: string)
	local richText = RichText:ToRichText(p)

	if not (richText:match("<") or richText:match(">")) then
		return richText
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.RichText = true
	textLabel.Text = richText
	task.defer(function()
		textLabel:Destroy()
	end)
	return textLabel.ContentText
end

function RichText.EscapeRichText(_, value: string)
	return string.gsub(value, ".", function(p)
		return v2[p] or p
	end) or ""
end

return RichText