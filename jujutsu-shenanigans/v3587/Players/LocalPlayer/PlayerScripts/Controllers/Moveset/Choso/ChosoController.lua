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
local v3 = nil
local controller = Knit.CreateController({
	Name = "ChosoController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Choso.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
		end,
		ChaseHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit3"), humanoidRootPart2, game.SoundService.Effect)
			local clone = utils.ChaseHit:Clone()
			clone.CFrame = CFrame.new(
				humanoidRootPart2.Position,
				(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart2.Position.Y, humanoidRootPart.Position.Z))
			) * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Parent = workspace.Effects
			clone.Ring:Emit(7)
			clone.Sparks:Emit(12)
			Debris:AddItem(clone, 0.5)
		end,
		Chase = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 1, -4)
			clone.Size = createVector(0, 0, 2)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(9, 9, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.3)
			v3:PlaySound(sounds.Misc.Chase, humanoidRootPart, game.SoundService.Effect)
			v3:DustTrail(p, 0.4, CFrame.Angles(0, -1.5707963267948966, 0))
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(data, p, p2)
			if p == 1 or p2 == "Up" then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(255, 0, 0), 0.3)
			elseif p == 2 then
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(255, 0, 0))
			elseif p == 3 or p2 == "Down" then
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(255, 0, 0), p2 == "Down" and 0.4 or 0.3)
			elseif p == 4 then
				v3:ArmFlash(data["Left Leg"], Color3.fromRGB(255, 0, 0), 0.4)
			end
		end,
		Launch = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Size = createVector(0, 0, 5)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(8, 8, 0),
				Transparency = 1,
				Position = clone.Position + Vector3.new(0, p, 0)
			}):Play()
			Debris:AddItem(clone, 0.3)

			if p < 0 then
				v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, humanoidRootPart, game.SoundService.Effect)
				v3:DustBreak(humanoidRootPart.Position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)

				if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 20 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end
		end,
		BloodStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Gojo.BlindsOff, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.4)
			v3:PlaySound(sounds.Itadori.CursedStrikes.Spin, humanoidRootPart, game.SoundService.Effect)
		end,
		Convergence = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p then
				v3:PlaySound(sounds.Choso.BloodMerge, humanoidRootPart, game.SoundService.Effect)
			else
				v3:PlaySound(sounds.Choso.Convergence, humanoidRootPart, game.SoundService.Effect)
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

			v3:Flash(instance, Color3.new(1, 0, 0))
			v3:PlaySound(sounds.Choso.PiercingBlood.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Hakari.RoughHit:Clone()
			clone.Glow.Color = ColorSequence.new(Color3.fromRGB(150, 0, 0))
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(150, 0, 0))
			clone.Wind.Color = ColorSequence.new(Color3.fromRGB(150, 0, 0))
			clone.Wind2.Color = ColorSequence.new(Color3.fromRGB(150, 0, 0))
			clone.PointLight.Color = Color3.fromRGB(150, 0, 0)
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
		end,
		Chat = function(instance)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			v3:PlaySound(sounds.Choso.Awaken, torso, game.SoundService.Effect)
			task.spawn(function()
				task.wait(0.7)

				if localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				end

				local clone = utils.Choso.Switch:Clone()
				clone.Parent = instance.Head
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = UDim2.new(15, 0, 15, 0)
				}):Play()
				local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				TweenService:Create(clone.Eye1, tweenInfo, {
					Size = UDim2.new(0.3, 0, 0, 0),
					ImageTransparency = 1
				}):Play()
				TweenService:Create(clone.Eye2, tweenInfo, {
					Size = UDim2.new(0.6, 0, 0, 0),
					ImageTransparency = 1
				}):Play()
				TweenService:Create(clone.Eye3, tweenInfo, {
					Size = UDim2.new(0.3, 0, 0, 0),
					ImageTransparency = 1
				}):Play()
				Debris:AddItem(clone, 0.5)
				local clone2 = utils.Choso.BloodSpread:Clone()
				clone2.Parent = instance.Head
				clone2:Emit(80)
				Debris:AddItem(clone2, 3)
				task.delay(1.1, function()
					clone2.Drag = 0
					clone2.Acceleration = createVector(0, -70, 0)
					clone2.Brightness = 0.5

					if localPlayer.Character == instance then
						CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
					end
				end)

				for i = 1, 3 do
					local clone3 = utils.Choso.Brother:Clone()
					clone3.HumanoidRootPart.Weld.Part0 = instance.HumanoidRootPart
					clone3.Parent = workspace.Effects
					Debris:AddItem(clone3, 1)

					for _, descendant in clone3:GetDescendants() do
						if not (descendant:IsA("BasePart") or descendant:IsA("Decal")) then
							continue
						end

						local transparency = descendant.Transparency
						descendant.Transparency = 1
						TweenService:Create(descendant, TweenInfo.new(0.3), {
							Transparency = transparency
						}):Play()
					end

					clone3.HumanoidRootPart.Weld.C0 *= CFrame.Angles(
						0,
						math.rad(i == 1 and -35 or i == 2 and 35 or 0),
						0
					)
					clone3.AnimationController:LoadAnimation(clone3.AnimationController.Animation):Play()
					local folder = clone3
					task.delay(0.6, function()
						for i2, descendant in folder:GetDescendants() do
							if descendant:IsA("BasePart") or descendant:IsA("Decal") then
								TweenService:Create(descendant, TweenInfo.new(0.4), {
									Transparency = 1
								}):Play()
							end
						end
					end)
					task.wait(0.2)
				end
			end)
			local clone = utils.Choso.Dialogue:Clone()
			clone.Parent = torso
			local position = clone.Text1.Position
			clone.Text1.Position = position - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Text1, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position
			}):Play()
			TweenService:Create(clone.Text1, TweenInfo.new(0.5), {
				TextTransparency = 0
			}):Play()
			TweenService:Create(clone.Text1.UIStroke, TweenInfo.new(0.5), {
				Transparency = 0
			}):Play()
			task.wait(0.7)
			local position2 = clone.Chat1.Position
			clone.Chat1.Position = position2 - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Chat1, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position2
			}):Play()
			TweenService:Create(clone.Chat1, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat1.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(1.25)
			Debris:AddItem(clone, 0.6)

			for _, guiObject in clone:GetDescendants() do
				if guiObject:IsA("Frame") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Position = guiObject.Position - UDim2.new(0, 0, 0.2, 0),
						BackgroundTransparency = 1
					}):Play()
				elseif guiObject:IsA("TextLabel") then
					TweenService:Create(guiObject, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						TextTransparency = 1
					}):Play()

					if guiObject:FindFirstChild("UIStroke") then
						TweenService:Create(
							guiObject:FindFirstChild("UIStroke"),
							TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
							{
								Transparency = 1
							}
						):Play()
					end
				end
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
	v = Knit.GetService("ChosoService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller