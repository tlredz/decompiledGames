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
require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "SpikeWrathController"
})

function controller.KnitStart(_)
	local v4 = {
		Startup = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.fromRGB(170, 85, 255), 1)
			v3:PlaySound(sounds.Mahito.ForceGrab.Retract, humanoidRootPart, game.SoundService.Effect)
		end,
		Start = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Mahito.Roll, humanoidRootPart, game.SoundService.Effect)
			local colors = {}

			for _, part in instance:GetChildren() do
				if part:IsA("BasePart") and part ~= humanoidRootPart then
					table.insert(colors, part.Color)
				end
			end

			local bodyFrontAttachment = instance.Torso.BodyFrontAttachment
			local parent = bodyFrontAttachment.Parent
			local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

			repeat
				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 300 then
					task.wait(0.1)
				else
					task.spawn(function()
						local clone = utils.Mahito.Pierce:Clone()
						clone.Position = humanoidRootPart.Position - Vector3.new(
							math.random(-35, 35),
							6,
							math.random(-35, 35)
						) + humanoidRootPart.CFrame.LookVector * 20
						clone.Attachment.WorldPosition = parent.Position
						clone.Pierce.Attachment0 = bodyFrontAttachment
						clone.Pierce.Color = ColorSequence.new(colors[math.random(1, #colors)])
						clone.Pierce.CurveSize0 = math.random(-25, 25)
						clone.Parent = workspace.Effects
						Debris:AddItem(clone, 0.7)
						local attachment = clone.Attachment
						TweenService:Create(attachment, TweenInfo.new(0.2), {
							Position = createVector(0, 0, 0)
						}):Play()
						TweenService:Create(clone.Pierce, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
							CurveSize0 = 0
						}):Play()
						task.wait(0.5)
						local worldPosition = attachment.WorldPosition
						attachment.Parent = parent
						attachment.WorldPosition = worldPosition
						TweenService:Create(attachment, TweenInfo.new(0.2), {
							Position = createVector(0, 0, 0)
						}):Play()
						Debris:AddItem(attachment, 0.2)
					end)
					local v5 = math.random(90, 130) / 100
					local clone = utils.Mahito.Worms.Morph2:Clone()
					clone.Decal:Destroy()
					clone.Color = colors[math.random(1, #colors)]
					clone.Weld.C0 *= CFrame.Angles(
						math.random(0, 3.141592653589793),
						math.random(0, 3.141592653589793),
						math.random(0, 3.141592653589793)
					)
					clone.Weld.Part0 = humanoidRootPart
					clone.Size = createVector(0, 0, 0)
					clone.Parent = workspace.Effects
					Debris:AddItem(clone, 1.7)
					TweenService:Create(clone.Weld, TweenInfo.new(v5 + 0.4, Enum.EasingStyle.Exponential), {
						C0 = clone.Weld.C0 * CFrame.Angles(
							math.random(0, 3.141592653589793),
							math.random(0, 3.141592653589793),
							math.random(0, 3.141592653589793)
						)
					}):Play()
					task.spawn(function()
						local v8 = v5 / 5
						TweenService:Create(clone, TweenInfo.new(v5, Enum.EasingStyle.Elastic), {
							Size = createVector(1, 1, 1) * math.random(40, 90) / 10
						}):Play()
						local tweenInfo2 = TweenInfo.new(v8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

						for i = 1, 4 do
							local lerped = CFrame.new(
								math.random(-20, 20) / 3,
								math.random(-10, 20) / 5,
								math.random(-20, 20) / 3
							):Lerp(
								CFrame.new(),
								i / 6
							)
							TweenService:Create(clone.Weld, tweenInfo2, {
								C1 = lerped
							}):Play()
							task.wait(v8)
						end

						TweenService:Create(clone, tweenInfo, {
							Size = createVector(0, 0, 0)
						}):Play()
					end)
					task.wait(0.075)
				end
			until not (p and p.Parent and p.Parent.Parent)
		end,
		Grab = function(instance, state, duration)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local colors = {}

			for _, part in state.Attachment0.Parent.Parent:GetChildren() do
				if part:IsA("BasePart") and part ~= humanoidRootPart then
					table.insert(colors, part.Color)
				end
			end

			local v5 = math.random(1, 2)

			if v5 == 1 then
				v3:PlaySound(sounds.Mahito.DrillSplit.Morph, humanoidRootPart, game.SoundService.Effect)
			elseif v5 == 2 then
				v3:PlaySound(sounds.Mahito.DrillSplit.Unmorph, humanoidRootPart, game.SoundService.Effect)
			end

			state.Color = ColorSequence.new(colors[math.random(1, #colors)])
			state.CurveSize1 = 45
			state.CurveSize0 = -45
			TweenService:Create(state, TweenInfo.new(duration, Enum.EasingStyle.Elastic), {
				CurveSize0 = 0,
				CurveSize1 = 0
			}):Play()
			task.wait(duration)
			TweenService:Create(state, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				CurveSize1 = 15
			}):Play()
			task.wait(0.8)
			TweenService:Create(state, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				CurveSize1 = 0
			}):Play()
			task.wait(0.7)
			local attachment = Instance.new("Attachment", state.Attachment0.Parent)
			attachment.WorldPosition = state.Attachment1.WorldPosition
			state.Attachment1 = attachment
			local v6 = math.random(40, 70) / 100
			TweenService:Create(attachment, TweenInfo.new(v6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = createVector(0, 0, 0)
			}):Play()
		end,
		Grab2 = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local colors = {}

			for _, part in instance:GetChildren() do
				if part:IsA("BasePart") and part ~= humanoidRootPart then
					table.insert(colors, part.Color)
				end
			end

			local v5 = math.random(1, 2)

			if v5 == 1 then
				v3:PlaySound(sounds.Mahito.DrillSplit.Morph, humanoidRootPart, game.SoundService.Effect)
			elseif v5 == 2 then
				v3:PlaySound(sounds.Mahito.DrillSplit.Unmorph, humanoidRootPart, game.SoundService.Effect)
			end

			local attachment = Instance.new("Attachment")
			local clone = utils.Mahito.Pierce.Pierce:Clone()
			clone.Attachment1 = attachment
			clone.Attachment0 = humanoidRootPart.RootAttachment
			clone.Color = ColorSequence.new(colors[math.random(1, #colors)])
			clone.CurveSize1 = 45
			clone.CurveSize0 = -45
			clone.Width0 = 3
			clone.Parent = attachment
			attachment.Parent = humanoidRootPart
			TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Elastic), {
				CurveSize0 = 0,
				CurveSize1 = 0
			}):Play()
			TweenService:Create(attachment, TweenInfo.new(0.1), {
				WorldPosition = humanoidRootPart2.Position
			}):Play()
			task.wait(0.1)
			TweenService:Create(attachment, TweenInfo.new(0.3), {
				Position = createVector(0, 0, 0)
			}):Play()
			Debris:AddItem(attachment, 0.3)
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
	v = Knit.GetService("SpikeWrathService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller