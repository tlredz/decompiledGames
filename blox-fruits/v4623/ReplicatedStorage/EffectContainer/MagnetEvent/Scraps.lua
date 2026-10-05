local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local scraps = FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local _WorldOrigin = workspace._WorldOrigin
local v = {}
local v2 = {}

local function bezier(p, p2, p3, p4)
	local v3 = 1 - p4
	return v3 * v3 * p + 2 * v3 * p4 * p2 + p4 * p4 * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function randBetween(p, p2)
	return p + math.random() * (p2 - p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function randSign()
	if math.random() < 0.5 then
		return 1
	end

	return -1
end

return function(data)
	local origin = data.Origin or data.Root and data.Root.Position or data.hrp and data.hrp.Position or data.Player and data.Player.Character.PrimaryPart.Position
	assert(origin, "Origin Vector3 missing in: ", script:GetFullName())
	local magnetEventTokens = workspace._WorldOrigin.InteractiveEffects:FindFirstChild("MagnetEventTokens")

	if not magnetEventTokens then
		return
	end

	local player = data.Player
	local child = magnetEventTokens:FindFirstChild(player.Name)

	if not child then
		return
	end

	local children = scraps.PassiveScraps:GetChildren()

	if not v[player.Name] then
		v[player.Name] = {}
	end

	local v3 = v[player.Name]
	local root = data.Root

	local function animateAbsorb(child2, absorbing)
		v3[child2] = nil
		local position = child2.Position
		local unit = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
		local v4 = (5 + math.random() * 7) * randSign()
		child2.Anchored = true
		child2.CanCollide = false
		local lastTime = tick()
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v5 = tick() - lastTime
			local v6 = math.clamp(v5 / absorbing, 0, 1)
			local v7 = v6 * v6
			local position2 = root.Position
			local v8 = (position + position2) * 0.5 + Vector3.new(0, (position - position2).Magnitude * 0.35, 0)
			local v10 = 1 - v7
			local v11 = v10 * v10 * position + 2 * v10 * v7 * v8 + v7 * v7 * position2
			child2.CFrame = CFrame.new(v11) * CFrame.fromAxisAngle(unit, v4 * (v7 * 4 + 1) * v5)

			if v6 >= 1 then
				renderSteppedConnection:Disconnect()
				local clone = scraps.AbsorbImpact:Clone()
				clone.CFrame = CFrame.new(child2.Position)
				clone.Parent = _WorldOrigin
				local sound = child2:FindFirstChildOfClass("Sound")

				if sound then
					sound:Destroy()
				end

				Util.Sound:Play("Magnet_Floating_Scrap_Pickup_01", root.Position)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end

				task.delay(1, function()
					clone:Destroy()
				end)
				child2:Destroy()
			end
		end)
	end

	if not v2[player.Name] then
		tick()
		v2[player.Name] = true
		child.ChildRemoved:Connect(function(child2)
			if string.find(child2.Name, "_Server") then
				local child3 = child:FindFirstChild("Scraps" .. tonumber(string.match(child2.Name, "%d+")) .. "_Client")

				if child3 then
					if child2:GetAttribute("Absorbing") then
						child3:SetAttribute("Absorbing", true)
						print("ABSORB")
						animateAbsorb(child3, child2:GetAttribute("Absorbing"))
					else
						v3[child3] = nil
						child3:Destroy()
					end
				end
			end
		end)
		RunService.RenderStepped:Connect(function()
			local now = tick()

			for k, v4 in pairs(v3) do
				if typeof(k) ~= "Instance" or typeof(v4) ~= "table" or k:GetAttribute("Absorbing") then
					continue
				end

				if k.Parent then
					if not ((currentCamera.CFrame.Position - k.Position).Magnitude > 250) then
						local v5 = now - v4.startTime
						local v6 = v4.surfacePos.Y + v4.hoverHeight + math.sin(v5 * v4.bobSpeed * 3.141592653589793 * 2) * 0.15
						local v7 = v4.arrivalCF * CFrame.Angles(v4.rotX * v5, v4.rotY * v5, v4.rotZ * v5)
						k.CFrame = CFrame.new(v4.surfacePos.X, v6, v4.surfacePos.Z) * v7.Rotation

						if v5 > 120 then
							v3[k] = nil
							local clone = scraps.DisappearImpact:Clone()
							clone.CFrame = CFrame.new(k.Position)
							clone.Parent = _WorldOrigin

							for _, emitter in pairs(clone:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end

							task.delay(1, function()
								clone:Destroy()
							end)
							k:Destroy()
						end
					end
				else
					v3[k] = nil
				end
			end
		end)
	end

	local function animateScrap(clone, position, surfacePos, hoverHeight, travelTime, r)
		local clone2 = scraps.ScrapAura:Clone()
		clone2.CFrame = CFrame.new(position)
		clone2.Anchored = false
		clone2.Massless = true
		clone2.Weld.Part1 = clone
		clone2.Parent = clone

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
			elseif effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local vector = Vector3.new(surfacePos.X, surfacePos.Y + hoverHeight, surfacePos.Z)
		local v4 = r * 0.7 + math.random() * r * 0.2
		local vector2 = Vector3.new(
			(position.X + vector.X) * 0.5,
			math.max(position.Y, vector.Y) + v4,
			(position.Z + vector.Z) * 0.5
		)
		local unit = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
		local v5 = (math.random() * 2 - 1) * 8
		local v6 = math.clamp(1.6 - r * 0.02, 0.5, 1.6)
		local v7 = math.clamp(0.5 - r * 0.01, 0.15, 0.5)
		local lastTime = tick()
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v8 = tick() - lastTime
			local v9 = math.clamp(v8 / travelTime, 0, 1)
			local v13 = 1 - v9
			local v14 = v13 * v13 * position + 2 * v13 * v9 * vector2 + v9 * v9 * vector
			clone.CFrame = CFrame.new(v14) * CFrame.fromAxisAngle(unit, v5 * v8)

			if v9 >= 1 then
				renderSteppedConnection:Disconnect()

				for _, trail in pairs(clone2:GetDescendants()) do
					if trail:IsA("Trail") then
						trail.Enabled = true
					end
				end

				v3[clone] = {
					surfacePos = surfacePos,
					hoverHeight = hoverHeight,
					arrivalCF = clone.CFrame,
					bobSpeed = 0.33 + math.random() * 0.22000000000000003,
					rotX = randBetween(v7, v6) * randSign(),
					rotY = randBetween(v7, v6) * randSign(),
					rotZ = randBetween(v7, v6) * randSign(),
					startTime = tick()
				}
			end
		end)
	end

	local function playExplode(scrapData)
		for _, scrap in ipairs(scrapData.scraps) do
			local clone = children[math.random(1, #children)]:Clone()
			clone.Name = "Scraps" .. scrap.serverId .. "_Client"
			clone.Anchored = true
			clone.CanCollide = false
			clone.CastShadow = true
			clone.Parent = child
			Util.Sound:Play("Magnet_Floating_Scrap_Ambient_Aura_01", clone)
			animateScrap(clone, scrapData.origin, scrap.surfacePos, scrap.hoverHeight, scrap.travelTime, scrapData.r)
		end
	end

	local function playSlash(scrapData)
		for _, scrap in ipairs(scrapData.scraps) do
			local clone = children[math.random(1, #children)]:Clone()
			clone.Name = "Scraps" .. scrap.serverId .. "_Client"
			clone.Anchored = true
			clone.CanCollide = false
			clone.CastShadow = true
			clone.Parent = child
			animateScrap(clone, scrap.spawnPos, scrap.surfacePos, scrap.hoverHeight, scrap.travelTime, scrapData.r)
		end
	end

	local scrapData = data.ScrapData

	if scrapData then
		if (currentCamera.CFrame.Position - origin).Magnitude > 1200 then
			return
		end

		if scrapData.scrapType == "Explode" then
			playExplode(scrapData)
		elseif scrapData.scrapType == "Slash" then
			playSlash(scrapData)
		end
	end
end