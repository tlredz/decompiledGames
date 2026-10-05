local ReplicatedStorage = game:GetService("ReplicatedStorage")
local House = require(ReplicatedStorage.Modules.Neighbors.House)
local FeatureFlags = require(ReplicatedStorage.Modules.FeatureFlags)

-- equivalent calls inferred from this helper; original call sites unknown
local function pivotPrefab(prefab, cframe: CFrame)
	if prefab.Model:GetPivot():FuzzyEq(cframe) then
		return
	end

	prefab.Model:PivotTo(cframe)
end

local folder = Instance.new("Folder", game.ReplicatedStorage)
folder.Name = "StuffFromHouses"

local function updatePrefab()
	local currentHouse = House:GetCurrentHouse()
	local currentPrefab = House:GetCurrentPrefab()
	local isEnabled = FeatureFlags:IsEnabled("FFlagParentInactivePrefabs")

	for _, prefab in next, House.Prefabs, nil do
		local v = currentHouse and currentPrefab and prefab.Model == currentPrefab.Model and true or false
		local v2

		if v and currentHouse then
			v2 = currentHouse.Model:GetPivot()
		else
			v2 = prefab.Model:GetAttribute("DefaultCFrame")
		end

		pivotPrefab(prefab, v2) -- equivalent call inferred; original call site unknown

		if isEnabled then
			prefab:SetEnabled(v)
		else
			prefab:SetEnabled(true)
		end
	end

	for _, child in pairs(folder:GetChildren()) do
		local origin = child:GetAttribute("Origin")

		if origin and origin ~= game.Players.LocalPlayer:GetAttribute("CurrentInternalMap") then
			child.Parent = game.Workspace.Places:FindFirstChild(origin):FindFirstChild("Server")
		end
	end

	if currentHouse then
		local server = currentHouse.Model:FindFirstChild("Server")

		if server and server:FindFirstChild("FakeWindows") then
			local fakeWindows = server.FakeWindows
			fakeWindows.Parent = folder
			fakeWindows:SetAttribute("Origin", currentHouse.Name)
		end
	end
end

House.ActiveHouseChanged:Connect(updatePrefab)
House.ActiveSkinChanged:Connect(updatePrefab)
House.HouseAdded:Connect(updatePrefab)
updatePrefab()