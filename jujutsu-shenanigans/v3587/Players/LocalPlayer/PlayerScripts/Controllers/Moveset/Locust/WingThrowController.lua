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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "WingThrowController"
})

function controller.KnitStart(_)
	local v4 = {
		Dash = function(instance, p)
			local humanoidRootPart = instance.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")

			if not humanoid then
				return
			end

			v3:PlaySound(sounds.Locust.Flight, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
				bodyGyro.P = 10000
				bodyGyro.MaxTorque = createVector(40000, 40000, 40000)
				p.Position = humanoidRootPart.Position + createVector(0, 12, 0)
				local lastTime = tick()
				humanoid.PlatformStand = true

				while true do
					local cFrame = workspace.CurrentCamera.CFrame

					if tick() - lastTime < 0.7 then
						local raycastResult = workspace:Raycast(
							humanoidRootPart.Position,
							cFrame.LookVector * 10,
							_G.MapParams
						)

						if raycastResult then
							p.Position = raycastResult.Position - cFrame.LookVector * 4
						else
							p.Position = humanoidRootPart.Position + cFrame.LookVector * 25
						end
					end

					bodyGyro.CFrame = cFrame
					task.wait()

					if p.Parent then
						continue
					end

					humanoid.PlatformStand = false
					bodyGyro:Destroy()
					break
				end
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
			v3:PlaySound(sounds.Todo.BruteForce.Swing, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Grab = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 200 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		ThrowHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			for i = 1, 10 do
				task.delay(i * 0.075, function()
					local clone = utils.Itadori.Shock:Clone()
					clone.CFrame = CFrame.lookAlong(humanoidRootPart.Position, humanoidRootPart.Velocity) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone.Parent = workspace.Effects
					TweenService:Create(clone, TweenInfo.new(0.15), {
						Size = createVector(10, 0, 10),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone, 0.15)
				end)
			end

			v3:Flash(instance, Color3.new(1, 1, 1))

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
	v = Knit.GetService("WingThrowService")
	v2 = Knit.GetController("ToolController")
	v3 = Knit.GetController("FXController")
end

return controller