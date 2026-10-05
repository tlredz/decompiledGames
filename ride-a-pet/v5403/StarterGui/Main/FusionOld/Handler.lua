local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local fusionSlots = localPlayer:WaitForChild("FusionSlots")
local Pets = require(ReplicatedStorage.GameData:WaitForChild("Pets"))
local rarityGradients = ReplicatedStorage.Assets:WaitForChild("RarityGradients")
local PetAging = require(ReplicatedStorage.GameServices:WaitForChild("PetAging"))
local StringService = require(ReplicatedStorage.GameServices:WaitForChild("StringService"))
local Mutations = require(ReplicatedStorage.GameData:WaitForChild("Mutations"))
local parent = script.Parent
local petsToFuseHolder = parent:WaitForChild("PetsToFuseHolder")
local petFrame = script:WaitForChild("PetFrame")
local v = {}
local v2 = {}
parent.Visible = false

-- equivalent calls inferred from this helper; original call sites unknown
local function Remove(p)
	local v3 = v[p]
	v[p] = nil

	if v3 then
		v3:Destroy()
	end
end

local function Update(instance)
	Remove(instance) -- equivalent call inferred; original call site unknown

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
	clone.Parent = petsToFuseHolder
	v[instance] = clone
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
		local v3 = name == "SpawnMutation" and "SatchelSpawnTag" or "SatchelCaption"
		local clone2 = script:WaitForChild(v3):Clone()
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
	local v3 = spawnMutation and Mutations.HexFor(spawnMutation)
	local text2 = v3 and string.format("<font color=\"%s\">[%s]</font>", v3, spawnMutation) or ""
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
	local v6 = mutation and Mutations.HexFor(mutation)

	if v6 then
		text3 = string.format("<font color=\"%s\">[%s]</font>\n%s", v6, mutation, text3)
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
local feed = parent:WaitForChild("Feed")
local textLabel = feed:FindFirstChild("TextLabel")
local text4 = not textLabel and "Fuse" or textLabel.Text or "Fuse"
local clones = {}
local v4 = false
local count = 0

local function RefreshOutcomes()
	for _, v5 in clones do
		v5:Destroy()
	end

	table.clear(clones)
	local attributes = {}

	for i = 1, 4 do
		local child = fusionSlots:FindFirstChild((tostring(i)))

		if child then
			table.insert(attributes, child:GetAttributes())
		end
	end

	local preview = FusionRules.Preview(attributes)
	local v5

	if preview == nil or fusionSlots:GetAttribute("Ready") ~= true then
		v5 = false
	else
		v5 = not v4
	end

	feed.Active = v5
	feed.AutoButtonColor = v5
	feed.ImageTransparency = v5 and 0 or 0.5

	if not preview then
		return
	end

	for k, outcome in preview.Outcomes do
		local clone = petFrame:Clone()
		clone.Name = "Outcome" .. k
		clone.LayoutOrder = k
		clone:SetAttribute("PetName", outcome.PetName)
		clone:SetAttribute("Chance", outcome.Chance)
		local petViewport = clone:FindFirstChild("PetViewport")

		if petViewport then
			petViewport:Destroy()
		end

		local petImage = clone.PetImage
		petImage.Image = Pets[outcome.PetName].Image or ""
		petImage.Visible = true
		petImage.Position = UDim2.fromScale(0.5, 0.5)
		petImage.Size = UDim2.fromScale(0.94, 0.72)
		petImage.ScaleType = Enum.ScaleType.Fit
		clone.PetName.Text = outcome.PetName
		clone.PetName.Visible = true
		clone.PetName.TextColor3 = Color3.new(1, 1, 1)

		for _, uIGradient in clone.PetName:GetChildren() do
			if uIGradient:IsA("UIGradient") then
				uIGradient:Destroy()
			end
		end

		local child = rarityGradients:FindFirstChild(Pets[outcome.PetName].Rarity or "")

		if child then
			local clone_2 = child:Clone()
			clone_2.Parent = clone.PetName
		end

		clone.Percent.Visible = true
		clone.Percent.Text = string.format("%.2f%%", outcome.Chance * 100)
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
	if v4 or fusionSlots:GetAttribute("Ready") ~= true then
		return
	end

	local attributes = {}

	for i = 1, 4 do
		local child = fusionSlots:FindFirstChild((tostring(i)))

		if not child then
			return
		end

		table.insert(attributes, child:GetAttributes())
	end

	if not FusionRules.Preview(attributes) then
		return
	end

	v4 = true
	parent.Visible = false
	localPlayer:SetAttribute("FusionPresentationPending", true)
	count += 1
	local v5 = count

	if textLabel then
		textLabel.Text = "Fusing..."
	end

	RefreshOutcomes()
	fusionAction:FireServer("Fuse")
	task.delay(8, function()
		if v4 and v5 == count then
			v4 = false
			localPlayer:SetAttribute("FusionPresentationPending", false)

			if textLabel then
				textLabel.Text = text4
			end

			RefreshOutcomes()
		end
	end)
end

feed.Activated:Connect(RequestFuse)
fusionAction.OnClientEvent:Connect(function(p, p2, value)
	if p ~= "Fuse" then
		return
	end

	v4 = false
	count += 1
	local v5 = count

	if p2 then
		parent.Visible = false

		if textLabel then
			textLabel.Text = text4
		end
	else
		localPlayer:SetAttribute("FusionPresentationPending", false)
		parent.Visible = true

		if textLabel then
			textLabel.Text = value or "Try again"
		end

		task.delay(3, function()
			if v5 == count and textLabel then
				textLabel.Text = text4
			end
		end)
	end

	RefreshOutcomes()
end)
fusionSlots:GetAttributeChangedSignal("Ready"):Connect(RefreshOutcomes)

local function Watch(p)
	if v2[p] then
		return
	end

	v2[p] = p.AttributeChanged:Connect(function()
		Update(p)
		RefreshOutcomes()
	end)
	Update(p)
	RefreshOutcomes()
end

fusionSlots.ChildAdded:Connect(Watch)
fusionSlots.ChildRemoved:Connect(function(child)
	if v2[child] then
		v2[child]:Disconnect()
		v2[child] = nil
	end

	Remove(child) -- equivalent call inferred; original call site unknown
	RefreshOutcomes()
end)

for _, child in fusionSlots:GetChildren() do
	if v2[child] then
		continue
	end

	local v5 = child
	v2[child] = child.AttributeChanged:Connect(function()
		Update(v5)
		RefreshOutcomes()
	end)
	Update(child)
	RefreshOutcomes()
end

RefreshOutcomes()