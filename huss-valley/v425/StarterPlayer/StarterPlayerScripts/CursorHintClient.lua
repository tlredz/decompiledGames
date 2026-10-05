local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local v = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
localPlayer:SetAttribute("CursorHintPending", v or nil)

if not v then
	return
end

local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local emoteEvent = chickenOrHero:WaitForChild("Emotes"):WaitForChild("EmoteEvent")
local ValleyPanels = require(chickenOrHero.Presentation.ValleyPanels)
local ValleyTheme = require(chickenOrHero.Presentation.ValleyTheme)
local screen = ValleyPanels.screen(localPlayer, "CursorWelcome", 74)
local v2 = ValleyPanels.make("Frame", screen, "Hint", {
	Size = UDim2.fromOffset(430, 148),
	Position = UDim2.fromScale(0.5, 0.26),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = ValleyTheme.Ink,
	BorderSizePixel = 0,
	Visible = false,
	Active = false
})
ValleyTheme.surface(v2, ValleyTheme.Ink, ValleyTheme.Gold, 8, 0.45)
ValleyPanels.make("UIScale", v2, "Scale", {})
ValleyPanels.text(v2, "Eyebrow", "ONE QUICK CONTROL", 20, 13, 350, 18, 10, ValleyTheme.Gold)
local text = ValleyPanels.text(v2, "Title", "Hold ALT to free your mouse", 20, 35, 390, 30, 20, ValleyTheme.Paper)
text.Font = Enum.Font.GothamBold
ValleyPanels.text(
	v2,
	"Body",
	"Use it to reach menus. Let go to look around again.",
	20,
	70,
	390,
	35,
	13,
	ValleyTheme.Muted
)
local button = ValleyPanels.button(v2, "Done", "GOT IT", 292, 110, 118, 28, ValleyTheme.Ink)
ValleyTheme.button(button, ValleyTheme.Gold)
button.TextSize = 11
local loaded = false
local v3 = false
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function complete(p)
	if flag then
		return
	end

	flag = true
	v2.Visible = false
	localPlayer:SetAttribute("CursorHintPending", nil)
	localPlayer:SetAttribute("CursorHintOpen", nil)

	if p then
		emoteEvent:FireServer("CursorHintSeen")
		task.delay(2, function()
			if localPlayer.Parent then
				emoteEvent:FireServer("CursorHintSeen")
			end
		end)
	end
end

button.Activated:Connect(function()
	complete(true)
end)
local onClientEventConnection = emoteEvent.OnClientEvent:Connect(function(p, p2)
	if p == "State" and type(p2) == "table" then
		loaded = p2.loaded
		v3 = p2.cursorHintSeen == true

		if v3 then
			complete(false) -- equivalent call inferred; original call site unknown
		end
	end
end)
local inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
	if v2.Visible and (input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt) then
		task.delay(0.6, function()
			complete(true)
		end)
	end
end)
local v4 = {
	"CreatorPanelOpen",
	"CreatorUIHidden",
	"CreatorCameraActive",
	"MapVoteOpen",
	"InMatch",
	"ScreenPresentationActive",
	"TutorialRouting",
	"TutorialSession",
	"BalloonOfferOpen",
	"ArmoryOpen",
	"ServerBrowserOpen",
	"JourneyOpen",
	"SettingsOpen",
	"UpdateLogOpen",
	"AdminConsoleActive",
	"AnnouncementComposerOpen",
	"EmoteWheelOpen",
	"MatchSummaryVisible",
	"FairPlayNoticeOpen",
	"ConnectionQualityOpen",
	"AdminRefreshActive",
	"Spectating"
}

local function permitted()
	if localPlayer:GetAttribute("ClientReady") ~= true or UserInputService:GetFocusedTextBox() then
		return false
	end

	local GuiService = game:GetService("GuiService")

	if GuiService.MenuIsOpen then
		return false
	end

	for _, attributeName in v4 do
		if localPlayer:GetAttribute(attributeName) == true then
			return false
		end
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function layout()
	local absoluteSize = screen.AbsoluteSize
	v2.Scale.Scale = math.min(1.1, absoluteSize.X * 0.92 / 430, absoluteSize.Y * 0.6 / 148)
end

screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
layout() -- equivalent call inferred; original call site unknown
emoteEvent:FireServer("Get")
task.spawn(function()
	local lastTime = os.clock()
	local v5 = 0
	local v6 = nil

	while screen.Parent and not flag do
		if not loaded and v5 < os.clock() then
			v5 = os.clock() + 3
			emoteEvent:FireServer("Get")
		end

		if loaded and permitted() then
			v6 = v6 or os.clock()

			if os.clock() - v6 > 1.5 then
				v2.Visible = true
				localPlayer:SetAttribute("CursorHintOpen", true)
			end
		else
			v2.Visible = false
			localPlayer:SetAttribute("CursorHintOpen", nil)
			v6 = nil
		end

		if not loaded and os.clock() - lastTime > 30 and not flag then
			flag = true
			v2.Visible = false
			localPlayer:SetAttribute("CursorHintPending", nil)
			localPlayer:SetAttribute("CursorHintOpen", nil)
		end

		task.wait(0.2)
	end

	onClientEventConnection:Disconnect()
	inputBeganConnection:Disconnect()
end)
script.Destroying:Connect(function()
	complete(false) -- equivalent call inferred; original call site unknown
	onClientEventConnection:Disconnect()
	inputBeganConnection:Disconnect()
	screen:Destroy()
end)