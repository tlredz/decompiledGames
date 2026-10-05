local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local LightningBeams = require(replicatedStorage.Modules.LightningBeams)
local random = Random.new()
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "DivergentFistController"
})

function controller.KnitStart(_)
	local v3 = {
		CurseBuild = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.DivergentFist.Crack, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.142)
			v2:Flash(instance, Color3.new(1, 1, 1), 0.275)
		end,
		DivergentSwing = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.DivergentFist.DivergentSwing:Clone()
			clone.Weld.Part1 = humanoidRootPart
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			v2:PlaySound(sounds.Itadori.DivergentFist.Swing, humanoidRootPart, game.SoundService.Effect)

			if p == true then
				clone.BlackFlashSparks:Emit(20)
				clone.BlackFlashWind:Emit(10)
				clone.BlackFlashLight.Enabled = true
				TweenService:Create(clone.BlackFlashLight, TweenInfo.new(0.6), {
					Brightness = 0
				}):Play()
				v2:PlaySound(sounds.Itadori.DivergentFist.BlackFlash, humanoidRootPart, game.SoundService.Effect)

				if localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end
			else
				clone.Wind:Emit(7)
				clone.Charge:Emit(1)
				clone.Glow:Emit(1)
				task.delay(0.3, function()
					clone.DivergentLight.Enabled = true
					TweenService:Create(clone.DivergentLight, TweenInfo.new(0.6), {
						Brightness = 0
					}):Play()
					v2:PlaySound(sounds.Itadori.DivergentFist.Divergent, humanoidRootPart, game.SoundService.Effect)
					clone.Flames:Emit(10)
					clone.Sparks:Emit(20)
					clone.Wind2:Emit(6)
				end)

				if localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
					task.wait(0.3)
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end
			end
		end,
		DivergentHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(0.333333, 0.666667, 1))
			v2:PlaySound(sounds.Itadori.DivergentFist.DivergentHit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		DivergentStun = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Itadori.DivergentFist.DivergentStun:Clone()
			clone.CFrame = CFrame.lookAt(humanoidRootPart2.Position, humanoidRootPart.Position)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.8)
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = createVector(0, 0, 15)
			}):Play()
			clone.Attachment.Lightning:Emit(5)
			clone.Attachment.Sparks:Emit(30)
			clone.Attachment.Glow:Emit(1)
			clone.Attachment.Wind:Emit(15)
			clone.Attachment.Flames:Emit(15)
			TweenService:Create(clone.PointLight, TweenInfo.new(0.8), {
				Brightness = 0
			}):Play()
			v2:Flash(instance2, Color3.new(0.333333, 0.666667, 1), 1.3)
			v2:PlaySound(sounds.Itadori.DivergentFist.DivergentHit, humanoidRootPart2, game.SoundService.Effect)

			if localPlayer.Character == instance2 or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		BlackFlashHit = function(instance, instance2)
			local WAIT_INTERVAL = 0.04

			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			for _, part in instance2:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local clone = utils.Itadori.DivergentFist.FlashBurn:Clone()
				clone.Parent = part
				Debris:AddItem(clone, 1)
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashHit:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			v2:Flash(instance2, Color3.new(1, 0, 0))
			v2:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart, game.SoundService.Effect)
			clone.Wind2:Emit(8)
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			task.delay(0.1, function()
				clone.Blast:Emit(8)
				clone.Sparks:Emit(15)
				clone.Lightning:Emit(6)
				clone.Wind:Emit(7)
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone2.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone2.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone2.Brightness = 200
				clone2.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone2:Destroy()
			end
		end,
		BlackFlashChain = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashHit:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			v2:Flash(instance2, Color3.new(1, 0, 0))
			v2:PlaySound(sounds.Itadori.PerfectHit, humanoidRootPart, game.SoundService.Effect)
			clone.Wind2:Emit(8)
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			task.delay(0.1, function()
				clone.Blast:Emit(8)
				clone.Sparks:Emit(15)
				clone.Lightning:Emit(6)
				clone.Wind:Emit(7)
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		BlackFlashFinisher = function(instance, instance2, p)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			for _, part in instance2:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local clone = utils.Itadori.DivergentFist.FlashBurn:Clone()
				clone.Parent = part
				Debris:AddItem(clone, 1)
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.Sparks:Emit(20)
			clone.Flare:Emit(20)
			clone.Lightning:Emit(25)
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			Debris:AddItem(clone, 3)
			v2:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart2, game.SoundService.Effect)

			if not p then
				v2:PlaySound(sounds.Itadori.DivergentFist.Voice, humanoidRootPart, game.SoundService.Effect)
			end

			v2:Bleed(instance2)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone2.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone2.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone2.Brightness = 200
				clone2.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone2:Destroy()
			end
		end,
		Finisher = function(p)
			if not p.HumanoidRootPart then
				return
			end

			v2:Bleed(p)
		end,
		MusicStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.DivergentFist.Woosh, humanoidRootPart, game.SoundService.Music)
		end,
		Music = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.DivergentFist.Wapam, humanoidRootPart, game.SoundService.Music)
		end,
		BlackFlashHitHard = function(instance, instance2, instance3)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Todo.BlackFlashHit:Clone()
			clone.Position = humanoidRootPart2.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)
			v2:Flash(instance2, Color3.new(1, 0, 0), 2)
			v2:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart2, game.SoundService.Effect)
			v2:PlaySound(sounds.Mahito.BlackFlash, humanoidRootPart2, game.SoundService.Effect)
			v2:PlaySound(sounds.Itadori.DivergentFist.Voice2, humanoidRootPart2, game.SoundService.Voice)
			task.delay(0.07, function()
				clone.Wind2:Emit(10)
				clone.Sparks:Emit(40)
				clone.Sparks2:Emit(30)
				clone.Lightning:Emit(10)
				TweenService:Create(clone, TweenInfo.new(0.1), {
					Size = createVector(18, 18, 18),
					Transparency = 1
				}):Play()
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				task.spawn(function()
					local WAIT_INTERVAL = 0.03
					CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1.8)

					if _G.Settings.Flash == true then
						local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
						clone2.Parent = game.Lighting
						task.wait(WAIT_INTERVAL)
						clone2.Brightness = 200
						clone2.Contrast = -1000
						task.wait(WAIT_INTERVAL)
						clone2.TintColor = Color3.new(1, 1, 1)
						clone2.Brightness = -200
						clone2.Contrast = 1000
						task.wait(WAIT_INTERVAL)
						clone2:Destroy()
					end

					game.Lighting.ExposureCompensation = 2
					TweenService:Create(game.Lighting, TweenInfo.new(0.5), {
						ExposureCompensation = 0
					}):Play()
				end)
				local clone2 = utils.Itadori.DivergentFist.FinisherScene:Clone()
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 1.8)

				if _G.Settings.Flash ~= true then
					for _, emitter in clone2:GetDescendants() do
						if emitter:IsA("ParticleEmitter") then
							emitter.Rate /= 10
						end
					end
				end

				task.delay(1.2, function()
					local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

					for _, emitter in clone2:GetDescendants() do
						if emitter:IsA("ParticleEmitter") then
							TweenService:Create(emitter, tweenInfo, {
								TimeScale = 0.05
							}):Play()
						end
					end
				end)
				local model = Instance.new("Model", clone2)
				local highlight = Instance.new("Highlight", model)
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.OutlineColor = Color3.new(1, 0, 0)
				highlight.FillColor = Color3.new(0, 0, 0)
				highlight.FillTransparency = 0
				local lastTime = tick()
				task.spawn(function()
					repeat
						clone2.CFrame = humanoidRootPart.CFrame - humanoidRootPart.Position + workspace.CurrentCamera.CFrame.Position
						local v4 = math.clamp((tick() - lastTime) / 1.8, 0, 1)
						clone2.Smear.Color = ColorSequence.new(
							Color3.fromRGB(85, 170, 255):Lerp(Color3.fromRGB(255, 118, 5), v4),
							Color3.fromRGB(0, 0, 0):Lerp(Color3.fromRGB(200, 0, 0), v4)
						)
						task.wait()
					until not (instance3:IsDescendantOf(workspace) and clone2.Parent)

					clone2:Destroy()
				end)
				task.spawn(function()
					local rootAttachment = humanoidRootPart2.RootAttachment

					repeat
						local attachment = Instance.new("Attachment", humanoidRootPart2)
						attachment.Position = random:NextUnitVector() * 30
						local v4 = LightningBeams.new(rootAttachment, attachment, nil, model)
						v4.Color = Color3.new(1, 0, 0)
						v4.PulseSpeed = 300
						v4.FadeLength = 0.35
						v4.MaxRadius = 20
						v4.MinRadius = 0
						v4.AnimationSpeed = _G.Settings.Flash == true and 75 or 5
						v4.MinThicknessMultiplier = 0.1
						v4.MaxThicknessMultiplier = 3
						task.delay(0.1, function()
							v4:Destroy()
						end)
						task.wait(0.02)
					until not model.Parent or not humanoidRootPart2.Parent or tick() - lastTime > 1.2

					if model.Parent and humanoidRootPart2.Parent then
						local pointLight = Instance.new("PointLight", humanoidRootPart2)
						pointLight.Color = Color3.fromRGB(255, 170, 0)
						pointLight.Range = 30
						TweenService:Create(pointLight, TweenInfo.new(0.6), {
							Brightness = 20
						}):Play()
						Debris:AddItem(pointLight, 0.6)

						for _ = 1, 10 do
							local attachment = Instance.new("Attachment", humanoidRootPart2)
							attachment.Position = random:NextUnitVector() * 30
							local v4 = LightningBeams.new(rootAttachment, attachment, nil, model)
							v4.Color = Color3.new(1, 0, 0)
							v4.PulseSpeed = 5
							v4.FadeLength = 1
							v4.MaxRadius = 30
							v4.MinRadius = 0
							v4.AnimationSpeed = 5
							v4.MinThicknessMultiplier = 0.1
							v4.MaxThicknessMultiplier = 3
							task.wait()
							task.delay(1, function()
								v4:Destroy()
							end)
						end
					end
				end)
			end
		end,
		BlackFlashFinisherHard = function(instance, instance2)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.Sparks:Emit(20)
			clone.Flare:Emit(20)
			clone.Lightning:Emit(25)
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			Debris:AddItem(clone, 3)
			v2:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart2, game.SoundService.Effect)
			v2:Bleed(instance2)
			local model = Instance.new("Model", workspace.Effects.Bolt)
			local highlight = Instance.new("Highlight", model)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.OutlineColor = Color3.new(1, 0, 0)
			highlight.FillColor = Color3.new(0, 0, 0)
			highlight.FillTransparency = 0
			Debris:AddItem(model, 1.2)
			local v4 = LightningBeams.new(clone.Core, humanoidRootPart2.RootAttachment, nil, model)
			v4.Color = Color3.new(1, 0, 0)
			v4.PulseSpeed = 1000
			v4.FadeLength = 0.35
			v4.MaxRadius = 20
			v4.MinRadius = 0
			v4.AnimationSpeed = 300
			v4.MinThicknessMultiplier = 0.5
			v4.MaxThicknessMultiplier = 10
			task.delay(0.1, function()
				local WAIT_INTERVAL2 = 0.1
				v4.MaxThicknessMultiplier = 5
				task.wait(WAIT_INTERVAL2)
				v4.MaxThicknessMultiplier = 3
				task.wait(WAIT_INTERVAL2)
				v4.MaxThicknessMultiplier = 2
				task.wait(WAIT_INTERVAL2)
				v4.MaxThicknessMultiplier = 1
				task.wait(0.4)
				v4:Destroy()
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1.5)

				if _G.Settings.Flash == true then
					local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone2.Parent = game.Lighting
					task.wait(WAIT_INTERVAL)
					clone2.TintColor = Color3.new(1, 1, 1)
					task.wait(WAIT_INTERVAL)
					clone2.Brightness = 200
					clone2.Contrast = -1000
					task.wait(WAIT_INTERVAL)
					clone2:Destroy()
				end

				game.Lighting.ExposureCompensation = 3
				TweenService:Create(game.Lighting, TweenInfo.new(2, Enum.EasingStyle.Sine), {
					ExposureCompensation = 0
				}):Play()
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("DivergentFistService")
	v2 = Knit.GetController("FXController")
end

return controller