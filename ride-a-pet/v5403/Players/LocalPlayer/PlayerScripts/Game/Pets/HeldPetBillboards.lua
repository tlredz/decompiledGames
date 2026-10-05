local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local gameServices = ReplicatedStorage:WaitForChild("GameServices")
require(gameServices:WaitForChild("PetRigService"))
local PetAging = require(gameServices:WaitForChild("PetAging"))
local StringService = require(gameServices:WaitForChild("StringService"))
local Pets = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Pets"))
local Mutations = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Mutations"))
local billboards = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Billboards")
local petSpeed = billboards:WaitForChild("PetSpeed")
local petCash = billboards:WaitForChild("PetCash")
local rarityGradients = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("RarityGradients")
local v = {
	Mythic = "Mythical",
	Mythical = "Mythic"
}

local function ApplyRarityGradient(parent, rarity)
	for _, uIGradient in parent:GetChildren() do
		if uIGradient:IsA("UIGradient") then
			uIGradient:Destroy()
		end
	end

	if not rarity then
		return
	end

	local v2 = rarityGradients:FindFirstChild(rarity) or rarityGradients:FindFirstChild(v[rarity] or "")

	if v2 then
		local clone = v2:Clone()
		clone.Parent = parent
	else
		warn(string.format("HeldPetBillboards: no gradient asset for rarity %q", (tostring(rarity))))
	end
end

local v2 = {}

local function LocalExtentsY(folder)
	local cFrame = folder.PrimaryPart.CFrame
	local v3 = nil
	local v4 = nil

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.Transparency < 1) then
			continue
		end

		local objectSpace = cFrame:ToObjectSpace(part.CFrame)
		local size = part.Size
		local v5 = 0.5 * (math.abs(objectSpace.XVector.Y) * size.X + math.abs(objectSpace.YVector.Y) * size.Y + math.abs(objectSpace.ZVector.Y) * size.Z)
		local v6 = objectSpace.Position.Y - v5
		local v7 = objectSpace.Position.Y + v5

		if not v3 or v6 < v3 then
			v3 = v6
		end

		if not v4 or v4 < v7 then
			v4 = v7
		end
	end

	return v3 or 0, v4 or 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Pin(speed, parent, p, p2, pin, p3)
	if p then
		speed.Size = p.Size

		if speed.MaxDistance ~= 1e999 then
			speed.MaxDistance = p.MaxDistance
		end
	end

	local v3 = pin[p3]

	if not v3 then
		local v4, v5 = LocalExtentsY(parent)

		if p2 >= 0 then
			v4 = v5 or v4
		end

		v3 = v4 + p2
		pin[p3] = v3
	end

	speed.StudsOffset = Vector3.new(0, v3, 0)
end

local function IsPetRig(model)
	local isA = model:IsA("Model")

	if isA then
		if model.PrimaryPart == nil or model:GetAttribute("PetName") == nil then
			isA = false
		else
			isA = model:GetAttribute("PetKey") ~= nil
		end
	end

	return isA
end

local function IsRidden(parent)
	local ridden = parent:GetAttribute("Ridden")

	if typeof(ridden) == "boolean" then
		return ridden
	end

	local assemblyRootPart = parent.PrimaryPart and parent.PrimaryPart.AssemblyRootPart

	if not assemblyRootPart then
		return false
	end

	local petMountJoint = assemblyRootPart:FindFirstChild("PetMountJoint")
	local v3

	if petMountJoint == nil then
		return false
	else
		v3 = petMountJoint:IsA("Motor6D")

		if v3 then
			if petMountJoint.Part1 == nil then
				return false
			else
				return (petMountJoint.Part1:IsDescendantOf(parent))
			end
		end
	end

	return v3
end

local PetRideModes = require(ReplicatedStorage.GameServices:WaitForChild("PetRideModes"))

local function StatsFor(parent)
	local weight = tonumber(parent:GetAttribute("Weight")) or PetAging.WeightStandardKG
	local pet = Pets[parent:GetAttribute("PetName") or ""]
	local combinedFactor = Mutations.CombinedFactor(
		parent:GetAttribute("Mutation"),
		parent:GetAttribute("SpawnMutation")
	)
	local data = parent:FindFirstChild("Data")

	if data then
		data:FindFirstChild("Speed")
	end

	local baseSpeed = PetRideModes.BaseSpeed(parent)
	return
		math.floor((PetAging.DisplaySpeedFor(baseSpeed, weight, combinedFactor))),
		(math.floor(math.floor((pet and tonumber(pet.Income) or 0) * (weight / PetAging.WeightStandardKG)) * combinedFactor))
end

local function Clear(p)
	local v3 = v2[p]

	if not v3 then
		return
	end

	v2[p] = nil

	for _, connection in v3.Connections or {} do
		connection:Disconnect()
	end

	if v3.Speed then
		v3.Speed:Destroy()
	end

	if v3.Cash then
		v3.Cash:Destroy()
	end
end

local function Refresh(model)
	if not (model.Parent and model.PrimaryPart) then
		Clear(model)
		return
	end

	local v3 = v2[model]

	if not v3 then
		v3 = {
			Pin = {},
			Connections = {}
		}
		v2[model] = v3
	end

	local v4, v5 = StatsFor(model)
	local ridden = IsRidden(model)

	if not v3.Speed then
		v3.Speed = petSpeed:Clone()
		v3.Speed.Adornee = model.PrimaryPart
		v3.Speed.Parent = model
		local pet = Pets[model:GetAttribute("PetName") or ""]
		ApplyRarityGradient(v3.Speed.Speed, pet and pet.Rarity)
	end

	v3.Speed.Speed.Text = PetAging.FormatSpeed(v4)
	Pin(v3.Speed, model, petSpeed, ridden and -2 or 3, v3.Pin, ridden and "SpeedRide" or "SpeedCarry") -- equivalent call inferred; original call site unknown

	if ridden then
		local size = petSpeed.Size
		v3.Speed.Size = UDim2.new(size.X.Scale * 0.65, size.X.Offset * 0.65, size.Y.Scale * 0.65, size.Y.Offset * 0.65)
	end

	if ridden then
		if v3.Cash then
			v3.Cash:Destroy()
			v3.Cash = nil
		end
	else
		if not v3.Cash then
			v3.Cash = petCash:Clone()
			v3.Cash.Adornee = model.PrimaryPart
			v3.Cash.Parent = model
			local pet = Pets[model:GetAttribute("PetName") or ""]
			ApplyRarityGradient(v3.Cash.Income, pet and pet.Rarity)
		end

		local cashEarned = v3.Cash:FindFirstChild("CashEarned")

		if cashEarned then
			cashEarned.Visible = false
		end

		v3.Cash.Income.Text = StringService.FormatCurrency(v5) .. "/s"
		local cash = v3.Cash
		local v10 = petCash
		local pin2 = v3.Pin

		if v10 then
			cash.Size = v10.Size

			if cash.MaxDistance ~= 1e999 then
				cash.MaxDistance = v10.MaxDistance
			end
		end

		local cash2 = pin2.Cash

		if not cash2 then
			local v11, _ = LocalExtentsY(model)
			cash2 = v11 + -0.5
			pin2.Cash = cash2
		end

		cash.StudsOffset = Vector3.new(0, cash2, 0)
	end
end

local gameObjects = workspace:WaitForChild("GameObjects")

local function WaitUntilPetRig(model)
	local isA = model:IsA("Model")

	if isA then
		if model.PrimaryPart == nil or model:GetAttribute("PetName") == nil then
			isA = false
		else
			isA = model:GetAttribute("PetKey") ~= nil
		end
	end

	if isA then
		return true
	end

	local v3 = os.clock() + 10

	while model.Parent == gameObjects and os.clock() < v3 do
		task.wait()
		local isA2 = model:IsA("Model")

		if isA2 then
			if model.PrimaryPart == nil or model:GetAttribute("PetName") == nil then
				isA2 = false
			else
				isA2 = model:GetAttribute("PetKey") ~= nil
			end
		end

		if isA2 then
			return true
		end
	end

	local isA2 = model:IsA("Model")

	if isA2 then
		if model.PrimaryPart == nil or model:GetAttribute("PetName") == nil then
			isA2 = false
		else
			isA2 = model:GetAttribute("PetKey") ~= nil
		end
	end

	return isA2
end

local function Watch(model)
	if not (model:IsA("Model") and WaitUntilPetRig(model) and model.Parent == gameObjects) then
		return
	end

	Refresh(model)
	local v3 = v2[model]

	if not v3 then
		return
	end

	for _, v4 in {
		"Ridden",
		"RideMode",
		"PredictedRideMode",
		"Mutation",
		"SpawnMutation"
	} do
		table.insert(v3.Connections, model:GetAttributeChangedSignal(v4):Connect(function()
			Refresh(model)
		end))
	end

	for _, v4 in { "Weight", "Age" } do
		table.insert(v3.Connections, model:GetAttributeChangedSignal(v4):Connect(function()
			table.clear(v3.Pin)
			Refresh(model)
		end))
	end

	v3.Connections[#v3.Connections + 1] = model.Destroying:Connect(function()
		Clear(model)
	end)
end

for _, child in gameObjects:GetChildren() do
	task.spawn(Watch, child)
end

gameObjects.ChildAdded:Connect(function(child)
	task.spawn(Watch, child)
end)
gameObjects.ChildRemoved:Connect(Clear)