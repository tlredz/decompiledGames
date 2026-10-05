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
	Name = "StockpileController"
})

function controller.KnitStart(_)
	local v3 = {
		Create = function(self, instance2, instance3)
			local humanoidRootPart = self:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Mahito.Stockpile.Create, humanoidRootPart, game.SoundService.Effect)

			local function morph(part)
				TweenService:Create(part, TweenInfo.new(0.2), {
					Transparency = 0
				}):Play()

				for _ = 1, 10 do
					local clone = utils.Mahito.Morph:Clone()
					clone.Weld.Part0 = part
					clone.Color = part.Color
					clone.Material = part.Material
					clone.Weld.C1 = CFrame.new(
						math.random(-part.Size.X, part.Size.X) / 2,
						math.random(-part.Size.Y, part.Size.Y) / 2,
						math.random(-part.Size.Z, part.Size.Z) / 2
					)
					clone.Parent = workspace.Effects
					local v4 = math.random(15, 35) / 10
					clone.Size = createVector(1, 1, 1) * v4
					TweenService:Create(
						clone,
						TweenInfo.new(math.random(10, 40) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
					Debris:AddItem(clone, 0.4)
				end
			end

			instance2.Transparency = 1
			instance2.Head.Transparency = 1
			instance3.Transparency = 1
			instance3.Head.Transparency = 1
			morph(instance2)
			morph(instance3)
			task.delay(0.2, function()
				morph(instance2.Head)
				morph(instance3.Head)
			end)
			instance2.Destroying:Connect(function()
				local clone = instance2:Clone()
				clone.CanCollide = true
				clone.Weld:Destroy()
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 2)
			end)
			instance3.Destroying:Connect(function()
				if instance2 == instance3 then
					return
				end

				local clone = instance3:Clone()
				clone.CanCollide = true
				clone.Weld:Destroy()
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 2)
			end)
		end,
		Swing = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p then
				v2:PlaySound(sounds.Mahito.Stockpile.Swing, humanoidRootPart, game.SoundService.Effect)
			else
				v2:PlaySound(sounds.Mahito.Stockpile.Swing2, humanoidRootPart, game.SoundService.Effect)
			end
		end,
		Hit = function(_, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit1, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
		end,
		FinalHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			clone.TimeScale = 0.4
			Debris:AddItem(clone, 1)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Crush = function(p, position)
			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			TweenService:Create(clone.Air, TweenInfo.new(0.2), {
				Position = createVector(0, 0, 0)
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			clone.Floor.Wind2.Color = ColorSequence.new(Color3.new(1, 0, 1))
			clone.Floor.Sparks.Color = ColorSequence.new(Color3.new(1, 0, 1))
			clone.PointLight.Color = Color3.new(1, 0, 1)
			clone.Floor.Ring:Emit(10)
			clone.Floor.Sparks:Emit(10)
			clone.Floor.Wind2:Emit(8)
			Debris:AddItem(clone, 1.5)
			v2:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)

			if localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Finisher = function(_, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.Dismantle.Explode, instance, game.SoundService.Effect)
			v2:PlaySound(sounds.Megumi.Elephant.Explode, humanoidRootPart, game.SoundService.Effect)
			instance.Head.Transparency = 1
			local decal = instance.Head:FindFirstChildWhichIsA("Decal")

			if decal then
				decal.Transparency = 1
			end

			for _, accessory in instance:GetChildren() do
				if not accessory:IsA("Accessory") then
					continue
				end

				local handle = accessory:FindFirstChild("Handle", true)

				if not (handle:FindFirstChild("HairAttachment") or handle:FindFirstChild("HatAttachment") or handle:FindFirstChild("FaceCenterAttachment") or handle:FindFirstChild("FaceFrontAttachment") or handle:FindFirstChild("NeckAttachment")) then
					continue
				end

				accessory:Destroy()
			end

			v2:Bleed(instance)

			for _ = 1, 40 do
				BloodyZee:Blood(instance.Head.CFrame, 50, 360, 360)
			end

			if _G.Settings.Gore then
				local clone = utils.Heian.BloodSpread:Clone()
				clone.Parent = instance.Head
				clone:Emit(20)
				Debris:AddItem(clone, 2)
			end

			local v4 = {
				"Torso",
				"Left Arm",
				"Right Arm",
				"Left Leg",
				"Right Leg",
				"Head"
			}

			for _, child in pairs(instance:GetChildren()) do
				if not table.find(v4, child.Name) then
					continue
				end

				if child.Name == "Head" then
					child.Mesh.Scale *= createVector(1, 1, 0.05)
				else
					child.Size *= createVector(1, 1, 0.05)
				end
			end

			if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 40 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
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
	v = Knit.GetService("StockpileService")
	v2 = Knit.GetController("FXController")
end

return controller