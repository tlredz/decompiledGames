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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "ItadoriController"
})

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, value, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(
				sounds.Itadori.M1:FindFirstChild("Hit" .. (value or 1)),
				humanoidRootPart,
				game.SoundService.Effect
			)

			if p then
				local clone = utils.Itadori.CounterHit:Clone()
				clone.Position = humanoidRootPart.Position
				clone.Parent = workspace.Effects
				clone.Glow:Emit(1)
				clone.Sparks:Emit(20)
				Debris:AddItem(clone, 0.5)
			end
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
		DismantleHit = function(player, p, p2)
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Itadori.Dismantle.FinishSlash, humanoidRootPart, game.SoundService.Effect)
			local position

			if typeof(p) == "Vector3" then
				position = p
			else
				position = p.HumanoidRootPart.Position
				v3:Flash(p, Color3.new(1, 1, 1))
				v3:PlaySound(sounds.Itadori.Dismantle.Slash, p.HumanoidRootPart, game.SoundService.Effect)
			end

			for _, v5 in ({
				{ CFrame.Angles(0, 0, -0.8726646259971648) },
				{ CFrame.Angles(0, 0, -0.7853981633974483) },
				{ CFrame.Angles(0, 0, 0) },
				{
					CFrame.new(-3, 0, 0) * CFrame.Angles(0, 0, 1.0471975511965976),
					CFrame.new(3, 0, 0) * CFrame.Angles(0, 0, 0.8726646259971648),
					CFrame.Angles(0, 0, -0.5235987755982988)
				}
			})[p2] do
				local cFrame = CFrame.new(humanoidRootPart.Position, position) * v5
				local clone = utils.Itadori.Dismantle.DismantleFly:Clone()
				clone.CFrame = cFrame
				clone.Parent = workspace.Effects
				local highlight = Instance.new("Highlight", clone)
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.FillTransparency = 0
				highlight.FillColor = Color3.new(0, 0, 0)
				task.delay(0, function()
					TweenService:Create(clone, TweenInfo.new(0.1), {
						Size = createVector(15, 0, 0),
						CFrame = cFrame + cFrame.LookVector * 30
					}):Play()
					task.wait(0.1)
					highlight:Destroy()
					clone.Transparency = 1
					task.wait(0.05)
					clone:Destroy()
				end)
			end
		end,
		CleaveGrab = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
		end,
		CleaveHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p or localPlayer.Character == instance then
				task.delay(0.1, function()
					if _G.Settings.Flash ~= true then
						return
					end

					local clone = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone.Parent = game.Lighting
					task.wait(0.05)
					clone.TintColor = Color3.new(1, 1, 1)
					clone.Brightness = 200
					clone.Contrast = -1000
					task.wait(0.05)
					clone:Destroy()
				end)
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			local clone = utils.Itadori.Dismantle.Cleave:Clone()
			clone.Weld.Part1 = humanoidRootPart
			clone.Parent = workspace.Effects
			task.delay(0.1, function()
				clone.Slashes.Enabled = false
				clone.Slash2.Enabled = false
				clone.PointLight:Destroy()
				Debris:AddItem(clone, 0.08)
			end)
			v3:PlaySound(sounds.Itadori.Dismantle.FinishSlash, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 10 do
				clone.Slashes:Emit(1)
				v3:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)
				BloodyZee:Blood(p.Torso.CFrame, 50, 180, 180)
				task.wait()
			end
		end,
		BlackFlashHit = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.PerfectHit:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			v3:Flash(instance2, Color3.new(1, 0, 0))
			v3:PlaySound(sounds.Itadori.PerfectHit, humanoidRootPart, game.SoundService.Effect)
			clone.Wind2:Emit(8)
			clone.Lightning:Emit(6)
			clone.Sparks:Emit(15)
			clone.Sparks2:Emit(20)
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Finisher = function(p)
			if not p.HumanoidRootPart then
				return
			end

			v3:Bleed(p)
		end,
		Feint = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.CounterHit.Feint:Clone()
			clone.Parent = humanoidRootPart
			clone.Sparks:Emit(10)
			clone.Star:Emit(1)
			clone.Ring:Emit(1)
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
		Swing2 = function(instance, p, p2)
			if instance:GetAttribute("InUlt") then
				if p ~= 4 then
					v3:ArmFlash(instance["Right Arm"], Color3.fromRGB(255, 255, 255), 0.3)
					return
				end

				v3:ArmFlash(instance["Left Arm"], Color3.fromRGB(255, 255, 255), 0.3)
				v3:ArmFlash(instance["Right Arm"], Color3.fromRGB(255, 255, 255), 0.3)
			elseif p == 1 or p == 3 or p2 == "Up" then
				v3:ArmFlash(instance["Right Arm"], Color3.fromRGB(255, 0, 0))
			elseif p == 2 then
				v3:ArmFlash(instance["Left Arm"], Color3.fromRGB(255, 0, 0))
			elseif p == 4 then
				v3:ArmFlash(instance["Right Leg"], Color3.fromRGB(255, 0, 0), p2 == "Down" and 0.4 or false)
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
				v3:DustBreak(humanoidRootPart.Position + createVector(0, 2, 0), createVector(0, 1, 0), 15, 25, 0.7, 1.4)

				if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 20 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end
		end,
		Switch = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.Switch.Fade:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(1)
			Debris:AddItem(clone, 1)
			local clone2 = utils.Itadori.Switch.Switch:Clone()
			clone2.Parent = humanoidRootPart
			Debris:AddItem(clone2, 0.8)

			for _, child in clone2:GetChildren() do
				TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
					Size = child.Size + UDim2.new(0, 0, 0.1, 0)
				}):Play()
				local v5 = child
				task.delay(0.3, function()
					TweenService:Create(v5, TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {
						Size = v5.Size - UDim2.new(0, 0, 0.1, 0)
					}):Play()
				end)
			end

			local v5 = v3:PlaySound(sounds.Itadori.FireArrow.Arrow, humanoidRootPart, game.SoundService.Effect)
			v5.PlaybackSpeed = 1.2
			v5.TimePosition = 0.7

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Chat = function(instance)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			local clone = utils.Itadori.Dialogue:Clone()
			clone.Parent = torso
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
			task.wait(0.4)
			v3:PlaySound(sounds.Gojo.BlindsOff, torso, game.SoundService.Effect)
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
				end
			end
		end,
		Chat2 = function(instance)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			local clone = utils.Itadori.Dialogue:Clone()
			clone.Chat1.Sub.Text = "IT'S A BINDING VOW I MADE WITH THAT BRAT."
			clone.Parent = torso
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
			task.wait(0.4)
			v3:PlaySound(sounds.Gojo.BlindsOff, torso, game.SoundService.Effect)
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
				end
			end
		end,
		ThrowableWind = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Yuta.PunchSwing, humanoidRootPart, game.SoundService.Effect)
		end,
		ThrowableHit = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Yuta.MetalHit, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Hakari.Impact, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.PointLight:Destroy()
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
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

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 150 then
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
	v = Knit.GetService("ItadoriService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller