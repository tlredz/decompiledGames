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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "AbsoluteDestructionController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance, p, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local jump = p and sounds.Mechamaru.AbsoluteDestruction.Jump or sounds.Mechamaru.AbsoluteDestruction.Run
			local v5 = v3:PlaySound(jump, humanoidRootPart, game.SoundService.Effect)

			if not p and instance2 then
				local footstepsChangedConnection = nil
				footstepsChangedConnection = instance2:GetAttributeChangedSignal("Footsteps"):Connect(function()
					if instance2:GetAttribute("Footsteps") then
						return
					end

					footstepsChangedConnection:Disconnect()
					TweenService:Create(v5, TweenInfo.new(0.5), {
						Volume = 0
					}):Play()
				end)
			end
		end,
		Step = function(p, position)
			if position then
				local clone = utils.Mechamaru.Dust:Clone()
				clone.bigimpact:Destroy()
				clone.Smoke2:Destroy()
				clone.Position = position
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 1)

				for _, child in clone:GetChildren() do
					child:Emit(child:GetAttribute("EmitCount") / 4)
				end
			end

			if localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Jump = function(instance, position)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				v3:PlaySound(sounds.Mechamaru.AbsoluteDestruction.Jump, humanoidRootPart, game.SoundService.Effect)
			end

			if position then
				local raycastResult = workspace:Raycast(
					position + createVector(0, 3, 0),
					createVector(0, -10, 0),
					_G.MapParams
				)

				if raycastResult then
					local clone = utils.Mechamaru.Dust:Clone()
					clone.bigimpact:Destroy()
					clone.Position = position
					clone.Parent = workspace.Effects
					Debris:AddItem(clone, 2)

					for _, descendant in clone:GetDescendants() do
						if descendant.Name == "Smoke2" then
							descendant.Color = ColorSequence.new(raycastResult.Instance.Color)
							descendant:Emit(20)
						else
							descendant:Emit(descendant:GetAttribute("EmitCount") / 2)
						end
					end
				end
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Slam = function(p, position)
			if position then
				local clone = utils.Choso.CounterSwing.Shock:Clone()
				clone.Transparency = 0
				clone.Size = createVector(30, 60, 30)
				clone.Position = position
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 0.4)
				TweenService:Create(clone, TweenInfo.new(0.4), {
					Transparency = 1,
					Size = createVector(70, 0, 70),
					Position = clone.Position - createVector(0, 30, 0)
				}):Play()
				local clone2 = utils.Mechamaru.BigSlam:Clone()
				clone2.Position = position
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 3)

				for _, descendant in clone2:GetDescendants() do
					descendant:Emit(descendant:GetAttribute("EmitCount"))
				end

				v3:PlaySound(sounds.Mechamaru.AbsoluteDestruction.Slam, clone2, game.SoundService.Effect)
			end

			if localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit2 = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, p or Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(p or Color3.new(1, 1, 1))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
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
	v = Knit.GetService("AbsoluteDestructionService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller