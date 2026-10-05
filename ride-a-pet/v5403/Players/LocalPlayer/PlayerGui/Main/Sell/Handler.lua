local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local gameData = ReplicatedStorage2:WaitForChild("GameData")
local Pets = require(gameData:WaitForChild("Pets"))
local Eggs = require(gameData:WaitForChild("Eggs"))
local Mutations = require(gameData:WaitForChild("Mutations"))
local gameServices = ReplicatedStorage2:WaitForChild("GameServices")
local SellValue = require(gameServices:WaitForChild("SellValue"))
local PetAging = require(gameServices:WaitForChild("PetAging"))
local String = require(ReplicatedStorage2:WaitForChild("Services"):WaitForChild("String"))
local UIController = require(ReplicatedStorage2:WaitForChild("UIController"))
local SoundService = game:GetService("SoundService")
local SFX = SoundService:WaitForChild("SFX")
local game2 = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Game")
local openSell = game2:WaitForChild("OpenSell")
local sellItems = game2:WaitForChild("SellItems")
local parent = script.Parent
local closeBtn = parent:WaitForChild("CloseBtn")
local pets = parent:WaitForChild("Pets")
local eggs = parent:WaitForChild("Eggs")
local scrollingFrame = parent:WaitForChild("ScrollingFrame")
local frame = parent:WaitForChild("Frame")
local weight = frame:WaitForChild("Weight")
local value = frame:WaitForChild("Value")
local selectAll = frame:WaitForChild("SelectAll")
local clearAll = frame:WaitForChild("ClearAll")

local function ClaimLabel(instance, name, callback)
	instance:WaitForChild("TextLabel")

	for _, label in instance:GetChildren() do
		if not (label:IsA("TextLabel") and label.Name == "TextLabel" and callback(label.Text)) then
			continue
		end

		label.Name = name
		return label
	end

	error((`Sell UI: no label for {name} under {instance:GetFullName()}`))
end

local function IsCash(value2)
	return string.sub(value2, 1, 1) == "$" and not string.find(value2, "/s", 1, true)
end

local claimLabel = ClaimLabel(frame, "SelectedCount", function(value2)
	return string.find(value2, "Selected", 1, true) ~= nil
end)
local claimLabel2 = ClaimLabel(frame, "TotalValue", IsCash)
local sell_Ready = frame:WaitForChild("Sell_Ready")
local sell_NotReady = frame:WaitForChild("Sell_NotReady")
parent:AddTag("FocusFrame")
closeBtn:AddTag("RotateOnHover")
closeBtn:AddTag("DarkenOnHover")
sell_Ready:AddTag("RotateOnHover")
local _1 = scrollingFrame:WaitForChild("1")
local _1_Selected = scrollingFrame:WaitForChild("1_Selected")
local image = _1.Image
local image2 = _1_Selected.Image
ClaimLabel(_1, "WeightText", function(value2)
	return string.find(string.lower(value2), "kg", 1, true) ~= nil
end)
ClaimLabel(_1, "IncomeText", function(value2)
	return string.find(value2, "/s", 1, true) ~= nil
end)
ClaimLabel(_1, "WorthText", IsCash)
local weightText = _1.WeightText
weightText.Name = "NameText"
weightText.TextColor3 = Color3.new(1, 1, 1)
weightText.TextXAlignment = Enum.TextXAlignment.Left
weightText.AnchorPoint = Vector2.new(0, 0.5)
weightText.Position = UDim2.fromScale(0.07, weightText.Position.Y.Scale - 0.02)
local clone = weightText:Clone()
clone.Name = "WeightText"
clone.Size = UDim2.fromScale(weightText.Size.X.Scale * 0.8, weightText.Size.Y.Scale * 0.8)
clone.Position = weightText.Position + UDim2.fromScale(0, weightText.Size.Y.Scale * 0.75)
clone.Parent = _1
local scale = weightText.Position.X.Scale
local v3 = clone.Position.Y.Scale + weightText.Size.Y.Scale * 0.75
local scale2 = clone.Size.Y.Scale
local v4 = scale2 * 0.5

local function TagLabel(name)
	local clone2 = clone:Clone()
	clone2.Name = name
	local uIAspectRatioConstraint = clone2:FindFirstChildOfClass("UIAspectRatioConstraint")

	if uIAspectRatioConstraint then
		uIAspectRatioConstraint:Destroy()
	end

	clone2.Visible = false
	clone2.Parent = _1
	return clone2
end

local clone2 = clone:Clone()
clone2.Name = "SpawnTag"
local uIAspectRatioConstraint = clone2:FindFirstChildOfClass("UIAspectRatioConstraint")

if uIAspectRatioConstraint then
	uIAspectRatioConstraint:Destroy()
end

clone2.Visible = false
clone2.Parent = _1
local clone3 = clone:Clone()
clone3.Name = "WeatherTag"
local uIAspectRatioConstraint2 = clone3:FindFirstChildOfClass("UIAspectRatioConstraint")

if uIAspectRatioConstraint2 then
	uIAspectRatioConstraint2:Destroy()
end

clone3.Visible = false
clone3.Parent = _1
_1.Parent = nil

for _, button in scrollingFrame:GetChildren() do
	if button:IsA("GuiButton") then
		button:Destroy()
	end
end

local uIGridLayout = scrollingFrame:WaitForChild("UIGridLayout")
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
uIGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- equivalent calls inferred from this helper; original call sites unknown
local function OpenScale()
	local child = parent:FindFirstChild(UIController.Settings.ScaleName)

	if child then
		return (math.max(child.Scale, 0.01))
	end

	return 1
end

local function SizeCells()
	if math.abs(OpenScale() - 1) > 0.001 then
		return
	end

	local v5 = scrollingFrame.AbsoluteSize.X - scrollingFrame.ScrollBarThickness

	if v5 <= 0 then
		return
	end

	local v6 = math.max(2, (math.floor(v5 * 0.010157)))
	local v7 = math.floor((v5 - math.ceil(v5 * 0.03) * 2 - v6 * 2) / 3)
	uIGridLayout.CellSize = UDim2.fromOffset(v7, v7)
	uIGridLayout.CellPadding = UDim2.fromOffset(v6, v6)
end

local function SizeCanvas()
	scrollingFrame.CanvasSize = UDim2.fromOffset(
		0,
		uIGridLayout.AbsoluteContentSize.Y / OpenScale() + uIGridLayout.CellPadding.Y.Offset
	)
end

scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(SizeCells)
uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(SizeCanvas)
SizeCells()
scrollingFrame.CanvasSize = UDim2.fromOffset(
	0,
	uIGridLayout.AbsoluteContentSize.Y / OpenScale() + uIGridLayout.CellPadding.Y.Offset
)

local function TallerOf(p, p2)
	if p.Y.Scale >= p2.Y.Scale then
		return p
	end

	return p2
end

local function ShorterOf(p, p2)
	if p.Y.Scale >= p2.Y.Scale then
		return p2
	end

	return p
end

local v5 = {
	Image = weight.Image,
	HoverImage = weight.HoverImage,
	Size = 0
}
local size = weight.Size
local size2 = value.Size

if not (size.Y.Scale >= size2.Y.Scale) then
	size = size2
end

v5.Size = size
local v6 = {
	Image = value.Image,
	HoverImage = value.HoverImage,
	Size = 0
}
local size3 = weight.Size
local size4 = value.Size

if size3.Y.Scale >= size4.Y.Scale then
	size3 = size4
end

v6.Size = size3
local v7 = "Pets"
local v8 = "Weight"
local v9 = {
	Pets = {},
	Eggs = {}
}
local v10 = {
	Pets = {},
	Eggs = {}
}
local v11 = {}
local flag = false
local count = 0
local now = -1e999
local flag2 = true
local v12 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function Cash(p)
	return "$" .. String.Abbreviate(p)
end

local v13 = {
	TooFar = "Get closer to Richie to sell!",
	Nothing = "None of those can be sold right now.",
	NotReady = "Still loading, try again in a moment.",
	Error = "Something went wrong, nothing was sold.",
	Busy = "Slow down a little!"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowMessage(p)
	pcall(function()
		local Handler = require(localPlayer.PlayerGui.Reusable.GameMessages.Handler)
		Handler:AddMessage(p)
	end)
end

local function TutorialFinished()
	local savedData = localPlayer:FindFirstChild("SavedData")
	local hasFinishedTutorial = savedData and savedData:FindFirstChild("HasFinishedTutorial")
	return hasFinishedTutorial ~= nil and hasFinishedTutorial.Value == true
end

local function CarriedTools()
	local tools = {}

	for _, v14 in { localPlayer.Character, localPlayer:FindFirstChildOfClass("Backpack") } do
		if not v14 then
			continue
		end

		for _, tool in v14:GetChildren() do
			if tool:IsA("Tool") then
				table.insert(tools, tool)
			end
		end
	end

	return tools
end

local function PetEntry(instance)
	local petKey = instance:GetAttribute("PetKey")
	local petName = instance:GetAttribute("PetName")

	if typeof(petKey) ~= "string" or not Pets[petName] then
		return nil
	end

	local weight2 = instance:GetAttribute("Weight")
	local petWorth, income = SellValue.PetWorth(
		petName,
		weight2,
		instance:GetAttribute("Mutation"),
		instance:GetAttribute("SpawnMutation")
	)

	if not petWorth then
		return nil
	end

	local v15 = {
		Key = petKey,
		Name = petName,
		Image = Pets[petName].Image,
		Weight = tonumber(weight2) or 0,
		Income = income,
		Worth = petWorth,
		IsPet = true,
		Mutation = instance:GetAttribute("Mutation"),
		SpawnMutation = instance:GetAttribute("SpawnMutation"),
		Locked = 0
	}
	local locked

	if instance:GetAttribute("Favorited") == true then
		locked = true
	elseif petKey == "TUTORIAL_Snail" then
		local savedData = localPlayer:FindFirstChild("SavedData")
		local hasFinishedTutorial = savedData and savedData:FindFirstChild("HasFinishedTutorial")
		locked = hasFinishedTutorial == nil or hasFinishedTutorial.Value ~= true
	else
		locked = false
	end

	v15.Locked = locked
	return v15
end

local function EggEntry(instance)
	local eggInventoryId = instance:GetAttribute("EggInventoryId")
	local egg = Eggs[instance.Name]

	if typeof(eggInventoryId) ~= "string" or not egg then
		return nil
	end

	local data = instance:FindFirstChild("Data")
	local amount = data and data:FindFirstChild("Amount")
	local amount2 = amount and tonumber(amount.Value) or 1
	local eggWorth = SellValue.EggWorth(instance.Name, amount2)

	if eggWorth then
		return {
			Key = eggInventoryId,
			Name = instance.Name,
			Image = egg.Image,
			Weight = tonumber(instance:GetAttribute("Weight")) or 0,
			Amount = amount2,
			Worth = eggWorth,
			IsPet = false,
			Mutation = instance:GetAttribute("Mutation"),
			SpawnMutation = instance:GetAttribute("SpawnMutation"),
			Locked = instance:GetAttribute("TutorialEgg") == true
		}
	end

	return nil
end

local function MarkDirty()
	flag2 = true
end

local function Collect()
	local v14 = {}
	local pets2 = {}
	local eggs2 = {}

	for _, v17 in CarriedTools() do
		v14[v17] = true

		if not v12[v17] then
			v12[v17] = v17.AttributeChanged:Connect(MarkDirty)
		end

		if v17:HasTag("Pet") then
			local petEntry = PetEntry(v17)

			if petEntry then
				pets2[petEntry.Key] = petEntry
			end
		elseif v17:GetAttribute("EggInventoryId") then
			local eggEntry = EggEntry(v17)

			if eggEntry then
				eggs2[eggEntry.Key] = eggEntry
			end
		end
	end

	for k, connection in v12 do
		if v14[k] then
			continue
		end

		connection:Disconnect()
		v12[k] = nil
	end

	local v17 = v10
	v10.Pets = pets2
	v17.Eggs = eggs2

	for k, v18 in v9 do
		for k2 in v18 do
			local v19 = v10[k][k2]

			if not v19 or v19.Locked then
				v18[k2] = nil
			end
		end
	end
end

local function Sorted(p)
	local result = {}

	for _, v14 in v10[p] do
		table.insert(result, v14)
	end

	table.sort(result, function(a, b)
		local weight2

		if v8 == "Weight" then
			weight2 = a.Weight
		else
			weight2 = a.Worth
		end

		local weight3

		if v8 == "Weight" then
			weight3 = b.Weight
		else
			weight3 = b.Worth
		end

		if weight2 ~= weight3 then
			return weight3 < weight2
		end

		if a.Worth == b.Worth then
			return a.Key < b.Key
		end

		return a.Worth > b.Worth
	end)
	return result
end

local Render

-- equivalent calls inferred from this helper; original call sites unknown
local function PaintTile(state, p)
	local visible = v9[v7][p.Key] == true
	local image3

	if visible then
		image3 = image2
	else
		image3 = image
	end

	state.Image = image3
	state.checkmark.Visible = visible
	local imageTransparency = p.Locked and 0.55 or 0
	state.ImageTransparency = imageTransparency
	state.Icon.ImageTransparency = imageTransparency
	state.AutoButtonColor = not p.Locked
end

local function PaintTag(p, p2, p3)
	local colorFor = Mutations.ColorFor(p2)

	if not colorFor then
		p.Visible = false
		return p3
	end

	local text = "[" .. p2 .. "]"
	local v15 = #text * v4
	p.Text = text
	p.TextColor3 = colorFor
	p.Position = UDim2.fromScale(p3, v3)
	p.Size = UDim2.fromScale(v15, scale2)
	p.Visible = true
	return p3 + v15 + 0.02
end

local function BuildTile(data, layoutOrder)
	local clone4 = _1:Clone()
	clone4.Name = data.Key
	clone4.LayoutOrder = layoutOrder
	clone4.Icon.Image = data.Image or ""
	clone4.NameText.Text = data.Name

	if data.Weight > 0 then
		local v14

		if data.IsPet then
			v14 = PetAging.InflatePetWeight(data.Weight)
		else
			v14 = PetAging.InflateEggWeight(data.Weight)
		end

		clone4.WeightText.Text = "(" .. String.Abbreviate(v14, 1, true) .. " KG)"
	else
		clone4.WeightText.Visible = false
	end

	local paintTag = PaintTag(clone4.SpawnTag, data.SpawnMutation, scale)
	PaintTag(clone4.WeatherTag, data.Mutation, paintTag)
	local incomeText = clone4.IncomeText

	if data.IsPet then
		incomeText.Text = Cash(data.Income) .. "/s"
	elseif data.Amount > 1 then
		incomeText.Text = "x" .. String:AddComma(data.Amount)
	else
		incomeText.Visible = false
	end

	local worthText = clone4.WorthText
	worthText.Text = Cash(data.Worth)
	PaintTile(clone4, data) -- equivalent call inferred; original call site unknown
	clone4.Activated:Connect(function()
		local v15 = v10[v7][data.Key]

		if flag or not v15 or v15.Locked then
			return
		end

		SFX.Click:Play()
		local v16 = v9[v7]
		v16[data.Key] = not v16[data.Key] or nil
		Render(false)
	end)
	clone4.Parent = scrollingFrame
	return clone4
end

local function SelectionSummary()
	local count2 = 0
	local total = 0

	for k, v14 in v9 do
		for k2 in v14 do
			local v15 = v10[k][k2]

			if not v15 then
				continue
			end

			count2 += 1
			total += v15.Worth
		end
	end

	return count2, total
end

local function PaintControls()
	pets.BackgroundTransparency = v7 == "Pets" and 0.6 or 0.2
	eggs.BackgroundTransparency = v7 == "Eggs" and 0.6 or 0.2
	local v14

	if v8 == "Weight" then
		v14 = v5
	else
		v14 = v6
	end

	local v15

	if v8 == "Value" then
		v15 = v5
	else
		v15 = v6
	end

	local v16 = weight
	local v17 = weight
	local v18 = weight
	local image3 = v14.Image
	local hoverImage = v14.HoverImage
	local size5 = v14.Size
	v16.Image = image3
	v17.HoverImage = hoverImage
	v18.Size = size5
	local v19 = value
	local v20 = value
	local v21 = value
	local image4 = v15.Image
	local hoverImage2 = v15.HoverImage
	local size6 = v15.Size
	v19.Image = image4
	v20.HoverImage = hoverImage2
	v21.Size = size6
	local visible = next(v9[v7]) ~= nil
	clearAll.Visible = visible
	selectAll.Visible = not visible
	local v23, v24 = SelectionSummary()
	claimLabel.Text = "Selected: " .. String:AddComma(v23)
	claimLabel2.Text = Cash(v24)
	sell_Ready.Visible = v23 > 0 and not flag
	sell_NotReady.Visible = not sell_Ready.Visible
end

Render = function(p)
	if p then
		Collect()

		for _, v14 in v11 do
			v14:Destroy()
		end

		table.clear(v11)

		for k, v14 in Sorted(v7) do
			v11[v14.Key] = BuildTile(v14, k)
		end

		flag2 = false
	else
		for k, v14 in v11 do
			local v15 = v10[v7][k]

			if not v15 then
				continue
			end

			PaintTile(v14, v15) -- equivalent call inferred; original call site unknown
		end
	end

	PaintControls()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Close()
	UIController.close(parent)
end

local function Open()
	if parent.Visible and not UIController.isOpen(parent) then
		parent.Visible = false
	end

	local v14 = v9
	v9.Pets = {}
	v14.Eggs = {}
	v7 = "Pets"
	SizeCells()
	scrollingFrame.CanvasPosition = Vector2.zero
	Render(true)
	UIController.open(parent)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RichieRoot()
	local stalls = workspace:FindFirstChild("Stalls")
	local sell = stalls and stalls:FindFirstChild("Sell")
	local richie = sell and sell:FindFirstChild("Richie")
	return richie and (richie.PrimaryPart or richie:FindFirstChild("HumanoidRootPart"))
end

openSell.OnClientEvent:Connect(Open)
closeBtn.Activated:Connect(function()
	SFX.Click:Play()
	Close() -- equivalent call inferred; original call site unknown
end)
GamepadUI.Watch(parent, Close, closeBtn)

local function SwitchTab(p)
	SFX.Click:Play()

	if v7 == p then
		return
	end

	v7 = p
	scrollingFrame.CanvasPosition = Vector2.zero
	Render(true)
end

pets.Activated:Connect(function()
	SFX.Click:Play()

	if v7 == "Pets" then
		return
	end

	v7 = "Pets"
	scrollingFrame.CanvasPosition = Vector2.zero
	Render(true)
end)
eggs.Activated:Connect(function()
	SFX.Click:Play()

	if v7 == "Eggs" then
		return
	end

	v7 = "Eggs"
	scrollingFrame.CanvasPosition = Vector2.zero
	Render(true)
end)
eggs.Visible = SellValue.EggSellingEnabled

local function SetSort(p)
	SFX.Click:Play()

	if v8 == p then
		return
	end

	v8 = p
	Render(true)
end

weight.Activated:Connect(function()
	SFX.Click:Play()

	if v8 == "Weight" then
		return
	end

	v8 = "Weight"
	Render(true)
end)
value.Activated:Connect(function()
	SFX.Click:Play()

	if v8 == "Value" then
		return
	end

	v8 = "Value"
	Render(true)
end)
selectAll.Activated:Connect(function()
	if flag then
		return
	end

	SFX.Click:Play()

	for k, v14 in v10[v7] do
		if not v14.Locked then
			v9[v7][k] = true
		end
	end

	Render(false)
end)
clearAll.Activated:Connect(function()
	if flag then
		return
	end

	SFX.Click:Play()
	table.clear(v9[v7])
	Render(false)
end)
sell_Ready.Activated:Connect(function()
	if flag or os.clock() - now < 1 then
		return
	end

	local v14 = {
		Pets = {},
		Eggs = {}
	}

	for k, v15 in v9 do
		for k2 in v15 do
			if v10[k][k2] then
				table.insert(v14[k], k2)
			end
		end
	end

	if #v14.Pets + #v14.Eggs == 0 then
		return
	end

	SFX.Click:Play()
	flag = true
	now = os.clock()
	count += 1
	local v15 = count
	PaintControls()
	sellItems:FireServer(v14)
	task.delay(30, function()
		if flag and count == v15 then
			flag = false
			PaintControls()
		end
	end)
end)
sellItems.OnClientEvent:Connect(function(p)
	flag = false

	if type(p) == "table" and tonumber(p.Sold) and p.Sold > 0 then
		local v14 = v9
		v9.Pets = {}
		v14.Eggs = {}
	elseif type(p) == "table" and v13[p.Reason] then
		ShowMessage(v13[p.Reason]) -- equivalent call inferred; original call site unknown
	end

	if UIController.isOpen(parent) then
		Render(true)
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function WatchContainer(instance)
	instance.ChildAdded:Connect(MarkDirty)
	instance.ChildRemoved:Connect(MarkDirty)
	flag2 = true
end

localPlayer.CharacterAdded:Connect(function(character)
	WatchContainer(character) -- equivalent call inferred; original call site unknown
	WatchContainer(localPlayer:WaitForChild("Backpack")) -- equivalent call inferred; original call site unknown
end)

if localPlayer.Character then
	WatchContainer(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

local backpack = localPlayer:FindFirstChildOfClass("Backpack")

if backpack then
	WatchContainer(backpack) -- equivalent call inferred; original call site unknown
end

RunService.Heartbeat:Connect(function()
	if not UIController.isOpen(parent) then
		return
	end

	local richieRoot = RichieRoot() -- equivalent call inferred; original call site unknown
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if richieRoot and humanoidRootPart and (humanoidRootPart.Position - richieRoot.Position).Magnitude > 30 then
		Close() -- equivalent call inferred; original call site unknown
	elseif flag2 then
		Render(true)
	end
end)