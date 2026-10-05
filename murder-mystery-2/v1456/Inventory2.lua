script:WaitForChild("EquipContainer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local clientServices = ReplicatedStorage:WaitForChild("ClientServices")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage2:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage3:WaitForChild("Modules"):WaitForChild("WindowService"))
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage4:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
ReplicatedStorage5:WaitForChild("Remotes")
local ItemService = require(clientServices:WaitForChild("ItemService"))
local InventoryService = require(clientServices:WaitForChild("InventoryService"))
local EquipService = require(clientServices:WaitForChild("EquipService"))
local v = {
	"Effects",
	"Perks",
	"Radios",
	"Pets"
}
local game2 = script.Parent:WaitForChild("Game")
local dock = game2:WaitForChild("Dock")
local inventory2 = game2:WaitForChild("Inventory2")
local main = inventory2:WaitForChild("Main")
local nav = inventory2:WaitForChild("Nav")
local tabs = main:WaitForChild("Weapons"):WaitForChild("Items"):WaitForChild("Tabs")
local container = main:WaitForChild("Weapons"):WaitForChild("Equipped"):WaitForChild("Container")
local itemList = main:WaitForChild("Weapons"):WaitForChild("Items"):WaitForChild("ItemList")
local v2 = {
	Weapons = {},
	Effects = {},
	Perks = {},
	Emotes = {},
	Radios = {},
	Pets = {}
}
local equipContainersByChildName = {}
local _ = {
	"Knife",
	"Gun",
	"Effects",
	"Perks",
	"Radios",
	"Pets"
}

local function SwitchWeaponTab(classFilter)
	v2.Weapons.Filters.ClassFilter = classFilter
	InventoryService:UpdateFilter(v2.Weapons)

	for _, child in tabs:GetChildren() do
		if not (child.Name ~= "Search" and child.Name ~= "UIListLayout") then
			continue
		end

		local visible = child.Name == classFilter
		child.ViewBorder.Visible = visible
		child.BackgroundTransparency = visible and 0.8 or 0.9
	end
end

local function SwitchInventoryTab(p)
	for _, button in nav:GetChildren() do
		if button:IsA("TextButton") then
			button.Style = button.Name == p and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
		end
	end

	for _, child in main:GetChildren() do
		child.Visible = child.Name == p
	end
end

local function onInventoryChanged(p: string, p2: string, p3: number)
	local v3 = v2[p]

	if p3 == nil or not (p3 > 0) then
		InventoryService:RemoveItem(v3, p2)
	else
		v3.Frames[p2].Frame.Container.Amount.Text = ItemService:GetAmountText(p3)
	end
end

local function InitializeWeapons()
	v2.Weapons = InventoryService:GenerateInventoryInfo("Weapons", ProfileData.Weapons.Owned)
	v2.Weapons.Filters.ClassFilter = "Current"
	InventoryService:UpdateFilter(v2.Weapons)
	itemList.NewItem:Destroy()

	for k, frame in v2.Weapons.Frames do
		local _ = Sync.Weapons[k]
		local v3 = k
		frame.Frame.Container.ActionButton.Activated:Connect(function()
			EquipService:EquipItem("Weapons", v3)
		end)
		frame.Frame.Parent = itemList
	end

	local searchText = tabs:WaitForChild("Search"):WaitForChild("Container"):WaitForChild("SearchText")
	InventoryService:ConnectSearchBox(v2.Weapons, searchText)
	tabs:WaitForChild("Current"):WaitForChild("View").Activated:Connect(function()
		SwitchWeaponTab("Current")
	end)
	tabs:WaitForChild("Classic"):WaitForChild("View").Activated:Connect(function()
		SwitchWeaponTab("Classic")
	end)
	tabs:WaitForChild("Event"):WaitForChild("View").Activated:Connect(function()
		SwitchWeaponTab("Event")
	end)
end

local function InitializeEquipContainers()
	equipContainersByChildName.Knife = EquipService:CreateEquipContainer("Knife")
	equipContainersByChildName.Gun = EquipService:CreateEquipContainer("Gun")
	equipContainersByChildName.Knife.Parent = container
	equipContainersByChildName.Gun.Parent = container

	for _, childName in v do
		local container2 = main:WaitForChild(childName):WaitForChild("Equipped"):WaitForChild("Container")
		local equipContainer = EquipService:CreateEquipContainer(childName)
		equipContainersByChildName[childName] = equipContainer
		equipContainer.Parent = container2
	end

	for k, v3 in equipContainersByChildName do
		EquipService:BindEquipContainer(k, v3)
	end
end

local function Initialize()
	InitializeWeapons()
	InitializeEquipContainers()

	for _, v3 in v do
		v2[v3] = InventoryService:GenerateInventoryInfo(v3, ProfileData[v3].Owned)

		for k, frame in v2[v3].Frames do
			local _ = Sync[v3][k]
			local v4 = v3
			local v5 = k
			frame.Frame.Container.ActionButton.Activated:Connect(function()
				EquipService:EquipItem(v4, v5)
			end)
			local v6 = v3 == "Toys" and "Emotes" or v3
			frame.Frame.Parent = main[v6].Items.ItemList
		end

		if v3 == "Perks" then
			continue
		end

		local v4 = v3
		equipContainersByChildName[v3]:WaitForChild("Button").Activated:Connect(function()
			EquipService:UnequipItem(v4)
		end)
	end

	v2.Emotes = InventoryService:GenerateInventoryInfo("Emotes", ProfileData.Emotes.Owned)

	for _, frame in v2.Emotes.Frames do
		frame.Frame.Parent = main.Emotes.Items.ItemList
	end

	for _, button in inventory2:WaitForChild("Nav"):GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local v3 = button
		button.Activated:Connect(function()
			SwitchInventoryTab(v3.Name)
		end)
	end

	SwitchInventoryTab("Weapons")
	WindowService:RegisterFrame(inventory2, "Inventory")
	dock:WaitForChild("Inventory").Activated:Connect(function()
		WindowService:ToggleFrame("Inventory")
	end)
	container:WaitForChild("Crafting"):WaitForChild("ActionButton").Activated:Connect(function()
		WindowService:AddToStack("Crafting")
	end)
	main:WaitForChild("Radios"):WaitForChild("Equipped"):WaitForChild("Container"):WaitForChild("ViewSongs"):WaitForChild("ActionButton").Activated:Connect(function()
		WindowService:AddToStack("Radio")
	end)

	for _, v3 in v2 do
		InventoryService:AutoUpdate(v3)
	end
end

Initialize()