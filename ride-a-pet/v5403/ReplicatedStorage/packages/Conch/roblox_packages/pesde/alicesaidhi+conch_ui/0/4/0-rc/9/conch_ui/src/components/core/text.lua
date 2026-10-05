local module = require("../../util/component")
local module2 = require("../../theme")
local module3 = require("../../../roblox_packages/vide")
local create = module3.create
local read = module3.read

local function find_weight(p: number)
	for _, v in Enum.FontWeight:GetEnumItems() do
		if math.abs(p - v.Value) <= 50 then
			return v
		end
	end

	return Enum.FontWeight.Regular
end

return module(function(data, _)
	local v = create("TextLabel")
	local v2 = {
		AutomaticSize = Enum.AutomaticSize.XY,
		AutoLocalize = false,
		BackgroundTransparency = 1,
		Text = data.text,
		TextColor3 = data.color or module2.text,
		TextTransparency = data.transparency,
		TextSize = function()
			return (math.round(read(data.size) or 24))
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

	v2.TextTruncate = splitWord
	local left

	if data.xalign == "left" then
		left = Enum.TextXAlignment.Left
	elseif data.xalign == "center" then
		left = Enum.TextXAlignment.Center
	elseif data.xalign == "right" then
		left = Enum.TextXAlignment.Right
	end

	v2.TextXAlignment = left
	local top

	if data.yalign == "top" then
		top = Enum.TextYAlignment.Top
	elseif data.yalign == "center" then
		top = Enum.TextYAlignment.Center
	elseif data.yalign == "bottom" then
		top = Enum.TextYAlignment.Bottom
	end

	v2.TextYAlignment = top
	v2.TextWrapped = data.wraps
	v2.RichText = data.rich

	function v2.FontFace()
		local v3 = read(data.font or module2.font)
		local family = v3.Family
		local v4 = find_weight(read(data.weight or 500))
		local v5

		if read(data.italic) then
			v5 = Enum.FontStyle.Italic
		else
			v5 = v3.Style
		end

		return Font.new(family, v4, v5)
	end

	local v3

	if data.stroke then
		v3 = create("UIStroke")({
			Color = data.stroke,
			Thickness = data.thickness or 1,
			Transparency = data.stroke_transparency
		})
	end

	v2[1] = v3
	return v(v2)
end)