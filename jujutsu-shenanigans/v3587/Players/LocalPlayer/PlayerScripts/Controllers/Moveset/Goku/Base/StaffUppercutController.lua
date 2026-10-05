local Knit = require(game.ReplicatedStorage.Knit.Knit)
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local controller = Knit.CreateController({
	Name = "StaffUppercutController"
})
local v = nil
local v2 = nil
local _ = workspace.CurrentCamera

function controller.KnitStart(_)
	local v3 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:PlaySound(sounds.Goku.StaffUppercut.Swing, humanoidRootPart, game.SoundService.Effect)
		end,
		StaffTrail = function(p)
			local gokuStick = p.SetAssets:FindFirstChild("GokuStick")

			if not gokuStick then
				return
			end

			gokuStick.Extention.Trail.Enabled = true
		end,
		StopTrail = function(p)
			local gokuStick = p.SetAssets:FindFirstChild("GokuStick")

			if not gokuStick then
				return
			end

			gokuStick.Extention.Trail.Enabled = false
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:Flash(instance, Color3.new(1, 1, 1))
			v:PlaySound(sounds.Goku.StaffUppercut.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p or localPlayer.Character == instance then
				local snapOh = instance:GetAttribute("Dead") and CameraShaker.Presets.SnapOh or CameraShaker.Presets.HeavyHit
				CameraShaker.CurrentShaker:Shake(snapOh)
			end

			task.wait(2)

			if instance:GetAttribute("Dead") and humanoidRootPart.Parent and humanoidRootPart.Position.Y > 275 then
				if localPlayer.Character == p or localPlayer.Character == instance then
					v:PlaySound(sounds.Goku.StaffUppercut.Twinkle, humanoidRootPart, game.SoundService.Effect)
				end

				local clone = utils.Goku.Star:Clone()
				clone.Star.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.5, 50),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Parent = humanoidRootPart
				Debris:AddItem(clone, 1)
				clone.Star:Emit(1)
			end
		end
	}
	v2.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	v2 = Knit.GetService("StaffUppercutService")
	v = Knit.GetController("FXController")
end

return controller