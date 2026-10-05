local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local fx = require(ReplicatedStorage.shared.modules.fx)
local CrewController = require(ReplicatedStorage.client.legacyControllers.CrewController)
local crewEmblems = require(ReplicatedStorage.shared.modules.library.crewEmblems)
local CustomColorPicker = require(ReplicatedStorage.shared.modules.CustomColorPicker)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local items = require(ReplicatedStorage.shared.modules.library.items)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local CrewGoalsUI = require(ReplicatedStorage.client.modules.ui.CrewGoalsUI)
local _ = Players.LocalPlayer
local crews = HudController:GetSafeZone():WaitForChild("Crews")
local home = crews:WaitForChild("Home")
local crewList = crews:WaitForChild("CrewList")
local invite = crews:WaitForChild("Invite")
local customizeCrew = crews:WaitForChild("CustomizeCrew")
local close = crews:WaitForChild("Close")
local left = home:WaitForChild("Left")
local _Name = left:WaitForChild("_Name")
local icon = left:WaitForChild("Icon")
local edit = icon:WaitForChild("Edit")
local rating = left:WaitForChild("Rating")
local crewGoals = left:WaitForChild("CrewGoals")
local fill = crewGoals:WaitForChild("Fill")
local goal = crewGoals:WaitForChild("Goal")
local rewardIcon = crewGoals:WaitForChild("RewardIcon")
local rewardName = crewGoals:WaitForChild("RewardName")
local actions = left:WaitForChild("Actions")
local back = actions:WaitForChild("Back")
local leave = actions:WaitForChild("Leave")
local manageMembers = actions:WaitForChild("ManageMembers")
local whoCanJoin = actions:WaitForChild("WhoCanJoin")
local crewGoals2 = actions:WaitForChild("CrewGoals")
local right = home:WaitForChild("Right")
local list = right:WaitForChild("List")
local categories = list:WaitForChild("Categories")
local actions2 = categories:WaitForChild("Actions")
local server = categories:WaitForChild("Server")
local scrollingFrame = list:WaitForChild("ScrollingFrame")
local player = scrollingFrame:WaitForChild("Player")
local top = right:WaitForChild("Top")
local textBox = top:WaitForChild("Search"):WaitForChild("TextBox")
local refresh = top:WaitForChild("Refresh")
local invite2 = top:WaitForChild("Invite")
local members = top:WaitForChild("Members")
local container = invite:WaitForChild("Container")
local scrollingFrame2 = container:WaitForChild("List"):WaitForChild("ScrollingFrame")
local player2 = scrollingFrame2:WaitForChild("Player")
local top2 = container:WaitForChild("Top")
local textBox2 = top2:WaitForChild("Search"):WaitForChild("TextBox")
local submitSearch = top2:WaitForChild("SubmitSearch")
local back2 = top2:WaitForChild("Back")
local container2 = customizeCrew:WaitForChild("Container")
local contents = container2:WaitForChild("Contents")
local scrollingFrame3 = contents:WaitForChild("IconPresets"):WaitForChild("ScrollingFrame")
local icon2 = scrollingFrame3:WaitForChild("Icon")
local iconPreview = contents:WaitForChild("IconPreview")
local color = contents:WaitForChild("color")
local confirm = contents:WaitForChild("Confirm")
local back3 = container2:WaitForChild("Top"):WaitForChild("Back")
local container3 = crewList:WaitForChild("Container")
local scrollingFrame4 = container3:WaitForChild("List"):WaitForChild("ScrollingFrame")
local clan = scrollingFrame4:WaitForChild("Clan")
local top3 = container3:WaitForChild("Top")
local textBox3 = top3:WaitForChild("Search"):WaitForChild("TextBox")
local submitSearch2 = top3:WaitForChild("SubmitSearch")
local ratingReset = top3:WaitForChild("RatingReset")
local header = crews:WaitForChild("Header")
local leaderboard = header:WaitForChild("IgnoreList"):WaitForChild("Header2"):WaitForChild("Leaderboard")
local back4 = header:WaitForChild("IgnoreList"):WaitForChild("Header2"):WaitForChild("Back")
local createCrew = crews:WaitForChild("CreateCrew")
local container4 = createCrew:WaitForChild("Container")
local contents2 = container4:WaitForChild("Contents")
local textBox4 = contents2:WaitForChild("NameBox"):WaitForChild("TextBox")
local create = contents2:WaitForChild("Create")
local whoCanJoin2 = contents2:WaitForChild("WhoCanJoin")
local icon3 = contents2:WaitForChild("Icon")
local edit2 = icon3:WaitForChild("Edit")
local _Name2 = contents2:WaitForChild("_Name")
local back5 = container4:WaitForChild("Top"):WaitForChild("Back")
local ui = ReplicatedStorage.resources.sounds.sfx.ui
local anno_localthought = ReplicatedStorage.events.anno_localthought
local remoteEvent = Net:RemoteEvent("Crew/OpenUI")
local remoteEvent2 = Net:RemoteEvent("Crew/OpenLeaderboard")
local v = { "Anyone", "Friends", "Disabled" }
local v2 = {
	Anyone = "Anyone",
	Friends = "Friends Only",
	Disabled = "Nobody"
}
local v3 = {
	Anyone = Color3.fromRGB(161, 255, 192),
	Friends = Color3.fromRGB(255, 232, 139),
	Disabled = Color3.fromRGB(234, 116, 118)
}
local v4 = {
	Anyone = "Anyone can now join the crew.",
	Friends = "Switched to friends only.",
	Disabled = "Switched to nobody can join."
}
local color2 = Color3.fromRGB(255, 232, 139)
local color3 = Color3.fromRGB(160, 209, 255)
local color4 = Color3.fromRGB(255, 255, 255)
local color5 = Color3.fromRGB(157, 216, 255)
local color6 = Color3.fromRGB(255, 184, 108)
local color7 = Color3.fromRGB(255, 232, 139)
Color3.fromRGB(150, 150, 150)
local color8 = Color3.fromRGB(234, 116, 118)
local color9 = Color3.fromRGB(161, 255, 192)
local color10 = Color3.fromRGB(150, 150, 150)
local v5 = Trove.new()
local v6 = nil
local flag = false
local visible = false
local v8 = false
local v9 = 0
local v10 = 0
local v11 = 0
local v12 = 0
local refreshAll
local renderMembers
local updateSearch
local renderInvite
local v13 = nil
local renderCustomize
local presetId = nil
local v14 = {
	r = 255,
	g = 255,
	b = 255
}
local v15 = nil
local v16 = "edit"
local renderCreate
local resetCreate
local DEFAULT_ID = crewEmblems.DEFAULT_ID
local v17 = {
	r = 255,
	g = 255,
	b = 255
}
local v18 = "Anyone"

-- equivalent calls inferred from this helper; original call sites unknown
local function notify(p: string?)
	if p then
		anno_localthought:Fire(p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setManageMode(flag2: boolean)
	if visible == flag2 then
		return
	end

	visible = flag2
	CrewController.SetUIOpen(flag2)
end

local function loadSnapshot(callback, p: string?)
	local v19 = v9 + 1
	v9 = v19
	task.spawn(function()
		local fetched = CrewController.Fetch(p)

		if v19 ~= v9 then
			return
		end

		if fetched == nil then
			if callback then
				callback(nil)
			end
		else
			v6 = fetched

			if callback then
				callback(fetched)
			end
		end
	end)
end

local v19 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function resetConfirm(p)
	local v20 = v19[p]

	if not v20 then
		return
	end

	p.Text = v20.original
	v19[p] = nil
end

local function armConfirm(label, text: string, fn)
	local v20 = v19[label]

	if v20 and v20.ready then
		resetConfirm(label) -- equivalent call inferred; original call site unknown
		fn()
	else
		if v20 then
			return
		end

		local now = os.clock()
		v19[label] = {
			armed = true,
			ready = false,
			token = now,
			original = label.Text
		}
		label.Text = text
		task.delay(0.5, function()
			local v21 = v19[label]

			if v21 and v21.token == now then
				v21.ready = true
			end
		end)
		task.delay(2, function()
			local v21 = v19[label]

			if v21 and v21.token == now then
				resetConfirm(label) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function localRole()
	local pointer = CrewController.GetPointer()
	return pointer and pointer.Role
end

-- equivalent calls inferred from this helper; original call sites unknown
local function canManage()
	local v20 = localRole() -- equivalent call inferred; original call site unknown
	return v20 == "Founder" or v20 == "Officer"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function canManageTarget(role: string)
	local v20 = localRole() -- equivalent call inferred; original call site unknown

	if v20 == "Founder" then
		return role ~= "Founder"
	end

	return v20 == "Officer" and role == "Member"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyLeftButtons()
	if visible then
		back.Visible = true
		leave.Visible = false
		manageMembers.Visible = false
		whoCanJoin.Visible = false
		edit.Visible = false
		crewGoals2.Visible = false
	else
		back.Visible = false
		leave.Visible = true
		manageMembers.Visible = canManage()
		whoCanJoin.Visible = localRole() == "Founder"
		edit.Visible = localRole() == "Founder"
		crewGoals2.Visible = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rewardIconFor(p: string)
	local v20 = items.Items and items.Items[p] or fish[p]
	local icon4 = v20 and (v20.Icon or v20.Image)

	if typeof(icon4) == "string" then
		return icon4
	end

	return ""
end

local function renderCrewGoals()
	local v20 = v6
	local thresholds = v20 and v20.Thresholds

	if not thresholds or #thresholds == 0 then
		crewGoals.Visible = false
		return
	end

	crewGoals.Visible = true
	local season = v20.Rating.Season
	local threshold = thresholds[#thresholds]
	local v21 = 0
	local v22 = false

	for _, threshold2 in ipairs(thresholds) do
		if season < v21 + threshold2.Rating then
			threshold = threshold2
			v22 = true
			break
		else
			v21 += threshold2.Rating
		end
	end

	if not v22 then
		v21 -= threshold.Rating
	end

	local v24 = math.max(threshold.Rating, 1)
	local v25 = math.clamp(season - v21, 0, v24)
	local v26 = v25 / v24
	fill.Size = UDim2.new(v26, 0, fill.Size.Y.Scale, fill.Size.Y.Offset)
	goal.Text = `{NumberUtils:Comma(v25)}/{NumberUtils:Comma(v24)}`
	local v27 = threshold.Rewards and threshold.Rewards[1]

	if v27 then
		local v28 = v27[2]
		local v29 = rewardName
		local text

		if #threshold.Rewards > 1 then
			text = `{v28} +{#threshold.Rewards - 1}` or v28
		else
			text = v28
		end

		v29.Text = text
		rewardIcon.Image = rewardIconFor(v28)
		rewardIcon.Visible = rewardIcon.Image ~= ""
	else
		rewardName.Text = ""
		rewardIcon.Visible = false
	end
end

local function renderHome()
	local v20 = v6

	if v20 then
		_Name.Text = v20.Name
		local v21 = crewEmblems.Get(v20.Emblem.PresetId)
		icon.Image = v21 and v21.Icon or ""
		local color11 = v20.Emblem.Color
		icon.ImageColor3 = Color3.fromRGB(color11.r, color11.g, color11.b)
		local container5 = rating:FindFirstChild("Container")

		if container5 then
			local rank = container5:FindFirstChild("Rank")
			local score = container5:FindFirstChild("Score")

			if rank and rank:IsA("TextLabel") then
				rank.Text = not v20.Rank and "Unranked" or `#{v20.Rank}` or "Unranked"
			end

			if score and score:IsA("TextLabel") then
				score.Text = NumberUtils:Comma(v20.Rating.Season)
			end
		end

		local label = whoCanJoin:FindFirstChild("Label")
		local uIStroke = whoCanJoin:FindFirstChild("UIStroke")
		local whoCanJoin3 = v20.WhoCanJoin
		local v22 = v3[whoCanJoin3] or v3.Anyone

		if label and label:IsA("TextLabel") then
			label.Text = v2[whoCanJoin3] or "Anyone"
			label.TextColor3 = v22
		end

		if uIStroke and uIStroke:IsA("UIStroke") then
			uIStroke.Color = v22
		end

		renderCrewGoals()
		applyLeftButtons() -- equivalent call inferred; original call site unknown
	else
		_Name.Text = "No Crew"
		crewGoals.Visible = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function nextWhoCanJoin(p: string)
	local index = table.find(v, p) or 1
	return v[index % #v + 1]
end

local function wireHome()
	leave.Activated:Connect(function()
		if flag then
			return
		end

		fx:PlaySound(ui.click2, leave, false)
		local label = leave:FindFirstChild("Label")

		if label and label:IsA("TextLabel") then
			armConfirm(label, "[Click again to confirm]", function()
				if flag then
					return
				end

				flag = true
				local leave2 = CrewController.Leave()
				flag = false

				if leave2.success then
					anno_localthought:Fire("You left the crew.")
					v6 = nil
					setManageMode(false) -- equivalent call inferred; original call site unknown
					home.Visible = false
					invite.Visible = false
					customizeCrew.Visible = false
					crewList.Visible = false
					resetCreate()
					renderCreate()
					createCrew.Visible = true
					leaderboard.Visible = false
				else
					notify(leave2.error) -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end)
	whoCanJoin.Activated:Connect(function()
		if flag or not v6 then
			return
		end

		flag = true
		fx:PlaySound(ui.click2, whoCanJoin, false)
		local whoCanJoin3 = nextWhoCanJoin(v6.WhoCanJoin) -- equivalent call inferred; original call site unknown
		local v21 = CrewController.SetWhoCanJoin(whoCanJoin3)
		flag = false

		if v21.success then
			v6.WhoCanJoin = whoCanJoin3
			renderHome()
			notify(v4[whoCanJoin3]) -- equivalent call inferred; original call site unknown
		else
			notify(v21.error) -- equivalent call inferred; original call site unknown
		end
	end)
	manageMembers.Activated:Connect(function()
		fx:PlaySound(ui.click2, manageMembers, false)
		setManageMode(true) -- equivalent call inferred; original call site unknown
		applyLeftButtons() -- equivalent call inferred; original call site unknown
		renderMembers()
	end)
	back.Activated:Connect(function()
		fx:PlaySound(ui.click2, back, false)
		setManageMode(false) -- equivalent call inferred; original call site unknown
		applyLeftButtons() -- equivalent call inferred; original call site unknown
		renderMembers()
	end)
	invite2.Activated:Connect(function()
		local now = os.clock()

		if now - v12 < 0.6 then
			return
		end

		v12 = now
		fx:PlaySound(ui.click2, invite2, false)
		home.Visible = false
		crewList.Visible = false
		invite.Visible = true
		renderInvite()
	end)
	edit.Activated:Connect(function()
		if localRole() ~= "Founder" then
			return
		end

		fx:PlaySound(ui.click2, edit, false)
		v16 = "edit"
		home.Visible = false
		crewList.Visible = false
		invite.Visible = false
		customizeCrew.Visible = true
		renderCustomize()
	end)
	crewGoals2.Activated:Connect(function()
		fx:PlaySound(ui.click2, crewGoals2, false)
		crews.Visible = false
		CrewGoalsUI:Open()
	end)
end

local maid = Trove.new()
local maid2 = Trove.new()
local v20 = nil
local v21 = 0
local flag2 = false

local function buildClanRow(data)
	local clone = clan:Clone()
	clone.Name = data.CrewId
	clone.Visible = true
	local player3 = clone:FindFirstChild("Player")

	if player3 then
		local headshot = player3:FindFirstChild("Headshot")

		if headshot and headshot:IsA("ImageLabel") then
			local v22 = crewEmblems.Get(data.Emblem.PresetId)
			headshot.Image = v22 and v22.Icon or ""
			local color11 = data.Emblem.Color
			headshot.ImageColor3 = Color3.fromRGB(color11.r, color11.g, color11.b)
		end

		local label = player3:FindFirstChild("Label")

		if label and label:IsA("TextLabel") then
			label.Text = data.Name
		end
	end

	local rating2 = clone:FindFirstChild("Rating")

	if rating2 then
		local rank = rating2:FindFirstChild("Rank")
		local score = rating2:FindFirstChild("Score")

		if rank and rank:IsA("TextLabel") then
			rank.Text = not data.Rank and "Unranked" or `#{data.Rank}` or "Unranked"
		end

		if score and score:IsA("TextLabel") then
			score.Text = NumberUtils:Comma(data.Rating)
		end
	end

	local members2 = clone:FindFirstChild("Members")

	if members2 then
		local label = members2:FindFirstChild("Label")

		if label and label:IsA("TextLabel") then
			label.Text = `{data.MemberCount}/{data.Capacity}`
		end
	end

	local actions3 = clone:FindFirstChild("Actions")

	if actions3 then
		local action = actions3:FindFirstChild("Action")

		if action and action:IsA("GuiButton") then
			local isInCrew = CrewController.IsInCrew()
			local label = action:FindFirstChild("Label")
			local uIStroke = action:FindFirstChild("UIStroke")

			if isInCrew then
				action.Active = false
				action.AutoButtonColor = false

				if label and label:IsA("TextLabel") then
					label.TextColor3 = color10
				end

				if uIStroke and uIStroke:IsA("UIStroke") then
					uIStroke.Color = color10
				end
			else
				action.Active = true
				action.AutoButtonColor = true
				maid:Add(action.Activated:Connect(function()
					if flag then
						return
					end

					flag = true
					fx:PlaySound(ui.click2, action, false)
					local join = CrewController.RequestJoin(data.CrewId)
					flag = false

					if join.success then
						notify(`Requested to join {data.Name}.`) -- equivalent call inferred; original call site unknown
					else
						notify(join.error) -- equivalent call inferred; original call site unknown
					end
				end))
			end
		end
	end

	clone.Parent = scrollingFrame4
	maid:Add(clone)
	return clone
end

local function updateCrewListSearch()
	local v22 = textBox3.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")

	for _, guiObject in ipairs(scrollingFrame4:GetChildren()) do
		if not (guiObject:IsA("GuiObject") and guiObject ~= clan) then
			continue
		end

		local player3 = guiObject:FindFirstChild("Player")
		local label = player3 and player3:FindFirstChild("Label")

		if label and label:IsA("TextLabel") then
			guiObject.Visible = v22 == "" or label.Text:lower():find(v22, 1, true) ~= nil
		end
	end
end

local function renderCrewList(flag3: boolean?)
	local now = os.clock()

	if flag3 or not v20 or now - v21 >= 30 then
		local leaderboard2 = CrewController.GetLeaderboard(50)

		if #leaderboard2 > 0 then
			v20 = leaderboard2
			v21 = now
		end
	end

	maid:Clean()

	for _, guiObject in ipairs(scrollingFrame4:GetChildren()) do
		if guiObject:IsA("GuiObject") and guiObject ~= clan then
			guiObject:Destroy()
		end
	end

	for i, v22 in ipairs(v20 or {}) do
		local clanRow = buildClanRow(v22)

		if clanRow then
			clanRow.LayoutOrder = i
		end
	end

	updateCrewListSearch()
end

local function runCrewSearch()
	local v22 = textBox3.Text:gsub("^%s*(.-)%s*$", "%1")

	if v22 == "" then
		renderCrewList()
		return
	end

	if flag then
		return
	end

	flag = true
	fx:PlaySound(ui.click2, submitSearch2, false)
	task.spawn(function()
		local searchByName = CrewController.SearchByName(v22)
		maid:Clean()

		for _, guiObject in ipairs(scrollingFrame4:GetChildren()) do
			if guiObject:IsA("GuiObject") and guiObject ~= clan then
				guiObject:Destroy()
			end
		end

		if searchByName then
			local clanRow = buildClanRow(searchByName)

			if clanRow then
				clanRow.LayoutOrder = 1
			end
		else
			notify(`No crew found named "{v22}".`) -- equivalent call inferred; original call site unknown
		end

		flag = false
	end)
end

local function secondsUntilReset()
	local now = os.time()
	local v22 = os.date("!*t", now)
	local month = v22.month + 1
	local year = v22.year

	if month > 12 then
		year += 1
		month = 1
	end

	return (math.max(0, os.time({
		year = year,
		month = month,
		day = 1,
		hour = 0,
		min = 0,
		sec = 0
	}) - now))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatReset(p: number)
	local v22 = math.floor(p / 86400)
	local v23 = math.floor(p % 86400 / 3600)
	local v24 = math.floor(p % 3600 / 60)
	local v25 = math.floor(p % 60)
	return string.format("Rating Reset: %02d:%02d:%02d:%02d", v22, v23, v24, v25)
end

local function startResetCountdown()
	maid2:Clean()
	ratingReset.Text = formatReset(secondsUntilReset())
	maid2:Add(task.spawn(function()
		while true do
			task.wait(1)
			ratingReset.Text = formatReset(secondsUntilReset())
		end
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showCrewList()
	if flag2 then
		return
	end

	flag2 = true
	home.Visible = false
	invite.Visible = false
	customizeCrew.Visible = false
	createCrew.Visible = false
	crewList.Visible = true
	leaderboard.Visible = false
	back4.Visible = not v8
	textBox3.Text = ""
	renderCrewList()
	startResetCountdown()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideCrewList()
	if not flag2 then
		return
	end

	flag2 = false
	crewList.Visible = false
	back4.Visible = false
	leaderboard.Visible = true
	textBox3.Text = ""
	maid2:Clean()
	home.Visible = true
	refreshAll()
end

local function wireCrewList()
	leaderboard.Activated:Connect(function()
		if flag2 then
			return
		end

		local now = os.clock()

		if now - v11 < 0.6 then
			return
		end

		v11 = now
		fx:PlaySound(ui.click2, leaderboard, false)
		showCrewList() -- equivalent call inferred; original call site unknown
	end)
	back4.Activated:Connect(function()
		if not flag2 then
			return
		end

		fx:PlaySound(ui.click2, back4, false)
		hideCrewList() -- equivalent call inferred; original call site unknown
	end)
	submitSearch2.Activated:Connect(function()
		runCrewSearch()
	end)
	textBox3.FocusLost:Connect(function(flag3: boolean)
		if flag3 then
			runCrewSearch()
		end
	end)
end

local maid3 = Trove.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function applyRoleIcon(role, role2: string)
	if role2 == "Founder" then
		role.Visible = true
		role.Image = "rbxassetid://122869255597458"
		role.ImageColor3 = color2
	else
		if role2 ~= "Officer" then
			role.Visible = false
			return
		end

		role.Visible = true
		role.Image = "rbxassetid://86078349037634"
		role.ImageColor3 = color3
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function roleColor(role: string)
	if role == "Founder" then
		return color2
	elseif role == "Officer" then
		return color3
	end

	return color4
end

local function buildRow(userId: number, entry)
	local clone = player:Clone()
	clone.Name = tostring(userId)
	clone.Visible = true
	local player3 = clone:WaitForChild("Player")
	local headshot = player3:FindFirstChild("Headshot")

	if headshot and headshot:IsA("ImageLabel") then
		headshot.Image = `rbxthumb://type=AvatarHeadShot&id={userId}&w=180&h=180`
	end

	local label = player3:FindFirstChild("Label")

	if label and label:IsA("TextLabel") then
		label.Text = entry.Name
		local textColor = roleColor(entry.Role) -- equivalent call inferred; original call site unknown
		label.TextColor3 = textColor
	end

	local role = player3:FindFirstChild("Role")

	if role and role:IsA("ImageLabel") then
		applyRoleIcon(role, entry.Role) -- equivalent call inferred; original call site unknown
	end

	local rating2 = clone:FindFirstChild("Rating")

	if rating2 then
		local label2 = rating2:FindFirstChild("Label")

		if label2 and label2:IsA("TextLabel") then
			label2.Text = NumberUtils:Comma(entry.Rating or 0)
		end
	end

	local server2 = clone:FindFirstChild("Server")
	local actions3 = clone:FindFirstChild("Actions")

	if server2 then
		server2.Visible = not visible
	end

	if actions3 then
		actions3.Visible = visible
	end

	if visible then
		if actions3 then
			local kick = actions3:FindFirstChild("Kick")
			local promoteOrDemote = actions3:FindFirstChild("PromoteOrDemote")
			local label2 = promoteOrDemote and promoteOrDemote:FindFirstChild("Label")
			local uIStroke = promoteOrDemote and promoteOrDemote:FindFirstChild("UIStroke")
			local v22 = entry.Role == "Officer"
			local v23 = v22 and color6 or color5
			local visible2 = localRole() == "Founder"

			if promoteOrDemote and promoteOrDemote:IsA("GuiObject") then
				promoteOrDemote.Visible = visible2
			end

			if label2 and label2:IsA("TextLabel") then
				label2.Text = v22 and "Demote" or "Promote"
				label2.TextColor3 = v23
			end

			if uIStroke and uIStroke:IsA("UIStroke") then
				uIStroke.Color = v23
			end

			if kick then
				maid3:Add(kick.Activated:Connect(function()
					if flag then
						return
					end

					fx:PlaySound(ui.click2, kick, false)
					local label3 = kick:FindFirstChild("Label")

					if label3 and label3:IsA("TextLabel") then
						armConfirm(label3, "Sure?", function()
							if flag then
								return
							end

							flag = true
							local v25 = CrewController.Kick(userId)
							flag = false

							if v25.success then
								notify(`Removed {entry.Name} from the crew.`) -- equivalent call inferred; original call site unknown
								v6.Members[tostring(userId)] = nil
								v6.MemberCount = math.max((v6.MemberCount or 1) - 1, 0)
								renderMembers()
							else
								notify(v25.error) -- equivalent call inferred; original call site unknown
							end
						end)
					end
				end))
			end

			if promoteOrDemote then
				maid3:Add(promoteOrDemote.Activated:Connect(function()
					if flag then
						return
					end

					flag = true
					fx:PlaySound(ui.click2, promoteOrDemote, false)
					local v25 = entry.Role == "Officer"
					local v26

					if v25 then
						v26 = CrewController.Demote(userId)
					else
						v26 = CrewController.Promote(userId)
					end

					flag = false

					if v26.success then
						local member = v6.Members[tostring(userId)]

						if v25 then
							notify(`Demoted {entry.Name} to Member.`) -- equivalent call inferred; original call site unknown

							if member then
								member.Role = "Member"
							end
						else
							notify(`Promoted {entry.Name} to Officer.`) -- equivalent call inferred; original call site unknown

							if member then
								member.Role = "Officer"
							end
						end

						renderMembers()
					else
						notify(v26.error) -- equivalent call inferred; original call site unknown
					end
				end))
			end
		end
	else
		local join = server2 and server2:FindFirstChild("Join")

		if join then
			maid3:Add(join.Activated:Connect(function()
				if flag then
					return
				end

				flag = true
				fx:PlaySound(ui.click2, join, false)
				local joinMemberServer = CrewController.JoinMemberServer(userId)
				flag = false
				local error = not joinMemberServer.success and joinMemberServer.error
				notify(error) -- equivalent call inferred; original call site unknown
			end))
		end
	end

	clone.Parent = scrollingFrame
	maid3:Add(clone)
	return clone
end

renderMembers = function()
	maid3:Clean()

	for k in pairs(v19) do
		if not k.Parent then
			v19[k] = nil
		end
	end

	actions2.Visible = visible
	server.Visible = not visible

	if not v6 then
		members.Text = "Members: 0/0"
		return
	end

	members.Text = `Members: {v6.MemberCount}/{v6.Capacity}`
	local v22 = {}

	for k, member in pairs(v6.Members) do
		local userId = tonumber(k)

		if not userId then
			continue
		end

		if visible then
			-- equivalent call inferred; original call site unknown
			if not canManageTarget(member.Role) then
				continue
			end
		end

		table.insert(v22, {
			userId = userId,
			entry = member
		})
	end

	local v23 = {
		Founder = 3,
		Officer = 2,
		Member = 1
	}
	table.sort(v22, function(a, b)
		local v24 = v23[a.entry.Role] or 0
		local v25 = v23[b.entry.Role] or 0

		if v24 == v25 then
			return (a.entry.Rating or 0) > (b.entry.Rating or 0)
		end

		return v25 < v24
	end)

	for i, v24 in ipairs(v22) do
		local row = buildRow(v24.userId, v24.entry)

		if row then
			row.LayoutOrder = i
		end
	end

	updateSearch()
end

updateSearch = function()
	local v22 = textBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")

	for _, guiObject in ipairs(scrollingFrame:GetChildren()) do
		if not (guiObject:IsA("GuiObject") and guiObject ~= player) then
			continue
		end

		local player3 = guiObject:FindFirstChild("Player")
		local label = player3 and player3:FindFirstChild("Label")

		if label and label:IsA("TextLabel") then
			guiObject.Visible = v22 == "" or label.Text:lower():find(v22, 1, true) ~= nil
		end
	end
end

local maid4 = Trove.new()
local count = 0
local levelsByUserId = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function inviteState(p: number)
	if not v6 then
		return "Invite"
	end

	local v22 = tostring(p)

	if v6.Members and v6.Members[v22] then
		return "Member"
	end

	if v6.JoinRequests and v6.JoinRequests[v22] then
		return "Requested"
	end

	if v6.Invites and v6.Invites[v22] then
		return "Invited"
	end

	return "Invite"
end

local function setActionState(clone, p: number, _: string)
	local actions3 = clone:FindFirstChild("Actions")

	if not actions3 then
		return
	end

	local accept = actions3:FindFirstChild("Accept")
	local invite3 = actions3:FindFirstChild("Invite")
	local decline = actions3:FindFirstChild("Decline")
	local v22 = inviteState(p) -- equivalent call inferred; original call site unknown

	if accept then
		accept.Visible = v22 == "Requested"
	end

	if decline then
		decline.Visible = v22 == "Requested"
	end

	if invite3 then
		invite3.Visible = v22 == "Invite" or v22 == "Invited"
		local label = invite3:FindFirstChild("Label")
		local uIStroke = invite3:FindFirstChild("UIStroke")
		local v23 = v22 == "Invited"
		local v24 = v23 and color8 or color7

		if label and label:IsA("TextLabel") then
			label.Text = v23 and "Cancel" or "Invite"
			label.TextColor3 = v24
		end

		if uIStroke and uIStroke:IsA("UIStroke") then
			uIStroke.Color = v24
		end

		if invite3:IsA("GuiButton") then
			invite3.AutoButtonColor = true
			invite3.Active = true
		end
	end

	if accept then
		local label = accept:FindFirstChild("Label")
		local uIStroke = accept:FindFirstChild("UIStroke")

		if label and label:IsA("TextLabel") then
			label.TextColor3 = color9
		end

		if uIStroke and uIStroke:IsA("UIStroke") then
			uIStroke.Color = color9
		end
	end
end

local function buildInviteRow(userId: number, displayName: string, username: string, level: number?)
	local clone = player2:Clone()
	clone.Name = tostring(userId)
	clone.Visible = true
	local player3 = clone:FindFirstChild("Player")

	if player3 then
		local headshot = player3:FindFirstChild("Headshot")

		if headshot and headshot:IsA("ImageLabel") then
			headshot.Image = `rbxthumb://type=AvatarHeadShot&id={userId}&w=180&h=180`
		end

		local label = player3:FindFirstChild("Label")

		if label then
			local displayName2 = label:FindFirstChild("DisplayName")
			local username2 = label:FindFirstChild("Username")

			if displayName2 and displayName2:IsA("TextLabel") then
				displayName2.Text = displayName
			end

			if username2 and username2:IsA("TextLabel") then
				username2.Text = `@{username}`
			end
		end
	end

	local level2 = clone:FindFirstChild("Level")

	if level2 then
		local label = level2:FindFirstChild("Label")

		if label and label:IsA("TextLabel") then
			label.Text = level and tostring(level) or "-"
		end
	end

	setActionState(clone, userId, displayName)
	local actions3 = clone:FindFirstChild("Actions")

	if actions3 then
		local accept = actions3:FindFirstChild("Accept")
		local invite3 = actions3:FindFirstChild("Invite")
		local decline = actions3:FindFirstChild("Decline")

		if invite3 then
			maid4:Add(invite3.Activated:Connect(function()
				if flag then
					return
				end

				local v23 = inviteState(userId) -- equivalent call inferred; original call site unknown

				if v23 ~= "Invite" and v23 ~= "Invited" then
					return
				end

				flag = true
				fx:PlaySound(ui.click2, invite3, false)

				if v23 == "Invited" then
					local rescindInvite = CrewController.RescindInvite(userId)
					flag = false

					if rescindInvite.success then
						notify(`Cancelled invite to {displayName}.`) -- equivalent call inferred; original call site unknown

						if v6 and v6.Invites then
							v6.Invites[tostring(userId)] = nil
						end

						setActionState(clone, userId, displayName)
					else
						notify(rescindInvite.error) -- equivalent call inferred; original call site unknown
					end
				else
					local invite4 = CrewController.Invite(userId)
					flag = false

					if invite4.success then
						notify(`Invited {displayName}.`) -- equivalent call inferred; original call site unknown

						if v6 then
							if not v6.Invites then
								v6.Invites = {}
							end

							v6.Invites[tostring(userId)] = {
								Name = displayName
							}
						end

						setActionState(clone, userId, displayName)
					else
						notify(invite4.error) -- equivalent call inferred; original call site unknown
					end
				end
			end))
		end

		if accept then
			maid4:Add(accept.Activated:Connect(function()
				if flag then
					return
				end

				local v23 = inviteState(userId) -- equivalent call inferred; original call site unknown

				if v23 ~= "Requested" then
					return
				end

				flag = true
				fx:PlaySound(ui.click2, accept, false)
				local acceptRequest = CrewController.AcceptRequest(userId)
				flag = false

				if acceptRequest.success then
					notify(`Accepted {displayName} into the crew.`) -- equivalent call inferred; original call site unknown

					if v6 then
						local v24 = tostring(userId)

						if v6.JoinRequests then
							v6.JoinRequests[v24] = nil
						end

						if not v6.Members then
							v6.Members = {}
						end

						if not v6.Members[v24] then
							v6.Members[v24] = {
								Role = "Member",
								Name = displayName,
								Rating = 0,
								JoinedAt = os.time(),
								LastSeen = os.time(),
								LastValidated = os.time()
							}
							v6.MemberCount = (v6.MemberCount or 0) + 1
						end
					end

					renderInvite()
				else
					notify(acceptRequest.error) -- equivalent call inferred; original call site unknown
				end
			end))
		end

		if decline then
			maid4:Add(decline.Activated:Connect(function()
				if flag then
					return
				end

				local v23 = inviteState(userId) -- equivalent call inferred; original call site unknown

				if v23 ~= "Requested" then
					return
				end

				flag = true
				fx:PlaySound(ui.click2, decline, false)
				local declineRequest = CrewController.DeclineRequest(userId)
				flag = false

				if declineRequest.success then
					notify(`Declined {displayName}'s request.`) -- equivalent call inferred; original call site unknown

					if v6 and v6.JoinRequests then
						v6.JoinRequests[tostring(userId)] = nil
					end

					renderInvite()
				else
					notify(declineRequest.error) -- equivalent call inferred; original call site unknown
				end
			end))
		end
	end

	clone.Parent = scrollingFrame2
	maid4:Add(clone)
	return clone
end

renderInvite = function()
	if not v6 then
		maid4:Clean()
		return
	end

	count += 1
	local v22 = count
	local v23 = {}
	local v24 = {}

	if v6.JoinRequests then
		for k, joinRequest in pairs(v6.JoinRequests) do
			local userId = tonumber(k)

			if not userId or v23[userId] then
				continue
			end

			v23[userId] = true
			table.insert(v24, {
				userId = userId,
				displayName = joinRequest.Name,
				username = joinRequest.Name,
				level = joinRequest.Level,
				requested = true
			})
		end
	end

	local userIds = {}

	for _, v25 in ipairs(Players:GetPlayers()) do
		local userId = v25.UserId

		if v23[userId] then
			continue
		end

		local v26 = inviteState(userId) -- equivalent call inferred; original call site unknown

		if v26 == "Member" then
			continue
		end

		v23[userId] = true
		table.insert(userIds, userId)
		table.insert(v24, {
			userId = userId,
			displayName = v25.DisplayName,
			username = v25.Name,
			level = levelsByUserId[userId],
			requested = false
		})
	end

	if v13 and not v23[v13.userId] then
		local v25 = inviteState(v13.userId) -- equivalent call inferred; original call site unknown

		if v25 ~= "Member" then
			v23[v13.userId] = true
			table.insert(v24, {
				userId = v13.userId,
				displayName = v13.name,
				username = v13.name,
				level = v13.level or levelsByUserId[v13.userId],
				requested = false
			})
		end
	end

	if #userIds > 0 then
		local levels = CrewController.GetLevels(userIds)

		if v22 ~= count then
			return
		end

		for _, v25 in ipairs(v24) do
			local level = levels[tostring(v25.userId)]

			if level == nil then
				if v25.level == nil then
					v25.level = levelsByUserId[v25.userId]
				end
			else
				levelsByUserId[v25.userId] = level
				v25.level = level
			end
		end
	end

	if v22 ~= count then
		return
	end

	maid4:Clean()
	table.sort(v24, function(a, b)
		if a.requested == b.requested then
			return a.username:lower() < b.username:lower()
		end

		return a.requested
	end)

	for i, v25 in ipairs(v24) do
		local inviteRow = buildInviteRow(v25.userId, v25.displayName, v25.username, v25.level)

		if inviteRow then
			inviteRow.LayoutOrder = i
		end
	end
end

local function runSearch()
	local v22 = textBox2.Text:gsub("^%s*(.-)%s*$", "%1")

	if v22 == "" then
		v13 = nil
		renderInvite()
	else
		if flag then
			return
		end

		flag = true
		fx:PlaySound(ui.click2, submitSearch, false)
		task.spawn(function()
			local user = CrewController.LookupUser(v22)

			if user.success and user.userId and user.name then
				v13 = {
					userId = user.userId,
					name = user.name,
					level = user.level
				}
				renderInvite()
			else
				v13 = nil
				local error = user.error or "Couldn't find that player."
				notify(error) -- equivalent call inferred; original call site unknown
				renderInvite()
			end

			flag = false
		end)
	end
end

local function wireInvite()
	back2.Activated:Connect(function()
		fx:PlaySound(ui.click2, back2, false)
		invite.Visible = false
		home.Visible = true
		v13 = nil
		textBox2.Text = ""
		maid4:Clean()
		refreshAll()
	end)
	submitSearch.Activated:Connect(runSearch)
	textBox2.FocusLost:Connect(function(flag3: boolean)
		if flag3 then
			runSearch()
		end
	end)
end

local maid5 = Trove.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function applyPreview(p: string?)
	local v22 = p and crewEmblems.Get(p) or crewEmblems.Get(crewEmblems.DEFAULT_ID)
	iconPreview.Image = v22 and v22.Icon or ""
	iconPreview.ImageColor3 = Color3.fromRGB(v14.r, v14.g, v14.b)
end

renderCustomize = function()
	maid5:Clean()

	for _, guiObject in ipairs(scrollingFrame3:GetChildren()) do
		if guiObject:IsA("GuiObject") and guiObject ~= icon2 then
			guiObject:Destroy()
		end
	end

	if v16 == "create" then
		presetId = DEFAULT_ID
		v14 = {
			r = v17.r,
			g = v17.g,
			b = v17.b
		}
	else
		if not v6 then
			return
		end

		presetId = v6.Emblem.PresetId
		local color11 = v6.Emblem.Color
		v14 = {
			r = color11.r,
			g = color11.g,
			b = color11.b
		}
	end

	if v15 then
		v15:LoadColor(Color3.fromRGB(v14.r, v14.g, v14.b))
	end

	applyPreview(presetId) -- equivalent call inferred; original call site unknown

	for _, v23 in ipairs(crewEmblems.GetAll()) do
		local clone = icon2:Clone()
		clone.Name = v23.Id
		clone.Visible = true

		if clone:IsA("ImageLabel") or clone:IsA("ImageButton") then
			clone.Image = v23.Icon
		end

		clone.Parent = scrollingFrame3
		maid5:Add(clone)

		if not clone:IsA("GuiButton") then
			continue
		end

		clone.Active = true
		local v24 = clone
		local v25 = v23
		maid5:Add(clone.MouseButton1Click:Connect(function()
			fx:PlaySound(ui.click2, v24, false)
			presetId = v25.Id
			applyPreview(presetId) -- equivalent call inferred; original call site unknown
		end))
	end
end

local function wireCustomize()
	v15 = CustomColorPicker.new(color, function(color11: Color3)
		v14 = {
			r = math.round(color11.R * 255),
			g = math.round(color11.G * 255),
			b = math.round(color11.B * 255)
		}
		applyPreview(presetId) -- equivalent call inferred; original call site unknown
	end)
	back3.Activated:Connect(function()
		fx:PlaySound(ui.click2, back3, false)
		customizeCrew.Visible = false
		maid5:Clean()

		if v16 == "create" then
			createCrew.Visible = true
		else
			home.Visible = true
		end

		presetId = nil
	end)
	confirm.Activated:Connect(function()
		if flag or not presetId then
			return
		end

		if v16 == "create" then
			fx:PlaySound(ui.click2, confirm, false)
			DEFAULT_ID = presetId
			v17 = {
				r = v14.r,
				g = v14.g,
				b = v14.b
			}
			customizeCrew.Visible = false
			maid5:Clean()
			createCrew.Visible = true
			renderCreate()
		else
			flag = true
			fx:PlaySound(ui.click2, confirm, false)
			local v22 = CrewController.SetEmblem(presetId, v14)
			flag = false

			if v22.success then
				anno_localthought:Fire("Emblem updated.")

				if v6 then
					v6.Emblem.PresetId = presetId
					v6.Emblem.Color = {
						r = v14.r,
						g = v14.g,
						b = v14.b
					}
				end

				customizeCrew.Visible = false
				home.Visible = true
				maid5:Clean()
				renderHome()
			else
				notify(v22.error) -- equivalent call inferred; original call site unknown
			end
		end
	end)
end

renderCreate = function()
	_Name2.Text = textBox4.Text == "" and "Your Crew" or textBox4.Text or "Your Crew"
	local v22 = crewEmblems.Get(DEFAULT_ID) or crewEmblems.Get(crewEmblems.DEFAULT_ID)
	icon3.Image = v22 and v22.Icon or ""
	icon3.ImageColor3 = Color3.fromRGB(v17.r, v17.g, v17.b)
	local label = whoCanJoin2:FindFirstChild("Label")
	local uIStroke = whoCanJoin2:FindFirstChild("UIStroke")
	local v23 = v3[v18] or v3.Anyone

	if label and label:IsA("TextLabel") then
		label.Text = v2[v18] or "Anyone"
		label.TextColor3 = v23
	end

	if uIStroke and uIStroke:IsA("UIStroke") then
		uIStroke.Color = v23
	end

	local label2 = create:FindFirstChild("Label")

	if label2 and label2:IsA("TextLabel") then
		label2.Text = "50,000 C$"
	end
end

resetCreate = function()
	textBox4.Text = ""
	DEFAULT_ID = crewEmblems.DEFAULT_ID
	v17 = {
		r = 255,
		g = 255,
		b = 255
	}
	v18 = "Anyone"
end

local function wireCreate()
	textBox4:GetPropertyChangedSignal("Text"):Connect(function()
		_Name2.Text = textBox4.Text == "" and "Your Crew" or textBox4.Text or "Your Crew"
	end)
	whoCanJoin2.Activated:Connect(function()
		fx:PlaySound(ui.click2, whoCanJoin2, false)
		v18 = nextWhoCanJoin(v18)
		renderCreate()
	end)
	edit2.Activated:Connect(function()
		fx:PlaySound(ui.click2, edit2, false)
		v16 = "create"
		createCrew.Visible = false
		customizeCrew.Visible = true
		renderCustomize()
	end)
	create.Activated:Connect(function()
		if flag then
			return
		end

		flag = true
		fx:PlaySound(ui.click2, create, false)
		local v22 = CrewController.Create(textBox4.Text, DEFAULT_ID, v17, v18)
		flag = false

		if v22.success then
			anno_localthought:Fire("Crew created!")
			resetCreate()
			createCrew.Visible = false
			refreshAll()
			home.Visible = true
			leaderboard.Visible = true
		else
			notify(v22.error) -- equivalent call inferred; original call site unknown
		end
	end)
	back5.Activated:Connect(function()
		fx:PlaySound(ui.click2, back5, false)
		crews.Visible = false
	end)
end

refreshAll = function()
	setManageMode(false) -- equivalent call inferred; original call site unknown

	local function fn(_)
		if flag2 then
			return
		end

		renderHome()
		renderMembers()
	end

	local v22 = v9 + 1
	v9 = v22
	local v23 = nil
	task.spawn(function()
		local fetched = CrewController.Fetch(v23)

		if v22 ~= v9 then
			return
		end

		if fetched == nil then
			if fn then
				fn(nil)
			end
		else
			v6 = fetched

			if fn then
				fn(fetched)
			end
		end
	end)
end

local Crews = {
	openCrewList = function()
		if flag2 then
			return
		end

		flag2 = true
		home.Visible = false
		invite.Visible = false
		customizeCrew.Visible = false
		createCrew.Visible = false
		crewList.Visible = true
		leaderboard.Visible = false
		back4.Visible = not v8
		textBox3.Text = ""
		renderCrewList()
		startResetCountdown()
	end,
	openMenu = function()
		crewList.Visible = false
		invite.Visible = false
		customizeCrew.Visible = false
		setManageMode(false) -- equivalent call inferred; original call site unknown
		v8 = false
		flag2 = false
		leaderboard.Visible = true
		back4.Visible = false

		local function fn(p)
			local isInCrew = CrewController.IsInCrew()

			if p or isInCrew then
				createCrew.Visible = false
				home.Visible = true
				renderHome()
				renderMembers()
			else
				resetCreate()
				renderCreate()
				home.Visible = false
				createCrew.Visible = true
				leaderboard.Visible = false
			end
		end

		local v22 = v9 + 1
		v9 = v22
		local v23 = nil
		task.spawn(function()
			local fetched = CrewController.Fetch(v23)

			if v22 ~= v9 then
				return
			end

			if fetched == nil then
				if fn then
					fn(nil)
				end
			else
				v6 = fetched

				if fn then
					fn(fetched)
				end
			end
		end)
		crews.Visible = true
	end
}

function Crews.init()
	wireHome()
	wireCrewList()
	wireInvite()
	wireCustomize()
	wireCreate()
	player.Visible = false
	player2.Visible = false
	icon2.Visible = false
	clan.Visible = false
	createCrew.Visible = false
	leaderboard.Visible = true
	back4.Visible = false
	textBox:GetPropertyChangedSignal("Text"):Connect(updateSearch)
	DataController.PlayerDataReplicator:Observe({ "Crews" }, function(p, p2)
		if not (crews.Visible and (p and p.Role) ~= (p2 and p2.Role) and v6) then
			return
		end

		applyLeftButtons() -- equivalent call inferred; original call site unknown

		if visible then
			renderMembers()
		end
	end)
	refresh.Activated:Connect(function()
		local now = os.clock()

		if now - v10 < 0.6 then
			return
		end

		v10 = now
		fx:PlaySound(ui.click2, refresh, false)

		local function fn(p)
			if p then
				renderHome()
				renderMembers()
			end
		end

		local v22 = v9 + 1
		v9 = v22
		local v23 = nil
		task.spawn(function()
			local fetched = CrewController.Fetch(v23)

			if v22 ~= v9 then
				return
			end

			if fetched == nil then
				if fn then
					fn(nil)
				end
			else
				v6 = fetched

				if fn then
					fn(fetched)
				end
			end
		end)
	end)
	crews:GetPropertyChangedSignal("Visible"):Connect(function()
		if not crews.Visible then
			maid3:Clean()
			maid4:Clean()
			maid5:Clean()
			maid:Clean()
			maid2:Clean()
			v5:Clean()
			v6 = nil
			v13 = nil
			presetId = nil
			v16 = "edit"
			v8 = false
			v20 = nil
			flag2 = false
			flag = false
			leaderboard.Visible = false
			back4.Visible = false
			setManageMode(false) -- equivalent call inferred; original call site unknown
		end
	end)
	close.Activated:Connect(function()
		fx:PlaySound(ui.click2, close, false)
		crews.Visible = false
	end)
	remoteEvent.OnClientEvent:Connect(Crews.openMenu)
	remoteEvent2.OnClientEvent:Connect(function()
		home.Visible = false
		invite.Visible = false
		customizeCrew.Visible = false
		createCrew.Visible = false
		setManageMode(false) -- equivalent call inferred; original call site unknown
		v8 = true
		local v22 = v9 + 1
		v9 = v22
		local v23 = nil
		local v24 = nil
		task.spawn(function()
			local fetched = CrewController.Fetch(v23)

			if v22 ~= v9 then
				return
			end

			if fetched == nil then
				if v24 then
					v24(nil)
				end
			else
				v6 = fetched

				if v24 then
					v24(fetched)
				end
			end
		end)
		showCrewList() -- equivalent call inferred; original call site unknown
		crews.Visible = true
	end)
end

return Crews