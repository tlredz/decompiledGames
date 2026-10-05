local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SettingsFlags = require(ReplicatedStorage2.SharedUtils.SettingsFlags)
local isClient = RunService:IsClient()
RunService:IsStudio()
local v = (isClient and "Client_" or "Server_") .. "Initiated"

if script:GetAttribute(v) then
	return
end

script:SetAttribute(v, true)
local modules = ReplicatedStorage:WaitForChild("Modules", 60)

if not modules then
	warn("[Blink.lua] Modules folder not found")
	return
end

local myDataController = modules:FindFirstChild("MyDataController")

if not myDataController then
	local clientUI = modules:FindFirstChild("ClientUI")
	myDataController = clientUI and clientUI:WaitForChild("MyDataController", 60)
end

if not myDataController then
	warn("[Blink.lua] MyDataController not found")
	return
end

local module = require(myDataController)
local Maid = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Maid"))
local TowerLUT = require(ReplicatedStorage.SharedUtils:WaitForChild("TowerLUT"))
local Universe = require(ReplicatedStorage.SharedUtils:WaitForChild("Universe"))
local v2 = {
	CoalMonster = 0.35
}
local isLobby = Universe:IsLobby()
local localPlayer = isClient and Players.LocalPlayer
local print2 = print

function print(...) end

local function getCharacterHeadParts(instance)
	local result = {}
	local blinkingParts = instance:FindFirstChild("BlinkingParts")
	local headPart = instance:FindFirstChild("HeadPart")

	if blinkingParts and #blinkingParts:GetChildren() > 0 then
		for _, objectValue in ipairs(blinkingParts:GetChildren()) do
			if objectValue:IsA("ObjectValue") and objectValue.Value then
				result[#result + 1] = objectValue.Value
			end
		end
	elseif headPart and headPart.Value then
		result[#result + 1] = headPart.Value
	end

	local head = #result == 0 and instance:FindFirstChild("Head")

	if head then
		result[#result + 1] = head
	end

	if #result == 0 then
		for _, child in ipairs(instance:GetChildren()) do
			if child:HasTag("Head") then
				result[#result + 1] = child
			end
		end
	end

	if #result == 0 then
	end

	return result
end

local function setHeadTexture(list, p: string, p2: string)
	for _, part in ipairs(list) do
		local decal = part:FindFirstChildWhichIsA("Decal")

		if decal then
			if not p2 or decal.Texture ~= p2 then
				decal.Texture = p
			end
		elseif part:IsA("MeshPart") and (not p2 or part.TextureID ~= p2) then
			part.TextureID = p
		end
	end
end

local function getGlowParts(folder)
	local parts = {}

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") and part:FindFirstChild("GlowFaceSA") then
			parts[#parts + 1] = part
		end
	end

	return parts
end

local function applyGlowSA(glowParts, instance, glowStrength)
	for _, parent in ipairs(glowParts) do
		for _, surfaceAppearance in ipairs(parent:GetChildren()) do
			if surfaceAppearance:IsA("SurfaceAppearance") and surfaceAppearance.Name == "GlowFaceSA" then
				surfaceAppearance:Destroy()
			end
		end

		local clone = instance:Clone()
		clone.Name = "GlowFaceSA"

		if glowStrength then
			clone.EmissiveStrength = glowStrength
		end

		clone.Parent = parent
	end
end

local function getTextureDictionary(model)
	local textures = {}
	local config = model:FindFirstChild("Config")

	if not config then
		return textures
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(p, childName)
		local child = config:FindFirstChild(childName)

		if child then
			textures[p] = child.Texture
		end
	end

	add("Normal", "NormalTexture") -- equivalent call inferred; original call site unknown
	add("Blink", "BlinkTexture") -- equivalent call inferred; original call site unknown
	add("Hurt", "HurtTexture") -- equivalent call inferred; original call site unknown
	add("Attack", "AttackTexture") -- equivalent call inferred; original call site unknown
	return textures
end

local function preloadTextures(model, config)
	local characterHeadParts = getCharacterHeadParts(model)
	local v3

	if #characterHeadParts > 0 then
		v3 = characterHeadParts[1]
	else
		v3 = false
	end

	local v4 = isLobby and { "BlinkTexture" } or { "BlinkTexture", "HurtTexture", "AttackTexture" }
	print("textures to load: ", v4, ", is lobby: ", isLobby)

	if v3 and config then
		for _, childName in ipairs(v4) do
			print(childName)
			local child = config:FindFirstChild(childName)

			if not child then
				continue
			end

			local part = Instance.new("Part")
			part.Massless = true
			part.CanCollide = false
			part.CanQuery = false
			part.Anchored = false
			part.Size = createVector(0.01, 0.01, 0.01)
			part.CFrame = model:GetPivot()
			part.Name = "PRELOAD_" .. childName
			part.Transparency = 0.99
			local motor6D = Instance.new("Motor6D")
			motor6D.Part0 = part
			motor6D.Part1 = model.PrimaryPart
			motor6D.Parent = part
			local specialMesh = Instance.new("SpecialMesh")
			specialMesh.Scale = part.Size
			specialMesh.MeshId = v3 and v3.MeshId
			specialMesh.TextureId = child.Texture
			specialMesh.Parent = part
			part.Parent = model
			print("\t", child, part)
			Debris:AddItem(part, 10)
		end
	end
end

local function AddCharacter(model)
	if not model:IsA("Model") or not model:HasTag("Blinker") or model:GetAttribute("HasBlinkerAttached") then
		return
	end

	print("Added model: ", (tostring(model)))
	local config = model:WaitForChild("Config", 99)

	if not config then
		print("NO CONFIG FOUND!")
		return
	end

	if isClient and localPlayer.Character ~= model then
		print("CLIENT MISSMATCH BLINK CHARACTER")
		return
	end

	model:SetAttribute("HasBlinkerAttached", true)
	local maid = Maid.new()
	local v3 = false
	local toonName = model:GetAttribute("ToonName")
	local currentSkin = model:GetAttribute("CurrentSkin")
	local monsterName = model:GetAttribute("MonsterName")
	local tower

	if monsterName == nil then
		tower = toonName and TowerLUT:GetTower(toonName)
	else
		tower = false
	end

	local skin

	if monsterName == nil and currentSkin ~= "Default" then
		skin = TowerLUT:GetSkin(toonName, currentSkin)
	else
		skin = false
	end

	local module2 = tower and require(tower)
	local module3 = skin and require(skin)
	preloadTextures(model, config)
	maid:GiveTask(model.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			maid:Destroy()
		end
	end))
	maid:GiveTask(model:GetAttributeChangedSignal("GlowActive"):Connect(function()
		if model:GetAttribute("GlowActive") then
			return
		end

		local glowParts = getGlowParts(model)

		for _, glowPart in ipairs(glowParts) do
			for _, surfaceAppearance in ipairs(glowPart:GetChildren()) do
				if surfaceAppearance:IsA("SurfaceAppearance") and surfaceAppearance.Name == "GlowFaceSA" then
					surfaceAppearance:Destroy()
				end
			end
		end

		if #glowParts > 0 then
			print2("[GlowFace][client] stripped local glow overlay from", #glowParts, "part(s) on", model.Name)
		end
	end))

	local function blinkSequence()
		print("BLINK!!")
		local characterHeadParts = getCharacterHeadParts(model)
		local v4 = monsterName and v2[monsterName] or 0.15

		if model:GetAttribute("GlowActive") then
			if monsterName == "GourdyMonster" then
				return
			end

			local glowFaces = model:FindFirstChild("GlowFaces")
			local glowParts = getGlowParts(model)

			if #glowParts == 0 then
				return
			end

			local glowStrength = model:GetAttribute("GlowStrength") or 30

			if model:GetAttribute("MonsterName") == "VeeMonster" then
				local glow_Blink = glowFaces and glowFaces:FindFirstChild("Glow_Blink")

				if glow_Blink then
					applyGlowSA(glowParts, glow_Blink, glowStrength)
				end
			else
				for _, glowPart in ipairs(glowParts) do
					for _, surfaceAppearance in ipairs(glowPart:GetChildren()) do
						if surfaceAppearance:IsA("SurfaceAppearance") and surfaceAppearance.Name == "GlowFaceSA" then
							surfaceAppearance:Destroy()
						end
					end
				end

				local textureDictionary = getTextureDictionary(model)
				setHeadTexture(
					getCharacterHeadParts(model),
					textureDictionary.Blink,
					textureDictionary.Hurt or textureDictionary.Attack
				)
			end

			task.wait(v4)

			if not v3 and model.Parent and model:GetAttribute("GlowActive") then
				local glowState = model:GetAttribute("GlowState") or "Normal"
				local v5 = glowFaces and (glowFaces:FindFirstChild("Glow_" .. glowState) or glowFaces:FindFirstChild("Glow_Normal"))

				if v5 then
					applyGlowSA(glowParts, v5, glowStrength)
				end
			end
		else
			if module3 and module3.BlinkSequence then
				module3.BlinkSequence(setHeadTexture, characterHeadParts)
				return
			end

			if module2 and module2.BlinkSequence then
				module2.BlinkSequence(setHeadTexture, characterHeadParts)
				return
			end

			local textureDictionary = getTextureDictionary(model)
			setHeadTexture(
				characterHeadParts,
				textureDictionary.Blink,
				textureDictionary.Hurt or textureDictionary.Attack
			)
			task.wait(v4)

			if not v3 and model.Parent then
				setHeadTexture(
					characterHeadParts,
					textureDictionary.Normal,
					textureDictionary.Hurt or textureDictionary.Attack
				)
			end
		end
	end

	local thread = task.spawn(function()
		module:onReplicaReady(function(p)
			while not v3 and model and model.Parent do
				local blinkToggle = p and p.Data.Settings and p.Data.Settings.BlinkToggle
				local effective = SettingsFlags:GetEffective(blinkToggle, "BlinkToggle")
				local v4 = model:GetAttribute("BlinkDisabled") == true or model:GetAttribute("GlowActive") == true

				if effective and not v4 then
					task.wait(3 + math.random() * 3)

					if v3 or not model.Parent then
						break
					else
						blinkSequence()
					end
				else
					task.wait(1)
				end
			end
		end)
	end)
	maid:GiveTask(function()
		v3 = true
		pcall(task.cancel, thread)
	end)
end

local function AddDandy(model)
	if not model:IsA("Model") then
		print("\tNot a model")
		return
	end

	if model:GetAttribute("HasBlinkerAttached") then
		print("\tBlinker is attached")
		return
	end

	local config = model:WaitForChild("Config", 3)

	if not config then
		print("NO CONFIG FOUND!")
		return
	end

	local maid = Maid.new()
	local v3 = false
	model:SetAttribute("HasBlinkerAttached", true)
	maid:GiveTask(model.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			maid:Destroy()
		end
	end))

	local function blinkSequence()
		print("BLINK!!")
		local characterHeadParts = getCharacterHeadParts(model)
		local textureID = characterHeadParts[1].TextureID
		local v4 = nil

		for _, decal in pairs(config:GetChildren()) do
			if not (decal:IsA("Decal") and decal.Texture == textureID) then
				continue
			end

			v4 = decal
			break
		end

		local v6 = v4.Name:sub(1, -8)
		local v7 = v6 == "Normal" and "" or v6
		local child = config:FindFirstChild(string.format("%sBlinkTexture", v7))

		if not child then
			return
		end

		setHeadTexture(characterHeadParts, child.Texture)
		task.wait(0.15)

		if not v3 and model.Parent then
			setHeadTexture(characterHeadParts, textureID)
		end
	end

	local thread = task.spawn(function()
		module:onReplicaReady(function(p)
			while not v3 and model and model.Parent do
				local blinkToggle = p and p.Data.Settings and p.Data.Settings.BlinkToggle
				local effective = SettingsFlags:GetEffective(blinkToggle, "BlinkToggle")
				local blinkDisabled = model:GetAttribute("BlinkDisabled") == true

				if effective and not blinkDisabled then
					task.wait(3 + math.random() * 3)

					if v3 or not (model.Parent and model:HasTag("Blinker")) then
						if not maid then
							break
						end

						maid:Destroy()
						break
					else
						blinkSequence()
					end
				else
					task.wait(1)
				end
			end
		end)
	end)
	maid:GiveTask(function()
		v3 = true
		model:SetAttribute("HasBlinkerAttached", nil)
		pcall(task.cancel, thread)
	end)
end

CollectionService:GetInstanceAddedSignal("Character"):Connect(AddCharacter)

for _, v3 in pairs(CollectionService:GetTagged("Character")) do
	task.spawn(AddCharacter, v3)
end

CollectionService:GetInstanceAddedSignal("Blinker"):Connect(function(instance)
	if instance:HasTag("Dandy") then
		AddDandy(instance)
	end
end)
return {}