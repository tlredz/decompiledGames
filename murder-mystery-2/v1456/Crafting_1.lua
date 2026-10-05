local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WindowService"))
local game2 = script.Parent.Parent.Game
local crafting = game2.Crafting
local salvage = game2.Salvage
local _ = game2.Inventory
local CraftModule = require(game.ReplicatedStorage.Modules.CraftModule)
local scrollFrame = crafting.Inventory.Salvage.ScrollFrame
local scrollFrame2 = crafting.Inventory.Craft.ScrollFrame
local recipe = script.Recipe
local item = script.Item
local confirm = crafting.Action.Confirm
CraftModule.SetSalvageConfirmButton(CraftModule.ShowSalvageRewards)
CraftModule.SetCraftConfirmButton(CraftModule.UpdateCraftConfirm)
CraftModule.SetCraftGUI(
	crafting,
	scrollFrame2,
	recipe,
	crafting.Action,
	scrollFrame,
	item,
	crafting.Action.Salvage,
	salvage,
	confirm
)
CraftModule.GenerateRecipes()
CraftModule.GenerateSalvageInventory(crafting.Inventory.Salvage.ScrollFrame, script.Item)
WindowService:RegisterFrame(game2:WaitForChild("Crafting"), "Crafting")
crafting.Title.Back.Activated:Connect(function()
	WindowService:Back()
end)
crafting.Action.Nav.Salvage.MouseButton1Click:connect(function()
	crafting.Inventory.Craft.Visible = false
	crafting.Inventory.Salvage.Visible = true
	crafting.Action.Craft.Visible = false
	crafting.Action.Salvage.Visible = true
	crafting.Action.Nav.Salvage.Style = Enum.ButtonStyle.RobloxRoundDefaultButton
	crafting.Action.Nav.Craft.Style = Enum.ButtonStyle.RobloxRoundButton
	CraftModule.ChangeMode("Salvage", true)
end)
crafting.Action.Nav.Craft.MouseButton1Click:connect(function()
	crafting.Inventory.Craft.Visible = true
	crafting.Inventory.Salvage.Visible = false
	crafting.Action.Craft.Visible = true
	crafting.Action.Salvage.Visible = false
	crafting.Action.Nav.Craft.Style = Enum.ButtonStyle.RobloxRoundDefaultButton
	crafting.Action.Nav.Salvage.Style = Enum.ButtonStyle.RobloxRoundButton
	CraftModule.ChangeMode("Craft", true)
end)
salvage.Claim.MouseButton1Click:connect(function()
	if salvage.Claim.Style == Enum.ButtonStyle.RobloxRoundDefaultButton then
		salvage.Visible = false
		crafting.Visible = true
	end
end)