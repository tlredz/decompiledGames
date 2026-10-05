local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local input = require(script.Parent:WaitForChild("input"))

function input.format.roblox(color: Color3, value: number?)
	return {
		color.R * 255,
		color.G * 255,
		color.B * 255,
		value or 1
	}
end

function chroma.roblox(...)
	local v = table.pack(...)
	v[v.n + 1] = "roblox"
	return Color.new(unpack(v, 1, v.n + 1))
end

function Color:roblox()
	local _rgb = self._rgb
	return Color3.fromRGB(_rgb[1], _rgb[2], _rgb[3])
end

table.insert(input.autodetect, {
	p = 56,
	test = function(...)
		local v = table.pack(...)

		if v.n == 1 and type(v[1]) == "userdata" and typeof(v[1]) == "Color3" then
			return "roblox"
		end

		return nil
	end
})
return nil