local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local v = require3("@game/ReplicatedStorage/Shared/ReplicatedInstances")
local v2 = require3("@game/ReplicatedStorage/Shared/CherubVariants")
local collection = script.Collection
local SwordAPI = {}

local function resolveAnimationFolder(instance, stringValue)
	local hasAccessoryEquipped = instance:GetAttribute("HasAccessoryEquipped")
	local animationStyle = instance:GetAttribute("AnimationStyle") or "Default"
	local child = stringValue:FindFirstChild(hasAccessoryEquipped and "Accessory" or "Base")

	if not child then
		return stringValue, hasAccessoryEquipped
	end

	local v3 = child:FindFirstChild(v2.GetAccessoryVariant(instance)) or child
	stringValue = v3:FindFirstChild(animationStyle) or v3
	local value = stringValue:IsA("StringValue") and stringValue.Value

	if value then
		stringValue = collection:FindFirstChild(value)

		if not stringValue then
			return nil, hasAccessoryEquipped
		end
	end

	return stringValue, hasAccessoryEquipped
end

function SwordAPI.GetStyles(_, childName: string)
	local result = {}

	if childName == "Single" or childName == "Default" then
		return result
	end

	local child = collection:FindFirstChild(childName)

	if child then
		for _, v3 in child:QueryDescendants(">Folder") do
			local names = {}

			for _, v4 in v3:QueryDescendants(">:not(Animation):not([$Ignore])") do
				table.insert(names, v4.Name)
			end

			result[v3.Name] = names
		end
	elseif RunService:IsStudio() then
		warn("Collection not found: " .. childName)
	end

	return result
end

function SwordAPI:GetCollections(childName: string?, childName2: string?, flag: boolean?)
	local v3 = {}
	local child = childName and collection:FindFirstChild(childName)
	local child2 = childName2 and collection:FindFirstChild(childName2)
	local default = not flag and collection.Default

	if child then
		table.insert(v3, child)
	end

	if child2 then
		table.insert(v3, child2)
	end

	if default then
		table.insert(v3, default)
	end

	return v3
end

function SwordAPI:GetAnimationsInCollections(instance, items, attributeName: string)
	local children = {}

	for _, item in items do
		local animationFolder, animationProfile = resolveAnimationFolder(instance, item)

		if not animationFolder then
			continue
		end

		for _, child in animationFolder:GetChildren(), nil, nil do
			if child:GetAttribute(attributeName) then
				table.insert(children, child)
			end
		end

		if not next(children) then
			continue
		end

		if not animationFolder:GetAttribute("HasAccessoryEquipped") or animationProfile then
			animationProfile = animationFolder:GetAttribute("AnimationProfile")
		end

		instance:SetAttribute("AnimationProfile", animationProfile)
		return children
	end

	return children
end

function SwordAPI.GetSuccessParryVariantCount(_, p, p2: string?, p3: string?)
	local collections = SwordAPI:GetCollections(p2, p3, true)

	for _, collection2 in collections do
		local animationFolder = resolveAnimationFolder(p, collection2)

		if not animationFolder then
			continue
		end

		local v3 = 0

		for _, child in animationFolder:GetChildren() do
			for k in child:GetAttributes() do
				local v4 = tonumber((k:match("^SuccessParry(%d+)$")))

				if v4 and v3 < v4 then
					v3 = v4
				end
			end
		end

		if v3 > 0 then
			return v3
		end
	end

	return nil
end

function SwordAPI.GetSlashName(_, value: string, p: string?)
	if p then
		return p
	end

	local collection2 = v:GetCollection("SwordFX")
	local formatted = `{value:gsub("%s+", "")}Slash`

	if collection2[value] then
		return value
	end

	if collection2[formatted] then
		return formatted
	end

	return "SlashEffect"
end

function SwordAPI.GetAnimations(_, p, value, p2: string?, p3: string?, flag: boolean?)
	local collections = SwordAPI:GetCollections(p2, p3, flag)

	if typeof(value) == "string" then
		return SwordAPI:GetAnimationsInCollections(p, collections, value)
	end

	for _, v3 in value do
		local animationsInCollections = SwordAPI:GetAnimationsInCollections(p, collections, v3)

		if #animationsInCollections > 0 then
			return animationsInCollections
		end
	end

	return {}
end

function SwordAPI.GetAnimationProfile(_, p: string?, p2: string?, flag: boolean?, value: string?, p3)
	local collections = SwordAPI:GetCollections(p, p2, false)
	local v3 = flag and "Accessory" or "Base"
	local v4 = value or "Default"

	for _, stringValue in collections do
		local child = stringValue:FindFirstChild(v3)

		if child then
			local v5 = child:FindFirstChild(v2.GetAccessoryVariant(p3)) or child
			stringValue = v5:FindFirstChild(v4) or v5
			local value2 = stringValue:IsA("StringValue") and stringValue.Value

			if value2 then
				stringValue = collection:FindFirstChild(value2)

				if not stringValue then
					continue
				end
			end
		end

		local animationProfile = stringValue:GetAttribute("AnimationProfile")

		if animationProfile and animationProfile ~= "" and (not stringValue:GetAttribute("HasAccessoryEquipped") or flag) then
			return animationProfile
		end
	end

	return nil
end

return SwordAPI