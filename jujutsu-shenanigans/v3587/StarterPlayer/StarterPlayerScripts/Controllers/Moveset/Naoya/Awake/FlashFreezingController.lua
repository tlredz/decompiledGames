local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "FlashFreezingController"
})

function controller.KnitStart(_)
	local v3 = {
		Frame = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			instance.Torso.Transparency = 0
			TweenService:Create(instance.Torso, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 0.5
			}):Play()
			v2:PlaySound(sounds.Naoya.Frame, humanoidRootPart, game.SoundService.Effect)
		end,
		Explode = function(position)
			local clone = utils.Naoya.NaoyaGlass:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)
			clone.Transparency = 1
			clone.Part.Transparency = 1
			clone.Front.Transparency = 1
			clone.Back.Transparency = 1
			clone.Attachment.Flash:Emit(1)
			clone.Attachment.Wind:Emit(2)
			clone.Attachment.WindCircle:Emit(2)
			clone.Attachment.Shockwave:Emit(2)
			clone.Shatter:Emit(10)
			local v4 = v2:PlaySound(sounds.Naoya.FrameBreak, clone, game.SoundService.Effect)
			v4.Volume = 0.5
			v4.PlaybackSpeed = math.random(100, 150) / 100

			if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude < 40 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			if _G.Settings.DesPHY then
				if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude > 100 then
					return
				end

				task.wait(0.1)
				local random = Random.new()
				local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

				for _ = 1, 2 do
					local clone2 = utils.Gojo.Shard:Clone()
					local unit = random:NextUnitVector().Unit
					clone2.Size = Vector3.new(0.2, math.random(5, 20) / 10, math.random(5, 20) / 10)
					clone2.CFrame = clone.CFrame * CFrame.new(math.random(-2, 2), math.random(-4, 4), 0)
					clone2.CFrame *= CFrame.Angles(0, math.random(0, 3.141592653589793), 0)
					clone2.CanCollide = true
					clone2.CollisionGroup = "Effects"
					clone2.Parent = workspace.Effects
					clone2.Transparency = 0.5
					clone2.Color = clone.Color
					clone2.Material = Enum.Material.Neon
					clone2.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					clone2.Velocity = unit * math.random(50, 100)
					TweenService:Create(clone2, tweenInfo, {
						Size = createVector(0, 0, 0)
					}):Play()
					Debris:AddItem(clone2, 3)
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
	v = Knit.GetService("FlashFreezingService")
	v2 = Knit.GetController("FXController")
end

return controller