local parent = script.Parent
local holders = parent:WaitForChild("Holders")
local toggles = parent:WaitForChild("Toggles")
local mutations = toggles:FindFirstChild("Mutations")

if mutations then
	mutations:Destroy()
end

local mutationsHolder = holders:FindFirstChild("MutationsHolder")

if mutationsHolder then
	mutationsHolder:Destroy()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local gameData = ReplicatedStorage:WaitForChild("GameData")
local gameServices = ReplicatedStorage:WaitForChild("GameServices")
local Eggs = require(gameData:WaitForChild("Eggs"))
local Pets = require(gameData:WaitForChild("Pets"))
require(gameData:WaitForChild("Spawns"))
local IndexRewards = require(gameData:WaitForChild("IndexRewards"))
local EggLuckBillboard = require(gameServices:WaitForChild("EggLuckBillboard"))
local PetViewportService = require(gameServices:WaitForChild("PetViewportService"))
local FusionCycle = require(gameServices:WaitForChild("FusionCycle"))
local Main = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("FormatNumber"):WaitForChild("Main"))
local precision = Main.NumberFormatter.with():Notation(Main.Notation.compactWithSuffixThousands({
	"K",
	"M",
	"B",
	"T",
	"Qa",
	"Qi",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"Dc"
})):Precision(Main.Precision.integer():WithMinDigits(3))
local eggs = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Eggs")
local rarityGradients = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("RarityGradients")
local activeEggs = (ReplicatedStorage:FindFirstChild("ServerData") or ReplicatedStorage):WaitForChild("ActiveEggs")
local localPlayer = game.Players.LocalPlayer
local savedData = localPlayer:WaitForChild("SavedData")
local ownedPets = savedData:WaitForChild("OwnedPets")
local rebirths = savedData:WaitForChild("Rebirths")
local indexRewardStage = savedData:WaitForChild("IndexRewardStage")
local claimIndexReward = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("ClaimIndexReward")
local eggsHolder = holders:WaitForChild("EggsHolder")
local petsHolder = holders:WaitForChild("PetsHolder")
local eggs2 = toggles:WaitForChild("Eggs")
local pets = toggles:WaitForChild("Pets")
local petProgress = parent:WaitForChild("PetProgress")
local progress = petProgress:WaitForChild("Progress")
local progressBar = progress:WaitForChild("ProgressBar")
local label = progress:WaitForChild("Label")
local claim = petProgress:WaitForChild("Claim")
local reward = petProgress:WaitForChild("Reward")
local cashImage = petProgress:WaitForChild("CashImage")
local notif = parent.Parent:WaitForChild("IndexToggle"):WaitForChild("Notif")
local eggFrame = script:WaitForChild("EggFrame")
local petFrame = script:WaitForChild("PetFrame")
local v = {
	["Hydra Dragon"] = {
		Padding = 0.65,
		VerticalBias = 0.15
	},
	Komodo = {
		Padding = 0.78,
		VerticalBias = -0.28,
		HorizontalBias = 0.1
	},
	Griffin = {
		Padding = 0.4333333333,
		VerticalBias = -0.28
	},
	Dragon = {
		Padding = 0.82,
		VerticalBias = 0.18
	}
}
local color = Color3.fromRGB(255, 235, 189)
local color2 = Color3.fromRGB(47, 24, 0)
local color3 = Color3.new(0, 0, 0)
local color4 = Color3.new(1, 1, 1)
local color5 = Color3.new(1, 1, 1)
local color6 = Color3.fromRGB(200, 200, 200)

local function ApplyRarity(clone, rarity, options)
	if not rarity or rarity == "Common" then
		return
	end

	local child = rarityGradients:FindFirstChild(rarity)

	if not child then
		warn(string.format("Index: no gradient asset for rarity %q", (tostring(rarity))))
		return
	end

	clone.BackgroundColor3 = color6
	local uIGradient = clone:FindFirstChildOfClass("UIGradient")

	if uIGradient then
		uIGradient:Destroy()
	end

	local clone2 = child:Clone()
	clone2.Name = rarity
	clone2.Parent = clone

	for _, label2 in options or {} do
		if not (label2 and label2:IsA("TextLabel")) then
			continue
		end

		local uIGradient2 = label2:FindFirstChildOfClass("UIGradient")

		if uIGradient2 then
			uIGradient2:Destroy()
		end

		local clone3 = child:Clone()
		clone3.Name = rarity
		clone3.Parent = label2
	end
end

local function BuildEggViewport(viewportFrame, childName)
	local folder = eggs:FindFirstChild(childName)

	if not folder then
		return false
	end

	local model = Instance.new("Model")

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local clone = part:Clone()
		clone.Anchored = true
		clone.Parent = model
	end

	if not model:FindFirstChildWhichIsA("BasePart") then
		model:Destroy()
		return false
	end

	model.Parent = viewportFrame
	local boundingBox, v2 = model:GetBoundingBox()
	local position = boundingBox.Position
	local v3 = math.max(v2.Magnitude / 2, 0.1)
	local v4 = v3 / 0.36397023426620234 * 1.15
	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	camera.CFrame = CFrame.lookAt(position + Vector3.new(0, v3 * 0.35, v4), position)
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	return true
end

local clones = {}
local v2 = {}
local v3 = {}

local function IsGlobalEgg(p)
	return Eggs[p].MaxAmount ~= nil
end

local serverData = ReplicatedStorage:WaitForChild("ServerData")

-- equivalent calls inferred from this helper; original call sites unknown
local function EggReleased(p)
	local egg = Eggs[p]
	local releaseKey = egg and egg.ReleaseKey

	if releaseKey == nil then
		return true
	end

	local attribute = serverData:GetAttribute("ReleaseAt_" .. releaseKey)
	return typeof(attribute) == "number" and attribute <= os.time()
end

local function UpdateEggCount(p)
	local v4 = clones[p]

	if not v4 then
		return
	end

	local visible = EggReleased(p) -- equivalent call inferred; original call site unknown
	v4.Visible = visible

	if not visible then
		return
	end

	local amount

	if Eggs[p].MaxAmount ~= nil then
		amount = v2[p] or 0
	else
		amount = Eggs[p].Amount or 0
	end

	v4.Visible = amount > 0 or not v3[p]
	v4.Count.Text = string.format("x%d In Map", amount)
	v4.Count.Visible = amount > 0
	local imageColor = amount > 0 and color4 or color3
	v4.ImageLabel.ImageColor3 = imageColor
	v4.ViewportFrame.ImageColor3 = imageColor
end

local function BuildEggPage()
	local function IsCatalogued(p)
		return Eggs[p].Premium ~= true
	end

	local v4 = {}

	for k in Eggs do
		if Eggs[k].Premium ~= true then
			table.insert(v4, k)
		end
	end

	table.sort(v4, function(a, b)
		return (Eggs[a].Luck or 0) < (Eggs[b].Luck or 0)
	end)

	for k, name in v4 do
		local egg = Eggs[name]
		local clone = eggFrame:Clone()
		clone.Name = name
		clone.LayoutOrder = k
		local luckDisplay = clone:FindFirstChild("LuckDisplay")
		local luck = luckDisplay and luckDisplay:FindFirstChild("Luck")

		if luck then
			luck.Text = EggLuckBillboard.FormatLuck(egg.Luck or 0)
		end

		ApplyRarity(clone, egg.Rarity)
		local visible

		if egg.Image == nil then
			visible = false
		else
			visible = egg.Image ~= ""
		end

		if visible then
			clone.ImageLabel.Image = egg.Image
			local v7 = clone
			local v8 = name
			task.spawn(function()
				local v9 = nil
				pcall(function()
					ContentProvider:PreloadAsync({ v7.ImageLabel }, function(p, p2)
						v9 = p2
					end)
				end)

				if v9 == Enum.AssetFetchStatus.Failure and BuildEggViewport(v7.ViewportFrame, v8) then
					v7.ImageLabel.Visible = false
					v7.ViewportFrame.Visible = true
				end
			end)
		else
			visible = not BuildEggViewport(clone.ViewportFrame, name)
		end

		clone.ImageLabel.Visible = visible
		clone.ViewportFrame.Visible = not visible
		clone.Parent = eggsHolder
		clones[name] = clone
		UpdateEggCount(name)
	end
end

local function CountsForMe(child)
	local privateTo = child:GetAttribute("PrivateTo")

	if privateTo ~= nil and privateTo ~= localPlayer.UserId then
		return false
	end

	if child:GetAttribute("AdminSpawn") == true then
		local adminEggId = child:GetAttribute("AdminEggId")
		local collectedAdminEggs = localPlayer:GetAttribute("CollectedAdminEggs")
		return type(adminEggId) ~= "string" or type(collectedAdminEggs) ~= "string" or string.find(
			collectedAdminEggs,
			"," .. adminEggId .. ",",
			1,
			true
		) == nil
	else
		local collectedEggs = localPlayer:GetAttribute("CollectedEggs")
		local egg = child:GetAttribute("Egg")

		if typeof(collectedEggs) == "string" and collectedEggs ~= "" and egg and string.find(
			collectedEggs,
			egg .. ",",
			1,
			true
		) then
			return false
		end

		return true
	end
end

local flag = false

local function RecountGlobals()
	table.clear(v3)

	for k in v2 do
		v2[k] = 0
	end

	for _, child in activeEggs:GetChildren() do
		local egg = child:GetAttribute("Egg")

		if not (egg and Eggs[egg] and Eggs[egg].MaxAmount ~= nil) then
			continue
		end

		if CountsForMe(child) then
			v2[egg] = (v2[egg] or 0) + 1
		elseif child:GetAttribute("AdminSpawn") == true and (child:GetAttribute("PrivateTo") == nil or child:GetAttribute("PrivateTo") == localPlayer.UserId) then
			v3[egg] = true
		end
	end

	for k in clones do
		UpdateEggCount(k)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function QueueRecount()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		RecountGlobals()
	end)
end

serverData.AttributeChanged:Connect(function(value)
	if string.sub(value, 1, 10) == "ReleaseAt_" then
		QueueRecount() -- equivalent call inferred; original call site unknown
	end
end)
task.spawn(function()
	while true do
		local v4 = nil

		for k, v5 in serverData:GetAttributes() do
			if not (string.sub(k, 1, 10) == "ReleaseAt_" and typeof(v5) == "number" and os.time() < v5) then
				continue
			end

			if not (v4 == nil or v5 < v4) then
				continue
			end

			v4 = v5
		end

		if v4 == nil then
			break
		end

		task.wait((math.clamp(v4 - os.time(), 1, 30)))
		QueueRecount() -- equivalent call inferred; original call site unknown
	end
end)
local clones2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function HasDiscovered(p)
	return string.find(ownedPets.Value, p .. ",", 1, true) ~= nil
end

local function PaintPet(p)
	local v4 = clones2[p]

	if not v4 then
		return
	end

	local visible

	if Pets[p].FusionOnly == true then
		if rebirths.Value >= 1 then
			visible = FusionCycle.Status()
		else
			visible = false
		end
	else
		visible = true
	end

	v4.Visible = visible
	local discovered = HasDiscovered(p) -- equivalent call inferred; original call site unknown
	v4.ViewportFrame.ImageColor3 = discovered and color4 or color3
	v4.PetName.Text = discovered and p or "???"
	local uIGradient = v4.PetName:FindFirstChildOfClass("UIGradient")

	if discovered then
		local child = not uIGradient and v4:GetAttribute("Rarity") and rarityGradients:FindFirstChild(v4:GetAttribute("Rarity"))

		if child then
			local clone = child:Clone()
			clone.Parent = v4.PetName
		end
	else
		if uIGradient then
			uIGradient:Destroy()
		end

		v4.PetName.TextColor3 = color5
	end
end

local function BuildPetPage()
	local uIGridStyleLayout = petsHolder:FindFirstChildWhichIsA("UIGridStyleLayout")

	if uIGridStyleLayout then
		uIGridStyleLayout.SortOrder = Enum.SortOrder.LayoutOrder
	end

	local v4 = {}

	for k, pet in Pets do
		if pet.HideOnIndex ~= true then
			table.insert(v4, k)
		end
	end

	table.sort(v4, function(a, b)
		local sampleSize = Pets[a].SampleSize or 0
		local sampleSize2 = Pets[b].SampleSize or 0

		if sampleSize == sampleSize2 then
			return a < b
		end

		return sampleSize < sampleSize2
	end)

	for k, name in v4 do
		local pet = Pets[name]
		local clone = petFrame:Clone()
		clone.Name = name
		clone.LayoutOrder = k
		local sampleSize = clone:FindFirstChild("SampleSize")

		if sampleSize then
			sampleSize.Text = pet.FusionOnly == true and "Fused" or "1 in " .. precision:Format(pet.SampleSize or 0)
		end

		local rarity = pet.Rarity

		if pet.Rarity ~= "Common" and rarityGradients:FindFirstChild(rarity) then
			clone:SetAttribute("Rarity", rarity)
		end

		ApplyRarity(clone, pet.Rarity, { clone.PetName, sampleSize })

		if not PetViewportService.Build(clone.ViewportFrame, name, v[name], false) then
			warn(string.format("Index: no pet asset named %q", name))
			clone.ViewportFrame.Visible = false
			clone.ImageLabel.Visible = true
		end

		clone.Parent = petsHolder
		clones2[name] = clone
		PaintPet(name)
	end
end

local flag2 = false

local function CardOnScreen(p)
	local Y = petsHolder.AbsolutePosition.Y
	local v4 = Y + petsHolder.AbsoluteSize.Y
	local Y2 = p.AbsolutePosition.Y
	return Y < Y2 + p.AbsoluteSize.Y and Y2 < v4
end

local function RefreshPetAnimations()
	local visible = parent.Visible and petsHolder.Visible

	for k, v4 in clones2 do
		local v5 = visible and v4.Visible and HasDiscovered(k)

		if v5 then
			local Y = petsHolder.AbsolutePosition.Y
			local v6 = Y + petsHolder.AbsoluteSize.Y
			local Y2 = v4.AbsolutePosition.Y

			if Y < Y2 + v4.AbsoluteSize.Y then
				v5 = Y2 < v6
			else
				v5 = false
			end
		end

		PetViewportService.SetAnimated(v4.ViewportFrame, v5)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function QueuePetAnimationRefresh()
	if flag2 then
		return
	end

	flag2 = true
	task.defer(function()
		flag2 = false
		RefreshPetAnimations()
	end)
end

parent:GetPropertyChangedSignal("Visible"):Connect(QueuePetAnimationRefresh)
petsHolder:GetPropertyChangedSignal("Visible"):Connect(QueuePetAnimationRefresh)
petsHolder:GetPropertyChangedSignal("CanvasPosition"):Connect(QueuePetAnimationRefresh)
petsHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(QueuePetAnimationRefresh)
ownedPets.Changed:Connect(QueuePetAnimationRefresh)
task.spawn(function()
	local status = FusionCycle.Status()

	while script.Parent do
		task.wait(0.25)
		local status2 = FusionCycle.Status()

		if status2 == status then
			continue
		end

		status = status2

		for k in clones2 do
			PaintPet(k)
		end

		QueuePetAnimationRefresh() -- equivalent call inferred; original call site unknown
	end
end)
rebirths.Changed:Connect(function()
	for k in clones2 do
		PaintPet(k)
	end

	QueuePetAnimationRefresh() -- equivalent call inferred; original call site unknown
end)
local v4 = progressBar.Position.X.Scale - progressBar.Size.X.Scale / 2
local scale = progressBar.Size.X.Scale
local v5 = 1 - v4 * 2
local Y = progressBar.Size.Y
local Y2 = progressBar.Position.Y

-- equivalent calls inferred from this helper; original call sites unknown
local function SetBar(value)
	local v6 = scale + (v5 - scale) * math.clamp(value, 0, 1)
	progressBar.Size = UDim2.new(v6, 0, Y.Scale, Y.Offset)
	progressBar.Position = UDim2.new(v4 + v6 / 2, 0, Y2.Scale, Y2.Offset)
end

local v6 = nil
local v7 = nil

local function SetClaimHint(p)
	if p and not v6 then
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "FirstClaimHint"
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = "rbxassetid://92534278124110"
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
		imageLabel.Size = UDim2.fromScale(0.9, 0.9)
		imageLabel.Position = UDim2.fromScale(0.5, 1.35)
		imageLabel.ZIndex = claim.ZIndex + 10
		imageLabel.Parent = claim
		v7 = TweenService:Create(
			imageLabel,
			TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{
				Position = UDim2.fromScale(0.5, 1.4700000000000002)
			}
		)
		v7:Play()
		v6 = imageLabel
	elseif not p and v6 then
		if v7 then
			v7:Cancel()
			v7 = nil
		end

		v6:Destroy()
		v6 = nil
	end
end

local function RefreshProgress()
	local discoveredCount = IndexRewards.DiscoveredCount(ownedPets.Value)
	local stageAt = IndexRewards.StageAt(indexRewardStage.Value)

	if stageAt then
		label.Text = string.format("%d/%d", discoveredCount, stageAt.Goal)
		SetBar(discoveredCount / stageAt.Goal) -- equivalent call inferred; original call site unknown
		reward.Text = IndexRewards.FormatCash(stageAt.Reward)
	else
		local stage = IndexRewards.Stages[IndexRewards.Count()]
		label.Text = string.format("%d/%d", discoveredCount, stage.Goal)
		local v8 = scale + (v5 - scale) * 1
		progressBar.Size = UDim2.new(v8, 0, Y.Scale, Y.Offset)
		progressBar.Position = UDim2.new(v4 + v8 / 2, 0, Y2.Scale, Y2.Offset)
	end

	local visible

	if stageAt == nil then
		visible = false
	else
		visible = stageAt.Goal <= discoveredCount
	end

	claim.Visible = visible
	reward.Visible = stageAt ~= nil
	cashImage.Visible = stageAt ~= nil
	notif.Visible = visible
	SetClaimHint(visible and indexRewardStage.Value == 0)
end

claim.Activated:Connect(function()
	if not claim.Visible then
		return
	end

	claim.Visible = false
	claimIndexReward:FireServer()
	task.delay(1, RefreshProgress)
end)

local function ShowPage(p)
	local v8 = p == true and "Pets" or p == false and "Eggs" or p
	local v9 = v8 ~= "Eggs" and "Pets" or v8
	petsHolder.Visible = v9 == "Pets"
	eggsHolder.Visible = v9 == "Eggs"
	petProgress.Visible = v9 == "Pets"

	for k, v10 in {
		[pets] = "Pets",
		[eggs2] = "Eggs"
	} do
		local uIStroke = k:FindFirstChildOfClass("UIStroke")

		if uIStroke then
			uIStroke.Color = v9 == v10 and color or color2
		end
	end
end

pets.Activated:Connect(function()
	ShowPage("Pets")
end)
eggs2.Activated:Connect(function()
	ShowPage("Eggs")
end)
BuildEggPage()
BuildPetPage()

if not flag2 then
	flag2 = true
	task.defer(function()
		flag2 = false
		RefreshPetAnimations()
	end)
end

activeEggs.ChildAdded:Connect(QueueRecount)
activeEggs.ChildRemoved:Connect(QueueRecount)
localPlayer:GetAttributeChangedSignal("CollectedEggs"):Connect(QueueRecount)
localPlayer:GetAttributeChangedSignal("CollectedAdminEggs"):Connect(QueueRecount)
RecountGlobals()
ownedPets.Changed:Connect(function()
	for k in clones2 do
		PaintPet(k)
	end

	RefreshProgress()
end)
indexRewardStage.Changed:Connect(RefreshProgress)
RefreshProgress()
ShowPage(true)