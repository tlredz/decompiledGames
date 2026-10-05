local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local animations = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "CharlesController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, instance2, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Charles.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
		end,
		ChaseHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Charles.M1:FindFirstChild("Hit3"), humanoidRootPart2, game.SoundService.Effect)
			local clone = utils.ChaseHit:Clone()
			clone.CFrame = CFrame.new(
				humanoidRootPart2.Position,
				(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart2.Position.Y, humanoidRootPart.Position.Z))
			) * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Parent = workspace.Effects
			clone.Ring:Emit(7)
			clone.Sparks:Emit(12)
			Debris:AddItem(clone, 0.5)
		end,
		Chase = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 1, -4)
			clone.Size = createVector(0, 0, 2)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(9, 9, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.3)
			v3:PlaySound(sounds.Misc.Chase, humanoidRootPart, game.SoundService.Effect)
			v3:DustTrail(p, 0.4, CFrame.Angles(0, -1.5707963267948966, 0))
		end,
		Swing = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(character, p, p2)
			if not character.HumanoidRootPart then
				return
			end

			local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)
			local v5 = not playerFromCharacter and 0 or (playerFromCharacter:GetAttribute("Ultimate") or 0) / 100
			local lerped = Color3.fromRGB(255, 255, 255):Lerp(Color3.fromRGB(85, 0, 0), v5)

			if p2 == "Down" or p == 4 and not p2 then
				v3:ArmFlash(character["Right Leg"], lerped, 0.4)
				return
			end

			if p2 == "Up" then
				v3:ArmFlash(character["Right Arm"], lerped, 0.3)
				return
			end

			local gWarstaff = character.SetAssets:FindFirstChild("GWarstaff")

			if gWarstaff then
				local clone = utils.Charles.CombatTrail:Clone()
				clone.Color = lerped
				clone.Trail.Color = ColorSequence.new(lerped)
				clone.Weld.Part0 = gWarstaff
				clone.Parent = workspace.Effects
				task.wait(0.35)
				clone.Trail.Enabled = false
				TweenService:Create(clone, TweenInfo.new(0.1), {
					Transparency = 1
				}):Play()
				Debris:AddItem(clone, 0.2)
			end
		end,
		Launch = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Size = createVector(0, 0, 5)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(8, 8, 0),
				Transparency = 1,
				Position = clone.Position + Vector3.new(0, p, 0)
			}):Play()
			Debris:AddItem(clone, 0.3)

			if p < 0 then
				v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, humanoidRootPart, game.SoundService.Effect)
				v3:DustBreak(humanoidRootPart.Position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)

				if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 20 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end
		end,
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Charles.UltStart, humanoidRootPart, game.SoundService.Effect)
		end,
		UltimateNo = function(p, p2, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = v3:PlaySound(sounds.Charles.Ult, humanoidRootPart, game.SoundService.Effect)
			task.delay(2, function()
				TweenService:Create(v5, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				Debris:AddItem(v5, 0.5)
			end)

			if localPlayer.Character == p2 or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit):StartFadeOut(1)
			end

			local v6 = {
				[1.1] = function()
					local clone = utils.Todo.Swing:Clone()
					clone.Weld.Part0 = humanoidRootPart
					clone.Parent = workspace.Effects
					Debris:AddItem(clone, 0.6)
					clone.Core.Wind:Emit(12)
					TweenService:Create(clone.Weld, TweenInfo.new(0.4), {
						C1 = clone.Weld.C1 * CFrame.Angles(0, -3.6651914291880923, 0)
					}):Play()
					TweenService:Create(clone.Beam, TweenInfo.new(0.4), {
						Width0 = 0
					}):Play()
				end,
				[1.733] = function()
					if not instance.Parent then
						return
					end

					local clone = utils.Gojo.Twofold:Clone()
					Debris:AddItem(clone, 1)
					clone.CFrame = instance.Head.CFrame * CFrame.new(0, -0.5, -0.5)
					clone.Size = createVector(0, 0, 0)
					clone.Parent = workspace.Effects
					clone.Sparks:Emit(10)

					if localPlayer.Character == p2 or localPlayer.Character == instance then
						CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
					end
				end
			}
			local renderSteppedConnection = nil
			local lastTime = tick()
			renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
				local v7 = tick() - lastTime
				local count = 0

				for k, callback in v6 do
					if v7 < k then
						count += 1
					else
						v6[k] = nil
						pcall(callback)
					end
				end

				if count <= 0 or not p.Parent and humanoidRootPart.Parent then
					renderSteppedConnection:Disconnect()
				end
			end)
		end,
		Ultimate = function(p, p2, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local function deflectFX(p3)
				local leftArm = p3 == 1 and instance["Left Arm"] or instance["Right Arm"]
				local clone = utils.Charles.ParryFX.Core:Clone()
				clone.Parent = leftArm
				Debris:AddItem(clone, 1)
				clone.Dust:Emit(1)
				clone.Ring:Emit(2)
			end

			local v5 = {
				[1.1] = function()
					local clone = utils.Todo.Swing:Clone()
					clone.Weld.Part0 = humanoidRootPart
					clone.Parent = workspace.Effects
					Debris:AddItem(clone, 0.6)
					clone.Core.Wind:Emit(12)
					TweenService:Create(clone.Weld, TweenInfo.new(0.4), {
						C1 = clone.Weld.C1 * CFrame.Angles(0, -3.6651914291880923, 0)
					}):Play()
					TweenService:Create(clone.Beam, TweenInfo.new(0.4), {
						Width0 = 0
					}):Play()
				end,
				[1.733] = function()
					if not instance.Parent then
						return
					end

					local clone = utils.Gojo.Twofold:Clone()
					Debris:AddItem(clone, 1)
					clone.CFrame = instance.Head.CFrame * CFrame.new(0, -0.5, -0.5)
					clone.Size = createVector(0, 0, 0)
					clone.Parent = workspace.Effects
					clone.Sparks.TimeScale = 0.05
					clone.Sparks:Emit(10)
					task.delay(0.2, function()
						clone.Sparks.TimeScale = 1
					end)
				end,
				[1.917] = function()
					local clone = utils.Hiromi.Shockwave:Clone()
					clone.Position = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 5 - createVector(
						0,
						2.5,
						0
					)
					clone.Parent = workspace.Effects
					clone.CFrame *= CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
					TweenService:Create(clone.mesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Scale = createVector(15, 0, 15)
					}):Play()
					TweenService:Create(clone.mesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Transparency = 1
					}):Play()
					clone.Floor.Ring:Emit(10)
					Debris:AddItem(clone, 1.5)
				end,
				[2.383] = function()
					if not instance and humanoidRootPart or localPlayer.Character ~= instance and localPlayer.Character ~= p2 then
						return
					end

					local clone = utils.Charles.Afterimage:Clone()

					if instance:GetScale() ~= 1 then
						clone:ScaleTo(instance:GetScale())
					end

					clone.HumanoidRootPart.CFrame = humanoidRootPart.CFrame
					clone.Parent = workspace.Effects
					clone.Control:LoadAnimation(animations.Charles.UltimateAfter):Play(0, nil, 0.6)
					Debris:AddItem(clone, 1.6)
					local highlight = Instance.new("Highlight", clone)
					highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					highlight.FillColor = Color3.new(1, 1, 1)
					highlight.FillTransparency = 0.9
					highlight.OutlineTransparency = 0.6
					task.spawn(function()
						for _, accessory in instance:GetChildren() do
							if not accessory:IsA("Accessory") then
								continue
							end

							local specialMesh = accessory:FindFirstChildWhichIsA("SpecialMesh", true)
							local AssetService = game:GetService("AssetService")
							local meshPartAsync = AssetService:CreateMeshPartAsync(specialMesh.MeshId)
							meshPartAsync.Size = specialMesh.Parent.Size * specialMesh.Scale
							meshPartAsync.CanCollide = false
							meshPartAsync.Material = Enum.Material.Glass
							meshPartAsync.Transparency = 3
							local clone2 = specialMesh.Parent.AccessoryWeld:Clone()
							clone2.Part0 = meshPartAsync
							clone2.Part1 = clone:FindFirstChild(clone2.Part1.Name)
							clone2.Parent = meshPartAsync
							meshPartAsync.Parent = clone
						end

						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
						TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							Saturation = -2,
							Contrast = -2
						}):Play()
						task.wait(1.6)
						TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							Saturation = 0,
							Contrast = 0
						}):Play()
						Debris:AddItem(colorCorrectionEffect, 0.5)
					end)
				end,
				[5.283] = function()
					deflectFX(1)
				end,
				[5.45] = function()
					deflectFX(2)
				end,
				[5.683] = function()
					deflectFX(1)
				end,
				[5.9] = function()
					deflectFX(1)
				end,
				[6] = function()
					deflectFX(2)
				end,
				[6.3] = function()
					deflectFX(2)
				end,
				[6.483] = function()
					deflectFX(1)
				end,
				[6.617] = function()
					deflectFX(2)
				end,
				[6.75] = function()
					deflectFX(1)
				end,
				[6.833] = function()
					deflectFX(2)
				end,
				[6.9] = function()
					deflectFX(1)
				end,
				[6.983] = function()
					deflectFX(2)
				end,
				[7.1] = function()
					deflectFX(1)
				end,
				[7.7] = function()
					local gWarStaff = p2.SetAssets:FindFirstChild("GWarStaff")

					if gWarStaff then
						local clone = utils.Charles.ParryFX.Glow:Clone()
						clone.Parent = gWarStaff.Trail
						clone:Emit(1)
						Debris:AddItem(clone, 0.4)
					end
				end,
				[8.15] = function()
					if not instance and humanoidRootPart or localPlayer.Character ~= instance and localPlayer.Character ~= p2 then
						return
					end

					local clone = utils.Charles.HitEnd:Clone()
					clone.CFrame = humanoidRootPart.CFrame
					clone.Parent = workspace.Effects
					Debris:AddItem(clone, 0.766)
					local tweenInfo = TweenInfo.new(0.766, Enum.EasingStyle.Exponential)

					for _, effect in clone:GetDescendants() do
						if effect:IsA("Beam") then
							TweenService:Create(effect, tweenInfo, {
								TextureSpeed = 0
							}):Play()
						elseif effect:IsA("ParticleEmitter") then
							TweenService:Create(effect, tweenInfo, {
								TimeScale = 0
							}):Play()
						end
					end
				end
			}
			v3:PlaySound(sounds.Charles.Ult, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Charles.UltVoice, humanoidRootPart, game.SoundService.Voice)

			if localPlayer.Character == p2 or localPlayer.Character == instance then
				local currentCamera = workspace.CurrentCamera
				local cFrame = currentCamera.CFrame
				local numberValue = Instance.new("NumberValue")
				TweenService:Create(numberValue, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {
					Value = 1
				}):Play()
				Debris:AddItem(numberValue, 0.8)
				local total = 0
				local renderSteppedConnection = nil
				local lastTime = tick()
				local counterCutscene = utils.Charles.CounterCutscene
				renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					local v6 = dt * 60
					total += v6
					local child = counterCutscene.Frames:FindFirstChild((tonumber((math.ceil(total)))))
					local child2 = counterCutscene.FOV:FindFirstChild((tonumber((math.ceil(total)))))

					if child and child2 and p2.Parent and humanoidRootPart and p.Parent then
						currentCamera.CFrame = cFrame:Lerp(humanoidRootPart.CFrame * child.Value, numberValue.Value)
						currentCamera.FieldOfView = child2.Value
						currentCamera.CameraType = Enum.CameraType.Scriptable
						local v7 = tick() - lastTime

						for k, callback in v5 do
							if v7 < k then
								continue
							end

							v5[k] = nil
							pcall(callback)
						end
					else
						renderSteppedConnection:Disconnect()
						currentCamera.CameraType = Enum.CameraType.Custom
						currentCamera.FieldOfView = 70
						currentCamera.CameraSubject = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
						game.Lighting.ExposureCompensation = 2
						TweenService:Create(game.Lighting, TweenInfo.new(1), {
							ExposureCompensation = 0
						}):Play()
						CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
					end
				end)
			else
				local renderSteppedConnection = nil
				local lastTime = tick()
				renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
					local v6 = tick() - lastTime
					local count = 0

					for k, callback in v5 do
						if v6 < k then
							count += 1
						else
							v5[k] = nil
							pcall(callback)
						end
					end

					if count <= 0 or not p.Parent and humanoidRootPart.Parent then
						renderSteppedConnection:Disconnect()
					end
				end)
			end
		end,
		Dead = function(p)
			if not p.HumanoidRootPart then
				return
			end

			v3:Bleed(p)

			for _ = 1, 40 do
				BloodyZee:Blood(p.Torso.CFrame * CFrame.Angles(0, 3.141592653589793, 0), math.random(-150, -5), 25, 25)
			end
		end,
		Mark = function(p, p2, p3)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local cframe = CFrame.new(p2, humanoidRootPart.Position)
			local magnitude = (p2 - humanoidRootPart.Position).Magnitude
			local clone = utils.Mahito.Dash:Clone()
			clone.CFrame = cframe + cframe.LookVector * magnitude / 2
			clone.Size = Vector3.new(5, 5, magnitude)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = Vector3.new(0, 0, magnitude),
				CFrame = clone.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			Debris:AddItem(clone, 0.2)

			if not p3 then
				return
			end

			local clone2 = utils.Charles.Mark:Clone()
			clone2.Weld.Part0 = p.Torso
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 30)

			repeat
				task.wait()
			until not (p3.Parent and p3.Parent.Parent and p3.Parent.Parent.Parent)

			TweenService:Create(clone2, TweenInfo.new(0.5), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone2.Decal, TweenInfo.new(0.5), {
				Transparency = 1
			}):Play()
			clone2.Aura.Enabled = false
		end,
		Future = function(instance, p, p2)
			local humanoidRootPart = instance.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1), 0.4)

			if localPlayer == p then
				local clone = utils.Charles.Afterimage:Clone()
				Debris:AddItem(clone, 0.8)

				if instance:GetScale() ~= 1 then
					clone:ScaleTo(instance:GetScale())
				end

				clone.HumanoidRootPart.CFrame = humanoidRootPart.CFrame
				clone.Parent = workspace.Effects
				local highlight = Instance.new("Highlight", clone)
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.FillColor = Color3.new(1, 1, 1)
				highlight.FillTransparency = 0.9
				highlight.OutlineTransparency = 0.7
				task.spawn(function()
					for _, accessory in instance:GetChildren() do
						if not accessory:IsA("Accessory") then
							continue
						end

						local specialMesh = accessory:FindFirstChildWhichIsA("SpecialMesh", true)
						local AssetService = game:GetService("AssetService")
						local meshPartAsync = AssetService:CreateMeshPartAsync(specialMesh.MeshId)
						meshPartAsync.Size = specialMesh.Parent.Size * specialMesh.Scale
						meshPartAsync.CanCollide = false
						meshPartAsync.Material = Enum.Material.Glass
						meshPartAsync.Transparency = 3
						local clone2 = specialMesh.Parent.AccessoryWeld:Clone()
						clone2.Part0 = meshPartAsync
						clone2.Part1 = clone:FindFirstChild(clone2.Part1.Name)
						clone2.Parent = meshPartAsync
						meshPartAsync.Parent = clone
					end

					local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
					TweenService:Create(highlight, tweenInfo, {
						FillTransparency = 1,
						OutlineTransparency = 1
					}):Play()

					for _, descendant in clone:GetDescendants() do
						if descendant:IsA("Decal") then
							descendant.Transparency = 1
						elseif descendant:IsA("BasePart") and descendant.Transparency ~= 1 then
							TweenService:Create(descendant, tweenInfo, {
								Transparency = 1
							}):Play()
						end
					end

					local dashLeft = animations.Misc.Movement.DashLeft
					local cframe = CFrame.new(-12, 0, 0)

					if p2 == "Right" then
						dashLeft = animations.Misc.Movement.DashRight
						cframe = CFrame.new(12, 0, 0)
					elseif p2 == "Back" then
						dashLeft = animations.Misc.Movement.DashBack
						cframe = CFrame.new(0, 0, 12)
					end

					local numberValue = Instance.new("NumberValue", clone)
					TweenService:Create(numberValue, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
						Value = 1
					}):Play()
					task.delay(0.4, function()
						TweenService:Create(
							numberValue,
							TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Value = 0
							}
						):Play()
					end)
					clone.Control:LoadAnimation(dashLeft):Play(nil, nil, p2 == "Back" and 0.8 or 1.8)

					repeat
						clone.HumanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(
							humanoidRootPart.CFrame * cframe,
							numberValue.Value
						)
						RunService.RenderStepped:Wait()
					until not (clone.Parent and humanoidRootPart.Parent)
				end)
			else
				instance.Humanoid.AutoRotate = false
				task.wait(0.7)
				instance.Humanoid.AutoRotate = true
			end
		end,
		Perfect = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Damage.HitGlow:Clone()

			if instance:GetScale() ~= 1 then
				clone:ScaleTo(instance:GetScale())
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)

			for _, child in clone:GetChildren() do
				local child2 = instance:FindFirstChild(child.Name)

				if child2 then
					child.CFrame = child2.CFrame
				end

				child.Color = Color3.new(0, 0, 0)
				child.Anchored = true
				TweenService:Create(child, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
			end

			v3:PlaySound(sounds.Itadori.ManjiKick.Dodge, humanoidRootPart, game.SoundService.Effect)
			local v5 = {
				"Dodge1",
				"Dodge2",
				"Dodge3",
				"Dodge4",
				"Dodge5"
			}

			for _, v6 in instance.Humanoid:GetPlayingAnimationTracks() do
				if table.find(v5, v6.Name) then
					v6:Stop(0.02)
				end
			end

			instance.Humanoid:LoadAnimation(animations.Hiromi.Dodge:GetChildren()[math.random(1, 5)]):Play(0.02)
			local childAddedConnection = nil
			childAddedConnection = instance.Info.ChildAdded:Connect(function(child)
				if child.Name ~= "Stun" and child.Name ~= "InSkill" then
					return
				end

				for _, v6 in instance.Humanoid:GetPlayingAnimationTracks() do
					if table.find(v5, v6.Name) then
						v6:Stop(0.02)
					end
				end

				childAddedConnection:Disconnect()
				childAddedConnection = nil
			end)
			task.wait(0.3)

			if childAddedConnection then
				childAddedConnection:Disconnect()
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("CharlesService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller