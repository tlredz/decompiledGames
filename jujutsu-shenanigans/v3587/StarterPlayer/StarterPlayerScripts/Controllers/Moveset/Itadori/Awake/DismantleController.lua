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
local v3 = nil
local controller = Knit.CreateController({
	Name = "DismantleController"
})

function controller.KnitStart(_)
	local v4 = {
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			v2:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local model = Instance.new("Model", workspace.Effects)
			Debris:AddItem(model, 0.65)
			local highlight = Instance.new("Highlight", model)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillTransparency = 0
			highlight.FillColor = Color3.new(0, 0, 0)

			for _ = 1, 10 do
				local cFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart2.Position) * CFrame.new(
					math.random(-40, 40) / 10,
					math.random(-40, 40) / 10,
					0
				) * CFrame.Angles(0, 0, (math.rad((math.random(0, 360)))))
				local clone = utils.Itadori.Dismantle.DismantleFly:Clone()
				clone.CFrame = cFrame
				clone.Parent = model
				task.delay(0, function()
					TweenService:Create(clone, TweenInfo.new(0.1), {
						Size = createVector(15, 0, 0),
						CFrame = cFrame + cFrame.LookVector * 30
					}):Play()
					task.wait(0.1)
					clone.Transparency = 1
					task.wait(0.05)
					clone:Destroy()
				end)
				task.wait(0.05)
			end
		end,
		Hit2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)
			BloodyZee:Blood(instance.Torso.CFrame, 50, 180, 180)
		end,
		Finisher = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.Dismantle.Dismantle:Clone()
			clone.Anchored = true
			clone.CFrame = humanoidRootPart.CFrame
			clone.Slash1.Enabled = false
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)
			clone.SlashFinish2.Glow:Emit(1)
			clone.SlashFinish2.Wind:Emit(2)
			v2:PlaySound(sounds.Itadori.Dismantle.FinishSlash, clone, game.SoundService.Effect)
			task.wait(0.2)
			clone.SlashFinish1:Emit(4)
			v2:PlaySound(sounds.Itadori.Dismantle.Explode, clone, game.SoundService.Effect)
			v2:Bleed(instance)
		end,
		Chant = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Heian.Chant.Chant:Clone()
			clone.Parent = instance.Head
			Debris:AddItem(clone, 1)
			TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				StudsOffset = createVector(2, 2, 2)
			}):Play()
			task.delay(0.5, function()
				TweenService:Create(clone.Chat, TweenInfo.new(0.5), {
					ImageTransparency = 1
				}):Play()
				TweenService:Create(clone.Chat.Sub, TweenInfo.new(0.5), {
					TextTransparency = 1
				}):Play()
			end)

			if p == 1 then
				v2:Flash(instance, Color3.fromRGB(255, 255, 255), 2)
				v2:PlaySound(sounds.Itadori.Dismantle.WorldSlash1, humanoidRootPart, game.SoundService.Effect)
			elseif p == 2 then
				v2:Flash(instance, Color3.fromRGB(255, 255, 255), 2)
				v2:PlaySound(sounds.Itadori.Dismantle.WorldSlash2, humanoidRootPart, game.SoundService.Effect)
				clone.Chat.Sub.Text = "RECOIL..."
			elseif p == 3 then
				v2:Flash(instance, Color3.fromRGB(255, 0, 0), 1)
				v2:PlaySound(sounds.Itadori.Dismantle.WorldSlash3, humanoidRootPart, game.SoundService.Effect)
				clone.Chat.Sub.Text = "TWIN METEORS."
				task.wait(0.5)
				local clone2 = utils.Gojo.LapseBlue.LapseBlue.Grab:Clone()
				clone2.Weld.Part0 = clone2
				clone2.Weld.Part1 = humanoidRootPart
				clone2.Parent = workspace.Effects
				local highlight = Instance.new("Highlight", clone2)
				highlight.FillTransparency = 1
				highlight.OutlineTransparency = 1
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
					Size = createVector(100, 6, 10),
					Transparency = 50
				}):Play()
				Debris:AddItem(clone2, 0.5)
			end
		end,
		WorldSlash = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Heian.Dismantle.FireWCS, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Itadori.Dismantle.WorldSlash:Clone()
			clone.CFrame = p + p.LookVector * 30
			clone.Parent = workspace.Effects
			TweenService:Create(clone.Slash, TweenInfo.new(0.1), {
				Size = createVector(0, 0, 60)
			}):Play()
			TweenService:Create(clone.Weld, TweenInfo.new(0.1), {
				C1 = CFrame.new(0, 0, 30)
			}):Play()
			Debris:AddItem(clone.Slash, 0.1)
			local highlight = Instance.new("Highlight", clone.Slash)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillTransparency = 0
			highlight.FillColor = Color3.new(0, 0, 0)
			Debris:AddItem(clone, 0.5)
			clone.Smear:Emit(50)
			clone.Stars:Emit(30)
			local clone2 = utils.Itadori.Dismantle.WorldSlash.Slash:Clone()
			clone2.Material = Enum.Material.Glass
			local weld = Instance.new("Weld", clone2)
			clone2.Weld.Part0 = clone
			clone2.Weld.Part1 = clone2
			clone2.Weld.C1 = CFrame.new(0, 0, 30)
			clone2.Transparency = 50
			clone2.Size = createVector(100, 6, 10)
			clone2.Parent = clone
			local highlight2 = Instance.new("Highlight", clone2)
			highlight2.FillTransparency = 1
			highlight2.OutlineTransparency = 1
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 60),
				Transparency = 1
			}):Play()
			TweenService:Create(weld, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				C1 = CFrame.new(0, 0, 15)
			}):Play()

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		WorldHit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)

			if p then
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
			end
		end,
		DismantleFly = function(instance, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = v2:PlaySound(sounds.Heian.Dismantle.Fire, humanoidRootPart, game.SoundService.Effect)
			v5.Volume *= 2
			local clone = utils.Itadori.Dismantle.DismatleProj:Clone()
			clone.CFrame = p + p.LookVector * 30
			clone.Parent = workspace.Effects
			TweenService:Create(clone.Slash, TweenInfo.new(0.1), {
				Size = createVector(0, 0, 60)
			}):Play()
			TweenService:Create(clone.Weld, TweenInfo.new(0.1), {
				C1 = CFrame.new(0, 0, 30)
			}):Play()
			Debris:AddItem(clone.Slash, 0.1)
			local highlight = Instance.new("Highlight", clone.Slash)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.FillTransparency = 0
			highlight.FillColor = Color3.new(0, 0, 0)
			Debris:AddItem(clone, 0.5)
			clone.Smear:Emit(50)
			clone.Stars:Emit(30)
			local clone2 = utils.Itadori.Dismantle.WorldSlash.Slash:Clone()
			clone2.Material = Enum.Material.Glass
			local weld = Instance.new("Weld", clone2)
			clone2.Weld.Part0 = clone
			clone2.Weld.Part1 = clone2
			clone2.Weld.C1 = CFrame.new(0, 0, 30)
			clone2.Transparency = 50
			clone2.Size = createVector(100, 6, 10)
			clone2.Parent = clone
			local highlight2 = Instance.new("Highlight", clone2)
			highlight2.FillTransparency = 1
			highlight2.OutlineTransparency = 1
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 60),
				Transparency = 1
			}):Play()
			TweenService:Create(weld, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				C1 = CFrame.new(0, 0, 15)
			}):Play()

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)

				if p2 then
					if _G.Settings.Flash ~= true then
						return
					end

					local clone3 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone3.TintColor = Color3.new(1, 1, 1)
					clone3.Parent = game.Lighting
					task.wait(0.04)
					clone3.Brightness = 200
					clone3.Contrast = -1000
					task.wait(0.04)
					clone3:Destroy()
				end
			end
		end,
		Aerial = function(instance, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")

			if not humanoid then
				return
			end

			p.Position = humanoidRootPart.Position + Vector3.new(0, p2 and 0 or 12, 0)
			v2:PlaySound(sounds.Itadori.CursedStrikes.Spin, humanoidRootPart, game.SoundService.Effect)
			local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
			bodyGyro.P = 10000
			bodyGyro.MaxTorque = createVector(40000, 40000, 40000)
			humanoid.PlatformStand = true

			repeat
				local mouseTarget = v3:GetMouseTarget()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouseTarget)
				task.wait()
			until not p.Parent

			bodyGyro:Destroy()
			humanoid.PlatformStand = false
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
	v = Knit.GetService("DismantleService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller