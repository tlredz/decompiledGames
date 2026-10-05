local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
game:GetService("TweenService")
local Players = game:GetService("Players")
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local scraps = FX:WaitForChild("Magnet"):WaitForChild("Scraps")
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
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

local function RecolorMagnetColor(instance, p)
	if typeof(instance) == "Instance" and instance.Parent then
		return WrapColor3Constructor(p, instance, "MagnetFruitVFXColor")
	end

	return p
end

local function isCrimsonGoldSkinEquipped(instance)
	if typeof(instance) == "Instance" then
		local magnetFruitVFXColor = instance:FindFirstChild("MagnetFruitVFXColor")

		if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
			return true
		end
	end

	return false
end

local function getRoot(player)
	if player.Root then
		return player.Root
	end

	if player.hrp then
		return player.hrp
	end

	local character = player.Character

	if typeof(character) == "Instance" and character:IsA("Model") then
		return character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
	end

	local player2 = player.Player or player.player

	if typeof(player2) == "Instance" then
		if player2:IsA("Player") then
			local character2 = player2.Character
			return character2 and (character2.PrimaryPart or character2:FindFirstChild("HumanoidRootPart"))
		elseif player2:IsA("Model") then
			return player2.PrimaryPart or player2:FindFirstChild("HumanoidRootPart")
		end
	elseif type(player2) == "table" then
		local character2 = player2.Character

		if typeof(character2) == "Instance" and character2:IsA("Model") then
			return character2.PrimaryPart or character2:FindFirstChild("HumanoidRootPart")
		end
	end

	return nil
end

local function getColorOwner(player, root)
	local player2 = player.Player or player.player

	if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
		return player2
	end

	local character = player.Character

	if typeof(character) == "Instance" and character:IsA("Model") then
		return Players:GetPlayerFromCharacter(character)
	end

	if type(player2) == "table" then
		local character2 = player2.Character

		if typeof(character2) == "Instance" and character2:IsA("Model") then
			return Players:GetPlayerFromCharacter(character2)
		end
	end

	local parent = root and root.Parent

	if typeof(parent) == "Instance" and parent:IsA("Model") then
		return Players:GetPlayerFromCharacter(parent)
	end

	return nil
end

local function getScrapBinName(data, colorOwner, root)
	if type(data.ScrapBinName) == "string" then
		return data.ScrapBinName
	end

	if type(data.ScrapOwnerName) == "string" then
		return data.ScrapOwnerName
	end

	if colorOwner then
		return colorOwner.Name
	end

	local player = data.Player or data.player

	if typeof(player) == "Instance" then
		return player.Name
	end

	if type(player) == "table" then
		if type(player.Name) == "string" then
			return player.Name
		end

		if player.Data and type(player.Data.Name) == "string" then
			return player.Data.Name
		end

		if typeof(player.Character) == "Instance" then
			return player.Character.Name
		end
	end

	local parent = root and root.Parent

	if typeof(parent) == "Instance" then
		return parent.Name
	end

	return nil
end

return function(data)
	local root = getRoot(data)
	local origin = data.Origin or root and root.Position
	assert(origin, "Origin Vector3 missing in: " .. script:GetFullName())
	local interactiveEffects = workspace._WorldOrigin:FindFirstChild("InteractiveEffects")

	if not interactiveEffects then
		return
	end

	local magnetFruitScraps = interactiveEffects:FindFirstChild("MagnetFruitScraps")

	if not magnetFruitScraps then
		return
	end

	local colorOwner = getColorOwner(data, root)
	local scrapBinName = getScrapBinName(data, colorOwner, root)

	if not scrapBinName then
		return
	end

	local child = magnetFruitScraps:FindFirstChild(scrapBinName)

	if not child then
		return
	end

	local player = data.Player
	local v3

	if typeof(player) == "Instance" then
		local magnetFruitVFXColor = player:FindFirstChild("MagnetFruitVFXColor")
		v3 = magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" and true or false
	else
		v3 = false
	end

	local children

	if v3 then
		children = scraps.ArcsteelPassiveScraps:GetChildren()
	else
		children = scraps.PassiveScraps:GetChildren()
	end

	if not v[scrapBinName] then
		v[scrapBinName] = {}
	end

	local v4 = v[scrapBinName]
	local player2 = data.Player
	local Players2 = game:GetService("Players")

	if player2 == Players2.LocalPlayer then
		if child:FindFirstChild("Highlight") then
			local highlight = child:FindFirstChild("Highlight")
			local player3 = data.Player
			local color = Color3.fromRGB(0, 0, 255)

			if typeof(player3) == "Instance" and player3.Parent then
				color = WrapColor3Constructor(color, player3, "MagnetFruitVFXColor")
			end

			highlight.OutlineColor = color
		else
			local highlight = Instance.new("Highlight")
			highlight.Enabled = true
			local player3 = data.Player
			local color = Color3.fromRGB(0, 0, 255)

			if typeof(player3) == "Instance" and player3.Parent then
				color = WrapColor3Constructor(color, player3, "MagnetFruitVFXColor")
			end

			highlight.OutlineColor = color
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 0.25
			highlight.Parent = child
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function SetParentWithMagnetColor(clone, parent)
		if colorOwner then
			Util.SetParentOverrideWithColor(clone, parent, colorOwner, "MagnetFruitVFXColor")
		else
			clone.Parent = parent
		end
	end

	local function animateAbsorb(child2, absorbing)
		v4[child2] = nil

		if not (root and root.Parent) then
			child2:Destroy()
			return
		end

		local position = child2.Position
		local unit = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
		local v5 = (5 + math.random() * 7) * randSign()
		child2.Anchored = true
		child2.CanCollide = false
		local lastTime = tick()
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v6 = tick() - lastTime
			local v7 = math.clamp(v6 / absorbing, 0, 1)
			local v8 = v7 * v7
			local position2 = root.Position
			local v9 = (position + position2) * 0.5 + Vector3.new(0, (position - position2).Magnitude * 0.35, 0)
			local v11 = 1 - v8
			local v12 = v11 * v11 * position + 2 * v11 * v8 * v9 + v8 * v8 * position2
			child2.CFrame = CFrame.new(v12) * CFrame.fromAxisAngle(unit, v5 * (v8 * 4 + 1) * v6)

			if v7 >= 1 then
				renderSteppedConnection:Disconnect()
				local clone = scraps.AbsorbImpact:Clone()
				clone.CFrame = CFrame.new(child2.Position)
				SetParentWithMagnetColor(clone, _WorldOrigin) -- equivalent call inferred; original call site unknown
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

	local v5 = v2[scrapBinName]

	if not v5 or v5.bin ~= child then
		if v5 then
			if v5.despawnConn then
				v5.despawnConn:Disconnect()
			end

			if v5.loopConn then
				v5.loopConn:Disconnect()
			end
		end

		local v6 = {
			bin = child
		}
		v2[scrapBinName] = v6
		v6.despawnConn = child.ChildRemoved:Connect(function(child2)
			if string.find(child2.Name, "_Server") then
				local child3 = child:FindFirstChild("Scraps" .. tonumber(string.match(child2.Name, "%d+")) .. "_Client")

				if child3 then
					if child2:GetAttribute("Absorbing") then
						child3:SetAttribute("Absorbing", child2:GetAttribute("Absorbing"))
						print("ABSORB")
						animateAbsorb(child3, child2:GetAttribute("Absorbing"))
					else
						v4[child3] = nil
						child3:Destroy()
					end
				end
			end
		end)
		v6.loopConn = RunService.RenderStepped:Connect(function()
			local now = tick()

			for k, v7 in pairs(v4) do
				if k:GetAttribute("Absorbing") then
					continue
				end

				if k.Parent then
					local v8 = now - v7.startTime
					local v9 = (currentCamera.CFrame.Position - k.Position).Magnitude > 250

					if v8 > 35 then
						v4[k] = nil

						if not v9 then
							local clone = scraps.DisappearImpact:Clone()
							clone.CFrame = CFrame.new(k.Position)
							SetParentWithMagnetColor(clone, _WorldOrigin) -- equivalent call inferred; original call site unknown

							for _, emitter in pairs(clone:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(emitter:GetAttribute("EmitCount"))
								end
							end

							task.delay(1, function()
								clone:Destroy()
							end)
						end

						k:Destroy()
					elseif not v9 then
						local v10 = v7.surfacePos.Y + v7.hoverHeight + math.sin(v8 * v7.bobSpeed * 3.141592653589793 * 2) * 0.15
						local v11 = v7.arrivalCF * CFrame.Angles(v7.rotX * v8, v7.rotY * v8, v7.rotZ * v8)
						k.CFrame = CFrame.new(v7.surfacePos.X, v10, v7.surfacePos.Z) * v11.Rotation
					end
				else
					v4[k] = nil
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
		SetParentWithMagnetColor(clone2, clone) -- equivalent call inferred; original call site unknown

		for _, effect in pairs(clone2:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = true
			elseif effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		local vector = Vector3.new(surfacePos.X, surfacePos.Y + hoverHeight, surfacePos.Z)
		local v6 = r * 0.7 + math.random() * r * 0.2
		local vector2 = Vector3.new(
			(position.X + vector.X) * 0.5,
			math.max(position.Y, vector.Y) + v6,
			(position.Z + vector.Z) * 0.5
		)
		local unit = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
		local v7 = (math.random() * 2 - 1) * 8
		local v8 = math.clamp(1.6 - r * 0.02, 0.5, 1.6)
		local v9 = math.clamp(0.5 - r * 0.01, 0.15, 0.5)
		local lastTime = tick()
		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local v10 = tick() - lastTime
			local v11 = math.clamp(v10 / travelTime, 0, 1)
			local v15 = 1 - v11
			local v16 = v15 * v15 * position + 2 * v15 * v11 * vector2 + v11 * v11 * vector
			clone.CFrame = CFrame.new(v16) * CFrame.fromAxisAngle(unit, v7 * v10)

			if v11 >= 1 then
				renderSteppedConnection:Disconnect()

				for _, trail in pairs(clone2:GetDescendants()) do
					if trail:IsA("Trail") then
						trail.Enabled = true
					end
				end

				v4[clone] = {
					surfacePos = surfacePos,
					hoverHeight = hoverHeight,
					arrivalCF = clone.CFrame,
					bobSpeed = 0.33 + math.random() * 0.22000000000000003,
					rotX = randBetween(v9, v8) * randSign(),
					rotY = randBetween(v9, v8) * randSign(),
					rotZ = randBetween(v9, v8) * randSign(),
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
			SetParentWithMagnetColor(clone, child) -- equivalent call inferred; original call site unknown
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
			SetParentWithMagnetColor(clone, child) -- equivalent call inferred; original call site unknown
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