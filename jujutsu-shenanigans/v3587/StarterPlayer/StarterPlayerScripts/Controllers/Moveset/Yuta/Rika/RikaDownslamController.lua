local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "RikaDownslamController"
})

function controller.KnitStart(_)
	local v3 = {
		RikaHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Yuta.M1.Hit4, humanoidRootPart, game.SoundService.Effect)
		end,
		RikaFloorHit = function(position, p)
			if typeof(position) ~= "Vector3" then
				local humanoidRootPart = position:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					return
				end

				v2:Flash(position, Color3.new(1, 1, 1))
				v2:PlaySound(sounds.Yuta.M1.Hit4, humanoidRootPart, game.SoundService.Effect)
				position = humanoidRootPart.Position
			end

			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.PointLight:Destroy()
			clone.Beam:Destroy()

			if p then
				clone.CFrame = CFrame.lookAlong(position, p) * CFrame.Angles(1.5707963267948966, 0, 0)
			else
				clone.Position = position
			end

			clone.Parent = workspace.Effects
			clone.Floor.Wind2.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Floor.Ring:Emit(10)
			clone.Floor.Wind2:Emit(8)
			Debris:AddItem(clone, 1.5)
			v2:PlaySound(sounds.Yuta.VeilstepHit, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude <= 50 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		RikaGrab = function(p, instance)
			local playSound = v2:PlaySound(sounds.Yuta.VeilstepJump, p, game.SoundService.Effect)
			playSound.TimePosition = 0.2
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuta.Rika.Grab, humanoidRootPart, game.SoundService.Effect)
		end,
		StartFly = function(p)
			v2:PlaySound(sounds.Yuta.Rika.StartFly, p, game.SoundService.Effect)
		end,
		DownslamFinisher = function(folder)
			local humanoidRootPart = folder.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local position = humanoidRootPart.Position
			local cframe = CFrame.lookAlong(position, createVector(0, 1, 0))

			for _ = 1, 8 do
				BloodyZee:Blood(cframe, 30, 20, 20)
			end

			local v4 = v2:PlaySound(sounds.Yuta.VeilstepHit, humanoidRootPart, game.SoundService.Effect)
			v4.Volume *= 1.5
			v2:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)

			for _, descendant in folder:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					descendant.Transparency = 1
				end
			end

			for _, part in folder:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				for _ = 1, 2 do
					local clone = utils.Damage.Chunk:Clone()
					clone.CFrame = part.CFrame
					clone.Velocity = Vector3.new(math.random(-80, 80), math.random(-80, 80), math.random(-80, 80))
					clone.RotVelocity = Vector3.new(
						math.random(-200, 200),
						math.random(-200, 200),
						math.random(-200, 200)
					)
					clone.Parent = workspace.Effects
					Debris:AddItem(clone, 1)

					if _G.Settings.Gore ~= false then
						continue
					end

					clone.Color = Color3.fromRGB(255, 85, 255)
					clone.Trail.Color = ColorSequence.new(Color3.fromRGB(255, 85, 255))
					clone.Blood.Color = clone.Trail.Color
				end
			end
		end
	}
	RikaDownslamService.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	RikaDownslamService = Knit.GetService("RikaDownslamService")
	v = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller