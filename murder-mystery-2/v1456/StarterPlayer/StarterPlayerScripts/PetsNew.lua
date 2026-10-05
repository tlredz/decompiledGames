task.wait(0.2)
CFrame.new(3, 0, 3)
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
require(script.DecalChroma)
require(script.FireChroma)
local Workspace = game:GetService("Workspace")
local petContainer = Workspace:WaitForChild("PetContainer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local pets = ReplicatedStorage:WaitForChild("Pets")
local v = {}

local function weldPet(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = folder
		weldConstraint.Part1 = part
		weldConstraint.Parent = part
		part.CanCollide = false
		part.CanQuery = false
		part.Anchored = true
	end
end

local function onPetAdded(p)
	local humanoidRootPart = p.Parent:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local clone = pets:WaitForChild(p.Value):Clone()
	weldPet(clone)
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.Anchored = false
	clone.Parent = petContainer
	clone.CFrame = humanoidRootPart.CFrame
	v[p] = clone
end

local function onPetRemoved(p)
	if v[p] then
		v[p]:Destroy()
	end

	v[p] = nil
end

local function onUpdate(p: number)
	for k, v2 in v do
		local humanoidRootPart = k.Parent:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			continue
		end

		local v3 = humanoidRootPart.Position - v2.Position

		if v3.Magnitude > 50 then
			v2.CFrame = humanoidRootPart.CFrame
		end

		local unit = Vector3.new(v3.Z, 0, v3.X).Unit
		local v4 = humanoidRootPart.Position + unit * 3
		v2.CFrame = v2.CFrame:Lerp(CFrame.new(v4), p)
	end
end

CollectionService:GetInstanceAddedSignal("PetValue"):Connect(onPetAdded)
CollectionService:GetInstanceRemovedSignal("PetValue"):Connect(onPetRemoved)
RunService.PreSimulation:Connect(onUpdate)
local RunService2 = game:GetService("RunService")
RunService2.Heartbeat:Connect(function() end)