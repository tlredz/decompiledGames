local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
	Name = "FlameArrowController"
})

function controller.KnitStart(_)
	local v3 = {
		HotHands = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.FireArrow.Hands, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Itadori.FireArrow.HotHands:Clone()
			clone.Parent = workspace.Effects
			clone.Weld.Part0 = instance["Left Arm"]
			Debris:AddItem(clone, 2)
			local clone2 = replicatedStorage.Utils.Itadori.FireArrow.HotHands:Clone()
			clone2.Parent = workspace.Effects
			clone2.Weld.Part0 = instance["Right Arm"]
			Debris:AddItem(clone2, 2)
			TweenService:Create(clone, TweenInfo.new(0.6), {
				Transparency = 0
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.6), {
				Transparency = 0
			}):Play()
			task.wait(0.8)
			clone.Flames.Enabled = false
			clone2.Flames.Enabled = false
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.3), {
				Transparency = 1
			}):Play()
		end,
		Clap = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.FireArrow.FireClap:Clone()
			clone.Parent = workspace.Effects
			clone.Weld.Part0 = humanoidRootPart
			Debris:AddItem(clone, 1)
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Color = Color3.new(1, 0, 0),
				Brightness = 0
			}):Play()
			clone.Dust:Emit(2)
			clone.Smash:Emit(4)
			clone.Flames:Emit(30)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end

			v2:PlaySound(sounds.Itadori.FireArrow.Clap, humanoidRootPart, game.SoundService.Effect)
		end,
		Arrow = function(p, data)
			local spike1 = data.Spike1
			local spike2 = data.Spike2
			spike1.Parent = p["Right Arm"]
			spike2.Parent = p["Right Arm"]
			data.Attachment1.Parent = p["Right Arm"]
			task.wait(0.2)
			TweenService:Create(data.PointLight, TweenInfo.new(2), {
				Brightness = 20,
				Range = 30
			}):Play()
			task.wait(0.5)
			data.Attachment0.Flare:Emit(3)
			data.Attachment0.Heat.Enabled = true
			TweenService:Create(spike1, TweenInfo.new(1.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
				Position = createVector(2, 2, -3.4)
			}):Play()
			TweenService:Create(spike2, TweenInfo.new(1.6, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
				Position = createVector(2, 2, 2.6)
			}):Play()
			v2:PlaySound(sounds.Itadori.FireArrow.Arrow, data, game.SoundService.Effect)
			TweenService:Create(
				v2:PlaySound(sounds.Itadori.FireArrow.Idle, data, game.SoundService.Effect),
				TweenInfo.new(1),
				{
					Volume = 1
				}
			):Play()
		end,
		Fire = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			v2:PlaySound(sounds.Itadori.FireArrow.Fire, humanoidRootPart, game.SoundService.Effect)
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
						{ cFrame + cFrame.LookVector * (192 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		Burn = function(self)
			local clone = utils.Itadori.FireArrow.Burn:Clone()
			clone.Parent = workspace.Effects
			clone.Position = self
			Debris:AddItem(clone, 3)
			clone.Center.Wind2:Emit(25)
			clone.Flames:Emit(200)
			TweenService:Create(clone, TweenInfo.new(0.75), {
				Size = createVector(0, 250, 0),
				CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			TweenService:Create(clone.Beam, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			TweenService:Create(clone.Lines, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			v2:PlaySound(sounds.Itadori.FireArrow.Explode, clone, game.SoundService.Effect)
		end,
		Finisher = function(instance)
			if not instance.HumanoidRootPart then
				return
			end

			v2:Burn(instance)

			for _, part in instance:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local clone = utils.Damage.Flames:Clone()
				clone.Parent = part
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
	v = Knit.GetService("FlameArrowService")
	v2 = Knit.GetController("FXController")
end

return controller