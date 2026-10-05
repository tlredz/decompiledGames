local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {}
local v2 = {}
local assetTemplates = nil
local sounds = nil
local v3 = nil
local v4 = nil

local function ensureRefs()
	if assetTemplates == nil then
		assetTemplates = ReplicatedStorage:FindFirstChild("AssetTemplates") or false
	end

	if assetTemplates and sounds == nil then
		sounds = assetTemplates:FindFirstChild("Sounds") or false
	end

	if assetTemplates and v3 == nil then
		local soundBank = assetTemplates:FindFirstChild("SoundBank")
		local success, result = pcall(function()
			return soundBank and require(soundBank)
		end)

		if success and type(result) == "table" then
			v3 = result
			v4 = {}

			for k, v5 in pairs(result) do
				v4[tostring(v5):lower()] = k
			end
		else
			v3 = false
		end
	end
end

local function normId(value)
	if type(value) == "number" then
		value = tostring((math.floor(value)))
	end

	if type(value) ~= "string" then
		return nil
	end

	local match = value:match("^%s*(.-)%s*$")

	if match == "" then
		return nil
	end

	if match:match("^rbxassetid://%d+$") then
		return match
	end

	local match2 = match:match("(%d+)")

	if match2 and match2 ~= "0" then
		return "rbxassetid://" .. match2
	end

	return nil
end

local function resolveSoundId(properties)
	local v5 = normId(properties.CustomSoundId)

	if v5 then
		return v5
	end

	local soundName = properties.SoundName

	if type(soundName) ~= "string" or soundName == "" then
		return nil
	end

	ensureRefs()
	local lower = soundName:lower()

	if sounds then
		for _, sound in ipairs(sounds:GetChildren()) do
			if not (sound:IsA("Sound") and sound.Name:lower() == lower) then
				continue
			end

			local v6 = normId(sound.SoundId)

			if v6 then
				return v6
			end
		end
	end

	local v6 = v4 and v4[lower]

	if v6 then
		return (normId(v6))
	end

	return (normId(soundName))
end

local v5 = {
	"MeshId",
	"TextureID",
	"TextureId",
	"Texture",
	"SoundId",
	"AnimationId",
	"Graphic",
	"ShirtTemplate",
	"PantsTemplate",
	"Image",
	"ColorMap",
	"NormalMap",
	"MetalnessMap",
	"RoughnessMap"
}

local function collectInstanceInto(folder, callback)
	for _, descendant in ipairs(folder:GetDescendants()) do
		for _, v6 in ipairs(v5) do
			local v7 = descendant
			local v8 = v6
			local success, result = pcall(function()
				return v7[v8]
			end)

			if success and type(result) == "string" and result ~= "" then
				callback(result)
			end
		end
	end
end

local function collectPresetInto(properties, add)
	local presetMeshName = properties.PresetMeshName or properties.PresetName

	if type(presetMeshName) ~= "string" or presetMeshName == "" then
		return
	end

	local presetRootFolder = properties.PresetRootFolder
	local v6 = (type(presetRootFolder) ~= "string" or presetRootFolder == "") and "PresetMeshes" or presetRootFolder
	local child = ReplicatedStorage:FindFirstChild(v6)

	if not child then
		ensureRefs()

		if assetTemplates then
			child = assetTemplates:FindFirstChild(v6)
		end
	end

	if not child then
		return
	end

	local child2 = child:FindFirstChild(presetMeshName, true)

	if child2 then
		collectInstanceInto(child2, add)
	end
end

local function collectMoveUrls(p)
	local v6 = {}
	local v7 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(p2)
		local v8 = normId(p2)

		if v8 and not v7[v8] then
			v7[v8] = true
			v6[#v6 + 1] = v8
		end
	end

	local scan

	scan = function(value, p2)
		if p2 > 8 then
			return
		end

		local typeName = type(value)

		if typeName == "string" then
			for k in value:gmatch("rbxassetid://%d+") do
				add(k) -- equivalent call inferred; original call site unknown
			end
		elseif typeName == "table" then
			for k, v8 in pairs(value) do
				scan(k, p2 + 1)
				scan(v8, p2 + 1)
			end
		end
	end

	if type(p) ~= "table" or type(p.Data) ~= "table" then
		return v6
	end

	for _, v8 in ipairs(p.Data) do
		if type(v8) ~= "table" then
			continue
		end

		scan(v8, 0)
		local properties = type(v8.Properties) == "table" and v8.Properties

		if not properties then
			if type(v8.Data) == "table" and type(v8.Data.Properties) == "table" then
				properties = v8.Data.Properties or nil
			else
				properties = nil
			end
		end

		if not properties then
			continue
		end

		local eventType = v8.EventType

		if eventType == "Sound" then
			add(resolveSoundId(properties)) -- equivalent call inferred; original call site unknown
		elseif eventType == "Animation" then
			add(properties.AnimationId) -- equivalent call inferred; original call site unknown
		elseif eventType == "Preset Mesh" or eventType == "Particle" then
			collectPresetInto(properties, add)
		end
	end

	return v6
end

local function preloadUrls(list)
	local v6 = {}

	for _, v7 in ipairs(list) do
		if type(v7) ~= "string" or v[v7] then
			continue
		end

		v[v7] = true
		local v8 = v7
		local success, result = pcall(function()
			return ContentProvider:GetAssetFetchStatus(v8)
		end)

		if not success or result ~= Enum.AssetFetchStatus.Success then
			v6[#v6 + 1] = v7
		end
	end

	for i = 1, #v6, 10 do
		local v7 = {}

		for i2 = i, math.min(i + 10 - 1, #v6) do
			v7[#v7 + 1] = v6[i2]
		end

		pcall(function()
			ContentProvider:PreloadAsync(v7)
		end)
		task.wait()
	end
end

local MovePreloader = {
	collectMoveUrls = collectMoveUrls
}
local v6 = {}

function MovePreloader.preloadMove(p, p2)
	if p2 ~= nil then
		if v6[p2] then
			return
		else
			v6[p2] = true
		end
	end

	task.spawn(function()
		preloadUrls(collectMoveUrls(p))
	end)
end

function MovePreloader.preloadList(p)
	if type(p) ~= "table" then
		return
	end

	task.spawn(function()
		preloadUrls(p)
	end)
end

function MovePreloader.preloadCharacter(instance, p)
	if typeof(instance) ~= "Instance" then
		return
	end

	if p then
		if v2[p] then
			return
		else
			v2[p] = true
		end
	end

	task.spawn(function()
		local v7 = {}
		local v8 = {}

		local function add(p2)
			local v9 = normId(p2)

			if v9 and not v8[v9] then
				v8[v9] = true
				v7[#v7 + 1] = v9
			end
		end

		collectInstanceInto(instance, add)
		preloadUrls(v7)
	end)
end

return MovePreloader