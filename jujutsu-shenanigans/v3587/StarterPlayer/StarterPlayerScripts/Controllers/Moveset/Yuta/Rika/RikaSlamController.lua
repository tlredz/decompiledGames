local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "RikaSlamController"
})

function controller.KnitStart(_)
	local v4 = {
		StartSound = function(p)
			if p and p.Parent then
				v2:PlaySound(sounds.Yuta.Rika.SlamTry, p, game.SoundService.Effect)
			end
		end,
		GrabLand = function(p, instance)
			if p and p.Parent then
				local v5 = v2:PlaySound(sounds.Yuta.Rika.SlamLand, p, game.SoundService.Effect)
				instance.AncestryChanged:Once(function()
					v5:Destroy()
				end)
			end
		end,
		Ring = function(instance, p)
			local torso = instance:FindFirstChild("Torso")
			local rootPart = instance:FindFirstChild("RootPart")

			if not (torso and rootPart) then
				return
			end

			local clone = utils.Yuta.RingSwing:Clone()
			clone.CFrame = CFrame.lookAlong(torso.Position, rootPart.CFrame.LookVector)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.6)
			clone[`{p}`].Ring:Emit(8)
		end
	}
	v3.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v3 = Knit.GetService("RikaSlamService")
	v = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller