local Color = require(script.Parent.Parent:WaitForChild("Color"))

function Color:clipped()
	return self._rgb._clipped == true
end

return nil