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
local controller = Knit.CreateController({
	Name = "ExtendSwingController"
})

function controller.KnitStart(_)
	local v3 = {
		Swing = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		SwingDown = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Misc.Swing.Fist2, humanoidRootPart, game.SoundService.Effect)
		end,
		Crush = function(p, position)
			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			TweenService:Create(clone.Air, TweenInfo.new(0.2), {
				Position = createVector(0, 0, 0)
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			clone.Floor.Wind2.Color = ColorSequence.new(Color3.new(1, 1, 0.498039))
			clone.Floor.Glow.Color = ColorSequence.new(Color3.new(1, 1, 0.498039))
			clone.Beam.Color = ColorSequence.new(Color3.new(1, 1, 0.498039))
			clone.PointLight.Color = Color3.new(1, 1, 0.498039)
			clone.Floor.Glow:Emit(1)
			clone.Floor.Ring:Emit(10)
			clone.Floor.Wind2:Emit(8)
			Debris:AddItem(clone, 1.5)
			v2:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)

			if localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Sweep = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v4 = v2:PlaySound(sounds.Misc.Swing.Fist3, humanoidRootPart, game.SoundService.Effect)
			v4.PlaybackSpeed *= 1.4
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit1"), humanoidRootPart, game.SoundService.Effect)
		end,
		Hit2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit1"), humanoidRootPart, game.SoundService.Effect)
		end,
		Hit3 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Megumi.Elephant.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		SweepMiss = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v2:Flash(instance, Color3.new(0.3, 1, 0), 0.2)
		end,
		SweepHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 0, 0))
			v2:PlaySound(sounds.Hiromi.Sweep, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Gojo.Teleport, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Hiromi.BlockBreak:Clone()
			clone.Parent = humanoidRootPart
			clone:Emit(20)
			Debris:AddItem(clone, 0.6)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Finisher = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance.Parent) then
				return
			end

			v2:PlaySound(sounds.Itadori.Dismantle.Explode, instance, game.SoundService.Effect)
			v2:PlaySound(sounds.Megumi.Elephant.Explode, humanoidRootPart, game.SoundService.Effect)
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

				if not (handle:FindFirstChild("HairAttachment") or handle:FindFirstChild("HatAttachment") or handle:FindFirstChild("FaceCenterAttachment") or handle:FindFirstChild("FaceFrontAttachment")) then
					continue
				end

				accessory:Destroy()
			end

			v2:Bleed(instance)

			for _ = 1, 40 do
				BloodyZee:Blood(instance.Head.CFrame, 50, 360, 360)
			end

			if _G.Settings.Gore then
				local clone = utils.Heian.BloodSpread:Clone()
				clone.Parent = instance.Head
				clone:Emit(20)
				Debris:AddItem(clone, 2)
			end

			if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 40 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
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
	v = Knit.GetService("ExtendSwingService")
	v2 = Knit.GetController("FXController")
end

return controller