-- failed to load script (decompiled with syntax error):
-- cBhGpfmsBMDOLjXlXabmzkbsB:32: Expected identifier when parsing expression, got ';'

local game2 = script.Parent.Parent:WaitForChild("Game")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local ItemPopupService = require(ReplicatedStorage3:WaitForChild("ClientServices"):WaitForChild("ItemPopupService"))
local inventory = game2:WaitForChild("Inventory")
local dock = game2:WaitForChild("Dock")
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage4:WaitForChild("Modules"):WaitForChild("WindowService"))
local modules = game.ReplicatedStorage:WaitForChild("Modules")
local InventoryModule = require(modules:WaitForChild("InventoryModule"))
InventoryModule.GUI.MyInventory = {}
InventoryModule.GUI.MyInventory.Main = inventory.Main
InventoryModule.GUI.MyInventory.Nav = inventory.Nav
InventoryModule.GUI.NewItem = game2.NewItem
InventoryModule.GUI.EvoMenu = inventory.Main.Weapons.EvoMenu

for _, childName in pairs({
	"Weapons",
	"Effects",
	"Perks",
	"Emotes",
	"Radios",
	"Pets"
}) do
	for childName2, _ in pairs(InventoryModule.CreateBlankInventoryTable()[childName]) do
		;(inventory.Main:FindFirstChild(childName).Items.Container:FindFirstChild(childName2) or inventory.Main:FindFirstChild(childName).Items.Container:FindFirstChild("Holiday").Container:FindFirstChild(childName2)).Container:ClearAllChildren()
	end
end

InventoryModule.MyInventory = InventoryModule.GenerateInventory(inventory, ProfileData)
local container = inventory.Main.Weapons.Items.Container
container.Holiday.Container.EventLayout:GetPropertyChangedSignal("AbsoluteContentSize"):connect(function()
	container.Holiday.Container.Size = UDim2.new(
		1,
		0,
		0,
		container.Holiday.Container.EventLayout.AbsoluteContentSize.Y + 3
	)
	container.Holiday.CanvasSize = UDim2.new(1, 0, 0, container.Holiday.Container.EventLayout.AbsoluteContentSize.Y + 6)
end)
InventoryModule.ConnectNavButtons(inventory.Nav, inventory.Main)
InventoryModule.ConnectTabButtons(inventory, "Weapons")
InventoryModule.UpdateMyEquip()
InventoryModule.ConnectEquipButtons()
InventoryModule.ConnectPetNaming(inventory.Main.Pets.Equipped.Container.NameYourPet.Container2)
InventoryModule.ConnectCodeFrame(inventory.Main.Weapons.Equipped.Container.Codes)
InventoryModule.ConnectEvoMenu()
WindowService:RegisterFrame(game2:WaitForChild("Inventory"), "Inventory")
dock.Inventory.Activated:Connect(function()
	WindowService:ToggleFrame("Inventory")
end)
local searchText = inventory.Main.Weapons.Items.Tabs.Search.Container.SearchText
searchText:GetPropertyChangedSignal("Text"):Connect(function()
	local text = searchText.Text
	local v = string.gsub(text, "S", "")
	local parent = nil

	for _, weapon in pairs(InventoryModule.MyInventory.Data.Weapons) do
		for _, v2 in weapon do
			v2.Frame.Visible = string.find(string.lower(v2.Name), string.lower(v))

			if parent then
				continue
			end

			if v2.Frame.Parent.Parent:IsA("ScrollingFrame") then
				parent = v2.Frame.Parent.Parent
			else
				parent = v2.Frame.Parent.Parent.Parent.Parent
			end
		end
	end

	if parent then
		parent.CanvasPosition = Vector2.new(0, 0)
	end
end)
local processing = game2.Processing

function _G.Process(text)
	if not text then
		processing.Visible = false
		return
	end

	processing.Title.Text = text
	spawn(function()
		while processing.Visible == true do
			processing.Spinner.Rotation = processing.Spinner.Rotation + 5
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:wait()
		end
	end)
	spawn(function()
		while processing.Visible == true do
			wait(0.2)
			processing.Title.Text = processing.Title.Text .. "."
		end
	end)
	processing.Visible = true
end

remotes:WaitForChild("Inventory"):WaitForChild("ProfileDataChanged").Event:Connect(function(p, _)
	if p == "Uniques" then
		InventoryModule.UpdateInventory(inventory, InventoryModule.MyInventory)
	end
end)
remotes:WaitForChild("Inventory"):WaitForChild("InventoryDataChanged").Event:Connect(function()
	InventoryModule.UpdateInventory(inventory, InventoryModule.MyInventory)
end)
inventory.Main.Weapons.Equipped.Container.Crafting.ActionButton.Activated:Connect(function()
	WindowService:AddToStack("Crafting")
end)
inventory.Main.Radios.Equipped.Container.ViewSongs.ActionButton.Activated:Connect(function()
	WindowService:AddToStack("Radio")
end)
local radio = game.Players.LocalPlayer:GetAttribute("Radio")
game2.Inventory.Main.Radios.NoRadioCover.Visible = not radio
game.ReplicatedStorage.Remotes.Shop.GetRadio.OnClientEvent:connect(function()
	game2.Inventory.Main.Radios.NoRadioCover.Visible = false
end)
game2.Inventory.Main.Radios.NoRadioCover.Buy.MouseButton1Click:connect(function()
	game.ReplicatedStorage.Remotes.Shop.GetRadio:FireServer()
end)
ItemPopupService.AnimationTargetLocation = game2:WaitForChild("Dock"):WaitForChild("Inventory")