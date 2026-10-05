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
require(replicatedStorage.Modules.StaticLightning)
local LightningBeams = require(replicatedStorage.Modules.LightningBeams)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "UnsatisfiedController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Ryu.Unsatisfied.Weave, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.2)
			v2:ArmFlash(instance["Right Arm"], Color3.fromRGB(170, 255, 255), 0.6)
			task.wait(0.2)
			v2:ArmFlash(instance["Left Arm"], Color3.fromRGB(170, 255, 255), 0.4)
		end,
		Dash = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Ryu.Unsatisfied.Dash, humanoidRootPart, game.SoundService.Effect)
			local model = Instance.new("Model")
			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = p * CFrame.new(0, -1, 0)
			clone.Parent = model
			model.Parent = workspace.Effects
			model:ScaleTo(0.8)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.LockedToPart = true
				end
			end

			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			TweenService:Create(clone, TweenInfo.new(0.6), {
				CFrame = clone.CFrame * CFrame.new(0, 0, -7)
			}):Play()
			Debris:AddItem(model, 2)
		end,
		Dash2 = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v2:DustTrail(instance, 0.6, CFrame.Angles(0, -1.5707963267948966, 0))
		end,
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Ryu.Unsatisfied["Hit" .. p], humanoidRootPart, game.SoundService.Effect)
			local v4 = math.random(140, 200) / 10
			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.Transparency = 0.7
			clone.Position = instance.Head.Position
			clone.Orientation = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
			clone.Size = createVector(0, 0, 7)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				Size = Vector3.new(v4, v4, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.1)
		end,
		Hit2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Ryu.Unsatisfied.FinalHit1, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(170, 255, 255))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)
			task.spawn(function()
				local model = Instance.new("Model", workspace.Effects)
				local highlight = Instance.new("Highlight", model)
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.FillTransparency = 1
				highlight.OutlineColor = Color3.new(0, 0, 0)
				Debris:AddItem(model, 0.6)
				local random = Random.new()
				Instance.new("Attachment", clone)
				tick()

				for _ = 1, 7 do
					local attachment = Instance.new("Attachment", clone)
					attachment.Position = random:NextUnitVector() * 30
					TweenService:Create(
						attachment,
						TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Position = random:NextUnitVector() * 30
						}
					):Play()
					local v4 = LightningBeams.new(humanoidRootPart.RootAttachment, attachment, nil, model)

					if instance:GetAttribute("Moveset") == "Yuta" then
						v4.Color = ColorSequence.new(Color3.fromRGB(223, 108, 255), Color3.fromRGB(90, 118, 219))
						v4.ColorOffsetSpeed = 0
					else
						v4.Color = ColorSequence.new(Color3.fromRGB(108, 104, 219), Color3.fromRGB(90, 118, 219))
					end

					v4.PulseSpeed = 6
					v4.FadeLength = 0.5
					v4.CurveSize0 = math.random(-10, 10)
					v4.CurveSize1 = math.random(-10, 10)
					v4.MaxRadius = 3
					v4.MinRadius = 0
					v4.AnimationSpeed = 10
					v4.MinThicknessMultiplier = 0.2
					v4.MaxThicknessMultiplier = 0.6
					task.delay(0.4, function()
						TweenService:Create(
							attachment,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Position = createVector(0, 0, 0)
							}
						):Play()
						task.wait(0.2)
						v4:Destroy()
					end)
				end

				repeat
					clone.Position = humanoidRootPart.Position
					task.wait()
				until not (humanoidRootPart.Parent and model.Parent)
			end)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 60 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		HitEnd = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Ryu.Unsatisfied.FinalHit2, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart2.Position
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

			task.wait(0.1)

			for _, child in utils.Ryu.Launch:GetChildren() do
				child:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(1.9198621771937625, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
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
	v = Knit.GetService("UnsatisfiedService")
	v2 = Knit.GetController("FXController")
end

return controller