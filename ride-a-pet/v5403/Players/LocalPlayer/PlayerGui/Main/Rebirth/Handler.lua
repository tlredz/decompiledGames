local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIController = require(ReplicatedStorage:WaitForChild("UIController"))
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local localPlayer = Players.LocalPlayer
local Rebirths = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Rebirths"))
local General = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("General"))
local Pets = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Pets"))
local rarityGradients = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("RarityGradients")
local Monetization = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Monetization"))
local Monetization2 = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Monetization"))
local PetViewportService = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("PetViewportService"))
local PetRenderer = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("Game"):WaitForChild("Pets"):WaitForChild("PetRenderer"))
local rebirth = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("Rebirth")
local savedData = localPlayer:WaitForChild("SavedData")
local cash = savedData:WaitForChild("Cash")
local rebirths = savedData:WaitForChild("Rebirths")
local SFX = SoundService:WaitForChild("SFX")
local parent = script.Parent
local notif = parent.Parent:WaitForChild("RebirthToggle"):WaitForChild("Notif")
local rebirth2 = parent:WaitForChild("Rebirth")
local skipRebirth = parent:WaitForChild("SkipRebirth")
local reset = parent:WaitForChild("Header"):WaitForChild("Reset")
local rewards = parent:WaitForChild("Rewards")
local segment2 = parent:WaitForChild("Segment2")
local label = rewards:WaitForChild("CurrentMultiplier"):WaitForChild("Label")
local label2 = rewards:WaitForChild("UpgradeMultiplier"):WaitForChild("Label")
local maxMultiplier = rewards:WaitForChild("MaxMultiplier")
local label3 = maxMultiplier:WaitForChild("Label")
local max = rewards:WaitForChild("Max")
local progressBarFrame = segment2:WaitForChild("ProgressBarFrame")
local progressBar = progressBarFrame:WaitForChild("ProgressBar")
local value = progressBarFrame:WaitForChild("Value")
local pEThOLDER = segment2:WaitForChild("pEThOLDER")
local petName = pEThOLDER:WaitForChild("PetName")
local viewport = pEThOLDER:WaitForChild("Image"):WaitForChild("Viewport")
local uIStroke = pEThOLDER:FindFirstChildOfClass("UIStroke")
local baseReward = rewards:WaitForChild("BaseReward")
local label4 = baseReward:WaitForChild("Label")
local firstChild = rewards:FindFirstChild("+")
local notEnough = rebirth2:FindFirstChild("NotEnough")
local textLabel = rebirth2:FindFirstChildWhichIsA("TextLabel")
local uIStroke2 = textLabel and textLabel:FindFirstChildOfClass("UIStroke")
local imageColor3 = rebirth2.ImageColor3
local textColor3 = textLabel and textLabel.TextColor3 or Color3.new(1, 1, 1)
local color = uIStroke2 and uIStroke2.Color or Color3.new()
local X = progressBar.AnchorPoint.X
local v = progressBar.Position.X.Scale - progressBar.Size.X.Scale * X
local v2 = math.max(1 - v * 2, 0.01)
local v3 = math.clamp(progressBar.Size.X.Scale / v2, 0, 1)
local Y = progressBar.Size.Y
local Y2 = progressBar.Position.Y
local color2 = Color3.new(0, 0, 0)
local color3 = Color3.new(1, 1, 1)

local function FormatCash(p)
	return (PetRenderer.FormatCash((math.floor(p))):gsub("(%.%d-)0+(%a)$", "%1%2"):gsub("%.(%a)$", "%1"))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCost()
	return Rebirths.GetCost(rebirths.Value)
end

local function GetMultiplier(p)
	return Rebirths.GetMultiplier(p)
end

local function TierIndex(p, list)
	return (math.clamp(p + 1, 1, (math.max(#list, 1))))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetRequiredPet(value2)
	local rebirthRequirements = General.RebirthRequirements
	local rebirthRequirements2 = General.RebirthRequirements
	return rebirthRequirements[math.clamp(value2 + 1, 1, (math.max(#rebirthRequirements2, 1)))]
end

local function GetBaseReward(p)
	local rebirthBases = General.RebirthBases
	local rebirthBases2 = General.RebirthBases
	return rebirthBases[math.clamp(p + 1, 1, (math.max(#rebirthBases2, 1)))]
end

local function GetNextBase(p)
	return General.RebirthBases[p + 1]
end

local v4 = false

local function ShowBaseReward(p)
	if p == v4 then
		return
	end

	v4 = p
	baseReward.Visible = p ~= nil

	if firstChild then
		firstChild.Visible = p ~= nil
	end

	if not p then
		return
	end

	label4.Text = p .. " Base"
	local v5 = General.Fences and General.Fences[p]

	if v5 and v5.Image then
		baseReward.Image = v5.Image
	end

	for _, uIGradient in label4:GetChildren() do
		if uIGradient:IsA("UIGradient") then
			uIGradient.Enabled = uIGradient.Name == p
		end
	end
end

local v5 = nil

local function ShowRequiredPet(text)
	if text == v5 then
		return
	end

	v5 = text
	petName.Text = text
	local pet = Pets[text]
	local rarity = pet and pet.Rarity
	local clone = rarity and petName:FindFirstChild(rarity)

	if not clone then
		local uIGradient = rarity and rarityGradients:FindFirstChild(rarity)

		if uIGradient and uIGradient:IsA("UIGradient") then
			clone = uIGradient:Clone()
			clone.Parent = petName
		end
	end

	for _, uIGradient in petName:GetChildren() do
		if uIGradient:IsA("UIGradient") then
			uIGradient.Enabled = uIGradient == clone
		end
	end

	petName.TextColor3 = Color3.new(1, 1, 1)

	if not PetViewportService.Build(viewport, text) then
		warn(string.format("Rebirth: no pet asset named %q", text))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PetBaseName(value2)
	return string.match(value2, "^(.-) %[") or value2
end

local function OwnsRequiredPet(p)
	for _, v6 in pairs(PetRenderer.GetAll()) do
		if v6.OwnerUserId == localPlayer.UserId and v6.Model.Parent and v6.Model.Name == p then
			return true
		end
	end

	local function Scan(instance)
		if not instance then
			return false
		end

		for _, tool in instance:GetChildren() do
			if tool:IsA("Tool") and tool:GetAttribute("PetKey") and PetBaseName(tool.Name) == p then
				return true
			end
		end

		return false
	end

	if Scan(localPlayer:FindFirstChildOfClass("Backpack")) or Scan(localPlayer.Character) then
		return true
	end

	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")
	local parent2 = petMountJoint and petMountJoint.Part1 and petMountJoint.Part1.Parent
	return parent2 ~= nil and parent2:GetAttribute("PetName") == p
end

local v6 = nil

local function Update()
	local value2 = rebirths.Value
	local cost = GetCost() -- equivalent call inferred; original call site unknown
	local cap = tonumber(Rebirths.Cap)
	local v8

	if cap == nil then
		v8 = false
	else
		v8 = cap <= value2
	end

	if v8 ~= v6 then
		v6 = v8
		rebirth2.Visible = not v8
		skipRebirth.Visible = not v8

		for _, guiObject in rewards:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = v8 == (guiObject == maxMultiplier or guiObject == max)
			end
		end

		if v8 then
			label3.Text = string.format("%gx", GetMultiplier(math.max(cap, value2)))
		end

		v4 = false
	end

	local text = GetRequiredPet(value2) -- equivalent call inferred; original call site unknown
	ShowRequiredPet(text)
	local ownsRequiredPet = OwnsRequiredPet(text)
	local v11 = cost <= cash.Value
	local v12 = ownsRequiredPet and v11
	label.Text = string.format("%gx", GetMultiplier(value2))
	label2.Text = string.format("%gx", GetMultiplier(value2 + 1))
	local v14

	if not v8 then
		v14 = General.RebirthBases[value2 + 1]
	end

	ShowBaseReward(v14)
	local v15 = value
	local value3 = cash.Value
	v15.Text = "$" .. PetRenderer.FormatCash((math.floor(value3))):gsub("(%.%d-)0+(%a)$", "%1%2"):gsub("%.(%a)$", "%1") .. " / $" .. PetRenderer.FormatCash((math.floor(cost))):gsub(
		"(%.%d-)0+(%a)$",
		"%1%2"
	):gsub(
		"%.(%a)$",
		"%1"
	)
	local v16 = math.clamp(cash.Value / cost, v3, 1) * v2
	progressBar.Size = UDim2.new(v16, 0, Y.Scale, Y.Offset)
	progressBar.Position = UDim2.new(v + v16 * X, 0, Y2.Scale, Y2.Offset)
	local v17 = viewport
	local imageColor

	if ownsRequiredPet then
		imageColor = color3
	else
		imageColor = color2
	end

	v17.ImageColor3 = imageColor

	if uIStroke then
		local v19 = uIStroke
		local color4

		if ownsRequiredPet then
			color4 = Color3.fromRGB(85, 255, 127)
		else
			color4 = Color3.fromRGB(255, 76, 76)
		end

		v19.Color = color4
	end

	if notEnough then
		notEnough.Visible = not v12
	end

	local function Dim(p)
		if v12 then
			return p
		end

		return (p:Lerp(Color3.new(0, 0, 0), 0.55))
	end

	local v19 = rebirth2
	local imageColor2 = imageColor3

	if not v12 then
		imageColor2 = imageColor2:Lerp(Color3.new(0, 0, 0), 0.55)
	end

	v19.ImageColor3 = imageColor2

	if textLabel then
		local v21 = textLabel
		local textColor = textColor3

		if not v12 then
			textColor = textColor:Lerp(Color3.new(0, 0, 0), 0.55)
		end

		v21.TextColor3 = textColor
	end

	if uIStroke2 then
		local v21 = uIStroke2
		local color4 = color

		if not v12 then
			color4 = color4:Lerp(Color3.new(0, 0, 0), 0.55)
		end

		v21.Color = color4
	end

	local rebirthCashHintSeen = tonumber(localPlayer:GetAttribute("RebirthCashHintSeen")) or 0
	local visible = v11 and not ownsRequiredPet and rebirthCashHintSeen < value2 + 1
	local v22 = notif

	if v12 or visible then
		visible = not v8
	end

	v22.Visible = visible
end

local function CapReached()
	local cap = tonumber(Rebirths.Cap)
	return cap ~= nil and cap <= rebirths.Value
end

local function SetSkipLuckHint()
	local rebirth3 = skipRebirth:WaitForChild("Rebirth")
	local size = rebirth3.Size
	local position = rebirth3.Position
	local luckHint = rebirth2:FindFirstChild("LuckHint")
	local luckHint2 = skipRebirth:FindFirstChild("LuckHint")

	if luckHint then
		luckHint:Destroy()
	end

	if luckHint2 then
		luckHint2:Destroy()
	end

	local clone = rebirth3:Clone()
	clone.Name = "LuckHint"
	clone.Text = "Keep Everything!"
	clone.TextColor3 = reset.TextColor3
	clone.TextScaled = true
	clone.ZIndex = rebirth3.ZIndex + 1
	clone.Size = UDim2.new(1, 0, size.Y.Scale, size.Y.Offset)
	clone.Position = UDim2.new(position.X.Scale, position.X.Offset, 1, 0)
	local uIStroke3 = clone:FindFirstChildWhichIsA("UIStroke")

	if uIStroke3 then
		uIStroke3.Color = rebirth3.TextStrokeColor3
	end

	skipRebirth.ClipsDescendants = false
	clone.Visible = true
	clone.Parent = skipRebirth
end

SetSkipLuckHint()
reset.Text = "Cash and luck reset on rebirth"
rebirth2.Activated:Connect(function()
	local cap = tonumber(Rebirths.Cap)
	local v7

	if cap == nil then
		v7 = false
	else
		v7 = cap <= rebirths.Value
	end

	if v7 then
		return
	end

	rebirth:FireServer()
end)
skipRebirth.Activated:Connect(function()
	local cap = tonumber(Rebirths.Cap)
	local v7

	if cap == nil then
		v7 = false
	else
		v7 = cap <= rebirths.Value
	end

	if v7 then
		return
	end

	local rebirthProductFor = Monetization2.RebirthProductFor(rebirths.Value)

	if rebirthProductFor then
		Monetization:OpenBuyPrompt(localPlayer, rebirthProductFor)
	end
end)
rebirth.OnClientEvent:Connect(function()
	local rebirth3 = SFX:FindFirstChild("Rebirth")

	if rebirth3 and not rebirth3:IsA("Sound") then
		rebirth3 = rebirth3:FindFirstChildWhichIsA("Sound")
	end

	if rebirth3 then
		rebirth3:Play()
	end

	UIController.close(parent)
	Update()
end)

while true do
	Update()
	task.wait(0.5)
end