local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local animations = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "DefenseResponseController"
})

function controller.KnitStart(_)
	local v3 = {
		Weave = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:ArmFlash(instance["Right Arm"], Color3.fromRGB(172, 203, 163), 1)
			v2:PlaySound(
				sounds.Hanami.DefenseResponse[`{p and "Air" or ""}Startup`],
				humanoidRootPart,
				game.SoundService.Effect
			)
			local clone = utils.Naoya.Fall:Clone()
			clone:PivotTo(humanoidRootPart.CFrame)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.5)
			clone.Mesh.Start.Transparency = 0.15
			clone.Mesh2.Start.Transparency = 0.3
			clone.Mesh3.Start.Transparency = 0.3
			TweenService:Create(
				clone.Mesh.Start,
				TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = clone.Mesh.End.Size,
					Transparency = 1,
					CFrame = clone.Mesh.End.CFrame
				}
			):Play()
			TweenService:Create(
				clone.Mesh2.Start,
				TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = clone.Mesh2.End.Size,
					Transparency = 1,
					CFrame = clone.Mesh2.End.CFrame
				}
			):Play()
			TweenService:Create(
				clone.Mesh3.Start,
				TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = clone.Mesh3.End.Size,
					Transparency = 1,
					CFrame = clone.Mesh3.End.CFrame
				}
			):Play()
			clone.Mesh.End:Destroy()
			clone.Mesh2.End:Destroy()
			clone.Mesh3.End:Destroy()
		end,
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 0.498039))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hanami.DefenseResponse[`Hit{p}`], humanoidRootPart, game.SoundService.Effect)
		end,
		Spike = function(position, instance, p, p2)
			local clone = utils.Hanami[p2 and "TreeMonster" or "360Spike"]:Clone()
			clone.Position = position - Vector3.new(0, 6 * p, 0)

			if p then
				local model = Instance.new("Model")
				clone.Parent = model
				model:ScaleTo(p)
				clone.Parent = workspace.Effects
				model:Destroy()
			end

			clone.Parent = workspace.Effects
			instance:GetPropertyChangedSignal("CFrame"):Connect(function()
				TweenService:Create(clone, TweenInfo.new(0.3), {
					CFrame = instance.CFrame * CFrame.new(0, 4 * p, 0)
				}):Play()
			end)

			for i = 1, 5 do
				local clone2 = utils.Hanami.ParticleDissipationHolder:Clone()
				clone2.BlackDust.Size = NumberSequence.new(8 - i / 2, 12 - i / 2)
				clone2.RedDust1.Size = clone2.BlackDust.Size
				clone2.RedDust2.Size = clone2.BlackDust.Size
				clone2.Position = Vector3.new(0, i * 2.5 + -6, 0)
				clone2.Parent = clone
			end

			v2:DustBreak(position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)
			v2:PlaySound(sounds.Hanami.DefenseResponse.Root, clone, game.SoundService.Effect)
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
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Position = position + Vector3.new(0, 4 * p, 0)
			}):Play()

			if instance then
				repeat
					task.wait()
				until not (instance and instance:IsDescendantOf(workspace.Effects))

				print(instance.Parent)
				v2:PlaySound(sounds.Hanami.RootDisappear, clone, game.SoundService.Effect)

				if _G.Settings.DesPHY then
					clone:Destroy()

					if (workspace.CurrentCamera.CFrame.Position - position).Magnitude > 150 then
						return
					end

					Random.new()

					for _ = 1, 15 do
						local v4 = math.random(100, 250) / 100
						local v5 = math.random(250, 500) / 100
						local clone4 = utils.Hiromi.GavelShard:Clone()
						clone4.Position = position + Vector3.new(
							math.random(-5, 5),
							math.random(-5, 5),
							math.random(-5, 5)
						)
						clone4.Size = Vector3.new(v4, v5, v4)
						clone4.Velocity = Vector3.new(math.random(-80, 80), math.random(30, 60), math.random(-80, 80))
						clone4.RotVelocity = Vector3.new(
							math.random(-50, 50),
							math.random(-50, 50),
							math.random(-50, 50)
						)
						clone4.Color = clone.Color
						clone4.Parent = workspace.Effects
						Debris:AddItem(clone4, 2)
						task.delay(1, function()
							TweenService:Create(clone4, TweenInfo.new(1), {
								Size = createVector(0, 0, 0)
							}):Play()
						end)
					end
				else
					TweenService:Create(clone, TweenInfo.new(0.2), {
						Transparency = 1
					}):Play()
					v2:PlayParticles(clone)
					Debris:AddItem(clone, 1)
				end
			else
				task.wait(1.3)
				TweenService:Create(clone, TweenInfo.new(0.2), {
					Transparency = 1
				}):Play()
				v2:PlayParticles(clone)
				v2:PlaySound(sounds.Hanami.RootDisappear, clone, game.SoundService.Effect)
				Debris:AddItem(clone, 1)
			end
		end,
		TreeMonster = function(position, instance, p)
			local clone = utils.Hanami.TreeMonster:Clone()
			clone.PrimaryPart.Position = position + createVector(0, 1, 0) - Vector3.new(0, p, 0)

			if p then
				local model = Instance.new("Model")
				clone.Parent = model
				model:ScaleTo(p)
				clone.Parent = workspace.Effects
				model:Destroy()
			end

			clone.Parent = workspace.Effects
			clone.AnimationController.Animator:LoadAnimation(animations.Hanami.EvilTreeIdle):Play(0)
			instance:GetPropertyChangedSignal("CFrame"):Connect(function()
				TweenService:Create(clone.PrimaryPart, TweenInfo.new(0.3), {
					CFrame = instance.CFrame * CFrame.new(0, 4 * p, 0)
				}):Play()
			end)
			instance:GetAttributeChangedSignal("Lasso"):Connect(function()
				clone.AnimationController:LoadAnimation(animations.Hanami.EvilTreeThrow):Play(0)
			end)

			for i = 1, 5 do
				local clone2 = utils.Hanami.ParticleDissipationHolder:Clone()
				clone2.BlackDust.Size = NumberSequence.new(8 - i / 2, 12 - i / 2)
				clone2.RedDust1.Size = clone2.BlackDust.Size
				clone2.RedDust2.Size = clone2.BlackDust.Size
				clone2.Position = Vector3.new(0, i * 2.5 + -6, 0)
				clone2.Parent = clone.Jaw
			end

			v2:DustBreak(position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)
			v2:PlaySound(sounds.Hanami.DefenseResponse.Root, clone.PrimaryPart, game.SoundService.Effect)
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
			TweenService:Create(clone.PrimaryPart, TweenInfo.new(0.2), {
				Position = position + Vector3.new(0, 4 * p, 0)
			}):Play()

			if instance then
				repeat
					task.wait()
				until not (instance and instance:IsDescendantOf(workspace.Effects))

				print(instance.Parent)
				v2:PlaySound(sounds.Hanami.RootDisappear, clone.PrimaryPart, game.SoundService.Effect)

				if _G.Settings.DesPHY then
					clone:Destroy()

					if (workspace.CurrentCamera.CFrame.Position - position).Magnitude > 150 then
						return
					end

					Random.new()

					for _ = 1, 15 do
						local v4 = math.random(100, 250) / 100
						local v5 = math.random(250, 500) / 100
						local clone4 = utils.Hiromi.GavelShard:Clone()
						clone4.Position = position + Vector3.new(
							math.random(-5, 5),
							math.random(-5, 5),
							math.random(-5, 5)
						)
						clone4.Size = Vector3.new(v4, v5, v4)
						clone4.Velocity = Vector3.new(math.random(-80, 80), math.random(30, 60), math.random(-80, 80))
						clone4.RotVelocity = Vector3.new(
							math.random(-50, 50),
							math.random(-50, 50),
							math.random(-50, 50)
						)
						clone4.Color = Color3.fromRGB(76, 60, 51)
						clone4.Parent = workspace.Effects
						Debris:AddItem(clone4, 2)
						task.delay(1, function()
							TweenService:Create(clone4, TweenInfo.new(1), {
								Size = createVector(0, 0, 0)
							}):Play()
						end)
					end
				else
					TweenService:Create(clone, TweenInfo.new(0.2), {
						Transparency = 1
					}):Play()
					v2:PlayParticles(clone)
					Debris:AddItem(clone, 1)
				end
			else
				task.wait(1.3)
				TweenService:Create(clone, TweenInfo.new(0.2), {
					Transparency = 1
				}):Play()
				v2:PlayParticles(clone)
				v2:PlaySound(sounds.Hanami.RootDisappear, clone.PrimaryPart, game.SoundService.Effect)
				Debris:AddItem(clone, 1)
			end
		end,
		SmallField = function(position)
			local clone = utils.Hanami.SmallFieldWindup:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			v2:PlaySound(sounds.Hanami.FlowersField.Field, clone, game.SoundService.Effect)
			task.wait(0.8)

			for _, emitter in clone:GetChildren() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			Debris:AddItem(clone, 1)
			local clone2 = utils.Hanami.SmallFieldExplosion:Clone()
			clone2.Position = position - createVector(0, 1, 0)
			clone2.Parent = workspace.Effects

			for _, child in clone2:GetChildren() do
				child:Emit(50)
			end

			task.wait(0.1)
			clone2.Size *= createVector(1.3, 1, 1.3)

			for _, child in clone2:GetChildren() do
				if child.Name:sub(1, 1) ~= "F" then
					continue
				end

				child.ShapePartial = 0.3
				child:Emit(10)
			end

			Debris:AddItem(clone2, 6)
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
	v = Knit.GetService("DefenseResponseService")
	v2 = Knit.GetController("FXController")
end

return controller