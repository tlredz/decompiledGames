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
local random = Random.new()
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "ElbowRushController"
})

function controller.KnitStart(_)
	local v4 = {
		BarrageHit = function(instance, p)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))

			for _ = 1, p and 2 or 1 do
				local clone = utils.Yuta.ElbowRush.HitParticle:Clone()
				clone.WorldPosition = torso.Position + random:NextUnitVector() * 2
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 0.5)
				clone.Spark:Emit(1)
			end
		end,
		BarrageSound = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Yuta.ElbowRush.Barrage, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Yuta.ElbowRush.Barrage2, humanoidRootPart, game.SoundService.Voice)
		end,
		Dust = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:DustTrail(instance, 0.4, CFrame.Angles(0, 1.5707963267948966, 0))
			v3:PlaySound(sounds.Yuta.ElbowRush.Whiff, humanoidRootPart, game.SoundService.Effect)
		end,
		ElbowHit = function(instance, instance2, cFrame)
			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance:FindFirstChild("HumanoidRootPart")) then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Yuta.MetalHit2, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Yuta.ElbowRush.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			clone.Dust:Emit(7)
			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			Debris:AddItem(clone, 2)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		StepSound = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Yuta.ElbowRush["Step" .. tonumber(p)], humanoidRootPart, game.SoundService.Effect)
		end,
		HeavyHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Yuta.MetalHit, humanoidRootPart, game.SoundService.Effect)
		end,
		Vanish = function(folder, instance)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Yuta.ElbowRush.Teleport, humanoidRootPart, game.SoundService.Effect)

			local function tpEffect()
				local clone = utils.Gojo.Teleport:Clone()
				clone.CFrame = humanoidRootPart.CFrame
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 1.1)
				clone.Floor.Dust:Emit(30)
				clone.Lines:Emit(30)

				if localPlayer.Character == folder then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end

			tpEffect()
			local transparenciesByDescendant = {}

			for _, descendant in folder:GetDescendants() do
				if not (descendant:IsA("BasePart") or descendant:IsA("Decal") and descendant.Transparency ~= 1) then
					continue
				end

				transparenciesByDescendant[descendant] = descendant.Transparency
				descendant.Transparency = 1
			end

			instance.AncestryChanged:Wait()

			for _, descendant in folder:GetDescendants() do
				if transparenciesByDescendant[descendant] then
					TweenService:Create(descendant, TweenInfo.new(0.1), {
						Transparency = transparenciesByDescendant[descendant]
					}):Play()
				end
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
	v = Knit.GetService("ElbowRushService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller