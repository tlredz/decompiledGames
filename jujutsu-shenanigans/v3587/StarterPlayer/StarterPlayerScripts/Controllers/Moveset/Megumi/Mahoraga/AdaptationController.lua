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
local controller = Knit.CreateController({
	Name = "AdaptationController"
})

function controller.KnitStart(_)
	local v3 = {
		Glow = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local outfit = instance:FindFirstChild("Outfit")

			if outfit then
				v2:PlaySound(sounds.Megumi.Mahoraga.AdaptGlow, humanoidRootPart, game.SoundService.Effect)
				local divineWheel = outfit.Head.DivineWheel
				local clone = divineWheel:Clone()
				clone.Color = Color3.fromRGB(188, 155, 93)
				clone.Material = Enum.Material.Neon
				clone.Size += createVector(0.1, 0.1, 0.1)
				local weld = Instance.new("Weld", clone)
				weld.Part0 = divineWheel
				weld.Part1 = clone
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Transparency = 1
				}):Play()
				Debris:AddItem(clone, 0.6)
			end
		end,
		Adapt = function(instance, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local divineWheelWeld = instance:FindFirstChild("DivineWheelWeld", true)

			if divineWheelWeld then
				v2:PlaySound(sounds.Megumi.Mahoraga.Adapt2, humanoidRootPart, game.SoundService.Effect)
				divineWheelWeld.C1 = CFrame.new() * CFrame.Angles(0, -90, 0)
				TweenService:Create(divineWheelWeld, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
					C1 = CFrame.new()
				}):Play()
			end

			if localPlayer.Character == instance or localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if not p2 then
					local clone = replicatedStorage.Utils.Megumi.Mahoraga.Adapt:Clone()
					clone.Type.Text = (instance:GetAttribute("A1") or "Melee") .. " Attacks"

					if instance:GetAttribute("A2") == 1.1 then
						clone.Effect.Text = "-10% DMG"
					elseif instance:GetAttribute("A2") == 1.3 then
						clone.Effect.Text = "-30% DMG"
					elseif instance:GetAttribute("A2") == 1.5 then
						clone.Effect.Text = "-50% DMG"
					elseif instance:GetAttribute("A2") == 1.7 then
						clone.Effect.Text = "-70% DMG"
					else
						clone.Effect.Text = "FULL ADAPTATION"
					end

					clone.Parent = localPlayer.PlayerGui
					Debris:AddItem(clone, 1)
					TweenService:Create(clone.Fade, TweenInfo.new(0.4), {
						Size = UDim2.new(3, 0, 3, 0),
						ImageTransparency = 1
					}):Play()
					TweenService:Create(clone.Wheel, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
						Rotation = 90
					}):Play()
					TweenService:Create(clone.Wheel.UIGradient, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
						Rotation = 0
					}):Play()
					TweenService:Create(clone.Wheel, TweenInfo.new(1), {
						ImageTransparency = 1
					}):Play()
					TweenService:Create(clone.Type, TweenInfo.new(1), {
						TextTransparency = 1
					}):Play()
					TweenService:Create(clone.Effect, TweenInfo.new(1), {
						TextTransparency = 1
					}):Play()
				end
			end
		end,
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Megumi.Mahoraga.Takedown.Startup, humanoidRootPart, game.SoundService.Effect)
		end,
		Teleport = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local model = Instance.new("Model")
			local clone = utils.Gojo.Teleport:Clone()
			clone.CFrame = humanoidRootPart.CFrame + createVector(0, 2, 0)
			clone.Parent = model
			model:ScaleTo(2)
			clone.Parent = workspace.Effects
			model:Destroy()
			Debris:AddItem(clone, 1.1)
			clone.Floor.Dust:Emit(30)
			clone.Lines:Emit(30)
			v2:PlaySound(sounds.Megumi.Mahoraga.Takedown.Teleport, humanoidRootPart, game.SoundService.Effect)
			task.delay(0.02, function()
				clone.CFrame = humanoidRootPart.CFrame
				clone.Lines:Emit(30)
				clone.Floor.Dust:Emit(30)
				local rootJoint = humanoidRootPart:FindFirstChild("RootJoint")

				if rootJoint then
					local cframe = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
					rootJoint.C0 = cframe * CFrame.new(7, 0, 0)
					TweenService:Create(rootJoint, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
						C0 = cframe
					}):Play()
				end

				local outfit = instance:FindFirstChild("Outfit")

				if outfit then
					local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

					for _, part in outfit:GetDescendants() do
						if not part:IsA("BasePart") then
							continue
						end

						local transparency = part.Transparency
						part.Transparency = 1
						TweenService:Create(part, tweenInfo, {
							Transparency = transparency
						}):Play()
					end
				end
			end)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Hit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Gojo.HardHit:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0.5235987755982988, 0, 0) + humanoidRootPart.CFrame.LookVector * 3.5
			clone.Position = humanoidRootPart2.Position
			clone.Parent = workspace.Effects
			clone.Dust:Emit(5)
			clone.Ring:Emit(5)
			clone.Sparks:Emit(10)
			Debris:AddItem(clone, 0.5)
			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Megumi.Elephant.Hit, humanoidRootPart2, game.SoundService.Effect)
			v2:PlaySound(sounds.Itadori.Rush.RushLaunch, humanoidRootPart2, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart2.Position).Magnitude < 150 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		WorldSlash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Megumi.Mahoraga.WorldSlash:Clone()
			clone:ScaleTo(2)
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, -6, 0) * CFrame.Angles(0, -1.5707963267948966, 0))
			clone.Char.Value = instance
			clone.Parent = workspace.Effects
			v2:PlaySound(sounds.Megumi.Mahoraga.WorldSlash.Startup, humanoidRootPart, game.SoundService.Effect)
			local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			for _, beam in clone.groundwavepart.windbeamburst:GetDescendants() do
				if beam:IsA("Beam") then
					TweenService:Create(beam, tweenInfo, {
						Brightness = 0,
						TextureSpeed = 0
					}):Play()
				end
			end

			local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			TweenService:Create(clone.mesh.Decal, tweenInfo2, {
				Transparency = 1
			}):Play()
			TweenService:Create(clone.mesh.Mesh, tweenInfo2, {
				Scale = createVector(16, 0, 16)
			}):Play()
			TweenService:Create(clone.mesh, tweenInfo2, {
				CFrame = clone.mesh.CFrame * CFrame.new(0, -12, 0) * CFrame.Angles(0, -3.12413936106985, 0)
			}):Play()
			clone.groundwavepart.speedlines1:Emit(10)
			clone.groundwavepart.speedlines2:Emit(10)
			clone.groundwavepart.groundwave.groundwave1:Emit(10)
			clone.groundwavepart.groundwave.groundwave2:Emit(4)
			clone.groundwavepart.groundwave.groundwave3:Emit(8)
			clone.groundwavepart.groundwave.groundwave4:Emit(8)
			clone.groundwavepart.groundwave.groundwave5:Emit(4)
			clone.groundwavepart.groundwave.groundwave6:Emit(4)
			clone.groundwavepart.groundwave.groundwave7:Emit(4)
			clone.groundwavepart.groundwave.groundwave8:Emit(6)
			clone.groundwavepart.groundwave.groundwave9:Emit(10)
			clone.groundwavepart.groundwave.groundwave10:Emit(5)
			clone.groundwavepart.groundwave.groundwave11:Emit(1)
			Debris:AddItem(clone, 3)
			local worldSlash = instance.Info:FindFirstChild("WorldSlash")

			if worldSlash then
				if (workspace.CurrentCamera.CFrame.Position - clone.PrimaryPart.Position).Magnitude < 150 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end

				worldSlash.Destroying:Connect(function()
					for _, effect in clone:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
							effect.Enabled = false
						end
					end
				end)
			end
		end,
		WorldSparkle = function(p)
			local v4 = nil

			for _, child in workspace.Effects:GetChildren() do
				if child.Name ~= "WorldSlash" then
					continue
				end

				local char = child:FindFirstChild("Char")

				if char and char.Value == p then
					v4 = child
				end
			end

			if not (v4 and v4.groundwavepart.chargespeedlines1.Enabled ~= false) then
				return
			end

			if _G.Settings.Flash == true then
				v4.groundwavepart.sparklelines1.Enabled = true
				v4.groundwavepart.sparklelines2.Enabled = true
				task.wait(0.25)

				if v4.groundwavepart.chargespeedlines1.Enabled == false then
					return
				end

				v4.groundwavepart.sparklelines1.Enabled = false
				v4.groundwavepart.sparklelines2.Enabled = false
			else
				task.wait(0.25)
			end

			if (workspace.CurrentCamera.CFrame.Position - v4.PrimaryPart.Position).Magnitude < 150 then
				if _G.Settings.Flash == true then
					local clone = utils.Megumi.Mahoraga.ImpactFrames:Clone()
					clone.Parent = game.Lighting
					task.delay(0.05, function()
						local WAIT_INTERVAL = 0.05
						clone.Contrast = 0
						clone.Saturation = 64
						task.wait(WAIT_INTERVAL)
						clone.Contrast = 8
						clone.Saturation = -1
						task.wait(WAIT_INTERVAL)
						clone.Contrast = -8
						task.wait(WAIT_INTERVAL)
						clone:Destroy()
						CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
					end)
				else
					task.delay(0.2, function()
						CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
					end)
				end
			end

			for _, child in v4.groundwavepart.impactframes["1"]:GetChildren() do
				child.Enabled = true
				local v5 = child
				task.delay(0.167, function()
					v5.Enabled = false
				end)
			end
		end,
		Interp = function(instance, folder)
			local cFrame = folder.CFrame
			local lastTime = tick()
			local positionChangedConnection = folder:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = folder.CFrame
				lastTime = tick()
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if folder.Parent then
					workspace:BulkMoveTo(
						{ folder },
						{ cFrame + cFrame.LookVector * (250 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
			local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			TweenService:Create(folder.slash.a, tweenInfo, {
				Width1 = 0
			}):Play()
			TweenService:Create(folder.slash.a2, tweenInfo, {
				Width1 = 0
			}):Play()
			TweenService:Create(folder.slash.b, tweenInfo, {
				Width1 = 0
			}):Play()
			TweenService:Create(folder.slash.b2, tweenInfo, {
				Width1 = 0
			}):Play()
			task.delay(0.5, function()
				for _, emitter in folder:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Megumi.Mahoraga.WorldSlash.Swing, humanoidRootPart, game.SoundService.Effect)
			local folder2 = nil

			for _, child in workspace.Effects:GetChildren() do
				if child.Name ~= "WorldSlash" then
					continue
				end

				local char = child:FindFirstChild("Char")

				if char and char.Value == instance then
					folder2 = child
				end
			end

			if not folder2 then
				return
			end

			for _, effect in folder2:GetDescendants() do
				if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
					effect.Enabled = false
				end
			end

			folder2.groundwavepart.slash.slash1:Emit(8)
			folder2.groundwavepart.slash.slash2:Emit(4)
			folder2.groundwavepart.slash.slash3:Emit(8)
			folder2.groundwavepart.slash.slash4:Emit(8)
		end,
		WorldHit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)

			if p then
				v2:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)
				v2:Bleed(instance)

				if localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

					if _G.Settings.Flash ~= true then
						return
					end

					local clone = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone.TintColor = Color3.new(1, 1, 1)
					clone.Parent = game.Lighting
					task.wait(0.04)
					clone.Brightness = 200
					clone.Contrast = -1000
					task.wait(0.04)
					clone:Destroy()
				end
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
	v = Knit.GetService("AdaptationService")
	v2 = Knit.GetController("FXController")
end

return controller