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
local LightningBeams = require(replicatedStorage.Modules.LightningBeams)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "KamutokeController"
})

function controller.KnitStart(_)
	local v3 = {
		Kamutoke = function(instance, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Heian.Kamutoke:Clone()
			clone.Handle.Weld.Part0 = instance["Right Arm"]
			clone.Parent = parent
			v2:PlaySound(sounds.Heian.Kamutoke.Equip, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Heian.Kamutoke.Equip2, humanoidRootPart, game.SoundService.Effect)
		end,
		Strike = function(position)
			local clone = utils.Mahito.WideSPStrike.HitArea:Clone()
			clone.Size = createVector(19, 0, 19)
			clone.Overlay.Color3 = Color3.new(1, 0, 0)
			clone.Prog.Overlay.Color3 = Color3.new(1, 0, 0)
			clone.Afterimages.Enabled = false
			clone.groundwaveing.Spin.Enabled = false
			clone.Position = position
			clone.Prog.Position = position
			clone.Prog.Overlay.Transparency = 1
			clone.Parent = workspace.Effects
			TweenService:Create(clone.Prog.Overlay, TweenInfo.new(0.4), {
				Transparency = 0.8
			}):Play()
			TweenService:Create(clone.Prog, TweenInfo.new(0.7, Enum.EasingStyle.Linear), {
				Size = clone.Size
			}):Play()
			Debris:AddItem(clone, 3)
			task.wait(0.7)
			clone.Prog:Destroy()
			local clone2 = utils.Heian.Lightning:Clone()
			clone2.Position = position
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 2)
			clone2.Attachment.Dust:Emit(25)
			clone2.Attachment.Ring:Emit(25)
			clone2.Attachment.Wind2:Emit(6)
			local v4 = LightningBeams.new(clone2.Air, clone2.Attachment)
			v4.PulseSpeed = 1000
			v4.FadeLength = 0.25
			v4.MaxRadius = 20
			v4.MinRadius = 0
			v4.AnimationSpeed = 300
			v4.MinThicknessMultiplier = 2
			v4.MaxThicknessMultiplier = 10
			v4.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 127))
			})
			task.delay(0.05, function()
				local raycastResult = workspace:Raycast(position, createVector(0, -20, 0), _G.MapParams)

				if raycastResult then
					clone2.Attachment.WorldPosition = raycastResult.Position
				end

				task.wait(0.1)
				v4:Destroy()
				clone2.Attachment.Burn:Emit(1)
				clone2.Sparks.Enabled = false
				TweenService:Create(clone2.PointLight, TweenInfo.new(0.5), {
					Brightness = 0
				}):Play()
			end)
			v2:PlaySound(sounds.Heian.Kamutoke.Fire[tostring(math.random(1, 4))], clone2, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 40 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			elseif (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 100 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			elseif (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 200 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Finisher = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			v2:Burn(p)
			v2:PlaySound(sounds.Gojo.HollowPurple.Hit, humanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("KamutokeService")
	v2 = Knit.GetController("FXController")
end

return controller