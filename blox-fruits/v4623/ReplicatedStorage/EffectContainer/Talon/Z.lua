local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local _ = game.ReplicatedStorage.Util
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local sound = Util.Sound
local masterClock = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(data)
	local me = data.Me
	local victim = data.Victim
	local head = victim:FindFirstChild("Head") or victim:FindFirstChild("HumanoidRootPart")

	if not head or (head.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")

	if game.Players.LocalPlayer.Character == me or game.Players.LocalPlayer.Character == victim then
		colorCorrectionEffect.Parent = game.Lighting
	end

	local v = 1.65 - (masterClock:GetTime() - data.Timestamp)

	if v < 0.4 then
		return
	end

	if game.Players.LocalPlayer.Character == me or game.Players.LocalPlayer.Character == victim then
		Effect.new("ShakeCam"):replicate({
			6,
			16,
			0.1,
			2,
			createVector(1, 1, 1),
			createVector(1, 1, 2)
		})
	end

	TweenService:Create(sound:Play("FlameVortex2", head), TweenInfo.new(v), {
		PlaybackSpeed = 1.25,
		Volume = 1.25
	}):Play()
	local lastTime = tick()
	local clone = script.FireOrb:Clone()
	clone.Parent = _WorldOrigin
	local v3 = false
	local count = 0

	while tick() - lastTime < v do
		local cFrame = head.CFrame
		local v4 = (tick() - lastTime) / v
		local flag

		if v4 > 0.5 then
			v4 = ((v4 - 0.5) / 0.5) ^ 0.15
			flag = true

			if not v3 then
				v3 = true
				Util.Sound:Play("FlameNukeExplosion2", head.Position)

				if game.Players.LocalPlayer.Character == me or game.Players.LocalPlayer.Character == victim then
					Effect.new("ShakeCam"):replicate({
						14,
						46,
						0.1,
						2,
						createVector(1, 1, 1),
						createVector(1, 1, 2)
					})
				end
			end
		else
			flag = false
		end

		count += 1

		if count % 2 == 0 then
			local v5 = (8 + v4 * 42) * (1 + math.random() / 2)
			local v6 = (3 + v4 * 6) * (1 + math.random())

			if flag then
				v6 *= 1 + v4
				v5 *= 1 + v4
			end

			local lerped = Color3.fromRGB(170, 85, 0):Lerp(Color3.fromRGB(33, 84, 185), flag and v4 or v4 / 4)
			TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.25), {
				Brightness = flag and 0.6 or v4 / 1.1,
				Contrast = flag and 0.6 or v4 / 1.1,
				Saturation = flag and 0.6 or v4 / 1.1,
				TintColor = lerped:Lerp(Color3.new(1, 1, 1), math.random() * 0.1)
			}):Play()

			if not flag then
				local clone2 = script.ThinRing:Clone()
				clone2.Color = Color3.new()
				clone2.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone2.Parent = _WorldOrigin
				local tween = TweenService:Create(clone2, TweenInfo.new(0.37, Enum.EasingStyle.Exponential), {
					Size = createVector(19, 0, 19) * (1 + v4) * (flag and 1.66 or 1),
					CFrame = clone2.CFrame + cFrame.LookVector * (10 + 10 * v4 * (flag and 1.66 or 1)),
					Transparency = 1
				})
				tween.Completed:Connect(function()
					clone2:Destroy()
				end)
				tween:Play()
			end

			for _ = 1, 3 do
				local color = math.random() > 0.33 and lerped or Color3.new()
				local v8 = (10 + math.random() * 6.6) * (0.5 + v4) * (flag and 1.66 or 1)
				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.CFrame = cFrame * CFrame.Angles(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
				part.Size = createVector(1, 1, 1)
				part.Color = color
				part.Transparency = 0
				part.Material = "Neon"
				local specialMesh = Instance.new("SpecialMesh")
				specialMesh.MeshType = "Sphere"
				specialMesh.Scale = createVector(0.15, 0.15, 1) * v8
				specialMesh.Parent = part
				part.Parent = _WorldOrigin
				local tween = TweenService:Create(specialMesh, TweenInfo.new(0.15 + math.random() * 0.1), {
					Scale = Vector3.new(),
					Offset = Vector3.new(0, 0, -v8 * (1 + math.random()))
				})
				tween.Completed:Connect(function()
					part:Destroy()
				end)
				tween:Play()
			end

			local clone2 = script.Shockwave:Clone()
			clone2.Size = createVector(1, 1, 1) * v6
			clone2.Color = lerped:Lerp(Color3.new(1, 1, 1), 0.3)
			clone2.CFrame = cFrame * CFrame.new(0, 0, v6 / 2.5 - 2.5)
			clone2.Parent = _WorldOrigin
			local tween = TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = Vector3.new(0, 0, v5),
				Color = lerped,
				CFrame = cFrame * CFrame.new(0, 0, v5 / 2 * (1 + math.random() * 0.5))
			})
			tween.Completed:Connect(function()
				clone2:Destroy()
			end)
			tween:Play()
			local colorSequence = flag and ColorSequence.new(Color3.fromRGB(0, 174, 255), Color3.new(0, 0, 1)) or ColorSequence.new(
				Color3.fromRGB(255, 115, 0),
				Color3.new(1, 0, 0)
			)
			clone.ParticleEmitter.SpreadAngle = Vector2.new(v6 * 0.75, v6 * 0.75)
			clone.ParticleEmitter.Speed = NumberRange.new(v5, v5 * 4)
			clone.ParticleEmitter.Size = NumberSequence.new(v6 * 0.15, v6 * 0.4)
			clone.ParticleEmitter.Color = colorSequence

			if count % (flag and 2 or 4) == 0 then
				local lerped2 = lerped:Lerp(Color3.new(1, 1, 1), 0.1)
				local clone3 = script.FireRings:Clone()

				for _, child in pairs(clone3:GetChildren()) do
					child.Size = child.Size.unit * v6 * (1 + math.random())
					child.Color = math.random() > 0.33 and lerped2:Lerp(Color3.new(1, 1, 1), 0.3) or Color3.new()
					child:SetAttribute("Dark", lerped2:Lerp(Color3.new(), 0.7))
				end

				clone3:SetPrimaryPartCFrame(cFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				clone3.Parent = _WorldOrigin

				for _, child in pairs(clone3:GetChildren()) do
					local tween2 = TweenService:Create(child, TweenInfo.new(0.2), {
						Size = child.Size * createVector(1.5, 3, 1.5) * (0.75 + math.random() * 0.5),
						Color = child:GetAttribute("Dark") or lerped2,
						Transparency = 1,
						CFrame = child.CFrame * CFrame.new(0, v5 * 0.85, 0) * CFrame.Angles(0, 3.141592653589793, 0)
					})
					local v8 = child
					tween2.Completed:Connect(function()
						v8:Destroy()
					end)
					tween2:Play()
				end

				task.delay(0.5, function()
					clone3:Destroy()
				end)
			end
		end

		clone.CFrame = cFrame
		task.wait()
	end

	TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.25), {
		Brightness = 0,
		Contrast = 0,
		Saturation = 0,
		TintColor = Color3.new(1, 1, 1)
	}):Play()
	clone.ParticleEmitter.Enabled = false
	task.wait(1)
	clone:Destroy()
	colorCorrectionEffect:Destroy()
end