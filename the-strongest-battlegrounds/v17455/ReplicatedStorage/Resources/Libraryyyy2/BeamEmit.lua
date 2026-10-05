local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
return function(instance, data, p)
	local clone = instance:Clone()
	clone.Parent = workspace:FindFirstChild("Ignore") or workspace.Thrown
	local v = p or clone.CFrame

	for _, beam in clone:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		local v2 = {
			Width0 = beam.Width0,
			Width1 = beam.Width1,
			TextureSpeed = beam.TextureSpeed,
			Brightness = beam.Brightness,
			LightEmission = beam.LightEmission
		}
		local tween = TweenService:Create(
			beam,
			TweenInfo.new(data.Duration, Enum.EasingStyle[data.Easing], Enum.EasingDirection[data.EasingDirection]),
			data.Properties
		)
		tween:Play()
		local v3 = beam
		tween.Completed:Once(function()
			v3.Enabled = false

			for k, v5 in v2 do
				v3[k] = v5
			end
		end)
	end

	TweenService:Create(
		clone,
		TweenInfo.new(data.Duration, Enum.EasingStyle[data.Easing], Enum.EasingDirection[data.EasingDirection]),
		{
			Position = (v * data.Offset).Position
		}
	):Play()
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		clone.CFrame *= CFrame.Angles(0, 0, (math.rad(data.RotationSpeed)))
		total += dt

		if total > 5 and heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
	end)
	Debris:AddItem(clone, 5)
	return clone
end