local FollowerLoop = require(script.FollowerLoop)
local SurfaceTracker = require(script.SurfaceTracker)
return {
	AttachToModel = function(p, instance, options)
		FollowerLoop.Drop(p)
		local v = options or {}

		if v.MaxActivationDistance ~= nil then
			p.MaxActivationDistance = v.MaxActivationDistance
		end

		local anchor = FollowerLoop.MakeAnchor(v.PartName, instance:GetPivot())
		local v2 = SurfaceTracker.new(instance, anchor)
		p.RequiresLineOfSight = false
		return FollowerLoop.Add(p, instance, anchor, v2, v)
	end
}