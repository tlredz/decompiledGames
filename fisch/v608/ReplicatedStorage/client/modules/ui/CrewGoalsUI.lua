local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Net = require(ReplicatedStorage.packages.Net)
local Quests = require(ReplicatedStorage.shared.modules.Quests)
local QuestShared = require(ReplicatedStorage.shared.modules.QuestShared)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local remoteFunction = Net:RemoteFunction("CrewGoals/GetState")
local remoteEvent = Net:RemoteEvent("Quests/ToggleTrack", 1e999)
local color = Color3.fromRGB(255, 195, 75)
local color2 = Color3.fromRGB(120, 220, 120)
local color3 = Color3.fromRGB(110, 110, 110)
local color4 = Color3.fromRGB(15, 15, 15)
local color5 = Color3.fromRGB(162, 234, 166)
local color6 = Color3.fromRGB(234, 116, 118)
local color7 = Color3.fromRGB(255, 232, 139)
local color8 = Color3.fromRGB(160, 209, 255)
local color9 = Color3.fromRGB(255, 255, 255)
local v = {
	Founder = 3,
	Officer = 2,
	Member = 1
}
local localPlayer = Players.LocalPlayer
local crewGoals = localPlayer:WaitForChild("PlayerGui"):WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("CrewGoals")
local listContents = crewGoals:WaitForChild("questList"):WaitForChild("listContents")
local questDetails = crewGoals:WaitForChild("questDetails")
local detailContents = questDetails:WaitForChild("detailContents")
local empty = questDetails:WaitForChild("empty")
local options = questDetails:FindFirstChild("options")
local track = options and options:FindFirstChild("Track")
local navigate = options and options:FindFirstChild("Navigate")
local header = detailContents:FindFirstChild("header")
local questDesc = detailContents:FindFirstChild("questDesc")
local quickDetails = detailContents:FindFirstChild("quickDetails")
local objectives = detailContents:FindFirstChild("objectives")
local rewards = detailContents:FindFirstChild("rewards")
local questProgress = detailContents:FindFirstChild("QuestProgress")
local list = detailContents:FindFirstChild("list")
local typeDivider = script:WaitForChild("typeDivider")
local quest = script:WaitForChild("quest")
local listItem = script:WaitForChild("listItem")
local CrewGoalsUI = {}
local v2 = nil
local v3 = 1
local clones = {}
local flag = false
local flag2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function stateColor(state: string)
	if state == "Completed" then
		return color2
	elseif state == "Locked" then
		return color3
	end

	return color
end

-- equivalent calls inferred from this helper; original call sites unknown
local function roleColor(role: string)
	if role == "Founder" then
		return color7
	elseif role == "Officer" then
		return color8
	end

	return color9
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyRoleIcon(role, role2: string)
	if role2 == "Founder" then
		role.Visible = true
		role.Image = "rbxassetid://122869255597458"
		role.ImageColor3 = color7
	else
		if role2 ~= "Officer" then
			role.Visible = false
			return
		end

		role.Visible = true
		role.Image = "rbxassetid://86078349037634"
		role.ImageColor3 = color8
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function joinOr(list2)
	if #list2 == 1 then
		return list2[1]
	end

	if #list2 == 2 then
		return (`{list2[1]} or {list2[2]}`)
	end

	return (`{table.concat(list2, ", ", 1, #list2 - 1)}, or {list2[#list2]}`)
end

local function describeObjective(list2)
	local v4 = list2[1]

	if v4 == "CatchFish" or v4 == "CatchFishAny" or v4 == "CatchFishWithCrabCage" or v4 == "CatchFishWithSpear" then
		local v5 = list2[2] or 1
		local v6 = list2[3]
		local v7 = list2[4]
		local v8 = typeof(list2[5]) ~= "table" and {} or list2[5] or {}
		local v9 = v8.Perfect and "Perfect Catch" or "Catch"
		local v10 = ""

		if v8.ShinyOrSparkling then
			v10 ..= "Shiny or Sparkling "
		end

		if v8.Shiny then
			v10 ..= "Shiny "
		end

		if v8.Sparkling then
			v10 ..= "Sparkling "
		end

		if typeof(v8.WeightClass) == "string" then
			v10 ..= `{v8.WeightClass} `
		end

		if typeof(v8.Mutation) == "string" then
			v10 ..= `{v8.Mutation} `
		end

		local v11 = "fish"

		if typeof(v6) == "table" and #v6 > 0 then
			if #v6 == 1 then
				v11 = v6[1]
			elseif #v6 == 2 then
				v11 = `{v6[1]} or {v6[2]}`
			else
				v11 = `{table.concat(v6, ", ", 1, #v6 - 1)}, or {v6[#v6]}`
			end
		elseif typeof(v7) == "table" and #v7 > 0 then
			local v13 = joinOr(v7) -- equivalent call inferred; original call site unknown
			v11 = `{v13} fish`
		end

		return (`{v9} {v5} {v10}{v11}{v4 == "CatchFishWithCrabCage" and " with Crab Cages" or v4 == "CatchFishWithSpear" and " with a spear" or ""}`)
	else
		if v4 == "SellFish" then
			return (`Sell {list2[2] or 1} fish`)
		elseif v4 == "AppraiseFish" then
			return (`Appraise {list2[2] or 1} fish`)
		elseif v4 == "BaitUse" then
			local v5 = list2[2] or 1
			return (`Use {v5} bait{v5 == 1 and "" or "s"}`)
		end

		if v4 == "Custom" and typeof(list2[3]) == "string" then
			return list2[3]
		end

		return "Complete the objective"
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isSelfCompleted(goal)
	for _, v4 in ipairs(goal.Completed) do
		if v4.UserId == localPlayer.UserId then
			return true
		end
	end

	return false
end

local function clearLines(instance, p)
	if not instance then
		return
	end

	for _, guiObject in ipairs(instance:GetChildren()) do
		if not guiObject:IsA("GuiObject") or p and p[guiObject.Name] then
			continue
		end

		guiObject:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addLine(objectives2, text: string, textColor: Color3?)
	if not objectives2 then
		return
	end

	local clone = listItem:Clone()
	clone:SetAttribute("CrewGoalClone", true)
	local line = clone:FindFirstChild("line")

	if line and line:IsA("TextLabel") then
		line.Text = text

		if textColor then
			line.TextColor3 = textColor
		end
	end

	clone.Visible = true
	clone.Parent = objectives2
end

local function connectClick(button, onActivated)
	if button:IsA("GuiButton") then
		button.Activated:Connect(onActivated)
	else
		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				onActivated()
			end
		end)
	end
end

local function formatReset(p: number)
	return (`New goals in {math.floor(p / 3600)}h {math.floor(p % 3600 / 60)}m`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function activeQuestInstance()
	local v4 = v2 and v2.Goals[v3]

	if v4 and v4.State == "Active" then
		return QuestShared:GetQuestInstance(localPlayer, v4.QuestId)
	end

	return nil
end

local function updateTrackButton()
	if not (options and track) then
		return
	end

	local v4 = activeQuestInstance() -- equivalent call inferred; original call site unknown

	if not v4 then
		options.Visible = false
		return
	end

	local tracking = v4:FindFirstChild("Tracking")
	local value

	if tracking == nil then
		value = false
	else
		value = tracking:IsA("BoolValue") and tracking.Value
	end

	local v5 = value and color6 or color5
	local uIStroke = track:FindFirstChild("UIStroke")

	if uIStroke and uIStroke:IsA("UIStroke") then
		uIStroke.Color = v5
	end

	if track:IsA("ImageButton") or track:IsA("ImageLabel") then
		track.ImageColor3 = v5
	end

	local label = track:FindFirstChild("Label")

	if label and label:IsA("TextLabel") then
		label.Text = value and "Untrack" or "Track"
		label.TextColor3 = v5
	end

	options.Visible = true
end

local function toggleTracking()
	local v4 = activeQuestInstance() -- equivalent call inferred; original call site unknown

	if not v4 then
		return
	end

	local tracking = v4:FindFirstChild("Tracking")

	if tracking and tracking:IsA("BoolValue") then
		tracking.Value = not tracking.Value
	end

	remoteEvent:FireServer(v4, not (tracking and tracking:IsA("BoolValue")) or tracking.Value)
	updateTrackButton()
end

local function buildRoster(goal)
	local result = {}

	for _, v4 in ipairs(goal.Completed) do
		result[v4.UserId] = true
	end

	local v4 = {}
	local result2 = {}

	for _, v5 in ipairs(v2.Members or {}) do
		v4[v5.UserId] = true
		table.insert(result2, v5)
	end

	table.sort(result2, function(a, b)
		local v5 = v[a.Role] or 0
		local v6 = v[b.Role] or 0

		if v5 == v6 then
			return (a.Rating or 0) > (b.Rating or 0)
		end

		return v6 < v5
	end)

	for _, v5 in ipairs(goal.Completed) do
		if not v4[v5.UserId] then
			table.insert(result2, {
				UserId = v5.UserId,
				Name = v5.Name,
				Role = "",
				Rating = 0
			})
		end
	end

	return result2, result
end

local function renderDetails()
	if not v2 then
		return
	end

	local goal = v2.Goals[v3]

	if not goal then
		return
	end

	local quest2 = Quests[goal.QuestId]
	local displayName = quest2 and quest2.DisplayName or goal.Id
	local selfCompleted = isSelfCompleted(goal) -- equivalent call inferred; original call site unknown

	if header then
		local questName = header:FindFirstChild("questName", true)

		if questName and questName:IsA("TextLabel") then
			questName.Text = displayName
		end

		local questIcon = header:FindFirstChild("questIcon", true)

		if questIcon and questIcon:IsA("ImageLabel") and quest2 and quest2.Icon then
			questIcon.Image = quest2.Icon
		end
	end

	if questDesc and questDesc:IsA("TextLabel") then
		if goal.State == "Locked" then
			questDesc.Text = "Locked. Complete the previous Crew Goal to unlock this one."
		elseif goal.State == "Completed" then
			questDesc.Text = "Your crew completed this goal today. Great work!"
		elseif selfCompleted then
			questDesc.Text = "You did your part! Waiting on the rest of the crew."
		else
			questDesc.Text = "Work together with your crew to complete this goal."
		end
	end

	if quickDetails then
		local countdown = quickDetails:FindFirstChild("countdown", true)

		if countdown and countdown:IsA("TextLabel") then
			local secondsUntilReset = v2.SecondsUntilReset
			countdown.Text = `New goals in {math.floor(secondsUntilReset / 3600)}h {math.floor(secondsUntilReset % 3600 / 60)}m`
		end

		local typeName = quickDetails:FindFirstChild("typeName", true)

		if typeName and typeName:IsA("TextLabel") then
			typeName.Text = "Crew Goals"
		end
	end

	clearLines(objectives)

	if quest2 then
		for _, v4 in ipairs(quest2.List) do
			addLine(objectives, describeObjective(v4), selfCompleted and color2 or nil)
		end
	end

	clearLines(rewards)
	addLine(rewards, (`+{NumberUtils:Comma(goal.RatingTotal or goal.Rating or 0)} Crew Rating for your crew`)) -- equivalent call inferred; original call site unknown

	if questProgress then
		local v5 = not (goal.Required > 0) and 0 or math.clamp(goal.CompletedCount / goal.Required, 0, 1) or 0
		local fill = questProgress:FindFirstChild("Fill")

		if fill and fill:IsA("GuiObject") then
			fill.Size = UDim2.new(v5, 0, fill.Size.Y.Scale, fill.Size.Y.Offset)
		end

		local progress = questProgress:FindFirstChild("Progress", true)

		if progress and progress:IsA("TextLabel") then
			progress.Text = `{goal.CompletedCount}/{goal.Required}`
		end
	end

	if list then
		local scrollingFrame = list:FindFirstChild("ScrollingFrame")
		local player = scrollingFrame and scrollingFrame:FindFirstChild("Player")

		if scrollingFrame and player then
			player.Visible = false
			clearLines(scrollingFrame, {
				Player = true
			})
			local roster, v5 = buildRoster(goal)

			for i, v6 in ipairs(roster) do
				local clone = player:Clone()
				clone:SetAttribute("CrewGoalClone", true)
				clone.Name = `Row_{v6.UserId}`
				clone.LayoutOrder = i
				local player2 = clone:FindFirstChild("Player")

				if player2 then
					local headshot = player2:FindFirstChild("Headshot")

					if headshot and headshot:IsA("ImageLabel") then
						headshot.Image = `rbxthumb://type=AvatarHeadShot&id={v6.UserId}&w=180&h=180`
					end

					local label = player2:FindFirstChild("Label")

					if label and label:IsA("TextLabel") then
						label.Text = v6.Name
						local textColor = roleColor(v6.Role) -- equivalent call inferred; original call site unknown
						label.TextColor3 = textColor
					end

					local role = player2:FindFirstChild("Role")

					if role and role:IsA("ImageLabel") then
						applyRoleIcon(role, v6.Role) -- equivalent call inferred; original call site unknown
					end
				end

				local status = clone:FindFirstChild("Status")

				if status then
					local label = status:FindFirstChild("Label")

					if label and label:IsA("TextLabel") then
						if v5[v6.UserId] == true then
							label.Text = "Completed"
							label.TextColor3 = color2
						else
							if goal.State == "Active" then
								label.Text = "Incomplete"
							else
								label.Text = "-"
							end

							label.TextColor3 = color3
						end
					end
				end

				clone.Visible = true
				clone.Parent = scrollingFrame
			end
		end
	end

	updateTrackButton()
end

local renderList

renderList = function()
	for _, v4 in ipairs(clones) do
		v4:Destroy()
	end

	table.clear(clones)
	clearLines(listContents)

	if not v2 then
		return
	end

	local clone = typeDivider:Clone()
	clone:SetAttribute("CrewGoalClone", true)
	clone.Name = "0 crew goals"
	clone.LayoutOrder = 0
	local typeName = clone:FindFirstChild("typeName", true)

	if typeName and typeName:IsA("TextLabel") then
		typeName.Text = "Crew Goals"
	end

	clone.Visible = true
	clone.Parent = listContents

	for i, goal in ipairs(v2.Goals) do
		local quest2 = Quests[goal.QuestId]
		local displayName = quest2 and quest2.DisplayName or goal.Id
		local clone2 = quest:Clone()
		clone2:SetAttribute("CrewGoalClone", true)
		clone2.Name = `{i} {displayName:lower()}`
		clone2.LayoutOrder = i
		local v4 = goal.State == "Locked"
		local backgroundColor = stateColor(goal.State) -- equivalent call inferred; original call site unknown
		local v6 = i == v3
		local questName = clone2:FindFirstChild("questName", true)

		if questName and questName:IsA("TextLabel") then
			if v4 then
				displayName = `{displayName} (Locked)` or displayName
			end

			questName.Text = displayName
			questName.TextColor3 = v6 and backgroundColor or backgroundColor:Lerp(color4, 0.35)
		end

		local leftBorder = clone2:FindFirstChild("leftBorder")

		if leftBorder and leftBorder:IsA("GuiObject") then
			leftBorder.BackgroundColor3 = backgroundColor
		end

		local quickDetails2 = clone2:FindFirstChild("quickDetails", true)

		if quickDetails2 and quickDetails2:IsA("GuiObject") then
			quickDetails2.Visible = false
		end

		if clone2:IsA("GuiButton") then
			clone2.Active = not v4
			clone2.AutoButtonColor = not v4
		end

		if not v4 then
			local v7 = i
			connectClick(clone2, function()
				v3 = v7
				renderList()
				renderDetails()
			end)
		end

		clone2.Visible = true
		clone2.Parent = listContents
		table.insert(clones, clone2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function renderEmpty(text: string)
	empty.Visible = true
	detailContents.Visible = false

	if options then
		options.Visible = false
	end

	local textLabel = empty:FindFirstChildWhichIsA("TextLabel", true)

	if textLabel then
		textLabel.Text = text
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function render()
	if v2 then
		empty.Visible = false
		detailContents.Visible = true
		renderList()
		renderDetails()
	else
		renderEmpty("Join a crew to take part in Crew Goals!") -- equivalent call inferred; original call site unknown
		renderList()
	end
end

function CrewGoalsUI:Refresh()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local success, result = pcall(function()
			return remoteFunction:InvokeServer()
		end)
		flag = false

		if not success then
			return
		end

		local v4 = v2
		v2 = result

		if v2 then
			local count = #v2.Goals

			if count == 0 then
				v3 = 1
			else
				local v5

				if v4 == nil or v4.DayId ~= v2.DayId then
					v5 = true
				elseif #v4.Goals > 0 then
					v5 = v3 == math.clamp(v4.GoalIndex, 1, #v4.Goals)
				else
					v5 = false
				end

				if v5 or v3 < 1 or count < v3 then
					v3 = math.clamp(v2.GoalIndex, 1, count)
				end
			end
		end

		if crewGoals.Visible then
			render() -- equivalent call inferred; original call site unknown
		end
	end)
end

function CrewGoalsUI:Open()
	local guiInset, v4 = GuiService:GetGuiInset()
	local v5 = v4 + Vector2.new(0, 90)
	crewGoals.Size = UDim2.new(0.85, -guiInset.X - v5.X, 1, -guiInset.Y - v5.Y)
	crewGoals.Position = UDim2.new(0.5, guiInset.X / 2 - v5.X / 2, 0.5, guiInset.Y / 2 - v5.Y / 2)
	crewGoals.Visible = true
	render() -- equivalent call inferred; original call site unknown
	self:Refresh()
end

function CrewGoalsUI:Close()
	crewGoals.Visible = false
end

function CrewGoalsUI:Toggle()
	if crewGoals.Visible then
		self:Close()
	else
		self:Open()
	end
end

function CrewGoalsUI.init()
	if flag2 then
		return
	end

	flag2 = true
	crewGoals.Visible = false

	if options then
		options.Visible = false
	end

	if options and options:IsA("GuiObject") then
		options.ZIndex = 50
	end

	if navigate and navigate:IsA("GuiObject") then
		navigate.Visible = false
	end

	if track and track:IsA("GuiObject") then
		if track:IsA("GuiButton") then
			track.Active = true
		end

		connectClick(track, toggleTracking)
	end

	local close = crewGoals:FindFirstChild("Close")

	if close and close:IsA("GuiObject") then
		connectClick(close, function()
			CrewGoalsUI:Close()
		end)
	end

	task.spawn(function()
		while true do
			task.wait(5)

			if crewGoals.Visible then
				CrewGoalsUI:Refresh()
			end
		end
	end)
end

function CrewGoalsUI.Start(_)
	CrewGoalsUI.init()
end

return CrewGoalsUI