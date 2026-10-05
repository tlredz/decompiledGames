local createVector = vector.create
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local ValleyPanels = require(chickenOrHero.Presentation:WaitForChild("ValleyPanels"))
local SkinCatalog = require(chickenOrHero.Weapons:WaitForChild("SkinCatalog"))
local Icon = require(script.Parent.TopbarPlus.Icon)
local questEvent = chickenOrHero.Quests:WaitForChild("QuestEvent")
local screen = ValleyPanels.screen(localPlayer, "ValleyQuests", 74)
screen.IgnoreGuiInset = true
screen.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
local panel, v, v2 = ValleyPanels.panel(screen, "QuestPanel", 560, 600)
local align = Icon.new():setName("ValleyQuests"):setLabel("QUESTS"):align("Left")

local function label(p, p2, p3, p4, p5, p6, p7, p8, p9)
	local text = ValleyPanels.text(p, p2, p3, p4, p5, p6, p7, 16, p8)
	text.TextScaled = true
	text.TextWrapped = false
	text.TextTruncate = Enum.TextTruncate.AtEnd

	if p9 then
		text.Font = Enum.Font.GothamBold
	end

	return text
end

local paper = ValleyPanels.Paper
local text = ValleyPanels.text(v, "Heading", "QUESTS", 22, 18, 445, 36, 16, paper)
text.TextScaled = true
text.TextWrapped = false
text.TextTruncate = Enum.TextTruncate.AtEnd
text.Font = Enum.Font.GothamBold
local gold = ValleyPanels.Gold
local text2 = ValleyPanels.text(v, "Timer", "Checking quests...", 22, 63, 516, 23, 16, gold)
text2.TextScaled = true
text2.TextWrapped = false
text2.TextTruncate = Enum.TextTruncate.AtEnd
text2.Font = Enum.Font.GothamBold
local muted = ValleyPanels.Muted
local text3 = ValleyPanels.text(v, "Subtitle", "", 22, 88, 516, 24, 16, muted)
text3.TextScaled = true
text3.TextWrapped = false
text3.TextTruncate = Enum.TextTruncate.AtEnd
local v3 = ValleyPanels.make("ScrollingFrame", v, "QuestList", {
	Position = UDim2.fromOffset(16, 123),
	Size = UDim2.fromOffset(528, 413),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = ValleyPanels.Gold,
	CanvasSize = UDim2.fromOffset(0, 0),
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ClipsDescendants = true
})
local muted2 = ValleyPanels.Muted
local text4 = ValleyPanels.text(v, "Footer", "", 22, 551, 516, 25, 16, muted2)
text4.TextScaled = true
text4.TextWrapped = false
text4.TextTruncate = Enum.TextTruncate.AtEnd
local v4 = nil
local mode = nil
local now = 0
local flag = false
local flag2 = true
local v5 = 1
local fn
local v6 = {}
local v7 = {}
local v8 = false
local count = 0
local fn2
local connections = {}
local connections2 = {}
local v9 = {}

local function connect(object, p)
	local connection = object:Connect(p)
	table.insert(connections, connection)
	return connection
end

local function refreshQuestIcon()
	local v10 = UserInputService.PreferredInput == Enum.PreferredInput.Touch
	align:setLabel(v10 and "" or "QUESTS")

	if v10 then
		align:setImage("rbxassetid://91418213056329")
	else
		align:modifyTheme({ "IconImage", "Image", "" })
	end
end

table.insert(connections, (UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(refreshQuestIcon)))
refreshQuestIcon()

-- equivalent calls inferred from this helper; original call sites unknown
local function action(p, id)
	questEvent:FireServer(p, id)
	task.delay(3, function()
		if flag2 then
			fn2()
		end
	end)
end

local function celebrate()
	TweenService:Create(text, TweenInfo.new(0.18), {
		TextColor3 = ValleyPanels.Gold
	}):Play()
	task.delay(1.2, function()
		if flag2 then
			TweenService:Create(text, TweenInfo.new(0.5), {
				TextColor3 = ValleyPanels.Paper
			}):Play()
		end
	end)
	local SoundService = game:GetService("SoundService")
	local gameAudio = SoundService:FindFirstChild("GameAudio")
	local _04_UI = gameAudio and gameAudio:FindFirstChild("04_UI")
	local notice = _04_UI and _04_UI:FindFirstChild("Notice")

	if notice and notice:IsA("Sound") then
		local clone = notice:Clone()
		clone.Volume = 0.35
		clone.Looped = false
		clone.Parent = screen
		clone:Play()
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 3)
	end
end

local function skipPrice(skipProductId)
	if (v6[skipProductId] == nil or v6[skipProductId] == false and os.clock() >= (v9[skipProductId] or 0)) and not v7[skipProductId] then
		v7[skipProductId] = true
		task.spawn(function()
			local success, productInfoAsync = pcall(
				MarketplaceService.GetProductInfoAsync,
				MarketplaceService,
				skipProductId,
				Enum.InfoType.Product
			)
			local v10 = v6
			local v12

			if success and type(productInfoAsync) == "table" and productInfoAsync.IsForSale and type(productInfoAsync.PriceInRobux) == "number" then
				v12 = productInfoAsync.PriceInRobux or false
			else
				v12 = false
			end

			v10[skipProductId] = v12
			v7[skipProductId] = nil
			v9[skipProductId] = os.clock() + 30

			if flag2 and v4 then
				fn()
			end
		end)
	end

	return v6[skipProductId]
end

local function countdown(p)
	local v10 = math.max(0, (math.floor(p)))
	local v11 = math.floor(v10 / 86400)
	local v12 = math.floor(v10 % 86400 / 3600)
	local v13 = math.floor(v10 % 3600 / 60)
	local v14 = v10 % 60

	if v11 > 0 then
		return string.format("%dd %dh %dm", v11, v12, v13)
	end

	if v12 > 0 then
		return string.format("%dh %dm", v12, v13)
	end

	return string.format("%dm %02ds", v13, v14)
end

local function updateTimer()
	if not v4 then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	if v4.mode == "Daily" and v4.daily then
		text2.Text = "RESETS IN " .. countdown(v4.daily.resetsAt - serverTimeNow)
	elseif v4.event then
		local event = v4.event

		if event.phase == "Upcoming" then
			text2.Text = "STARTS IN " .. countdown(event.startsAt - serverTimeNow)
		elseif event.phase == "Active" then
			text2.Text = "ENDS IN " .. countdown(event.endsAt - serverTimeNow)
		else
			text2.Text = "THIS EVENT HAS ENDED"
		end
	end

	if v4.event and (v4.event.phase == "Upcoming" and v4.event.startsAt <= serverTimeNow or v4.event.phase == "Active" and v4.event.endsAt <= serverTimeNow) and not flag then
		fn2()
	end

	if v4.mode == "Daily" and v4.daily and v4.daily.resetsAt <= serverTimeNow and not flag then
		fn2()
	end
end

local function clearCards()
	for _, connection in connections2 do
		connection:Disconnect()
	end

	table.clear(connections2)

	for _, child in v3:GetChildren() do
		child:Destroy()
	end
end

local function preview(p, id)
	local v10 = SkinCatalog.get(id)
	local child = v10 and chickenOrHero.Weapons.Models:FindFirstChild(v10.Model)
	local blade = child and child:FindFirstChild("Blade")

	if not (blade and blade:IsA("BasePart")) then
		return
	end

	local v11 = ValleyPanels.make("ViewportFrame", p, "WeaponPreview", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.08, 0.02),
		Size = UDim2.fromScale(0.84, 0.62),
		Ambient = Color3.fromRGB(200, 210, 225),
		LightColor = Color3.new(1, 1, 1),
		LightDirection = createVector(-1, -1, -1),
		Active = false
	})
	local v12 = ValleyPanels.make("WorldModel", v11, "Display", {})
	local parent = ValleyPanels.make("Model", v12, "Knife", {})
	local clone = blade:Clone()
	clone.Transparency = 0
	clone.CFrame = child:GetAttribute("PreviewRotation") or CFrame.identity
	clone.Anchored = true
	clone.CanCollide = false
	clone.Parent = parent

	for _, descendant in clone:GetDescendants() do
		if not (descendant:IsA("LuaSourceContainer") or descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint")) then
			continue
		end

		descendant:Destroy()
	end

	local _, v14 = parent:GetBoundingBox()
	local currentCamera = ValleyPanels.make("Camera", v11, "PreviewCamera", {
		FieldOfView = 35
	})
	v11.CurrentCamera = currentCamera

	local function fit()
		local absoluteSize = v11.AbsoluteSize
		local v16 = absoluteSize.Y > 0 and absoluteSize.X / absoluteSize.Y or 1
		local v17 = math.max(v14.Y, v14.X / math.max(0.1, v16)) / (math.tan((math.rad(currentCamera.FieldOfView / 2))) * 2) + v14.Z / 2
		currentCamera.CFrame = CFrame.lookAt(Vector3.new(0, 0, v17 * 1.12), createVector(0, 0, 0))
	end

	table.insert(connections2, v11:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit))
	fit()
end

local function dailyCard(quest, k)
	local v10 = (k - 1) * 105
	local v11 = ValleyPanels.make("Frame", v3, quest.id, {
		Position = UDim2.fromOffset(0, v10),
		Size = UDim2.fromOffset(512, 97),
		BackgroundColor3 = Color3.fromRGB(25, 39, 53),
		BorderSizePixel = 0
	})
	ValleyPanels.corner(v11, 10)
	ValleyPanels.stroke(
		v11,
		quest.claimed and ValleyPanels.Muted or quest.complete and ValleyPanels.Gold or ValleyPanels.Blue,
		0.55
	)
	local text5 = quest.text
	local paper2 = ValleyPanels.Paper
	local text6 = ValleyPanels.text(v11, "Title", text5, 14, 11, 355, 24, 16, paper2)
	text6.TextScaled = true
	text6.TextWrapped = false
	text6.TextTruncate = Enum.TextTruncate.AtEnd
	text6.Font = Enum.Font.GothamBold
	local v12 = quest.rewardCurrency == "gems" and "◆ " .. quest.rewardAmount .. " GEMS" or "◉ " .. quest.rewardAmount .. " COINS"
	local gold2 = ValleyPanels.Gold
	local text7 = ValleyPanels.text(v11, "Reward", v12, 374, 11, 122, 22, 16, gold2)
	text7.TextScaled = true
	text7.TextWrapped = false
	text7.TextTruncate = Enum.TextTruncate.AtEnd
	text7.Font = Enum.Font.GothamBold
	text7.TextXAlignment = Enum.TextXAlignment.Right
	local v13 = string.format("%d / %d", quest.progress, quest.target)
	local muted3 = ValleyPanels.Muted
	local text8 = ValleyPanels.text(v11, "Progress", v13, 14, 44, 112, 19, 16, muted3)
	text8.TextScaled = true
	text8.TextWrapped = false
	text8.TextTruncate = Enum.TextTruncate.AtEnd
	local v14 = ValleyPanels.make("Frame", v11, "ProgressTrack", {
		Position = UDim2.fromOffset(14, 72),
		Size = UDim2.fromOffset(340, 9),
		BackgroundColor3 = Color3.fromRGB(55, 69, 77),
		BorderSizePixel = 0
	})
	ValleyPanels.corner(v14, 4)
	local v15 = ValleyPanels.make("Frame", v14, "Fill", {
		Size = UDim2.fromScale(math.clamp(quest.progress / quest.target, 0, 1), 1),
		BackgroundColor3 = ValleyPanels.Gold,
		BorderSizePixel = 0
	})
	ValleyPanels.corner(v15, 4)
	local v16 = quest.claimed and "CLAIMED" or quest.complete and "CLAIM" or "IN PROGRESS"
	local button = ValleyPanels.button(
		v11,
		"Claim",
		v16,
		373,
		47,
		123,
		38,
		quest.complete and not quest.claimed and Color3.fromRGB(78, 118, 91) or Color3.fromRGB(49, 65, 73)
	)
	button.TextScaled = true
	button.Active = quest.complete and not quest.claimed and v4.loaded

	if button.Active then
		button.Activated:Connect(function()
			if not button.Active then
				return
			end

			button.Active = false
			button.Text = "CLAIMING..."
			action("ClaimDaily", quest.id) -- equivalent call inferred; original call site unknown
		end)
	end
end

local function eventDetail(data)
	local v10 = ValleyPanels.make("Frame", v3, "SelectedWeapon", {
		Position = UDim2.fromOffset(0, 140),
		Size = UDim2.fromOffset(512, 268),
		BackgroundColor3 = Color3.fromRGB(25, 39, 53),
		BorderSizePixel = 0
	})
	ValleyPanels.corner(v10, 10)
	ValleyPanels.stroke(v10, data.claimable and ValleyPanels.Gold or ValleyPanels.Blue, 0.55)
	local name = data.name
	local paper2 = ValleyPanels.Paper
	local text5 = ValleyPanels.text(v10, "Name", name, 14, 10, 310, 27, 16, paper2)
	text5.TextScaled = true
	text5.TextWrapped = false
	text5.TextTruncate = Enum.TextTruncate.AtEnd
	text5.Font = Enum.Font.GothamBold
	local v11 = data.claimed and "UNLOCKED" or data.locked and "LOCKED" or data.claimable and "READY TO CLAIM" or "IN PROGRESS"
	local gold2 = data.claimable and ValleyPanels.Gold or ValleyPanels.Muted
	local text6 = ValleyPanels.text(v10, "Status", v11, 333, 12, 164, 23, 16, gold2)
	text6.TextScaled = true
	text6.TextWrapped = false
	text6.TextTruncate = Enum.TextTruncate.AtEnd
	text6.Font = Enum.Font.GothamBold
	text6.TextXAlignment = Enum.TextXAlignment.Right
	local bonus = data.bonus
	local v12 = "+" .. bonus.Amount .. " " .. string.upper(bonus.Currency) .. " PER MATCH WHILE EQUIPPED"
	local gold3 = ValleyPanels.Gold
	local text7 = ValleyPanels.text(v10, "Bonus", v12, 14, 42, 480, 22, 16, gold3)
	text7.TextScaled = true
	text7.TextWrapped = false
	text7.TextTruncate = Enum.TextTruncate.AtEnd
	text7.Font = Enum.Font.GothamBold

	for k, quest in data.quests do
		local v13 = 70 + (k - 1) * 48
		local gold4 = quest.complete and ValleyPanels.Gold or data.locked and ValleyPanels.Muted or ValleyPanels.Paper
		local v14 = "Quest" .. k
		local v15 = (quest.complete and "✓ " or "• ") .. quest.text
		local complete = quest.complete
		local text8 = ValleyPanels.text(v10, v14, v15, 14, v13, 480, 23, 16, gold4)
		text8.TextScaled = true
		text8.TextWrapped = false
		text8.TextTruncate = Enum.TextTruncate.AtEnd

		if complete then
			text8.Font = Enum.Font.GothamBold
		end

		local v16 = string.format("%d/%d", quest.progress, quest.target)

		if quest.alternateTarget then
			v16 = string.format(
				"%d/%d OR %d/%d",
				quest.progress,
				quest.target,
				quest.alternateProgress or 0,
				quest.alternateTarget
			)
		end

		local v17 = "Count" .. k
		local v18 = v13 + 24
		local text9 = ValleyPanels.text(v10, v17, v16, 370, v18, 126, 17, 16, gold4)
		text9.TextScaled = true
		text9.TextWrapped = false
		text9.TextTruncate = Enum.TextTruncate.AtEnd
		text9.Font = Enum.Font.GothamBold
		text9.TextXAlignment = Enum.TextXAlignment.Right
		local v19 = ValleyPanels.make("Frame", v10, "QuestTrack" .. k, {
			Position = UDim2.fromOffset(14, v13 + 29),
			Size = UDim2.fromOffset(340, 7),
			BackgroundColor3 = Color3.fromRGB(55, 69, 77),
			BorderSizePixel = 0
		})
		ValleyPanels.corner(v19, 4)
		local v20 = quest.progress / quest.target

		if quest.alternateTarget then
			v20 = math.max(v20, (quest.alternateProgress or 0) / quest.alternateTarget)
		end

		local v21 = ValleyPanels.make("Frame", v19, "Fill", {
			Size = UDim2.fromScale(math.clamp(v20, 0, 1), 1),
			BackgroundColor3 = ValleyPanels.Gold,
			BorderSizePixel = 0
		})
		ValleyPanels.corner(v21, 4)
	end

	local v13 = data.claimed and "OWNED" or data.locked and "UNLOCK PREVIOUS" or data.claimable and "CLAIM KNIFE" or "COMPLETE QUESTS"
	local skipProductId = v4.event.skipProductId
	local v14 = (v4.event.skipCredits or 0) > 0
	local v15

	if skipProductId or v14 then
		v15 = v4.loaded and v4.event.claimsEnabled and not data.claimed and not (data.locked or data.claimable)
	else
		v15 = v14
	end

	local v16 = v15 and not v14 and skipPrice(skipProductId)

	if v15 then
		local v17 = type(v16) == "number" and utf8.char(57346) .. " " .. v16 or v16 == false and "UNAVAILABLE" or "..."
		local button = ValleyPanels.button(
			v10,
			"SkipQuests",
			v14 and "USE SAVED SKIP" or "SKIP " .. v17,
			14,
			224,
			238,
			34,
			Color3.fromRGB(105, 72, 133)
		)
		button.TextScaled = true
		local active

		if v14 or type(v16) == "number" then
			active = not v8
		else
			active = false
		end

		button.Active = active
		button.Activated:Connect(function()
			if not button.Active then
				return
			end

			v8 = not v14
			count += 1
			local v19 = count
			button.Active = false
			button.Text = "OPENING..."
			action(v14 and "RedeemSkipCredit" or "PromptSkip", data.id) -- equivalent call inferred; original call site unknown
			task.delay(8, function()
				if flag2 and count == v19 then
					v8 = false
					fn2()
					fn()
				end
			end)
		end)
	end

	local button = ValleyPanels.button(
		v10,
		"Claim",
		v13,
		v15 and 260 or 14,
		224,
		v15 and 238 or 484,
		34,
		data.claimable and Color3.fromRGB(78, 118, 91) or Color3.fromRGB(49, 65, 73)
	)
	button.TextScaled = true
	button.Active = data.claimable and v4.loaded and v4.event.claimsEnabled

	if button.Active then
		button.Activated:Connect(function()
			if not button.Active then
				return
			end

			button.Active = false
			button.Text = "CLAIMING..."
			action("ClaimEvent", data.id) -- equivalent call inferred; original call site unknown
		end)
	end
end

local function eventCards()
	local weapons = v4.event.weapons
	v5 = math.clamp(v5, 1, #weapons)

	for k, weapon in weapons do
		local v10 = (k - 1) * 172
		local v11 = k == v5
		local v12 = ValleyPanels.make("TextButton", v3, weapon.id, {
			Position = UDim2.fromOffset(v10, 0),
			Size = UDim2.fromOffset(164, 130),
			BackgroundColor3 = v11 and Color3.fromRGB(44, 65, 76) or Color3.fromRGB(25, 39, 53),
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = true
		})
		ValleyPanels.corner(v12, 10)
		ValleyPanels.stroke(
			v12,
			v11 and ValleyPanels.Gold or weapon.claimed and ValleyPanels.Muted or ValleyPanels.Blue,
			0.55
		)
		preview(v12, weapon.id)
		local name = weapon.name
		local paper2 = ValleyPanels.Paper
		local text5 = ValleyPanels.text(v12, "Name", name, 8, 84, 148, 19, 16, paper2)
		text5.TextScaled = true
		text5.TextWrapped = false
		text5.TextTruncate = Enum.TextTruncate.AtEnd
		text5.Font = Enum.Font.GothamBold
		text5.TextWrapped = true
		text5.TextTruncate = Enum.TextTruncate.None
		text5.TextXAlignment = Enum.TextXAlignment.Center
		local count2 = 0

		for _, quest in weapon.quests do
			if quest.complete then
				count2 += 1
			end
		end

		local v13 = weapon.claimed and "OWNED" or weapon.locked and "LOCKED" or string.format("%d / 3 QUESTS", count2)
		local gold2 = weapon.claimed and ValleyPanels.Gold or ValleyPanels.Muted
		local text6 = ValleyPanels.text(v12, "Status", v13, 8, 108, 148, 15, 16, gold2)
		text6.TextScaled = true
		text6.TextWrapped = false
		text6.TextTruncate = Enum.TextTruncate.AtEnd
		text6.Font = Enum.Font.GothamBold
		text6.TextXAlignment = Enum.TextXAlignment.Center
		local v14 = k
		v12.Activated:Connect(function()
			v5 = v14
			fn()
		end)
	end

	eventDetail(weapons[v5])
end

fn = function()
	if not v4 then
		return
	end

	clearCards()
	mode = v4.mode

	if v4.mode == "Daily" and v4.daily then
		text.Text = "QUESTS"
		text3.Text = "Complete and claim three quests each day."
		v3.ScrollingEnabled = true
		v3.CanvasSize = UDim2.fromOffset(0, 315)

		for k, quest in v4.daily.quests do
			dailyCard(quest, k)
		end

		text4.Text = v4.message or v4.loaded and "Daily quests reset at 00:00 UTC." or "Loading your quest progress..."
	else
		text.Text = "QUESTS"
		text3.Text = "Earn the three knives in order during this limited event."
		v3.ScrollingEnabled = false
		v3.CanvasSize = UDim2.fromOffset(0, 413)
		eventCards()
		text4.Text = v4.message or v4.loaded and "Complete all three quests, then claim each knife." or "Loading your collection..."
	end

	updateTimer()
end

fn2 = function()
	if flag then
		return
	end

	flag = true
	questEvent:FireServer("Get")
	task.delay(4, function()
		if flag2 then
			flag = false
		end
	end)
end

align:bindEvent("selected", function()
	local HudNavigation = require(chickenOrHero.Presentation.HudNavigation)
	HudNavigation.opening("Quests")
	panel.Visible = true
	fn2()
end)
align:bindEvent("deselected", function()
	panel.Visible = false
end)
table.insert(connections, (localPlayer:GetAttributeChangedSignal("QuestOpenRequestedAt"):Connect(function()
	align:select()
end)))
table.insert(connections, (v2.Activated:Connect(function()
	align:deselect()
end)))
table.insert(connections, (questEvent.OnClientEvent:Connect(function(p, p2)
	if p ~= "State" or type(p2) ~= "table" then
		return
	end

	local v10 = v4
	v4 = p2

	if v4.message then
		v8 = false
		count += 1
	end

	local flag3 = false

	if v10 and v10.loaded and v4.loaded then
		for k, weapon in v4.event.weapons do
			local weapon2 = v10.event.weapons[k]

			if not weapon.claimed or not weapon2 or weapon2.claimed then
				continue
			end

			flag3 = true
		end

		if v10.daily and v4.daily and v10.daily.day == v4.daily.day then
			for k, quest in v4.daily.quests do
				local quest2 = v10.daily.quests[k]

				if not quest.claimed or not quest2 or quest2.claimed then
					continue
				end

				flag3 = true
			end
		end
	end

	if v10 and v10.mode == "Event" and v4.mode == "Event" then
		local weapon = v10.event.weapons[v5]
		local weapon2 = v4.event.weapons[v5]

		if weapon and weapon2 and not weapon.claimed and weapon2.claimed then
			v5 = math.min(v5 + 1, #v4.event.weapons)
		end
	end

	now = os.clock()
	flag = false

	if panel.Visible or mode ~= v4.mode then
		fn()
	end

	if flag3 then
		celebrate()
	end
end)))
table.insert(connections, (MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, p2)
	if p == localPlayer.UserId and v4 and v4.event and p2 == v4.event.skipProductId then
		v8 = false
		count += 1

		if panel.Visible then
			fn2()
			fn()
		end
	end
end)))
local tick

tick = function()
	if not flag2 then
		return
	end

	if panel.Visible then
		updateTimer()

		if v4 and not v4.loaded and os.clock() - now > 2 then
			fn2()
		end
	elseif v4 and os.clock() - now > 90 then
		fn2()
	end

	task.delay(1, tick)
end

task.delay(1, tick)
script.Destroying:Connect(function()
	flag2 = false

	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
	clearCards()
	align:destroy()
	screen:Destroy()
end)