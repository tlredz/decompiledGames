local createVector = vector.create
local FS = {}
local library = require(game.ReplicatedStorage.library)
local playAttachment = library.PlayAttachment
local maid = library.Maid
local playTween = library.PlayTween
local _ = library.CamShake
local _ = library.PlayFlipBook
local dtwait = library.dtwait
local EFP = library.EFP
local playMesh = library.PlayMesh
local _ = library.Impact
local _ = library.GlassLight
local _ = library.RaiseZIndex
local able = library.Able
local lifeScale = library.LifeScale
local quickFX = library.QuickFX
local _ = library.QuickWeld
local _ = library.Yield
local _ = library.ProcessPart
local _ = library.WeldObject
local _ = library.Bezier
local vfx = script.vfx
local class = {}
class.__index = class
local random = Random.new()
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local _ = game.Workspace.Camera

function FS.FirstEvent(data)
	local char = data.Char
	local v = char ~= game.Players.LocalPlayer.Character
	shared.NerfVfx({
		Script = script,
		Char = char
	})
	local cleanupTable = data.CleanupTable
	local realAnim = data.RealAnim
	local bind = data.Bind
	local _ = char.Humanoid
	local humanoidRootPart = char.HumanoidRootPart

	local function GetTorsoCF()
		local _, v2, _ = char.HumanoidRootPart.CFrame:ToOrientation()
		return CFrame.new(char.Torso.Position) * CFrame.Angles(0, v2, 0)
	end

	local object = setmetatable({}, class)
	object._maid = maid.new()
	local v2 = char == game.Players.LocalPlayer.Character
	local parentChangedConnection = nil
	local v3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Clean()
		if not v3 then
			v3 = true
			object._maid:doCleaning()
		end
	end

	local v4 = false
	local sfx = shared.sfx({
		SoundId = "rbxassetid://110844914335330",
		Parent = v2 and workspace or char.Torso,
		AddTo = cleanupTable,
		TimePosition = realAnim.TimePosition + 0.1,
		Volume = 7,
		RollOffMaxDistance = v2 and 200 or 80
	})
	sfx:Play()
	local lastTime = tick()
	local thread = task.delay(9.5, function()
		for _, v5 in pairs(cleanupTable) do
			if typeof(v5) == "thread" then
				continue
			end

			local v6 = tostring(v5)
			local v7 = nil

			for _, descendant in pairs(script.vfx:GetDescendants()) do
				if tostring(descendant) ~= v6 then
					continue
				end

				v7 = descendant
				break
			end

			if v7 then
				v5:SetAttribute("DelayDeletion", 5)
			end
		end

		sfx:SetAttribute("DelayDeletion", 5)
	end)
	table.insert(cleanupTable, thread)
	parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if bind and bind.Parent then
			return
		end

		v4 = true
		workspace.Camera:SetAttribute("paused", false)

		if tick() - lastTime >= 9.87 then
			return parentChangedConnection:Disconnect()
		end

		if thread then
			task.cancel(thread)
		end

		Clean() -- equivalent call inferred; original call site unknown
		return parentChangedConnection:Disconnect()
	end)
	task.delay(15, function()
		if parentChangedConnection then
			return parentChangedConnection:Disconnect()
		end
	end)
	task.delay(15, function()
		Clean() -- equivalent call inferred; original call site unknown
	end)
	warn(true, v2)

	local function FirstEvent()
		local folder = nil
		task.delay(2.02, function()
			if v2 and folder then
				for _, beam in pairs(folder:GetDescendants()) do
					if not beam:IsA("Beam") then
						continue
					end

					playTween(beam, {
						Time = 0.05,
						EasingStyle = "Sine",
						Goal = {
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(1, 1)
							})
						}
					})
					game.Debris:AddItem(beam, 0.05)
				end
			end
		end)

		if v2 then
			local v5

			if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v4 = true
				v5 = false
			else
				v5 = true
			end

			if not v5 then
				return
			end

			dtwait(0.3)
			local v6

			if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v4 = true
				v6 = false
			else
				v6 = true
			end

			if not v6 then
				return
			end

			local v7 = object._maid:give(Instance.new("ColorCorrectionEffect"))
			v7.Brightness = 5
			table.insert(cleanupTable, v7)

			if v2 then
				v7.Parent = game.Lighting
			end

			dtwait(0.05)
			local v8

			if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v4 = true
				v8 = false
			else
				v8 = true
			end

			if not v8 then
				return
			end

			v7.TintColor = Color3.fromRGB(255, 0, 0)
			v7.Brightness = 1.667
			dtwait(0.05)
			local v9

			if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v4 = true
				v9 = false
			else
				v9 = true
			end

			if not v9 then
				return
			end

			v7:Destroy()
			folder = quickFX({
				FX = vfx.LinesStuff,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(4.669425964355469, -2.979383945465088, 2.005949020385742) * CFrame.Angles(
					-1.5707963705062866,
					1.5707963705062866,
					0
				) * CFrame.Angles(-1.5707963267948966, -1.5707963267948966, 0)
			})
			game.Debris:AddItem(folder, 2)
			table.insert(cleanupTable, folder)
			TweenService:Create(folder.M1, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
				CFrame = humanoidRootPart.CFrame * CFrame.new(26.27595520019531, 0.2, 2.3607187271118164)
			}):Play()
			dtwait(0.4)
			local v10

			if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v4 = true
				v10 = false
			else
				v10 = true
			end

			if not v10 then
				return
			end

			TweenService:Create(folder.M1.Attachment.Beam, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Width0 = 73,
				Width1 = 73
			}):Play()
			playTween(folder.F1.Attachment.Beam, {
				Time = 0.3,
				EasingStyle = "Standard",
				Goal = {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
					})
				}
			})
		else
			local v5

			if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v4 = true
				v5 = false
			else
				v5 = true
			end

			if not v5 then
				return
			end

			local v6 = quickFX({
				FX = vfx.Glow,
				Maid = object._maid,
				Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
			})
			playAttachment(v6)
			table.insert(cleanupTable, v6)
			dtwait(1.1)
			local v7

			if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v4 = true
				v7 = false
			else
				v7 = true
			end

			if not v7 then
				return
			end
		end

		dtwait(1.2)
		local v5

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v5 = false
		else
			v5 = true
		end

		if not v5 then
			return
		end

		dtwait(0.3)
		local v6

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v6 = false
		else
			v6 = true
		end

		if not v6 then
			return
		end

		local FX = quickFX({
			FX = vfx.SmokeFx,
			Maid = object._maid,
			Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
		})
		playAttachment(FX)
		table.insert(cleanupTable, FX)
		task.delay(1.1, function()
			local v8

			if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
				v4 = true
				v8 = false
			else
				v8 = true
			end

			if not v8 then
				return
			end

			local function ad()
				local currentCamera = workspace.CurrentCamera
				local clone = script.vfx.RedScreen:Clone()
				clone.Parent = workspace.Thrown
				clone.Anchored = true
				clone.Position = createVector(40000, 40000, 40000)
				table.insert(cleanupTable, clone)
				workspace.Camera:SetAttribute("paused", true)
				currentCamera.FieldOfView = game.Players.LocalPlayer:GetAttribute("S_FOV") or 70
				currentCamera.CameraType = Enum.CameraType.Scriptable
				currentCamera.CFrame = clone.CFrame * CFrame.new(0, 0, 7.5)
				return clone
			end

			local FX2 = nil

			local function EyeEvent()
				if v2 then
					for _, accessory in pairs(char:GetChildren()) do
						if accessory:IsA("Accessory") and accessory:GetAttribute("EmoteBindThing") then
							accessory:SetAttribute("ForceDestroy", true)
						end
					end

					local folder2 = ad()
					folder2.Parent = EFP
					FX2 = folder2
					able({
						FX = folder2,
						On = true
					})

					for _, emitter in pairs(folder2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						if emitter.Name == "Star" then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						elseif emitter.Name == "wavee" or emitter.Name == "Mist" then
							local v10 = emitter
							task.delay(0.4, function()
								v10:Emit(v10:GetAttribute("EmitCount"))
							end)
						elseif emitter.Name == "Star2" then
							local v10 = emitter
							task.delay(0.9, function()
								v10:Emit(v10:GetAttribute("EmitCount"))
							end)
						elseif emitter.Name == "water" or emitter.Name == "black" or emitter.Name == "black2" then
							local v10 = emitter
							task.delay(0.95, function()
								v10:Emit(v10:GetAttribute("EmitCount"))
							end)
						end
					end
				end

				dtwait(2)
				local v10

				if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v4 = true
					v10 = false
				else
					v10 = true
				end

				if not v10 then
					return
				end

				if FX2 then
					able({
						FX = FX2,
						On = false
					})
				end

				if v2 then
					sfx.Parent = char.Torso
					workspace.Camera:SetAttribute("paused", false)
					task.spawn(function()
						local lastTime2 = tick()
						local v11 = nil
						v11 = shared.loop(function()
							if tick() - lastTime2 > 2 then
								v11()
							else
								local v12

								if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
									v4 = true
									v12 = false
								else
									v12 = true
								end

								if not v12 then
									v11()
								end
							end

							shared.repfire({
								Effect = "Camshake",
								Intensity = 1
							})
						end, 60)
						wait(2)
						local v12

						if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
							v4 = true
							v12 = false
						else
							v12 = true
						end

						if not v12 then
							return
						end

						local lastTime3 = tick()
						local v13 = nil
						v13 = shared.loop(function()
							if tick() - lastTime3 > 2 then
								v13()
							else
								local v14

								if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
									v4 = true
									v14 = false
								else
									v14 = true
								end

								if not v14 then
									v13()
								end
							end

							shared.repfire({
								Effect = "Camshake",
								Intensity = 3
							})
						end, 60)
					end)
					local primaryPart = char.PrimaryPart
					local currentCamera = workspace.CurrentCamera
					game.Players.LocalPlayer.CameraMinZoomDistance = 100
					local v11 = primaryPart.CFrame * CFrame.new(
						0.121032715,
						4.415802,
						15.8661346,
						0.999988973,
						-0.000791892409,
						0.00464361906,
						-2.88034645e-8,
						0.985767841,
						0.168112651,
						-0.00471064448,
						-0.168110803,
						0.985756874
					)
					currentCamera.CFrame = CFrame.new(
						v11.Position,
						(primaryPart.CFrame + primaryPart.CFrame.lookVector * 10).Position + createVector(0, 2, 0)
					)
					currentCamera.CameraType = Enum.CameraType.Custom
					local lastTime2 = tick()
					local heartbeatConnection = nil
					local RunService = game:GetService("RunService")
					heartbeatConnection = RunService.Heartbeat:Connect(function()
						if tick() - lastTime2 > 0.15 then
							game.Players.LocalPlayer.CameraMinZoomDistance = 0.5
							return heartbeatConnection:Disconnect()
						else
							currentCamera.CFrame = CFrame.new(
								v11.Position,
								(primaryPart.CFrame + primaryPart.CFrame.lookVector * 10).Position
							)
						end
					end)
				end

				local function AuraEvent()
					local v11

					if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v4 = true
						v11 = false
					else
						v11 = true
					end

					if not v11 then
						return
					end

					local v12 = object._maid:give(Instance.new("Highlight"))
					table.insert(cleanupTable, v12)
					v12.DepthMode = Enum.HighlightDepthMode.Occluded
					v12.FillColor = Color3.fromRGB(0, 0, 0)
					v12.FillTransparency = 0
					v12.OutlineTransparency = 1
					v12.Parent = char
					TweenService:Create(v12, TweenInfo.new(4, Enum.EasingStyle.Sine), {
						FillTransparency = 1
					}):Play()
					game.Debris:AddItem(v12, 4)
					local FX3 = quickFX({
						FX = vfx.LinesFx,
						Maid = object._maid,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
					})
					able({
						FX = FX3,
						On = true
					})
					table.insert(cleanupTable, FX3)
					local folder2 = quickFX({
						FX = vfx.Lightning,
						Maid = object._maid,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
					})
					table.insert(cleanupTable, folder2)

					for _, effect in pairs(folder2:GetDescendants()) do
						local v14

						if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
							v4 = true
							v14 = false
						else
							v14 = true
						end

						if not v14 then
							return
						end

						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							effect.Enabled = true
						end
					end

					local folder3 = nil
					local v14

					if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v4 = true
						v14 = false
					else
						v14 = true
					end

					if not v14 then
						return
					end

					local FX4 = quickFX({
						FX = vfx.Blast,
						Maid = object._maid,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
					})
					FX4:ScaleTo(3)
					lifeScale({
						FX = FX4,
						Scale = 2.5
					})
					playAttachment(FX4)
					local folder4 = quickFX({
						FX = vfx.PreAura,
						Maid = object._maid,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0)
					})
					folder4:ScaleTo(0.5)
					table.insert(cleanupTable, FX4)
					table.insert(cleanupTable, folder4)
					local v16 = object._maid:give(Instance.new("NumberValue"))
					table.insert(cleanupTable, v16)
					object._maid:giveTask(v16.Changed:Connect(function()
						local v17

						if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
							v4 = true
							v17 = false
						else
							v17 = true
						end

						if not v17 then
							return
						end

						folder4:ScaleTo(v16.Value)
					end))

					for _, emitter in pairs(folder4:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v17

						if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
							v4 = true
							v17 = false
						else
							v17 = true
						end

						if not v17 then
							return
						end

						emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min * 0.5, emitter.Lifetime.Max * 0.5)
						emitter.Speed = NumberRange.new(emitter.Speed.Min * 2, emitter.Speed.Max * 2)
					end

					task.spawn(function()
						for i = 1, 28 do
							local v17

							if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
								v4 = true
								v17 = false
							else
								v17 = true
							end

							if not (v17 and shared.OnScreen(humanoidRootPart.Position)) then
								break
							end

							local v18 = i * 0.3
							local clone = vfx.Bright2:Clone()
							table.insert(cleanupTable, clone)
							local v19 = v18 / 10 * 20

							if v then
								v19 /= 1.125
							end

							clone:ScaleTo(v19)
							playMesh({
								Model = clone,
								EndT = 0,
								Anchor = humanoidRootPart.CFrame * CFrame.new(0, v18 / 10 * 150, 0) * CFrame.Angles(
									0,
									math.rad((math.random(0, 360))),
									0
								),
								Info = TweenInfo.new(v18 / 50 + 0.2, Enum.EasingStyle.Quad)
							})
							dtwait(0.06)
						end
					end)
					v16.Value = folder4:GetScale()
					TweenService:Create(v16, TweenInfo.new(2.1, Enum.EasingStyle.Sine), {
						Value = v and 2.5 or 4
					}):Play()
					able({
						FX = folder4,
						On = true
					})
					local thread2 = task.delay(2.1, function()
						able({
							FX = folder4,
							On = false
						})
					end)
					table.insert(cleanupTable, thread2)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Built }
					local v17 = object._maid:give(Instance.new("NumberValue"))
					v17.Value = 5
					table.insert(cleanupTable, v17)
					TweenService:Create(v17, TweenInfo.new(2.1, Enum.EasingStyle.Sine), {
						Value = v and 25 or 40
					}):Play()
					task.spawn(function()
						local cFrame = humanoidRootPart.CFrame
						local lastTime2 = tick()

						while tick() - lastTime2 < 2.1 do
							local v18

							if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
								v4 = true
								v18 = false
							else
								v18 = true
							end

							if not v18 then
								break
							end

							for _ = 1, math.random(6, 9) do
								local v19

								if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
									v4 = true
									v19 = false
								else
									v19 = true
								end

								if not v19 then
									return
								end

								local v20 = cFrame * CFrame.new(
									random:NextNumber(-v17.Value, v17.Value),
									-humanoidRootPart.Size.Y * 1.3,
									random:NextNumber(-v17.Value, v17.Value)
								)
								local raycastResult = game.Workspace:Raycast(
									v20.Position,
									createVector(0, -30, 0),
									raycastParams
								)

								if not (raycastResult and shared.OnScreen(humanoidRootPart.Position)) then
									continue
								end

								local v21 = object._maid:give(vfx.Rock:Clone())
								table.insert(cleanupTable, v21)
								v21.Material = raycastResult.Instance.Material
								v21.Size = createVector(0, 0, 0)
								v21.Color = raycastResult.Instance.Color
								local cFrame2 = v20 * CFrame.new(0, random:NextNumber(40, 70), 0) * CFrame.Angles(
									math.rad((math.random(0, 360))),
									math.rad((math.random(0, 360))),
									(math.rad((math.random(0, 360))))
								)
								table.insert(cleanupTable, cFrame2)
								v21.CFrame = v20 * CFrame.Angles(
									math.rad((math.random(0, 360))),
									math.rad((math.random(0, 360))),
									(math.rad((math.random(0, 360))))
								)
								v21.Parent = EFP
								TweenService:Create(v21, TweenInfo.new(0.15, Enum.EasingStyle.Sine), {
									Size = Vector3.new(
										random:NextNumber(2, 4),
										random:NextNumber(2, 4),
										random:NextNumber(2, 4)
									)
								}):Play()
								local number = random:NextNumber(0.3, 0.5)
								task.delay(0.15, function()
									local v25

									if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
										v4 = true
										v25 = false
									else
										v25 = true
									end

									if not v25 then
										return
									end

									TweenService:Create(v21, TweenInfo.new(number - 0.15, Enum.EasingStyle.Sine), {
										Size = createVector(0, 0, 0)
									}):Play()
								end)
								TweenService:Create(v21, TweenInfo.new(number, Enum.EasingStyle.Sine), {
									CFrame = cFrame2
								}):Play()
								game.Debris:AddItem(v21, number * 5)
							end

							local v19

							if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
								v4 = true
								v19 = false
							else
								v19 = true
							end

							if not v19 then
								break
							end

							dtwait(0.06)
						end
					end)
					local v18

					if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v4 = true
						v18 = false
					else
						v18 = true
					end

					if not v18 then
						return
					end

					dtwait(2.1)
					local v19

					if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v4 = true
						v19 = false
					else
						v19 = true
					end

					if not v19 then
						return
					end

					able({
						FX = FX3,
						On = false
					})

					for _, effect in pairs(folder2:GetDescendants()) do
						if effect:IsA("Beam") then
							playTween(effect, {
								Time = 0.25,
								EasingStyle = "Sine",
								Goal = {
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 1),
										NumberSequenceKeypoint.new(1, 1)
									})
								}
							})
							game.Debris:AddItem(effect, 0.25)
						elseif effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						end
					end

					if folder3 then
						TweenService:Create(folder3.partbg, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()

						for _, effect in pairs(folder3:GetDescendants()) do
							local v20

							if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
								v4 = true
								v20 = false
							else
								v20 = true
							end

							if not v20 then
								return
							end

							if effect:IsA("Beam") then
								playTween(effect, {
									Time = 0.25,
									EasingStyle = "Sine",
									Goal = {
										Transparency = NumberSequence.new({
											NumberSequenceKeypoint.new(0, 1),
											NumberSequenceKeypoint.new(1, 1)
										})
									}
								})
								game.Debris:AddItem(effect, 0.25)
							elseif effect:IsA("ParticleEmitter") then
								effect.Enabled = false
							end
						end
					end

					local folder5 = quickFX({
						FX = v and vfx.BigAuraFx2 or vfx.BigAuraFx,
						Maid = object._maid,
						Anchor = humanoidRootPart.CFrame * CFrame.new(0, -humanoidRootPart.Size.Y * 1.5, 0) * CFrame.Angles(
							0,
							0,
							3.141592653589793
						)
					})

					for _, effect in pairs(folder5:GetDescendants()) do
						local v20

						if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
							v4 = true
							v20 = false
						else
							v20 = true
						end

						if not v20 then
							return
						end

						if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
							continue
						end

						effect.Enabled = true

						if effect:IsA("ParticleEmitter") then
							effect.Rate *= 0.7
						end
					end

					dtwait(1.6)
					local v20

					if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
						v4 = true
						v20 = false
					else
						v20 = true
					end

					if not v20 then
						return
					end

					for _, effect in pairs(folder5:GetDescendants()) do
						local v21

						if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
							v4 = true
							v21 = false
						else
							v21 = true
						end

						if not v21 then
							break
						end

						if effect:IsA("Beam") then
							playTween(effect, {
								Time = 0.25,
								EasingStyle = "Sine",
								Goal = {
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 1),
										NumberSequenceKeypoint.new(1, 1)
									})
								}
							})
							game.Debris:AddItem(effect, 0.25)
						elseif effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						end
					end
				end

				task.spawn(AuraEvent)
			end

			EyeEvent()
		end)
		dtwait(1.5)
		able({
			FX = FX,
			On = true
		})
		dtwait(2)
		able({
			FX = FX,
			On = false
		})
	end

	task.spawn(FirstEvent)
	wait(14)
	Clean() -- equivalent call inferred; original call site unknown
end

return FS