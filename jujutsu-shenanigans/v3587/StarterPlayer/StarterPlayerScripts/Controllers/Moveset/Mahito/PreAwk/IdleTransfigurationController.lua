local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "IdleTransfigurationController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.fromRGB(170, 85, 255), 1)
			v3:PlaySound(sounds.Mahito.Transfig.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Flash = function(self)
			local humanoidRootPart = self:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Mahito.Transfig.Eyes, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.EyeGlow:Clone()
			clone.Weld.Part0 = self.Head
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Eye1.Glow:Emit(1)
			clone.Eye2.Glow:Emit(1)
			clone.Glow:Emit(1)
			task.wait(0.8)
			clone.Trail1.Trail.Enabled = false
			clone.Trail2.Trail.Enabled = false
		end,
		Dash = function(instance, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Itadori.Rush.Rush, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			clone.Dust:Emit(7)
			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			Debris:AddItem(clone, 2)
			local clone2 = utils.Itadori.Shock:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(8, 0, 8),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.2)
			task.delay(0.1, function()
				local clone3 = utils.Itadori.Shock:Clone()
				clone3.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone3, 0.2)
				local now = tick()

				repeat
					if now < tick() then
						now = tick() + math.random(8, 14) / 100
						local clone4 = utils.Mahito.BodyRepel["Wind" .. math.random(1, 5)]:Clone()
						clone4.CFrame = humanoidRootPart.CFrame * CFrame.Angles(
							1.5707963267948966,
							math.rad((math.random(0, 360))),
							0
						)
						clone4.Size = createVector(6, 6, 6)
						TweenService:Create(clone4, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
							CFrame = clone4.CFrame + humanoidRootPart.CFrame.LookVector * 3,
							Size = createVector(7, 0, 7)
						}):Play()
						Debris:AddItem(clone4, 0.3)
						clone4.Parent = workspace.Effects
						TweenService:Create(clone4, TweenInfo.new(0.15), {
							Transparency = 0.5
						}):Play()
						task.delay(0.15, function()
							TweenService:Create(clone4, TweenInfo.new(0.15), {
								Transparency = 1
							}):Play()
						end)
					end

					task.wait()
				until not (parent.Parent and humanoidRootPart.Parent)
			end)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				local numberValue = Instance.new("NumberValue", parent)
				numberValue.Value = 200
				TweenService:Create(
					numberValue,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Value = 50
					}
				):Play()

				repeat
					parent.Velocity = humanoidRootPart.CFrame.LookVector * numberValue.Value
					RunService.Stepped:Wait()
				until not (parent.Parent and humanoidRootPart.Parent)
			end
		end,
		Hit = function(p, parent)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(parent, Color3.fromRGB(170, 85, 255), 3)
			v3:PlaySound(sounds.Hakari.OverLuck.Hit1, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.Soulfire.Morph, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)

			if localPlayer == p or localPlayer.Character == parent then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				local clone2 = utils.Hakari.IdleDeath.AudioVis:Clone()
				clone2.Beat.ImageTransparency = 0
				clone2.Beat.ImageColor3 = Color3.fromRGB(170, 85, 255)
				clone2.Parent = localPlayer.PlayerGui
				Debris:AddItem(clone2, 0.6)
				local pointLight = Instance.new("PointLight")
				pointLight.Brightness = 20
				pointLight.Range = 15
				pointLight.Color = Color3.fromRGB(170, 85, 255)
				pointLight.Parent = clone
				local highlight = Instance.new("Highlight")
				highlight.FillTransparency = 1
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.Parent = parent
				TweenService:Create(highlight, TweenInfo.new(0.8), {
					OutlineTransparency = 1
				}):Play()
				Debris:AddItem(highlight, 0.8)
				TweenService:Create(
					game.Lighting,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						ExposureCompensation = -4
					}
				):Play()
				TweenService:Create(pointLight, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Brightness = 90
				}):Play()
				TweenService:Create(clone2.Beat, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Size = UDim2.new(1.3, 0, 1.3, 0),
					ImageTransparency = 0
				}):Play()
				task.wait(0.2)
				TweenService:Create(clone2.Beat, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Size = UDim2.new(2, 0, 2, 0),
					ImageTransparency = 1
				}):Play()
				task.wait(0.1)
				TweenService:Create(game.Lighting, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					ExposureCompensation = 0
				}):Play()
				TweenService:Create(pointLight, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Brightness = 0
				}):Play()
			end
		end,
		HitFinish = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.FocusHit.Burst:Clone()

			if instance:GetAttribute("Moveset") == "Nanami" then
				local model = Instance.new("Model")
				local part = Instance.new("Part")
				part.Parent = model
				clone.Parent = part
				model:ScaleTo(1.5)
				Debris:AddItem(model, 0.2)
			end

			clone.Parent = humanoidRootPart
			clone.Glow:Emit(1)
			clone.Wind2:Emit(10)
			Debris:AddItem(clone, 0.7)
			v3:PlaySound(sounds.Mahito.Slap, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Finisher = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = instance:GetAttribute("Moveset") == "Nanami"
			local clone = utils.Mahito.FocusHit.Burst:Clone()

			if v5 then
				local model = Instance.new("Model")
				local part = Instance.new("Part")
				part.Parent = model
				clone.Parent = part
				model:ScaleTo(1.5)
				Debris:AddItem(model, 0.2)
			end

			clone.Parent = humanoidRootPart
			task.delay(0.3, function()
				if not humanoidRootPart.Parent then
					return
				end

				v3:PlaySound(sounds.Itadori.Rush.RushBreak, humanoidRootPart, game.SoundService.Effect)
				clone.Glow:Emit(1)
				task.wait(0.3)
				clone.Wind:Emit(10)
				clone.Wind2:Emit(10)
			end)
			local torso = v5 and instance.Torso or instance.Head

			for _ = 1, 7 do
				local clone2 = utils.Mahito.Morph:Clone()
				clone2.Weld.Part0 = torso
				clone2.Color = torso.Color
				clone2.Material = torso.Material
				clone2.Weld.C1 = CFrame.new(
					math.random(-torso.Size.X, torso.Size.X) / 2,
					math.random(-torso.Size.Y, torso.Size.Y) / 2,
					math.random(-torso.Size.Z, torso.Size.Z) / 2
				)
				clone2.Parent = workspace.Effects
				local v6 = math.random(10, 20) / (v5 and 6 or 10)
				clone2.Size = createVector(0, 0, 0)
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
					Size = createVector(1, 1, 1) * v6
				}):Play()
				Debris:AddItem(clone2, 1.5)
				task.delay(0.6, function()
					clone2.Weld:Destroy()
					clone2.Velocity = Vector3.new(math.random(-40, 40), math.random(-20, 40), math.random(-40, 40))
					TweenService:Create(clone2, TweenInfo.new(0.5), {
						Size = createVector(0, 0, 0)
					}):Play()
				end)
			end

			task.delay(0.6, function()
				if not instance.Parent then
					return
				end

				local v6 = v3:PlaySound(sounds.Itadori.Dismantle.Explode, instance, game.SoundService.Effect)
				v6.RollOffMaxDistance = 400
				v6.RollOffMinDistance = 100

				for _ = 1, 10 do
					local clone2 = utils.Damage.Chunk:Clone()
					clone2.CFrame = torso.CFrame
					clone2.Blood.Enabled = false
					clone2.Velocity = Vector3.new(math.random(-60, 60), math.random(-30, 60), math.random(-60, 60))
					clone2.RotVelocity = Vector3.new(
						math.random(-200, 200),
						math.random(-200, 200),
						math.random(-200, 200)
					)
					clone2.Parent = workspace.Effects
					Debris:AddItem(clone2, 1)

					if _G.Settings.Gore ~= false then
						continue
					end

					clone2.Color = Color3.fromRGB(255, 85, 255)
					clone2.Trail.Color = ColorSequence.new(Color3.fromRGB(255, 85, 255))
				end

				if v5 then
					instance.Torso.Transparency = 1
					instance["Left Arm"].Transparency = 1
					instance["Right Arm"].Transparency = 1
				end

				instance.Head.Transparency = 1
				local decal = instance.Head:FindFirstChildWhichIsA("Decal")

				if decal then
					decal.Transparency = 1
				end

				for _, accessory in instance:GetChildren() do
					if not accessory:IsA("Accessory") then
						continue
					end

					local handle = accessory:FindFirstChild("Handle", true)

					if not (handle:FindFirstChild("HairAttachment") or handle:FindFirstChild("HatAttachment") or handle:FindFirstChild("FaceCenterAttachment") or handle:FindFirstChild("FaceFrontAttachment") or v5 and handle:FindFirstChild("NeckAttachment") or v5 and handle:FindFirstChild("BodyBackAttachment")) then
						continue
					end

					accessory:Destroy()
				end

				if instance:FindFirstChild("SetAssets") and v5 then
					instance.SetAssets:Destroy()
				end

				if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 40 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				end
			end)
		end,
		BlackFlashImpact = function(instance, instance2)
			local WAIT_INTERVAL = 0.04

			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance2, Color3.new(1, 0, 0))
			v3:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone.Brightness = 200
				clone.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone:Destroy()
			end
		end,
		BlackFlashHit = function(instance, instance2)
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
			v3:Flash(instance2, Color3.new(1, 0, 0), 2)
			v3:PlaySound(sounds.Mahito.BlackFlash, humanoidRootPart2, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone2.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone2.Brightness = 200
				clone2.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone2.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone2.Brightness = -200
				clone2.Contrast = 1000
				task.wait(WAIT_INTERVAL)
				clone2:Destroy()
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
	v = Knit.GetService("IdleTransfigurationService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller