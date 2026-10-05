local VisibilityHelpers = require(script.Parent.Parent.Parent.Modules.VisibilityHelpers)
return {
	GetTransparency = function(p, _)
		if p == nil then
			return nil
		end

		local holdTiming, v = VisibilityHelpers.GetHoldTiming(p, "transparent")
		return VisibilityHelpers.NormalizeTiming(holdTiming, v)
	end
}