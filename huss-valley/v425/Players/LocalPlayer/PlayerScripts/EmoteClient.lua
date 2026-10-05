local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local emotes = chickenOrHero:WaitForChild("Emotes")
local emoteEvent = emotes:WaitForChild("EmoteEvent")
local EmoteCatalog = require(emotes.EmoteCatalog)
local EmotePlayback = require(emotes.EmotePlayback)
local HudNavigation = require(chickenOrHero.Presentation.HudNavigation)
local EmoteWheelView = require(chickenOrHero.Presentation.EmoteWheelView)
local ValleyTheme = require(chickenOrHero.Presentation.ValleyTheme)
local v, v2 = EmoteWheelView.build(playerGui)
local wheel = v.Shade.Wheel
local flag = false
local v3 = {
	owned = 0,
	loaded = false
}
v3.owned = {}
local v4 = 1
local clone = {}
local selectedObject = nil
local v5 = {
	"StarterPackOpen",
	"LikeRewardOpen",
	"CreatorPanelOpen",
	"CreatorUIHidden",
	"CreatorCameraActive",
	"MapVoteOpen",
	"ReleaseCameraForUI",
	"ScreenPresentationActive",
	"TutorialSession",
	"TutorialRouting",
	"AdminRefreshActive",
	"FairPlayNoticeOpen",
	"BalloonOfferOpen",
	"ConnectionQualityOpen",
	"MatchSummaryVisible",
	"AdminConsoleActive",
	"AnnouncementComposerOpen",
	"ChoiceSpotlightActive",
	"Spectating"
}

local function ready()
	if not EmoteCatalog.Enabled or localPlayer:GetAttribute("ClientReady") ~= true then
		return false
	end

	for _, attributeName in v5 do
		if localPlayer:GetAttribute(attributeName) == true then
			return false
		end
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function close()
	flag = false
	v.Shade.Visible = false
	localPlayer:SetAttribute("EmoteWheelOpen", nil)

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(v) then
		GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
	end
end

local function render()
	if EmoteCatalog.ComingSoon then
		clone = {}
		v4 = 1
		wheel.Center.EmoteName.Text = "COMING\nSOON"
		wheel.Center.EmoteName.Font = Enum.Font.GothamBold
		wheel.Center.EmoteName.TextSize = 20
		wheel.Center.Stop.Visible = false
		wheel.Previous.Visible = false
		wheel.Next.Visible = false
		wheel.Page.Visible = false
		wheel.Hint.Text = ""
		wheel.Status.Text = "New emotes are on the way."

		for _, v6 in v2 do
			v6.Visible = true
			v6.Active = false
			v6.Selectable = false
			v6.AutoButtonColor = false
			v6.Number.Text = ""
			v6.Caption.Text = "◇"
			v6.Caption.TextColor3 = ValleyTheme.Purple
			v6.Source.Text = ""
			v6.Border.Color = ValleyTheme.Purple
			v6.Border.Transparency = 0.8
		end
	else
		clone = table.clone(EmoteCatalog.Entries)
		table.sort(clone, function(a, b)
			local v6 = v3.owned[a.Id] or a.Route == "Starter"

			if v6 ~= (v3.owned[b.Id] or b.Route == "Starter") then
				return v6
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function order(p)
				for k, entry in EmoteCatalog.Entries do
					if entry.Id == p.Id then
						return k
					end
				end

				return 99
			end

			local v7 = order(a) -- equivalent call inferred; original call site unknown
			local v8 = order(b) -- equivalent call inferred; original call site unknown
			return v7 < v8
		end)
		local v6 = math.max(1, (math.ceil(#clone / 6)))
		v4 = math.clamp(v4, 1, v6)
		wheel.Page.Text = v4 .. " / " .. v6

		for k, v7 in v2 do
			local v8 = clone[(v4 - 1) * 6 + k]
			v7.Visible = v8 ~= nil

			if not v8 then
				continue
			end

			local v9 = v3.owned[v8.Id] or v8.Route == "Starter"
			v7.Caption.Text = v8.Name
			v7.Number.Text = v9 and tostring(k) or "◇"
			local source = v7.Source
			local text

			if v9 then
				text = not EmoteCatalog.available(v8.Id) and "AWAITING RELEASE" or v8.Route == "Starter" and "FREE FOR EVERYONE" or "IN YOUR COLLECTION"
			else
				text = v8.Route:upper() .. " JOURNEY · LV " .. v8.Level
			end

			source.Text = text
			v7.Caption.TextColor3 = v9 and ValleyTheme.Paper or ValleyTheme.Muted
			v7.Border.Color = v9 and ValleyTheme.Purple or ValleyTheme.Border
			v7.Border.Transparency = v9 and 0.4 or 0.7
		end
	end
end

local function choose(p)
	if EmoteCatalog.ComingSoon then
		return
	end

	local v6 = clone[(v4 - 1) * 6 + p]

	if not v6 then
		return
	end

	wheel.Center.EmoteName.Text = v6.Name

	if not v3.owned[v6.Id] and v6.Route ~= "Starter" then
		wheel.Status.Text = "Unlock at level " .. v6.Level .. " in the " .. v6.Route:lower() .. " Journey, then claim it."
		return
	end

	if not EmoteCatalog.available(v6.Id) then
		wheel.Status.Text = "This emote is awaiting release."
		return
	end

	emoteEvent:FireServer("Play", v6.Id)
	wheel.Status.Text = "Starting…"
end

local function toggle()
	if flag then
		close() -- equivalent call inferred; original call site unknown
	else
		if not ready() then
			return
		end

		HudNavigation.opening("Emotes")
		localPlayer:SetAttribute("SpectateRequestedExit", os.clock())
		selectedObject = GuiService.SelectedObject
		flag = true
		v.Shade.Visible = true
		localPlayer:SetAttribute("EmoteWheelOpen", true)
		wheel.Status.Text = ""
		render()
		EmoteWheelView.layout(v)
		emoteEvent:FireServer("Get")

		if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
			GuiService.SelectedObject = EmoteCatalog.ComingSoon and wheel.Close or v2[1]
		end
	end
end

v.Open.Activated:Connect(toggle)
wheel.Close.Activated:Connect(close)

for k, v6 in v2 do
	local v7 = k
	v6.Activated:Connect(function()
		choose(v7)
	end)
end

wheel.Previous.Activated:Connect(function()
	v4 = v4 <= 1 and math.ceil(#clone / 6) or v4 - 1
	render()
end)
wheel.Next.Activated:Connect(function()
	v4 = v4 % math.ceil(#clone / 6) + 1
	render()
end)
wheel.Center.Stop.Activated:Connect(function()
	emoteEvent:FireServer("Stop")
	close() -- equivalent call inferred; original call site unknown
end)
HudNavigation.Opening.Event:Connect(function(p)
	if p ~= "Emotes" then
		close() -- equivalent call inferred; original call site unknown
	end
end)
emoteEvent.OnClientEvent:Connect(function(p, p2)
	if p == "State" and type(p2) == "table" then
		v3 = p2
		render()

		if p2.message then
			wheel.Status.Text = p2.message
			HudNavigation.Notice:Fire(p2.message)
		end
	elseif p == "Playing" then
		close() -- equivalent call inferred; original call site unknown
	end
end)
local v6 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function clearPreview(p)
	local v7 = v6[p]
	v6[p] = nil

	if v7 then
		EmotePlayback.dispose(v7.track)
	end
end

local function cancel()
	local character = localPlayer.Character

	if character and character:GetAttribute("EmoteId") then
		emoteEvent:FireServer("Stop")
		clearPreview(character) -- equivalent call inferred; original call site unknown
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

		if animator then
			for _, v7 in animator:GetPlayingAnimationTracks() do
				if v7.Name:sub(1, 12) == "ValleyEmote_" then
					v7:Stop(0.08)
				end
			end
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if UserInputService:GetFocusedTextBox() then
		return
	end

	if flag and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
		close() -- equivalent call inferred; original call site unknown
	else
		if not gameProcessed and (input.KeyCode == Enum.KeyCode.G or input.KeyCode == Enum.KeyCode.DPadUp) then
			toggle()
			return
		end

		if flag and not gameProcessed then
			local v8 = ({
				[Enum.KeyCode.One] = 1,
				[Enum.KeyCode.Two] = 2,
				[Enum.KeyCode.Three] = 3,
				[Enum.KeyCode.Four] = 4,
				[Enum.KeyCode.Five] = 5,
				[Enum.KeyCode.Six] = 6
			})[input.KeyCode]

			if v8 then
				choose(v8)
			end
		end

		if not flag and not gameProcessed and (input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Space) then
			cancel()
		end
	end
end)
UserInputService.JumpRequest:Connect(cancel)
local total = 0
local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.1 then
		return
	end

	total = 0

	if flag and not ready() then
		close() -- equivalent call inferred; original call site unknown
	end

	local armoryOpen = localPlayer:GetAttribute("ArmoryOpen") or localPlayer:GetAttribute("JourneyOpen") or localPlayer:GetAttribute("SettingsOpen") or localPlayer:GetAttribute("UpdateLogOpen") or localPlayer:GetAttribute("ServerBrowserOpen")
	v.Open.Visible = ready() and not flag and not armoryOpen
	local valleyHUD = playerGui:FindFirstChild("ValleyHUD")
	local menuToggle = valleyHUD and valleyHUD:FindFirstChild("MenuToggle")

	if menuToggle then
		local absolutePosition = v.AbsolutePosition
		v.Open.Position = UDim2.fromOffset(
			menuToggle.AbsolutePosition.X - absolutePosition.X,
			menuToggle.AbsolutePosition.Y + menuToggle.AbsoluteSize.Y + 6 - absolutePosition.Y
		)
	end

	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.MoveDirection.Magnitude > 0.05 then
		cancel()
	end

	if RunService:IsStudio() and not EmoteCatalog.ComingSoon then
		local v7 = {}

		for _, v8 in Players:GetPlayers() do
			local character2 = v8.Character
			local emoteId = character2 and character2:GetAttribute("EmoteId")

			if not character2 or not emoteId or not EmoteCatalog.get(emoteId) or EmoteCatalog.assetId(emoteId) then
				continue
			end

			v7[character2] = true
			local v9 = v6[character2]
			local emoteStartedAt = character2:GetAttribute("EmoteStartedAt")

			if not (not v9 or v9.id ~= emoteId or v9.stamp ~= emoteStartedAt) then
				continue
			end

			clearPreview(character2) -- equivalent call inferred; original call site unknown
			local humanoid2 = character2:FindFirstChildOfClass("Humanoid")
			local animator = humanoid2 and humanoid2:FindFirstChildOfClass("Animator")

			if not animator then
				continue
			end

			local loaded = EmotePlayback.load(animator, emoteId)
			v6[character2] = {
				id = emoteId,
				stamp = emoteStartedAt,
				track = loaded
			}

			if loaded then
				loaded:Play(0.15)
			end
		end

		for k in v6 do
			if v7[k] then
				continue
			end

			clearPreview(k) -- equivalent call inferred; original call site unknown
		end
	end
end)
v:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	EmoteWheelView.layout(v)
end)
EmoteWheelView.layout(v)
render()
emoteEvent:FireServer("Get")
script.Destroying:Connect(function()
	heartbeatConnection:Disconnect()
	close() -- equivalent call inferred; original call site unknown

	for k in v6 do
		clearPreview(k) -- equivalent call inferred; original call site unknown
	end

	v:Destroy()
end)