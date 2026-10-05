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
local RocksModule2 = require(game.ReplicatedStorage.Util.RocksModule2)
local FX = require(ReplicatedStorage.FX)

local function debrisPart(data, p, p2)
	local v = math.random(15, 30) / 10
	local part = Instance.new("Part")
	Util.Debris:AddItem(part, 5)
	part.Material = data.Material
	part.Transparency = data.Transparency
	part.Reflectance = data.Reflectance
	part.Color = data.Color
	part.Size = Vector3.new(v, v, v)
	part.CFrame = CFrame.new(p, p + p2) * CFrame.Angles(
		math.rad((math.random(-35, 35))),
		math.rad((math.random(-35, 35))),
		(math.rad((math.random(-35, 35))))
	)
	part.CanCollide = false
	part.Parent = _WorldOrigin
	part.Velocity = part.CFrame.lookVector.Unit * Vector3.new(
		math.random(80, 150),
		math.random(80, 120),
		math.random(80, 150)
	)
	part.RotVelocity = Vector3.new(math.random(-7, 7), math.random(-7, 7), math.random(-7, 7))
	part.CFrame *= CFrame.Angles(
		math.rad((math.random(-180, 180))),
		math.rad((math.random(-180, 180))),
		(math.rad((math.random(-180, 180))))
	)
	return part
end

FX:WaitForChild("Mammoth")

local function CMOVE(plr, hrp, hold)
	local parent = hrp.Parent
	local mammoth = FX:WaitForChild("Mammoth")
	local accessory = Instance.new("Accessory")
	accessory.Name = "MammothAccessory"
	accessory.Parent = parent
	local clone = mammoth.MammothSilhouette:Clone()
	local primaryPart = clone.PrimaryPart
	local _ = clone.body
	local _ = clone.AnimationController
	primaryPart.CFrame = hrp.CFrame
	clone.Parent = accessory
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = primaryPart
	motor6D.Part1 = hrp
	motor6D.C0 = motor6D.Part1.CFrame:inverse()
	motor6D.C1 = motor6D.Part1.CFrame:inverse() * CFrame.new(0, -8, 0)
	motor6D.Name = "RigWeld"
	motor6D.Parent = primaryPart
	local body = clone.body
	local lookVector = hrp.CFrame.LookVector
	local v = hrp.Position + lookVector * 1
	local rayMap, v2, v3 = Util.RayMap(v, createVector(0, -80, 0))

	if rayMap then
		local v4 = v3 * 0.1
		local _ = hrp.CFrame
		local clone2 = mammoth.FormEmit:Clone()
		clone2.CFrame = CFrame.new(v2, v2 + v4) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone2.Parent = _WorldOrigin
		Util.Debris:AddItem(clone2, 3)
		task.spawn(function()
			local descendants = clone2:GetDescendants()
			local v5 = {}

			for k, emitter in pairs(descendants) do
				if emitter:IsA("ParticleEmitter") then
					v5[k] = {
						count = emitter:GetAttribute("EmitCount") or 0,
						delay = emitter:GetAttribute("EmitDelay") or 0
					}
				end
			end

			for k, descendant in pairs(descendants) do
				if not v5[k] then
					continue
				end

				if v5[k].delay > 0 then
					local v6 = k
					local v7 = descendant
					task.spawn(function()
						task.wait(v5[v6].delay)
						v7:Emit(v5[v6].count)
					end)
				else
					descendant:Emit(v5[k].count)
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

			if not plr.Character:FindFirstChild("MAMMOTH_C") then
				continue
			end

			plr.Character.MAMMOTH_C.Name = "DESTROYING"
			flag = true
			break
		end
	end

	Util.Debris:AddItem(accessory, 2.8)
	Util.Debris:AddItem(clone, 4)

	if flag then
		Util.Anims:Get(clone, "MammothCUntrans"):Play()
		body.aura1.Enabled = true
		body.aura2.Enabled = true
		body.BLACKTRAIL.Trail.Enabled = true
		clone.exp.Size = createVector(26.202, 4.679, 31.044)
		clone.exp.FR2.Enabled = true
		clone.exp.FR3.Enabled = true
		local children = body.C_dash:GetChildren()
		local v4 = {}

		for k, v5 in pairs(children) do
			v4[k] = {
				count = v5:GetAttribute("EmitCount") or 0,
				delay = v5:GetAttribute("EmitDelay") or 0
			}
		end

		for k, v5 in pairs(children) do
			if not v4[k] then
				continue
			end

			if v4[k].delay > 0 then
				local v6 = k
				local v7 = v5
				task.spawn(function()
					task.wait(v4[v6].delay)
					v7:Emit(v4[v6].count)
				end)
			else
				v5:Emit(v4[k].count)
			end
		end

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
			local clone2 = mammoth.Shockwave:Clone()
			local clone3 = mammoth.Shockwave2:Clone()
			clone2.CFrame = hrp.CFrame * CFrame.new(-8, 0, 15)
			clone2.Parent = _WorldOrigin
			clone3.CFrame = hrp.CFrame * CFrame.new(8, 0, 15)
			clone3.Parent = _WorldOrigin
			Util.Debris:AddItem(clone2, 1)
			Util.Debris:AddItem(clone3, 1)
			TweenService:Create(clone2, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(12.429, 35.5, 137.286)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.new(-14, 0, -95)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(12.429, 35.5, 137.286)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.new(14, 0, -95)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
		Util.Sound:Play("MammothDash", hrp, nil, 1 + math.random(-5, 5) / 100, 3)
		Util.Sound:Play("Tackle", hrp, nil, 1 + math.random(-10, 10) / 100, 2.5)
		body.WINDTRAIL4.Trail2.Enabled = true
		body.WINDTRAIL1.Trail2.Enabled = true
		body.t2.Trail2.Enabled = true
		task.spawn(function()
			body.SiloTrail.dust2.Lifetime = NumberRange.new(0.19, 0.2)
			local lastTime = tick()

			while tick() - lastTime < 0.36666666666666664 do
				task.wait(0.016666666666666666)
				body.SiloTrail.dust2:Emit(3)
			end
		end)
		body.shadow2:Emit(8)
		body.shadow1:Emit(8)
		task.spawn(function()
			task.wait(0.07)

			for _ = 1, 3 do
				task.wait(0.033)

				for _, child in pairs(body.C_emit:GetChildren()) do
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
			local rayMap2, v5, _ = Util.RayMap(position, createVector(0, -10, 0))

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
		Util.Sound:Play("port2", hrp, 20, 1 + math.random(-5, 5) / 100, 3)
		task.wait(0.23)
		local v5 = Util.Sound:Play("MammothTrunkSlam", hrp, 20, 1 + math.random(-22, 22) / 100, 4)
		task.delay(2, function()
			Util.Sound:FadeOut(v5, 1.5)
		end)
		local clone2 = mammoth.SlamTrunk:Clone()
		local primaryPart2 = clone2.PrimaryPart
		local clone3 = mammoth.RedCracksGround:Clone()
		task.spawn(function()
			task.wait(0.17)
			local descendants = primaryPart2.Attachment:GetDescendants()
			local v6 = {}

			for k, descendant in pairs(descendants) do
				v6[k] = {
					count = descendant:GetAttribute("EmitCount") or 0,
					delay = descendant:GetAttribute("EmitDelay") or 0
				}
			end

			for k, descendant in pairs(descendants) do
				if not v6[k] then
					continue
				end

				if v6[k].delay > 0 then
					local v7 = k
					local v8 = descendant
					task.spawn(function()
						task.wait(v6[v7].delay)
						v8:Emit(v6[v7].count)
					end)
				else
					descendant:Emit(v6[k].count)
				end
			end

			task.wait(0.04)

			if plr == game.Players.LocalPlayer then
				Util.CameraShaker:ShakeOnce(12, 1.5, 0.1, 0.6, createVector(0.1, 0.8, 0.1), createVector(1, 1, 1))
			end

			for _, child in pairs(body.CMove_Up:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			task.wait(0.36)

			for _, child in pairs(body.CMove_DOWN2:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			task.wait(0.08)

			if plr == game.Players.LocalPlayer then
				Util.CameraShaker:ShakeOnce(12, 9, 0.1, 0.5, createVector(1, 1, 1), createVector(1, 1, 1))
			end

			Util.Sound:Play("MammothDebris", hrp, nil, 1 + math.random(-5, 5) / 100, 7)

			for _, child in pairs(body.CMove_DOWN:GetChildren()) do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			task.spawn(function()
				local lookVector2 = plr.Character.PrimaryPart.CFrame.LookVector
				local v7 = hrp.Position + lookVector2 * 15.5
				local rayMap2, v8, v9 = Util.RayMap(v7, createVector(0, -15, 0))

				if rayMap2 then
					local _ = plr.Character.PrimaryPart.CFrame
					primaryPart2.CFrame = CFrame.new(v8, v8 + v9) * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone2.Parent = _WorldOrigin
					Util.Debris:AddItem(clone3, 2)
					Util.Debris:AddItem(clone2, 3.5)
					task.spawn(function()
						TweenService:Create(
							primaryPart2,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
							{
								Size = createVector(60, 0.03, 60)
							}
						):Play()
						TweenService:Create(
							clone3,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0),
							{
								Size = createVector(60, 0.05, 60)
							}
						):Play()
						task.wait(0.3)
						TweenService:Create(
							clone3.Decal,
							TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, false, 0),
							{
								Transparency = 1
							}
						):Play()
						TweenService:Create(
							primaryPart2.Decal,
							TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0),
							{
								Color3 = Color3.new(0, 0, 0)
							}
						):Play()
						TweenService:Create(
							primaryPart2.Decal,
							TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
							{
								Transparency = 1
							}
						):Play()
					end)
					task.spawn(function()
						local _, _ = Util.RayMap(primaryPart2.Position, createVector(0, -5, 0))

						for _ = 1, 16 do
							debrisPart(rayMap2, v8, v9)
						end
					end)
					task.spawn(function()
						for _, folder in pairs(clone2:GetChildren()) do
							if folder == clone2.SlamTrunkBig then
								continue
							end

							for _, descendant in pairs(folder:GetDescendants()) do
								if not (descendant.Name == "wind" or descendant.Name == "Embers") then
									continue
								end

								descendant:Emit(descendant:GetAttribute("EmitCount"))

								if descendant.Name ~= "wind" then
									continue
								end

								local v10 = descendant
								task.delay(descendant.Lifetime.Max + 0.1, function()
									v10:Destroy()
								end)
							end
						end

						task.wait(0.075)
						RocksModule2.Ground(
							primaryPart2.Position + createVector(0, 1, 0),
							25,
							createVector(4, 2, 4),
							nil,
							5,
							false,
							2.5
						)
						RocksModule2.Ground(
							primaryPart2.Position + createVector(0, 1, 0),
							32,
							createVector(8.5, 3.25, 8.5),
							nil,
							6,
							false,
							2.75
						)
						RocksModule2.Ground(
							primaryPart2.Position + createVector(0, 1, 0),
							38,
							createVector(10, 5.5, 10),
							nil,
							8,
							false,
							3
						)
						RocksModule2.Ground(
							primaryPart2.Position + createVector(0, 1, 0),
							48,
							createVector(12, 7.5, 12),
							nil,
							10,
							false,
							3
						)
					end)

					if plr == game.Players.LocalPlayer then
						task.spawn(function()
							task.wait(0.085)
							Util.CameraShaker:ShakeOnce(17, 15, 0.05, 0.4, createVector(3, 3, 3), createVector(3, 3, 3))
							local clone4 = script.LTN:Clone()
							clone4.Parent = game.Lighting
							Util.Debris:AddItem(clone4, 2)
							TweenService:Create(clone4, TweenInfo.new(0.001), {
								TintColor = Color3.fromRGB(255, 53, 53),
								Brightness = 1,
								Contrast = -2,
								Saturation = -3
							}):Play()
							task.wait()
							TweenService:Create(clone4, TweenInfo.new(0.001), {
								TintColor = Color3.fromRGB(0, 0, 0),
								Brightness = -1,
								Contrast = -2,
								Saturation = -3
							}):Play()
							task.wait()
							TweenService:Create(
								clone4,
								TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
								{
									TintColor = Color3.fromRGB(255, 255, 255),
									Brightness = 0,
									Contrast = 0,
									Saturation = 0
								}
							):Play()
							Util.Debris:AddItem(clone4, 1)
						end)
						task.spawn(function()
							task.wait(0.08)
							local clone4 = script.Blur:Clone()
							local Debris = game:GetService("Debris")
							Debris:AddItem(clone4, 1)
							clone4.Parent = game.Lighting
							TweenService:Create(
								workspace.Camera,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									FieldOfView = 83
								}
							):Play()
							TweenService:Create(
								clone4,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = 21
								}
							):Play()
							task.wait(0.082)
							TweenService:Create(
								clone4,
								TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = 0
								}
							):Play()
							TweenService:Create(
								workspace.Camera,
								TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
								{
									FieldOfView = 70
								}
							):Play()
						end)
					end

					task.spawn(function()
						task.wait(0.43)
						TweenService:Create(
							primaryPart2.Decal,
							TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, false, 0),
							{
								Transparency = 1
							}
						):Play()
					end)

					-- equivalent calls inferred from this helper; original call sites unknown
					local function groundEffects(_, rayMap3)
						if rayMap3 then
							primaryPart2.Rocks.Color = ColorSequence.new(rayMap3.Color)
							primaryPart2.Attachment.ParticleEmitter2.Color = ColorSequence.new(rayMap3.Color)
							primaryPart2.Attachment.ParticleEmitter.Color = ColorSequence.new(rayMap3.Color)
						end
					end

					groundEffects(nil, rayMap2) -- equivalent call inferred; original call site unknown
				end
			end)
		end)

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

		clone.exp.FR2.Enabled = false
		clone.exp.FR3.Enabled = false
		clone.exp.Sparks2.Enabled = false
		clone.exp.Sparks3.Enabled = false
		body.aura1.Enabled = false
		body.aura2.Enabled = false
		task.wait(0.7)
		primaryPart.Anchored = true
		motor6D:Destroy()
		task.wait(0.3)
		clone.eyeR.EyeR.Eye.Enabled = false
		clone.eyeL.EyeL.Eye.Enabled = false
		body.SiloTrailPerm.smoke.Enabled = false
		body.shadowout.shadow1:Emit(body.shadowout.shadow1:GetAttribute("EmitCount"))
		body.BLACKTRAIL.Trail.Enabled = false
		body.t2.Trail2.Enabled = false
		body.WINDTRAIL4.Trail2.Enabled = false
		body.WINDTRAIL1.Trail2.Enabled = false
		Util.Sound:Play("MammothUntransform", hrp, nil, 1 + math.random(-5, 5) / 100, 2)

		for _, part in pairs(clone:GetChildren()) do
			if part:IsA("MeshPart") then
				TweenService:Create(part, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
					Transparency = 1
				}):Play()
			end
		end

		task.wait(0.105)
		local descendants = body.Disperse:GetDescendants()
		local v6 = {}

		for k, emitter in pairs(descendants) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.LockedToPart = false
			v6[k] = {
				count = emitter:GetAttribute("EmitCount") or 0,
				delay = emitter:GetAttribute("EmitDelay") or 0
			}
		end

		for k, descendant in pairs(descendants) do
			if not v6[k] then
				continue
			end

			if v6[k].delay > 0 then
				local v7 = k
				local v8 = descendant
				task.spawn(function()
					task.wait(v6[v7].delay)
					v8:Emit(v6[v7].count)
				end)
			else
				descendant:Emit(v6[k].count)
			end
		end
	else
		task.cancel(thread)
		primaryPart.Anchored = true
		motor6D:Destroy()

		for _, part in pairs(clone:GetChildren()) do
			if part:IsA("MeshPart") then
				TweenService:Create(part, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
					Transparency = 1
				}):Play()
			end
		end
	end
end

return function(data)
	local plr = data.plr
	local hrp = data.hrp
	local hold = data.hold

	if not hrp or (hrp.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 then
		return
	end

	CMOVE(plr, hrp, hold)
end