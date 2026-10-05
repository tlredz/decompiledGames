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
	Name = "VerdictController"
})

function controller.KnitStart(_)
	local v4 = {
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hiromi.Verdict.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Jump = function(p, p2, p3)
			local humanoidRootPart = p2.Parent.Parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p3 == true then
				v3:PlaySound(sounds.Hiromi.Verdict.RunSmack, humanoidRootPart, game.SoundService.Effect)
			else
				v3:PlaySound(sounds.Hiromi.Verdict.RunSlash, humanoidRootPart, game.SoundService.Effect)
			end

			local v5 = humanoidRootPart.CFrame.LookVector * 6 - createVector(0, 2, 0)

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
		Arm = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			v3:PlaySound(sounds.Hiromi.Execution.Sever, humanoidRootPart, game.SoundService.Effect)

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

			v3:PlaySound(sounds.Hiromi.Execution.Sever2, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 30 do
				BloodyZee:Blood(instance2["Right Leg"].CFrame, math.random(5, 150), 25, 25)
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
		HitSlash = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			for _ = 1, 30 do
				BloodyZee:Blood(instance.Torso.CFrame, math.random(5, 150), 25, 25)
			end

			if _G.Settings.Gore then
				local clone = utils.Heian.BloodSpread:Clone()
				clone.Parent = instance.Torso
				clone:Emit(20)
				Debris:AddItem(clone, 2)
			end

			v3:PlaySound(sounds.Hiromi.Execution.Sever, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Hiromi.Execution.Flash, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		HitBreak = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Hiromi.Whack:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.5)

			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				local v5 = emitter
				task.delay(0.02, function()
					v5.TimeScale = 0
					task.wait(0.3)
					v5.TimeScale = 1
				end)
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hiromi.Verdict.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			task.wait(0.3)
			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hiromi.Verdict.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Hit = function(p, instance)
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
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)
			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
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
	v = Knit.GetService("VerdictService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller