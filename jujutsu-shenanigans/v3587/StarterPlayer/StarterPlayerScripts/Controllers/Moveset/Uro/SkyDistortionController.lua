local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
local controller = Knit.CreateController({
	Name = "SkyDistortionController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Uro.SkyDistortion.Swing, humanoidRootPart, game.SoundService.Effect)
		end,
		Interp = function(instance)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			local model = Instance.new("Model", workspace.Effects)
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.Parent = model
			local position = instance.Position + instance.CFrame.LookVector * 4 - instance.CFrame.RightVector * 5 - createVector(
				0,
				2,
				0
			)
			local clone = utils.Uro.AirDistort2:Clone()
			clone.Parent = model
			v2:PlaySound(sounds.Uro.SkyDistortion.Throw, clone, game.SoundService.Effect)
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			task.spawn(function()
				repeat
					local clone2 = utils.Uro.Ring:Clone()
					clone2.CFrame = instance.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
					clone2.Parent = model
					clone2.Attachment.Wind:Emit(2)
					TweenService:Create(clone2, TweenInfo.new(0.5), {
						Size = clone2.Size * 2,
						Transparency = 1
					}):Play()
					Debris:AddItem(clone2, 0.5)
					task.wait(0.075)
				until not instance.Parent

				Debris:AddItem(model, 0.5)
				TweenService:Create(clone, tweenInfo, {
					Size = createVector(15, 15, 0),
					Position = position
				}):Play()
			end)
			local v5 = 10
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function(_, dt)
				if instance.Parent then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (180 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					local magnitude = (position - instance.Position).Magnitude
					local cframe = CFrame.lookAt(position, instance.Position)
					v5 = math.lerp(v5, 2, 2 * dt)
					clone.CFrame = cframe + cframe.LookVector * (magnitude / 2)
					clone.Size = Vector3.new(v5, v5, magnitude)
				else
					steppedConnection:Disconnect()
					positionChangedConnection:Disconnect()
				end
			end)
			instance.Destroying:Connect(function()
				if (workspace.CurrentCamera.CFrame.Position - instance.Position).Magnitude < 40 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end

				v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, instance, game.SoundService.Effect)
				local tweenInfo2 = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

				for _, child in instance.Rocks:GetChildren() do
					child.BlueGrab:Destroy()
					child.Parent = workspace.Effects
					Debris:AddItem(child, 2)
					TweenService:Create(child, tweenInfo, {
						Position = child:GetAttribute("P1"),
						Orientation = child:GetAttribute("V2")
					}):Play()
					TweenService:Create(child, tweenInfo2, {
						Size = createVector(0, 0, 0)
					}):Play()
				end
			end)
		end,
		Crunch = function(instance, instance2, items)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local magnitude = (workspace.CurrentCamera.CFrame.Position - instance2.Position).Magnitude

			if magnitude < 40 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			if magnitude > 75 or not (instance2.Parent and instance2:FindFirstChild("Rocks")) then
				return
			end

			for _, item in items do
				local part = Instance.new("Part")
				part.CollisionGroup = "Effects"
				part.Massless = true
				part.Position = item[1]
				part.Orientation = item[2]
				part.Color = item[3]
				part.Material = item[4]
				part.Size = item[5]
				part.Transparency = item[6]
				part.Parent = instance2.Rocks
				part:SetAttribute("P1", item[1])
				part:SetAttribute("P2", item[2])
				local attachment = Instance.new("Attachment", part)
				attachment.Name = "BlueGrab"
				local alignPosition = Instance.new("AlignPosition", attachment)
				alignPosition.Responsiveness = 30
				TweenService:Create(alignPosition, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Responsiveness = 200
				}):Play()
				alignPosition.Attachment0 = attachment
				alignPosition.Attachment1 = instance2.Attachment
				part.RotVelocity = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
			end
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
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(255, 165, 165))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 60 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
	v = Knit.GetService("SkyDistortionService")
	v2 = Knit.GetController("FXController")
end

return controller