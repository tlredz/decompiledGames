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
	Name = "SlicingExorcismController"
})

function controller.KnitStart(_)
	local v3 = {
		Saw = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Choso.SlicingExorcism.Saw1, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Choso.Convergence, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Choso.BloodBurst, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.4)
			v2:PlaySound(sounds.Itadori.CursedStrikes.Spin, humanoidRootPart, game.SoundService.Effect)
		end,
		Interp = function(instance)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			v2:PlaySound(sounds.Mahito.CrushingRushdown.HairPull, instance, game.SoundService.Effect)
			local v4 = v2:PlaySound(sounds.Choso.SlicingExorcism.Saw, instance, game.SoundService.Effect, true)
			TweenService:Create(v4, TweenInfo.new(0.3), {
				Volume = 1
			}):Play()
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Position and instance.Transparency ~= 1 then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (150 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
				TweenService:Create(v4, TweenInfo.new(0.3), {
					Volume = 0
				}):Play()
			end)
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Mahito.DrillSplit.Drill, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 0, 0))
			v2:PlaySound(sounds.Choso.PiercingBlood.Hit, humanoidRootPart, game.SoundService.Effect)
		end,
		Reflect = function(p)
			p.Center.Sparks:Emit(10)
			v2:PlaySound(sounds.Choso.SlicingExorcism.Reflect, p, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - p.Position).Magnitude < 140 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Finisher = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)
			v2:Bleed(instance)
		end,
		Flashup = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			if instance2 then
				for _, attachment in instance2:GetChildren() do
					if not (attachment:IsA("Attachment") and attachment.ParticleEmitter.Enabled ~= false) then
						continue
					end

					attachment.ParticleEmitter.Enabled = false
					attachment.ParticleEmitter.Name = "Out"
					local clone = utils.Choso.Supernova.Blood1.ParticleEmitter:Clone()
					clone.Parent = attachment
				end
			end
		end,
		Blood = function(instance, folder, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v4 = {
				0,
				0.5,
				1,
				1.5
			}
			local clone = utils.Choso.PiercingBlood:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -9)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, v4[p] + 1)
			clone.Start.Blood.Speed = NumberRange.new(10, 400)
			v2:PlaySound(sounds.Choso.PiercingBlood.Fire, humanoidRootPart, game.SoundService.Effect)
			clone.Start.Blood.Enabled = true
			clone.Start.Burst.Enabled = true
			TweenService:Create(clone.End, TweenInfo.new(0.1), {
				Position = createVector(0, 0, -60)
			}):Play()
			TweenService:Create(clone.Beam, TweenInfo.new(0.3), {
				Width0 = 0.5,
				Width1 = 0.5
			}):Play()
			Debris:AddItem(clone.Beam, v4[p] + 0.3)
			task.delay(v4[p], function()
				TweenService:Create(clone.Beam, TweenInfo.new(0.3), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				clone.Start.Blood.Enabled = false
				clone.Start.Burst.Enabled = false
			end)
			local model = Instance.new("Model")
			local clone2 = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone2.CFrame = clone.CFrame * CFrame.new(0, -1, 0)
			clone2.Parent = model
			model.Parent = workspace.Effects
			model:ScaleTo(0.6)
			clone2.Ring:Emit(7)
			clone2.Dash1.Dash:Emit(1)
			clone2.Dash2.Dash:Emit(1)
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Quad), {
				CFrame = clone2.CFrame - clone2.CFrame.LookVector * 16
			}):Play()
			Debris:AddItem(model, 2)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			task.spawn(function()
				local now = tick()

				repeat
					clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -9)
					task.wait()
				until not humanoidRootPart.Parent or tick() > now + v4[p]
			end)

			if folder then
				for _, attachment in folder:GetChildren() do
					if not (attachment:IsA("Attachment") and attachment.ParticleEmitter.Enabled ~= false) then
						continue
					end

					local clone3 = utils.Choso.PiercingBlood.Beam:Clone()
					clone3.Attachment0 = attachment
					clone3.Attachment1 = clone.Start
					clone3.Parent = attachment
					TweenService:Create(clone3, TweenInfo.new(v4[p] + 0.3), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end

				task.delay(v4[p], function()
					for _, effect in folder:GetDescendants() do
						if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
							effect.Enabled = false
						end
					end
				end)
			end

			for i = 1, 4 do
				local clone3 = utils.Itadori.Shock:Clone()
				clone3.CFrame = clone.CFrame * CFrame.Angles(1.5707963267948966, 0, 0) + clone.CFrame.LookVector * (i * 14)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.15), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone3, 0.15)
				task.wait(0.02)
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
	v = Knit.GetService("SlicingExorcismService")
	v2 = Knit.GetController("FXController")
end

return controller