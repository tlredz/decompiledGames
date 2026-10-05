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
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "EnergyRippleController"
})
local v3 = {
	10,
	5,
	55,
	50
}
local v4 = {
	"rbxassetid://14881939208",
	"rbxassetid://14881938857",
	"rbxassetid://14881938578",
	"rbxassetid://14881938271",
	"rbxassetid://14881937942",
	"rbxassetid://14881937668",
	"rbxassetid://14881937499",
	"rbxassetid://14881937341",
	"rbxassetid://14881937187",
	"rbxassetid://14881937032",
	"rbxassetid://14881936897",
	"rbxassetid://14881936734",
	"rbxassetid://14881936492"
}

function controller.KnitStart(_)
	local v5 = {
		Hit = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v:Flash(instance2, Color3.fromRGB(255, 170, 255))
			local v6 = p % 3
			local v7 = v6 == 0 and 3 or v6
			v:PlaySound(sounds.Yuta.M1:FindFirstChild("Hit" .. v7), humanoidRootPart2, game.SoundService.Effect)
			local clone = utils.Yuta.SlashHit:Clone()
			clone.Slash.Color = ColorSequence.new(Color3.fromRGB(255, 85, 255))
			clone.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart.CFrame.LookVector) * CFrame.Angles(
				0,
				0,
				(math.rad(v3[p] or 0))
			)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)
			clone.Slash:Emit(5)
		end,
		AirHit = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:Flash(instance, Color3.new(1, 1, 1))
			v:PlaySound(sounds.Yuta.M1.Hit4, humanoidRootPart, game.SoundService.Effect)
		end,
		StartBomb = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v6 = v:PlaySound(sounds.Yuta.EnergyRipple.Start, humanoidRootPart, game.SoundService.Effect)
			instance2.AncestryChanged:Connect(function()
				v6:Destroy()
			end)
			instance2:GetAttributeChangedSignal("Feint"):Connect(function()
				v6:Destroy()
			end)
		end,
		StabFloor = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local position = humanoidRootPart.Position

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 30 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Bomb = function(position, p)
			local clone = utils.Yuta.EnergyRipple:Clone()
			clone.Ground.Lightning.Enabled = false
			clone.Position = position
			clone.Ground.Position = position
			local preloadMeshFlipbook = v:PreloadMeshFlipbook(v4)
			local v6 = clone.Size.Y / 2
			local model

			if v6 ~= p then
				local v7 = p / v6
				model = Instance.new("Model")
				clone.Parent = model
				model:ScaleTo(v7)
			end

			local children = clone.RingBeams:GetChildren()

			for _, v7 in children do
				v7.Enabled = false
			end

			local size = clone.Size
			local transparency = clone.Transparency
			local range = clone.PointLight.Range
			local brightness = clone.PointLight.Brightness
			clone.Size = createVector(5, 5, 5)
			clone.Ground.Size = createVector(10, 5, 10)
			clone.Transparency = 1
			clone.PointLight.Range = 0
			clone.PointLight.Brightness = 0
			clone.Parent = workspace.Effects

			if model then
				model:Destroy()
			end

			v:PlaySound(sounds.Yuta.EnergyRipple.Bomb1, clone, game.SoundService.Effect)
			Debris:AddItem(clone, 5)
			clone.Ground.Lightning.Enabled = true
			TweenService:Create(clone, TweenInfo.new(0.19999999999999998, Enum.EasingStyle.Linear), {
				Size = Vector3.new(size.X / 2.5, size.Y * 0.66, size.Z / 2.5)
			}):Play()
			task.delay(0.19999999999999998, function()
				TweenService:Create(clone, TweenInfo.new(0.1), {
					Size = size
				}):Play()
			end)
			TweenService:Create(clone.Ground, TweenInfo.new(0.3), {
				Size = Vector3.new(size.X, 5, size.Y)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.15), {
				Transparency = transparency
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(0.3), {
				Brightness = brightness,
				Range = range
			}):Play()
			task.wait(0.3)
			v:PlaySound(sounds.Yuta.EnergyRipple.Bomb2, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 50 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			clone.Transparency = 1
			clone.Ground.Lightning.Enabled = false
			TweenService:Create(clone.PointLight, TweenInfo.new(0.1), {
				Brightness = 0,
				Range = range * 2
			}):Play()
			clone.Ground.Attachment.WindCrescent1:Emit(4)
			clone.Ground.Attachment.Wind2:Emit(30)
			local tweenInfo = TweenInfo.new(0.5)
			local tweenInfo2 = TweenInfo.new(0.35)

			for _, v7 in children do
				v7.Enabled = true
				TweenService:Create(v7, tweenInfo, {
					CurveSize0 = 0,
					CurveSize1 = 0
				}):Play()
				TweenService:Create(v7, tweenInfo2, {
					Width0 = 0,
					Width1 = 0
				}):Play()
				TweenService:Create(v7.Attachment0, tweenInfo, {
					Position = Vector3.new(0, size.Y * 1.2 / 2, 0)
				}):Play()
				TweenService:Create(v7.Attachment1, tweenInfo, {
					Position = Vector3.new(0, size.Y * 1.2 / 2, 0)
				}):Play()
				local v8 = v7
				task.delay(0.2, function()
					v8.Color = ColorSequence.new(Color3.new())
				end)
			end

			local clone2 = utils.Yuta.ExplosionDissolve:Clone()
			clone2.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad((Random.new():NextNumber(-180, 180))), 0)
			clone2.Parent = workspace.Effects
			clone2.Mesh.Scale = size / 2
			clone2.Attachment.WindRings:Emit(10)
			v:PlayMeshFlipbook(clone2.Mesh, 1, v4, function()
				clone2.Transparency = 1
				preloadMeshFlipbook:Destroy()
				local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					clone2.CFrame *= CFrame.Angles(0, math.rad(dt * 300), 0)
					RunService.RenderStepped:Wait()
				end)
				task.wait(2)
				heartbeatConnection:Disconnect()
				clone2:Destroy()
			end)
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
			TweenService:Create(clone2.Mesh, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Scale = clone2.Mesh.Scale * 1.2
			}):Play()
			TweenService:Create(clone2.PointLight, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Range = clone2.PointLight.Range * 1.2
			}):Play()
			task.wait(0.5)
			TweenService:Create(clone2.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
		end,
		BombHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:Flash(instance, Color3.fromRGB(255, 170, 255))
			v:PlaySound(sounds.Yuta.M1.Hit4, humanoidRootPart, game.SoundService.Effect)
		end,
		FeintSwing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Yuta.ResoluteSlash.RingSwing.Attachment:Clone()
			clone.Ring.RotSpeed = NumberRange.new(-800, -200)
			clone.Parent = humanoidRootPart
			clone.Ring:Emit(8)
			Debris:AddItem(clone, 0.6)
			local clone2 = utils.Ryu.Slash:Clone()
			clone2:ScaleTo(1.7)
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Weld.C0 = CFrame.Angles(0.2617993877991494, -0.4363323129985824, 3.490658503988659)
			clone2.Part1.Mesh.Scale = createVector(-20, 1, 20)
			clone2.Part2.Mesh.Scale = createVector(20.445, 1, 20.445)
			clone2.Weld.C1 = CFrame.Angles(0, -1.5707963267948966, 0)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.115)
			task.spawn(function()
				local part = Instance.new("Part")
				part.CanCollide = false
				part.Anchored = true
				part.Parent = workspace.Effects
				part.Transparency = 1
				part.Size = createVector(1, 1, 1)
				Debris:AddItem(part, 2)
				local clone3 = utils.Yuta.Outburst.OutburstExplode.Hitbox.Star:Clone()
				clone3.Parent = part
				clone3.Lifetime = NumberRange.new(0.2)
				clone3.LockedToPart = false

				repeat
					task.wait(0.02)
					part.CFrame = clone2.Weld.Part0.CFrame * clone2.Weld.C0 * clone2.Weld.C1:Inverse() * CFrame.new(
						0,
						0,
						10
					)
					clone3:Emit(1)
				until clone2.Parent == nil
			end)
			local tweenInfo = TweenInfo.new(0.115, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local tweenInfo2 = TweenInfo.new(0.115, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(clone2.Weld, tweenInfo, {
				C1 = clone2.Weld.C1 * CFrame.Angles(0, -2.181661564992912, 0)
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
		FeintHit = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:PlaySound(sounds.Yuta.EnergyRipple.Feint.Hit, humanoidRootPart, game.SoundService.Effect)
			v:PlaySound(sounds.Yuta.EnergyRipple.Feint.CEBurst, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Yuta.Outburst.OutburstExplode:Clone()
			clone:ScaleTo(0.65)
			clone.Hitbox.Anchored = false
			clone.Hitbox.Massless = true
			clone.Weld.Part0 = humanoidRootPart
			Debris:AddItem(clone, 3)
			local pointLight = clone.Hitbox.Attachment.PointLight
			local range = pointLight.Range
			pointLight.Range = 0
			clone.Parent = workspace.Effects
			TweenService:Create(pointLight, TweenInfo.new(0.2), {
				Range = range
			}):Play()

			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter:GetAttribute("EmitDelay") == 0.5 then
					emitter:SetAttribute("EmitDelay", 0.8)
				end

				if emitter.Lifetime.Min > 0.25 then
					emitter.Lifetime = NumberRange.new(emitter.Lifetime.Min + 0.3, emitter.Lifetime.Max + 0.3)
				end

				emitter.ZOffset += 4
				emitter.LockedToPart = true
			end

			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if emitter:GetAttribute("EmitDelay") and emitter:GetAttribute("EmitDelay") ~= 0.8 then
					local v6 = emitter
					task.delay(emitter:GetAttribute("EmitDelay"), function()
						v6:Emit(v6:GetAttribute("EmitCount"))
					end)
				else
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			task.wait(0.75)
			TweenService:Create(pointLight, TweenInfo.new(0.1), {
				Range = 0
			}):Play()

			if instance2:GetAttribute("Ragdoll") == 0 then
				Debris:AddItem(clone, 0.25)
				return
			end

			v:PlaySound(sounds.Yuta.EnergyRipple.Feint.Explosion, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 or (workspace.CurrentCamera.CFrame.Position - clone.Hitbox.Position).Magnitude < 50 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			for _, emitter in clone:GetDescendants() do
				if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitDelay") == 0.8) then
					continue
				end

				emitter.LockedToPart = false
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			local clone2 = utils.Gojo.ReversalRed.RedExplode:Clone()
			clone2.Position = clone.Hitbox.Position
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
		end
	}
	v2.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitInit(_)
	v2 = Knit.GetService("EnergyRippleService")
	v = Knit.GetController("FXController")
end

return controller