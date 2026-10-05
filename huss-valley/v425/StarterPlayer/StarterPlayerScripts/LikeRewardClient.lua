local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local ValleyPanels = require(chickenOrHero.Presentation.ValleyPanels)
local HudNavigation = require(chickenOrHero.Presentation.HudNavigation)
local armoryEvent = chickenOrHero.Weapons:WaitForChild("ArmoryEvent")
local screen = ValleyPanels.screen(localPlayer, "LikeReward", 68)
local panel, v, v2 = ValleyPanels.panel(screen, "Panel", 520, 340)
ValleyPanels.make("Frame", v, "TopRule", {
	Size = UDim2.new(1, -28, 0, 3),
	Position = UDim2.fromOffset(14, 0),
	BackgroundColor3 = ValleyPanels.Gold,
	BorderSizePixel = 0
})
ValleyPanels.text(v, "Eyebrow", "HUSS VALLEY  /  FREE REWARD", 28, 24, 400, 18, 11, ValleyPanels.Gold)
local text_2 = ValleyPanels.text(v, "Heading", "LIKE REWARD", 28, 61, 450, 40, 30, ValleyPanels.Paper)
text_2.Font = Enum.Font.GothamBold
ValleyPanels.text(v, "Instructions", "LIKE THE GAME AND REJOIN TO CLAIM", 28, 112, 464, 42, 16, ValleyPanels.Muted)
local text = ValleyPanels.text(v, "Rewards", "+50 GEMS +30 COINS", 28, 171, 464, 40, 27, ValleyPanels.Gold)
text.Font = Enum.Font.GothamBold
text.TextXAlignment = Enum.TextXAlignment.Center
local text2 = ValleyPanels.text(v, "Status", "", 28, 220, 464, 28, 12, ValleyPanels.Muted)
text2.TextXAlignment = Enum.TextXAlignment.Center
local button = ValleyPanels.button(v, "Claim", "LOADING…", 28, 270, 464, 44, Color3.fromRGB(81, 67, 39))
local v3 = {
	loaded = false
}
local v4 = false
local selectedObject = nil
local textLabel = nil
local flag = true
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function connect(object, p)
	table.insert(connections, object:Connect(p))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function remaining()
	local likeRewardReadyAt = localPlayer:GetAttribute("LikeRewardReadyAt")

	if type(likeRewardReadyAt) == "number" then
		return (math.max(0, (math.ceil(likeRewardReadyAt - workspace:GetServerTimeNow()))))
	end

	return nil
end

local function clockText(p)
	return string.format("%d:%02d", math.floor(p / 60), p % 60)
end

local function syncWorldReward()
	if not flag then
		return
	end

	local freeReward = workspace:FindFirstChild("FreeReward")

	if not freeReward then
		return
	end

	if v3.likeRewardClaimed == true then
		freeReward:Destroy()
		textLabel = nil
	else
		local sign = freeReward:FindFirstChild("Sign")
		local title = sign and sign:FindFirstChild("Title")

		if not (sign and sign:IsA("BillboardGui") and title and title:IsA("TextLabel")) then
			return
		end

		if not (textLabel and textLabel:IsDescendantOf(sign)) then
			textLabel = Instance.new("TextLabel")
			textLabel.Name = "LocalRewardCountdown"
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.fromScale(1, 0.16)
			textLabel.Position = UDim2.new(
				0,
				0,
				title.Position.Y.Scale + title.Size.Y.Scale + 0.025,
				title.Position.Y.Offset + title.Size.Y.Offset
			)
			textLabel.Font = Enum.Font.GothamMedium
			textLabel.TextColor3 = Color3.fromRGB(166, 172, 181)
			textLabel.TextScaled = true
			textLabel.TextStrokeColor3 = Color3.fromRGB(25, 29, 35)
			textLabel.TextStrokeTransparency = 0.35
			textLabel.Parent = sign
		end

		local v5 = remaining() -- equivalent call inferred; original call site unknown
		textLabel.Text = not v5 and "Loading…" or v5 > 0 and string.format("%d:%02d", math.floor(v5 / 60), v5 % 60) .. " until this can be claimed" or (v3.rewardJoins or 0) < 2 and "Rejoin to claim" or "Ready to claim!"
	end
end

local function eligible()
	return localPlayer:GetAttribute("ClientReady") == true and not (localPlayer:GetAttribute("InMatch") or localPlayer:GetAttribute("TutorialRouting") or localPlayer:GetAttribute("ScreenPresentationActive"))
end

local function render()
	if not flag then
		return
	end

	local likeRewardClaimed = v3.likeRewardClaimed == true
	local v5 = remaining() -- equivalent call inferred; original call site unknown
	local v6 = v5 == nil or v5 > 0
	local loaded = v3.loaded

	if loaded then
		if (v3.rewardJoins or 0) >= 2 then
			loaded = not v6
		else
			loaded = false
		end
	end

	button.Text = likeRewardClaimed and "CLAIMED  ✓" or v4 and "CLAIMING…" or v3.loaded and (v6 and "REWARD LOCKED" or loaded and "CLAIM REWARD" or "REJOIN TO CLAIM") or "LOADING…"
	local v7 = button
	local active = loaded and not (likeRewardClaimed or v4)

	if active then
		if localPlayer:GetAttribute("ClientReady") == true then
			active = not (localPlayer:GetAttribute("InMatch") or localPlayer:GetAttribute("TutorialRouting") or localPlayer:GetAttribute("ScreenPresentationActive"))
		else
			active = false
		end
	end

	v7.Active = active
	button.Selectable = button.Active
	button.AutoButtonColor = button.Active
	button.TextTransparency = button.Active and 0 or 0.35
	text2.Text = likeRewardClaimed and "Your reward has been added to your wallet." or not (v3.loaded and v5) and "Loading your reward…" or v5 > 0 and string.format(
		"%d:%02d",
		math.floor(v5 / 60),
		v5 % 60
	) .. " until this can be claimed" or loaded and "Welcome back! Your reward is ready." or "First visit recorded. Come back to collect your reward."

	if v3.sessionOnly then
		text2.Text ..= "  (Studio session only)"
	end

	syncWorldReward()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hide()
	panel.Visible = false
	localPlayer:SetAttribute("LikeRewardOpen", nil)

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(screen) then
		GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
	end
end

local function show()
	local v5

	if localPlayer:GetAttribute("ClientReady") == true then
		v5 = not (localPlayer:GetAttribute("InMatch") or localPlayer:GetAttribute("TutorialRouting") or localPlayer:GetAttribute("ScreenPresentationActive"))
	else
		v5 = false
	end

	if not v5 then
		return
	end

	HudNavigation.opening("LikeReward")
	selectedObject = GuiService.SelectedObject
	panel.Visible = true
	localPlayer:SetAttribute("LikeRewardOpen", true)
	localPlayer:SetAttribute("SpectateRequestedExit", os.clock())
	render()
	armoryEvent:FireServer("Get")

	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		GuiService.SelectedObject = button.Active and button or v2
	end
end

connect(v2.Activated, hide) -- equivalent call inferred; original call site unknown
table.insert(connections, button.Activated:Connect(function()
	if not button.Active then
		return
	end

	v4 = true
	render()
	armoryEvent:FireServer("ClaimLikeReward")
	task.delay(5, function()
		if flag and v4 then
			v4 = false
			render()
			text2.Text = "Please try again. Your claim can only pay once."
		end
	end)
end))
table.insert(connections, armoryEvent.OnClientEvent:Connect(function(p, p2)
	if p ~= "State" or type(p2) ~= "table" then
		return
	end

	v3 = p2

	if not p2.pending then
		v4 = false
	end

	render()

	if panel.Visible and p2.message then
		text2.Text = p2.message
	end
end))
table.insert(connections, HudNavigation.Opening.Event:Connect(function(p)
	if p ~= "LikeReward" then
		hide() -- equivalent call inferred; original call site unknown
	end
end))

for _, v5 in {
	"InMatch",
	"ScreenPresentationActive",
	"TutorialRouting",
	"ClientReady",
	"MatchSummaryVisible"
} do
	table.insert(connections, localPlayer:GetAttributeChangedSignal(v5):Connect(function()
		local v6

		if localPlayer:GetAttribute("ClientReady") == true then
			v6 = not (localPlayer:GetAttribute("InMatch") or localPlayer:GetAttribute("TutorialRouting") or localPlayer:GetAttribute("ScreenPresentationActive"))
		else
			v6 = false
		end

		if not v6 or localPlayer:GetAttribute("MatchSummaryVisible") then
			hide() -- equivalent call inferred; original call site unknown
		end
	end))
end

table.insert(connections, UserInputService.InputBegan:Connect(function(input)
	if panel.Visible and not UserInputService:GetFocusedTextBox() and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
		hide() -- equivalent call inferred; original call site unknown
	end
end))
local ProximityPromptService = game:GetService("ProximityPromptService")
table.insert(connections, ProximityPromptService.PromptTriggered:Connect(function(player, p)
	local freeReward = workspace:FindFirstChild("FreeReward")

	if p == localPlayer and freeReward and player:IsDescendantOf(freeReward) then
		show()
	end
end))
connect(localPlayer:GetAttributeChangedSignal("LikeRewardReadyAt"), render) -- equivalent call inferred; original call site unknown
table.insert(connections, workspace.ChildAdded:Connect(function(child)
	if child.Name == "FreeReward" then
		task.defer(syncWorldReward)
	end
end))
render()
armoryEvent:FireServer("Get")
task.spawn(function()
	while flag do
		task.wait(0.25)

		if flag then
			render()
		end
	end
end)
script.Destroying:Connect(function()
	flag = false

	for _, connection in connections do
		connection:Disconnect()
	end

	hide() -- equivalent call inferred; original call site unknown

	if textLabel then
		textLabel:Destroy()
	end

	screen:Destroy()
end)