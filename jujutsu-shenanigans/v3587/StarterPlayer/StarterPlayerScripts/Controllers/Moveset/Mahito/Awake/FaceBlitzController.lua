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
	Name = "FaceBlitzController"
})

function controller.KnitStart(_)
	local v4 = {
		Grab = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 150 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Leap = function(instance)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			local raycastResult = workspace:Raycast(torso.Position, createVector(0, -12, 0), _G.MapParams)

			if raycastResult then
				local clone = utils.Itadori.CrushingBlow:Clone()
				clone.Position = raycastResult.Position
				clone.PointLight:Destroy()
				clone.Air:Destroy()
				clone.Parent = workspace.Effects
				clone.Floor.Wind2.Color = ColorSequence.new(Color3.new(0.666667, 0.333333, 1))
				clone.Floor.Sparks.Color = ColorSequence.new(Color3.new(0.666667, 0.333333, 1))
				clone.Floor.Ring:Emit(10)
				clone.Floor.Sparks:Emit(10)
				clone.Floor.Wind2:Emit(8)
				Debris:AddItem(clone, 1.5)
				v3:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)

				if localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				end
			end
		end,
		Leap2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			local raycastResult = workspace:Raycast(torso.Position, createVector(0, -12, 0), _G.MapParams)

			if raycastResult then
				local clone = utils.Itadori.CrushingBlow:Clone()
				clone.Position = raycastResult.Position
				clone.PointLight:Destroy()
				clone.Air:Destroy()
				clone.Parent = workspace.Effects
				clone.Floor.Wind2.Color = ColorSequence.new(Color3.new(0.666667, 0.333333, 1))
				clone.Floor.Sparks.Color = ColorSequence.new(Color3.new(0.666667, 0.333333, 1))
				clone.Floor.Ring:Emit(10)
				clone.Floor.Sparks:Emit(10)
				clone.Floor.Wind2:Emit(8)
				Debris:AddItem(clone, 1.5)
				v3:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)

				if localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				end
			end

			local clone = utils.Itadori.Shock:Clone()
			clone.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + humanoidRootPart.Velocity) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(10, 0, 10),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.3)
			task.delay(0.075, function()
				local clone2 = utils.Itadori.Shock:Clone()
				clone2.CFrame = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + humanoidRootPart.Velocity
				) * CFrame.Angles(1.5707963267948966, 0, 0) + humanoidRootPart.CFrame.LookVector * 3
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone2, 0.2)
				task.wait(0.075)
				local clone3 = utils.Itadori.Shock:Clone()
				clone3.CFrame = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + humanoidRootPart.Velocity
				) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone3, 0.2)
				task.wait(0.075)
				local clone4 = utils.Itadori.Shock:Clone()
				clone4.CFrame = CFrame.new(
					humanoidRootPart.Position,
					humanoidRootPart.Position + humanoidRootPart.Velocity
				) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone4.Parent = workspace.Effects
				TweenService:Create(clone4, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone4, 0.2)
			end)
			v3:PlaySound(sounds.Itadori.Rush.RushLaunch, humanoidRootPart, game.SoundService.Effect)
			local clone2 = utils.Mahito.Worms.WormLaunch.groundwaveing.groundwaveing1:Clone()
			clone2.EmissionDirection = Enum.NormalId.Front
			clone2.Parent = humanoidRootPart
			Debris:AddItem(clone2, 1)
			task.delay(0.5, function()
				clone2.Enabled = false
			end)
			local clone3 = utils.Mahito.Worms.WormLaunch.groundwaveing.groundwaveing3:Clone()
			clone3.EmissionDirection = Enum.NormalId.Front
			clone3.Parent = humanoidRootPart
			Debris:AddItem(clone3, 1)
			task.delay(0.5, function()
				clone3.Enabled = false
			end)
		end,
		Teleport = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local model = Instance.new("Model")
			local clone = utils.Gojo.Teleport:Clone()
			clone.CFrame = humanoidRootPart.CFrame + createVector(0, 2, 0)
			clone.Parent = model
			model:ScaleTo(2)
			clone.Parent = workspace.Effects
			model:Destroy()
			Debris:AddItem(clone, 1.1)
			clone.Floor.Dust:Emit(30)
			clone.Lines:Emit(30)
			v3:PlaySound(sounds.Megumi.Mahoraga.Takedown.Teleport, humanoidRootPart, game.SoundService.Effect)
			task.delay(0.02, function()
				clone.CFrame = humanoidRootPart.CFrame
				clone.Lines:Emit(30)
				clone.Floor.Dust:Emit(30)
				local rootJoint = humanoidRootPart:FindFirstChild("RootJoint")

				if rootJoint then
					local cframe = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
					rootJoint.C0 = cframe * CFrame.new(7, 0, 0)
					TweenService:Create(rootJoint, TweenInfo.new(0.5, Enum.EasingStyle.Elastic), {
						C0 = cframe
					}):Play()
				end

				local outfit = instance:FindFirstChild("Outfit")

				if outfit then
					local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

					for _, part in outfit:GetDescendants() do
						if not part:IsA("BasePart") then
							continue
						end

						local transparency = part.Transparency
						part.Transparency = 1
						TweenService:Create(part, tweenInfo, {
							Transparency = transparency
						}):Play()
					end
				end
			end)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Crush = function(position)
			local clone = utils.Megumi.Mahoraga.Earthquake:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.Air:Destroy()
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			TweenService:Create(clone.Floor.Ring2, TweenInfo.new(0.4), {
				TimeScale = 0.5
			}):Play()
			clone.Floor.Ring2:Emit(10)
			clone.Floor.Wind2:Emit(15)
			clone.Floor.Dust:Emit(100)
			Debris:AddItem(clone, 3)
			local clone2 = utils.Megumi.Mahoraga.WorldSlash.mesh:Clone()
			clone2.Position = position
			clone2.Decal.Transparency = 0
			clone2.Mesh.Scale = createVector(2, 50, 2)
			clone2.Parent = clone
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Size = createVector(80, 40, 80),
				CFrame = clone2.CFrame * CFrame.Angles(0, -3.12413936106985, 0)
			}):Play()
			TweenService:Create(clone2.Mesh, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Scale = createVector(60, 10, 60)
			}):Play()
			TweenService:Create(clone2.Decal, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 1)
			v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, clone, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.WideSPStrike.Crush, clone, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.WideSPStrike.Crush2, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 180 then
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
	v = Knit.GetService("FaceBlitzService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller