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
	Name = "FocusStrikeController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and p ~= 2) then
				return
			end

			local playSound = v2:PlaySound(sounds.Hakari.OverLuck.Charge, humanoidRootPart, game.SoundService.Effect)
			playSound.PlaybackSpeed = 1.5
		end,
		Chain = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Mahito.Variants.Transform3, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Mahito.Chainwhip.Chains, humanoidRootPart, game.SoundService.Effect)
			task.delay(0.4, function()
				v2:PlaySound(sounds.Mahito.Chainwhip.Swing, humanoidRootPart, game.SoundService.Effect)
			end)

			for _ = 1, 20 do
				local clone = utils.Mahito.Morph:Clone()
				clone.Weld.Part0 = instance["Right Arm"]
				clone.Color = instance["Right Arm"].Color
				clone.Weld.C1 = CFrame.new(
					math.random(-150, 150) / 100,
					math.random(200, 500) / 100,
					math.random(-150, 150) / 100
				)
				clone.Parent = workspace.Effects
				local v4 = math.random(6, 20) / 10
				clone.Size = createVector(1, 1, 1) * v4
				TweenService:Create(
					clone,
					TweenInfo.new(math.random(20, 40) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
				TweenService:Create(clone.Weld, TweenInfo.new(math.random(10, 40) / 100), {
					C1 = CFrame.new(0, -1, 0)
				}):Play()
				Debris:AddItem(clone, 0.4)
			end

			local clone = utils.Mahito.Whip:Clone()
			clone.Parent = workspace.Effects
			local v4 = {}
			local descendants = {}

			for _, descendant in clone:GetDescendants() do
				if (descendant.Name == "S1" or descendant.Name == "S2" or descendant.Name == "S3" or descendant.Name == "S4" or descendant.Name == "S5" or descendant.Name == "S6") and descendant:IsA("MeshPart") then
					descendant.CFrame = instance["Right Arm"].CFrame
					descendant.Massless = false
					table.insert(v4, Instance.new("BodyForce", descendant))
					descendant.CollisionGroup = "Effects"
					descendant.Size *= 1.5
				elseif descendant:IsA("RopeConstraint") then
					table.insert(descendants, descendant)
					local trail = Instance.new("Trail")
					trail.Attachment0 = descendant.Attachment0
					trail.Attachment1 = descendant.Attachment1
					trail.Brightness = 5
					trail.WidthScale = NumberSequence.new(1, 0)
					trail.Lifetime = 0.1
					trail.Transparency = NumberSequence.new(0.8, 1)
					trail.Parent = descendant
				end
			end

			Debris:AddItem(clone, 1.7)
			task.delay(1.5, function()
				v2:PlaySound(sounds.Mahito.Variants.Transform3, humanoidRootPart, game.SoundService.Effect)

				for _ = 1, 20 do
					local clone2 = utils.Mahito.Morph:Clone()
					clone2.Weld.Part0 = instance["Right Arm"]
					clone2.Color = instance["Right Arm"].Color
					clone2.Weld.C1 = CFrame.new(
						math.random(-150, 150) / 100,
						math.random(400, 800) / 100,
						math.random(-150, 150) / 100
					)
					clone2.Parent = workspace.Effects
					local v5 = math.random(6, 25) / 10
					clone2.Size = createVector(1, 1, 1) * v5
					TweenService:Create(
						clone2,
						TweenInfo.new(math.random(20, 40) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
					TweenService:Create(clone2.Weld, TweenInfo.new(math.random(10, 40) / 100), {
						C1 = CFrame.new(0, -1, 0)
					}):Play()
					Debris:AddItem(clone2, 0.4)
				end
			end)
			local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut)
			local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

			for _, v5 in descendants do
				TweenService:Create(v5, tweenInfo, {
					Length = 3.5
				}):Play()
			end

			task.delay(0.8, function()
				for _, v5 in descendants do
					local rodConstraint = Instance.new("RodConstraint")
					rodConstraint.Length = v5.CurrentDistance
					rodConstraint.Attachment0 = v5.Attachment0
					rodConstraint.Attachment1 = v5.Attachment1
					rodConstraint.Parent = v5.Parent
					v5.Enabled = false
					local v7 = v5
					task.delay(0.4, function()
						rodConstraint.Enabled = false
						v7.Enabled = true
						v7.Length = rodConstraint.Length
						TweenService:Create(v7, tweenInfo2, {
							Length = 0
						}):Play()
					end)
				end

				task.wait(0.4)

				for _, v5 in v4 do
					v5.Parent.CanCollide = false
				end
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if not (instance.Parent and clone.Parent) then
					steppedConnection:Disconnect()
					return
				end

				clone.CFrame = instance["Right Arm"].CFrame * CFrame.new(0, -0.5, 0)
				local v5 = -220 * (descendants[1].Length - 0.9)

				for k, v6 in v4 do
					v6.Force = instance["Right Arm"].CFrame.UpVector * v5

					if v6.Parent.CanCollide ~= false then
						continue
					end

					v6:Destroy()
					v4[k] = nil
				end
			end)
		end,
		Hit = function(_, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit1, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.FocusHit:Clone()
			clone.Parent = workspace.Effects
			clone.Position = humanoidRootPart.Position
			clone.Sparks:Emit(20)
			clone.Wind2:Emit(10)
			Debris:AddItem(clone, 0.6)
		end,
		BlackFlashHit = function(instance, instance2)
			local WAIT_INTERVAL = 0.04

			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			for _, part in instance2:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local clone = utils.Itadori.DivergentFist.FlashBurn:Clone()
				clone.Parent = part
				Debris:AddItem(clone, 1)
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashHit:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			v2:Flash(instance2, Color3.new(1, 0, 0))
			v2:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart, game.SoundService.Effect)
			clone.Wind2:Emit(8)
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			task.delay(0.1, function()
				clone.Blast:Emit(8)
				clone.Sparks:Emit(15)
				clone.Lightning:Emit(6)
				clone.Wind:Emit(7)
				v2:PlaySound(sounds.Mahito.BlackFlash, humanoidRootPart, game.SoundService.Effect)
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone2.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone2.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone2.Brightness = 200
				clone2.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone2:Destroy()
			end
		end,
		Finisher1 = function(instance, instance2)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.Sparks:Emit(20)
			clone.Flare:Emit(20)
			clone.Lightning:Emit(5)
			local clone2 = utils.Gojo.BlackFlashHit.Sparks2:Clone()
			clone2.SpreadAngle = Vector2.new(70, 70)
			clone2.Acceleration = createVector(0, 5, 50)
			clone2.LockedToPart = true
			clone2.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 6, 3),
				NumberSequenceKeypoint.new(1, 0, 0)
			})
			clone2.Parent = clone
			clone2:Emit(30)
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			Debris:AddItem(clone, 3)
			v2:PlaySound(sounds.Mahito.BlackFlash, humanoidRootPart2, game.SoundService.Effect)
			v2:Bleed(instance2)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone3 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone3.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone3.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone3.Brightness = 200
				clone3.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone3:Destroy()
			end
		end,
		Finisher = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.FocusHit.Burst:Clone()
			clone.Parent = humanoidRootPart
			task.delay(0.5, function()
				if not instance2.Parent then
					return
				end

				v2:PlaySound(sounds.Itadori.Rush.RushBreak, humanoidRootPart, game.SoundService.Effect)
				clone.Glow:Emit(1)
				task.wait(0.3)
				clone.Wind:Emit(10)
				clone.Wind2:Emit(10)
			end)

			for _, part in instance2:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				for _ = 1, 2 do
					local clone2 = utils.Mahito.Morph:Clone()
					clone2.Weld.Part0 = part
					clone2.Color = part.Color
					clone2.Material = part.Material
					clone2.Weld.C1 = CFrame.new(
						math.random(-part.Size.X, part.Size.X) / 2,
						math.random(-part.Size.Y, part.Size.Y) / 2,
						math.random(-part.Size.Z, part.Size.Z) / 2
					)
					clone2.Parent = workspace.Effects
					local v4 = math.random(20, 30) / 10
					clone2.Size = createVector(0, 0, 0)
					TweenService:Create(clone2, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {
						Size = createVector(1, 1, 1) * v4
					}):Play()
					Debris:AddItem(clone2, 1.5)
					task.delay(0.8, function()
						clone2.Weld:Destroy()
						clone2.Velocity = Vector3.new(math.random(-40, 40), math.random(-20, 40), math.random(-40, 40))
						TweenService:Create(clone2, TweenInfo.new(0.5), {
							Size = createVector(0, 0, 0)
						}):Play()
					end)
				end
			end

			task.delay(0.8, function()
				if not instance2.Parent then
					return
				end

				local v4 = v2:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)
				v4.RollOffMaxDistance = 400
				v4.RollOffMinDistance = 100
				v2:Bleed(instance2)

				if localPlayer.Character == instance or localPlayer.Character == instance2 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end
			end)
		end,
		ChainHit = function(_, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Mahito.Chainwhip.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
			local clone2 = utils.Mahito.FocusHit:Clone()
			clone2.Parent = workspace.Effects
			clone2.Position = humanoidRootPart.Position
			clone2.Sparks:Emit(20)
			clone2.Wind2:Emit(10)
			Debris:AddItem(clone2, 0.6)
		end,
		BigClub = function(parent)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Mahito.Variants.Transform2, humanoidRootPart, game.SoundService.Effect)
			task.delay(0.4, function()
				v2:PlaySound(sounds.Mahito.ForceGrab.Swing, humanoidRootPart, game.SoundService.Effect)
			end)

			for _ = 1, 20 do
				local clone = utils.Mahito.Morph:Clone()
				clone.Weld.Part0 = parent["Right Arm"]
				clone.Color = parent["Right Arm"].Color
				clone.Weld.C1 = CFrame.new(
					math.random(-200, 200) / 100,
					math.random(200, 500) / 100,
					math.random(-200, 200) / 100
				)
				clone.Parent = workspace.Effects
				local v4 = math.random(6, 20) / 10
				clone.Size = createVector(1, 1, 1) * v4
				TweenService:Create(
					clone,
					TweenInfo.new(math.random(20, 40) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
				TweenService:Create(clone.Weld, TweenInfo.new(math.random(10, 40) / 100), {
					C1 = CFrame.new(0, -1, 0)
				}):Play()
				Debris:AddItem(clone, 0.4)
			end

			local clone = utils.Mahito.BigClub:Clone()
			clone.Parent = parent

			for _, part in pairs(clone:GetChildren()) do
				if part:IsA("BasePart") then
					part.Color = parent["Right Arm"].Color
				end
			end

			clone.Weld.Part0 = parent["Right Arm"]
			Debris:AddItem(clone, 1.9)
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
	v = Knit.GetService("FocusStrikeService")
	v2 = Knit.GetController("FXController")
end

return controller