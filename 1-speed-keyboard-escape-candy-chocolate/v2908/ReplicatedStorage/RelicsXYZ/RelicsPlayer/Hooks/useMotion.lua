local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local React = require(shared.React)
local Ripple = require(shared.Ripple)
local v = {}
task.spawn(function()
	while true do
		local v2 = task.wait(0.016666666666666666)

		for k in v do
			k:step(v2)
		end
	end
end)

local function useMotion(p, _: number?)
	local v2 = React.useMemo(function()
		return Ripple.createMotion(p)
	end, {})
	local v3, v4 = React.useBinding(p)
	v2:onStep(v4)
	React.useEffect(function()
		v[v2] = true
		return function()
			v[v2] = nil
		end
	end, {})
	return v3, v2
end

return useMotion