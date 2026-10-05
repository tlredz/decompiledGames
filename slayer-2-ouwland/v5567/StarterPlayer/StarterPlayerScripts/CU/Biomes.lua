local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local localPlayer = Players.LocalPlayer
Utility.GetData(localPlayer, true)
local getvaluesfolder = Utility.getvaluesfolder(localPlayer, true)
local modulesByName = {}

for _, moduleScript in ipairs(script:QueryDescendants("ModuleScript")) do
	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

local GetInstanceChain

GetInstanceChain = function(p: string, options)
	local v = options or {}

	if v[p] then
		return {}
	end

	v[p] = true
	local v2 = modulesByName[p]

	if not v2 then
		return {}
	end

	local result = {}

	if v2.ContinueInstance then
		for _, v3 in ipairs(GetInstanceChain(v2.ContinueInstance, v)) do
			table.insert(result, v3)
		end
	end

	table.insert(result, p)
	return result
end

local ResolveProperties

ResolveProperties = function(p: string, options)
	local v = options or {}

	if v[p] then
		return {}
	end

	v[p] = true
	local v2 = modulesByName[p]

	if not v2 then
		return {}
	end

	local result = {}

	if v2.ContinueProperties then
		for k, v3 in pairs(ResolveProperties(v2.ContinueProperties, v)) do
			result[k] = v3
		end
	end

	if v2.Properties then
		for k, property in pairs(v2.Properties) do
			result[k] = property
		end
	end

	return result
end

local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)

local function ResolveMinigameBiome()
	local minigameKey = workspace:GetAttribute("MinigameKey")
	local minigameState = workspace:GetAttribute("MinigameState")
	local minigameMap = workspace:GetAttribute("MinigameMap")
	local v = {}

	if minigameKey ~= nil then
		if minigameState ~= nil then
			if minigameMap ~= nil then
				table.insert(v, (`Minigame_{minigameKey}_{minigameState}_{minigameMap}`))
			end

			table.insert(v, (`Minigame_{minigameKey}_{minigameState}`))
		end

		table.insert(v, (`Minigame_{minigameKey}`))
	end

	table.insert(v, "Minigame")

	for _, v2 in v do
		if modulesByName[v2] ~= nil then
			return v2
		end
	end

	return "Default"
end

local v = nil
local v2 = {}

function UpdateBiome()
	local v3 = not gameSettings.IsMinigame and "Default" or ResolveMinigameBiome()
	local character = localPlayer.Character
	local v4 = character ~= nil and character:GetAttribute("InMuzanLair") == true and modulesByName.MuzanLair ~= nil and "MuzanLair" or v3
	local training = getvaluesfolder:FindFirstChild("Training")

	if training ~= nil then
		local type = training:GetAttribute("Type")

		if modulesByName[type] then
			v4 = type
		end
	end

	if v ~= v4 then
		local v5 = v
		v = v4

		if v5 and modulesByName[v5] and modulesByName[v5].Stop then
			modulesByName[v5].Stop()
		end

		local instanceChain = GetInstanceChain(v4)
		local v7 = {}

		for _, v8 in ipairs(instanceChain) do
			v7[v8] = true
		end

		if v5 == nil then
			for _, v8 in ipairs(game.Lighting:QueryDescendants("BloomEffect,ColorCorrectionEffect,SunRaysEffect,Atmosphere,Sky,DepthOfFieldEffect")) do
				v8:Destroy()
			end
		end

		for k, list in pairs(v2) do
			if v7[k] then
				continue
			end

			for _, v8 in ipairs(list) do
				v8:Destroy()
			end

			v2[k] = nil
		end

		for _, v8 in ipairs(instanceChain) do
			if v2[v8] then
				continue
			end

			local v9 = modulesByName[v8]
			local clones = {}

			if v9.Instances then
				for _, instance in ipairs(v9.Instances) do
					local clone = instance:Clone()
					clone.Parent = game.Lighting
					table.insert(clones, clone)
				end
			end

			v2[v8] = clones
		end

		local properties = ResolveProperties(v4)

		for k, v9 in pairs(properties) do
			game.Lighting[k] = v9
		end

		local v9 = modulesByName[v4]

		if v9.Do then
			v9.Do(v5)
		end
	end
end

UpdateBiome()
local v3 = {
	Training = true
}
getvaluesfolder.ChildAdded:Connect(function(child)
	if v3[child.Name] then
		UpdateBiome()
	end
end)
getvaluesfolder.ChildRemoved:Connect(function(child)
	if v3[child.Name] then
		UpdateBiome()
	end
end)

if gameSettings.IsMinigame then
	for _, v4 in { "MinigameKey", "MinigameState", "MinigameMap" } do
		workspace:GetAttributeChangedSignal(v4):Connect(UpdateBiome)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hookCharacter(character)
	character:GetAttributeChangedSignal("InMuzanLair"):Connect(UpdateBiome)
	UpdateBiome()
end

if localPlayer.Character ~= nil then
	hookCharacter(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

localPlayer.CharacterAdded:Connect(hookCharacter)