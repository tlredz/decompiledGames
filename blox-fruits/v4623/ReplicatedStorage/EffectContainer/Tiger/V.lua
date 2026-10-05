local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
local RockRipple = require(script.Parent.Modules.RockRipple)
local Rock2 = require(game.ReplicatedStorage.Util.Rock2)

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

local function tweenBeamTransparency(instance, tweenInfo, p: number)
	if instance:GetAttribute("BeamTransparency") == nil then
		instance:SetAttribute("BeamTransparency", instance.Transparency == NumberSequence.new(1) and 1 or 0)
		instance:SetAttribute("OriginalBeamTransparencyNumberSequence", instance.Transparency)
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = instance:GetAttribute("BeamTransparency")
	local changedConnection = numberValue.Changed:Connect(function(beamTransparency)
		local numberSequenceKeypoints = {}

		for i, keypoint in ipairs(instance:GetAttribute("OriginalBeamTransparencyNumberSequence").Keypoints) do
			numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
				keypoint.Time,
				keypoint.Value + (1 - keypoint.Value) * beamTransparency
			)
		end

		instance.Transparency = NumberSequence.new(numberSequenceKeypoints)
		instance:SetAttribute("BeamTransparency", beamTransparency)
	end)
	local v = game.TweenService:Create(numberValue, tweenInfo, {
		Value = p
	})
	v:Play()
	v.Completed:Once(function()
		changedConnection:Disconnect()
		changedConnection = nil
		numberValue:Destroy()
		numberValue = nil
	end)
end

local function windRibbon(p, cFrame, p2, p3, p4, folder)
	Util.Debris:AddItem(folder, 2)
	folder.Part.Color = Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), p, "LeopardFruitVFXColor")
	folder.Part.CFrame = cFrame
	folder.Part.Transparency = 1
	local tween = TweenService:Create(
		folder.Part,
		TweenInfo.new(math.random(1, 2) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			CFrame = folder.Part.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(
				math.rad((math.random(-360, 360))),
				math.rad((math.random(-360, 360))),
				(math.rad((math.random(-360, 360))))
			),
			Size = folder.Part.Size * math.random(6, 8),
			Color = Util.WrapColor3Constructor(Color3.fromRGB(0, 0, 0), p, "LeopardFruitVFXColor"),
			Transparency = 1
		}
	)
	Util.ResizeModel(folder, math.random(p2, p3), folder.Part.Position)
	task.spawn(function()
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") then
				continue
			end

			local v = beam
			task.spawn(function()
				task.wait(0.15)
				tweenBeamTransparency(v, TweenInfo.new(0.1), 1)
			end)
		end

		local beam = folder.Part.beam1.Beam
		local beam2 = folder.Part.beam2.Beam
		local beam3 = folder.Part.beam3.Beam
		local beam4 = folder.Part.beam4.Beam
		local beam5 = folder.Part.beam5.Beam
		local beam6 = folder.Part.beam6.Beam
		TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam3, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 100,
			Width1 = 14
		}):Play()
		TweenService:Create(beam4, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam5, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 44,
			Width1 = 0
		}):Play()
		TweenService:Create(beam6, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 100,
			Width1 = 14
		}):Play()
		task.wait(0.05)
		TweenService:Create(beam, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam2, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam3, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam4, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam5, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(beam6, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Width0 = 0,
			Width1 = 0
		}):Play()
	end)
	tween.Completed:Connect(function()
		folder:Destroy()
	end)
	Util.SetParentOverrideWithColor(folder, p4, p, "LeopardFruitVFXColor")
	tween:Play()
end

local V = FX:WaitForChild("TigerEffects").V
return function(data)
	local player = data.player
	local hrp = data.hrp
	local _ = data.isForTransformation

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local currentCamera = Workspace.CurrentCamera

	if (hrp.Position - currentCamera.CFrame.Position).Magnitude > 600 then
		return
	end

	local folder = Instance.new("Folder", Workspace._WorldOrigin)
	Util.Debris:AddItem(folder, 10)

	if hrp.Parent == game.Players.LocalPlayer.Character then
		task.spawn(function()
			TweenService:Create(
				Workspace.Camera,
				TweenInfo.new(0.067, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					FieldOfView = 96
				}
			):Play()
			task.wait(0.067)
			TweenService:Create(
				Workspace.Camera,
				TweenInfo.new(0.033, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					FieldOfView = 70
				}
			):Play()
			task.wait(0.033)
			TweenService:Create(
				Workspace.Camera,
				TweenInfo.new(0.433, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					FieldOfView = 62
				}
			):Play()
			task.wait(0.433)
			TweenService:Create(Workspace.Camera, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
				FieldOfView = 30
			}):Play()
			task.wait(0.1)
			TweenService:Create(
				Workspace.Camera,
				TweenInfo.new(0.034, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{
					FieldOfView = 105
				}
			):Play()
			Util.CameraShaker:ShakeOnce(15, 12, 0.05, 0.7, createVector(2, 2, 2), createVector(2, 2, 2))
			task.wait(0.034)
			TweenService:Create(
				Workspace.Camera,
				TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
				{
					FieldOfView = 70
				}
			):Play()
		end)
	end

	local transformTiger = V.TransformTiger
	local clone = transformTiger.Charge:Clone()
	local clone2 = transformTiger.Explode:Clone()
	local clone3 = transformTiger.Floor:Clone()
	local clone4 = transformTiger.FIRESHOCKSHOCK:Clone()
	local clone5 = V.head.EYETIGERL:Clone()
	local clone6 = V.head.EYETIGERR:Clone()
	local clone7 = V.head.POP:Clone()
	local clone8 = V.head.POP2:Clone()
	Util.Sound:Play("BF_TigerFt_TFM_V_01", hrp)
	Util.SetParentOverrideWithColor(clone5, hrp.Parent.Head, player, "LeopardFruitVFXColor")
	Util.SetParentOverrideWithColor(clone6, hrp.Parent.Head, player, "LeopardFruitVFXColor")
	Util.SetParentOverrideWithColor(clone7, hrp.Parent.Head, player, "LeopardFruitVFXColor")
	Util.SetParentOverrideWithColor(clone8, hrp.Parent.Head, player, "LeopardFruitVFXColor")
	emitAll(clone5)
	emitAll(clone6)
	emitAll(clone7)
	emitAll(clone7)
	emitAll(clone8)
	Util.Debris:AddItem(clone5, 2.5)
	Util.Debris:AddItem(clone6, 2.5)
	Util.Debris:AddItem(clone7, 2.5)
	Util.Debris:AddItem(clone8, 2.5)
	task.wait(0.1)
	clone3.CFrame = hrp.CFrame * CFrame.new(0, -2.5, 0)
	Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
	Util.Debris:AddItem(clone3, 4.5)
	emitAll(clone3)
	task.wait(0.1)
	clone.CFrame = hrp.CFrame * CFrame.new(0, -2.5, 0)
	Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
	Util.Debris:AddItem(clone, 2.5)
	task.spawn(function()
		for _ = 1, 5 do
			emitAll(clone)
			task.wait(0.045)
		end
	end)
	task.wait(0.4)
	clone4.CFrame = hrp.CFrame
	Util.SetParentOverrideWithColor(clone4, folder, player, "LeopardFruitVFXColor")
	Util.Debris:AddItem(clone4, 0.5)
	TweenService:Create(clone4, TweenInfo.new(0.333, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
		Size = createVector(190, 190, 190),
		Transparency = 1
	}):Play()

	for _, attachment in pairs(clone2:GetChildren()) do
		if not attachment:IsA("Attachment") then
			continue
		end

		Util.SetParentOverrideWithColor(attachment, hrp, player, "LeopardFruitVFXColor")
		emitAll(attachment)
		Util.Debris:AddItem(attachment, 2.5)
	end

	local ray = Util.Ray
	local v = hrp.Position + createVector(0, 2, 0)
	local v2 = { Workspace.Characters, Workspace.Enemies, folder }
	local _, _, _ = ray(v, createVector(-0, -15, -0), v2, false)
	local ray2 = Util.Ray
	local v3 = hrp.Position + createVector(0, 2, 0)
	local v4 = { Workspace.Characters, Workspace.Enemies, folder }
	local v5, v6, v7 = ray2(v3, createVector(-0, -40, -0), v4, false)

	if v5 ~= nil then
		local cframe = CFrame.new(v6)
		local clone9 = FX:WaitForChild("TigerEffects").V.VFloor:Clone()
		clone9.CFrame = cframe
		Util.SetParentOverrideWithColor(clone9, folder, player, "LeopardFruitVFXColor")
		emitAll(clone9)
		Util.Debris:AddItem(clone9, 4.5)
		task.spawn(function()
			task.wait(0.1753)
			local clone10 = FX:WaitForChild("TigerEffects").V.VExpand:Clone()
			clone10.PrimaryPart.CFrame = CFrame.new(v6)
			Util.SetParentOverrideWithColor(clone10, folder, player, "LeopardFruitVFXColor")
			Util.Debris:AddItem(clone10, 3)
			emitAll(clone10)
		end)
		task.spawn(function()
			local position = hrp.Position
			local position2 = hrp.Position
			local magnitude = (position - position2).magnitude
			local ray3, v8, _ = Util.Ray(
				position,
				CFrame.new(position, position2).LookVector.Unit * (magnitude + 2),
				{ Workspace.Characters, Workspace.Enemies }
			)

			local function lerp(p, p2, p3)
				return p + (p2 - p) * p3
			end

			local back = Util.Tween.ease.inout.back

			for i = 1, 6 do
				local v9 = i
				task.spawn(function()
					if 20 % v9 ~= 0 then
						local v10 = CFrame.new(position, v8) * CFrame.new(
							0,
							0,
							-math.random(5, (math.max(14, magnitude)))
						) * CFrame.Angles(0, 1.5707963267948966, 0)
					end

					local v11 = v9 % 2 == 0
					local clone10

					if v11 then
						local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
						clone10 = FX2:WaitForChild("TigerEffects").WINDRIBBONS.RibbonFire3:Clone()
					elseif v9 % 3 == 0 then
						local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
						clone10 = FX2:WaitForChild("TigerEffects").WINDRIBBONS.RibbonFire4:Clone()
					else
						local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
						clone10 = FX2:WaitForChild("TigerEffects").WINDRIBBONS.RingSwish:Clone()
					end

					Util.Debris:AddItem(clone10, 2)
					local part = clone10.Part
					part.Transparency = 1
					local v12 = false
					local v13 = v9 / 6
					local v14

					if v13 < 0.75 then
						v14 = math.min(1, (v13 / 0.75) ^ 0.8 + 0.2)
					else
						v14 = 1 - (v13 - 0.75) / 0.25
						v12 = true
					end

					local v15 = back(v14, 0.01, 3.89, 1, 11)
					clone10:ScaleTo((math.max(v15, v12 and 2.5 or 0.1)))
					task.spawn(function()
						local beam = part.beam1.Beam
						local beam2 = part.beam2.Beam
						local beam3 = part.beam3.Beam
						local beam4 = part.beam4.Beam
						local beam5 = part.beam5.Beam
						local beam6 = part.beam6.Beam
						TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 17.6 * v15,
							Width1 = 0
						}):Play()
						TweenService:Create(
							beam2,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = 17.6 * v15,
								Width1 = 0
							}
						):Play()
						TweenService:Create(
							beam3,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = math.random(20, 30) * v15,
								Width1 = 6 * v15
							}
						):Play()
						TweenService:Create(
							beam4,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = 17.6 * v15,
								Width1 = 0
							}
						):Play()
						TweenService:Create(
							beam5,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = 17.6 * v15,
								Width1 = 0
							}
						):Play()
						TweenService:Create(
							beam6,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = math.random(20, 30) * v15,
								Width1 = 6 * v15
							}
						):Play()
						task.wait(0.05)
						TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam3, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam4, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam5, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
						TweenService:Create(beam6, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end)
					task.spawn(function()
						emitAll(clone10)
						task.wait(0.2)

						for i2, emitter in pairs(clone10:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.LockedToPart = false
							end
						end
					end)
					local cframe2 = CFrame.Angles(
						math.rad((math.random(-30, 30))),
						math.rad((math.random(-30, 30))),
						(math.rad((math.random(-30, 30))))
					)
					part.CFrame = CFrame.new(position2) * cframe2
					local v17 = ({ -1, 1 })[math.random(1, 2)] * 179
					local tween = TweenService:Create(
						part,
						TweenInfo.new(v11 and 0.35 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = Vector3.new(5, v11 and 1 or 3, 5),
							Position = position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)),
							Transparency = 1
						}
					)
					local tween2 = TweenService:Create(
						part,
						TweenInfo.new(v11 and 0.1 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, false, 0),
						{
							Orientation = part.Orientation + Vector3.new(0, v17, 0)
						}
					)
					tween2.Completed:Connect(function()
						if part then
							tween2 = TweenService:Create(
								part,
								TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
								{
									Orientation = part.Orientation + Vector3.new(0, v17, 0)
								}
							)
							tween2:Play()
						end
					end)
					tween.Completed:Connect(function()
						if not ray3 then
							task.spawn(function()
								for i2, beam in pairs(clone10:GetDescendants()) do
									if beam:IsA("Beam") then
										beam.Enabled = false
									end
								end

								task.wait(2.5)
								clone10:Destroy()
							end)
							return
						end

						local tween3 = TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
							{
								Transparency = 1,
								CFrame = part.CFrame * CFrame.new(0, 1, 0) * CFrame.Angles(
									math.rad((math.random(-5, 5))),
									v17,
									(math.rad((math.random(-5, 5))))
								)
							}
						)
						tween3.Completed:Connect(function()
							task.spawn(function()
								for i2, beam in pairs(clone10:GetDescendants()) do
									if beam:IsA("Beam") then
										beam.Enabled = false
									end
								end

								task.wait(2.5)
								clone10:Destroy()
							end)
						end)
						tween3:Play()
					end)
					Util.SetParentOverrideWithColor(clone10, folder, player, "LeopardFruitVFXColor")
					tween:Play()
					tween2:Play()
				end)
				wait(0.025)
			end
		end)
		task.spawn(function()
			local part = Instance.new("Part")
			part.Name = "BAMPROCK"
			part.CanTouch = false
			part.CanQuery = false
			part.CanCollide = false
			part.Anchored = true
			RockRipple.createRippleEffect(part, v6, 9, 5, 7, 3)
		end)
		local v8 = CFrame.new(v6, v6 + v7) * CFrame.Angles(-1.5707963267948966, 0, 0)
		local random = Random.new()

		for i = 1, 22 do
			local v10 = Rock2.new({
				Type = "Ground",
				FadeOut = { 0.25, 0.5 },
				FadeIn = { 0.25, 0.5 },
				Lifetime = { 1, 2.5 },
				Size = Vector3.new(random:NextNumber(1, 2), random:NextNumber(1, 2), random:NextNumber(1, 2)),
				Scale = { 2.75, 5.5 }
			})
			local unit = Vector3.new(
				math.sin(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2,
				random:NextNumber(0, 1) * 1.25,
				math.cos(random:NextNumber(-1, 1) * 2 * 3.141592653589793) * 2
			).Unit
			v10.Type = "Flying"
			v10:Spawn(v8 * CFrame.Angles(0, 6.283185307179586 * (i / 22), 0) * CFrame.new(0, 0, -33.75))
			v10:Eject({
				Velocity = 1.5 * Util.Misc.Physics.Velocity(
					Vector3.new(),
					unit * random:NextNumber(22, 88),
					Vector3.new(0, -Workspace.Gravity * random:NextNumber(0.25, 1), 0),
					0.25 + random:NextNumber(0, 2)
				),
				AngularVelocity = Vector3.new(
					random:NextNumber(-1, 1),
					random:NextNumber(-1, 1),
					random:NextNumber(-1, 1)
				) * 2 * 3.141592653589793 * (1 / v10.Scale)
			})
		end

		task.spawn(function()
			local groundSpike = FX:WaitForChild("TigerEffects").GroundSpike
			local cFrame = cframe

			for i = 0, 17 do
				local number = random:NextNumber(i * 2 * 3.141592653589793 / 18, (i + 1) * 2 * 3.141592653589793 / 18)
				local v10 = math.random()
				local v11 = 24 + 30 * v10
				local clone10 = groundSpike:Clone()
				local v12 = 1.6 + 1.6 * v10
				ScaleModel(clone10, v12)
				local v13 = cFrame * CFrame.Angles(0, number, 0) * CFrame.new(0, 0, -v11) * CFrame.Angles(
					-math.rad(20 + 25 * v10),
					0,
					0
				) * CFrame.new(0, -27 * v12, 0)
				clone10:PivotTo(v13)
				Util.SetParentOverrideWithColor(clone10, folder, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(clone10, 8)
				destroyAfter(clone10, 3)
				task.delay(random:NextNumber(0.3, 0.6), function()
					heartbeatLoopFor2(0.6, function(p, p2, p3)
						clone10.lavaGradient.Spike.Color = Util.WrapColor3Constructor(
							Color3.fromRGB(255 * (1 - p3), 128 * (1 - p3), 0),
							player,
							"LeopardFruitVFXColor"
						)
					end, function()
						clone10.lavaGradient.Spike.Color = Util.WrapColor3Constructor(
							Color3.fromRGB(0, 0, 0),
							player,
							"LeopardFruitVFXColor"
						)
					end)
				end)
				local v15 = clone10
				task.delay(random:NextNumber(1.6, 2), function()
					TweenService:Create(
						v15.lavaGradient,
						TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
						{
							CFrame = v15.lavaGradient.CFrame * CFrame.new(0, math.random(-45, -35), 0)
						}
					):Play()
				end)
				local v16 = clone10
				task.delay(random:NextNumber(0, 0.4), function()
					heartbeatLoopFor2(0.1, function(p, p2, p3)
						v16:PivotTo(v13 * CFrame.new(0, 27 * v12 * p3, 0))
					end)
				end)
			end
		end)
		task.spawn(function()
			task.wait(1.85)

			for _, emitter in pairs(clone9:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") and emitter.Enabled == true then
					emitter.Enabled = false
				end
			end
		end)
	end
end