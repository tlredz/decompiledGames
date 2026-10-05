local createVector = vector.create

local function ScaleParticle(p, p2)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, p.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p2, keypoint.Envelope)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
require(ReplicatedStorage:WaitForChild("FX"))
local meshes = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Meshes")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
Util = Util.Debris
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
return function(data)
	local smokeColor = data.SmokeColor or Color3.new(0.1, 0.1, 0.1)
	local origin = data.Origin or CFrame.new()
	local scale = data.Scale or 1
	local lifetime = data.Lifetime or 2.5
	local clones = {}

	for i = 1, 4 do
		local _ = 6.283185307179586 * ((i - 1) / 4)
		local clone = meshes[("Smoke%d"):format(math.random(999) % 2 == 0 and 0 or 1)]:Clone()
		clone.Color = smokeColor
		clone.CFrame = origin
		clone.Mesh.Scale = Vector3.new()
		clone.Parent = _WorldOrigin
		clones[i] = clone
	end

	local tweenInfo = TweenInfo.new(lifetime * 0.083, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	for k, v in next, clones, nil do
		local v2 = 6.283185307179586 * ((k - 1) / 4)
		local tween = TweenService:Create(v, tweenInfo, {
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

		local v7 = TweenService:Create(mesh, tweenInfo, {
			Scale = createVector(0.075, 0.18, 0.075) * v6
		})
		tween:Play()
		v7:Play()
	end

	wait(tweenInfo.Time * 0.25)
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
			local clone = meshes[("Smoke%d"):format(math.random(999) % 2 == 0 and 0 or 1)]:Clone()
			clone.Color = smokeColor
			clone.Mesh.Scale = Vector3.new()
			clone.CFrame = origin
			clone.Parent = _WorldOrigin
			clones2[i] = clone
		end

		local tweenInfo2 = TweenInfo.new(lifetime * 0.083, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		for k, v in next, clones2, nil do
			local v2 = 6.283185307179586 * ((k - 1) / 6)
			local tween = TweenService:Create(v, tweenInfo2, {
				CFrame = origin * CFrame.Angles(0, v2, 0) * CFrame.new(
					0,
					2 * scale + 2 * (k / 6) * (k % 2 == 0 and 1 or -1) * scale,
					-1.5 * scale + math.random() * scale
				)
			})
			local tween2 = TweenService:Create(v.Mesh, tweenInfo2, {
				Scale = createVector(1, 1, 1) * math.min(0.1, math.random()) * (scale > 1 and scale * 0.75 or scale)
			})
			tween:Play()
			tween2:Play()
		end

		wait(tweenInfo2.Time)
		Effect.new("Slash"):replicate({
			CFrame = origin * CFrame.new(0, 6.5 * scale, 0),
			Color = Color3.new(1, 1, 1),
			Width = { 1 * scale, 1.75 * scale },
			Radius = { 0, 12 * scale },
			Transparency = { 0.25, 1 },
			Duration = { lifetime * 0.5, lifetime * 0.5 },
			Direction = -1
		})
		local tweenInfo3 = TweenInfo.new(lifetime * 0.416, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		for k, v in next, clones2, nil do
			local v2 = 6.283185307179586 * ((k - 1) / 6)
			local tween = TweenService:Create(v, tweenInfo3, {
				CFrame = origin * CFrame.Angles(0, v2 + 0.39269908169872414, 0) * CFrame.new(
					0,
					3 * scale + 2.5 * (k / 6) * (k % 2 == 0 and 1 or -1) * scale,
					-3 * scale + math.random() * scale
				)
			})
			local tween2 = TweenService:Create(v.Mesh, tweenInfo3, {
				Scale = v.Mesh.Scale * 1.5 * (scale > 1 and scale * 0.75 or scale)
			})
			tween:Play()
			tween2:Play()
		end

		wait(tweenInfo3.Time)

		for k, v in next, clones2, nil do
			local tweenInfo4 = TweenInfo.new(
				lifetime * 0.166 + math.random() * lifetime * 0.25,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.In
			)
			local v2 = 6.283185307179586 * ((k - 1) / 6)
			local tween = TweenService:Create(v, tweenInfo4, {
				CFrame = origin * CFrame.Angles(0, v2 + 0.7853981633974483, 0) * CFrame.new(
					0,
					3 * scale + 3 * (k / 6) * (k % 2 == 0 and 1 or -1) * scale,
					-8 * scale + math.random() * scale
				)
			})
			local tween2 = TweenService:Create(v.Mesh, tweenInfo4, {
				Scale = Vector3.new()
			})
			local v3 = v
			tween.Completed:Connect(function()
				v3:Destroy()
			end)
			tween:Play()
			tween2:Play()
		end
	end)
	wait(tweenInfo.Time * 0.75)

	for k, v in next, clones, nil do
		local tweenInfo2 = TweenInfo.new(
			lifetime * 0.25 + math.min(0.75, math.random()) * lifetime * 0.25,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		)
		local tweenInfo3 = TweenInfo.new(tweenInfo2.Time, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local v2 = 6.283185307179586 * ((k - 1) / 4)
		local tween = TweenService:Create(v, tweenInfo2, {
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

		local v7 = TweenService:Create(mesh, tweenInfo2, {
			Scale = v5 * v6
		})
		local v8 = v
		tween.Completed:Connect(function()
			local tween2 = TweenService:Create(v8, tweenInfo3, {
				CFrame = origin * CFrame.Angles(0, v2 + 0.5235987755982988, 0) * CFrame.new(0, 2 * scale, -10 * scale) * CFrame.Angles(
					-0.7853981633974483,
					0,
					0
				)
			})
			local tween3 = TweenService:Create(v8.Mesh, tweenInfo3, {
				Scale = Vector3.new()
			})
			tween2.Completed:Connect(function()
				v8:Destroy()
			end)
			tween2:Play()
			tween3:Play()
		end)
		tween:Play()
		v7:Play()
	end
end