local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local assets = script.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = false
raycastParams.FilterDescendantsInstances = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }

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

		if not proxy then
			return
		end

		local rootProxy = proxy:FindFirstChild("RootProxy")

		if not rootProxy then
			return
		end

		local hitTargetProxy = proxy:FindFirstChild("HitTargetProxy")

		if not hitTargetProxy then
			return
		end

		local folder = Instance.new("Folder")
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "LightningFruitVFXColor")
		Util.Debris:AddItem(folder, 15)
		local startCFrame = data.StartCFrame
		local clone = assets.Phase1.StartImpact:Clone()
		clone.CFrame = startCFrame * CFrame.new(0, 0, -3)
		Util.SetParentOverrideWithColor(clone, folder, player, "LightningFruitVFXColor")
		local v = false

		if player and player.Character and player.Character:IsDescendantOf(workspace) then
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				v = humanoidRootPart:GetAttribute("LightningSkin") and humanoidRootPart:GetAttribute("LightningSkin") == "Purple"
			end
		end

		Util.Sound:Play("BF_Thunder_RumbleDragon_03_Cast_01", clone.Position)
		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		end

		local clone2 = assets.Phase1.Projectile:Clone()
		clone2.CFrame = startCFrame
		local clone3 = assets.Phase1.DragonHead:Clone()
		clone3:PivotTo(startCFrame)
		Util.SetParentOverrideWithColor(clone3, folder, player, "LightningFruitVFXColor")

		if v then
			clone3["Body.009"].Color = Color3.fromRGB(109, 69, 159)
		end

		clone3.Script.Enabled = true
		clone2:GetPropertyChangedSignal("CFrame"):Connect(function()
			clone3.RootPart.Controller.WorldCFrame = clone2.CFrame
		end)
		clone2.Destroying:Once(function()
			clone3:Destroy()
		end)
		local v2 = Util.Sound:Play("BF_Thunder_RumbleDragon_03_TravelLoop_01", clone2)
		TweenService:Create(v2, TweenInfo.new(0.5), {
			Volume = 1
		}):Play()

		for _, effect in pairs(clone2:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
				continue
			end

			effect.Enabled = true

			if effect:IsA("ParticleEmitter") then
				effect:Emit(1)
			end
		end

		local speed = data.Speed
		local v3 = false
		local v4 = {}
		local flag = true
		task.spawn(function()
			local now = tick()

			repeat
				if now - tick() <= 0 then
					now = tick() + 0.035
					local v5 = clone2.Position + Vector3.new(math.random(-25, 25), 0, math.random(-25, 25))
					local raycastResult = workspace:Raycast(
						v5 + createVector(0, 1, 0),
						createVector(-0, -25, -0),
						raycastParams
					)

					if raycastResult then
						for _ = 1, math.random(1, 2) do
							local v6 = raycastResult
							task.spawn(function()
								local clone4 = FX:WaitForChild("Lightning2").Z_Charged.Part:Clone()
								clone4.CFrame = CFrame.new(clone2.Position, v6.Position)
								Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
								clone4.Anchored = false
								clone4.Weld.Part1 = clone2
								clone4.Massless = true
								clone4.Attach1:SetAttribute("Pos", v6.Position)
								local lightningBoltShafi = Util.LightningBoltShafi.new(
									clone4.Attach0,
									clone4.Attach1,
									10,
									math.random(5, 10) / 15,
									folder
								)
								lightningBoltShafi.Color = Util.WrapColor3Constructor(
									Color3.new(0.411765, 0.952941, 1),
									player,
									"LightningFruitVFXColor"
								)
								v4[clone4.Attach1] = lightningBoltShafi
								clone2.Destroying:Once(function()
									if v4[clone4.Attach1] == nil then
										return
									end

									v4[clone4.Attach1] = nil
									lightningBoltShafi:Destroy()
								end)

								if flag then
									task.wait(0.05 * math.random() + 0.1)
								else
									task.wait(0.125 * math.random() + 0.075)
								end

								if v4[clone4.Attach1] == nil then
									return
								end

								v4[clone4.Attach1] = nil
								lightningBoltShafi:Destroy()
							end)
						end
					end
				end

				for k, _ in pairs(v4) do
					local pos = k:GetAttribute("Pos")

					if k:GetAttribute("Dontmove") == nil then
						k.WorldPosition = CFrame.new(pos, clone2.Position) * createVector(0, 0, -5)
					else
						k.WorldPosition = pos
					end
				end

				task.wait()
			until v3 == true
		end)
		local lastTime = os.clock()
		local _ = clone2.Position
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			local v5 = os.clock() - lastTime
			local _ = 1 - v5

			if v5 >= 1 then
				heartbeatConnection:Disconnect()
				flag = false
			else
				local _ = clone2.CFrame * CFrame.new(0, 0, -speed * dt)

				if hitTargetProxy.Value then
					heartbeatConnection:Disconnect()
				elseif proxy:GetAttribute("Exploding") then
					heartbeatConnection:Disconnect()
					flag = false
				else
					local targeted = proxy:GetAttribute("Targeted")

					if targeted then
						local position = clone2.Position
						local unit = (targeted - position).Unit
						clone2.CFrame = CFrame.lookAt(position, position + unit) * CFrame.new(0, 0, -speed * dt)
					else
						clone2.CFrame *= CFrame.new(0, 0, -speed * dt)
					end
				end
			end
		end)

		repeat
			task.wait(0.03333333333333333)
		until not proxy:IsDescendantOf(workspace) or hitTargetProxy.Value or proxy:GetAttribute("Exploding")

		flag = false

		for k, v5 in pairs(v4) do
			v5:Destroy()
			v4[k] = nil
		end

		local v5 = {}
		local clones = {}
		local clone4 = assets.Phase1.Spark:Clone()
		clone4.CFrame = clone2.CFrame
		Util.SetParentOverrideWithColor(clone4, folder, player, "LightningFruitVFXColor")
		local value

		if proxy:IsDescendantOf(workspace) and hitTargetProxy.Value then
			value = hitTargetProxy.Value

			if v5[value.Parent] == nil then
				local clone5 = FX:WaitForChild("Lightning2").Z_Charged.Assets.Phase2.HitAuraM:Clone()
				clone5:PivotTo(value.CFrame)
				Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")
				table.insert(clones, clone5)

				for _, emitter in pairs(clone5:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end
		end

		clone4.CFrame = clone2.CFrame

		for _, emitter in pairs(clone4:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v6 = emitter
			task.spawn(function()
				if v6:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v6:GetAttribute("EmitDelay"))
				end

				v6:Emit(v6:GetAttribute("EmitCount"))
			end)
		end

		local v6

		if value then
			task.spawn(function()
				local v7 = v5[1]

				if not v7 then
					return
				end

				local position = v7.PrimaryPart.Position

				for _ = 1, math.random(1, 2) do
					task.spawn(function()
						local clone5 = FX:WaitForChild("Lightning2").Z_Charged.Part:Clone()
						clone5.CFrame = CFrame.new(clone2.Position, position)
						Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")
						clone5.Anchored = false
						clone5.Weld.Part1 = clone2
						clone5.Massless = true
						clone5.Attach1.WorldPosition = position
						clone5.Attach1:SetAttribute("Pos", position)
						clone5.Attach1:SetAttribute("Dontmove", true)
						local lightningBoltShafi = Util.LightningBoltShafi.new(
							clone5.Attach0,
							clone5.Attach1,
							12,
							math.random(5, 10) / 12,
							folder
						)
						lightningBoltShafi.Color = Util.WrapColor3Constructor(
							Color3.new(0.411765, 0.952941, 1),
							player,
							"LightningFruitVFXColor"
						)
						v4[clone5.Attach1] = lightningBoltShafi
						clone2.Destroying:Once(function()
							if v4[clone5.Attach1] == nil then
								return
							end

							v4[clone5.Attach1] = nil
							lightningBoltShafi:Destroy()
						end)
						task.wait(speed + math.random(-5, 5) / 100)

						if v4[clone5.Attach1] == nil then
							return
						end

						v4[clone5.Attach1] = nil
						lightningBoltShafi:Destroy()
					end)
				end
			end)
			local v7 = tick() + 4
			local count = 0

			while not (v7 <= tick()) and not (count >= 9) and proxy:IsDescendantOf(workspace) and not proxy:GetAttribute("Exploding") do
				if rootProxy.Value then
					local value2 = rootProxy.Value
					rootProxy.Value = nil
					print("server target wiped")
					local cFrame = value2.CFrame
					local lookVector = CFrame.new(clone2.Position, cFrame.Position).LookVector
					local cframe = CFrame.new(cFrame.Position, cFrame.Position + lookVector)
					clone2.CFrame = CFrame.new(clone2.Position, cframe.Position)
					local _ = proxy.Value.Position
					local now = os.clock()
					local _ = clone2.Position
					local v8 = false
					local v9 = false
					proxy:GetAttributeChangedSignal("BounceReached"):Once(function()
						v9 = true
					end)
					local heartbeatConnection2 = nil
					heartbeatConnection2 = RunService.Heartbeat:Connect(function(dt)
						local v12 = os.clock() - now
						local v13 = 0.35 - v12
						local position = value2.Position

						if v12 >= 0.35 then
							heartbeatConnection2:Disconnect()
							v8 = true
						else
							local unit = (position - clone2.Position).Unit
							local v14 = speed * dt
							local v15 = clone2.Position + unit * v14
							local cframe2 = CFrame.new(v15, v15 + unit)

							if proxy:IsDescendantOf(workspace) and not proxy:GetAttribute("Exploding") then
								if not v9 then
									clone2.CFrame = cframe2
									return
								end

								Util.Sound:Play("BF_Thunder_RumbleDragon_03_SparkBounce_01", proxy.Value.Position)
								count += 1
								speed = math.min(speed * 1.5, 1200)
							end

							heartbeatConnection2:Disconnect()
							v8 = true
						end
					end)

					repeat
						task.wait()
					until v8 == true

					if proxy:IsDescendantOf(workspace) and not proxy:GetAttribute("Exploding") and count < 9 then
						local cFrame2 = value2.CFrame
						local lookVector2 = CFrame.new(clone2.Position, cFrame2.Position).LookVector
						local cframe2 = CFrame.new(cFrame2.Position, cFrame2.Position + lookVector2)
						clone4.CFrame = clone2.CFrame

						for _, emitter in pairs(clone4:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v12 = emitter
							task.spawn(function()
								if v12:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v12:GetAttribute("EmitDelay"))
								end

								v12:Emit(v12:GetAttribute("EmitCount"))
							end)
						end

						task.spawn(function()
							local clone5 = FX:WaitForChild("Lightning2").Z_Charged.Assets.Phase2.HitAuraM:Clone()
							clone5:PivotTo(cframe2)
							Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")
							table.insert(clones, clone5)

							for _, emitter in pairs(clone5:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter.Enabled = true
								end
							end
						end)
						local v12 = value2
						task.spawn(function()
							if not v12:IsDescendantOf(workspace) then
								return
							end

							local position = v12.Position

							for i = 1, math.random(1, 2) do
								task.spawn(function()
									local clone5 = FX:WaitForChild("Lightning2").Z_Charged.Part:Clone()
									clone5.CFrame = CFrame.new(clone2.Position, position)
									Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")
									clone5.Anchored = false
									clone5.Weld.Part1 = clone2
									clone5.Massless = true
									clone5.Attach1.WorldPosition = position
									clone5.Attach1:SetAttribute("Pos", position)
									clone5.Attach1:SetAttribute("Dontmove", true)
									local lightningBoltShafi = Util.LightningBoltShafi.new(
										clone5.Attach0,
										clone5.Attach1,
										12,
										math.random(5, 10) / 12,
										folder
									)
									lightningBoltShafi.Color = Util.WrapColor3Constructor(
										Color3.new(0.411765, 0.952941, 1),
										player,
										"LightningFruitVFXColor"
									)
									v4[clone5.Attach1] = lightningBoltShafi
									clone2.Destroying:Once(function()
										if v4[clone5.Attach1] == nil then
											return
										end

										v4[clone5.Attach1] = nil
										lightningBoltShafi:Destroy()
									end)
									task.wait(speed + math.random(-5, 5) / 100)

									if v4[clone5.Attach1] == nil then
										return
									end

									v4[clone5.Attach1] = nil
									lightningBoltShafi:Destroy()
								end)
							end
						end)
					end
				end

				task.wait()
			end

			v6 = true
		else
			v6 = false
		end

		repeat
			task.wait(0.03333333333333333)
		until not proxy:IsDescendantOf(workspace) or proxy:GetAttribute("Exploding") or v6

		clone2.CFrame = proxy.Value

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		for _, folder2 in pairs(clones) do
			for _, emitter in pairs(folder2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		clone4.CFrame = clone2.CFrame

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

		for _, descendant in pairs(clone2:GetDescendants()) do
			if descendant:IsA("ParticleEmitter") then
				descendant:Destroy()
			end

			if descendant:IsA("BasePart") or descendant:IsA("MeshPart") then
				descendant.Transparency = 1
			end
		end

		v3 = true
		Util.Sound:Play("BF_Thunder_RumbleDragon_03_Explosion_01", clone2.Position)
		task.wait(0.1)
		local clone5 = assets.Phase1.Explosion:Clone()
		clone5.CFrame = clone2.CFrame
		Util.SetParentOverrideWithColor(clone5, folder, player, "LightningFruitVFXColor")

		if v then
			pcall(function()
				clone5.Model1.Impact.Attachment.Particle_2.Color = ColorSequence.new(Color3.fromRGB(190, 106, 250))
			end)
		end

		DeleteImpactAfterDuration(clone5) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone5:GetDescendants()) do
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

		if (workspace.CurrentCamera.CFrame.p - clone2.Position).Magnitude < 100 then
			Util.CameraShaker:ShakeOnce(14, 14, 0.2, 1)
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

		local raycastResult = workspace:Raycast(
			clone2.Position + createVector(0, 1, 0),
			createVector(-0, -25, -0),
			raycastParams
		)

		if raycastResult then
			local clone6 = FX:WaitForChild("Lightning2").Z_Charged.Assets.Phase2.GroundBurn:Clone()
			clone6.CFrame = AlignCFrame(CFrame.new(raycastResult.Position), raycastResult.Normal) + raycastResult.Normal * 0.01
			Util.SetParentOverrideWithColor(clone6, folder, player, "LightningFruitVFXColor")
			DeleteImpactAfterDuration(clone4) -- equivalent call inferred; original call site unknown

			for _, emitter in pairs(clone6:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end

		task.wait(0.1)
		clone2:Destroy()
	end
end