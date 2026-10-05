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
	Name = "IdolDebutController"
})

function controller.KnitStart(_)
	local v4 = {
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hakari.EnergySurge.Swag, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.DrillSplit.Leap, humanoidRootPart, game.SoundService.Effect)
			local followTakada = workspace.Effects:FindFirstChild("FollowTakada")

			if followTakada and localPlayer.Character == instance then
				local track = followTakada.Humanoid:LoadAnimation(animations.Todo.IdolDebut)
				track:Play()
				task.wait(0.7)
				track:Stop()
			end
		end,
		Swing2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Hakari.RoughSwing:Clone()
			clone.Weld.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(0, 0, 3.839724354387525)
			clone.Beam.Width0 = 50
			clone.Beam.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Core.Flames.Enabled = false
			clone.Weld.Part0 = humanoidRootPart
			clone.Beam.CurveSize0 = -8
			clone.Beam.CurveSize1 = 8
			clone.A0.CFrame -= createVector(3.6, 0, 0)
			clone.A1.CFrame += createVector(3.6, 0, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.1)
			v3:PlaySound(sounds.Hakari.Counter.Startup, humanoidRootPart, game.SoundService.Effect)
			TweenService:Create(
				clone.Weld,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					C1 = clone.Weld.C1 * CFrame.Angles(0, 3.141592653589793, 0)
				}
			):Play()
			TweenService:Create(clone.Beam, TweenInfo.new(0.3), {
				Width0 = 0
			}):Play()
		end,
		Jump = function(p, p2)
			local humanoidRootPart = p2.Parent.Parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = humanoidRootPart.CFrame.LookVector * 5 - createVector(0, 5, 0)

			if localPlayer.Character == humanoidRootPart.Parent then
				TweenService:Create(p2, TweenInfo.new(0.5), {
					P = 100000
				}):Play()

				repeat
					p2.Position = p.Position - v5
					task.wait()
				until not (p2.Parent and p)
			else
				repeat
					local v6 = humanoidRootPart.CFrame - humanoidRootPart.Position + p.Position - v5
					humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(v6, 0.15)
					task.wait()
				until not (p2.Parent and p)
			end

			TweenService:Create(p2, TweenInfo.new(0.5), {
				P = 100000
			}):Play()

			repeat
				p2.Position = p.Position - v5
				task.wait()
			until not (p2.Parent and p)
		end,
		JumpBurst = function(position, p)
			if localPlayer.Character == p then
				return
			end

			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.Position = position
			clone.PointLight:Destroy()
			clone.Air:Destroy()
			clone.Parent = workspace.Effects
			clone.Floor.Wind2.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Floor.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Floor.Ring:Emit(10)
			clone.Floor.Sparks:Emit(10)
			clone.Floor.Wind2:Emit(8)
			Debris:AddItem(clone, 1.5)
			v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, clone, game.SoundService.Effect)
			v3:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)
		end,
		Hit = function(instance, instance2)
			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			if localPlayer.Character == instance and instance:GetAttribute("InUlt") then
				local clone2 = utils.Todo.Debut.Flash:Clone()
				local camera = Instance.new("Camera", clone2.Main)
				clone2.Main.CurrentCamera = camera
				clone2.Parent = localPlayer.PlayerGui
				TweenService:Create(clone2.Fade, TweenInfo.new(0.2), {
					BackgroundTransparency = 1
				}):Play()
				local clone3 = utils.DomainWarn.Panel.Viewport.Display:Clone()
				clone3["Left Arm"].FingersL:Destroy()
				clone3["Right Arm"].FingersR:Destroy()
				clone3.Parent = clone2.Main
				pcall(function()
					v3:ApplyCopyOutfit(instance, clone3)
				end)
				clone3.Humanoid:LoadAnimation(clone2.User):Play(0)
				local clone4 = utils.Todo.Awakening.Takada:Clone()
				clone4.Parent = clone2.Main
				clone4.HumanoidRootPart.CFrame = clone3.HumanoidRootPart.CFrame
				clone4.Humanoid:LoadAnimation(clone2.Takada):Play(0)
				local clone5 = utils.DomainWarn.Panel.Viewport.Display:Clone()
				clone5["Left Arm"].FingersL:Destroy()
				clone5["Right Arm"].FingersR:Destroy()
				clone5.Parent = clone2.Main
				pcall(function()
					v3:ApplyCopyOutfit(instance2, clone5)
				end)
				clone5.Humanoid:LoadAnimation(clone2.Target):Play(0)
				local total = 0
				local renderSteppedConnection = nil
				local cameraData = utils.Todo.Debut.CameraData
				renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					local v5 = dt * 60
					total += v5
					local child = cameraData.Frames:FindFirstChild((tonumber((math.ceil(total)))))
					local child2 = cameraData.FOV:FindFirstChild((tonumber((math.ceil(total)))))

					if child and child2 and clone3.Parent then
						camera.CFrame = clone3.HumanoidRootPart.CFrame * child.Value
						camera.FieldOfView = child2.Value
					else
						renderSteppedConnection:Disconnect()
					end
				end)
				task.delay(1, function()
					local WAIT_INTERVAL = 0.03
					v3:PlaySound(sounds.Todo.Debut.Jump, workspace, game.SoundService.Effect)
					v3:PlaySound(sounds.Todo.Debut.Jump2, workspace, game.SoundService.Effect)
					task.wait(0.55)
					v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, workspace, game.SoundService.Effect)
					task.wait(0.45)
					TweenService:Create(clone2.Fade, TweenInfo.new(0.2), {
						BackgroundTransparency = 0
					}):Play()
					task.wait(0.2)
					clone2:Destroy()

					if _G.Settings.Flash == true then
						local clone6 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
						clone6.TintColor = Color3.fromRGB(255, 0, 255)
						clone6.Parent = game.Lighting
						task.wait(WAIT_INTERVAL)
						clone6.Brightness = 200
						clone6.Contrast = -1000
						task.wait(WAIT_INTERVAL)
						clone6.TintColor = Color3.new(1, 1, 1)
						clone6.Brightness = -200
						clone6.Contrast = 1000
						task.wait(WAIT_INTERVAL)
						clone6:Destroy()
					end

					game.Lighting.ExposureCompensation = 2
					TweenService:Create(game.Lighting, TweenInfo.new(1), {
						ExposureCompensation = 0
					}):Play()
				end)
			end
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Todo.BruteForce.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
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
	v = Knit.GetService("IdolDebutService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller