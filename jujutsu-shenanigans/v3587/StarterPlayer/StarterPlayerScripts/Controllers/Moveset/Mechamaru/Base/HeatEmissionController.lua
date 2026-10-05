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
local EffectUtils = require(replicatedStorage.Modules.EffectUtils)
local Trove = require(replicatedStorage.Knit.Trove)
local SraikoVFX = require(replicatedStorage.Modules.SraikoVFX)
local enabled = SraikoVFX.Enabled
local emit = SraikoVFX.Emit
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "HeatEmissionController"
})

function controller.KnitStart(_)
	local v3 = {
		Start = function(parent, p)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v4 = Trove.new()
			v4:AttachToInstance(p)
			local clone = v4:Clone(replicatedStorage.Utils.Mechamaru.BoosterL)
			clone.Parent = parent
			local clone2 = v4:Clone(replicatedStorage.Utils.Mechamaru.BoosterR)
			clone2.Parent = parent

			local function CreateBoosterWeld(part, p2)
				local motor6D = Instance.new("Motor6D")
				motor6D.C0 = CFrame.new(0, 0.75, 0.625) * CFrame.Angles(0.7853981633974483, 0, 0)
				motor6D.Part0 = p2
				motor6D.Part1 = part
				motor6D.Name = part.Name
				motor6D.Parent = p2
				part.Parent.AncestryChanged:Once(function()
					motor6D:Destroy()
				end)
			end

			CreateBoosterWeld(clone2["Arm BoostterrrrR"], parent["Right Arm"])
			CreateBoosterWeld(clone["Arm BoostterrrrL"], parent["Left Arm"])
			v2:PlaySound(sounds.Mechamaru.HeatEmission.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Leap = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mechamaru.BoostOnVFX.BoostHit.Meshes.Mesh:Clone()
			local v4 = SraikoVFX.HandleMesh(clone, humanoidRootPart.CFrame * clone.Offset.Value)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, v4)
			emit(utils.Mechamaru.BoostOnVFX.BoostHit.Emit.Strike, humanoidRootPart, true, 3)
			local clone2 = utils.Hiromi.Shockwave:Clone()
			clone2.Position = humanoidRootPart.Position - createVector(0, 3, 0)
			clone2.Parent = workspace.Effects
			local clone3 = utils.Misc.M.DashHit:Clone()
			clone3.Position = humanoidRootPart.Position - createVector(0, 3, 0)
			clone3.Parent = workspace.Effects

			for _, emitter in clone3:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone3, 1)
			local clone4 = utils.Misc.M.Slash.PointLight:Clone()
			clone4.Parent = clone3
			TweenService:Create(clone4, TweenInfo.new(0.6), {
				Brightness = 0,
				Color = Color3.new(1, 0, 0)
			}):Play()
			clone2.CFrame *= CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
			TweenService:Create(clone2.mesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Scale = createVector(15, 0, 15)
			}):Play()
			TweenService:Create(clone2.mesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			clone2.Floor.Glow:Emit(1)
			clone2.Floor.Ring:Emit(10)
			Debris:AddItem(clone2, 1.5)
			local boosterR = instance:FindFirstChild("BoosterR")
			local boosterL = instance:FindFirstChild("BoosterL")

			if boosterR and boosterL then
				enabled(boosterR["Arm BoostterrrrR"].Stage1, false)
				enabled(boosterR["Arm BoostterrrrR"].Stage2, true)
				enabled(boosterL["Arm BoostterrrrL"].Stage1, false)
				enabled(boosterL["Arm BoostterrrrL"].Stage2, true)
				task.wait(0.4)
				enabled(boosterR["Arm BoostterrrrR"].Stage2, false)
				enabled(boosterL["Arm BoostterrrrL"].Stage2, false)
			end
		end,
		Blast = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local cFrame = (humanoidRootPart.CFrame - createVector(0, 2, 0)) * CFrame.Angles(-0.5235987755982988, 0, 0)
			v2:PlaySound(sounds.Mechamaru.HeatEmission.Vent, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mechamaru.BoostOnVFX.BoostHit.Meshes.Mesh:Clone()
			local v5 = SraikoVFX.HandleMesh(clone, cFrame * clone.Offset.Value)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, v5)
			local clone2 = utils.Mechamaru.Heat:Clone()
			clone2.Parent = workspace.Effects
			clone2.CFrame = cFrame
			clone2.Smoke:Emit(30)
			Debris:AddItem(clone2, 1.5)
			local clone3 = utils.Misc.M.Slash.PointLight:Clone()
			clone3.Parent = clone2

			if p then
				clone2.Flames:Emit(30)
				clone2.Attachment.Wind2:Emit(5)
				EffectUtils.AutoEffects(utils.Mechamaru.UltraCannonVFX.FireCannon, humanoidRootPart)
				v2:PlaySound(sounds.Mechamaru.HeatEmission.Ignition, humanoidRootPart, game.SoundService.Effect)
				clone3.Brightness = 15
				TweenService:Create(clone3, TweenInfo.new(0.6), {
					Brightness = 0,
					Color = Color3.new(1, 0, 0)
				}):Play()

				if localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
				end
			else
				local clone4 = utils.Choso.CounterSwing.Shock:Clone()
				clone4.Size = createVector(6, 30, 6)
				clone4.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone4.Parent = workspace.Effects
				Debris:AddItem(clone4, 0.2)
				TweenService:Create(clone4, TweenInfo.new(0.2), {
					Size = createVector(25, 0, 25),
					Transparency = 1,
					Position = clone4.Position + humanoidRootPart.CFrame.LookVector * 10
				}):Play()
				TweenService:Create(clone3, TweenInfo.new(0.1), {
					Brightness = 0,
					Color = Color3.new(1, 0, 0)
				}):Play()

				if localPlayer.Character == instance then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				end
			end
		end,
		Hit = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			task.delay(0.4, function()
				v2:PlaySound(sounds.Naoya.Decisive.Swing2, humanoidRootPart, game.SoundService.Effect)
			end)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
	v = Knit.GetService("HeatEmissionService")
	v2 = Knit.GetController("FXController")
end

return controller