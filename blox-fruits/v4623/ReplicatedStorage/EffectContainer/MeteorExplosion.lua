local createVector = vector.create

local function ScaleParticle(cloudSmall, scale)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, cloudSmall.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * scale, keypoint.Envelope)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local debris = Util.Debris
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local assets = ReplicatedStorage:WaitForChild("Assets")
local meshes = assets:WaitForChild("Meshes")
assets:WaitForChild("Particles")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
return function(data)
	local smokeColor = data.SmokeColor or Color3.new(0.25, 0.25, 0.25)
	local origin = data.Origin or CFrame.new()
	local scale = data.Scale or 1
	local lifetime = data.Lifetime or 2.5

	if (origin.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	local clone = meshes.CrownExplosion:Clone()
	clone.Mesh.Scale = Vector3.new()
	clone.CFrame = origin
	clone.Parent = _WorldOrigin
	local tweenInfo = TweenInfo.new(lifetime * 0.166, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
	local tween = TweenService:Create(clone, tweenInfo, {
		CFrame = origin * CFrame.new(0, 8 * scale, 0)
	})
	local tween2 = TweenService:Create(clone.Mesh, tweenInfo, {
		Scale = createVector(3.5, 4, 3.5) * scale,
		VertexColor = createVector(3, 3, 3)
	})
	tween.Completed:Connect(function()
		local tweenInfo2 = TweenInfo.new(lifetime * 0.583, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween3 = TweenService:Create(clone, tweenInfo2, {
			CFrame = origin * CFrame.new(0, 7 * scale, 0),
			Transparency = 1
		})
		local tween4 = TweenService:Create(clone.Mesh, tweenInfo2, {
			Scale = createVector(0.25, 3, 0.25) * scale
		})
		tween3.Completed:Connect(function()
			clone:Destroy()
		end)
		tween3:Play()
		tween4:Play()
	end)
	tween:Play()
	tween2:Play()
	spawn(function()
		wait(tweenInfo.Time * 0.25)

		for i = 1, 6 do
			local v2 = origin * CFrame.Angles(0, 6.283185307179586 * ((i - 1) / 6), 0) * CFrame.new(
				0,
				1.25 * scale + math.random() * scale,
				-0.75 * scale
			)
			local clone2 = FX:WaitForChild("SmokeTrail"):Clone()
			clone2.Center.CloudSmall.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(225, 115, 0)),
				ColorSequenceKeypoint.new(0.25, Color3.fromRGB(225, 115, 0)),
				ColorSequenceKeypoint.new(0.3, smokeColor),
				ColorSequenceKeypoint.new(1, smokeColor)
			})
			clone2.Center.CloudSmall.Size = ScaleParticle(clone2.Center.CloudSmall, scale)
			clone2.CFrame = origin
			clone2.Velocity = (v2.p - origin.p).Unit * math.random(75, 125) * (scale > 1 and scale * 0.5 or scale)
			clone2.Parent = _WorldOrigin
			debris:AddItem(clone2, 3)
		end
	end)
	local clones = {}

	for i = 1, 4 do
		local _ = 6.283185307179586 * ((i - 1) / 4)
		local clone2 = meshes[("Smoke%d"):format(math.random(999) % 2 == 0 and 0 or 1)]:Clone()
		clone2.Color = smokeColor
		clone2.CFrame = origin
		clone2.Mesh.Scale = Vector3.new()
		clone2.Parent = _WorldOrigin
		clones[i] = clone2
	end

	local tweenInfo2 = TweenInfo.new(lifetime * 0.083, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	for k, v in next, clones, nil do
		local v2 = 6.283185307179586 * ((k - 1) / 4)
		local tween3 = TweenService:Create(v, tweenInfo2, {
			CFrame = origin * CFrame.Angles(0, v2, 0) * CFrame.new(0, 1.75 * scale, -1.5 * scale) * CFrame.Angles(
				-0.5235987755982988,
				0,
				0
			)
		})
		local mesh = v.Mesh
		local v6

		if scale > 1 then
			v6 = scale * 0.75 or scale
		else
			v6 = scale
		end

		local v7 = TweenService:Create(mesh, tweenInfo2, {
			Scale = createVector(0.075, 0.18, 0.075) * v6
		})
		tween3:Play()
		v7:Play()
	end

	wait(tweenInfo2.Time * 0.25)
	Effect.new("Slash"):replicate({
		CFrame = origin,
		Color = Color3.new(1, 1, 1),
		Width = { 2 * scale, 2 * scale },
		Radius = { 0, 25 * scale },
		Transparency = { 0.25, 1 },
		Duration = { lifetime * 0.5, lifetime * 1.1 }
	})
	spawn(function()
		local clones2 = {}

		for i = 1, 6 do
			local _ = 6.283185307179586 * ((i - 1) / 6)
			local clone2 = meshes[("Smoke%d"):format(math.random(999) % 2 == 0 and 0 or 1)]:Clone()
			clone2.Color = smokeColor
			clone2.Mesh.Scale = Vector3.new()
			clone2.CFrame = origin
			clone2.Parent = _WorldOrigin
			clones2[i] = clone2
		end

		local tweenInfo3 = TweenInfo.new(lifetime * 0.083, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		for k, v in next, clones2, nil do
			local v2 = 6.283185307179586 * ((k - 1) / 6)
			local tween3 = TweenService:Create(v, tweenInfo3, {
				CFrame = origin * CFrame.Angles(0, v2, 0) * CFrame.new(
					0,
					2 * scale + 2 * (k / 6) * (k % 2 == 0 and 1 or -1) * scale,
					-1.5 * scale + math.random() * scale
				)
			})
			local tween4 = TweenService:Create(v.Mesh, tweenInfo3, {
				Scale = createVector(1, 1, 1) * math.min(0.1, math.random()) * (scale > 1 and scale * 0.75 or scale)
			})
			tween3:Play()
			tween4:Play()
		end

		wait(tweenInfo3.Time)
		Effect.new("Slash"):replicate({
			CFrame = origin * CFrame.new(0, 6.5 * scale, 0),
			Color = Color3.new(1, 1, 1),
			Width = { 1 * scale, 1.75 * scale },
			Radius = { 0, 12 * scale },
			Transparency = { 0.25, 1 },
			Duration = { lifetime * 0.5, lifetime * 0.5 },
			Direction = -1
		})
		local tweenInfo4 = TweenInfo.new(lifetime * 0.416, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		for k, v in next, clones2, nil do
			local v2 = 6.283185307179586 * ((k - 1) / 6)
			local tween3 = TweenService:Create(v, tweenInfo4, {
				CFrame = origin * CFrame.Angles(0, v2 + 0.39269908169872414, 0) * CFrame.new(
					0,
					3 * scale + 2.5 * (k / 6) * (k % 2 == 0 and 1 or -1) * scale,
					-3 * scale + math.random() * scale
				)
			})
			local tween4 = TweenService:Create(v.Mesh, tweenInfo4, {
				Scale = v.Mesh.Scale * 1.5 * (scale > 1 and scale * 0.75 or scale)
			})
			tween3:Play()
			tween4:Play()
		end

		wait(tweenInfo4.Time)

		for k, v in next, clones2, nil do
			local tweenInfo5 = TweenInfo.new(
				lifetime * 0.166 + math.random() * lifetime * 0.25,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.In
			)
			local v2 = 6.283185307179586 * ((k - 1) / 6)
			local tween3 = TweenService:Create(v, tweenInfo5, {
				CFrame = origin * CFrame.Angles(0, v2 + 0.7853981633974483, 0) * CFrame.new(
					0,
					3 * scale + 3 * (k / 6) * (k % 2 == 0 and 1 or -1) * scale,
					-8 * scale + math.random() * scale
				)
			})
			local tween4 = TweenService:Create(v.Mesh, tweenInfo5, {
				Scale = Vector3.new()
			})
			local v3 = v
			tween3.Completed:Connect(function()
				v3:Destroy()
			end)
			tween3:Play()
			tween4:Play()
		end
	end)
	wait(tweenInfo2.Time * 0.75)

	for k, v in next, clones, nil do
		local tweenInfo3 = TweenInfo.new(
			lifetime * 0.25 + math.min(0.75, math.random()) * lifetime * 0.25,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
		local tweenInfo4 = TweenInfo.new(tweenInfo3.Time, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local v2 = 6.283185307179586 * ((k - 1) / 4)
		local tween3 = TweenService:Create(v, tweenInfo3, {
			CFrame = origin * CFrame.Angles(0, v2, 0) * CFrame.new(0, 0.75 * scale, -3.5 * scale) * CFrame.Angles(
				-1.7951958020513104,
				0,
				0
			)
		})
		local mesh = v.Mesh
		local v5 = v.Mesh.Scale * createVector(1.25, 1.1, 1.25)
		local v6

		if scale > 1 then
			v6 = scale * 0.75 or scale
		else
			v6 = scale
		end

		local v7 = TweenService:Create(mesh, tweenInfo3, {
			Scale = v5 * v6
		})
		local v8 = v
		tween3.Completed:Connect(function()
			local tween4 = TweenService:Create(v8, tweenInfo4, {
				CFrame = origin * CFrame.Angles(0, v2 + 0.5235987755982988, 0) * CFrame.new(0, 2 * scale, -10 * scale) * CFrame.Angles(
					-0.7853981633974483,
					0,
					0
				)
			})
			local tween5 = TweenService:Create(v8.Mesh, tweenInfo4, {
				Scale = Vector3.new()
			})
			tween4.Completed:Connect(function()
				v8:Destroy()
			end)
			tween4:Play()
			tween5:Play()
		end)
		tween3:Play()
		v7:Play()
	end
end