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
	Name = "TechniqueChargeController"
})

function controller.KnitStart(_)
	local v4 = {
		FingertipLightning = function(instance, instance2)
			local fingersR = instance:FindFirstChild("FingersR")

			if not fingersR then
				return
			end

			local gunEffects = fingersR:FindFirstChild("GunEffects", true)

			if not gunEffects then
				return
			end

			gunEffects.Lightning.Enabled = true
			gunEffects.PointLight.Enabled = true
			v3:PlaySound(sounds.Mechamaru.Absolute.Special.LightningStart, gunEffects, game.SoundService.Effect)
			local v5 = v3:PlaySound(
				sounds.Mechamaru.Absolute.Special.LightningLoop,
				gunEffects,
				game.SoundService.Effect
			)
			instance2.AncestryChanged:Wait()
			v5:Destroy()
			gunEffects.Lightning.Enabled = false
			gunEffects.PointLight.Enabled = false

			for _, emitter in gunEffects:GetChildren() do
				if emitter:IsA("ParticleEmitter") and emitter.Name ~= "Lightning" then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end,
		FingerShoot = function(instance, cframe, p)
			local fingersR = instance:FindFirstChild("FingersR")

			if not fingersR then
				return
			end

			local gunEffects = fingersR:FindFirstChild("GunEffects", true)

			if not gunEffects then
				return
			end

			local worldCFrame = gunEffects.WorldCFrame
			local clone = utils.Gojo.LapseBlue.Throw:Clone()
			clone.CFrame = worldCFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone.Size = createVector(0, 0, 24)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = createVector(36, 36, 0),
				Position = clone.Position - clone.CFrame.LookVector * 12,
				Transparency = 1
			}):Play()
			Debris:AddItem(clone, 0.2)
			v3:PlaySound(sounds.Mechamaru.Absolute.Special.Shot, gunEffects, game.SoundService.Effect)

			if p then
				v3:Flash(p, Color3.new(1, 0, 0))
				cframe = CFrame.lookAlong(p.HumanoidRootPart.Position, cframe.LookVector)
			end

			local clone2 = utils.Mechamaru.GunBullet:Clone()
			clone2.WorldCFrame = cframe
			clone2.BeamStart.WorldPosition = worldCFrame.Position
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 2)
			TweenService:Create(clone2.BeamStart.Beam, TweenInfo.new(0.3), {
				Width1 = 0
			}):Play()

			for _, emitter in clone2:GetChildren() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			if localPlayer:DistanceFromCharacter(cframe.Position) < 40 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			v3:PlaySound(sounds.Mahito.Soulfire.Fire, clone2, game.SoundService.Effect)
		end,
		SpecialStartSound = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Mechamaru.Absolute.Special.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		SimpleDomainDart = function(instance, p)
			local torso = instance:FindFirstChild("Torso")

			if not torso then
				return
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { torso }
			local clone = utils.Mechamaru.SimpleDomainDart:Clone()
			clone.Parent = workspace.Effects
			local C0 = CFrame.new(0, 0, -0.5) * CFrame.Angles(0, 3.141592653589793, 0)
			local v6 = torso.Position - p
			local raycastResult = workspace:Raycast(p, v6, raycastParams)

			if raycastResult then
				local position = raycastResult.Position
				local _ = raycastResult.Normal
				local cframe = CFrame.lookAt(position, position + v6.Unit)
				C0 = torso.CFrame:ToObjectSpace(cframe)
			end

			local weld = Instance.new("Weld", clone)
			weld.Part1 = clone
			weld.C0 = C0
			weld.Part0 = torso
			v3:PlaySound(sounds.Mahito.Soulfire.Hit, instance.HumanoidRootPart, game.SoundService.Effect)
			task.wait(1)
			clone.Capsule.Attachment.Sparks.Enabled = true
			local lastTime = tick()
			local capsuleWeld = clone.CapsuleWeld
			task.delay(0.2, function()
				v3:PlaySound(sounds.Mahito.Soulfire.Morph, instance.HumanoidRootPart, game.SoundService.Effect)
				local v7 = true

				for _ = 1, 10 do
					for _ = 1, 2 do
						local clone2 = utils.Mahito.Morph:Clone()
						clone2.Weld.Part0 = torso
						clone2.Color = torso.Color
						clone2.Weld.C0 = CFrame.new(C0.Position) * CFrame.new(
							math.random(-30, 30) / 100,
							math.random(-30, 30) / 100,
							0
						)
						clone2.Parent = workspace.Effects
						local v8 = math.random(5, 7) / 10
						clone2.Size = createVector(1, 1, 1) * v8
						TweenService:Create(
							clone2,
							TweenInfo.new(math.random(10, 40) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.In),
							{
								Size = createVector(0, 0, 0)
							}
						):Play()
						Debris:AddItem(clone2, 0.4)
					end

					if instance:GetAttribute("Moveset") == "Mahito" and v7 then
						task.spawn(function()
							local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
							local cframe = CFrame.lookAlong(clone.Position, -clone.CFrame.LookVector)
							local v8 = {
								Color3.fromRGB(170, 170, 127),
								Color3.fromRGB(255, 170, 255),
								Color3.fromRGB(85, 170, 127),
								Color3.fromRGB(85, 85, 127),
								Color3.fromRGB(85, 85, 0)
							}

							if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 300 then
								return
							end

							local clone2 = utils.Mahito.Worms.Worm:Clone()
							clone2:SetPrimaryPartCFrame(cframe * CFrame.Angles(
								math.rad((math.random(70, 110))),
								math.rad((math.random(-20, 20))),
								0
							))
							local velocity = cframe.LookVector * math.random(80, 120)
							clone2["1"].RotVelocity = Vector3.new(
								math.random(-200, 200),
								math.random(-200, 200),
								math.random(-200, 200)
							)
							local color = v8[math.random(1, #v8)]

							for _, child in clone2:GetChildren() do
								child.Color = color
								child.Velocity = velocity
							end

							clone2.Parent = workspace.Effects
							Debris:AddItem(clone2, 3)

							for i = 2, 4 do
								local v11 = clone2[tostring(i)]
								local v12 = clone2[tostring(i - 1)]
								local attachment = Instance.new("Attachment", v11)
								local attachment2 = Instance.new("Attachment", v12)
								attachment.Position = createVector(0, 0, -1.5)
								attachment2.Position = createVector(0, 0, 1.5)
								local ballSocketConstraint = Instance.new("BallSocketConstraint")
								ballSocketConstraint.Attachment0 = attachment
								ballSocketConstraint.Attachment1 = attachment2
								ballSocketConstraint.LimitsEnabled = true
								ballSocketConstraint.Parent = attachment
							end

							clone2[tostring(5)]:Destroy()
							clone2[tostring(6)]:Destroy()
							clone2[tostring(7)]:Destroy()
							clone2[tostring(8)]:Destroy()
							clone2:ScaleTo(0.5)
							sounds.Mahito.Worms.Fire.PlaybackSpeed = math.random(140, 200) / 100
							v3:PlaySound(sounds.Mahito.Worms.Fire, clone2["1"], game.SoundService.Effect)
							local v11 = clone2[tostring(1)]
							v11.CanCollide = true
							v11.Anchored = false
							local v12 = clone2[tostring(2)]
							v12.CanCollide = true
							v12.Anchored = false
							local v13 = clone2[tostring(3)]
							v13.CanCollide = true
							v13.Anchored = false
							local v14 = clone2[tostring(4)]
							v14.CanCollide = true
							v14.Anchored = false
							task.wait(1.6)
							local tweenInfo = TweenInfo.new(0.1111111111111111)
							local v15 = {
								Size = createVector(0, 0, 0)
							}

							for i = 4, 1, -1 do
								TweenService:Create(clone2[tostring(i)], tweenInfo, v15):Play()
								task.wait(0.1111111111111111)
							end
						end)
						v7 = false
					else
						v7 = true
					end

					task.wait(0.07)
				end
			end)
			local total = 0
			local v7 = 1

			repeat
				local v8 = task.wait()
				local v9 = math.clamp((tick() - lastTime) / 1, 0, 1)
				capsuleWeld.C1 = CFrame.new(v9 * 1, 0, 0) * CFrame.Angles(math.rad(total), 0, 0)
				total += v8 * 720
			until v7 <= tick() - lastTime

			for _, child in clone.Detonate:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			clone.Capsule.Attachment:Destroy()
			clone.Capsule.Transparency = 1
			v3:Flash(instance, Color3.new(1, 0, 0))

			if localPlayer:DistanceFromCharacter(clone.Detonate.WorldPosition) < 40 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end

			v3:PlaySound(sounds.Mahito.Soulfire.Fire, clone, game.SoundService.Effect)
			Debris:AddItem(clone, 2)
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
	v = Knit.GetService("TechniqueChargeService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller