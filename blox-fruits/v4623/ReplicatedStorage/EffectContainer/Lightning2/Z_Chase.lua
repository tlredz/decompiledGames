local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local assets = FX:WaitForChild("Lightning2").Z_Chase.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
Util.ResizeModel(assets.Phase1.Explosion, 1.5)

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function AlignCFrame(data, normal)
	local v = not (normal and normal.Magnitude > 0 and normal) and createVector(0, 1, 0) or normal
	local p = data.p
	local unit = data.LookVector:Cross(v).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(v).Unit
	return CFrame.fromMatrix(p, unit2, v, unit3)
end

return function(data)
	local player = data.player

	if (currentCamera.CFrame.p - data.Origin).Magnitude > 1000 then
		return
	end

	local stage = data.Stage

	if stage == 1 then
		return
	end

	if stage == 2 then
		local proxy = data.Proxy

		if not (proxy and proxy:IsDescendantOf(workspace)) then
			return
		end

		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		Util.Debris:AddItem(folder, 15)
		local startCFrame = data.StartCFrame
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = startCFrame * CFrame.new(0, 0, -3)
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
		Util.Sound:Play("BF_Thunder_RumbleDragon_02_Cast_04", startCFrame.Position)
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.spawn(function()
				if v:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v:GetAttribute("EmitDelay"))
				end

				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end

		local clone2 = assets.Phase1.ProjectileModel:Clone()
		local projectile = clone2.Projectile
		projectile.CFrame = startCFrame
		Util.SetParentOverrideWithColor(clone2, folder, player, "LightningFruitVFXColor")
		local v = Util.Sound:Play("BF_Thunder_RumbleDragon_02_TravelLoop_01", projectile)
		TweenService:Create(v, TweenInfo.new(0.4), {
			Volume = 1
		}):Play()

		for _, effect in pairs(projectile:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
				continue
			end

			effect.Enabled = true

			if effect:IsA("ParticleEmitter") then
				effect:Emit(1)
			end
		end

		local lifetime = data.Lifetime
		local speed = data.Speed
		local v2 = speed
		local clone3 = assets.Phase2.HitAura:Clone()
		clone3.CFrame = projectile.CFrame
		Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")
		local v3 = {}
		local v4 = {}
		local flag = true
		local lastTime = os.clock()
		local v5 = false
		local v6 = false
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			local v7 = os.clock() - lastTime
			local _ = lifetime - v7

			if lifetime <= v7 then
				heartbeatConnection:Disconnect()
				flag = false
			elseif proxy:GetAttribute("Exploding") or not proxy:IsDescendantOf(workspace) then
				heartbeatConnection:Disconnect()
				flag = false
			else
				if proxy:GetAttribute("Targeted") then
					if not v6 then
						v6 = true
						lastTime = os.clock()
						lifetime = 0.5
						Util.Sound:Play("BF_Thunder_RumbleDragon_02_Explosion_04", projectile)
						v7 = os.clock() - lastTime
					end

					local v8 = 1 - (1 - math.clamp(v7 / lifetime, 0, 1)) ^ 5
					speed = v2 + (10 - v2) * v8
					clone2:ScaleTo(clone2:GetScale() + 0.025)
				end

				local targeted = proxy:GetAttribute("Targeted")
				local cFrame

				if targeted then
					local position = projectile.Position
					local unit = (targeted - position).Unit
					local unit2 = projectile.CFrame.LookVector:Lerp(unit, 2 * dt).Unit
					cFrame = CFrame.lookAt(position, position + unit2) * CFrame.new(0, 0, -speed * dt)
				else
					cFrame = projectile.CFrame * CFrame.new(0, 0, -speed * dt)
				end

				if not v6 then
					projectile.CFrame = cFrame
					return
				end

				local _, v9, _ = Util.Ray(
					cFrame.Position,
					createVector(0, 1, 0) * -(v7 / lifetime) ^ 0.333 * 13,
					{ workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
				)
				local v10 = v9 + createVector(0, 1, 0) * (v7 / lifetime) ^ 0.333 * 13
				projectile.CFrame = CFrame.new(v10) * cFrame.Rotation
			end
		end)
		task.spawn(function()
			local now = tick()
			local now2 = tick()
			local color3Constructor = Util.WrapColor3Constructor(
				Color3.new(0.584314, 0.603922, 1),
				player,
				"LightningFruitVFXColor"
			)
			local color3Constructor2 = Util.WrapColor3Constructor(
				Color3.new(0.4, 0.490196, 1),
				player,
				"LightningFruitVFXColor"
			)

			repeat
				if now - tick() <= 0 then
					now = tick() + 0.035
					local v7 = projectile.Position + Vector3.new(math.random(-25, 25), 0, math.random(-25, 25))
					local raycastResult = workspace:Raycast(
						v7 + createVector(0, 1, 0),
						createVector(-0, -25, -0),
						raycastParams
					)

					if raycastResult then
						for _ = 1, math.random(1, 2) do
							local v8 = raycastResult
							task.spawn(function()
								local clone4 = FX:WaitForChild("Lightning2").Z_Chase.Part:Clone()
								clone4.CFrame = CFrame.new(projectile.Position, v8.Position)
								Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
								clone4.Anchored = false
								clone4.Weld.Part1 = projectile
								clone4.Massless = true
								clone4.Attach1:SetAttribute("Pos", v8.Position)
								local lightningBoltShafi = Util.LightningBoltShafi.new(
									clone4.Attach0,
									clone4.Attach1,
									10,
									math.random(5, 10) / 15,
									folder
								)
								lightningBoltShafi.Frequency = math.random(2, 3)
								lightningBoltShafi.AnimationSpeed = math.random(3, 4)
								lightningBoltShafi.Color = Util.WrapColor3Constructor(
									Color3.new(0.411765, 0.952941, 1),
									player,
									"LightningFruitVFXColor"
								)
								v3[clone4.Attach1] = lightningBoltShafi

								if flag then
									task.wait(0.05 * math.random() + 0.1)
								else
									task.wait(0.125 * math.random() + 0.075)
								end

								if v3[clone4.Attach1] == nil then
									return
								end

								v3[clone4.Attach1] = nil
								lightningBoltShafi:Destroy()
							end)
						end
					end
				end

				if now2 - tick() <= 0 then
					now2 = tick() + 0.025

					for _ = 1, math.random(1, 2) do
						task.spawn(function()
							local v7 = projectile.CFrame * CFrame.Angles(
								math.rad((math.random(-180, 180))),
								math.rad((math.random(-180, 180))),
								(math.rad((math.random(-180, 180))))
							) * CFrame.new(0, 0, -math.random(10, 20)).Position
							local clone4 = FX:WaitForChild("Lightning2").Z_Chase.Part:Clone()
							clone4.CFrame = CFrame.new(projectile.Position, v7)
							Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
							clone4.Anchored = false
							clone4.Weld.Part1 = projectile
							clone4.Massless = true
							clone4.Attach1:SetAttribute("Pos", v7)
							local lightningBoltShafi = Util.LightningBoltShafi.new(
								clone4.Attach0,
								clone4.Attach1,
								5,
								math.random(5, 10) / 10,
								folder,
								color3Constructor
							)
							lightningBoltShafi.Frequency = math.random(2, 3)
							lightningBoltShafi.AnimationSpeed = math.random(3, 4)
							lightningBoltShafi.Color = Util.WrapColor3Constructor(
								Color3.new(0.411765, 0.952941, 1),
								player,
								"LightningFruitVFXColor"
							)
							v3[clone4.Attach1] = lightningBoltShafi
							task.wait(0.05 * math.random() + 0.075)

							if v3[clone4.Attach1] == nil then
								return
							end

							v3[clone4.Attach1] = nil
							lightningBoltShafi:Destroy()
						end)
					end
				end

				for _, child in pairs(proxy:GetChildren()) do
					if not child.Value or not child.Value:IsDescendantOf(workspace) or v4[child] then
						continue
					end

					local value = child.Value
					v4[child] = child
					local v9 = 0.015 * math.random() + 0.015
					local v10 = child
					task.spawn(function()
						clone3.CFrame = value.CFrame

						for i = 1, math.random(1, 2) do
							task.spawn(function()
								local v11 = math.random(0, 5) / 100
								task.delay(v11 * 1.15, function()
									for i2, emitter in pairs(clone3:GetDescendants()) do
										if emitter:IsA("ParticleEmitter") then
											emitter:Emit(emitter:GetAttribute("EmitCount"))
										end
									end
								end)
								task.wait(v11)
								local clone4 = FX:WaitForChild("Lightning2").Z_Chase.Part:Clone()
								clone4.CFrame = CFrame.new(projectile.Position, value.Position)
								Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
								clone4.Anchored = false
								clone4.Weld.Part1 = projectile
								clone4.Massless = true
								clone4.Attach1:SetAttribute("Pos", value.Position)
								local lightningBoltShafi = Util.LightningBoltShafi.new(
									clone4.Attach0,
									clone4.Attach1,
									12,
									math.random(5, 10) / 13,
									folder,
									color3Constructor2
								)
								lightningBoltShafi.Frequency = math.random(2, 3)
								lightningBoltShafi.AnimationSpeed = math.random(3, 4)
								lightningBoltShafi.Color = Util.WrapColor3Constructor(
									Color3.new(0.411765, 0.952941, 1),
									player,
									"LightningFruitVFXColor"
								)
								v3[clone4.Attach1] = lightningBoltShafi
								task.wait(v9 + math.random(5, 15) / 100)

								if v3[clone4.Attach1] == nil then
									return
								end

								v3[clone4.Attach1] = nil
								lightningBoltShafi:Destroy()
							end)
						end

						task.wait(v9)
						v4[v10] = nil
					end)
				end

				for k, _ in pairs(v3) do
					local pos = k:GetAttribute("Pos")

					if k:GetAttribute("Dontmove") == nil then
						k.WorldPosition = CFrame.new(pos, projectile.Position) * createVector(0, 0, -5)
					else
						k.WorldPosition = pos
						print("??")
					end
				end

				task.wait()
			until v5 == true
		end)

		repeat
			task.wait()
		until flag == false

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		for k, v7 in pairs(v3) do
			v7:Destroy()
			v3[k] = nil
		end

		local clone4 = assets.Phase1.Spark:Clone()
		clone4.CFrame = projectile.CFrame
		Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
		clone4.CFrame = projectile.CFrame

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v7 = emitter
			task.spawn(function()
				if v7:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v7:GetAttribute("EmitDelay"))
				end

				v7:Emit(v7:GetAttribute("EmitCount"))
			end)
		end

		for _, emitter in pairs(projectile:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Destroy()
			end
		end

		v5 = true

		if (workspace.CurrentCamera.CFrame.p - projectile.Position).Magnitude < 100 then
			Util.CameraShaker:ShakeOnce(6, 6, 0.2, 0.6)
			local Effect = require(game.ReplicatedStorage.Effect)
			Effect.new("ColorCorrection"):replicate({
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(183, 218, 255),
					player,
					"LightningFruitVFXColor"
				),
				Brightness = 0.1,
				Saturation = 0.1,
				Contrast = 0.1,
				FadeIn = 0,
				FadeOut = 0.3,
				Lifetime = 0.1
			})
		end

		task.wait(0.05)
		local clone5 = assets.Phase1.BeforeExplosion:Clone()
		clone5:PivotTo(projectile.CFrame)
		Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")

		for _, emitter in pairs(clone5:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v7 = emitter
			task.spawn(function()
				v7:Emit(v7:GetAttribute("EmitCount"))
				v7.Enabled = true
				task.wait(0.25)
				v7.Enabled = false
			end)
		end

		task.spawn(function()
			for i = clone5:GetScale() * 100, 0, -8 do
				clone5:ScaleTo(i / 100)
				task.wait(0.005)
			end
		end)
		task.wait(0.25)
		local clone6 = assets.Phase1.Explosion:Clone()
		clone6.CFrame = projectile.CFrame
		Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
		DeleteImpactAfterDuration(clone6) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone6:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v7 = emitter
			task.spawn(function()
				if v7:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v7:GetAttribute("EmitDelay"))
				end

				v7:Emit(v7:GetAttribute("EmitCount"))
			end)
		end

		local raycastResult = workspace:Raycast(projectile.Position, createVector(-0, -25, -0), raycastParams)

		if raycastResult then
			local clone7 = assets.Phase2.GroundBurn:Clone()
			Util.SetParentOverrideWithColor(clone7, folder, player, "LightningFruitVFXColor")
			clone7.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone7:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end

		if (workspace.CurrentCamera.CFrame.p - projectile.Position).Magnitude < 100 then
			Util.CameraShaker:ShakeOnce(12, 10, 0.2, 1)
			local Effect = require(game.ReplicatedStorage.Effect)
			Effect.new("ColorCorrection"):replicate({
				TintColor = Util.WrapColor3ConstructorForTintColor(
					Color3.fromRGB(156, 215, 255),
					player,
					"LightningFruitVFXColor"
				),
				Brightness = 0.5,
				Saturation = 0.1,
				Contrast = 0.1,
				FadeIn = 0,
				FadeOut = 0.1,
				Lifetime = 0.1
			})
		end
	end
end