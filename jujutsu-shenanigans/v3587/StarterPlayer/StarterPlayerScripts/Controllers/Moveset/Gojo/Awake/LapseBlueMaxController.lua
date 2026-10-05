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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "LapseBlueMaxController"
})

function controller.KnitStart(_)
	local v4 = {
		Aerial = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")

			if not humanoid then
				return
			end

			local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
			bodyGyro.P = 10000
			bodyGyro.MaxTorque = createVector(40000, 40000, 40000)
			p.Position = humanoidRootPart.Position + createVector(0, 6, 0)
			humanoid.PlatformStand = true

			repeat
				local mouseTarget = v3:GetMouseTarget()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouseTarget)
				task.wait()
			until not p.Parent

			bodyGyro:Destroy()
			humanoid.PlatformStand = false
		end,
		BlueGrab = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
		end,
		Blue = function(instance, attachment)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.LapseBlueMax:Clone()
			clone.AlignPosition.Attachment1 = attachment
			clone.Position = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 5
			clone.Parent = workspace.Effects
			TweenService:Create(clone.PointLight, TweenInfo.new(0.5), {
				Brightness = 5
			}):Play()
			TweenService:Create(clone.Startup.Paint, TweenInfo.new(0.4), {
				TimeScale = 1
			}):Play()
			TweenService:Create(clone.Startup.Charge, TweenInfo.new(0.4), {
				TimeScale = 1
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
				Size = createVector(5, 5, 5)
			}):Play()
			local v5 = v2:PlaySound(sounds.Gojo.LapseBlue.Wind, clone, game.SoundService.Effect, true)
			TweenService:Create(v5, TweenInfo.new(0.5), {
				Volume = 3
			}):Play()
			TweenService:Create(v5, TweenInfo.new(1.25), {
				Pitch = 2
			}):Play()
			attachment:GetAttributeChangedSignal("Grab"):Connect(function()
				if attachment:GetAttribute("Grab") == true then
					clone.Startup.Paint.Enabled = false
					clone.Startup.Charge.Enabled = false
					clone.Transparency = 0
					TweenService:Create(
						clone,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(10, 10, 10)
						}
					):Play()

					if localPlayer.Character == instance then
						CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
						clone.AlignPosition.Responsiveness = 20
					else
						clone.AlignPosition.Responsiveness = 70
					end

					TweenService:Create(clone.PointLight, TweenInfo.new(0.5), {
						Brightness = 15
					}):Play()
					TweenService:Create(clone, TweenInfo.new(1.5, Enum.EasingStyle.Back), {
						Size = createVector(10, 10, 10)
					}):Play()

					for _, emitter in clone.Center:GetChildren() do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = true
						end
					end

					v2:PlaySound(sounds.Gojo.LapseBlue.Absorb, clone, game.SoundService.Effect)
				else
					clone.Startup.Smoke.Enabled = false
					TweenService:Create(v5, TweenInfo.new(0.5), {
						Volume = 0
					}):Play()
					TweenService:Create(clone.Center.Aura, TweenInfo.new(1), {
						TimeScale = 0.4
					}):Play()
				end
			end)
			local v6 = true
			attachment:GetAttributeChangedSignal("Purple"):Connect(function()
				clone.Anchored = true
				v6 = false

				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				TweenService:Create(clone.PointLight, TweenInfo.new(0.4), {
					Brightness = 0
				}):Play()
				Debris:AddItem(clone, 1)
				local clone2 = utils.Gojo.HollowPurple.PurpleMax:Clone()
				clone2.Position = clone.Position
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2, TweenInfo.new(2.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = createVector(15, 15, 15)
				}):Play()
				TweenService:Create(
					clone2.PointLight,
					TweenInfo.new(2.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Brightness = 40
					}
				):Play()
				v2:PlaySound(sounds.Gojo.HollowPurple.Smash, clone2, game.SoundService.Effect)
				v2:PlaySound(sounds.Gojo.HollowPurple.Music2, clone2, game.SoundService.Music)

				if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude < 300 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end

				clone2.Center.Glow:Emit(1)
				task.wait(0.5)
				clone2.Lightning.Enabled = true
				v2:PlaySound(sounds.Gojo.HollowPurple.Summon, clone2, game.SoundService.Effect)
				v2:PlaySound(sounds.Gojo.HollowPurple.MaxCharge, clone2, game.SoundService.Music)
				task.wait(1)
				v2:PlaySound(sounds.Gojo.HollowPurple.Explode, clone2, game.SoundService.Effect)
				task.wait(0.7)
				clone2.Explode.Ring:Emit(1)
				TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
					Color = Color3.fromRGB(255, 170, 255),
					Size = createVector(150, 150, 150)
				}):Play()
				local highlight = Instance.new("Highlight", clone2.Warp)
				highlight.FillTransparency = 1
				highlight.OutlineTransparency = 1
				TweenService:Create(clone2.Warp, TweenInfo.new(0.3), {
					Transparency = 40
				}):Play()
				task.wait(0.3)
				clone2.PointLight:Destroy()
				clone2.Warp:Destroy()
				clone2.Lightning.Enabled = false
				clone2.Transparency = 1

				for _, emitter in clone2.Center:GetChildren() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				clone2.Explode.Hit:Emit(30)
				clone2.Explode.Wind:Emit(30)
				clone2.Explode.Ring2:Emit(10)
				clone2.Explode.Star:Emit(80)
				Debris:AddItem(clone2, 20)

				if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude < 150 then
					game.Lighting.ExposureCompensation = 10
					TweenService:Create(game.Lighting, TweenInfo.new(2), {
						ExposureCompensation = 0
					}):Play()
					CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit):StartFadeOut(4)
				end
			end)

			repeat
				task.wait()
			until v6 == false or not attachment.Parent

			if v6 == true then
				clone.Anchored = true
				TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
					Size = createVector(0, 0, 0)
				}):Play()

				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				TweenService:Create(clone.PointLight, TweenInfo.new(0.4), {
					Brightness = 0
				}):Play()
				Debris:AddItem(clone, 1)
				TweenService:Create(v5, TweenInfo.new(0.5), {
					Volume = 0
				}):Play()
				TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = clone.Position + clone.Velocity / 4
				}):Play()
			end
		end,
		PurpleHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.fromRGB(255, 85, 255), 2)
			v2:PlaySound(sounds.Gojo.HollowPurple.Hit, humanoidRootPart, game.SoundService.Effect)
		end,
		Finisher = function(folder, parent)
			local humanoidRootPart = folder.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

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
					clone.Parent = parent
					Debris:AddItem(clone, 1)

					if _G.Settings.Gore == false then
						clone.Color = Color3.fromRGB(255, 85, 255)
						clone.Trail.Color = ColorSequence.new(Color3.fromRGB(255, 85, 255))
						clone.Blood.Color = clone.Trail.Color
					end

					task.delay(0.2, function()
						local attachment = Instance.new("Attachment", clone)
						local alignPosition = Instance.new("AlignPosition", attachment)
						alignPosition.Responsiveness = 0
						alignPosition.Attachment0 = attachment
						alignPosition.Attachment1 = parent.Parent
						TweenService:Create(
							alignPosition,
							TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
							{
								Responsiveness = 200
							}
						):Play()
					end)
				end
			end
		end,
		Finisher2 = function(p)
			if not p.HumanoidRootPart then
				return
			end

			v2:Burn(p)
		end
	}
	v.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
	local random = Random.new()
	v.Debree:Connect(function(items, parent)
		if (workspace.CurrentCamera.CFrame.Position - parent.Parent.WorldPosition).Magnitude > 75 or not _G.Settings.DesPHY then
			return
		end

		for _, item in items do
			local part = Instance.new("Part")
			part.CanCollide = false
			part.Massless = true
			part.Position = item[1]
			part.Orientation = item[2]
			part.Color = item[3]
			part.Material = item[4]
			part.Size = item[5]
			part.Velocity = random:NextUnitVector() * random:NextInteger(60, 100)
			part.RotVelocity = Vector3.new(math.random(-40, 40), math.random(-40, 40), math.random(-40, 40))
			part.Parent = parent
			Debris:AddItem(part, 0.8)

			if math.random(1, 10) == 1 then
				v2:DebreeSound(part)
			end

			task.delay(0.2, function()
				local attachment = Instance.new("Attachment", part)
				attachment.Name = "BlueGrab"
				local alignPosition = Instance.new("AlignPosition", attachment)
				alignPosition.Responsiveness = 0
				TweenService:Create(alignPosition, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Responsiveness = 100
				}):Play()
				alignPosition.Attachment0 = attachment

				if parent.Parent:IsA("Attachment") then
					attachment = parent.Parent or attachment
				end

				alignPosition.Attachment1 = attachment
			end)
		end
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("LapseBlueMaxService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller