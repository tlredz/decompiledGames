local Color = require(script.Parent.Parent:WaitForChild("Color"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local css2rgb = require(script:WaitForChild("css2rgb"))
local input = require(script.Parent:WaitForChild("input"))
local rgb2css = require(script:WaitForChild("rgb2css"))

function Color:css(p2: string?)
	return rgb2css(self._rgb, p2)
end

function chroma.css(...)
	local v = table.pack(...)
	v[v.n + 1] = "css"
	return Color.new(unpack(v, 1, v.n + 1))
end

input.format.css = css2rgb.css2rgb
table.insert(input.autodetect, {
	p = 59,
	test = function(value, ...)
		if select("#", ...) == 0 and type(value) == "string" and css2rgb.test(value) then
			return "css"
		end

		return nil
	end
})
return nil