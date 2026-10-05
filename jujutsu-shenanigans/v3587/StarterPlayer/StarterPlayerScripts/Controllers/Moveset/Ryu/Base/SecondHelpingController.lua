local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "SecondHelpingController"
})

function controller.KnitStart(_)
	local v4 = {
		Startup = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Ryu.SecondHelping.Startup, humanoidRootPart, game.SoundService.Effect)
			local cframe = CFrame.lookAt(humanoidRootPart.Position, p)

			for _, child in utils.Ryu.Doosh:GetChildren() do
				child:PivotTo(cframe * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Ryu.Slash:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = CFrame.Angles(0, 0, -1.3962634015954636)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.2)
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(clone.Weld, tweenInfo, {
				C1 = CFrame.Angles(0, 2.9670597283903604, 0)
			}):Play()

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("Decal") then
					TweenService:Create(descendant, tweenInfo2, {
						Transparency = 1
					}):Play()
				elseif descendant:IsA("SpecialMesh") then
					TweenService:Create(descendant, tweenInfo, {
						Scale = descendant.Scale * 1.7
					}):Play()
				end
			end
		end,
		Crush = function(position)
			local clone = utils.Hiromi.Shockwave:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.CFrame *= CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
			TweenService:Create(clone.mesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Scale = createVector(15, 0, 15)
			}):Play()
			TweenService:Create(clone.mesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			clone.Floor.Glow:Emit(1)
			clone.Floor.Ring:Emit(10)
			Debris:AddItem(clone, 1.5)
			local clone2 = utils.Choso.CounterSwing.Shock:Clone()
			clone2.Size = createVector(10, 30, 10)
			clone2.CFrame = CFrame.new(position)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.3)
			TweenService:Create(clone2, TweenInfo.new(0.3), {
				Size = createVector(36, 7, 36),
				Transparency = 1,
				Position = clone2.Position - createVector(0, 3, 0)
			}):Play()
			local clone3 = utils.Choso.CounterSwing.Shock:Clone()
			clone3.Size = createVector(20, 10, 20)
			clone3.CFrame = CFrame.new(position)
			clone3.Parent = workspace.Effects
			Debris:AddItem(clone3, 0.2)
			TweenService:Create(clone3, TweenInfo.new(0.2), {
				Size = createVector(0, 36, 0),
				Transparency = 1,
				Position = clone3.Position + createVector(0, 10, 0)
			}):Play()
			v2:DustBreak(position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)
			v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, clone, game.SoundService.Effect)
			v2:PlaySound(sounds.Hakari.Impact, clone, game.SoundService.Effect)
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Ryu.SecondHelping.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(170, 255, 255))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 60 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		HitPact = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Ryu.SecondHelping.AirHit, humanoidRootPart2, game.SoundService.Effect)
			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = (humanoidRootPart.CFrame - humanoidRootPart.Position + humanoidRootPart2.Position) * CFrame.Angles(
				1.9198621771937625,
				0,
				0
			)
			clone.Size = createVector(0, 0, 7)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(12, 12, 1)
			}):Play()
			Debris:AddItem(clone, 0.9)
			task.delay(0.5, function()
				TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
					Size = createVector(25, 25, 0),
					Transparency = 1
				}):Play()
				task.wait(0.2)
				v2:PlaySound(sounds.Ryu.SecondHelping.AirHit2, humanoidRootPart2, game.SoundService.Effect)
			end)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 60 then
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
	v = Knit.GetService("SecondHelpingService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller