local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")
local localPlayer = Players.LocalPlayer
local Pets = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Pets"))
local StringService = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("StringService"))
local PetAging = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetAging"))
local PetNameRules = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetNameRules"))
local Mutations = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Mutations"))
local rarityGradients = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("RarityGradients")
local parent = script.Parent
local petName = parent:WaitForChild("PetName")
local rarity = parent:WaitForChild("Rarity")
local speed = parent:WaitForChild("Speed")
local petImage = parent:WaitForChild("PetImage")
local mutationImage = parent:WaitForChild("MutationImage")
local mutation = parent:WaitForChild("Mutation")
local mutationGradient = mutation:WaitForChild("MutationGradient")
local weight = parent:WaitForChild("Weight")
local clone = mutation:Clone()
clone.Name = "MutationSecond"
clone.RichText = false
clone.Visible = false
clone.Parent = parent
local mutationGradient2 = clone:WaitForChild("MutationGradient")
local currentCamera = workspace.CurrentCamera

local function PetAtScreenPoint(p)
	local viewportPointToRay = currentCamera:ViewportPointToRay(p.X, p.Y)
	local raycastParams = RaycastParams.new()
	local filterDescendantsInstances = {}

	if localPlayer.Character then
		table.insert(filterDescendantsInstances, localPlayer.Character)
	end

	local renderedEggs = workspace:FindFirstChild("RenderedEggs")

	if renderedEggs then
		table.insert(filterDescendantsInstances, renderedEggs)
	end

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local raycastResult = workspace:Raycast(
		viewportPointToRay.Origin,
		viewportPointToRay.Direction * 200,
		raycastParams
	)

	if not raycastResult then
		return nil
	end

	local instance = raycastResult.Instance

	while instance and instance ~= workspace do
		if instance:HasTag("Pet") then
			return instance
		else
			instance = instance.Parent
		end
	end

	return nil
end

local scale = petName.Position.X.Scale
local scale2 = petName.Position.Y.Scale
local scale3 = mutation.Position.X.Scale
local scale4 = mutation.Position.Y.Scale
local size = mutation.Size
local text = petName.Text
local v = 0.02
local v2 = {}

local function MutationWidthScale(text2)
	if v2[text2] then
		return v2[text2]
	end

	local X = parent.AbsoluteSize.X
	local Y = mutation.AbsoluteSize.Y

	if X <= 0 or Y <= 0 then
		return nil
	end

	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Text = text2
	getTextBoundsParams.Font = mutation.FontFace
	getTextBoundsParams.Size = Y
	getTextBoundsParams.Width = 10000
	local success, result = pcall(function()
		return TextService:GetTextBoundsAsync(getTextBoundsParams)
	end)
	getTextBoundsParams:Destroy()

	if success and result then
		local v3 = (result.X + 10) / X
		v2[text2] = v3
		return v3
	else
		return nil
	end
end

local v3 = {}

local function NameWidthScale(text2)
	if v3[text2] then
		return v3[text2]
	end

	local X = parent.AbsoluteSize.X
	local absoluteSize = petName.AbsoluteSize

	if X <= 0 or absoluteSize.Y <= 0 then
		return nil
	end

	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Text = text2
	getTextBoundsParams.Font = petName.FontFace
	getTextBoundsParams.Size = absoluteSize.Y
	getTextBoundsParams.Width = absoluteSize.X
	local success, result = pcall(function()
		return TextService:GetTextBoundsAsync(getTextBoundsParams)
	end)

	if success and result then
		local v4 = math.min(result.X, absoluteSize.X) / X
		v3[text2] = v4
		return v4
	else
		return nil
	end
end

task.spawn(function()
	while parent.AbsoluteSize.X <= 0 do
		task.wait()
	end

	local nameWidthScale = NameWidthScale(text)

	if nameWidthScale then
		local v5 = 10 / math.max(parent.AbsoluteSize.X, 1)
		v = math.max(scale3 - (scale + nameWidthScale), 0.01) + v5
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyMutationGradient(p, mutationGradient3)
	local v4 = mutationGradient3 or mutationGradient
	local gradientFor = Mutations.GradientFor(p)

	if gradientFor then
		v4.Color = gradientFor
		v4.Rotation = 90
	end
end

local function ApplyRarityGradient(rarity2, p)
	local parent2 = p or rarity

	for _, uIGradient in parent2:GetChildren() do
		if uIGradient:IsA("UIGradient") then
			uIGradient:Destroy()
		end
	end

	local child = rarity2 and rarityGradients:FindFirstChild(rarity2)

	if child then
		local clone = child:Clone()
		clone.Parent = parent2
	end
end

local function NicknameOf(instance)
	local ownerUserId = instance:GetAttribute("OwnerUserId")
	local v4

	if typeof(ownerUserId) == "number" then
		v4 = Players:GetPlayerByUserId(ownerUserId) or nil
	end

	return PetNameRules.GetNickname(v4, instance:GetAttribute("PetKey"))
end

local function DisplayName(instance)
	local display = PetNameRules.Display
	local ownerUserId = instance:GetAttribute("OwnerUserId")
	local v4

	if typeof(ownerUserId) == "number" then
		v4 = Players:GetPlayerByUserId(ownerUserId) or nil
	end

	return display(PetNameRules.GetNickname(v4, instance:GetAttribute("PetKey")), instance.Name)
end

local clone2 = petName:Clone()
clone2.Name = "SpeciesName"
clone2.Visible = false
clone2.Parent = parent
local size2 = parent.Size
local size3 = petName.Size
local scale5 = size3.Y.Scale
local v4 = scale5 + size.Y.Scale
local v5 = {}
local v6 = 1
local v7 = false
local count = 0
local weight2 = nil
local v8 = nil
local v9 = 1

for _, guiObject in parent:GetChildren() do
	if not guiObject:IsA("GuiObject") or guiObject == clone2 or guiObject.Name:match("_Shadow$") then
		continue
	end

	v5[guiObject] = {
		Position = guiObject.Position,
		Size = guiObject.Size
	}
end

local function Fit(p)
	return UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale * v6, p.Y.Offset)
end

local function ApplyLayout(p)
	if p == v7 then
		return
	end

	v7 = p
	local v10 = not p and 1 or 1 + v4
	v6 = 1 / v10
	parent.Size = UDim2.new(size2.X.Scale, size2.X.Offset, size2.Y.Scale * v10, size2.Y.Offset * v10)

	for k, v11 in v5 do
		local v12 = (not p or k ~= rarity and k ~= speed) and 0 or v4
		local position = v11.Position
		k.Position = UDim2.new(position.X.Scale, position.X.Offset, (position.Y.Scale + v12) * v6, position.Y.Offset)
		local size4 = v11.Size
		k.Size = UDim2.new(size4.X.Scale, size4.X.Offset, size4.Y.Scale * v6, size4.Y.Offset)
	end

	clone2.Position = UDim2.fromScale(scale, (scale2 + scale5) * v6)
	local size5 = size3
	clone2.Size = UDim2.new(size5.X.Scale, size5.X.Offset, size5.Y.Scale * v6, size5.Y.Offset)
end

local function FillPanel(instance)
	count += 1
	local v10 = count
	weight2 = instance:GetAttribute("Weight")
	local v11 = tonumber(weight2)
	weight.Text = not v11 and "" or "[" .. StringService.Abbreviate(PetAging.InflatePetWeight(v11), 2, true) .. " KG]" or ""
	weight.Visible = v11 ~= nil
	local pet = Pets[instance.Name]
	local ownerUserId = instance:GetAttribute("OwnerUserId")
	local v12

	if typeof(ownerUserId) == "number" then
		v12 = Players:GetPlayerByUserId(ownerUserId) or nil
	end

	local nickname = PetNameRules.GetNickname(v12, instance:GetAttribute("PetKey"))
	ApplyLayout(nickname ~= nil)
	local display = PetNameRules.Display
	local ownerUserId2 = instance:GetAttribute("OwnerUserId")
	local v13

	if typeof(ownerUserId2) == "number" then
		v13 = Players:GetPlayerByUserId(ownerUserId2) or nil
	end

	v8 = display(PetNameRules.GetNickname(v13, instance:GetAttribute("PetKey")), instance.Name)
	local v14 = petName
	local text4

	if nickname then
		text4 = `"{nickname}"`
	else
		text4 = v8
	end

	v14.Text = text4
	clone2.Text = instance.Name
	clone2.Visible = nickname ~= nil
	local data = instance:FindFirstChild("Data")
	local speed2 = data and data:FindFirstChild("Speed")
	local value = speed2 and speed2.Value or pet and pet.Speed
	speed.Text = value and StringService.AddComma(value) .. " M/s" or ""
	ApplyRarityGradient(pet and pet.Rarity, speed)

	if pet and pet.HideOnIndex == true then
		rarity.Text = "???"
	elseif pet and pet.SampleSize then
		rarity.Text = StringService.FormatOdds(pet.SampleSize)
	else
		rarity.Text = ""
	end

	ApplyRarityGradient(pet and pet.Rarity)
	petImage.Image = pet and pet.Image or ""
	local mutation2 = instance:GetAttribute("Mutation")
	local spawnMutation = instance:GetAttribute("SpawnMutation")
	local labelFor = Mutations.LabelFor(mutation2, spawnMutation)
	mutation.Visible = labelFor ~= ""
	mutation.RichText = false
	mutationGradient.Enabled = true
	clone.Visible = false

	if labelFor ~= "" then
		local v16

		if mutation2 == nil then
			v16 = false
		else
			v16 = spawnMutation ~= nil
		end

		local v17 = spawnMutation or mutation2
		mutation.Text = "[" .. v17 .. "]"
		local v18 = size
		mutation.Size = UDim2.new(v18.X.Scale, v18.X.Offset, v18.Y.Scale * v6, v18.Y.Offset)
		ApplyMutationGradient(v17, nil) -- equivalent call inferred; original call site unknown

		if v16 then
			clone.Text = "+ [" .. mutation2 .. "]"
			local v19 = size
			clone.Size = UDim2.new(v19.X.Scale, v19.X.Offset, v19.Y.Scale * v6, v19.Y.Offset)
			ApplyMutationGradient(mutation2, mutationGradient2) -- equivalent call inferred; original call site unknown
		end
	end

	local name

	if nickname then
		name = instance.Name
	else
		name = v8
	end

	local v16

	if nickname then
		v16 = scale4 + scale5
	else
		v16 = scale4
	end

	local v17 = v6
	local text2 = weight.Text
	local text3 = mutation.Visible and mutation.Text or ""
	local text5 = (labelFor == "" or mutation2 == nil or spawnMutation == nil) and "" or clone.Text or ""
	task.spawn(function()
		local nameWidthScale = NameWidthScale(name)
		local v20 = text2 == "" and 0 or MutationWidthScale(text2) or 0
		local v21 = text3 == "" and 0 or MutationWidthScale(text3) or 0
		local v22 = text5 == "" and 0 or MutationWidthScale(text5) or 0

		if v10 ~= count or not (nameWidthScale and v20 and v21 and v22) then
			return
		end

		local v23 = {
			{ mutation, text3, v21 },
			{ clone, text5, v22 }
		}

		if nickname then
			weight.Visible = text2 ~= ""
			weight.Position = UDim2.fromScale(scale, (scale2 + scale5 * 2) * v17)
			weight.Size = UDim2.new(v20, 0, size.Y.Scale * v17, size.Y.Offset)
		else
			table.insert(v23, 1, { weight, text2, v20 })
		end

		local v24 = scale + nameWidthScale + v

		for _, v25 in ipairs(v23) do
			local v26 = v25[1]
			local v27 = v25[2]
			local v28 = v25[3]
			v26.Visible = v27 ~= ""

			if v27 == "" then
				continue
			end

			v26.Position = UDim2.fromScale(v24, v16 * v17)
			v26.Size = UDim2.new(v28, 0, size.Y.Scale * v17, size.Y.Offset)
			v24 += v28
		end

		v9 = math.max(1, v24, not nickname and 0 or scale + v20)
	end)
	local mutationImage2 = instance:GetAttribute("MutationImage")
	mutationImage.Visible = mutationImage2 ~= nil

	if mutationImage2 then
		mutationImage.Image = mutationImage2
	end
end

local function PlaceAt(vector)
	local guiInset = GuiService:GetGuiInset()
	local viewportSize = currentCamera.ViewportSize
	local absoluteSize = parent.AbsoluteSize
	local v10 = math.max(8, viewportSize.X - absoluteSize.X * v9 - 8)
	local v11 = math.max(absoluteSize.Y / 2 + 8, viewportSize.Y - guiInset.Y - absoluteSize.Y / 2 - 8)
	parent.Position = UDim2.fromOffset(
		math.clamp(vector.X - guiInset.X, 8, v10),
		(math.clamp(vector.Y - guiInset.Y, absoluteSize.Y / 2 + 8, v11))
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CurrentMode()
	local lastInputType = UserInputService:GetLastInputType()

	if lastInputType == Enum.UserInputType.Touch then
		return "Touch"
	end

	if lastInputType.Name:sub(1, 7) == "Gamepad" then
		return "Gamepad"
	end

	return "Mouse"
end

local v10 = nil
local v11 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function Hide()
	count += 1
	v10 = nil
	parent.Visible = false
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local vector = Vector2.new(input.Position.X, input.Position.Y)
	local petAtScreenPoint = PetAtScreenPoint(vector)

	if petAtScreenPoint then
		v10 = petAtScreenPoint
		FillPanel(petAtScreenPoint)
		parent.Visible = true
		v11 = os.clock() + 5
		PlaceAt(Vector2.new(vector.X, vector.Y - parent.AbsoluteSize.Y * 0.75))
	else
		Hide() -- equivalent call inferred; original call site unknown
	end
end)
RunService.RenderStepped:Connect(function()
	if v10 and v10.Parent then
		if v10:GetAttribute("Weight") == weight2 then
			local v12 = v10
			local display = PetNameRules.Display
			local ownerUserId = v12:GetAttribute("OwnerUserId")
			local v13

			if typeof(ownerUserId) == "number" then
				v13 = Players:GetPlayerByUserId(ownerUserId) or nil
			end

			if display(PetNameRules.GetNickname(v13, v12:GetAttribute("PetKey")), v12.Name) ~= v8 then
				FillPanel(v10)
			end
		else
			FillPanel(v10)
		end
	end

	local currentMode = CurrentMode() -- equivalent call inferred; original call site unknown

	if currentMode == "Touch" then
		if v10 then
			local now = os.clock()

			if v11 < now or not v10.Parent then
				Hide() -- equivalent call inferred; original call site unknown
			end
		end
	else
		local v13 = currentMode == "Gamepad"
		local v14 = v13 and currentCamera.ViewportSize / 2 or UserInputService:GetMouseLocation()
		local petAtScreenPoint = PetAtScreenPoint(v14)

		if petAtScreenPoint ~= v10 then
			v10 = petAtScreenPoint

			if petAtScreenPoint then
				FillPanel(petAtScreenPoint)
			end

			parent.Visible = petAtScreenPoint ~= nil
		end

		if petAtScreenPoint then
			PlaceAt(Vector2.new(v14.X + (v13 and 40 or 14), v14.Y))
		end
	end
end)