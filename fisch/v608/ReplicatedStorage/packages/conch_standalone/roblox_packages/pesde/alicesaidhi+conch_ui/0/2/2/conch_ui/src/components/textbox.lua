local module = require("../theme")
local module2 = require("../../roblox_packages/vide")
local create = module2.create
local source = module2.source
local effect = module2.effect
local changed = module2.changed
local read = module2.read
return function(list)
	local v = source("")
	local v2 = create("TextBox")
	local v3 = {
		Size = function()
			return UDim2.fromOffset(read(list.width) or 0, read(list.height) or 0)
		end,
		AutomaticSize = Enum.AutomaticSize.XY,
		Text = list.text,
		PlaceholderText = list.placeholder,
		TextSize = list.text_size or 16,
		TextColor3 = module.text,
		TextXAlignment = list.xalignment,
		MultiLine = list.multiline,
		FontFace = module.font,
		BackgroundTransparency = 1
	}
	local v4

	if list.update_text then
		v4 = changed("Text", list.update_text)
	end

	v3[1], v3[2] = v4, (changed("Text", v))

	function v3.Focused()
		if not list.update_focused then
			return
		end

		list.update_focused(true)
	end

	function v3.FocusLost(p)
		if list.update_focused then
			list.update_focused(false)
		end

		if not (p and list.focused) then
			return
		end

		list.enter(v())
	end

	do local _values = table.pack(create("ImageButton")({
	Size = UDim2.new(0.1, 4, 1, 4),
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.fromScale(1, 0.5),
	BackgroundTransparency = 1,
	Image = "rbxassetid://95456233777548",
	create("UIAspectRatioConstraint")({
		AspectRatio = 1
	}),
	Activated = function()
		if not list.focused then
			return
		end

		list.enter(v())
	end
}), unpack(list)); for _k = 1, _values.n do v3[2 + _k] = _values[_k] end end
	local v5 = v2(v3)
	effect(function()
		local v6 = read(list.focused)

		if v5:IsFocused() == v6 then
			return
		end

		task.defer(function()
			if v6 then
				v5:CaptureFocus()
			else
				v5:ReleaseFocus(false)
			end
		end)
	end)
	return v5
end