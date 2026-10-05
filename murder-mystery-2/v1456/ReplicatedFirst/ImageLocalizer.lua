local v = {}
local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local translatorForPlayerAsync = nil
local translatorForLocaleAsync = nil
local v2 = pcall(function()
	translatorForPlayerAsync = LocalizationService:GetTranslatorForPlayerAsync(localPlayer)
end)
local v3 = pcall(function()
	translatorForLocaleAsync = LocalizationService:GetTranslatorForLocaleAsync("en")
end)

function v.translateByKey(p, p2)
	local v4 = ""
	local v5

	if v2 then
		v5 = pcall(function()
			v4 = translatorForPlayerAsync:FormatByKey(p, p2)
		end)
	else
		v5 = false
	end

	if v3 and not v5 then
		v5 = pcall(function()
			v4 = translatorForLocaleAsync:FormatByKey(p, p2)
		end)
	end

	if v5 then
		return v4
	end

	return false
end

local CollectionService = game:GetService("CollectionService")
local tagged = CollectionService:GetTagged("LocalizationImageKey")

local function LocalizeKeyValue(p)
	local parent = p.Parent
	local value = p.Value
	local image = tostring(parent.Image)
	local translateByKey = v.translateByKey(value)

	if translateByKey then
		local success, result = pcall(function()
			parent.Image = "rbxassetid://" .. translateByKey
		end)

		if not success then
			parent.Image = "rbxassetid://" .. image
			warn(result)
		end
	end
end

local CollectionService2 = game:GetService("CollectionService")
CollectionService2:GetInstanceAddedSignal("LocalizationImageKey"):connect(LocalizeKeyValue)

for _, v4 in pairs(tagged) do
	LocalizeKeyValue(v4)
end