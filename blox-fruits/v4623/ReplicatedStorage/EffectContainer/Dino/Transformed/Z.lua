local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.MasterClock
local _ = Util.BoatTween
local debris = Util.Debris
local sound = Util.Sound
local _ = Util.PartCache
local player = nil
local _ = Util.CameraShaker
local FX = require(game.ReplicatedStorage.FX)
local Z = FX:WaitForChild("Dino").Transformed.Z

local function GetNumberDependingDistance(p, p2, p3, p4, p5)
	if p <= p4 then
		return p2
	end

	if p4 < p and p <= p5 then
		return p2 + (p3 - p2) * ((p - p4) / (p5 - p4))
	end

	return p3
end

local function TailWhip(folder, humanoidRootPart, data)
	local multiplier = data.Multiplier
	local slashAngle = data.SlashAngle
	local slashAngle2 = data.SlashAngle2
	local yPosition = data.YPosition
	local clone = data.SlashType:Clone()
	debris:AddItem(clone, 2)
	clone.CFrame = humanoidRootPart.CFrame
	clone.Weld.Part0 = humanoidRootPart
	clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.new(0, yPosition, 0) * slashAngle * slashAngle2
	Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.CurveSize0 *= multiplier
			descendant.CurveSize1 *= multiplier
			descendant.Width0 *= multiplier
			descendant.Width1 *= multiplier
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * multiplier,
				descendant.Position.Y * multiplier,
				descendant.Position.Z * multiplier
			)
		end
	end

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.Enabled = true
			local startDelay = descendant:GetAttribute("StartDelay")
			local v = descendant
			local v2 = descendant:GetAttribute("EndDelay")
			task.spawn(function()
				local tween = TweenService:Create(
					v,
					TweenInfo.new(v2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v.Width0 * 1.5,
						Width1 = v.Width1 * 1.5,
						CurveSize0 = v.CurveSize0 * 1.5,
						CurveSize1 = v.CurveSize1 * 1.5
					}
				)
				v.Width0 = 0
				v.Width1 = 0
				task.wait(startDelay)
				tween:Play()
			end)
		elseif descendant:IsA("Attachment") then
			TweenService:Create(descendant, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = Vector3.new(
					descendant.Position.X * 1.5,
					descendant.Position.Y * 1.5,
					descendant.Position.Z * 1.5
				)
			}):Play()
		end
	end

	for _ = 1, 3 do
		local tween = TweenService:Create(
			clone.Weld,
			TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * CFrame.Angles(
					0,
					1.0471975511965976,
					0
				)
			}
		)
		tween:Play()
		tween.Completed:Wait()
	end

	clone.Weld.Enabled = false
	clone.Anchored = true
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.Angles(0, 1.3089969389957472, 0)
	}):Play()

	for _, effect in ipairs(clone:GetDescendants()) do
		if effect:IsA("Beam") then
			local v = effect
			task.spawn(function()
				local endDelay = v:GetAttribute("EndDelay")
				local tween = TweenService:Create(
					v,
					TweenInfo.new(endDelay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween:Play()
				tween.Completed:Wait()
				v:Destroy()
			end)
		elseif effect:IsA("ParticleEmitter") then
			effect.Enabled = false
		end
	end
end

local function StartProjectileSlash(p, folder, lifetime)
	local v = math.random(10, 35) / 10
	local clone = Z.ProjectileSlash:Clone()
	debris:AddItem(clone, 2)

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("Beam") then
			descendant.CurveSize0 *= v
			descendant.CurveSize1 *= v
			descendant.Width0 *= v
			descendant.Width1 *= v
		elseif descendant:IsA("Attachment") then
			descendant.Position = Vector3.new(
				descendant.Position.X * v,
				descendant.Position.Y * v,
				descendant.Position.Z * v
			)
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Enabled = true

			if descendant:GetAttribute("Scale") then
				descendant.Size = NumberSequence.new(descendant:GetAttribute("Scale") * v)
			end
		elseif descendant:IsA("BasePart") then
			descendant.Size = Vector3.new(descendant.Size.X * v, descendant.Size.Y * v, descendant.Size.Z * v)
		end
	end

	clone.CFrame = p * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
	Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")

	for _, beam in ipairs(clone:GetDescendants()) do
		if beam:IsA("Beam") then
			beam.Enabled = true
		end
	end

	local v2 = math.rad((math.random(-25, 25)))
	local v3 = math.rad((math.random(-25, 25)))
	local v4 = math.random(10, 20) / 10
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(lifetime / v4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{
			CFrame = clone.CFrame * CFrame.new(0, 0, -300) * CFrame.Angles(v2, 0, v3)
		}
	)
	tween:Play()
	tween.Completed:Wait()
	local clone2 = Z.ProjectileImpact:Clone()
	debris:AddItem(clone2, 5)
	clone2.CFrame = clone.CFrame
	Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")
	sound:Play("Tail Slash- Explosion", clone.Position, nil, 1 + math.random(-15, 15) / 100, 1)
	clone:Destroy()

	for _, emitter in ipairs(clone2:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v5 = emitter
		task.spawn(function()
			if v5:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v5:GetAttribute("EmitDelay"))
			end

			v5:Emit(v5:GetAttribute("EmitCount"))
		end)
	end
end

local function GroundClawSlash(cFrame, _, folder)
	local v = 1.5
	local v2 = 15

	for i = 1, 2 do
		local v3 = i
		task.spawn(function()
			local clone = nil

			if v3 == 1 then
				v = math.random(25, 35) / 10
				clone = Z.GroundSlash:Clone()
			elseif v3 == 2 then
				v2 *= 1.85
				v = 2
				clone = Z.GroundSlash2:Clone()
			end

			debris:AddItem(clone, 6)
			clone.CFrame = cFrame
			clone.Orientation = Vector3.new(0, clone.Orientation.Y, clone.Orientation.Z)
			clone.CFrame *= CFrame.new(0, 0, -v2 * v)
			Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")
			cFrame = clone.CFrame

			for i2, descendant in ipairs(clone:GetDescendants()) do
				if descendant:IsA("Beam") then
					descendant.CurveSize0 *= v
					descendant.CurveSize1 *= v
					descendant.Width0 *= v * 1.5
					descendant.Width1 *= v * 1.5
				elseif descendant:IsA("Attachment") then
					descendant.Position = Vector3.new(
						descendant.Position.X * v,
						descendant.Position.Y * v,
						descendant.Position.Z * v
					)
				elseif descendant:IsA("ParticleEmitter") then
					descendant.Enabled = true
				end
			end

			for i2, beam in ipairs(clone:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = true
				local startDelay = beam:GetAttribute("StartDelay")
				local v4 = beam
				local v5 = beam:GetAttribute("EndDelay")
				task.spawn(function()
					local tween = TweenService:Create(
						v4,
						TweenInfo.new(v5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
						{
							Width0 = v4.Width0,
							Width1 = v4.Width1
						}
					)
					v4.Width0 = 0
					v4.Width1 = 0
					task.wait(startDelay)
					tween:Play()
					task.wait(v5)
					local tween2 = TweenService:Create(
						v4,
						TweenInfo.new(v5 / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Width0 = 0,
							Width1 = 0
						}
					)
					tween2:Play()
					tween2.Completed:Wait()
					v4:Destroy()
				end)
			end

			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					CFrame = clone.CFrame * CFrame.Angles(-2.0943951023931953, 0, 0)
				}
			)
			tween:Play()
			tween.Completed:Wait()
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				CFrame = clone.CFrame * CFrame.Angles(-2.2689280275926285, 0, 0)
			}):Play()
		end)
		task.wait(0.125)
	end
end

return function(player2)
	player = player2.player
	local ID = player2.ID

	if ID == 1 then
		return
	end

	if ID == 2 then
		local endPosition = player2.EndPosition
		local character = player2.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 1000 then
				return
			end

			local folder = Instance.new("Folder", workspace._WorldOrigin)
			Util.Debris:AddItem(folder, 7)
			local cFrame = CFrame.new(humanoidRootPart.Position, endPosition) * CFrame.new(0, 0, -5)
			sound:Play("DinoZProjectile", cFrame.Position, nil, 1.5, 1)
			sound:Play("Transformed- Tail Slash", cFrame.Position, nil, 1.5 + math.random(-15, 15) / 100, 1)
			local clone = Z.TailSpin:Clone()
			clone.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone, folder, player, "TRexFruitVFXColor")

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			local total = 0
			local total2 = 0

			for _ = 1, 3 do
				task.spawn(function()
					task.wait(math.random(10, 100) / 1000)
					total += 0.125
					total2 += 3
					TailWhip(folder, humanoidRootPart, {
						Multiplier = total + 2,
						SlashAngle = CFrame.Angles(0, math.rad((math.random(-170, -150))), 0),
						SlashAngle2 = CFrame.Angles(math.rad((math.random(1, 5))), 0, (math.rad(total2))),
						YPosition = math.random(-30, 30) / 100,
						SlashType = Z.TailWhipSlash
					})
				end)
			end

			task.spawn(function()
				task.wait(0.1)
				local clone2 = Z.StartImpact:Clone()
				clone2.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v2 = emitter
					task.spawn(function()
						if v2:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v2:GetAttribute("EmitDelay"))
						end

						v2:Emit(v2:GetAttribute("EmitCount"))
					end)
				end

				TailWhip(folder, humanoidRootPart, {
					Multiplier = 2,
					SlashAngle = CFrame.Angles(0, 1.5707963267948966, 0),
					SlashAngle2 = CFrame.Angles(0, 0, 0),
					YPosition = -10,
					SlashType = Z.SmallTailWhipSlash
				})
			end)
			task.spawn(function()
				task.wait(0.15)
				TailWhip(folder, humanoidRootPart, {
					Multiplier = 3,
					SlashAngle = CFrame.Angles(0, -2.443460952792061, 0),
					SlashAngle2 = CFrame.Angles(0, 0, 0.3490658503988659),
					YPosition = 0,
					SlashType = Z.FinalTailWhipSlash
				})

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
			task.wait(0.1)

			for i = 1, 5 do
				local v2 = i
				task.spawn(function()
					local v3 = cFrame * CFrame.new(0, 0, -3)
					local v4

					if v2 == 1 then
						v4 = -0.6108652381980153
					elseif v2 == 2 then
						v4 = -0.30543261909900765
					elseif v2 == 3 then
						v4 = 0
					elseif v2 == 4 then
						v4 = 0.30543261909900765
					elseif v2 == 5 then
						v4 = 0.6108652381980153
					else
						v4 = nil
					end

					local cFrame2 = v3 * CFrame.Angles(0, v4, 0)
					local position = cFrame2.Position
					local ray, v6, v7 = Util.Ray(
						position + createVector(0, 1, 0),
						CFrame.new(position).UpVector * -25,
						{ workspace.Characters, workspace.Enemies },
						false
					)

					if ray then
						local v8 = v6 + createVector(0, 5, 0)
						task.spawn(function()
							local clone2 = Z.GroundSlashSpark:Clone()
							clone2.CFrame = cFrame2
							clone2.Orientation = Vector3.new(0, clone2.Orientation.Y, clone2.Orientation.Z)
							clone2.Position = v8 + createVector(0, -6, 0)
							Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")

							for i2, emitter in pairs(clone2:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end

							local tween = TweenService:Create(
								clone2,
								TweenInfo.new(0.225, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
								{
									Position = clone2.CFrame * CFrame.new(0, 0, -110).Position
								}
							)
							clone2.CFrame *= CFrame.Angles(-0.5235987755982988, 0, 0)
							tween:Play()
							tween.Completed:Wait()

							for i2, emitter in pairs(clone2:GetDescendants()) do
								if not emitter:IsA("ParticleEmitter") then
									continue
								end

								if emitter:GetAttribute("Color") then
									emitter.Color = ColorSequence.new(ray.Color, ray.Color)
								end

								emitter.Enabled = false
							end

							local clone3 = Z.GroundSparkEnd:Clone()
							clone3.CFrame = clone2.CFrame
							Util.SetParentOverrideWithColor(clone3, folder, player, "TRexFruitVFXColor")

							for i2, emitter in pairs(clone3:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end
						end)
						GroundClawSlash(cFrame2, v8, folder)
					end
				end)
			end

			local position = cFrame.Position
			local ray, v2, _ = Util.Ray(
				position + createVector(0, 1, 0),
				CFrame.new(position).UpVector * -25,
				{ workspace.Characters, workspace.Enemies },
				false
			)

			if ray then
				local clone2 = Z.GroundSmoke:Clone()
				clone2.CFrame = CFrame.new(v2)
				Util.SetParentOverrideWithColor(clone2, folder, player, "TRexFruitVFXColor")

				for _, emitter in pairs(clone2:GetDescendants()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v3 = emitter
					task.spawn(function()
						if v3:GetAttribute("EmitDelay") ~= 0 then
							task.wait(v3:GetAttribute("EmitDelay"))
						end

						if v3:GetAttribute("Color") then
							v3.Color = ColorSequence.new(ray.Color, ray.Color)
						end

						v3:Emit(v3:GetAttribute("EmitCount"))
					end)
				end
			end

			for _ = 1, 10 do
				local v3 = cFrame * CFrame.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
				local v4 = math.rad((math.random(-5, 5)))
				local v5 = math.rad((math.random(-15, 15)))
				local v6 = math.rad((math.random(-5, 5)))
				local v7 = v3 * CFrame.Angles(v4, v5, v6)
				task.spawn(function()
					task.wait(math.random(10, 100) / 1000)
					StartProjectileSlash(v7, folder, player2.Lifetime)
				end)
			end
		end
	end
end