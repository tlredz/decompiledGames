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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "ExecutionController"
})

function controller.KnitStart(_)
	local v4 = {
		Charge = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local execSword = instance.SetAssets:FindFirstChild("ExecSword")

			if not execSword then
				return
			end

			v2:PlaySound(sounds.Hiromi.Execution.Charge, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Hiromi.SwordBuild.Charge:Clone()
			Debris:AddItem(clone, 2)
			clone.Parent = execSword
			task.wait(0.7)

			for _, child in clone:GetChildren() do
				child.Enabled = false
			end
		end,
		Charged = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local execSword = instance.SetAssets:FindFirstChild("ExecSword")

			if not execSword then
				return
			end

			v2:PlaySound(sounds.Hiromi.Execution.Flash, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Hiromi.SwordBuild.ChargeEmit:Clone()
			Debris:AddItem(clone, 1)
			clone.Parent = execSword

			for _, child in clone:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end
		end,
		Aerial = function(instance, instance2)
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
			instance2.Position = humanoidRootPart.Position + createVector(0, 6, 0)
			humanoid.PlatformStand = true

			repeat
				local mouseTarget = v3:GetMouseTarget()
				bodyGyro.CFrame = instance2:GetAttribute("Aim") or CFrame.new(humanoidRootPart.Position, mouseTarget)
				task.wait()
			until not instance2.Parent

			bodyGyro:Destroy()
			humanoid.PlatformStand = false
		end,
		Woosh = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Hiromi.Execution.Dash, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Hiromi.Thrust:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -11) * CFrame.Angles(-1.5707963267948966, 0, 0)
			Debris:AddItem(clone, 2)
			clone.Parent = workspace.Effects

			for _, child in clone.Attachment:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Fly = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.BodyRepel["Wind" .. math.random(1, 5)]:Clone()
			clone.CFrame = CFrame.lookAlong(humanoidRootPart.Position, humanoidRootPart.Velocity) * CFrame.Angles(
				1.5707963267948966,
				math.rad((math.random(0, 360))),
				0
			)
			clone.Transparency = 0.5
			clone.Size = createVector(3, 6, 3)
			TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				CFrame = clone.CFrame + humanoidRootPart.CFrame.LookVector * 3,
				Size = createVector(15, 0, 15)
			}):Play()
			Debris:AddItem(clone, 0.2)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Transparency = 1
			}):Play()
		end,
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.fromRGB(255, 85, 255), 0.5)
			v2:PlaySound(sounds.Hiromi.Execution.Stab, humanoidRootPart, game.SoundService.Effect)

			if p then
				v2:PlaySound(sounds.Hiromi.Fall, humanoidRootPart, game.SoundService.Effect)
			end
		end,
		Whack = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 0.498039))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end
		end,
		Arm = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			v2:PlaySound(sounds.Hiromi.Execution.Sever, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 30 do
				BloodyZee:Blood(instance2["Left Arm"].CFrame, math.random(5, 150), 25, 25)
			end

			local execSword = instance.SetAssets:FindFirstChild("ExecSword")

			if execSword then
				task.spawn(function()
					local clone = utils.Hiromi.Limb:Clone()
					local leftArm = instance2["Left Arm"]
					clone["Left Arm"].Size = leftArm.Size
					clone["Left Arm"].Color = leftArm.Color

					if instance2:FindFirstChildWhichIsA("Shirt") then
						local clone_2 = instance2:FindFirstChildWhichIsA("Shirt"):Clone()
						clone_2.Parent = clone
					end

					Debris:AddItem(clone, 6)
					clone.Parent = workspace.Effects

					repeat
						clone:PivotTo(execSword.CFrame * CFrame.new(0, 0, 5))
						task.wait()
					until not (clone.Parent and execSword.Parent)
				end)
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Leg = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			v2:PlaySound(sounds.Hiromi.Execution.Sever2, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 30 do
				BloodyZee:Blood(instance2["Right Leg"].CFrame, math.random(5, 150), 25, 25)
			end

			if _G.Settings.Gore then
				local clone = utils.Heian.BloodSpread:Clone()
				clone.Parent = instance["Right Leg"]
				clone:Emit(20)
				Debris:AddItem(clone, 2)
			end

			local execSword = instance.SetAssets:FindFirstChild("ExecSword")

			if execSword then
				task.spawn(function()
					local clone = utils.Hiromi.Limb:Clone()
					clone["Left Arm"].Transparency = 1
					clone["Right Leg"].Transparency = 0
					local rightLeg = instance2["Right Leg"]
					clone["Right Leg"].Size = rightLeg.Size
					clone["Right Leg"].Color = rightLeg.Color

					if instance2:FindFirstChildWhichIsA("Pants") then
						local clone_2 = instance2:FindFirstChildWhichIsA("Pants"):Clone()
						clone_2.Parent = clone
					end

					Debris:AddItem(clone, 6)
					clone.Parent = workspace.Effects

					repeat
						clone:PivotTo(execSword.CFrame * CFrame.new(0, 0, 5))
						task.wait()
					until not (clone.Parent and execSword.Parent)
				end)
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Head = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			v2:PlaySound(sounds.Hiromi.Stab, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 20 do
				BloodyZee:Blood(instance2.Head.CFrame, math.random(5, 150), 45, 45)
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Curb = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hiromi.Execution.Curb, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Hiromi.Execution.Step, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Locust.Slam:Clone()
			clone.Position = instance2.Torso.Position
			clone.Parent = workspace.Effects

			for _, child in clone.Attachment:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			Debris:AddItem(clone, 0.5)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
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
	v = Knit.GetService("ExecutionService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller