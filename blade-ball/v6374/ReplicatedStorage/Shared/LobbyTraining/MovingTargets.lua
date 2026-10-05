game:GetService("ReplicatedStorage")
game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function easeInOutSine(p: number)
	return -(math.cos(3.141592653589793 * p) - 1) * 0.5
end

local function calculateTime(instance)
	local type = instance:GetAttribute("Type")
	local defaultPivot = instance:GetAttribute("DefaultPivot")

	if not defaultPivot then
		defaultPivot = instance:GetPivot()
		instance:SetAttribute("DefaultPivot", defaultPivot)
	end

	if type == "Spin" then
		local time = instance:GetAttribute("Time") or 5
		return function()
			return defaultPivot * CFrame.Angles(0, 0, 6.283185307179586 * (workspace:GetServerTimeNow() % time / time))
		end
	end

	if type ~= "Move" then
		error((`"{type}" MoveType is Unsupported`))
		return
	end

	local offset = instance:GetAttribute("Offset")
	local timeOffset = instance:GetAttribute("TimeOffset") or 0
	local time = instance:GetAttribute("Time") or 5
	return function()
		local v = (workspace:GetServerTimeNow() + timeOffset) % time / time - 1

		if v > 0.5 then
			v = 1 - v
		end

		local v2 = v * 2
		return defaultPivot * offset.Rotation * CFrame.new(offset.Position * easeInOutSine(v2))
	end
end

return calculateTime