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
local controller = Knit.CreateController({
	Name = "EarthquakeController"
})

function controller.KnitStart(_)
	local v3 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Megumi.Mahoraga.Cursed:Clone()
			clone.Weld.Part0 = instance["Right Arm"]
			clone.Parent = workspace.Effects
			clone.Shine.Sparks:Emit(10)
			clone.Shine.Glow:Emit(1)
			Debris:AddItem(clone, 1)
			task.delay(0.2, function()
				clone.Shine.Shine:Emit(2)
				TweenService:Create(clone.Shine.PointLight, TweenInfo.new(0.8), {
					Brightness = 0
				}):Play()
				task.wait(0.4)
				clone.Trail.Enabled = false
			end)
			v2:PlaySound(sounds.Megumi.Mahoraga.Earthquake.Startup, humanoidRootPart, game.SoundService.Effect)
		end,
		Crush = function(p, position, p2)
			local clone = utils.Megumi.Mahoraga.Earthquake:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			TweenService:Create(clone.Air, TweenInfo.new(0.2), {
				Position = createVector(0, 0, 0)
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			clone.Floor.Ring:Emit(10)
			clone.Floor.Wind:Emit(8)
			Debris:AddItem(clone, 1)

			if localPlayer == p and not p2 then
				clone.Floor.FluxFissureRef:Emit(1)
				clone.Floor.FluxFissure:Emit(1)
				v2:PlaySound(sounds.Megumi.Mahoraga.Earthquake.Attempt, workspace, game.SoundService.Effect)
			end

			v2:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 80 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Crush2 = function(position)
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
			v2:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)
			v2:PlaySound(sounds.Megumi.Mahoraga.Earthquake.Success, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 180 then
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
	v = Knit.GetService("EarthquakeService")
	v2 = Knit.GetController("FXController")
end

return controller