local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function waitForRelics(p: number)
	local v = os.clock() + p

	while os.clock() < v do
		local relicsXYZ = ReplicatedStorage:FindFirstChild("RelicsXYZ", true)

		if relicsXYZ and relicsXYZ:IsA("ModuleScript") then
			return relicsXYZ
		else
			task.wait(0.5)
		end
	end

	return nil
end

local v = waitForRelics(30)

if not v then
	warn("[EmoteStand] RelicsXYZ module not found in ReplicatedStorage — stands disabled.")
	return
end

local module = require(v)
local emotes = module.Emotes
local ownership = module.Ownership
local Marketplace = require(v.Shared.Marketplace)
local RelicsPlayerClient = require(ReplicatedStorage.UISystems.RelicsPlayerClient)
local v2 = nil
local flag = false

local function prepareDummy(folder)
	local animate = folder:FindFirstChild("Animate")

	if animate then
		animate:Destroy()
	end

	local humanoid = folder:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.EvaluateStateMachine = false

		if not humanoid:FindFirstChildOfClass("Animator") then
			local animator = Instance.new("Animator")
			animator.Parent = humanoid
		end
	end

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end
end

local function getDummyTemplate()
	while flag do
		task.wait(0.1)
	end

	if v2 then
		return v2
	end

	flag = true

	for _, v3 in { not (localPlayer.UserId > 0) and 1 or localPlayer.UserId, 1 } do
		local v4 = v3
		local success, result = pcall(function()
			return Players:CreateHumanoidModelFromUserIdAsync(v4)
		end)

		if not (success and result) then
			continue
		end

		prepareDummy(result)
		result.Archivable = true
		result.Parent = script
		v2 = result
		break
	end

	flag = false
	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createDummy()
	local dummyTemplate = getDummyTemplate()

	if dummyTemplate then
		return dummyTemplate:Clone()
	end

	warn("[EmoteStand] Failed to create dummy (CreateHumanoidModelFromUserIdAsync failed).")
	return nil
end

local function getStandTop(stand)
	local cFrame, size

	if stand:IsA("BasePart") then
		cFrame = stand.CFrame
		size = stand.Size
	elseif stand:IsA("Model") then
		cFrame, size = stand:GetBoundingBox()
	else
		return nil
	end

	local rotation = cFrame.Rotation
	local v3 = (math.abs(rotation.XVector.Y) * size.X + math.abs(rotation.YVector.Y) * size.Y + math.abs(rotation.ZVector.Y) * size.Z) * 0.5
	local lookVector = cFrame.LookVector
	local vector = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector.Magnitude < 0.01 then
		local rightVector = cFrame.RightVector
		vector = Vector3.new(rightVector.Z, 0, -rightVector.X)
	end

	local v4 = not (vector.Magnitude > 0.01) and 0 or math.atan2(-vector.X, -vector.Z)
	local v5 = cFrame.Position + Vector3.new(0, v3, 0)
	return CFrame.new(v5) * CFrame.Angles(0, v4, 0)
end

local function getPromptParent(model)
	if model:IsA("Model") then
		return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model
	end

	return model
end

local v3 = {}

local function getBuyText(p)
	local productId = p.ProductId

	if v3[productId] then
		return v3[productId]
	end

	local productType = p.ProductType or Enum.InfoType.Asset
	local v4, v5 = Marketplace.GetProductInfo(productId, productType):await()
	local v6

	if v4 and v5 and v5.PriceInRobux then
		v6 = `Buy {v5.PriceInRobux} R$`
		v3[productId] = v6
	else
		return "Buy"
	end

	return v6
end

local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}

local function preloadAnimation(animation)
	if v7[animation] then
		return
	end

	if v6[animation] then
		while not v7[animation] do
			task.wait()
		end
	else
		v6[animation] = true
		pcall(function()
			ContentProvider:PreloadAsync({ animation })
		end)
		v7[animation] = true
		v6[animation] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playerOwnsEmote(p)
	return p.Owners[localPlayer.UserId] == true or ownership.PlayerOwnsAsync(localPlayer, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePrompt(state)
	local prompt = state.prompt
	local emote = state.emote

	if not (prompt and emote) then
		return
	end

	prompt.ObjectText = emote.Name
	prompt.ActionText = state.owns and "Open" or "Buy"
	task.spawn(function()
		local owns = playerOwnsEmote(emote) -- equivalent call inferred; original call site unknown

		if state.prompt ~= prompt then
			return
		end

		state.owns = owns

		if owns then
			prompt.ActionText = "Open"
		else
			prompt.ActionText = getBuyText(emote)
		end
	end)
end

local function promptEmotePurchase(emote)
	local productType = emote.ProductType

	if productType == Enum.InfoType.GamePass then
		MarketplaceService:PromptGamePassPurchase(localPlayer, emote.ProductId)
	elseif productType == Enum.InfoType.Product then
		MarketplaceService:PromptProductPurchase(localPlayer, emote.ProductId)
	else
		MarketplaceService:PromptPurchase(localPlayer, emote.ProductId)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onTriggered(p)
	local emote = p.emote

	if emote then
		local owns = playerOwnsEmote(emote) -- equivalent call inferred; original call site unknown
		p.owns = owns

		if owns then
			RelicsPlayerClient.OpenEmoteWheelAndBoombox()
		else
			promptEmotePurchase(emote)
		end
	end
end

local function clearBuild(state)
	state.emote = nil
	state.owns = false
	state.buildId += 1

	for _, buildConnection in state.buildConnections do
		buildConnection:Disconnect()
	end

	table.clear(state.buildConnections)

	if state.dummy then
		state.dummy:Destroy()
		state.dummy = nil
	end

	if state.prompt then
		state.prompt:Destroy()
		state.prompt = nil
	end

	if state.promptAttachment then
		state.promptAttachment:Destroy()
		state.promptAttachment = nil
	end
end

local function buildStand(state, emote)
	if state.destroyed or state.emote then
		return
	end

	state.emote = emote
	state.buildId += 1
	local buildId = state.buildId
	local stand = state.stand
	task.spawn(function()
		local standTop = getStandTop(stand)

		if standTop then
			if state.destroyed or state.buildId ~= buildId then
				return
			end

			local rotationY = tonumber(stand:GetAttribute("RotationY")) or 0
			local scale = tonumber(stand:GetAttribute("Scale")) or 1
			local offsetY = tonumber(stand:GetAttribute("OffsetY")) or 1.25
			local proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt.Name = "EmoteStandPrompt"
			proximityPrompt.MaxActivationDistance = 20
			proximityPrompt.RequiresLineOfSight = false
			local primaryPart = stand

			if primaryPart:IsA("Model") then
				primaryPart = primaryPart.PrimaryPart or primaryPart:FindFirstChildWhichIsA("BasePart") or primaryPart
			end

			local attachment = Instance.new("Attachment")
			attachment.Name = "EmoteStandPromptAttachment"
			attachment.Parent = primaryPart
			attachment.WorldCFrame = standTop * CFrame.new(0, 2.5, 0)
			state.promptAttachment = attachment
			proximityPrompt.Parent = attachment
			state.prompt = proximityPrompt
			table.insert(state.buildConnections, proximityPrompt.Triggered:Connect(function()
				onTriggered(state) -- equivalent call inferred; original call site unknown
			end))
			updatePrompt(state) -- equivalent call inferred; original call site unknown
			local dummy = createDummy() -- equivalent call inferred; original call site unknown

			if not dummy then
				return
			end

			if state.destroyed or state.buildId ~= buildId then
				dummy:Destroy()
				return
			end

			state.dummy = dummy

			if scale ~= 1 then
				dummy:ScaleTo(scale)
			end

			local humanoid = dummy:FindFirstChildOfClass("Humanoid")
			local rootPart = humanoid and humanoid.RootPart

			if humanoid and rootPart then
				local boundingBox, v9 = dummy:GetBoundingBox()
				local v10 = boundingBox.Position.Y - v9.Y / 2
				local v11 = rootPart.Position.Y - v10 + offsetY
				rootPart.Anchored = true
				rootPart.CFrame = standTop * CFrame.Angles(0, math.rad(rotationY), 0) * CFrame.new(0, v11, 0)
			end

			dummy.Name = `EmoteStand_{emote.Name}`
			dummy.Parent = stand

			if emote.SongId and not emote.Animation:GetAttribute("SongIsEncrypted") then
				local sound = Instance.new("Sound")
				sound.Name = "EmoteStandMusic"
				sound.SoundId = `rbxassetid://{emote.SongId}`
				sound.Looped = true
				sound.Volume = tonumber(stand:GetAttribute("MusicVolume")) or 0.35
				sound.RollOffMode = Enum.RollOffMode.InverseTapered
				sound.RollOffMinDistance = 8
				sound.RollOffMaxDistance = 40
				sound.Parent = rootPart or dummy
				sound:Play()
			end

			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

			if animator then
				preloadAnimation(emote.Animation)

				if state.destroyed or state.buildId ~= buildId then
					return
				end

				local success, result = pcall(function()
					return animator:LoadAnimation(emote.Animation)
				end)

				if success and result then
					result.Priority = Enum.AnimationPriority.Action
					result.Looped = true
					result:Play(0, 1, 1)
				else
					warn("[EmoteStand] LoadAnimation failed for", emote.Name)
				end
			end

			local v9 = false

			local function attachEffect(p)
				if v9 or state.destroyed or state.dummy ~= dummy then
					return
				end

				v9 = true
				local success, result = pcall(function()
					local v10 = emotes.SetupEffect(p, emote.SongId)

					if v10 then
						emotes.AttachEffectToCharacter(v10, dummy, nil)
						module.Auras.BindEffect(v10)
						v10.Parent = dummy
					end
				end)

				if not success then
					warn("[EmoteStand] VFX failed for", emote.Name, result)
				end
			end

			local effect = emote.Animation:FindFirstChild("Effect")

			if effect then
				attachEffect(effect)
			else
				table.insert(state.buildConnections, emote.Animation.ChildAdded:Connect(function(child)
					if child.Name == "Effect" then
						attachEffect(child)
					end
				end))
			end
		else
			warn((`[EmoteStand] {stand:GetFullName()} is neither a BasePart nor a Model.`))

			if state.buildId == buildId then
				state.emote = nil
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function registerStandForEmote(p)
	local v8 = v5[p.emoteName]

	if not v8 then
		v8 = {}
		v5[p.emoteName] = v8
	end

	table.insert(v8, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unregisterStandForEmote(p)
	local v8 = v5[p.emoteName]

	if v8 then
		local index = table.find(v8, p)

		if index then
			table.remove(v8, index)
		end

		if #v8 == 0 then
			v5[p.emoteName] = nil
		end
	end
end

local function setupStand(instance)
	if v4[instance] then
		return
	end

	local emote = instance:GetAttribute("Emote")

	if type(emote) ~= "string" or emote == "" then
		warn((`[EmoteStand] {instance:GetFullName()} : missing string attribute "Emote".`))
		return
	end

	local v8 = {
		stand = instance,
		emoteName = emote,
		emote = nil,
		dummy = nil,
		prompt = nil,
		promptAttachment = nil,
		buildConnections = {},
		buildId = 0,
		destroyed = false,
		owns = false
	}
	v4[instance] = v8
	registerStandForEmote(v8) -- equivalent call inferred; original call site unknown
	local v9 = emotes.GetEmotes()[emote]

	if v9 then
		task.spawn(buildStand, v8, v9)
	end

	task.delay(20, function()
		if v8.destroyed or v8.emote then
			return
		end

		local v10 = {}

		for k in emotes.GetEmotes() do
			table.insert(v10, k)
		end

		table.sort(v10)
		warn(
			`[EmoteStand] {instance:GetFullName()} : emote "{emote}" unknown after 20s.`,
			not (#v10 > 0) and "No emotes loaded (backend unavailable?)." or `Available emotes: {table.concat(v10, ", ")}`
		)
	end)
end

local function teardownStand(p)
	local v8 = v4[p]

	if v8 then
		v8.destroyed = true
		v4[p] = nil
		unregisterStandForEmote(v8) -- equivalent call inferred; original call site unknown
		clearBuild(v8)
	end
end

emotes.EmoteAdded:Connect(function(p)
	local v8 = v5[p.Name]

	if v8 then
		for _, v9 in ipairs(v8) do
			if not v9.emote then
				task.spawn(buildStand, v9, p)
			end
		end
	end
end)
emotes.EmoteRemoved:Connect(function(p)
	local v8 = v5[p.Name]

	if v8 then
		for _, v9 in ipairs(v8) do
			if v9.emote == p then
				clearBuild(v9)
			end
		end
	end
end)

for _, v8 in CollectionService:GetTagged("EmoteStand") do
	task.spawn(setupStand, v8)
end

CollectionService:GetInstanceAddedSignal("EmoteStand"):Connect(function(p)
	task.spawn(setupStand, p)
end)
CollectionService:GetInstanceRemovedSignal("EmoteStand"):Connect(teardownStand)

local function onOwnershipChanged(p, p2: number)
	local v8 = p2 == localPlayer.UserId and v5[p.Name]

	if v8 then
		for _, v9 in ipairs(v8) do
			if v9.emote ~= p then
				continue
			end

			local prompt = v9.prompt
			local emote = v9.emote

			if not (prompt and emote) then
				continue
			end

			prompt.ObjectText = emote.Name
			prompt.ActionText = v9.owns and "Open" or "Buy"
			local emote2 = emote
			local v11 = v9
			local prompt2 = prompt
			task.spawn(function()
				local owns = playerOwnsEmote(emote2) -- equivalent call inferred; original call site unknown

				if v11.prompt ~= prompt2 then
					return
				end

				v11.owns = owns

				if owns then
					prompt2.ActionText = "Open"
				else
					prompt2.ActionText = getBuyText(emote2)
				end
			end)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshAllOwnedPrompts()
	for _, v8 in v4 do
		if not v8.emote then
			continue
		end

		local prompt = v8.prompt
		local emote = v8.emote

		if not (prompt and emote) then
			continue
		end

		prompt.ObjectText = emote.Name
		prompt.ActionText = v8.owns and "Open" or "Buy"
		local emote2 = emote
		local v10 = v8
		local prompt2 = prompt
		task.spawn(function()
			local owns = playerOwnsEmote(emote2) -- equivalent call inferred; original call site unknown

			if v10.prompt ~= prompt2 then
				return
			end

			v10.owns = owns

			if owns then
				prompt2.ActionText = "Open"
			else
				prompt2.ActionText = getBuyText(emote2)
			end
		end)
	end
end

emotes.OwnerAdded:Connect(onOwnershipChanged)
emotes.OwnerRemoved:Connect(onOwnershipChanged)
MarketplaceService.PromptPurchaseFinished:Connect(function(p, _, p2)
	if p == localPlayer and p2 then
		refreshAllOwnedPrompts() -- equivalent call inferred; original call site unknown
	end
end)
MarketplaceService.PromptBundlePurchaseFinished:Connect(function(p, _, p2)
	if p == localPlayer and p2 then
		refreshAllOwnedPrompts() -- equivalent call inferred; original call site unknown
	end
end)