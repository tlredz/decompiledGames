local React = require(game.ReplicatedStorage.Packages.React)
local createElement = React.createElement
return React.forwardRef(function(p, p2)
	local ref = React.useRef(nil)
	React.useEffect(function()
		local current = p2 and p2.current or ref.current

		if current then
			current:SetControlPoints(p.ControlPoints)
		end
	end, { p2 and p2.current or ref.current, p.ControlPoints })
	local clone = table.clone(p)
	clone.ControlPoints = nil
	clone.ref = p2 or ref
	return createElement("Path2D", clone)
end)