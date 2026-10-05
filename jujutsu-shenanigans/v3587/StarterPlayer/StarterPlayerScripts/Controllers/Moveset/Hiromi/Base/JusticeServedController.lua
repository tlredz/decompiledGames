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
local controller = Knit.CreateController({
	Name = "JusticeServedController"
})

function controller.KnitStart(_)
	local v3 = {
		Expand = function(instance, part, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Hiromi.GavelExpand:Clone()
			clone.Weld.Part0 = part
			clone.Parent = part.Extensions

			if not p2 then
				local clone2 = utils.Hiromi.CombatTrail:Clone()
				clone2.Weld.Part0 = clone.Core
				clone2.Weld.C1 = CFrame.new(0, 0, 0)
				clone2.Parent = clone
				clone2.Transparency = 1
				clone2.Trail.Enabled = false
				task.delay(0.2, function()
					TweenService:Create(clone2, TweenInfo.new(0.2), {
						Transparency = 0.5
					}):Play()
					clone2.Trail.Enabled = true
					task.wait(0.4)
					clone2.Trail.Enabled = false
					TweenService:Create(clone2, TweenInfo.new(0.3), {
						Transparency = 1
					}):Play()
				end)
			end

			for i = 1, 20 do
				task.delay(i * 0.0375, function()
					clone:ScaleTo((math.lerp(clone:GetScale(), 4.75, 0.2)))
				end)
			end

			task.wait(0.3)
			v2:PlaySound(sounds.Hiromi.HeavySwing, humanoidRootPart, game.SoundService.Effect)
			local now = tick()

			while true do
				local now2 = tick()

				if now + 0.05 < now2 and p2 then
					local clone2 = utils.Itadori.Shock:Clone()
					clone2.CFrame = part.CFrame
					clone2.Transparency = 0.3
					clone2.Parent = workspace.Effects
					TweenService:Create(clone2, TweenInfo.new(0.15), {
						Size = createVector(20, 0, 20),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone2, 0.15)
					now = tick()
				end

				task.wait()

				if p and p.Parent then
					continue
				end

				for i = 1, 20 do
					task.delay(i * 0.015, function()
						clone:ScaleTo((math.lerp(clone:GetScale(), 0.5, 0.15)))
					end)
				end

				Debris:AddItem(clone, 0.3)
				break
			end
		end,
		Crush = function(p, position, p2)
			local clone = utils.Hiromi.Shockwave:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.CFrame *= CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
			TweenService:Create(clone.mesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Scale = createVector(15, 0, 15)
			}):Play()
			TweenService:Create(clone.mesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			clone.Floor.Glow:Emit(1)
			clone.Floor.Ring:Emit(10)
			Debris:AddItem(clone, 1.5)
			local clone2 = utils.Choso.CounterSwing.Shock:Clone()
			clone2.Size = createVector(10, 30, 10)
			clone2.CFrame = CFrame.new(position)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.3)
			TweenService:Create(clone2, TweenInfo.new(0.3), {
				Size = createVector(36, 7, 36),
				Transparency = 1,
				Position = clone2.Position - createVector(0, 3, 0)
			}):Play()
			local clone3 = utils.Choso.CounterSwing.Shock:Clone()
			clone3.Size = createVector(20, 10, 20)
			clone3.CFrame = CFrame.new(position)
			clone3.Parent = workspace.Effects
			Debris:AddItem(clone3, 0.2)
			TweenService:Create(clone3, TweenInfo.new(0.2), {
				Size = createVector(0, 36, 0),
				Transparency = 1,
				Position = clone3.Position + createVector(0, 10, 0)
			}):Play()
			v2:DustBreak(position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)
			v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, clone, game.SoundService.Effect)
			v2:PlaySound(sounds.Hakari.Impact, clone, game.SoundService.Effect)

			if p2 and localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Megumi.Elephant.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		FinalHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Megumi.Elephant.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Jump = function(p, p2, p3)
			local humanoidRootPart = p2.Parent.Parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v4 = p3 * 5

			if localPlayer.Character == humanoidRootPart.Parent then
				local v5 = v4 - createVector(0, 1.5, 0)
				TweenService:Create(p2, TweenInfo.new(0.5), {
					P = 50000
				}):Play()

				repeat
					p2.Position = p.Position - v5
					humanoidRootPart.CFrame = CFrame.lookAlong(humanoidRootPart.Position, v5)
					task.wait()
				until not (p2.Parent and p)
			else
				repeat
					local v5 = CFrame.lookAlong(p.Position, v4) - v4
					humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(v5, 0.075)
					task.wait()
				until not (p2.Parent and p)
			end
		end,
		Finisher = function(p, folder)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and folder.Parent) then
				return
			end

			local v4

			if folder.Torso.Transparency == 0 and folder.Head.Transparency == 1 then
				v4 = not folder:GetAttribute("Woah")
			else
				v4 = false
			end

			v2:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Megumi.Elephant.Explode, humanoidRootPart, game.SoundService.Effect)

			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					descendant.Transparency = 1
				end
			end

			for _ = 1, 50 do
				BloodyZee:Blood(humanoidRootPart.CFrame, 200, 360, 360)
			end

			if _G.Settings.Gore then
				local clone = utils.Heian.BloodSpread:Clone()
				clone.Parent = folder.Head
				clone:Emit(20)
				Debris:AddItem(clone, 2)
			end

			for _ = 1, 20 do
				local clone = utils.Damage.Chunk:Clone()
				clone.CFrame = humanoidRootPart.CFrame
				clone.CollisionGroup = "Effects"
				clone.Velocity = Vector3.new(math.random(-90, 90), math.random(20, 50), math.random(-90, 90))
				clone.RotVelocity = Vector3.new(math.random(-200, 200), math.random(-200, 200), math.random(-200, 200))
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 3)
				task.delay(0.1, function()
					clone.CanCollide = true
					task.wait(1.9)
					TweenService:Create(clone, TweenInfo.new(1), {
						Size = createVector(0, 0, 0)
					}):Play()
					clone.Blood.Enabled = false
					clone.Trail.Enabled = false
				end)

				if _G.Settings.Gore ~= false then
					continue
				end

				clone.Color = Color3.fromRGB(255, 85, 255)
				clone.Trail.Color = ColorSequence.new(Color3.fromRGB(255, 85, 255))
				clone.Blood.Color = clone.Trail.Color
			end

			if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 40 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			folder:SetAttribute("Woah", true)

			if v4 and (localPlayer.Character == folder or localPlayer == p) then
				v2:PlaySound(sounds.Todo.Boom, workspace, game.SoundService.Effect)
				local clone = utils.Todo.Woah:Clone()
				clone.ImageLabel.Image = "rbxassetid://16726446989"
				clone.Parent = localPlayer.PlayerGui
				Debris:AddItem(clone, 1)
				TweenService:Create(clone.ImageLabel, TweenInfo.new(1), {
					ImageTransparency = 1
				}):Play()
			end
		end,
		BangEmoteFinisher = function(folder, p)
			local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Megumi.Elephant.Explode, humanoidRootPart, game.SoundService.Effect)
			local v4 = { "Torso", "Left Arm", "Right Arm" }

			for _, accessory in pairs(folder:GetDescendants()) do
				if table.find(v4, accessory.Name) then
					accessory.Transparency = 1
				end

				if not accessory:IsA("Accessory") then
					continue
				end

				local handle = accessory:FindFirstChild("Handle")
				local attachment = handle and handle:FindFirstChildOfClass("Attachment")

				if not attachment then
					continue
				end

				for _, v6 in pairs({
					"Neck",
					"Back",
					"Front",
					"Shoulder",
					"Waist"
				}) do
					if not string.find(attachment.Name, v6) then
						continue
					end

					v6:Destroy()
					break
				end
			end

			for _ = 1, 50 do
				BloodyZee:Blood(CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + p), 200, 40, 40)
			end

			if _G.Settings.Gore then
				local clone = utils.Heian.BloodSpread:Clone()
				clone.Parent = folder.Head
				clone:Emit(20)
				Debris:AddItem(clone, 2)
			end

			for _ = 1, 20 do
				local clone = utils.Damage.Chunk:Clone()
				clone.CFrame = humanoidRootPart.CFrame
				clone.CollisionGroup = "Effects"
				clone.Velocity = p * 10 + Vector3.new(math.random(-5, 5), math.random(5, 15), math.random(-5, 5))
				clone.RotVelocity = Vector3.new(math.random(-200, 200), math.random(-200, 200), math.random(-200, 200))
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 3)
				task.delay(0.1, function()
					clone.CanCollide = true
					task.wait(1.9)
					TweenService:Create(clone, TweenInfo.new(1), {
						Size = createVector(0, 0, 0)
					}):Play()
					clone.Blood.Enabled = false
					clone.Trail.Enabled = false
				end)

				if _G.Settings.Gore ~= false then
					continue
				end

				clone.Color = Color3.fromRGB(255, 85, 255)
				clone.Trail.Color = ColorSequence.new(Color3.fromRGB(255, 85, 255))
				clone.Blood.Color = clone.Trail.Color
			end

			if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 40 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Hyah = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.MeiMei.UpdraftSlash, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Ryu.Slash:Clone()
			clone:ScaleTo(1.7)
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = CFrame.Angles(0, 0, 0.6108652381980153)
			clone.Weld.C1 = CFrame.Angles(0, -1.5707963267948966, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.15)
			local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tweenInfo2 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(clone.Weld, tweenInfo, {
				C1 = clone.Weld.C1 * CFrame.Angles(0, -1.7453292519943295, 0)
			}):Play()

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("Decal") then
					descendant.Color3 = Color3.fromRGB(455, 255, 127)
					TweenService:Create(descendant, tweenInfo2, {
						Transparency = 1
					}):Play()
				elseif descendant:IsA("SpecialMesh") then
					TweenService:Create(descendant, tweenInfo, {
						Scale = descendant.Scale * 1.2
					}):Play()
				end
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
	v = Knit.GetService("JusticeServedService")
	v2 = Knit.GetController("FXController")
end

return controller