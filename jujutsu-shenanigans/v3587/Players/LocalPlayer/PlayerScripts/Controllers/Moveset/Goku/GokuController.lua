local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
local controller = Knit.CreateController({
	Name = "GokuController"
})
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
local currentCamera = workspace.CurrentCamera

function controller.KnitStart(_)
	local v4 = {
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.M1:FindFirstChild("Hit" .. p), humanoidRootPart, game.SoundService.Effect)
		end,
		KickHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.M1.Hit4, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SmallBump)
			end
		end,
		DownslamHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 0, 0))
			v2:PlaySound(sounds.Goku.M2DownslamHit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
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

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit3"), humanoidRootPart2, game.SoundService.Effect)
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

			v2:PlaySound(sounds.Itadori.Dismantle.FinishSlash, humanoidRootPart, game.SoundService.Effect)
			local position

			if typeof(p) == "Vector3" then
				position = p
			else
				position = p.HumanoidRootPart.Position
				v2:Flash(p, Color3.new(1, 1, 1))
				v2:PlaySound(sounds.Itadori.Dismantle.Slash, p.HumanoidRootPart, game.SoundService.Effect)
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

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
		end,
		CleaveHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)

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
			v2:PlaySound(sounds.Itadori.Dismantle.FinishSlash, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 10 do
				clone.Slashes:Emit(1)
				v2:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)
				BloodyZee:Blood(p.Torso.CFrame, 50, 180, 180)
				task.wait()
			end
		end,
		StartScream = function(instance)
			local head = instance:FindFirstChild("Head")

			if not head then
				return
			end

			local v5 = v2:PlaySound(sounds.Goku.MonkeyScream, head, game.SoundService.Effect)
			task.wait(0.8)
			TweenService:Create(v5, TweenInfo.new(1), {
				Volume = 0
			}):Play()
			task.wait(1)
			v5:Destroy()
		end,
		ChestBeat = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Goku.ChestBeat, humanoidRootPart, game.SoundService.Effect)
			local humanoidRootPart2 = localPlayer.Character:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			if humanoidRootPart == humanoidRootPart2 or (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude < 300 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Finisher = function(p)
			if not p.HumanoidRootPart then
				return
			end

			v2:Bleed(p)
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
		Chase = function(parent)
			local humanoidRootPart = parent.HumanoidRootPart

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
			v2:PlaySound(sounds.Misc.Chase, humanoidRootPart, game.SoundService.Effect)
			v2:DustTrail(parent, 0.4, CFrame.Angles(0, -1.5707963267948966, 0))
			local clone2 = utils.Goku.NimbusCloud:Clone()
			clone2.Parent = parent
			parent:SetAttribute("CloudEnabled", true)
			local cFrame2 = humanoidRootPart.CFrame * CFrame.new(0, 0, 20) * CFrame.Angles(0, 1.5707963267948966, 0)
			clone2.CFrame = cFrame2
			local lastTime = tick()

			repeat
				task.wait()
				clone2.CFrame = cFrame2:Lerp(
					humanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 1.5707963267948966, 0),
					(math.clamp((tick() - lastTime) / 0.1, 0, 1))
				)
			until tick() - lastTime > 0.1

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = { parent }

			repeat
				task.wait()
				local cFrame = currentCamera.CFrame

				if parent == localPlayer.Character and not workspace:Raycast(
					humanoidRootPart.Position,
					createVector(0, -4, 0),
					raycastParams
				) then
					humanoidRootPart.CFrame = CFrame.lookAlong(
						humanoidRootPart.Position,
						cFrame.LookVector,
						cFrame.UpVector
					)
				end

				clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -2, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
			until not parent:GetAttribute("CloudEnabled")
		end,
		StopCloud = function(instance)
			if not instance:GetAttribute("CloudEnabled") then
				return
			end

			instance:SetAttribute("CloudEnabled", nil)
			local nimbusCloud = instance:FindFirstChild("NimbusCloud")

			if not nimbusCloud then
				return
			end

			nimbusCloud.Trail.Enabled = false

			for _, part in nimbusCloud:GetChildren() do
				if part:IsA("BasePart") then
					TweenService:Create(part, TweenInfo.new(0.2), {
						Size = createVector(0, 0, 0)
					}):Play()
				end
			end

			task.wait(0.2)
			nimbusCloud:Destroy()
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
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
				v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, humanoidRootPart, game.SoundService.Effect)
				v2:DustBreak(humanoidRootPart.Position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)

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

			local v5 = v2:PlaySound(sounds.Itadori.FireArrow.Arrow, humanoidRootPart, game.SoundService.Effect)
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
			v2:PlaySound(sounds.Gojo.BlindsOff, torso, game.SoundService.Effect)
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
			v2:PlaySound(sounds.Gojo.BlindsOff, torso, game.SoundService.Effect)
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
		GokuVanish = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance2.Parent) then
				return
			end

			local vanish = utils.Goku.Vanish
			local attachment = vanish.Limb.Attachment
			local attachment2 = vanish.Head.Attachment
			local attachment3 = vanish.Torso.Attachment
			local attachment4 = vanish.Limb2.Attachment
			local attachment5 = vanish.Head2.Attachment
			local attachment6 = vanish.Torso2.Attachment

			-- equivalent calls inferred from this helper; original call sites unknown
			local function playParticles(attachment7, parent, p)
				local clone = attachment7:Clone()
				clone.Parent = parent
				clone.Vanish:Emit(1)
				Debris:AddItem(clone, p)
			end

			playParticles(attachment3, instance.Torso, 1) -- equivalent call inferred; original call site unknown
			playParticles(attachment2, instance.Head, 1) -- equivalent call inferred; original call site unknown
			playParticles(attachment, instance["Right Arm"], 1) -- equivalent call inferred; original call site unknown
			playParticles(attachment, instance["Left Arm"], 1) -- equivalent call inferred; original call site unknown
			playParticles(attachment, instance["Right Leg"], 1) -- equivalent call inferred; original call site unknown
			playParticles(attachment, instance["Left Leg"], 1) -- equivalent call inferred; original call site unknown
			v2:PlaySound(sounds.Goku.Vanish, humanoidRootPart, game.SoundService.Effect)
			instance2.AncestryChanged:Wait()
			v2:PlaySound(sounds.Goku.Appear, humanoidRootPart, game.SoundService.Effect)
			playParticles(attachment6, instance.Torso, 1) -- equivalent call inferred; original call site unknown
			playParticles(attachment5, instance.Head, 1) -- equivalent call inferred; original call site unknown
			playParticles(attachment4, instance["Right Arm"], 1) -- equivalent call inferred; original call site unknown
			playParticles(attachment4, instance["Left Arm"], 1) -- equivalent call inferred; original call site unknown
			playParticles(attachment4, instance["Right Leg"], 1) -- equivalent call inferred; original call site unknown
			playParticles(attachment4, instance["Left Leg"], 1) -- equivalent call inferred; original call site unknown
		end,
		Follow = function(instance, p, p2, p3)
			local cframe = CFrame.lookAlong(createVector(0, 0, 0), -p3)

			repeat
				task.wait()
				instance.Position = p2.Position + p3 * 3
				p.CFrame = cframe
			until not instance:GetAttribute("Track")
		end
	}
	v3.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetService("GokuService")
end

return controller