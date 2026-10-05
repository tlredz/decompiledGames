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
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.DestroyAfter

local function emitAll(folder)
	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect:GetAttribute("EmitDuration")
			local v2 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v) and v ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v3 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v3)
					task.wait(v)

					if v3 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		else
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v = effect
			local v3 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v:Emit(emitCount or 0)

				if tonumber(v3) and v3 ~= 0 then
					v.Enabled = true

					if not v:GetAttribute("pr3") then
						v:SetAttribute("pr3", 0)
					end

					local v4 = (v:GetAttribute("pr3") + 1) % 1000
					v:SetAttribute("pr3", v4)
					task.wait(v3)

					if v4 == v:GetAttribute("pr3") then
						v.Enabled = false
					end
				end
			end)
		end
	end
end

local FX = require(ReplicatedStorage:WaitForChild("FX"))
local m1sAwakened = FX:WaitForChild("TigerEffects").M1sAwakened

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

local function hit(player, _, hrp, _, _, stage)
	local WAIT_INTERVAL = 0.185
	local DISTANCE_THRESHOLD = 30
	local DISTANCE_THRESHOLD_2 = 180
	local folder = Instance.new("Folder")
	folder.Parent = workspace._WorldOrigin
	Util.Debris:AddItem(folder, 5)

	local function BasicSlash(folder2)
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
			TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
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
		TweenService:Create(folder2, TweenInfo.new(0.075, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
			CFrame = folder2.CFrame * CFrame.Angles(-1.3089969389957472, 0, 0)
		}):Play()
	end

	if stage == 1 then
		Util.Sound:Play("BF_TigerFt_AWK_M1_Slash_01", hrp)
		local v = mockPart(player, hrp)
		task.wait(WAIT_INTERVAL)

		if (workspace.CurrentCamera.CFrame.p - hrp.Position).Magnitude <= DISTANCE_THRESHOLD_2 then
			Util.CameraShaker:ShakeOnce(6, 5, 0.05, 0.4, createVector(0.7, 0.7, 0.7), createVector(0.7, 0.7, 0.7))
		end

		local cFrame = hrp.CFrame
		local cframe = CFrame.Angles(0, 0, -0.6108652381980153)
		local cframe2 = CFrame.Angles(-2.9670597283903604, 0, 0)
		local _ = hrp.CFrame * cframe
		local _ = hrp.CFrame * CFrame.new(0, 0, -9) * cframe
		local clone = m1sAwakened.ClawPart1:Clone()
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

		if (workspace.CurrentCamera.CFrame.p - v.Position).Magnitude <= DISTANCE_THRESHOLD then
			Util.CameraShaker:ShakeOnce(8, 8, 0.1, 0.42, createVector(-0.7, 0.2, 0.1), createVector(0.5, 0.5, 0.5))
		end

		local ray = Util.Ray
		local v2 = v.Position + createVector(0, 1, 0)
		local v3 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local v4, _, _ = ray(v2, createVector(-0, -17, -0), v3)

		if v4 then
			local clone2 = m1sAwakened.floor:Clone()

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
		Util.Sound:Play("BF_TigerFt_AWK_M1_Slash_02", hrp)
		local v = mockPart(player, hrp)
		task.wait(WAIT_INTERVAL)

		if (workspace.CurrentCamera.CFrame.p - hrp.Position).Magnitude <= DISTANCE_THRESHOLD_2 then
			Util.CameraShaker:ShakeOnce(6, 5, 0.05, 0.4, createVector(0.7, 0.7, 0.7), createVector(0.7, 0.7, 0.7))
		end

		local cFrame = hrp.CFrame
		local cframe = CFrame.Angles(0, 0, 0.6108652381980153)
		local cframe2 = CFrame.Angles(2.9670597283903604, 0, 0)
		local _ = hrp.CFrame * cframe
		local _ = hrp.CFrame * CFrame.new(0, 0, -9) * cframe
		local clone = m1sAwakened.ClawPart1:Clone()
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

		if (workspace.CurrentCamera.CFrame.p - v.Position).Magnitude <= DISTANCE_THRESHOLD then
			Util.CameraShaker:ShakeOnce(8, 8, 0.1, 0.42, createVector(0.7, 0.2, 0.1), createVector(0.5, 0.5, 0.5))
		end

		local ray = Util.Ray
		local v2 = v.Position + createVector(0, 1, 0)
		local v3 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local v4, _, _ = ray(v2, createVector(-0, -17, -0), v3)

		if v4 then
			local clone2 = m1sAwakened.floor:Clone()

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
		Util.Sound:Play("BF_TigerFt_AWK_M1_Slash_03", hrp)
		local v = mockPart(player, hrp)
		task.wait(WAIT_INTERVAL)

		if (workspace.CurrentCamera.CFrame.p - hrp.Position).Magnitude <= DISTANCE_THRESHOLD_2 then
			Util.CameraShaker:ShakeOnce(6, 5, 0.05, 0.4, createVector(0.7, 0.7, 0.7), createVector(0.7, 0.7, 0.7))
		end

		local cFrame = hrp.CFrame
		local cframe = CFrame.Angles(0, 0, -2.530727415391778)
		local cframe2 = CFrame.Angles(2.9670597283903604, 0, 0)
		local _ = hrp.CFrame * cframe
		local _ = hrp.CFrame * CFrame.new(0, 0, -9) * cframe
		local clone = m1sAwakened.ClawPart1:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 0, -15)
		Util.SetParentOverrideWithColor(clone, folder, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone, 1.5)
		clone.Weld.Part0 = hrp
		clone.Weld.C0 = clone.Weld.Part0.CFrame:ToObjectSpace(clone.Weld.Part1.CFrame) * cframe * cframe2 * CFrame.new(
			0,
			-3,
			6
		)
		emitAll(clone)
		BasicSlash(clone)
		v.CFrame = hrp.CFrame * CFrame.new(-3, 5, -5)

		if (workspace.CurrentCamera.CFrame.p - v.Position).Magnitude <= DISTANCE_THRESHOLD then
			Util.CameraShaker:ShakeOnce(8, 8, 0.1, 0.42, createVector(0.7, 0.2, 0.1), createVector(0.5, 0.5, 0.5))
		end

		local ray = Util.Ray
		local v2 = v.Position + createVector(0, 1, 0)
		local v3 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
		local v4, _, _ = ray(v2, createVector(-0, -17, -0), v3)

		if v4 then
			local clone2 = m1sAwakened.floor:Clone()

			for _, child in pairs(clone2:GetChildren()) do
				if child.Name ~= "scratch3" then
					continue
				end

				Util.SetParentOverrideWithColor(child, v, player, "LeopardFruitVFXColor")
				Util.Debris:AddItem(child, 2)
				emitAll(child)
			end
		end
	elseif stage == 4 then
		local tigerRig = hrp.Parent.TigerRig:WaitForChild("TigerRig")
		local clone = m1sAwakened.Mouth:Clone()
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
					11,
					13,
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

		Util.Sound:Play("BF_TigerFt_AWK_M1_Finisher_01", hrp)
		task.wait(0.044)
		emitAll(clone.Charge)
		task.wait(0.15)
		local clone2 = m1sAwakened.FIRESHOCKSHOCK:Clone()
		clone2.CFrame = hrp.CFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone2, 0.5)
		TweenService:Create(clone2, TweenInfo.new(0.333, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
			Size = createVector(130, 130, 130),
			Transparency = 1
		}):Play()
		task.spawn(function()
			for _ = 1, 7 do
				emitAll(clone.Impact)
				task.wait(0.072)
			end
		end)
		task.spawn(function()
			for _ = 1, 19 do
				task.spawn(function()
					local clone3 = m1sAwakened.Spin2:Clone()
					clone3.CFrame = hrp.CFrame * CFrame.Angles(
						math.rad((math.random(-360, 360))),
						math.rad((math.random(-360, 360))),
						(math.rad((math.random(-360, 360))))
					)
					Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone3, 2)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
						{
							CFrame = clone3.CFrame * CFrame.Angles(
								math.rad((math.random(-360, -360))),
								math.rad((math.random(-360, -360))),
								(math.rad((math.random(-360, -360))))
							)
						}
					):Play()
					TweenService:Create(
						clone3.Mesh,
						TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
						{
							Scale = createVector(5, 5, 5)
						}
					):Play()
					TweenService:Create(
						clone3.Decal,
						TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
						{
							Transparency = 1
						}
					):Play()
				end)
				task.wait(0.0175)
			end
		end)
		task.spawn(function()
			task.wait(0.175)

			local function lerp(p, p2, p3)
				return p + (p2 - p) * p3
			end

			local position = hrp.Position
			local v = hrp.Position + createVector(0, 10, 0)
			local magnitude = (position - v).magnitude
			local ray, v2, _ = Util.Ray(
				position,
				CFrame.new(position, v).LookVector.Unit * (magnitude + 8),
				{ workspace.Characters, workspace.Enemies }
			)
			local back = Util.Tween.ease.inout.back

			for i = 1, 6 do
				local v3 = i
				task.spawn(function()
					if 20 % v3 ~= 0 then
						local v4 = CFrame.new(position, v2) * CFrame.new(
							0,
							0,
							-math.random(5, (math.max(14, magnitude)))
						) * CFrame.Angles(1.5707963267948966, 0, 0)
					end

					local v5 = v3 % 2 == 0
					local clone3

					if v5 then
						clone3 = m1sAwakened.SwirlCrescent:Clone()
					elseif v3 % 3 == 0 then
						clone3 = m1sAwakened.WindV2:Clone()
					else
						clone3 = m1sAwakened.WindFragments:Clone()
					end

					Util.Debris:AddItem(clone3, 2)
					local part = clone3.Part
					part.Transparency = 1
					local v6 = false
					local v7 = v3 / 6
					local v8

					if v7 < 0.75 then
						v8 = math.min(1, (v7 / 0.75) ^ 0.8 + 0.2)
					else
						v8 = 1 - (v7 - 0.75) / 0.25
						v6 = true
					end

					local v9 = back(v8, 0.01, 0.89, 1, 11)
					clone3:ScaleTo((math.max(v9, v6 and 2.5 or 0.1)))
					task.spawn(function()
						local beam = part.beam1.Beam
						local beam2 = part.beam2.Beam
						local beam3 = part.beam3.Beam
						local beam4 = part.beam4.Beam
						local beam5 = part.beam5.Beam
						local beam6 = part.beam6.Beam
						TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							Width0 = 17.6 * v9,
							Width1 = 0
						}):Play()
						TweenService:Create(
							beam2,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = 17.6 * v9,
								Width1 = 0
							}
						):Play()
						TweenService:Create(
							beam3,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = math.random(20, 30) * v9,
								Width1 = 6 * v9
							}
						):Play()
						TweenService:Create(
							beam4,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = 17.6 * v9,
								Width1 = 0
							}
						):Play()
						TweenService:Create(
							beam5,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = 17.6 * v9,
								Width1 = 0
							}
						):Play()
						TweenService:Create(
							beam6,
							TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Width0 = math.random(20, 30) * v9,
								Width1 = 6 * v9
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
						emitAll(clone3)
						task.wait(0.2)

						for i2, emitter in pairs(clone3:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.LockedToPart = false
							end
						end
					end)
					local cframe = CFrame.Angles(
						math.rad((math.random(-15, 15))),
						math.rad((math.random(-180, 180))),
						(math.rad((math.random(-15, 15))))
					)
					part.CFrame = CFrame.new(v) * cframe
					local v11 = ({ -1, 1 })[math.random(1, 2)] * 179
					local tween = TweenService:Create(
						part,
						TweenInfo.new(v5 and 0.35 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
						{
							Size = Vector3.new(5, v5 and 1 or 3, 5),
							Position = position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)),
							Transparency = 1
						}
					)
					local tween2 = TweenService:Create(
						part,
						TweenInfo.new(v5 and 0.1 or 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, false, 0),
						{
							Orientation = part.Orientation + Vector3.new(0, v11, 0)
						}
					)
					tween2.Completed:Connect(function()
						if part then
							tween2 = TweenService:Create(
								part,
								TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
								{
									Orientation = part.Orientation + Vector3.new(0, v11, 0)
								}
							)
							tween2:Play()
						end
					end)
					tween.Completed:Connect(function()
						if not ray then
							task.spawn(function()
								for i2, beam in pairs(clone3:GetDescendants()) do
									if beam:IsA("Beam") then
										beam.Enabled = false
									end
								end

								task.wait(2.5)
								clone3:Destroy()
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
									v11,
									(math.rad((math.random(-5, 5))))
								)
							}
						)
						tween3.Completed:Connect(function()
							task.spawn(function()
								for i2, beam in pairs(clone3:GetDescendants()) do
									if beam:IsA("Beam") then
										beam.Enabled = false
									end
								end

								task.wait(2.5)
								clone3:Destroy()
							end)
						end)
						tween3:Play()
					end)
					Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
					tween:Play()
					tween2:Play()
				end)
				wait(0.025)
			end
		end)
		local ray = Util.Ray
		local v = hrp.Position + createVector(0, 2, 0)
		local v2 = { workspace.Characters, workspace.Enemies, folder }
		local v3, v4, _ = ray(v, createVector(-0, -40, -0), v2, false)

		if v3 ~= nil then
			local cframe = CFrame.new(v4)
			task.spawn(function()
				task.wait(0.12)
				local clone3 = m1sAwakened.RoarFloor:Clone()
				clone3.CFrame = cframe
				Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
				emitAll(clone3)
				Util.Debris:AddItem(clone3, 4.5)
				task.spawn(function()
					task.wait(1.5)

					for _, emitter in pairs(clone3:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") and emitter.Enabled == true then
							emitter.Enabled = false
						end
					end
				end)
			end)
			task.wait(WAIT_INTERVAL)
			task.spawn(function()
				local random = Random.new()
				local groundSpike = m1sAwakened.GroundSpike
				local cFrame = cframe

				for i = 0, 20 do
					local number = random:NextNumber(
						i * 2 * 3.141592653589793 / 21,
						(i + 1) * 2 * 3.141592653589793 / 21
					)
					local v6 = math.random()
					local v7 = 19 + 10 * v6
					local clone3 = groundSpike:Clone()
					local v8 = 1.4 + 0.6000000000000001 * v6
					ScaleModel(clone3, v8)
					local v9 = cFrame * CFrame.Angles(0, number, 0) * CFrame.new(0, 0, -v7) * CFrame.Angles(
						-math.rad(20 + 25 * v6),
						0,
						0
					) * CFrame.new(0, -26 * v8, 0)
					clone3:PivotTo(v9)
					Util.SetParentOverrideWithColor(clone3, folder, player, "LeopardFruitVFXColor")
					Util.Debris:AddItem(clone3, 7)
					task.spawn(function()
						task.wait(2.3)
						task.delay(random:NextNumber(0.4, 0.8), function()
							TweenService:Create(
								clone3.PrimaryPart,
								TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
								{
									CFrame = clone3.PrimaryPart.CFrame * CFrame.new(0, -42, 0)
								}
							):Play()
						end)
					end)
					local v11 = clone3
					task.spawn(function()
						TweenService:Create(
							v11.lavaGradient.Spike,
							TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								Color = Util.WrapColor3Constructor(
									Color3.fromRGB(202, 87, 42),
									player,
									"LeopardFruitVFXColor"
								)
							}
						):Play()
						task.wait(0.5)
						TweenService:Create(
							v11.lavaGradient.Spike,
							TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								Color = Util.WrapColor3Constructor(
									Color3.fromRGB(35, 15, 7),
									player,
									"LeopardFruitVFXColor"
								)
							}
						):Play()
					end)
					local v12 = clone3
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
	local _ = data.mouse
	local stage = data.stage

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 1000 or not hrp then
		return
	end

	local tigerRig = hrp.Parent:FindFirstChild("TigerRig")

	if not tigerRig then
		return
	end

	hit(player, plr, hrp, cFrame, tigerRig, stage)
end