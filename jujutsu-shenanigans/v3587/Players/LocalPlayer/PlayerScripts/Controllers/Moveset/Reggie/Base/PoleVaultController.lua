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
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "PoleVaultController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Nanami.CrossCut.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Drop = function(instance)
			local clone = instance:Clone()
			clone.Weld:Destroy()
			clone.CollisionGroup = "NoPlayerCollision"
			clone.AssemblyLinearVelocity = createVector(0, 0, 0)
			clone.CanCollide = true
			clone:PivotTo(instance:GetPivot())
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)
		end,
		Slam = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = humanoidRootPart.CFrame * CFrame.new(-0.2, -3, -3.6)
			local raycastResult = workspace:Raycast(
				v5.Position + createVector(0, 3, 0),
				createVector(0, -10, 0),
				_G.MapParams
			)

			if not raycastResult then
				return
			end

			local position = raycastResult.Position
			local clone = utils.Hiromi.Shockwave:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(0.5)
			Debris:AddItem(model, 0.2)
			clone.CFrame = CFrame.new(position)
			clone.Parent = workspace.Effects
			clone.CFrame *= CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
			TweenService:Create(clone.mesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Scale = createVector(5, 0, 5)
			}):Play()
			TweenService:Create(clone.mesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			clone.Floor.Glow:Emit(1)
			clone.Floor.Ring:Emit(5)
			Debris:AddItem(clone, 1.5)
			local clone2 = utils.Choso.CounterSwing.Shock:Clone()
			clone2.Size = createVector(5, 15, 5)
			clone2.CFrame = CFrame.new(position)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.3)
			TweenService:Create(clone2, TweenInfo.new(0.3), {
				Size = createVector(20, 5, 20),
				Transparency = 1,
				Position = clone2.Position - createVector(0, 3, 0)
			}):Play()
			v3:PlaySound(sounds.Haruta.BackstabFinisher.Slam, clone, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Launch = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local position = (humanoidRootPart.CFrame * CFrame.new(-0.2, -3, -3.6)).Position
			local raycastResult = workspace:Raycast(
				position + createVector(0, 3, 0),
				createVector(0, -10, 0),
				_G.MapParams
			)

			if raycastResult then
				position = raycastResult.Position
			end

			local clone = utils.Choso.CounterSwing.Shock:Clone()
			clone.Size = createVector(20, 10, 20)
			clone.CFrame = CFrame.new(position) * humanoidRootPart.CFrame.Rotation * CFrame.Angles(
				-0.6108652381980153,
				0,
				0
			)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.2)
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = createVector(0, 36, 0),
				Transparency = 1,
				CFrame = clone.CFrame * CFrame.new(0, 10, 0)
			}):Play()
			v3:PlaySound(sounds.Reggie.BluntTrauma.Whoosh5, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("PoleVaultService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller