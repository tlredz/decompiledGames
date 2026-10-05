local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("GamepadService")
game:GetService("GuiService")
local TopRightClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}
local v2 = true
local clones = {}
Client.Events.RevertSupporting:Connect(function()
	localPlayer:WaitForChild("Supporting"):SetAttribute("PlayerName", nil)
end)
local v3 = 1
local v4 = {
	Steak = "rbxassetid://96601885412457",
	Ribs = "rbxassetid://88419070643504",
	Any = "rbxassetid://99739042628672",
	Pumpkin = "rbxassetid://111676606177768",
	Jellyfish = "rbxassetid://104370139321013",
	Fish = "rbxassetid://115347458273278",
	Carrot = "rbxassetid://129489145525698",
	Cake = "rbxassetid://122777093335571"
}

function RenderRecipeBook()
	local recipeList = Client.Interface.RecipeList
	local recipes = {}

	for k, recipe in pairs(Client.Databases.Recipes) do
		if k == "Types" then
			continue
		end

		recipe.Name = k
		table.insert(recipes, recipe)
	end

	table.sort(recipes, function(a, b)
		return a.Priority < b.Priority
	end)
	local v5 = math.ceil(#recipes / 4)

	local function changeDisplaying(p)
		local count = 0

		for i = (p - 1) * 4 + 1, (p - 1) * 4 + 4 do
			count += 1

			if recipes[i] then
				if recipeList:FindFirstChild("Frame" .. count) then
					local child = recipeList:FindFirstChild("Frame" .. count)

					if not child then
						break
					end

					child.TitleText.Text = recipes[i].Name
					child.Description.Text = recipes[i].Description or " "

					if recipes[i].ChefLevel and recipes[i].ChefLevel > (localPlayer:GetAttribute("ClassLevel") or 1) then
						child.LevelWarning.TextLabel.Text = "REQUIRES LEVEL " .. recipes[i].ChefLevel
						child.LevelWarning.Visible = true
					else
						child.LevelWarning.Visible = false
					end

					for i2 = 1, 3 do
						local child2 = child.RecipeHolder:FindFirstChild("Item" .. i2)
						child2.TextLabel.Text = recipes[i].Ingredients[i2]
						child2.Image = v4[recipes[i].Ingredients[i2]]
					end

					child.Visible = true
				end
			else
				local child = recipeList:FindFirstChild("Frame" .. count)

				if child then
					child.Visible = false
				end
			end
		end

		recipeList.LeftButton.Visible = v3 ~= 1
		recipeList.RightButton.Visible = v3 ~= v5
	end

	changeDisplaying(v3)
	recipeList.LeftButton.Activated:Connect(function()
		Client.Sound.Play("PageTurn", {
			Duplicate = true
		})
		v3 = math.clamp(v3 - 1, 1, v5)
		changeDisplaying(v3)
	end)
	recipeList.RightButton.Activated:Connect(function()
		Client.Sound.Play("PageTurn", {
			Duplicate = true
		})
		v3 = math.clamp(v3 + 1, 1, v5)
		changeDisplaying(v3)
	end)
end

function RefreshSupportList(p)
	local playerHolder = Client.Interface.SupportList.PlayerHolder

	for _, v5 in pairs(clones) do
		v5:Destroy()
	end

	for _, v5 in pairs(game.Players:GetPlayers()) do
		if v5 == localPlayer then
			continue
		end

		local clone = playerHolder.Template:Clone()
		clone.TextLabel.Text = v5.DisplayName
		clone.Name = v5.Name
		local userId = v5.UserId
		local headShot = Enum.ThumbnailType.HeadShot
		local size420x = Enum.ThumbnailSize.Size420x420
		task.spawn(function()
			local userThumbnailAsync, v10 = Players:GetUserThumbnailAsync(userId, headShot, size420x)

			if userThumbnailAsync then
				clone.FaceImage.Image = userThumbnailAsync
			end
		end)

		if p and p == v5.UserId then
			clone.ImageButton.TextLabel.Visible = true
		else
			clone.ImageButton.TextLabel.Visible = false
		end

		local v10 = v5
		clone.ImageButton.MouseButton1Down:Connect(function()
			if localPlayer:GetAttribute("SupportingPlayer") == v10.UserId then
				localPlayer:SetAttribute("SupportingPlayer", nil)
				Client.Events.SupportingChanged:FireServer()
				Client.Sound.Play("Scribble")
			else
				if not v2 then
					Client.PopUpUI.AddPopUp("can only change once per minute", "warning")
					return
				end

				Client.Sound.Play("Scribble")
				localPlayer:SetAttribute("SupportingPlayer", v10.UserId)
				Client.Events.SupportingChanged:FireServer(v10)
				v2 = false
				task.spawn(function()
					wait(60)
					v2 = true
				end)
			end
		end)
		table.insert(clones, clone)
		clone.Visible = true
		clone.Parent = playerHolder
	end
end

local clones2 = {}

function RefreshPeltList()
	for _, v5 in pairs(clones2) do
		v5:Destroy()
	end

	local peltHolder = Client.Interface.PeltList.PeltHolder
	local peltList = localPlayer:WaitForChild("PeltList", 15)

	for _, folder in pairs(peltList:GetChildren()) do
		if not folder:IsA("Folder") then
			continue
		end

		local clone = peltHolder.Template:Clone()
		clone.LayoutOrder = folder:GetAttribute("LayoutOrder") or 9
		clone.ImageLabel.Image = folder:GetAttribute("Image") or ""
		clone.TextLabel.Text = folder:GetAttribute("Description") or ""
		clone.Visible = true

		if folder.Name == "Mammoth Tusk" and (localPlayer:GetAttribute("ClassLevel") or 1) < 3 then
			clone.Visible = false
		end

		clone.Parent = peltHolder
		table.insert(clones2, clone)

		if folder:GetAttribute("Complete") then
			if folder.Name == "Mammoth Tusk" then
				clone.TickBox.TextLabel.Visible = true
				clone.TickBox.TextLabel.Text = folder:GetAttribute("Count")
			else
				clone.TickBox.Tick.Visible = true
			end

			clone.TextLabel.TextColor3 = Color3.fromRGB(0, 127, 4)
		else
			clone.TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)

			if folder.Name == "Mammoth Tusk" then
				clone.TickBox.Tick.Visible = false
				clone.TickBox.TextLabel.Text = folder:GetAttribute("Count") or 0
				clone.TickBox.TextLabel.Visible = true
			else
				clone.TickBox.Tick.Visible = false
			end
		end
	end
end

local clones3 = {}
local v5 = {
	Bunnies = "rbxassetid://71943160941122",
	Wolves = "rbxassetid://113579146776668",
	["Alpha Wolves"] = "rbxassetid://87654858338325",
	Bears = "rbxassetid://108415579791178",
	Mammoths = "rbxassetid://77831091321267",
	Cultists = "rbxassetid://100103909624382"
}
local v6 = {
	Bunnies = 1,
	Wolves = 2,
	Cultists = 3,
	["Alpha Wolves"] = 4,
	Bears = 5,
	Mammoths = 6
}

function RefreshGunslingerList()
	for _, v7 in pairs(clones3) do
		v7:Destroy()
	end

	local targetsHolder = Client.Interface.Gunslinger.TargetsHolder
	local gunslingerList = localPlayer:WaitForChild("GunslingerList", 15)

	for _, folder in pairs(gunslingerList:GetChildren()) do
		if not folder:IsA("Folder") then
			continue
		end

		local clone = targetsHolder.Template:Clone()
		local target = folder:GetAttribute("Target") or "Bunnies"
		clone.LayoutOrder = v6[target] or 9
		clone.ImageLabel.Image = v5[target] or ""

		if folder:GetAttribute("Completed") then
			clone.TopText.TextColor3 = Color3.fromRGB(22, 166, 0)
			clone.ImageLabel.ImageColor3 = Color3.fromRGB(22, 166, 0)
			clone.BottomText.Text = `MAX ({folder:GetAttribute("StatValue") or 1})`
			clone.LevelBar.Fill.Size = UDim2.new(1, 0, 1, 0)
			clone.LevelBar.Fill.BackgroundColor3 = Color3.fromRGB(22, 166, 0)
			clone.LevelBar.TextLabel.Text = "COMPLETE"
		else
			clone.LevelBar.TextLabel.Text = `{folder:GetAttribute("Kills") or 0} / {folder:GetAttribute("NextKillGoal") or 5}`
			clone.BottomText.Text = `lvl {folder:GetAttribute("Level") or 1} ({folder:GetAttribute("StatValue") or 1})`
			clone.LevelBar.Fill.Size = UDim2.new(
				folder:GetAttribute("Kills") / folder:GetAttribute("NextKillGoal"),
				0,
				1,
				0
			)
		end

		clone.TopText.Text = `{string.upper(target)} - {folder:GetAttribute("Description") or ""}`
		clone.Visible = true
		clone.Parent = targetsHolder
		table.insert(clones3, clone)
	end
end

local clones4 = {}

function RenderUndeadList()
	for _, v7 in pairs(clones4) do
		v7:Destroy()
	end

	local undeadHolder = Client.Interface.UndeadList.UndeadHolder
	local undeadClassPerks = localPlayer:WaitForChild("UndeadClassPerks", 15)

	for i = 1, 10 do
		if not undeadClassPerks:GetAttribute("Perk" .. i) then
			break
		end

		local clone = undeadHolder.Template:Clone()
		clone.LayoutOrder = i or 9
		clone.TextLabel.Text = undeadClassPerks:GetAttribute("Perk" .. i)
		clone.Visible = true
		clone.Parent = undeadHolder
		table.insert(clones4, clone)

		if undeadClassPerks:GetAttribute("Perk" .. i .. "Done") then
			clone.TickBox.Tick.Visible = true
			clone.TextLabel.TextColor3 = Color3.fromRGB(0, 127, 4)
		else
			clone.TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
			clone.TickBox.Tick.Visible = false
		end
	end
end

local v7 = {
	SupportList = function()
		task.spawn(function()
			localPlayer:GetAttributeChangedSignal("SupportingPlayer"):Connect(function()
				RefreshSupportList(localPlayer:GetAttribute("SupportingPlayer"))
			end)
			RefreshSupportList(localPlayer:GetAttribute("SupportingPlayer"))
			game.Players.PlayerAdded:Connect(function()
				RefreshSupportList(localPlayer:GetAttribute("SupportingPlayer"))
			end)
		end)
	end,
	HunterList = function()
		task.spawn(function()
			local peltList = localPlayer:WaitForChild("PeltList", 15)

			if not peltList then
				return
			end

			for _, folder in pairs(peltList:GetChildren()) do
				if folder:IsA("Folder") then
					folder.AttributeChanged:Connect(function()
						RefreshPeltList()
					end)
				end
			end

			RefreshPeltList()
			peltList.ChildAdded:Connect(function(folder)
				if folder:IsA("Folder") then
					RefreshPeltList()
				end

				folder.AttributeChanged:Connect(function()
					RefreshPeltList()
				end)
			end)
		end)
	end,
	GunslingerList = function()
		task.spawn(function()
			local gunslingerList = localPlayer:WaitForChild("GunslingerList", 15)

			if not gunslingerList then
				return
			end

			for _, folder in pairs(gunslingerList:GetChildren()) do
				if folder:IsA("Folder") then
					folder.AttributeChanged:Connect(function()
						RefreshGunslingerList()
					end)
				end
			end

			RefreshGunslingerList()
			gunslingerList.ChildAdded:Connect(function(folder)
				if folder:IsA("Folder") then
					RefreshGunslingerList()
				end

				folder.AttributeChanged:Connect(function()
					RefreshGunslingerList()
				end)
			end)
		end)
	end,
	Recipes = function()
		RenderRecipeBook()
	end,
	UndeadList = function()
		task.spawn(function()
			local undeadClassPerks = localPlayer:WaitForChild("UndeadClassPerks", 15)

			if not undeadClassPerks then
				return
			end

			undeadClassPerks.AttributeChanged:Connect(function()
				RenderUndeadList()
			end)
			RenderUndeadList()
		end)
	end,
	Furniture = function()
		task.spawn(function()
			wait(0.5)
			local topRight = Client.Interface.TopRight
			local furnitureTrader = ReplicatedStorage.Shops["Furniture Trader"]
			local furniture = Client.Interface.TopRight.Frame.Furniture
			local furnitureShopOpen = furnitureTrader:GetAttribute("FurnitureShopOpen") or false

			if furnitureShopOpen and furnitureShopOpen == true then
				furniture.Visible = true
				topRight.Visible = true
			else
				furniture.Visible = false

				if topRight:GetAttribute("EnabledSoFar") <= 1 then
					topRight.Visible = false
				end
			end

			furnitureTrader:GetAttributeChangedSignal("FurnitureShopOpen"):Connect(function()
				local furnitureShopOpen2 = furnitureTrader:GetAttribute("FurnitureShopOpen") or false

				if furnitureShopOpen2 and furnitureShopOpen2 == true then
					furniture.Visible = true
					topRight.Visible = true
				else
					furniture.Visible = false

					if topRight:GetAttribute("EnabledSoFar") <= 1 then
						topRight.Visible = false
					end
				end
			end)
		end)
	end
}
local flag = false
local v8 = {
	SupportList = "SupportList",
	HunterList = "PeltList",
	GunslingerList = "Gunslinger",
	Recipes = "RecipeList",
	Furniture = "Furniture",
	UndeadList = "UndeadList"
}
Client.Events.OpenSupportList:Connect(function()
	TopRightClient.AddTopRightIcon("SupportList")
end)
Client.Events.OpenHunterList:Connect(function()
	TopRightClient.AddTopRightIcon("HunterList")
end)
Client.Events.OpenRecipes:Connect(function()
	TopRightClient.AddTopRightIcon("Recipes")
end)
Client.Events.OpenFurniture:Connect(function()
	TopRightClient.AddTopRightIcon("Furniture")
end)
Client.Events.OpenUndeadList:Connect(function()
	TopRightClient.AddTopRightIcon("UndeadList")
end)
Client.Events.OpenGunslingerList:Connect(function()
	TopRightClient.AddTopRightIcon("GunslingerList")
end)
Client.Events.TopRightMenuEnabled:Connect(function(p)
	TopRightClient.AddTopRightIcon(p)
end)
local count = 0
local v9 = true
local v10 = nil

function TopRightClient.AddTopRightIcon(childName)
	if v[childName] then
		return
	end

	if childName ~= "Furniture" then
		Client.PopUpUI.AddPopUp("added button to top right menu", "yellow")
		v10 = childName
	end

	local child = Client.Interface.TopRight.Frame:FindFirstChild(childName)

	if not child then
		return
	end

	v[childName] = true
	local topRight = Client.Interface.TopRight
	topRight.Visible = true

	if child.Visible ~= true then
		topRight:SetAttribute("EnabledSoFar", topRight:GetAttribute("EnabledSoFar") + 1)
		child.LayoutOrder = topRight:GetAttribute("EnabledSoFar")
		v7[childName]()
	end

	local v11 = Client.Interface[v8[childName]]

	if (childName == "Furniture" and v10 or childName ~= "Furniture") and not (topRight.Frame.Furniture.Marker.TextLabel.Visible or topRight.Frame.Furniture.Marker.Pointer.Visible) then
		topRight.Frame.Furniture.Marker.Visible = false
	end

	flag = true
	task.spawn(function()
		while flag do
			wait(0.75)

			if child:FindFirstChild("Exclaim") then
				child.Exclaim.Visible = not child.Exclaim.Visible
			end
		end

		child.Exclaim.Visible = false
	end)
	task.spawn(function()
		wait(55)
		flag = false
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ToggleButtonPress()
		v11.Visible = not v11.Visible
		flag = false
		Client.Sound.Play("CloseButton")

		if v11.Visible then
			Client.Sound.Play("Paper")
		end
	end

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	task.spawn(function()
		wait(10)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
	end)
	Client.Sound.Play("UseToolGui")
	count += 1
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonB and v11.Visible then
			v11.Visible = false
		end

		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.T then
			if v11.Name ~= "Furniture" then
				ToggleButtonPress() -- equivalent call inferred; original call site unknown
			end
		elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Y then
			if v11.Name == "Furniture" and ReplicatedStorage.Shops["Furniture Trader"]:GetAttribute("FurnitureShopOpen") then
				ToggleButtonPress() -- equivalent call inferred; original call site unknown
			end
		elseif input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.DPadDown then
			if not v9 or childName == "Furniture" and v10 then
				return
			end

			v9 = false

			if v11.Name == "Furniture" and ReplicatedStorage.Shops["Furniture Trader"]:GetAttribute("FurnitureShopOpen") then
				ToggleButtonPress() -- equivalent call inferred; original call site unknown
			elseif v11.Name ~= "Furniture" then
				ToggleButtonPress() -- equivalent call inferred; original call site unknown
			end

			task.spawn(function()
				wait(0.15)
				v9 = true
			end)
		end
	end)
	child.MouseButton1Down:Connect(function()
		ToggleButtonPress() -- equivalent call inferred; original call site unknown
	end)

	if v11.Name ~= "Furniture" then
		v11.CloseButton.MouseButton1Down:Connect(function()
			ToggleButtonPress() -- equivalent call inferred; original call site unknown
		end)
	end

	if childName ~= "Furniture" then
		child.Visible = true
	end
end

local v11 = false

function WhistleEnabled()
	task.spawn(function()
		if not v11 then
			v11 = true
			Client.AnimalTamingClient.WhistleButtonSetup()
		end

		local currentlyEquipped = Client.InventoryHandler.GetCurrentlyEquipped()

		if not currentlyEquipped or not currentlyEquipped:GetAttribute("ToolName") or currentlyEquipped:GetAttribute("ToolName") ~= "Taming Flute" then
			return
		end

		local topRight = Client.Interface.TopRight
		topRight.Visible = true
		topRight.Frame.PetWhistle.Visible = true
	end)
end

function TopRightClient.Init()
	task.spawn(function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function checkDecorator()
			if localPlayer:GetAttribute("DecoratorGamePass") then
				TopRightClient.AddTopRightIcon("Furniture")
			end
		end

		localPlayer:GetAttributeChangedSignal("DecoratorGamePass"):Connect(checkDecorator)
		checkDecorator() -- equivalent call inferred; original call site unknown
	end)
	task.spawn(function()
		local function updatePetCount()
			if localPlayer:GetAttribute("CurrentPets") and localPlayer:GetAttribute("CurrentPets") > 0 then
				Client.Interface.TopRight.Frame.PetWhistle.PetCount.Text = localPlayer:GetAttribute("CurrentPets") .. "/" .. localPlayer:GetAttribute("MaxPets") or 2
				WhistleEnabled()
			end
		end

		localPlayer:GetAttributeChangedSignal("CurrentPets"):Connect(function()
			updatePetCount()
		end)
		updatePetCount()
	end)
	task.spawn(function()
		wait(5)

		if localPlayer:GetAttribute("Class") ~= "Beastmaster" then
			return
		end

		Client.AnimalTamingClient.SummonButtonSetup()
		local itemBag = localPlayer:WaitForChild("ItemBag")

		local function checkSteaks()
			if not localPlayer:FindFirstChild("ItemBag") then
				return
			end

			local children = localPlayer.ItemBag:GetChildren()
			local count2 = 0

			for _, v12 in pairs(children) do
				if v12.Name == "Steak" or v12.Name == "Cooked Steak" then
					count2 += 1
				end
			end

			local petSummon = Client.Interface.TopRight.Frame.PetSummon

			if petSummon and petSummon:FindFirstChild("Steaks") then
				petSummon.Steaks.Steak1.Visible = count2 >= 1
				petSummon.Steaks.Steak2.Visible = count2 >= 2
				petSummon.Steaks.Steak3.Visible = count2 >= 3
			end

			return count2 >= 3
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateSummonImage()
			local petSummon = Client.Interface.TopRight.Frame.PetSummon

			if checkSteaks() then
				petSummon.ImageTransparency = 0
				petSummon:SetAttribute("Ready", true)
			else
				petSummon.ImageTransparency = 0.75
				petSummon:SetAttribute("Ready", false)
			end
		end

		itemBag.ChildAdded:Connect(function()
			updateSummonImage() -- equivalent call inferred; original call site unknown
		end)
		itemBag.ChildRemoved:Connect(function()
			updateSummonImage() -- equivalent call inferred; original call site unknown
		end)
		updateSummonImage() -- equivalent call inferred; original call site unknown
	end)
end

return TopRightClient