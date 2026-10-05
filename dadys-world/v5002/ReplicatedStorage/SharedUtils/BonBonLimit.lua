local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BonBonLimit = {
	TAG = "PlacedBonBons",
	PLACED_ATTRIBUTE = "Placed",
	MAX = 10
}

function BonBonLimit.GetPlaced()
	local result = {}

	for _, v in ipairs(CollectionService:GetTagged(BonBonLimit.TAG)) do
		if v:IsDescendantOf(workspace) then
			table.insert(result, v)
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createRemovalEffect(cFrame)
	pcall(function()
		local currentRoom = workspace:FindFirstChild("CurrentRoom")
		local currentRoomModel = currentRoom and currentRoom:FindFirstChildOfClass("Model")

		if not currentRoomModel then
			return
		end

		local clone = ReplicatedStorage.Parts.ItemDrop:Clone()
		clone.CFrame = cFrame
		clone.Anchored = true
		clone.Size *= 0.7
		clone.Parent = currentRoomModel

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(20)
			end
		end

		Debris:AddItem(clone, 2)
	end)
end

function BonBonLimit.MakeRoom()
	local placed = BonBonLimit.GetPlaced()

	while #placed >= BonBonLimit.MAX do
		local v = 1e999
		local v2 = nil

		for i, v3 in ipairs(placed) do
			local attribute = v3:GetAttribute(BonBonLimit.PLACED_ATTRIBUTE) or 0

			if not (attribute < v) then
				continue
			end

			v2 = i
			v = attribute
		end

		if not v2 then
			break
		end

		local v3 = table.remove(placed, v2)
		local cFrame = v3.PrimaryPart and v3.PrimaryPart.CFrame
		CollectionService:RemoveTag(v3, BonBonLimit.TAG)
		v3:Destroy()

		if not cFrame then
			continue
		end

		createRemovalEffect(cFrame) -- equivalent call inferred; original call site unknown
	end
end

function BonBonLimit.Register(instance)
	instance:SetAttribute(BonBonLimit.PLACED_ATTRIBUTE, workspace.DistributedGameTime)
	CollectionService:AddTag(instance, BonBonLimit.TAG)
end

return BonBonLimit