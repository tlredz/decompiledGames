local UserInputService = game:GetService("UserInputService")

if game.PlaceId ~= 130574217370467 then
	return
end

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local crates = chickenOrHero:WaitForChild("Crates")
local weapons = chickenOrHero:WaitForChild("Weapons")
local SkinCatalog = require(weapons:WaitForChild("SkinCatalog"))
local models = weapons:WaitForChild("Models")
local ValleyPanels = require(chickenOrHero.Presentation.ValleyPanels)
local crateEvent = crates:WaitForChild("CrateEvent")
local screen = ValleyPanels.screen(localPlayer, "StudioKnifePreview", 80)
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function connect(object, p)
	table.insert(connections, object:Connect(p))
end

screen.Enabled = false
local parent = ValleyPanels.make("Frame", screen, "PreviewControls", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 16, 1, -16),
	Size = UDim2.fromOffset(330, 400),
	BackgroundColor3 = ValleyPanels.Ink
})
ValleyPanels.corner(parent, 12)
ValleyPanels.stroke(parent, ValleyPanels.Gold, 0.45)
local uIScale = Instance.new("UIScale")
uIScale.Parent = parent
local text = ValleyPanels.text(parent, "Title", "STUDIO · KNIFE PREVIEW", 12, 8, 306, 20, 13, ValleyPanels.Gold)
text.Font = Enum.Font.GothamBold
local text2 = ValleyPanels.text(
	parent,
	"Skin",
	"Choose a knife to hold as a chaser",
	12,
	31,
	306,
	22,
	13,
	ValleyPanels.Paper
)
local button = ValleyPanels.button(parent, "Previous", "‹", 12, 59, 40, 30)
local button2 = ValleyPanels.button(parent, "Next", "NEXT KNIFE ›", 58, 59, 166, 30)
local button3 = ValleyPanels.button(parent, "Exit", "EXIT", 230, 59, 88, 30)
local button4 = ValleyPanels.button(parent, "Draw", "DRAW", 12, 96, 96, 30)
local button5 = ValleyPanels.button(parent, "Stab", "STAB", 117, 96, 96, 30)
local button6 = ValleyPanels.button(parent, "Dive", "DIVE", 222, 96, 96, 30)
local v2 = {
	{ "CluckBasher", ValleyPanels.button(parent, "CluckBasher", "CLUCK", 12, 134, 96, 30) },
	{ "BananaBlade", ValleyPanels.button(parent, "BananaBlade", "BANANA", 117, 134, 96, 30) },
	{ "PizzaPunisher", ValleyPanels.button(parent, "PizzaPunisher", "PIZZA", 222, 134, 96, 30) }
}
local childNames = {}

for _, childName in SkinCatalog.Order do
	local v3 = SkinCatalog.get(childName)
	local model = models:FindFirstChild(childName)
	local handle = model and model:FindFirstChild("Handle")
	local blade = model and model:FindFirstChild("Blade")
	local stowedBlade = model and model:FindFirstChild("StowedBlade")
	local bladeWeld = handle and handle:FindFirstChild("BladeWeld")

	if not (v3 and v3.EquipReady ~= false and model and model:IsA("Model")) then
		continue
	end

	if not (handle and handle:IsA("BasePart") and blade and blade:IsA("BasePart")) then
		continue
	end

	if not (stowedBlade and stowedBlade:IsA("BasePart") and bladeWeld and bladeWeld:IsA("JointInstance")) then
		continue
	end

	if not (typeof(model:GetAttribute("GripC0")) == "CFrame" and typeof(model:GetAttribute("GripC1")) == "CFrame") then
		continue
	end

	if typeof(model:GetAttribute("StowedOffset")) ~= "CFrame" then
		continue
	end

	table.insert(childNames, childName)
end

local v3 = false
local index = 0
local now = -1e999

-- equivalent calls inferred from this helper; original call sites unknown
local function send(p, p2)
	if os.clock() - now < 0.55 then
		return
	end

	now = os.clock()
	crateEvent:FireServer(p, p2)
end

local parent2 = ValleyPanels.make("ScrollingFrame", parent, "AllKnives", {
	Position = UDim2.fromOffset(12, 174),
	Size = UDim2.fromOffset(306, 214),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.new()
})
local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Padding = UDim.new(0, 4)
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.Parent = parent2
local buttons = {}

for k, v5 in childNames do
	local button7 = ValleyPanels.button(parent2, v5, SkinCatalog.get(v5).Name, 0, 0, 294, 30)
	button7.LayoutOrder = k
	buttons[v5] = button7
	local v6 = v5
	table.insert(connections, button7.Activated:Connect(function()
		if localPlayer:GetAttribute("InMatch") ~= true then
			send("PreviewSkin", v6) -- equivalent call inferred; original call site unknown
		end
	end))
end

local function cycle(p)
	if #childNames == 0 then
		return
	end

	local studioKnifePreview = localPlayer:GetAttribute("StudioKnifePreview")
	index = table.find(childNames, studioKnifePreview) or index
	index = (index - 1 + p) % #childNames + 1
	send("PreviewSkin", childNames[index]) -- equivalent call inferred; original call site unknown
end

table.insert(connections, button.Activated:Connect(function()
	if #childNames == 0 then
		return
	end

	local studioKnifePreview = localPlayer:GetAttribute("StudioKnifePreview")
	index = table.find(childNames, studioKnifePreview) or index
	index = (index - 1 + -1) % #childNames + 1
	send("PreviewSkin", childNames[index]) -- equivalent call inferred; original call site unknown
end))
table.insert(connections, button2.Activated:Connect(function()
	if #childNames == 0 then
		return
	end

	local studioKnifePreview = localPlayer:GetAttribute("StudioKnifePreview")
	index = table.find(childNames, studioKnifePreview) or index
	index = (index - 1 + 1) % #childNames + 1
	send("PreviewSkin", childNames[index]) -- equivalent call inferred; original call site unknown
end))
table.insert(connections, button3.Activated:Connect(function()
	if os.clock() - now < 0.55 then
		return
	end

	now = os.clock()
	crateEvent:FireServer("StopPreview", "")
end))

for _, v5 in v2 do
	local v6 = v5
	table.insert(connections, v5[2].Activated:Connect(function()
		send("PreviewSkin", v6[1]) -- equivalent call inferred; original call site unknown
	end))
end

for k, v5 in {
	[button4] = "Draw",
	[button5] = "Stab",
	[button6] = "Dive"
} do
	local v6 = v5
	table.insert(connections, k.Activated:Connect(function()
		send("PreviewAction", v6) -- equivalent call inferred; original call site unknown
	end))
end

local function refresh()
	screen.Enabled = v3
	parent.Visible = v3
	local active = localPlayer:GetAttribute("InMatch") ~= true
	text.Text = active and "TEST KNIVES · F7 TO CLOSE" or "TEST KNIVES · LOBBY ONLY"

	for _, v6 in buttons do
		v6.Active = active
		v6.TextTransparency = active and 0 or 0.55
	end

	button.Active = active
	button2.Active = active
	local studioKnifePreview = localPlayer:GetAttribute("StudioKnifePreview")
	local v6 = SkinCatalog.get(studioKnifePreview)
	text2.Text = not v6 and "Choose a knife to hold as a chaser" or tostring(table.find(childNames, studioKnifePreview) or 0) .. "/" .. #childNames .. " · " .. v6.Name or "Choose a knife to hold as a chaser"

	for _, v7 in {
		button4,
		button5,
		button6,
		button3
	} do
		v7.Active = active and studioKnifePreview ~= nil
		v7.TextTransparency = studioKnifePreview and 0 or 0.55
	end

	for _, v7 in v2 do
		v7[2].BackgroundColor3 = studioKnifePreview == v7[1] and ValleyPanels.Gold or Color3.fromRGB(36, 56, 70)
		v7[2].TextColor3 = studioKnifePreview == v7[1] and ValleyPanels.Ink or ValleyPanels.Paper
	end
end

table.insert(connections, UserInputService.InputBegan:Connect(function(input)
	if UserInputService:GetFocusedTextBox() or input.KeyCode ~= Enum.KeyCode.F7 then
		return
	end

	v3 = not v3

	if not v3 then
		crateEvent:FireServer("StopPreview", "")
	end

	refresh()
end))
connect(localPlayer:GetAttributeChangedSignal("StudioKnifePreview"), refresh) -- equivalent call inferred; original call site unknown
connect(localPlayer:GetAttributeChangedSignal("InMatch"), refresh) -- equivalent call inferred; original call site unknown
local viewportSizeChangedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function updateScale()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		uIScale.Scale = math.min(1, currentCamera.ViewportSize.X * 0.94 / 330, currentCamera.ViewportSize.Y * 0.9 / 400)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindCamera()
	if viewportSizeChangedConnection then
		viewportSizeChangedConnection:Disconnect()
		viewportSizeChangedConnection = nil
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		viewportSizeChangedConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	end

	updateScale() -- equivalent call inferred; original call site unknown
end

connect(workspace:GetPropertyChangedSignal("CurrentCamera"), bindCamera) -- equivalent call inferred; original call site unknown
bindCamera() -- equivalent call inferred; original call site unknown
refresh()
script.Destroying:Connect(function()
	if viewportSizeChangedConnection then
		viewportSizeChangedConnection:Disconnect()
	end

	for _, connection in connections do
		connection:Disconnect()
	end

	screen:Destroy()
end)