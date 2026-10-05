local Color = require(script.Parent.Parent:WaitForChild("Color"))

function Color:premultiply(flag: boolean?)
	local _rgb = self._rgb
	local v = _rgb[4]

	if not flag then
		return Color.new({
			_rgb[1] * v,
			_rgb[2] * v,
			_rgb[3] * v,
			v
		}, "rgb")
	end

	self._rgb = {
		_rgb[1] * v,
		_rgb[2] * v,
		_rgb[3] * v,
		v
	}
	return self
end

return nil