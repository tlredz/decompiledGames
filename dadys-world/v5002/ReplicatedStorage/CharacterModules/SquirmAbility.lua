local SquirmAbility = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local CooldownAcceleration = require(ReplicatedStorage.Modules.Gameplay.CooldownAcceleration)
local SoundGroupManager = require(ReplicatedStorage.Modules.Audio.SoundGroupManager)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local Squirm = require(ReplicatedStorage.TowerData.Squirm)
local ServerStorage = game:GetService("ServerStorage")
local editData = ReplicatedStorage:FindFirstChild("editData")
local StatisticsManager = require(ServerStorage.SharedModules.StatisticsManager)
local IchorTransactions = require(ServerStorage.SharedModules.IchorTransactions)
local holdDuration = Squirm.HoldDuration or 4
local abilityDuration = Squirm.AbilityDuration or 10
local holdMovementSlowMultiplier = Squirm.HoldMovementSlowMultiplier or 0.5
local abilityCooldown = Squirm.AbilityCooldown or 80
local bookshelfProximityRange = Squirm.BookshelfProximityRange or 15
local bookshelfCooldownMultiplier = Squirm.BookshelfCooldownMultiplier or 2
local v = {}

local function playAbilityAnim(instance, animationId, p)
	if not instance then
		return nil
	end

	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoid then
		return nil
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not animator then
		return nil
	end

	if not v[instance] then
		v[instance] = {}
	end

	local track = v[instance][animationId]

	if not track then
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		track = animator:LoadAnimation(animation)
		v[instance][animationId] = track
		animation:Destroy()
	end

	track.Looped = p or false
	track.Priority = Enum.AnimationPriority.Action4
	track:Play(0)
	return track
end

local function stopAbilityAnim(p, p2)
	if not (p and v[p]) then
		return
	end

	local v2 = v[p][p2]

	if v2 then
		v2:Stop()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupAbilityAnims(p)
	if v[p] then
		for _, v2 in pairs(v[p]) do
			v2:Stop()
		end

		v[p] = nil
	end
end

local v2 = {
	"rbxassetid://82761841004688",
	"rbxassetid://132527910432050",
	"rbxassetid://127607908952032",
	"rbxassetid://115164005258143"
}
local v3 = {
	"rbxassetid://81167400489850",
	"rbxassetid://100403250970115",
	"rbxassetid://138661951185444",
	"rbxassetid://140212018684433",
	"rbxassetid://73333603415063",
	"rbxassetid://93975368488032"
}
local flag = false

local function preloadBookTextures()
	if flag then
		return
	end

	task.spawn(function()
		local ContentProvider = game:GetService("ContentProvider")
		local success, result = pcall(function()
			local v4 = {}

			for _, texture in ipairs(v2) do
				local decal = Instance.new("Decal")
				decal.Texture = texture
				table.insert(v4, decal)
			end

			for _, texture in ipairs(v3) do
				local decal = Instance.new("Decal")
				decal.Texture = texture
				table.insert(v4, decal)
			end

			ContentProvider:PreloadAsync(v4)

			for _, v5 in ipairs(v4) do
				v5:Destroy()
			end
		end)

		if success then
			flag = true
		else
			warn("[SquirmAbility] Failed to preload book textures:", result)
		end
	end)
end

if not flag then
	task.spawn(function()
		local ContentProvider = game:GetService("ContentProvider")
		local success, result = pcall(function()
			local v4 = {}

			for _, texture in ipairs(v2) do
				local decal = Instance.new("Decal")
				decal.Texture = texture
				table.insert(v4, decal)
			end

			for _, texture in ipairs(v3) do
				local decal = Instance.new("Decal")
				decal.Texture = texture
				table.insert(v4, decal)
			end

			ContentProvider:PreloadAsync(v4)

			for _, v5 in ipairs(v4) do
				v5:Destroy()
			end
		end)

		if success then
			flag = true
		else
			warn("[SquirmAbility] Failed to preload book textures:", result)
		end
	end)
end

local function playChewSound(part)
	local parent = nil

	if part:IsA("BasePart") then
		parent = part
	else
		for _, part2 in ipairs(part:GetDescendants()) do
			if not part2:IsA("BasePart") then
				continue
			end

			parent = part2
			break
		end
	end

	if not parent then
		return
	end

	local v5 = Audio:Play("Sounds.Toon.Squirm.Chew", {
		Parent = parent,
		Volume = 0.15,
		RollOffMaxDistance = 40,
		RollOffMode = Enum.RollOffMode.LinearSquare
	})

	if v5 then
		SoundGroupManager.AssignSFXSound(v5)
	end
end

local v4 = {}
local v5 = {}
local v6 = {}

local function setBookshelfChewedTexture(folder)
	local texture = v2[math.random(1, #v2)]
	local result = {}
	local v8 = {}

	for _, decal in ipairs(folder:GetDescendants()) do
		if not decal:IsA("Decal") or decal:GetAttribute("SquirmChewed") then
			continue
		end

		table.insert(result, {
			instance = decal,
			original = decal.Texture
		})
		decal.Texture = texture
		decal:SetAttribute("SquirmChewed", true)

		if decal.Parent and decal.Parent:IsA("BasePart") then
			v8[decal.Parent] = true
		end
	end

	task.defer(function()
		local parts = ReplicatedStorage:FindFirstChild("Parts")
		local bookParticles = parts and parts:FindFirstChild("BookParticles")

		if not bookParticles then
			return
		end

		for k in pairs(v8) do
			if not (k and k.Parent) then
				continue
			end

			local attachment = Instance.new("Attachment")
			attachment.Name = "ChewDustAttachment"
			attachment.Parent = k

			for _, emitter in ipairs(bookParticles:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local clone = emitter:Clone()
				clone.Rate = 0
				clone.Enabled = false
				clone.Parent = attachment
				clone:Emit(8)
			end

			task.delay(4, function()
				if attachment and attachment.Parent then
					attachment:Destroy()
				end
			end)
		end
	end)
	return result
end

local function emitChewDust(part)
	if not (part and part:IsA("BasePart")) then
		return
	end

	local parts = ReplicatedStorage:FindFirstChild("Parts")
	local bookParticles = parts and parts:FindFirstChild("BookParticles")

	if not bookParticles then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "ChewDustAttachment"
	attachment.Parent = part

	for _, emitter in ipairs(bookParticles:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local clone = emitter:Clone()
		clone.Rate = 0
		clone.Enabled = false
		clone.Parent = attachment
		clone:Emit(8)
	end

	task.delay(4, function()
		if attachment and attachment.Parent then
			attachment:Destroy()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fireDustEvent(p)
	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		return
	end

	local v7 = events:FindFirstChild("SquirmChewDust")

	if not v7 then
		v7 = Instance.new("RemoteEvent")
		v7.Name = "SquirmChewDust"
		v7.Parent = events
	end

	v7:FireAllClients(p)
end

local function chewNextSection(folder)
	local decals = {}

	for _, decal in ipairs(folder:GetDescendants()) do
		if not decal:IsA("Decal") or decal:GetAttribute("SquirmChewed") then
			continue
		end

		table.insert(decals, decal)
	end

	if #decals == 0 then
		return false
	end

	local part = decals[math.random(1, #decals)]
	local texture = v2[math.random(1, #v2)]
	local part2 = part:IsA("MeshPart") and part or part.Parent
	part:SetAttribute("SquirmChewed", true)
	local clone = part:Clone()
	clone.Name = "ChewedOverlay"
	clone.Texture = texture
	clone.Transparency = 1
	clone.Parent = part2
	local tween = TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0
	})
	tween.Completed:Connect(function()
		part.Texture = texture
		part.Transparency = 0

		if clone and clone.Parent then
			clone:Destroy()
		end

		if part2 and part2:IsA("BasePart") then
			fireDustEvent(part2) -- equivalent call inferred; original call site unknown
		end
	end)
	tween:Play()
	return true
end

local function swapCharacterBookTexture(instance)
	if not instance then
		return
	end

	local children = {}

	for _, child in ipairs(instance:GetChildren()) do
		if child.Name:match("^Book_0[1-4]$") then
			table.insert(children, child)
		end
	end

	if #children == 0 then
		warn("[SquirmAbility] No Book_01-04 models found on character")
		return
	end

	local v7 = v3[math.random(1, #v3)]

	for _, part in ipairs(children) do
		if part:IsA("MeshPart") then
			part.TextureID = v7
		end

		for _, descendant in ipairs(part:GetDescendants()) do
			if descendant:IsA("MeshPart") then
				descendant.TextureID = v7
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				descendant.Texture = v7
			end
		end
	end
end

local function getUnchewedCount(folder)
	local count = 0

	for _, decal in ipairs(folder:GetDescendants()) do
		if not decal:IsA("Decal") or decal:GetAttribute("SquirmChewed") then
			continue
		end

		count += 1
	end

	return count
end

local function restoreBookshelfTextures(list)
	if not list then
		return
	end

	for _, v7 in ipairs(list) do
		if v7.instance and v7.instance.Parent then
			v7.instance.Texture = v7.original
		end
	end
end

local function getNibbleEvent()
	local events = ReplicatedStorage:FindFirstChild("Events")

	if not events then
		return nil
	end

	local v7 = events:FindFirstChild("SquirmBookshelfNibble")

	if not v7 then
		v7 = Instance.new("RemoteEvent")
		v7.Name = "SquirmBookshelfNibble"
		v7.Parent = events
	end

	return v7
end

local function hasBookTextures(folder)
	for _, decal in ipairs(folder:GetDescendants()) do
		if decal:IsA("Decal") then
			return true
		end
	end

	return false
end

local function findNearbyBookshelf(instance, p)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local position = humanoidRootPart.Position
	local lookVector = humanoidRootPart.CFrame.LookVector
	local tagged = CollectionService:GetTagged("BookShelfModel")
	local v7 = p or bookshelfProximityRange
	local v8 = nil

	for _, part in ipairs(tagged) do
		if not (part:IsDescendantOf(workspace) and hasBookTextures(part)) then
			continue
		end

		local magnitude = 1e999
		local position2

		if part:IsA("BasePart") then
			magnitude = (position - part.Position).Magnitude
			position2 = part.Position
		else
			position2 = position

			for _, part2 in ipairs(part:GetDescendants()) do
				if not part2:IsA("BasePart") then
					continue
				end

				local magnitude2 = (position - part2.Position).Magnitude

				if not (magnitude2 < magnitude) then
					continue
				end

				position2 = part2.Position
				magnitude = magnitude2
			end
		end

		if not (magnitude <= v7) then
			continue
		end

		local unit = (position2 - position).Unit

		if not (lookVector:Dot(Vector3.new(unit.X, 0, unit.Z).Unit) >= 0.3) then
			continue
		end

		v8 = part
		v7 = magnitude
	end

	return v8, v7
end

function SquirmAbility.Initialize(instance)
	if not Players:GetPlayerFromCharacter(instance) then
		return
	end

	swapCharacterBookTexture(instance)
	SquirmAbility.StartCooldownTracker(instance)
	instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			SquirmAbility.Cleanup(instance)
		end
	end)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.Died:Once(function()
			SquirmAbility.Cleanup(instance)
		end)
	end
end

function SquirmAbility.StartCooldownTracker(instance)
	if v5[instance] then
		return
	end

	local abilities = instance:FindFirstChild("Abilities")

	if not abilities then
		return
	end

	local ability1 = abilities:FindFirstChild("Ability1")

	if not ability1 then
		return
	end

	local currentCooldown = ability1:FindFirstChild("CurrentCooldown")

	if not currentCooldown then
		return
	end

	v6[instance] = {
		isNear = false,
		currentBookshelf = nil,
		lastChewTime = 0
	}
	local AchievementGiver = require(ServerStorage.SharedModules.AchievementGiver)
	v5[instance] = RunService.Heartbeat:Connect(function()
		-- [DEDUP] synthesized from 2 duplicated terminal regions
		local function deduplicatedTail()
			if v6[instance] and v6[instance].isNear then
				CooldownAcceleration.Remove(instance, "SquirmBookshelf")
				local events = ReplicatedStorage:FindFirstChild("Events")
				local v7

				if events then
					v7 = events:FindFirstChild("SquirmBookshelfNibble")

					if not v7 then
						v7 = Instance.new("RemoteEvent")
						v7.Name = "SquirmBookshelfNibble"
						v7.Parent = events
					end
				end

				if v7 then
					v7:FireAllClients(instance, nil, "stop")
				end

				v6[instance].isNear = false
				v6[instance].currentBookshelf = nil
				instance:SetAttribute("NearBookshelf", false)
				instance:SetAttribute("DisableQuirks", nil)
			end
		end

		if not (instance and instance.Parent) then
			SquirmAbility.StopCooldownTracker(instance)
		elseif currentCooldown.Value <= 0 then
			return deduplicatedTail()
		else
			local decoding = instance:FindFirstChild("Decoding")

			if decoding and decoding.Value ~= nil then
				return deduplicatedTail()
			else
				local nearbyBookshelf = findNearbyBookshelf(instance)
				local isNear = v6[instance] and v6[instance].isNear

				if nearbyBookshelf then
					v6[instance].isNear = true
					v6[instance].currentBookshelf = nearbyBookshelf
					instance:SetAttribute("NearBookshelf", true)
					instance:SetAttribute("DisableQuirks", true)
					CooldownAcceleration.Apply(instance, "SquirmBookshelf", bookshelfCooldownMultiplier)

					if not isNear then
						local events = ReplicatedStorage:FindFirstChild("Events")
						local v7

						if events then
							v7 = events:FindFirstChild("SquirmBookshelfNibble")

							if not v7 then
								v7 = Instance.new("RemoteEvent")
								v7.Name = "SquirmBookshelfNibble"
								v7.Parent = events
							end
						end

						if v7 then
							v7:FireAllClients(instance, nearbyBookshelf, "start")
						end

						v6[instance].lastChewTime = tick()
						local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

						if playerFromCharacter then
							local v8 = "SquirmMasteryEaten_" .. playerFromCharacter.UserId

							if not nearbyBookshelf:GetAttribute(v8) then
								nearbyBookshelf:SetAttribute(v8, true)

								if editData then
									task.spawn(function()
										editData:Invoke(playerFromCharacter, function(p)
											for _, v9 in pairs(p.Data.Mastery) do
												if v9.Name ~= "Squirm" then
													continue
												end

												for _, v10 in pairs(v9.RequirementList) do
													if v10.Name == "EatBookshelfOnCooldown" then
														v10.Current = math.min(v10.Current + 1, v10.Amount)
													end
												end

												break
											end
										end)
									end)
								end

								StatisticsManager:IncrementKey(playerFromCharacter, "BookshelvesEatenOnCooldown", 1)
								local count = 0

								for _, v9 in ipairs(CollectionService:GetTagged("BookShelfModel")) do
									if v9:IsDescendantOf(workspace) and v9:GetAttribute(v8) then
										count += 1
									end
								end

								if count >= 10 then
									AchievementGiver:CompleteAchievementOneOff(playerFromCharacter, "ID_31_FineDining")
								end
							end
						end
					end

					local lastChewTime = v6[instance].lastChewTime or 0
					local now = tick()

					if now - lastChewTime >= 1.5 then
						v6[instance].lastChewTime = now
						chewNextSection(nearbyBookshelf)
						local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

						if humanoidRootPart then
							playChewSound(humanoidRootPart)
						end
					end
				else
					if isNear then
						CooldownAcceleration.Remove(instance, "SquirmBookshelf")
						local events = ReplicatedStorage:FindFirstChild("Events")
						local v7

						if events then
							v7 = events:FindFirstChild("SquirmBookshelfNibble")

							if not v7 then
								v7 = Instance.new("RemoteEvent")
								v7.Name = "SquirmBookshelfNibble"
								v7.Parent = events
							end
						end

						if v7 then
							v7:FireAllClients(instance, nil, "stop")
						end
					end

					v6[instance].isNear = false
					v6[instance].currentBookshelf = nil
					instance:SetAttribute("NearBookshelf", false)
					instance:SetAttribute("DisableQuirks", nil)
				end
			end
		end
	end)
end

function SquirmAbility.StopCooldownTracker(instance)
	if v5[instance] then
		v5[instance]:Disconnect()
		v5[instance] = nil
	end

	if v6[instance] then
		local events = ReplicatedStorage:FindFirstChild("Events")
		local v7

		if events then
			v7 = events:FindFirstChild("SquirmBookshelfNibble")

			if not v7 then
				v7 = Instance.new("RemoteEvent")
				v7.Name = "SquirmBookshelfNibble"
				v7.Parent = events
			end
		end

		if v7 and v6[instance].isNear then
			v7:FireAllClients(instance, nil, "stop")
		end
	end

	v6[instance] = nil
	CooldownAcceleration.Remove(instance, "SquirmBookshelf")

	if instance and instance.Parent then
		instance:SetAttribute("NearBookshelf", nil)
	end
end

function SquirmAbility.StartChannel(instance, p)
	local abilities = instance:FindFirstChild("Abilities")

	if not abilities then
		return false, "No abilities"
	end

	local ability1 = abilities:FindFirstChild("Ability1")

	if not ability1 then
		return false, "No ability"
	end

	local currentCooldown = ability1:FindFirstChild("CurrentCooldown")

	if currentCooldown and currentCooldown.Value > 0 then
		return false, "That Ability is on Cooldown!"
	end

	if v4[instance] then
		return false, "Already channeling!"
	end

	local speedModIds = StatModifierManager.ApplySpeedModifiers(instance, holdMovementSlowMultiplier, "SquirmHold", {
		category = "ability",
		antiCheat = true
	})
	local tagged = CollectionService:GetTagged("BookShelfModel")
	local count = 0

	for _, v8 in ipairs(tagged) do
		if v8:IsDescendantOf(workspace) then
			count += 1
		end
	end

	local nearbyBookshelf, _ = findNearbyBookshelf(instance)

	if nearbyBookshelf then
		instance:SetAttribute("EatingBookshelf", true)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local squirmEatPoint = nearbyBookshelf:FindFirstChild("SquirmEatPoint", true)

			if squirmEatPoint and squirmEatPoint:IsA("Attachment") then
				local worldCFrame = squirmEatPoint.WorldCFrame
				local vector = Vector3.new(worldCFrame.Position.X, humanoidRootPart.Position.Y, worldCFrame.Position.Z)
				local _, v8, _ = worldCFrame:ToOrientation()
				local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

				if playerFromCharacter then
					playerFromCharacter:SetAttribute("KM_TELEPORT_TEMPORARY_EXCEPTION", true)
				end

				humanoidRootPart.CFrame = CFrame.new(vector) * CFrame.Angles(0, v8, 0)
			end
		end

		local events = ReplicatedStorage:FindFirstChild("Events")
		local v8

		if events then
			v8 = events:FindFirstChild("SquirmBookshelfNibble")

			if not v8 then
				v8 = Instance.new("RemoteEvent")
				v8.Name = "SquirmBookshelfNibble"
				v8.Parent = events
			end
		end

		if v8 then
			v8:FireAllClients(instance, nearbyBookshelf, "start")
		end

		if humanoidRootPart then
			playChewSound(humanoidRootPart)
		end
	end

	v4[instance] = {
		startTime = workspace.DistributedGameTime,
		speedModIds = speedModIds,
		heartbeatConn = nil,
		animLoopConn = nil,
		targetBookshelf = nearbyBookshelf
	}
	instance:SetAttribute("HoldAbilityActive", true)
	instance:SetAttribute("HoldAbilityStart", workspace.DistributedGameTime)
	instance:SetAttribute("HoldAbilityDuration", holdDuration)
	local v8 = playAbilityAnim(instance, "rbxassetid://126404363103447", true)
	swapCharacterBookTexture(instance)

	if v8 then
		v4[instance].animLoopConn = v8:GetMarkerReachedSignal("BookFinished"):Connect(function()
			swapCharacterBookTexture(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				playChewSound(humanoidRootPart)
			end

			instance:SetAttribute("SquirmBookEaten", tick())
		end)
	end

	v4[instance].heartbeatConn = RunService.Heartbeat:Connect(function()
		local v9 = v4[instance]

		if not v9 then
			return
		end

		local decoding = instance:FindFirstChild("Decoding")

		if decoding and decoding.Value ~= nil then
			SquirmAbility.CancelChannel(instance, "Started extracting")
		elseif holdDuration <= workspace.DistributedGameTime - v9.startTime then
			SquirmAbility.CompleteChannel(instance, p)
		end
	end)
	return true, nil
end

function SquirmAbility.CompleteChannel(instance, p)
	local v7 = v4[instance]

	if not v7 then
		return false
	end

	if v7.heartbeatConn then
		v7.heartbeatConn:Disconnect()
	end

	if v7.animLoopConn then
		v7.animLoopConn:Disconnect()
	end

	if v7.speedModIds then
		StatModifierManager.RemoveSpeedModifiers(instance, v7.speedModIds)
	end

	local targetBookshelf = v7.targetBookshelf or findNearbyBookshelf(instance)

	if targetBookshelf then
		local events = ReplicatedStorage:FindFirstChild("Events")
		local v8

		if events then
			v8 = events:FindFirstChild("SquirmBookshelfNibble")

			if not v8 then
				v8 = Instance.new("RemoteEvent")
				v8.Name = "SquirmBookshelfNibble"
				v8.Parent = events
			end
		end

		if v8 then
			v8:FireAllClients(instance, nil, "stop")
		end

		instance:SetAttribute("EatingBookshelf", nil)
		setBookshelfChewedTexture(targetBookshelf)
	end

	v4[instance] = nil
	instance:SetAttribute("HoldAbilityActive", false)
	instance:SetAttribute("HoldAbilityStart", nil)
	instance:SetAttribute("HoldAbilityDuration", nil)
	local v8 = StatModifierManager.ApplyModifier(instance, "DecodeSpeedModifier", 2, "SquirmAbility", {
		category = "ability"
	})
	instance:SetAttribute("SquirmBuffActive", true)

	if editData and p then
		local v9 = "SquirmAbilityUsed_Floor" .. workspace.Info.Floor.Value
		local attribute = instance:GetAttribute(v9)
		task.spawn(function()
			editData:Invoke(p, function(p2)
				if not p2 then
					return
				end

				if not attribute and workspace.Info.FloorActive.Value then
					instance:SetAttribute(v9, true)
					local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)
					local survivalPoints = child and child:FindFirstChild("SurvivalPoints")
					local trinkets = instance:FindFirstChild("Trinkets")
					local hasIchorTrinket

					if trinkets then
						local trinket1 = trinkets:FindFirstChild("Trinket1")
						local trinket2 = trinkets:FindFirstChild("Trinket2")
						hasIchorTrinket = trinket1 and trinket1.Value == "UnreleasedIchorItem" and true or trinket2 and trinket2.Value == "UnreleasedIchorItem"
					else
						hasIchorTrinket = false
					end

					local v11 = hasIchorTrinket and 6 or 5

					if survivalPoints then
						survivalPoints.Value += 3
					end

					IchorTransactions:GiveIchor(p, p2, v11, true)
					local AnalyticsService = require(ReplicatedStorage.Modules.Services.AnalyticsService)
					AnalyticsService:TrackCoinEarned(p, v11, "AbilityUse", {
						HasIchorTrinket = hasIchorTrinket,
						Ability = "Squirm"
					})
				end

				for _, v10 in pairs(p2.Data.Mastery) do
					if v10.Name ~= "Squirm" then
						continue
					end

					for _, v11 in pairs(v10.RequirementList) do
						if v11.Name == "ActiveAbilityActivate" then
							v11.Current = math.min(v11.Current + 1, v11.Amount)
						end
					end

					break
				end
			end)
		end)
	end

	local storyEvents = ReplicatedStorage:FindFirstChild("StoryEvents")
	local dialogueEvent = storyEvents and storyEvents:FindFirstChild("DialogueEvent")

	if dialogueEvent then
		local dialogueModules = ReplicatedStorage:FindFirstChild("DialogueModules")
		local squirm = dialogueModules and dialogueModules:FindFirstChild("Squirm")

		if squirm then
			local success, result = pcall(require, squirm)

			if success and result.UseAbility then
				dialogueEvent:Fire(instance, "Squirm", result.UseAbility[math.random(1, #result.UseAbility)], 2.5)
			end
		end
	end

	task.delay(abilityDuration, function()
		if instance and instance.Parent then
			if v8 then
				StatModifierManager.RemoveModifier(instance, "DecodeSpeedModifier", v8)
			end

			instance:SetAttribute("SquirmBuffActive", nil)
		end
	end)
	local abilities = instance:FindFirstChild("Abilities")
	local ability1 = abilities and abilities:FindFirstChild("Ability1")
	local currentCooldown = ability1 and ability1:FindFirstChild("CurrentCooldown")
	local cooldown = ability1 and ability1:FindFirstChild("Cooldown")

	if currentCooldown then
		currentCooldown.Value = cooldown and cooldown.Value or abilityCooldown
		task.spawn(function()
			while instance and instance.Parent and currentCooldown.Value > 0 do
				currentCooldown.Value = math.max(0, currentCooldown.Value - 0.1)
				task.wait(0.1)
			end
		end)
	end

	local rbxassetid126404363103447 = instance and v[instance] and v[instance]["rbxassetid://126404363103447"]

	if rbxassetid126404363103447 then
		rbxassetid126404363103447:Stop()
	end

	return true
end

function SquirmAbility.CancelChannel(instance, holdAbilityCancelReason)
	local v7 = v4[instance]

	if not v7 then
		return
	end

	if v7.heartbeatConn then
		v7.heartbeatConn:Disconnect()
	end

	if v7.animLoopConn then
		v7.animLoopConn:Disconnect()
	end

	if v7.speedModIds then
		StatModifierManager.RemoveSpeedModifiers(instance, v7.speedModIds)
	end

	if v7.targetBookshelf then
		local events = ReplicatedStorage:FindFirstChild("Events")
		local v8

		if events then
			v8 = events:FindFirstChild("SquirmBookshelfNibble")

			if not v8 then
				v8 = Instance.new("RemoteEvent")
				v8.Name = "SquirmBookshelfNibble"
				v8.Parent = events
			end
		end

		if v8 then
			v8:FireAllClients(instance, nil, "stop")
		end

		instance:SetAttribute("EatingBookshelf", nil)
	end

	v4[instance] = nil
	instance:SetAttribute("HoldAbilityActive", false)
	instance:SetAttribute("HoldAbilityCancelled", true)

	if holdAbilityCancelReason then
		instance:SetAttribute("HoldAbilityCancelReason", holdAbilityCancelReason)
	end

	task.delay(0.1, function()
		if instance and instance.Parent then
			instance:SetAttribute("HoldAbilityCancelled", nil)
			instance:SetAttribute("HoldAbilityCancelReason", nil)
		end
	end)

	if instance then
		if not v[instance] then
			return
		end

		local rbxassetid126404363103447 = v[instance]["rbxassetid://126404363103447"]

		if rbxassetid126404363103447 then
			rbxassetid126404363103447:Stop()
		end
	end
end

function SquirmAbility.IsChanneling(p)
	return v4[p] ~= nil
end

function SquirmAbility.HandleClientCancel(p, _)
	if v4[p] then
		SquirmAbility.CancelChannel(p, "Released early")
	end
end

function SquirmAbility.Cleanup(p)
	if v4[p] then
		SquirmAbility.CancelChannel(p)
	end

	SquirmAbility.StopCooldownTracker(p)
	cleanupAbilityAnims(p) -- equivalent call inferred; original call site unknown
end

return SquirmAbility