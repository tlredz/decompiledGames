local localPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local skill2 = FX:WaitForChild("Rengoku").Skill2
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local debris = Util.Debris

local function quadBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cubicBezier(p, p2, p3, p4, p5)
	local v = p2 + (p3 - p2) * p
	local v2 = p3 + (p4 - p3) * p
	local v3 = p4 + (p5 - p4) * p
	local v4 = v + (v2 - v) * p
	return v4 + (v2 + (v3 - v2) * p - v4) * p
end

local v = {}
return function(data)
	local root = data.Root or data.HumanoidRootPart
	local effectId = data.EffectId or data.EffectID

	if not effectId then
		return
	end

	if data.skillHeld then
		v[effectId] = true
		local v2 = nil

		for _, model in root.Parent:GetChildren() do
			if not (model:IsA("Model") and model:GetAttribute("WeaponName") == "rengoku") then
				continue
			end

			for _, part in model:GetDescendants() do
				if not (part:IsA("BasePart") and part.Name == "Blade") then
					continue
				end

				v2 = part
				break
			end
		end

		if not v2 then
			return
		end

		local currentCamera = workspace.CurrentCamera

		if (currentCamera.CFrame.p - root.Position).Magnitude > 800 then
			return
		end

		local holdTime = data.holdTime
		local chargeTime = data.chargeTime
		coroutine.wrap(function()
			for _ = 1, 5 do
				coroutine.wrap(function()
					local position = v2.Position
					local clone = skill2.Trail:Clone()
					clone.CFrame = v2.CFrame * CFrame.new(
						math.random(-25, 25),
						math.random(2, 10),
						math.random(-25, 25)
					)
					clone.Parent = _WorldOrigin
					local position2 = clone.Position
					local magnitude = (position2 - position).Magnitude
					clone.CFrame = CFrame.new(position2, position)
					local v3 = (position2 - position) / 2
					local position3 = CFrame.new(CFrame.new(position2) * (v3 / -1.5)).Position
					local position4 = CFrame.new(CFrame.new(position) * (v3 / 1.5)).Position
					local halfMagnitude = magnitude / 2
					local v5 = position3 + Vector3.new(
						math.random(-halfMagnitude, halfMagnitude),
						math.random(-3, 8) * 2,
						math.random(-halfMagnitude, halfMagnitude)
					)
					local v6 = position4 + Vector3.new(
						math.random(-halfMagnitude, halfMagnitude),
						math.random(-3, 8) * 2,
						math.random(-halfMagnitude, halfMagnitude)
					)

					for i = 1, magnitude do
						local v7 = i / magnitude
						local v8 = cubicBezier(v7, position2, v5, v6, position)
						clone.CFrame = clone.CFrame:Lerp(CFrame.new(v8, position), v7)
						RunService.Heartbeat:Wait()
					end

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					debris:AddItem(clone, 1)
				end)()
			end
		end)()
		local clone = skill2.Start:Clone()
		clone.Position = v2.Position
		clone.Parent = _WorldOrigin
		debris:AddItem(clone, 4)
		clone.Weld.Part0 = v2

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		task.wait(chargeTime)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local clone2 = skill2.Star:Clone()
		clone2.Position = v2.Position
		clone2.Parent = _WorldOrigin
		debris:AddItem(clone2, 5)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local bladeFlame = skill2.BladeFlame
		local v3 = {}

		for _, emitter in pairs(bladeFlame:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local clone3 = emitter:Clone()
			clone3.Parent = v2
			clone3.Enabled = true
			table.insert(v3, clone3)
		end

		local clone3 = skill2.Start2:Clone()
		clone3.Position = root.Position + Vector3.new(0, -3 + clone3.Size.Y / 2, 0)
		clone3.Parent = _WorldOrigin
		debris:AddItem(clone3, 4)
		local v4 = 1

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local lastTime = os.clock()
		local v5 = true
		coroutine.wrap(function()
			local random = Random.new()

			repeat
				if os.clock() - lastTime < (chargeTime + holdTime) / 2 and v5 == true then
					local clone4 = clone3.Attach_0:Clone()
					local clone5 = clone3.Attach_1:Clone()
					clone4.Parent = clone3
					clone5.Parent = clone3

					for _, child in pairs(clone5:GetChildren()) do
						child.Attachment0 = clone4
						child.Attachment1 = clone5
						child.Enabled = true
					end

					local v6 = math.random(1, 6)
					local v7 = random:NextNumber(0.25, 0.75) * chargeTime
					local v8 = math.random(7, 15) / 10
					local v9 = 8.5 * v8
					local tween = TweenService:Create(
						clone4,
						TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Position = Vector3.new(0, v6, -v9)
						}
					)
					local tween2 = TweenService:Create(
						clone5,
						TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Position = Vector3.new(0, v6, v9)
						}
					)
					local curveSize = 11.5 * v8
					local tween3 = TweenService:Create(
						clone5.Beam,
						TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = -curveSize,
							CurveSize1 = curveSize,
							Width0 = 1.5,
							Width1 = 1.5
						}
					)
					local tween4 = TweenService:Create(
						clone5.Beam2,
						TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = curveSize,
							CurveSize1 = -curveSize,
							Width0 = 1.5,
							Width1 = 1.5
						}
					)
					local tween5 = TweenService:Create(
						clone5.Beam3,
						TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = -curveSize,
							CurveSize1 = curveSize,
							Width0 = 4,
							Width1 = 4
						}
					)
					local tween6 = TweenService:Create(
						clone5.Beam4,
						TweenInfo.new(v7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CurveSize0 = curveSize,
							CurveSize1 = -curveSize,
							Width0 = 4,
							Width1 = 4
						}
					)
					tween:Play()
					tween2:Play()
					tween3:Play()
					tween4:Play()
					tween5:Play()
					tween6:Play()
					coroutine.wrap(function()
						task.wait(v7 * 0.85)
						tween3 = TweenService:Create(
							clone5.Beam,
							TweenInfo.new(v7 * 0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween4 = TweenService:Create(
							clone5.Beam2,
							TweenInfo.new(v7 * 0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween5 = TweenService:Create(
							clone5.Beam3,
							TweenInfo.new(v7 * 0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween6 = TweenService:Create(
							clone5.Beam4,
							TweenInfo.new(v7 * 0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween3:Play()
						tween4:Play()
						tween5:Play()
						tween6:Play()
						tween3.Completed:Wait()
						clone4:Destroy()
						clone5:Destroy()
					end)()
				end

				task.wait(0.14)
			until v5 == true
		end)()
		local v6 = Util.Sound:Play("RengokuChargeWindup", root)
		local v7 = Util.Sound:Play("Mera_FireLoop", root)
		v7.Looped = true
		local v8 = false
		local clone4 = nil
		local renderSteppedConnection = nil
		local clone5 = nil

		while true do
			task.wait()

			if holdTime <= os.clock() - lastTime and v4 == 1 then
				v7.Volume = 0.85
				v7.PlaybackSpeed = 1.5
				local clone6 = skill2.Star2:Clone()
				clone6.Position = v2.Position
				clone6.Parent = _WorldOrigin
				debris:AddItem(clone6, 5)
				v4 = 2

				for _, emitter in pairs(clone6:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				for _, emitter in pairs(clone3:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				v5 = false

				if not v8 then
					local clone7 = skill2.BladeFlame2:Clone()

					for _, folder in pairs(clone7:GetChildren()) do
						for _, emitter in pairs(folder:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								table.insert(v3, emitter)
							end
						end

						folder.Parent = v2
					end

					clone7:Destroy()
					v8 = true
				end

				if localPlayer == game.Players:GetPlayerFromCharacter(root.Parent) then
					if not clone5 then
						clone5 = skill2.CameraFocus:Clone()
						clone5.Parent = _WorldOrigin
						renderSteppedConnection = RunService.RenderStepped:Connect(function()
							clone5.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(
								1.5707963267948966,
								0,
								0
							)
						end)
					end

					if not clone4 then
						clone4 = skill2.ScreenColor:Clone()
						clone4.Parent = game.Lighting
						TweenService:Create(clone4, TweenInfo.new(0.25), {
							Brightness = clone4.Brightness,
							Contrast = clone4.Contrast,
							Saturation = clone4.Saturation,
							TintColor = clone4.TintColor
						}):Play()
						clone4.Brightness = 0
						clone4.Contrast = 0
						clone4.Saturation = 0
						clone4.TintColor = Color3.fromRGB(255, 255, 255)
					end
				end
			end

			if not (not root:IsDescendantOf(workspace) or v[effectId] == nil) then
				continue
			end

			Util.Sound:FadeOut(v7, 0.3)
			Util.Sound:FadeOut(v6, 0.3)

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for k, v9 in pairs(v3) do
				v9.Enabled = false
				debris:AddItem(v9, v9.Lifetime.Max)
				v3[k] = nil
			end

			if clone4 then
				local tween = TweenService:Create(clone4, TweenInfo.new(0.15), {
					Brightness = 0,
					Contrast = 0,
					Saturation = 0,
					TintColor = Color3.fromRGB(232, 139, 139)
				})
				tween:Play()
				debris:AddItem(clone4, 1)
				coroutine.wrap(function()
					tween.Completed:Wait()
					tween = TweenService:Create(clone4, TweenInfo.new(0.125), {
						TintColor = Color3.fromRGB(255, 255, 255)
					})
					tween:Play()
				end)()
			end

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end

			if clone5 then
				clone5:Destroy()
			end

			v[effectId] = nil
			return
		end
	else
		if not v[effectId] then
			return
		end

		v[effectId] = nil
	end
end