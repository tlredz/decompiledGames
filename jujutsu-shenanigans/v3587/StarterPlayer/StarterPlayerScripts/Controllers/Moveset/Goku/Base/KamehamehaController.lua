local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local controller = Knit.CreateController({
	Name = "KamehamehaController"
})
local v = nil
local v2 = nil
local currentCamera = workspace.CurrentCamera

function controller.KnitStart(_)
	local v3 = {
		AutoRotate = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if instance == localPlayer.Character then
				repeat
					task.wait()
					instance2.CFrame = instance2:GetAttribute("FinalPos") or CFrame.lookAlong(
						humanoidRootPart.Position,
						currentCamera.CFrame.LookVector,
						currentCamera.CFrame.UpVector
					)
				until not instance2.Parent
			end
		end,
		StartCharge = function(parent)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Goku.Ball:Clone()
			clone.Parent = parent
			clone.Ball.Part0 = parent["Left Arm"]
			clone.Size = createVector(0, 0, 0)
			clone.Attachment.Glow:Emit(1)
			TweenService:Create(clone, TweenInfo.new(0.5), {
				Size = createVector(1, 1, 1)
			}):Play()
			v:PlaySound(sounds.Goku.Kamehameha.Use, humanoidRootPart, game.SoundService.Effect)
		end,
		ChargeStronger = function(instance)
			local ball = instance:FindFirstChild("Ball")

			if not ball then
				return
			end

			ball.Attachment.Charge.Enabled = true
			TweenService:Create(ball, TweenInfo.new(0.5), {
				Size = createVector(2, 2, 2)
			}):Play()
		end,
		Shoot = function(instance, cFrame)
			local ball = instance:FindFirstChild("Ball")

			if not ball then
				return
			end

			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			ball:Destroy()
			local clone = utils.Goku.Kamehameha:Clone()
			clone.Parent = workspace.Effects
			clone.Ball1.CFrame = cFrame
			clone.Ball2.CFrame = cFrame
			clone.Shaft.Size = createVector(0, 2, 2)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Map.Data }
			local lastTime = tick()

			while true do
				task.wait()
				local position = (humanoidRootPart.CFrame * CFrame.new(0, 0, -5)).Position
				clone.Ball1.Position = position
				local raycastResult = workspace:Raycast(position, cFrame.LookVector * 50, raycastParams)
				local position2 = cFrame * CFrame.new(0, 0, -50).Position

				if raycastResult then
					position2 = raycastResult.Position
				end

				local v4 = 1 + math.random() / 2
				local v5 = createVector(1, 1, 1) * v4 * 1.5
				local vector2 = Vector3.new(1, v4, v4)
				clone.Ball1.Position = position
				clone.Ball2.Position = clone.Ball2.Position:Lerp(position2, 0.3)
				clone.Ball1.Size = createVector(4, 4, 4) * v5
				clone.Ball2.Size = createVector(3, 3, 3) * v5
				clone.Shaft.Size = clone.Shaft.Size:Lerp(Vector3.new((position - position2).Magnitude, 2, 2), 0.3) * vector2
				clone.Shaft.CFrame = CFrame.lookAt((position + clone.Ball2.Position) / 2, position2) * CFrame.Angles(
					0,
					1.5707963267948966,
					0
				)

				if instance == localPlayer.Character then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightLoop)
				end

				if not (tick() - lastTime > 0.5) then
					continue
				end

				TweenService:Create(clone.Shaft, TweenInfo.new(0.3), {
					Size = Vector3.new(clone.Shaft.Size.X, 0, 0)
				}):Play()
				TweenService:Create(clone.Ball1, TweenInfo.new(0.3), {
					Size = createVector(0, 0, 0)
				}):Play()
				TweenService:Create(clone.Ball2, TweenInfo.new(0.3), {
					Size = createVector(0, 0, 0)
				}):Play()
				task.wait(0.3)
				clone:Destroy()
				break
			end
		end,
		RemoveCharges = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local ball = instance:FindFirstChild("Ball")

			if not ball then
				return
			end

			if humanoidRootPart:FindFirstChild("Kamehameha") then
				humanoidRootPart:FindFirstChild("Kamehameha"):Destroy()
			end

			ball:Destroy()
		end,
		Hit = function(folder)
			if folder:GetAttribute("KamehamehaFinished") then
				return
			end

			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if not folder:GetAttribute("Dead") then
				v:Flash(folder, Color3.fromRGB(13, 105, 172))
				return
			end

			folder:SetAttribute("KamehamehaFinished", true)

			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					descendant.Transparency = 1
				end
			end

			for _ = 1, 10 do
				local part = Instance.new("Part")
				part.Color = Color3.fromRGB(13, 105, 172)
				part.Material = Enum.Material.Neon
				part.Anchored = true
				part.CanCollide = false
				part.Position = humanoidRootPart.Position
				part.Parent = workspace.Effects
				Debris:AddItem(part, 2)
				TweenService:Create(
					part,
					TweenInfo.new(math.random(0.5, 2), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						Position = part.Position + Vector3.new(
							math.random(-5, 5),
							math.random(1, 6),
							math.random(-5, 5)
						),
						Orientation = Vector3.new(
							math.random(-180, 180),
							math.random(-180, 180),
							math.random(-180, 180)
						),
						Size = createVector(0, 0, 0)
					}
				):Play()
				v:PlaySound(sounds.Goku.Kamehameha.Finisher, humanoidRootPart, game.SoundService.Effect)
			end
		end
	}
	v2.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	v2 = Knit.GetService("KamehamehaService")
	v = Knit.GetController("FXController")
end

return controller