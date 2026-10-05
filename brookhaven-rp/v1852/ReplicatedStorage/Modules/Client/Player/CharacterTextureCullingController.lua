local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local PlayerSession = require(GameSdkShared.Modules.PlayerSession)
local FreeCamController = require(ReplicatedStorage.Modules.Client.PlayerController.FreeCamController)
local v = {
	MeshPart = "TextureID",
	SpecialMesh = "TextureId",
	Decal = "ColorMap",
	Texture = "ColorMap"
}
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local v2 = {}
local v3 = 400
local v4 = v3 * v3
local v5 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function stripTexture(descendant)
	local v6 = v[descendant.ClassName]

	if not (v6 ~= nil and descendant[v6] ~= "") then
		return
	end

	if descendant:GetAttribute("_SavedTextureID") == nil then
		descendant:SetAttribute("_SavedTextureID", descendant[v6])
	end

	descendant[v6] = ""
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreTexture(_SavedTextureIDs)
	local _SavedTextureID = _SavedTextureIDs:GetAttribute("_SavedTextureID")

	if _SavedTextureID == nil then
		return
	end

	local v6 = v[_SavedTextureIDs.ClassName]

	if v6 == nil then
		return
	end

	_SavedTextureIDs[v6] = _SavedTextureID
	_SavedTextureIDs:SetAttribute("_SavedTextureID", nil)
end

local function stripTextures(p, folder)
	for _, descendant in folder:GetDescendants() do
		stripTexture(descendant) -- equivalent call inferred; original call site unknown
	end

	p.janitor:Add(folder.DescendantAdded:Connect(stripTexture), "Disconnect", "HiddenDescendantAdded")
	p.isHidden = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreTextures(p, folder)
	p.janitor:Remove("HiddenDescendantAdded")

	for _, descendant in folder:GetDescendants() do
		restoreTexture(descendant) -- equivalent call inferred; original call site unknown
	end

	p.isHidden = false
end

local function update()
	if FreeCamController.IsFreecamEnabled() or currentCamera.FieldOfView <= 30 then
		if not v5 then
			for k, v6 in v2 do
				if not v6.isHidden then
					continue
				end

				restoreTextures(v6, k) -- equivalent call inferred; original call site unknown
			end
		end

		v5 = true
	else
		v5 = false
		local position = currentCamera.CFrame.Position

		for k, v6 in v2 do
			local rootPart = v6.rootPart

			if rootPart == nil then
				continue
			end

			local v7 = (position.X - rootPart.Position.X) ^ 2 + (position.Y - rootPart.Position.Y) ^ 2 + (position.Z - rootPart.Position.Z) ^ 2
			local v8 = v4 < v7

			if v8 and not v6.isHidden then
				stripTextures(v6, k)
			elseif not v8 and v6.isHidden then
				restoreTextures(v6, k) -- equivalent call inferred; original call site unknown
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onCharacterRemoving(p)
	local v6 = v2[p]

	if v6 == nil then
		return
	end

	if v6.isHidden then
		stripTextures(v6, p)
	end

	v6.janitor:Destroy()
	v2[p] = nil
end

local function onCharacterAdded(character)
	if v2[character] ~= nil then
		return
	end

	local v6 = {
		janitor = Janitor.new(),
		rootPart = character:WaitForChild("HumanoidRootPart", 10),
		isHidden = false
	}

	if v6.rootPart == nil then
		warn("CharacterTextureDistanceController: Failed to find root part for character", character:GetFullName())
		return
	end

	v2[character] = v6
	v6.janitor:Add(character.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			onCharacterRemoving(character) -- equivalent call inferred; original call site unknown
		end
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onPlayerAdded(player)
	if player == localPlayer then
		return
	end

	player.CharacterAdded:Connect(onCharacterAdded)
	player.CharacterRemoving:Connect(onCharacterRemoving)

	if player.Character ~= nil then
		onCharacterAdded(player.Character)
	end
end

return {
	FrameworkStart = function()
		local v6, v7 = ABTest.GetExperimentVariables("tech-character-texture-culling"):timeout(10):await()

		if not v6 or v7 == nil or not v7.enabled then
			return
		end

		v3 = v7[(PlayerSession.GetPlatform() == "Mobile" or PlayerSession.GetPlatform() == "Tablet") and "mobile-radius-studs" or "radius-studs"] or v3
		v4 = v3 * v3
		print("CharacterTextureCullingController: Enabled with radius of " .. tostring(v3) .. " studs")
		Players.PlayerAdded:Connect(onPlayerAdded)

		for _, v8 in Players:GetPlayers() do
			onPlayerAdded(v8) -- equivalent call inferred; original call site unknown
		end

		local total = 0
		RunService.Heartbeat:Connect(function(dt: number)
			total += dt

			if total < 0.3333333333333333 then
				return
			end

			total = 0
			update()
		end)
	end
}