local Color = require(script.Parent.Parent:WaitForChild("Color"))

function Color:alpha(value: number?, flag: boolean?)
	if type(value) ~= "number" then
		return self._rgb[4]
	end

	if not flag then
		return Color.new({
			self._rgb[1],
			self._rgb[2],
			self._rgb[3],
			value
		}, "rgb")
	end

	self._rgb[4] = value
	return self
end

return nil