local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Ray = require(ReplicatedStorage.Util.Ray)
local Debris = require(ReplicatedStorage.Util.Debris)
local Sound = require(ReplicatedStorage.Util.Sound)
local TableUtil = require(ReplicatedStorage.Modules.TableUtil)
local chests = ReplicatedStorage.EffectContainer.Chests
local v = {
	MAX_DIST = 600
}
local v2 = {
	{
		NAME = "Mirage",
		EMIT_DUR = 1.7,
		LOOT_DUR = 2,
		LOOT = {
			PARTICLES = { "Bills" },
			AMOUNT = NumberRange.new(30, 60),
			DELAY = 0.06
		},
		SOUND = "DiamondChestOpen"
	},
	{
		NAME = "Fragment",
		EMIT_DUR = 1.2,
		LOOT_DUR = 1.5,
		LOOT = {
			PARTICLES = { "Fragments", "FragmentsSpill" },
			AMOUNT = NumberRange.new(15, 30),
			DELAY = 0.08
		},
		SOUND = "FragmentChestOpen"
	}
}
local v3 = {
	bounceDecay = 0.6,
	frictionDecay = 0.95,
	gravity = createVector(0, -196.2, 0),
	maxSpeed = 200,
	minBounce = 5,
	velocityOffset = {
		x = { -20, 20 },
		y = { 40, 70 },
		z = { -20, 20 }
	}
}
TableUtil.deepFreeze(v3)
TableUtil.deepFreeze(v2)
TableUtil.deepFreeze(v)

local function lerpInCubic(vector2: Vector3, vector3: Vector3, p: number)
	return vector2 + (vector3 - vector2) * p ^ 3
end

return function(player)
	local character = player.Character
	local v4 = v2[player.ID]
	local cFrame = player.CFrame

	if (workspace.CurrentCamera.CFrame.Position - cFrame.Position).Magnitude > v.MAX_DIST then
		return
	end

	local random = Random.new()
	local clone = chests.Open.ChestEffects[v4.NAME]:Clone()
	Debris:AddItem(clone, 5)
	clone.CFrame = cFrame

	if character then
		local copy = TableUtil.deepCopy(v3)
		copy.coinAmount = random:NextInteger(v4.LOOT.AMOUNT.Min, v4.LOOT.AMOUNT.Max) or random:NextInteger(7, 10)
		copy.spawnDelay = v4.LOOT.DELAY
		local v5 = {}
		task.spawn(function()
			for _ = 1, copy.coinAmount do
				if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude > 1500 then
					break
				end

				local clone2 = chests.Open.BounceLoot:Clone()
				Debris:AddItem(clone2, 5)
				clone2.CFrame = clone.CFrame * CFrame.new(math.random(-1, 1), 0, math.random(-1, 1))
				clone2.Parent = _WorldOrigin

				if v4.NAME == "Fragment" then
					local lootParticle = clone2.Attachment.LootParticle
					lootParticle.Texture = "rbxassetid://18890899129"
					lootParticle.Color = ColorSequence.new(Color3.fromRGB(145, 66, 184))
					lootParticle.Rotation = NumberRange.new(-50, 50)
					lootParticle.Size = NumberSequence.new(0.8)
					lootParticle.Brightness = 2.5
				end

				clone2.Attachment.LootParticle:Emit(1)

				if clone2 ~= nil then
					table.insert(v5, {
						clone2,
						Vector3.new(
							math.random(copy.velocityOffset.x[1], copy.velocityOffset.x[2]),
							math.random(copy.velocityOffset.y[1], copy.velocityOffset.y[2]),
							math.random(copy.velocityOffset.z[1], copy.velocityOffset.z[2])
						),
						os.clock(),
						clone2.Position
					})
				end

				task.wait(copy.spawnDelay)
			end
		end)
		task.spawn(function()
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local clone2

			if character and humanoidRootPart then
				clone2 = chests.Open.CoinCollect.Collect:Clone()
				Debris:AddItem(clone2, 6)
				clone2.Parent = humanoidRootPart
			end

			local v6 = copy.spawnDelay * copy.coinAmount + 2
			local lastTime = os.clock()
			local v7 = RunService.Heartbeat:Wait()
			local v8 = os.clock() - lastTime
			local count = 0

			while v8 < v6 do
				v8 = os.clock() - lastTime

				if humanoidRootPart and (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 1000 then
					break
				end

				for i, v9 in ipairs(v5) do
					local v10 = os.clock() - v9[3]

					if v10 < 1 then
						if v9[1] then
							v9[4] = v9[1].Position
						end

						v9[2] += copy.gravity * v7
						v9[2] = v9[2].Magnitude > copy.maxSpeed and v9[2].Unit * copy.maxSpeed or v9[2]
						local v11 = v9[2] * v7
						local v12, v13, v14 = Ray(
							v9[1].Position,
							v11,
							{ workspace.Characters, workspace:FindFirstChild("Enemies") },
							false
						)

						if v12 and v13 and v14 then
							if math.abs((v9[2]:Dot(v14))) > copy.minBounce then
								local dot = v9[2]:Dot(v14)
								v9[2] = (v9[2] - 2 * dot * v14) * copy.bounceDecay
								local v15 = v9[2] - v9[2]:Dot(v14) * v14
								v9[2] = v9[2]:Dot(v14) * v14 + v15 * copy.frictionDecay
								v9[1].Position = v13 + v14 * 0.1
							else
								v9[2] = createVector(0, 0, 0)
								v9[1].Position = v13 + v14 * 0.1
							end
						else
							v9[1].Position = v9[1].Position + v11
						end
					elseif character and humanoidRootPart then
						local v11 = math.min(0.5, v10 - 1) / 0.5
						local v12 = v9[1]
						local v13 = v9[4]
						v12.Position = v13 + (humanoidRootPart.Position - v13) * v11 ^ 3

						if v11 >= 1 then
							if v9[1] then
								v9[1]:Destroy()
							end

							if clone2 then
								count += 1

								if count == copy.coinAmount then
									Sound:Play(
										"CoinCollect" .. random:NextInteger(1, 3),
										humanoidRootPart,
										nil,
										1 + random:NextNumber(-1, 1) / 6 + count / 20,
										0.45
									)
								else
									Sound:Play(
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

							table.remove(v5, i)
						end
					end
				end

				v7 = RunService.Heartbeat:Wait()
			end

			for _, v9 in ipairs(v5) do
				if v9[1] then
					v9[1]:Destroy()
				end
			end

			if clone2 then
				clone2:Destroy()
			end
		end)
	end

	clone.Anchored = false
	clone.Parent = _WorldOrigin
	Sound:Play(v4.SOUND, clone, nil, 1 + math.random(-7, 7) / 100, 0.5)
	local v5 = {}
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

	if v4.NAME == "Fragment" then
		for _, emitter in ipairs(clone:GetChildren()) do
			if emitter:IsA("ParticleEmitter") and emitter.Name ~= "Lines" then
				table.insert(children, emitter)
			end
		end
	end

	for _, v6 in ipairs(v4.LOOT.PARTICLES) do
		table.insert(v5, clone[v6])
	end

	Sound:Play("ZapSaberHit", clone, nil, 1.1 + math.random(-20, 20) / 100, 0.4)
	task.spawn(function()
		local lastTime = os.clock()
		local v7 = {}

		for _, list in ipairs({ children, v5, children2 }) do
			for _, v8 in ipairs(list) do
				v7[v8] = { lastTime, v8:getAttribute("EmitCount") or 1, v8:getAttribute("EmitDelay") or 0.5 }
			end
		end

		local v8 = math.max(v4.EMIT_DUR, v4.LOOT_DUR)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function canRun()
			return os.clock() - lastTime <= v8
		end

		for _, v9 in ipairs(children2) do
			v9:Emit(v7[v9][2])
		end

		while canRun() do
			local v9 = os.clock() - lastTime

			if v9 < v4.LOOT_DUR then
				for _, v10 in ipairs(v5) do
					if not (os.clock() - v7[v10][1] > v7[v10][3]) then
						continue
					end

					v10:Emit(v7[v10][2])
					v7[v10][1] = os.clock()
				end
			end

			if v9 < v4.EMIT_DUR then
				for _, v10 in ipairs(children) do
					if not (os.clock() - v7[v10][1] > v7[v10][3]) then
						continue
					end

					v10:Emit(v7[v10][2])
					v7[v10][1] = os.clock()
				end
			end

			RunService.Heartbeat:Wait()
		end
	end)
end