local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local animations = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "MalevolantShrineController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.MalevolantShrine.Voice, humanoidRootPart, game.SoundService.Voice)
			v2:DomainBurst(humanoidRootPart)
			local character = localPlayer.Character

			if character and character:FindFirstChild("HumanoidRootPart") then
				local humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude <= 37.5 then
					v2:Domain(instance, function(p, instance2)
						instance2.Humanoid:LoadAnimation(animations.Itadori.DomainWarn):Play(0)
						p.Panel.ImageLabel.Image = "rbxassetid://14812133399"
						p.Panel.ImageLabel.Size = UDim2.new(0.8, 0, 0.8, 0)
						p.Panel.Viewport.LightColor = Color3.fromRGB(255, 155, 155)
						p.Panel.Viewport.Ambient = Color3.fromRGB(0, 0, 0)
						p.Panel.Viewport.LightDirection = createVector(0, 1, 0)
					end)
				end
			end
		end,
		Opening = function(parent, p, p2, p3)
			local clone = utils.Itadori.MalevolantShrine.DomainBG:Clone()
			clone.Parent = parent
			clone.CFrame = parent.CFrame
			task.spawn(function()
				repeat
					task.wait()
				until not (p2.Parent and p2.Parent.Parent and p2.Parent.Parent.Parent)

				clone:Destroy()
			end)
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
			colorCorrectionEffect.Name = "DomainCC"
			TweenService:Create(colorCorrectionEffect, TweenInfo.new(2), {
				Saturation = -1,
				Contrast = 1
			}):Play()
			local v4 = nil

			if p3 then
				local v5 = v2:PlaySound(sounds.Itadori.MalevolantShrine.Music, workspace, game.SoundService.Music, true)
				v5.TimePosition = 1.5
				game.SoundService.AmbientReverb = Enum.ReverbType.Arena
				task.spawn(function()
					repeat
						task.wait()
					until not (p2.Parent and p2.Parent.Parent and p2.Parent.Parent.Parent)

					game.SoundService.AmbientReverb = Enum.ReverbType.NoReverb
					TweenService:Create(v5, TweenInfo.new(2), {
						Volume = 0
					}):Play()
					Debris:AddItem(v5, 2)

					if v4 then
						v4:StartFadeOut(1)
					end

					colorCorrectionEffect:Destroy()
				end)
			else
				local domainGround = p.DomainGround
				domainGround.Surround.Enabled = true
				TweenService:Create(domainGround.Surround, TweenInfo.new(0.8), {
					ShapePartial = 1
				}):Play()
				Debris:AddItem(domainGround, 2)
				v2:PlaySound(sounds.Itadori.MalevolantShrine.Ring, workspace, game.SoundService.Effect)
				task.delay(0.8, function()
					TweenService:Create(domainGround, TweenInfo.new(0.4), {
						Transparency = 0
					}):Play()
					v2:DomainMapFade(Color3.fromRGB(0, 0, 0), 0.4, 1.6)
				end)
				local v5 = v2:PlaySound(sounds.Itadori.MalevolantShrine.Music, workspace, game.SoundService.Music, true)
				local v6 = v2:PlaySound(sounds.Itadori.MalevolantShrine.Ready, workspace, game.SoundService.Effect)
				game.SoundService.AmbientReverb = Enum.ReverbType.Arena
				task.spawn(function()
					repeat
						task.wait()
					until not (p2.Parent and p2.Parent.Parent and p2.Parent.Parent.Parent)

					game.SoundService.AmbientReverb = Enum.ReverbType.NoReverb
					TweenService:Create(v5, TweenInfo.new(2), {
						Volume = 0
					}):Play()
					Debris:AddItem(v5, 2)

					if v6 then
						TweenService:Create(v6, TweenInfo.new(0.5), {
							Volume = 0
						}):Play()
					end

					if v4 then
						v4:StartFadeOut(1)
					end

					colorCorrectionEffect:Destroy()
				end)
				task.wait(1.5)
			end

			local shrine = clone.Floor.Shrine
			shrine:SetPrimaryPartCFrame(clone.Floor.CFrame - createVector(0, 30, 0))
			TweenService:Create(
				shrine.Shrine,
				TweenInfo.new(1.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out),
				{
					CFrame = clone.Floor.CFrame + createVector(0, 10, 0)
				}
			):Play()
			TweenService:Create(
				shrine.Skulls,
				TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = clone.Floor.CFrame + createVector(0, 3, 0)
				}
			):Play()
			clone.Floor.Ripple.Enabled = true

			if not p3 then
				v2:PlaySound(sounds.Itadori.MalevolantShrine.WaterSplash, shrine.Shrine, game.SoundService.Effect)
				clone.Floor.Water.Splash:Emit(10)
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				task.wait(1)

				if not (p2 and p2.Parent) then
					return
				end
			end

			TweenService:Create(
				clone.Floor.Attachment.Charge,
				TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
				{
					TimeScale = 1
				}
			):Play()
			TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5), {
				Saturation = 0,
				Brightness = 0.1,
				Contrast = 0.5,
				TintColor = Color3.fromRGB(255, 195, 195)
			}):Play()
			v4 = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.LightHit)
			TweenService:Create(clone, TweenInfo.new(1.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Color = Color3.fromRGB(136, 62, 62)
			}):Play()
			task.wait(0.5)
			clone.Floor.Attachment.Charge.Enabled = false
			clone.Slash1.Enabled = true
			clone.Slash2.Enabled = true
			clone.Sparks.Enabled = true
		end,
		Shatter = function(position)
			local clone = utils.Domain:Clone()
			clone.Transparency = 1
			clone.CanCollide = false
			clone.Position = position
			clone.Shatter.Color = ColorSequence.new(Color3.new(0, 0, 0))
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)

			for _, child in clone:GetChildren() do
				if child.Name == "Shatter" then
					child:Emit(100)
				else
					child:Destroy()
				end
			end

			v2:PlaySound(sounds.Itadori.MalevolantShrine.Shatter, clone, game.SoundService.Effect)
			clone.Transparency = 0
			clone.Color = Color3.new(0, 0, 0)
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Transparency = 1
			}):Play()

			if _G.Settings.DesPHY then
				if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude > 150 then
					return
				end

				local random = Random.new()
				local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)

				for _ = 1, 80 do
					local clone2 = utils.Gojo.Shard:Clone()
					local unit = random:NextUnitVector().Unit
					clone2.Size = Vector3.new(0.1, math.random(1, 8), math.random(1, 8))
					clone2.CFrame = CFrame.lookAlong(position, unit) * CFrame.Angles(1.5707963267948966, 0, 0) + unit * 37.5
					clone2.CFrame *= CFrame.Angles(0, math.random(0, 3.141592653589793), 0)
					clone2.Color = Color3.new(0, 0, 0)
					clone2.CanCollide = true
					clone2.CollisionGroup = "Effects"
					clone2.Parent = workspace.Effects
					clone2.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
					clone2.Transparency = 0
					clone2.Material = Enum.Material.Neon
					TweenService:Create(clone2, tweenInfo, {
						Size = createVector(0, 0, 0)
					}):Play()
					Debris:AddItem(clone2, 4)
				end
			end
		end,
		Hit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.MalevolantShrine.Hit:Clone()
			clone.Parent = workspace.Effects
			clone.Weld.Part1 = humanoidRootPart

			while true do
				task.wait(math.random(10, 20) / 100)

				if instance2 and instance2:IsDescendantOf(workspace.Characters) and instance2.Value ~= true then
					clone.Slash1.Enabled = true
					clone.Slash2.Enabled = true
					v2:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)
				else
					clone.Slash1.Enabled = false
					clone.Slash2.Enabled = false
				end

				if not (not instance2 or not instance2.Parent or instance:GetAttribute("Dead")) then
					continue
				end

				clone:Destroy()

				if instance:GetAttribute("Dead") then
					v2:PlaySound(sounds.Itadori.Dismantle.Explode, humanoidRootPart, game.SoundService.Effect)
					v2:Bleed(instance)
				end

				break
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
	v = Knit.GetService("MalevolantShrineService")
	v2 = Knit.GetController("FXController")
end

return controller