require(script.Types)
local Sounds = require(script.Sounds)
local Packs = require(script.Packs)
local SoundPacks = {
	ATTRIBUTE_NAME = "EquippedSoundPack",
	DEFAULT_SOUND = "Creamy",
	PREVIEW_COOLDOWN = 0.2,
	PREVIEW_VOLUME = 0.6,
	DEFAULT_ASSET_VOLUME = 1,
	COLOR_DEFAULT = Color3.fromHex("361400"),
	COLOR_EQUIPPED = Color3.fromHex("ffffff"),
	LOCKED_TRANSPARENCY = 0.6,
	Sounds = Sounds,
	Packs = Packs,
	GetSound = function(p: string)
		return Sounds.Library[p]
	end,
	GetPack = function(p: string)
		return Packs[p]
	end,
	GetSortedPacks = function()
		local result = {}

		for k, pack in pairs(Packs) do
			table.insert(result, {
				key = k,
				pack = pack
			})
		end

		table.sort(result, function(a, b)
			return a.pack.order < b.pack.order
		end)
		return result
	end,
	GetPackSounds = function(p: string)
		local result = {}
		local pack = Packs[p]

		if not pack then
			return result
		end

		for _, sound in ipairs(pack.sounds) do
			local sound2 = Sounds.Library[sound]

			if sound2 then
				table.insert(result, {
					key = sound,
					sound = sound2
				})
			else
				warn(("[SoundPacks] Son '%s' introuvable dans Sounds.Library (pack '%s')"):format(sound, p))
			end
		end

		return result
	end
}
local v = nil

function SoundPacks.GetPackForSound(p: string)
	if not v then
		v = {}

		for k, pack in pairs(Packs) do
			for _, sound in ipairs(pack.sounds) do
				v[sound] = k
			end
		end
	end

	local v2 = v[p]
	return v2, v2 and Packs[v2] or nil
end

local v2 = {}

function SoundPacks.ResolveSoundAssets(p: string)
	if v2[p] then
		return v2[p]
	end

	local v3 = {}
	local v4 = Sounds.Library[p]

	if v4 then
		for _, asset in ipairs(v4.assets) do
			table.insert(v3, {
				assetId = asset.assetId,
				volume = asset.volume or SoundPacks.DEFAULT_ASSET_VOLUME,
				weight = asset.weight or 1
			})
		end
	end

	local selected = #v3 == 0 and {
		{
			assetId = Sounds.BACKUP_SOUND_ID,
			volume = 1,
			weight = 1
		}
	} or v3
	v2[p] = selected
	return selected
end

function SoundPacks.PickRandomAsset(list, object)
	local total = 0

	for _, v3 in ipairs(list) do
		total += v3.weight
	end

	local number = object:NextNumber(0, total)

	for _, v3 in ipairs(list) do
		number -= v3.weight

		if number <= 0 then
			return v3
		end
	end

	return list[#list]
end

function SoundPacks:ApplyGradient(data)
	if not data then
		return
	end

	if data.color then
		self.Color = data.color
	end

	if data.transparency then
		self.Transparency = data.transparency
	end

	if data.rotation then
		self.Rotation = data.rotation
	end
end

function SoundPacks.GetRequiredGamepassKeys()
	local v3 = {}
	local gamepassKeys = {}

	for _, pack in pairs(Packs) do
		local unlock = pack.unlock

		if unlock.type ~= "Gamepass" or not unlock.gamepassKey or v3[unlock.gamepassKey] then
			continue
		end

		v3[unlock.gamepassKey] = true
		table.insert(gamepassKeys, unlock.gamepassKey)
	end

	return gamepassKeys
end

return SoundPacks