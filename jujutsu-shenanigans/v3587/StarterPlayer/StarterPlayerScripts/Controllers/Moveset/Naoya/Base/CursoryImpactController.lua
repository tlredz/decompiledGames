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
local controller = Knit.CreateController({
	Name = "CursoryImpactController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Naoya.Cursory.Swing, humanoidRootPart, game.SoundService.Effect)
			v2:ArmFlash(instance["Right Arm"], Color3.fromRGB(128, 126, 255), 0.65)
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Naoya.Cursory.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Megumi.Mahoraga.WorldSlash.mesh:Clone()
			clone.Position = humanoidRootPart.Position - createVector(0, 2, 0)
			clone.Decal.Transparency = 0
			clone.Mesh.Scale = createVector(2, -5, 2)
			clone.Decal.Transparency = 0.8
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.9, Enum.EasingStyle.Exponential), {
				CFrame = clone.CFrame * CFrame.Angles(0, -3.12413936106985, 0)
			}):Play()
			TweenService:Create(clone.Mesh, TweenInfo.new(0.9, Enum.EasingStyle.Exponential), {
				Scale = createVector(15, 25, 15)
			}):Play()
			TweenService:Create(clone.Decal, TweenInfo.new(0.9, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.9)

			if localPlayer.Character == instance or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			for _ = 1, 3 do
				local v4 = math.random(300, 500) / 10
				local clone2 = utils.Gojo.LapseBlue.Throw:Clone()
				clone2.Transparency = 0.7
				clone2.Position = instance.Head.Position
				clone2.Orientation = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
				clone2.Size = createVector(0, 0, 7)
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Size = Vector3.new(v4, v4, 0),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone2, 0.15)
				task.wait(0.025)
			end
		end,
		UhOh = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Naoya.Cursory.Kick, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.2)
			v2:ArmFlash(instance["Right Leg"], Color3.fromRGB(128, 126, 255), 0.65)
		end,
		Grab = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Naoya.Cursory.Grab, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(0.666667, 0.666667, 1))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Naoya.Cursory.KickHit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Throw = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.PointLight:Destroy()
			clone.Wind:Emit(20)
			Debris:AddItem(clone, 3)
			local clone2 = utils.Choso.CounterSwing.Shock:Clone()
			clone2.Size = createVector(6, 30, 6)
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.2)
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(25, 0, 25),
				Transparency = 1,
				Position = clone2.Position + humanoidRootPart.CFrame.LookVector * 10
			}):Play()
			v2:PlaySound(sounds.Todo.BruteForce.Swing, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Zwoosh = function(folder, _)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local tweenInfo = TweenInfo.new(1.2)
			v2:PlaySound(sounds.Naoya.Decisive.Startup, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Damage.HitGlow:Clone()
			Debris:AddItem(clone, 1.2)
			clone.Parent = workspace.Effects

			for _, child in clone:GetChildren() do
				child.Color = Color3.fromRGB(128, 126, 255)
				child.Anchored = true
				child.CFrame = folder[child.Name].CFrame
				TweenService:Create(child, tweenInfo, {
					Transparency = 1,
					Position = child.Position
				}):Play()
			end

			local clone2 = utils.Naoya.Teleport:Clone()
			clone2.CFrame = humanoidRootPart.CFrame
			clone2.Parent = workspace.Effects
			clone2.Lines:Emit(8)
			clone2.Floor.Dust:Emit(30)
			Debris:AddItem(clone2, 1)
			local transparenciesByDescendant = {}

			for _, descendant in folder:GetDescendants() do
				if not ((descendant:IsA("BasePart") or descendant:IsA("Decal")) and descendant.Transparency ~= 1) then
					continue
				end

				local transparency = descendant.Transparency
				descendant.Transparency = 1
				transparenciesByDescendant[descendant] = transparency
			end

			task.wait(0.25)
			v2:PlaySound(sounds.Naoya.Decisive.Flicker2, humanoidRootPart, game.SoundService.Effect)

			for k, transparency in transparenciesByDescendant do
				if k.Parent then
					k.Transparency = transparency
				end
			end

			local clone3 = utils.Naoya.Teleport:Clone()
			clone3.CFrame = humanoidRootPart.CFrame
			clone3.Parent = workspace.Effects
			clone3.Lines:Emit(8)
			clone3.Floor.Dust:Emit(30)
			Debris:AddItem(clone3, 1)
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Naoya.RoughSwing:Clone()
			clone.Weld.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(0, 0, 3.4033920413889427)
			clone.Core.Flames.Enabled = false
			clone.Weld.Part0 = humanoidRootPart
			clone.Beam.CurveSize0 = -8
			clone.Beam.CurveSize1 = 8
			clone.A0.CFrame -= createVector(3.6, 0, 0)
			clone.A1.CFrame += createVector(3.6, 0, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.3)
			TweenService:Create(
				clone.Weld,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					C1 = clone.Weld.C1 * CFrame.Angles(0, 3.141592653589793, 0)
				}
			):Play()
			TweenService:Create(clone.Beam, TweenInfo.new(0.3), {
				Width0 = 0
			}):Play()
		end,
		Swing2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			for i = 1, 2 do
				local clone = utils.Naoya.RoughSwing:Clone()
				clone.Weld.C0 = CFrame.new(0, 1, 0) * CFrame.Angles(0, 0, -0.4363323129985824)
				clone.Weld.Part0 = humanoidRootPart
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 0.8)

				if i == 2 then
					clone.Beam.CurveSize0 = -8
					clone.Beam.CurveSize1 = 8
					clone.A0.CFrame -= createVector(3.6, 0, 0)
					clone.A1.CFrame += createVector(3.6, 0, 0)
					clone.Weld.C1 *= CFrame.Angles(0, 3.141592653589793, 0)
				end

				TweenService:Create(clone.Weld, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					C1 = clone.Weld.C1 * CFrame.Angles(0, 3.141592653589793, 0)
				}):Play()
				TweenService:Create(clone.Beam, TweenInfo.new(0.5), {
					Width0 = 0
				}):Play()
				task.delay(0.3, function()
					clone.Core.Flames.Enabled = false
				end)
				task.wait(0.05)
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
	v = Knit.GetService("CursoryImpactService")
	v2 = Knit.GetController("FXController")
end

return controller