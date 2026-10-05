local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(script.Parent.Parent.Parent.OrchestratorState)
local v = {}

local function GetOutfitsFolder()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local concert = assets and assets:FindFirstChild("Concert")
	local outfits = concert and concert:FindFirstChild("Outfits")

	if outfits and outfits:IsA("Folder") then
		return outfits
	end

	return nil
end

local function GetOutfitNames()
	local names = {}
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local concert = assets and assets:FindFirstChild("Concert")
	local outfits = concert and concert:FindFirstChild("Outfits")

	if not (outfits and outfits:IsA("Folder")) then
		outfits = nil
	end

	if outfits then
		for _, child in outfits:GetChildren() do
			table.insert(names, child.Name)
		end
	end

	table.sort(names)
	return names
end

local function IsOutfitItem(child)
	return child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") or child:IsA("BodyColors")
end

local function ClearOutfitItems(character)
	for _, child in character:GetChildren() do
		if IsOutfitItem(child) then
			child:Destroy()
		end
	end
end

local function DressCharacter(humanoid, character, items)
	for _, item in items do
		local clone = item:Clone()

		if clone:IsA("Accessory") then
			if not pcall(humanoid.AddAccessory, humanoid, clone) then
				clone.Parent = character
			end
		else
			clone.Parent = character
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CleanupRecord(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	v[p] = nil
	local ancestryConnection = v2.AncestryConnection

	if ancestryConnection then
		ancestryConnection:Disconnect()
		v2.AncestryConnection = nil
	end
end

local function GetRecord(target)
	local v2 = v[target]

	if v2 then
		return v2
	end

	local parent = target.Parent
	assert(parent and parent:IsA("Model"), "HumanoidOutfit requires the Humanoid to be parented to a Model.")
	v2 = {
		Humanoid = target,
		Character = parent,
		OriginalItems = nil,
		AppliedOutfit = nil,
		AncestryConnection = nil
	}
	v[target] = v2
	v2.AncestryConnection = target.AncestryChanged:Connect(function(_, parent2)
		if parent2 == nil then
			CleanupRecord(target) -- equivalent call inferred; original call site unknown
		end
	end)
	return v2
end

local function CaptureOriginalItems(player)
	if player.OriginalItems then
		return
	end

	local clones = {}

	for _, child in player.Character:GetChildren() do
		if IsOutfitItem(child) then
			table.insert(clones, child:Clone())
		end
	end

	player.OriginalItems = clones
end

local function ApplyOutfit(player, outfitName: string)
	if player.AppliedOutfit == outfitName then
		return
	end

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local concert = assets and assets:FindFirstChild("Concert")
	local outfits = concert and concert:FindFirstChild("Outfits")

	if not (outfits and outfits:IsA("Folder")) then
		outfits = nil
	end

	assert(outfits, "The bbnomulaConcertOutfits folder was not found in ReplicatedStorage.Assets.")
	local child = outfits:FindFirstChild(outfitName)
	assert(child, (`Outfit "{outfitName}" was not found in bbnomulaConcertOutfits.`))
	CaptureOriginalItems(player)
	ClearOutfitItems(player.Character)
	local children = {}

	for _, child2 in child:GetChildren() do
		if IsOutfitItem(child2) then
			table.insert(children, child2)
		end
	end

	DressCharacter(player.Humanoid, player.Character, children)
	player.AppliedOutfit = outfitName
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RestoreOriginalOutfit(player)
	local originalItems = player.OriginalItems

	if not originalItems then
		return
	end

	ClearOutfitItems(player.Character)
	DressCharacter(player.Humanoid, player.Character, originalItems)
	player.OriginalItems = nil
	player.AppliedOutfit = nil
end

local function FindActiveCommand(keyframes, timePosition: number)
	local count = #keyframes
	local v2 = 1
	local v3 = nil

	while v2 <= count do
		local v4 = math.floor((v2 + count) / 2)

		if keyframes[v4].Time <= timePosition then
			v2 = v4 + 1
			v3 = v4
		else
			count = v4 - 1
		end
	end

	if v3 then
		return keyframes[v3]
	end

	return nil
end

local options = GetOutfitNames()
local HumanoidOutfit = {}
HumanoidOutfit.Type = "HumanoidOutfit"
HumanoidOutfit.DisplayName = "Outfit"
HumanoidOutfit.HasKeyframeEasing = false
HumanoidOutfit.EditableProperties = {
	{
		Path = { "Value", "Mode" },
		DisplayName = "Mode",
		ValueType = "enum",
		Default = "RESTORE",
		Options = { "APPLY", "RESTORE" }
	},
	{
		Path = { "Value", "OutfitName" },
		DisplayName = "Outfit",
		ValueType = "enum",
		Default = options[1],
		Options = options
	}
}

function HumanoidOutfit.Supports(humanoid)
	local isA = humanoid:IsA("Humanoid")

	if isA then
		if humanoid.Parent == nil then
			isA = false
		else
			isA = humanoid.Parent:IsA("Model")
		end
	end

	return isA
end

function HumanoidOutfit.ValidateKeyframe(p)
	local value = p.Value

	if type(value) ~= "table" then
		return false, "HumanoidOutfit keyframes must contain a command table."
	end

	if value.Mode == "RESTORE" then
		return true, nil
	end

	if value.Mode ~= "APPLY" then
		return false, "HumanoidOutfit Mode must be APPLY or RESTORE."
	end

	if type(value.OutfitName) == "string" and value.OutfitName ~= "" then
		return true, nil
	end

	return false, "HumanoidOutfit needs an outfit name to apply."
end

function HumanoidOutfit.Capture(_)
	return {
		Mode = "RESTORE"
	}
end

function HumanoidOutfit.Evaluate(data)
	if RunService:IsRunning() and not data.IsServer then
		return
	end

	local record = GetRecord(data.Target)
	local activeCommand = FindActiveCommand(data.Strip.Keyframes, data.TimePosition)

	if activeCommand then
		local value = activeCommand.Value

		if value.Mode ~= "RESTORE" then
			local outfitName = value.OutfitName
			local v5

			if type(outfitName) == "string" then
				v5 = outfitName ~= ""
			else
				v5 = false
			end

			assert(v5, "HumanoidOutfit has an invalid outfit name.")
			ApplyOutfit(record, outfitName)
			return
		end
	end

	RestoreOriginalOutfit(record) -- equivalent call inferred; original call site unknown
end

function HumanoidOutfit.OnStop(p)
	local target = p.Target
	local v3 = v[target]

	if v3 then
		RestoreOriginalOutfit(v3) -- equivalent call inferred; original call site unknown
		CleanupRecord(target) -- equivalent call inferred; original call site unknown
	end
end

return HumanoidOutfit