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
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "PiercingBloodController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Choso.PiercingBlood.Startup, humanoidRootPart, game.SoundService.Effect)
		end,
		Clap = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Choso.PiercingBlood.Clap, humanoidRootPart, game.SoundService.Effect)
		end,
		Blood = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Choso.PiercingBlood:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)

			if p then
				clone.Start.Blood.Speed = NumberRange.new(10, 400)
			end

			v2:PlaySound(sounds.Choso.PiercingBlood.Fire, humanoidRootPart, game.SoundService.Effect)
			clone.Start.Blood:Emit(30)
			clone.Start.Burst:Emit(8)
			TweenService:Create(clone.End, TweenInfo.new(0.1), {
				Position = Vector3.new(0, 0, -(p and 60 or 30))
			}):Play()
			TweenService:Create(clone.Beam, TweenInfo.new(0.3), {
				Width0 = 0,
				Width1 = 0
			}):Play()
			Debris:AddItem(clone.Beam, 0.3)
			local model = Instance.new("Model")
			local clone2 = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone2.CFrame = clone.CFrame * CFrame.new(0, -1, 0)
			clone2.Parent = model
			model.Parent = workspace.Effects
			model:ScaleTo(0.6)
			clone2.Ring:Emit(7)
			clone2.Dash1.Dash:Emit(1)
			clone2.Dash2.Dash:Emit(1)
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Quad), {
				CFrame = clone2.CFrame - clone2.CFrame.LookVector * 16
			}):Play()
			Debris:AddItem(model, 2)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			for i = 1, 4 do
				local clone3 = utils.Itadori.Shock:Clone()
				clone3.CFrame = clone.CFrame * CFrame.Angles(1.5707963267948966, 0, 0) + clone.CFrame.LookVector * ((p and 14 or 7) * i)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.15), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone3, 0.15)
				task.wait(0.02)
			end
		end,
		Hold = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v2:Flash(instance, Color3.fromRGB(255, 0, 0), 1)
			local clone = utils.Choso.Concentrate:Clone()
			clone.Parent = instance["Right Arm"].RightGripAttachment
			instance2.Destroying:Connect(function()
				clone:Destroy()
			end)
		end,
		Flash = function(self)
			local humanoidRootPart = self:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Choso.Flash:Clone()
			Debris:AddItem(clone, 0.4)
			clone.Parent = self["Right Arm"].RightGripAttachment
			clone:Emit(15)
			TweenService:Create(clone, TweenInfo.new(0.3), {
				TimeScale = 0.4
			}):Play()
			v2:PlaySound(sounds.Choso.PiercingBlood.Pressure, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 0, 0))
			v2:PlaySound(sounds.Choso.PiercingBlood.Hit, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("PiercingBloodService")
	v2 = Knit.GetController("FXController")
end

return controller