local module = require("../theme")
local module2 = require("../../roblox_packages/vide")
local create = module2.create
local source = module2.source
local cleanup = module2.cleanup
local read = module2.read
local v = {
	"-",
	"/",
	"|",
	"\\"
}
return function(list)
	local v2 = source(0)
	local thread = task.spawn(function()
		while true do
			v2(v2() + task.wait())
		end
	end)
	cleanup(function()
		task.cancel(thread)
	end)
	local v3 = create("TextLabel")
	local v4 = {
		Size = function()
			local v5 = read(list.width)
			local v6 = read(list.height)
			return UDim2.new(0, v5 or 0, 0, v6 or 0)
		end,
		Position = function()
			return UDim2.new(read(list.xs) or 0, read(list.x) or 0, read(list.ys) or 0, read(list.y) or 0)
		end,
		AnchorPoint = list.anchor and function()
			return Vector2.new(read(list.anchor)[1] or 0, read(list.anchor)[2] or 0)
		end or nil,
		AutomaticSize = list.auto,
		LayoutOrder = list.layout,
		BackgroundTransparency = 1,
		Text = function()
			return (`{v[v2() * list.speed // 1 % 4 + 1]} - {v2() * 100 // 1 / 100}\ts`)
		end,
		TextSize = list.text_size,
		TextColor3 = list.color or function()
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
		end,
		FontFace = function()
			local font = module.font()
			local v5 = read(list.weight) or Enum.FontWeight.Regular
			return Font.new(font.Family, v5)
		end,
		TextWrapped = list.wrapped,
		TextXAlignment = list.xalignment
	}
	v4.BackgroundTransparency = 1
	do local _values = table.pack(unpack(list)); for _k = 1, _values.n do v4[_k] = _values[_k] end end
	return v3(v4)
end