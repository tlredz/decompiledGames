local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local FX = require(ReplicatedStorage.FX)
local mammoth = FX:WaitForChild("Mammoth")

local function punt1(plr, hrp, hold)
	local v = hrp.Size.Y * 0.5 + hrp.Parent.Humanoid.HipHeight + 9
	local accessory = Instance.new("Accessory")
	accessory.Name = "MammothAccessory"
	accessory.Parent = plr.Character
	local clone = mammoth.MammothSilhouette:Clone()

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail()
		for _, part in pairs(clone:GetChildren()) do
			if part:IsA("MeshPart") then
				TweenService:Create(part, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
					Transparency = 1
				}):Play()
			end
		end
	end

	local primaryPart = clone.PrimaryPart
	local body = clone.body
	local animationController = clone.AnimationController
	local clone2 = mammoth.tusks:Clone()
	primaryPart.CFrame = hrp.CFrame
	clone.Parent = accessory
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = primaryPart
	motor6D.Part1 = hrp
	motor6D.C0 = motor6D.Part1.CFrame:inverse()
	motor6D.C1 = motor6D.Part1.CFrame:inverse() * CFrame.new(0, -8, 0)
	motor6D.Name = "RigWeld"
	motor6D.Parent = primaryPart
	local clone3 = mammoth.FormEmit:Clone()
	local lookVector = hrp.CFrame.LookVector
	local v2 = hrp.Position + lookVector * 1
	local rayMap, v3, v4 = Util.RayMap(v2, createVector(0, -1, 0) * v)

	if rayMap then
		local v5 = v4 * 0.1
		local _ = hrp.CFrame
		clone3.CFrame = CFrame.new(v3, v3 + v5) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone3.Parent = _WorldOrigin
		Util.Debris:AddItem(clone3, 3)
		task.spawn(function()
			local descendants = clone3:GetDescendants()
			local v6 = {}

			for k, emitter in pairs(descendants) do
				if emitter:IsA("ParticleEmitter") then
					v6[k] = {
						count = emitter:GetAttribute("EmitCount") or 0,
						delay = emitter:GetAttribute("EmitDelay") or 0
					}
				end
			end

			for k, descendant in pairs(descendants) do
				if not v6[k] then
					continue
				end

				if v6[k].delay > 0 then
					local v7 = descendant
					local v8 = k
					task.delay(v6[k].delay, function()
						v7:Emit(v6[v8].count)
					end)
				else
					descendant:Emit(v6[k].count)
				end
			end
		end)
	end

	for _, part in pairs(clone:GetChildren()) do
		if part:IsA("MeshPart") and part.Name ~= "eye" then
			TweenService:Create(
				part,
				TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In, 0, false, 0),
				{
					Transparency = 0
				}
			):Play()
		end
	end

	local thread = task.delay(0.2, function()
		clone.eyeL.EyeL.Eye.Enabled = true
		clone.eyeL.EyeL.EYEGLOW:Emit(3)
		clone.eyeR.EyeR.Eye.Enabled = true
		clone.eyeR.EyeR.EYEGLOW:Emit(3)
	end)

	while hold and hold.Value and hold.Parent and hold.Parent:IsDescendantOf(workspace) do
		wait()
	end

	local flag = false

	if hold and hold.Parent then
		for _ = 1, 100 do
			task.wait(0.03333333333333333)

			if not plr.Character:FindFirstChild("MAMMOTH_X") then
				continue
			end

			plr.Character.MAMMOTH_X.Name = "DESTROYING"
			flag = true
			break
		end
	end

	Util.Debris:AddItem(accessory, 2)
	Util.Debris:AddItem(clone, 4)

	if flag then
		Util.Sound:Play("MammothSpawn", hrp, nil, 1 + math.random(-5, 5) / 100, 2.5)
		Util.Anims:Get(clone, "MammothXUntrans"):Play()
		body.aura1.Enabled = true
		body.aura2.Enabled = true
		body.BLACKTRAIL.Trail.Enabled = true
		clone.exp.Size = createVector(26.202, 4.679, 31.044)
		clone.exp.FR2.Enabled = true
		clone.exp.FR3.Enabled = true
		task.spawn(function()
			local children = body.dashstart:GetChildren()
			local v5 = {}

			for k, v6 in pairs(children) do
				v5[k] = {
					count = v6:GetAttribute("EmitCount") or 0,
					delay = v6:GetAttribute("EmitDelay") or 0
				}
			end

			for k, v6 in pairs(children) do
				if v5[k].delay > 0 then
					local v7 = k
					local v8 = v6
					task.spawn(function()
						task.wait(v5[v7].delay)
						v8:Emit(v5[v7].count)
					end)
				else
					v6:Emit(v5[k].count)
				end
			end
		end)
		task.spawn(function()
			body.SiloTrail.dust2.Lifetime = NumberRange.new(0.19, 0.2)
			local lastTime = tick()

			while tick() - lastTime < 0.36666666666666664 do
				task.wait(0.016666666666666666)
				body.SiloTrail.dust2:Emit(3)
			end
		end)
		task.spawn(function()
			task.wait(0.058)

			for _, child in pairs(clone.exp.beams3:GetChildren()) do
				child.Enabled = true
				TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Width1 = 13.799,
					Width0 = 3.067
				}):Play()
			end

			for _, child in pairs(clone.exp.beams2:GetChildren()) do
				child.Enabled = true
				TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Width1 = 22.999,
					Width0 = 3.067
				}):Play()
			end

			for _, child in pairs(clone.exp.beams1:GetChildren()) do
				child.Enabled = true
				TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
					Width1 = 0,
					Width0 = 18.399
				}):Play()
			end

			clone.exp.Sparks2.Enabled = true
			clone.exp.Sparks3.Enabled = true
			local clone4 = mammoth.Shockwave:Clone()
			local clone5 = mammoth.Shockwave2:Clone()
			clone4.CFrame = hrp.CFrame * CFrame.new(-8, 0, 15)
			clone4.Parent = _WorldOrigin
			clone5.CFrame = hrp.CFrame * CFrame.new(8, 0, 15)
			clone5.Parent = _WorldOrigin
			Util.Debris:AddItem(clone4, 1)
			Util.Debris:AddItem(clone5, 1)
			TweenService:Create(clone4, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(12.429, 35.5, 137.286)
			}):Play()
			TweenService:Create(clone4, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = clone4.CFrame * CFrame.new(-14, 0, -95)
			}):Play()
			TweenService:Create(clone4, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(12.429, 35.5, 137.286)
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = clone5.CFrame * CFrame.new(14, 0, -95)
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
		Util.Sound:Play("Tackle", hrp, nil, 1 + math.random(-10, 10) / 100, 2.5)

		if plr == game.Players.LocalPlayer then
			animationController:LoadAnimation(script.MammothPunt):Play()
		end

		body.WINDTRAIL4.Trail2.Enabled = true
		body.WINDTRAIL1.Trail2.Enabled = true
		body.t2.Trail2.Enabled = true
		task.spawn(function()
			task.wait(0.07)

			for _ = 1, 3 do
				task.wait(0.038)

				for _, child in pairs(body.emit:GetChildren()) do
					child:Emit(child:GetAttribute("EmitCount"))
				end

				for _, child in pairs(body.runemit:GetChildren()) do
					if child.Name == "third" then
						child:Destroy()
					else
						child.LockedToPart = true
						child.Speed = NumberRange.new(65, 90)
						child:Emit(child:GetAttribute("EmitCount"))
					end
				end
			end
		end)
		task.spawn(function()
			task.wait(0.2)
			local position = hrp.Position
			local rayMap2, v5, _ = Util.RayMap(position, createVector(0, -1, 0) * v)

			if rayMap2 then
				local function groundEffects(_, rayMap3)
					if rayMap3 then
						body.emitground.Rocks.Color = ColorSequence.new(rayMap3.Color)
						body.emitground.SlashSmoke.Color = ColorSequence.new(rayMap3.Color)
						body.emitground.SlashSmoke:Emit(16)
						body.emitground.Rocks:Emit(8)
					end
				end

				groundEffects(v5, rayMap2)
			end
		end)
		Util.Sound:Play("port2", hrp, nil, 1 + math.random(-5, 5) / 100, 3)
		task.wait(0.23)
		clone2.CFrame = hrp.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 1.5707963267948966, -0.7853981633974483)
		clone2.Parent = _WorldOrigin
		Util.Debris:AddItem(clone2, 3)
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Parent = clone2
		weldConstraint.Part0 = hrp
		weldConstraint.Part1 = clone2
		TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			CFrame = hrp.CFrame * CFrame.new(0, 8, -19) * CFrame.Angles(1.3962634015954636, 1.5707963267948966, 0),
			Size = createVector(47.892, 47.892, 24.503)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
			Transparency = 1
		}):Play()
		Util.Sound:Play("MammothDebris", clone2.Position, nil, 1 + math.random(-5, 5) / 100, 3)
		Util.Sound:Play("MammothDashHit", clone2.Position, nil, 1 + math.random(-5, 5) / 100, 4)

		for _, child in pairs(clone.exp.beams1:GetChildren()) do
			TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Width1 = 0,
				Width0 = 0
			}):Play()
		end

		for _, child in pairs(clone.exp.beams2:GetChildren()) do
			TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Width1 = 0,
				Width0 = 0
			}):Play()
		end

		for _, child in pairs(clone.exp.beams3:GetChildren()) do
			TweenService:Create(child, TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Width1 = 0,
				Width0 = 0
			}):Play()
		end

		if plr == game.Players.LocalPlayer then
			Util.CameraShaker:ShakeOnce(11, 12, 0.1, 1, createVector(1, 1, 1), createVector(2.2, 2.1, 2.1))
			task.spawn(function()
				task.wait(0.23)
				local clone4 = script.LTN:Clone()
				clone4.Parent = game.Lighting
				Util.Debris:AddItem(clone4, 2)
				TweenService:Create(clone4, TweenInfo.new(0.013), {
					TintColor = Color3.fromRGB(255, 146, 146),
					Brightness = 0.3,
					Contrast = 1,
					Saturation = -1
				}):Play()
				task.wait(0.013)
				TweenService:Create(clone4, TweenInfo.new(0.01), {
					TintColor = Color3.fromRGB(86, 3, 3),
					Brightness = 0.3,
					Contrast = 0,
					Saturation = 0
				}):Play()
				task.wait(0.01)
				TweenService:Create(clone4, TweenInfo.new(0.01), {
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = -0.15,
					Contrast = 1,
					Saturation = -1
				}):Play()
				task.wait(0.01)
				TweenService:Create(clone4, TweenInfo.new(0.12), {
					TintColor = Color3.fromRGB(255, 255, 255),
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				}):Play()
				Util.Debris:AddItem(clone4, 1)
			end)
		end

		clone.exp.FR2.Enabled = false
		clone.exp.FR3.Enabled = false
		task.wait(0.15)
		clone.exp.Sparks2.Enabled = false
		clone.exp.Sparks3.Enabled = false
		body.frontemit.Hit2:Emit(2)

		for _, child in pairs(clone2.emit:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		clone2.Attachment1.Effect:Emit(3)
		clone2.Attachment2.Effect:Emit(3)
		body.t2.Trail2.Enabled = false
		body.WINDTRAIL4.Trail2.Enabled = false
		body.WINDTRAIL1.Trail2.Enabled = false
		body.aura1.Enabled = false
		body.aura2.Enabled = false
		local clone4 = mammoth.SlamTrunkPart:Clone()
		task.spawn(function()
			local lookVector2 = plr.Character.PrimaryPart.CFrame.LookVector
			local v5 = hrp.Position + lookVector2 * 13.5
			local rayMap2, v6, v7 = Util.RayMap(v5, createVector(0, -1, 0) * v)

			if rayMap2 then
				local _ = v7 * 0.1
				local _ = hrp.CFrame
				clone4.CFrame = Util.Misc.AlignCFrame(CFrame.new(v6, v6 + lookVector2), v7)
				clone4.Parent = _WorldOrigin
				Util.Debris:AddItem(clone4, 1.5)
				clone4.Decal.Transparency = 1
				local clone5 = mammoth.ground1:Clone()
				local clone6 = mammoth.ground2:Clone()
				clone5.CFrame = clone4.CFrame * CFrame.new(-6.3, 0, -10) * CFrame.Angles(0, 0, -3.141592653589793)
				clone6.CFrame = clone4.CFrame * CFrame.new(6.3, 0, -10) * CFrame.Angles(0, 0, -3.141592653589793)
				clone5.BrickColor = rayMap2.BrickColor
				clone5.Material = rayMap2.Material
				clone6.BrickColor = rayMap2.BrickColor
				clone6.Material = rayMap2.Material
				clone5.Anchored = true
				clone6.Anchored = true
				clone5.Parent = _WorldOrigin
				clone6.Parent = _WorldOrigin
				Util.Debris:AddItem(clone5, 4)
				Util.Debris:AddItem(clone6, 4)
				TweenService:Create(clone5, TweenInfo.new(3.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
					CFrame = clone5.CFrame * CFrame.new(0, 4, 0),
					Size = createVector(1.988, 1.612, 13.606)
				}):Play()
				TweenService:Create(clone6, TweenInfo.new(3.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
					CFrame = clone6.CFrame * CFrame.new(0, 4, 0),
					Size = createVector(1.988, 1.612, 13.606)
				}):Play()
				task.spawn(function()
					task.wait(0.08)
					local _, _ = Util.RayMap(hrp.Position, createVector(0, -1, 0) * v)

					for _ = 1, 8 do
						local clone7 = mammoth.Rock:Clone()
						clone7.Size = Vector3.new(math.random(1.5, 2), math.random(1.5, 3), math.random(1.5, 2))
						clone7.Position = clone4.Position + hrp.CFrame.LookVector * 15 + createVector(0, 2, 0)
						clone7.CFrame = CFrame.new(clone7.Position)
						clone7.Anchored = false
						clone7.CanCollide = false
						clone7.Parent = workspace
						clone7.BrickColor = rayMap2.BrickColor
						clone7.Material = rayMap2.Material
						local vector2 = Vector3.new(math.random(-20, 20), math.random(90, 110), math.random(-20, 20))
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.MaxForce = createVector(10000, 10000, 10000)
						bodyVelocity.Velocity = hrp.CFrame.LookVector * 5 + vector2
						bodyVelocity.Parent = clone7
						local vector3 = Vector3.new(
							math.rad((math.random(360))),
							math.rad((math.random(360))),
							(math.rad((math.random(360))))
						)
						local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
						bodyAngularVelocity.AngularVelocity = vector3
						bodyAngularVelocity.Parent = clone7
						task.spawn(function()
							task.wait(0.02)
							bodyVelocity:Destroy()
						end)
						Util.Debris:AddItem(clone7, 5)
					end
				end)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function groundEffects(_, rayMap3)
					if rayMap3 then
						clone4.Rocks.Color = ColorSequence.new(rayMap3.Color)
						clone4.Attachment.ParticleEmitter2.Color = ColorSequence.new(rayMap3.Color)
						clone4.Attachment.ParticleEmitter.Color = ColorSequence.new(rayMap3.Color)
					end
				end

				groundEffects(nil, rayMap2) -- equivalent call inferred; original call site unknown
			end
		end)
		task.wait(0.19)
		body.SiloTrailPerm.smoke.Enabled = false
		body.BLACKTRAIL.Trail.Enabled = false
		body.shadow2:Emit(8)
		body.shadow1:Emit(8)
		body.shadowout.shadow1:Emit(13)
		primaryPart.Anchored = true
		motor6D:Destroy()
		task.wait(0.2)
		clone.eyeR.EyeR.Eye.Enabled = false
		clone.eyeL.EyeL.Eye.Enabled = false
		Util.Sound:Play("MammothUntransform", hrp, nil, 1 + math.random(-5, 5) / 100, 2)
		local children = body.Disperse:GetChildren()
		local v5 = {}

		for k, emitter in pairs(children) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.LockedToPart = false
			v5[k] = {
				count = emitter:GetAttribute("EmitCount") or 0,
				delay = emitter:GetAttribute("EmitDelay") or 0
			}
		end

		for k, v6 in pairs(children) do
			if not v5[k] then
				continue
			end

			if v5[k].delay > 0 then
				local v7 = k
				local v8 = v6
				task.spawn(function()
					task.wait(v5[v7].delay)
					v8:Emit(v5[v7].count)
				end)
			else
				v6:Emit(v5[k].count)
			end
		end

		return deduplicatedTail()
	else
		task.cancel(thread)
		primaryPart.Anchored = true
		motor6D:Destroy()
		clone.eyeR.EyeR.Eye.Enabled = false
		clone.eyeL.EyeL.Eye.Enabled = false
		return deduplicatedTail()
	end
end

return function(data)
	local plr = data.plr
	local hrp = data.hrp
	local hold = data.hold

	if not hrp or (hrp.Position - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	punt1(plr, hrp, hold)
end