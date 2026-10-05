local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "DivinePummelController"
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Spawns, workspace.Domains }

function controller.KnitStart(_)
	local v3 = {
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Misc.Swing.Fist3, humanoidRootPart, game.SoundService.Effect)
		end,
		Grab = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(player, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit3"), humanoidRootPart, game.SoundService.Effect)
			local rightArm = player.Character["Right Arm"]
			local raycastResult = workspace:Raycast(
				rightArm.Position - rightArm.CFrame.UpVector * 2,
				createVector(0, -10, 0),
				raycastParams
			)

			if raycastResult then
				local clone = utils.Itadori.CrushingBlow:Clone()
				clone.Position = raycastResult.Position
				clone.PointLight:Destroy()
				clone.Air:Destroy()
				clone.Parent = workspace.Effects
				clone.Floor.Wind2.Color = ColorSequence.new(Color3.new(1, 1, 1))
				clone.Floor.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
				clone.Floor.Ring:Emit(10)
				clone.Floor.Sparks:Emit(10)
				clone.Floor.Wind2:Emit(8)
				Debris:AddItem(clone, 1.5)
				v2:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)
			end

			if localPlayer.Character == instance or localPlayer == player then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		FinalHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit4"), humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer == p then
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
	v = Knit.GetService("DivinePummelService")
	v2 = Knit.GetController("FXController")
end

return controller