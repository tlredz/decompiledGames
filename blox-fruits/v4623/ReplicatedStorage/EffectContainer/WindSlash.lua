function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FPSTracker = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("FPSTracker"))
local RenderDistance = require(ReplicatedStorage:WaitForChild("Util"):WaitForChild("RenderDistance"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local windSlashThin = FX:WaitForChild("WindSlashThin")
local v = {}
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("WindSlash", Enum.RenderPriority.Last.Value + 1001, function(p)
	for k, v2 in pairs(v) do
		local v3 = (tick() - v2.Start) / v2.Lifetime

		if v3 > 1 then
			v2.Wind:Destroy()
			v2.Attachment0:Destroy()
			v2.Attachment1:Destroy()
			v[k] = nil
		elseif v2.RenderDistance:WithinRange(p) then
			local attachment0 = v2.Attachment0
			local attachment1 = v2.Attachment1
			local wind = v2.Wind
			local width = lerpNumber(v2.Size[1], v2.Size[2], v3)
			attachment0.CFrame = v2.Origin * CFrame.new(0, 0, -v2.Speed * v3 - width / 6)
			attachment1.CFrame = attachment0.CFrame * CFrame.new(0, 0, width)
			wind.Width0 = width
			wind.Width1 = width
			wind.Color = ColorSequence.new(v2.Color[1]:lerp(v2.Color[2], v3))
			wind.Transparency = NumberSequence.new(lerpNumber(v2.Transparency[1], v2.Transparency[2], v3))
		end
	end
end)
return function(data)
	local renderRequirements = data.RenderRequirements
	local v2 = not renderRequirements and 30 or renderRequirements.FPS or 30
	local v3 = not renderRequirements and 60 or renderRequirements.DistanceMin or 60
	local v4 = not renderRequirements and 75 or renderRequirements.DistanceMax or 75
	local multiplier = renderRequirements and renderRequirements.Multiplier
	local origin = data.Origin
	local offset = data.Offset
	local color = data.Color
	local size = data.Size
	local transparency = data.Transparency
	local lifetime = data.Lifetime
	local speed = data.Speed or data.Size[1]

	if v2 < FPSTracker.FPS and RenderDistance.value(origin.p) < v3 then
		local clone = windSlashThin:Clone()
		local attachment = Instance.new("Attachment")
		local clone2 = attachment:Clone()
		attachment.CFrame = origin * offset * CFrame.Angles(0, 0, -1.5707963267948966) * CFrame.new(0, 0, -size[1] / 6)
		clone2.CFrame = attachment.CFrame * CFrame.new(0, 0, size[1])
		clone.Width0 = size[1]
		clone.Width1 = size[1]
		clone.Color = ColorSequence.new(color[1])
		clone.Transparency = NumberSequence.new(transparency[1])
		clone.Attachment0 = attachment
		clone.Attachment1 = clone2
		attachment.Parent = workspace.Terrain
		clone2.Parent = workspace.Terrain
		clone.Parent = workspace._WorldOrigin
		table.insert(v, {
			RenderDistance = RenderDistance.new(origin.p, v3, v4, multiplier),
			Origin = attachment.CFrame,
			Attachment0 = attachment,
			Attachment1 = clone2,
			Wind = clone,
			Size = size,
			Color = color,
			Transparency = transparency,
			Speed = speed,
			Lifetime = lifetime,
			Start = tick()
		})
	end
end