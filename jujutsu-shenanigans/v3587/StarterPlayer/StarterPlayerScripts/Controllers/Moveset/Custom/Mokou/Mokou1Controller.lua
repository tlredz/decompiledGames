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
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "Mokou1Controller"
})

function controller.KnitStart(_)
	local v4 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			task.wait(0.1)
			v2:PlaySound(sounds.Misc.M.Slash, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Misc.M.Slash:Clone()

			if p == 1 then
				clone.Weld.C0 *= CFrame.Angles(0, 0, 3.9269908169872414)
				v2:PlaySound(sounds.Misc.M.Mokou1Voice, humanoidRootPart, game.SoundService.Voice)
			elseif p == 2 then
				clone.Weld.C0 *= CFrame.Angles(0, 0, -1.3962634015954636)
			else
				clone.Weld.C0 *= CFrame.Angles(0, 0, 0.7853981633974483)
			end

			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Wind:Emit(12)
			TweenService:Create(clone.Weld, TweenInfo.new(0.4), {
				C1 = clone.Weld.C1 * CFrame.Angles(0, -3.141592653589793, 0)
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0,
				Color = Color3.new(1, 0, 0)
			}):Play()

			for _, effect in clone:GetDescendants() do
				if effect:IsA("ParticleEmitter") then
					TweenService:Create(effect, TweenInfo.new(0.4), {
						Rate = 0
					}):Play()
				elseif effect:IsA("Beam") then
					TweenService:Create(effect, TweenInfo.new(0.4), {
						Width0 = 0
					}):Play()
				end
			end
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Mahito.Soulfire.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)

			if localPlayer.Character == instance or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Mahito.Soulfire.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)

			if localPlayer.Character == instance or localPlayer == p then
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
	v = Knit.GetService("Mokou1Service")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller