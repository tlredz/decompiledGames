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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "TripleSentenceController"
})

function controller.KnitStart(_)
	local v3 = {
		Interp = function(instance)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Parent then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (300 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		Summon = function(instance, parent)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			task.wait(0.3)
			local clone = utils.Hiromi.SwordBuild.Charge:Clone()
			Debris:AddItem(clone, 1)
			clone.Parent = parent
			task.wait(0.1)
			clone:Destroy()

			for _, child in utils.Hiromi.SwordBuild.Create:GetChildren() do
				local clone2 = child:Clone()
				clone2.Parent = parent
				Debris:AddItem(clone2, 1.5)
				clone2:Emit(clone2:GetAttribute("EmitCount"))
			end
		end,
		Arm = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			v2:PlaySound(sounds.Hiromi.Execution.Sever, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 20 do
				BloodyZee:Blood(
					instance2["Left Arm"].CFrame * CFrame.Angles(1.5707963267948966, 0, 0),
					math.random(-150, -5),
					25,
					25
				)
			end

			task.spawn(function()
				local clone = utils.Hiromi.Limb:Clone()
				local leftArm = instance2["Left Arm"]
				leftArm.CFrame = instance2["Left Arm"].CFrame - createVector(0, 0.5, 0)
				clone["Left Arm"].Size = leftArm.Size
				clone["Left Arm"].Color = leftArm.Color

				if instance2:FindFirstChildWhichIsA("Shirt") then
					local clone_2 = instance2:FindFirstChildWhichIsA("Shirt"):Clone()
					clone_2.Parent = clone
				end

				Debris:AddItem(clone, 6)
				clone.Parent = workspace.Effects
				clone.HumanoidRootPart.Anchored = false
				clone.HumanoidRootPart.CanCollide = true
				clone.HumanoidRootPart.CollisionGroup = "Effects"
				clone.HumanoidRootPart.Velocity = p * 50
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Leg = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			v2:PlaySound(sounds.Hiromi.Execution.Sever2, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 20 do
				BloodyZee:Blood(
					instance2["Right Leg"].CFrame * CFrame.Angles(1.5707963267948966, 0, 0),
					math.random(-150, -5),
					25,
					25
				)
			end

			task.spawn(function()
				local clone = utils.Hiromi.Limb:Clone()
				clone["Left Arm"].Transparency = 1
				clone["Right Leg"].Transparency = 0
				local rightLeg = instance2["Right Leg"]
				rightLeg.CFrame = instance2["Right Leg"].CFrame - createVector(0, 0.5, 0)
				clone["Right Leg"].Size = rightLeg.Size
				clone["Right Leg"].Color = rightLeg.Color

				if instance2:FindFirstChildWhichIsA("Pants") then
					local clone_2 = instance2:FindFirstChildWhichIsA("Pants"):Clone()
					clone_2.Parent = clone
				end

				Debris:AddItem(clone, 6)
				clone.Parent = workspace.Effects
				clone.HumanoidRootPart.Anchored = false
				clone.HumanoidRootPart.CanCollide = true
				clone.HumanoidRootPart.CollisionGroup = "Effects"
				clone.HumanoidRootPart.Velocity = p * 50
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Teleport = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Teleport:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.1)
			clone.Floor.Dust:Emit(30)
			clone.Lines:Emit(30)
			v2:PlaySound(sounds.Megumi.Mahoraga.Takedown.Teleport, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Hiromi.Sweep, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Stab = function(_, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 0.498039), 1)
			v2:PlaySound(sounds.Hiromi.Stab, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 40 do
				BloodyZee:Blood(instance.Torso.CFrame, math.random(-150, -5), 25, 25)
			end

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 70 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end
		end,
		Toss = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Hiromi.SwordPull, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Hiromi.Swing, humanoidRootPart, game.SoundService.Effect)
			task.delay(0.2, function()
				v2:PlaySound(sounds.Hiromi.Sweep, humanoidRootPart, game.SoundService.Effect)
			end)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Hit1 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Hiromi.Whack:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.5)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			v2:Flash(instance, Color3.new(1, 1, 0.498039), 0.5)
			v2:PlaySound(sounds.Hiromi.Verdict.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 0.498039))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hiromi.Verdict.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		ThrowStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Hiromi.ThrowStart, humanoidRootPart, game.SoundService.Effect)
		end,
		Throw = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Hiromi.Throw:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
			Debris:AddItem(clone, 2)

			if p == false then
				v2:PlaySound(sounds.Hiromi.Throw, humanoidRootPart, game.SoundService.Effect)
			else
				v2:PlaySound(sounds.Hiromi.Throw2, humanoidRootPart, game.SoundService.Effect)
			end

			TweenService:Create(clone.Attachment, TweenInfo.new(0.2), {
				Position = clone.Core.Position
			}):Play()

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
	v = Knit.GetService("TripleSentenceService")
	v2 = Knit.GetController("FXController")
end

return controller