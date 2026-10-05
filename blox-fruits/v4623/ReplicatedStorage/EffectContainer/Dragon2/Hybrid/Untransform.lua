local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Mouse"))
local sound = Util.Sound
local _ = Util.MasterClock
local debris = Util.Debris
local _ = Util.Rock2
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local untransform = FX:WaitForChild("Dragon2").Hybrid.Untransform

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teslaFeeler(p, attachment, p2, p3, p4)
	task.spawn(function()
		local ray, v, v2 = Util.Ray(
			p.Position,
			p.lookVector.Unit * p2,
			{ workspace.Characters, workspace.Enemies },
			false
		)

		if ray then
			Util.Sound:Play("ZapSaberHit", v, nil, 1.5 + math.random(-40, 40) / 100, 0.2)
			local clone = untransform.StaticImpact:Clone()
			Util.Debris:AddItem(clone, 1)
			clone.CFrame = CFrame.new(v, v + v2) * CFrame.Angles(-1.5707963267948966, 0, 0)
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, p4, "DragonFruitVFXColor")
			clone.Diamond:Emit(2)
			clone.Sparks:Emit(math.random(6, 10))
			local attachment2 = Instance.new("Attachment")
			Util.SetParentOverrideWithColor(attachment2, clone, p4, "DragonFruitVFXColor")
			attachment2.Orientation = createVector(0, 0, 0)
			Util.SetParentOverrideWithColor(clone, _WorldOrigin, p4, "DragonFruitVFXColor")
			local lightningBolt = Util.LightningBolt.new(attachment, attachment2, 0, 0, math.random(10, 14))
			lightningBolt.Color = Util.WrapColor3Constructor(
				Color3.new(0.596078, 0.690196, 1),
				p4,
				"DragonFruitVFXColor"
			)
			lightningBolt.MinThicknessMultiplier = 0.5
			lightningBolt.MaxThicknessMultiplier = 2.5
			lightningBolt.AnimationSpeed = 6
			lightningBolt.PulseSpeed = 15
			lightningBolt.MaxAngleOffset = 0.24434609527920614

			if lightningBolt then
				local lastTime = tick()
				local v3 = 0.016666666666666666

				while tick() - lastTime < 0.4 do
					local v4 = math.min(1, (tick() - lastTime) / 0.4)

					if v4 >= 1 or not (lightningBolt and clone and attachment) then
						break
					end

					lightningBolt.MinThicknessMultiplier = 0.5 + -0.48 * (v4 * v3 * 60)
					lightningBolt.MaxThicknessMultiplier = 2.5 + -2.45 * (v4 * v3 * 60)
					local v6 = v4 * v3 * 60
					lightningBolt.CurveSize0 = 0 + (p3 - 0) * v6
					lightningBolt.AddTransparency = 0 + 1 * (v4 * v3 * 60)
					v3 = RunService.RenderStepped:Wait()
				end

				if lightningBolt then
					lightningBolt:Destroy()
				end

				if clone then
					clone:Destroy()
				end
			end
		end
	end)
end

return function(data)
	local ID = data.ID
	local player = data.player
	local root = ID == 1 and data.Root

	if root then
		if (root.Position - workspace.CurrentCamera.CFrame.p).Magnitude > 900 then
			return
		end

		local ray, v, _ = Util.Ray(
			root.Position,
			-(CFrame.new(root.Position).upVector.Unit * (root.Size.Y / 2) + createVector(0, 5, 0)),
			{ workspace.Characters, workspace.Enemies },
			false
		)
		local cframe = CFrame.new(root.Position - Vector3.new(0, root.Size.Y / 2 + 3, 0))

		if ray then
			cframe = CFrame.new(v + createVector(0, 0.25, 0))
		end

		local clone = untransform.Transform:Clone()
		debris:AddItem(clone, 10)
		clone.CFrame = cframe
		local prime = clone.Prime
		local erupt = clone.Erupt
		local blast = clone.Blast
		Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "DragonFruitVFXColor")
		sound:Play("BF_V3_Hybrid_Deactivate_01", root)
		task.spawn(function()
			for _, emitter in pairs(blast:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local _ = {
				[5] = true,
				[10] = true,
				[15] = true
			}
			task.spawn(function()
				for _ = 1, 7 do
					local attachment = Instance.new("Attachment")
					debris:AddItem(attachment, 1)
					Util.SetParentOverrideWithColor(attachment, workspace.Terrain, player, "DragonFruitVFXColor")
					attachment.CFrame = CFrame.new(root.Position + createVector(0, 3, 0))
					attachment.Orientation = createVector(0, 0, 90)

					for _, emitter in pairs(erupt:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Emit(emitter:GetAttribute("EmitCount"))
						end
					end

					clone.CastFlames:Emit(clone.CastFlames:GetAttribute("EmitCount"))
					clone.Contrast:Emit(clone.Contrast:GetAttribute("EmitCount"))
					teslaFeeler(
						CFrame.new(clone.Position + createVector(0, 10, 0)) * CFrame.Angles(
							math.rad((math.random(-30, 30))),
							math.rad((math.random(0, 360))),
							(math.rad((math.random(-30, 30))))
						),
						attachment,
						math.random(65, 85),
						math.random(25, 85),
						player
					) -- equivalent call inferred; original call site unknown
					task.wait(0.028)
				end
			end)

			if root == game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or (root.Position - workspace.CurrentCamera.CFrame.Position).Magnitude < 80 then
				Util.CameraShaker:ShakeOnce(5, 10, 1, 1)
				Effect.new("ColorCorrection"):replicate({
					TintColor = Util.WrapColor3ConstructorForTintColor(
						Color3.fromRGB(255, 255, 255),
						player,
						"DragonFruitVFXColor"
					),
					Brightness = -1,
					Saturation = -1,
					Contrast = 6,
					FadeIn = 0,
					FadeOut = 0.2,
					Lifetime = 0.1
				})
			end

			for _, v3 in pairs({}) do
				if v3 then
					v3:Destroy()
				end
			end
		end)
		task.spawn(function()
			local clone2 = untransform.Start:Clone()
			clone2.CFrame = cframe
			Util.SetParentOverrideWithColor(clone2, clone, player, "DragonFruitVFXColor")
			local emittersByEmitter = {}

			for _, emitter in pairs(clone2:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emittersByEmitter[emitter] = emitter
			end

			local lastTime = tick()

			while true do
				for _, v2 in pairs(emittersByEmitter) do
					v2:Emit(1)
				end

				task.wait(0.005)

				if not (tick() - lastTime >= 0.15) then
					continue
				end

				for _, emitter in pairs(clone2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				break
			end
		end)
		task.wait(0.05)

		for _, emitter in pairs(prime:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end
end