local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Network = require(ReplicatedStorage.Modules.Network)
local localPlayer = Players.LocalPlayer
local houseInteractables = ReplicatedStorage.Modules.HouseInteractables
require(houseInteractables.BaseInteractable)
local folder = Instance.new("Folder", game.ReplicatedStorage)
folder.Name = "InternalMapData"
local cframe = CFrame.new(0, 500000, 0)
local prefabs = ReplicatedStorage:WaitForChild("Prefabs")
local cFramesByBase = {}
local v = {}

for i, child in prefabs:GetChildren() do
	child:PivotTo(cframe * CFrame.new(i * 1000, 0, 0))
	child:SetAttribute("PrefabCFrame", child:GetPivot())
	child:SetAttribute("Enabled", false)
end

prefabs.Parent = workspace

-- equivalent calls inferred from this helper; original call sites unknown
local function PhysicsDoorAdded(instance)
	task.spawn(function()
		cFramesByBase[instance:WaitForChild("Base")] = instance.Base.CFrame
	end)
end

for _, v2 in CollectionService:GetTagged("PhysicsDoor") do
	local v3 = v2
	task.spawn(function()
		cFramesByBase[v3:WaitForChild("Base")] = v3.Base.CFrame
	end)
end

CollectionService:GetInstanceAddedSignal("PhysicsDoor"):Connect(function(instance)
	PhysicsDoorAdded(instance) -- equivalent call inferred; original call site unknown
end)
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function get_current_map()
	return localPlayer:GetAttribute("CurrentInternalMap")
end

local function GetCurrentSkin()
	local v3 = get_current_map() -- equivalent call inferred; original call site unknown
	local child = workspace.Places:FindFirstChild(v3)

	if child then
		return child:GetAttribute("SkinName")
	end

	return "Default"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCurrentPrefab()
	local v3 = get_current_map() -- equivalent call inferred; original call site unknown
	local child = workspace.Places:FindFirstChild(v3)
	return (prefabs:FindFirstChild((`{not child and "Default" or child:GetAttribute("SkinName")}Prefab`)))
end

local function HouseInteractableAdded(instance)
	local interactableType = instance:GetAttribute("InteractableType")

	if not interactableType then
		return
	end

	if houseInteractables:FindFirstChild(interactableType) then
		local success, result = pcall(function()
			local child = houseInteractables:FindFirstChild(interactableType)
			local module = require(child)
			local v3 = module(instance)
			v3.StateChanged.Event:Connect(function(flag: boolean)
				Network:fire("UpdateState", instance.Name, flag)
			end)
			v2[instance.Name] = v3
		end)

		if not success then
			warn(`Interactable: {interactableType}({instance.Name}) failed`, result)
		end
	else
		warn((`Interactable: {interactableType}({instance.Name}) does not have a module yet.`))
	end
end

for _, v3 in CollectionService:GetTagged("HouseInteractable") do
	HouseInteractableAdded(v3)
end

CollectionService:GetInstanceAddedSignal("HouseInteractable"):Connect(function(p)
	task.wait()
	HouseInteractableAdded(p)
end)

local function safe_pivot(instance, cframe2)
	if not instance:GetPivot().Position:FuzzyEq(cframe2.Position, 0.1) then
		instance:PivotTo(cframe2)
	end
end

local function update_place_display(p, _)
	local _ = v[p]
end

local function register_place(parent)
	local folder2 = Instance.new("Folder", folder)
	folder2.Name = parent.Name
	v[parent] = {
		Active = parent:GetAttribute("PlaceDefaultCFrame") or parent:GetPivot(),
		Inactive = parent:GetPivot() + createVector(0, 35000, 0)
	}

	local function update()
		if localPlayer:GetAttribute("CurrentInternalMap") == parent.Name then
			local _ = v[parent]

			for _, child in folder2:GetChildren() do
				child.Parent = parent
			end
		else
			if parent:FindFirstChild("Interior") then
				parent.Interior.Parent = folder2
			end

			local _ = v[parent]
		end
	end

	localPlayer:GetAttributeChangedSignal("CurrentInternalMap"):Connect(function()
		return update()
	end)
	update()
end

local attributeChangedConnection = nil
localPlayer:GetAttributeChangedSignal("CurrentInternalMap"):Connect(function()
	local v3 = get_current_map() -- equivalent call inferred; original call site unknown

	if v3 then
		task.wait(0.1)
		local currentPrefab = GetCurrentPrefab() -- equivalent call inferred; original call site unknown
		local place = workspace.Places[v3]
		local v5 = v[place]

		for _, child in prefabs:GetChildren() do
			child:SetAttribute("Enabled", child == currentPrefab)
		end

		currentPrefab:PivotTo(v5.Active)
		local houseStates = place.HouseStates

		for _, child in workspace.Places:GetChildren() do
			local fakeLights = child.Structure:FindFirstChild("FakeLights")
			local magnitude = math.floor((child:GetPivot().Position - place:GetPivot().Position).Magnitude)

			if not fakeLights then
				continue
			end

			for _, part in fakeLights:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				for _, light in part:GetChildren() do
					if light:IsA("Light") then
						light.Enabled = child ~= place and magnitude <= 381
					end
				end
			end
		end

		for k, v6 in houseStates:GetAttributes() do
			if v2[k] then
				v2[k]:SetState(v6, true)
			end
		end

		if attributeChangedConnection then
			attributeChangedConnection:Disconnect()
			attributeChangedConnection = nil
		end

		attributeChangedConnection = houseStates.AttributeChanged:Connect(function(attributeName)
			if not v2[attributeName] then
				return
			end

			local attribute = houseStates:GetAttribute(attributeName)

			if v2[attributeName].State == attribute then
				return
			end

			v2[attributeName]:SetState(attribute, true)
		end)
	else
		for _, child in prefabs:GetChildren() do
			if child:GetPivot() ~= child:GetAttribute("PrefabCFrame") then
				child:PivotTo(child:GetAttribute("PrefabCFrame"))
			end
		end

		for k, cFrame in cFramesByBase do
			k.CFrame = cFrame
		end

		if attributeChangedConnection then
			attributeChangedConnection:Disconnect()
			attributeChangedConnection = nil
		end

		for _, child in workspace.Places:GetChildren() do
			local fakeLights = child.Structure:FindFirstChild("FakeLights")

			if not fakeLights then
				continue
			end

			for _, part in fakeLights:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				for _, light in part:GetChildren() do
					if light:IsA("Light") then
						light.Enabled = true
					end
				end
			end
		end
	end
end)
workspace.Places.ChildAdded:Connect(function(child)
	task.wait()
	return register_place(child)
end)

for _, child in workspace.Places:GetChildren() do
	register_place(child)
end