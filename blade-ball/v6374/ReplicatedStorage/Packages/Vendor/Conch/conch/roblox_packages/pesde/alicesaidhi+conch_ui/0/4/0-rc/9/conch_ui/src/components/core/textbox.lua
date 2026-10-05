local module = require("../../util/component")
local module2 = require("../../theme")
local module3 = require("../../../roblox_packages/vide")
local create = module3.create
local source = module3.source
local read = module3.read
local changed = module3.changed
local action = module3.action
local effect = module3.effect

local function find_weight(p: number)
	for _, v in Enum.FontWeight:GetEnumItems() do
		if math.abs(p - v.Value) <= 50 then
			return v
		end
	end

	return Enum.FontWeight.Regular
end

return module(function(data, _)
	local v = source("")
	local v2 = create("TextBox")
	local v3 = {
		AutomaticSize = Enum.AutomaticSize.XY,
		AutoLocalize = false,
		BackgroundTransparency = 1,
		Text = data.text,
		TextColor3 = data.color or module2.text,
		PlaceholderColor3 = module2.select_color("subtext1"),
		TextTransparency = data.transparency,
		PlaceholderText = data.placeholder,
		TextSize = function()
			return (math.round((read(data.size or 16))))
		end
	}
	local splitWord

	if data.truncate == "split" then
		splitWord = Enum.TextTruncate.SplitWord
	elseif data.truncate == "end" then
		splitWord = Enum.TextTruncate.AtEnd
	else
		splitWord = Enum.TextTruncate.None
	end

	v3.TextTruncate = splitWord
	local left

	if data.xalign == "left" then
		left = Enum.TextXAlignment.Left
	elseif data.xalign == "center" then
		left = Enum.TextXAlignment.Center
	elseif data.xalign == "right" then
		left = Enum.TextXAlignment.Right
	end

	v3.TextXAlignment = left
	local top

	if data.yalign == "top" then
		top = Enum.TextYAlignment.Top
	elseif data.yalign == "center" then
		top = Enum.TextYAlignment.Center
	elseif data.yalign == "bottom" then
		top = Enum.TextYAlignment.Bottom
	end

	v3.TextYAlignment = top
	v3.TextWrapped = data.wraps

	function v3.FontFace()
		local v4 = read(data.font or module2.font)
		local family = v4.Family
		local v5 = find_weight(read(data.weight or 500))
		local v6

		if read(data.italic) then
			v6 = Enum.FontStyle.Italic
		else
			v6 = v4.Style
		end

		return Font.new(family, v5, v6)
	end

	local v4

	if data.update_text then
		v4 = changed("Text", data.update_text)
	end

	v3[1], v3[2] = v4, (changed("Text", v))
	v3.TextEditable = data.editable
	v3.RichText = data.rich
	v3.MultiLine = data.multiline

	function v3.Focused()
		if not data.update_focused then
			return
		end

		data.update_focused(true)
	end

	function v3.FocusLost(p)
		if data.update_focused then
			data.update_focused(false)
		end

		if not (p and data.focused) then
			return
		end

		data.enter(v())
	end

	local v5

	if data.stroke then
		v5 = create("UIStroke")({
			Color = data.stroke,
			Thickness = data.thickness or 1,
			Transparency = data.stroke_transparency
		})
	end

	do local _values = table.pack(v5, action(function(object)
	effect(function()
		local v6 = read(data.focused)

		if object:IsFocused() == v6 then
			return
		end

		task.delay(0, function()
			if v6 then
				object:CaptureFocus()
			else
				object:ReleaseFocus(false)
			end
		end)
	end)
end)); for _k = 1, _values.n do v3[2 + _k] = _values[_k] end end
	return v2(v3)
end)