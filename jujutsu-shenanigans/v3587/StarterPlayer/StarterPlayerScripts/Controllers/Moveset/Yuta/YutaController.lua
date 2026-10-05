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
	Name = "YutaController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, instance2, p, p2, p3)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))

			if p3 or p2 == false then
				v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit" .. p), humanoidRootPart2, game.SoundService.Effect)

				if p3 then
					v3:PlaySound(sounds.Yuta.MetalHit3, humanoidRootPart2, game.SoundService.Effect)
				end
			else
				local v5

				if p2 == "Up" or p2 == "Down" then
					v5 = p2
				else
					v5 = p
				end

				v3:PlaySound(sounds.Yuta.M1:FindFirstChild("Hit" .. v5), humanoidRootPart2, game.SoundService.Effect)

				if p2 then
					local clone = utils.Yuta.SlashHit:Clone()
					clone.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart.CFrame.LookVector)

					if p == 2 then
						clone.CFrame *= CFrame.Angles(0, 0, -0.2617993877991494)
					elseif p == 3 then
						clone.CFrame *= CFrame.Angles(0, 0, 0.4363323129985824)
					elseif p2 == "Up" then
						clone.CFrame *= CFrame.Angles(0, 0, -1.3089969389957472)
					end

					clone.Parent = workspace.Effects
					Debris:AddItem(clone, 0.5)
					clone.Slash:Emit(5)
				end
			end
		end,
		ChaseHit = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			if p then
				v3:Flash(instance2, Color3.new(1, 1, 1))
				v3:PlaySound(
					sounds.Yuta.M1:FindFirstChild("Hit" .. math.random(1, 3)),
					humanoidRootPart2,
					game.SoundService.Effect
				)
			else
				v3:Flash(instance2, Color3.new(1, 1, 1))
				v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit3"), humanoidRootPart2, game.SoundService.Effect)
			end

			local clone = utils.ChaseHit:Clone()
			clone.CFrame = CFrame.new(
				humanoidRootPart2.Position,
				(Vector3.new(humanoidRootPart.Position.X, humanoidRootPart2.Position.Y, humanoidRootPart.Position.Z))
			) * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			clone.Ring:Emit(7)
			clone.Sparks:Emit(12)
		end,
		AerialHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart2, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			local cframe = CFrame.new(humanoidRootPart.Position, humanoidRootPart2.Position - createVector(0, 4, 0))
			local clone = utils.Gojo.HardHit:Clone()
			clone.CFrame = cframe + cframe.LookVector * 4
			clone.Parent = workspace.Effects
			clone.Dust:Emit(5)
			clone.Ring:Emit(5)
			clone.Sparks:Emit(10)
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
		Swing = function(instance, value, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if instance:GetAttribute("InUlt") and not p2 then
				v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
				return
			end

			local v5 = (p == "Up" or p == "Down") and "4Sword" or value or 4
			v3:PlaySound(sounds.Yuta.M1:FindFirstChild("Swing" .. v5), humanoidRootPart, game.SoundService.Effect)
		end,
		Swing2 = function(data, p, p2, p3)
			if p3 == false then
				if p == 1 then
					v3:ArmFlash(data["Left Arm"], Color3.fromRGB(255, 85, 255), 0.3)
					task.wait(0.233)
					v3:ArmFlash(data["Right Arm"], Color3.fromRGB(255, 85, 255), 0.2)
				elseif p == 2 then
					v3:ArmFlash(data["Right Arm"], Color3.fromRGB(255, 85, 255), 0.3)
					task.wait(0.233)
					v3:ArmFlash(data["Left Arm"], Color3.fromRGB(255, 85, 255), 0.2)
				elseif p == 3 then
					v3:ArmFlash(data["Left Arm"], Color3.fromRGB(255, 85, 255), 0.6)
				else
					v3:ArmFlash(data["Right Arm"], Color3.fromRGB(255, 85, 255), 0.4)
				end
			else
				if p == 4 and not p2 then
					v3:ArmFlash(data["Left Leg"], Color3.fromRGB(255, 85, 255), 0.4)
					return
				end

				local yutaSword = data.SetAssets:FindFirstChild("YutaSword")

				if yutaSword and p3 then
					local clone = utils.Yuta.CombatTrail:Clone()
					clone.Weld.Part0 = yutaSword.Sword.MeshPart
					clone.Parent = workspace.Effects
					task.wait(p == 4 and 0.425 or 0.275)
					clone.Trail.Enabled = false
					TweenService:Create(clone, TweenInfo.new(0.1), {
						Transparency = 1
					}):Play()
					Debris:AddItem(clone, 0.2)
				end
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
		SwordSound = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = v3:PlaySound(sounds.Yuta.SwordGrab, humanoidRootPart, game.SoundService.Effect)

			if p then
				v5.Volume *= 0.2
				v5.PlaybackSpeed = 1.5
			end

			local yutaSword = instance.SetAssets:FindFirstChild("YutaSword")

			if not yutaSword then
				return
			end

			yutaSword.Sheath.Glow.Glow:Emit(2)
		end,
		BreakChainSound = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Yuta.Ultimate.BreakChain, humanoidRootPart, game.SoundService.Effect)
		end,
		MetalArmSound = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Yuta.Ultimate.EquipArm, humanoidRootPart, game.SoundService.Effect)
		end,
		ShakeArmSound = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Yuta.Ultimate.ShakeArm, humanoidRootPart, game.SoundService.Effect)
		end,
		PutRingSound = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Yuta.Ultimate.PutRing, humanoidRootPart, game.SoundService.Effect)
		end,
		BreakChain = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local yutaSword = instance.SetAssets:FindFirstChild("YutaSword")

			if not yutaSword then
				return
			end

			local chainRing = yutaSword:FindFirstChild("ChainRing")

			if not chainRing then
				return
			end

			local count = 0
			local children = {}

			for _, child in chainRing:GetChildren() do
				if child:IsA("Weld") then
					child:Destroy()
				elseif child:IsA("Part") then
					count += 1

					if count % 3 == 0 then
						child:SetAttribute(
							"Velocity",
							humanoidRootPart.Velocity + humanoidRootPart.CFrame.LookVector * math.random(5, 10) + createVector(
								0,
								1,
								0
							) * math.random(5, 15) + humanoidRootPart.CFrame.RightVector * math.random(-5, 5)
						)
						table.insert(children, child)
					else
						child:Destroy()
					end
				elseif child:IsA("Model") then
					child:Destroy()
				end
			end

			local v5 = createVector(0, 1, 0) * -workspace.Gravity

			repeat
				local v6 = task.wait()

				for _, v7 in children do
					local velocity = v7:GetAttribute("Velocity")
					v7.Position += v7:GetAttribute("Velocity") * v6
					v7:SetAttribute("Velocity", velocity + v5 * v6)
				end
			until not chainRing.Parent
		end,
		Chat = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			v3:PlaySound(
				sounds.Yuta.Ultimate[p == "Zero" and "VLZero" or "VL"],
				humanoidRootPart,
				game.SoundService.Voice
			)
			local clone = utils.Yuta.Dialogue:Clone()
			clone.Parent = torso
			task.wait(0.45)
			local position = clone.Text1.Position
			clone.Text1.Position = position - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Text1, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position
			}):Play()
			TweenService:Create(clone.Text1, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			TweenService:Create(clone.Text1.UIStroke, TweenInfo.new(0.3), {
				Transparency = 0
			}):Play()
			task.wait(0.5)
			local position2 = clone.Text2.Position
			clone.Text2.Position = position2 + UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Text2, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position2
			}):Play()
			TweenService:Create(clone.Text2, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			TweenService:Create(clone.Text2.UIStroke, TweenInfo.new(0.3), {
				Transparency = 0
			}):Play()
			task.wait(1)
			local position3 = clone.Chat.Position
			clone.Chat.Position = position3 - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Chat, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position3
			}):Play()
			TweenService:Create(clone.Chat, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(1.2)
			Debris:AddItem(clone, 0.6)

			for _, guiObject in clone:GetDescendants() do
				if guiObject:IsA("ImageLabel") then
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
		end,
		RingEmit = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local yutaRing = instance.SetAssets:FindFirstChild("YutaRing")

			if not yutaRing then
				return
			end

			yutaRing.Diamond.Visuals.ConstantGlow.Enabled = true
			task.wait(0.3)
			local beam = yutaRing.Diamond.Visuals.Beam
			local beam2 = beam.Beam
			beam2.TextureLength = 0.1
			beam.Position = createVector(0, 0, 0)
			beam2.Enabled = true
			TweenService:Create(beam2, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				TextureLength = 1
			}):Play()
			TweenService:Create(beam, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Position = createVector(-0, -2, -0)
			}):Play()
			task.wait(0.7)
			yutaRing.Diamond.Visuals.ConstantGlow.Enabled = false
			TweenService:Create(beam2, TweenInfo.new(0.3), {
				TextureLength = 0.1,
				Width1 = 0,
				Width0 = 0
			}):Play()
			TweenService:Create(beam, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				Position = createVector(-0, -0.5, -0)
			}):Play()
			task.wait(0.3)
			beam:Destroy()
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
	v = Knit.GetService("YutaService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller