local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local debris = Util.Debris
local boatTween = Util.BoatTween
local ChestData = require(script.ChestData)
local _ = {
	MAX_DIST = 600
}

local function lerpInCubic(p, p2, p3)
	return p + (p2 - p) * p3 ^ 3
end

return function(player)
	local ID = player.ID
	local model = player.Model
	local velocity = player.Velocity
	local character = player.Character
	local v = ChestData[ID]
	local NAME = v.NAME

	if model and model:FindFirstChild("LootTexture") then
		local cFrame = model.LootTexture.CFrame

		if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > 600 then
			return
		end

		local random = Random.new()
		local descendants = model:GetDescendants()
		local v2 = {}

		for _, instance in ipairs(descendants) do
			if not (instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("PointLight")) then
				continue
			end

			instance.Enabled = false
			table.insert(v2, instance)
		end

		local clone = script.ChestEffects[NAME]:Clone()
		debris:AddItem(clone, 5)
		clone.CFrame = cFrame

		if character then
			local v3 = {
				bounceDecay = 0.6,
				frictionDecay = 0.95,
				gravity = createVector(0, -196.2, 0),
				coinAmount = random:NextInteger(v.LOOT.AMOUNT.Min, v.LOOT.AMOUNT.Max) or random:NextInteger(7, 10),
				spawnDelay = v.LOOT.DELAY,
				maxSpeed = 200,
				minBounce = 5
			}
			local v4 = {}
			task.spawn(function()
				for _ = 1, v3.coinAmount do
					if not clone or (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude > 1500 then
						break
					end

					local clone2 = script.BounceLoot:Clone()
					debris:AddItem(clone2, 5)
					clone2.CFrame = clone.CFrame * CFrame.new(math.random(-1, 1), 0, math.random(-1, 1))
					clone2.Parent = _WorldOrigin

					if NAME == "Fragment" then
						local lootParticle = clone2.Attachment.LootParticle
						lootParticle.Texture = "rbxassetid://18890899129"
						lootParticle.Color = ColorSequence.new(Color3.fromRGB(145, 66, 184))
						lootParticle.Rotation = NumberRange.new(-50, 50)
						lootParticle.Size = NumberSequence.new(0.8)
						lootParticle.Brightness = 2.5
					end

					clone2.Attachment.LootParticle:Emit(1)

					if clone2 ~= nil then
						table.insert(v4, {
							clone2,
							Vector3.new(math.random(-20, 20), math.random(40, 70), math.random(-20, 20)),
							os.clock(),
							clone2.Position
						})
					end

					task.wait(v3.spawnDelay)
				end
			end)
			task.spawn(function()
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				local clone2

				if character and humanoidRootPart then
					clone2 = script.CoinCollect.Collect:Clone()
					debris:AddItem(clone2, 6)
					clone2.Parent = humanoidRootPart
				end

				local v5 = v3.spawnDelay * v3.coinAmount + 2
				local lastTime = os.clock()
				local v6 = RunService.Heartbeat:Wait()
				local v7 = os.clock() - lastTime
				local count = 0

				while v7 < v5 do
					v7 = os.clock() - lastTime

					if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 1000 then
						break
					end

					for i, v8 in ipairs(v4) do
						local v9 = os.clock() - v8[3]

						if v9 < 1 then
							if v8[1] then
								v8[4] = v8[1].Position
							end

							v8[2] += v3.gravity * v6
							v8[2] = v8[2].Magnitude > v3.maxSpeed and v8[2].Unit * v3.maxSpeed or v8[2]
							local v10 = v8[2] * v6
							local ray, v11, v12 = Util.Ray(
								v8[1].Position,
								v10,
								{ workspace.Characters, workspace.Enemies },
								false
							)

							if ray then
								if math.abs((v8[2]:Dot(v12))) > v3.minBounce then
									local dot = v8[2]:Dot(v12)
									v8[2] = (v8[2] - 2 * dot * v12) * v3.bounceDecay
									local v13 = v8[2] - v8[2]:Dot(v12) * v12
									v8[2] = v8[2]:Dot(v12) * v12 + v13 * v3.frictionDecay
									v8[1].Position = v11 + v12 * 0.1
								else
									v8[2] = createVector(0, 0, 0)
									v8[1].Position = v11 + v12 * 0.1
								end
							else
								v8[1].Position = v8[1].Position + v10
							end
						elseif character and humanoidRootPart then
							local v10 = math.min(0.5, v9 - 1) / 0.5
							local v11 = v8[1]
							local v12 = v8[4]
							v11.Position = v12 + (humanoidRootPart.Position - v12) * v10 ^ 3

							if v10 >= 1 then
								if v8[1] then
									v8[1]:Destroy()
								end

								if clone2 then
									count += 1

									if count == v3.coinAmount then
										Util.Sound:Play(
											"CoinCollect" .. random:NextInteger(1, 3),
											humanoidRootPart,
											nil,
											1 + random:NextNumber(-1, 1) / 6 + count / 20,
											0.45
										)
									else
										Util.Sound:Play(
											"CoinCollect5",
											humanoidRootPart,
											nil,
											1 + random:NextNumber(-1, 1) / 6 + count / 20,
											0.45
										)
									end

									clone2.Position = Vector3.new(
										random:NextNumber(-2, 2),
										random:NextNumber(-1, 1),
										random:NextNumber(-2, 2)
									)

									for _, child in ipairs(clone2:GetChildren()) do
										child:Emit(child:GetAttribute("EmitCount"))
									end
								end

								table.remove(v4, i)
							end
						end
					end

					v6 = RunService.Heartbeat:Wait()
				end

				for _, v8 in ipairs(v4) do
					if v8[1] then
						v8[1]:Destroy()
					end

					v4 = nil
				end

				if clone2 then
					clone2:Destroy()
				end
			end)
		end

		local bottomWood = model:FindFirstChild("BottomWood")

		if bottomWood then
			local motor6D = Instance.new("Motor6D")
			motor6D.Part0 = bottomWood
			motor6D.Part1 = clone
			motor6D.Parent = bottomWood
			motor6D.C0 = CFrame.new(0, 1, 0)
		end

		clone.Anchored = false
		clone.Parent = _WorldOrigin
		Util.Sound:Play(v.SOUND, clone, nil, 1 + math.random(-7, 7) / 100, 0.5)
		local beams = clone.Beams
		local v3 = {}
		local children = clone.RepeatingParticles:GetChildren()
		local children2 = clone.OneOffParticles:GetChildren()

		if clone:FindFirstChild("Lines") then
			table.insert(children, clone.Lines)
		end

		if clone:FindFirstChild("FogAttachment") then
			for _, child in ipairs(clone.FogAttachment:GetChildren()) do
				table.insert(children2, child)
			end
		end

		if NAME == "Fragment" then
			for _, emitter in ipairs(clone:GetChildren()) do
				if emitter:IsA("ParticleEmitter") and emitter.Name ~= "Lines" then
					table.insert(children, emitter)
				end
			end
		end

		for _, v4 in ipairs(v.LOOT.PARTICLES) do
			table.insert(v3, clone[v4])
		end

		if model:FindFirstChild("AnimationController") then
			local children3 = model:GetChildren()

			for _, part in ipairs(children3) do
				if not part:IsA("BasePart") then
					continue
				end

				for _, v4 in ipairs(v.LOOSE) do
					if part.Name == v4 then
						part.Transparency = 1
					end
				end
			end

			local clone2 = script.Gibs[NAME .. "Lock"]:Clone()
			local v4 = math.random(30, 50) / 10
			debris:AddItem(clone2, v4)
			clone2.CFrame = clone.CFrame * CFrame.new(0, 0.018, -1.86)
			local model2 = Instance.new("Model", _WorldOrigin)
			debris:AddItem(model2, v4)
			clone2.Parent = model2
			clone2.Anchored = false
			local destroyingConnection = nil
			destroyingConnection = clone2.Destroying:Connect(function()
				if clone2 then
					Effect.new("Chests.Despawn"):play({
						Adornee = clone2
					})
				end

				destroyingConnection:Disconnect()
			end)
			local children4 = model:GetChildren()

			for _, v5 in ipairs(children4) do
				for _, v6 in ipairs({ "Spikes", "Crystals" }) do
					if v5.Name == v6 then
						v5.Transparency = 1
					end
				end
			end

			local pushBox = model:FindFirstChild("PushBox")
			local localPlayer = game.Players.LocalPlayer
			local humanoidRootPart = pushBox and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				task.spawn(function()
					local v5 = {
						MinForce = 50000,
						MaxForce = 200000,
						Range = 5,
						Duration = 3,
						Dir = createVector(0, 0, 0),
						VectorForce = pushBox.VectorForce,
						Start = os.clock()
					}

					if velocity then
						pushBox:ApplyImpulse(velocity)
					end

					while humanoidRootPart and pushBox and not (os.clock() - v5.Start > v5.Duration) do
						local cframe = CFrame.new(pushBox.Position, humanoidRootPart.Position)
						local v6 = math.max((pushBox.Position - humanoidRootPart.Position).Magnitude, 1)

						if v6 <= v5.Range then
							local cross = cframe.RightVector:Cross(createVector(0, 1, 0))
							local v7 = v5.MaxForce / v6 ^ 0.25
							v5.Dir = cross.Unit
							v5.VectorForce.Force = v5.Dir * math.clamp(v7, v5.MinForce, v5.MaxForce)
						else
							v5.Dir = Vector3.new()
							v5.VectorForce.Force = Vector3.new()
						end

						RunService.PreRender:Wait()
					end
				end)
			end

			local clone3 = script.Gibs[NAME .. "Lid"]:Clone()
			local children5 = clone3:GetChildren()

			for _, v5 in ipairs(children5) do
				v5.CollisionGroup = "Chest"
			end

			debris:AddItem(clone3, math.random(30, 50) / 10)
			clone3:SetPrimaryPartCFrame(clone.CFrame * CFrame.new(0, 3, 0))
			clone3.Parent = _WorldOrigin
			local destroyingConnection2 = nil
			destroyingConnection2 = clone3.Destroying:Connect(function()
				if clone3 then
					Effect.new("Chests.Despawn"):play({
						Adornee = clone3.PrimaryPart
					})
				end

				destroyingConnection2:Disconnect()
			end)
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Velocity = clone.CFrame:VectorToWorldSpace((Vector3.new(
				math.random(-7, 7),
				45,
				math.random(8, 12)
			)))
			bodyVelocity.Parent = clone3.PrimaryPart
			clone3.PrimaryPart:ApplyAngularImpulse((Vector3.new(
				math.random(-25, 25),
				math.random(-15, 15),
				math.random(20, 55)
			)))
			debris:AddItem(bodyVelocity, 1)
			task.delay(0.2, function()
				if bodyVelocity then
					bodyVelocity:Destroy()
				end
			end)
			local bodyVelocity2 = Instance.new("BodyVelocity")
			bodyVelocity2.Velocity = clone.CFrame:VectorToWorldSpace((Vector3.new(
				math.random(-7, 7),
				20,
				math.random(-20, -10)
			)))
			bodyVelocity2.Parent = clone2
			debris:AddItem(bodyVelocity2, 1)
			task.delay(0.1, function()
				if bodyVelocity2 then
					bodyVelocity2:Destroy()
				end
			end)
			local _ = { CFrame.new(-1.9, 0.61, 2.92), CFrame.new(0, 1.08, 2.51), CFrame.new(1.9, 1.48, 2.99) }
		end

		Util.Sound:Play("ZapSaberHit", clone, nil, 1.1 + math.random(-20, 20) / 100, 0.4)
		task.delay(v.OPEN_DELAY, function()
			if model then
				local lastTime = os.clock()
				local v5 = {}

				for _, list in ipairs({ children, v3, children2 }) do
					for _, v6 in ipairs(list) do
						v5[v6] = { lastTime, v6:getAttribute("EmitCount") or 1, v6:getAttribute("EmitDelay") or 0.5 }
					end
				end

				local pointLight = Instance.new("PointLight")
				debris:AddItem(pointLight, v.EMIT_DUR + 1)
				pointLight.Color = v.LIGHT_COL
				pointLight.Range = 0
				pointLight.Brightness = 2
				pointLight.Parent = clone
				boatTween:Create(pointLight, {
					Time = v.EMIT_DUR,
					EasingStyle = "Bounce",
					EasingDirection = "Out",
					DelayTime = 0,
					RepeatCount = 0,
					Reverses = true,
					StepType = "Heartbeat",
					Goal = {
						Range = v.LIGHT_RADIUS,
						Brightness = v.LIGHT_BRIGHT
					}
				}):Play()

				for _, beam in ipairs(beams:GetChildren()) do
					if not beam:IsA("Beam") then
						continue
					end

					beam.Enabled = true
					boatTween:Create(beam, {
						Time = v.BEAM_DUR,
						EasingStyle = "Sine",
						EasingDirection = "In",
						DelayTime = 0,
						RepeatCount = 0,
						Reverses = false,
						StepType = "Heartbeat",
						Goal = {
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(0.5, 1),
								NumberSequenceKeypoint.new(1, 1)
							})
						}
					}):Play()
				end

				if NAME == "Diamond" or NAME == "Mirage" then
					local spill = beams.Spill

					for _, beam in ipairs(spill:GetChildren()) do
						if not beam:IsA("Beam") then
							continue
						end

						beam.Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(0.5, 1),
							NumberSequenceKeypoint.new(1, 1)
						})
						beam.Enabled = true
						local v6 = boatTween:Create(beam, {
							Time = 0.5,
							EasingStyle = "Sine",
							EasingDirection = "In",
							DelayTime = 0,
							RepeatCount = 0,
							Reverses = false,
							StepType = "Heartbeat",
							Goal = {
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new(0.5, 0),
									NumberSequenceKeypoint.new(1, 0)
								})
							}
						})
						local v7 = beam
						v6.Completed:Once(function()
							boatTween:Create(v7, {
								Time = math.max(0.1, v.LOOT_DUR - 0.2),
								EasingStyle = "Sine",
								EasingDirection = "Out",
								DelayTime = 0,
								RepeatCount = 0,
								Reverses = false,
								StepType = "Heartbeat",
								Goal = {
									Transparency = NumberSequence.new({
										NumberSequenceKeypoint.new(0, 1),
										NumberSequenceKeypoint.new(0.5, 1),
										NumberSequenceKeypoint.new(1, 1)
									})
								}
							}):Play()
						end)
						v6:Play()
					end
				end

				local v6 = math.max(v.EMIT_DUR, v.LOOT_DUR, v.BEAM_DUR)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function canRun()
					return os.clock() - lastTime <= v6
				end

				for _, v7 in ipairs(children2) do
					v7:Emit(v5[v7][2])
				end

				while canRun() do
					local v7 = os.clock() - lastTime

					if v7 < v.LOOT_DUR then
						for _, v8 in ipairs(v3) do
							if not (os.clock() - v5[v8][1] > v5[v8][3]) then
								continue
							end

							v8:Emit(v5[v8][2])
							v5[v8][1] = os.clock()
						end
					end

					if v7 < v.EMIT_DUR then
						for _, v8 in ipairs(children) do
							if not (os.clock() - v5[v8][1] > v5[v8][3]) then
								continue
							end

							v8:Emit(v5[v8][2])
							v5[v8][1] = os.clock()
						end
					end

					RunService.Heartbeat:Wait()
				end
			end
		end)
	end
end