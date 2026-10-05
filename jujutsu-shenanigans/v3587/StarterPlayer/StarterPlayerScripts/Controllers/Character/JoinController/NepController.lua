local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local _ = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local _ = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "NepController"
})

function controller.KnitStart(_)
	local v3 = {
		ToggleRadio = function(p, _, _)
			v2:PlaySound(sounds.Misc.Nep.Start, p.Root, game.SoundService.Effect)

			if p.Root:FindFirstChild("StaticLoop") then
				p.Root.StaticLoop:Destroy()
				return
			end

			local clone = sounds.Misc.Nep.StaticLoop:Clone()
			clone.SoundGroup = game.SoundService.Effect
			clone.Parent = p.Root
			clone:Play()
		end,
		RadioBeep = function(p)
			v2:PlaySound(sounds.Misc.Nep.Beep, p.Root, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Itadori.EyeTrails:Clone()
			clone.Eye1:Destroy()
			clone.Trail1:Destroy()
			clone.Trail2:Destroy()
			clone.Eye2.Glow.Enabled = false
			clone.Weld.Part0 = p.Model.Button
			clone.Eye2.CFrame = CFrame.new()
			clone.Parent = workspace.Effects
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(203, 0, 3))
			clone.Eye2.Glow.Color = ColorSequence.new(Color3.fromRGB(203, 0, 3))
			clone.Glow.Color = ColorSequence.new(Color3.fromRGB(203, 0, 3))
			clone.Glow.ZOffset = 0
			clone.Glow:Emit(1)
			clone.Eye2.Glow:Emit(1)
			Debris:AddItem(clone, 0.5)
		end,
		RadioSignal = function(p, p2)
			if p2 and p.Root:FindFirstChild("Signal") then
				p.Root.Signal:Destroy()
			else
				v2:PlaySound(sounds.Misc.Nep.Signal, p.Root, game.SoundService.Effect)
			end
		end,
		RadioBounce = function(instance)
			local music = instance.Root.Music

			if not music.Playing then
				return
			end

			local total = 0
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt * 12

				if music.Playing then
					local halfVolume = music.Volume / 2

					if halfVolume <= 0 then
						instance:ScaleTo(1)
						return
					end

					instance:ScaleTo(1 * (1 + math.sin(total) * 0.15 * halfVolume))
				else
					instance:ScaleTo(1)
					heartbeatConnection:Disconnect()
				end
			end)
		end,
		RadioTalk = function(p, text, value)
			if p.Root:FindFirstChild("Entry") then
				p.Root.Entry:Destroy()
			end

			local v4 = value or 2.5
			v2:PlaySound(sounds.Misc.Nep.Talk, p.Root, game.SoundService.Voice)
			v2:PlaySound(sounds.Misc.Nep.TalkStart, p.Root, game.SoundService.Effect)
			local clone = p.Root._Entry:Clone()
			clone.Name = "Entry"
			clone.TextLabel.Text = text
			clone.Enabled = true
			clone.Parent = p.Root
			Debris:AddItem(clone, v4 + 0.5)
			task.delay(v4, function()
				if not clone.Parent then
					return
				end

				TweenService:Create(clone.TextLabel, TweenInfo.new(0.5), {
					BackgroundTransparency = 1,
					TextTransparency = 1
				}):Play()
				TweenService:Create(clone.TextLabel.UIStroke, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
			end)
		end,
		UngezieferRage = function(p)
			v2:PlaySound(sounds.Misc.Nep.Rage, p.HumanoidRootPart, game.SoundService.Effect)
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
	v = Knit.GetService("NepService")
	v2 = Knit.GetController("FXController")
end

return controller