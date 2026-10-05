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
require(replicatedStorage.Modules.LightningBeams)
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
Random.new()
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local controller = Knit.CreateController({
	Name = "CollapseController"
})

function controller.KnitStart(_)
	local v5 = {
		Hit = function(p, p2)
			local humanoidRootPart = p2.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			v2:Flash(p2, Color3.new(0.333333, 0.666667, 1), 0.2)
			local clone = utils.Nanami.Collapse.Slam.Emit.Strike.Hit:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(0.75)
			Debris:AddItem(model, 0.1)
			clone.Parent = humanoidRootPart

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				local v6 = emitter
				task.delay(0.05, function()
					v6.TimeScale = 0.1
				end)
				local v7 = emitter
				task.delay(0.221, function()
					v7.TimeScale = 1
				end)
			end

			if p == localPlayer.Character or p2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Hit2 = function(p, p2)
			if not p2.HumanoidRootPart then
				return
			end

			v2:Flash(p2, Color3.new(0.333333, 0.666667, 1), 0.2)

			if p == localPlayer.Character or p2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Jump = function(p, p2)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart or p2 then
				return
			end

			v2:PlaySound(sounds.Nanami.Collapse.Jump, humanoidRootPart, game.SoundService.Effect)
			local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -10, 0), raycastParams)

			if raycastResult then
				for _, child in pairs(utils.Nanami.Collapse.Jump.Meshes:GetChildren()) do
					local clone = child:Clone()
					local v6 = SraikoVFX.HandleMesh(
						clone,
						CFrame.new(raycastResult.Position) * (p.HumanoidRootPart.CFrame - p.HumanoidRootPart.CFrame.Position) * CFrame.Angles(
							0.5235987755982988,
							0,
							0
						)
					)
					clone.Parent = workspace.Effects
					Debris:AddItem(clone, v6)
				end

				SraikoVFX.Emit(
					utils.Nanami.Collapse.Jump.Jump,
					CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal) * CFrame.Angles(
						-1.5707963267948966,
						0,
						0
					)
				)
			end
		end,
		ArmEmit = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			for _, child in pairs(utils.Nanami.Collapse.ChargeEmit.Meshes:GetChildren()) do
				local clone = child:Clone()
				local v6 = SraikoVFX.HandleMesh(clone, humanoidRootPart.CFrame)
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, v6)
			end

			local clone = utils.Nanami.Collapse.ChargeEmit.Emit.Strike:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect:Emit(effect:GetAttribute("EmitCount"))
				end

				if not effect:IsA("Beam") then
					continue
				end

				effect.Enabled = true
				TweenService:Create(effect, TweenInfo.new(0.3), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				local v6 = effect
				task.delay(0.4, function()
					v6.Enabled = false
					v6.Width0 = 25
					v6.Width1 = 25
				end)
			end

			v2:PlaySound(sounds.Nanami.Collapse.Charge, humanoidRootPart, game.SoundService.Effect)
		end,
		Leap = function(instance, p, object, _, _)
			local humanoidRootPart = instance.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")

			if not humanoid then
				return
			end

			if localPlayer.Character == instance then
				local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
				local _ = assemblyLinearVelocity.Magnitude
				local position = humanoidRootPart.Position + assemblyLinearVelocity / 10
				local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
				bodyGyro.P = 0
				bodyGyro.MaxTorque = createVector(0, 0, 0)
				p.Position = position
				local lastTime = tick()
				humanoid.PlatformStand = true
				local v7 = false

				while true do
					local v8 = RunService.Heartbeat:Wait()
					local unit = assemblyLinearVelocity.Unit
					local X = bodyGyro.MaxTorque.X
					local v9 = X + (40000 - X) * 25 * v8
					bodyGyro.MaxTorque = Vector3.new(v9, v9, v9)
					bodyGyro.P += (10000 - bodyGyro.P) * 25 * v8
					local unit2 = unit:Lerp(workspace.CurrentCamera.CFrame.LookVector, 25 * v8).Unit
					assemblyLinearVelocity = assemblyLinearVelocity:Lerp(
						unit2 * assemblyLinearVelocity.Magnitude,
						25 * v8
					) + Vector3.new(0, -workspace.Gravity, 0) * v8
					position += assemblyLinearVelocity * v8
					local raycastResult = workspace:Raycast(
						humanoidRootPart.Position,
						assemblyLinearVelocity.Unit * 10,
						_G.MapParams
					)

					if raycastResult then
						position = raycastResult.Position - assemblyLinearVelocity.Unit * 5

						if not v7 and tick() - lastTime > 0.3 then
							object:FireServer(raycastResult.Position, raycastResult.Normal, humanoidRootPart.Position)
							v7 = true
						end
					end

					p.Position = position
					bodyGyro.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + unit2)
					task.wait()

					if p.Parent then
						continue
					end

					bodyGyro:Destroy()

					repeat
						task.wait()
					until not humanoidRootPart:FindFirstChild("CollapseBG")

					humanoid.PlatformStand = false
					break
				end
			end
		end,
		Collapse = function(p, position, p2)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.LapseBlue.Grab:Clone()
			clone.Weld:Destroy()
			clone.Anchored = true
			clone.Position = position
			clone.Size = createVector(50, 50, 50)
			clone.Parent = workspace.Effects
			local highlight = Instance.new("Highlight", clone)
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			TweenService:Create(clone, TweenInfo.new(0.226, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
				Size = createVector(0, 0, 0),
				Transparency = 50
			}):Play()
			Debris:AddItem(clone, 0.5)
			local clone2 = utils.Nanami.Collapse.OrbEmit.Strike:Clone()
			clone2.CFrame = CFrame.new(position, position + p2) * CFrame.new(0, 0, -2)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 6)
			clone2.Beams.WorldCFrame = CFrame.lookAt(
				position,
				(humanoidRootPart.CFrame * CFrame.new(0, -4.5, 0)).Position
			) * CFrame.new(0, 0, -1) * CFrame.Angles(0, 3.141592653589793, 0)
			clone2.Beams2.WorldCFrame = CFrame.lookAt(
				position,
				(humanoidRootPart.CFrame * CFrame.new(0, -4.5, 0)).Position
			) * CFrame.new(0, 0, -1) * CFrame.Angles(0, 3.141592653589793, 0)

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end

			for _, beam in pairs(clone2.Beams:GetDescendants()) do
				if beam:IsA("Beam") then
					beam.Enabled = true
				end
			end

			v2:PlaySound(sounds.Nanami.Collapse.Impact, clone2, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 100 then
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap):StartFadeOut(0.226)
			end

			task.wait(0.226)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 100 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			for _, effect in pairs(clone2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end

				if effect:IsA("Beam") then
					effect.Enabled = false
				end
			end

			for _, child in pairs(utils.Nanami.Collapse.Slam.Meshes:GetChildren()) do
				local clone3 = child:Clone()
				local v6 = SraikoVFX.HandleMesh(clone3, CFrame.new(position, position + p2) * CFrame.new(0, 0, 7))
				clone3.Parent = workspace.Effects
				Debris:AddItem(clone3, v6)
			end

			SraikoVFX.Emit(utils.Nanami.Collapse.Slam.Emit.Strike, CFrame.new(position, position + p2))

			for _, beam in pairs(clone2.Beams2:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = true
				TweenService:Create(beam, TweenInfo.new(0.2), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				local v6 = beam
				task.delay(0.30000000000000004, function()
					v6.Enabled = false
					v6.Width0 = 45
					v6.Width1 = 45
				end)
			end
		end,
		CollapseDebree = function(p, buf, instance)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			RunService.Heartbeat:Wait()
			local clones = {}
			instance.AncestryChanged:Once(function()
				v2:PlaySound(sounds.Nanami.Collapse.Activate, humanoidRootPart, game.SoundService.Effect)
				task.wait(0.5)

				for _, v6 in pairs(clones) do
					v6:Destroy()
				end
			end)

			for i = 1, buffer.len(buf) / 2 do
				local v6 = buffer.readu16(buf, (i - 1) * 2)
				local voxel = v2.Voxels[v6]

				if not (voxel[2] == nil or voxel[2] ~= false) then
					continue
				end

				for _, child in pairs(utils.Nanami.Collapse.Rock:GetChildren()) do
					local clone = child:Clone()
					table.insert(clones, clone)
					clone.Parent = voxel[1]
					Debris:AddItem(clone, 10)
				end
			end
		end,
		Break = function(position)
			local clone = utils.Nanami.Collapse.Break:Clone()
			clone.CFrame = CFrame.new(position)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 3)
			local playSound = v2:PlaySound(sounds.Nanami.Collapse.DebreeDrop, clone, game.SoundService.Effect)
			playSound.PlaybackSpeed = math.random(90, 110) / 100

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 65 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Launch = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Size = createVector(0, 0, 5)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.3), {
				Size = createVector(8, 8, 0),
				Transparency = 1,
				Position = clone.Position + Vector3.new(0, p, 0)
			}):Play()
			Debris:AddItem(clone, 0.3)

			if p < 0 then
				v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, humanoidRootPart, game.SoundService.Effect)
				v2:DustBreak(humanoidRootPart.Position + createVector(0, 2, 0), createVector(0, 1, 0), 6, 15, 0.4, 1)

				if localPlayer:DistanceFromCharacter(humanoidRootPart.Position) < 20 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
				end
			end
		end,
		Finisher = function(p)
			if not p.HumanoidRootPart then
				return
			end

			if _G.Settings.Gore then
				local clone = utils.Heian.BloodSpread:Clone()
				clone.Parent = p.Head
				clone:Emit(20)
				Debris:AddItem(clone, 2)
			end

			v2:Bleed(p)
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
	v = Knit.GetService("CollapseService")
	v3 = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
	v4 = Knit.GetController("HandicapController")
end

return controller