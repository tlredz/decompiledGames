local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
local AssetService = game:GetService("AssetService")
game:GetService("HttpService")
local EncodingService = game:GetService("EncodingService")
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
local StaticLightning = require(replicatedStorage.Modules.StaticLightning)
local LightningBeams = require(replicatedStorage.Modules.LightningBeams)
local random = Random.new()
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "ResoluteSlashController"
})

function decode(p)
	return EncodingService:DecompressBuffer(p, Enum.CompressionAlgorithm.Zstd)
end

function controller.KnitStart(_)
	local values = {}

	for i, child in utils.Yuta.ResoluteSlash.BlackFlashFlipbook:GetChildren() do
		values[i] = decode(buffer.fromstring(child:GetAttribute("Image")))
	end

	local size = utils.Yuta.ResoluteSlash.BlackFlashFlipbook:GetAttribute("Size")
	local random2 = Random.new()
	utils.Yuta.ResoluteSlash.BlackFlashFlipbook:Destroy()
	local v3 = {
		WarnAndTrack = function(instance, p, instance2, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.CounterHit.Feint:Clone()

			for _, child in clone:GetChildren() do
				child.Color = ColorSequence.new(Color3.fromRGB(255, 170, 255))
				child.TimeScale = 0.7
			end

			clone.Parent = humanoidRootPart
			clone.Sparks:Emit(30)
			clone.Ring:Emit(6)
			Debris:AddItem(clone, 1)
			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			if not p2 then
				v:PlaySound(sounds.Yuta.SwordGrab, humanoidRootPart2, game.SoundService.Effect)
			end

			if instance2 == localPlayer.Character then
				repeat
					task.wait()
					p.CFrame = CFrame.new(humanoidRootPart2.Position, humanoidRootPart.Position)
				until not p.Parent
			end
		end,
		Teleport = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:PlaySound(sounds.Yuta.Leap, humanoidRootPart, game.SoundService.Effect)
			v:DustTrail(instance, 0.2, CFrame.Angles(0, -1.5707963267948966, 0))
			local vanish = utils.Goku.Vanish
			local attachment = vanish.Limb.Attachment
			local attachment2 = vanish.Head.Attachment
			local attachment3 = vanish.Torso.Attachment
			local attachment4 = vanish.Limb2.Attachment
			local attachment5 = vanish.Head2.Attachment

			local function playParticles(attachment7, attachment8, parent)
				local clone = attachment7:Clone()
				clone.Parent = parent
				clone.Vanish:Emit(1)
				Debris:AddItem(clone, 0.3)
				task.delay(0.1, function()
					local clone2 = attachment8:Clone()
					clone2.Parent = parent
					clone2.Vanish:Emit(1)
					Debris:AddItem(clone2, 0.3)
				end)
			end

			playParticles(attachment3, vanish.Torso2.Attachment, instance.Torso)
			playParticles(attachment2, attachment5, instance.Head)
			playParticles(attachment, attachment4, instance["Right Arm"])
			playParticles(attachment, attachment4, instance["Left Arm"])
			playParticles(attachment, attachment4, instance["Right Leg"])
			playParticles(attachment, attachment4, instance["Left Leg"])
			task.wait(0.15)

			if not p then
				local yutaSword = instance.SetAssets:FindFirstChild("YutaSword")

				if not yutaSword then
					return
				end

				local blade = yutaSword.Sword.Blade
				local clone = utils.Yuta.ResoluteSlash.SwordBurst2.SwordB2:Clone()
				clone.Parent = blade
				Debris:AddItem(clone, 1)

				for _, emitter in clone:GetDescendants() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local v4 = emitter
					task.delay(emitter:GetAttribute("EmitDelay"), function()
						v4:Emit(v4:GetAttribute("EmitCount"))
					end)
				end

				task.wait(0.1)
				local clone2 = utils.Yuta.ResoluteSlash.SwordBurst.Center:Clone()
				clone2.Parent = blade
				Debris:AddItem(clone2, 0.2)
				clone2.Glow:Emit(1)
			end
		end,
		ChargeEffect = function(p)
			local yutaSword = p.SetAssets:FindFirstChild("YutaSword")

			if not yutaSword then
				return
			end

			local blade = yutaSword.Sword.Blade
			local clone = utils.Yuta.ResoluteSlash.SwordBurst.Attachment0:Clone()
			local clone2 = utils.Yuta.ResoluteSlash.SwordBurst.Center:Clone()
			clone.Parent = blade
			clone2.Parent = blade
			Debris:AddItem(clone, 0.5)
			Debris:AddItem(clone2, 4)
			clone.Burst1:Emit(1)
			clone2.Burst2:Emit(1)
			task.wait(0.2)
			clone2:Destroy()
			local clone3 = utils.Yuta.ResoluteSlash.SwordBurst.Sparks:Clone()
			clone3.Parent = blade
			Debris:AddItem(clone3, 0.7)
			clone3:Emit(30)
		end,
		Confused = function(instance)
			local head = instance:FindFirstChild("Head")

			if not head then
				return
			end

			local clone = utils.Yuta.ResoluteSlash.Confused.Attachment:Clone()
			clone.Parent = head
			clone.Question:Emit(1)
			Debris:AddItem(clone, 1)
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (humanoidRootPart and instance.SetAssets:FindFirstChild("YutaSword")) then
				return
			end

			v:PlaySound(sounds.Yuta.Swing, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Yuta.ResoluteSlash.RingSwing.Attachment:Clone()
			clone.Parent = humanoidRootPart
			clone.Ring:Emit(8)
			Debris:AddItem(clone, 0.6)
		end,
		Swing2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Yuta.ResoluteSlash.RingSwing.Attachment:Clone()
			clone.Parent = humanoidRootPart
			clone.Ring:Emit(8)
			Debris:AddItem(clone, 0.6)
		end,
		Slash = function(p, p2)
			local clone = utils.Yuta.ResoluteSlash.SlashHit.Attachment:Clone()
			clone.Parent = p2.Head
			clone.WorldCFrame = CFrame.lookAlong(clone.WorldPosition, p)
			clone.Slash:Emit(2)
			Debris:AddItem(clone, 0.5)
			v:PlaySound(sounds.Yuta.ResoluteSlash, p2.Head, game.SoundService.Effect)
		end,
		Hit = function(p, p2)
			v:Flash(p, Color3.fromRGB(255, 170, 255))

			if p2 then
				v:PlaySound(sounds.Yuta.ResoluteHit, p.Head, game.SoundService.Effect)
			end
		end,
		BlackFlashWindup = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local leftGripAttachment = instance["Left Arm"].LeftGripAttachment

			if not leftGripAttachment then
				return
			end

			if p then
				v:PlaySound(sounds.Yuta.BlackFlash.Windup, humanoidRootPart, game.SoundService.Music)

				if localPlayer.Character == instance or localPlayer.Character == instance2 then
					local clone = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone.Parent = game.Lighting
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
					TweenService:Create(
						clone,
						TweenInfo.new(1.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							TintColor = Color3.new(1, 1, 1),
							Brightness = 2
						}
					):Play()
					TweenService:Create(
						workspace.CurrentCamera,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							FieldOfView = 40
						}
					):Play()
					task.delay(1.1, function()
						clone:Destroy()
						TweenService:Create(
							workspace.CurrentCamera,
							TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								FieldOfView = 70
							}
						):Play()
						game.Lighting.ExposureCompensation = 2
						TweenService:Create(game.Lighting, TweenInfo.new(1), {
							ExposureCompensation = 0
						}):Play()
					end)
				end

				task.spawn(function()
					local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart2 then
						return
					end

					local faceFrontAttachment = instance2.Head.FaceFrontAttachment
					local model = Instance.new("Model", workspace.Effects)
					local highlight = Instance.new("Highlight", model)
					highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					highlight.OutlineColor = Color3.new(1, 0, 0)
					highlight.FillColor = Color3.new(0, 0, 0)
					highlight.FillTransparency = 0
					Debris:AddItem(model, 1.1)

					for _ = 1, 10 do
						local attachment = Instance.new("Attachment", humanoidRootPart2)
						attachment.Position = random:NextUnitVector() * 40
						local v4 = LightningBeams.new(faceFrontAttachment, attachment, nil, model)
						v4.Color = Color3.new(1, 0, 0)
						v4.PulseSpeed = 100
						v4.MaxRadius = 16
						v4.MinRadius = 0
						v4.AnimationSpeed = 10
						v4.MinThicknessMultiplier = 0.1
						v4.MaxThicknessMultiplier = 2
						task.delay(0.1, function()
							local WAIT_INTERVAL = 0.1
							v4.AnimationSpeed = 5
							task.wait(WAIT_INTERVAL)
							v4.AnimationSpeed = 2.5
							task.wait(WAIT_INTERVAL)
							v4.AnimationSpeed = 1
							task.wait(WAIT_INTERVAL)
							v4.AnimationSpeed = 0.5
							task.wait(0.2)
							v4.AnimationSpeed = 0.1
							task.wait(WAIT_INTERVAL)
							v4:Destroy()
							attachment:Destroy()
						end)
					end
				end)
			end

			v:PlaySound(sounds.Yuta.BlackFlash.Windup2, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Yuta.ResoluteSlash.BlackFlashWindup:Clone()
			local frame = clone.BB.Frame
			clone.Parent = workspace.Effects
			local editableImage = AssetService:CreateEditableImage({
				Size = size
			})
			frame.ImageContent = Content.fromObject(editableImage)
			local v4 = 0.3 / #values
			local v5 = #values * 1.8
			local count = 0

			for _ = 1, 2 do
				for _, v6 in values do
					clone.Position = (humanoidRootPart.Position + random2:NextUnitVector() * 4):Lerp(
						leftGripAttachment.WorldPosition,
						(math.clamp(count / v5, 0, 1))
					)
					count += 1
					editableImage:WritePixelsBuffer(Vector2.zero, editableImage.Size, v6)
					task.wait(v4)
				end
			end

			clone:Destroy()
		end,
		BlackFlash = function(instance, instance2, p)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v:PlaySound(sounds.Yuta.BlackFlash.Land2, humanoidRootPart, game.SoundService.Effect)
			local v4 = v:PlaySound(sounds.Yuta.BlackFlash.Land, humanoidRootPart, game.SoundService.Music)
			task.delay(5, function()
				TweenService:Create(v4, TweenInfo.new(3), {
					Volume = 0
				}):Play()
			end)
			local faceFrontAttachment = instance2.Head.FaceFrontAttachment
			local clone = utils.Itadori.DivergentFist.BlackFlashHit:Clone()
			clone.Position = humanoidRootPart2.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Wind2:Emit(8)
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			task.delay(0.1, function()
				clone.Blast:Emit(8)
				clone.Sparks:Emit(15)
				clone.Lightning:Emit(6)
				clone.Wind:Emit(7)
			end)
			v:Flash(instance2, Color3.new(1, 0, 0))
			v:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart2, game.SoundService.Effect)
			task.spawn(function()
				local model = Instance.new("Model", workspace.Effects)
				local highlight = Instance.new("Highlight", model)
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.OutlineColor = Color3.new(1, 0, 0)
				highlight.FillColor = Color3.new(0, 0, 0)
				highlight.FillTransparency = 0

				repeat
					local attachment = Instance.new("Attachment", humanoidRootPart2)
					attachment.Position = random:NextUnitVector() * 30
					local v5 = LightningBeams.new(faceFrontAttachment, attachment, nil, model)
					v5.Color = Color3.new(1, 0, 0)
					v5.PulseSpeed = 300
					v5.FadeLength = 0.35
					v5.MaxRadius = 20
					v5.MinRadius = 0
					v5.AnimationSpeed = _G.Settings.Flash == true and 75 or 5
					v5.MinThicknessMultiplier = 0.1
					v5.MaxThicknessMultiplier = 3
					task.delay(0.1, function()
						v5:Destroy()
						attachment:Destroy()
					end)
					task.wait(0.02)
				until not (p.Parent and instance2.Parent and instance.Parent)

				model:Destroy()
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone2.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone2.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone2.Brightness = 200
				clone2.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone2:Destroy()
				local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)

				repeat
					task.wait()
				until not (p.Parent and instance2.Parent and instance.Parent)

				shakeSustain:StartFadeOut(0.5)
			end
		end,
		BlackFlashTrail = function(p, value)
			local random3 = Random.new()
			local disk = utils.Yuta.ResoluteSlash.Disk
			local model = Instance.new("Model", workspace.Effects)
			local highlight = Instance.new("Highlight")
			highlight.FillColor = Color3.new()
			highlight.OutlineTransparency = 1
			highlight.FillTransparency = 0
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = model
			local raycastResult = workspace:Raycast(p.Position, p.LookVector * 100, _G.MapParams)
			local v4 = (not raycastResult and (value or 100) or raycastResult.Distance) / 20

			if v4 < 1 then
				return
			end

			local thicknessFade = StaticLightning.ThicknessFade(0.5, 1.2)
			local v5 = {}

			for i = 1, v4 do
				local position = (p * CFrame.new(0, 0, i * -20 + 5)).Position

				for _ = 1, 5 do
					local distance = 20
					local unitVector = random3:NextUnitVector()
					local raycastResult2 = workspace:Raycast(position, unitVector * distance, _G.MapParams)

					if raycastResult2 then
						distance = raycastResult2.Distance
					end

					local bolt = StaticLightning.CreateBolt({
						Position1 = position,
						Position2 = position + unitVector * distance,
						PartCount = math.floor(distance / 6),
						Thickness = thicknessFade,
						Color = Color3.new(1, 0, 0),
						Parent = model
					})

					if raycastResult2 then
						local number = random3:NextNumber(2, 4)
						local clone = disk:Clone()
						clone.CFrame = CFrame.lookAlong(raycastResult2.Position, raycastResult2.Normal) * CFrame.Angles(
							0,
							1.5707963267948966,
							0
						)
						clone.Size *= Vector3.new(1, number, number)
						clone.Parent = model
						table.insert(bolt, clone)
					end

					table.insert(v5, bolt)

					for _, v6 in bolt do
						v6.Transparency = 1
					end

					task.spawn(function()
						for k, v7 in bolt do
							task.wait(0.02)
							v7.Transparency = 0
							TweenService:Create(v7, TweenInfo.new(0.2), {
								Size = v7.Size * createVector(0.5, 0.5, 1)
							}):Play()
						end

						task.wait(0.1)

						for k, v7 in bolt do
							v7:Destroy()
							task.wait(0.02)
						end
					end)
				end

				task.wait(0.1)
			end

			task.wait(0.3)
			model:Destroy()
		end,
		SmallThrow = function(p, instance)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local _ = instance.Head.FaceFrontAttachment
			local clone = utils.Itadori.DivergentFist.BlackFlashHit:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Wind2:Emit(8)
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			task.delay(0.1, function()
				clone.Blast:Emit(8)
				clone.Sparks:Emit(15)
				clone.Lightning:Emit(6)
				clone.Wind:Emit(7)
			end)
			v:Flash(instance, Color3.new(1, 0, 0))
			v:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone2.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone2.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone2.Brightness = 200
				clone2.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone2:Destroy()
			end

			task.wait(0.4)

			for _, part in instance:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local clone2 = utils.Itadori.DivergentFist.FlashBurn:Clone()
				clone2.Parent = part
				Debris:AddItem(clone2, 0.5)
			end
		end,
		FinalThrow = function(instance, p, p2)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local position = p.Position
			local _ = p.LookVector
			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.Sparks:Emit(20)
			clone.Flare:Emit(20)
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			Debris:AddItem(clone, 3)

			if (localPlayer.Character == instance or localPlayer.Character == p2) and _G.Settings.Flash == true then
				local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone2.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone2.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone2.Brightness = 200
				clone2.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone2:Destroy()
			end

			v:Flash(instance, Color3.new(1, 0, 0))
			v:Bleed(p2)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude <= 80 then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(1)
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
	v2 = Knit.GetService("ResoluteSlashService")
	v = Knit.GetController("FXController")
end

return controller