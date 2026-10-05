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
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "DismantleV2Controller"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Heian.Dismantle.Start, humanoidRootPart, game.SoundService.Effect)

			if instance:GetAttribute("Moveset") ~= "Heian" then
				return
			end

			if p == 1 then
				v2:PlaySound(sounds.Heian.Dismantle1, humanoidRootPart, game.SoundService.Voice)
			elseif p == 3 then
				v2:PlaySound(sounds.Heian.Dismantle3, humanoidRootPart, game.SoundService.Voice)
			end
		end,
		Interp = function(_, instance)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			v2:PlaySound(sounds.Heian.Dismantle.Fire, instance, game.SoundService.Effect)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Parent then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (300 * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Heian.Dismantle.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)
		end,
		DismantleSweep = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Heian.Sweep:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2.5)
			TweenService:Create(clone.Attachment.Dust, TweenInfo.new(1), {
				TimeScale = 1
			}):Play()
			TweenService:Create(clone.Attachment.Ring, TweenInfo.new(1), {
				TimeScale = 1
			}):Play()
			TweenService:Create(
				clone.Slashes,
				TweenInfo.new(0.75, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
				{
					TimeScale = 1
				}
			):Play()

			if instance:GetAttribute("Moveset") == "Heian" then
				v2:PlaySound(sounds.Heian.Dismantle2, humanoidRootPart, game.SoundService.Voice)
			end

			local v5

			if localPlayer.Character == instance then
				v5 = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
				v5:StartFadeIn(0.75)
			end

			local v6 = v2:PlaySound(sounds.Heian.Slashes2, humanoidRootPart, game.SoundService.Effect)
			TweenService:Create(v6, TweenInfo.new(0.75), {
				Volume = 2.5
			}):Play()
			local lastTime = tick()

			repeat
				v2:PlaySound(sounds.Heian.Dismantle.Fire, humanoidRootPart, game.SoundService.Effect)
				task.wait(0.075)
			until not humanoidRootPart.Parent or tick() - lastTime > 0.75 or instance:GetAttribute("Dead")

			if not humanoidRootPart.Parent or instance:GetAttribute("Dead") then
				return
			end

			clone.Attachment.Dust.Enabled = false
			clone.Attachment.Ring.Enabled = false
			clone.Slashes.Enabled = false
			clone.Break:Emit(30)
			clone.Stars:Emit(20)

			if v6 then
				TweenService:Create(v6, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
			end

			if v5 then
				v5:StartFadeOut(0.5)
			end

			v2:PlaySound(sounds.Itadori.Rush.RushLaunch, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 100 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone2.TintColor = Color3.new(1, 1, 1)
				clone2.Parent = game.Lighting
				task.wait(0.04)
				clone2.Brightness = 200
				clone2.Contrast = -1000
				task.wait(0.04)
				clone2:Destroy()
			end
		end,
		Split = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)
			v2:Bleed(instance)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone.TintColor = Color3.new(1, 1, 1)
				clone.Parent = game.Lighting
				task.wait(0.04)
				clone.Brightness = 200
				clone.Contrast = -1000
				task.wait(0.04)
				clone:Destroy()
			end
		end,
		WCS = function(cFrame)
			task.spawn(function()
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)

				if workspace:GetAttribute("CC1") or _G.Settings.Flash ~= true then
					return
				end

				local clone = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone.TintColor = Color3.new(1, 1, 1)
				clone.Parent = game.Lighting
				task.wait(0.02)
				clone.Brightness = 200
				clone.Contrast = -1000
				task.wait(0.02)
				clone:Destroy()
			end)
			local clone = utils.Heian.WorldSlash:Clone()
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			local highlight = Instance.new("Highlight", clone.Slash)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillTransparency = 0
			highlight.FillColor = Color3.new(0, 0, 0)
			Debris:AddItem(clone, 4.1)
			v2:PlaySound(sounds.Heian.Dismantle.FireWCS, clone, game.SoundService.Effect)
			v2:PlaySound(sounds.Heian.Dismantle.Fire, clone, game.SoundService.Effect)
			clone.Smear:Emit(200)
			clone.Dust:Emit(200)
			TweenService:Create(clone.Slash, TweenInfo.new(0.2), {
				Size = createVector(0, 0, 500)
			}):Play()
			TweenService:Create(clone.Weld, TweenInfo.new(0.2), {
				C1 = CFrame.new(0, 0, 0)
			}):Play()
			task.wait(0.2)
			clone.slashenabled3.Enabled = false
			clone.slashenabled4.Enabled = false
			clone.Stars:Emit(100)
		end
	}
	v.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("DismantleV2Service")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller