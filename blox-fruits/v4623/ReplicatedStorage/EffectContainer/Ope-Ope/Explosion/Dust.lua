local createVector = vector.create

local function ScaleParticle(dust, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, dust.Size.Keypoints, nil do
		local v = keypoint.Value * p
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, v, v < keypoint.Envelope and v or keypoint.Envelope)
		)
	end

	dust.Speed = NumberRange.new(dust.Speed.Min * p, dust.Speed.Max * p)
	return NumberSequence.new(numberSequenceKeypoints)
end

local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local effects = ReplicatedStorage["Ope-Ope"].Effects
local Tween = require(ReplicatedStorage.Util.Tween)
local Effect = require(ReplicatedStorage.Effect)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local currentCamera = workspace.CurrentCamera
return function(list)
	local now = tick()
	local v, v2, mScale, v4, v5, v6 = unpack(list)

	if (v2.p - currentCamera.CFrame.p).Magnitude < 2 * mScale then
		local v7 = 1 - (v2.p - currentCamera.CFrame.p).Magnitude / (2 * mScale)
		Effect.new("ShakeCam"):replicate({
			10 * v7,
			10 * v7,
			0,
			4 * v4,
			createVector(1, 1, 1),
			createVector(1, 0, 0)
		})
	end

	Sound:Play("Ope.Explosion.SpikeDust", v2.p, 2 * mScale)
	Effect.new("Ope-Ope.Shockwave"):replicate({
		v2 * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, 1, 0),
		1.5 * mScale,
		1.25 * v4
	})
	Effect.new("Ope-Ope.Hit"):replicate({ v2, mScale })

	if not v6 then
		local clone = effects.DustShockwave:Clone()
		clone.CFrame = v2 * CFrame.Angles(-1.5707963267948966, 0, 0)
		local scale = clone.Mesh.Scale
		clone.Mesh.Scale = Vector3.new()
		clone.Parent = _WorldOrigin
		local tweenInfo = TweenInfo.new(v4 * 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local tween = TweenService:Create(clone, tweenInfo, {
			CFrame = v2 * CFrame.new(0, 0, -mScale / 3) * CFrame.Angles(-1.5707963267948966, 0, 0)
		})
		local tween2 = TweenService:Create(clone.Mesh, tweenInfo, {
			Scale = scale * createVector(0.25, 0.5, 0.25) * mScale / 2,
			VertexColor = createVector(4, 2, 1)
		})
		tween.Completed:Connect(function()
			local tweenInfo2 = TweenInfo.new(v4 * 0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.In)
			local tween3 = TweenService:Create(clone, tweenInfo2, {
				Transparency = 1
			})
			local tween4 = TweenService:Create(clone.Mesh, tweenInfo2, {
				Scale = scale * createVector(0, 0.5, 0) * mScale / 2
			})
			tween4.Completed:Connect(function()
				clone:Destroy()
			end)
			tween3:Play()
			tween4:Play()
		end)
		tween:Play()
		tween2:Play()
	end

	local v7 = {}
	local v8 = 1

	if mScale > 125 then
		if not v6 then
			for i = 1, 15 do
				local v9 = i / 15
				math.min(1.25, v9 ^ 0.5)
				local _ = 6.283185307179586 * (i / 15)
				local clone = effects.DustCloud:Clone()
				clone.Color = Color3.fromRGB(163, 162, 165)
				clone.Mesh.VertexColor = Vector3.new(v.Color.r, v.Color.g, v.Color.b)
				clone.CFrame = v2 * CFrame.new(0, mScale * 0.1, 0)
				clone.Transparency = 1
				clone.Mesh.Scale = Vector3.new()
				clone.Dust:Destroy()
				clone.Parent = _WorldOrigin
				table.insert(v7, {
					Part = clone,
					Mesh = clone.Mesh,
					mScale = mScale,
					Scale = createVector(0.121, 0.125, 0.091) * Vector3.new(
						1 - math.random() * 0.25,
						1 - math.random() * 0.25,
						1 - math.random() * 0.25
					) * mScale * 0.3,
					Origin = clone.CFrame,
					Offset = CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					),
					Goal = clone.CFrame * CFrame.new(0, -mScale * 0.1, -mScale * 0.4),
					Start = now + (i == 1 and 0 or v4 / 2 * v9)
				})
			end
		end
	else
		v8 = 1 + mScale / 125
	end

	local v9 = {}

	for i = 1, 15 do
		local v10 = math.min(1.25, (i / 15) ^ 0.5)
		local _ = 6.283185307179586 * (i / 15)
		local clone = effects.DustCloud:Clone()
		clone.Color = v.Color
		clone.Mesh.VertexColor = Vector3.new(v.Color.r, v.Color.g, v.Color.b)
		clone.CFrame = v2 * CFrame.new(0, mScale * 0.1, 0)
		clone.Mesh.Scale = Vector3.new()
		clone.Dust.Color = ColorSequence.new(v.Color)
		clone.Dust.Size = ScaleParticle(clone.Dust, v10 * mScale / 3)
		clone.Dust.Transparency = NumberSequence.new(1)
		clone.Parent = _WorldOrigin
		table.insert(v9, {
			Part = clone,
			Mesh = clone.Mesh,
			mScale = v8 * mScale * 0.75,
			Scale = v8 * createVector(0.121, 0.125, 0.091) * Vector3.new(
				1 - math.random() * 0.25,
				1 - math.random() * 0.25,
				1 - math.random() * 0.25
			) * mScale * 0.2,
			Origin = clone.CFrame,
			Offset = CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			),
			Goal = clone.CFrame * CFrame.new(0, -mScale * 0.1, -mScale * 0.4)
		})
	end

	local now2 = tick()
	local finished = false

	while not finished do
		local now3 = tick()
		local v10 = math.min(v4, now3 - now2)
		local v11 = math.min(1, v10 / v4)
		local back = Tween.ease.out.back(v10, 0, 1, v4)
		local expo = Tween.ease.out.expo(v10, 1, -1, v4)

		for k, v12 in next, v7, nil do
			local v13 = 2 * (6.283185307179586 * (k / 15))
			local v14 = k / 15
			local v15 = math.min(1.25, v14 ^ 0.75)
			local v16 = v14 ^ 0.25
			v12.Part.CFrame = v12.Origin * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(0, v13, 0) * CFrame.new(
				0,
				v16 * v12.mScale * (k / 15),
				v15 * -v12.mScale / 3 * back
			) * v12.Offset

			if not (now3 - v12.Start > 0) then
				continue
			end

			local v17 = now3 - v12.Start

			if v4 / 2 < v17 then
				v12.Finished = true
			else
				local back2 = Tween.ease.out.back(now3 - v12.Start, 0, 1, v4 / 2)
				local quad = Tween.ease.out.quad(now3 - v12.Start, 1, -1, v4 / 2)
				v12.Part.Transparency = quad
				v12.Mesh.Scale = v15 * 1.75 * v12.Scale * back2
			end
		end

		for k, v12 in next, v9, nil do
			local v13 = 6.283185307179586 * (k / 15)
			local v14 = k / 15
			local v15 = math.min(1.25, v14 ^ 0.5)
			local v16 = v14 ^ 0.25
			v12.Part.CFrame = v12.Origin * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(0, v13, 0) * CFrame.new(
				0,
				0,
				v16 * -v12.mScale / 3 * back
			) * v12.Offset
			v12.Mesh.Scale = v15 * 1.5 * v12.Scale * back
			v12.Part.Dust.Transparency = NumberSequence.new(expo)
		end

		finished = #v7 > 0 and v7[#v7].Finished or v11 == 1
		RunService.RenderStepped:Wait()
	end

	for _, v10 in next, { v7, v9 }, nil do
		for _, v11 in next, v10, nil do
			if v11.Part:FindFirstChild("Dust") then
				v11.Part.Dust.Enabled = false
			end
		end
	end

	local tweenInfo = TweenInfo.new(v5, Enum.EasingStyle.Back, Enum.EasingDirection.In)

	for _, v10 in next, { v7, v9 }, nil do
		for k, v11 in next, v10, nil do
			local tween = TweenService:Create(v11.Part, tweenInfo, {
				Transparency = 0
			})
			local tween2 = TweenService:Create(v11.Part.Mesh, tweenInfo, {
				Scale = Vector3.new()
			})
			local v12 = v11
			tween.Completed:Connect(function()
				v12.Part:Destroy()
			end)
			delay(v4 / #v10 * (k - 1), function()
				tween:Play()
				tween2:Play()
			end)
		end
	end
end