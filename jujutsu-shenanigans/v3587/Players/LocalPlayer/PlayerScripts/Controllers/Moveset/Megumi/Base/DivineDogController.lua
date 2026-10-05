local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "DivineDogController"
})
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Spawns, workspace.Domains }

function controller.KnitStart(_)
	local v3 = {
		Summon = function(p)
			local clone = utils.Megumi.Spawn:Clone()
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Position = p.Position - createVector(0, 3.5, 0)
			clone.Shadow:Emit(12)
			clone.Dive:Emit(6)
			v2:PlaySound(sounds.Megumi.DivineDog.Spawn, clone, game.SoundService.Effect)
		end,
		Follow = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local animationController = instance2.AnimationController
			local track = animationController:LoadAnimation(animationController.DivineDogsIdle)
			local track2 = animationController:LoadAnimation(animationController.DivineDogsWalk)
			local track3 = animationController:LoadAnimation(animationController.Emote)
			track:Play()
			track2:Play(nil, 0.01, 2)
			track3.Priority = Enum.AnimationPriority.Action2
			local childAddedConnection = instance.Info.ChildAdded:Connect(function(child)
				if child.Name == "Emote" then
					track:Stop()
					track3:Play()
					child.Destroying:Connect(function()
						track:Play()
						track3:Stop()
					end)
				end
			end)
			local position = instance2.RootPart.Position
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function(_, dt)
				if humanoidRootPart.Parent and p and p.Parent and instance2:FindFirstChild("RootPart") then
					local v4 = humanoidRootPart.Position + humanoidRootPart.CFrame.RightVector * 8
					local raycastResult = workspace:Raycast(
						v4 + createVector(0, 2, 0),
						createVector(0, -20, 0),
						raycastParams
					)

					if raycastResult then
						v4 = raycastResult.Position + createVector(0, 3.5, 0)
					end

					local v5

					if instance2.Target.Value and instance2.Target.Value:FindFirstChild("HumanoidRootPart") then
						local humanoidRootPart2 = instance2.Target.Value:FindFirstChild("HumanoidRootPart")

						if instance2.Target:GetAttribute("CF") then
							v5 = instance2.RootPart.CFrame:Lerp(instance2.Target:GetAttribute("CF"), 0.1)
						else
							local lookVector = CFrame.new(humanoidRootPart.Position, humanoidRootPart2.Position).LookVector
							v5 = instance2.RootPart.CFrame:Lerp(
								CFrame.new(
									humanoidRootPart2.Position - lookVector * 9,
									humanoidRootPart2.Position - lookVector * 10
								) + createVector(0, 1, 0),
								0.1
							)
						end

						track:AdjustWeight(0.01)
						track2:AdjustWeight(0.01)
					else
						v5 = instance2.RootPart.CFrame:Lerp(
							(humanoidRootPart.CFrame - humanoidRootPart.Position + v4) * CFrame.Angles(
								0,
								3.141592653589793,
								0
							),
							0.1
						)
						local magnitude = (position - v5.Position).Magnitude

						if 6 * dt < magnitude then
							track:AdjustWeight(0.01)
							track2:AdjustWeight(2)
							local vectorToObjectSpace = instance2.RootPart.CFrame:VectorToObjectSpace(humanoidRootPart.Velocity)
							v5 *= CFrame.Angles(0, math.rad((math.clamp(vectorToObjectSpace.X, -5, 5))), 0)
						else
							track:AdjustWeight(1)
							track2:AdjustWeight(0.01)
						end
					end

					instance2:SetPrimaryPartCFrame(v5)
					position = instance2.RootPart.Position
				else
					steppedConnection:Disconnect()
					childAddedConnection:Disconnect()
					local clone = utils.Megumi.Spawn:Clone()
					clone.Position = position
					clone.Shadow.LockedToPart = true
					clone.Parent = workspace.Effects
					clone.Shadow.Orientation = Enum.ParticleOrientation.FacingCamera
					clone.Shadow.EmissionDirection = Enum.NormalId.Right
					clone.Shadow.Lifetime = NumberRange.new(0.3, 0.6)
					clone.Shadow:Emit(30)
					Debris:AddItem(clone, 1)
					v2:PlaySound(sounds.Megumi.DivineDog.Despawn, clone, game.SoundService.Effect)
				end
			end)
		end,
		Slash = function(instance, p)
			local rootPart = instance:FindFirstChild("RootPart")

			if not rootPart then
				return
			end

			if p < 3 then
				v2:PlaySound(sounds.Megumi.DivineDog.Slash, rootPart, game.SoundService.Effect)
			else
				v2:PlaySound(sounds.Megumi.DivineDog.Bite, rootPart, game.SoundService.Effect)
			end

			task.wait(0.5)
			local clone = utils.Megumi.DivineAttack:Clone()
			clone.CFrame = rootPart.CFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, -6)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.2)

			if p == 1 then
				clone.CFrame *= CFrame.Angles(0, 0, -0.7853981633974483)
			else
				if p ~= 2 then
					clone.Bite:Emit(1)
					return
				end

				clone.CFrame *= CFrame.Angles(0, 0, 0.7853981633974483)
			end

			clone.Slash1.Slash:Emit(3)
			clone.Slash2.Slash:Emit(3)
			clone.Slash3.Slash:Emit(3)
		end,
		Hit = function(p, instance, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.fromRGB(255, 255, 255))

			if p2 < 3 then
				v2:PlaySound(sounds.Megumi.DivineDog.SlashHit, humanoidRootPart, game.SoundService.Effect)
			else
				v2:PlaySound(sounds.Megumi.DivineDog.BiteHit, humanoidRootPart, game.SoundService.Effect)
			end

			if localPlayer == p or localPlayer.Character == instance then
				if p2 < 3 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				else
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end
			end
		end,
		Finisher = function(p)
			if not p.HumanoidRootPart then
				return
			end

			v2:Bleed(p)
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
	v = Knit.GetService("DivineDogService")
	v2 = Knit.GetController("FXController")
end

return controller