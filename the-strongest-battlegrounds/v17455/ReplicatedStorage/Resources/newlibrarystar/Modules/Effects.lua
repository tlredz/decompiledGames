local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Effects = {}

function Effects.distortion(data)
	local meshInstance = data.MeshInstance

	if not meshInstance then
		meshInstance = script:FindFirstChild("DistortionMesh")

		if not (meshInstance and meshInstance:IsA("BasePart")) then
			warn("effects.distortion: provide MeshInstance or add 'DistortionMesh' under Modules/Effects")
			return
		end
	end

	local clone = meshInstance:Clone()
	clone.CFrame = data.Position
	clone.Parent = workspace:FindFirstChild("Thrown") or workspace
	clone.Transparency = data.StartDistortion
	clone.Size = Vector3.new(data.StartRadius, data.StartRadius, data.StartRadius)
	TweenService:Create(clone, TweenInfo.new(data.Duration, data.EasingStyle, data.EasingDirection), {
		Size = Vector3.new(data.EndRadius, data.EndRadius, data.EndRadius),
		Transparency = data.EndDistortion
	}):Play()
	Debris:AddItem(clone, data.Duration)
end

function Effects.tweenBeamRig(instance, data, cframe: CFrame?)
	local clone = instance:Clone()
	clone.Parent = workspace:FindFirstChild("Thrown") or workspace
	local v = cframe or clone.CFrame or CFrame.new()

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
			data.Properties or {}
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
			Position = (v * (data.Offset or CFrame.new())).Position
		}
	):Play()
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if clone.CFrame then
			clone.CFrame *= CFrame.Angles(0, 0, (math.rad(data.RotationSpeed or 0)))
		end

		total += dt

		if total > (data.CleanAfter or 5) and heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
	end)
	Debris:AddItem(clone, data.CleanAfter or 5)
	return clone
end

function Effects.tweenBeams(folder, p, p2)
	for _, beam in folder:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Enabled = true
		TweenService:Create(beam, p, p2):Play()
	end
end

return Effects