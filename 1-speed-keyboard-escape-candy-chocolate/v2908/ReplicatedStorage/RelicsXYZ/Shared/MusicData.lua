local parent = script.Parent
local Backend = require(parent.Backend)
local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local Tags = require(parent.Tags)
local Mutex = require(parent.Mutex)
require(parent.Trove)
local Signal = require(parent.Signal)
local Promise = require(parent.Promise)
local Secrets = require(parent.Secrets)
local Migration = require(parent.Migration)
local GamePasses = require(parent.GamePasses)
local RunContext = require(parent.RunContext)
local ClientReady = require(parent.ClientReady)
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local playlistAdded = Signal.new()
local playlistRemoved = Signal.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function addOwner(p, userId: number)
	local ref = p.Ref
	Mutex.AddLock(ref, "Owners", (`{userId}`))
end

local function removeOwner(p, p2: number)
	local ref = p.Ref
	Mutex.RemoveLock(ref, "Owners", (`{p2}`))
end

local v7 = {}

if not RunContext.IsEdit then
	local firstTagged = Tags.FindFirstTagged("RelicsUnlocks")

	if firstTagged then
		for _, child in firstTagged:GetChildren() do
			for _, intValue in child:GetChildren() do
				if intValue:IsA("IntValue") then
					v7[intValue.Value] = true
				end
			end
		end
	end
end

local function isSongLockedByBadge(value)
	if typeof(value) ~= "number" then
		value = tonumber((string.sub(value, 14)))
	end

	return v7[value]
end

local function userHasUnlocked(p, p2: number)
	if p then
		return Mutex.HasLock(p.Ref, "Owners", (`{p2}`))
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setOwnershipRequired(p, flag: boolean, p2: string?)
	local ref = p.Ref

	if flag then
		Mutex.AddLock(ref, "RequiresOwnership", p2)
	else
		Mutex.RemoveLock(ref, "RequiresOwnership", p2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRequiresOwnership(p)
	return Mutex.HasLock(p.Ref, "RequiresOwnership")
end

local function getRequiresOwnershipChangedSignal(p)
	local lockChangedSignal = Mutex.GetLockChangedSignal(p.Ref, "RequiresOwnership")
	local v8 = Signal.new()
	local requiresOwnership = getRequiresOwnership(p) -- equivalent call inferred; original call site unknown
	p.Maid:Connect(lockChangedSignal, function()
		local requiresOwnership2 = getRequiresOwnership(p) -- equivalent call inferred; original call site unknown

		if requiresOwnership2 ~= requiresOwnership then
			requiresOwnership = requiresOwnership2
			v8:Fire(requiresOwnership)
		end
	end)
	return v8
end

local function getOwnershipChangedSignal(p, p2: number)
	local lockChangedSignal = Mutex.GetLockChangedSignal(p.Ref, "Owners")
	local v8 = Signal.new()
	local v9 = not p or Mutex.HasLock(p.Ref, "Owners", (`{p2}`))
	p.Maid:Connect(lockChangedSignal, function()
		local v10 = p
		local v12 = not v10 or Mutex.HasLock(v10.Ref, "Owners", (`{p2}`))

		if v12 ~= v9 then
			v9 = v12
			v8:Fire(v9)
		end
	end)
	return v8
end

local function findPlaylistByName(p: string)
	for _, v8 in v do
		if v8.Name == p then
			return v8
		end
	end

	return nil
end

local function findPlaylistById(p: string)
	for _, v8 in v do
		if v8.Id == p then
			return v8
		end
	end

	return nil
end

local function findPlaylistByAssetId(p: number)
	for _, v8 in v do
		if v8.ProductId == p then
			return v8
		end

		if not v8.LegacyIds then
			continue
		end

		for _, legacyId in v8.LegacyIds do
			if legacyId.Id == p then
				return v8
			end
		end
	end

	return nil
end

local function getPlaylists(flag: boolean?)
	local result = {}

	for _, v8 in v do
		if v8.IsPublic == flag or v8.IsPublic == nil or flag == nil and v8.IsPublic == false then
			table.insert(result, v8)
		end
	end

	return result
end

local function getSongIds(p)
	local sortPriorities = {}
	local result = {}

	for k, song in p.Songs do
		sortPriorities[k] = song.SortPriority or 1e999
		table.insert(result, k)
	end

	table.sort(result, function(a, b)
		return sortPriorities[a] < sortPriorities[b]
	end)
	return result
end

local function getAllSongs()
	return table.clone(v3)
end

local function getSongById(p: string)
	return v3[p]
end

local function unlockBadgeOwnedSongs(p)
	if not RunContext.IsServer then
		return
	end

	local firstTagged = Tags.FindFirstTagged("RelicsUnlocks")

	if not firstTagged then
		return
	end

	for _, intValue in firstTagged:GetChildren() do
		if not intValue:IsA("IntValue") then
			continue
		end

		local v8 = intValue.Value
		local success, result = pcall(function()
			return BadgeService:UserHasBadgeAsync(p.UserId, v8)
		end)

		if not (success and result) then
			continue
		end

		for _, intValue2 in intValue:GetChildren() do
			if not intValue2:IsA("IntValue") then
				continue
			end

			local v9 = v3[`rbxassetid://{intValue2.Value}`]

			if not v9 then
				continue
			end

			local userId = p.UserId

			if v9 and not Mutex.HasLock(v9.Ref, "Owners", (`{userId}`)) then
				addOwner(v9, p.UserId) -- equivalent call inferred; original call site unknown
			end

			for _, v10 in v do
				if not v10.Songs[v9.Id] then
					continue
				end

				local userId2 = p.UserId

				if not v10 or Mutex.HasLock(v10.Ref, "Owners", (`{userId2}`)) then
					continue
				end

				addOwner(v10, p.UserId) -- equivalent call inferred; original call site unknown
			end
		end
	end
end

Tags.BindWithMaid("RelicsPlaylist", function(instance, maid)
	local name = instance.Name
	local id = tostring(instance:GetAttribute("Id"))
	local image = tostring(instance:GetAttribute("Image"))
	local isFree = instance:GetAttribute("IsFree") and true or false
	local isActive = instance:GetAttribute("IsActive") and true or false
	local requiresPurchase = instance:GetAttribute("RequiresPurchase") and true or false
	local isIncluded = instance:GetAttribute("IsIncluded") and true or false
	local hasTag = instance:HasTag("RelicsPublicPlaylist")
	local productId = tonumber(instance:GetAttribute("ProductId")) or 0
	local productType = instance:GetAttribute("ProductType") or Enum.InfoType.GamePass
	local v12 = nil

	for k, v14 in v4 do
		if k == productId and productId > 0 then
			v12 = v14
			break
		elseif v14.LegacyIds then
			local flag = false

			for _, legacyId in v14.LegacyIds do
				if not (legacyId.Id == productId and productId > 0) then
					continue
				end

				v12 = v14
				flag = true
				break
			end

			if flag then
				break
			end
		end
	end

	if v12 == nil then
		for _, v15 in v4 do
			if v15.Name ~= name then
				continue
			end

			if v15.ProductId and v15.ProductId > 0 then
				productId = v15.ProductId
				instance:SetAttribute("ProductId", productId)
			end

			v12 = v15
			break
		end
	end

	local legacyIds = {}
	local limitedInfo = ""

	if v12 then
		productType = v12.ProductType or productType
		limitedInfo = v12.LimitedInfo or limitedInfo
		legacyIds = v12.LegacyIds or legacyIds
		instance:SetAttribute("LimitedInfo", limitedInfo)
		instance:SetAttribute("ProductType", productType)
	end

	if #legacyIds == 0 then
		local legacyIds2 = instance:GetAttribute("LegacyIds")

		if type(legacyIds2) == "string" or type(legacyIds2) == "number" then
			legacyIds = Migration.ParseLegacyIds(legacyIds2)
		end
	end

	local sortPriority = tonumber(instance:GetAttribute("SortPriority")) or 0
	local changed = Signal.new()
	local attributesByAttributeName = {
		Id = id,
		Name = name,
		Image = image,
		IsFree = isFree,
		IsActive = isActive,
		ProductId = productId,
		ProductType = productType,
		RequiresPurchase = requiresPurchase,
		RequiresOwnership = false,
		IsPublic = hasTag,
		IsIncluded = isIncluded,
		LimitedInfo = limitedInfo,
		Songs = {},
		LegacyIds = legacyIds,
		SongAdded = Signal.new(),
		SongRemoved = Signal.new(),
		SortPriority = sortPriority,
		Changed = changed,
		Owners = "",
		Maid = maid,
		Ref = instance
	}
	maid:Connect(instance.AttributeChanged, function(attributeName: string)
		local v15 = attributesByAttributeName[attributeName]
		local attribute = instance:GetAttribute(attributeName)

		if attributeName == "LegacyIds" then
			attributesByAttributeName.LegacyIds = Migration.ParseLegacyIds(attribute)
			changed:Fire("LegacyIds")
		elseif typeof(attribute) == typeof(v15) then
			attributesByAttributeName[attributeName] = attribute
			changed:Fire(attributeName)
		end
	end)
	v[instance] = attributesByAttributeName
	playlistAdded:Fire(attributesByAttributeName)
	maid:Add(function()
		v[instance] = nil
		playlistRemoved:Fire(attributesByAttributeName)
	end)
end)
Tags.BindWithMaid("RelicsSong", function(instance, maid)
	local name = instance.Name
	local parent2 = instance.Parent
	local playlist = parent2 and v[parent2]

	if not playlist then
		return
	end

	local id = tostring(instance:GetAttribute("Id"))
	local v9 = {
		Id = id,
		Title = name,
		Artist = tostring(instance:GetAttribute("Artist")),
		Playlist = playlist,
		SortPriority = tonumber(instance:GetAttribute("SortPriority")) or 0,
		IsEncrypted = instance:GetAttribute("IsEncrypted") and true or false,
		Changed = Signal.new(),
		RequiresOwnership = false,
		Owners = "",
		Maid = maid,
		Ref = instance
	}
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function register()
		if flag then
			return
		end

		flag = true
		v3[id] = v9
		v2[instance] = v9
		playlist.Songs[id] = v9
		playlist.SongAdded:Fire(v9)
	end

	register() -- equivalent call inferred; original call site unknown
	maid:Add(function()
		if playlist.Songs[id] == v9 then
			v2[instance] = nil
			playlist.Songs[id] = nil
			playlist.SongRemoved:Fire(v9)
		end

		if v3[id] == v9 then
			v3[id] = nil
		end
	end)
end)

local function shouldSongBeEncrypted(p: string)
	local v8 = v3[p]
	return v8 ~= nil and v8.IsEncrypted
end

if RunContext.IsServer or RunContext.IsEdit then
	local function linkGamePassToPlaylist(data)
		if data.RelicsAssetType ~= "PLAYLIST" then
			return
		end

		local productId = data.ProductId
		local playlistByAssetId = findPlaylistByAssetId(productId)

		if playlistByAssetId == nil then
			local legacyIds = data.LegacyIds

			if legacyIds then
				for _, legacyId in legacyIds do
					playlistByAssetId = findPlaylistByAssetId(legacyId.Id)

					if playlistByAssetId then
						break
					end
				end
			end
		end

		local v8

		if playlistByAssetId == nil then
			local name = data.Name

			for _, playlistByAssetId2 in v do
				if playlistByAssetId2.Name ~= name then
					continue
				end

				v8 = playlistByAssetId2
				break
			end
		else
			v8 = playlistByAssetId
		end

		if v8 then
			local ref = v8.Ref

			if v8.ProductType ~= data.ProductType then
				v8.ProductType = data.ProductType
				ref:SetAttribute("ProductType", data.ProductType)
			end

			if v8.ProductId ~= productId then
				v8.ProductId = productId
				ref:SetAttribute("ProductId", productId)
			end

			if data.LegacyIds then
				local v9 = {}

				for _, legacyId in data.LegacyIds do
					table.insert(v9, (`{legacyId.Id}:{legacyId.InfoType.Name}`))
				end

				v8.LegacyIds = data.LegacyIds
				ref:SetAttribute("LegacyIds", table.concat(v9, ","))
			end
		end

		v4[productId] = {
			LimitedInfo = data.Id,
			ProductType = data.ProductType,
			LegacyIds = data.LegacyIds,
			Name = data.Name,
			ProductId = productId
		}
	end

	GamePasses.GamePassAdded:Connect(linkGamePassToPlaylist)

	for _, v8 in GamePasses.GetGamePasses() do
		linkGamePassToPlaylist(v8)
	end

	Tags.BindWithMaid(GamePasses.ContentTag, function(p)
		local gamePass = GamePasses.FindGamePassFromContent(p)

		if not gamePass then
			return
		end

		linkGamePassToPlaylist(gamePass)
	end)
	playlistAdded:Connect(function(p)
		for _, v8 in GamePasses.GetGamePasses() do
			if not (v8.RelicsAssetType == "PLAYLIST" and (v8.ProductId == p.ProductId or v8.Name == p.Name)) then
				continue
			end

			linkGamePassToPlaylist(v8)
			break
		end
	end)
end

if not RunContext.IsClient or RunContext.IsEdit then
	local v8 = Promise.new(function(callback)
		local v9, v10 = Backend.GET("roblox/games/playlists", "RELICS_API_KEY"):await()
		local firstTagged = Tags.FindFirstTagged("RelicsFeatures")
		local v11, v12

		if firstTagged and firstTagged:GetAttribute("PublicPlaylists") then
			v11, v12 = Backend.GET("roblox/games/playlists", "RELICS_PUBLIC_KEY"):await()
		else
			v11 = false
			v12 = {}
		end

		callback({ not v9 and {} or v10, not v11 and {} or v12 })
	end)

	local function onPlayerAdded(p)
		ClientReady.WaitForClient(p)
		v8:andThen(function(list)
			for _, v9 in list[1] do
				Secrets.LoadEncryptedSongs(p, v9.songs)

				for _, v10 in Tags.GetTagged("RelicsPlaylist") do
					local count = 0

					for _, child in v10:GetChildren() do
						local id = child:GetAttribute("Id")

						if typeof(id) ~= "number" then
							id = tonumber((string.sub(id, 14)))
						end

						if not v7[id] then
							continue
						end

						count += 1
						setOwnershipRequired(v2[child], true, nil) -- equivalent call inferred; original call site unknown
					end

					if count ~= #v10:GetChildren() then
						continue
					end

					setOwnershipRequired(v[v10], true, nil) -- equivalent call inferred; original call site unknown
				end
			end

			unlockBadgeOwnedSongs(p)
		end)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)

	for _, v9 in Players:GetPlayers() do
		task.spawn(onPlayerAdded, v9)
	end

	v8:andThen(function(items)
		script:ClearAllChildren()

		for _, item in items do
			for k, v9 in item do
				local assetId = v9.assetId or "rbxassetid://0"
				local configuration = Instance.new("Configuration")
				configuration:SetAttribute("Id", v9.id)
				configuration:SetAttribute("Image", v9.image)
				configuration:SetAttribute("IsFree", v9.isFree)
				configuration:SetAttribute("IsActive", v9.isActive)
				configuration:SetAttribute("ProductId", tonumber(assetId:match("%d+$")) or 0)
				configuration:SetAttribute("ProductType", Enum.InfoType.GamePass)

				if v9.isFree then
					k = k - 10000 or k
				end

				configuration:SetAttribute("SortPriority", k)
				configuration:SetAttribute("IsIncluded", v9.isIncluded)
				configuration.Archivable = false
				configuration.Name = v9.name
				configuration:AddTag("RelicsPlaylist")

				if RunContext.IsStudio and #v9.songs == 0 then
					local configuration2 = Instance.new("Configuration")
					configuration2.Name = "Shaku"
					configuration2:SetAttribute("Id", "rbxassetid://7024332460")
					configuration2:SetAttribute("Artist", "Pegboard Nerds")
					configuration2:SetAttribute("IsEncrypted", false)
					configuration2:SetAttribute("SortPriority", 1)
					configuration2:AddTag("RelicsSong")
					configuration2.Parent = configuration
				end

				for k2, song in v9.songs do
					local secret = song.secret
					local name = song.title:gsub(" %(?[Nn][Ee][Ww]%)?", "")
					local configuration2 = Instance.new("Configuration")
					configuration2.Name = name
					configuration2:SetAttribute("Id", song.id)
					configuration2:SetAttribute("Artist", song.artist)
					configuration2:SetAttribute("SortPriority", song.sort or k2)
					configuration2:SetAttribute("IsEncrypted", secret ~= nil)
					configuration2:AddTag("RelicsSong")
					configuration2.Parent = configuration

					if secret then
						Secrets.RegisterEncryptedAsset(song.id, secret)
					end
				end

				configuration.Parent = script
			end
		end
	end):catch(function(p)
		warn("[RelicsXYZ] Failed to load playlists:", p)
	end)

	if RunContext.IsEdit then
		v8:andThen(function(list)
			local firstTagged = Tags.FindFirstTagged("RelicsUnlocks")

			if not firstTagged then
				warn("[RelicsXYZ] No 'RelicsUnlocks' folder found! Create a folder and tag it with 'RelicsUnlocks'")
				return
			end

			local allPlaylists = firstTagged:FindFirstChild("AllPlaylists") or Instance.new("Folder")
			allPlaylists.Name = "AllPlaylists"
			allPlaylists.Parent = firstTagged
			allPlaylists:ClearAllChildren()

			for _, v9 in list[1] do
				local configuration = Instance.new("Configuration")
				configuration.Name = v9.name
				configuration.Parent = allPlaylists

				for _, song in v9.songs do
					local intValue = Instance.new("IntValue")
					intValue.Name = song.title
					intValue.Parent = configuration
					intValue.Value = tonumber((string.sub(song.id, 14)))
				end
			end
		end):catch(function(p)
			warn("[RelicsXYZ] Failed to load playlists:", p)
		end)
	end
end

return table.freeze({
	FindPlaylistByAssetId = findPlaylistByAssetId,
	FindPlaylistByName = findPlaylistByName,
	FindPlaylistById = findPlaylistById,
	GetPlaylists = getPlaylists,
	GetAllSongs = getAllSongs,
	GetSongById = getSongById,
	GetSongIds = getSongIds,
	AddOwner = addOwner,
	RemoveOwner = removeOwner,
	UserHasUnlocked = userHasUnlocked,
	UnlockBadgeOwnedSongs = unlockBadgeOwnedSongs,
	SetOwnershipRequired = setOwnershipRequired,
	GetRequiresOwnership = getRequiresOwnership,
	GetOwnershipChangedSignal = getOwnershipChangedSignal,
	GetRequiresOwnershipChangedSignal = getRequiresOwnershipChangedSignal,
	IsSongLockedByBadge = isSongLockedByBadge,
	IsSongOfEmote = Secrets.IsSongOfEmote,
	RegisterSecretForUser = Secrets.RegisterSecretForUser,
	IsSecretRegistered = Secrets.IsSecretRegistered,
	WaitForSecretRegistered = Secrets.WaitForSecretRegistered,
	ShouldSongBeEncrypted = shouldSongBeEncrypted,
	PlaylistAdded = playlistAdded,
	PlaylistRemoved = playlistRemoved
})