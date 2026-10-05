local ValleyTheme = require(script.Parent.ValleyTheme)

-- equivalent calls inferred from this helper; original call sites unknown
local function text(instance, childName, textColor, p)
	local label = instance:FindFirstChild(childName)

	if label and label:IsA("TextLabel") then
		label.TextColor3 = textColor
		label.Font = p and Enum.Font.GothamBold or Enum.Font.Gotham
	end
end

local function sounds(sounds2, p)
	for _, v in { "Equip", "Swing", "Hit" } do
		ValleyTheme.button(sounds2[v], p)
	end

	text(sounds2, "Label", ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
end

local function card(instance, textColor)
	ValleyTheme.surface(instance, ValleyTheme.Ink:Lerp(textColor, 0.065), textColor, 8, 0.64)
	text(instance, "Index", textColor, true) -- equivalent call inferred; original call site unknown
	text(instance, "Eyebrow", textColor, true) -- equivalent call inferred; original call site unknown
	text(instance, "Title", ValleyTheme.Paper, true) -- equivalent call inferred; original call site unknown
	text(instance, "Tagline", ValleyTheme.Paper, false) -- equivalent call inferred; original call site unknown

	for _, v in {
		"Description",
		"Footnote",
		"Hint",
		"Loading"
	} do
		text(instance, v, ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
	end

	ValleyTheme.button(instance.Buy, textColor, ValleyTheme.Ink:Lerp(textColor, 0.17))

	if instance:FindFirstChild("Sounds") then
		sounds(instance.Sounds, textColor)
	end
end

local ArmoryStyle = {}

function ArmoryStyle.apply(p)
	local canvas = p.Overlay.Canvas
	ValleyTheme.surface(canvas, ValleyTheme.Ink, ValleyTheme.Gold, 8, 0.55)
	canvas.Brand.Font = Enum.Font.GothamBold
	canvas.Brand.TextColor3 = ValleyTheme.Paper
	canvas.HeaderRule.BackgroundColor3 = ValleyTheme.Gold
	canvas.HeaderRule.BackgroundTransparency = 0.78
	ValleyTheme.button(canvas.Close, ValleyTheme.Gold)
	canvas.Details.Title.Font = Enum.Font.GothamBold
	canvas.Details.Title.TextColor3 = ValleyTheme.Paper
	text(canvas.Details, "Subtitle", ValleyTheme.Paper, false) -- equivalent call inferred; original call site unknown
	text(canvas.Details, "Description", ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
	text(canvas, "Status", ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
	text(canvas, "Notice", ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
	text(canvas, "ScrollHint", ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
	text(canvas.Hero, "PreviewHint", ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
	sounds(canvas.Sounds, ValleyTheme.Blue)
	ValleyTheme.surface(p.SkinTile, ValleyTheme.InventoryInk:Lerp(ValleyTheme.Blue, 0.08), ValleyTheme.Blue, 5, 0.74)
	text(p.SkinTile, "NameLabel", ValleyTheme.Paper, true) -- equivalent call inferred; original call site unknown
	text(p.SkinTile, "Index", ValleyTheme.Blue, true) -- equivalent call inferred; original call site unknown
	text(p.SkinTile, "State", ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
	local storefront = canvas.Storefront
	card(storefront.Featured, ValleyTheme.Purple)
	card(storefront.Earnable, ValleyTheme.Blue)
	card(storefront.BalloonDagger, Color3.fromRGB(245, 144, 190))
	card(storefront.TopWinsDagger, Color3.fromRGB(255, 215, 107))
	card(storefront.Perks.DoubleXP, ValleyTheme.Blue)
	card(storefront.Perks.VIP, ValleyTheme.Gold)

	for _, v in { "PerksHeading", "Stacking", "Footer" } do
		local paper3 = v == "PerksHeading" and ValleyTheme.Paper or ValleyTheme.Muted
		text(storefront, v, paper3, v == "PerksHeading") -- equivalent call inferred; original call site unknown
	end

	for _, v in { "Coins", "Gems" } do
		local v2 = storefront[v]
		local gold = v == "Coins" and ValleyTheme.Gold or ValleyTheme.Mint
		text(v2, "Heading", ValleyTheme.Paper, true) -- equivalent call inferred; original call site unknown
		text(v2, "Description", ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown

		for _, frame in v2.Packs:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			ValleyTheme.surface(frame, ValleyTheme.Ink:Lerp(gold, 0.055), gold, 8, 0.72)
			text(frame, "Amount", gold, true) -- equivalent call inferred; original call site unknown
			text(frame, "Caption", ValleyTheme.Muted, false) -- equivalent call inferred; original call site unknown
			ValleyTheme.button(frame.Buy, gold, ValleyTheme.Ink:Lerp(gold, 0.13))
		end
	end
end

function ArmoryStyle:view(p, p2)
	local blue = p and ValleyTheme.Blue or ValleyTheme.Gold
	local inventoryInk = p and ValleyTheme.InventoryInk or ValleyTheme.Ink
	self.BackgroundColor3 = inventoryInk
	self.Depth.Enabled = false
	self.Border.Color = blue
	self.TopRule.BackgroundColor3 = blue
	self.HeaderRule.BackgroundColor3 = blue
	self.Tabs.ActiveLine.BackgroundColor3 = blue
	self.Edition.Text = p and "MY KNIVES  /  YOUR COLLECTION" or p2 == "Abilities" and "ABILITIES  /  PERMANENT UNLOCKS" or p2 == "Items" and "ITEMS  /  CONSUMABLE PACKS" or "THE ARMORY  /  SHOP"
	self.Edition.TextColor3 = blue

	for _, v in {
		"Shop",
		"Abilities",
		"Items",
		"Inventory"
	} do
		local tab = self.Tabs[v]
		local v2 = v == (p2 or p and "Inventory" or "Shop")
		local button = ValleyTheme.button
		local v3

		if v2 then
			v3 = inventoryInk:Lerp(blue, 0.14) or inventoryInk
		else
			v3 = inventoryInk
		end

		button(tab, blue, v3)
		tab.BackgroundTransparency = v2 and 0 or 0.45
		tab.TextColor3 = v2 and ValleyTheme.Paper or ValleyTheme.Muted
		tab.Border.Transparency = v2 and 0.4 or 0.8
	end

	ValleyTheme.button(self.Close, blue, inventoryInk)
	self.Hero.Field.Outline.Color = blue
	self.Hero.Field.Outline.Transparency = 0.8
	self.Hero.Field.CentreLine.BackgroundColor3 = blue
	self.Hero.Field.CentreLine.BackgroundTransparency = 0.85
	self.Hero.Field.CentreCircle.Outline.Color = blue
	self.Hero.Field.CentreCircle.Outline.Transparency = 0.85
	sounds(self.Sounds, blue)
	self.Selection.ScrollBarImageColor3 = blue
	self.Storefront.ScrollBarImageColor3 = blue
end

function ArmoryStyle.action(p, p2, p3)
	local blue = p2 and ValleyTheme.Blue or ValleyTheme.Gold
	local inventoryInk = p2 and ValleyTheme.InventoryInk or ValleyTheme.Ink
	ValleyTheme.button(p.Details.Action, blue, inventoryInk:Lerp(blue, p3 and 0.22 or 0.075))
	p.Details.Action.Border.Transparency = p3 and 0.4 or 0.78
	p.Details.Action.TextTransparency = p3 and 0 or 0.2
end

return ArmoryStyle