local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local PetAging = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetAging"))
local Pets = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Pets"))
local Foods = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Foods"))
local Mutations = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Mutations"))
require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetRigService"))
local PetViewportService = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetViewportService"))
local PetRenderer = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("Game"):WaitForChild("Pets"):WaitForChild("PetRenderer"))
local General = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("General"))
local PetNameRules = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetNameRules"))
local game2 = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local placePet = game2:WaitForChild("PlacePet")
local pickupPet = game2:WaitForChild("PickupPet")
local feedPet = game2:WaitForChild("FeedPet")
local rarityGradients = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("RarityGradients")
local parent = script.Parent
local holder = parent:WaitForChild("Holder")
local header = parent:FindFirstChild("Header")
local capacity = header and header:FindFirstChild("Capacity") or parent:WaitForChild("Capacity")
local placeBest = parent:WaitForChild("PlaceBest")
local petFrame = script:WaitForChild("PetFrame")
local color = Color3.fromRGB(170, 255, 0)
local color2 = Color3.fromRGB(255, 0, 0)
local v = {
	Mythic = "Mythical",
	Mythical = "Mythic"
}
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v2 = {
	FieldOfView = 40,
	Padding = 0.92
}

local function ApplyRarityGradient(parent2, rarity)
	if not parent2 then
		return
	end

	for _, uIGradient in parent2:GetChildren() do
		if uIGradient:IsA("UIGradient") then
			uIGradient:Destroy()
		end
	end

	if not rarity then
		return
	end

	local v3 = rarityGradients:FindFirstChild(rarity) or rarityGradients:FindFirstChild(v[rarity] or "")

	if v3 then
		local clone = v3:Clone()
		clone.Parent = parent2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function BuildViewport(petViewport, name)
	local success, result = pcall(function()
		return PetViewportService.Build(petViewport, name, v2)
	end)
	return success and result == true
end

local v3 = {}
local v4 = {}
local v5 = {}

local function Comma(p)
	return (tostring((math.floor(tonumber(p) or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function SetBar(petKey, bar, p)
	local v6 = v5[petKey]
	v5[petKey] = p
	local v7 = v4[petKey]

	if v7 then
		v7:Cancel()
		v4[petKey] = nil
	end

	local uDim = UDim2.new(p, 0, 1, 0)

	if not v6 or p <= v6 or p - v6 < 0.02 then
		bar.Size = uDim
		return
	end

	local tween = TweenService:Create(bar, tweenInfo, {
		Size = uDim
	})
	v4[petKey] = tween
	tween.Completed:Once(function()
		if v4[petKey] == tween then
			v4[petKey] = nil
		end
	end)
	tween:Play()
end

local function HeldFood()
	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")

	if tool and tool:HasTag("Food") and Foods[tool.Name] then
		return tool
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StyleAction(instance)
	local action = instance:FindFirstChild("Action")
	local textLabel = action and action:FindFirstChild("TextLabel")

	if not textLabel then
		return
	end

	local character = localPlayer.Character
	local tool = character and character:FindFirstChildOfClass("Tool")

	if not (tool and tool:HasTag("Food") and Foods[tool.Name]) then
		tool = nil
	end

	local v6 = tool ~= nil
	action.ImageColor3 = v6 and color or color2
	textLabel.Text = v6 and "Feed" or "Unequip"
end

local v6 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function HookAction(clone, petKey)
	local action = clone:FindFirstChild("Action")

	if not action then
		return
	end

	action.Activated:Connect(function()
		local character = localPlayer.Character
		local tool = character and character:FindFirstChildOfClass("Tool")

		if not (tool and tool:HasTag("Food") and Foods[tool.Name]) then
			tool = nil
		end

		if tool then
			feedPet:FireServer(petKey, tool.Name)
			return
		end

		if v6[petKey] then
			return
		end

		v6[petKey] = true
		task.delay(1, function()
			v6[petKey] = nil
		end)
		PetRenderer.Remove(localPlayer.UserId, petKey)
		pickupPet:FireServer(petKey)
	end)
end

local size = petFrame.PetHolder.PetName.Size
local position = petFrame.PetHolder.PetName.Position
local position2 = petFrame.Income.Position
local uDim = UDim2.fromScale(size.X.Scale, 0.331)
local uDim2 = UDim2.fromScale(position.X.Scale, 0.286)
local uDim3 = UDim2.fromScale(position2.X.Scale, 0.553)

local function BuildFrame(p)
	local clone = petFrame:Clone()
	local name = p.Model.Name
	clone.Name = p.PetKey
	clone.PetHolder.PetName.Text = name
	local pet = Pets[name]
	ApplyRarityGradient(clone.PetHolder.PetName, pet and pet.Rarity)
	ApplyRarityGradient(clone:FindFirstChild("Income"), pet and pet.Rarity)
	HookAction(clone, p.PetKey) -- equivalent call inferred; original call site unknown
	StyleAction(clone) -- equivalent call inferred; original call site unknown
	local visible = BuildViewport(clone.PetHolder.PetViewport, name) -- equivalent call inferred; original call site unknown

	if not visible then
		clone.PetHolder.PetImage.Image = pet and pet.Image or ""
	end

	clone.PetHolder.PetImage.Visible = not visible
	clone.PetHolder.PetViewport.Visible = visible
	clone.Parent = holder
	v3[p.PetKey] = clone
	return clone
end

local function UpdateFrame(data, instance)
	local age, v7, v8

	if data.BirthTime then
		age, v7, v8 = PetAging.StateFrom(data.BirthTime, nil, data)
	else
		age = tonumber(data.Model:GetAttribute("Age")) or 1
		v8 = PetAging.RequirementFor(age, data)
		v7 = 0
	end

	local v9 = data.BaseWeight and PetAging.WeightFor(data.BaseWeight, age) or tonumber(data.Model:GetAttribute("Weight")) or 1
	instance.Age.Text = "Age: " .. tostring((math.floor(tonumber(age) or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
		"^,",
		""
	)
	instance.Weight.Text = PetAging.FormatWeight(v9, true)
	local petName = data.Model:GetAttribute("PetName") or data.Model.Name
	local nickname = PetNameRules.GetNickname(localPlayer, data.PetKey)

	if nickname then
		petName = `"{nickname}"\n{petName}`
	end

	local petName2 = instance.PetHolder.PetName

	if petName2.Text ~= petName then
		petName2.Text = petName
		local size2

		if nickname then
			size2 = uDim
		else
			size2 = size
		end

		petName2.Size = size2
		local position3

		if nickname then
			position3 = uDim2
		else
			position3 = position
		end

		petName2.Position = position3
		local income = instance:FindFirstChild("Income")

		if income and income:IsA("GuiObject") then
			local position4

			if nickname then
				position4 = uDim3
			else
				position4 = position2
			end

			income.Position = position4
		end
	end

	local displayIncome = tonumber(data.DisplayIncome) or tonumber(data.Income) or 0
	local income = instance:FindFirstChild("Income")

	if income then
		income.Text = "($" .. PetRenderer.FormatCash(displayIncome) .. "/s)"
	end

	StyleAction(instance) -- equivalent call inferred; original call site unknown
	instance.EXP.Label.Text = string.format(
		"%s/%s EXP",
		tostring((math.floor(tonumber(v7) or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""),
		(tostring((math.floor(tonumber(v8) or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
	)
	SetBar(data.PetKey, instance.EXP.Bar, math.clamp(v7 / math.max(v8, 1), 0, 1))
	instance.LayoutOrder = -math.clamp(math.floor(displayIncome), 0, 1073741824)
end

local function UpdateCapacity(count)
	local maxPets = localPlayer:GetAttribute("MaxPets") or 5
	capacity.Text = count .. "/" .. maxPets

	for _, label in parent:GetDescendants() do
		if label ~= capacity and label.Name == "Capacity" and label:IsA("TextLabel") then
			label.Text = capacity.Text
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowMessage(p)
	pcall(function()
		local Handler = require(localPlayer.PlayerGui.Reusable.GameMessages.Handler)
		Handler:AddMessage(p)
	end)
end

local flag = false

local function IncomeOf(tool)
	local petName = tool:GetAttribute("PetName") or tool.Name
	local pet = Pets[petName]
	local income = pet and tonumber(pet.Income) or 0

	if income <= 0 then
		return 0
	end

	local weight = tonumber(tool:GetAttribute("Weight")) or 1
	local combinedFactor = Mutations.CombinedFactor(tool:GetAttribute("Mutation"), tool:GetAttribute("SpawnMutation"))
	return (math.floor(math.floor(income * (weight / PetAging.WeightStandardKG)) * combinedFactor))
end

local function FindPetTool(key)
	for _, v7 in { localPlayer.Character, localPlayer:FindFirstChildOfClass("Backpack") } do
		if not v7 then
			continue
		end

		for _, tool in v7:GetChildren() do
			if tool:IsA("Tool") and tool:GetAttribute("PetKey") == key then
				return tool
			end
		end
	end

	return nil
end

local function CollectOwnedPets()
	local result = {}

	for _, v7 in pairs(PetRenderer.GetAll()) do
		if v7.OwnerUserId == localPlayer.UserId and v7.Model and v7.Model.Parent then
			table.insert(result, {
				Key = v7.PetKey,
				Income = tonumber(v7.DisplayIncome) or 0,
				Placed = true,
				Position = v7.Model:GetPivot().Position
			})
		end
	end

	for _, v7 in { localPlayer.Character, (localPlayer:FindFirstChildOfClass("Backpack")) } do
		if not v7 then
			continue
		end

		for _, tool in v7:GetChildren() do
			if not (tool:IsA("Tool") and tool:HasTag("Pet") and tool:GetAttribute("PetKey")) then
				continue
			end

			table.insert(result, {
				Key = tool:GetAttribute("PetKey"),
				Income = IncomeOf(tool),
				Placed = false,
				Tool = tool
			})
		end
	end

	table.sort(result, function(a, b)
		return a.Income > b.Income
	end)
	return result
end

local function PlacementFor(humanoidRootPart, k)
	local v7 = ((k - 1) % 3 - 1) * 4
	local v8 = math.floor((k - 1) / 3) * 4 + 8
	local position3 = (humanoidRootPart.CFrame * CFrame.new(v7, 0, -v8)).Position
	local plot = General:GetPlot(localPlayer)
	local baseplate = plot and plot:FindFirstChild("Baseplate")

	if not baseplate then
		return position3
	end

	local pointToObjectSpace = baseplate.CFrame:PointToObjectSpace(position3)
	local v9 = baseplate.Size.X / 2 - 2
	local v10 = baseplate.Size.Z / 2 - 2
	return baseplate.CFrame:PointToWorldSpace((Vector3.new(
		math.clamp(pointToObjectSpace.X, -v9, v9),
		pointToObjectSpace.Y,
		(math.clamp(pointToObjectSpace.Z, -v10, v10))
	)))
end

local function PlaceBest()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
		return
	end

	local maxPets = localPlayer:GetAttribute("MaxPets") or 5
	local collectOwnedPets = CollectOwnedPets()

	if #collectOwnedPets == 0 then
		ShowMessage("No Pets To Place") -- equivalent call inferred; original call site unknown
	else
		local v8 = {}
		local v9 = {}

		for i = 1, math.min(maxPets, #collectOwnedPets) do
			v8[i] = collectOwnedPets[i]
			v9[collectOwnedPets[i].Key] = true
		end

		local positions = {}
		local count = 0

		for _, v10 in collectOwnedPets do
			if not v10.Placed or v9[v10.Key] then
				continue
			end

			table.insert(positions, v10.Position)
			PetRenderer.Remove(localPlayer.UserId, v10.Key)
			pickupPet:FireServer(v10.Key)
			count += 1
			task.wait(0.2)
		end

		local count2 = 0

		for k, v10 in v8 do
			if v10.Placed then
				continue
			end

			local tool = v10.Tool

			if not (tool and tool.Parent) then
				tool = FindPetTool(v10.Key)
			end

			if not tool then
				continue
			end

			humanoid:EquipTool(tool)
			local v11 = os.clock() + 2

			while tool.Parent ~= character and os.clock() < v11 do
				task.wait()
			end

			if tool.Parent ~= character then
				continue
			end

			local v12 = table.remove(positions, 1) or PlacementFor(humanoidRootPart, k)
			placePet:FireServer(v10.Key, v12)
			count2 += 1
			task.wait(0.2)
		end

		if count2 == 0 and count == 0 then
			ShowMessage("Best Pets Already Placed") -- equivalent call inferred; original call site unknown
		end

		if count2 > 0 and localPlayer:GetAttribute("IsRiding") ~= true then
			humanoid:UnequipTools()
		end
	end
end

placeBest.Activated:Connect(function()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local success, result = pcall(PlaceBest)

		if not success then
			warn("[PetsTracker] PlaceBest failed: " .. tostring(result))
		end

		flag = false
	end)
end)

local function RestyleAllActions()
	for _, v7 in pairs(v3) do
		if not v7.Parent then
			continue
		end

		StyleAction(v7) -- equivalent call inferred; original call site unknown
	end
end

local function HookCharacter(character)
	character.ChildAdded:Connect(function()
		task.defer(RestyleAllActions)
	end)
	character.ChildRemoved:Connect(function()
		task.defer(RestyleAllActions)
	end)
	task.defer(RestyleAllActions)
end

localPlayer.CharacterAdded:Connect(HookCharacter)

if localPlayer.Character then
	HookCharacter(localPlayer.Character)
end

local bindableEvent = Instance.new("BindableEvent")
bindableEvent.Name = "FocusPet"
bindableEvent.Parent = parent
local color3 = petFrame:WaitForChild("UIStroke").Color
local v7 = {}
bindableEvent.Event:Connect(function(p)
	task.spawn(function()
		local v8 = nil

		for _ = 1, 20 do
			v8 = v3[p]

			if v8 then
				break
			else
				task.wait(0.1)
			end
		end

		if not v8 then
			return
		end

		task.wait(0.35)
		local v9 = v8.AbsolutePosition.Y - holder.AbsolutePosition.Y + holder.CanvasPosition.Y
		local v10 = math.max(holder.AbsoluteCanvasSize.Y - holder.AbsoluteSize.Y, 0)
		local v11 = math.clamp(v9 - 10, 0, v10)
		TweenService:Create(holder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CanvasPosition = Vector2.new(0, v11)
		}):Play()
		local uIStroke = v8:FindFirstChild("UIStroke")

		if not uIStroke then
			return
		end

		local v12 = (v7[p] or 0) + 1
		v7[p] = v12
		uIStroke.Color = Color3.new(1, 1, 1)
		task.delay(1, function()
			if v7[p] == v12 and uIStroke.Parent then
				TweenService:Create(uIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Color = color3
				}):Play()
			end
		end)
	end)
end)
local uIListLayout = holder:WaitForChild("UIListLayout")
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PetRenderer.Added.Event:Connect(function(p, p2)
	if p ~= localPlayer.UserId then
		return
	end

	local v8 = PetRenderer.Get(p, p2)

	if not v8 then
		return
	end

	local v9 = v3[p2]

	if not (v9 and v9.Parent) then
		v9 = BuildFrame(v8)
	end

	pcall(UpdateFrame, v8, v9)
	local count = 0

	for _, v10 in pairs(PetRenderer.GetAll()) do
		if v10.OwnerUserId == localPlayer.UserId and v10.Model.Parent then
			count += 1
		end
	end

	UpdateCapacity(count)
end)
PetRenderer.Removed.Event:Connect(function(p, p2)
	if p ~= localPlayer.UserId then
		return
	end

	local v8 = v3[p2]

	if v8 then
		v3[p2] = nil
		v8:Destroy()
	end

	local count = 0

	for _, v9 in pairs(PetRenderer.GetAll()) do
		if v9.OwnerUserId == localPlayer.UserId and v9.Model.Parent then
			count += 1
		end
	end

	UpdateCapacity(count)
end)

for _, guiObject in holder:GetChildren() do
	if guiObject:IsA("GuiObject") then
		guiObject:Destroy()
	end
end

while true do
	local v8 = {}
	local count = 0

	for _, v9 in pairs(PetRenderer.GetAll()) do
		if not (v9.OwnerUserId == localPlayer.UserId and v9.Model.Parent) then
			continue
		end

		v8[v9.PetKey] = v9
		count += 1
	end

	local v9 = {}

	for _, guiObject in holder:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local name = guiObject.Name

		if v8[name] and not v9[name] then
			v9[name] = true
			v3[name] = guiObject
		else
			if v3[name] == guiObject then
				v3[name] = nil
			end

			guiObject:Destroy()
		end
	end

	for k, v10 in pairs(v8) do
		local v11 = v3[k]

		if not (v11 and v11.Parent) then
			v11 = BuildFrame(v10)
		end

		if pcall(UpdateFrame, v10, v11) then
			continue
		end

		v3[k] = nil
		v11:Destroy()
	end

	UpdateCapacity(count)
	task.wait(0.5)
end