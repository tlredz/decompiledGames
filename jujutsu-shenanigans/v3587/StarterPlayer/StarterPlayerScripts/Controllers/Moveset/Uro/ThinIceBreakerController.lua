local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.StaticLightning)
require(replicatedStorage.Modules.LightningBeams)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "ThinIceBreakerController"
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
			humanoid.PlatformStand = true

			while true do
				local mouseTarget = v3:GetMouseTarget()

				if not bodyGyro:GetAttribute("Lock") then
					bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouseTarget)
				end

				task.wait()

				if p.Parent then
					continue
				end

				bodyGyro:Destroy()
				humanoid.PlatformStand = false
				break
			end
		end,
		Startup = function(instance)
			local WAIT_INTERVAL = 0.2
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Uro.ThinIceBreaker.Start, humanoidRootPart, game.SoundService.Effect)
			task.wait(WAIT_INTERVAL)
			v2:ArmFlash(instance["Right Arm"], Color3.fromRGB(255, 133, 172), 0.6)
			task.wait(WAIT_INTERVAL)
			v2:ArmFlash(instance["Left Arm"], Color3.fromRGB(255, 133, 172), 0.4)
			task.wait(WAIT_INTERVAL)
			v2:PlaySound(sounds.Ryu.NotInvited.Swing, humanoidRootPart, game.SoundService.Effect)
		end,
		Crack = function(instance, duration, duration2)
			local DISTANCE_THRESHOLD = 60
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Uro.IceBreaker:Clone()
			clone.SmallShard.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, duration + duration2 + 1)
			local highlight = Instance.new("Highlight", clone)
			highlight.FillColor = Color3.fromRGB(255, 255, 255)
			highlight.OutlineColor = Color3.fromRGB(170, 255, 255)
			highlight.FillTransparency = 0.9
			highlight.OutlineTransparency = 0.8
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded

			if duration == 0.5 then
				v2:PlaySound(sounds.Uro.ThinIceBreaker.Die, humanoidRootPart, game.SoundService.Effect)
				highlight.FillTransparency = -1
				highlight.FillColor = Color3.fromRGB(127, 127, 127)

				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < DISTANCE_THRESHOLD then
					local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
					task.delay(duration2, function()
						shakeSustain:StartFadeOut(0.3)
					end)
				end
			else
				if duration == 0.15 then
					highlight.FillTransparency = -1
					highlight.FillColor = Color3.fromRGB(127, 127, 127)
					clone.SmallShard.Weld.C0 = clone.SmallShard.Weld.C0 - createVector(0, 0, 4)
				end

				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < DISTANCE_THRESHOLD then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end

			v2:PlaySound(sounds.Uro.ThinIceBreaker.Impact, humanoidRootPart, game.SoundService.Effect)
			TweenService:Create(
				clone.SmallShard,
				TweenInfo.new(duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = clone.SmallShard.Size * 1.1
				}
			):Play()
			task.wait(duration)
			v2:PlaySound(sounds.Uro.ThinIceBreaker.Crack, humanoidRootPart, game.SoundService.Effect)
			TweenService:Create(
				clone.BigShard,
				TweenInfo.new(duration2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = clone.BigShard.Size * 1.2
				}
			):Play()
			clone.SmallShard.Transparency = 7
			clone.BigShard.Material = Enum.Material.Glass
			clone.BigShard.Transparency = 5

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < DISTANCE_THRESHOLD then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			local v5 = duration2 - duration
			task.wait(v5)
			v2:PlaySound(sounds.Uro.ThinIceBreaker.Explode, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < DISTANCE_THRESHOLD then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			local cFrame = clone.SmallShard.CFrame
			clone.SmallShard.Material = Enum.Material.Plastic
			clone.BigShard.Material = Enum.Material.Plastic

			for _, child in utils.Ryu.Launch:GetChildren() do
				child:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			if duration == 0.5 then
				for _, child in utils.Misc.M.Awk.mokultMeh["3"]:GetChildren() do
					child:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0))
					Knit.GetController("MokouController"):ArcTween(child.Start, true)
				end
			end

			if _G.Settings.DesPHY then
				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 100 then
					return
				end

				Random.new()
				local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

				for _ = 1, 20 do
					local clone2 = utils.Gojo.Shard:Clone()
					local lookVector = (cFrame * CFrame.Angles(
						math.rad((math.random(-60, 60))),
						math.rad((math.random(-60, 60))),
						0
					)).LookVector
					clone2.Size = Vector3.new(0.2, math.random(10, 80) / 10, math.random(10, 80) / 10)
					clone2.CFrame = cFrame * CFrame.new(math.random(-10, 10), math.random(-5, 10), 0)
					clone2.CFrame *= CFrame.Angles(0, math.random(0, 3.141592653589793), 0)
					clone2.CanCollide = true
					clone2.CollisionGroup = "Effects"
					clone2.Parent = clone
					clone2.Transparency = 5
					clone2.Material = Enum.Material.Glass
					clone2.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					clone2.Velocity = lookVector * math.random(30, 60) + humanoidRootPart.Velocity
					TweenService:Create(clone2, tweenInfo, {
						Size = createVector(0, 0, 0)
					}):Play()
					Debris:AddItem(clone2, 1)
				end
			end
		end,
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Ryu.Unsatisfied["Hit" .. p], humanoidRootPart, game.SoundService.Effect)
		end,
		HitEnd = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Ryu.Unsatisfied.FinalHit2, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart2.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(170, 255, 255))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)
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
	v = Knit.GetService("ThinIceBreakerService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller