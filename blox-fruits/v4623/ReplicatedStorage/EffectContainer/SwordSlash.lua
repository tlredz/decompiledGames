local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local models = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Tween
require(ReplicatedStorage:WaitForChild("Queue"))

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local v = {}
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("SwordSlash", 10050, function(p)
	for k, v2 in pairs(v) do
		v2.time += p

		if v2.time > v2.duration then
			v2.ring:Destroy()
			v[k] = nil
		else
			local v3 = v2.time / v2.duration

			if v2.lerpTransparency then
				local ring = v2.ring
				local transparency = v2.transparency
				ring.Transparency = transparency + (1 - transparency) * v3
			end

			v2.ring.CFrame = v2.cframe:Lerp(v2.endCFrame, v3)
		end
	end
end)
return function(instance)
	if instance.LerpTransparency == nil then
		instance.LerpTransparency = true
	end

	local size = instance.Size or createVector(12, 12, 12)
	local transparency = instance.Transparency or 0
	local cFrame = instance.CFrame or CFrame.new()
	local endCFrame = instance.EndCFrame or cFrame * CFrame.new(0, 0, -3.5)
	local color = instance.Color or Color3.new(1, 1, 1)
	local duration = instance.Duration or 0.13
	local v2 = cFrame * CFrame.Angles(0, 1.5707963267948966, 0)
	local endCFrame2 = endCFrame * CFrame.Angles(0, 1.5707963267948966, 0)

	if Util.RenderDistance.value(v2.p) > 100 + size.x * 5 then
		return
	end

	local clone = models.SwordSlash:Clone()
	clone.Mesh.VertexColor = Vector3.new(color.r, color.g, color.b) * 3
	clone.Transparency = transparency
	clone.Mesh.Scale = size / 1500
	clone.CFrame = v2
	clone.Parent = _WorldOrigin
	table.insert(v, {
		time = 0,
		ring = clone,
		cframe = v2,
		endCFrame = endCFrame2,
		transparency = transparency,
		duration = duration,
		lerpTransparency = instance.LerpTransparency
	})
end