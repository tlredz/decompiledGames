local Players = game:GetService("Players")
local parent = script.Parent
local useEmotes = require(parent.useEmotes)
local useSignal = require(parent.useSignal)
local useAuraData = require(parent.useAuraData)
local useUgcSkins = require(parent.useUgcSkins)
local useAttribute = require(parent.useAttribute)
local useOwnership = require(parent.useOwnership)
local usePlaylists = require(parent.usePlaylists)
local usePlayerData = require(parent.usePlayerData)
local useGamePasses = require(parent.useGamePasses)
local useStyleSheet = require(parent.useStyleSheet)
local useActiveBundle = require(parent.useActiveBundle)
local parent2 = parent.Parent
local shared = parent2.Parent.Shared
local State = require(parent2.State)
local Enums = require(parent2.Enums)
local Auras = require(shared.Auras)
local React = require(shared.React)
local Emotes = require(shared.Emotes)
local Bundles = require(shared.Bundles)
local Boombox = require(shared.Boombox)
local Ownership = require(shared.Ownership)
require(shared.MusicData)
require(shared.GamePasses)
local Marketplace = require(shared.Marketplace)
local components = parent2.Components
local SongList = require(components.SongList)
local AuraPreview = require(components.AuraPreview)
local EmotePreview = require(components.EmotePreview)
local BoomboxPreview = require(components.BoomboxPreview)
local v = {}
local localPlayer = Players.LocalPlayer

local function useBoomboxConfigs()
	local state, setState = React.useState(Boombox.GetBoomboxConfigs)
	useSignal(Boombox.BoomboxConfigAdded, function(_)
		setState(Boombox.GetBoomboxConfigs)
	end, {})
	useSignal(Boombox.BoomboxConfigRemoved, function(_)
		setState(Boombox.GetBoomboxConfigs)
	end, {})
	return state
end

local function useIsLockedBundleFinalItem(p, value: string?)
	local v2 = useActiveBundle()
	local v3 = useGamePasses()
	local v4 = (v2 and v2.Type) == "LastItemLocked"
	local v5 = usePlaylists({
		IncludeInactiveUnowned = true
	})
	local v6 = React.useMemo(function()
		local result = {}

		for _, v7 in v3 do
			if v7.ProductId and v7.ProductId > 0 then
				result[v7.ProductId] = v7
			end

			local sourceIds = v7.SourceIds

			if sourceIds then
				if sourceIds.Asset and sourceIds.Asset > 0 then
					result[sourceIds.Asset] = v7
				end

				if sourceIds.GamePass and sourceIds.GamePass > 0 then
					result[sourceIds.GamePass] = v7
				end
			end

			if not v7.LegacyIds then
				continue
			end

			for _, legacyId in v7.LegacyIds do
				if legacyId.Id and legacyId.Id > 0 then
					result[legacyId.Id] = v7
				end
			end
		end

		return result
	end, { v3 })
	local v7 = React.useMemo(function()
		if not value then
			return nil
		end

		for _, v8 in v3 do
			if v8.RelicsAssetType == p and v8.Name:upper() == value:upper() then
				return v8
			end
		end

		return nil
	end, { value, p, v3 })
	local v8 = React.useMemo(function()
		local result = {}

		for _, v9 in ipairs(v5) do
			local v10 = Ownership.Get(v9)

			for _, v11 in v10 do
				local id = v11.Id

				if id > 0 then
					result[id] = v9
				end
			end
		end

		return result
	end, { v5 })
	local v9 = React.useMemo(function()
		local result = {}

		for _, v10 in ipairs(v5) do
			result[v10.Name:upper()] = v10
		end

		return result
	end, { v5 })
	local v10 = React.useCallback(function(data)
		if not (data and v7 and v4) then
			return {
				Applies = false,
				Records = {},
				TotalPrereqs = 0
			}
		end

		local function isFinalItemId(p2: number?)
			if not p2 or p2 <= 0 then
				return false
			end

			if p2 == v7.ProductId then
				return true
			end

			local sourceIds = v7.SourceIds

			if sourceIds and (p2 == sourceIds.Asset or p2 == sourceIds.GamePass) then
				return true
			end

			if v7.LegacyIds then
				for _, legacyId in v7.LegacyIds do
					if p2 == legacyId.Id then
						return true
					end
				end
			end

			return false
		end

		if not isFinalItemId(data.AssetId) then
			return {
				Applies = false,
				Records = {},
				TotalPrereqs = 0
			}
		end

		local clone = table.clone(data.Items)
		table.sort(clone, function(a, b)
			return (a.Sort or 1e999) < (b.Sort or 1e999)
		end)
		local count = 0
		local records = {}

		for i, v12 in ipairs(clone) do
			local assetId2 = Bundles.ResolveAssetId(v12)

			if assetId2 and isFinalItemId(assetId2.Id) then
				continue
			end

			local formatted = `bundle:{data.Id}:prereq:{i}:{v12.ItemType}:{v12.Id}`
			local v13 = {}
			local v15 = {}

			local function addCandidate(id: number?, infoType)
				if type(id) ~= "number" or id <= 0 or infoType == nil then
					return
				end

				local key = Ownership.KeyOf(id, infoType)

				if v15[key] then
					return
				end

				v15[key] = true
				table.insert(v13, {
					Id = id,
					InfoType = infoType
				})
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local v17 = v13

			local function addGamePassCandidates(p2)
				Ownership.Get(p2, v17)
			end

			local v18 = v13

			local function addPlaylistCandidates(p2)
				addGamePassCandidates(p2) -- equivalent call inferred; original call site unknown
			end

			if v12.ItemType == "GAME_PASS" then
				local v19 = assetId2 and v6[assetId2.Id]

				if v19 then
					addGamePassCandidates(v19) -- equivalent call inferred; original call site unknown
					local v20 = v19.RelicsAssetType == "PLAYLIST" and v9[v19.Name:upper()]

					if v20 then
						addGamePassCandidates(v20) -- equivalent call inferred; original call site unknown
					end
				elseif assetId2 then
					addCandidate(assetId2.Id, assetId2.InfoType)
				end
			elseif v12.ItemType == "PLAYLIST" then
				local v19 = assetId2 and v8[assetId2.Id]

				if v19 then
					addGamePassCandidates(v19) -- equivalent call inferred; original call site unknown
				elseif assetId2 then
					addCandidate(assetId2.Id, assetId2.InfoType)
				end
			elseif assetId2 then
				addCandidate(assetId2.Id, assetId2.InfoType)
			end

			count += 1

			for _, v19 in ipairs(v13) do
				table.insert(records, {
					Id = v19.Id,
					InfoType = v19.InfoType,
					Key = formatted
				})
			end
		end

		return {
			Applies = true,
			Records = records,
			TotalPrereqs = count
		}
	end, {
		v7,
		v6,
		v8,
		v4,
		v9
	})
	local v11 = React.useMemo(function()
		return v10(v2)
	end, {
		v2,
		v7,
		v6,
		v8,
		v9,
		v4
	})
	local _, v12 = useOwnership(v11.Records)
	return v11.Applies and v12 < v11.TotalPrereqs
end

function v.AURA(value, p)
	local v2 = useAuraData()
	local aura = value and value:gsub(" [Aa][Uu][Rr][Aa]", "")
	local v4 = aura and Auras.FindAura(aura)
	local equipped = v2.Aura == aura
	local hideBackground = p == "ItemPage"
	local locked = useIsLockedBundleFinalItem("AURA", aura)
	local title = aura and aura:upper()
	local v9 = useStyleSheet("Palette", "Color3")

	if title and title:sub(-5) ~= " AURA" then
		title ..= " AURA"
	end

	local ownership = React.useMemo(function()
		if v4 then
			return Ownership.Get(v4)
		end

		return {}
	end, { v4 })
	local owned = useOwnership(ownership)

	if aura then
		owned = v2.Unlocks[aura] or owned
	end

	local purchase = React.useCallback(function()
		if locked or not v4 then
			return
		end

		if v4.ProductId and v4.ProductId > 0 then
			Marketplace.PromptPurchase(v4.ProductId, v4.ProductType)
		end
	end, { v4, locked })
	local equip = React.useCallback(function()
		local equipAura = Auras.EquipAura
		local v14

		if not equipped then
			v14 = aura
		end

		equipAura(v14)
	end, { aura, equipped })
	local render = React.useMemo(function()
		if hideBackground and v4 then
			return {
				Widget = AuraPreview,
				Props = {
					Aura = aura
				}
			}
		end

		return nil
	end, { hideBackground, v4, aura })
	return {
		Title = title,
		Purchase = purchase,
		Equip = equip,
		Enabled = true,
		Owned = owned,
		Ownership = ownership,
		Locked = locked,
		Equipped = equipped,
		Product = React.useMemo(function()
			if v4 then
				return {
					Id = v4.ProductId,
					InfoType = v4.ProductType
				}
			end

			return nil
		end, { v4 }),
		Render = render,
		Image = v4 and v4.Image,
		BackgroundImage = v4 and v4.HeaderImage,
		IconSpinStyle = "PerlinNoise",
		StrokeColor = v9("Color-Collection-AurasFeatured"),
		TitleStrokeColor = Color3.new(),
		PreviewBackground = not hideBackground and nil,
		HideBackground = hideBackground
	}
end

function v.SKIN(skin2, _)
	local v2 = useStyleSheet("Palette", "Color3")
	local v3 = useStyleSheet("Icons", "string")
	local v4 = useUgcSkins()
	local v5 = usePlayerData("UGCSkin/Skin", "Unlocks/Skins")
	local skin = v5.UGCSkin.Skin
	local v6 = skin2 and v4[skin2]
	local productId = v6 and v6.ProductId
	local productType = v6 and v6.ProductType
	local locked = useIsLockedBundleFinalItem("SKIN", skin2)
	local ownership = React.useMemo(function()
		return not v6 and {} or Ownership.Get(v6)
	end, { v6 })
	local v9 = useOwnership(ownership)
	local equipped = skin == skin2
	local owned = not v9 and v5.Unlocks and v5.Unlocks.Skins and v5.Unlocks.Skins[skin2] and true or v9

	if productId == 0 then
		equipped = skin == nil or skin == "Default"
		owned = true
	end

	local title

	if skin2 then
		local v14

		if v6 then
			v14 = v6.DisplayName or skin2
		else
			v14 = skin2
		end

		title = string.upper(v14)
	else
		title = skin2
	end

	return {
		Title = title,
		UnequipText = equipped and skin == nil and "EQUIPPED" or nil,
		Purchase = function()
			if locked then
				return
			end

			if productId and productType then
				Marketplace.PromptPurchase(productId, productType)
			end
		end,
		Equip = function()
			if equipped or skin2 == "Default" then
				Boombox.EquipSkin(nil)
			else
				Boombox.EquipSkin(skin2)
			end
		end,
		Render = {
			Widget = BoomboxPreview,
			Props = {
				Skin = skin2
			}
		},
		Product = {
			Id = productId,
			InfoType = productType
		},
		Enabled = true,
		Owned = owned,
		Ownership = ownership,
		Locked = locked,
		Equipped = equipped,
		StrokeColor = v2("Color-Collection-CosmeticsFeatured"),
		BackgroundImage = v3("Image-CategoryBackground-Skins")
	}
end

function v.EMOTE(name, p)
	local v2 = useStyleSheet("Palette", "Color3")
	local v3 = useStyleSheet("Icons", "string")
	local v4 = useEmotes()
	local v5 = name and v4[name]
	local v6 = React.useContext(State.Context)
	local locked = useIsLockedBundleFinalItem("EMOTE", name)
	local v8 = useAttribute(localPlayer, Emotes.Mutex, function(value)
		if type(value) == "string" then
			return value
		end

		return nil
	end)
	local userId = localPlayer.UserId
	local animation = v5 and v5.Animation
	local v9 = animation and tonumber(animation.AnimationId:match("%d+$"))
	local useState = React.useState
	local v10

	if v5 then
		v10 = v5.Owners[userId] or false
	else
		v10 = false
	end

	local state, setState = useState(v10)
	local equipped

	if v5 and v9 then
		equipped = v8 == `Emote_{v9}`
	else
		equipped = false
	end

	React.useEffect(function()
		if v5 then
			setState(v5.Owners[userId] == true)
		end
	end, { v5 })
	useSignal(Emotes.OwnerAdded, function(p2, p3)
		if p2 == v5 and p3 == userId then
			setState(true)
		end
	end, { name, v5 })
	useSignal(Emotes.OwnerRemoved, function(p2, p3)
		if p2 == v5 and p3 == userId then
			setState(false)
		end
	end, { name, v5 })
	local animation2 = v5 and v5.Animation
	local v12

	if (animation2 and animation2:FindFirstChildWhichIsA("ParticleEmitter", true)) == nil then
		v12 = false
	else
		v12 = p == "ItemPage"
	end

	local ownership = React.useMemo(function()
		if v5 then
			return Ownership.Get(v5)
		end

		return {}
	end, { v5 })
	local v14 = useOwnership(ownership)

	if name then
		if v5 then
			name = v5.Name or name
		end

		name = string.upper(name)
	end

	return {
		Title = name,
		Purchase = function()
			if locked then
				return
			end

			if v5 and v5.ProductId and v5.ProductType then
				Marketplace.PromptPurchase(v5.ProductId, v5.ProductType)
			end
		end,
		Equip = function()
			if v5 then
				Emotes.PlayEmoteLocal(v5, v6)
			end
		end,
		Enabled = true,
		Owned = state or v14,
		Locked = locked,
		EquipText = "PLAY",
		UnequipText = "STOP",
		Equipped = equipped,
		HideBackground = v12,
		Ownership = ownership,
		Product = v5 and {
			Id = v5.ProductId,
			InfoType = v5.ProductType
		},
		Render = {
			Widget = EmotePreview,
			Props = {
				Emote = v5 and v5.Animation,
				RenderEffect = v12
			}
		},
		StrokeColor = v2("Color-Collection-DancesFeatured"),
		BackgroundImage = v3("Image-CategoryBackground-Emotes"),
		PreviewBackground = not v12 and nil
	}
end

function v.PLAYLIST(name, _)
	local v2 = React.useContext(State.Context)
	local v3 = usePlaylists({
		IncludeInactiveUnowned = true
	})
	local locked = useIsLockedBundleFinalItem("PLAYLIST", name)
	local v5 = useStyleSheet("Palette", "Color3")
	local v6 = useStyleSheet("Icons", "string")
	local v7 = React.useMemo(function()
		if not name then
			return nil
		end

		for _, v8 in v3 do
			if not (v8.LimitedInfo ~= name and v8.Name:lower() ~= name:lower()) then
				return v8
			end

			if v8.Id:lower() == name:lower() then
				return v8
			end
		end

		return nil
	end, { name, v3 })
	local productId = v7 and v7.ProductId
	local v8 = useBoomboxConfigs()
	local songs = React.useMemo(function()
		if not v7 then
			return {}
		end

		local sortPrioritiesById = {}
		local ids = {}

		for _, song in v7.Songs do
			sortPrioritiesById[song.Id] = song.SortPriority or 1e999
			table.insert(ids, song.Id)
		end

		table.sort(ids, function(a, b)
			return sortPrioritiesById[a] < sortPrioritiesById[b]
		end)
		return ids
	end, { v7 })
	local ownership = React.useMemo(function()
		local v11 = {}
		local v12 = {}

		local function addOwnership(id: number?, p)
			if type(id) ~= "number" or id <= 0 then
				return
			end

			local infoType = p or Enum.InfoType.GamePass
			local key = Ownership.KeyOf(id, infoType)

			if v12[key] then
				return
			end

			v12[key] = true
			table.insert(v11, {
				Id = id,
				InfoType = infoType
			})
		end

		if not v7 then
			return v11
		end

		for _, v13 in Ownership.Get(v7) do
			addOwnership(v13.Id, v13.InfoType)
		end

		if not v7.IsIncluded then
			return v11
		end

		for _, v13 in v8 do
			local assetId = v13.AssetId
			local gamePassId = v13.GamePassId

			if gamePassId then
				addOwnership(gamePassId, Enum.InfoType.GamePass)
			end

			addOwnership(assetId, Enum.InfoType.Asset)
		end

		return v11
	end, { v7 })
	local owned = useOwnership(ownership)
	local product = productId and {
		Id = productId,
		InfoType = v7 and v7.ProductType or Enum.InfoType.GamePass
	} or nil
	local v13 = v2.Status == Enums.UserStatus.BoomboxPurchased
	local isPublic

	if v7 then
		isPublic = v7.IsPublic or false
	else
		isPublic = false
	end

	local v14 = v7 and v7.Name:upper() == "FAVORITES"
	local isFree = v7 and v7.IsFree

	if name then
		if v7 then
			name = v7.Name or name
		end

		name = string.upper(name)
	end

	return {
		Title = name,
		StrokeColor = v5("Color-Collection-PlaylistsFeatured"),
		TitleStrokeColor = Color3.new(),
		Purchase = function()
			if locked then
				return
			end

			if productId then
				Marketplace.PromptPurchase(productId, v7 and v7.ProductType or Enum.InfoType.GamePass)
			end
		end,
		Equip = function()
			v2.SetSongList(songs)

			if #songs > 0 then
				local v16 = not v2.Shuffled and 1 or math.random(1, #songs)
				v2.SetSong(songs[v16])
			end
		end,
		BackgroundImage = v7 and v7.Image,
		Image = v6("Icon-MusicRecord"),
		IconSpinStyle = "MusicAccented",
		Ownership = ownership,
		Owned = owned,
		PageRender = {
			Widget = SongList,
			Props = {
				Songs = songs,
				IsGamePass = true,
				SampleMode = not owned,
				[React.Tag] = "PreviewSongList"
			}
		},
		Enabled = (isPublic or v14) and true or v13 and true or isFree,
		Equipped = false,
		EquipText = "PLAY",
		Product = product,
		Locked = locked
	}
end

local function useRelicsAssetInfo(value)
	local v2 = useGamePasses()
	local v3 = v2[React.useMemo(function()
		if type(value) == "string" then
			if v2[value] then
				return value
			end
		elseif type(value) == "table" and value.Type == nil and value.Id ~= nil then
			return value.Id
		end

		return nil
	end, { value, v2 })]
	local v4 = React.useMemo(function()
		local type2 = nil

		if v3 then
			return v3.RelicsAssetType
		end

		if type(value) == "table" then
			type2 = value.Type
		end

		return type2
	end, { value, v3 })
	local v5 = React.useMemo(function()
		if v3 then
			return v3.Name
		end

		if type(value) == "table" then
			return value.Id
		end

		return nil
	end, { value, v3 })
	local v6 = {}
	local renderContext

	if type(value) == "table" then
		renderContext = value.RenderContext
	end

	local AURA = v.AURA
	local v7

	if v4 == "AURA" then
		v7 = v5
	end

	local v8 = AURA(v7, renderContext)
	local SKIN = v.SKIN
	local v9

	if v4 == "SKIN" then
		v9 = v5
	end

	local v10 = SKIN(v9, renderContext)
	local EMOTE = v.EMOTE
	local v11

	if v4 == "EMOTE" then
		v11 = v5
	end

	local v12 = EMOTE(v11, renderContext)
	local PLAYLIST = v.PLAYLIST
	local v13

	if v4 == "PLAYLIST" then
		v13 = v5
	end

	local v14 = PLAYLIST(v13, renderContext)

	if not v5 then
		return v6
	end

	if v4 == "AURA" then
		return v8
	elseif v4 == "SKIN" then
		return v10
	elseif v4 == "EMOTE" then
		return v12
	elseif v4 == "PLAYLIST" then
		return v14
	end

	return v6
end

return useRelicsAssetInfo