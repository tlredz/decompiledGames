local createVector = vector.create
local HudNavigation = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Presentation"):WaitForChild("HudNavigation"))
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local weapons = chickenOrHero:WaitForChild("Weapons")
local SkinCatalog = require(weapons:WaitForChild("SkinCatalog"))
local armoryEvent = weapons:WaitForChild("ArmoryEvent")
local presentationCues = chickenOrHero:WaitForChild("Audio"):WaitForChild("PresentationCues")
local playerGui = localPlayer:WaitForChild("PlayerGui")
local valleyArmory = playerGui:WaitForChild("ValleyArmory")
local valleyArmoryShade = playerGui:WaitForChild("ValleyArmoryShade")
local canvas = valleyArmory.Overlay.Canvas
local dock = valleyArmory.Dock
local v = {
	Shop = 68,
	Abilities = 108,
	Items = 72,
	Inventory = 124
}
local ArmoryStyle = require(chickenOrHero:WaitForChild("Presentation"):WaitForChild("ArmoryStyle"))
local clone = canvas.Tabs.Shop:Clone()
clone.Name = "Abilities"
clone.Text = "ABILITIES"
clone.Parent = canvas.Tabs
local clone2 = canvas.Tabs.Shop:Clone()
clone2.Name = "Items"
clone2.Text = "ITEMS"
clone2.Parent = canvas.Tabs
canvas.Tabs.Shop.Text = "SHOP"
canvas.Tabs.Inventory.Text = "MY KNIVES"
ArmoryStyle.apply(valleyArmory)
local StorefrontClient = require(weapons:WaitForChild("StorefrontClient"))
local v2 = StorefrontClient.new(canvas, weapons, SkinCatalog, presentationCues, localPlayer)
local v3 = {
	loaded = false,
	owned = 0,
	equipped = 0,
	coins = 0,
	gems = 0
}
v3.owned = {}
v3.equipped = SkinCatalog.Default
local v4 = "Shop"
local default = SkinCatalog.Default
local v5 = false
local v6 = true
local clones = {}
local model = nil
local camera = nil
local v7 = 3
local total = 0
local v8 = false
local X = 0
local selectedObject = nil
local zero = Vector2.zero

local function applyViewStyle()
	local visible = v4 == "Inventory"

	for _, v10 in {
		"Hero",
		"Details",
		"Sounds",
		"Status",
		"Selection"
	} do
		canvas[v10].Visible = visible
	end

	v2:setOpen(v5 and not visible, v4)
	ArmoryStyle.view(canvas, visible, v4)
end

local function permitted()
	return localPlayer:GetAttribute("ClientReady") == true and localPlayer:GetAttribute("InMatch") ~= true and localPlayer:GetAttribute("TutorialRouting") ~= true and localPlayer:GetAttribute("ScreenPresentationActive") ~= true and localPlayer:GetAttribute("AdminRefreshActive") ~= true
end

local function comma(p)
	return tostring((math.floor(p))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function layout()
	local absoluteSize = valleyArmory.AbsoluteSize

	if absoluteSize.X == 0 or absoluteSize.Y == 0 or absoluteSize == zero then
		return
	end

	zero = absoluteSize
	dock.Scale.Scale = math.min(absoluteSize.X / 1280, absoluteSize.Y / 720)
	local v9 = absoluteSize.X / absoluteSize.Y < 1.1
	local v10 = not v9 and absoluteSize.Y < 600
	local v11 = v9 and 930 or v10 and 490 or 680
	canvas.Size = UDim2.fromOffset(v9 and 600 or 1080, v11)
	local v12 = math.max(14, GuiService:GetGuiInset().Y + 6)
	local v13 = math.max(100, absoluteSize.Y - v12 - math.max(14, absoluteSize.Y * 0.04))
	canvas.Position = UDim2.new(0.5, 0, 0, v12 + v13 * 0.5)
	canvas.Scale.Scale = math.min(1.05, absoluteSize.X * 0.94 / (v9 and 600 or 1080), v13 / v11)
	canvas.TopRule.Size = UDim2.new(1, 0, 0, 3)
	canvas.Close.Position = UDim2.new(1, -85, 0, 23)
	canvas.Wallet.Position = UDim2.fromOffset(v9 and 320 or 790, 23)
	canvas.Tabs.Position = UDim2.fromOffset(v9 and 28 or 352, v9 and 92 or 25)
	canvas.Tabs.Size = UDim2.fromOffset(426, 48)
	local total2 = 0

	for _, v14 in {
		"Shop",
		"Abilities",
		"Items",
		"Inventory"
	} do
		local tab = canvas.Tabs[v14]
		tab.Position = UDim2.fromOffset(total2, 0)
		tab.Size = UDim2.fromOffset(v[v14], 42)
		tab.TextScaled = true
		tab.TextWrapped = false
		tab.TextTruncate = Enum.TextTruncate.None
		total2 += v[v14] + 18
	end

	local tab = canvas.Tabs[v4]
	canvas.Tabs.ActiveLine.Position = UDim2.fromOffset(tab.Position.X.Offset, 44)
	canvas.Tabs.ActiveLine.Size = UDim2.fromOffset(v[v4], 3)
	canvas.HeaderRule.Position = UDim2.fromOffset(28, v9 and 151 or 99)
	canvas.HeaderRule.Size = UDim2.new(1, -56, 0, 1)
	canvas.Hero.Position = UDim2.fromOffset(v9 and 5 or 28, v9 and 163 or v10 and 110 or 120)
	canvas.Hero.Size = UDim2.fromOffset(590, v9 and 275 or v10 and 245 or 332)
	canvas.Hero.Field.Size = UDim2.fromOffset(518, v10 and 210 or 275)
	canvas.Hero.Field.CentreLine.Size = UDim2.fromOffset(1, v10 and 210 or 275)
	canvas.Hero.Field.CentreCircle.Position = UDim2.fromOffset(190, v10 and 36 or 68)
	canvas.Hero.PreviewHint.Visible = not (v9 or v10)
	canvas.Details.Position = UDim2.fromOffset(v9 and 30 or 650, v9 and 452 or v10 and 110 or 125)
	canvas.Details.Size = UDim2.fromOffset(v9 and 540 or 400, 320)
	canvas.Details.Title.Size = UDim2.fromOffset(v9 and 540 or 395, 95)
	canvas.Details.Title.TextSize = v10 and 36 or 40
	canvas.Details.Subtitle.Position = UDim2.fromOffset(0, v10 and 105 or 139)
	canvas.Details.Description.Position = UDim2.fromOffset(0, v10 and 143 or 179)
	canvas.Details.Action.Position = UDim2.fromOffset(0, v10 and 219 or 270)
	canvas.Details.Subtitle.Size = UDim2.fromOffset(v9 and 540 or 395, 29)
	canvas.Details.Description.Size = UDim2.fromOffset(v9 and 540 or 391, 74)
	canvas.Details.Action.Size = UDim2.fromOffset(v9 and 540 or 391, 49)
	canvas.Sounds.Position = UDim2.fromOffset(v9 and 30 or 40, v9 and 787 or v10 and 360 or v11 - 157)
	canvas.Status.Position = UDim2.fromOffset(v9 and 30 or 650, v9 and 837 or v10 and 381 or v11 - 159)
	canvas.Status.Size = UDim2.fromOffset(v9 and 540 or 390, v9 and 25 or 47)
	canvas.Selection.Position = UDim2.fromOffset(28, v9 and 875 or v10 and 420 or v11 - 94)
	canvas.Selection.Size = UDim2.new(1, -56, 0, v9 and 50 or 67)
	local v14 = v9 and 169 or 118
	canvas.Storefront.Position = UDim2.fromOffset(28, v14)
	canvas.Storefront.Size = UDim2.new(1, -56, 1, -v14 - 33)
	canvas.Notice.Position = UDim2.new(0, 28, 1, -29)
	canvas.Notice.Size = UDim2.new(1, -56, 0, 25)
	v2:layout((v9 and 600 or 1080) - 56, v9)
end

local function preview(p)
	local weapon = canvas.Hero.Weapon
	weapon:ClearAllChildren()
	model = nil
	local v9 = SkinCatalog.get(p)
	local child = v9 and weapons.Models:FindFirstChild(v9.Model)

	if not child then
		return
	end

	local blade = child:FindFirstChild("Blade") or child:FindFirstChildWhichIsA("MeshPart", true)

	if not blade then
		return
	end

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = weapon
	model = Instance.new("Model")
	model.Name = "Preview"
	model.Parent = worldModel
	local clone3 = blade:Clone()

	for _, descendant in clone3:GetDescendants() do
		if not (descendant:IsA("LuaSourceContainer") or descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint")) then
			continue
		end

		descendant:Destroy()
	end

	clone3.Anchored = true
	clone3.CanCollide = false
	clone3.CanTouch = false
	clone3.CanQuery = false
	clone3.Transparency = 0
	clone3.CFrame = CFrame.new() * (child:GetAttribute("PreviewRotation") or CFrame.Angles(
		-0.4363323129985824,
		-0.20943951023931956,
		-0.5585053606381855
	))
	clone3.Parent = model
	model.PrimaryPart = clone3
	local boundingBox, v10 = model:GetBoundingBox()
	v7 = math.max(v10.X, v10.Y, v10.Z)
	model:PivotTo(model:GetPivot() - boundingBox.Position)
	camera = Instance.new("Camera")
	camera.FieldOfView = 33
	camera.Parent = weapon
	weapon.CurrentCamera = camera
	total = 0
end

local function updateAction()
	local v9 = SkinCatalog.get(default)

	if not v9 then
		return
	end

	canvas.Details.Collection.Text = v9.Collection
	canvas.Details.Collection.TextColor3 = v9.Accent
	canvas.Details.Title.Text = v9.Name
	canvas.Details.Subtitle.Text = v9.Subtitle
	canvas.Details.Description.Text = v9.Description
	local action = canvas.Details.Action
	local v10 = v3.owned[default] == true

	if v3.loaded then
		if v3.equipped == default then
			action.Text = "EQUIPPED  ✓"
		elseif v10 then
			action.Text = "EQUIP KNIFE"
		elseif v9.Available and v9.Offer then
			action.Text = tostring((math.floor(v9.Offer.Price))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
				"^,",
				""
			) .. "  " .. string.upper(v9.Offer.Currency)
		else
			action.Text = "COMING LATER"
		end
	else
		action.Text = "LOADING COLLECTION…"
	end

	local v11 = v3.loaded and (v10 and v3.equipped ~= default and true or not v10 and v9.Available and v9.Offer ~= nil)
	action.Active = v11
	action.AutoButtonColor = v11
	ArmoryStyle.action(canvas, v4 == "Inventory", v11)
end

local render

render = function()
	applyViewStyle()
	local selectedObject2 = GuiService.SelectedObject

	if selectedObject2 and selectedObject2:IsDescendantOf(canvas.Selection) then
		GuiService.SelectedObject = canvas.Close
	end

	for _, v9 in clones do
		v9:Destroy()
	end

	table.clear(clones)
	local v9 = {}

	for _, v10 in SkinCatalog.Order do
		if v4 == "Shop" and v10 ~= "DevelopersPencil" and v10 ~= "SecretPencil" or v4 == "Inventory" and v3.owned[v10] then
			table.insert(v9, v10)
		end
	end

	local v10 = #v9 == 0 and { SkinCatalog.Default } or v9

	if not table.find(v10, default) then
		default = v10[1]
		preview(default)
	end

	for k, name in v10 do
		local v12 = SkinCatalog.get(name)
		local clone3 = valleyArmory.SkinTile:Clone()
		clone3.Name = name
		clone3.Visible = true
		clone3.LayoutOrder = k
		clone3.Index.Text = string.format("%02d", k)
		clone3.NameLabel.Text = v12.Name
		clone3.State.Text = v3.equipped == name and "EQUIPPED" or v3.owned[name] and "OWNED" or v12.Available and "AVAILABLE" or "COMING LATER"
		clone3.SelectionMark.Visible = name == default
		clone3.SelectionMark.BackgroundColor3 = v12.Accent
		clone3.BackgroundTransparency = name == default and 0.08 or 0.55
		clone3.Parent = canvas.Selection
		table.insert(clones, clone3)
		local v13 = name
		clone3.Activated:Connect(function()
			default = v13
			preview(v13)
			render()
		end)
	end

	canvas.Tabs.ActiveLine.Position = UDim2.fromOffset(canvas.Tabs[v4].Position.X.Offset, 44)
	canvas.Tabs.ActiveLine.Size = UDim2.fromOffset(v[v4], 3)
	updateAction()
end

local function setOpen(armoryOpen, p)
	if armoryOpen then
		HudNavigation.opening((p or v4) == "Inventory" and "Inventory" or "Shop")
	end

	if armoryOpen and not permitted() then
		return
	end

	if p then
		v4 = p
		zero = Vector2.zero
		canvas.Status.Text = v4 == "Inventory" and "Your collection. Your choice." or "Earn coins by playing. Find your next favourite."
	end

	if armoryOpen and not v5 then
		selectedObject = GuiService.SelectedObject
		presentationCues:Fire("ArmoryOpen")
		armoryEvent:FireServer("Get")
	elseif not armoryOpen and v5 then
		presentationCues:Fire("ArmoryClose")
	end

	v5 = armoryOpen
	valleyArmory.Overlay.Visible = armoryOpen
	valleyArmoryShade.Enabled = armoryOpen
	v2:setOpen(armoryOpen and v4 ~= "Inventory", v4)
	localPlayer:SetAttribute("ArmoryOpen", armoryOpen)

	if armoryOpen then
		default = v4 == "Inventory" and v3.equipped or default
		render()
		preview(default)
		layout()

		if UserInputService.GamepadEnabled then
			GuiService.SelectedObject = canvas.Close
		end
	elseif GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(valleyArmory) then
		GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
	end
end

weapons:WaitForChild("ArmoryNavigation").Event:Connect(function(p)
	if p ~= "Featured" and p ~= "Earnable" and p ~= "VIP" then
		return
	end

	setOpen(true, "Shop")

	if v5 then
		task.defer(function()
			if v5 and v4 == "Shop" then
				v2:focus(p)
			end
		end)
	end
end)

local function availability()
	local v9 = permitted()
	dock.Visible = false
	HudNavigation.setAvailable("Shop", v9)
	HudNavigation.setAvailable("Inventory", v9)

	if not v9 or localPlayer:GetAttribute("ServerBrowserOpen") == true or localPlayer:GetAttribute("MatchSummaryVisible") == true then
		if v5 then
			presentationCues:Fire("ArmoryClose")
		end

		v5 = false
		valleyArmory.Overlay.Visible = false
		valleyArmoryShade.Enabled = false
		v2:setOpen(false, v4)
		localPlayer:SetAttribute("ArmoryOpen", false)

		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(valleyArmory) then
			GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
		end
	end
end

HudNavigation.register("Shop", function()
	setOpen(true, "Shop")
end)
HudNavigation.register("Inventory", function()
	setOpen(true, "Inventory")
end)
HudNavigation.Opening.Event:Connect(function(p)
	if p ~= "Shop" and p ~= "Inventory" then
		if v5 then
			presentationCues:Fire("ArmoryClose")
		end

		v5 = false
		valleyArmory.Overlay.Visible = false
		valleyArmoryShade.Enabled = false
		v2:setOpen(false, v4)
		localPlayer:SetAttribute("ArmoryOpen", false)

		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(valleyArmory) then
			GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
		end
	end
end)
dock.Shop.Activated:Connect(function()
	setOpen(true, "Shop")
end)
dock.Inventory.Activated:Connect(function()
	setOpen(true, "Inventory")
end)
clone2.Activated:Connect(function()
	setOpen(true, "Items")
end)
clone.Activated:Connect(function()
	setOpen(true, "Abilities")
end)
canvas.Tabs.Shop.Activated:Connect(function()
	setOpen(true, "Shop")
end)
canvas.Tabs.Inventory.Activated:Connect(function()
	setOpen(true, "Inventory")
end)
canvas.Close.Activated:Connect(function()
	if v5 then
		presentationCues:Fire("ArmoryClose")
	end

	v5 = false
	valleyArmory.Overlay.Visible = false
	valleyArmoryShade.Enabled = false
	v2:setOpen(false, v4)
	localPlayer:SetAttribute("ArmoryOpen", false)

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(valleyArmory) then
		GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
	end
end)
canvas.Details.Action.Activated:Connect(function()
	if not v3.loaded or v3.equipped == default then
		return
	end

	armoryEvent:FireServer(v3.owned[default] and "Equip" or "Buy", default)
end)

for _, v9 in { "Equip", "Swing", "Hit" } do
	local v10 = v9
	canvas.Sounds[v9].Activated:Connect(function()
		presentationCues:Fire("KnifePreview", default, v10)
	end)
end

armoryEvent.OnClientEvent:Connect(function(p, data)
	if p ~= "State" or type(data) ~= "table" then
		return
	end

	local coins = v3.coins
	local gems = v3.gems
	v3 = data
	v2:update(v3)
	HudNavigation.setWallet(data.loaded, data.coins, data.gems)
	dock.Coins.Text = not data.loaded and "—" or tostring((math.floor(data.coins))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
		"^,",
		""
	) or "—"
	dock.Gems.Text = not data.loaded and "—" or tostring((math.floor(data.gems))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
		"^,",
		""
	) or "—"
	canvas.Wallet.Coins.Text = "●  " .. dock.Coins.Text
	canvas.Wallet.Gems.Text = "◆  " .. dock.Gems.Text

	if data.loaded and coins < data.coins then
		dock.Coins.TextColor3 = Color3.fromRGB(255, 246, 212)
		TweenService:Create(dock.Coins, TweenInfo.new(0.8), {
			TextColor3 = Color3.fromRGB(228, 203, 137)
		}):Play()
	end

	if data.loaded and gems < data.gems then
		dock.Gems.TextColor3 = Color3.fromRGB(219, 255, 239)
		TweenService:Create(dock.Gems, TweenInfo.new(0.65), {
			TextColor3 = Color3.fromRGB(127, 217, 191)
		}):Play()
	end

	canvas.Status.Text = data.message or v4 == "Inventory" and "Your collection. Your choice." or "Earn coins by playing. Find your next favourite."

	if v5 then
		render()
	end
end)
canvas.Hero.Weapon.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v8 = true
		X = input.Position.X
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if v8 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		total += (input.Position.X - X) * 0.012
		X = input.Position.X
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v8 = false
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if UserInputService:GetFocusedTextBox() then
		return
	end

	if v5 and (input.KeyCode == Enum.KeyCode.ButtonB or input.KeyCode == Enum.KeyCode.Escape) then
		if v5 then
			presentationCues:Fire("ArmoryClose")
		end

		v5 = false
		valleyArmory.Overlay.Visible = false
		valleyArmoryShade.Enabled = false
		v2:setOpen(false, v4)
		localPlayer:SetAttribute("ArmoryOpen", false)

		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(valleyArmory) then
			GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
		end
	elseif not gameProcessed and (input.KeyCode == Enum.KeyCode.N or input.KeyCode == Enum.KeyCode.ButtonY) then
		setOpen(not v5, "Inventory")
	end
end)

for _, v9 in {
	"ClientReady",
	"InMatch",
	"TutorialRouting",
	"ScreenPresentationActive",
	"AdminRefreshActive",
	"ServerBrowserOpen",
	"MatchSummaryVisible"
} do
	localPlayer:GetAttributeChangedSignal(v9):Connect(availability)
end

local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
	layout()
	v2:step(dt)

	if v5 and v4 == "Inventory" and camera and model then
		if not v8 then
			total += math.min(dt, 0.1) * 0.18
		end

		local v9 = v7 * 2
		camera.CFrame = CFrame.lookAt(
			Vector3.new(math.sin(total) * v9, v7 * 0.1, math.cos(total) * v9),
			createVector(0, 0, 0)
		)
	end
end)
localPlayer:SetAttribute("ArmoryOpen", false)
availability()
layout()
task.spawn(function()
	while v6 and not v3.loaded do
		armoryEvent:FireServer("Get")
		task.wait(3)
	end
end)
script.Destroying:Connect(function()
	v6 = false
	renderSteppedConnection:Disconnect()
	v2:destroy()
	valleyArmoryShade.Enabled = false
	localPlayer:SetAttribute("ArmoryOpen", false)
end)