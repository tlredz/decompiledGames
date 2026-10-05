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
require(replicatedStorage.Modules.EffectUtils)
local Trove = require(replicatedStorage.Knit.Trove)
local SraikoVFX = require(replicatedStorage.Modules.SraikoVFX)
local enabled = SraikoVFX.Enabled
local emit = SraikoVFX.Emit
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local controller = Knit.CreateController({
	Name = "BoostOnController"
})

function controller.KnitStart(_)
	local v5 = {
		Start = function(parent, p)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v6 = Trove.new()
			v6:AttachToInstance(p)
			local clone = v6:Clone(replicatedStorage.Utils.Mechamaru.BoosterL)
			clone.Parent = parent
			local clone2 = v6:Clone(replicatedStorage.Utils.Mechamaru.BoosterR)
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
			v4:PlaySound(sounds.Mechamaru.BoostOn.PunchWoosh, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.1)
			v4:PlaySound(sounds.Mechamaru.BoostOn.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Boost = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v4:PlaySound(sounds.Mechamaru.BoostOn.Booster, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mechamaru.BoostOnVFX.BoostHit.Meshes.Mesh:Clone()
			local v6 = SraikoVFX.HandleMesh(
				clone,
				humanoidRootPart.CFrame * CFrame.Angles(1.0471975511965976, 0, 0) * clone.Offset.Value
			)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, v6)
			emit(utils.Mechamaru.BoostOnVFX.BoostHit.Emit.Strike, humanoidRootPart, true, 3)
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
				v4:PlaySound(sounds.Mechamaru.BoostOn.SecondPart, humanoidRootPart, game.SoundService.Effect)
			end
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

			v4:Flash(instance2, Color3.new(1, 1, 1))
			v4:PlaySound(sounds.Mechamaru.BoostOn.Hit, humanoidRootPart2, game.SoundService.Effect)
			v4:PlaySound(sounds.Mechamaru.PuppetBarrage.FlyUp, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Touch = function(parent, instance, p)
			if not parent:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v4:Flash(instance, Color3.new(1, 1, 1))
			v4:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
			local v6 = Trove.new()
			v6:AttachToInstance(p)
			local rightArm = parent:FindFirstChild("Right Arm")

			if not rightArm then
				return
			end

			local clone = v6:Clone(utils.Mechamaru["Hand blasterR"])
			clone.Weld.Part0 = rightArm

			if parent:GetAttribute("Moveset") ~= "Mechamaru" then
				clone.BlasterL.Transparency = 1
				clone.Neon.Transparency = 1
			end

			clone.Parent = parent
		end,
		Blast = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local cFrame = (humanoidRootPart.CFrame - createVector(0, 2, 0)) * CFrame.Angles(-0.8726646259971648, 0, 0)
			v4:PlaySound(sounds.Mechamaru.UltraCannon.Shoot, humanoidRootPart, game.SoundService.Effect)
			v4:PlaySound(sounds.Mechamaru.UltraCannon.Explode, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mechamaru.Heat:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = cFrame
			Debris:AddItem(clone, 1.5)
			clone.Flames:Emit(30)
			clone.Attachment.Wind2:Emit(5)
			local clone2 = utils.Misc.M.DashHit:Clone()
			clone2.Position = humanoidRootPart.Position
			clone2.Parent = workspace.Effects

			for _, emitter in clone2:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone2, 1)
			local clone3 = utils.Misc.M.Slash.PointLight:Clone()
			clone3.Parent = clone
			clone3.Brightness = 15
			TweenService:Create(clone3, TweenInfo.new(0.6), {
				Brightness = 0,
				Color = Color3.new(1, 0, 0)
			}):Play()
			local clone4 = utils.Mechamaru.CannonFire:Clone()
			clone4:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(-0.8726646259971648, 0, 0) * CFrame.new(0, 0, -34))
			clone4.Parent = workspace.Effects
			Debris:AddItem(clone4, 1)

			for _, child in clone4:GetChildren() do
				child.Size *= createVector(3, 3, 1)
				TweenService:Create(child, TweenInfo.new(0.6), {
					Size = Vector3.new(0, 0, child.Size.Z),
					CFrame = child.CFrame - child.CFrame.LookVector * 5
				}):Play()
				Debris:AddItem(child, 0.6)
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
	v = Knit.GetService("BoostOnService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("ToolController")
	v4 = Knit.GetController("FXController")
end

return controller