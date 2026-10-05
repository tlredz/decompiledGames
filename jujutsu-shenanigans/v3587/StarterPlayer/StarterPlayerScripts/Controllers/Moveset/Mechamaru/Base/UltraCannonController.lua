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
local EffectUtils = require(replicatedStorage.Modules.EffectUtils)
local Trove = require(replicatedStorage.Knit.Trove)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "UltraCannonController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(parent, p, object, p2)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local maid = Trove.new()
			maid:AttachToInstance(p)
			maid:Add(v2:PlaySound(sounds.Mechamaru.UltraCannon.Start, humanoidRootPart, game.SoundService.Effect))
			local leftArm = parent:FindFirstChild("Left Arm")

			if leftArm then
				local clone = maid:Clone(utils.Mechamaru["Hand blasterL"])
				clone.Weld.Part0 = leftArm

				if parent:GetAttribute("Moveset") ~= "Mechamaru" then
					clone.BlasterL.Transparency = 1
					clone.Neon.Transparency = 1
				end

				clone.Parent = parent
			end

			if p2 and object and localPlayer.Character == p2 then
				repeat
					object:FireServer((v3:GetMouseTarget(75)))
					task.wait()
				until not object.Parent
			end
		end,
		FireCannon = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				EffectUtils.AutoEffects(utils.Mechamaru.UltraCannonVFX.FireCannon, humanoidRootPart)
				v2:PlaySound(sounds.Mechamaru.UltraCannon.Shoot, humanoidRootPart, game.SoundService.Effect)
			end

			local handblasterL = instance:FindFirstChild("Hand blasterL")

			if handblasterL then
				EffectUtils.Enable("ParticleEmitter", handblasterL, nil, nil, true)
			end

			local clone = utils.Mechamaru.CannonFire:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(0, 0, -34))
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)

			for _, child in clone:GetChildren() do
				TweenService:Create(child, TweenInfo.new(0.3), {
					Size = Vector3.new(0, 0, child.Size.Z),
					CFrame = child.CFrame - child.CFrame.LookVector * 5
				}):Play()
				Debris:AddItem(child, 0.3)
			end

			local model = Instance.new("Model")
			local clone2 = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
			clone2.Parent = model
			model.Parent = workspace.Effects
			model:ScaleTo(0.6)
			clone2.Ring:Emit(7)
			clone2.Dash1.Dash:Emit(1)
			clone2.Dash2.Dash:Emit(1)
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Quad), {
				CFrame = clone2.CFrame - clone2.CFrame.LookVector * 16
			}):Play()
			Debris:AddItem(model, 2)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		AlbatrosStart = function(parent, p)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				EffectUtils.AutoEffects(utils.Mechamaru.UltraCannonVFX.AlbatrosStart, humanoidRootPart)
				v2:PlaySound(sounds.Mechamaru.UltraCannon.Albatros, humanoidRootPart, game.SoundService.Effect)
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
			local v5 = maid:Add(EffectUtils.Enable(
				{ "ParticleEmitter", "Beam" },
				utils.Mechamaru.UltraCannonVFX.AlbatrosFire.Beam,
				humanoidRootPart,
				1.75
			))
			v5.Weld.C0 = CFrame.Angles(0, 3.141592653589793, 0)
			local albatrosChargeEnable = humanoidRootPart:FindFirstChild("AlbatrosChargeEnable")

			if albatrosChargeEnable then
				albatrosChargeEnable:Destroy()
			end

			local v6 = maid:Add(EffectUtils.Enable(
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

					if v5.Parent then
						v5.End.CFrame = CFrame.new(0, 0, distance)
						v5.End2.CFrame = CFrame.new(0, 0, distance / 1.2)
						v5.Attachment.CFrame = CFrame.new(0, 0, distance / 3) * CFrame.Angles(0, 3.141592653589793, 0)
					end

					if v6.Parent then
						v6.Wind.Size = vector.create(1, 0.187, distance / 1.3)
						v6.Wind.Weld.C0 = CFrame.new(0, -3.1, -distance / 1.2)

						for _, emitter in v6.Attachment1:GetChildren() do
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

			v2:Flash(instance, Color3.fromRGB(255, 255, 255))
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
	v = Knit.GetService("UltraCannonService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller