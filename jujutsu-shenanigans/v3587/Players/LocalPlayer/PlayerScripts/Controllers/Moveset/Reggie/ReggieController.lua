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
	Name = "ReggieController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
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
			if p2 == "Down" then
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(255, 255, 255), 0.4)
			elseif p2 == "Up" then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(255, 255, 255), 0.3)
			elseif p == 1 then
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(255, 255, 255), 0.3)
			elseif p == 2 then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(255, 255, 255), 0.3)
			elseif p == 3 then
				v3:ArmFlash(data["Left Leg"], Color3.fromRGB(255, 255, 255), 0.3)
			elseif p == 4 then
				v3:ArmFlash(data["Left Leg"], Color3.fromRGB(255, 255, 255), 0.4)
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
		MoveSwap = function(p, p2, p3)
			if p == localPlayer.Character then
				local moveset = localPlayer.PlayerGui:WaitForChild("Main").Controls.Moveset
				local reggieSlot = moveset:FindFirstChild("ReggieSlot")

				if reggieSlot and not p3 then
					reggieSlot.BackgroundColor3 = Color3.new(1, 1, 1)
					TweenService:Create(reggieSlot, TweenInfo.new(1), {
						BackgroundColor3 = Color3.fromRGB(31, 31, 31)
					}):Play()
				end

				if p2 then
					for _, frame in moveset:GetChildren() do
						if not (frame:IsA("Frame") and frame.ItemName.Text == p2.Name) then
							continue
						end

						frame.BackgroundColor3 = Color3.new(1, 1, 1)
						TweenService:Create(frame, TweenInfo.new(1), {
							BackgroundColor3 = Color3.fromRGB(31, 31, 31)
						}):Play()
					end
				end
			end
		end,
		Discard = function(p, instance)
			if localPlayer.Character == p then
				local clone = utils.Reggie.Highlight:Clone()
				clone.Parent = p
				clone.Adornee = p
				instance.Destroying:Connect(function()
					clone:Destroy()
				end)
			end
		end,
		GoldSeal = function(p, instance)
			if localPlayer.Character == p then
				local clone = utils.Reggie.Highlight:Clone()
				clone.FillColor = Color3.fromRGB(255, 217, 102)
				clone.OutlineColor = Color3.fromRGB(255, 217, 102)
				clone.Parent = p
				clone.Adornee = p
				instance.Destroying:Connect(function()
					clone:Destroy()
				end)
			end
		end,
		DiscardWhoosh = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.Discard, humanoidRootPart, game.SoundService.Effect)
		end,
		Burn = function(instance, p, cFrame)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Reggie.ReceiptBurn:Clone()
			clone.Parent = workspace.Effects
			clone.Anchored = true

			if p then
				cFrame = p.MainReceipt.CFrame or cFrame
			end

			clone.CFrame = cFrame
			v3:PlayParticles(clone)
			Debris:AddItem(clone, 3)
			v3:PlaySound(sounds.Reggie.CouponBurn, humanoidRootPart, game.SoundService.Effect)
		end,
		Spa = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Reggie.Spotlight:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			v3:PlayParticles(clone)
			Debris:AddItem(clone, 3)
		end,
		Sweep = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Reggie.SweepStars:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 1.75, -0.9) * CFrame.Angles(
				0,
				-0.4363323129985824,
				0.4363323129985824
			)
			clone.Parent = workspace.Effects

			for _, child in clone.Attachment:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			Debris:AddItem(clone, 1)
		end,
		Ultimate = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.Ultimate, humanoidRootPart, game.SoundService.Effect)
		end,
		Chat = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local clone = utils.Reggie.Dialogue:Clone()
			clone.Parent = instance.Torso
			local position = clone.Chat1.Position
			clone.Chat1.Position = position - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Chat1, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position
			}):Play()
			TweenService:Create(clone.Chat1, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat1.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(0.5)
			local position2 = clone.Chat2.Position
			clone.Chat2.Position = position2 - UDim2.new(0, 0, 0.15, 0)
			TweenService:Create(clone.Chat2, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = position2
			}):Play()
			TweenService:Create(clone.Chat2, TweenInfo.new(0.3), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(clone.Chat2.Sub, TweenInfo.new(0.3), {
				TextTransparency = 0
			}):Play()
			task.wait(1.5)
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
				end
			end
		end,
		CouponStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.CouponWhoosh, humanoidRootPart, game.SoundService.Effect)
		end,
		LitteringStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.Littering.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		LitteringLand = function(p)
			v3:PlaySound(sounds.Reggie.Littering.Land, p, game.SoundService.Effect)
		end,
		LitteringActivate = function(p)
			for _, child in p.CE_Infuse:GetChildren() do
				child.Enabled = true
				child:Emit(1)
			end

			local clone = utils.Reggie.ReceiptBurn:Clone()
			clone.Parent = workspace.Effects
			clone.Anchored = true
			clone.CFrame = p.CFrame
			v3:PlayParticles(clone)
			Debris:AddItem(clone, 3)
			v3:PlaySound(sounds.Reggie.CouponBurn2, p, game.SoundService.Effect)
		end,
		Ball = function(instance, p)
			local clone = replicatedStorage.Utils.Reggie.Ball:Clone()
			clone.Size *= math.random(135, 175) / 100 / (instance:GetAttribute("Delay") and 1.5 or 1)
			clone.Color = Color3.fromRGB(math.random(100, 170), math.random(100, 170), math.random(100, 170))
			clone.Position = instance.Position + instance.CFrame.UpVector * 2
			clone.AssemblyLinearVelocity = instance.CFrame.UpVector * math.random(50, 110) + Vector3.new(
				math.random(-5, 5),
				0,
				math.random(-5, 5)
			)
			clone.AssemblyAngularVelocity = Vector3.new(
				math.random(-20, 20),
				math.random(-20, 20),
				math.random(-20, 20)
			)
			clone.CanCollide = true
			clone.Parent = workspace.Effects
			task.delay(2, function()
				TweenService:Create(clone, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
				Debris:AddItem(clone, 0.5)
			end)
			local clone2 = utils.Gojo.LapseBlue.Throw:Clone()
			clone2.CFrame = CFrame.new(clone.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Size = createVector(0, 0, 5)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.3), {
				Size = createVector(8, 8, 0),
				Transparency = 1,
				Position = clone2.Position + createVector(0, 3, 0)
			}):Play()
			Debris:AddItem(clone2, 0.3)
			local playSound = v3:PlaySound(sounds.Reggie.Littering.BallSpawn, clone, game.SoundService.Effect)
			playSound.Volume = p and 0.16666666666666666 or 0.3333333333333333
		end,
		BallHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.Littering.BallHit, humanoidRootPart, game.SoundService.Effect)
		end,
		RainbowSealExplode = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local position = humanoidRootPart.Position
			local clone = utils.Reggie.BikeExplode:Clone()
			clone.Parent = workspace.Effects
			clone.Position = position
			Debris:AddItem(clone, 6)
			v3:PlayParticles(clone)
			v3:PlaySound(sounds.Reggie.DroneStrike.Explode, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 35 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
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
	v = Knit.GetService("ReggieService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller