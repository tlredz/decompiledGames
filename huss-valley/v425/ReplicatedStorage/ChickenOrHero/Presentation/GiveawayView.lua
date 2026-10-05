local createVector = vector.create
local ValleyPanels = require(script.Parent.ValleyPanels)
local ValleyTheme = require(script.Parent.ValleyTheme)
local SkinCatalog = require(script.Parent.Parent.Weapons.SkinCatalog)
local VerifiedName = require(script.Parent.VerifiedName)
local GiveawayView = {}
GiveawayView.__index = GiveawayView

-- equivalent calls inferred from this helper; original call sites unknown
local function text(p, p2, formatted, p3, p4, p5, p6, p7, p8)
	local text2 = ValleyPanels.text(p, p2, formatted, p3, p4, p5, p6, p7, p8)
	text2.RichText = false
	return text2
end

local function circle(p, p2, p3, backgroundColor, value)
	local v = ValleyPanels.make("Frame", p, p2, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(p3, p3),
		BackgroundColor3 = backgroundColor,
		BackgroundTransparency = value or 0,
		BorderSizePixel = 0
	})
	ValleyPanels.make("UICorner", v, "Round", {
		CornerRadius = UDim.new(1, 0)
	})
	return v
end

function GiveawayView:preview(p)
	self:ClearAllChildren()
	local v = SkinCatalog.get(p)
	local child = v and script.Parent.Parent.Weapons.Models:FindFirstChild(v.Model)

	if not child then
		return
	end

	local clone = child.Blade:Clone()

	for _, descendant in clone:GetDescendants() do
		if not (descendant:IsA("BasePart") or descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("LuaSourceContainer") or descendant:IsA("ParticleEmitter") or descendant:IsA("Beam")) then
			continue
		end

		descendant:Destroy()
	end

	clone.Anchored = true
	clone.Transparency = 0
	clone.CFrame = child:GetAttribute("PreviewRotation") or CFrame.identity
	clone.CFrame = clone.CFrame.Rotation
	clone.Parent = self
	local camera = Instance.new("Camera")
	camera.FieldOfView = 36
	local v2 = math.max(clone.Size.X, clone.Size.Y, clone.Size.Z)
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 0, v2 * 1.65), createVector(0, 0, 0))
	camera.Parent = self
	self.CurrentCamera = camera
	self.Ambient = Color3.fromRGB(210, 210, 220)
	self.LightColor = Color3.new(1, 1, 1)
	self.LightDirection = createVector(-1, -1, -2)
end

function GiveawayView.new(p)
	local gui = ValleyPanels.make("ScreenGui", p, "GlobalGiveaway", {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.None,
		ClipToDeviceSafeArea = false,
		DisplayOrder = 10000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = false
	})
	local v2 = ValleyPanels.make("TextButton", gui, "Dim", {
		Size = UDim2.fromScale(1, 1),
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(3, 8, 15),
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		Modal = true,
		Active = true
	})
	local root = ValleyPanels.make("Frame", v2, "Stage", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(1100, 620),
		BackgroundTransparency = 1
	})
	local scale = ValleyPanels.make("UIScale", root, "Scale", {})
	local heading = text(root, "Heading", "THE OWNER'S GLOBAL GIVEAWAY", 26, 18, 1030, 28, 14, ValleyTheme.Gold) -- equivalent call inferred; original call site unknown
	heading.Font = Enum.Font.GothamBold
	local title = text(root, "Title", "ONE SERVER. ONE WINNER.", 26, 52, 1030, 52, 32, ValleyTheme.Paper) -- equivalent call inferred; original call site unknown
	title.Font = Enum.Font.GothamBlack
	local sub = text(
		root,
		"Subtitle",
		"The owner has begun a global wheel spin.",
		28,
		105,
		1040,
		30,
		16,
		ValleyTheme.Muted
	) -- equivalent call inferred; original call site unknown
	local port = ValleyPanels.make("Frame", root, "WheelWindow", {
		Position = UDim2.fromOffset(0, 138),
		Size = UDim2.fromOffset(690, 440),
		BackgroundTransparency = 1,
		ClipsDescendants = true
	})
	local disc = circle(ValleyPanels.make("Frame", port, "Center", {
		Position = UDim2.fromOffset(285, 232),
		Size = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1
	}), "Wheel", 580, ValleyTheme.InventoryInk, 0.05)
	ValleyPanels.stroke(disc, ValleyTheme.Gold, 0.3)
	disc.Outline.Thickness = 3
	local v11 = circle(disc, "InnerRing", 410, ValleyTheme.Ink, 0.15)
	ValleyPanels.stroke(v11, ValleyTheme.Gold, 0.8)
	local ring = ValleyPanels.make("Frame", disc, "Seats", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	})
	local v13 = circle(disc, "Hub", 170, ValleyTheme.Ink, 0)
	ValleyPanels.stroke(v13, ValleyTheme.Gold, 0.45)
	v13.ZIndex = 3
	local hubText = text(v13, "Words", "VALLEY\nGIVEAWAY", 0, 40, 170, 90, 14, ValleyTheme.Gold) -- equivalent call inferred; original call site unknown
	hubText.TextXAlignment = Enum.TextXAlignment.Center
	hubText.Font = Enum.Font.GothamBold
	local heroPortrait = ValleyPanels.make("ImageLabel", v13, "CurrentPlayer", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.fromOffset(110, 110),
		BackgroundTransparency = 1,
		Visible = false
	})
	ValleyPanels.corner(heroPortrait, 12)
	local pointer = text(port, "Pointer", "◀", 552, 211, 58, 54, 44, ValleyTheme.Gold) -- equivalent call inferred; original call site unknown
	pointer.ZIndex = 8
	local prize = ValleyPanels.make("Frame", root, "Prize", {
		Position = UDim2.fromOffset(724, 165),
		Size = UDim2.fromOffset(340, 359),
		BorderSizePixel = 0,
		BackgroundColor3 = ValleyTheme.Ink
	})
	ValleyTheme.surface(prize, ValleyTheme.Ink, ValleyTheme.Gold, 8, 0.35)
	local gold4 = ValleyTheme.Gold
	local text_2 = ValleyPanels.text(prize, "Label", "THE PRIZE", 20, 18, 300, 24, 12, gold4)
	text_2.RichText = false
	local preview = ValleyPanels.make("ViewportFrame", prize, "Preview", {
		Position = UDim2.fromOffset(20, 50),
		Size = UDim2.fromOffset(300, 190),
		BackgroundTransparency = 1
	})
	local amount = text(prize, "Amount", "", 20, 75, 300, 150, 55, ValleyTheme.Gold) -- equivalent call inferred; original call site unknown
	amount.TextXAlignment = Enum.TextXAlignment.Center
	amount.Font = Enum.Font.GothamBlack
	local name = text(prize, "Name", "", 20, 250, 300, 55, 24, ValleyTheme.Paper) -- equivalent call inferred; original call site unknown
	name.Font = Enum.Font.GothamBold
	name.TextXAlignment = Enum.TextXAlignment.Center
	local caption = text(prize, "Caption", "A gift from the owner", 20, 312, 300, 24, 13, ValleyTheme.Muted) -- equivalent call inferred; original call site unknown
	caption.TextXAlignment = Enum.TextXAlignment.Center
	local selected = text(root, "Selected", "", 26, 564, 1040, 34, 22, ValleyTheme.Gold) -- equivalent call inferred; original call site unknown
	selected.Font = Enum.Font.GothamBold
	local note = text(root, "Note", "", 28, 599, 1030, 20, 12, ValleyTheme.Muted) -- equivalent call inferred; original call site unknown
	local confetti = {}

	for i = 1, 28 do
		confetti[i] = ValleyPanels.make("Frame", root, "Confetti" .. i, {
			Size = UDim2.fromOffset(i % 4 + 5, i % 6 + 9),
			BorderSizePixel = 0,
			BackgroundColor3 = i % 2 == 0 and ValleyTheme.Gold or ValleyTheme.Purple,
			Visible = false,
			ZIndex = 10,
			Active = false
		})
	end

	local object = setmetatable({
		heroPortrait = heroPortrait,
		confetti = confetti,
		gui = gui,
		root = root,
		scale = scale,
		port = port,
		disc = disc,
		ring = ring,
		hubText = hubText,
		prize = prize,
		preview = preview,
		amount = amount,
		name = name,
		caption = caption,
		heading = heading,
		title = title,
		sub = sub,
		selected = selected,
		note = note,
		cards = {},
		pointer = pointer
	}, GiveawayView)

	local function layout()
		local absoluteSize = gui.AbsoluteSize
		local v25 = absoluteSize.X < absoluteSize.Y
		object.note.TextSize = (v25 or absoluteSize.Y < 520) and 18 or 12
		local v26 = v25 and 620 or 1100
		local v27 = v25 and 920 or 680
		root.Size = UDim2.fromOffset(v26, v27)
		scale.Scale = math.min(absoluteSize.X * 0.97 / v26, absoluteSize.Y * 0.96 / v27, 1.3)
		heading.Size = UDim2.fromOffset(v26 - 50, 28)
		title.Size = UDim2.fromOffset(v26 - 50, 52)
		title.TextSize = v25 and 26 or 32
		sub.Size = UDim2.fromOffset(v26 - 50, 42)
		port.Position = UDim2.fromOffset(0, v25 and 150 or 138)
		port.Size = UDim2.fromOffset(v25 and 620 or 690, v25 and 470 or 440)
		prize.Position = v25 and UDim2.fromOffset(26, 676) or UDim2.fromOffset(724, 165)
		prize.Size = v25 and UDim2.fromOffset(568, 175) or UDim2.fromOffset(340, 359)
		preview.Position = v25 and UDim2.fromOffset(10, 10) or UDim2.fromOffset(20, 50)
		preview.Size = v25 and UDim2.fromOffset(170, 155) or UDim2.fromOffset(300, 190)
		amount.Position = preview.Position
		amount.Size = preview.Size
		amount.TextSize = v25 and 34 or 55
		prize.Label.Position = v25 and UDim2.fromOffset(198, 18) or UDim2.fromOffset(20, 18)
		name.Position = v25 and UDim2.fromOffset(190, 55) or UDim2.fromOffset(20, 250)
		name.Size = v25 and UDim2.fromOffset(350, 70) or UDim2.fromOffset(300, 55)
		caption.Position = v25 and UDim2.fromOffset(190, 131) or UDim2.fromOffset(20, 312)
		caption.Size = v25 and UDim2.fromOffset(350, 24) or UDim2.fromOffset(300, 24)
		selected.Position = UDim2.fromOffset(26, v25 and 628 or 588)
		selected.Size = UDim2.fromOffset(v26 - 50, 40)
		note.Position = UDim2.fromOffset(28, v25 and 875 or 637)
		note.Size = UDim2.fromOffset(v26 - 56, 34)
	end

	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	layout()
	return object
end

function GiveawayView:show(data, p)
	self.data = data
	self.gui.Enabled = true
	self.ring:ClearAllChildren()
	table.clear(self.cards)
	local pool = data.pool
	self.winnerIndex = 1

	for k, v in pool do
		if v.id == data.winner.id then
			self.winnerIndex = k
		end

		local v2 = (k - 1) / #pool * 3.141592653589793 * 2
		local v3 = math.clamp(1533.097214951819 / #pool * 0.72, 22, 74)
		local v4 = ValleyPanels.make("Frame", self.ring, "Player" .. k, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, math.cos(v2) * 244, 0.5, math.sin(v2) * 244),
			Size = UDim2.fromOffset(v3, v3),
			BackgroundColor3 = ValleyTheme.Ink,
			BorderSizePixel = 0
		})
		ValleyPanels.corner(v4, 6)
		ValleyPanels.stroke(v4, ValleyTheme.Gold, 0.5)
		local v5 = ValleyPanels.make("ImageLabel", v4, "Portrait", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = "rbxthumb://type=AvatarHeadShot&id=" .. v.id .. "&w=150&h=150"
		})
		ValleyPanels.corner(v5, 6)

		if #pool <= 14 then
			local text2 = text(
				v4,
				"Name",
				VerifiedName.format(v.display, v.verified),
				-30,
				v3 + 3,
				v3 + 60,
				30,
				11,
				ValleyTheme.Paper
			) -- equivalent call inferred; original call site unknown
			text2.RichText = true
			text2.TextXAlignment = Enum.TextXAlignment.Center
		end

		table.insert(self.cards, v4)
	end

	local prize = data.prize
	self.name.Text = prize.kind == "Dagger" and SkinCatalog.get(prize.skin).Name or prize.kind:upper()
	self.preview.Visible = prize.kind == "Dagger"
	self.amount.Visible = not self.preview.Visible

	if self.preview.Visible then
		GiveawayView.preview(self.preview, prize.skin)
	else
		self.preview:ClearAllChildren()
		self.amount.Text = tostring(prize.amount)
	end

	local v = false

	for _, v3 in pool do
		if v3.id ~= p then
			continue
		end

		v = true
		break
	end

	self.note.Text = data.preview and "PREVIEW ONLY · No prizes are awarded." or data.excluded[tostring(p)] or v and "Match paused · It resumes automatically after the result." or "You joined after this draw opened. Enjoy the result!"
	self.heading.Text = data.preview and "OWNER PREVIEW  /  NO REWARDS" or "THE OWNER'S GLOBAL GIVEAWAY"
	self.finalAngle = 2520 - (self.winnerIndex - 1) * 360 / #pool
	self.lastIndex = nil

	for _, v3 in self.confetti do
		v3.Visible = false
	end
end

function GiveawayView:step(p)
	local data = self.data

	if not data then
		return
	end

	local v = p < data.spinAt
	local v2 = math.clamp((p - data.spinAt) / (data.resultAt - data.spinAt), 0, 1)
	local rotation = v and -80 or -80 + (self.finalAngle + 80) * (1 - (1 - v2) ^ 5)
	self.ring.Rotation = rotation

	for _, card in self.cards do
		card.Rotation = -rotation
	end

	local lastIndex = math.floor(-rotation % 360 / 360 * #data.pool + 0.5) % #data.pool + 1
	local winner = data.pool[lastIndex]
	self.title.Text = v and "A GLOBAL WHEEL HAS BEGUN" or v2 < 1 and "WHO WILL TAKE IT HOME?" or "WE HAVE A WINNER!"
	self.sub.Text = v and "The owner is giving away " .. self.name.Text .. "." or v2 < 1 and "Spinning for " .. #data.pool .. " eligible players in this server." or data.preview and "Preview complete. No prize was awarded." or "Prize saved. It's yours to keep."
	self.hubText.Text = v and "GET\nREADY" or v2 < 1 and "GOOD\nLUCK" or "WINNER"

	if v2 >= 1 then
		winner = data.winner
	end

	self.heroPortrait.Visible = not v
	self.hubText.Position = UDim2.fromOffset(0, v and 40 or 122)
	self.hubText.Size = UDim2.fromOffset(170, v and 90 or 36)

	if not v then
		self.hubText.RichText = true
		self.hubText.Text = VerifiedName.format(winner.display, winner.verified)
		self.heroPortrait.Image = "rbxthumb://type=AvatarHeadShot&id=" .. winner.id .. "&w=150&h=150"
	end

	self.selected.RichText = true
	self.selected.Text = (v2 >= 1 and "WINNER  ·  " or "") .. VerifiedName.format(winner.display, winner.verified) .. "  @" .. winner.name

	if v2 >= 1 then
		for k, card in self.cards do
			card.Outline.Color = k == self.winnerIndex and ValleyTheme.Gold or ValleyTheme.Border
			card.Outline.Thickness = k == self.winnerIndex and 4 or 1
		end
	end

	local v5 = p - data.resultAt

	for k, v6 in self.confetti do
		v6.Visible = v5 >= 0 and v5 < 3

		if not v6.Visible then
			continue
		end

		local v8 = v5 / 3
		v6.Position = UDim2.fromScale(k * 0.618 % 1 + math.sin(v5 * 3 + k) * 0.03, -0.12 + v8 * (1.2 + k % 5 * 0.12))
		v6.Rotation = k * 47 + v5 * (k % 2 == 0 and 90 or -90)
		v6.BackgroundTransparency = math.clamp((v8 - 0.65) / 0.35, 0, 1)
	end

	local v6

	if lastIndex == self.lastIndex then
		v6 = false
	else
		v6 = not v and v2 < 1
	end

	self.lastIndex = lastIndex
	return v6, v2 >= 1
end

function GiveawayView:hide()
	self.gui.Enabled = false
	self.data = nil
	self.preview:ClearAllChildren()
	self.ring:ClearAllChildren()
	table.clear(self.cards)
end

return GiveawayView