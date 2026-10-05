local module = require("../theme")
local module2 = require("../../roblox_packages/vide")
local create = module2.create
local read = module2.read
return function(list)
	local v = create("TextLabel")
	local v2 = {
		Size = function()
			return UDim2.fromOffset(read(list.width) or 0, read(list.height) or 0)
		end
	}
	local Y

	if not (list.width and list.height) then
		if list.width then
			Y = Enum.AutomaticSize.Y
		else
			Y = Enum.AutomaticSize.X
		end
	end

	v2.AutomaticSize = Y
	v2.Text = list.text
	v2.TextSize = list.text_size

	function v2.TextColor3()
		local text_style = list.text_style

		if read(text_style) == "normal" then
			return (module.text())
		end

		if read(text_style) == "warn" then
			return (module.text_warn())
		end

		if read(text_style) == "error" then
			return (module.text_error())
		end

		if read(text_style) == "info" then
			return (module.text_info())
		end

		return (module.text())
	end

	function v2.FontFace()
		local font = module.font()
		local v3 = read(list.weight) or Enum.FontWeight.Regular
		return Font.new(font.Family, v3)
	end

	v2.TextWrapped = list.wrapped
	v2.TextXAlignment = list.xalignment
	v2.LayoutOrder = list.order
	v2.BackgroundTransparency = 1
	do local _values = table.pack(unpack(list)); for _k = 1, _values.n do v2[_k] = _values[_k] end end
	return v(v2)
end