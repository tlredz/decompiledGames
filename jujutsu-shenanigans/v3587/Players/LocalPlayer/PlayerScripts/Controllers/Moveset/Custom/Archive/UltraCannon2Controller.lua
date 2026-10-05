local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local EffectUtils = require(replicatedStorage.Modules.EffectUtils)
local Trove = require(replicatedStorage.Knit.Trove)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local controller = Knit.CreateController({
	Name = "UltraCannon2Controller"
})

function controller.KnitStart(_)
	local v5 = {
		Aerial = function(instance, instance2)
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
			instance2.Position = humanoidRootPart.Position + createVector(0, 6, 0)
			humanoid.PlatformStand = true

			repeat
				local mouseTarget = v3:GetMouseTarget()
				bodyGyro.CFrame = instance2:GetAttribute("Aim") or CFrame.new(humanoidRootPart.Position, mouseTarget)
				task.wait()
			until not instance2.Parent

			bodyGyro:Destroy()
			humanoid.PlatformStand = false
		end,
		Start = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local maid = Trove.new()
			maid:AttachToInstance(p)
			maid:Add(v4:PlaySound(sounds.Mechamaru.UltraCannon.Start, humanoidRootPart, game.SoundService.Effect))
		end,
		ChargeStart = function(parent, p)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				EffectUtils.AutoEffects(utils.Mechamaru.UltraCannonVFX.ChargeStart, humanoidRootPart)
			end

			local leftArm = parent:FindFirstChild("Left Arm")

			if leftArm then
				local v6 = Trove.new()
				v6:AttachToInstance(p)
				local clone = v6:Clone(utils.Mechamaru["Hand blasterL"])
				clone.Weld.Part0 = leftArm

				if parent:GetAttribute("Moveset") ~= "Mechamaru" then
					clone.BlasterL.Transparency = 1
					clone.Neon.Transparency = 1
				end

				clone.Parent = parent
			end

			if localPlayer.Character == parent then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightLoop)
			end
		end,
		AlbatrosStart = function(parent, p)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				EffectUtils.AutoEffects(utils.Mechamaru.UltraCannonVFX.AlbatrosStart, humanoidRootPart)
				v4:PlaySound(sounds.Mechamaru.UltraCannon.Albatros, humanoidRootPart, game.SoundService.Effect)
			end

			local maid = Trove.new()
			maid:AttachToInstance(p)
			local head = parent:FindFirstChild("Head")

			if head and parent:GetAttribute("Moveset") == "Mechamaru" then
				local clone = maid:Clone(utils.Mechamaru["Mecha mouth blaster"])
				clone.Weld.Part0 = head
				clone.Parent = parent
			end

			local function AddBooster(childName)
				local child = parent:FindFirstChild(childName)

				if not child then
					return
				end

				local clone = utils.Mechamaru[`Booster{childName:sub(1, 1)}`]:Clone()
				clone.Weld.Part0 = child
				local unionOperation = clone:FindFirstChildOfClass("UnionOperation")
				unionOperation.Stage1:Destroy()
				unionOperation.Stage2:Destroy()

				if parent:GetAttribute("Moveset") ~= "Mechamaru" then
					EffectUtils.Visibility(clone, false)
				end

				maid:Add(function()
					Debris:AddItem(clone, 0.3)
					EffectUtils.Visibility(clone, false, 0.15)
				end)
				clone.Parent = parent
			end

			AddBooster("Left Arm")
			AddBooster("Right Arm")
			local _ = localPlayer.Character == parent
		end,
		AlbatrosCharge = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				local maid = Trove.new()
				maid:AttachToInstance(p)
				maid:Add(EffectUtils.Enable(
					"ParticleEmitter",
					utils.Mechamaru.UltraCannonVFX.AlbatrosCharge.Enable.AlbatrosChargeEnable,
					humanoidRootPart
				))
				EffectUtils.AutoEffects(utils.Mechamaru.UltraCannonVFX.AlbatrosCharge, humanoidRootPart)
			end

			local handblasterL = instance:FindFirstChild("Hand blasterL")

			if handblasterL then
				EffectUtils.Enable("ParticleEmitter", handblasterL, nil, nil, true)
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
			end
		end,
		AlbatrosFire = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local maid = Trove.new()
			maid:AttachToInstance(p)
			local distance = 37.5
			local v6 = maid:Add(EffectUtils.Enable(
				{ "ParticleEmitter", "Beam" },
				utils.Mechamaru.UltraCannonVFX.AlbatrosFire.Beam,
				humanoidRootPart,
				1.75
			))
			v6.Weld.C0 = CFrame.Angles(0, 3.141592653589793, 0)
			local albatrosChargeEnable = humanoidRootPart:FindFirstChild("AlbatrosChargeEnable")

			if albatrosChargeEnable then
				albatrosChargeEnable:Destroy()
			end

			local v7 = maid:Add(EffectUtils.Enable(
				"ParticleEmitter",
				utils.Mechamaru.UltraCannonVFX.AlbatrosFire.Enable,
				humanoidRootPart,
				1.75
			))

			local function AddBoosterFX(childName)
				local child = instance:FindFirstChild(childName)
				local unionOperation = child and child:FindFirstChildOfClass("UnionOperation")

				if not unionOperation then
					return
				end

				EffectUtils.Enable(
					"ParticleEmitter",
					utils.Mechamaru.UltraCannonVFX.AlbatrosFire[`{childName}Enable`],
					unionOperation,
					1.75
				)
			end

			local boosterL = instance:FindFirstChild("BoosterL")
			local unionOperation = boosterL and boosterL:FindFirstChildOfClass("UnionOperation")

			if unionOperation then
				EffectUtils.Enable(
					"ParticleEmitter",
					utils.Mechamaru.UltraCannonVFX.AlbatrosFire.BoosterLEnable,
					unionOperation,
					1.75
				)
			end

			local boosterR = instance:FindFirstChild("BoosterR")
			local unionOperation2 = boosterR and boosterR:FindFirstChildOfClass("UnionOperation")

			if unionOperation2 then
				EffectUtils.Enable(
					"ParticleEmitter",
					utils.Mechamaru.UltraCannonVFX.AlbatrosFire.BoosterREnable,
					unionOperation2,
					1.75
				)
			end

			task.spawn(function()
				local coneSwirl = utils.Mechamaru.UltraCannonVFX.AlbatrosRepeat.ConeSwirl
				local repeatCount = coneSwirl:GetAttribute("RepeatCount")
				local repeatDelay = coneSwirl:GetAttribute("RepeatDelay")

				for _ = 1, repeatCount do
					if not p.Parent then
						break
					end

					EffectUtils.AutoMeshes(coneSwirl, humanoidRootPart)
					task.wait(repeatDelay)
				end
			end)
			task.spawn(function()
				for _ = 1, 21 do
					if not (p.Parent and humanoidRootPart.Parent) then
						break
					end

					local raycastResult = workspace:Raycast(
						humanoidRootPart.Position,
						humanoidRootPart.CFrame.LookVector * 37.5,
						_G.MapParams
					)
					distance = raycastResult and raycastResult.Distance or 37.5

					if v6.Parent then
						v6.End.CFrame = CFrame.new(0, 0, distance)
						v6.End2.CFrame = CFrame.new(0, 0, distance / 1.2)
						v6.Attachment.CFrame = CFrame.new(0, 0, distance / 3) * CFrame.Angles(0, 3.141592653589793, 0)
					end

					if v7.Parent then
						v7.Wind.Size = vector.create(1, 0.187, distance / 1.3)
						v7.Wind.Weld.C0 = CFrame.new(0, -3.1, -distance / 1.2)

						for _, emitter in v7.Attachment1:GetChildren() do
							if emitter:IsA("ParticleEmitter") then
								emitter.Speed = NumberRange.new(0, emitter:GetAttribute("MaxSpeed") * (distance / 37.5))
							end
						end
					end

					for _, child in utils.Mechamaru.UltraCannonVFX.AlbatrosRepeat.Beam:GetChildren() do
						local clone = child.Start:Clone()
						Debris:AddItem(clone, 0.15)
						clone.CFrame = humanoidRootPart.CFrame * clone.CFrame
						local size = child.End.Size
						EffectUtils.Tween(clone, 0.15, "Cubic", "Out", {
							CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -distance / 2 - 2),
							Size = vector.create(size.X, size.Y, size.Z - 23 + distance)
						})
						clone.Parent = workspace.Effects
					end

					if localPlayer.Character == instance then
						CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
					end

					task.wait(0.07)
				end

				task.wait(0.2)

				if p.Parent and localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
				end
			end)
			EffectUtils.AutoEffects(utils.Mechamaru.UltraCannonVFX.FireCannon, humanoidRootPart)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
			end
		end,
		AlbatrosHit = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v4:Flash(instance, Color3.fromRGB(255, 255, 255))
		end,
		FireCannon = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				EffectUtils.AutoEffects(utils.Mechamaru.UltraCannonVFX.FireCannon, humanoidRootPart)
				v4:PlaySound(sounds.Mechamaru.UltraCannon.Shoot, humanoidRootPart, game.SoundService.Effect)
			end

			local handblasterL = instance:FindFirstChild("Hand blasterL")

			if handblasterL then
				EffectUtils.Enable("ParticleEmitter", handblasterL, nil, nil, true)
			end

			if instance2.Parent then
				local cFrame = instance2.CFrame
				local lastTime = tick()
				local positionChangedConnection = instance2:GetPropertyChangedSignal("Position"):Connect(function()
					cFrame = instance2.CFrame
					lastTime = tick()
				end)
				local steppedConnection = nil
				steppedConnection = RunService.Stepped:Connect(function()
					if instance2.Parent then
						workspace:BulkMoveTo(
							{ instance2 },
							{ cFrame + cFrame.LookVector * (180 * (tick() - lastTime)) },
							Enum.BulkMoveMode.FireCFrameChanged
						)
						return
					end

					steppedConnection:Disconnect()
					positionChangedConnection:Disconnect()
				end)
			end

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		ProjectileCancel = function(p)
			if not p.Parent then
				return
			end

			p.Transparency = 1
			EffectUtils.Enable({ "ParticleEmitter", "Trail" }, p, nil, nil, true)
		end,
		ProjectileExplode = function(instance)
			if not instance.Parent then
				return
			end

			instance.Transparency = 1
			EffectUtils.Enable({ "ParticleEmitter", "Trail" }, instance, nil, nil, true)
			EffectUtils.AutoEffects(utils.Mechamaru.UltraCannonVFX.ProjectileExplode, instance)
			v4:PlaySound(sounds.Mechamaru.UltraCannon.Explode, instance, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - instance.Position).Magnitude <= 60 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
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
	v = Knit.GetService("UltraCannon2Service")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("ToolController")
	v4 = Knit.GetController("FXController")
end

return controller