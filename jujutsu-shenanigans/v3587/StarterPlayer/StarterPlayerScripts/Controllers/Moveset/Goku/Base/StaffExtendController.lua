local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.BloodyZee)
local controller = Knit.CreateController({
	Name = "StaffExtendController"
})
local v = nil
local v2 = nil
local _ = workspace.CurrentCamera

function controller.KnitStart(_)
	local v3 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:PlaySound(sounds.Goku.StaffExtend.Swing, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.Transparency = 0.75
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.15, -0.25, -1)
			clone.Size = createVector(2, 2, 0)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Position = clone.Position + humanoidRootPart.CFrame.LookVector * 7,
				Size = createVector(0, 0, 5),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.2)
			local clone2 = utils.Gojo.LapseBlue.Throw:Clone()
			clone2.Transparency = 0.65
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(-0.15, -0.25, -8)
			clone2.Size = createVector(0, 0, 2.5)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.15), {
				Position = clone2.Position + humanoidRootPart.CFrame.LookVector * -2.5,
				Size = createVector(2.25, 2.25, 0.4),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.15)
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:Flash(instance, Color3.new(1, 1, 1))
			v:PlaySound(sounds.Goku.StaffExtend.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		UpriseExtend = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local raycastResult = workspace:Raycast(
				(humanoidRootPart.CFrame * CFrame.new(-0.219, 0, -1.245)).Position,
				createVector(0, -75, 0),
				_G.MapParams
			)
			local gokuStick = raycastResult and instance.SetAssets:FindFirstChild("GokuStick")

			if gokuStick then
				gokuStick.Uprise.Uprise.Enabled = false
				task.wait()
				gokuStick.Uprise.Anchored = true

				if raycastResult.Distance < 10 then
					gokuStick.Uprise.CFrame = CFrame.new(raycastResult.Position)
				else
					TweenService:Create(gokuStick.Uprise, TweenInfo.new(0.2), {
						CFrame = CFrame.new(raycastResult.Position)
					}):Play()
				end
			end
		end,
		UpriseEnd = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local gokuStick = instance.SetAssets:FindFirstChild("GokuStick")

			if gokuStick then
				gokuStick.Uprise.Anchored = false
				task.wait()
				gokuStick.Uprise.Uprise.Enabled = true
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
				v:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, humanoidRootPart, game.SoundService.Effect)
				v:DustBreak(humanoidRootPart.Position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)

				if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 20 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end
		end
	}
	v2.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	v2 = Knit.GetService("StaffExtendService")
	v = Knit.GetController("FXController")
end

return controller