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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local Trove = require(replicatedStorage.Knit.Trove)
local SraikoVFX = require(replicatedStorage.Modules.SraikoVFX)
local enabled = SraikoVFX.Enabled
local emit = SraikoVFX.Emit
local emitMesh = SraikoVFX.EmitMesh
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "UltraSpinController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(parent, p)
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
			local rightArm = parent:FindFirstChild("Right Arm")

			if not (p.Parent and humanoidRootPart and rightArm) then
				return
			end

			local v5 = Trove.new()
			v5:AttachToInstance(p)
			local clone = v5:Clone(utils.Mechamaru.Drill)
			clone.Weld.Part0 = rightArm
			clone.B.Weld.Part0 = rightArm
			clone.F.Weld.Part0 = rightArm
			clone.L.Weld.Part0 = rightArm
			clone.R.Weld.Part0 = rightArm
			clone.Parent = parent
			local v6 = v3:PlaySound(sounds.Mechamaru.UltraSpin.Start, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.3)
			TweenService:Create(v6, TweenInfo.new(0.5), {
				Volume = 0
			}):Play()
			v3:PlaySound(sounds.Mechamaru.UltraSpin.Dash, humanoidRootPart, game.SoundService.Effect)
		end,
		DrillAppear = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (p.Parent and humanoidRootPart) then
				return
			end

			instance:FindFirstChild("Right Arm")
			instance:FindFirstChild("Left Arm")
			local drill = instance:FindFirstChild("Drill")

			if drill then
				EffectUtils.Visibility(drill, true)

				for _, child in utils.Mechamaru.UltraSpinVFX.DrillRepeat.Meshes:GetChildren() do
					local v5 = child
					task.spawn(function()
						for i = 1, v5:GetAttribute("RepeatCount") do
							if p.Parent and not humanoidRootPart:FindFirstChild("GrabWeld") then
								EffectUtils.AutoMeshes(v5, drill.Metalbit)
								task.wait(v5:GetAttribute("RepeatDelay"))
							else
								break
							end
						end
					end)
				end
			end

			EffectUtils.AutoEffects(utils.Mechamaru.UltraSpinVFX.DrillAppear, humanoidRootPart)
		end,
		DrillWindup = function(instance, p)
			local drill = instance:FindFirstChild("Drill")

			if p.Parent and drill then
				EffectUtils.Enable("ParticleEmitter", drill.Metalbit.Sparks)
			end
		end,
		DrillSwing = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not (p.Parent and humanoidRootPart) then
				return
			end

			local maid = Trove.new()
			maid:AttachToInstance(p)
			local v5 = EffectUtils.Enable(
				"ParticleEmitter",
				utils.Mechamaru.UltraSpinVFX.DrillSwing.WindEnable,
				humanoidRootPart,
				0.65
			)
			maid:Connect(humanoidRootPart.ChildAdded, function(p2)
				if p2.Name == "GrabWeld" then
					maid:Clean()
				end
			end)
			maid:Add(function()
				EffectUtils.Enable("ParticleEmitter", v5, nil, nil, true)
			end)
			EffectUtils.AutoEffects(utils.Mechamaru.UltraSpinVFX.DrillSwing, humanoidRootPart)
		end,
		DrillHide = function(instance)
			local drill = instance:FindFirstChild("Drill")

			if not drill then
				return
			end

			EffectUtils.Visibility(drill, false)
		end,
		DrillStop = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local drill = instance:FindFirstChild("Drill")

			if drill then
				EffectUtils.Enable("ParticleEmitter", drill, nil, nil, true)
			end

			v3:PlaySound(sounds.Mechamaru.UltraSpin.End, humanoidRootPart, game.SoundService.Effect)
		end,
		HitSound = function(instance)
			local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Mechamaru.UltraSpin.Hit, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(instance, instance2, instance3, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance3 and instance3:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			if p and instance2.Parent then
				local drill = instance:FindFirstChild("Drill")

				if drill then
					EffectUtils.Enable("ParticleEmitter", drill.Metalbit.Hits)

					for _, child in utils.Mechamaru.UltraSpinVFX.DrillRepeat.Meshes:GetChildren() do
						local v5 = child
						task.spawn(function()
							for i = 1, v5:GetAttribute("RepeatCount") do
								if not instance2.Parent then
									break
								end

								EffectUtils.AutoMeshes(v5, drill.Metalbit)
								task.wait(v5:GetAttribute("RepeatDelay"))
							end
						end)
					end
				end

				local maid = Trove.new()
				maid:AttachToInstance(instance2)
				local v5 = EffectUtils.Enable(
					"ParticleEmitter",
					utils.Mechamaru.UltraSpinVFX.DrillSwing.WindEnable,
					humanoidRootPart
				)
				maid:Add(function()
					EffectUtils.Debris(v5, 2)
					EffectUtils.Enable("ParticleEmitter", v5, nil, nil, true)
				end)
				task.spawn(function()
					local clone = utils.Mahito.Drill.DrillImpact:Clone()
					clone.Position = humanoidRootPart.Position
					clone.Parent = workspace.Effects
					Debris:AddItem(clone, 1)

					if _G.Settings.Gore == true then
						clone.Blood.Enabled = true
						clone.Hit.Enabled = true
					end

					repeat
						v3:Flash(instance3, Color3.new(1, 1, 1))
						v3:PlaySound(sounds.Mahito.DrillSplit.DrillHit, humanoidRootPart2, game.SoundService.Effect)
						BloodyZee:Blood(humanoidRootPart2.CFrame, 70, 180, 180)
						clone.Position = instance3.Torso.Position
						task.wait(0.075)
					until not instance2:IsDescendantOf(workspace.Characters) or instance2:GetAttribute("Finisher")

					clone.Blood.Enabled = false
					clone.Hit.Enabled = false
				end)
			end

			if localPlayer.Character == instance or localPlayer.Character == instance3 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyLoop)
			end
		end,
		FinalHit = function(instance, _, instance2, _)
			local humanoidRootPart = instance2 and instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance2, Color3.new(0.8, 0, 0))
			local cframe = CFrame.lookAlong(humanoidRootPart.Position, createVector(0, 1, 0))

			for _ = 1, 8 do
				BloodyZee:Blood(cframe, math.random(55, 70), 35, 35)
			end

			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			EffectUtils.AutoEffects(utils.Mechamaru.UltraSpinVFX.DrillSlam, humanoidRootPart2)
			local position = humanoidRootPart.Position - createVector(0, 3, 0)
			local clone = utils.Hiromi.Shockwave:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.CFrame *= CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
			TweenService:Create(clone.mesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Scale = createVector(15, 0, 15)
			}):Play()
			TweenService:Create(clone.mesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			clone.Floor.Glow:Emit(1)
			clone.Floor.Ring:Emit(10)
			Debris:AddItem(clone, 1.5)
			local clone2 = utils.Choso.CounterSwing.Shock:Clone()
			clone2.Size = createVector(10, 30, 10)
			clone2.CFrame = CFrame.new(position)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.3)
			TweenService:Create(clone2, TweenInfo.new(0.3), {
				Size = createVector(36, 7, 36),
				Transparency = 1,
				Position = clone2.Position - createVector(0, 3, 0)
			}):Play()
			local clone3 = utils.Choso.CounterSwing.Shock:Clone()
			clone3.Size = createVector(20, 10, 20)
			clone3.CFrame = CFrame.new(position)
			clone3.Parent = workspace.Effects
			Debris:AddItem(clone3, 0.2)
			TweenService:Create(clone3, TweenInfo.new(0.2), {
				Size = createVector(0, 36, 0),
				Transparency = 1,
				Position = clone3.Position + createVector(0, 10, 0)
			}):Play()
			v3:DustBreak(position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)
			v3:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, clone, game.SoundService.Effect)
			v3:PlaySound(sounds.Hakari.Impact, clone, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Finisher = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Mechamaru.UltraSpin.Finisher, humanoidRootPart, game.SoundService.Effect)
		end,
		DrillClose = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			emit(utils.Mechamaru.UltraSpinVFX.DrillClose.Emit.Strike, humanoidRootPart, true, 5)
			emitMesh(utils.Mechamaru.UltraSpinVFX.DrillClose.Meshes.Mesh, humanoidRootPart)
		end,
		BurstEnableTrue = function(parent)
			local rightArm = parent:FindFirstChild("Right Arm")
			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if not (rightArm and humanoidRootPart) then
				return
			end

			local clone = utils.Mechamaru["Hand blasterR"]:Clone()
			clone.Weld.Part0 = rightArm

			if parent:GetAttribute("Moveset") ~= "Mechamaru" then
				clone.BlasterR.Transparency = 1
				clone.Neon.Transparency = 1
			end

			clone.Parent = parent
			Debris:AddItem(clone, 4)
			emit(utils.Mechamaru.UltraSpinVFX.ShootReady.Emit.Strike, humanoidRootPart, true, 5)
			emitMesh(utils.Mechamaru.UltraSpinVFX.ShootReady.Meshes.Mesh, humanoidRootPart)
		end,
		BurstEnableFalse = function(instance)
			local handblasterR = instance:FindFirstChild("Hand blasterR")
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if handblasterR and humanoidRootPart then
				enabled(handblasterR, false)
				emit(utils.Mechamaru.UltraSpinVFX.Shoot.Emit.Strike, humanoidRootPart, true, 5)
			end
		end,
		Burn = function(instance, object)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mechamaru.UltraSpinVFX.Burn.Emit.Strike:Clone()
			enabled(clone, true, humanoidRootPart, true, 4, { "Beam", "ParticleEmitter" })
			clone.Parent = workspace.Effects
			emitMesh(utils.Mechamaru.UltraSpinVFX.Burn.Meshes.Mesh, humanoidRootPart)
			object:GetAttributeChangedSignal("Disable"):Once(function()
				enabled(clone, false, nil, nil, nil, { "Beam", "ParticleEmitter" })
			end)
		end,
		Burn2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			emitMesh(utils.Mechamaru.UltraSpinVFX.Burn2.Meshes.Mesh, humanoidRootPart)
		end,
		Burn3 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			emitMesh(utils.Mechamaru.UltraSpinVFX.Burn3.Meshes.Mesh, humanoidRootPart)
		end,
		Strike2 = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			emitMesh(utils.Mechamaru.UltraSpinVFX.Burn4.Meshes.Mesh, humanoidRootPart)
			instance2:SetAttribute("Disable", true)
			local clone = utils.Mechamaru.UltraSpinVFX.Burn.Emit.Strike2:Clone()
			enabled(clone, true, humanoidRootPart, true, 4, { "Beam", "ParticleEmitter" })
			clone.Parent = workspace.Effects
			instance2:GetAttributeChangedSignal("Disable"):Once(function()
				enabled(clone, false, nil, nil, nil, { "Beam", "ParticleEmitter" })
			end)
		end,
		Burnt = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			emit(utils.Mechamaru.UltraSpinVFX.Burnt.Emit.Strike, humanoidRootPart, true, 5)
		end,
		BurnFalse = function(_, instance)
			instance:SetAttribute("Disable", nil)
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
	v = Knit.GetService("UltraSpinService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller