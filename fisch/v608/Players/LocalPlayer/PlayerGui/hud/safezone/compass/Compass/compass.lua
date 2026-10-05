local Players = game:GetService("Players")
game:GetService("Workspace")
local RunService = game:GetService("RunService")
local _ = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local parent = script.Parent
local v = 0
local v2 = {
	[parent.N] = -3.141592653589793,
	[parent.E] = -1.5707963267948966,
	[parent.S] = 0,
	[parent.W] = 1.5707963267948966,
	[parent.NE] = -2.356194490192345,
	[parent.NW] = 2.356194490192345,
	[parent.SE] = -0.7853981633974483,
	[parent.SW] = 0.7853981633974483
}

local function restrictAngle(p: number)
	if p < -3.141592653589793 then
		return p + 6.283185307179586
	end

	if p > 3.141592653589793 then
		return p - 6.283185307179586
	end

	return p
end

RunService.PreRender:Connect(function(dt)
	local v3 = math.min(dt, 0.03333333333333333)
	local lookVector = currentCamera.CFrame.LookVector
	local v4 = -math.atan2(lookVector.z, lookVector.x) - v

	if v4 < -3.141592653589793 then
		v4 += 6.283185307179586
	elseif v4 > 3.141592653589793 then
		v4 -= 6.283185307179586
	end

	local v5 = v + v4 * v3 * 30

	if v5 < -3.141592653589793 then
		v5 += 6.283185307179586
	elseif v5 > 3.141592653589793 then
		v5 -= 6.283185307179586
	end

	v = v5

	for k, v6 in v2 do
		local v7 = v5 - v6

		if v7 < -3.141592653589793 then
			v7 += 6.283185307179586
		elseif v7 > 3.141592653589793 then
			v7 -= 6.283185307179586
		end

		if math.sin(v7) > 0 then
			k.Visible = false
		else
			local v8 = math.cos(v7)
			k.Position = UDim2.new(v8 * 0.6 + 0.5, k.Position.X.Offset, 0, 3)
			k.Visible = true
		end
	end
end)