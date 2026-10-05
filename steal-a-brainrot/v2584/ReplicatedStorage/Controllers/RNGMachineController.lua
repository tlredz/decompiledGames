local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Animals = require(ReplicatedStorage.Shared.Animals)
local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
local CustomRichTextController = require(ReplicatedStorage.Controllers.CustomRichTextController)
local AnimalOverheadController = require(ReplicatedStorage.Controllers.AnimalOverheadController)
local BackpackController = require(ReplicatedStorage.Controllers.BackpackController)
local FastOverheadController = require(ReplicatedStorage.Controllers.FastOverheadController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local Net = require(ReplicatedStorage.Packages.Net)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Spr = require(ReplicatedStorage.Packages.Spr)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
require(ReplicatedStorage.Packages.Synchronizer.Channel)
local Trove = require(ReplicatedStorage.Packages.Trove)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local LuckIcons = require(ReplicatedStorage.Datas.LuckIcons)
local Mutations = require(ReplicatedStorage.Datas.Mutations)
local RNGMachineData = require(ReplicatedStorage.Datas.RNGMachineData)
local RNGMachineLimitedStockData = require(ReplicatedStorage.Datas.RNGMachineLimitedStockData)
local VFX = require(ReplicatedStorage.Shared.VFX)
local remoteFunction = Net:RemoteFunction("RNGMachineService/Buy")
local remoteFunction2 = Net:RemoteFunction("RNGMachineService/BuySkill")
local remoteEvent = Net:RemoteEvent("RNGMachineService/SpinStage")
local remoteEvent2 = Net:RemoteEvent("RNGMachineService/LuckExplosion")
local class = {}
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v = ReplicatorClient.get((`RNGMachine_{localPlayer.UserId}`))
local rNGMachineActivity = ReplicatorClient.get("RNGMachineActivity")
local animals = ReplicatedStorage.Animations.Animals
local rNGMachine = ReplicatedStorage.Sounds.Sfx["RNG Machine"]
local v2 = nil
local frozen = table.freeze({
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII"
})
local frozen2 = table.freeze({
	"Luck",
	"Speed",
	"GoldMutation",
	"DiamondMutation",
	"RainbowMutation",
	"EventMutation"
})
local _2x = LuckIcons["2x"]
local icon = Mutations.Crystal.Icon
local frozen3 = table.freeze({
	"rbxassetid://109197687749885",
	"rbxassetid://140082451010054",
	"rbxassetid://118043092840867",
	"rbxassetid://99161525590490",
	"rbxassetid://92307396985409",
	"rbxassetid://102896229500021",
	"rbxassetid://75095065291971"
})
local frozen4 = table.freeze({ Mutations.Gold.Icon, "rbxassetid://92030344139640", "rbxassetid://89363812265296" })
local frozen5 = table.freeze({ Mutations.Diamond.Icon, "rbxassetid://102810669205215", "rbxassetid://137640109371878" })
local frozen6 = table.freeze({ Mutations.Rainbow.Icon, "rbxassetid://81050017254533", "rbxassetid://89484412421203" })
local frozen7 = table.freeze({
	"rbxassetid://116329858308535",
	"rbxassetid://111075055814781",
	"rbxassetid://131490709703976",
	"rbxassetid://135858566074631",
	"rbxassetid://127684169481211",
	"rbxassetid://117312654669919",
	"rbxassetid://100757263065120"
})
local vector = Vector2.new(2400, 2200)
local vector2 = Vector2.new(1200, 1400)
local anchorPoint = vector2 / vector
local vector3 = Vector2.new(145, 145)
local color = Color3.fromRGB(138, 138, 138)
local color2 = Color3.fromRGB(65, 65, 65)
local v4 = vector3.X / 1.1
local v5 = vector3.X * 0.75
local v6 = v4 * 0.5
local frozen8 = table.freeze({
	Luck = table.freeze({
		vector2 + Vector2.new(-v5, v6),
		vector2 + Vector2.new(-v5 * 2, 0),
		vector2 + Vector2.new(-v5 * 3, v6),
		vector2 + Vector2.new(-v5 * 3, -v6),
		vector2 + Vector2.new(-v5 * 4, 0),
		vector2 + Vector2.new(-v5 * 5, -v6),
		vector2 + Vector2.new(-v5 * 6, 0)
	}),
	Speed = table.freeze({
		vector2 + Vector2.new(0, v4),
		vector2 + Vector2.new(v5, v4 + v6),
		vector2 + Vector2.new(0, v4 * 2),
		vector2 + Vector2.new(v5, v4 * 2 + v6),
		vector2 + Vector2.new(v5 * 2, v4 * 2),
		vector2 + Vector2.new(v5 * 2, v4 * 3),
		vector2 + Vector2.new(v5 * 3, v4 * 3 + v6)
	}),
	GoldMutation = table.freeze({ vector2, vector2 + Vector2.new(0, -v4), vector2 + Vector2.new(v5, -v6) }),
	DiamondMutation = table.freeze({
		vector2 + Vector2.new(v5 * 2, -v4),
		vector2 + Vector2.new(v5, -v4 - v6),
		vector2 + Vector2.new(0, -v4 * 2)
	}),
	RainbowMutation = table.freeze({
		vector2 + Vector2.new(0, -v4 * 3),
		vector2 + Vector2.new(v5, -v4 * 2 - v6),
		vector2 + Vector2.new(v5 * 2, -v4 * 2)
	})
})
local frozen9 = table.freeze({
	vector2,
	vector2 + Vector2.new(v5, -v6),
	vector2 + Vector2.new(0, -v4),
	vector2 + Vector2.new(-v5, -v4 - v6),
	vector2 + Vector2.new(0, -v4 * 2),
	vector2 + Vector2.new(v5, -v4 * 2 - v6),
	vector2 + Vector2.new(0, -v4 * 3)
})
local v7 = vector2 + Vector2.new(v5 * 2, -v4 * 3)
local v8 = vector2 + Vector2.new(-v5, v6)
local v9 = nil
local v10 = nil
local v11 = "Main"
local flag = false
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local scale3 = 0.82
local zero = Vector2.zero
local v17 = 0.82
local v18 = {}
local v19 = nil
local flag2 = false
local count = 0
local v20 = false
local v21 = nil
local zero2 = Vector2.zero
local zero3 = Vector2.zero
local count2 = 0
local v22 = false
local v23 = {
	PrivateStagePayload = nil,
	ActivityData = nil,
	SelectedIdentity = nil,
	SelectedOwnerUserId = nil,
	SelectedState = nil,
	StageVisualEndsAt = 0,
	ActiveSpinner = nil,
	ActiveTween = nil,
	ActiveConnection = nil,
	SpinningText = nil,
	SpinningTextToken = 0,
	LatestOfferExpiresAt = 0,
	OptimisticSpinToken = 0
}
local v24 = nil
local v25 = {}
local v26 = nil
local v27 = nil
local v28 = nil
local resultName = nil
local v29 = nil
local v30 = nil
local v31 = nil
local v32 = {
	Entries = {},
	Order = {},
	PlayerPreviewVisible = false
}
local v33 = {}
local v34 = {}
local v35 = {}
local v36 = {}
local v37 = {}
local v38 = {}
local v39 = nil

local function updateMutationScreen(p: string?)
	if p == nil or p == "Normal" then
		p = nil
	end

	v29 = p
	local displayWithRichText = v29 or ""
	local mutation = Mutations[displayWithRichText]

	if mutation then
		displayWithRichText = mutation.DisplayWithRichText or mutation.DisplayText
	end

	if v30 then
		CustomRichTextController.apply(v30, displayWithRichText, {
			attachToInstance = true
		})
	end

	if v31 then
		v31.LocalTransparencyModifier = v29 and 1 or 0
	end
end

function v32.UpdatePosition()
	local v40 = v32.PlayerPreviewVisible and 0.62 or 0.43

	for k, v41 in v32.Order do
		local entry = v32.Entries[v41]

		if not entry then
			continue
		end

		entry.Display.Size = UDim2.new(entry.Display.Size.X.Scale, entry.Display.Size.X.Offset, 0.2, 0)
		entry.Display.Position = UDim2.fromScale(entry.Display.Position.X.Scale, v40 + (k - 1) * 0.17)
	end
end

function v32:Resize(p: number)
	self.ResizeToken += 1
	local resizeToken = self.ResizeToken
	local display = self.Display
	local image = self.Image
	task.spawn(function()
		local parent = display.Parent

		if resizeToken ~= self.ResizeToken or not (parent and parent:IsA("BillboardGui")) then
			return
		end

		local getTextBoundsParams = Instance.new("GetTextBoundsParams")
		getTextBoundsParams.Text = display.Text
		getTextBoundsParams.Font = display.FontFace
		getTextBoundsParams.RichText = display.RichText
		getTextBoundsParams.Size = 100
		local success, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)
		getTextBoundsParams:Destroy()

		if not success or textBoundsAsync.Y <= 0 then
			return
		end

		local v40 = parent.Size.Y.Scale / parent.Size.X.Scale
		local v41 = 0.2 * (textBoundsAsync.X / textBoundsAsync.Y) * v40
		local v42 = 0.2 * v40
		local v43 = v42 * 0.08
		local v44 = (v32.PlayerPreviewVisible and 0.62 or 0.43) + (p - 1) * 0.17
		display.Size = UDim2.fromScale(v41, 0.2)
		display.Position = UDim2.fromScale(0.5 + (v42 + v43) / 2, v44)
		image.AnchorPoint = Vector2.new(1, 0.5)
		image.Position = UDim2.fromScale(-v43 / v41, 0.5)
		image.Size = UDim2.fromScale(1, 1)
	end)
end

function v32.SetPlayerPreviewVisible(playerPreviewVisible: boolean)
	v32.PlayerPreviewVisible = playerPreviewVisible
	v32.GetBillboard()
	v32.UpdatePosition()
end

function v32.Refresh()
	for k, v40 in v32.Order do
		local entry = v32.Entries[v40]

		if entry then
			v32.Resize(entry, k)
		end
	end

	v32.UpdatePosition()
end

function v32.GetBillboard()
	local rNGMachine2 = workspace:FindFirstChild("RNGMachine")
	local overhead = rNGMachine2 and rNGMachine2:FindFirstChild("Overhead")
	local billboardGui = overhead and overhead:FindFirstChild("BillboardGui")

	if not (billboardGui and billboardGui:IsA("BillboardGui")) then
		return nil
	end

	local displayText = billboardGui:FindFirstChild("DisplayText")

	if displayText and displayText:IsA("TextLabel") then
		displayText.Position = UDim2.fromScale(0.5, 0.08)
		displayText.Size = UDim2.fromScale(0.9, 0.3)
	end

	return billboardGui
end

function v32.CreateEntry(p: string)
	local billboard = v32.GetBillboard()

	if not billboard then
		return nil
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = `LimitedStockDisplay-{p}`
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Position = UDim2.fromScale(0.5, 0.35)
	textLabel.Size = UDim2.fromScale(0.2, 0.2)
	textLabel.TextColor3 = Color3.fromRGB(255, 40, 30)
	textLabel.TextScaled = true
	textLabel.TextStrokeTransparency = 1
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Visible = false
	textLabel.ZIndex = 3
	textLabel.Parent = billboard
	local displayText = billboard:FindFirstChild("DisplayText")
	local uIStroke = displayText and displayText:FindFirstChildOfClass("UIStroke")

	if uIStroke then
		local clone = uIStroke:Clone()
		clone.Parent = textLabel
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "BrainrotImage"
	imageLabel.AnchorPoint = Vector2.new(1, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Position = UDim2.fromScale(-0.08, 0.5)
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
	imageLabel.ZIndex = 3
	imageLabel.Parent = textLabel
	local v40 = {
		Display = textLabel,
		Image = imageLabel,
		ResizeToken = 0,
		LastText = nil
	}
	v32.Entries[p] = v40
	return v40
end

function v32.Render(items)
	v32.GetBillboard()
	table.clear(v32.Order)
	local v40 = {}

	for k, item in items do
		local brainrot = item.Brainrot
		v40[brainrot] = true
		table.insert(v32.Order, brainrot)
		local v41 = v32.Entries[brainrot] or v32.CreateEntry(brainrot)

		if not v41 then
			continue
		end

		local v42 = not (item.Remaining > 0) and "SOLD OUT" or `{item.Remaining} LEFT`
		v41.Display.Text = v42
		local imageId = RNGMachineLimitedStockData.ImageIds[brainrot]
		v41.Image.Image = not imageId and "" or `rbxassetid://{imageId}`
		v41.Display.TextColor3 = RNGMachineLimitedStockData.TextColors[brainrot] or Color3.fromRGB(255, 40, 30)
		v41.Display.Visible = true

		if v41.LastText == v42 then
			continue
		end

		v41.LastText = v42
		v32.Resize(v41, k)
	end

	for k, entry in v32.Entries do
		if v40[k] then
			continue
		end

		entry.ResizeToken += 1
		entry.Display:Destroy()
		v32.Entries[k] = nil
	end

	v32.UpdatePosition()
end

local function observeMutationScreen(label)
	if not label:IsA("TextLabel") then
		return nil
	end

	v30 = label
	updateMutationScreen(v29)
	label.Visible = true
	return function()
		if v30 == label then
			CustomRichTextController.cleanup(label)
			v30 = nil
		end
	end
end

local function observeMutationScreenLine(part)
	if not part:IsA("BasePart") then
		return nil
	end

	v31 = part
	updateMutationScreen(v29)
	return function()
		if v31 == part then
			part.LocalTransparencyModifier = 0
			v31 = nil
		end
	end
end

local function getTemplate(skillTreeFrame, p: string)
	for _, button in ipairs(skillTreeFrame:GetChildren()) do
		if button.Name == p and button:IsA("ImageButton") then
			return button
		end
	end

	error((`Missing SkillTree template {p}`))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSkillPosition(p, p2: number)
	if v11 == "EventMutation" then
		return frozen9[p2]
	end

	return frozen8[p][p2]
end

local function setNodeText(clone, p, p2: number, p3: string)
	local v40 = v10

	if not v40 then
		return
	end

	local v41 = v40.SkillTree[p][p2]
	local title = clone:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		local text

		if p == "Luck" then
			text = `{v41.Multiplier}x`
		elseif p == "Speed" then
			text = `Speed {p2}`
		elseif p == "EventMutation" then
			text = `Tier {p2}`
		else
			text = `{v41.Mutation} {p2}`
		end

		title.Text = text
	end

	local txt = clone:FindFirstChild("Txt")

	if txt and txt:IsA("TextLabel") then
		txt.Text = p3 == "RebirthLocked" and "Locked" or p3 == "Owned" and "Owned" or `${NumberUtils:ToString(v41.Cost)}`
	end

	local lockedOverlay = clone:FindFirstChild("LockedOverlay")

	if lockedOverlay then
		local txt2 = lockedOverlay:FindFirstChild("Txt")

		if txt2 and txt2:IsA("TextLabel") then
			txt2.Text = `{v41.RequiredRebirths} REBIRTHS`
		end
	end

	local icon2 = clone:FindFirstChild("Icon")

	if icon2 and icon2:IsA("ImageLabel") then
		local image

		if p == "Luck" then
			image = LuckIcons[`{v41.Multiplier}x`] or _2x
		elseif p == "Speed" then
			image = frozen3[p2]
		elseif p == "GoldMutation" then
			image = frozen4[p2]
		elseif p == "DiamondMutation" then
			image = frozen5[p2]
		elseif p == "RainbowMutation" then
			image = frozen6[p2]
		else
			image = p ~= "EventMutation" and "" or frozen7[p2]
		end

		icon2.Image = image
	end
end

local function configureNode(clone, name: string, point: Vector2)
	clone.Name = name
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.Position = UDim2.fromOffset(point.X, point.Y)
	clone.Size = UDim2.fromOffset(vector3.X, vector3.Y)
	clone.Visible = true
	local title = clone:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		title.Position -= UDim2.fromScale(0, 0.07)
	end

	local txt = clone:FindFirstChild("Txt")

	if txt and txt:IsA("TextLabel") then
		txt.Position += UDim2.fromScale(0, 0.07)
	end

	local lockedOverlay = clone:FindFirstChild("LockedOverlay")
	local txt2 = lockedOverlay and lockedOverlay:FindFirstChild("Txt")

	if txt2 and txt2:IsA("TextLabel") then
		txt2.Position += UDim2.fromScale(0, 0.07)
	end
end

function class:_buySkill(p)
	if flag2 then
		return
	end

	local v40 = v10

	if not v40 or v40.Skills[p].Level >= #v40.SkillTree[p] then
		return
	end

	flag2 = true
	task.spawn(function()
		local success, result, v41 = pcall(function()
			return remoteFunction2:InvokeServer(p)
		end)

		if success then
			if result ~= true and v41 then
				warn(v41)
			end
		else
			warn(result)
		end

		flag2 = false
	end)
end

local function createEventMutationNavigation(parent)
	local v40 = v10

	if not v40 then
		return
	end

	local clone = v18.Open:Clone()
	configureNode(clone, "EventMutationTree", v7)
	local title = clone:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		title.Text = "Event Mutations"
	end

	local txt = clone:FindFirstChild("Txt")

	if txt and txt:IsA("TextLabel") then
		txt.Text = "Open"
	end

	local icon2 = clone:FindFirstChild("Icon")

	if icon2 and icon2:IsA("ImageLabel") then
		icon2.Image = icon
	end

	local v41 = v40.SkillTree.EventMutation[v40.Skills.EventMutation.Level + 1]
	local notif = clone:FindFirstChild("Notif")

	if notif and notif:IsA("GuiObject") then
		notif.Visible = v41 ~= nil and v40.Rebirths >= v41.RequiredRebirths
	end

	local hitbox = clone:FindFirstChild("Hitbox")

	if hitbox and hitbox:IsA("ImageButton") then
		hitbox.Active = true
		hitbox.Interactable = true
		hitbox.Selectable = true
		hitbox.Activated:Connect(function()
			class:_setSkillTreePage("EventMutation")
		end)
	end

	clone.Parent = parent
end

local function createEventMutationBack(parent)
	local clone = v18.Owned:Clone()
	configureNode(clone, "EventMutationBack", v8)
	clone.ImageColor3 = Color3.fromRGB(221, 67, 67)
	local title = clone:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		title.Visible = false
	end

	local txt = clone:FindFirstChild("Txt")

	if txt and txt:IsA("TextLabel") then
		txt.Text = "BACK"
	end

	local icon2 = clone:FindFirstChild("Icon")

	if icon2 and icon2:IsA("ImageLabel") then
		icon2.Image = "rbxassetid://139585696788832"
		icon2.Position -= UDim2.fromScale(0, 0.06)
	end

	local hitbox = clone:FindFirstChild("Hitbox")

	if hitbox and hitbox:IsA("ImageButton") then
		hitbox.Active = true
		hitbox.Interactable = true
		hitbox.Selectable = true
		hitbox.Activated:Connect(function()
			class:_setSkillTreePage("Main")
		end)
	end

	clone.Parent = parent
end

local function createSkillNode(parent, p, i: number)
	local v40 = v10

	if not v40 then
		return
	end

	local level = v40.Skills[p].Level
	local v41 = v40.SkillTree[p][i]
	local v42

	if i <= level then
		v42 = "Owned"
	elseif i ~= level + 1 then
		v42 = "Locked"
	elseif v40.Rebirths >= v41.RequiredRebirths then
		v42 = "Open"
	else
		v42 = "RebirthLocked"
	end

	local skillPosition = getSkillPosition(p, i) -- equivalent call inferred; original call site unknown
	local clone = v18[v42]:Clone()
	configureNode(clone, `{p}{frozen[i]}`, skillPosition)

	if v42 == "Locked" then
		clone.ImageColor3 = color2
	elseif v42 ~= "Owned" then
		clone.ImageColor3 = color
	end

	setNodeText(clone, p, i, v42)
	local notif = clone:FindFirstChild("Notif")

	if notif and notif:IsA("GuiObject") then
		notif.Visible = false
	end

	if v42 == "Locked" then
		for _, childName in ipairs({ "Title", "Txt", "LockedOverlay" }) do
			local guiObject = clone:FindFirstChild(childName)

			if guiObject and guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		local icon2 = clone:FindFirstChild("Icon")

		if icon2 and icon2:IsA("ImageLabel") then
			icon2.Visible = false
			local clone2 = icon2:Clone()
			clone2.Name = "LockedIcon"
			clone2.Image = "rbxassetid://113074138024674"
			clone2.ImageColor3 = Color3.new(1, 1, 1)
			clone2.Visible = true
			clone2.Parent = icon2.Parent
		end
	end

	clone.Parent = parent
	local hitbox = clone:FindFirstChild("Hitbox")

	if hitbox and hitbox:IsA("ImageButton") then
		local v43 = v42 == "Open"
		hitbox.Active = v43
		hitbox.Interactable = v43
		hitbox.Selectable = v43

		if v43 then
			hitbox.Activated:Connect(function()
				class:_buySkill(p)
			end)
		end
	end
end

function class:_renderSkillTree()
	local parent = v13
	local v41 = v10

	if not (parent and v41) then
		return
	end

	for _, child in ipairs(parent:GetChildren()) do
		if child ~= v14 then
			child:Destroy()
		end
	end

	if v11 == "EventMutation" then
		for i = 1, math.min(#v41.SkillTree.EventMutation, v41.Skills.EventMutation.Level + 2) do
			createSkillNode(parent, "EventMutation", i)
		end

		createEventMutationBack(parent)

		if v19 then
			v19.Visible = true
		end
	else
		if v19 then
			v19.Visible = false
		end

		local function renderBranch(p)
			for i = 1, math.min(#v41.SkillTree[p], v41.Skills[p].Level + 2) do
				createSkillNode(parent, p, i)
			end
		end

		renderBranch("Luck")
		renderBranch("Speed")
		renderBranch("GoldMutation")

		if v41.Skills.GoldMutation.Level >= #v41.SkillTree.GoldMutation then
			renderBranch("DiamondMutation")

			if v41.Skills.DiamondMutation.Level >= #v41.SkillTree.DiamondMutation then
				renderBranch("RainbowMutation")

				if v41.Skills.RainbowMutation.Level >= #v41.SkillTree.RainbowMutation then
					createEventMutationNavigation(parent)
				end
			end
		end
	end
end

local function setCanvasOffset(point: Vector2)
	zero = point
	local v40 = v13

	if v40 then
		Spr.target(v40, 0.85, 14, {
			Position = UDim2.new(0.5, point.X, 0.5, point.Y)
		})
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function centerCanvas()
	setCanvasOffset(Vector2.zero)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCanvasZoom(value: number)
	local v40 = v14

	if not v40 then
		return
	end

	scale3 = math.clamp(value, 0.6, 1.25)
	Spr.target(v40, 0.85, 12, {
		Scale = scale3
	})
end

local function setupPanning(skillTreeFrame)
	skillTreeFrame.Active = true
	skillTreeFrame.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch or not v13 then
			return
		end

		v20 = true
		v21 = input
		zero2 = Vector2.new(input.Position.X, input.Position.Y)
		zero3 = zero
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			if not (v12 and v12.Enabled) then
				return
			end

			setCanvasZoom(scale3 + math.sign(input.Position.Z) * 0.1) -- equivalent call inferred; original call site unknown
		else
			if not v20 or input.UserInputType ~= Enum.UserInputType.MouseMovement and input ~= v21 then
				return
			end

			local vector4 = Vector2.new(input.Position.X, input.Position.Y)
			setCanvasOffset(zero3 + (vector4 - zero2))
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input == v21 or input.UserInputType == Enum.UserInputType.MouseButton1 then
			v20 = false
			v21 = nil
		end
	end)
	UserInputService.TouchPinch:Connect(function(list, p: number, _: number, p2, _: boolean)
		if not v12 or not v12.Enabled or #list < 2 then
			return
		end

		if p2 == Enum.UserInputState.Begin then
			v17 = scale3
			v20 = false
			v21 = nil
		elseif p2 == Enum.UserInputState.Change then
			setCanvasZoom(v17 * p) -- equivalent call inferred; original call site unknown
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isGamepadPreferred()
	return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
end

local function getPreferredSkillTreeSelection()
	local v40 = v13
	local v41 = nil
	local v42 = 1e999

	if not v40 then
		return v41 or v15
	end

	for _, guiObject in ipairs(v40:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local hitbox = guiObject:FindFirstChild("Hitbox")

		if not (hitbox and hitbox:IsA("GuiButton") and hitbox.Selectable and hitbox.Interactable) then
			continue
		end

		local magnitude = (Vector2.new(guiObject.Position.X.Offset, guiObject.Position.Y.Offset) - vector2).Magnitude

		if not (magnitude < v42) then
			continue
		end

		v41 = hitbox
		v42 = magnitude
	end

	return v41 or v15
end

local function focusSkillTreeSelection()
	if not (v12 and v12.Enabled and isGamepadPreferred()) then
		return
	end

	GuiService.SelectedObject = getPreferredSkillTreeSelection()
end

local function centerSelectedSkillNode()
	local v40 = v12
	local v41 = v13
	local selectedObject = GuiService.SelectedObject

	if not (v40 and v40.Enabled and v41 and selectedObject and selectedObject:IsDescendantOf(v41)) then
		return
	end

	while selectedObject.Parent and selectedObject.Parent ~= v41 do
		selectedObject = selectedObject.Parent
	end

	if selectedObject.Parent ~= v41 or not selectedObject:IsA("GuiObject") then
		return
	end

	setCanvasOffset(vector2 - Vector2.new(selectedObject.Position.X.Offset, selectedObject.Position.Y.Offset))
end

local function getNodeAnimationScale(parent)
	local rNGMachinePopScale = parent:FindFirstChild("RNGMachinePopScale")

	if rNGMachinePopScale and rNGMachinePopScale:IsA("UIScale") then
		return rNGMachinePopScale
	end

	local uIScale = Instance.new("UIScale")
	uIScale.Name = "RNGMachinePopScale"
	uIScale.Parent = parent
	return uIScale
end

-- equivalent calls inferred from this helper; original call sites unknown
local function prepareNodeAnimation(guiObject)
	local v40 = guiObject:FindFirstChild("RNGMachinePopScale")

	if not (v40 and v40:IsA("UIScale")) then
		v40 = Instance.new("UIScale")
		v40.Name = "RNGMachinePopScale"
		v40.Parent = guiObject
	end

	v40.Scale = 0
	guiObject.Visible = false
end

local function animateNode(parent)
	local v40 = parent:FindFirstChild("RNGMachinePopScale")

	if not (v40 and v40:IsA("UIScale")) then
		v40 = Instance.new("UIScale")
		v40.Name = "RNGMachinePopScale"
		v40.Parent = parent
	end

	parent.Visible = true
	TweenService:Create(v40, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
end

local function animateNodes(p: number)
	local v40 = v13

	if not v40 then
		return
	end

	local guiObjects = {}

	for _, guiObject in ipairs(v40:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		prepareNodeAnimation(guiObject) -- equivalent call inferred; original call site unknown
		table.insert(guiObjects, guiObject)
	end

	table.sort(guiObjects, function(a, b)
		local vector4 = Vector2.new(a.Position.X.Offset, a.Position.Y.Offset)
		local vector5 = Vector2.new(b.Position.X.Offset, b.Position.Y.Offset)
		return (vector4 - vector2).Magnitude < (vector5 - vector2).Magnitude
	end)

	for i, v41 in ipairs(guiObjects) do
		local parent = v41
		task.delay((i - 1) * 0.03, function()
			if p ~= count or not parent.Parent then
				return
			end

			animateNode(parent)
		end)
	end
end

local function animateNewlyRevealedNodes(p, data)
	local v40 = v13

	if not v40 then
		return
	end

	local function animateNamedNode(childName: string, duration: number)
		local guiObject = v40:FindFirstChild(childName)

		if not (guiObject and guiObject:IsA("GuiObject")) then
			return
		end

		prepareNodeAnimation(guiObject) -- equivalent call inferred; original call site unknown
		task.delay(duration, function()
			if guiObject.Parent then
				animateNode(guiObject)
			end
		end)
	end

	local function animateBranch(p2)
		local level = p.Skills[p2].Level
		local level2 = data.Skills[p2].Level

		if level2 <= level then
			return
		end

		local v41 = level2 + 2

		if not data.SkillTree[p2][v41] then
			return
		end

		animateNamedNode(`{p2}{frozen[v41]}`, 0)
	end

	local function completedBranch(p2)
		local count3 = #data.SkillTree[p2]
		return p.Skills[p2].Level < count3 and count3 <= data.Skills[p2].Level
	end

	local function animateVisibleBranch(p2)
		for i = 1, math.min(#data.SkillTree[p2], data.Skills[p2].Level + 2) do
			animateNamedNode(`{p2}{frozen[i]}`, (i - 1) * 0.03)
		end
	end

	local level = p.Skills.Luck.Level
	local level2 = data.Skills.Luck.Level

	if not (level2 <= level) then
		local v41 = level2 + 2

		if data.SkillTree.Luck[v41] then
			animateNamedNode(`Luck{frozen[v41]}`, 0)
		end
	end

	local level3 = p.Skills.Speed.Level
	local level4 = data.Skills.Speed.Level

	if not (level4 <= level3) then
		local v41 = level4 + 2

		if data.SkillTree.Speed[v41] then
			animateNamedNode(`Speed{frozen[v41]}`, 0)
		end
	end

	local level5 = p.Skills.GoldMutation.Level
	local level6 = data.Skills.GoldMutation.Level

	if not (level6 <= level5) then
		local v41 = level6 + 2

		if data.SkillTree.GoldMutation[v41] then
			animateNamedNode(`GoldMutation{frozen[v41]}`, 0)
		end
	end

	local level7 = p.Skills.DiamondMutation.Level
	local level8 = data.Skills.DiamondMutation.Level

	if not (level8 <= level7) then
		local v41 = level8 + 2

		if data.SkillTree.DiamondMutation[v41] then
			animateNamedNode(`DiamondMutation{frozen[v41]}`, 0)
		end
	end

	local level9 = p.Skills.RainbowMutation.Level
	local level10 = data.Skills.RainbowMutation.Level

	if not (level10 <= level9) then
		local v41 = level10 + 2

		if data.SkillTree.RainbowMutation[v41] then
			animateNamedNode(`RainbowMutation{frozen[v41]}`, 0)
		end
	end

	local level11 = p.Skills.EventMutation.Level
	local level12 = data.Skills.EventMutation.Level

	if not (level12 <= level11) then
		local v41 = level12 + 2

		if data.SkillTree.EventMutation[v41] then
			animateNamedNode(`EventMutation{frozen[v41]}`, 0)
		end
	end

	local count3 = #data.SkillTree.GoldMutation
	local v41

	if p.Skills.GoldMutation.Level < count3 then
		v41 = count3 <= data.Skills.GoldMutation.Level
	else
		v41 = false
	end

	if v41 then
		animateVisibleBranch("DiamondMutation")
	end

	local count4 = #data.SkillTree.DiamondMutation
	local v42

	if p.Skills.DiamondMutation.Level < count4 then
		v42 = count4 <= data.Skills.DiamondMutation.Level
	else
		v42 = false
	end

	if v42 then
		animateVisibleBranch("RainbowMutation")
	end

	local count5 = #data.SkillTree.RainbowMutation
	local v43

	if p.Skills.RainbowMutation.Level < count5 then
		v43 = count5 <= data.Skills.RainbowMutation.Level
	else
		v43 = false
	end

	if v43 then
		animateNamedNode("EventMutationTree", 0)
	end
end

local function playOpenAnimation()
	local v40 = v12

	if not v40 then
		return
	end

	local darkBG = v40:FindFirstChild("DarkBG")

	if darkBG and darkBG:IsA("GuiObject") then
		darkBG.BackgroundTransparency = 1
		TweenService:Create(darkBG, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.25
		}):Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateSkillTreePageChrome()
	local v40 = v12

	if not v40 then
		return
	end

	local close = v40:FindFirstChild("Close")
	local txt = close and close:FindFirstChild("Txt")

	if txt and txt:IsA("TextLabel") then
		txt.Text = "CLOSE"
	end

	if v19 then
		v19.Visible = v11 == "EventMutation"
	end
end

function class:_setSkillTreePage(p: string)
	v11 = p
	count += 1
	local v40 = count
	updateSkillTreePageChrome() -- equivalent call inferred; original call site unknown
	self:_renderSkillTree()
	centerCanvas() -- equivalent call inferred; original call site unknown
	animateNodes(v40)
	task.delay(0.25, focusSkillTreeSelection)
end

function class:_openSkillTree()
	local v40 = v12

	if not v40 then
		return
	end

	v11 = "Main"
	count += 1
	local v41 = count
	updateSkillTreePageChrome() -- equivalent call inferred; original call site unknown
	self:_renderSkillTree()
	centerCanvas() -- equivalent call inferred; original call site unknown
	animateNodes(v41)
	v40.Enabled = true
	playOpenAnimation()
	task.delay(0.25, focusSkillTreeSelection)
end

function class:_setupSkillTree()
	local skillTree = playerGui:FindFirstChild("SkillTree")
	local skillTreeFrame = skillTree and skillTree:FindFirstChild("Frame")
	local close = skillTree and skillTree:FindFirstChild("Close")

	if not (skillTree and skillTree:IsA("ScreenGui") and skillTreeFrame and skillTreeFrame:IsA("Frame") and close and close:IsA("ImageButton")) then
		warn("RNG Machine skill tree interface is incomplete")
		return
	end

	v12 = skillTree
	v15 = close
	close.Selectable = true
	skillTree:GetPropertyChangedSignal("Enabled"):Connect(function()
		BackpackController:SetEnabled("RNGMachineSkillTree", not skillTree.Enabled)

		if skillTree.Enabled then
			task.delay(0.25, focusSkillTreeSelection)
		elseif GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(skillTree) then
			GuiService.SelectedObject = nil
		end
	end)
	v18.Open = getTemplate(skillTreeFrame, "OpenTemplate"):Clone()
	v18.Owned = getTemplate(skillTreeFrame, "OwnedTemplate"):Clone()
	v18.Locked = getTemplate(skillTreeFrame, "LockedTemplate"):Clone()
	v18.RebirthLocked = getTemplate(skillTreeFrame, "RebirthLockedTemplate"):Clone()

	for _, v40 in pairs(v18) do
		v40.Parent = nil
	end

	for _, button in ipairs(skillTreeFrame:GetChildren()) do
		if button:IsA("GuiButton") then
			button.Visible = false
		end
	end

	skillTreeFrame.Active = true
	skillTreeFrame.ClipsDescendants = true
	skillTreeFrame.SelectionGroup = true
	local frame = Instance.new("Frame")
	frame.Name = "RNGMachineSkills"
	frame.AnchorPoint = anchorPoint
	frame.BackgroundTransparency = 1
	frame.ClipsDescendants = false
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromOffset(vector.X, vector.Y)
	frame.Parent = skillTreeFrame
	v13 = frame
	local uIScale = Instance.new("UIScale")
	uIScale.Name = "RNGMachineZoom"
	uIScale.Scale = scale3
	uIScale.Parent = frame
	v14 = uIScale
	setupPanning(skillTreeFrame)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "PanHint"
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Position = UDim2.fromScale(0.5, 0.015)
	textLabel.Size = UDim2.fromScale(0.35, 0.055)
	textLabel.Text = isGamepadPreferred() and "USE D-PAD TO MOVE" or "DRAG TO MOVE"
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.TextStrokeTransparency = 0
	textLabel.ZIndex = 20
	textLabel.Parent = skillTreeFrame
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "EventMutationNotice"
	textLabel2.AnchorPoint = Vector2.new(0.5, 1)
	textLabel2.BackgroundTransparency = 1
	textLabel2.Font = Enum.Font.GothamBold
	textLabel2.Position = UDim2.new(
		close.Position.X.Scale,
		close.Position.X.Offset,
		close.Position.Y.Scale - close.Size.Y.Scale * 0.5 - 0.008,
		close.Position.Y.Offset - close.Size.Y.Offset * 0.5
	)
	textLabel2.Size = UDim2.fromScale(0.35, 0.025)
	textLabel2.Text = "ONLY ACTIVE WHILE A MUTATION EVENT IS RUNNING"
	textLabel2.TextColor3 = Color3.fromRGB(255, 127, 0)
	textLabel2.TextScaled = true
	textLabel2.TextStrokeTransparency = 0
	textLabel2.TextWrapped = true
	textLabel2.Visible = false
	textLabel2.ZIndex = 20
	textLabel2.Parent = skillTreeFrame
	v19 = textLabel2

	-- equivalent calls inferred from this helper; original call sites unknown
	local function closeSkillTree()
		count += 1
		skillTree.Enabled = false
	end

	close.Activated:Connect(closeSkillTree)
	GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(centerSelectedSkillNode)
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		textLabel.Text = isGamepadPreferred() and "USE D-PAD TO MOVE" or "DRAG TO MOVE"

		if v12 and v12.Enabled then
			if UserInputService.PreferredInput ~= Enum.PreferredInput.Gamepad then
				return
			end

			GuiService.SelectedObject = getPreferredSkillTreeSelection()
		end
	end)
	UserInputService.InputBegan:Connect(function(input)
		if skillTree.Enabled and input.KeyCode == Enum.KeyCode.ButtonB then
			closeSkillTree() -- equivalent call inferred; original call site unknown
		end
	end)
	skillTree.Enabled = false
	BackpackController:SetEnabled("RNGMachineSkillTree", true)
	updateSkillTreePageChrome() -- equivalent call inferred; original call site unknown
	self:_renderSkillTree()
	centerCanvas() -- equivalent call inferred; original call site unknown
end

local function getTaggedPrompt(tag: string)
	for _, proximityPrompt in ipairs(CollectionService:GetTagged(tag)) do
		if proximityPrompt:IsA("ProximityPrompt") and proximityPrompt:IsDescendantOf(game) then
			return proximityPrompt
		end
	end

	return nil
end

function class:_reconcilePrompts(data)
	local taggedPrompt = getTaggedPrompt("RNGMachineSpinPrompt")
	local taggedPrompt2 = getTaggedPrompt("RNGMachineSkillTreePrompt")
	local enabled

	if data == nil then
		enabled = false
	else
		enabled = data.Enabled
	end

	local v40 = not data and "Idle" or data.State
	local offer

	if data then
		offer = data.Offer
	end

	local v41

	if v40 == "Offer" then
		v41 = typeof(offer) == "table"
	else
		v41 = false
	end

	if taggedPrompt then
		taggedPrompt.Enabled = enabled and v40 ~= "Spinning"
		taggedPrompt.UIOffset = Vector2.new(0, 36)
		local actionText = v41 and "Spin Again" or "Spin"

		if data then
			actionText = `{actionText} (${NumberUtils:ToString(data.SpinCost)})`
		end

		taggedPrompt.ActionText = actionText
	end

	if taggedPrompt2 then
		taggedPrompt2.Enabled = enabled
		taggedPrompt2.UIOffset = Vector2.new(0, -36)
		taggedPrompt2.ActionText = "Upgrades"
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function deferPromptReconcile()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		flag = false
		class:_reconcilePrompts(v10)
	end)
end

local function observeSkillTreePrompt(proximityPrompt)
	if not proximityPrompt:IsA("ProximityPrompt") then
		return nil
	end

	proximityPrompt.Enabled = false
	proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	deferPromptReconcile() -- equivalent call inferred; original call site unknown
	local triggeredConnection = proximityPrompt.Triggered:Connect(function()
		class:_openSkillTree()
	end)
	return function()
		triggeredConnection:Disconnect()
		deferPromptReconcile() -- equivalent call inferred; original call site unknown
	end
end

local function observeSpinPrompt(proximityPrompt)
	if not proximityPrompt:IsA("ProximityPrompt") then
		return nil
	end

	proximityPrompt.Enabled = false
	proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	deferPromptReconcile() -- equivalent call inferred; original call site unknown
	local triggeredConnection = proximityPrompt.Triggered:Connect(function(player)
		if player and player ~= localPlayer or v10 and v10.State == "Offer" then
			return
		end

		v23.OptimisticSpinToken += 1
		local optimisticSpinToken = v23.OptimisticSpinToken
		v22 = true
		v23.PrivateStagePayload = nil
		class:_reconcileActivityDisplay()
		task.delay(1, function()
			if optimisticSpinToken == v23.OptimisticSpinToken and (not v10 or v10.State ~= "Spinning") and not v23.PrivateStagePayload then
				v22 = false
				class:_reconcileActivityDisplay()
			end
		end)
	end)
	return function()
		triggeredConnection:Disconnect()
		deferPromptReconcile() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearActiveSpinAnimation()
	if v23.ActiveConnection then
		v23.ActiveConnection:Disconnect()
		v23.ActiveConnection = nil
	end

	if v23.ActiveTween then
		v23.ActiveTween:Cancel()
		v23.ActiveTween = nil
	end

	if v23.ActiveSpinner then
		v23.ActiveSpinner:Destroy()
		v23.ActiveSpinner = nil
	end
end

local function clearDisplay()
	count2 += 1
	clearActiveSpinAnimation() -- equivalent call inferred; original call site unknown
	v23.SelectedIdentity = nil
	v23.SelectedOwnerUserId = nil
	v23.SelectedState = nil
	v23.StageVisualEndsAt = 0

	if v26 then
		v26:Destroy()
		v26 = nil
	end

	v27 = nil
	v28 = nil
	resultName = nil

	if v24 then
		v24:Destroy()
		v24 = nil
	end

	table.clear(v25)
end

local function prepareStageDisplay()
	count2 += 1
	clearActiveSpinAnimation() -- equivalent call inferred; original call site unknown

	if v26 then
		v26:Destroy()
		v26 = nil
	end

	v27 = nil
	v28 = nil
	resultName = nil

	for _, v40 in pairs(v25) do
		if v40.Parent then
			v40:PivotTo(CFrame.new(0, 100000, 100000))
		end
	end
end

local function observeDisplayCenter(part)
	if not part:IsA("BasePart") then
		return nil
	end

	v9 = part
	task.defer(function()
		class:_reconcileActivityDisplay()
	end)
	return function()
		if v9 == part then
			v9 = nil
			clearDisplay()
		end
	end
end

local function observeVfxPart(p, part)
	if not part:IsA("BasePart") then
		return nil
	end

	p[part] = true
	v38[part] = part.Color
	return function()
		p[part] = nil
		v38[part] = nil
	end
end

local function createVfxObserver(p)
	return function(part)
		local v40 = p

		if not part:IsA("BasePart") then
			return nil
		end

		v40[part] = true
		v38[part] = part.Color
		return function()
			v40[part] = nil
			v38[part] = nil
		end
	end
end

local vfxObserver = createVfxObserver(v33)
local vfxObserver2 = createVfxObserver(v34)
local vfxObserver3 = createVfxObserver(v35)
local vfxObserver4 = createVfxObserver(v36)
local vfxObserver5 = createVfxObserver(v37)

local function observeLeverRoot(part)
	if not part:IsA("BasePart") then
		return nil
	end

	v39 = part
	return function()
		if v39 == part then
			v39 = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDisplayCenter()
	local v40 = v9

	if v40 and v40:IsDescendantOf(workspace) then
		return v40:GetPivot()
	end

	return nil
end

local function prepareModel(folder, p: number?)
	local primaryPart = folder.PrimaryPart

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
			descendant.Massless = true

			if not primaryPart then
				folder.PrimaryPart = descendant
				primaryPart = descendant
			end
		elseif descendant:IsA("LuaSourceContainer") then
			descendant:Destroy()
		end
	end

	if primaryPart then
		primaryPart.Anchored = true
	end

	if p then
		local _, v40 = folder:GetBoundingBox()
		local v41 = math.max(v40.X, v40.Y, v40.Z)

		if v41 > 0 then
			folder:ScaleTo(folder:GetScale() * (p / v41))
		end
	end

	folder:SetAttribute("DefaultScale", folder:GetScale())
end

local function destroySpinParticleEmitters(folder)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Destroy()
		end
	end
end

local function destroySpinTrails(folder)
	for _, trail in ipairs(folder:GetDescendants()) do
		if trail:IsA("Trail") then
			trail:Destroy()
		end
	end
end

local function playIdleAnimation(parent, childName: string)
	local child = animals:FindFirstChild(childName)
	local roadBrainrotIdle = child and (child:FindFirstChild("RoadBrainrotIdle") or child:FindFirstChild("Idle"))

	if not (roadBrainrotIdle and roadBrainrotIdle:IsA("Animation")) then
		return
	end

	local parent2 = parent:FindFirstChildOfClass("AnimationController") or parent:FindFirstChildOfClass("Humanoid")

	if not parent2 then
		parent2 = Instance.new("AnimationController")
		parent2.Parent = parent
	end

	local v41 = parent2:FindFirstChildOfClass("Animator")

	if not v41 then
		v41 = Instance.new("Animator")
		v41.Parent = parent2
	end

	local track = v41:LoadAnimation(roadBrainrotIdle)
	track.Priority = Enum.AnimationPriority.Idle
	track.Looped = true
	track:Play(0.1)
	track:AdjustSpeed(roadBrainrotIdle:GetAttribute("Speed") or 1)
end

local function createDisplay(p, model)
	if p.Type == "Luck" then
		local luckIcons = ReplicatedStorage:FindFirstChild("LuckIcons")
		local v40 = string.gsub(p.Name, "x$", "")
		local model2 = luckIcons and luckIcons:FindFirstChild(v40)

		if not (model2 and model2:IsA("Model")) then
			return nil
		end

		local clone = model2:Clone()
		clone.Name = p.Name
		prepareModel(clone)
		return clone
	else
		if not (model and model:IsA("Model")) then
			return nil
		end

		local clone = model:Clone()
		clone.Name = p.Name
		prepareModel(clone)
		clone:SetAttribute("PlayIdleAnimation", true)
		return clone
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDisplayCacheKey(p, mutation: string?)
	return (`{p.Type}:{p.Name}:{mutation or "Normal"}`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getStagePlaybackSpeed(stage: number)
	return (math.min((stage - 1) * 0.08 + 1, 1.4))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSpinVolumeMultiplier(p: number)
	if p <= 1 then
		return 1
	end

	return (math.min((p - 2) * 0.12 + 1.12, 1.8))
end

local function getLuckLandedVolumeMultiplier(p: number)
	return (math.min((p - 1) * 0.12 + 1.2, 1.8))
end

local function playRNGSound(childName: string, vector4: Vector3, value: number?)
	local sound = rNGMachine:FindFirstChild(childName)

	if not (sound and sound:IsA("Sound")) then
		return nil
	end

	local playbackSpeed = value or 1
	local v41 = SoundController:PlaySound(sound, vector4, false)

	if v41 then
		v41.PlaybackSpeed = playbackSpeed
	end

	return v41
end

local function playSpinTick(data)
	local sound = rNGMachine:FindFirstChild(data.Stage == 1 and "RegularSpin" or "LuckySpin")
	local parent = v9

	if not (sound and sound:IsA("Sound") and parent) then
		return
	end

	local clone = sound:Clone()
	local soundId = clone:GetAttribute("SoundId")

	if typeof(soundId) == "string" then
		clone:SetAttribute("SoundId", nil)
		clone.SoundId = soundId
	end

	clone.Looped = false
	clone.PlaybackSpeed = math.min((data.Stage - 1) * 0.08 + 1, 1.4)
	clone.Volume *= getSpinVolumeMultiplier(data.Stage)
	clone.Parent = parent
	clone.Ended:Once(function()
		task.delay(0.1, function()
			if clone.Parent then
				clone:Destroy()
			end
		end)
	end)
	clone:Play()
end

local function createLandedOverhead(instance, resultName2: string, mutation: string?, maid)
	local animal = Animals2[resultName2]
	local primaryPart = instance.PrimaryPart

	if not animal or animal.HideOverhead or not primaryPart then
		return nil
	end

	local OVERHEAD_ATTACHMENT = instance:FindFirstChild("OVERHEAD_ATTACHMENT", true)

	if not (OVERHEAD_ATTACHMENT and OVERHEAD_ATTACHMENT:IsA("Attachment")) then
		local attachment = Instance.new("Attachment")
		attachment.Name = "RNGMachineOverhead"
		attachment.Parent = primaryPart
		attachment.WorldCFrame = instance:GetPivot() * CFrame.new(
			0,
			instance:GetExtentsSize().Y * 0.75 * (animal.OverheadYOffsetModifier or 1),
			0
		)
		OVERHEAD_ATTACHMENT = maid:Add(attachment)
	end

	local fastOverhead, v40 = FastOverheadController.createFastOverhead({
		adornee = OVERHEAD_ATTACHMENT,
		guiTemplate = FastOverheadController.GuiTemplates.AnimalOverhead
	})
	maid:Add(v40)
	AnimalOverheadController:Populate({
		Overhead = fastOverhead,
		Index = resultName2,
		Mutation = mutation,
		Player = localPlayer,
		Trove = maid,
		HidePrice = true
	})
	fastOverhead.Generation.Text = `${NumberUtils:ToString(Animals:GetGeneration(resultName2, mutation, nil))}/s`
	fastOverhead.Generation.Visible = not animal.HideGeneration
	return fastOverhead
end

local function configureOfferTimer(instance, p: number, maid)
	local stolen = instance:FindFirstChild("Stolen")

	if not (stolen and stolen:IsA("TextLabel")) then
		return
	end

	stolen.Visible = true
	stolen.LayoutOrder = -1
	stolen.Size = UDim2.fromScale(1, 0.25)

	local function updateTimer()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v40 = math.max(0, (math.ceil(p - serverTimeNow)))
		stolen.Text = `{v40}s`
		return v40 > 0 and stolen.Parent ~= nil
	end

	local v40 = math.max(0, (math.ceil(p - workspace:GetServerTimeNow())))
	stolen.Text = `{v40}s`

	if v40 > 0 then
		local _ = stolen.Parent == nil
	end

	maid:Add(task.spawn(function()
		repeat
			task.wait(1)
			local serverTimeNow = workspace:GetServerTimeNow()
			local v41 = math.max(0, (math.ceil(p - serverTimeNow)))
			stolen.Text = `{v41}s`
			local v42

			if v41 > 0 then
				v42 = stolen.Parent ~= nil
			else
				v42 = false
			end
		until not v42
	end))
end

function class:_updateLandedOffer(data)
	local v40 = v27

	if not (v40 and v40.Parent) then
		return
	end

	v40.Enabled = false
	local offer = data and data.Offer

	if not data or not data.Enabled or data.State ~= "Offer" or typeof(offer) ~= "table" then
		return
	end

	if offer.Name ~= resultName then
		return
	end

	local animal = Animals2[offer.Name]
	local displayName

	if animal then
		displayName = animal.DisplayName
	else
		displayName = offer.Name
	end

	v40.ActionText = "Purchase"
	v40.ObjectText = `{displayName} ${NumberUtils:ToString(offer.BuyPrice)}`
	v40.Enabled = true

	if v28 then
		local odds = offer.Odds
		v28.Price.Visible = data.ShowResultOdds and typeof(odds) == "number"

		if data.ShowResultOdds and typeof(odds) == "number" then
			v28.Price.Text = `1 in {NumberUtils:Comma((math.max(1, (math.round(odds)))))}`
		end
	end
end

function class:_setupLandedBrainrot(instance, p, flag3: boolean, p2: number?)
	if not flag3 then
		return
	end

	local primaryPart = instance.PrimaryPart

	if not primaryPart then
		return
	end

	local maid = Trove.new()
	v26 = maid
	resultName = p.ResultName
	v28 = createLandedOverhead(instance, p.ResultName, p.Mutation, maid)

	if v28 and p2 then
		configureOfferTimer(v28, p2, maid)
	end

	local promptAttachment = instance:FindFirstChild("PromptAttachment", true)

	if not (promptAttachment and promptAttachment:IsA("Attachment")) then
		local attachment = Instance.new("Attachment")
		attachment.Name = "PromptAttachment"
		attachment.Parent = primaryPart
		promptAttachment = maid:Add(attachment)
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ActionText = "Purchase"
	proximityPrompt.ObjectText = p.ResultName
	proximityPrompt.HoldDuration = 0.25
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.MaxActivationDistance = 10
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = promptAttachment
	v27 = maid:Add(proximityPrompt)
	maid:Add(proximityPrompt.Triggered:Connect(function()
		proximityPrompt.Enabled = false
		task.spawn(function()
			local success, result, v40 = pcall(remoteFunction.InvokeServer, remoteFunction)

			if success then
				if result ~= true then
					if v40 then
						warn(v40)
					end

					self:_updateLandedOffer(v10)
					self:_reconcilePrompts(v10)
				end
			else
				warn(result)
				self:_updateLandedOffer(v10)
				self:_reconcilePrompts(v10)
			end
		end)
	end))
	self:_updateLandedOffer(v10)
	self:_reconcilePrompts(v10)
end

local function playLuckVFX(instance, color3: Color3?)
	local primaryPart = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)

	if not (primaryPart and primaryPart:IsA("BasePart")) then
		return
	end

	local v40 = color3 or Color3.fromRGB(72, 255, 108)
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0
	pointLight.Color = v40
	pointLight.Range = 24
	pointLight.Shadows = true
	pointLight.Parent = primaryPart
	local highlight = Instance.new("Highlight")
	highlight.Adornee = instance
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = v40
	highlight.FillTransparency = 1
	highlight.OutlineColor = v40
	highlight.OutlineTransparency = 1
	highlight.Parent = instance
	Debris:AddItem(pointLight, 1)
	Debris:AddItem(highlight, 1)
	local tween = TweenService:Create(pointLight, TweenInfo.new(0.12), {
		Brightness = 8
	})
	local tween2 = TweenService:Create(highlight, TweenInfo.new(0.12), {
		FillTransparency = 0.2,
		OutlineTransparency = 0
	})
	tween:Play()
	tween2:Play()
	task.delay(0.18, function()
		if pointLight.Parent and highlight.Parent then
			TweenService:Create(pointLight, TweenInfo.new(0.18), {
				Brightness = 0
			}):Play()
			TweenService:Create(highlight, TweenInfo.new(0.18), {
				FillTransparency = 0.75,
				OutlineTransparency = 0.5
			}):Play()
		end
	end)
end

local function getLuckStyle(p: number)
	local luckIcons = ReplicatedStorage:FindFirstChild("LuckIcons")
	local child = luckIcons and luckIcons:FindFirstChild((tostring(p)))
	local glow = child and child:FindFirstChild("Glow", true)

	if glow and glow:IsA("ParticleEmitter") then
		return glow.Color, glow.Color.Keypoints[1].Value, LuckIcons[`{p}x`]
	end

	return nil, nil, LuckIcons[`{p}x`]
end

local function styleVfx(folder, luckStyle, color3: Color3?, texture: string?)
	for _, descendant in ipairs(folder:GetDescendants()) do
		local v40 = descendant.Name == "LuckIcons" or descendant.Name == "LuckIcon"

		if descendant:IsA("ParticleEmitter") then
			if v40 then
				if texture then
					descendant.Texture = texture
				end
			elseif luckStyle then
				descendant.Color = luckStyle
			end
		elseif descendant:IsA("Beam") then
			if v40 then
				if texture then
					descendant.Texture = texture
				end
			elseif luckStyle then
				descendant.Color = luckStyle
			end
		elseif descendant:IsA("Trail") then
			if v40 then
				if texture then
					descendant.Texture = texture
				end
			elseif luckStyle then
				descendant.Color = luckStyle
			end
		elseif descendant:IsA("Light") and color3 then
			descendant.Color = color3
		end
	end
end

local function setLuckySpinVfx(p: number, flag3: boolean)
	local luckStyle, color3, texture = getLuckStyle(p)

	for k in pairs(v33) do
		if flag3 and color3 then
			k.Color = color3
		elseif not flag3 and v38[k] then
			k.Color = v38[k]
		end

		styleVfx(k, luckStyle, color3, texture)

		if flag3 then
			VFX.enable(k, true)
		else
			VFX.disable(k, true)
		end
	end

	for k in pairs(v34) do
		styleVfx(k, luckStyle, color3, texture)

		if flag3 then
			VFX.enable(k, true)
		else
			VFX.disable(k, true)
		end
	end
end

local function emitExplosion(items, p: number)
	local luckStyle, color3, texture = getLuckStyle(p)

	for k in pairs(items) do
		styleVfx(k, luckStyle, color3, texture)
		VFX.emit(k)
	end
end

local function emitHighLuckExplosion(p: number)
	local v40

	if p >= 12 then
		v40 = v37
	else
		v40 = v36
	end

	emitExplosion(v40, p)
	local rNGMachineVFX = ReplicatedStorage:FindFirstChild("RNGMachineVFX")
	local child = rNGMachineVFX and rNGMachineVFX:FindFirstChild((`{p}xLuckMapVFX`))

	if not child then
		return
	end

	local clone = child:Clone()
	clone.Parent = workspace
	local luckStyle, color3, texture = getLuckStyle(p)
	styleVfx(clone, luckStyle, color3, texture)
	VFX.emit(clone)
	Debris:AddItem(clone, 10)
end

local function playLeverAnimation()
	local v40 = v39
	local parent = v40 and v40.Parent
	local v41 = v2

	if not (v40 and parent and parent:IsA("Model") and v41) then
		return
	end

	local animator = parent:FindFirstChildWhichIsA("Animator", true)

	if not animator then
		return
	end

	animator:LoadAnimation(v41):Play(0.1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getStageMultiplier(p)
	return (tonumber(string.match(p.ResultName, "%d+")))
end

function class:_renderActivityOffer(p, flag3: boolean)
	local offer = p.Offer

	if not offer then
		return
	end

	prepareStageDisplay()
	updateMutationScreen(offer.Mutation)
	setLuckySpinVfx(offer.Multiplier, false)
	local v40 = count2
	local displayCenter = getDisplayCenter() -- equivalent call inferred; original call site unknown

	if not displayCenter then
		return
	end

	local parent

	if v24 then
		parent = v24
	else
		parent = Instance.new("Folder")
		parent.Name = "RNGMachineDisplay"
		parent.Parent = workspace
		v24 = parent
	end

	local v42 = {
		Type = "Brainrot",
		Name = offer.Name
	}
	local v43 = {
		Stage = 0,
		Multiplier = offer.Multiplier,
		StartedAt = p.SpinStartedAt,
		Duration = 0,
		Entries = { v42 },
		ResultIndex = 1,
		ResultType = "Brainrot",
		ResultName = offer.Name,
		Mutation = offer.Mutation
	}
	local v44 = false

	local function renderModel(p2)
		if v44 or v40 ~= count2 then
			return
		end

		local displayCacheKey = getDisplayCacheKey(v42, offer.Mutation) -- equivalent call inferred; original call site unknown
		local v46 = v25[displayCacheKey]

		if not (v46 and v46.Parent) then
			v46 = createDisplay(v42, p2)

			if not v46 then
				return
			end

			v46:PivotTo(CFrame.new(0, 100000, 100000))
			v46.Parent = parent
			v25[displayCacheKey] = v46
			destroySpinParticleEmitters(v46)
			destroySpinTrails(v46)

			if offer.Mutation then
				task.spawn(function()
					local v47 = Animals:ApplyMutation(v46, offer.Name, offer.Mutation)

					if v40 == count2 and v46.Parent then
						if v47 then
							v46.Destroying:Once(v47)
						end

						destroySpinTrails(v46)
					elseif v47 then
						v47()
					end
				end)
			end

			task.spawn(playIdleAnimation, v46, offer.Name)
		end

		v44 = true
		local v47 = displayCenter * CFrame.Angles(0, 1.5707963267948966, 0)
		v46:PivotTo(v47)
		self:_setupLandedBrainrot(v46, v43, flag3, offer.ServerExpiresAt)
	end

	local mutation = offer.Mutation
	local v46 = v25[`{v42.Type}:{v42.Name}:{mutation or "Normal"}`]

	if v46 and v46.Parent then
		renderModel(v46)
		return
	end

	local modelBestEffort = BrainrotAssets.getModelBestEffort(offer.Name, function(p2)
		renderModel(p2)
	end, 20)

	if modelBestEffort then
		renderModel(modelBestEffort)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isSpinHidden(position: Vector3)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return false
	end

	if (currentCamera.CFrame.Position - position).Magnitude > 100 then
		return true
	end

	local _, v40 = currentCamera:WorldToViewportPoint(position)
	return not v40
end

function class:_animateStage(data, p: number, p2: string)
	if v23.SelectedIdentity ~= p2 or v23.SelectedOwnerUserId ~= p then
		return
	end

	prepareStageDisplay()
	updateMutationScreen(data.Mutation)
	local v40 = count2
	local entries = data.Entries

	if #entries == 0 or not entries[data.ResultIndex] then
		return
	end

	local displayCenter = getDisplayCenter() -- equivalent call inferred; original call site unknown

	if not displayCenter then
		return
	end

	playLeverAnimation()
	setLuckySpinVfx(data.Multiplier, data.Multiplier > 1)
	local names = {}

	for _, entry in ipairs(entries) do
		if entry.Type == "Brainrot" then
			table.insert(names, entry.Name)
		end
	end

	BrainrotAssets.preload(names)
	local parent

	if v24 then
		parent = v24
	else
		parent = Instance.new("Folder")
		parent.Name = "RNGMachineDisplay"
		parent.Parent = workspace
		v24 = parent
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "Spinner"
	numberValue.Value = 0
	numberValue.Parent = parent
	v23.ActiveSpinner = numberValue
	local v42 = math.max(0, workspace:GetServerTimeNow() - data.StartedAt)

	if p ~= localPlayer.UserId and data.ResultType == "Luck" then
		local stageMultiplier = getStageMultiplier(data) -- equivalent call inferred; original call site unknown
		local v43 = data.Duration * 0.85 - v42

		if stageMultiplier and stageMultiplier >= 10 and v43 > 0 then
			task.delay(v43, function()
				if v40 == count2 and v23.SelectedOwnerUserId == p and v23.SelectedIdentity == p2 then
					emitHighLuckExplosion(stageMultiplier)
				end
			end)
		end
	end

	if p ~= localPlayer.UserId then
		local v43 = math.min(2, data.Duration)
		v42 = math.min(v42, (math.max(0, data.Duration - v43)))
	end

	local v43 = math.max(0.01, data.Duration - v42)
	v23.StageVisualEndsAt = p == localPlayer.UserId and 0 or os.clock() + math.max(0.01, data.Duration * 0.85 - v42)
	local v44 = math.max(0, 0.4 - v42)
	local v45 = os.clock() + v44
	local count3 = #entries
	local v46 = {}
	local v47 = {}
	local v48 = {}
	local scalesByInstance = {}
	local v49 = false

	local function restoreFinalScale(instance, p3: number)
		-- equivalent call inferred; original call site unknown
		if isSpinHidden(displayCenter.Position) then
			task.spawn(function()
				if v40 ~= count2 or not instance.Parent then
					return
				end

				instance:ScaleTo(p3)
			end)
			return
		end

		local v50 = math.abs(instance:GetScale() - p3)

		if p3 * 0.001 <= v50 then
			instance:ScaleTo(p3)
		end
	end

	local function initializeScale(instance)
		local defaultScale = instance:GetAttribute("DefaultScale")
		local scale

		if typeof(defaultScale) == "number" then
			scale = defaultScale
		else
			scale = instance:GetScale()
		end

		if typeof(defaultScale) ~= "number" then
			instance:SetAttribute("DefaultScale", scale)
		end

		local scale2 = instance:GetScale()

		if v44 > 0 then
			-- equivalent call inferred; original call site unknown
			if not isSpinHidden(displayCenter.Position) then
				local v50 = scale * 0.5
				local v51 = math.abs(scale2 - v50)

				if scale * 0.001 <= v51 then
					instance:ScaleTo(v50)
				end

				scale2 = v50
			end
		end

		v48[instance] = scale2
		scalesByInstance[instance] = scale
	end

	local function registerModel(p3: number, p4, p5)
		if v40 ~= count2 or v46[p3] then
			return
		end

		local displayCacheKey = getDisplayCacheKey(p4, data.Mutation) -- equivalent call inferred; original call site unknown
		local v50 = v25[displayCacheKey]

		if not (v50 and v50.Parent) then
			v50 = createDisplay(p4, p5)

			if not v50 then
				return
			end

			local v51

			if p4.Type == "Brainrot" then
				v51 = v50:GetAttribute("PlayIdleAnimation") == true
			else
				v51 = false
			end

			if v51 then
				destroySpinParticleEmitters(v50)
				destroySpinTrails(v50)
			end

			v50:PivotTo(CFrame.new(0, 100000, 100000))
			v50.Parent = parent

			if v51 and data.Mutation then
				task.spawn(function()
					local v52 = Animals:ApplyMutation(v50, p4.Name, data.Mutation)

					if v40 == count2 and v50.Parent then
						if v52 then
							v50.Destroying:Once(v52)
						end

						destroySpinTrails(v50)
					elseif v52 then
						v52()
					end
				end)
			end

			v25[displayCacheKey] = v50
			task.spawn(function()
				local success, result = pcall(ContentProvider.PreloadAsync, ContentProvider, { v50 })

				if not success then
					warn(result)
				end
			end)

			if v50:GetAttribute("PlayIdleAnimation") then
				task.spawn(playIdleAnimation, v50, p4.Name)
			end
		end

		local v51 = assert(v50)
		v46[p3] = v51
		table.insert(v47, v51)
		initializeScale(v51)

		if v49 and p3 == data.ResultIndex then
			restoreFinalScale(v51, scalesByInstance[v51])
			v51:PivotTo(displayCenter * CFrame.Angles(0, 1.5707963267948966, 0))

			if data.ResultType == "Brainrot" then
				self:_setupLandedBrainrot(v51, data, p == localPlayer.UserId, nil)
			end
		else
			v51:PivotTo(CFrame.new(0, 100000, 100000))
		end
	end

	for i, entry in ipairs(entries) do
		local mutation = data.Mutation
		local v51 = v25[`{entry.Type}:{entry.Name}:{mutation or "Normal"}`]

		if v51 and v51.Parent then
			registerModel(i, entry, v51)
		elseif entry.Type == "Luck" then
			registerModel(i, entry, nil)
		else
			local v52 = i
			local v53 = entry
			local modelBestEffort = BrainrotAssets.getModelBestEffort(entry.Name, function(p3)
				registerModel(v52, v53, p3)
			end, 20)

			if modelBestEffort then
				registerModel(i, entry, modelBestEffort)
			end
		end
	end

	local v50 = count3
	local v51 = -1e999

	local function updateObjects(p3: number)
		local v52 = os.clock() < v45

		-- equivalent call inferred; original call site unknown
		if isSpinHidden(displayCenter.Position) then
			for _, v53 in pairs(v46) do
				if v53.Parent then
					v53:PivotTo(CFrame.new(0, 100000, 100000))
				end
			end
		else
			for i = 1, count3 do
				local v53 = v46[i]

				if not (v53 and v53.Parent) then
					continue
				end

				local v54 = count3 == 1 and 0.5 or math.clamp((p3 - (i - 1)) % count3 * 0.5, 0, 1)
				local v55 = math.sin(v54 * 3.141592653589793)
				local v56 = scalesByInstance[v53]
				local v57 = v48[v53]

				if v55 < 0.01 then
					if not v52 and v57 > 0.001 then
						v53:ScaleTo(0.001)
						v48[v53] = 0.001
					end

					v53:PivotTo(CFrame.new(0, 100000, 100000))
				else
					local v58 = math.clamp(v56 * v55 * 1.01, 0.001, v56)

					if not v52 then
						local v59 = math.abs(v57 - v58)

						if v56 * 0.001 <= v59 then
							v53:ScaleTo(v58)
							v48[v53] = v58
						end
					end

					v53:PivotTo(displayCenter * CFrame.new(v55 * -5 + 5, v55 * 3 + -3, (v54 - 0.5) * 20) * CFrame.Angles(
						0,
						1.5707963267948966,
						0
					))
				end
			end

			local v53 = (math.floor(p3 + 0.5) - 1) % count3 + 1

			if v53 ~= v50 then
				v50 = v53
				local now = os.clock()

				if now - v51 >= 0.1 then
					v51 = now
					playSpinTick(data)
				end
			end
		end
	end

	local v52 = RNGMachineData.DisplayRotations * count3 + data.ResultIndex
	local v54 = v52 * TweenService:GetValue(
		not (data.Duration > 0) and 1 or math.clamp(v42 / data.Duration, 0, 1),
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.Out
	)
	local changedConnection = numberValue.Changed:Connect(updateObjects)
	v23.ActiveConnection = changedConnection
	numberValue.Value = v54
	updateObjects(v54)
	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(v43, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Value = v52
		}
	)
	v23.ActiveTween = tween
	tween:Play()
	task.spawn(function()
		local v55 = math.max(0, data.Duration * 0.85 - v42)
		task.wait(v55)

		if v40 == count2 and parent.Parent then
			numberValue.Value = v52

			if v23.ActiveSpinner == numberValue then
				v23.ActiveSpinner = nil
				v23.ActiveTween = nil
				v23.ActiveConnection = nil
			end

			tween:Cancel()
			changedConnection:Disconnect()
			numberValue:Destroy()
			v49 = true
			local v56 = v46[data.ResultIndex]

			if v56 then
				restoreFinalScale(v56, scalesByInstance[v56])

				for k, v58 in pairs(v46) do
					if k ~= data.ResultIndex then
						v58:PivotTo(CFrame.new(0, 100000, 100000))
					end
				end

				v56:PivotTo(displayCenter * CFrame.Angles(0, 1.5707963267948966, 0))
				local v58 = data.ResultType == "Luck" and "LuckLanded" or "BrainrotLanded"
				local position = displayCenter.Position
				local stagePlaybackSpeed = getStagePlaybackSpeed(data.Stage) -- equivalent call inferred; original call site unknown
				local sound = rNGMachine:FindFirstChild(v58)
				local v59

				if sound and sound:IsA("Sound") then
					local playbackSpeed = stagePlaybackSpeed or 1
					v59 = SoundController:PlaySound(sound, position, false)

					if v59 then
						v59.PlaybackSpeed = playbackSpeed
					end
				end

				if v59 then
					local v60

					if data.ResultType == "Luck" then
						v60 = math.min((data.Stage - 1) * 0.12 + 1.2, 1.8)
					else
						v60 = getSpinVolumeMultiplier(data.Stage)
					end

					v59.Volume *= v60 * 1.2
				end

				if data.ResultType == "Luck" then
					local stageMultiplier = getStageMultiplier(data) -- equivalent call inferred; original call site unknown

					if not stageMultiplier then
						playLuckVFX(v56, nil)
						return
					end

					local _, v61 = getLuckStyle(stageMultiplier)
					playLuckVFX(v56, v61)
					setLuckySpinVfx(stageMultiplier, true)

					if stageMultiplier < 10 then
						emitExplosion(v35, stageMultiplier)
					end
				else
					setLuckySpinVfx(data.Multiplier, false)
					self:_setupLandedBrainrot(v56, data, p == localPlayer.UserId, nil)
				end
			else
				for _, v57 in ipairs(v47) do
					v57:PivotTo(CFrame.new(0, 100000, 100000))
				end

				local v57 = data.ResultType == "Luck" and "LuckLanded" or "BrainrotLanded"
				local position = displayCenter.Position
				local stagePlaybackSpeed = getStagePlaybackSpeed(data.Stage) -- equivalent call inferred; original call site unknown
				local sound = rNGMachine:FindFirstChild(v57)

				if sound then
					if not sound:IsA("Sound") then
						return
					end

					local playbackSpeed = stagePlaybackSpeed or 1
					local v59 = SoundController:PlaySound(sound, position, false)

					if v59 then
						v59.PlaybackSpeed = playbackSpeed
					end
				end
			end
		else
			if v23.ActiveSpinner == numberValue then
				v23.ActiveSpinner = nil
				v23.ActiveTween = nil
				v23.ActiveConnection = nil
			end

			changedConnection:Disconnect()
			tween:Cancel()
			numberValue:Destroy()
		end
	end)
end

local function isOfferActivityValid(p, p2: number)
	return p.State == "Offer" and p.Offer ~= nil and p2 < p.Offer.ServerExpiresAt
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isSpinActivityActive(session, serverTimeNow: number)
	if session.State ~= "Spinning" then
		return false
	end

	local stage = session.Stage
	return not stage or serverTimeNow < stage.StartedAt + stage.Duration * 0.85
end

local function getActivityPriorityMultiplier(p)
	return p.Multiplier
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDisplayedSpinTier(session)
	local stage = session.Stage

	if stage and stage.ResultType == "Luck" then
		return tonumber(string.match(stage.ResultName, "%d+")) or session.Multiplier
	end

	return session.Multiplier
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isStageNewer(privateStagePayload, stage)
	if not stage then
		return true
	end

	if privateStagePayload.StartedAt == stage.StartedAt then
		return privateStagePayload.Stage > stage.Stage
	end

	return privateStagePayload.StartedAt > stage.StartedAt
end

local function getSpinningTextLabel()
	local spinningText = v23.SpinningText

	if spinningText and spinningText.Parent then
		return spinningText
	end

	local rNGMachine2 = workspace:FindFirstChild("RNGMachine")
	local spinningText2 = rNGMachine2 and rNGMachine2:FindFirstChild("SpinningText", true)

	if spinningText2 and spinningText2:IsA("TextLabel") then
		v23.SpinningText = spinningText2
		return spinningText2
	else
		return nil
	end
end

local function updateSpinningText(p)
	v23.SpinningTextToken += 1
	local spinningTextToken = v23.SpinningTextToken
	local spinningText = v23.SpinningText

	if not (spinningText and spinningText.Parent) then
		local rNGMachine2 = workspace:FindFirstChild("RNGMachine")
		spinningText = rNGMachine2 and rNGMachine2:FindFirstChild("SpinningText", true)

		if spinningText and spinningText:IsA("TextLabel") then
			v23.SpinningText = spinningText
		else
			spinningText = nil
		end
	end

	if not spinningText then
		v32.SetPlayerPreviewVisible(false)
		return
	end

	local playerByUserId

	if p and p.UserId ~= localPlayer.UserId then
		playerByUserId = Players:GetPlayerByUserId(p.UserId)
	end

	if playerByUserId then
		spinningText.Text = `{playerByUserId.DisplayName} is spinning...`
		local imageLabel = spinningText:FindFirstChild("ImageLabel")

		if imageLabel and imageLabel:IsA("ImageLabel") then
			imageLabel.Image = `rbxthumb://type=AvatarHeadShot&id={playerByUserId.UserId}&w=150&h=150`
		end

		spinningText.TextXAlignment = Enum.TextXAlignment.Left
		spinningText.Position = UDim2.new(spinningText.Position.X.Scale, spinningText.Position.X.Offset, 0.33, 0)
		spinningText.Visible = true
		v32.SetPlayerPreviewVisible(true)
		task.spawn(function()
			local parent = spinningText.Parent
			local imageLabel2 = spinningText:FindFirstChild("ImageLabel")

			if spinningTextToken ~= v23.SpinningTextToken or not (parent and parent:IsA("BillboardGui") and imageLabel2 and imageLabel2:IsA("ImageLabel")) then
				return
			end

			local getTextBoundsParams = Instance.new("GetTextBoundsParams")
			getTextBoundsParams.Text = spinningText.Text
			getTextBoundsParams.Font = spinningText.FontFace
			getTextBoundsParams.RichText = spinningText.RichText
			getTextBoundsParams.Size = 100
			local success, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)
			getTextBoundsParams:Destroy()

			if not success or textBoundsAsync.Y <= 0 then
				return
			end

			local scale = spinningText.Size.Y.Scale
			local v41 = parent.Size.Y.Scale / parent.Size.X.Scale
			local v42 = scale * (textBoundsAsync.X / textBoundsAsync.Y) * v41
			local v43 = scale * v41
			local v44 = v43 * 0.15
			spinningText.Size = UDim2.fromScale(v42, scale)
			spinningText.Position = UDim2.fromScale(0.5 + (v43 + v44) / 2, 0.33)
			imageLabel2.AnchorPoint = Vector2.new(1, 0.5)
			imageLabel2.Position = UDim2.fromScale(-v44 / v42, 0.5)
			imageLabel2.Size = UDim2.fromScale(1, 1)
			imageLabel2.SizeConstraint = Enum.SizeConstraint.RelativeYY
		end)
	else
		spinningText.Visible = false
		v32.SetPlayerPreviewVisible(false)
	end
end

local function getSelectedActivity()
	local activityData = v23.ActivityData
	local v40

	if activityData then
		v40 = activityData.Sessions[tostring(localPlayer.UserId)]
	end

	local privateStagePayload = v23.PrivateStagePayload

	if v10 ~= nil and v10.State == "Spinning" or v22 then
		if v40 and v40.State == "Spinning" then
			local stage = v40.Stage

			if privateStagePayload then
				-- equivalent call inferred; original call site unknown
				if isStageNewer(privateStagePayload, stage) then
					stage = privateStagePayload
				end
			end

			return v40, stage
		else
			local v41 = {
				UserId = localPlayer.UserId,
				SpinStartedAt = 0,
				State = "Spinning",
				Multiplier = 0,
				Stage = 0,
				Offer = nil
			}
			local spinStartedAt

			if privateStagePayload then
				spinStartedAt = privateStagePayload.StartedAt
			else
				spinStartedAt = workspace:GetServerTimeNow()
			end

			v41.SpinStartedAt = spinStartedAt
			v41.Multiplier = not privateStagePayload and 1 or privateStagePayload.Multiplier
			v41.Stage = privateStagePayload
			return v41, privateStagePayload
		end
	else
		local serverTimeNow = workspace:GetServerTimeNow()
		local offer

		if v10 then
			offer = v10.Offer
		end

		if v40 then
			if v40.State == "Spinning" then
				return v40, v40.Stage
			end

			local v41

			if v40.State == "Offer" and v40.Offer ~= nil then
				v41 = serverTimeNow < v40.Offer.ServerExpiresAt
			else
				v41 = false
			end

			if v41 then
				return v40, nil
			end
		end

		if v10 and v10.State == "Offer" and offer and serverTimeNow < offer.ServerExpiresAt then
			return {
				UserId = localPlayer.UserId,
				SpinStartedAt = offer.ExpiresAt,
				State = "Offer",
				Multiplier = offer.Multiplier,
				Stage = nil,
				Offer = {
					Name = offer.Name,
					Multiplier = offer.Multiplier,
					Mutation = offer.Mutation,
					ExpiresAt = offer.ExpiresAt,
					ServerExpiresAt = offer.ServerExpiresAt
				}
			}, nil
		end

		if not activityData then
			return nil, nil
		end

		local v41 = nil
		local v42 = nil

		for _, session in pairs(activityData.Sessions) do
			if not (session.UserId == localPlayer.UserId or Players:GetPlayerByUserId(session.UserId)) then
				continue
			end

			local spinActivityActive = isSpinActivityActive(session, serverTimeNow) -- equivalent call inferred; original call site unknown

			if not spinActivityActive then
				if session.State == "Offer" and session.Offer ~= nil then
					spinActivityActive = serverTimeNow < session.Offer.ServerExpiresAt
				else
					spinActivityActive = false
				end
			end

			if not spinActivityActive then
				continue
			end

			if session.State == "Offer" then
				local v43 = assert(session.Offer)

				if not (v43.ExpiresAt < v23.LatestOfferExpiresAt) then
					local offer2 = v42 and v42.Offer

					if not offer2 or v43.ExpiresAt > offer2.ExpiresAt or v43.ExpiresAt == offer2.ExpiresAt and v42 and session.SpinStartedAt > v42.SpinStartedAt then
						v42 = session
					end
				end
			else
				local multiplier = session.Multiplier
				local v43 = not v41 and -1e999 or v41.Multiplier

				if not v41 or v43 < multiplier or multiplier == v43 and session.SpinStartedAt < v41.SpinStartedAt then
					v41 = session
				end
			end
		end

		local v43 = v41 or v42

		if v43 and v43.State == "Spinning" then
			return v43, v43.Stage
		end

		return v43, nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getActivityIdentity(selectedActivity, stage)
	if selectedActivity.State == "Offer" then
		local v40 = assert(selectedActivity.Offer)
		return (`{selectedActivity.UserId}:Offer:{v40.ExpiresAt}`)
	end

	if stage then
		return (`{selectedActivity.UserId}:Spinning:{stage.Stage}:{stage.StartedAt}`)
	end

	return (`{selectedActivity.UserId}:Spinning:Pending:{selectedActivity.SpinStartedAt}`)
end

function class:_reconcileActivityDisplay()
	local selectedActivity, stage = getSelectedActivity()

	if selectedActivity then
		if selectedActivity.State == "Offer" and selectedActivity.Offer then
			v23.LatestOfferExpiresAt = math.max(v23.LatestOfferExpiresAt, selectedActivity.Offer.ExpiresAt)
		end

		if selectedActivity.UserId ~= localPlayer.UserId and v23.SelectedOwnerUserId and v23.SelectedOwnerUserId ~= localPlayer.UserId and v23.SelectedState == "Spinning" and v23.ActivityData then
			local session = v23.ActivityData.Sessions[tostring(v23.SelectedOwnerUserId)]

			if session and session.State == "Spinning" then
				local v40

				if selectedActivity.UserId == session.UserId then
					v40 = false
				else
					local multiplier = selectedActivity.Multiplier
					local displayedSpinTier = getDisplayedSpinTier(session) -- equivalent call inferred; original call site unknown
					v40 = displayedSpinTier < multiplier
				end

				if not v40 then
					stage = session.Stage
					selectedActivity = session
				end
			end
		end

		local activityIdentity = getActivityIdentity(selectedActivity, stage) -- equivalent call inferred; original call site unknown

		if selectedActivity.State == "Spinning" and v23.SelectedOwnerUserId == selectedActivity.UserId and v23.SelectedState == "Spinning" and v23.SelectedIdentity and v23.SelectedIdentity ~= activityIdentity and os.clock() < v23.StageVisualEndsAt then
			updateSpinningText(selectedActivity)
			task.delay(v23.StageVisualEndsAt - os.clock(), function()
				self:_reconcileActivityDisplay()
			end)
		else
			local v40

			if v23.SelectedOwnerUserId == selectedActivity.UserId then
				v40 = v23.SelectedState == "Spinning"
			else
				v40 = false
			end

			if selectedActivity.State == "Offer" and selectedActivity.UserId ~= localPlayer.UserId and v40 and os.clock() < v23.StageVisualEndsAt then
				updateSpinningText(selectedActivity)
				task.delay(v23.StageVisualEndsAt - os.clock(), function()
					self:_reconcileActivityDisplay()
				end)
			else
				local activityIdentity2 = getActivityIdentity(selectedActivity, stage) -- equivalent call inferred; original call site unknown
				local v41 = selectedActivity.UserId == localPlayer.UserId
				updateSpinningText(selectedActivity)

				if v23.SelectedIdentity == activityIdentity2 and v24 then
					if selectedActivity.State == "Offer" and v41 then
						self:_updateLandedOffer(v10)
					end
				else
					v23.SelectedIdentity = activityIdentity2
					v23.SelectedOwnerUserId = selectedActivity.UserId
					v23.SelectedState = selectedActivity.State

					if selectedActivity.State == "Offer" then
						if v41 or not selectedActivity.Stage or v40 then
							self:_renderActivityOffer(selectedActivity, v41)
							return
						end

						local clone = table.clone(selectedActivity.Stage)
						clone.StartedAt = workspace:GetServerTimeNow()
						self:_animateStage(clone, selectedActivity.UserId, activityIdentity2)
					else
						if stage then
							self:_animateStage(stage, selectedActivity.UserId, activityIdentity2)
							return
						end

						prepareStageDisplay()
						v29 = nil
						local displayWithRichText = v29 or ""
						local mutation = Mutations[displayWithRichText]

						if mutation then
							displayWithRichText = mutation.DisplayWithRichText or mutation.DisplayText
						end

						if v30 then
							CustomRichTextController.apply(v30, displayWithRichText, {
								attachToInstance = true
							})
						end

						if v31 then
							v31.LocalTransparencyModifier = v29 and 1 or 0
						end

						setLuckySpinVfx(selectedActivity.Multiplier, selectedActivity.Multiplier > 1)
					end
				end
			end
		end
	else
		updateSpinningText(nil)

		if v23.SelectedIdentity or v24 then
			clearDisplay()
		end

		v29 = nil
		local displayWithRichText = v29 or ""
		local mutation = Mutations[displayWithRichText]

		if mutation then
			displayWithRichText = mutation.DisplayWithRichText or mutation.DisplayText
		end

		if v30 then
			CustomRichTextController.apply(v30, displayWithRichText, {
				attachToInstance = true
			})
		end

		if v31 then
			v31.LocalTransparencyModifier = v29 and 1 or 0
		end

		setLuckySpinVfx(1, false)
	end
end

local function getSynchronizedSkillLevel(object, p, max: number)
	local v40 = object:Get((`RNGMachine.{p}Level`))

	if typeof(v40) == "number" then
		return (math.clamp(math.floor(v40), 0, max))
	end

	return 0
end

local function getClientState(data, object)
	local rebirth = object:Get("Rebirth")
	local rebirths = (typeof(rebirth) ~= "number" or rebirth ~= rebirth) and 0 or rebirth
	local v41 = #data.SkillTree.Luck
	local v42 = object:Get("RNGMachine.LuckLevel")
	local level = typeof(v42) ~= "number" and 0 or math.clamp(math.floor(v42), 0, v41)
	local v44 = #data.SkillTree.Speed
	local v45 = object:Get("RNGMachine.SpeedLevel")
	local level2 = typeof(v45) ~= "number" and 0 or math.clamp(math.floor(v45), 0, v44)
	local spinCost = math.round((data.SpinCosts[level + 1] or data.SpinCosts[#data.SpinCosts]) * data.SpeedSpinCostMultiplier ^ level2)
	local v48 = {
		Enabled = data.Enabled,
		ShowResultOdds = data.ShowResultOdds,
		State = data.State,
		SpinCost = spinCost,
		SkillTree = data.SkillTree,
		SpinCosts = data.SpinCosts,
		SpeedSpinCostMultiplier = data.SpeedSpinCostMultiplier,
		Offer = data.Offer,
		LimitedStocks = data.LimitedStocks,
		Rebirths = rebirths,
		Skills = 0
	}
	local v51 = #data.SkillTree.GoldMutation
	local v52 = object:Get("RNGMachine.GoldMutationLevel")
	local skills = {
		Luck = {
			Level = level
		},
		Speed = {
			Level = level2
		},
		GoldMutation = {
			Level = typeof(v52) ~= "number" and 0 or math.clamp(math.floor(v52), 0, v51)
		},
		DiamondMutation = 0,
		RainbowMutation = 0,
		EventMutation = 0
	}
	local v54 = #data.SkillTree.DiamondMutation
	local v55 = object:Get("RNGMachine.DiamondMutationLevel")
	skills.DiamondMutation = {
		Level = typeof(v55) ~= "number" and 0 or math.clamp(math.floor(v55), 0, v54)
	}
	local v57 = #data.SkillTree.RainbowMutation
	local v58 = object:Get("RNGMachine.RainbowMutationLevel")
	skills.RainbowMutation = {
		Level = typeof(v58) ~= "number" and 0 or math.clamp(math.floor(v58), 0, v57)
	}
	local v60 = #data.SkillTree.EventMutation
	local v61 = object:Get("RNGMachine.EventMutationLevel")
	skills.EventMutation = {
		Level = typeof(v61) ~= "number" and 0 or math.clamp(math.floor(v61), 0, v60)
	}
	v48.Skills = skills
	return v48
end

function class:_handleStateChanged(data)
	local v40 = v10
	v10 = data
	v32.Render(data.LimitedStocks)

	if v11 == "EventMutation" and data.Skills.RainbowMutation.Level < #data.SkillTree.RainbowMutation then
		v11 = "Main"
		updateSkillTreePageChrome() -- equivalent call inferred; original call site unknown
		centerCanvas() -- equivalent call inferred; original call site unknown
	end

	self:_updateLandedOffer(data)
	self:_reconcilePrompts(data)

	if v12 and v12.Enabled then
		self:_renderSkillTree()

		if v40 then
			animateNewlyRevealedNodes(v40, data)
		end

		task.defer(focusSkillTreeSelection)
	end

	if data.State == "Spinning" then
		if (not v40 or v40.State ~= "Spinning") and not v22 then
			v23.PrivateStagePayload = nil
		end

		self:_reconcileActivityDisplay()
		v22 = false
	else
		v23.PrivateStagePayload = nil
		v22 = false
		self:_reconcileActivityDisplay()
	end
end

function class:_setupObservers()
	Observers.observeTag("RNGMachineCenter", observeDisplayCenter)
	Observers.observeTag("RNGMachineSpinPrompt", observeSpinPrompt)
	Observers.observeTag("RNGMachineSkillTreePrompt", observeSkillTreePrompt)
	Observers.observeTag("RNGMachineRecolorVFX", vfxObserver)
	Observers.observeTag("RNGMachinePadVFX", vfxObserver2)
	Observers.observeTag("RNGMachineLuckExplosionVFX", vfxObserver3)
	Observers.observeTag("RNGMachine10xExplosionVFX", vfxObserver4)
	Observers.observeTag("RNGMachine12xExplosionVFX", vfxObserver5)
	Observers.observeTag("RNGMachineLeverRoot", observeLeverRoot)
	Observers.observeTag("RNGMachineMutationScreen", observeMutationScreen)
	Observers.observeTag("RNGMachineMutationScreenLine", observeMutationScreenLine)
	Observers.observeTag("RNGMachineLuckGui", function(p)
		p.Enabled = ReplicatedStorage:GetAttribute("RNGMachineLuck") == true
		local rNGMachineLuckChangedConnection = ReplicatedStorage:GetAttributeChangedSignal("RNGMachineLuck"):Connect(function()
			p.Enabled = ReplicatedStorage:GetAttribute("RNGMachineLuck") == true
		end)
		return function()
			rNGMachineLuckChangedConnection:Disconnect()
		end
	end)
	ReplicatedStorage:GetAttributeChangedSignal("3RoadsEvent"):Connect(function()
		task.defer(function()
			clearDisplay()
			self:_reconcileActivityDisplay()
		end)
	end)
	deferPromptReconcile() -- equivalent call inferred; original call site unknown
end

function class:_setupRemotes()
	remoteEvent.OnClientEvent:Connect(function(privateStagePayload)
		if workspace:GetServerTimeNow() - privateStagePayload.StartedAt > privateStagePayload.Duration + 0.5 then
			return
		end

		if not v10 or v10.State ~= "Spinning" then
			v22 = true
		end

		v23.PrivateStagePayload = privateStagePayload
		self:_reconcileActivityDisplay()
	end)
	remoteEvent2.OnClientEvent:Connect(function(value)
		if v23.SelectedOwnerUserId == localPlayer.UserId and v23.SelectedState == "Spinning" and typeof(value) == "number" and (value == 10 or value == 12) then
			emitHighLuckExplosion(value)
		end
	end)
end

function class:_setupActivityReplication()
	local function reconcileCharacter()
		task.delay(0.1, function()
			self:_reconcileActivityDisplay()
			updateSpinningText(getSelectedActivity())
			v32.Refresh()
		end)
	end

	Players.LocalPlayer.CharacterAdded:Connect(reconcileCharacter)

	if Players.LocalPlayer.Character then
		task.delay(0.1, function()
			self:_reconcileActivityDisplay()
			updateSpinningText(getSelectedActivity())
			v32.Refresh()
		end)
	end

	Players.PlayerRemoving:Connect(function(player)
		if v23.SelectedOwnerUserId == player.UserId then
			updateSpinningText(nil)
			clearDisplay()
		end

		task.defer(function()
			self:_reconcileActivityDisplay()
		end)
	end)
	task.spawn(function()
		rNGMachineActivity:WaitForLoaded()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateActivity(activityData)
			v23.ActivityData = activityData
			self:_reconcileActivityDisplay()
		end

		rNGMachineActivity:ListenRaw(updateActivity)
		updateActivity(rNGMachineActivity.Data) -- equivalent call inferred; original call site unknown
	end)
end

function class:_setupStateReplication()
	task.spawn(function()
		v:WaitForLoaded()
		local v40 = Synchronizer:Wait(localPlayer)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateState()
			local data = v.Data

			if data then
				self:_handleStateChanged((getClientState(data, v40)))
			end
		end

		v:ListenRaw(function(p)
			self:_handleStateChanged((getClientState(p, v40)))
		end)
		v40:OnChanged("Rebirth", updateState)

		for _, v41 in ipairs(frozen2) do
			v40:OnChanged(`RNGMachine.{v41}Level`, updateState)
		end

		updateState() -- equivalent call inferred; original call site unknown
	end)
end

function class:Start()
	local leverAnimation = script:FindFirstChild("LeverAnimation")

	if leverAnimation and leverAnimation:IsA("Animation") then
		v2 = leverAnimation
	else
		warn("RNG Machine lever animation is missing")
	end

	self:_setupSkillTree()
	self:_setupObservers()
	self:_setupRemotes()
	self:_setupActivityReplication()
	self:_setupStateReplication()
	task.spawn(function()
		local success, result = pcall(ContentProvider.PreloadAsync, ContentProvider, rNGMachine:GetChildren())

		if not success then
			warn(result)
		end
	end)
end

return table.freeze(class)