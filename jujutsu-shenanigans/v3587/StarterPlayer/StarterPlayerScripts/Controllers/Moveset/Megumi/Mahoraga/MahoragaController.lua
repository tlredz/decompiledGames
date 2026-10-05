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
	Name = "MahoragaController"
})
local v4 = {
	{ "7485051715", Color3.fromRGB(255, 0, 0) },
	{ "7461510428", Color3.fromRGB(0, 255, 0) },
	{ "2698713530", Color3.fromRGB(0, 0, 255) }
}

function controller.KnitStart(_)
	local v5 = {
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(
				sounds.Megumi.Mahoraga.M1:FindFirstChild("Hit" .. p),
				humanoidRootPart,
				game.SoundService.Effect
			)
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
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
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
		Wheel = function(folder)
			for _, image in folder:GetDescendants() do
				if not image:IsA("ImageLabel") then
					continue
				end

				folder.UIScale.Scale = _G.Settings.UIS
				TweenService:Create(image, TweenInfo.new(1), {
					ImageTransparency = 0
				}):Play()
			end
		end,
		Wheel2 = function(p)
			local adaptation = localPlayer.PlayerGui:FindFirstChild("Adaptation").Adaptation

			if not adaptation then
				return
			end

			adaptation.Type.Image = "rbxassetid://" .. v4[p][1]
			adaptation.Type.ImageColor3 = v4[p][2]
		end,
		Wheel3 = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local outfit = instance:FindFirstChild("Outfit")

			if outfit then
				v3:PlaySound(sounds.Megumi.Mahoraga.Adapt, humanoidRootPart, game.SoundService.Effect)
				local divineWheelWeld = outfit.Head.DivineWheelWeld
				divineWheelWeld.C1 = CFrame.new() * CFrame.Angles(0, -90, 0)
				TweenService:Create(divineWheelWeld, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
					C1 = CFrame.new()
				}):Play()
				local divineWheel = outfit.Head.DivineWheel
				divineWheel.Color = v4[p][2]
				TweenService:Create(divineWheel, TweenInfo.new(0.4), {
					Color = Color3.fromRGB(188, 155, 93)
				}):Play()
			end

			if localPlayer.Character == instance then
				local adaptation = localPlayer.PlayerGui:FindFirstChild("Adaptation").Adaptation

				if not adaptation then
					return
				end

				adaptation.WheelBG.ImageColor3 = v4[p][2]
				adaptation.Wheel.Rotation = -90
				adaptation.WheelBG.Rotation = -90
				TweenService:Create(adaptation.Wheel, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
					Rotation = 0
				}):Play()
				TweenService:Create(adaptation.WheelBG, TweenInfo.new(1, Enum.EasingStyle.Elastic), {
					Rotation = 0
				}):Play()
			end
		end,
		ParryStart = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Misc.Swing.Fist2, humanoidRootPart, game.SoundService.Effect)
		end,
		Parry = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Megumi.Mahoraga.Parry:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Highlight.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			clone.Attachment.Ring:Emit(3)
			clone.Attachment.Star:Emit(1)
			clone.Attachment.Sparks:Emit(10)
			Debris:AddItem(clone, 0.4)
			sounds.Megumi.Mahoraga.Parry.Pitch = math.random(80, 120) / 100
			v3:PlaySound(sounds.Megumi.Mahoraga.Parry, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Parry2 = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local highlight = Instance.new("Highlight", instance)
			highlight.FillTransparency = 0
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.FillColor = Color3.fromRGB(255, 0, 0)
			TweenService:Create(highlight, TweenInfo.new(0.4), {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
			Debris:AddItem(highlight, 0.4)
			local clone = utils.Megumi.Mahoraga.Parry:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, -2)
			clone.Parent = workspace.Effects
			local highlight2 = Instance.new("Highlight", clone)
			highlight2.FillTransparency = 1
			highlight2.OutlineTransparency = 1
			Debris:AddItem(highlight2, 0.1)
			TweenService:Create(clone, TweenInfo.new(0.1), {
				Size = createVector(40, 40, 40),
				Transparency = 1
			}):Play()
			clone.Scream.Dust:Emit(10)
			clone.Scream.Ring:Emit(10)
			clone.Scream.Sparks:Emit(15)
			Debris:AddItem(clone, 1)
			v3:PlaySound(sounds.Megumi.Mahoraga.Parry2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
	v.Hitbox:Connect(function(instance, p, object)
		local humanoidRootPart = p.HumanoidRootPart

		if not humanoidRootPart then
			return
		end

		local v6 = nil

		while true do
			local sphereHitbox = v2:SphereHitbox(p, CFrame.new(0, 0, -6), 12)

			for _, v8 in sphereHitbox do
				local info = v8:FindFirstChild("Info")

				if not info then
					continue
				end

				local knockback = info:FindFirstChild("Knockback")

				if not (not knockback or knockback.Value ~= false) then
					continue
				end

				v6 = sphereHitbox
				break
			end

			if v6 then
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

			object:FireServer(v6, humanoidRootPart.CFrame)
			break
		end
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("MahoragaService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller