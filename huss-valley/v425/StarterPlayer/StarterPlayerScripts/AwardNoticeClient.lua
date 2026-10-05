local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local adminEvent = chickenOrHero:WaitForChild("Admin"):WaitForChild("AdminEvent")
local ValleyPanels = require(chickenOrHero.Presentation.ValleyPanels)
local ValleyTheme = require(chickenOrHero.Presentation.ValleyTheme)
local v = ValleyPanels.make("ScreenGui", localPlayer:WaitForChild("PlayerGui"), "ValleyAwards", {
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ScreenInsets = Enum.ScreenInsets.None,
	DisplayOrder = 91,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})
local v2 = {}

for k, v3 in {
	{ UDim2.new(), UDim2.new(1, 0, 0, 3) },
	{ UDim2.new(0, 0, 1, -3), UDim2.new(1, 0, 0, 3) },
	{ UDim2.new(), UDim2.new(0, 3, 1, 0) },
	{ UDim2.new(1, -3, 0, 0), UDim2.new(0, 3, 1, 0) }
} do
	v2[k] = ValleyPanels.make("Frame", v, "Edge" .. k, {
		Position = v3[1],
		Size = v3[2],
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Active = false
	})
end

local v3 = ValleyPanels.make("CanvasGroup", v, "Card", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromScale(0.5, 0.18),
	Size = UDim2.fromOffset(430, 146),
	BackgroundColor3 = ValleyTheme.Ink,
	BackgroundTransparency = 0.04,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Visible = false,
	Active = false
})
ValleyPanels.corner(v3, 8)
ValleyPanels.stroke(v3, ValleyTheme.Gold, 0.35)
local outline = v3.Outline
ValleyPanels.make("UIScale", v3, "Scale", {})
local v4 = ValleyPanels.make("Frame", v3, "Rule", {
	Size = UDim2.new(1, 0, 0, 3),
	BorderSizePixel = 0,
	BackgroundColor3 = ValleyTheme.Gold
})
local folder = ValleyPanels.make("Frame", v3, "Mark", {
	Position = UDim2.fromOffset(15, 27),
	Size = UDim2.fromOffset(55, 56),
	BackgroundTransparency = 1
})
local v5 = ValleyPanels.make("Frame", folder, "Gift", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1
})
local v6 = ValleyPanels.make("Frame", folder, "Rank", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Visible = false
})
ValleyPanels.make("Frame", v5, "Box", {
	Position = UDim2.fromOffset(13, 25),
	Size = UDim2.fromOffset(29, 23),
	BackgroundTransparency = 1
})
ValleyPanels.stroke(v5.Box, ValleyTheme.Gold, 0)
ValleyPanels.make("Frame", v5, "Lid", {
	Position = UDim2.fromOffset(10, 20),
	Size = UDim2.fromOffset(35, 5),
	BorderSizePixel = 0,
	BackgroundColor3 = ValleyTheme.Gold
})
ValleyPanels.make("Frame", v5, "Ribbon", {
	Position = UDim2.fromOffset(26, 20),
	Size = UDim2.fromOffset(3, 28),
	BorderSizePixel = 0,
	BackgroundColor3 = ValleyTheme.Gold
})

for k, v7 in { 18, 29 } do
	local v8 = ValleyPanels.make("Frame", v5, "Bow" .. k, {
		Position = UDim2.fromOffset(v7, 10),
		Size = UDim2.fromOffset(9, 9),
		Rotation = k == 1 and -25 or 25,
		BackgroundTransparency = 1
	})
	ValleyPanels.stroke(v8, ValleyTheme.Gold, 0)
end

local v7 = ValleyPanels.make("Frame", v6, "Diamond", {
	Position = UDim2.fromOffset(14, 14),
	Size = UDim2.fromOffset(27, 27),
	Rotation = 45,
	BackgroundTransparency = 1
})
ValleyPanels.stroke(v7, ValleyTheme.Gold, 0)
ValleyPanels.make("Frame", v6, "Center", {
	Position = UDim2.fromOffset(22, 22),
	Size = UDim2.fromOffset(11, 11),
	Rotation = 45,
	BorderSizePixel = 0,
	BackgroundColor3 = ValleyTheme.Gold
})
local text = ValleyPanels.text(v3, "Eyebrow", "", 82, 17, 300, 19, 11, ValleyTheme.Gold)
text.Font = Enum.Font.GothamBold
local text2 = ValleyPanels.text(v3, "Title", "", 82, 42, 308, 42, 23, ValleyTheme.Paper)
text2.Font = Enum.Font.GothamBold
text2.TextScaled = true
ValleyPanels.make("UITextSizeConstraint", text2, "Limits", {
	MinTextSize = 14,
	MaxTextSize = 23
})
local text3 = ValleyPanels.text(v3, "Detail", "", 82, 87, 322, 44, 12, ValleyTheme.Muted)
local button = ValleyPanels.button(v3, "Close", "×", 396, 6, 28, 28, ValleyTheme.Ink)
button.BackgroundTransparency = 1
button.TextSize = 21
local v8 = {}
local v9 = {}
local v10 = nil
local v11 = false
local flag = true
local v12 = {
	"GlobalWheelOpen",
	"ScreenPresentationActive",
	"TutorialRouting",
	"TutorialSession",
	"AdminRefreshActive",
	"MatchSummaryVisible",
	"BalloonOfferOpen",
	"FairPlayNoticeOpen",
	"ChoiceSpotlightActive"
}

local function ready()
	if localPlayer:GetAttribute("ClientReady") ~= true then
		return false
	end

	for _, attributeName in v12 do
		if localPlayer:GetAttribute(attributeName) then
			return false
		end
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function layout()
	local absoluteSize = v.AbsoluteSize
	v3.Scale.Scale = math.min(1, absoluteSize.X * 0.88 / 430, absoluteSize.Y * 0.38 / 146)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tween(p, duration, p2)
	TweenService:Create(p, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p2):Play()
end

local function present(data)
	v10 = data
	v11 = false
	local v13 = data.kind == "AccessRemoved"
	local purple = data.kind == "Gift" and ValleyTheme.Purple or v13 and ValleyTheme.Blue or ValleyTheme.Gold

	for _, v14 in v2 do
		v14.BackgroundColor3 = purple
		TweenService:Create(v14, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.35
		}):Play()
	end

	v4.BackgroundColor3 = purple
	outline.Color = purple
	text.TextColor3 = purple
	v5.Visible = data.kind == "Gift"
	v6.Visible = not v5.Visible

	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Frame") and descendant.BackgroundTransparency < 1 then
			descendant.BackgroundColor3 = purple
		elseif descendant:IsA("UIStroke") then
			descendant.Color = purple
		end
	end

	text.Text = (data.kind == "Gift" and "GIFT FROM " or data.kind == "Rank" and "RANKED BY " or data.kind == "Title" and "TITLE FROM " or "ACCESS UPDATE · ") .. (data.from or "THE OWNER")
	text2.Text = data.label
	text3.Text = data.detail or ""
	v3.Visible = true
	v3.GroupTransparency = 1
	v3.Position = UDim2.fromScale(0.5, 0.16)
	layout() -- equivalent call inferred; original call site unknown
	tween(v3, 0.3, {
		GroupTransparency = 0,
		Position = UDim2.fromScale(0.5, 0.18)
	}) -- equivalent call inferred; original call site unknown

	if data.kind == "Gift" then
		chickenOrHero.Weapons.ArmoryEvent:FireServer("CheckRewards")
	end

	local total = 0

	while flag and not v11 and total < 7 do
		task.wait(0.1)

		if ready() then
			v3.Visible = true
			total += 0.1
		else
			v3.Visible = false

			for _, v16 in v2 do
				v16.BackgroundTransparency = 1
			end
		end
	end

	TweenService:Create(v3, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		GroupTransparency = 1
	}):Play()

	for _, v16 in v2 do
		TweenService:Create(v16, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()
	end

	task.wait(0.4)
	v3.Visible = false

	if flag then
		adminEvent:FireServer("AwardAck", data.id)
	end

	v10 = nil
end

button.Activated:Connect(function()
	v11 = true
end)
adminEvent.OnClientEvent:Connect(function(p, items)
	if p ~= "Awards" or type(items) ~= "table" then
		return
	end

	for _, item in items do
		if not (type(item) == "table" and type(item.id) == "string" and type(item.label) == "string") then
			continue
		end

		if v9[item.id] then
			if not v10 or v10.id ~= item.id then
				local v13 = false

				for _, v15 in v8 do
					if v15.id ~= item.id then
						continue
					end

					v13 = true
					break
				end

				if not v13 then
					adminEvent:FireServer("AwardAck", item.id)
				end
			end
		else
			v9[item.id] = true
			table.insert(v8, item)
		end
	end
end)
v:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)

-- equivalent calls inferred from this helper; original call sites unknown
local function sync()
	if ready() then
		adminEvent:FireServer("AwardReady")
	end
end

localPlayer:GetAttributeChangedSignal("ClientReady"):Connect(sync)
task.spawn(function()
	while flag do
		if ready() and #v8 > 0 then
			present(table.remove(v8, 1))
		else
			task.wait(0.2)
		end
	end
end)
layout() -- equivalent call inferred; original call site unknown
sync() -- equivalent call inferred; original call site unknown
script.Destroying:Connect(function()
	flag = false
	v:Destroy()
end)