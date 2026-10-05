local ToolWorkshopClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("CollectionService")
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://84509073695341"
Random.new()
local itemsContent = nil
local recipes = nil
local v = {}
local v2 = {}
local v3 = {
	["Bunny Foot"] = "rbxassetid://117362208530862",
	["Wolf Pelt"] = "rbxassetid://89903166344518",
	["Alpha Wolf Pelt"] = "rbxassetid://106205251189894",
	["Bear Pelt"] = "rbxassetid://131709597137934",
	["Cultist Gem"] = "rbxassetid://84548955291283",
	Scrap = "rbxassetid://78397538071418",
	Log = "rbxassetid://71789994216635",
	["Thorn Body"] = "rbxassetid://108700976589045",
	Kunai = "rbxassetid://99564309562446",
	["Riot Shield"] = "rbxassetid://125504598776471",
	Chainsaw = "rbxassetid://117518214301380",
	["Tactical Shotgun"] = "rbxassetid://97356005567801",
	["Mammoth Helmet"] = "rbxassetid://94517364346269",
	["Mammoth Tusk"] = "rbxassetid://136665867333309",
	["Infernal Helmet"] = "rbxassetid://92810464017395",
	["Cultist King Antler"] = "rbxassetid://105857885846510",
	["Scorpion Shell"] = "rbxassetid://110610597506471",
	["Boar Helmet"] = "rbxassetid://98945328713427",
	["Boar Tusk"] = "rbxassetid://77482743255749",
	["Obsidiron Chest"] = "rbxassetid://122548348634582",
	["Obsidiron Ingot"] = "rbxassetid://132599127851405",
	["Meteor Shard"] = "rbxassetid://125111211829031",
	["Gold Shard"] = "rbxassetid://111241679322407",
	["Armour Trim Kit"] = "rbxassetid://100576295588863",
	["Axe Trim Kit"] = "rbxassetid://100576295588863"
}

function CloseGui(p)
	if p then
		Client.Sound.Play("CloseButton")
	end

	Client.Interface.WorkshopRecipes.Visible = false
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
end

ContextActionService:BindActionAtPriority("CloseWorkbench", function(_, p, _)
	if not Client.Interface.WorkshopRecipes.Visible or p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	CloseGui(true)
	GamepadService:DisableGamepadCursor()
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.ButtonB)

function AnvilFinishedLoop(parent)
	local track = parent.AnimationController.Animator:LoadAnimation(animation)
	track:Play()
	local flag = true
	local highlight = Instance.new("Highlight")
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = false
	highlight.FillColor = Color3.fromRGB(120, 40, 0)
	highlight.FillTransparency = 0.45
	highlight.OutlineTransparency = 1
	highlight.Name = "HighlightAnvilHologram"
	highlight.Parent = parent

	if highlight then
		parent.HighlightAnvilHologram.FillTransparency = 1
		parent.HighlightAnvilHologram.Enabled = true
	end

	task.spawn(function()
		while flag do
			wait(1.2)

			if not (flag and parent and parent:FindFirstChild("ParticlePart")) then
				continue
			end

			parent.PrimaryPart.Hammer:Play()

			if highlight then
				parent.HighlightAnvilHologram.FillTransparency = 0.45
				TweenService:Create(parent.HighlightAnvilHologram, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
					FillTransparency = 1
				}):Play()
			end

			for _, emitter in pairs(parent.ParticlePart:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end

		if highlight then
			highlight.Adornee = nil
			highlight:Destroy()
			highlight = nil
		end
	end)
	task.spawn(function()
		wait(8)
		flag = false
		parent.PrimaryPart.HammerComplete:Play()
		track:Stop()
		wait(0.46)

		if highlight and highlight.Parent then
			highlight.Enabled = false
		end
	end)
end

function AnvilIngredientAddedAnim(instance)
	Client.Sound.Play("AnvilAdd", {
		Volume = 0.5,
		Replicate = true,
		ReplicationProperties = {
			Instance = instance.PrimaryPart,
			Volume = 0.45
		}
	})
end

Client.Events.AnvilBuildTool:Connect(function(instance)
	if instance == nil or instance.Parent == nil then
		return
	end

	local anvilHologram = instance:WaitForChild("Functional"):WaitForChild("AnvilHologram")
	print("anvil anim")
	AnvilFinishedLoop(anvilHologram)
end)
Client.Events.LowerAnvil:Connect(function(instance)
	if instance == nil or instance.Parent == nil then
		return
	end

	local podium = instance:WaitForChild("Functional"):WaitForChild("Podium")
	local anvilHologram = instance:WaitForChild("Functional"):WaitForChild("AnvilHologram")
	local pivot = podium:GetPivot()
	local pivot2 = anvilHologram:GetPivot()
	wait(0.5)
	Client.TweenModule.new(function(p)
		podium:PivotTo(pivot - Vector3.new(0, 4 * p, 0))
		anvilHologram:PivotTo(pivot2 - Vector3.new(0, 4 * p, 0))
	end, 3.25):Play()
	anvilHologram.PrimaryPart.GratingStone:Play()
end)

function MakePieceSolid(instance)
	instance.CanCollide = true
	instance.Color = instance:GetAttribute("DefaultColour") or Color3.fromRGB(120, 123, 139)
	instance.Material = instance:GetAttribute("DefaultMaterial") or Enum.Material.Metal
	instance.Transparency = 0
end

function MakePieceGhost(p)
	p.CanCollide = false
	p.Color = Color3.fromRGB(237, 234, 234)
	p.Material = Enum.Material.ForceField
	p.Transparency = 0.5
end

function CheckBuildAnvil(p, instance)
	if instance:GetAttribute("Interaction") ~= "Item" then
		return
	end

	if instance:GetAttribute("AnvilPiece") then
		instance.Parent = game.ReplicatedStorage.TempStorage
		instance:SetAttribute("Destroyed", true)
		local child = p.Functional.AnvilHologram:FindFirstChild(instance.Name)

		if child and child:GetAttribute("Completed") == nil then
			for _, part in pairs(child:GetChildren()) do
				if part:IsA("BasePart") then
					MakePieceSolid(part)
				end
			end

			local v4 = Client.Events.RequestBuildAnvilPiece:InvokeServer(p, instance)

			if not (v4 and v4.Success) then
				instance.Parent = workspace.Items
				instance:SetAttribute("Destroyed", nil)

				for _, part in pairs(child:GetChildren()) do
					if part:IsA("BasePart") then
						MakePieceGhost(part)
					end
				end
			end
		end
	end
end

Client.Events.AnvilIngredientAdded:Connect(function(instance, instance2)
	if not instance2:GetAttribute("Destroyed") then
		instance2:SetAttribute("Destroyed", true)
	end

	instance2:Destroy()

	if not instance2:GetAttribute("Animated") then
		instance2:SetAttribute("Animated", true)
		AnvilIngredientAddedAnim(instance:WaitForChild("Functional"):WaitForChild("AnvilHologram"))
	end
end)

function CheckBuildTool(instance, instance2)
	if instance2:GetAttribute("Destroyed") or instance2:GetAttribute("Interaction") ~= "Item" then
		return
	end

	local name = instance2.Name
	local v4 = instance2:GetAttribute("Scrappable") and "Scrap" or name
	local v5 = v2[instance][v4]

	if v5 then
		local folder = v5.Folder

		if folder:GetAttribute("Quantity" .. v5.Index) > (folder:GetAttribute("Added" .. v5.Index) or 0) then
			instance2.Parent = game.ReplicatedStorage.TempStorage
			instance2:SetAttribute("Destroyed", true)
			task.spawn(function()
				if not instance2:GetAttribute("Animated") then
					instance2:SetAttribute("Animated", true)
					AnvilIngredientAddedAnim(instance:WaitForChild("Functional"):WaitForChild("AnvilHologram"))
				end
			end)
			local v6 = Client.Events.RequestAddAnvilIngredient:InvokeServer(instance, instance2)

			if v6 and v6.Success then
				instance2:Destroy()
			else
				instance2.Parent = workspace.Items
				instance2:SetAttribute("Destroyed", nil)
			end
		end
	end
end

local v4 = {}
local v5 = {}
local clonesByInstance = {}

function ChooseGui(instance)
	for _, child in pairs(instance.Parent:GetChildren()) do
		if child.Name == "ItemsContent" and child ~= instance then
			child.Visible = false
		end
	end

	instance.Visible = true
	Client.Interface.WorkshopRecipes.Border.Visible = instance:GetAttribute("MeteorEvent") == true
end

function ToolWorkshopClient.OpenWindow(p)
	if not clonesByInstance[p] then
		print("NO GUI FOUND TO DISPLAY")
		return
	end

	ChooseGui(clonesByInstance[p])
	task.spawn(function()
		if UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
			GamepadService:EnableGamepadCursor(clonesByInstance[p])
		end
	end)
end

function CancelRecipe(p)
	Client.Sound.Play("KeyPress", {
		Duplicate = true
	})
	Client.Events.RequestCancelRecipe:FireServer(p)
end

function SelectRecipe(p, p2)
	Client.Sound.Play("KeyPress", {
		Duplicate = true
	})
	CloseGui()
	v[p2] = p
	print("recipe name " .. p)
	Client.Events.RequestSelectRecipe:FireServer(p2, p)
end

local function CreateRecipeGui(instance, p)
	local name = instance.Name
	local v6 = tonumber((string.sub(instance.Name, 7)))
	local parent = clonesByInstance[p]

	if not parent then
		print("NO GUI FOUND")
		return
	end

	local template_Regular = parent.Template_Regular

	if v6 > 4 then
		template_Regular = parent.Template_MeteorEvent
	end

	local recipeName = instance:GetAttribute("RecipeName")
	local cooldown = instance:GetAttribute("Cooldown")
	local selected = instance:GetAttribute("Selected")

	if selected and selected == true then
		v[p] = recipeName
	end

	local layoutOrder = tonumber((string.sub(instance.Name, 7)))

	if not selected and v[p] == recipeName then
		v[p] = nil
	end

	if not recipeName then
		return
	end

	v5[p] = v5[p] or {}
	local clone = v5[p][name]

	if not clone then
		clone = template_Regular:Clone()
		clone.Name = name

		if layoutOrder > 4 then
			for _, image in pairs(clone:GetDescendants()) do
				if image:IsA("ImageLabel") and image.Name == "Adornment" then
					image.Visible = true
				end
			end
		end

		clone.LayoutOrder = layoutOrder
		v5[p][name] = clone
		v4[p] = v4[p] or {}
		v4[p][name] = v4[p][name] or {}
		v4[p][name].click = clone.SelectButton_Lower.MouseButton1Down:Connect(function()
			if Client.PingClient.PingActive or (instance:GetAttribute("Cooldown") or instance:GetAttribute("Selected")) then
				return
			end

			local recipeName2 = instance:GetAttribute("RecipeName")

			if recipeName2 then
				SelectRecipe(recipeName2, p)
			end
		end)
		v4[p][name].cancel = clone.CancelButton_Lower.MouseButton1Down:Connect(function()
			if Client.PingClient.PingActive or not instance:GetAttribute("Selected") or instance:GetAttribute("Building") then
				return
			end

			CancelRecipe(p)
		end)
		clone.Visible = true
		clone.Parent = parent
	end

	clone.Frame.ItemName.Text = recipeName
	clone.Frame.Icon.Image = v3[recipeName] or ""

	if cooldown then
		clone.Cooldown.Visible = true
		clone.Selected.Enabled = false
	else
		clone.Cooldown.Visible = false

		if selected then
			clone.Selected.Enabled = true
		else
			clone.Selected.Enabled = false
		end
	end

	if v[p] then
		for _, v9 in pairs(v5[p]) do
			v9.SelectButton_Lower.Visible = false
		end
	else
		for _, v9 in pairs(v5[p]) do
			if not v9.Cooldown.Visible then
				v9.SelectButton_Lower.Visible = true
			end
		end
	end

	if selected and not instance:GetAttribute("Building") then
		clone.CancelButton_Lower.Visible = true
	else
		clone.CancelButton_Lower.Visible = false
	end

	for _, child in pairs(clone.ComponentsList:GetChildren()) do
		if child.Name ~= "Ingredient" and child.Name ~= "UIListLayout" then
			child:Destroy()
		end
	end

	for i = 1, 5 do
		if not instance:GetAttribute("Ingredient" .. i) then
			continue
		end

		local clone2 = clone.ComponentsList.Ingredient:Clone()
		clone2.ItemName.Text = instance:GetAttribute("Ingredient" .. i)
		clone2.Quantity.Text = "x" .. (instance:GetAttribute("Quantity" .. i) or "1")
		clone2.Icon.Image = v3[instance:GetAttribute("Ingredient" .. i)] or ""
		clone2.LayoutOrder = i
		clone2.Name = "Ingredient" .. i
		clone2.Visible = true
		clone2.Parent = clone.ComponentsList
	end

	clone.Visible = true
end

local function RemoveRecipeButton(p, p2)
	v5[p2] = v5[p2] or {}
	local v6 = v5[p2][p]

	if v6 then
		v6:Destroy()
		v5[p2][p] = nil
	end

	if v4[p2][p] then
		for _, connection in pairs(v4[p2][p]) do
			if connection then
				connection:Disconnect()
			end
		end

		v4[p2][p] = nil
	end
end

local function RecipeAttributeChanged(folder, p)
	local name = folder.Name
	v4[p] = v4[p] or {}
	v4[p][name] = v4[p][name] or {}
	v4[p][name].attributeChanged = folder.AttributeChanged:Connect(function(value)
		if string.sub(value, 1, 4) == "Ingre" or string.sub(value, 1, 3) == "Qua" or value == "RecipeName" or value == "Cooldown" or value == "Selected" or value == "Building" then
			CreateRecipeGui(folder, p)
		end
	end)
end

local function InitializeWorkshopOptions(instance)
	local recipes2 = instance.Recipes

	for _, folder in pairs(recipes2:GetChildren()) do
		if not (folder:IsA("Folder") and folder.Name:match("^Recipe%d+$")) then
			continue
		end

		CreateRecipeGui(folder, instance)
		RecipeAttributeChanged(folder, instance)
	end

	v4[instance] = v4[instance] or {}
	v4[instance].childAdded = recipes2.ChildAdded:Connect(function(folder)
		if folder:IsA("Folder") and folder.Name:match("^Recipe%d+$") then
			CreateRecipeGui(folder, instance)
			RecipeAttributeChanged(folder, instance)
		end
	end)
	v4[instance].childRemoved = recipes2.ChildRemoved:Connect(function(folder)
		if folder:IsA("Folder") and folder.Name:match("^Recipe%d+$") then
			CreateRecipeGui(folder, instance)
			RecipeAttributeChanged(folder, instance)
		end
	end)
end

function ToolWorkshopAdded(instance)
	local touchZone = instance:WaitForChild("Functional"):WaitForChild("TouchZone")
	task.spawn(function()
		recipes = instance:WaitForChild("Recipes")

		repeat
			wait()
		until itemsContent

		local clone = itemsContent:Clone()

		if instance.Name == "ToolWorkshopMeteorShower" then
			clone:SetAttribute("MeteorEvent", true)
		end

		clone.Parent = itemsContent.Parent
		clonesByInstance[instance] = clone
		clone.Visible = false
		InitializeWorkshopOptions(instance)
	end)
	touchZone.Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if parent and parent.Parent then
			if parent:GetAttribute("Destroyed") then
				return
			end

			if instance:GetAttribute("WorkshopComplete") then
				CheckBuildTool(instance, parent)
			else
				CheckBuildAnvil(instance, parent)
			end
		end
	end)

	local function updateIngredients()
		local selectedRecipe = instance:GetAttribute("SelectedRecipe")
		v2[instance] = {}

		if selectedRecipe then
			local child = instance.Recipes:FindFirstChild(selectedRecipe)

			if child then
				local v6 = 1

				while child:GetAttribute("Ingredient" .. v6) do
					v2[instance][child:GetAttribute("Ingredient" .. v6)] = {
						Index = v6,
						Folder = child
					}
					v6 += 1
				end
			end

			print(v2[instance])
		end
	end

	instance:GetAttributeChangedSignal("SelectedRecipe"):Connect(updateIngredients)
	updateIngredients()
end

function ToolWorkshopClient.Init()
	task.spawn(function()
		itemsContent = Client.Interface.WorkshopRecipes.ItemsContent
		Client.Interface.WorkshopRecipes:WaitForChild("CloseButton").MouseButton1Down:Connect(function()
			CloseGui(true)
		end)
	end)
end

Client.Utility.ForAllTagged("ToolWorkshop", ToolWorkshopAdded)
return ToolWorkshopClient