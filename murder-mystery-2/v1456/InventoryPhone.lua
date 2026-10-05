-- failed to load script (decompiled with syntax error):
-- cBhGpeAvqLzsZTVjXPcrWLtMV:32: Expected identifier when parsing expression, got ';'

local parent = script.Parent.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage2:WaitForChild("Remotes")
local lobby = parent:WaitForChild("Lobby")
local screens = lobby:WaitForChild("Screens")
parent:WaitForChild("Game")
local inventory = screens.Inventory
local _ = lobby.Dock
local modules = game.ReplicatedStorage.Modules
local InventoryModule = require(modules.InventoryModule)
InventoryModule.GUI.MyInventory = {}
InventoryModule.GUI.MyInventory.Main = inventory.Main
InventoryModule.GUI.MyInventory.Nav = inventory.Nav
InventoryModule.GUI.NewItem = parent.NewItem
InventoryModule.GUI.EvoMenu = inventory.Main.Weapons.EvoMenu
InventoryModule.GUI.ItemGridLayout = modules.InventoryModule.Phone.PhoneGridLayout

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
InventoryModule.ConnectCodeFrame(inventory.Nav.Main.Codes)
InventoryModule.ConnectEvoMenu()
local searchText = inventory.Main.Weapons.TitleBar.Container.Search.Container.SearchText
searchText:GetPropertyChangedSignal("Text"):connect(function()
	local text = searchText.Text
	local v = string.gsub(text, "S", "")

	for _, weapon in pairs(InventoryModule.MyInventory.Data.Weapons) do
		for _, v2 in pairs(weapon) do
			v2.Frame.Visible = string.find(string.lower(v2.Name), string.lower(v))

			if v2.Frame.Parent.Parent:IsA("ScrollingFrame") then
				v2.Frame.Parent.Parent.CanvasPosition = Vector2.new(0, 0)
			else
				v2.Frame.Parent.Parent.Parent.Parent.CanvasPosition = Vector2.new(0, 0)
			end
		end
	end
end)
local processing = screens.Processing

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
local radio = game.Players.LocalPlayer:GetAttribute("Radio")
inventory.Main.Radios.NoRadioCover.Visible = not radio
game.ReplicatedStorage.Remotes.Shop.GetRadio.OnClientEvent:connect(function()
	inventory.Main.Radios.NoRadioCover.Visible = false
end)
inventory.Main.Radios.NoRadioCover.Buy.MouseButton1Click:connect(function()
	game.ReplicatedStorage.Remotes.Shop.GetRadio:FireServer()
end)
game:GetService("TweenService")
TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

local function PlayTweens(items)
	for _, item in pairs(items) do
		item:Play()
	end
end

game.Players.LocalPlayer:GetAttribute("Elite")
_G.CoinBagFull = false