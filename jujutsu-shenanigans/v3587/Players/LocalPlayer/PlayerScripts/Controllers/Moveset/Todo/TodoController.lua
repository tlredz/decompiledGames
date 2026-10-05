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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "TodoController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Todo.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
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
			v3:PlaySound(sounds.Todo.M1:FindFirstChild("Hit3"), humanoidRootPart2, game.SoundService.Effect)
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
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(data, p, p2)
			if p2 == "Down" then
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(0, 170, 255), 0.4)
			elseif p == 2 or p == 4 then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(0, 170, 255), 0.3)
			else
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(0, 170, 255), 0.3)
			end
		end,
		Swap = function(instance, instance2, cFrame, cFrame2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local v5 = false

			for i = 1, 2 do
				local clone = game.ReplicatedStorage.Utils.Todo.Clap:Clone()
				clone.Position = i == 1 and humanoidRootPart.Position or humanoidRootPart2.Position
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 1.5)
				clone.Attachment.Sparks:Emit(20)
				TweenService:Create(clone, TweenInfo.new(0.3), {
					Size = createVector(0, 0, 0),
					Transparency = 1
				}):Play()
				v3:PlaySound(sounds.Todo.Clap, clone, game.SoundService.Effect)

				if not (v5 == false and (clone.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 50) then
					continue
				end

				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				v5 = true
			end

			if instance2 and instance2:GetAttribute("Ragdoll") > 0 or (p == true or not _G.Shift) then
				return
			end

			if localPlayer.Character == instance then
				local objectSpace = humanoidRootPart.CFrame:ToObjectSpace(workspace.CurrentCamera.CFrame)
				humanoidRootPart.CFrame = cFrame
				workspace.CurrentCamera.CFrame = cFrame:ToWorldSpace(objectSpace)
			elseif localPlayer.Character == instance2 then
				local objectSpace = humanoidRootPart2.CFrame:ToObjectSpace(workspace.CurrentCamera.CFrame)
				humanoidRootPart.CFrame = cFrame2
				workspace.CurrentCamera.CFrame = cFrame2:ToWorldSpace(objectSpace)
			end
		end,
		Swap2 = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = false

			for i = 1, 2 do
				local clone = game.ReplicatedStorage.Utils.Todo.Clap:Clone()
				clone.Position = i == 1 and humanoidRootPart.Position or instance2.PrimaryPart.Position
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 1.5)
				clone.Attachment.Sparks:Emit(20)
				TweenService:Create(clone, TweenInfo.new(0.3), {
					Size = createVector(0, 0, 0),
					Transparency = 1
				}):Play()
				v3:PlaySound(sounds.Todo.Clap, clone, game.SoundService.Effect)

				if not (v5 == false and (clone.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 50) then
					continue
				end

				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				v5 = true
			end
		end,
		Fakeout = function(p, p2)
			local clone = game.ReplicatedStorage.Utils.Todo.Clap:Clone()
			clone.Position = p2 or p.HumanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.5)
			clone.Attachment.Sparks:Emit(20)
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(0, 0, 0),
				Transparency = 1
			}):Play()
			v3:PlaySound(sounds.Todo.Clap, clone, game.SoundService.Effect)

			if (clone.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 130 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Perfect = function(parent)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local highlight = Instance.new("Highlight")
			highlight.OutlineColor = Color3.fromRGB(85, 255, 255)
			highlight.FillColor = Color3.fromRGB(170, 255, 255)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = parent
			Debris:AddItem(highlight, 0.5)
			TweenService:Create(highlight, TweenInfo.new(0.5), {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
			v3:PlaySound(sounds.Todo.Perfect, humanoidRootPart, game.SoundService.Effect)
		end,
		Woosh = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Todo.Woosh:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2.7)
			clone.Attachment.Glow:Emit(1)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					TweenService:Create(emitter, TweenInfo.new(0.7), {
						Rate = 0
					}):Play()
				end
			end
		end,
		GrabHit = function(p, instance, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))

			if p2 == 1 then
				v3:PlaySound(sounds.Hakari.OverLuck.Hit2, humanoidRootPart, game.SoundService.Effect)
				local clone = utils.Gojo.HardHit:Clone()
				clone.CFrame = humanoidRootPart.CFrame
				clone.Parent = workspace.Effects
				clone.Dust:Emit(5)
				clone.Ring:Emit(5)
				clone.Sparks:Emit(10)
				Debris:AddItem(clone, 0.5)

				if localPlayer == p or localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end
			elseif p2 == 2 then
				v3:PlaySound(
					sounds.Gojo.M1:FindFirstChild("Hit" .. math.random(1, 4)),
					humanoidRootPart,
					game.SoundService.Effect
				)
			elseif p2 == 3 then
				v3:PlaySound(sounds.Gojo.M1.Hit4, humanoidRootPart, game.SoundService.Effect)

				if localPlayer == p or localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
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
		BlueGrab2 = function(parent)
			local clone = utils.Itadori.CounterHit.Feint:Clone()

			for _, child in clone:GetChildren() do
				child.Color = ColorSequence.new(Color3.fromRGB(85, 170, 255))
			end

			clone.Parent = parent.PrimaryPart
			clone.Sparks:Emit(10)
			clone.Ring:Emit(3)
			Debris:AddItem(clone, 0.5)
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 0.5
			highlight.OutlineTransparency = 0.5
			highlight.FillColor = Color3.fromRGB(85, 170, 255)
			highlight.OutlineColor = Color3.fromRGB(85, 170, 255)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = parent
			Debris:AddItem(highlight, 0.5)
			TweenService:Create(highlight, TweenInfo.new(0.5), {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
		end,
		Chat = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Todo.Awaken.SFX, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				local clone = utils.Todo.Awakening.Flash:Clone()
				local camera = Instance.new("Camera", clone.Main)
				local camera2 = Instance.new("Camera", clone.Chain)
				clone.Main.CurrentCamera = camera
				clone.Chain.CurrentCamera = camera2
				clone.Parent = localPlayer.PlayerGui
				local clone2 = utils.DomainWarn.Panel.Viewport.Display:Clone()
				clone2["Left Arm"].FingersL:Destroy()
				clone2["Right Arm"].FingersR:Destroy()
				clone2.Parent = clone.Main
				pcall(function()
					v3:ApplyCopyOutfit(instance, clone2)
				end)
				clone2.Humanoid:LoadAnimation(animations.Todo.Ultimate):Play(0)
				local clone3 = utils.Todo.Awakening.Takada:Clone()
				clone3.Parent = clone.Main
				clone3.Humanoid:LoadAnimation(clone.Main.TakadaSummon):Play(0)
				clone3.HumanoidRootPart.CFrame = clone2.HumanoidRootPart.CFrame
				task.spawn(function()
					if not _G.Settings.Outfit then
						return
					end

					local humanoidDescriptionFromOutfitId = game.Players:GetHumanoidDescriptionFromOutfitId(_G.Settings.Outfit)
					clone3.Humanoid:ApplyDescriptionReset(humanoidDescriptionFromOutfitId)
					local clone4 = clone3:Clone()
					utils.Todo.Awakening.Takada:Destroy()
					clone4.Parent = utils.Todo.Awakening
				end)
				local total = 0
				local renderSteppedConnection = nil
				local cameraData = utils.Todo.Awakening.CameraData
				renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					local v5 = dt * 60
					total += v5
					local child = cameraData.Frames:FindFirstChild((tonumber((math.ceil(total)))))
					local child2 = cameraData.FOV:FindFirstChild((tonumber((math.ceil(total)))))

					if child and child2 then
						camera.CFrame = clone2.HumanoidRootPart.CFrame * child.Value
						camera.FieldOfView = child2.Value
					else
						renderSteppedConnection:Disconnect()
					end
				end)
				local clone4 = utils.Todo.Awakening.Aura:Clone()
				clone4.Parent = workspace.Effects
				local clone5 = utils.Todo.Awakening.CC:Clone()
				clone5.Parent = game.Lighting
				local clone6 = utils.Todo.Awakening.Imagination:Clone()
				clone6.Label.Text = "※ THIS IS " .. string.upper(localPlayer.DisplayName or localPlayer.Name) .. "'S IMAGINATION"
				clone6.Label.Label.Text = clone6.Label.Text
				TweenService:Create(clone6.Label, TweenInfo.new(0.5), {
					TextTransparency = 0.5
				}):Play()
				TweenService:Create(clone6.Label.Label, TweenInfo.new(0.5), {
					TextTransparency = 0
				}):Play()
				clone6.Parent = localPlayer.PlayerGui
				local v5 = v3:PlaySound(sounds.Todo.Awaken.Music, workspace, game.SoundService.Music, true)
				task.spawn(function()
					repeat
						clone4.Position = workspace.CurrentCamera.CFrame.Position
						task.wait()
					until not (instance.Parent and instance:GetAttribute("InUlt"))

					if v5 then
						TweenService:Create(v5, TweenInfo.new(1.5), {
							Volume = 0
						}):Play()
						Debris:AddItem(v5, 1.5)
					end

					if clone4 then
						for _, child in clone4:GetChildren() do
							child.Enabled = false
						end

						Debris:AddItem(clone4, 2)
					end

					if clone5 then
						TweenService:Create(clone5, TweenInfo.new(1), {
							TintColor = Color3.new(1, 1, 1),
							Brightness = 0
						}):Play()
						Debris:AddItem(clone5, 1)
					end

					if clone6 then
						TweenService:Create(clone6.Label, TweenInfo.new(0.5), {
							TextTransparency = 1
						}):Play()
						TweenService:Create(clone6.Label.Label, TweenInfo.new(0.5), {
							TextTransparency = 1
						}):Play()
						Debris:AddItem(clone6, 0.5)
					end
				end)
				local track = clone.Chain.Necklace.Ctrl:LoadAnimation(clone.Chain.Chain)
				camera2.CFrame = clone.Chain.Necklace.RootPart.CFrame * CFrame.new(0, 0, 8)
				camera2.FieldOfView = 40
				track:Play(0)
				task.delay(0.4, function()
					TweenService:Create(clone.Chain, TweenInfo.new(0.3), {
						ImageTransparency = 1
					}):Play()

					for _, animation in utils.Todo:GetDescendants() do
						if not animation:IsA("Animation") then
							continue
						end

						local track2 = clone3.Humanoid:LoadAnimation(animation)
						track2:Play(0)
						track2:Stop(0)
					end
				end)
				TweenService:Create(clone.Swipe, TweenInfo.new(0.15), {
					Position = UDim2.new(0, 0, 1, 0)
				}):Play()
				task.delay(0.05, function()
					clone.BG.Visible = true
					clone.Main.Visible = true
					task.wait(1.5)
					local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					clone.BG.BG.Visible = true

					for _, image in clone.BG.BG:GetChildren() do
						if not image:IsA("ImageLabel") then
							continue
						end

						local v6 = 1 + math.random(5, 20) / 100
						TweenService:Create(image, tweenInfo, {
							Size = UDim2.new(image.Size.X.Scale * v6, 0, image.Size.Y.Scale * v6, 0),
							Position = UDim2.new(image.Position.X.Scale * v6, 0, image.Position.Y.Scale * v6, 0)
						}):Play()
					end
				end)
				task.delay(2.25, function()
					clone.Swipe.Position = UDim2.new(0, 0, -1, 0)
					TweenService:Create(clone.Swipe, TweenInfo.new(0.2), {
						Position = UDim2.new(0, 0, 1, 0)
					}):Play()
					task.wait(0.075)
					clone.Chain.Visible = false
					clone.Main.Visible = false
					clone.BG.Visible = false
					task.spawn(function()
						local clone7 = utils.Todo.Awakening.Takada:Clone()
						clone7.HumanoidRootPart.CFrame = humanoidRootPart.CFrame
						clone7.Name = "FollowTakada"

						for _, part in clone7:GetDescendants() do
							if part:IsA("BasePart") then
								part.CollisionGroup = "NoCollision"
							end
						end

						clone7.HumanoidRootPart.Anchored = true
						clone7.Parent = workspace.Effects
						local track2 = clone7.Humanoid:LoadAnimation(animations.Todo.TakadaJoint.TakadaIdle)
						track2:Play(0)
						track2.Priority = Enum.AnimationPriority.Idle
						local humanoidRootPart2 = clone7.HumanoidRootPart
						local v6 = true

						while true do
							local v7 = humanoidRootPart.CFrame * CFrame.new(-2, 2, 2)

							if clone7:GetAttribute("A") then
								v7 = humanoidRootPart.CFrame * clone7:GetAttribute("A")
							end

							humanoidRootPart2.CFrame = humanoidRootPart2.CFrame:Lerp(v7, 0.1)
							local v8 = not (instance:GetAttribute("Stun") or instance:GetAttribute("Ragdoll") > 0)

							if v8 == true and v6 == false then
								v6 = true

								for _, descendant in clone7:GetDescendants() do
									if not (descendant.Name ~= "HumanoidRootPart" and (descendant:IsA("BasePart") or descendant:IsA("Decal"))) then
										continue
									end

									TweenService:Create(descendant, TweenInfo.new(0.3), {
										Transparency = 0
									}):Play()
								end
							elseif v8 == false and v6 == true then
								v6 = false

								for _, descendant in clone7:GetDescendants() do
									if not (descendant.Name ~= "HumanoidRootPart" and (descendant:IsA("BasePart") or descendant:IsA("Decal"))) then
										continue
									end

									TweenService:Create(descendant, TweenInfo.new(0.3), {
										Transparency = 1
									}):Play()
								end
							end

							task.wait()

							if humanoidRootPart.Parent and instance.Parent and instance:GetAttribute("InUlt") then
								continue
							end

							Debris:AddItem(clone7, 0.5)

							for _, descendant in clone7:GetDescendants() do
								if descendant:IsA("BasePart") or descendant:IsA("Decal") then
									TweenService:Create(descendant, TweenInfo.new(0.5), {
										Transparency = 1
									}):Play()
								end
							end

							break
						end
					end)
				end)
			end
		end,
		Applause = function(parent)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = game.ReplicatedStorage.Utils.Todo.Clap:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.5)
			clone.Attachment.Sparks:Emit(20)
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(0, 0, 0),
				Transparency = 1
			}):Play()
			v3:PlaySound(sounds.Todo.Clap, clone, game.SoundService.Effect)
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 0.5
			highlight.OutlineTransparency = 0.5
			highlight.FillColor = Color3.fromRGB(255, 255, 255)
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = parent
			Debris:AddItem(highlight, 2)
			TweenService:Create(highlight, TweenInfo.new(2), {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
			v3:PlaySound(sounds.Todo.OST, humanoidRootPart, game.SoundService.Music)
			v3:PlaySound(sounds.Todo.Voice, humanoidRootPart, game.SoundService.Voice)
			parent.Humanoid:LoadAnimation(animations.Todo.Summon):Play(0)

			if (clone.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 130 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
	v = Knit.GetService("TodoService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller