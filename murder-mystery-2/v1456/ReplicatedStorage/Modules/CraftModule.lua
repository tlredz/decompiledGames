local CraftModule = {}
local _ = {
	Classic = 1,
	Common = 2,
	Uncommon = 3,
	Rare = 4,
	Legendary = 5,
	Godly = 6,
	Victim = 7,
	Unique = 7,
	Christmas = 1.5,
	Halloween = 1.6,
	Ancient = 6.5
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("ProfileData"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local ItemPopupService = require(ReplicatedStorage3:WaitForChild("ClientServices"):WaitForChild("ItemPopupService"))
local rarity = Sync.Rarity
local GridCreator = require(game.ReplicatedStorage.Modules.GridCreator)
CraftModule.GUI = nil
CraftModule.Mode = "Craft"
local codes = Sync.Codes
local v = {}
local v2 = nil
local v3 = nil
local mouseButton1ClickConnection = nil

for _, code in pairs(codes) do
	v[code.Prize] = true
end

function CraftModule.SetCraftGUI(GUI, recipesFrame, newRecipeFrame, actionNav, salvageInventoryFrame, newItemFrame, salvageConfirmFrame, salvageGUI, salvageConfirmButton)
	CraftModule.GUI = GUI
	CraftModule.RecipesFrame = recipesFrame
	CraftModule.NewRecipeFrame = newRecipeFrame
	CraftModule.ActionNav = actionNav
	CraftModule.SalvageInventoryFrame = salvageInventoryFrame
	CraftModule.NewItemFrame = newItemFrame
	CraftModule.SalvageConfirmFrame = salvageConfirmFrame
	CraftModule.SalvageGUI = salvageGUI
	CraftModule.SalvageConfirmButton = salvageConfirmButton
	v2 = nil
	v3 = nil
	mouseButton1ClickConnection = CraftModule.SalvageConfirmButton.MouseButton1Click:connect(CraftModule.ActionConfirmButtonFunction)
end

function CraftModule.CraftConfirm() end

function CraftModule.SalvageConfirm() end

function CraftModule.SetCraftConfirmButton(craftConfirm)
	CraftModule.CraftConfirm = craftConfirm
end

function CraftModule.SetSalvageConfirmButton(salvageConfirm)
	CraftModule.SalvageConfirm = salvageConfirm
end

function CraftModule.ChangeMode(mode, p)
	CraftModule.Mode = mode

	if p then
		CraftModule.ActionNav.Confirm.Style = mode == "Salvage" and (v2 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton) or v3 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
	end
end

function CraftModule.CheckHasRecipe(p)
	local count = 0
	local count2 = 0
	local count3 = 0
	local result = {}

	if Sync.Recipes[p].CombinationRecipe then
		local flag = false

		for k, recipe in pairs(Sync.Recipes) do
			if recipe.CombinedRecipe ~= p then
				continue
			end

			local v4, _ = CraftModule.CheckHasRecipe(k)

			if v4 then
				return true, true
			end

			if flag then
				flag = true
			end
		end

		return false, flag
	else
		for k, material in pairs(Sync.Recipes[p].Materials) do
			count3 += 1

			if not (ProfileData.Materials.Owned[k] and ProfileData.Materials.Owned[k] > 0) then
				continue
			end

			count += 1
			result[k] = "Has"

			if not (material <= ProfileData.Materials.Owned[k]) then
				continue
			end

			count2 += 1
			result[k] = "Completed"
		end

		local v4 = count3 <= count2
		local v5 = count > 0
		local v6

		if count > 0 then
			v6 = not (count3 <= count2)
		else
			v6 = false
		end

		return v4, v5, v6, result
	end
end

function CraftModule.GetRecipes()
	local v4 = {}

	for k, recipe in pairs(Sync.Recipes) do
		if not recipe.CombinedRecipe then
			continue
		end

		if v4[recipe.CombinedRecipe] then
			v4[recipe.CombinedRecipe][k] = recipe
		else
			v4[recipe.CombinedRecipe] = {
				[k] = recipe
			}
		end
	end

	local result = {}

	for k, recipe in pairs(Sync.Recipes) do
		if not recipe.CombinedRecipe then
			table.insert(result, {
				ID = k,
				Data = recipe
			})
		end
	end

	for k, v5 in pairs(v4) do
		for k2, v7 in pairs(result) do
			if v7.ID ~= k then
				continue
			end

			local recipeList = {}

			for k3, v9 in pairs(v5) do
				table.insert(recipeList, {
					ID = k3,
					Data = v9
				})
			end

			table.sort(recipeList, function(a, b)
				return a.ID < b.ID
			end)
			result[k2].Data.RecipeList = recipeList
			break
		end
	end

	table.sort(result, function(a, b)
		local _, _, _ = CraftModule.CheckHasRecipe(a.ID)
		local _, _, _ = CraftModule.CheckHasRecipe(b.ID)
		return a.Data.SortPriority > b.Data.SortPriority
	end)
	return result
end

function CraftModule.MakeMaterialFrame(p, p2, instance, list, p3)
	instance.Visible = true
	local instanceContainer = instance:FindFirstChild("Container") or instance
	instanceContainer.Icon.Image = p2.Image

	if p3 then
		local _, _, _, v4 = CraftModule.CheckHasRecipe(p3)
		local v5 = ProfileData.Materials.Owned[p] and ProfileData.Materials.Owned[p] > 0
		instanceContainer.Amount.Text = v5 and ProfileData.Materials.Owned[p] .. "/" .. list or "x" .. list
		instanceContainer.BorderColor3 = v4[p] == "Completed" and Color3.new(0, 140, 0) or v4[p] == "Has" and Color3.new(
			1,
			1,
			0
		) or Color3.new(0, 0, 0)
		instanceContainer.BorderSizePixel = v4[p] and 2 or 0
	elseif tonumber(list) then
		instanceContainer.Amount.Text = "x" .. list
	else
		instanceContainer.Amount.Text = list[1] ~= list[2] and list[1] .. "-" .. list[2] or list[1]
	end
end

function CraftModule.MakeMaterialFrames(p, p2, p3)
	local recipe = Sync.Recipes[p]
	local v4 = 1

	for k, material in pairs(recipe.Materials) do
		local v5 = p2["Material" .. v4]
		local material2 = Sync.Materials[k]
		CraftModule.MakeMaterialFrame(k, material2, v5, material, p3 and p or nil)
		v4 += 1
	end
end

function CraftModule.ActionConfirmButtonFunction()
	print("pressed")
	local v4

	if CraftModule.Mode == "Craft" then
		v4 = v3
	else
		v4 = v2
	end

	print(v4, v3, v2, CraftModule.Mode)

	if v4 then
		CraftModule[CraftModule.Mode](v4)
	end
end

function CraftModule.UpdateCraftConfirm(p, _, p2)
	local action = CraftModule.GUI.Action
	local craft = action.Craft

	if p and not p2 then
		local recipe = Sync.Recipes[p]
		CraftModule.CheckHasRecipe(p)
		CraftModule.MakeMaterialFrames(p, craft.Recipe)
		local v4 = {
			ItemID = recipe.RewardItem or recipe
		}
		GridCreator.MakeItemFrame(craft.Reward.Container, v4)
		action.Confirm.Style = Enum.ButtonStyle.RobloxRoundDefaultButton
		v3 = p
	else
		for _, child in pairs(craft.Recipe:GetChildren()) do
			child.Container.Icon.Image = ""
			child.Container.Amount.Text = ""
		end

		craft.Reward.Container.Icon.Image = ""
		craft.Reward.Container.Amount.Text = ""
		craft.Reward.Container.ItemName.Text = ""
		action.Confirm.Style = Enum.ButtonStyle.RobloxRoundButton
		v3 = nil
	end
end

function CraftModule.UpdateCraftConfirmMobile(_, p, visible)
	if visible == nil then
		visible = not p.Result.Confirm.Visible
	end

	if visible == true then
		for _, child in pairs(CraftModule.RecipesFrame.Container:GetChildren()) do
			if child ~= p then
				CraftModule.UpdateCraftConfirmMobile(nil, child, false)
			end
		end
	end

	if p then
		p.Result.Confirm.Visible = visible
		p.Result.Container.Craft.Text = visible and "Cancel" or "Craft"
		p.Result.Container.Craft.TextColor3 = visible and Color3.new(1, 1, 1) or Color3.fromRGB(159, 255, 130)
	end
end

function CraftModule.CheckSalvageable(p)
	if not p then
		return false
	end

	local v4 = Sync.SalvageRewards[p] or Sync.SalvageRewards[Sync.Item[p].Rarity]
	local rewards = v4 and v4.Rewards
	local v5 = not v[p]

	if not v5 then
		return v5 and rewards or false
	end

	if (Sync.Item[p].Event == nil or Sync.SalvageRewards[p] ~= nil) and Sync.Item[p].Season == nil then
		if Sync.Item[p].ItemType == "Misc" then
			v5 = false
		else
			v5 = rewards
		end
	else
		v5 = false
	end

	return v5 and rewards or false
end

function CraftModule.ShowSalvageRewards(itemID)
	local v4 = CraftModule.CheckSalvageable(itemID)
	GridCreator.MakeItemFrame(CraftModule.SalvageConfirmFrame, {
		ItemID = itemID
	})
	CraftModule.SalvageConfirmFrame.Icon.ItemName.TextColor3 = v4 and rarity[Sync.Item[itemID].Rarity] or Color3.new(
		0.5,
		0.5,
		0.5
	)
	CraftModule.SalvageConfirmFrame.Icon.ImageColor3 = v4 and Color3.new(1, 1, 1) or Color3.new(0.2, 0.2, 0.2)
	local rewards = CraftModule.SalvageConfirmFrame:FindFirstChild("Rewards") or CraftModule.SalvageConfirmFrame

	for _, child in pairs(rewards:GetChildren()) do
		child.Visible = false
	end

	print((tostring(v4)))

	if v4 then
		v2 = itemID
		local v5 = 1

		for k, v6 in pairs(v4) do
			local reward = rewards["Material" .. v5]
			CraftModule.MakeMaterialFrame(k, Sync.Materials[k], reward, v6.Amount)
			v5 += 1
		end

		print((tostring(v2)))
	else
		v2 = nil
	end

	CraftModule.SalvageConfirmButton.Style = v2 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
end

function CraftModule.SalvageConfirmMobile(p, p2)
	local visible = not p2.Cancel.Visible

	for _, child in pairs(CraftModule.SalvageInventoryFrame.Container:GetChildren()) do
		child.Container.Cancel.Visible = false
		child.Container.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
	end

	p2.Cancel.Visible = visible
	p2.BackgroundColor3 = visible and Color3.fromRGB(130, 130, 130) or Color3.fromRGB(54, 54, 54)

	if visible then
		CraftModule.ShowSalvageRewards(p)
	else
		CraftModule.ShowSalvageRewards(nil)
	end

	CraftModule.SalvageConfirmFrame.Visible = visible
end

function CraftModule.MakeSalvageItemFrame(p, p2)
	GridCreator.MakeItemFrame(p, p2)
	local itemID = p2.ItemID
	local v4 = CraftModule.CheckSalvageable(itemID)
	p.Container.Cover.Visible = not v4

	if p.Container:FindFirstChild("Cancel") then
		p.Container.Cancel.MouseButton1Click:connect(function()
			p.Container.Cancel.Visible = false
			p.Container.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
			CraftModule.SalvageConfirmFrame.Visible = false
		end)
	end

	p.Container.Button.MouseButton1Click:connect(function()
		CraftModule.SalvageConfirm(itemID, p.Container)
	end)
end

function CraftModule.CreateRecipeFrame(data, p, _)
	local data2 = p.Data
	local ID = p.ID
	local _ = Sync.Materials

	if not data2.CombinationRecipe then
		data.RecipeName.Text = data2.Name
		data.RecipeName.TextColor3 = rarity[data2.Rarity]
		data.Result.Container.Icon.Image = data2.Image
		CraftModule.MakeMaterialFrames(ID, data.Materials, true)
		local v4, v5, _ = CraftModule.CheckHasRecipe(ID)

		if v4 then
			data.Complete.Visible = true
			data.Result.Container.Craft.Visible = true
			data.Result.Container.Craft.MouseButton1Click:connect(function()
				CraftModule.CraftConfirm(ID, data)
			end)
		elseif v5 then
			data.InProgress.Visible = true
		end

		if data.Result:FindFirstChild("Confirm") then
			data.Result.Confirm.MouseButton1Click:connect(function()
				CraftModule.Craft(ID, true)
			end)
		end

		data.Missing.Visible = not v5
	end
end

function CraftModule.GenerateSalvageInventory()
	GridCreator.CreateGrid(
		CraftModule.MakeSalvageItemFrame,
		CraftModule.NewItemFrame,
		GridCreator.GetSortedInventory(),
		CraftModule.SalvageInventoryFrame
	)
end

function CraftModule.GenerateRecipes()
	GridCreator.CreateList(
		CraftModule.CreateRecipeFrame,
		CraftModule.NewRecipeFrame,
		CraftModule.GetRecipes(),
		CraftModule.RecipesFrame
	)
end

game.ReplicatedStorage.Remotes.Inventory.InventoryDataChanged.Event:Connect(function(p, _, _)
	if p == "Weapons" then
		CraftModule.GenerateSalvageInventory()
	end
end)
game.ReplicatedStorage.Remotes.Inventory.UpdateSalvageClient.Event:connect(function() end)

function CraftModule.Salvage()
	local salvageGUI = CraftModule.SalvageGUI
	salvageGUI.Claim.Style = Enum.ButtonStyle.RobloxRoundButton
	salvageGUI.Claim.Text = "Salvaging..."
	CraftModule.GUI.Visible = false
	_G.Process("Salvaging")
	local v4 = time()
	local v5 = game.ReplicatedStorage.Remotes.Inventory.Salvage:InvokeServer(v2)
	local v6 = v2
	v2 = nil
	CraftModule.ShowSalvageRewards(nil)
	CraftModule.GenerateSalvageInventory()
	CraftModule.GenerateRecipes()
	local container = salvageGUI.Main.Item1.Container
	local container2 = salvageGUI.Main.Item2.Container
	local container3 = salvageGUI.Main.Item3.Container
	container.Icon.Image = ""
	container.ItemName.Text = ""
	container2.Icon.Image = ""
	container2.ItemName.Text = ""
	container3.Icon.Image = ""
	container3.ItemName.Text = ""
	wait(0.75 - (time() - v4))

	if v5 then
		_G.Process(nil)
		container.Icon.Image = GridCreator.GetImage(Sync.Item[v6].Image)
		container.ItemName.Text = Sync.Item[v6].ItemName
		container.ItemName.TextColor3 = rarity[Sync.Item[v6].Rarity]
		salvageGUI.Visible = true
		wait(0.5)
		container.Slider:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2)
		container2.Slider:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2)
		container3.Slider:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.2)
		wait(0.5)

		for k, v7 in pairs(v5) do
			local container4 = salvageGUI.Main["Item" .. k].Container
			container4.Icon.Image = Sync.Materials[v7.ID].Image
			container4.ItemName.Text = Sync.Materials[v7.ID].Name .. " [x" .. v7.Amount .. "]"
			container4.ItemName.TextColor3 = rarity[Sync.Materials[v7.ID].Rarity]
		end

		container.Slider:TweenPosition(UDim2.new(0, 0, -1, 0), "Out", "Quad", 0.2)
		container2.Slider:TweenPosition(UDim2.new(0, 0, -1, 0), "Out", "Quad", 0.2)
		container3.Slider:TweenPosition(UDim2.new(0, 0, -1, 0), "Out", "Quad", 0.2)
		wait(0.4)
		salvageGUI.Claim.Style = Enum.ButtonStyle.RobloxRoundDefaultButton
		salvageGUI.Claim.Text = "Claim!"
	end
end

function CraftModule.Craft(p, _)
	CraftModule.GUI.Visible = false
	_G.Process("Crafting")
	local v4 = time()
	local v5, v6, v7 = game.ReplicatedStorage.Remotes.Inventory.Craft:InvokeServer(p)
	CraftModule.GenerateRecipes()

	if not CraftModule.CheckHasRecipe(p) then
		CraftModule.CraftConfirm(nil, nil, true)
	end

	wait(0.75 - (time() - v4))
	_G.Process(nil)
	CraftModule.GUI.Visible = true

	if _G.ViewLobbyFrame ~= nil then
		_G.ViewLobbyFrame("Inventory")
	end

	if v5 then
		ItemPopupService:AddNewItem(v5, v7, v6)
	end

	game.ReplicatedStorage.Remotes.Inventory.UpdateSalvageClient:Fire()
end

return CraftModule