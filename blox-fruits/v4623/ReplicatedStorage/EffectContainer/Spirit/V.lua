local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local V = FX:WaitForChild("Spirit").V
local _ = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local _ = Util.LightningBolt

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

local function getResource(p, p2, items)
	local clone = V[p]:Clone()

	if p2 then
		Util.Debris:AddItem(clone, p2)
	end

	if items then
		for k, item in pairs(items) do
			if clone[k] then
				clone[k] = item
			end
		end
	end

	return clone
end

local function chime(position, p)
	local parent = Util.Sound:Play("PrimeChime", position, nil, p, 3)
	local chorusSoundEffect = Instance.new("ChorusSoundEffect")
	chorusSoundEffect.Depth = 0.25
	chorusSoundEffect.Parent = parent
	local pitchShiftSoundEffect = Instance.new("PitchShiftSoundEffect")
	pitchShiftSoundEffect.Octave = 0.5
	pitchShiftSoundEffect.Parent = parent
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 1)
	part.Anchored = true
	part.Size = Vector3.new()
	part.CanCollide = false
	part.Transparency = 1
	part.Position = position
	local clone = V.ExplosionOrigin.Twinkles.UpSparkle:Clone()
	clone.Speed = NumberRange.new(0)
	clone.Lifetime = NumberRange.new(0.1)
	clone.Squash = NumberSequence.new(0.1)
	clone.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 20),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.Rotation = NumberRange.new(-10, 10)
	clone.Parent = part
	part.Parent = _WorldOrigin
	clone:Emit(1)
end

local function fireEmission(value, p, p2, items)
	local v = value or 3
	local clone = V.FireTrail:Clone()
	debris:AddItem(clone, v + 1)
	local flames = clone.Flames
	local embers = clone.Embers
	local trail = clone.Trail

	for k, item in pairs(items) do
		clone[k] = item
	end

	clone.Parent = _WorldOrigin
	trail.Enabled = true
	local lastTime = tick()
	task.spawn(function()
		local v2 = 0.016666666666666666
		local v3 = 1

		while tick() - lastTime < v do
			local _ = (tick() - lastTime) / v
			clone.CFrame = clone.CFrame * CFrame.new(0, 0, -p2 * v2 * 60) * CFrame.Angles(
				math.rad(p * math.cos(v3 / 5 + math.random(-15, 15) / 10)) * v2 * 60,
				0,
				0
			)
			flames:Emit(2)
			embers:Emit(math.random(2, 3))
			v3 += 1
			v2 = RunService.RenderStepped:Wait()
		end

		if clone then
			task.wait(1)

			if clone then
				clone:Destroy()
			end
		end
	end)
end

return function(data)
	local stage = data.Stage or 1

	if stage == 1 then
		local root = data.Root

		if (root.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		local parent = Util.Sound:Play("PrimeChime", root, nil, 0.8, 3)
		local echoSoundEffect = Instance.new("EchoSoundEffect")
		echoSoundEffect.Delay = 0.08
		echoSoundEffect.Parent = parent
		local clone = V.Twinkle.Attachment:Clone()
		Util.Debris:AddItem(clone, 1)
		clone.Parent = root
		clone.Sparkle:Emit(1)
		clone.SparkleDark:Emit(1)
	elseif stage == 2 then
		local position = data.Position

		if (position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
			return
		end

		local v = {}
		task.spawn(function()
			for i = 1, 3 do
				chime(position + Vector3.new(math.random(-30, 30), i * 4 + 10, math.random(-30, 30)), i / 10 + 1)
				task.wait(0.1)
			end

			local clone = V.ExplosionOrigin:Clone()
			Util.Debris:AddItem(clone, 15)
			clone.Position = position
			clone.Parent = _WorldOrigin
			local static = clone.Static
			local rotating = clone.Rotating
			local twinkles = clone.Twinkles
			Util.Sound:Play("IcebergExplosion", position, nil, 0.5, 2)

			for _, v2 in pairs({ static, rotating }) do
				for _ = 1, 2 do
					for _, child in pairs(v2:GetChildren()) do
						child:Emit(child:GetAttribute("EmitCount"))
					end
				end
			end

			local clone2 = V.SpikedBall:Clone()
			debris:AddItem(clone2, 6)
			clone2.CFrame = CFrame.new(clone.Position) * CFrame.Angles(
				math.rad((math.random(0, 360))),
				math.rad((math.random(0, 360))),
				(math.rad((math.random(0, 360))))
			)
			clone2.Parent = _WorldOrigin
			local clone3 = V.IceMist:Clone()
			clone3.Parent = clone2
			local tween = TweenService:Create(
				clone2,
				TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(120, 120, 120)
				}
			)
			tween.Completed:Connect(function()
				task.delay(0.5, function()
					if clone2 then
						local tween2 = TweenService:Create(
							clone2,
							TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
							{
								Transparency = 1,
								Size = createVector(100, 100, 100)
							}
						)
						tween2.Completed:Connect(function()
							clone3.Enabled = false
							task.wait(2)
							clone2:Destroy()
						end)
						tween2:Play()
					end
				end)
			end)
			tween:Play()
			local clone4 = V.IceSpike:Clone()
			debris:AddItem(clone4, 6)
			clone4.Size = createVector(0, 0, 0)
			clone4.CFrame = CFrame.new(position)
			clone4.Parent = _WorldOrigin
			task.spawn(function()
				for _ = 1, 10 do
					fireEmission(math.random(3, 5) / 10, math.random(4, 7), math.random(40, 60) / 10, {
						CFrame = CFrame.new(position) * CFrame.Angles(
							math.rad((math.random(-10, 10))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-10, 10))))
						)
					})
				end

				local _ = CFrame.new(position) * CFrame.Angles(
					math.rad((math.random(-10, 10))),
					math.rad((math.random(-180, 180))),
					(math.rad((math.random(-10, 10))))
				)

				for _ = 1, 12 do
					fireEmission(math.random(7, 8) / 10, math.random(15, 20), math.random(40, 60) / 10, {
						CFrame = CFrame.new(position) * CFrame.Angles(
							math.rad((math.random(-10, 10))),
							math.rad((math.random(-180, 180))),
							(math.rad((math.random(-10, 10))))
						)
					})
					task.wait(0.02)
				end
			end)

			for i = 1, 2 do
				for i2 = 1, 5 do
					local clone5 = V.IceSpike:Clone()
					debris:AddItem(clone5, 5)
					clone5.Size = Vector3.new()
					clone5.CFrame = CFrame.new(position) * CFrame.Angles(
						0,
						math.rad(i2 * (360 / (i == 1 and 5 or 3))),
						(math.rad(i ~= 1 and 80 or math.random(50, 70) or 80))
					)
					clone5.Parent = _WorldOrigin
					local tween2 = TweenService:Create(
						clone5,
						TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = createVector(30, 170, 30),
							CFrame = clone5.CFrame * CFrame.new(0, 30, 0)
						}
					)
					tween2.Completed:Connect(function()
						task.delay(0.5, function()
							if clone5 then
								local tween3 = TweenService:Create(
									clone5,
									TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
									{
										Transparency = 1,
										Size = createVector(25, 60, 25)
									}
								)
								tween3.Completed:Connect(function()
									if clone5 then
										clone5:Destroy()
									end
								end)
								tween3:Play()
							end
						end)
					end)
					tween2:Play()
				end
			end

			local parent = Util.Sound:Play("GenericExplosion3", position, nil, 1, 2)
			local flangeSoundEffect = Instance.new("FlangeSoundEffect")
			flangeSoundEffect.Depth = 1
			flangeSoundEffect.Rate = 0.1
			flangeSoundEffect.Parent = parent
			local reverbSoundEffect = Instance.new("ReverbSoundEffect")
			reverbSoundEffect.Density = 0.55
			reverbSoundEffect.Parent = parent
			Util.Sound:Play("ElectricExplosionLong2", position, nil, 1.5, 1)
			clone.FireParticles.Rays:Emit(math.random(6, 8))

			if (position - workspace.CurrentCamera.CFrame.p).magnitude < 300 then
				Util.CameraShaker:ShakeOnce(10, 10, 2, 2)
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game:GetService("Lighting")
				local tween2 = TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
					{
						TintColor = Color3.fromRGB(253, 255, 190),
						Contrast = 0.8,
						Brightness = 0.2
					}
				)
				tween2.Completed:Connect(function()
					colorCorrectionEffect:Destroy()
				end)
				tween2:Play()
			end

			twinkles.UpSparkle:Emit(1)
			twinkles.SideSparkle:Emit(1)
			clone.SnowDust.Enabled = true
			clone.FireDiamonds.Enabled = true
			task.delay(3, function()
				clone.SnowDust.Enabled = false
				clone.FireDiamonds.Enabled = false
			end)
			local v3 = 0.016666666666666666
			local lastTime = tick()
			task.spawn(function()
				local now = tick()
				local now2 = tick()
				local now3 = tick()
				local now4 = tick()

				while true do
					local now5 = tick()
					local v4 = now5 - lastTime

					if v4 > 3 then
						break
					end

					local _ = v4 / 3.5

					if v4 < 2 then
						if now5 - now4 > 0.05 and tick() - lastTime < 0.5 then
							static.Wisp:Emit(2)
						end

						rotating.Orientation += Vector3.new(0, v3 * 2 * 60, 0)
						local _ = now5 - now > 0.7

						if now5 - now2 > 0.05 and tick() - lastTime < 0.6 then
							local resource = getResource("Wind", 1.5, {
								CFrame = CFrame.new(position + createVector(0, 10, 0)) * CFrame.Angles(
									math.rad((math.random(-15, 15))),
									math.rad((math.random(-5, 5))),
									(math.rad((math.random(-15, 15))))
								),
								Size = Vector3.new(),
								Transparency = 0.2
							})
							resource.Parent = _WorldOrigin
							table.insert(v, { 2, resource })
							local tween2 = TweenService:Create(
								resource,
								TweenInfo.new(
									math.random(3, 6) / 10,
									Enum.EasingStyle.Sine,
									Enum.EasingDirection.Out,
									0,
									false,
									0
								),
								{
									Size = createVector(370, 30, 370),
									Transparency = 1,
									Color = Color3.fromRGB(167, 169, 179)
								}
							)
							tween2.Completed:Connect(function()
								resource:Destroy()
							end)
							tween2:Play()
							now2 = tick()
						end

						local _ = now5 - now3 > 0.7
					end

					if #v > 0 then
						local v5 = v3 * 60

						for k, v6 in pairs(v) do
							if v6[2] == nil then
								table.remove(v, k)
							elseif v6[1] == 0 then
								v6[2].CFrame *= CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(v5 * 1), 0)
							elseif v6[1] == 1 then
								v6[2].CFrame *= CFrame.new(0, v5 * -0.5, 0) * CFrame.Angles(0, math.rad(v5 * 1), 0)
							elseif v6[1] == 2 then
								v6[2].CFrame *= CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(v5 * -35), 0)
							elseif v6[1] == 3 then
								v6[2].CFrame *= CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(v5 * -5), 0)
							end
						end
					end

					v3 = RunService.RenderStepped:Wait()
				end

				if #v > 0 then
					for _, v4 in pairs(v) do
						if v4[2] then
							v4[2]:Destroy()
						end
					end
				end

				v = nil
			end)
		end)
	end
end