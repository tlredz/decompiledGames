local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local pets = ServerStorage.ReplicatedAssets.Pets
local PetVisualUtil = {
	BOB_TAG = "bob",
	PET_MODEL_NAME = "Pet",
	PET_ANCHOR_WELD_NAME = "PetAnchorWeld",
	PET_WELD_NAME = "PetWeld"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getPetTemplate(petId)
	return pets:FindFirstChild(petId) or pets:FindFirstChild("Book")
end

local function preparePetModel(folder)
	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
	end
end

function PetVisualUtil.create(parent, part, petId, p, C0, p2)
	local petTemplate = getPetTemplate(petId) -- equivalent call inferred; original call site unknown

	if not petTemplate then
		return
	end

	local clone = petTemplate:Clone()
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart", true) or clone.PrimaryPart

	if not humanoidRootPart then
		clone:Destroy()
		return
	end

	preparePetModel(clone)
	clone.Name = PetVisualUtil.PET_MODEL_NAME
	clone:SetAttribute("PetId", petId)
	clone.PrimaryPart = humanoidRootPart
	local part2 = Instance.new("Part")
	part2.Name = tostring(p)
	part2.Size = createVector(1, 1, 1)
	part2.Transparency = 1
	part2.CanCollide = false
	part2.CanTouch = false
	part2.CanQuery = false
	part2.Massless = true
	part2.Anchored = false
	part2.CFrame = part.CFrame * C0
	part2.Parent = parent
	CollectionService:AddTag(part2, PetVisualUtil.BOB_TAG)
	local weld = Instance.new("Weld")
	weld.Name = PetVisualUtil.PET_ANCHOR_WELD_NAME
	weld.Part0 = part
	weld.Part1 = part2
	weld.C0 = C0
	weld.Parent = part2
	clone.Parent = part2
	humanoidRootPart.CFrame = part2.CFrame

	if p2 == false then
		humanoidRootPart:SetNetworkOwner(nil)
	elseif p2 then
		humanoidRootPart:SetNetworkOwner(p2)
	end

	local weld2 = Instance.new("Weld")
	weld2.Name = PetVisualUtil.PET_WELD_NAME
	weld2.Part0 = part2
	weld2.Part1 = humanoidRootPart
	weld2.C0 = CFrame.new()
	weld2.Parent = part2
	part2:SetAttribute("BaseCF", weld2.C0)
	return part2, clone, humanoidRootPart, weld2
end

return PetVisualUtil