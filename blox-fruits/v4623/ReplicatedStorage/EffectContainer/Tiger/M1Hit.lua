local createVector = vector.create
local _WorldOrigin = workspace._WorldOrigin
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
require(script.Spikes)
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
local random = Random.new()
local FX = require(ReplicatedStorage2:WaitForChild("FX"))
require(script.Parent.Modules.RockRipple)
require(game.ReplicatedStorage.Util.Rock2)

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		else
			emitter:Emit(1)
		end
	end
end

function ScaleModel(folder, modelScale, p)
	local modelScale2 = folder:GetAttribute("ModelScale")
	local v = modelScale2 == nil and 1 or modelScale2
	local v2 = p or folder:GetPivot().Position
	local v3 = modelScale / v

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local position = part.Position
		local v4 = part.CFrame - position
		local v5 = position - v2
		part.Size *= Vector3.new(v3, v3, v3)
		part.CFrame = v4 + v2 + v5 * v3
	end

	folder:SetAttribute("ModelScale", modelScale)
end

local function mockPart(p, part)
	local part2 = Instance.new("Part")
	part2.Size = part.Size
	part2.CFrame = part.CFrame
	part2.Transparency = 1
	part2.Anchored = true
	part2.CanCollide = false
	Util.SetParentOverrideWithColor(part2, _WorldOrigin, p, "LeopardFruitVFXColor")
	Util.Debris:AddItem(part2, 4)
	return part2
end

local function BasicSlash(folder)
	task.spawn(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			beam.Enabled = true
			local v = beam:GetAttribute("StartDelay") / 2
			local v3 = beam
			local v4 = beam:GetAttribute("EndDelay") / 2
			task.spawn(function()
				local tween = TweenService:Create(
					v3,
					TweenInfo.new(v4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						Width0 = v3.Width0,
						Width1 = v3.Width1
					}
				)
				v3.Width0 = 0
				v3.Width1 = 0
				task.wait(v)
				tween:Play()
				task.wait(v4)
				local tween2 = TweenService:Create(
					v3,
					TweenInfo.new(v4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				tween2:Play()
				tween2.Completed:Wait()
				v3:Destroy()
			end)
		end
	end)
	local tween = TweenService:Create(
		folder.Weld,
		TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			C0 = folder.Weld.Part0.CFrame:ToObjectSpace(folder.Weld.Part1.CFrame) * CFrame.Angles(
				-2.6179938779914944,
				0,
				0
			)
		}
	)
	tween:Play()
	tween.Completed:Wait()
	folder.Weld.Enabled = false
	folder.Anchored = true
	TweenService:Create(folder, TweenInfo.new(0.075, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CFrame = folder.CFrame * CFrame.Angles(-1.3089969389957472, 0, 0)
	}):Play()
end

local function hit(player, plr, hrp, _, _, _, stage)
	local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
	local m1s = FX2:WaitForChild("TigerEffects").M1s
	local folder = Instance.new("Folder")
	folder.Parent = workspace._WorldOrigin
	Util.Debris:AddItem(folder, 5)

	if stage == 1 then
		Util.Sound:Play("BF_TigerFt_TFM_M1_Slash_01", hrp)
		local v = mockPart(player, hrp)
		task.wait(0.1)

		if (workspace.CurrentCamera.CFrame.p - hrp.Position).Magnitude <= 180 then
			Util.CameraShaker:ShakeOnce(6, 5, 0.05, 0.4, createVector(0.7, 0.7, 0.7), createVector(0.7, 0.7, 0.7))
		end

		local cFrame = hrp.CFrame
		local cframe = CFrame.Angles(0, 0, 0.6108652381980153)
		local cframe2 = CFrame.Angles(2.9670597283903604, 0, 0)
		local _ = hrp.CFrame * cframe
		local _ = hrp.CFrame * CFrame.new(0, 0, -9) * cframe
		local clone = m1s.ClawPart1:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 0, -15)
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone, 1.5)
		clone.Weld.Part0 = hrp
		clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * cframe * cframe2 * CFrame.new(
			-2,
			0,
			6
		)
		emitAll(clone)
		BasicSlash(clone)
		v.CFrame = hrp.CFrame * CFrame.new(-3, 5, -5)

		if (workspace.CurrentCamera.CFrame.p - v.Position).Magnitude <= 30 then
			Util.CameraShaker:ShakeOnce(8, 8, 0.1, 0.42, createVector(0.7, 0.2, 0.1), createVector(0.5, 0.5, 0.5))
		end

		local ray = Util.Ray
		local v2 = v.Position + createVector(0, 1, 0)
		local v3 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local v4, _, _ = ray(v2, createVector(-0, -17, -0), v3)

		if v4 then
			local clone2 = m1s.floor:Clone()

			for _, child in pairs(clone2:GetChildren()) do
				if child.Name ~= "scratchL" then
					continue
				end

				Util.SetParentOverrideWithColor(child, v, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(child, 2)
				emitAll(child)
			end
		end
	elseif stage == 2 then
		Util.Sound:Play("BF_TigerFt_TFM_M1_Slash_02", hrp)
		local v = mockPart(player, hrp)
		task.wait(0.1)

		if (workspace.CurrentCamera.CFrame.p - hrp.Position).Magnitude <= 180 then
			Util.CameraShaker:ShakeOnce(6, 5, 0.05, 0.4, createVector(0.7, 0.7, 0.7), createVector(0.7, 0.7, 0.7))
		end

		local cFrame = hrp.CFrame
		local cframe = CFrame.Angles(0, 0, -0.6108652381980153)
		local cframe2 = CFrame.Angles(-2.9670597283903604, 0, 0)
		local _ = hrp.CFrame * cframe
		local _ = hrp.CFrame * CFrame.new(0, 0, -9) * cframe
		local clone = m1s.ClawPart1:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone, 1.5)
		clone.Weld.Part0 = hrp
		clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * cframe * cframe2 * CFrame.new(
			2,
			0,
			6
		)
		BasicSlash(clone)
		emitAll(clone)
		v.CFrame = hrp.CFrame * CFrame.new(3, 5, -5)

		if (workspace.CurrentCamera.CFrame.p - v.Position).Magnitude <= 30 then
			Util.CameraShaker:ShakeOnce(8, 8, 0.1, 0.42, createVector(-0.7, 0.2, 0.1), createVector(0.5, 0.5, 0.5))
		end

		local ray = Util.Ray
		local v2 = v.Position + createVector(0, 1, 0)
		local v3 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local v4, _, _ = ray(v2, createVector(-0, -17, -0), v3)

		if v4 then
			local clone2 = m1s.floor:Clone()

			for _, child in pairs(clone2:GetChildren()) do
				if child.Name ~= "scratchR" then
					continue
				end

				Util.SetParentOverrideWithColor(child, v, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(child, 2)
				emitAll(child)
			end
		end
	elseif stage == 3 then
		Effect.new("Tiger.ZFireChargeRedKick"):play({
			player = plr,
			hrp = hrp,
			amount = 2
		})

		local function BasicSlash2(folder2)
			task.spawn(function()
				for _, beam in pairs(folder2:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Enabled = true
					local v = beam:GetAttribute("StartDelay") / 2
					local v3 = beam
					local v4 = beam:GetAttribute("EndDelay") / 2
					task.spawn(function()
						local tween = TweenService:Create(
							v3,
							TweenInfo.new(v4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
							{
								Width0 = v3.Width0,
								Width1 = v3.Width1
							}
						)
						v3.Width0 = 0
						v3.Width1 = 0
						task.wait(v)
						tween:Play()
						task.wait(v4)
						local tween2 = TweenService:Create(
							v3,
							TweenInfo.new(v4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Width0 = 0,
								Width1 = 0
							}
						)
						tween2:Play()
						tween2.Completed:Wait()
						v3:Destroy()
					end)
				end
			end)
			local tween = TweenService:Create(
				folder2.Weld,
				TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					C0 = folder2.Weld.Part0.CFrame:ToObjectSpace(folder2.Weld.Part1.CFrame) * CFrame.Angles(
						-2.6179938779914944,
						0,
						0
					)
				}
			)
			tween:Play()
			tween.Completed:Wait()
			folder2.Weld.Enabled = false
			folder2.Anchored = true
			TweenService:Create(folder2, TweenInfo.new(0.075, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				CFrame = folder2.CFrame * CFrame.Angles(-1.3089969389957472, 0, 0)
			}):Play()
		end

		local cFrame = hrp.CFrame
		local cframe = CFrame.Angles(0, 0.7853981633974483, 1.5707963267948966)
		local cframe2 = CFrame.Angles(2.2689280275926285, 0, 0)
		local _ = hrp.CFrame * cframe
		local _ = hrp.CFrame * CFrame.new(0, 0, -9) * cframe
		local clone = m1s.KickBampist:Clone()
		clone.CFrame = cFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone, 1.5)
		clone.Weld.Part0 = hrp
		clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * cframe * cframe2 * CFrame.new(
			2,
			0,
			1
		)
		BasicSlash2(clone)
		emitAll(clone)
		task.spawn(function()
			local FX3 = require(ReplicatedStorage2:WaitForChild("FX"))
			local clone2 = FX3:WaitForChild("TigerEffects").X_Untrans.WindSwirl:Clone()
			clone2.CFrame = hrp.CFrame * CFrame.new(1.007, -0.324, 0.596)
			Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone2, 2)
			TweenService:Create(clone2.Mesh, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
				Scale = createVector(9.8, 19.6, 10.5)
			}):Play()
			task.wait(0.05)
			TweenService:Create(clone2.Decal, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				CFrame = clone2.CFrame * CFrame.Angles(0, -3.0823910853621457, 0)
			}):Play()
			task.wait(0.083)
			TweenService:Create(clone2, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				CFrame = clone2.CFrame * CFrame.Angles(0, 3.765076622279728, 0)
			}):Play()
			task.wait(0.075)
		end)
		Util.Sound:Play("BF_TigerFt_TFM_M1_Kick_0" .. tostring(math.random(1, 3)), hrp)
	elseif stage == 4 then
		local tigerRig = hrp.Parent.TigerRig:WaitForChild("TigerRig")
		local clone = m1s.Mouth:Clone()
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
		clone.RigidConstraint.Attachment0 = clone.Attachment
		clone.RigidConstraint.Attachment1 = tigerRig.RootPart.Controller.Torso1.Torso2.Torso3.Neck1.Neck2.Neck3.Head.Jaw
		task.spawn(function()
			if hrp.Parent == game.Players.LocalPlayer.Character then
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
					{
						FieldOfView = 57
					}
				):Play()
				task.wait(0.25)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
					{
						FieldOfView = 114
					}
				):Play()
				Util.CameraShaker:ShakeOnce(
					10,
					12,
					0.05,
					1.25,
					createVector(1.3, 1.3, 1.3),
					createVector(1.5, 1.5, 1.5)
				)
				task.wait(0.14)
				TweenService:Create(
					workspace.Camera,
					TweenInfo.new(0.383, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end
		end)

		if (hrp.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
			local bloomEffect = Instance.new("BloomEffect")
			bloomEffect.Name = "LeopardZBloom"
			bloomEffect.Intensity = 4
			bloomEffect.Threshold = 0.4
			bloomEffect.Size = 24
			Util.SetParentOverrideWithColor(bloomEffect, game.Lighting, player, "LeopardFruitVFXColor")
			heartbeatLoopFor2(0.2, function(_, _, p)
				bloomEffect.Intensity = 4 - 4 * p
				bloomEffect.Threshold = 0.4 + 0.6 * p
				bloomEffect.Size = 64 - 64 * p
			end, function()
				bloomEffect:Destroy()
			end)
		end

		Util.Sound:Play("BF_TigerFt_TFM_M1_Finisher_0" .. tostring(math.random(1, 3)), hrp)
		task.wait(0.044)
		local clone2 = m1s.BURSTM14CHARGEPRE:Clone()
		clone2.CFrame = hrp.CFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
		emitAll(clone2)
		Util.Debris:AddItem(clone2, 1.5)
		task.wait(0.025)
		local clone3 = m1s.BURSTM14CHARGE:Clone()
		clone3.CFrame = hrp.CFrame
		Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone3, 1.5)
		task.spawn(function()
			for _ = 1, 3 do
				emitAll(clone.Charge)
				task.wait(0.025)
			end
		end)
		task.wait(0.125)
		local clone4 = m1s.FIRESHOCKSHOCK:Clone()
		clone4.CFrame = hrp.CFrame
		Util.SetParentOverrideWithColor(clone4, folder, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone4, 0.5)
		TweenService:Create(clone4, TweenInfo.new(0.333, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
			Size = createVector(130, 130, 130),
			Transparency = 1
		}):Play()
		local clone5 = m1s.BURSTM14:Clone()
		clone5.CFrame = hrp.CFrame
		Util.SetParentOverrideWithColor(clone5, folder, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone5, 1.5)
		task.spawn(function()
			for _ = 1, 7 do
				emitAll(clone.Impact)
				task.wait(0.055)
			end
		end)
		task.spawn(function()
			for _ = 1, 11 do
				task.spawn(function()
					local clone6 = m1s.Spin2:Clone()
					clone6.CFrame = hrp.CFrame * CFrame.Angles(
						math.rad((math.random(-360, 360))),
						math.rad((math.random(-360, 360))),
						(math.rad((math.random(-360, 360))))
					)
					Util.SetParentOverrideWithColor(clone6, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone6, 2)
					TweenService:Create(
						clone6,
						TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
						{
							CFrame = clone6.CFrame * CFrame.Angles(
								math.rad((math.random(-360, -360))),
								math.rad((math.random(-360, -360))),
								(math.rad((math.random(-360, -360))))
							)
						}
					):Play()
					TweenService:Create(
						clone6.Mesh,
						TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
						{
							Scale = createVector(5, 5, 5)
						}
					):Play()
					TweenService:Create(
						clone6.Decal,
						TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
						{
							Transparency = 1
						}
					):Play()
				end)
				task.wait(0.035)
			end
		end)
		local ray = Util.Ray
		local v = hrp.Position + createVector(0, 2, 0)
		local v2 = { workspace.Characters, workspace.Enemies, folder }
		local v3, v4, _ = ray(v, createVector(-0, -40, -0), v2, false)

		if v3 ~= nil then
			local cframe = CFrame.new(v4)
			local clone6 = FX:WaitForChild("TigerEffects").M1s.RoarFloor:Clone()
			clone6.CFrame = cframe
			Util.SetParentOverrideWithColor(clone6, folder, player, "LeopardFruitVFXColor")
			emitAll(clone6)
			Util.Debris:AddItem(clone6, 4.5)
			task.spawn(function()
				task.wait(1.5)

				for _, emitter in pairs(clone6:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") and emitter.Enabled == true then
						emitter.Enabled = false
					end
				end
			end)
			task.spawn(function()
				for _ = 1, 7 do
					emitAll(clone6.ringpop)
					clone6.ringpop.FloorDelaySmoke.Color = ColorSequence.new(v3.Color)
					task.wait(0.055)
				end
			end)
			task.spawn(function()
				local FX3 = require(ReplicatedStorage2:WaitForChild("FX"))
				local groundSpike = FX3:WaitForChild("TigerEffects").M1s.GroundSpike
				local cFrame = cframe

				for i = 0, 15 do
					local number = random:NextNumber(
						i * 2 * 3.141592653589793 / 16,
						(i + 1) * 2 * 3.141592653589793 / 16
					)
					local v6 = math.random()
					local v7 = 18 + 10 * v6
					local clone7 = groundSpike:Clone()
					local v8 = 1 + 1 * v6
					ScaleModel(clone7, v8)
					local v9 = cFrame * CFrame.Angles(0, number, 0) * CFrame.new(0, 0, -v7) * CFrame.Angles(
						-math.rad(20 + 25 * v6),
						0,
						0
					) * CFrame.new(0, -26 * v8, 0)
					clone7:PivotTo(v9)
					Util.SetParentOverrideWithColor(clone7, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone7, 3)
					destroyAfter(clone7, 3)
					task.delay(random:NextNumber(0, 0.3), function()
						heartbeatLoopFor2(0.6, function(p, p2, p3)
							clone7.lavaGradient.Spike.Color = Util.WrapColor3Constructor(
								Color3.fromRGB(255 * (1 - p3), 128 * (1 - p3), 0),
								player,
								"LeopardFruitVFXColor"
							)
						end, function()
							clone7.lavaGradient.Spike.Color = Util.WrapColor3Constructor(
								Color3.fromRGB(0, 0, 0),
								player,
								"LeopardFruitVFXColor"
							)
						end)
					end)
					local v11 = clone7
					task.delay(random:NextNumber(1.2, 1.6), function()
						TweenService:Create(
							v11.lavaGradient,
							TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
							{
								CFrame = v11.lavaGradient.CFrame * CFrame.new(0, math.random(-32, -25), 0)
							}
						):Play()
					end)
					local v12 = clone7
					task.delay(random:NextNumber(0, 0.4), function()
						heartbeatLoopFor2(0.1, function(p, p2, p3)
							v12:PivotTo(v9 * CFrame.new(0, 26 * v8 * p3, 0))
						end)
					end)
				end
			end)
		end
	end
end

return function(data)
	local player = data.player
	local plr = data.plr
	local hrp = data.hrp
	local cFrame = data.CFrame
	local mouse = data.mouse
	local stage = data.stage

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 or not hrp then
		return
	end

	local tigerRig = hrp.Parent:FindFirstChild("TigerRig")

	if not tigerRig then
		return
	end

	hit(player, plr, hrp, cFrame, mouse, tigerRig, stage)
end