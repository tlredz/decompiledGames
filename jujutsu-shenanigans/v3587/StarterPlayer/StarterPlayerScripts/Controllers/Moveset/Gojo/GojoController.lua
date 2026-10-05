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
	Name = "GojoController"
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
		Teleport = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Teleport:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.1)
			clone.Center.Flash:Emit(1)
			v3:PlaySound(sounds.Gojo.Teleport2, humanoidRootPart, game.SoundService.Effect)
			task.delay(0.1, function()
				clone.Floor.Dust:Emit(30)
				task.wait(0.05)
				clone.CFrame = humanoidRootPart.CFrame
				clone.Lines:Emit(30)
				clone.Floor.Dust:Emit(30)
			end)

			if localPlayer.Character == instance then
				local clone2 = utils.Gojo.TeleportBreak:Clone()
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 0.8)
				local highlight = Instance.new("Highlight")
				highlight.OutlineTransparency = 1
				highlight.FillColor = Color3.new(1, 1, 1)
				highlight.FillTransparency = 0.8
				highlight.Parent = clone2
				task.delay(0.1, function()
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
					v3:PlaySound(sounds.Gojo.Teleport, humanoidRootPart, game.SoundService.Effect)

					for _ = 1, 30 do
						local clone3 = utils.Gojo.Shard:Clone()
						clone3.CFrame = clone2.Part.CFrame * CFrame.new(
							math.random(-40, 40) / 10,
							math.random(-20, 20) / 10,
							0
						)
						clone3.CFrame *= CFrame.Angles(math.random(0, 360), math.random(0, 360), math.random(0, 360))
						clone3.Parent = clone2.Shards
						TweenService:Create(clone3, TweenInfo.new(math.random(4, 7) / 10), {
							Size = createVector(0, 0, 0)
						}):Play()
						local v5 = clone2.Part.CFrame * CFrame.Angles(math.random(0, 30), math.random(-30, 30), 0)
						clone3.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
						local bodyVelocity = Instance.new("BodyVelocity")
						bodyVelocity.Archivable = false
						bodyVelocity.Parent = clone3
						bodyVelocity.Velocity = v5.LookVector * math.random(1, 80) / 10
					end

					repeat
						clone2:SetPrimaryPartCFrame(workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -2))

						for _, child in clone2.Shards:GetChildren() do
							child.BodyVelocity.Velocity -= createVector(0, 0.25, 0)
						end

						RunService.RenderStepped:Wait()
					until not clone2.Parent
				end)
			end
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
				v3:ArmFlash(data["Right Leg"], Color3.fromRGB(85, 255, 255), 0.4)
			elseif p == 1 or p == 4 then
				v3:ArmFlash(data["Right Arm"], Color3.fromRGB(85, 255, 255), 0.3)
			else
				v3:ArmFlash(data["Left Arm"], Color3.fromRGB(85, 255, 255), 0.3)
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
		Chat = function(instance)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			local clone = utils.Gojo.Dialogue:Clone()
			clone.Parent = torso
			v3:PlaySound(sounds.Gojo.GrabBlinds, torso, game.SoundService.Effect)
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
			task.wait(0.3)
			v3:PlaySound(sounds.Gojo.BlindsOff, torso, game.SoundService.Effect)
			task.wait(1)
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
		FistSlam = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Gojo.FistSlam, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		CamFix = function(instance, cFrame)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local objectSpace = humanoidRootPart.CFrame:ToObjectSpace(workspace.CurrentCamera.CFrame)
			humanoidRootPart.CFrame = cFrame
			workspace.CurrentCamera.CFrame = cFrame:ToWorldSpace(objectSpace)
		end,
		DragStart = function(instance, p, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = v3:PlaySound(sounds.Gojo.TeleportDrag, humanoidRootPart, game.SoundService.Effect)
			local v6 = nil

			if localPlayer.Character == p then
				v6 = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
			elseif localPlayer.Character == instance then
				v6 = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.LightHit)
			end

			instance2.AncestryChanged:Connect(function()
				if v6 then
					v6:StartFadeOut(0.5)
				end

				v5:Stop()
			end)
		end,
		DragThrow = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance.HumanoidRootPart

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
			v3:PlaySound(sounds.Gojo.DragThrow, humanoidRootPart, game.SoundService.Effect)

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
	v.Hitbox:Connect(function(instance, p, object)
		local humanoidRootPart = p.HumanoidRootPart

		if not humanoidRootPart then
			return
		end

		local v5 = nil

		while true do
			local sphereHitbox = v2:SphereHitbox(p, CFrame.new(0, -1, -3), 10)

			for _, v7 in sphereHitbox do
				local info = v7:FindFirstChild("Info")

				if not info then
					continue
				end

				local knockback = info:FindFirstChild("Knockback")

				if not (not knockback or knockback.Value ~= false) then
					continue
				end

				v5 = sphereHitbox
				break
			end

			if v5 then
				local numberValue = instance:FindFirstChildWhichIsA("NumberValue")

				if numberValue then
					TweenService:Create(numberValue, TweenInfo.new(0.1), {
						Value = 0
					}):Play()
				end
			else
				task.wait(0.05)

				if instance.Parent then
					continue
				end
			end

			object:FireServer(v5, humanoidRootPart.CFrame)
			break
		end
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("GojoService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller