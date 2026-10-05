local parent = script.Parent.Parent
wait(0.5)
local crafting = parent.Lobby.Screens.Inventory.Main.Crafting
local scrollFrame = crafting.Main.Salvage.ScrollFrame
local scrollFrame2 = crafting.Main.Craft.ScrollFrame
local confirm = crafting.Main.Salvage.Confirm
local salvaging = parent.Lobby.Screens.Inventory.Main.Salvaging
local confirm2 = confirm.Confirm
local recipe = script.Recipe
local item = script.Item
local CraftModule = require(game.ReplicatedStorage.Modules.CraftModule)
CraftModule.SetCraftGUI(crafting, scrollFrame2, recipe, crafting.Nav, scrollFrame, item, confirm, salvaging, confirm2)
CraftModule.GenerateRecipes()
CraftModule.GenerateSalvageInventory()
CraftModule.SetCraftConfirmButton(CraftModule.UpdateCraftConfirmMobile)
CraftModule.SetSalvageConfirmButton(CraftModule.SalvageConfirmMobile)
crafting.Nav.Salvage.MouseButton1Click:connect(function()
	crafting.Main.Craft.Visible = false
	crafting.Main.Salvage.Visible = true
	crafting.Nav.Salvage.Style = Enum.ButtonStyle.RobloxRoundDefaultButton
	crafting.Nav.Craft.Style = Enum.ButtonStyle.RobloxRoundButton
	CraftModule.ChangeMode("Salvage")
end)
crafting.Nav.Craft.MouseButton1Click:connect(function()
	crafting.Main.Craft.Visible = true
	crafting.Main.Salvage.Visible = false
	crafting.Nav.Craft.Style = Enum.ButtonStyle.RobloxRoundDefaultButton
	crafting.Nav.Salvage.Style = Enum.ButtonStyle.RobloxRoundButton
	CraftModule.ChangeMode("Craft")
end)
salvaging.Claim.MouseButton1Click:connect(function()
	if salvaging.Claim.Style == Enum.ButtonStyle.RobloxRoundDefaultButton then
		salvaging.Visible = false
		crafting.Visible = true
	end
end)