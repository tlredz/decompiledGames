local createVector = vector.create
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local crates = chickenOrHero:WaitForChild("Crates")
local CrateCatalog = require(crates:WaitForChild("CrateCatalog"))
local CrateReel = require(crates:WaitForChild("CrateReel"))
local SkinCatalog = require(chickenOrHero.Weapons.SkinCatalog)
local ValleyPanels = require(chickenOrHero.Presentation.ValleyPanels)
local HudNavigation = require(chickenOrHero.Presentation.HudNavigation)
local crateEvent = crates:WaitForChild("CrateEvent")
local screen = ValleyPanels.screen(localPlayer, "Crates", 72)
local connections = {}
local v = true

-- equivalent calls inferred from this helper; original call sites unknown
local function connect(object, p)
	table.insert(connections, object:Connect(p))
end

local panel, v2, selectedObject2 = ValleyPanels.panel(screen, "Collection", 740, 590)
selectedObject2.ZIndex = 11
local text = ValleyPanels.text(v2, "Heading", "KNIFE CRATES", 24, 22, 590, 34, 26, ValleyPanels.Paper)
text.Font = Enum.Font.GothamBold
ValleyPanels.text(
	v2,
	"Subtitle",
	"One knife per opening. Every outcome and its exact chance is below.",
	24,
	62,
	692,
	30,
	13,
	ValleyPanels.Muted
)
local v4 = ValleyPanels.make("Frame", v2, "Knives", {
	Position = UDim2.fromOffset(24, 105),
	Size = UDim2.fromOffset(692, 332),
	BackgroundTransparency = 1,
	BorderSizePixel = 0
})
local text2 = ValleyPanels.text(v2, "Status", "", 24, 448, 692, 34, 13, ValleyPanels.Muted)
local button = ValleyPanels.button(v2, "Gems", "GEMS", 24, 489, 336, 42, Color3.fromRGB(43, 70, 65))
local button2 = ValleyPanels.button(v2, "Robux", "CHECKING PRICE", 376, 489, 340, 42, Color3.fromRGB(81, 67, 39))
ValleyPanels.text(
	v2,
	"Disclosure",
	"Duplicates become gems at the amounts shown. Odds never change with ownership.",
	24,
	539,
	692,
	28,
	11,
	ValleyPanels.Muted
)
local v5 = ValleyPanels.make("Frame", v2, "Reveal", {
	Visible = false,
	Active = false,
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = ValleyPanels.Ink,
	BorderSizePixel = 0,
	ZIndex = 10
})
ValleyPanels.corner(v5, 14)
local text3 = ValleyPanels.text(v5, "Heading", "UNSEALING…", 24, 52, 692, 42, 28, ValleyPanels.Gold)
text3.TextXAlignment = Enum.TextXAlignment.Center
text3.Font = Enum.Font.GothamBold
local v6 = ValleyPanels.make("Frame", v5, "Artwork", {
	Position = UDim2.fromOffset(170, 117),
	Size = UDim2.fromOffset(400, 285),
	BackgroundTransparency = 1
})
local text4 = ValleyPanels.text(v5, "Detail", "", 40, 411, 660, 62, 18, ValleyPanels.Paper)
text4.TextXAlignment = Enum.TextXAlignment.Center
local button3 = ValleyPanels.button(v5, "Continue", "CONTINUE", 250, 507, 240, 42)
local v7 = {}
local v8 = nil
local v9 = nil
local flag = false
local v10 = {}
local ids = {}
local v11 = {}
local selectedObject = nil
local count = 0

local function layout()
	local v12 = screen.AbsoluteSize.X < 650
	local v13 = v12 and 420 or 740
	local v14 = v12 and 770 or 590
	v2.Size = UDim2.fromOffset(v13, v14)
	v2.Scale.Scale = math.min(1, screen.AbsoluteSize.X * 0.94 / v13, screen.AbsoluteSize.Y * 0.94 / v14)
	selectedObject2.Position = UDim2.fromOffset(v13 - 60, 16)
	text.Size = UDim2.fromOffset(v13 - 98, 36)
	text.TextSize = v12 and 20 or 26
	v2.Subtitle.Size = UDim2.fromOffset(v13 - 48, 36)
	local v15 = v12 and 512 or 332
	v4.Size = UDim2.fromOffset(v13 - 48, v15)
	local v16 = 105 + v15 + 8
	text2.Position = UDim2.fromOffset(24, v16)
	text2.Size = UDim2.fromOffset(v13 - 48, 34)
	local v17 = (v13 - 64) / 2
	button.Position = UDim2.fromOffset(24, v16 + 40)
	button.Size = UDim2.fromOffset(v17, 42)
	button2.Position = UDim2.fromOffset(40 + v17, v16 + 40)
	button2.Size = UDim2.fromOffset(v17, 42)
	v2.Disclosure.Position = UDim2.fromOffset(24, v16 + 85)
	v2.Disclosure.Size = UDim2.fromOffset(v13 - 48, 48)
	text3.Size = UDim2.fromOffset(v13 - 48, 60)
	text3.TextSize = v12 and 21 or 28
	v6.Position = UDim2.fromOffset(24, 130)
	v6.Size = UDim2.fromOffset(v13 - 48, 260)
	text4.Size = UDim2.fromOffset(v13 - 80, 74)
	button3.Position = UDim2.fromOffset((v13 - 240) / 2, 507)
	local v18 = v12 and 2 or 4
	local v19 = v12 and 4 or 2
	local v20 = (v13 - 48 - (v18 - 1) * 10) / v18
	local v21 = (v15 - (v19 - 1) * 10) / v19
	local count2 = 0

	for _, frame in v4:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		frame.Size = UDim2.fromOffset(v20, v21)
		frame.Position = UDim2.fromOffset(count2 % v18 * (v20 + 10), math.floor(count2 / v18) * (v21 + 10))
		frame.Art.Size = UDim2.fromOffset(v20 - 12, v21 - 57)
		frame.NameLabel.Position = UDim2.fromOffset(4, v21 - 55)
		frame.NameLabel.Size = UDim2.fromOffset(v20 - 8, 24)
		frame.Rarity.Position = UDim2.fromOffset(4, v21 - 31)
		frame.Rarity.Size = UDim2.fromOffset(v20 - 8, 24)
		count2 += 1
	end
end

connect(screen:GetPropertyChangedSignal("AbsoluteSize"), layout) -- equivalent call inferred; original call site unknown
layout()
local v12 = {
	Common = ValleyPanels.Muted,
	Rare = ValleyPanels.Blue,
	Epic = ValleyPanels.Purple,
	Legendary = ValleyPanels.Gold
}

local function preview(p, skin)
	local v13 = SkinCatalog.get(skin)
	local child = v13 and chickenOrHero.Weapons.Models:FindFirstChild(v13.Model)

	if not child then
		return
	end

	local v14 = ValleyPanels.make("ViewportFrame", p, "Preview", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Ambient = Color3.fromRGB(200, 210, 225),
		LightColor = Color3.new(1, 1, 1),
		LightDirection = createVector(-1, -1, -1)
	})
	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = v14
	local model = Instance.new("Model")
	model.Parent = worldModel
	local blade = child:FindFirstChild("Blade")

	if not blade then
		v14:Destroy()
		return
	end

	local clone = blade:Clone()
	clone.Transparency = 0
	clone.CFrame = child:GetAttribute("PreviewRotation") or CFrame.Angles(-0.3, 0, -0.5)
	clone.Parent = model

	for _, descendant in model:GetDescendants() do
		if descendant:IsA("LuaSourceContainer") or descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
		end
	end

	local boundingBox, v15 = model:GetBoundingBox()
	model:PivotTo(model:GetPivot() - boundingBox.Position)
	local camera = Instance.new("Camera")
	camera.FieldOfView = 35
	camera.Parent = v14
	v14.CurrentCamera = camera
	local extent = math.max(v15.X, v15.Y, v15.Z, 0.5)
	table.insert(v11, {
		viewport = v14,
		camera = camera,
		extent = extent
	})
end

local v13 = CrateReel.new(v6, ValleyPanels, CrateCatalog, SkinCatalog, v12, preview)

-- equivalent calls inferred from this helper; original call sites unknown
local function bonus(p)
	if p == "Epic" then
		return "+0.35 speed · −0.35s cooldowns"
	elseif p == "Legendary" then
		return "+0.85 speed · −0.85s cooldowns"
	end

	return "Cosmetic · standard stats"
end

local function render()
	if not v then
		return
	end

	local v14 = v8 and CrateCatalog.get(v8)

	if not v14 then
		return
	end

	local v15

	if v7.loaded == true and v7.allowed == true then
		v15 = not (v7.pending or flag or v5.Visible or localPlayer:GetAttribute("InMatch"))
	else
		v15 = false
	end

	button.Text = tostring(v14.Gems) .. " GEMS"
	local v16 = button
	local active

	if v15 then
		if (v7.gems or 0) >= v14.Gems then
			active = type(v7.token) == "string"
		else
			active = false
		end
	else
		active = v15
	end

	v16.Active = active
	local v18

	if type(v9) == "table" and type(v9.PriceInRobux) == "number" then
		v18 = v9.PriceInRobux >= 0
	else
		v18 = false
	end

	button2.Text = v18 and utf8.char(57346) .. " " .. v9.PriceInRobux or v9 == false and "PRICE UNAVAILABLE" or "CHECKING PRICE"
	button2.Active = v15 and v18 and v9.IsForSale == true

	for _, v19 in { button, button2 } do
		v19.AutoButtonColor = v19.Active
		v19.TextTransparency = v19.Active and 0 or 0.45
	end

	local v19 = text2
	local reason

	if flag then
		reason = "Opening your crate…"
	elseif v7.loaded then
		if v7.allowed == true then
			reason = "Your balance: " .. tostring(v7.gems or 0) .. " gems · Knives equip from your armory"
		else
			reason = v7.reason or "Crates are unavailable for this account."
		end
	else
		reason = "Loading your collection…"
	end

	v19.Text = reason
end

local function hide()
	count += 1
	v13:cancel()
	v4:ClearAllChildren()
	table.clear(v11)
	v8 = nil
	v9 = nil
	v5.Visible = false
	flag = false
	panel.Visible = false
	localPlayer:SetAttribute("CrateOpen", nil)

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(screen) then
		GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
	end
end

local function show(p)
	if not v or panel.Visible then
		return
	end

	local v14 = CrateCatalog.get(p)

	if not v14 or localPlayer:GetAttribute("InMatch") then
		return
	end

	v13:cancel()
	HudNavigation.opening("Crates")
	selectedObject = GuiService.SelectedObject
	v8 = p
	count += 1
	local v15 = count
	v9 = nil
	v7 = {}
	flag = false
	panel.Visible = true
	v5.Visible = false
	localPlayer:SetAttribute("CrateOpen", true)
	text.Text = string.upper(v14.Name)
	v4:ClearAllChildren()
	table.clear(v11)

	for _, entry in v14.Entries do
		local v16 = SkinCatalog.get(entry.Skin)

		if not v16 then
			continue
		end

		local rarity = v16.Rarity or "Common"
		local v17 = v12[rarity] or ValleyPanels.Muted
		local v18 = ValleyPanels.make("Frame", v4, entry.Skin, {
			BackgroundColor3 = Color3.fromRGB(25, 40, 52),
			BorderSizePixel = 0
		})
		ValleyPanels.corner(v18, 10)
		ValleyPanels.stroke(v18, v17, 0.5)
		preview(ValleyPanels.make("Frame", v18, "Art", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(6, 2)
		}), entry.Skin)
		local text5 = ValleyPanels.text(v18, "NameLabel", v16.Name, 4, 110, 154, 24, 13, ValleyPanels.Paper)
		text5.Font = Enum.Font.GothamBold
		text5.TextXAlignment = Enum.TextXAlignment.Center
		local text_2 = ValleyPanels.text(
			v18,
			"Rarity",
			string.upper(rarity) .. " · " .. string.format("%.1f%%", entry.Weight / 100),
			4,
			136,
			154,
			24,
			11,
			v17
		)
		text_2.TextXAlignment = Enum.TextXAlignment.Center
	end

	v2.Disclosure.Text = [[
Duplicates: Common +10 · Rare +20 · Epic +40 · Legendary +75 gems.
Epic: +0.35 speed / −0.35s timers · Legendary: +0.85 speed / −0.85s timers.]]
	layout()
	render()
	crateEvent:FireServer("Open", p)

	for i = 1, 2 do
		task.delay(i * 0.6, function()
			if v and panel.Visible and count == v15 and v8 == p and v7.loaded == nil then
				crateEvent:FireServer("Open", p)
			end
		end)
	end

	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		GuiService.SelectedObject = selectedObject2
	end

	task.spawn(function()
		local success, productInfoAsync = pcall(
			MarketplaceService.GetProductInfoAsync,
			MarketplaceService,
			v14.ProductId,
			Enum.InfoType.Product
		)

		if v and panel.Visible and v8 == p and count == v15 then
			v9 = success and productInfoAsync or false
			render()
		end
	end)
end

connect(selectedObject2.Activated, hide) -- equivalent call inferred; original call site unknown
table.insert(connections, button3.Activated:Connect(function()
	v13:cancel()
	v5.Visible = false
	flag = false
	render()

	if v8 then
		crateEvent:FireServer("Open", v8)
	end
end))
table.insert(connections, button.Activated:Connect(function()
	if button.Active then
		flag = true
		render()
		crateEvent:FireServer("BuyGems", v8, v7.token)
	end
end))
table.insert(connections, button2.Activated:Connect(function()
	if button2.Active then
		flag = true
		render()
		crateEvent:FireServer("Prompt", v8)
	end
end))
table.insert(connections, crateEvent.OnClientEvent:Connect(function(p, data)
	if p == "State" and type(data) == "table" and data.crate == v8 then
		v7 = data
		render()
	elseif p == "Notice" then
		flag = false
		render()
		text2.Text = tostring(data)
	elseif p == "Result" and type(data) == "table" and not v10[data.id] then
		v10[data.id] = true
		table.insert(ids, data.id)

		if #ids > 128 then
			v10[table.remove(ids, 1)] = nil
		end

		crateEvent:FireServer("Ack", data.id)
		local v14 = SkinCatalog.get(data.skin)

		if not v14 then
			return
		end

		flag = false

		if localPlayer:GetAttribute("InMatch") then
			HudNavigation.Notice:Fire("Crate unlocked: " .. v14.Name)
			return
		end

		if not panel.Visible then
			show(data.crate)
		end

		flag = true
		v5.Visible = true
		render()
		text3.Text = "UNSEALING YOUR KNIFE…"
		text3.TextColor3 = ValleyPanels.Gold
		text4.Text = CrateCatalog.get(data.crate).Name
		button3.Visible = false
		v13:play(data, function()
			text3.Text = string.upper(v14.Rarity or "Common") .. " · " .. v14.Name
			text3.TextColor3 = v12[v14.Rarity] or ValleyPanels.Gold
			local v15 = text4
			local text5 = data.duplicate and "Already collected · +" .. tostring(data.gems or 0) .. " gems"

			if not text5 then
				text5 = "Added to your armory\n" .. bonus(v14.Rarity)
			end

			v15.Text = text5
			button3.Visible = true

			if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
				GuiService.SelectedObject = button3
			end
		end)
	end
end))
table.insert(connections, MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, p2)
	if p == localPlayer.UserId and v8 and p2 == CrateCatalog.get(v8).ProductId then
		flag = false
		render()
		crateEvent:FireServer("Get", v8)
	end
end))
table.insert(connections, ProximityPromptService.PromptTriggered:Connect(function(player, p)
	if p == localPlayer and player.Name == "CratePrompt" then
		show(player:GetAttribute("CrateId"))
	end
end))
table.insert(connections, HudNavigation.Opening.Event:Connect(function(p)
	if p ~= "Crates" then
		hide()
	end
end))
table.insert(connections, UserInputService.InputBegan:Connect(function(input)
	if panel.Visible and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
		hide()
	end
end))
table.insert(connections, localPlayer:GetAttributeChangedSignal("InMatch"):Connect(function()
	if localPlayer:GetAttribute("InMatch") then
		hide()
	end
end))
connect(localPlayer.CharacterRemoving, hide) -- equivalent call inferred; original call site unknown
local total = 0
table.insert(connections, RunService.RenderStepped:Connect(function(dt)
	if not panel.Visible then
		return
	end

	total += dt

	for i = #v11, 1, -1 do
		local v14 = v11[i]

		if v14.viewport.Parent then
			if v14.viewport.Parent.Visible then
				local v15 = total * 0.3
				v14.camera.CFrame = CFrame.lookAt(
					Vector3.new(math.sin(v15) * v14.extent * 1.9, v14.extent * 0.4, math.cos(v15) * v14.extent * 1.9),
					createVector(0, 0, 0)
				)
			end
		else
			table.remove(v11, i)
		end
	end
end))
script.Destroying:Connect(function()
	v = false

	for _, connection in connections do
		connection:Disconnect()
	end

	hide()
	screen:Destroy()
end)