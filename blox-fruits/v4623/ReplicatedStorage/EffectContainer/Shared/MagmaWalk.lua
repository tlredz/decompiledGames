local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local Util = require(game.ReplicatedStorage.Util)
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util2 = require(ReplicatedStorage:WaitForChild("Util"))
Util2 = Util2.Sound
local v = {}
local v2 = {}

local function ScaleParticle(emitter, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, emitter.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	return
		NumberSequence.new(numberSequenceKeypoints),
		NumberRange.new(emitter.Speed.Min * p, emitter.Speed.Max * p),
		emitter.Acceleration * p
end

return function(data)
	local position = data.Position
	local size = data.Size or data.Scale or Vector3.new(2 + math.random(7, 9), 2, 2 + math.random(7, 9))
	local duration = data.Duration or 2
	local cframe = CFrame.new(position.X, not data.RespectHeight and -3.8 or position.Y or -3.8, position.Z)

	if (position - currentCamera.CFrame.p).Magnitude > 200 + 4 * size.Magnitude then
		return
	end

	local flag = false
	local v3 = false

	for _, v4 in pairs(v) do
		local v5 = v4[1]
		local v6 = v4[2]

		if not (((v5 - cframe.p) * createVector(1, 0, 1)).Magnitude < ((size * createVector(1, 0, 1)).Magnitude + (v6 * createVector(
			1,
			0,
			1
		)).Magnitude) / 4 - 2.5) then
			continue
		end

		flag = true
	end

	if flag then
		return
	end

	if data.Type == "AwakenedBlob" then
		local v4 = {}
		local emitters = {}
		local v5 = 0
		local clone = game.ReplicatedStorage.Assets.Models.MagmaFloors[data.Type or "Blob"]:Clone()

		if data.NonCollide then
			clone.PrimaryPart.CanCollide = false
		else
			clone.PrimaryPart.CanCollide = true
		end

		clone:SetPrimaryPartCFrame(cframe * CFrame.Angles(
			(math.random() - 0.5) * 0.06,
			math.random() * 7,
			(math.random() - 0.5) * 0.07
		))
		clone.Parent = workspace
		local count = 0
		local v6 = {}

		for _, v7 in pairs(v2) do
			count += 1
			table.insert(v6, v7)
		end

		local v7

		if count == 0 then
			v7 = true
		else
			table.sort(v6, function(a, b)
				return (position - a).Magnitude < (position - b).Magnitude
			end)
			v7 = #v6 > 0 and ((v6[1] - position) * createVector(1, 0, 1)).Magnitude >= (size * createVector(1, 0, 1)).Magnitude / 2 or v3
		end

		if v7 then
			v2[clone] = position
		end

		v[clone] = { position, size }
		Util.Debris:AddItem(clone, duration + 0.25, function()
			if v7 then
				v2[clone] = nil
			end

			v[clone] = nil
		end)

		for _, child in pairs(clone:GetChildren()) do
			local size2 = child.Size

			if child == clone.PrimaryPart then
				child.Size = size2 * createVector(1, 0.25, 1) * size
				child.PointLight.Brightness = 0
				child.PointLight.Range = 0
				v4[child] = TweenService:Create(
					child.PointLight,
					TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
					{
						Brightness = 7,
						Range = size.Magnitude / 2
					}
				)

				for _, emitter in pairs(child:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					v5 = math.max(v5, emitter.Lifetime.Max)
					local size3, speed, acceleration = ScaleParticle(
						emitter,
						(size * createVector(1, 0, 1)).Magnitude * 0.08
					)
					emitter.Size = size3
					emitter.Speed = speed
					emitter.Acceleration = acceleration
					local enable = emitter:GetAttribute("Enable")
					local emit = emitter:GetAttribute("Emit")

					if emit then
						emitter:Emit(typeof(emit) == "number" and emit or 1)
					end

					if enable then
						if typeof(enable) == "number" then
							local v11 = emitter
							task.delay(enable, function()
								v11.Enabled = false
							end)
						end

						emitter.Enabled = enable and true
					end

					table.insert(emitters, emitter)
				end
			else
				v4[child] = TweenService:Create(
					child,
					TweenInfo.new(0.25, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
					{
						Size = size2 * createVector(1, 0.25, 1) * size
					}
				)
			end
		end

		for _, v8 in pairs(v4) do
			v8:Play()
		end

		if v7 then
			Util.Sound:Play("SteamHiss", clone.PrimaryPart, nil, 5.224 / (duration + 0.25 + 0.75))
		end

		task.delay(0.25, function()
			for k, _ in pairs(v4) do
				local size2 = k.Size

				if k == clone.PrimaryPart then
					v4[k] = TweenService:Create(
						k.PointLight,
						TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							Brightness = 0,
							Range = 0
						}
					)
				else
					local color = k.Color

					if math.sqrt(color.R ^ 2 * 0.241 + color.G ^ 2 * 0.691 + color.B ^ 2 * 0.068) >= 0.1 then
						v4[k] = TweenService:Create(
							k,
							TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
							{
								Size = size2 * 0,
								Color = Color3.fromRGB(17, 17, 17)
							}
						)
					else
						v4[k] = TweenService:Create(
							k,
							TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
							{
								Size = size2 * 0
							}
						)
					end
				end
			end

			for _, v8 in pairs(v4) do
				v8:Play()
			end

			task.wait(duration)

			for _, v8 in pairs(emitters) do
				v8.Enabled = false
			end

			emitters = nil
			v[clone] = nil

			if v7 then
				v2[clone] = nil
			end

			task.wait(v5)

			for k, _ in pairs(v4) do
				k:Destroy()
			end

			clone:Destroy()
			v4 = nil
		end)
	end
end