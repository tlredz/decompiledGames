local createVector = vector.create
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local weapons = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Weapons")
local armoryEvent = weapons:WaitForChild("ArmoryEvent")
local armoryNavigation = weapons:WaitForChild("ArmoryNavigation")
local playerGui = localPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BalloonOffer"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 80
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui
local frame = Instance.new("Frame")
frame.Name = "Card"
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.fromOffset(560, 430)
frame.BackgroundColor3 = Color3.fromRGB(28, 25, 42)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = false
frame.Parent = screenGui
local uIScale = Instance.new("UIScale")
uIScale.Parent = frame
local uICorner = Instance.new("UICorner")
uICorner.CornerRadius = UDim.new(0, 18)
uICorner.Parent = frame
local uIStroke = Instance.new("UIStroke")
uIStroke.Color = Color3.fromRGB(242, 137, 190)
uIStroke.Transparency = 0.4
uIStroke.Parent = frame

local function label(name, text, p, p2, p3, p4, textSize, p5)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.Text = text
	textLabel.Position = UDim2.fromOffset(p, p2)
	textLabel.Size = UDim2.fromOffset(p3, p4)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = textSize
	textLabel.TextColor3 = p5 or Color3.fromRGB(250, 241, 249)
	textLabel.BackgroundTransparency = 1
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = frame
	return textLabel
end

local function button(name, text, p, p2, p3, p4, backgroundColor)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.Text = text
	textButton.Position = UDim2.fromOffset(p, p2)
	textButton.Size = UDim2.fromOffset(p3, p4)
	textButton.Font = Enum.Font.GothamBold
	textButton.TextSize = 16
	textButton.TextColor3 = Color3.fromRGB(255, 245, 250)
	textButton.BackgroundColor3 = backgroundColor
	textButton.Parent = frame
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(0, 9)
	uICorner2.Parent = textButton
	return textButton
end

label("Eyebrow", "A LITTLE PARTY FAVOUR", 26, 22, 450, 24, 14, Color3.fromRGB(255, 151, 201))
local v = button("Close", "×", 509, 12, 38, 36, Color3.fromRGB(44, 37, 55))
v.Modal = true
label("Title", "FREE BALLOON\nDAGGER", 264, 77, 270, 72, 28)
label(
	"Description",
	"Bring a friend to the Valley.\nKeep the party forever.",
	264,
	159,
	263,
	70,
	18,
	Color3.fromRGB(218, 210, 228)
)
local viewportFrame = Instance.new("ViewportFrame")
viewportFrame.Name = "Dagger"
viewportFrame.Position = UDim2.fromOffset(16, 54)
viewportFrame.Size = UDim2.fromOffset(242, 214)
viewportFrame.BackgroundTransparency = 1
viewportFrame.Ambient = Color3.fromRGB(210, 210, 220)
viewportFrame.LightColor = Color3.new(1, 1, 1)
viewportFrame.Parent = frame
local balloonDagger = weapons:WaitForChild("Models"):WaitForChild("BalloonDagger")
local worldModel = Instance.new("WorldModel")
worldModel.Parent = viewportFrame
local clone = balloonDagger:WaitForChild("Blade"):Clone()

for _, descendant in clone:GetDescendants() do
	if not (descendant:IsA("JointInstance") or descendant:IsA("LuaSourceContainer") or descendant:IsA("WeldConstraint")) then
		continue
	end

	descendant:Destroy()
end

clone.CFrame = balloonDagger:GetAttribute("PreviewRotation") or CFrame.identity
clone.Anchored = true
clone.Transparency = 0
clone.Parent = worldModel
local camera = Instance.new("Camera")
camera.FieldOfView = 35
camera.Parent = viewportFrame
viewportFrame.CurrentCamera = camera
local v2 = math.max(clone.Size.X, clone.Size.Y, clone.Size.Z)
local v3 = label(
	"Progress",
	"○  Invite a friend who joins through your invite.",
	26,
	266,
	508,
	50,
	17,
	Color3.fromRGB(231, 220, 238)
)
local v4 = button("Invite", "INVITE A FRIEND", 26, 330, 250, 46, Color3.fromRGB(163, 72, 124))
local v5 = button("Claim", "CHECK CLAIM", 286, 330, 248, 46, Color3.fromRGB(55, 46, 72))
local v6 = label(
	"Note",
	"Like or favourite if you enjoy the Valley — always optional.",
	26,
	385,
	508,
	26,
	12,
	Color3.fromRGB(175, 164, 188)
)
local GuiService = game:GetService("GuiService")
local selectedObject = nil
local v7 = {
	loaded = false,
	owned = 0
}
v7.owned = {}
local v8 = false
local v9 = false
local now = 0
local now2 = 0
local total = 0

local function permitted()
	local v10 = not (localPlayer:GetAttribute("CreatorPanelOpen") or localPlayer:GetAttribute("CreatorUIHidden") or localPlayer:GetAttribute("CreatorCameraActive"))

	if v10 then
		if localPlayer:GetAttribute("MapVoteOpen") == true or localPlayer:GetAttribute("CursorHintPending") == true or localPlayer:GetAttribute("CursorHintOpen") == true or localPlayer:GetAttribute("EmoteWheelOpen") == true or localPlayer:GetAttribute("AnnouncementComposerOpen") == true or localPlayer:GetAttribute("JourneyOpen") == true or localPlayer:GetAttribute("SettingsOpen") == true or localPlayer:GetAttribute("UpdateLogOpen") == true or localPlayer:GetAttribute("ClientReady") ~= true or localPlayer:GetAttribute("InMatch") == true or localPlayer:GetAttribute("ScreenPresentationActive") == true or localPlayer:GetAttribute("AdminRefreshActive") == true or localPlayer:GetAttribute("TutorialRouting") == true or localPlayer:GetAttribute("AdminConsoleActive") == true or localPlayer:GetAttribute("ServerBrowserOpen") == true then
			return false
		else
			return localPlayer:GetAttribute("MatchSummaryVisible") ~= true
		end
	end

	return v10
end

local function update()
	local balloonDagger2 = v7.owned.BalloonDagger == true
	v3.Text = balloonDagger2 and "✓  Unlocked! Your balloon dagger is yours forever." or "○  Invite a friend who joins through your invite."
	v3.TextColor3 = balloonDagger2 and Color3.fromRGB(151, 235, 187) or Color3.fromRGB(231, 220, 238)
	v5.Text = not v7.loaded and "LOADING…" or v7.equipped == "BalloonDagger" and "EQUIPPED ✓" or balloonDagger2 and "EQUIP DAGGER" or "CHECK CLAIM"
	v4.Visible = not balloonDagger2
	v5.Position = UDim2.fromOffset(balloonDagger2 and 26 or 286, 330)
	v5.Size = UDim2.fromOffset(balloonDagger2 and 508 or 248, 46)
end

local function show(visible)
	if visible and not permitted() then
		return
	end

	if visible and not v8 then
		selectedObject = GuiService.SelectedObject
	end

	if not visible and GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(frame) then
		GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
	end

	v8 = visible
	frame.Visible = visible
	localPlayer:SetAttribute("BalloonOfferOpen", visible)

	if visible then
		armoryEvent:FireServer("Get")
		update()

		if UserInputService.GamepadEnabled then
			GuiService.SelectedObject = v7.owned.BalloonDagger and v5 or v4
		end
	end
end

v.Activated:Connect(function()
	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(frame) then
		GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
	end

	v8 = false
	frame.Visible = false
	localPlayer:SetAttribute("BalloonOfferOpen", false)
end)
armoryNavigation.Event:Connect(function(p)
	if p == "Balloon" then
		if not permitted() then
			return
		end

		if not v8 then
			selectedObject = GuiService.SelectedObject
		end

		v8 = true
		frame.Visible = true
		localPlayer:SetAttribute("BalloonOfferOpen", true)
		armoryEvent:FireServer("Get")
		update()

		if UserInputService.GamepadEnabled then
			GuiService.SelectedObject = v7.owned.BalloonDagger and v5 or v4
		end
	end
end)
armoryEvent.OnClientEvent:Connect(function(p, p2)
	if p == "State" and type(p2) == "table" then
		v7 = p2
		update()

		if v7.owned.BalloonDagger then
			v6.Text = "Find it any time in My Knives."
		end
	end
end)
v4.Activated:Connect(function()
	if not v8 or os.clock() - now < 3 then
		return
	end

	now = os.clock()
	task.spawn(function()
		local success, result = pcall(SocialService.CanSendGameInviteAsync, SocialService, localPlayer)

		if not v8 then
			return
		end

		if success and result then
			v6.Text = pcall(SocialService.PromptGameInvite, SocialService, localPlayer) and "Your friend needs to join through your invite to unlock it." or "The invite window could not open. Please try again."
		else
			v6.Text = "Invites are unavailable here. Try the published game."
		end
	end)
end)
v5.Activated:Connect(function()
	if not v8 or os.clock() - now2 < 1 then
		return
	end

	now2 = os.clock()

	if v7.loaded and v7.owned.BalloonDagger then
		if v7.equipped ~= "BalloonDagger" then
			armoryEvent:FireServer("Equip", "BalloonDagger")
		end
	else
		armoryEvent:FireServer("CheckRewards")
		v6.Text = "Not yet — your invited friend needs to join. It unlocks automatically."
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and v8 and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(frame) then
			GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
		end

		v8 = false
		frame.Visible = false
		localPlayer:SetAttribute("BalloonOfferOpen", false)
	end
end)
local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
	if v8 and not permitted() then
		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(frame) then
			GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
		end

		v8 = false
		frame.Visible = false
		localPlayer:SetAttribute("BalloonOfferOpen", false)
	end

	if not v8 then
		return
	end

	local absoluteSize = screenGui.AbsoluteSize
	uIScale.Scale = math.min(1, (absoluteSize.X - 28) / 560, (absoluteSize.Y - 28) / 430)
	total += math.min(dt, 0.1) * 0.25
	camera.CFrame = CFrame.lookAt(
		Vector3.new(math.sin(total) * v2 * 1.9, v2 * 0.08, math.cos(total) * v2 * 1.9),
		createVector(0, 0, 0)
	)
end)
task.spawn(function()
	task.wait(5)

	while screenGui.Parent and not v9 do
		if permitted() and v7.loaded and localPlayer:GetAttribute("ArmoryOpen") ~= true and localPlayer:GetAttribute("ServerBrowserOpen") ~= true and localPlayer:GetAttribute("MatchSummaryVisible") ~= true then
			v9 = true

			if not v7.owned.BalloonDagger and permitted() then
				if not v8 then
					selectedObject = GuiService.SelectedObject
				end

				v8 = true
				frame.Visible = true
				localPlayer:SetAttribute("BalloonOfferOpen", true)
				armoryEvent:FireServer("Get")
				update()

				if UserInputService.GamepadEnabled then
					GuiService.SelectedObject = v7.owned.BalloonDagger and v5 or v4
				end
			end
		end

		task.wait(1)
	end
end)
armoryEvent:FireServer("Get")
script.Destroying:Connect(function()
	renderSteppedConnection:Disconnect()
	localPlayer:SetAttribute("BalloonOfferOpen", nil)
	screenGui:Destroy()
end)