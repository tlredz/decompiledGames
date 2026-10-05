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
local v3 = nil
local controller = Knit.CreateController({
	Name = "ChaosController"
})

function controller.KnitStart(_)
	local v4 = {
		Form = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			local tweenInfo2 = TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
			v3:PlaySound(sounds.Misc.S.Form, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Misc.S.C:Clone()

			for i, child in clone:GetChildren() do
				child.Weld.Part0 = humanoidRootPart
				child.Weld.C0 *= CFrame.Angles(0, math.rad(51.42857142857143 * i), 0)
				TweenService:Create(child.Weld, tweenInfo, {
					C1 = CFrame.new(0, 0, -8)
				}):Play()
				local v5 = child
				task.delay(1.2, function()
					TweenService:Create(v5.Weld, tweenInfo2, {
						C1 = CFrame.new(0, 0, 0)
					}):Play()
				end)
			end

			clone.Parent = workspace.Effects
			local v5 = tick() + 2

			while true do
				task.wait()

				for _, child in clone:GetChildren() do
					child.Weld.C0 *= CFrame.Angles(0, 0.08726646259971647, 0)
				end

				if not (v5 < tick()) then
					continue
				end

				clone:Destroy()

				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 100 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end

				break
			end
		end,
		Boost = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			task.spawn(function()
				local clone = utils.Misc.S.Boost:Clone()
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 1.1)
				task.delay(0.7, function()
					for _, effect in clone:GetDescendants() do
						if effect:IsA("Beam") then
							TweenService:Create(effect, TweenInfo.new(0.4), {
								Width0 = 0,
								Width1 = 0
							}):Play()
						elseif effect:IsA("ParticleEmitter") then
							effect.Enabled = false
						end
					end
				end)

				repeat
					clone.CFrame = CFrame.lookAlong(humanoidRootPart.Position, -humanoidRootPart.Velocity) * CFrame.Angles(
						0,
						0,
						math.random(0, 3.141592653589793)
					)
					task.wait()
				until not clone.Parent
			end)
			v3:PlaySound(sounds.Misc.S.Dash, humanoidRootPart, game.SoundService.Effect)
			CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)

			for _ = 1, 30 do
				local clone = utils.Mahito.BodyRepel["Wind" .. math.random(1, 5)]:Clone()
				clone.CFrame = CFrame.lookAlong(humanoidRootPart.Position, humanoidRootPart.Velocity) * CFrame.Angles(
					1.5707963267948966,
					math.rad((math.random(0, 360))),
					0
				)
				clone.Transparency = 0.5
				clone.Size = createVector(6, 6, 20)
				TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
					CFrame = clone.CFrame + humanoidRootPart.CFrame.LookVector * 3,
					Size = createVector(40, 0, 40)
				}):Play()
				Debris:AddItem(clone, 0.15)
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(0.15), {
					Transparency = 0.5
				}):Play()
				task.delay(0.15, function()
					TweenService:Create(clone, TweenInfo.new(0.15), {
						Transparency = 1
					}):Play()
				end)
				task.wait(0.03)
			end
		end,
		Melee = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and p) then
				return
			end

			sounds.Misc.S.Dash2.PlaybackSpeed = math.random(100, 200) / 100
			v3:PlaySound(sounds.Misc.S.Dash2, humanoidRootPart, game.SoundService.Effect)
			local v5 = math.random(1, 4)
			local leftArm

			if v5 == 1 then
				leftArm = instance["Left Arm"]
			elseif v5 == 2 then
				leftArm = instance["Right Arm"]
			elseif v5 == 3 then
				leftArm = instance["Left Leg"]
			else
				leftArm = instance["Right Leg"]
			end

			v3:ArmFlash(leftArm, Color3.fromRGB(255, 255, 127), 0.5)
			local v6 = tick() + 0.3

			repeat
				local v7 = task.wait()
				local v8 = p.HumanoidRootPart.Position - humanoidRootPart.CFrame.LookVector * 3
				humanoidRootPart.CFrame = humanoidRootPart.CFrame - humanoidRootPart.Position + humanoidRootPart.Position:Lerp(
					v8,
					20 * v7
				) + Vector3.new(math.random(-20, 20) / 10, math.random(-20, 20) / 10, math.random(-20, 20) / 10)
			until v6 < tick()
		end,
		MeleeHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			local v5 = sounds.Misc.S.Hit["Hit" .. math.random(1, 2)]
			v5.PlaybackSpeed = math.random(100, 150) / 100
			v3:PlaySound(v5, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Misc.S.HeavyHit:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			clone.Glow:Emit(1)
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 300 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			else
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Interp = function(instance)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			v3:PlaySound(sounds.Choso.PiercingBlood.Fire, instance, game.SoundService.Effect)
			v3:PlaySound(sounds.Choso.PiercingBlood.Pressure2, instance, game.SoundService.Effect)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Parent then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (instance:GetAttribute("Speed") * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		HomingHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			sounds.Misc.S.OrbHit.PlaybackSpeed = math.random(100, 150) / 100
			v3:PlaySound(sounds.Misc.S.OrbHit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Misc.S.HeavyHit:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.4)
			TweenService:Create(clone.PointLight, TweenInfo.new(0.4), {
				Brightness = 0
			}):Play()
			clone.Sparks:Emit(50)
			clone.Wind2:Emit(7)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 300 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			else
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		On = function()
			v3:PlaySound(sounds.Misc.S.On, workspace, game.SoundService.Effect)
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
	v = Knit.GetService("ChaosService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller