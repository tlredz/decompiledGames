local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local V = FX:WaitForChild("Soul").V
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.Debris
local lightningBolt = Util.LightningBolt

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

local function exteriorBolt(topAttachment, bottomAttachment, p, p2, p3)
	local v = lightningBolt.new(topAttachment, bottomAttachment, p, p2, p3, Color3.fromRGB(119, 0, 255))
	v.Color = Color3.fromRGB(119, 0, 255)
	v.AnimationSpeed = 13
	v.FadeLength = 0.5
	v.Thickness = 2
	v.MaxAngleOffset = 0.5235987755982988
	return v
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
	local clone = V.ExplCore.Base.UpSparkle:Clone()
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
			local clone = V.ExplCore:Clone()
			Util.Debris:AddItem(clone, 15)
			clone.Position = position + createVector(0, 30, 0)
			local base = clone.Base
			local emberDust = clone.EmberDust
			local purpDiamonds = clone.PurpDiamonds
			local upSparkle = base.UpSparkle
			local sideSparkle = base.SideSparkle
			local wrapRings = base.WrapRings
			local rays = base.Rays
			local electricityWisp = base.ElectricityWisp
			clone.Parent = _WorldOrigin

			for i = 1, 3 do
				chime(position + Vector3.new(math.random(-30, 30), i * 4 + 10, math.random(-30, 30)), i / 10 + 1)
				wait(0.1)
			end

			local parent = Util.Sound:Play("GenericExplosion3", position, nil, 1, 2)
			local flangeSoundEffect = Instance.new("FlangeSoundEffect")
			flangeSoundEffect.Depth = 1
			flangeSoundEffect.Rate = 0.1
			flangeSoundEffect.Parent = parent
			local reverbSoundEffect = Instance.new("ReverbSoundEffect")
			reverbSoundEffect.Density = 0.55
			reverbSoundEffect.Parent = parent
			Util.Sound:Play("GenericExplosion2", position, nil, 1, 2)
			rays:Emit(math.random(8, 12))
			local clone2 = V.ExplBall:Clone()
			Util.Debris:AddItem(clone2, 15)
			clone2.Size = Vector3.new()
			clone2.Position = position
			clone2.Parent = _WorldOrigin
			local tween = TweenService:Create(
				clone2,
				TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Size = createVector(160, 160, 160)
				}
			)
			tween.Completed:Connect(function()
				local tween2 = TweenService:Create(
					clone2,
					TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
					{
						Transparency = 1,
						Size = createVector(150, 150, 150)
					}
				)
				tween2.Completed:Connect(function()
					clone2:Destroy()
				end)
				tween2:Play()
			end)
			tween:Play()
			table.insert(v, { 3, clone2 })
			local topAttachment = clone2.TopAttachment
			local bottomAttachment = clone2.BottomAttachment
			local v3 = exteriorBolt(topAttachment, bottomAttachment, -80, 80, math.random(15, 20))
			local v4 = exteriorBolt(topAttachment, bottomAttachment, 80, -80, math.random(15, 20))

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

			upSparkle:Emit(1)
			sideSparkle:Emit(1)
			emberDust.Enabled = true
			purpDiamonds.Enabled = true
			task.spawn(function()
				wait(3)
				emberDust.Enabled = false
				purpDiamonds.Enabled = false
			end)
			local v5 = 0.016666666666666666
			local now = tick()
			task.spawn(function()
				local now2 = tick()
				local now3 = tick()
				local now4 = tick()
				local now5 = tick()

				while true do
					local now6 = tick()
					local v6 = now6 - now

					if v6 > 3 then
						break
					end

					local _ = v6 / 3.5

					if v6 < 2 then
						if clone2 then
							topAttachment.Position = Vector3.new(0, clone2.Size.Y / 2, 0)
							bottomAttachment.Position = Vector3.new(0, -clone2.Size.Y / 2, 0)
						end

						if now6 - now5 > 0.05 then
							local v7 = v3
							local addTransparency = v3.AddTransparency
							v7.AddTransparency = addTransparency + (1 - addTransparency) * 0.04
							local v8 = v4
							local addTransparency2 = v4.AddTransparency
							v8.AddTransparency = addTransparency2 + (1 - addTransparency2) * 0.04
							electricityWisp:Emit(2)
						end

						if now6 - now2 > 0.7 then
							local resource = getResource("DomeShockwave", 2, {
								CFrame = CFrame.new(position + createVector(0, 75, 0)) * CFrame.Angles(
									0,
									math.rad((math.random(-180, 180))),
									0
								),
								Size = Vector3.new()
							})
							resource.Parent = _WorldOrigin
							table.insert(v, { 1, resource })
							local tween2 = TweenService:Create(
								resource,
								TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
								{
									Size = createVector(190, 30.5, 190),
									Transparency = 1
								}
							)
							tween2.Completed:Connect(function()
								resource:Destroy()
							end)
							tween2:Play()
							now2 = tick()
						end

						if now6 - now3 > 0.25 then
							wrapRings:Emit(1)
							local resource = getResource("Wind", 1.5, {
								CFrame = CFrame.new(position + createVector(0, 10, 0)) * CFrame.Angles(
									math.rad((math.random(-45, 45))),
									math.rad((math.random(-180, 180))),
									(math.rad((math.random(-45, 45))))
								),
								Size = Vector3.new(),
								Transparency = 0.2
							})
							resource.Parent = _WorldOrigin
							table.insert(v, { 2, resource })
							local tween2 = TweenService:Create(
								resource,
								TweenInfo.new(
									math.random(6, 8) / 10,
									Enum.EasingStyle.Sine,
									Enum.EasingDirection.Out,
									0,
									false,
									0
								),
								{
									Size = createVector(270, 30, 270),
									Transparency = 1,
									Color = Color3.fromRGB(221, 148, 30)
								}
							)
							tween2.Completed:Connect(function()
								resource:Destroy()
							end)
							tween2:Play()
							now3 = tick()
						end

						if now6 - now4 > 0.7 then
							local v7 = position + createVector(0, 2, 0)
							local ray, v8, _ = Util.Ray(
								v7,
								CFrame.new(v7, v7 - createVector(0, 1, 0)).lookVector.Unit * 100,
								{ workspace.Characters, workspace.Enemies },
								false
							)

							if ray then
								local resource = getResource("BlastWave", 2, {
									CFrame = CFrame.new(v8 + createVector(0, 51, 0)) * CFrame.Angles(
										0,
										math.rad((math.random(-180, 180))),
										0
									),
									Size = createVector(1, 100, 1)
								})
								resource.Parent = _WorldOrigin
								table.insert(v, { 0, resource })
								local tween2 = TweenService:Create(
									resource,
									TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
									{
										Size = createVector(290, 1, 290),
										Transparency = 1,
										Position = resource.Position - createVector(0, 50, 0)
									}
								)
								tween2.Completed:Connect(function()
									resource:Destroy()
								end)
								tween2:Play()
							end

							now4 = tick()
						end
					end

					if #v > 0 then
						local v7 = v5 * 60

						for k, v8 in pairs(v) do
							if v8[2] == nil then
								table.remove(v, k)
							elseif v8[1] == 0 then
								v8[2].CFrame *= CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(v7 * 1), 0)
							elseif v8[1] == 1 then
								v8[2].CFrame *= CFrame.new(0, v7 * -0.5, 0) * CFrame.Angles(0, math.rad(v7 * 1), 0)
							elseif v8[1] == 2 then
								v8[2].CFrame *= CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(v7 * -35), 0)
							elseif v8[1] == 3 then
								v8[2].CFrame *= CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(v7 * -5), 0)
							end
						end
					end

					v5 = RunService.RenderStepped:Wait()
				end

				if #v > 0 then
					for _, v6 in pairs(v) do
						if v6[2] then
							v6[2]:Destroy()
						end
					end
				end

				v = nil

				if v3 then
					v3:Destroy()
				end

				if v4 then
					v4:Destroy()
				end
			end)
		end)
	end
end