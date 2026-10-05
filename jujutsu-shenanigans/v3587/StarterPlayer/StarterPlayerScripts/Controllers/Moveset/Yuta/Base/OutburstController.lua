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
local SraikoVFX = require(replicatedStorage.Modules.SraikoVFX)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local controller = Knit.CreateController({
	Name = "OutburstController"
})

function controller.KnitStart(_)
	local v5 = {
		BodyBurst = function(instance)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			local clone = utils.Yuta.Outburst.Aura:Clone()
			clone.Parent = torso
			Debris:AddItem(clone, 0.6)
			task.delay(0.3, function()
				clone.Aura.Enabled = false
			end)
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

			v3:PlaySound(sounds.Haruta.AmbushHit, humanoidRootPart2, game.SoundService.Effect)
			v3:Flash(instance2, Color3.fromRGB(255, 170, 255))
			local clone = utils.Yuta.SlashHit:Clone()
			clone.Slash.Color = ColorSequence.new(Color3.fromRGB(255, 85, 255))
			clone.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart.CFrame.LookVector)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			clone.Slash:Emit(5)

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
			end
		end,
		SwordBurst = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local yutaSword = instance.SetAssets:FindFirstChild("YutaSword")

			if not yutaSword then
				return
			end

			local clone = utils.Yuta.Outburst.SwordBurst:Clone()
			clone.Parent = yutaSword.Sword
			v3:PlayParticles(clone)
			Debris:AddItem(clone, 0.35)
		end,
		ProjectileExplode = function(position)
			local clone = utils.Yuta.Outburst.YutaAOE:Clone()
			clone.Parent = workspace.Effects
			clone.Position = position
			v3:PlayParticles(clone)
			Debris:AddItem(clone, 1)
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Range = 0
			}):Play()
		end,
		Aerial = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")

			if not humanoid then
				return
			end

			p.Position = humanoidRootPart.Position
			v3:PlaySound(sounds.Itadori.CursedStrikes.Spin, humanoidRootPart, game.SoundService.Effect)
			local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
			bodyGyro.P = 10000
			bodyGyro.MaxTorque = createVector(40000, 40000, 40000)
			humanoid.PlatformStand = true

			repeat
				local mouseTarget = v4:GetMouseTarget()
				bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, mouseTarget)
				task.wait()
			until not p.Parent

			bodyGyro:Destroy()
			humanoid.PlatformStand = false
		end,
		Interp = function(instance)
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)

			for _, child in instance:GetChildren() do
				child.Squash = NumberSequence.new(0)
				child.Size = NumberSequence.new(3)

				if child.Name == "CursedEnergy3" or child.Name == "CursedEnergy4" then
					local v6 = child
					task.spawn(function()
						for i = 1, 30 do
							local value = TweenService:GetValue(
								i / 30,
								Enum.EasingStyle.Exponential,
								Enum.EasingDirection.Out
							)
							v6.Size = NumberSequence.new(3 + -1.5 * value)
							v6.Squash = NumberSequence.new(-3 * value)
							task.wait(0.025)
						end
					end)
				else
					local v6 = child
					task.spawn(function()
						for i = 1, 30 do
							local value = TweenService:GetValue(
								i / 30,
								Enum.EasingStyle.Exponential,
								Enum.EasingDirection.Out
							)
							v6.Size = NumberSequence.new(3 + -1.5 * value)
							v6.Squash = NumberSequence.new(3 * value)
							task.wait(0.025)
						end
					end)
				end
			end

			instance.Size = createVector(0, 0, 0)
			TweenService:Create(instance, TweenInfo.new(0.5), {
				Size = createVector(15, 0.25, 0.25)
			}):Play()
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Parent ~= workspace.Bullets then
					return
				end

				if instance.Parent then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + cFrame.LookVector * (instance:GetAttribute("Speed") * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		StartCharge = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Yuta.Outburst.Start, instance.HumanoidRootPart, game.SoundService.Effect)
			local clone = utils.Yuta.Outburst.ChargeMeter:Clone()
			clone.Parent = humanoidRootPart
			local yutaSword = instance.SetAssets:FindFirstChild("YutaSword")

			if not yutaSword then
				return
			end

			local clone2 = utils.Yuta.Outburst.SwordCEFlash:Clone()
			clone2.Parent = yutaSword.Sword
			local bars = clone:FindFirstChild("Bars")
			TweenService:Create(bars, TweenInfo.new(0), {
				GroupTransparency = 0
			}):Play()
			local flag = nil
			local total = 0.35
			instance2:GetAttributeChangedSignal("Started"):Once(function()
				flag = true
				local count = 0

				for _ = 1, 3 do
					task.wait(0.2)

					if not instance2.Parent then
						break
					end

					count += 1
					local child = bars:FindFirstChild(count)
					v3:Flash(instance, Color3.new(1, 1, 1):Lerp(Color3.fromRGB(255, 85, 255), count / 3), 0.2)
					local v6 = v3:PlaySound(sounds.Yuta.ResoluteSlash, humanoidRootPart, game.SoundService.Effect)
					v6.Volume = 0.5
					v6.PlaybackSpeed = 2.2 - count / 3
					child.BackgroundColor3 = Color3.new(1, 1, 1)
					child.BackgroundTransparency = 0
					TweenService:Create(child, TweenInfo.new(0.2), {
						BackgroundColor3 = Color3.fromRGB(255, 85, 255)
					}):Play()
					total += 0.35
					local raycastResult = workspace:Raycast(
						humanoidRootPart.Position,
						createVector(-0, -7.5, -0),
						raycastParams
					)

					if not raycastResult then
						continue
					end

					for _, model in pairs(utils.Nanami.BluntCut.Charge:GetChildren()) do
						if not model:IsA("Model") then
							continue
						end

						local clone3 = model:Clone()
						clone3:ScaleTo(total)

						if clone3.Name == "NewSlash" then
							clone3:SetAttribute("StartTransparency", 0.5)
						end

						local v7 = SraikoVFX.HandleMesh(
							clone3,
							CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
								-1.5707963267948966,
								0,
								0
							)
						)
						clone3.Parent = workspace.Effects
						Debris:AddItem(clone3, v7)
					end
				end
			end)
			instance2.AncestryChanged:Once(function()
				TweenService:Create(bars, TweenInfo.new(1), {
					GroupTransparency = 1
				}):Play()
				Debris:AddItem(clone, 1)
				Debris:AddItem(clone2, 0.2)

				if flag then
					clone2.CursedEnergy1:Emit(2)
				end
			end)
		end,
		Slash = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Yuta.Outburst.Swing, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Yuta.ResoluteSlash.RingSwing.Attachment:Clone()
			clone.Ring.RotSpeed = NumberRange.new(-800, -200)
			clone.Parent = humanoidRootPart
			clone.Ring:Emit(8)
			Debris:AddItem(clone, 0.6)
			local clone2 = utils.Ryu.Slash:Clone()
			clone2:ScaleTo(1.7)
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Weld.C0 = CFrame.Angles(0, -0.4363323129985824, 3.141592653589793)
			clone2.Part1.Mesh.Scale = Vector3.new(-16 - p, 2, 16 + p)
			clone2.Part2.Mesh.Scale = Vector3.new(16.445 + p, 2, 16.445 + p)
			clone2.Weld.C1 = CFrame.Angles(0, -1.5707963267948966, 0)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.125)
			local tweenInfo = TweenInfo.new(0.125, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tweenInfo2 = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(clone2.Weld, tweenInfo, {
				C1 = clone2.Weld.C1 * CFrame.Angles(0, -1.7453292519943295, 0)
			}):Play()

			for _, descendant in clone2:GetDescendants() do
				if descendant:IsA("Decal") then
					descendant.Color3 = Color3.fromRGB(440, 223, 355)
					TweenService:Create(descendant, tweenInfo2, {
						Transparency = 1
					}):Play()
				elseif descendant:IsA("SpecialMesh") then
					TweenService:Create(descendant, tweenInfo, {
						Scale = descendant.Scale * 1.2
					}):Play()
				end
			end
		end,
		GroundExplode = function(cFrame, p, _)
			local clone = utils.Yuta.Outburst.OutburstExplode:Clone()
			clone:ScaleTo((p / clone.Hitbox.Size).Z)
			clone.Hitbox.CFrame = cFrame
			local pointLight = clone.Hitbox.Attachment.PointLight
			local range = pointLight.Range
			pointLight.Range = 0
			clone.Parent = workspace.Effects
			TweenService:Create(pointLight, TweenInfo.new(0.2), {
				Range = range
			}):Play()

			for _, emitter in clone:GetDescendants() do
				if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitDelay") ~= 0.5) then
					continue
				end

				if emitter:GetAttribute("EmitDelay") then
					local v6 = emitter
					task.delay(emitter:GetAttribute("EmitDelay"), function()
						v6:Emit(v6:GetAttribute("EmitCount"))
					end)
				else
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone, 3)
			v3:PlaySound(sounds.Yuta.Outburst.Charge, clone.Hitbox, game.SoundService.Effect)
			task.wait(0.5)
			TweenService:Create(pointLight, TweenInfo.new(0.1), {
				Range = 0
			}):Play()
			v3:PlaySound(sounds.Yuta.Outburst.Explosion, clone.Hitbox, game.SoundService.Effect)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitDelay") == 0.5 then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone2 = utils.Gojo.ReversalRed.RedExplode:Clone()
			clone2.Position = cFrame.Position
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 2)
			clone2.Light.Color = pointLight.Color
			clone2.Burst.Color = ColorSequence.new(Color3.fromRGB(255, 150, 255))
			clone2.Sparks.Color = ColorSequence.new(Color3.fromRGB(255, 150, 255))
			clone2.Burst:Emit(1)
			clone2.Sparks:Emit(15)
			clone2.Wind:Emit(6)
			clone2.Dust:Emit(6)
			TweenService:Create(clone2.Light, TweenInfo.new(0.5), {
				Brightness = 0
			}):Play()

			if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude < 60 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		ExplosionHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.fromRGB(255, 85, 255))
			v3:PlaySound(sounds.Yuta.Outburst.ExplosionHit, humanoidRootPart, game.SoundService.Effect)
		end,
		Clash = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p then
				v3:Flash(p, Color3.new(1, 1, 0.498039), 0.6)
			end

			v3:Flash(instance, Color3.new(1, 1, 0.498039), 0.6)
			v3:PlaySound(sounds.Misc.Items.Clash, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Misc.Items.Clash.Attachment:Clone()
			clone.Parent = humanoidRootPart
			Debris:AddItem(clone, 0.9)

			for _, light in clone:GetChildren() do
				if light:IsA("PointLight") then
					TweenService:Create(light, TweenInfo.new(light:GetAttribute("Duration")), {
						Brightness = 0
					}):Play()
				else
					light:Emit(light:GetAttribute("EmitCount"))
				end
			end

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 150 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("OutburstService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
	v4 = Knit.GetController("ToolController")
end

return controller