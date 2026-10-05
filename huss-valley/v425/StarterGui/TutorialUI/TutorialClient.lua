local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local card = parent.Card
local hint = parent.Hint
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local action = chickenOrHero:WaitForChild("Tutorial"):WaitForChild("Action")
local session = chickenOrHero.Game.Session
local clone = parent.TargetMarker:Clone()
clone.Name = "TutorialDestination"
clone.Parent = localPlayer.PlayerGui
parent.TargetMarker.Enabled = false
local GameConfig = require(chickenOrHero.Game.GameConfig)
local mapName = GameConfig.MapName
local v = {}
local v2 = nil
local v3 = 0
local connections = {}
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "TutorialFocus"
blurEffect.Size = 0
blurEffect.Parent = game.Lighting
local v4 = nil

local function words(value)
	local preferredInput = UserInputService.PreferredInput
	local v5 = preferredInput == Enum.PreferredInput.Touch and "tap CATCH" or preferredInput == Enum.PreferredInput.Gamepad and "press R2" or "press E"
	local v6 = preferredInput == Enum.PreferredInput.Touch and "tap DASH" or preferredInput == Enum.PreferredInput.Gamepad and "press LT / L2" or "press Space"
	return ((value or ""):gsub("{CATCH}", v5):gsub("{DASH}", v6))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function send(p)
	if os.clock() < v3 then
		return
	end

	v3 = os.clock() + 0.4
	action:FireServer(p, v.token)
end

local function update()
	local tutorialState = localPlayer:GetAttribute("TutorialState")

	if tutorialState then
		local success, result = pcall(function()
			return HttpService:JSONDecode(tutorialState)
		end)

		if success then
			v = result
		end
	else
		v = {}
	end

	local tutorialTargetSide = localPlayer:GetAttribute("TutorialSession") == true
	local v5 = localPlayer:GetAttribute("InitialLoadingComplete") ~= true or localPlayer:GetAttribute("ScreenPresentationActive") == true
	local tutorialReturnError = localPlayer:GetAttribute("TutorialReturnError") == true
	local tutorialStudioFinished = localPlayer:GetAttribute("TutorialStudioFinished") == true
	local mode = tutorialTargetSide and v.mode or ""
	local visible = not v5 and (mode == "Prompt" or mode == "Travel")
	localPlayer:SetAttribute("TutorialModalActive", visible or nil)
	parent.Shade.Visible = visible
	card.Visible = visible
	local v7 = session:GetAttribute("Phase") == "HeroChoice" or session:GetAttribute("Phase") == "SelectHero"
	local hint2 = hint
	local visible2

	if tutorialTargetSide then
		if mode == "Playing" then
			visible2 = not (v5 or v7)
		else
			visible2 = false
		end
	else
		visible2 = tutorialTargetSide
	end

	hint2.Visible = visible2
	hint.Title.Text = words(v.title)
	hint.Body.Text = words(v.body)
	local eyebrow = card.Eyebrow
	local text

	if mode == "Travel" then
		text = v.completed and "PRACTICE COMPLETE" or "LEAVING PRACTICE"
	else
		text = ("PRACTICE  /  %d OF 2"):format(v.step or 1)
	end

	eyebrow.Text = text
	card.Title.Text = words(v.title)
	card.Body.Text = words(v.body)
	card.Continue.Text = v.button or "Continue"
	card.Continue.Visible = mode == "Prompt" or tutorialReturnError
	card.Skip.Visible = mode == "Prompt"

	if mode == "Travel" then
		card.Body.Text = localPlayer:GetAttribute("TutorialRouteMessage") or words(v.body)
		card.Continue.Text = "Retry connection"

		if tutorialStudioFinished then
			card.Title.Text = words(v.title)
		end
	end

	local tutorialRouteMessage = localPlayer:GetAttribute("TutorialRouteMessage")
	local routing = parent.Routing
	routing.Visible = tutorialRouteMessage ~= nil and tutorialRouteMessage ~= "" and not (visible or v5)
	parent.Routing.Text.Text = tutorialRouteMessage or ""

	if tutorialTargetSide then
		if mode == "Playing" then
			tutorialTargetSide = localPlayer:GetAttribute("TutorialTargetSide")
		else
			tutorialTargetSide = false
		end
	end

	local child = workspace:FindFirstChild(mapName)
	local field = child and child:FindFirstChild("Field")
	clone.Adornee = field and tutorialTargetSide and field:FindFirstChild("Safezone" .. tutorialTargetSide .. "Side") or nil
	clone.Enabled = clone.Adornee ~= nil and not (v5 or v7)
	local v14 = visible and mode .. tostring(tutorialReturnError) or ""

	if v2 ~= v14 then
		v2 = v14

		if v4 then
			v4:Cancel()
		end

		v4 = TweenService:Create(blurEffect, TweenInfo.new(0.2), {
			Size = visible and 10 or 0
		})
		v4:Play()

		if visible then
			card.GroupTransparency = 1
			card.Reveal.Value = 0.97
			TweenService:Create(card, TweenInfo.new(0.22), {
				GroupTransparency = 0
			}):Play()
			TweenService:Create(card.Reveal, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
				Value = 1
			}):Play()

			if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad and card.Continue.Visible then
				GuiService.SelectedObject = card.Continue
			end
		elseif GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(card) then
			GuiService.SelectedObject = nil
		end
	end
end

table.insert(connections, card.Continue.Activated:Connect(function()
	send(v.mode == "Travel" and "RetryReturn" or "Continue") -- equivalent call inferred; original call site unknown
end))
table.insert(connections, card.Skip.Activated:Connect(function()
	if os.clock() < v3 then
		return
	end

	v3 = os.clock() + 0.4
	action:FireServer("Skip", v.token)
end))
card.Continue.NextSelectionRight = card.Skip
card.Skip.NextSelectionLeft = card.Continue

for _, v5 in {
	"TutorialState",
	"TutorialSession",
	"TutorialReturnError",
	"TutorialRouteMessage",
	"TutorialStudioFinished",
	"TutorialTargetSide",
	"InitialLoadingComplete",
	"ScreenPresentationActive"
} do
	table.insert(connections, localPlayer:GetAttributeChangedSignal(v5):Connect(update))
end

table.insert(connections, session:GetAttributeChangedSignal("Phase"):Connect(update))
table.insert(connections, UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
	update()

	if card.Visible and card.Continue.Visible and UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		GuiService.SelectedObject = card.Continue
	end
end))
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	localPlayer:SetAttribute("TutorialModalActive", nil)

	if v4 then
		v4:Cancel()
	end

	blurEffect:Destroy()
	clone:Destroy()
end)
update()