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
require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "SoulfireController"
})

function controller.KnitStart(_)
	local v3 = {
		Morph = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2) then
				return
			end

			v2:PlaySound(sounds.Mahito.Soulfire.Morph, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 20 do
				local clone = utils.Mahito.Morph:Clone()
				clone.Weld.Part0 = instance["Right Arm"]
				clone.Color = instance["Right Arm"].Color
				clone.Weld.C1 = CFrame.new(
					math.random(-50, 50) / 100,
					math.random(-100, 100) / 100,
					math.random(-50, 50) / 100
				)
				clone.Parent = workspace.Effects
				local v4 = math.random(5, 25) / 10
				clone.Size = createVector(1, 1, 1) * v4
				TweenService:Create(
					clone,
					TweenInfo.new(math.random(10, 40) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
				Debris:AddItem(clone, 0.4)
			end

			instance2.Destroying:Connect(function()
				if not instance.Parent then
					return
				end

				for _ = 1, 20 do
					local clone = utils.Mahito.Morph:Clone()
					clone.Weld.Part0 = instance["Right Arm"]
					clone.Color = instance["Right Arm"].Color
					clone.Weld.C1 = CFrame.new(
						math.random(-50, 50) / 100,
						math.random(-100, 100) / 100,
						math.random(-50, 50) / 100
					)
					clone.Parent = workspace.Effects
					local v4 = math.random(5, 15) / 10
					clone.Size = createVector(1, 1, 1) * v4
					TweenService:Create(
						clone,
						TweenInfo.new(math.random(10, 30) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
					Debris:AddItem(clone, 0.3)
				end
			end)
		end,
		Fire = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 1, -6)
			clone.Size = createVector(0, 0, 6)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = createVector(9, 9, 0),
				Position = clone.Position - humanoidRootPart.CFrame.LookVector * 4,
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.2)
			v2:PlaySound(sounds.Mahito.Soulfire.Fire, humanoidRootPart, game.SoundService.Effect)

			if not p then
				return
			end

			p.Attachment.Flash:Emit(1)
			p.Attachment.PointLight.Brightness = 10
			TweenService:Create(p.Attachment.PointLight, TweenInfo.new(0.3), {
				Brightness = 0
			}):Play()
		end,
		Interp = function(instance)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Parent then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (200 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Mahito.Soulfire.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
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
	v = Knit.GetService("SoulfireService")
	v2 = Knit.GetController("FXController")
end

return controller