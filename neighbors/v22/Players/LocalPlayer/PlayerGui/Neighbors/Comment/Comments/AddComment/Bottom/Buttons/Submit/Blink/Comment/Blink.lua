local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sin2(p: number)
	return (math.sin(p) + 1) / 2
end

local RunService = game:GetService("RunService")
RunService.Heartbeat:connect(function(_: number)
	if script.Parent.Visible then
		script.Parent.Transparency = sin2(6 * os.clock()) * -0.19999999999999996 + 1
	end
end)