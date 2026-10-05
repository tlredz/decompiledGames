local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local fusionSlots = localPlayer:WaitForChild("FusionSlots")
local Pets = require(ReplicatedStorage.GameData:WaitForChild("Pets"))
local rarityGradients = ReplicatedStorage.Assets:WaitForChild("RarityGradients")
local PetAging = require(ReplicatedStorage.GameServices:WaitForChild("PetAging"))
local StringService = require(ReplicatedStorage.GameServices:WaitForChild("StringService"))
local Mutations = require(ReplicatedStorage.GameData:WaitForChild("Mutations"))
local Fusion = require(ReplicatedStorage.GameData.Fusion)
local UIController = require(ReplicatedStorage.UIController)
local RunService = game:GetService("RunService")
local parent = script.Parent
local fusionGuide = parent.Parent:WaitForChild("FusionGuide")
local status = parent:WaitForChild("Status")

local function RefreshEstimateVisibility()
	local v = status.Visible and status.Text:match("%S") ~= nil

	for _, label in parent:GetChildren() do
		if not (label:IsA("TextLabel") and label.Text:find("Fusion time:", 1, true)) then
			continue
		end

		label.Visible = not v
	end
end

status:GetPropertyChangedSignal("Text"):Connect(RefreshEstimateVisibility)
status:GetPropertyChangedSignal("Visible"):Connect(RefreshEstimateVisibility)
RefreshEstimateVisibility()
local skipFuse = parent:WaitForChild("SkipFuse")
local v = 0
local petsToFuseHolder = parent:WaitForChild("PetsToFuseHolder")
local petFrame = script:WaitForChild("PetFrame")
local v2 = {}
local v3 = {}
parent.Visible = false
local actionsHolder = parent.Parent:WaitForChild("ActionsHolder")

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshActionsVisibility()
	actionsHolder.Visible = not parent.Visible
end

parent:GetPropertyChangedSignal("Visible"):Connect(RefreshActionsVisibility)
RefreshActionsVisibility() -- equivalent call inferred; original call site unknown

local function Remove(p)
	local child = petsToFuseHolder:FindFirstChild(p.Name)

	if child then
		for _, child2 in child:GetChildren() do
			if child2.Name == "EmptySlot" then
				child2.Visible = true
			end
		end
	end

	local v4 = v2[p]
	v2[p] = nil

	if v4 then
		v4:Destroy()
	end
end

local function Update(instance)
	Remove(instance)

	if instance.Parent ~= fusionSlots then
		return
	end

	local petName = instance:GetAttribute("PetName")

	if typeof(petName) ~= "string" then
		return
	end

	local clone = petFrame:Clone()
	clone.Name = "FusionSlot" .. instance.Name
	clone.LayoutOrder = tonumber(instance.Name) or 0
	clone:SetAttribute("PetKey", instance:GetAttribute("PetKey"))
	clone.PetName.Visible = false

	for _, guiObject in clone:GetDescendants() do
		if guiObject:IsA("GuiObject") and (guiObject.Name == "Percent" or guiObject.Name == "PercentLabel") then
			guiObject.Visible = false
		end
	end

	clone.Visible = true
	local child = petsToFuseHolder:FindFirstChild(instance.Name)

	if not child then
		clone:Destroy()
		return
	end

	clone.Parent = child
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.Position = UDim2.fromScale(0.5, 0.5)
	clone.Size = UDim2.fromScale(0.85, 0.85)

	for _, child2 in child:GetChildren() do
		if child2.Name == "EmptySlot" then
			child2.Visible = false
		end
	end

	v2[instance] = clone
	local petViewport = clone:FindFirstChild("PetViewport")

	if petViewport then
		petViewport:Destroy()
	end

	local petImage = clone:FindFirstChild("PetImage")

	if petImage then
		petImage.Visible = true
		petImage.Image = Pets[petName] and Pets[petName].Image or ""
		petImage.AnchorPoint = Vector2.new(0.5, 0.5)
		petImage.Position = UDim2.fromScale(0.5, 0.5)
		petImage.Size = UDim2.fromScale(1, 1)
		petImage.ScaleType = Enum.ScaleType.Fit
	end

	local function Label(name, _, _, text)
		local v4 = name == "SpawnMutation" and "SatchelSpawnTag" or "SatchelCaption"
		local clone2 = script:WaitForChild(v4):Clone()
		clone2.Name = name
		clone2.RichText = true
		clone2.TextScaled = true
		clone2.TextWrapped = true
		clone2.TextTruncate = Enum.TextTruncate.None
		clone2.Text = text
		clone2.Visible = text ~= ""
		clone2.ZIndex = (petImage and petImage.ZIndex or 1) + 2
		clone2.Parent = clone
	end

	local spawnMutation = instance:GetAttribute("SpawnMutation")
	local v4 = spawnMutation and Mutations.HexFor(spawnMutation)
	local text2 = v4 and string.format("<font color=\"%s\">[%s]</font>", v4, spawnMutation) or ""
	local clone2 = script:WaitForChild("SatchelSpawnTag"):Clone()
	clone2.Name = "SpawnMutation"
	clone2.RichText = true
	clone2.TextScaled = true
	clone2.TextWrapped = true
	clone2.TextTruncate = Enum.TextTruncate.None
	clone2.Text = text2
	clone2.Visible = text2 ~= ""
	clone2.ZIndex = (not petImage and 1 or petImage.ZIndex or 1) + 2
	clone2.Parent = clone
	local weight = tonumber(instance:GetAttribute("Weight")) or PetAging.WeightStandardKG
	local text3 = StringService.Abbreviate(PetAging.InflatePetWeight(weight), 2, true) .. " KG"
	local mutation = instance:GetAttribute("Mutation")
	local v7 = mutation and Mutations.HexFor(mutation)

	if v7 then
		text3 = string.format("<font color=\"%s\">[%s]</font>\n%s", v7, mutation, text3)
	end

	local clone3 = script:WaitForChild("SatchelCaption"):Clone()
	clone3.Name = "WeightCaption"
	clone3.RichText = true
	clone3.TextScaled = true
	clone3.TextWrapped = true
	clone3.TextTruncate = Enum.TextTruncate.None
	clone3.Text = text3
	clone3.Visible = text3 ~= ""
	clone3.ZIndex = (petImage and petImage.ZIndex or 1) + 2
	clone3.Parent = clone
end

local FusionRules = require(ReplicatedStorage.GameServices:WaitForChild("FusionRules"))
local fusionAction = ReplicatedStorage.Remotes.Game:WaitForChild("FusionAction")
local possiblePetsHolder = parent:WaitForChild("PossiblePetsHolder")
local fuse = parent:WaitForChild("Fuse")
local textLabel = fuse:FindFirstChild("TextLabel")
local cash = localPlayer:WaitForChild("SavedData"):WaitForChild("Cash")
local cost = fuse:WaitForChild("Cost")
local imageColor3 = fuse.ImageColor3
local fuseCost = nil

local function RefreshCost()
	local fusionStatus = fusionSlots:GetAttribute("FusionStatus")

	if fusionStatus then
		local v4 = math.max(0, (math.ceil((fusionSlots:GetAttribute("EndsAt") or 0) - workspace:GetServerTimeNow())))
		local v5

		if fusionStatus == "Result" then
			v5 = fusionSlots:GetAttribute("FusionFailed") == true
		else
			v5 = false
		end

		fuse.ImageColor3 = imageColor3
		local v6 = cost
		local text

		if fusionStatus == "Waiting" then
			text = v4 > 0 and "Fusion in progress" or "Ready to reveal"
		else
			text = v5 and "No animal received" or "Ready to collect"
		end

		v6.Text = text
	else
		local v4

		if fuseCost == nil then
			v4 = false
		else
			local value = cash.Value
			v4 = fuseCost <= value
		end

		fuse.ImageColor3 = v4 and imageColor3 or imageColor3:Lerp(Color3.new(0, 0, 0), 0.55)
		cost.Text = fuseCost and "Cost: $" .. StringService.Abbreviate(fuseCost, 2, true) or "Cost: --"
	end
end

cash:GetPropertyChangedSignal("Value"):Connect(RefreshCost)
local text4 = not textLabel and "Fuse" or textLabel.Text or "Fuse"
local clones = {}
local flag = false
local count = 0
local mutationFrame = script:WaitForChild("MutationFrame")
local v5 = {}
local v7 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function Feedback(text)
	status.Text = text
	v = os.clock() + 3
end

local v8 = 1

local function SetGuideStep(value)
	v8 = math.clamp(value, 1, 4)
	fusionGuide:SetAttribute("Step", v8)
	fusionGuide["Step" .. 1].Visible = v8 == 1
	fusionGuide["Step" .. 2].Visible = v8 == 2
	fusionGuide["Step" .. 3].Visible = v8 == 3
	fusionGuide["Step" .. 4].Visible = v8 == 4
	fusionGuide.Previous.Visible = v8 > 1
	fusionGuide.Next.TextLabel.Text = v8 == 4 and "Done" or "Next"
end

fusionGuide.Next.Activated:Connect(function()
	if v8 == 4 then
		UIController.open(parent)
	else
		SetGuideStep(v8 + 1)
	end
end)
fusionGuide.Previous.Activated:Connect(function()
	SetGuideStep(v8 - 1)
end)
SetGuideStep(1)
fusionGuide:WaitForChild("Back").Activated:Connect(function()
	UIController.open(parent)
end)
fusionGuide:WaitForChild("Close").Activated:Connect(function()
	UIController.open(parent)
end)

for k, mutation in Mutations do
	if type(mutation) == "table" and (mutation.WeatherName or k == "Magma") then
		table.insert(v7, k)
	end
end

table.sort(v7, function(a, b)
	return (Mutations[a].StatMultiplier or 0) < (Mutations[b].StatMultiplier or 0)
end)

local function MakeOddsRows(p, items, field)
	local scrollingFrame = parent.Extra[p].ScrollingFrame
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.CanvasSize = UDim2.new()

	for _, guiObject in scrollingFrame:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = false
		end
	end

	for k, item in items do
		local clone = mutationFrame:Clone()
		clone.Name = item
		clone.LayoutOrder = k
		clone.Visible = false
		local v9 = Mutations.ColorFor(item) or Color3.new(1, 1, 1)
		clone.ImageColor3 = v9
		clone.TextLabel.TextColor3 = v9
		clone.TextLabel.Text = item .. " - 0%"
		clone.TextLabel.RichText = false

		if item == "Rainbow" then
			for _, image in { clone, clone.TextLabel } do
				local uIGradient = Instance.new("UIGradient")
				uIGradient.Color = Mutations.GradientFor(item)

				if image:IsA("ImageLabel") then
					image.ImageColor3 = Color3.new(1, 1, 1)
				else
					image.TextColor3 = Color3.new(1, 1, 1)
				end

				uIGradient.Parent = image
			end
		end

		clone.Parent = scrollingFrame
		table.insert(v5, {
			Row = clone,
			Name = item,
			Field = field
		})
	end
end

MakeOddsRows("Mutation", { "Gold", "Diamond", "Rainbow" }, "SpawnMutation")
MakeOddsRows("Traits", v7, "Mutation")

local function RefreshExtra(preview)
	for _, v9 in v5 do
		local v10 = not preview and 0 or preview.Mutations[v9.Field][v9.Name] or 0
		v9.Row.Visible = v10 > 0
		v9.Row:SetAttribute("Chance", v10)
		v9.Row.TextLabel.Text = string.format(
			"%s - %s%%",
			v9.Name,
			string.format("%.2f", v10 * 100):gsub("0+$", ""):gsub("%.$", "")
		)
	end
end

for i = 1, Fusion.RequiredPets do
	local child = petsToFuseHolder:WaitForChild((tostring(i)))
	child.Active = false
	child.Selectable = false
	child.Interactable = false

	for _, guiObject in child:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = guiObject.Name == "EmptySlot"
		end
	end
end

skipFuse.Activated:Connect(function()
	if fusionSlots:GetAttribute("FusionStatus") == "Waiting" then
		fusionAction:FireServer("SkipPurchase")
	end
end)

for _, guiObject in possiblePetsHolder:GetChildren() do
	if guiObject:IsA("GuiObject") then
		guiObject.Visible = false
	end
end

local possibleFuse = parent:FindFirstChild("PossibleFuse")

if possibleFuse then
	possibleFuse.Visible = false
end

for _, label in parent:GetChildren() do
	if not (label:IsA("TextLabel") and label.Text:find("Fusion time:", 1, true)) then
		continue
	end

	label.Text = "Fusion time: 4.5s"
end

local function RefreshStatus()
	local fusionStatus = fusionSlots:GetAttribute("FusionStatus")
	local v9

	if fusionStatus == "Result" then
		v9 = fusionSlots:GetAttribute("FusionFailed") == true
	else
		v9 = false
	end

	local count2 = #fusionSlots:GetChildren()
	local v10 = math.max(0, (math.ceil((fusionSlots:GetAttribute("EndsAt") or 0) - workspace:GetServerTimeNow())))
	skipFuse.Visible = fusionStatus == "Waiting" and v10 > 0
	cost.Visible = not skipFuse.Visible
	local text

	if fusionStatus == "Waiting" then
		text = not (v10 > 0) and "Reveal animal" or string.format("%dm %02ds", math.floor(v10 / 60), v10 % 60) or "Reveal animal"
	elseif fusionStatus == "Result" then
		text = v9 and "Continue" or "Collect animal"
	else
		text = count2 < Fusion.RequiredPets and string.format("Add %d animals", Fusion.RequiredPets - count2) or text4
	end

	if textLabel and not flag then
		textLabel.Text = text
	end

	local active = not flag

	if active then
		if fusionStatus == "Waiting" and v10 == 0 or fusionStatus == "Result" then
			active = true
		else
			active = not fusionStatus

			if active then
				if fusionSlots:GetAttribute("Ready") == true and fuseCost ~= nil then
					local value = cash.Value
					active = fuseCost <= value
				else
					active = false
				end
			end
		end
	end

	fuse.Active = active
	fuse.AutoButtonColor = false

	if parent.Visible and not parent:GetAttribute("UIClosing") then
		fuse.ImageTransparency = active and 0 or 0.5
	end

	RefreshCost()
	local now = os.clock()

	if v <= now then
		local v15 = status
		local text2

		if fusionStatus == "Waiting" then
			text2 = v10 > 0 and "Your Pets are fusing, wait for the timer to finish" or "Your fused pet is ready. Reveal it now!"
		else
			text2 = fusionStatus == "Result" and (v9 and "Fusion failed. All four animals were consumed." or "Your fused animal is ready. Collect it from the machine.") or ""
		end

		v15.Text = text2
	end
end

local function RefreshOutcomes()
	for _, v9 in clones do
		v9:Destroy()
	end

	table.clear(clones)
	local attributes = {}

	for i = 1, Fusion.RequiredPets do
		local child = fusionSlots:FindFirstChild((tostring(i)))

		if child then
			table.insert(attributes, child:GetAttributes())
		end
	end

	local preview = FusionRules.Preview(attributes)
	RefreshExtra(preview)
	fuseCost = preview and preview.FuseCost
	RefreshCost()

	for _, label in parent:GetChildren() do
		if not (label:IsA("TextLabel") and label.Text:find("Fusion time:", 1, true)) then
			continue
		end

		local fuseTime = preview and preview.FuseTime
		label.Text = fuseTime and string.format("Fusion time: %dm %ds", math.floor(fuseTime / 60), fuseTime % 60) or "Fusion time: --"
	end

	local possible_Fusion = parent:FindFirstChild("Possible_Fusion")

	if possible_Fusion then
		for _, guiObject in possible_Fusion:GetChildren() do
			if guiObject:IsA("TextLabel") and guiObject.Text == "Select pets to preview fusions" then
				guiObject.Visible = preview == nil
			end

			if guiObject.Name == "Nothing" and guiObject:IsA("GuiObject") then
				guiObject.Visible = preview == nil
			end
		end
	end

	RefreshStatus()

	if not preview then
		return
	end

	local displayOutcomes = FusionRules.GetDisplayOutcomes(preview)

	for _, child in possiblePetsHolder:GetChildren() do
		if child:IsA("UIListLayout") or child:IsA("UIGridLayout") then
			child.SortOrder = Enum.SortOrder.LayoutOrder
		end
	end

	for k, displayOutcome in displayOutcomes do
		local clone = petFrame:Clone()
		clone.Size = UDim2.fromScale(math.min(0.23, 0.92 / #displayOutcomes), 0.95)
		clone.Name = "Outcome" .. k
		clone.LayoutOrder = k
		clone:SetAttribute("PetName", displayOutcome.PetName)
		clone:SetAttribute("Chance", displayOutcome.Chance)
		local petViewport = clone:FindFirstChild("PetViewport")

		if petViewport then
			petViewport:Destroy()
		end

		local petImage = clone.PetImage
		local pet = Pets[displayOutcome.PetName]
		petImage.Image = not pet and "" or pet.Image or ""
		petImage.Visible = true
		petImage.Position = UDim2.fromScale(0.5, 0.5)
		petImage.Size = UDim2.fromScale(0.94, 0.72)
		petImage.ScaleType = Enum.ScaleType.Fit

		if displayOutcome.IsFailure then
			petImage.Visible = false
		end

		clone.PetName.Text = displayOutcome.PetName
		clone.PetName.Visible = true
		clone.PetName.TextColor3 = Color3.new(1, 1, 1)

		for _, uIGradient in clone.PetName:GetChildren() do
			if uIGradient:IsA("UIGradient") then
				uIGradient:Destroy()
			end
		end

		local child = pet and rarityGradients:FindFirstChild(pet.Rarity or "")

		if child then
			local clone_2 = child:Clone()
			clone_2.Parent = clone.PetName
		end

		clone.Percent.Visible = true
		clone.Percent.Text = FusionRules.FormatOutcomeChance(preview, displayOutcome)
		clone.Percent.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Percent.Position = UDim2.fromScale(0.5, 0.88)
		clone.Percent.Size = UDim2.fromScale(0.94, 0.22)
		clone.Percent.ZIndex = petImage.ZIndex + 2
		clone.Visible = true
		clone.Parent = possiblePetsHolder
		table.insert(clones, clone)
	end
end

local function RequestFuse()
	if flag then
		return
	end

	local fusionStatus = fusionSlots:GetAttribute("FusionStatus")

	if fusionStatus == "Waiting" then
		if workspace:GetServerTimeNow() < (fusionSlots:GetAttribute("EndsAt") or 1e999) then
			return
		end

		flag = true
		localPlayer:SetAttribute("FusionPresentationPending", true)
		fusionAction:FireServer("Fuse")
		parent.Visible = false
		task.delay(8, function()
			flag = false
			localPlayer:SetAttribute("FusionPresentationPending", false)
			RefreshStatus()
		end)
	elseif fusionStatus == "Result" then
		if fusionSlots:GetAttribute("FusionFailed") == true then
			fusionAction:FireServer("Claim", fusionSlots:GetAttribute("FusionResultKey"))
			return
		end

		local fusionResult = localPlayer:FindFirstChild("FusionResult")
		local pet = fusionResult and fusionResult:FindFirstChild("Pet")

		if pet then
			fusionAction:FireServer("Claim", pet:GetAttribute("PetKey"))
		end
	elseif fusionSlots:GetAttribute("Ready") == true then
		local attributes = {}

		for i = 1, Fusion.RequiredPets do
			local child = fusionSlots:FindFirstChild((tostring(i)))

			if not child then
				return
			end

			table.insert(attributes, child:GetAttributes())
		end

		local preview = FusionRules.Preview(attributes)

		if not preview then
			return
		end

		if cash.Value < preview.FuseCost then
			fusionAction:FireServer("Start")
			return
		end

		flag = true
		parent.Visible = false
		count += 1
		local v9 = count

		if textLabel then
			textLabel.Text = "Fusing..."
		end

		RefreshOutcomes()
		fusionAction:FireServer("Start")
		task.delay(8, function()
			if flag and v9 == count then
				flag = false
				localPlayer:SetAttribute("FusionPresentationPending", false)

				if textLabel then
					textLabel.Text = text4
				end

				RefreshOutcomes()
			end
		end)
	else
		Feedback("Place four animals in the machine first.") -- equivalent call inferred; original call site unknown
	end
end

fuse.Activated:Connect(RequestFuse)
fusionAction.OnClientEvent:Connect(function(p, p2, value)
	if p == "Claim" or p == "Fuse" then
		flag = false

		if p2 then
			parent.Visible = false
		else
			Feedback(value or "Try again.") -- equivalent call inferred; original call site unknown
		end

		RefreshStatus()
	else
		if p ~= "Start" then
			return
		end

		flag = false
		count += 1
		local v9 = count

		if p2 then
			parent.Visible = false

			if textLabel then
				textLabel.Text = text4
			end
		else
			localPlayer:SetAttribute("FusionPresentationPending", false)
			parent.Visible = true
			local v10 = value == "Not Enough Cash To Fuse"

			if textLabel then
				textLabel.Text = v10 and "Not Enough" or value or "Try again"
			end

			task.delay(v10 and 1 or 3, function()
				if v9 == count and textLabel then
					textLabel.Text = text4
				end
			end)
		end

		RefreshOutcomes()
	end
end)
fusionSlots:GetAttributeChangedSignal("Ready"):Connect(RefreshOutcomes)
fusionSlots:GetAttributeChangedSignal("FusionStatus"):Connect(RefreshOutcomes)
fusionSlots:GetAttributeChangedSignal("FusionFailed"):Connect(RefreshOutcomes)
fusionSlots:GetAttributeChangedSignal("FusionPreviewJSON"):Connect(RefreshOutcomes)
cash:GetPropertyChangedSignal("Value"):Connect(RefreshStatus)
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent.Visible then
		RefreshOutcomes()
	end
end)
local now = 0
RunService.Heartbeat:Connect(function()
	if parent.Visible and os.clock() - now >= 0.25 then
		now = os.clock()
		RefreshStatus()
	end
end)

local function Watch(p)
	if v3[p] then
		return
	end

	v3[p] = p.AttributeChanged:Connect(function()
		Update(p)
		RefreshOutcomes()
	end)
	Update(p)
	RefreshOutcomes()
end

fusionSlots.ChildAdded:Connect(Watch)
fusionSlots.ChildRemoved:Connect(function(child)
	if v3[child] then
		v3[child]:Disconnect()
		v3[child] = nil
	end

	Remove(child)
	RefreshOutcomes()
end)

for _, child in fusionSlots:GetChildren() do
	if v3[child] then
		continue
	end

	local v9 = child
	v3[child] = child.AttributeChanged:Connect(function()
		Update(v9)
		RefreshOutcomes()
	end)
	Update(child)
	RefreshOutcomes()
end

RefreshOutcomes()