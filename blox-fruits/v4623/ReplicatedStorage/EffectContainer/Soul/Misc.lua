local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local misc = FX:WaitForChild("Soul").Misc
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.Debris
local lightningBolt = Util.LightningBolt

function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

local function cloud(cframe, clone, p)
	local clone2 = clone:Clone()
	Util.Debris:AddItem(clone2, p + 10)
	local inner = clone2.Inner
	local outer = clone2.Outer
	inner.Color = Color3.fromRGB(89, 16, 179)
	outer.Color = Color3.fromRGB(90, 65, 173)
	inner.Size = createVector(0, 0, 0)
	outer.Size = createVector(0, 0, 0)
	clone2:SetPrimaryPartCFrame(cframe)
	clone2.Parent = _WorldOrigin

	for _, child in pairs(clone2:GetChildren()) do
		local tween = TweenService:Create(
			child,
			TweenInfo.new(p * 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0),
			{
				Size = child.Name == "Inner" and createVector(134.625, 114.625, 134.625) or createVector(
					139.079,
					119.079,
					139.079
				),
				Transparency = 1
			}
		)
		local tween2 = TweenService:Create(
			child,
			TweenInfo.new(p * 2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				Orientation = child.Orientation + createVector(0, 150, 0)
			}
		)
		tween.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween:Play()
		tween2:Play()
	end

	return clone2
end

return function(data)
	local effectID = data.EffectID

	if typeof(data.HitRoot) == "table" then
		return
	end

	if effectID == 1 then
		local hitRoot = data.HitRoot
		Util.Sound:Play("ElectricBounce", hitRoot, nil, math.random(9, 15) / 10, 1)
		local clone = misc.SoulBallHitFX.At:Clone()
		Util.Debris:AddItem(clone, 1)
		clone.Parent = hitRoot
		clone.Diamond:Emit(1)
		clone.Flares:Emit(2)
		clone.Star:Emit(1)
	elseif effectID == 2 then
		local victimRoot = data.VictimRoot
		local victimHum = data.VictimHum
		local duration = data.Duration

		if victimRoot and victimHum then
			Util.Sound:Play("ElectricZap", victimRoot, nil, math.random(9, 15) / 10, 0.4)
			local clone = misc.LightningGlow:Clone()
			clone.Parent = victimRoot
			local clone2 = misc.Sparks:Clone()
			clone2.Parent = victimRoot
			local clone3 = misc.Lightning:Clone()
			clone3.Parent = victimRoot
			Util.Debris:AddItem(clone, duration + 2)
			Util.Debris:AddItem(clone2, duration + 2)
			Util.Debris:AddItem(clone3, duration + 2)
			task.spawn(function()
				wait(duration)

				if clone then
					clone.Enabled = false
				end

				if clone2 then
					clone2.Enabled = false
				end

				if clone3 then
					clone3.Enabled = false
				end
			end)
		end
	elseif effectID == 3 then
		local startRoot = data.StartRoot
		local endRoot = data.EndRoot
		local duration = data.Duration

		if startRoot and endRoot then
			if (endRoot.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
				return
			end

			Util.Sound:Play("Hit1Electric", endRoot, nil, math.random(9, 13) / 10, 0.3)
			local equalizerSoundEffect = Instance.new("EqualizerSoundEffect")
			equalizerSoundEffect.HighGain = 0
			equalizerSoundEffect.LowGain = 10
			task.spawn(function()
				local attachment = Instance.new("Attachment")
				attachment.Parent = startRoot
				Util.Debris:AddItem(attachment, 2)
				local attachment2 = Instance.new("Attachment")
				attachment2.Parent = endRoot
				Util.Debris:AddItem(attachment2, 2)
				local v = lightningBolt.new(
					attachment,
					attachment2,
					math.random(-20, 20),
					math.random(-20, 20),
					math.random(15, 20),
					Color3.fromRGB(119, 0, 255)
				)
				v.Color = Color3.fromRGB(119, 0, 255)
				v.AnimationSpeed = 15
				v.Thickness = 0.5
				local clone = misc.Orbs:Clone()
				clone.Parent = attachment2
				local clone2 = misc.Spikes:Clone()
				clone2.Parent = attachment2
				clone:Emit(15)
				clone2:Emit(15)
				wait(duration)

				if v then
					v:Destroy()
				end
			end)
		end
	elseif effectID == 4 then
		local hitRoot = data.HitRoot

		if hitRoot then
			if (hitRoot.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
				return
			end

			Util.Sound:Play("ShortExplosion", hitRoot, nil, math.random(9, 13) / 10, 1)
			local equalizerSoundEffect = Instance.new("EqualizerSoundEffect")
			equalizerSoundEffect.HighGain = 0
			equalizerSoundEffect.LowGain = 10
			local clone = misc.SunHitFX.Attachment:Clone()
			Util.Debris:AddItem(clone, 1)
			clone.Parent = hitRoot

			for _, child in pairs(clone:GetChildren()) do
				child:Emit(1)
			end
		end
	elseif effectID == 5 then
		local hitRoot = data.HitRoot

		if hitRoot then
			if (hitRoot.Position - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
				return
			end

			Util.Sound:Play("Hit1Electric", hitRoot, nil, math.random(9, 13) / 10, 1)
			local equalizerSoundEffect = Instance.new("EqualizerSoundEffect")
			equalizerSoundEffect.HighGain = 0
			equalizerSoundEffect.LowGain = 10
			local clone = misc.CloudHitFX.Attachment:Clone()
			Util.Debris:AddItem(clone, 1)
			clone.Parent = hitRoot

			for _, child in pairs(clone:GetChildren()) do
				child:Emit(1)
			end
		end
	elseif effectID == 6 then
		local spawnPosition = data.SpawnPosition

		if (spawnPosition - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		end

		Util.Sound:Play("TreeRoot", spawnPosition, nil, math.random(15, 16) / 10, 1)
		local clone = misc.Vine:Clone()
		Util.Debris:AddItem(clone, 8)
		clone.CFrame = CFrame.new(spawnPosition - createVector(0, 15, 0)) * CFrame.Angles(
			0,
			math.rad((math.random(0, 360))),
			0
		)
		clone.Mesh.Scale = Vector3.new()
		clone.Parent = _WorldOrigin
		local tween = TweenService:Create(
			clone,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
			{
				CFrame = clone.CFrame * CFrame.new(0, 25, 0) * CFrame.Angles(0, 2.181661564992912, 0)
			}
		)
		local tween2 = TweenService:Create(
			clone.Mesh,
			TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
			{
				Scale = createVector(14.333, 25.333, 14.333)
			}
		)
		tween.Completed:Connect(function()
			wait(1.5)
			local tween3 = TweenService:Create(
				clone,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
				{
					Transparency = 1,
					Position = clone.Position - createVector(0, 10, 0)
				}
			)
			tween3.Completed:Connect(function()
				if clone then
					clone:Destroy()
				end
			end)
			tween3:Play()
		end)
		tween2:Play()
		tween:Play()
	elseif effectID == 7 then
		local spawnPosition = data.SpawnPosition
		local lifetime = data.Lifetime
		local timestamp = data.Timestamp

		if (spawnPosition - workspace.CurrentCamera.CFrame.p).magnitude > 900 then
			return
		else
			task.spawn(function()
				local outerColor = data.OuterColor
				local innerColor = data.InnerColor
				local clone = misc.ToxicCloudModel:Clone()
				Util.Debris:AddItem(clone, lifetime + 10)
				local clone2 = clone.Cloud:Clone()
				clone.Cloud:Destroy()
				local core = clone.Core
				local uprightSmog = core.ParticleAttachment.UprightSmog
				local dots = core.Dots
				clone.Parent = _WorldOrigin
				local v = {}
				table.insert(v, (cloud(CFrame.new(spawnPosition), clone2, 2, innerColor, outerColor)))
				uprightSmog.Enabled = true
				local v2 = Util.MasterClock:GetTime() - timestamp
				local lastTime = tick()
				tick()
				local now = tick() - 0.8
				local v3 = lifetime - v2
				local v4 = {}
				local total = 0
				local v5 = 0.016666666666666666

				while tick() - lastTime <= v3 do
					if tick() - now > 0.8 then
						table.insert(
							v,
							(cloud(
								CFrame.new(spawnPosition) * CFrame.Angles(0, math.random(-180, 180), 0),
								clone2,
								2,
								innerColor,
								outerColor
							))
						)
						now = tick()
					end

					if #v4 > 0 then
						for k, part in pairs(v4) do
							if part:IsA("BasePart") then
								part.Position = core.Position
							elseif part[1] ~= nil and part[1].PrimaryPart ~= nil then
								part[1]:SetPrimaryPartCFrame(part[1].PrimaryPart.CFrame * CFrame.new(
									0,
									k / 80,
									-part[2]
								))
								part[2] *= 0.95
							end
						end
					end

					if #v > 0 then
						for _, v6 in pairs(v) do
							if v6 ~= nil and v6.PrimaryPart ~= nil then
								v6:SetPrimaryPartCFrame(CFrame.new(spawnPosition) * CFrame.Angles(0, math.rad(total), 0))
							end
						end
					end

					clone:SetPrimaryPartCFrame(CFrame.new(spawnPosition - createVector(0, 2, 0)) * CFrame.Angles(
						0,
						math.rad(total),
						0
					))
					total += 2 / (tick() - lastTime) * v5 * 60
					v5 = RunService.RenderStepped:Wait()
				end

				uprightSmog.Enabled = false
				dots.Enabled = false
				wait(5)
				clone:Destroy()
				clone2:Destroy()
			end)
		end
	end
end