local module = require("../../../roblox_packages/vide")
local create = module.create
local read = module.read
return function(data)
	local p = data.p or 0
	local x = data.x or p
	local y = data.y or p
	local l = data.l or x
	local t = data.t or y
	local b = data.b or y
	local r = data.r or x
	local ps = data.ps or 0
	local xs = data.xs or ps
	local ys = data.ys or ps
	local ls = data.ls or xs
	local ts = data.ts or ys
	local bs = data.bs or ys
	local rs = data.rs or xs
	return create("UIPadding")({
		PaddingLeft = function()
			return UDim.new(read(ls), read(l))
		end,
		PaddingRight = function()
			return UDim.new(read(rs), read(r))
		end,
		PaddingTop = function()
			return UDim.new(read(ts), read(t))
		end,
		PaddingBottom = function()
			return UDim.new(read(bs), read(b))
		end
	})
end