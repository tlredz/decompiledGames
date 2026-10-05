local ReplicatedStorage = game:GetService("ReplicatedStorage")
local clientServices = ReplicatedStorage:WaitForChild("ClientServices")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage2:WaitForChild("Remotes")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage3:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage4:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage5:WaitForChild("Modules"):WaitForChild("WindowService"))
require(clientServices:WaitForChild("ItemService"))
local InventoryService = require(clientServices:WaitForChild("InventoryService"))
local CraftingService = require(clientServices:WaitForChild("CraftingService"))
local ReplicatedStorage6 = game:GetService("ReplicatedStorage")
local RecipeService = require(ReplicatedStorage6:WaitForChild("SharedServices"):WaitForChild("RecipeService"))
local crafting2 = script.Parent:WaitForChild("Game"):WaitForChild("Crafting2")
local results = crafting2:WaitForChild("Contents"):WaitForChild("Results")
local input = results:WaitForChild("Input")
local output = results:WaitForChild("Output")
local itemList = crafting2:WaitForChild("Contents"):WaitForChild("Inventory"):WaitForChild("ItemList")
local inventoryInfo = InventoryService:GenerateInventoryInfo("Weapons", CraftingService:GetSalvageInventory(), itemList)
local inventoryInfo2 = InventoryService:GenerateInventoryInfo(
	"Materials",
	CraftingService:GenerateMaterialInventory(),
	itemList
)

local function InitializeSalvageItems()
	InventoryService:ForEachFrame(inventoryInfo, function(p: string, p2)
		p2.Container.ActionButton.Activated:Connect(function()
			CraftingService:SelectItemForCrafting(input, output, "Weapons", p)
		end)
	end)
	InventoryService:ForEachFrame(inventoryInfo2, function(p: string, p2)
		p2.Container.ActionButton.Activated:Connect(function()
			CraftingService:SelectItemForCrafting(input, output, "Materials", p)
		end)
	end)
	results:WaitForChild("Input"):WaitForChild("SingleContainer"):WaitForChild("Button").Activated:Connect(function()
		CraftingService:ClearCrafting(input, results.Output)
	end)
	remotes:WaitForChild("Inventory"):WaitForChild("InventoryDataChanged").Event:Connect(function(_: string, p: string, p2: number)
		if not (inventoryInfo.Frames[p] and RecipeService:IsItemSalvageable(p)) then
			return
		end

		InventoryService:ApplyChangesToInventoryInfo(inventoryInfo, p, p2)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Initialize()
	WindowService:RegisterFrame(crafting2, "Crafting")
	InitializeSalvageItems()
end

Initialize() -- equivalent call inferred; original call site unknown