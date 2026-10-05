local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Replion = require(packages.Replion)
local v = false

-- equivalent calls inferred from this helper; original call sites unknown
local function applyToDescendant(descendant, flag: boolean)
	if descendant:IsA("BasePart") then
		descendant.Transparency = flag and 0 or 1
		descendant.CanCollide = flag
	elseif descendant:IsA("ProximityPrompt") then
		descendant.Enabled = flag
	elseif descendant:IsA("BillboardGui") then
		descendant.Enabled = flag
	end
end

local function applyToModel(folder)
	local v2 = v

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = v2 and 0 or 1
			descendant.CanCollide = v2
		elseif descendant:IsA("ProximityPrompt") then
			descendant.Enabled = v2
		elseif descendant:IsA("BillboardGui") then
			descendant.Enabled = v2
		end
	end

	folder.DescendantAdded:Connect(function(descendant)
		applyToDescendant(descendant, v) -- equivalent call inferred; original call site unknown
	end)
end

local function applyAll()
	for _, model in ipairs(CollectionService:GetTagged("SplitBranchTwig")) do
		if model:IsA("Model") then
			applyToModel(model)
		end
	end
end

return {
	Start = function(_)
		v = false
		applyAll()
		CollectionService:GetInstanceAddedSignal("SplitBranchTwig"):Connect(function(model)
			if model:IsA("Model") then
				applyToModel(model)
			end
		end)
		local v2 = Replion.Client:WaitReplion("EverturnSplitbranchTwig")
		v = v2:Get("Unlocked") == true
		applyAll()
		v2:OnDataChange(function()
			v = v2:Get("Unlocked") == true
			applyAll()
		end)
	end
}