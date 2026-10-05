local createVector = vector.create
local Players = game:GetService("Players")
local parent = script.Parent
local Tags = require(parent.Tags)
local Auras = require(parent.Auras)
local Guard = require(parent.Guard)
local Mutex = require(parent.Mutex)
local Trove = require(parent.Trove)
local Emotes = require(parent.Emotes)
local Signal = require(parent.Signal)
local Backend = require(parent.Backend)
local Network = require(parent.Network)
local Promise = require(parent.Promise)
local Recents = require(parent.Recents)
local Settings = require(parent.Settings)
local Migration = require(parent.Migration)
local MusicData = require(parent.MusicData)
local Ownership = require(parent.Ownership)
local PlayerData = require(parent.PlayerData)
local RunContext = require(parent.RunContext)
local GamePasses = require(parent.GamePasses)
local Marketplace = require(parent.Marketplace)
local ServerAudio = require(parent.ServerAudio)
local v = {}
local v2 = {}
local event = Network.Event("RELICSxyz_EquipUGCSkin", Guard.Optional(Guard.String))
local v3 = {}
local v4 = {}
local v5 = {}
local skinAdded = Signal.new()
local skinRemoved = Signal.new()
local boomboxConfigAdded = Signal.new()
local boomboxConfigRemoved = Signal.new()
local patchFeed = ServerAudio.PatchFeed
local sendAudioPatch = ServerAudio.SendAudioPatch
local fn = nil

local function setBoomboxVisibilityHandler(callback)
	assert(
		RunContext.IsServer or RunContext.IsEdit,
		"Boombox.SetBoomboxVisibilityHandler should only be called on the server."
	)
	fn = callback
end

local function getSkins()
	return table.clone(v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createWire(sourceInstance, p)
	local wire = Instance.new("Wire")
	wire.SourceInstance = sourceInstance
	wire.TargetInstance = p
	wire.Parent = p
	return wire
end

local function getBoomboxConfigs(_)
	local result = {}

	for _, v10 in v4 do
		table.insert(result, v10)
	end

	table.sort(result, function(a, b)
		return a.Priority > b.Priority
	end)
	return result
end

Tags.BindWithMaid("RelicsBoombox", function(instance, maid)
	local gamePass = tonumber(instance:GetAttribute("GamePass"))
	local priority = tonumber(instance:GetAttribute("Priority")) or 0
	local accessoryId = instance:GetAttribute("AccessoryId") or instance:GetAttribute("AssetId") or instance:GetAttribute("ProductId")
	local giftProductId = tonumber(instance:GetAttribute("GiftProductId"))
	local accessoryType = instance:GetAttribute("AccessoryType")
	local productType = instance:GetAttribute("ProductType")
	local legacyIds = instance:GetAttribute("LegacyIds") or instance:GetAttribute("LegacyId")

	if typeof(accessoryType) ~= "EnumItem" or not accessoryType:IsA("AccessoryType") then
		if type(accessoryType) == "string" then
			accessoryType = Enum.AccessoryType:FromName(accessoryType) or Enum.AccessoryType.Back
		else
			accessoryType = Enum.AccessoryType.Back
		end
	end

	if typeof(productType) ~= "EnumItem" or not productType:IsA("InfoType") then
		if type(productType) == "string" then
			productType = Enum.InfoType:FromName(productType) or Enum.InfoType.Asset
		else
			productType = Enum.InfoType.Asset
		end
	end

	local legacyIds2 = not legacyIds and {} or Migration.ParseLegacyIds(legacyIds)

	if gamePass then
		table.insert(legacyIds2, {
			Id = gamePass,
			InfoType = Enum.InfoType.GamePass
		})
	end

	if type(accessoryId) == "number" then
		local changed = Signal.new()
		local renderOffset = instance:GetAttribute("RenderOffset")
		local renderAmbient = instance:GetAttribute("RenderAmbient")
		local renderZoomScale = tonumber(instance:GetAttribute("RenderZoomScale")) or 1
		local attributesByAttributeName = {
			ProductId = accessoryId,
			ProductType = productType,
			LegacyIds = legacyIds2,
			GiftProductId = giftProductId,
			AccessoryType = accessoryType,
			Priority = priority,
			Source = instance,
			RenderOffset = 0,
			RenderAmbient = 0,
			RenderZoomScale = 0,
			Changed = 0,
			AssetId = 0,
			GamePassId = 0
		}

		if typeof(renderOffset) ~= "CFrame" then
			renderOffset = CFrame.identity
		end

		attributesByAttributeName.RenderOffset = renderOffset

		if typeof(renderAmbient) ~= "Color3" then
			renderAmbient = Color3.new(1, 1, 1)
		end

		attributesByAttributeName.RenderAmbient = renderAmbient
		attributesByAttributeName.RenderZoomScale = renderZoomScale
		attributesByAttributeName.Changed = changed
		attributesByAttributeName.AssetId = accessoryId
		attributesByAttributeName.GamePassId = gamePass
		maid:Connect(instance.AttributeChanged, function(attributeName: string)
			local attribute = instance:GetAttribute(attributeName)
			local v12 = attributesByAttributeName[attributeName]

			if typeof(v12) == typeof(attribute) then
				if typeof(v12) == "EnumItem" and typeof(attribute) == "EnumItem" and v12.EnumType ~= attribute.EnumType then
					attribute = v12
				end

				attributesByAttributeName[attributeName] = attribute
				changed:Fire(attributeName)
			end
		end)
		v4[instance] = attributesByAttributeName
		boomboxConfigAdded:Fire(attributesByAttributeName)
		maid:Add(function()
			v4[instance] = nil
			boomboxConfigRemoved:Fire(attributesByAttributeName)
			changed:DisconnectAll()
		end)
	end
end)

local function getRolloffCurve()
	local firstTagged = Tags.FindFirstTagged("RelicsAudioCurve")
	local minDistance = 12
	local maxDistance = 45
	local curveStep = 4

	if firstTagged then
		minDistance = tonumber(firstTagged:GetAttribute("MinDistance")) or minDistance
		maxDistance = tonumber(firstTagged:GetAttribute("MaxDistance")) or maxDistance
		curveStep = tonumber(firstTagged:GetAttribute("CurveStep")) or curveStep
	end

	local result = {}

	for i = minDistance, maxDistance, math.max(math.abs(maxDistance - minDistance) / 20, curveStep) do
		result[i] = math.pow(i - minDistance - (maxDistance - minDistance), 2) / math.pow(maxDistance - minDistance, 2)
	end

	result[maxDistance] = 0
	return result
end

local function isFreemium(instance)
	local playlists = MusicData.GetPlaylists()

	for _, playlist in playlists do
		if playlist.IsFree and playlist.IsActive then
			return true
		end
	end

	local rELICSxyz_MockFreemium = instance and instance:GetAttribute("RELICSxyz_MockFreemium")
	return type(rELICSxyz_MockFreemium) == "boolean" and rELICSxyz_MockFreemium
end

local function promiseAccessory(assetId: number, accessoryType)
	local accessoryType2 = accessoryType or Enum.AccessoryType.Back
	local formatted = `{accessoryType2.Name}:{assetId}`

	if v5[formatted] then
		return v5[formatted]
	end

	v5[formatted] = Promise.new(function(callback, callback2)
		local humanoidDescription = Instance.new("HumanoidDescription")
		local accessoryDescription = Instance.new("AccessoryDescription")
		accessoryDescription.AccessoryType = accessoryType2
		accessoryDescription.AssetId = assetId
		accessoryDescription.IsLayered = false
		accessoryDescription.Parent = humanoidDescription
		local accessory = Players:CreateHumanoidModelFromDescriptionAsync(humanoidDescription, Enum.HumanoidRigType.R15):FindFirstChildOfClass("Accessory")

		if not accessory then
			callback2("Invalid accessory.")
			return
		end

		local handle = accessory:FindFirstChild("Handle")

		if handle and handle:IsA("BasePart") then
			handle.AudioCanCollide = false
		end

		callback(accessory)
	end):catch(function(_)
		v5[formatted] = nil
	end)
	return v5[formatted]
end

local function promiseBoombox(data)
	local productId = data.ProductId or data.AssetId
	local accessoryType = data.AccessoryType

	if not v[productId] then
		v[productId] = Promise.retryWithDelay(promiseAccessory, 5, 2, productId, accessoryType)
	end

	return v[productId]
end

local function addSongToHistory(p: number, id: string)
	local v10 = PlayerData.Get(p)

	if not v10.IsLoaded or (id == "" or MusicData.IsSongOfEmote(id)) then
		return
	end

	v10:Patch(function(p3)
		local recents = p3.Recents
		local v11 = nil

		for k, recent in recents do
			if not (recent.Type == "SONG" and recent.Id == id) then
				continue
			end

			v11 = k
			break
		end

		if v11 then
			table.remove(recents, v11)
		end

		table.insert(recents, 1, {
			Type = "SONG",
			Id = id
		})

		while #recents > 10 do
			table.remove(recents)
		end

		p3.Recents = recents
	end)
end

local function getVector3Value(parent2, name: string, vector2: Vector3)
	local vector3Value = parent2:FindFirstChild(name)

	if vector3Value and vector3Value:IsA("Vector3Value") then
		return vector3Value
	end

	local vector3Value2 = Instance.new("Vector3Value")
	vector3Value2.Name = name
	vector3Value2.Value = vector2
	vector3Value2.Parent = parent2
	return vector3Value2
end

local function getOriginalSize(parent2)
	local size = parent2.Size
	local originalSize = parent2:FindFirstChild("OriginalSize")

	if originalSize and originalSize:IsA("Vector3Value") then
		return originalSize
	end

	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Name = "OriginalSize"
	vector3Value.Value = size
	vector3Value.Parent = parent2
	return vector3Value
end

local function getOriginalPosition(parent2)
	local position = parent2.Position
	local originalPosition = parent2:FindFirstChild("OriginalPosition")

	if originalPosition and originalPosition:IsA("Vector3Value") then
		return originalPosition
	end

	local vector3Value = Instance.new("Vector3Value")
	vector3Value.Name = "OriginalPosition"
	vector3Value.Value = position
	vector3Value.Parent = parent2
	return vector3Value
end

local function hotPatchAccessory(instance, instance2)
	local handle = instance:FindFirstChild("Handle")
	local handle2 = instance2:FindFirstChild("Handle")

	if not (handle and handle:IsA("MeshPart") and (handle2 and handle2:IsA("MeshPart"))) then
		return false
	end

	local attachment = handle:FindFirstChildOfClass("Attachment")
	local attachment2 = handle2:FindFirstChildOfClass("Attachment")

	if not (attachment and attachment2) then
		return false
	end

	local size = handle.Size
	local v10 = handle:FindFirstChild("OriginalSize")

	if not (v10 and v10:IsA("Vector3Value")) then
		v10 = Instance.new("Vector3Value")
		v10.Name = "OriginalSize"
		v10.Value = size
		v10.Parent = handle
	end

	local size2 = handle2.Size
	local v11 = handle2:FindFirstChild("OriginalSize")

	if not (v11 and v11:IsA("Vector3Value")) then
		v11 = Instance.new("Vector3Value")
		v11.Name = "OriginalSize"
		v11.Value = size2
		v11.Parent = handle2
	end

	local position = attachment.Position
	local v12 = attachment:FindFirstChild("OriginalPosition")

	if not (v12 and v12:IsA("Vector3Value")) then
		v12 = Instance.new("Vector3Value")
		v12.Name = "OriginalPosition"
		v12.Value = position
		v12.Parent = attachment
	end

	local position2 = attachment2.Position
	local v13 = attachment2:FindFirstChild("OriginalPosition")

	if not (v13 and v13:IsA("Vector3Value")) then
		v13 = Instance.new("Vector3Value")
		v13.Name = "OriginalPosition"
		v13.Value = position2
		v13.Parent = attachment2
	end

	local surfaceAppearance = handle:FindFirstChildOfClass("SurfaceAppearance")
	local surfaceAppearance2 = handle2:FindFirstChildOfClass("SurfaceAppearance")
	local wrapLayer = handle:FindFirstChildOfClass("WrapLayer")
	local wrapLayer2 = handle2:FindFirstChildOfClass("WrapLayer")

	if surfaceAppearance then
		surfaceAppearance:Destroy()
	end

	if wrapLayer then
		wrapLayer:Destroy()
	end

	if surfaceAppearance2 then
		local clone = surfaceAppearance2:Clone()
		clone.Parent = handle
	end

	if wrapLayer2 then
		local clone_2 = wrapLayer2:Clone()
		clone_2.Parent = handle
	end

	local v14 = handle.Size / v10.Value
	handle.TextureContent = handle2.TextureContent
	handle.Size = v11.Value * v14
	handle:ApplyMesh(handle2)
	attachment.Position = v13.Value * v14
	attachment.Orientation = attachment2.Orientation
	v10.Value = v11.Value
	v12.Value = v13.Value

	if attachment.Name == attachment2.Name then
		return true
	end

	local parent2 = instance.Parent

	if parent2 then
		local weld = handle:FindFirstChildOfClass("Weld")
		local rigidConstraint = handle:FindFirstChildOfClass("RigidConstraint")

		for _, part in parent2:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			local attachment3 = part:FindFirstChild(attachment2.Name)

			if not (attachment3 and attachment3:IsA("Attachment")) then
				continue
			end

			if weld then
				weld.Part1 = part
				weld.C1 = attachment3.CFrame
			end

			if rigidConstraint then
				rigidConstraint.Attachment1 = attachment3
			end
		end
	end

	attachment.Name = attachment2.Name
	return true
end

local function updateSkin(clone, rELICSxyz_UGCSkin: string?)
	if rELICSxyz_UGCSkin == "Default" then
		rELICSxyz_UGCSkin = nil
	end

	local v10 = rELICSxyz_UGCSkin and v2[rELICSxyz_UGCSkin]
	local handle = clone and clone:FindFirstChild("Handle")

	if not (handle and handle:IsA("MeshPart")) then
		return false
	end

	if v10 and v10.Accessory then
		if hotPatchAccessory(clone, v10.Accessory) then
			clone:SetAttribute("HotPatched", true)
			return true
		end
	elseif clone:GetAttribute("HotPatched") then
		local v11 = getBoomboxConfigs()[1];
		(v11 and promiseAccessory(v11.AssetId, v11.AccessoryType)):andThen(function(p)
			if hotPatchAccessory(clone, p) then
				clone:SetAttribute("HotPatched", false)
			end

			if v10 and v10.TextureId then
				local textureID = handle.TextureID

				if not handle:GetAttribute("RELICSxyz_DefaultSkin") then
					handle:SetAttribute("RELICSxyz_DefaultSkin", textureID)
				end

				handle.TextureID = `rbxassetid://{v10.TextureId}`
			end
		end)
		return true
	elseif v10 and v10.TextureId then
		local textureID = handle.TextureID

		if not handle:GetAttribute("RELICSxyz_DefaultSkin") then
			handle:SetAttribute("RELICSxyz_DefaultSkin", textureID)
		end

		handle.TextureID = `rbxassetid://{v10.TextureId}`
		return true
	else
		local rELICSxyz_DefaultSkin = handle:GetAttribute("RELICSxyz_DefaultSkin")

		if type(rELICSxyz_DefaultSkin) == "string" then
			handle.TextureID = rELICSxyz_DefaultSkin
		else
			handle:SetAttribute("RELICSxyz_DefaultSkin", handle.TextureID)
		end

		return true
	end

	return false
end

local function createServerAudio(userId: number)
	local v10 = v3[userId]

	if v10 then
		return v10
	end

	if RunContext.IsClient and not RunContext.IsEdit then
		error("CreateServerAudio should only be called on the server.")
	end

	while true do
		local v11 = ServerAudio.Find(userId)

		if not v11 then
			break
		end

		v11.Bin:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = `ServerAudio{userId}`
	folder:SetAttribute("UserId", userId)
	folder:AddTag("RELICSxyz_ServerAudio")
	folder.Parent = ServerAudio.Bin
	folder.Archivable = false
	local audioPlayer = Instance.new("AudioPlayer")
	audioPlayer.Parent = folder
	local audioAnalyzer = Instance.new("AudioAnalyzer")
	audioAnalyzer.SpectrumEnabled = false
	audioAnalyzer.Name = "Bass"
	audioAnalyzer.Parent = folder
	local audioFilter = Instance.new("AudioFilter")
	audioFilter.FilterType = Enum.AudioFilterType.Lowpass24dB
	audioFilter.Frequency = 100
	audioFilter.Q = 1.2
	audioFilter.Name = "FilterBass"
	audioFilter.Parent = audioAnalyzer
	local audioAnalyzer2 = Instance.new("AudioAnalyzer")
	audioAnalyzer2.SpectrumEnabled = false
	audioAnalyzer2.Name = "Treble"
	audioAnalyzer2.Parent = folder
	local audioFilter2 = Instance.new("AudioFilter")
	audioFilter2.FilterType = Enum.AudioFilterType.Bandpass
	audioFilter2.Frequency = 1100
	audioFilter2.Q = 4
	audioFilter2.Name = "FilterTreble"
	audioFilter2.Parent = audioAnalyzer2
	local audioAnalyzer3 = Instance.new("AudioAnalyzer")
	audioAnalyzer3.SpectrumEnabled = false
	audioAnalyzer3.Name = "Percussion"
	audioAnalyzer3.Parent = folder
	local audioFilter3 = Instance.new("AudioFilter")
	audioFilter3.FilterType = Enum.AudioFilterType.Highpass24dB
	audioFilter3.Frequency = 2130
	audioFilter3.Q = 2.2
	audioFilter3.Name = "FilterPercussion"
	audioFilter3.Parent = audioAnalyzer3
	local audioAnalyzer4 = Instance.new("AudioAnalyzer")
	audioAnalyzer4.SpectrumEnabled = false
	audioAnalyzer4.Name = "Loudness"
	audioAnalyzer4.Parent = folder
	local maid = Trove.new()
	maid:Add(folder)
	createWire(audioPlayer, audioAnalyzer4) -- equivalent call inferred; original call site unknown
	createWire(audioPlayer, audioFilter) -- equivalent call inferred; original call site unknown
	createWire(audioPlayer, audioFilter2) -- equivalent call inferred; original call site unknown
	createWire(audioPlayer, audioFilter3) -- equivalent call inferred; original call site unknown
	createWire(audioFilter, audioAnalyzer) -- equivalent call inferred; original call site unknown
	createWire(audioFilter2, audioAnalyzer2) -- equivalent call inferred; original call site unknown
	createWire(audioFilter3, audioAnalyzer3) -- equivalent call inferred; original call site unknown
	maid:Connect(patchFeed, function(data)
		if data.Owner == userId then
			if data.SongId then
				if MusicData.ShouldSongBeEncrypted(data.SongId) then
					if MusicData.IsSecretRegistered(data.SongId) then
						audioPlayer.Asset = data.SongId
					else
						MusicData.WaitForSecretRegistered(data.SongId, 10):andThen(function()
							audioPlayer.Asset = data.SongId
						end):catch(function(p)
							warn(`[RelicsXYZ.Boombox] ✗ FAILED to wait for secret registration: {data.SongId}`, p)
							audioPlayer.Asset = data.SongId
						end)
					end
				else
					audioPlayer.Asset = data.SongId
				end

				task.spawn(addSongToHistory, userId, data.SongId)
			end

			if data.Volume then
				audioPlayer.Volume = data.Volume
			end

			if data.TimePosition then
				audioPlayer.TimePosition = data.TimePosition
			end

			if data.Playing ~= nil then
				if data.Playing then
					audioPlayer:Play()
				else
					audioPlayer:Stop()
				end
			end
		end
	end)
	v3[userId] = {
		Audio = audioPlayer,
		Bin = folder,
		Maid = maid
	}
	maid:Add(function()
		v3[userId] = nil
		folder:Destroy()
	end)
	return v3[userId]
end

local function createBoomboxAsyncImpl(instance, humanoid, _: number?)
	local userId = instance.UserId
	local rolloffCurve = getRolloffCurve()
	local v10 = Trove.new()
	local v11 = getBoomboxConfigs()[1]
	local productId = v11.ProductId or v11.AssetId
	local accessoryType = v11.AccessoryType

	if not v[productId] then
		v[productId] = Promise.retryWithDelay(promiseAccessory, 5, 2, productId, accessoryType)
	end

	local expect = v[productId]:expect()
	local v12 = ServerAudio.Await(userId, 5)
	local clone = expect:Clone()
	local handle = clone.Handle
	local audioEmitter = Instance.new("AudioEmitter")
	audioEmitter.AudioInteractionGroup = "RELICSxyz"
	audioEmitter:SetDistanceAttenuation(rolloffCurve)
	audioEmitter.Name = "Emitter"
	audioEmitter.Parent = handle

	if v12 then
		local audio = v12.Audio
		local wire = Instance.new("Wire")
		wire.SourceInstance = audio
		wire.TargetInstance = audioEmitter
		wire.Parent = audioEmitter
	else
		warn("[RelicsXYZ] Failed to find server audio for userId", userId)
	end

	if humanoid then
		if humanoid:IsA("Humanoid") then
			humanoid:AddAccessory(clone)
		else
			clone.Parent = humanoid
		end
	end

	local function onAuraChanged()
		local rELICSxyz_Aura = instance:GetAttribute("RELICSxyz_Aura")
		local v13

		if type(rELICSxyz_Aura) == "string" then
			v13 = Auras.FindAura(rELICSxyz_Aura)
		end

		local attachment = handle:FindFirstChildOfClass("Attachment")
		local aura = handle:FindFirstChild("Aura")

		if aura then
			aura:Destroy()
		end

		if not (v13 and v13.Effect and v13.Effect:IsA("BasePart")) then
			return
		end

		local clone2 = v13.Effect:Clone()
		local v14 = Auras.BindEffect(clone2)
		local rigidConstraint = Instance.new("RigidConstraint")
		rigidConstraint.Attachment0 = attachment
		rigidConstraint.Attachment1 = v14
		rigidConstraint.Parent = v14
		clone2.Parent = handle
	end

	local function onAuraAdded(p: string)
		if instance:GetAttribute("RELICSxyz_Aura") == p then
			onAuraChanged()
		end
	end

	local function onSkinChanged()
		local rELICSxyz_UGCSkin = instance:GetAttribute("RELICSxyz_UGCSkin")

		if (type(rELICSxyz_UGCSkin) == "string" or type(rELICSxyz_UGCSkin) == "nil") and not updateSkin(
			clone,
			rELICSxyz_UGCSkin
		) then
			warn("[RelicsXYZ] Unknown/invalid UGC skin:", rELICSxyz_UGCSkin, "for player", instance.Name)
		end
	end

	local function onSkinAdded(p: string)
		if instance:GetAttribute("RELICSxyz_UGCSkin") == p then
			onSkinChanged()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onShowChanged()
		local rELICSxyz_ShowBoombox = instance:GetAttribute("RELICSxyz_ShowBoombox")

		if type(rELICSxyz_ShowBoombox) == "boolean" then
			fn(handle, rELICSxyz_ShowBoombox)
		end
	end

	local attributeChangedSignal = instance:GetAttributeChangedSignal("RELICSxyz_Aura")
	v10:Connect(Auras.AuraAdded, onAuraAdded)
	v10:Connect(attributeChangedSignal, onAuraChanged)
	onAuraChanged()
	v10:Connect(instance:GetAttributeChangedSignal("RELICSxyz_UGCSkin"), onSkinChanged)
	v10:Connect(skinAdded, onSkinAdded)
	onSkinChanged()
	v10:Connect(instance:GetAttributeChangedSignal("RELICSxyz_ShowBoombox"), onShowChanged)
	onShowChanged() -- equivalent call inferred; original call site unknown
	v10:Connect(clone.Destroying, function()
		v10:Clean()
	end)
	return clone, v10
end

local function createAudioEmitterAsyncImpl(p: number, parent2, p2: number?)
	local v10

	if p2 then
		v10 = ServerAudio.Await(p, p2)
	else
		v10 = ServerAudio.Await(p)
	end

	local audioEmitter = Instance.new("AudioEmitter")
	audioEmitter.AudioInteractionGroup = "RELICSxyz"
	audioEmitter.Name = "Emitter" .. tostring(p)
	audioEmitter:SetDistanceAttenuation((getRolloffCurve()))
	audioEmitter.Parent = parent2

	if not v10 then
		warn("[RelicsXYZ] Failed to find server audio for userId", p)
		return audioEmitter
	end

	createWire(v10.Audio, audioEmitter) -- equivalent call inferred; original call site unknown
	return audioEmitter
end

local function getBoomboxOwnershipChangedSignal(p)
	local boomboxConfigs = getBoomboxConfigs()
	local v10 = Signal.new()

	for _, boomboxConfig in boomboxConfigs do
		local v11 = Ownership.Get(boomboxConfig)

		for _, v12 in ipairs(v11) do
			Marketplace.GetOwnershipChangedSignal(p, v12.Id, v12.InfoType):Connect(function()
				v10:Fire()
			end)
		end
	end

	return v10
end

local function promiseBoomboxOwnership(p)
	return Promise.new(function(callback, callback2)
		if Backend.IsDemo() then
			callback(true)
			return
		end

		local boomboxConfigs = getBoomboxConfigs()
		local v10 = {}

		for _, boomboxConfig in ipairs(boomboxConfigs) do
			for _, v11 in Ownership.Get(boomboxConfig) do
				table.insert(v10, (Marketplace.GetOwnership(p, v11.Id, v11.InfoType)))
			end
		end

		local v11 = false

		if not Promise.allSettled(v10):await() then
			callback2("Failed to check ownership.")
			return
		end

		for _, v13 in v10 do
			local v14, v15 = v13:await()

			if not (v14 and v15) then
				continue
			end

			v11 = true
			break
		end

		callback(v11)
	end)
end

local function playerOwnsBoomboxAsync(p)
	local v10, v11 = Promise.new(function(callback, callback2)
		if Backend.IsDemo() then
			callback(true)
			return
		end

		local boomboxConfigs = getBoomboxConfigs()
		local v12 = {}

		for _, boomboxConfig in ipairs(boomboxConfigs) do
			for _, v13 in Ownership.Get(boomboxConfig) do
				table.insert(v12, (Marketplace.GetOwnership(p, v13.Id, v13.InfoType)))
			end
		end

		local v13 = false

		if not Promise.allSettled(v12):await() then
			callback2("Failed to check ownership.")
			return
		end

		for _, v15 in v12 do
			local v16, v17 = v15:await()

			if not (v16 and v17) then
				continue
			end

			v13 = true
			break
		end

		callback(v13)
	end):await()
	return v10 and v11
end

local function validateSkinOwnership(p, skin: string?)
	if not (skin and v2[skin]) then
		return Promise.reject("Invalid skin name.")
	end

	if skin == "Default" then
		return Promise.resolve(true)
	end

	local v10 = PlayerData.Read(p.UserId)

	if v10 and v10.Unlocks and v10.Unlocks.Skins and v10.Unlocks.Skins[skin] then
		return Promise.resolve(true)
	end

	local v11 = v2[skin]
	local v12 = {}
	local v13 = {}

	local function addOwnershipCheck(id: number?, infoType)
		if type(id) ~= "number" or id <= 0 then
			return
		end

		local infoType2 = infoType or Enum.InfoType.Asset
		local key = Ownership.KeyOf(id, infoType2)

		if v13[key] then
			return
		end

		v13[key] = true
		table.insert(v12, {
			Id = id,
			InfoType = infoType2
		})
	end

	for _, v14 in Ownership.Get(v11) do
		addOwnershipCheck(v14.Id, v14.InfoType)
	end

	return Marketplace.BulkResolveOwnership(p, v12):andThen(function(list)
		local v14 = false

		for _, v16 in ipairs(list) do
			if not v16 then
				continue
			end

			v14 = true
			break
		end

		return Promise.resolve(v14)
	end)
end

local function equipSkinImpl(p, skin: string?)
	local v10 = PlayerData.Get(p.UserId)

	if not v10 then
		return Promise.reject("Player data not found.")
	end

	if skin == "Default" then
		skin = nil
	end

	local firstTagged = Tags.FindFirstTagged("RelicsFeatures")

	if firstTagged and not firstTagged:GetAttribute("Skins") and skin ~= nil then
		return Promise.reject("Skins feature disabled")
	end

	if (skin and v2[skin]) == nil then
		return v10:Patch(function(p2)
			p2.UGCSkin.Skin = nil
		end):andThen(function()
			Recents.PushRecentSkin("Default", p.UserId)
		end)
	end

	return validateSkinOwnership(p, skin):andThen(function(p2)
		if p2 then
			return v10:Patch(function(p3)
				p3.UGCSkin.Skin = skin
			end):andThen(function()
				if skin then
					Recents.PushRecentSkin(skin, p.UserId)
				end
			end)
		end

		return Promise.reject("Player does not own the skin.")
	end)
end

local function equipSkin(p: string?, userId: number?)
	if not (RunContext.IsServer or RunContext.IsEdit) then
		event:Client():Fire(p)
		return
	end

	if RunContext.IsEdit then
		local StudioService = game:GetService("StudioService")
		userId = StudioService:GetUserId()
	end

	local playerByUserId = userId and Players:GetPlayerByUserId(userId)
	assert(playerByUserId, "Expected provided player to be in the server")
	equipSkinImpl(playerByUserId, p):catch(function(p2)
		warn("[RelicsXYZ] Failed to equip skin for player", playerByUserId.Name, ":", p2, debug.traceback())
		return false
	end)
end

local function temporarilyEnableMusicPlayer(p, p2: string)
	assert(RunContext.IsServer or RunContext.IsEdit, "Should only be called on the server.")
	Mutex.AddLock(p, "RELICSxyz_TemporaryBoombox", p2)
end

local function clearTemporaryMusicPlayer(p, p2: string)
	assert(RunContext.IsServer or RunContext.IsEdit, "Should only be called on the server.")
	Mutex.RemoveLock(p, "RELICSxyz_TemporaryBoombox", p2)
end

local function hasTemporaryPermission(p, p2: string?)
	return Mutex.HasLock(p, "RELICSxyz_TemporaryBoombox", p2)
end

Tags.BindWithMaid("RelicsUGCSkin", function(parent2, maid)
	local itemId = parent2:GetAttribute("ItemId")
	local itemType = parent2:GetAttribute("ItemType")
	local legacyIds = parent2:GetAttribute("LegacyIds") or parent2:GetAttribute("LegacyId")
	local textureId = parent2:GetAttribute("TextureId")
	local displayName = parent2:GetAttribute("DisplayName")
	local limitedInfo = parent2:GetAttribute("LimitedInfo")
	local accessoryId = parent2:GetAttribute("AccessoryId")
	local renderOffset = parent2:GetAttribute("RenderOffset")
	local accessoryType = parent2:GetAttribute("AccessoryType")
	local accessory = parent2:FindFirstChildOfClass("Accessory")
	local renderZoomScale = parent2:GetAttribute("RenderZoomScale")
	local gamePassId = parent2:GetAttribute("GamePassId")

	if accessoryId == nil and itemType == Enum.InfoType.Asset then
		if typeof(accessoryType) ~= "EnumItem" or not accessoryType:IsA("AccessoryType") then
			accessoryType = Enum.AccessoryType.Back
		end

		accessoryId = itemId
	end

	if type(itemId) ~= "number" then
		warn("[RelicsXYZ] Invalid skin item ID.", parent2)
		return
	end

	if legacyIds and type(legacyIds) ~= "number" and type(legacyIds) ~= "string" then
		warn("[RelicsXYZ] Invalid skin legacy IDs (expected number or string).", parent2)
		return
	end

	if type(displayName) ~= "string" then
		displayName = nil
	end

	if type(limitedInfo) ~= "string" then
		limitedInfo = nil
	end

	if not limitedInfo and itemId ~= 0 then
		return
	end

	local legacyIds2

	if legacyIds then
		legacyIds2 = Migration.ParseLegacyIds(legacyIds)
	end

	if type(accessoryId) ~= "number" then
		accessoryId = nil
	end

	if typeof(itemType) ~= "EnumItem" or not itemType:IsA("InfoType") then
		itemType = Enum.InfoType.Asset
	end

	if accessoryId and accessoryId > 0 and accessoryId ~= itemId then
		if itemId and itemId > 0 then
			legacyIds2 = legacyIds2 or {}
			local v11 = false

			for _, v13 in legacyIds2 do
				if not (v13.Id == itemId and v13.InfoType == itemType) then
					continue
				end

				v11 = true
				break
			end

			if not v11 then
				table.insert(legacyIds2, {
					Id = itemId,
					InfoType = itemType
				})
			end
		end

		itemType = Enum.InfoType.Asset
		itemId = accessoryId
	end

	if type(gamePassId) ~= "number" or not (gamePassId > 0) then
		gamePassId = nil
	end

	if gamePassId then
		legacyIds2 = legacyIds2 or {}
		local v11 = false

		for _, v13 in legacyIds2 do
			if not (v13.Id == gamePassId and v13.InfoType == Enum.InfoType.GamePass) then
				continue
			end

			v11 = true
			break
		end

		if not v11 then
			table.insert(legacyIds2, {
				Id = gamePassId,
				InfoType = Enum.InfoType.GamePass
			})
		end
	end

	if legacyIds2 and #legacyIds2 > 0 then
		local v11 = {}

		for _, v12 in legacyIds2 do
			table.insert(v11, (`{v12.Id}:{v12.InfoType.Name}`))
		end

		parent2:SetAttribute("LegacyIds", table.concat(v11, ","))
	end

	if typeof(accessoryType) ~= "EnumItem" or not accessoryType:IsA("AccessoryType") then
		if type(accessoryType) == "string" then
			accessoryType = Enum.AccessoryType:FromName(accessoryType) or Enum.AccessoryType.Back
		else
			accessoryType = Enum.AccessoryType.Back
		end
	end

	if type(textureId) ~= "number" then
		textureId = nil
	end

	if typeof(renderOffset) ~= "CFrame" then
		renderOffset = nil
	end

	if type(renderZoomScale) ~= "number" or not (renderZoomScale > 0) then
		renderZoomScale = nil
	end

	local changed = Signal.new()
	local name = parent2.Name
	local attributesByAttributeName = {
		ProductId = itemId,
		ProductType = itemType,
		TextureId = textureId,
		DisplayName = displayName,
		LimitedInfo = limitedInfo,
		AccessoryType = accessoryType,
		RenderZoomScale = renderZoomScale,
		RenderOffset = renderOffset,
		AccessoryId = accessoryId,
		Accessory = accessory,
		LegacyIds = legacyIds2,
		Changed = changed
	}

	local function updateAccessory()
		if attributesByAttributeName.AccessoryId and attributesByAttributeName.AccessoryType and (RunContext.IsServer or RunContext.IsEdit) then
			promiseAccessory(attributesByAttributeName.AccessoryId, attributesByAttributeName.AccessoryType):andThen(function(accessory2)
				if not accessory2 then
					return
				end

				local accessory3 = parent2:FindFirstChildOfClass("Accessory")

				if accessory3 then
					accessory3:Destroy()
				end

				local clone = accessory2:Clone()
				clone.Name = "Accessory"
				clone.Parent = parent2
				attributesByAttributeName.Accessory = accessory2
				changed:Fire("Accessory")
			end):catch(function(p)
				warn("[RelicsXYZ] Failed to load accessory for skin", name, ":", p)
			end)
		end
	end

	maid:Connect(parent2.AttributeChanged, function(attributeName: string)
		local attribute = parent2:GetAttribute(attributeName)
		local v12 = attributesByAttributeName[attributeName]

		if typeof(v12) == typeof(attribute) then
			if typeof(v12) == "EnumItem" and typeof(attribute) == "EnumItem" and v12.EnumType ~= attribute.EnumType then
				attribute = v12
			end

			attributesByAttributeName[attributeName] = attribute
			changed:Fire(attributeName)

			if attributeName == "AccessoryId" or attributeName == "AccessoryType" then
				updateAccessory()
			end
		end
	end)
	maid:Connect(parent2.ChildAdded, function(accessory2)
		if accessory2:IsA("Accessory") then
			attributesByAttributeName.Accessory = accessory2
			changed:Fire("Accessory")
		end
	end)
	maid:Add(function()
		v2[name] = nil
		skinRemoved:Fire(name, attributesByAttributeName)
		changed:DisconnectAll()
	end)
	updateAccessory()
	v2[name] = attributesByAttributeName
	skinAdded:Fire(name, attributesByAttributeName)
end)

if RunContext.IsServer or RunContext.IsEdit then
	local server = event:Server()

	if not script:FindFirstChild("Default") then
		local configuration = Instance.new("Configuration")
		configuration.Name = "Default"
		configuration.Archivable = false
		configuration:SetAttribute("ItemId", 0)
		configuration:SetAttribute("TextureId", 0)
		configuration:SetAttribute("DisplayName", "Default Skin")
		configuration:SetAttribute("ItemType", Enum.InfoType.Asset)
		configuration.Parent = script
		configuration:AddTag("RelicsUGCSkin")
	end

	patchFeed:Connect(function(p)
		local songId = p.SongId
		local owner = p.Owner
		local playerByUserId = songId and owner and Players:GetPlayerByUserId(owner)

		if playerByUserId then
			local rELICSxyz_EmoteAnimation = playerByUserId:GetAttribute("RELICSxyz_EmoteAnimation")
			local emote = Emotes.GetEmoteBySongId(songId)

			if emote then
				local character = playerByUserId and playerByUserId.Character
				local animate = character and character:FindFirstChild("Animate")
				local playEmote = animate and animate:FindFirstChild("PlayEmote")

				if playEmote and playEmote:IsA("BindableFunction") then
					playEmote:Invoke(emote.Animation)
					return
				end
			end

			local v10

			if type(rELICSxyz_EmoteAnimation) == "number" or type(rELICSxyz_EmoteAnimation) == "string" then
				v10 = Emotes.GetEmoteByAnimationId(rELICSxyz_EmoteAnimation)
			end

			if v10 then
				local character = playerByUserId and playerByUserId.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local rootPart = humanoid and humanoid.RootPart

				if rootPart then
					rootPart:ApplyImpulse(createVector(0, 1, 0))
				end
			end
		end
	end)
	server:On(function(instance, p: string?)
		equipSkinImpl(instance, p):andThen(function()
			local v10 = PlayerData.Read(instance.UserId)

			if v10 then
				local firstTagged = Tags.FindFirstTagged("RelicsFeatures")
				local v11 = not firstTagged or (firstTagged:GetAttribute("Skins") and true or false)
				local skin = v10.UGCSkin.Skin
				instance:SetAttribute("RELICSxyz_UGCSkin", v11 and skin or nil)
			end
		end):catch(function(p2)
			warn("[RelicsXYZ] Failed to equip skin for player", instance.Name, ":", p2, debug.traceback())
		end)
	end)
	assert(
		RunContext.IsServer or RunContext.IsEdit,
		"Boombox.SetBoomboxVisibilityHandler should only be called on the server."
	)

	fn = function(p, p2)
		p.Transparency = p2 and 0 or 1
	end

	Tags.BindWithMaid("RelicsTrialMount", function(attachment, object)
		if not attachment:IsA("Attachment") or attachment:GetAttribute("NoBoombox") then
			return
		end

		local boomboxId = tonumber(attachment:GetAttribute("BoomboxId"))
		local boomboxConfigs = getBoomboxConfigs()
		local boomboxConfig = boomboxConfigs[1]

		if boomboxId then
			for _, boomboxConfig2 in boomboxConfigs do
				if boomboxConfig2.AssetId ~= boomboxId then
					continue
				end

				boomboxConfig = boomboxConfig2
				break
			end
		end

		if boomboxConfig then
			local productId = boomboxConfig.ProductId or boomboxConfig.AssetId
			local accessoryType = boomboxConfig.AccessoryType

			if not v[productId] then
				v[productId] = Promise.retryWithDelay(promiseAccessory, 5, 2, productId, accessoryType)
			end

			boomboxConfig = v[productId]
		end

		if boomboxConfig then
			boomboxConfig:andThen(function(object2)
				local scale = tonumber(attachment:GetAttribute("Scale")) or 1
				local v10 = object2:QueryDescendants("MeshPart")[1]

				if v10 then
					local clone = v10:Clone()
					clone.Size = clone.MeshSize * scale

					for _, child in attachment:GetChildren() do
						if child:IsA("RigidConstraint") or child:IsA("BasePart") then
							child:Destroy()
						end
					end

					local attachment2 = Instance.new("Attachment")
					attachment2.Parent = clone
					local rigidConstraint = Instance.new("RigidConstraint")
					rigidConstraint.Attachment0 = attachment
					rigidConstraint.Attachment1 = attachment2
					rigidConstraint.Parent = clone
					clone.Parent = attachment
					attachment.Position = Vector3.new(0, 0.5 + clone.Size.Y / 2, 0)
					object:Add(clone)
				end
			end)
		end
	end)
	local v10 = {}

	local function onPlayerAdded(instance)
		local userId = instance.UserId
		createServerAudio(userId)
		PlayerData.Load(userId):andThen(function()
			if not instance:IsDescendantOf(game) then
				return
			end

			local v11 = PlayerData.Get(userId)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateSkin2(skin: string?)
				local firstTagged = Tags.FindFirstTagged("RelicsFeatures")
				instance:SetAttribute(
					"RELICSxyz_UGCSkin",
					(not firstTagged or (firstTagged:GetAttribute("Skins") and true or false)) and skin or nil
				)
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateBoombox()
				instance:SetAttribute("RELICSxyz_ShowBoombox", (Settings.GetBool("BoomboxIdol", userId)))
			end

			v11:Connect("UGCSkin/Skin", updateSkin2)
			v11:Connect("Settings/BoomboxIdol", updateBoombox)
			updateSkin2(v11.CurrentData.UGCSkin.Skin) -- equivalent call inferred; original call site unknown
			updateBoombox() -- equivalent call inferred; original call site unknown
		end)
		Promise.new(function(callback, callback2)
			if Backend.IsDemo() then
				callback(true)
				return
			end

			local boomboxConfigs = getBoomboxConfigs()
			local v11 = {}

			for _, boomboxConfig in ipairs(boomboxConfigs) do
				for _, v12 in Ownership.Get(boomboxConfig) do
					table.insert(v11, (Marketplace.GetOwnership(instance, v12.Id, v12.InfoType)))
				end
			end

			local v12 = false

			if not Promise.allSettled(v11):await() then
				callback2("Failed to check ownership.")
				return
			end

			for _, v14 in v11 do
				local v15, v16 = v14:await()

				if not (v15 and v16) then
					continue
				end

				v12 = true
				break
			end

			callback(v12)
		end):andThen(function(p)
			if not instance:IsDescendantOf(game) then
				return
			end

			if p then
				instance:SetAttribute("RELICSxyz_OwnsBoombox", true)
				return
			end

			local boomboxConfigs = getBoomboxConfigs()
			local maid = Trove.new()
			maid:Add(function()
				v10[userId] = nil
			end)

			for _, boomboxConfig in boomboxConfigs do
				for _, v11 in Ownership.Get(boomboxConfig) do
					maid:Connect(Marketplace.GetOwnershipChangedSignal(instance, v11.Id, v11.InfoType), function()
						maid:Clean()
						instance:SetAttribute("RELICSxyz_OwnsBoombox", true)
					end)
				end
			end

			v10[userId] = maid
		end):catch(function(p)
			warn("[RelicsXYZ] Failed to determine boombox ownership for", instance.Name, ":", p)
		end)
	end

	local function onPlayerRemoving(p)
		local userId = p.UserId
		local v11 = v3[userId]
		local maid = v11 and v11.Maid

		if maid then
			maid:Clean()
		end

		local v12 = v10[userId]

		if v12 then
			v12:Clean()
			v10[userId] = nil
		end
	end

	for _, v11 in Players:GetPlayers() do
		task.defer(onPlayerAdded, v11)
	end

	local firstTagged = Tags.FindFirstTagged("RelicsFeatures")

	if firstTagged then
		local function updateFeatures()
			if firstTagged:GetAttribute("Skins") then
				return
			end

			for _, v11 in Players:GetPlayers() do
				local v12 = v11
				PlayerData.Load(v11.UserId):andThen(function(object)
					if object.CurrentData.UGCSkin.Skin ~= nil then
						object:Patch(function(p)
							p.UGCSkin.Skin = nil
						end)
					end

					v12:SetAttribute("RELICSxyz_UGCSkin", nil)
				end)
			end
		end

		firstTagged:GetAttributeChangedSignal("Skins"):Connect(updateFeatures)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	Tags.BindWithMaid(GamePasses.ContentTag, function(instance, object)
		local gamePass = GamePasses.FindGamePassFromContent(instance)

		if not gamePass or gamePass.RelicsAssetType ~= "SKIN" then
			return
		end

		local v11

		if instance:IsA("Configuration") then
			instance:SetAttribute("LimitedInfo", gamePass.Id)
			v11 = instance
		else
			v11 = Instance.new("Configuration")

			if instance:IsA("IntValue") then
				v11:SetAttribute("TextureId", instance.Value)
			elseif instance:IsA("StringValue") then
				local v12 = tonumber(instance.Value:match("%d+$"))

				if v12 then
					v11:SetAttribute("TextureId", v12)
				end
			elseif instance:IsA("Decal") then
				local v12 = tonumber(instance.Texture:match("%d+$"))

				if v12 then
					v11:SetAttribute("TextureId", v12)
				end
			end
		end

		v11.Name = gamePass.Name
		v11:SetAttribute("ItemId", gamePass.ProductId)
		v11:SetAttribute("ItemType", gamePass.ProductType)
		v11:SetAttribute("LimitedInfo", gamePass.Id)

		if gamePass.LegacyIds and #gamePass.LegacyIds > 0 then
			local v12 = {}

			for _, legacyId in gamePass.LegacyIds do
				table.insert(v12, (`{legacyId.Id}:{legacyId.InfoType.Name}`))
			end

			v11:SetAttribute("LegacyIds", table.concat(v12, ","))
		else
			v11:SetAttribute("LegacyIds", nil)
		end

		object:Add(v11)
		v11:AddTag("RelicsUGCSkin")
		v11.Parent = instance.Parent
	end)
end

return table.freeze({
	GetSkins = getSkins,
	EquipSkin = equipSkin,
	UpdateSkin = updateSkin,
	SkinAdded = skinAdded,
	SkinRemoved = skinRemoved,
	IsFreemium = isFreemium,
	PromiseBoombox = promiseBoombox,
	SendAudioPatch = sendAudioPatch,
	AudioPatchFeed = patchFeed,
	FindServerAudio = ServerAudio.Find,
	HotPatchAccessory = hotPatchAccessory,
	WaitForServerAudio = ServerAudio.Await,
	ValidateSkinOwnership = validateSkinOwnership,
	TemporarilyEnableMusicPlayer = temporarilyEnableMusicPlayer,
	ClearTemporaryMusicPlayer = clearTemporaryMusicPlayer,
	HasTemporaryPermission = hasTemporaryPermission,
	GetBoomboxConfigs = getBoomboxConfigs,
	BoomboxConfigAdded = boomboxConfigAdded,
	BoomboxConfigRemoved = boomboxConfigRemoved,
	CreateBoomboxAsync = createBoomboxAsyncImpl,
	CreateAudioEmitterAsync = createAudioEmitterAsyncImpl,
	SetBoomboxVisibilityHandler = setBoomboxVisibilityHandler,
	PlayerOwnsBoomboxAsync = playerOwnsBoomboxAsync,
	PromiseBoomboxOwnership = promiseBoomboxOwnership,
	GetBoomboxOwnershipChangedSignal = getBoomboxOwnershipChangedSignal
})