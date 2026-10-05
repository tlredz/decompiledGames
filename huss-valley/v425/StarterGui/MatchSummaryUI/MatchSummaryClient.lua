local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local game2 = chickenOrHero:WaitForChild("Game")
local presentation = chickenOrHero:WaitForChild("Presentation")
local session = game2:WaitForChild("Session")
local matchSummary = game2:WaitForChild("MatchSummary")
local MatchSummaryConfig = require(presentation:WaitForChild("MatchSummaryConfig"))
local panel = script.Parent:WaitForChild("Panel")
local close_2 = panel:WaitForChild("Close")
close_2.Modal = false
local backdrop = panel:WaitForChild("Backdrop")
backdrop.BackgroundTransparency = MatchSummaryConfig.BackdropTransparency
local presentationCues = chickenOrHero:WaitForChild("Audio"):WaitForChild("PresentationCues")

-- equivalent calls inferred from this helper; original call sites unknown
local function cue(p, p2)
	presentationCues:Fire(p, p2)
end

local RecapHighlights = require(presentation:WaitForChild("RecapHighlights"))
local v = RecapHighlights.new(panel, MatchSummaryConfig, cue)
local RecapRewards = require(presentation:WaitForChild("RecapRewards"))
local v2 = RecapRewards.new(panel.Personal, MatchSummaryConfig, cue, localPlayer)
local RecapSoloWin = require(presentation:WaitForChild("RecapSoloWin"))
local v3 = RecapSoloWin.new(panel:WaitForChild("SoloWin"), cue)
local v4 = {}
local flag = false
local v5 = false
local clone = nil
local v6 = nil
local shownAt = 0

for _, v8 in {
	panel,
	panel.Outcome,
	panel.StageTitle,
	panel.Personal,
	panel.Footer,
	panel.Close
} do
	v4[v8] = {
		Size = v8.Size,
		Position = v8.Position
	}
end

local clone2 = panel.StageTitle:Clone()
clone2.Name = "EventRewards"
clone2.Visible = false
clone2.Parent = panel

-- equivalent calls inferred from this helper; original call sites unknown
local function isAdminRecap(p)
	return p and (p.mode == "CrossyRoad" or p.mode == "DonkeyKong" or p.mode == "FFACatchers")
end

local function rewardLayout(visible)
	for k, v8 in v4 do
		k.Size = v8.Size
		k.Position = v8.Position
	end

	clone2.Visible = visible

	if not visible then
		return
	end

	local size = v4[panel].Size
	panel.Size = UDim2.fromScale(size.X.Scale, size.Y.Scale * 0.6)
	panel.Outcome.Position = UDim2.fromScale(0.055, 0.05)
	panel.Outcome.Size = UDim2.fromScale(0.89, 0.08)
	panel.StageTitle.Position = UDim2.fromScale(0.05, 0.15)
	panel.StageTitle.Size = UDim2.fromScale(0.9, 0.12)
	clone2.Position = UDim2.fromScale(0.055, 0.31)
	clone2.Size = UDim2.fromScale(0.89, 0.1)
	panel.Personal.Position = UDim2.fromScale(0.075, 0.48)
	panel.Personal.Size = UDim2.fromScale(0.85, 0.3)
	panel.Footer.Position = UDim2.fromScale(0.065, 0.9)
	panel.Footer.Size = UDim2.fromScale(0.5, 0.055)
	panel.Close.Position = UDim2.fromScale(0.67, 0.865)
	panel.Close.Size = UDim2.fromScale(0.265, 0.11)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function regularVisible(visible)
	for _, v8 in {
		"Outcome",
		"StageTitle",
		"Stage",
		"Tabs",
		"Personal"
	} do
		panel[v8].Visible = visible
	end
end

local function startMain(serverTimeNow)
	if flag then
		return
	end

	flag = true
	v3:hide()
	regularVisible(true) -- equivalent call inferred; original call site unknown

	if v5 then
		panel.Stage.Visible = false
		panel.Tabs.Visible = false
		cue("RecapOpen", nil) -- equivalent call inferred; original call site unknown
	else
		v:show(clone, serverTimeNow)
	end

	v2:show(v6, os.clock())
end

local v8 = nil
local matchId = nil
local v9 = nil
local v10 = nil
local count = 0
local v11 = true
local connections = {}
local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "MatchSummaryBlur"
blurEffect.Size = 0
blurEffect.Enabled = false
blurEffect.Parent = game:GetService("Lighting")
local v12 = nil

local function focusBackground(enabled, p)
	if v12 then
		v12:Cancel()
		v12 = nil
	end

	local size = not enabled and 0 or MatchSummaryConfig.BackgroundBlurSize or 8

	if p then
		blurEffect.Size = size
		blurEffect.Enabled = enabled
	else
		blurEffect.Enabled = true
		local tween = TweenService:Create(
			blurEffect,
			TweenInfo.new(
				enabled and MatchSummaryConfig.FadeIn or MatchSummaryConfig.FadeOut,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Size = size
			}
		)
		v12 = tween
		tween.Completed:Once(function(p2)
			if v12 == tween and p2 == Enum.PlaybackState.Completed then
				v12 = nil
				blurEffect.Enabled = enabled
			end
		end)
		tween:Play()
	end
end

local function close(p)
	count += 1
	local v13 = count
	matchId = nil
	v:hide()
	v2:hide()
	v3:hide()
	flag = false
	cue("RecapStop", nil) -- equivalent call inferred; original call site unknown
	localPlayer:SetAttribute("MatchSummaryVisible", nil)
	focusBackground(false, p)

	if v10 then
		v10:Cancel()
	end

	if p then
		panel.Visible = false
		panel.GroupTransparency = 1
	else
		v10 = TweenService:Create(panel, TweenInfo.new(MatchSummaryConfig.FadeOut), {
			GroupTransparency = 1
		})
		v10:Play()
		task.delay(MatchSummaryConfig.FadeOut, function()
			if v11 and count == v13 then
				panel.Visible = false
			end
		end)
	end
end

local function dismiss()
	if not matchId then
		return
	end

	v8 = matchId
	close(false)
end

local function read()
	if matchSummary.Value == "" then
		v9 = nil
		count += 1
		matchId = nil
		v:hide()
		v2:hide()
		v3:hide()
		flag = false
		cue("RecapStop", nil) -- equivalent call inferred; original call site unknown
		localPlayer:SetAttribute("MatchSummaryVisible", nil)

		if v12 then
			v12:Cancel()
			v12 = nil
		end

		blurEffect.Size = 0
		blurEffect.Enabled = false

		if v10 then
			v10:Cancel()
		end

		panel.Visible = false
		panel.GroupTransparency = 1
	else
		local success, result = pcall(game.HttpService.JSONDecode, game.HttpService, matchSummary.Value)

		if success and type(result) == "table" and result.version == 2 and type(result.matchId) == "string" and type(result.expiresAt) == "number" and type(result.shownAt) == "number" and type(result.result) == "string" and type(result.rankings) == "table" and type(result.participants) == "table" and not (#result.participants > MatchSummaryConfig.MaxParticipants) then
			if isAdminRecap(result) then
				local v13 = false

				for _, participant in result.participants do
					if participant.userId ~= localPlayer.UserId then
						continue
					end

					v13 = true
					break
				end

				if not v13 then
					v9 = nil
					count += 1
					matchId = nil
					v:hide()
					v2:hide()
					v3:hide()
					flag = false
					cue("RecapStop", nil) -- equivalent call inferred; original call site unknown
					localPlayer:SetAttribute("MatchSummaryVisible", nil)

					if v12 then
						v12:Cancel()
						v12 = nil
					end

					blurEffect.Size = 0
					blurEffect.Enabled = false

					if v10 then
						v10:Cancel()
					end

					panel.Visible = false
					panel.GroupTransparency = 1
					return
				end
			end

			v9 = result
		else
			v9 = nil
			count += 1
			matchId = nil
			v:hide()
			v2:hide()
			v3:hide()
			flag = false
			cue("RecapStop", nil) -- equivalent call inferred; original call site unknown
			localPlayer:SetAttribute("MatchSummaryVisible", nil)

			if v12 then
				v12:Cancel()
				v12 = nil
			end

			blurEffect.Size = 0
			blurEffect.Enabled = false

			if v10 then
				v10:Cancel()
			end

			panel.Visible = false
			panel.GroupTransparency = 1
		end
	end
end

local function update()
	local serverTimeNow = workspace:GetServerTimeNow()
	local v13 = v9

	if v13 then
		if v9.matchId == v8 or not (serverTimeNow < v9.expiresAt) or session:GetAttribute("Phase") ~= "Intermission" or localPlayer:GetAttribute("InMatch") == true or localPlayer:GetAttribute("InitialLoadingComplete") ~= true then
			v13 = false
		else
			v13 = localPlayer:GetAttribute("ScreenPresentationActive") ~= true
		end
	end

	if v13 then
		if matchId ~= v9.matchId then
			count += 1

			if v10 then
				v10:Cancel()
			end

			v:hide()
			v2:hide()
			v3:hide()
			flag = false
			matchId = v9.matchId
			panel.Visible = true
			panel.GroupTransparency = 1
			localPlayer:SetAttribute("MatchSummaryVisible", true)
			v5 = isAdminRecap(v9) == true
			rewardLayout(v5)
			focusBackground(not v5, false)
			local names = {}
			local v15 = nil

			for _, participant in v9.participants do
				if participant.userId == localPlayer.UserId then
					v15 = participant
				end

				if participant.won then
					table.insert(names, participant.name)
				end
			end

			panel.Outcome.Text = v9.result:find("CATCHERS WIN", 1, true) and "CATCHERS WIN" or v9.result:find(
				"RUNNERS WIN",
				1,
				true
			) and "RUNNERS WIN" or #names ~= 1 and "MATCH COMPLETE" or names[1] .. " WINS" or "MATCH COMPLETE"
			v6 = v15

			if v5 then
				panel.Outcome.Text = v9.mode == "FFACatchers" and "LAST ONE STANDING" or "YOUR REWARDS"
				local stageTitle = panel.StageTitle
				local text

				if v9.mode == "FFACatchers" then
					text = v9.lastStandingName or "No survivor"
				else
					text = v9.mode == "CrossyRoad" and "CROSSY ROADS" or "DONKEY KONG"
				end

				stageTitle.Text = text
				clone2.Text = v9.mode == "FFACatchers" and ("+%d COINS  ·  +%d GEMS"):format(
					not v15 and 0 or v15.eventCoins or 0,
					not v15 and 0 or v15.eventGems or 0
				) or not (v15 and v15.won) and "Finish the course to earn a 15-minute boost." or v9.mode == "CrossyRoad" and "2× COINS · 15 MINUTES" or "2× GEMS · 15 MINUTES"
			end

			local v16

			if not v5 then
				v16 = RecapSoloWin.winner(v9) or nil
			end

			shownAt = v9.shownAt + (v16 and MatchSummaryConfig.SoloWinSeconds or 0)
			clone = table.clone(v9)
			clone.shownAt = shownAt

			if v16 and serverTimeNow < shownAt then
				regularVisible(false) -- equivalent call inferred; original call site unknown
				v3:show(v16)
			else
				startMain(serverTimeNow)
			end

			v10 = TweenService:Create(
				panel,
				TweenInfo.new(MatchSummaryConfig.FadeIn, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					GroupTransparency = 0
				}
			)
			v10:Play()
		end

		if not flag and shownAt <= serverTimeNow then
			startMain(serverTimeNow)
		end

		panel.Footer.Text = ("NEXT MATCH · %ds"):format((math.max(0, (math.ceil(v9.expiresAt - serverTimeNow)))))
		local preferredInput = UserInputService.PreferredInput
		panel.Close.Text = preferredInput == Enum.PreferredInput.Touch and "CLOSE" or preferredInput == Enum.PreferredInput.Gamepad and "B / ○ · CLOSE" or "ENTER · CLOSE"
	elseif matchId then
		count += 1
		matchId = nil
		v:hide()
		v2:hide()
		v3:hide()
		flag = false
		cue("RecapStop", nil) -- equivalent call inferred; original call site unknown
		localPlayer:SetAttribute("MatchSummaryVisible", nil)

		if v12 then
			v12:Cancel()
			v12 = nil
		end

		blurEffect.Size = 0
		blurEffect.Enabled = false

		if v10 then
			v10:Cancel()
		end

		panel.Visible = false
		panel.GroupTransparency = 1
	end
end

panel.Visible = false
panel.GroupTransparency = 1
table.insert(connections, panel.Close.Activated:Connect(dismiss))
table.insert(connections, matchSummary.Changed:Connect(read))
ContextActionService:BindAction("CoHDismissRecap", function(_, p)
	if not matchId or UserInputService:GetFocusedTextBox() or game.GuiService.MenuIsOpen then
		return Enum.ContextActionResult.Pass
	end

	if p == Enum.UserInputState.Begin and matchId then
		v8 = matchId
		close(false)
	end

	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.Return, Enum.KeyCode.ButtonB)
local total = 0
table.insert(connections, RunService.RenderStepped:Connect(function(dt)
	total += dt

	if total >= 0.1 then
		total = 0
		update()
	end

	if matchId then
		v:update(workspace:GetServerTimeNow())
		v2:update(os.clock())
	end
end))
script.Destroying:Connect(function()
	v11 = false
	count += 1
	matchId = nil
	v:hide()
	v2:hide()
	v3:hide()
	flag = false
	cue("RecapStop", nil) -- equivalent call inferred; original call site unknown
	localPlayer:SetAttribute("MatchSummaryVisible", nil)

	if v12 then
		v12:Cancel()
		v12 = nil
	end

	blurEffect.Size = 0
	blurEffect.Enabled = false

	if v10 then
		v10:Cancel()
	end

	panel.Visible = false
	panel.GroupTransparency = 1
	v:destroy()
	v2:destroy()
	v3:destroy()

	for _, connection in connections do
		connection:Disconnect()
	end

	ContextActionService:UnbindAction("CoHDismissRecap")
	blurEffect:Destroy()
	clone2:Destroy()
end)
read()
update()