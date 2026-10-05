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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "ReversalRedMaxController"
})

function controller.KnitStart(_)
	local v4 = {
		Aerial = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")

			if not humanoid then
				return
			end

			local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
			bodyGyro.P = 10000
			bodyGyro.MaxTorque = createVector(40000, 40000, 40000)
			p.Position = humanoidRootPart.Position + createVector(0, 12, 0)
			humanoid.PlatformStand = true

			repeat
				local mouseTarget = v3:GetMouseTarget()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouseTarget)
				task.wait()
			until not p.Parent

			bodyGyro:Destroy()
			humanoid.PlatformStand = false
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Gojo.ReversalRed.Aim, humanoidRootPart, game.SoundService.Effect)
		end,
		Red = function(data)
			TweenService:Create(data, TweenInfo.new(1), {
				Size = createVector(1, 1, 1)
			}):Play()
			TweenService:Create(data.Light, TweenInfo.new(1), {
				Brightness = 15,
				Range = 15
			}):Play()
			v2:PlaySound(sounds.Gojo.ReversalRed.MaxCharge, data, game.SoundService.Effect)
			data.Glow:Emit(3)
			data.Wind:Emit(20)
			TweenService:Create(data.Weld, TweenInfo.new(0.95, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
				C1 = data.Weld.C1 * CFrame.new(0, 0, -4)
			}):Play()
			TweenService:Create(data.Charge, TweenInfo.new(0.4), {
				TimeScale = 1
			}):Play()
			task.wait(0.3)
			TweenService:Create(data.Beam, TweenInfo.new(1), {
				Width0 = 10,
				Width1 = 40
			}):Play()
			TweenService:Create(data.Beam2, TweenInfo.new(0.75), {
				Width1 = 30
			}):Play()
			TweenService:Create(data.AttachmentEnd, TweenInfo.new(0.75), {
				Position = createVector(0, 0, 18)
			}):Play()
			task.wait(0.1)
			data.Charge.Enabled = false
			task.wait(0.35)
			data.Charging:Emit(5)
		end,
		Fire = function(instance, p)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Gojo.ReversalRed.MaxFire, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Gojo.ReversalRed.RedMaxFire:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = p * CFrame.new(0, 1, -55)
			clone.Sparks:Emit(75)
			clone.Attachment.ChargeFire:Emit(10)
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(0, 0, 100),
				Color = Color3.new(1, 0, 0)
			}):Play()
			Debris:AddItem(clone, 1)

			if localPlayer.Character == instance then
				if _G.Settings.Flash ~= true then
					return
				end

				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
		Explode = function(position)
			local clone = utils.Gojo.ReversalRed.RedExplode:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)
			clone.Burst:Emit(1)
			clone.Sparks:Emit(15)
			clone.Wind:Emit(6)
			clone.Dust:Emit(6)
			TweenService:Create(clone.Light, TweenInfo.new(0.5), {
				Brightness = 0
			}):Play()
			v2:PlaySound(sounds.Gojo.ReversalRed.Explode, clone, game.SoundService.Effect)
		end,
		Hit = function(instance)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(
				sounds.Gojo.M1:FindFirstChild("Hit" .. math.random(1, 4)),
				humanoidRootPart,
				game.SoundService.Effect
			)

			if localPlayer.Character == instance then
				if _G.Settings.Flash ~= true then
					return
				end

				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
		Music = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			task.wait(0.1)
			v2:PlaySound(sounds.Gojo.Remember, humanoidRootPart, game.SoundService.Music)
		end,
		BlackFlashImpact = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = replicatedStorage.Utils.Itadori.DivergentFist.FinisherDrag:Clone()
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 0.8)
			v2:Flash(instance2, Color3.new(1, 0, 0), 0.8)
			v2:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Itadori.DivergentFist.BlackFlash, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone2.Brightness = -clone2.Brightness
				clone2.Contrast = -clone2.Contrast
				clone2.Parent = game.Lighting
				TweenService:Create(clone2, TweenInfo.new(1.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
					TintColor = Color3.new(1, 1, 1)
				}):Play()
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						FieldOfView = 40
					}
				):Play()
				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
				task.wait(0.8)
				shakeSustain:StartFadeOut(0.5)
				clone2:Destroy()
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						FieldOfView = 70
					}
				):Play()
			end
		end,
		BlackFlashHit = function(instance, instance2)
			local WAIT_INTERVAL = 0.03
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Gojo.BlackFlashHit:Clone()
			clone.Position = humanoidRootPart2.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)
			v2:Flash(instance2, Color3.new(1, 0, 0), 2)
			v2:PlaySound(sounds.Mahito.BlackFlash, humanoidRootPart2, game.SoundService.Effect)
			clone.Wind2:Emit(8)
			task.delay(0.2, function()
				clone.Blast:Destroy()
				clone.Sparks:Emit(30)
				clone.Sparks2:Emit(30)
				clone.Lightning:Emit(40)
				local clone2 = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
				clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
				clone2.Parent = workspace.Effects
				clone2.Wind:Emit(20)
				clone2.Sparks:Emit(20)
				clone2.Flare:Emit(20)
				clone2.Lightning:Emit(25)
				clone2.Back1.Back:Emit(1)
				clone2.Back2.Back:Emit(1)
				TweenService:Create(clone2.Back1, TweenInfo.new(2), {
					CFrame = clone2.Back1.CFrame - clone2.Back1.CFrame.LookVector * 20
				}):Play()
				TweenService:Create(clone2.Back2, TweenInfo.new(2), {
					CFrame = clone2.Back2.CFrame - clone2.Back2.CFrame.LookVector * 20
				}):Play()
				TweenService:Create(clone2.PointLight, TweenInfo.new(1), {
					Brightness = 0
				}):Play()
				Debris:AddItem(clone2, 3)
			end)
			clone.BillboardGui.Enabled = false

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

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
					clone2.Brightness = 200
					clone2.Contrast = -1000
					task.wait(WAIT_INTERVAL)
					clone2.Brightness = -200
					clone2.Contrast = 1000
					task.wait(WAIT_INTERVAL)
					clone2:Destroy()
				end

				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				game.Lighting.ExposureCompensation = 2
				TweenService:Create(game.Lighting, TweenInfo.new(1), {
					ExposureCompensation = 0
				}):Play()
			end
		end,
		Finisher = function(p)
			if not p.HumanoidRootPart then
				return
			end

			v2:Bleed(p)
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
	v = Knit.GetService("ReversalRedMaxService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller