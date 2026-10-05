local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local modules = ReplicatedStorage.shared.modules
local questProps = require(modules.library.questProps)
local questProps2 = ReplicatedStorage.resources.replicated.questProps
local remoteEvent = Net:RemoteEvent("QuestProps/Sync")
local remoteEvent2 = Net:RemoteEvent("QuestProps/Interact")
local remoteEvent3 = Net:RemoteEvent("QuestProps/Claimed")
local v = nil
local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getContainer()
	if v and v.Parent then
		return v
	end

	local folder = Instance.new("Folder")
	folder.Name = "LocalQuestProps"
	folder.Parent = workspace
	v = folder
	return folder
end

local function attachPrompt(data, propId: string, primaryPart)
	if not primaryPart:IsA("BasePart") then
		if primaryPart:IsA("Model") then
			primaryPart = primaryPart.PrimaryPart or primaryPart:FindFirstChildWhichIsA("BasePart", true)
		else
			primaryPart = nil
		end
	end

	if not primaryPart then
		return
	end

	local override = questProps.GetOverride(data, propId)
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Name = "QuestPropPrompt"
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.ActionText = override and override.ActionText or data.ActionText
	proximityPrompt.ObjectText = override and override.ObjectText or data.ObjectText
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.MaxActivationDistance = 10
	proximityPrompt.Parent = primaryPart
	proximityPrompt.Triggered:Connect(function()
		proximityPrompt.Enabled = false
		remoteEvent2:FireServer(data.Id, propId)
		task.delay(1, function()
			if proximityPrompt.Parent then
				proximityPrompt.Enabled = true
			end
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearSet(p: string)
	local v4 = v2[p]

	if v4 then
		v4:Destroy()
		v2[p] = nil
	end

	v3[p] = nil
end

local function renderSet(data, claimed)
	clearSet(data.Id) -- equivalent call inferred; original call site unknown
	local child = questProps2:FindFirstChild(data.TemplateFolder)

	if not child then
		warn((`[QuestProps] Missing template folder "{data.TemplateFolder}"`))
		return
	end

	local v4 = Trove.new()
	v2[data.Id] = v4
	v3[data.Id] = {}
	local folder = Instance.new("Folder")
	folder.Name = data.Id
	local container = getContainer() -- equivalent call inferred; original call site unknown
	folder.Parent = container
	v4:Add(folder)

	for _, v5 in CollectionService:GetTagged(data.Tag) do
		if not v5:IsDescendantOf(child) then
			continue
		end

		local propId = v5:GetAttribute("PropId")

		if typeof(propId) ~= "string" or claimed[propId] then
			continue
		end

		local clone = v5:Clone()
		CollectionService:RemoveTag(clone, data.Tag)

		if clone:IsA("BasePart") then
			clone.Anchored = true
		end

		for _, part in clone:GetDescendants() do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end

		clone.Parent = folder
		v3[data.Id][propId] = clone
		attachPrompt(data, propId, clone)
	end
end

local function onSync(items)
	for k in v2 do
		if items[k] then
			continue
		end

		clearSet(k) -- equivalent call inferred; original call site unknown
	end

	for k, item in items do
		local v4 = questProps.Get(k)

		if v4 then
			renderSet(v4, item.Claimed or {})
		end
	end
end

local function onClaimed(p: string, p2: string)
	local v4 = v3[p] and v3[p][p2]

	if v4 then
		v4:Destroy()
		v3[p][p2] = nil
	end
end

return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(onSync)
		remoteEvent3.OnClientEvent:Connect(onClaimed)
		remoteEvent:FireServer()
	end
}