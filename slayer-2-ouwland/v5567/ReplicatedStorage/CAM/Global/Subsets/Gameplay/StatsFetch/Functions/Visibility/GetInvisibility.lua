local VisibilityHelpers = require(script.Parent.Parent.Parent.Modules.VisibilityHelpers)
return {
	GetInvisibility = function(p, _)
		if p == nil then
			return nil
		end

		local holdTiming, v = VisibilityHelpers.GetHoldTiming(p, "invisibility")
		return VisibilityHelpers.NormalizeTiming(holdTiming, v)
	end
}