local createVector = vector.create

local function ScaleParticle(particle, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, particle.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	particle.Speed = NumberRange.new(particle.Speed.Min * p, particle.Speed.Max * p)
	return NumberSequence.new(numberSequenceKeypoints)
end

local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local opeOpe = game.ReplicatedStorage["Ope-Ope"]
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera

local function MapRay(p, p2)
	return workspace:FindPartOnRayWithWhitelist(Ray.new(p, p2), { workspace.Map })
end

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = {}
RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.First.Value, function(p)
	local now = tick()
	local cFrame = currentCamera.CFrame

	for k, v2 in pairs(v) do
		if v2.Attachment and v2.Attachment.Parent then
			v2.Angle = v2.Angle % 6.283185307179586 + 3.141592653589793 * p
			local v3 = v2.Mouse.Value - cFrame.p
			local p2 = cFrame.p
			local v4 = v3 + v3.Unit
			local part, v5, v6 = workspace:FindPartOnRayWithWhitelist(Ray.new(p2, v4), { workspace.Map })
			CFrame.new()
			local v7

			if part then
				v7 = CFrame.new(v5, v5 + v6)
			else
				v7 = CFrame.new(v5, v2.Origin)
			end

			local lerped = v2.lastCF:lerp(v7, p * 12)
			v2.Part.CFrame = lerped * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(0, v2.Angle, 0)
			v2.lastCF = lerped

			if v2.ColorValue.Value and v2.ColorValue.Value ~= v2.Color then
				v2.PrevColor = v2.Color
				v2.Color = v2.ColorValue.Value
				v2.ColorUpdate = now
			elseif v2.PrevColor and v2.ColorUpdate then
				local _ = now - v2.ColorUpdate
				v2.Part.Color = v2.PrevColor:Lerp(v2.Color, 1)
				v2.Part.Particle.Color = ColorSequence.new(v2.Part.Color)
			end
		else
			v2.Part.Particle.Enabled = false
			local tween = TweenService:Create(v2.Part, tweenInfo2, {
				Size = Vector3.new(),
				Transparency = 1
			})
			local v3 = v2
			tween.Completed:Connect(function()
				wait(1)
				v3.Part:Destroy()
			end)
			tween:Play()
			v[k] = nil
		end
	end
end)
return function(list)
	local v2, attachment, v4, v5, origin, colorValue = unpack(list)
	local color = v5 or Color3.new(0, 1, 0)
	local v9 = v4 or 5

	if attachment and attachment.Parent then
		local clone = opeOpe.Effects.Indicator:Clone()
		clone.Transparency = 1
		clone.Color = color
		clone.Particle.Size = ScaleParticle(clone.Particle, v9 * 0.25)
		clone.Particle.Color = ColorSequence.new(color)
		clone.Size = Vector3.new()
		clone.CFrame = CFrame.new(v2.Mouse.Value) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = _WorldOrigin
		table.insert(v, {
			Color = color,
			ColorValue = colorValue,
			Origin = origin,
			lastCF = clone.CFrame,
			Mouse = v2.Mouse,
			Part = clone,
			Attachment = attachment,
			Angle = 0
		})
		TweenService:Create(clone, tweenInfo, {
			Size = createVector(1, 0.5, 1) * v9,
			Transparency = 0
		}):Play()
	end
end