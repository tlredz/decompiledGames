local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local runService = module.Services.RunService
local userInputService = module.Services.UserInputService
local collectionService = module.Services.CollectionService
local color = Color3.new(1, 1, 1)
local color2 = Color3.new(0, 1, 0)
local color3 = Color3.new(1, 0, 0)
local fusion = module.Libs.Fusion
local tutorial = module.Shared.Tutorial
local instance = module.Instance
local playerGui = instance:WaitForChild("PlayerGui")
local tutorial2 = playerGui:WaitForChild("Tutorial")
local target = tutorial2:WaitForChild("Target")
local uIStroke = target:WaitForChild("Center"):WaitForChild("UIStroke")
local message = tutorial2:WaitForChild("Message")
local content = message:WaitForChild("Content")
local title = content:WaitForChild("Title")
local desc = content:WaitForChild("Desc")
local scroll = content:WaitForChild("Options"):WaitForChild("Scroll")
local arrow = tutorial2:WaitForChild("Arrow")
local icon = arrow:WaitForChild("Icon")
local HUD = module.Interface:WaitForChild("HUD")
local frames = module.Interface:WaitForChild("Frames")
local buttons = HUD:WaitForChild("Left"):WaitForChild("Buttons")
local bottom = HUD:WaitForChild("Bottom")
local buttons2 = bottom:WaitForChild("Buttons")
local quests = HUD:WaitForChild("Quests")
local multipliers = HUD:WaitForChild("Multipliers")

for _, child in HUD:GetChildren() do
	if not (child.Name == "Multipliers" and child:FindFirstChild("List") and child:FindFirstChild("Arrow")) then
		continue
	end

	multipliers = child
end

local scroll2 = frames:WaitForChild("Dialog"):WaitForChild("Content"):WaitForChild("Options"):WaitForChild("Scroll")
local scroll3 = frames:WaitForChild("Teleport"):WaitForChild("List"):WaitForChild("Scroll")
local main = frames:WaitForChild("Star"):WaitForChild("Buttons"):WaitForChild("Single"):WaitForChild("Main")
local playerLevel = frames:WaitForChild("PlayerLevel")
local main2 = playerLevel:WaitForChild("Main")
local frameOptions = playerLevel:WaitForChild("FrameOptions")
local maps = workspace:WaitForChild("Client"):WaitForChild("Maps")
local option = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Dialog"):WaitForChild("Option")
local size = option:WaitForChild("Main").Size
local position = message.Position
local v = {
	Bottom = {
		Shown = position,
		Hidden = UDim2.new(position.X.Scale, position.X.Offset, 1.5, 0)
	},
	Top = {
		Shown = UDim2.new(position.X.Scale, position.X.Offset, 0.3, 0),
		Hidden = UDim2.new(position.X.Scale, position.X.Offset, -0.05, 0)
	}
}
local size2 = arrow.Size
local scope = fusion.scoped(fusion)
local value = scope:Value(v.Bottom.Hidden)
local spring = scope:Spring(value, 10, 1)
local value2 = scope:Value(UDim2.new())
local spring2 = scope:Spring(value2, 10, 1)
local value3 = scope:Value(UDim2.new())
local spring3 = scope:Spring(value3, 10, 1)
local value4 = scope:Value(UDim2.fromScale(0, 0))
local spring4 = scope:Spring(value4, 10, 1)
local v2 = {}
local v3 = false
local v4 = nil
local v5 = nil
local v6 = false
local v7 = "Bottom"
local v8 = "Bottom"
local thread = nil
local flag = false
local v9 = nil
local now = 0
local v10 = nil
local now2 = 0
local v11 = 0
local name = nil
local v12 = nil
local topBarPlus = nil
local renderSteppedConnection = nil
local Tutorial = {}
local scope2 = fusion.scoped(fusion, {
	Build = function(self, layoutOrder: number, duration: number)
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.Instance = option:Clone()
		self.Instance.Name = self.Text
		self.Instance.LayoutOrder = layoutOrder
		self.Instance.Main.Title.Text = self.Text
		self.Instance.Main.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, self.LightenedColor),
			ColorSequenceKeypoint.new(1, self.Color)
		})
		self.Instance.Main.Title.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, self.LightenedColor),
			ColorSequenceKeypoint.new(1, color)
		})
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			self.Callback()
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Size = self.SizeSpring
		})
		task.delay(duration, function()
			if not next(self) then
				return
			end

			self.Size:set(size)
		end)
	end
})

-- equivalent calls inferred from this helper; original call sites unknown
local function GetTutorialData()
	return module.Data.Tutorial
end

local function GetCurrentStep()
	local tutorial3 = GetTutorialData() -- equivalent call inferred; original call site unknown

	if tutorial3 and tutorial3.Status == "Active" then
		return tutorial.GetStep(tutorial3.Step), tutorial3.Step
	end

	return nil, 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsTouch()
	return userInputService.TouchEnabled and not userInputService.KeyboardEnabled
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetStarPrice()
	local v13 = module.Shared.Stars.List[tutorial.StarName]

	if v13 then
		return tonumber(v13.Price.Amount) or 0
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetQuestInfo()
	local v13 = module.Shared.Quests.List[tutorial.QuestClass]
	return v13 and v13.List[tutorial.QuestName]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetQuestData()
	local v13 = module.Data.Quests.List[tutorial.QuestClass]
	return v13 and v13.List[tutorial.QuestName]
end

local function GetRemainingMissions()
	local questInfo = GetQuestInfo() -- equivalent call inferred; original call site unknown
	local questData = GetQuestData() -- equivalent call inferred; original call site unknown

	if not (questInfo and questData) then
		return {}
	end

	local names = {}

	for k, mission in questInfo.Missions do
		if not mission.Name or (questData.Missions[k] or 0) >= mission.Amount then
			continue
		end

		table.insert(names, mission.Name)
	end

	return names
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetFirstEnemyNames()
	local remainingMissions = GetRemainingMissions()

	if #remainingMissions == 0 or table.find(remainingMissions, tutorial.FirstEnemyName) then
		return { tutorial.FirstEnemyName }
	end

	return remainingMissions
end

local function CountCompletedMissions()
	local questInfo = GetQuestInfo() -- equivalent call inferred; original call site unknown
	local questData = GetQuestData() -- equivalent call inferred; original call site unknown

	if not (questInfo and questData) then
		return 0
	end

	local count = 0

	for k, mission in questInfo.Missions do
		if (questData.Missions[k] or 0) >= mission.Amount then
			count += 1
		end
	end

	return count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsPaused(p, step: number)
	if not p then
		return false
	end

	if module.Data.Gamemode ~= nil then
		return true
	end

	if (tutorial.GetStepIndex("Teleport") or 1e999) <= step then
		return false
	end

	return module.Data.Maps.Current ~= tutorial.MapName
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatText(text: string)
	local formatText = tutorial.FormatText
	local touch = IsTouch() -- equivalent call inferred; original call site unknown
	return formatText(text, touch, {
		Price = GetStarPrice()
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetOrigin()
	return tutorial2.AbsolutePosition
end

local function IsGuiVisible(parent)
	while parent do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		end

		if parent:IsA("LayerCollector") then
			return parent.Enabled
		else
			parent = parent.Parent
		end
	end

	return false
end

local function GetGuiRect(data)
	if not (data.Parent and IsGuiVisible(data)) then
		return nil, nil
	end

	local absolutePosition = GetOrigin() -- equivalent call inferred; original call site unknown
	local v14 = data.AbsolutePosition + data.AbsoluteSize / 2 - absolutePosition
	local absoluteSize = tutorial2.AbsoluteSize

	if v14.X < 0 or v14.Y < 0 or v14.X > absoluteSize.X or v14.Y > absoluteSize.Y then
		return nil, nil
	end

	return v14, data.AbsoluteSize
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetButton(instance2, childName: string)
	local child = instance2:FindFirstChild(childName)
	return child and child:FindFirstChild("Main")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetDialogOption(childName: string)
	if not module.Frame:IsFrameOpened("Dialog") then
		return nil
	end

	return GetButton(scroll2, childName)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetTopbarWidget(p: string)
	local icon2 = module.Libs.TopBarPlus.getIcon(p)
	return icon2 and icon2.widget
end

local function GetMenuOption(p: string)
	local icon2 = module.Libs.TopBarPlus.getIcon("Menu")

	if not icon2 then
		return nil
	end

	if not icon2.isSelected then
		return icon2.widget
	end

	return GetTopbarWidget(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCharacterPosition()
	local character = instance.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart and humanoidRootPart.Position
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetEnemyPosition(instance2)
	local enemyID = instance2:GetAttribute("EnemyID")
	local v13 = enemyID and module.Utils.Enemies.GetPosition(enemyID)

	if v13 then
		return v13.Position
	end

	return instance2.Position
end

local function FindNearestEnemy(list)
	if #list == 0 then
		return nil
	end

	local characterPosition = GetCharacterPosition() -- equivalent call inferred; original call site unknown

	if not characterPosition then
		return nil
	end

	local v14 = 1e999
	local v15 = nil

	for _, part in collectionService:GetTagged("Enemy") do
		if not (part:IsA("BasePart") and part:IsDescendantOf(workspace) and part:GetAttribute("MapName") == module.Data.Maps.Current) then
			continue
		end

		if not (part:GetAttribute("SessionID") == nil and part:GetAttribute("Died") ~= true) then
			continue
		end

		if not table.find(list, part:GetAttribute("EnemyName")) then
			continue
		end

		local enemyPosition = GetEnemyPosition(part) -- equivalent call inferred; original call site unknown

		if not enemyPosition then
			continue
		end

		local magnitude = (enemyPosition - characterPosition).Magnitude

		if not (magnitude < v14) then
			continue
		end

		v15 = part
		v14 = magnitude
	end

	return v15
end

local function FindTaggedModel(tag: string, p: string, p2)
	for _, model in collectionService:GetTagged(tag) do
		if not (model:IsA("Model") and model:IsDescendantOf(p2 or workspace)) then
			continue
		end

		local parent = model.Parent
		local parent2 = parent and parent.Parent

		if model.Name == p or parent and parent.Name == p or parent2 and parent2.Name == p then
			return model
		end
	end

	return nil
end

local function CreateModelTarget(instance2)
	if not instance2 then
		return nil
	end

	if v10 and v10.Instance == instance2 then
		return v10
	end

	local boundingBox, v13 = instance2:GetBoundingBox()
	return {
		Instance = instance2,
		Point = boundingBox.Position + Vector3.new(0, v13.Y / 2 + 2, 0)
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CreateEnemyTarget(instance2)
	if instance2 then
		return {
			Instance = instance2,
			Enemy = true
		}
	end

	return nil
end

local function GetWorldPoint(data)
	if not data.Instance.Parent then
		return nil
	end

	if not data.Enemy then
		return data.Point
	end

	local instance2 = data.Instance

	if instance2:GetAttribute("Died") == true then
		return nil
	end

	local enemyID = instance2:GetAttribute("EnemyID")
	local v13 = enemyID and module.Scripts.Rendering.Enemies.Get(enemyID)

	if v13 and v13.Head and v13.Head.Parent then
		return v13.Head.Position + Vector3.new(0, v13.Head.Size.Y / 2 + 4, 0)
	end

	local enemyPosition = GetEnemyPosition(instance2) -- equivalent call inferred; original call site unknown
	return enemyPosition and enemyPosition + createVector(0, 6, 0)
end

local function IsListOpen(instance2)
	local list = instance2:FindFirstChild("List")
	return list ~= nil and list:IsA("GuiObject") and list.Visible
end

local function IsLevelTabOpen(childName: string)
	if not module.Frame:IsFrameOpened(playerLevel) then
		return false
	end

	local guiObject = main2:FindFirstChild(childName)
	return guiObject ~= nil and guiObject:IsA("GuiObject") and guiObject.Visible
end

local v13 = {
	LevelStats = function()
		if not module.Frame:IsFrameOpened(playerLevel) then
			return false
		end

		local stats = main2:FindFirstChild("Stats")
		return stats ~= nil and stats:IsA("GuiObject") and stats.Visible
	end,
	LevelRewards = function()
		if not module.Frame:IsFrameOpened(playerLevel) then
			return false
		end

		local rewards = main2:FindFirstChild("Rewards")
		return rewards ~= nil and rewards:IsA("GuiObject") and rewards.Visible
	end,
	Fighters = function()
		return module.Frame:IsFrameOpened("Fighters")
	end,
	Backpack = function()
		return module.Frame:IsFrameOpened("Backpack")
	end,
	QuestTracker = function()
		local list = quests:FindFirstChild("List")
		return list ~= nil and list:IsA("GuiObject") and list.Visible
	end,
	Multipliers = function()
		local list = multipliers:FindFirstChild("List")
		return list ~= nil and list:IsA("GuiObject") and list.Visible
	end,
	TimeRewards = function()
		return module.Frame:IsFrameOpened("Rewards")
	end
}

local function GetLessonRequirement(p: string)
	return function()
		return module.Frame:IsFrameOpened(p)
	end
end

local function GetBlockingClose(instance2)
	for _, childName in module.Frame:GetOpenedFrames() do
		local child = frames:FindFirstChild(childName)

		if not child or instance2:IsDescendantOf(child) then
			continue
		end

		local button = GetButton(child, "Close") -- equivalent call inferred; original call site unknown

		if button then
			return button
		end
	end

	return nil
end

local function GetLevelGuide(name2: string)
	if not module.Frame:IsFrameOpened(playerLevel) then
		return GetButton(buttons, "PlayerLevel")
	end

	local stats = main2:FindFirstChild("Stats")
	local rewards = main2:FindFirstChild("Rewards")

	if name2 == "LevelStats" then
		return stats and stats.Visible and stats:FindFirstChild("Points")
	end

	if rewards and rewards.Visible then
		return rewards
	end

	return GetButton(frameOptions, "Rewards")
end

local function GetLessonGuide(p: string)
	if module.Frame:IsFrameOpened(p) then
		return nil
	end

	if p == "Achievements" then
		return GetButton(buttons, "Achievements")
	end

	local icon2 = module.Libs.TopBarPlus.getIcon("Menu")

	if not icon2 then
		return nil
	end

	local widget

	if not icon2.isSelected then
		widget = icon2.widget
		return widget
	end

	widget = module.Libs.TopBarPlus.getIcon(p)
	return widget and widget.widget
end

local function ResolveGuides(p, flag2: boolean)
	if flag2 then
		return GetButton(buttons, "Teleport"), nil
	end

	local name2 = p.Name

	if name2 == "Level" then
		return bottom:FindFirstChild("Level"), nil
	end

	if name2 == "LevelStats" or name2 == "LevelRewards" then
		return GetLevelGuide(name2), nil
	end

	if name2 == "FighterAttack" or name2 == "MeleeAttack" or name2 == "CollectYen" then
		return nil, "FirstEnemy"
	end

	if name2 == "OpenStar" then
		if module.Frame:IsFrameOpened("Star") then
			return main, nil
		end

		return nil, "Star"
	elseif name2 == "Fighters" or name2 == "Backpack" then
		if module.Frame:IsFrameOpened(name2) then
			return nil, nil
		end

		return GetButton(buttons, name2), nil
	elseif name2 == "AcceptQuest" then
		local dialogOption = GetDialogOption("Accept Quest") -- equivalent call inferred; original call site unknown

		if module.Frame:IsFrameOpened("Dialog") then
			return dialogOption, nil
		end

		return nil, "Npc"
	elseif name2 == "QuestTracker" then
		local list = quests:FindFirstChild("List")
		local v14

		if list == nil then
			v14 = false
		else
			v14 = list:IsA("GuiObject") and list.Visible
		end

		if v14 then
			return quests:FindFirstChild("List"), nil
		end

		return GetButton(quests, "Arrow"), nil
	elseif name2 == "Multipliers" then
		local list = multipliers:FindFirstChild("List")
		local v14

		if list == nil then
			v14 = false
		else
			v14 = list:IsA("GuiObject") and list.Visible
		end

		if v14 then
			return multipliers:FindFirstChild("List"), nil
		end

		local list2 = quests:FindFirstChild("List")
		local v15

		if list2 == nil then
			v15 = false
		else
			v15 = list2:IsA("GuiObject") and list2.Visible
		end

		if v15 then
			return GetButton(quests, "Arrow"), nil
		end

		return GetButton(multipliers, "Arrow"), nil
	else
		if name2 == "AutoAttack" then
			return GetButton(buttons2, "AutoAttack"), nil
		elseif name2 == "AutoClicker" then
			return GetButton(buttons2, "AutoClicker"), nil
		end

		if name2 == "TimeRewards" then
			if module.Frame:IsFrameOpened("Rewards") then
				return nil, nil
			end

			return GetButton(buttons, "Rewards"), nil
		elseif name2 == "CompleteQuest" then
			if not (name and v4) then
				return nil, "QuestEnemy"
			end

			local v14 = name
			local widget

			if not module.Frame:IsFrameOpened(v14) then
				if v14 == "Achievements" then
					widget = GetButton(buttons, "Achievements")
				else
					local icon2 = module.Libs.TopBarPlus.getIcon("Menu")

					if icon2 then
						if icon2.isSelected then
							widget = GetTopbarWidget(v14)
						else
							widget = icon2.widget
						end
					end
				end
			end

			return widget, "QuestEnemy"
		elseif name2 == "ClaimQuest" then
			local dialogOption = GetDialogOption("Claim Reward") -- equivalent call inferred; original call site unknown

			if module.Frame:IsFrameOpened("Dialog") then
				return dialogOption, nil
			end

			return nil, "Npc"
		else
			if name2 ~= "Teleport" then
				return nil, nil
			end

			if not module.Frame:IsFrameOpened("Teleport") then
				return GetButton(buttons, "Teleport"), nil
			end

			local child = scroll3:FindFirstChild(tutorial.NextMapName)
			local buttons3 = child and child:FindFirstChild("Main") and child.Main:FindFirstChild("Info") and child.Main.Info:FindFirstChild("Buttons")

			if buttons3 then
				buttons3 = GetButton(buttons3, "Teleport")
			end

			return buttons3, nil
		end
	end
end

local function ScanWorldTarget(p: string?)
	if not p then
		v10 = nil
	elseif p == "FirstEnemy" then
		v10 = CreateEnemyTarget(FindNearestEnemy(GetFirstEnemyNames()))
	elseif p == "QuestEnemy" then
		v10 = CreateEnemyTarget(FindNearestEnemy(GetRemainingMissions()))
	elseif p == "Star" then
		v10 = CreateModelTarget(FindTaggedModel("StarModel", tutorial.StarName))
	elseif p == "Npc" then
		v10 = CreateModelTarget(FindTaggedModel("Npc", tutorial.NpcName, maps:FindFirstChild(tutorial.MapName)))
	end
end

local function ClearOptions()
	for k, v14 in v2 do
		v14.Instance:Destroy()
		v14:doCleanup()
		v2[k] = nil
	end
end

local function SetOptions(items)
	local v14 = {}

	for _, item in items do
		v14[item.Text] = true
	end

	for k, v15 in v2 do
		if v14[k] then
			continue
		end

		v15.Instance:Destroy()
		v15:doCleanup()
		v2[k] = nil
	end

	for k, item in items do
		local v15 = v2[item.Text]

		if v15 then
			v15.Callback = item.Callback
			v15.Instance.LayoutOrder = k
		else
			local innerScope = scope2:innerScope()
			innerScope.Text = item.Text
			innerScope.Color = item.Color
			innerScope.LightenedColor = module.Utils.Colors:Lighten(item.Color, 0.5)
			innerScope.Callback = item.Callback
			innerScope:Build(k, k * 0.05)
			v2[item.Text] = innerScope
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CancelMessageTimer()
	if thread then
		task.cancel(thread)
		thread = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HideMessage()
	CancelMessageTimer() -- equivalent call inferred; original call site unknown
	v4 = nil
	name = nil
	v12 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowMessage(p: string, p2: string, text: string, p3, flag2: boolean?, value5: string?)
	CancelMessageTimer() -- equivalent call inferred; original call site unknown
	v4 = p
	v5 = p2
	v7 = value5 or "Bottom"
	name = nil
	v12 = nil
	flag = false
	title.Text = tutorial.Texts.Title
	desc.Text = text
	SetOptions(p3)

	if flag2 then
		thread = task.delay(tutorial.MessageDuration, function()
			thread = nil

			if v5 == p2 then
				HideMessage() -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

local function RequestSkip()
	if module.Frame:IsFrameOpened("Confirmation") then
		return
	end

	module.Scripts.Interface.Confirmation.Start({
		Title = tutorial.Texts.SkipTitle,
		Description = tutorial.Texts.SkipDescription,
		ConfirmText = tutorial.Texts.SkipConfirm,
		CancelText = tutorial.Texts.SkipCancel,
		Callback = function(flag2: boolean)
			if not flag2 then
				return
			end

			module.Signal:Fire("General", "Tutorial", "Skip")
		end
	})
end

local function Answer(flag2: boolean)
	if flag then
		return
	end

	flag = true
	module.Signal:Fire("General", "Tutorial", "Answer", flag2)
	task.delay(2, function()
		flag = false
	end)
end

local function Advance()
	if flag then
		return
	end

	local tutorial3 = GetTutorialData() -- equivalent call inferred; original call site unknown
	local step

	if tutorial3 and tutorial3.Status == "Active" then
		tutorial.GetStep(tutorial3.Step)
		step = tutorial3.Step
	else
		step = 0
	end

	if step <= 0 then
		return
	end

	flag = true
	module.Signal:Fire("General", "Tutorial", "Advance", step)
	task.delay(2, function()
		flag = false
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetSkipOption()
	return {
		Text = tutorial.Texts.Skip,
		Color = color3,
		Callback = RequestSkip
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetGotItOption()
	return {
		Text = tutorial.Texts.GotIt,
		Color = color2,
		Callback = HideMessage
	}
end

local function GetRequiredOptions(option2, requirement)
	if requirement and not requirement() then
		return { GetSkipOption() }, {
			Option = option2,
			Requirement = requirement
		}
	end

	return { option2, GetSkipOption() }, nil
end

local function ShowPrompt()
	local prompt = tutorial.Texts.Prompt
	local v14 = {
		{
			Text = tutorial.Texts.Accept,
			Color = color2,
			Callback = function()
				if flag then
					return
				end

				flag = true
				module.Signal:Fire("General", "Tutorial", "Answer", true)
				task.delay(2, function()
					flag = false
				end)
			end
		},
		{
			Text = tutorial.Texts.Decline,
			Color = color3,
			Callback = function()
				if flag then
					return
				end

				flag = true
				module.Signal:Fire("General", "Tutorial", "Answer", false)
				task.delay(2, function()
					flag = false
				end)
			end
		}
	}
	CancelMessageTimer() -- equivalent call inferred; original call site unknown
	v4 = "Prompt"
	v5 = "Prompt"
	v7 = "Bottom"
	name = nil
	v12 = nil
	flag = false
	title.Text = tutorial.Texts.Title
	desc.Text = prompt
	SetOptions(v14)
end

local function ShowStep(data, step: number)
	local formatted = `Step{step}`

	if data.Kind == "Info" then
		local text

		if #tutorial.Steps <= step then
			text = tutorial.Texts.Finish
		else
			text = tutorial.Texts.Next
		end

		local v17, v18 = GetRequiredOptions({
			Text = text,
			Color = color2,
			Callback = Advance
		}, v13[data.Name])
		local text2 = FormatText(data.Text) -- equivalent call inferred; original call site unknown
		ShowMessage("Step", formatted, text2, v17, false, data.MessagePlacement) -- equivalent call inferred; original call site unknown
		v12 = v18
	else
		ShowMessage(
			"Step",
			formatted,
			FormatText(data.Text),
			{ GetGotItOption(), GetSkipOption() },
			true,
			data.MessagePlacement
		)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowPause()
	local pause = tutorial.Texts.Pause
	local v14 = { GetSkipOption() }
	CancelMessageTimer() -- equivalent call inferred; original call site unknown
	v4 = "Pause"
	v5 = "Pause"
	v7 = "Bottom"
	name = nil
	v12 = nil
	flag = false
	title.Text = tutorial.Texts.Title
	desc.Text = pause
	SetOptions(v14)
end

local function ShowMissionCompleted()
	local remainingMissions = GetRemainingMissions()

	if #remainingMissions == 0 then
		return
	end

	local lesson = tutorial.Lessons[v11]
	local v15 = {
		Enemy = remainingMissions[1]
	}

	if not lesson then
		ShowMessage(
			"Mission",
			`Mission{v11}`,
			tutorial.FormatText(tutorial.Texts.MissionCompleted, IsTouch(), v15),
			{ GetGotItOption(), GetSkipOption() },
			true
		)
		return
	end

	local option2 = GetGotItOption() -- equivalent call inferred; original call site unknown
	local name2 = lesson.Name
	local v18, v19 = GetRequiredOptions(option2, function()
		return module.Frame:IsFrameOpened(name2)
	end)
	local formatted = `Mission{v11}`
	local formatText = tutorial.FormatText(lesson.Text, IsTouch(), v15)
	CancelMessageTimer() -- equivalent call inferred; original call site unknown
	v4 = "Mission"
	v5 = formatted
	v7 = "Bottom"
	name = nil
	v12 = nil
	flag = false
	title.Text = tutorial.Texts.Title
	desc.Text = formatText
	SetOptions(v18)
	name = lesson.Name
	v12 = v19
end

local function IsMessageBlocked()
	if module.Frame:IsFrameOpened("Dialog") or module.Frame:IsFrameOpened("Confirmation") then
		return true
	end

	local stars = module.Scripts.Interface.Stars
	return stars ~= nil and stars.IsRolling() and not stars.IsAutoRolling()
end

local function RenderMessage()
	local v14

	if v4 == nil then
		v14 = false
	else
		v14 = not IsMessageBlocked()
	end

	if v14 == v6 and v7 == v8 then
		return
	end

	if v7 ~= v8 then
		v8 = v7
		spring:setPosition(v[v8].Hidden)
	end

	v6 = v14
	local v15 = v[v8]

	if not v14 then
		value:set(v15.Hidden)
		return
	end

	message.Visible = true
	value:set(v15.Shown)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HideTarget()
	if not target.Visible then
		return
	end

	v9 = nil
	target.Visible = false
end

local function RenderTarget(p)
	local v14, v15

	if p then
		v14, v15 = GetGuiRect(p)
	end

	if v14 and v15 then
		local uDim = UDim2.fromOffset(v14.X, v14.Y)
		local uDim2 = UDim2.fromOffset(v15.X + 12, v15.Y + 12)

		if p ~= v9 then
			if not v9 then
				spring2:setPosition(uDim)
				spring3:setPosition(UDim2.fromOffset(uDim2.X.Offset * 1.6, uDim2.Y.Offset * 1.6))
			end

			v9 = p
			now = os.clock()
		end

		value2:set(uDim)
		value3:set(uDim2)

		if os.clock() - now > 0.6 then
			spring2:setPosition(uDim)
			spring3:setPosition(uDim2)
		end

		uIStroke.Transparency = (math.sin(os.clock() * 5.235987755982989) + 1) / 2 * 0.5
		target.Visible = true
	else
		HideTarget() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HideArrow()
	if not arrow.Visible then
		return
	end

	value4:set(UDim2.fromScale(0, 0))
	spring4:setPosition(UDim2.fromScale(0, 0))
	arrow.Visible = false
end

local function RenderArrow()
	local v14 = v10 and GetWorldPoint(v10)

	if v14 then
		local currentCamera = workspace.CurrentCamera
		local absolutePosition = GetOrigin() -- equivalent call inferred; original call site unknown
		local absoluteSize = tutorial2.AbsoluteSize
		local worldToScreenPoint, v16 = currentCamera:WorldToScreenPoint(v14)
		local v17 = Vector2.new(worldToScreenPoint.X, worldToScreenPoint.Y) - absolutePosition

		if not arrow.Visible then
			arrow.Visible = true
			value4:set(size2)
		end

		if v16 then
			if v17.X >= 0 and v17.Y >= 0 and v17.X <= absoluteSize.X then
				v16 = v17.Y <= absoluteSize.Y
			else
				v16 = false
			end
		end

		if v16 then
			local v18 = math.sin(os.clock() * 4) * 10
			local v19 = arrow.AbsoluteSize.Y / 2 + v18
			arrow.Position = UDim2.fromOffset(v17.X, v17.Y - v19)
			icon.Rotation = 270
		else
			local pointToObjectSpace = currentCamera.CFrame:PointToObjectSpace(v14)
			local vector2 = Vector2.new(pointToObjectSpace.X, -pointToObjectSpace.Y)

			if pointToObjectSpace.Z > 0 then
				vector2 = Vector2.new(pointToObjectSpace.X, (math.abs(pointToObjectSpace.Z)))
			end

			if vector2.Magnitude < 0.001 then
				vector2 = Vector2.new(0, 1)
			end

			local halfAbsoluteSize = absoluteSize / 2
			local v19 = halfAbsoluteSize - absoluteSize * 0.08
			local v20 = halfAbsoluteSize + vector2 * math.min(
				v19.X / math.max(math.abs(vector2.X), 0.001),
				v19.Y / math.max(math.abs(vector2.Y), 0.001)
			)
			arrow.Position = UDim2.fromOffset(v20.X, v20.Y)
			icon.Rotation = math.deg((math.atan2(vector2.X, -vector2.Y))) + 90
		end
	else
		HideArrow() -- equivalent call inferred; original call site unknown
	end
end

local function RenderLockedOption()
	if not (v12 and v4 and v12.Requirement()) then
		return
	end

	local option2 = v12.Option
	v12 = nil
	SetOptions({ option2, GetSkipOption() })
end

local function RenderLesson()
	if not name or v4 ~= "Mission" or not module.Frame:IsFrameOpened(name) then
		return
	end

	HideMessage() -- equivalent call inferred; original call site unknown
end

local function Render()
	if name and v4 == "Mission" and module.Frame:IsFrameOpened(name) then
		HideMessage() -- equivalent call inferred; original call site unknown
	end

	RenderMessage()
	RenderLockedOption()
	local tutorial3 = GetTutorialData() -- equivalent call inferred; original call site unknown
	local v15, step

	if tutorial3 and tutorial3.Status == "Active" then
		v15 = tutorial.GetStep(tutorial3.Step)
		step = tutorial3.Step
	else
		step = 0
	end

	if v15 then
		local paused = IsPaused(v15, step) -- equivalent call inferred; original call site unknown
		local v17, v18 = ResolveGuides(v15, paused)

		if v17 and not GetGuiRect(v17) then
			v17 = GetBlockingClose(v17) or v17
		end

		if os.clock() - now2 >= 0.25 then
			now2 = os.clock()
			ScanWorldTarget(v18)
		elseif not v18 then
			v10 = nil
		end

		RenderTarget(v17)
		RenderArrow()
	else
		HideTarget() -- equivalent call inferred; original call site unknown
		HideArrow() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetRendering(flag2: boolean)
	if flag2 and not renderSteppedConnection then
		renderSteppedConnection = runService.RenderStepped:Connect(Render)
	elseif not flag2 and renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

local function RefreshSkipIcon(flag2: boolean)
	if flag2 and not topBarPlus then
		topBarPlus = module.Libs.TopBarPlus.new()
		topBarPlus:setName("SkipTutorial")
		topBarPlus:setLabel(tutorial.Texts.SkipTitle)
		topBarPlus:align("Left")
		topBarPlus:oneClick(true)
		topBarPlus:bindEvent("deselected", RequestSkip)
	elseif not flag2 and topBarPlus then
		topBarPlus:destroy()
		topBarPlus = nil
	end
end

function Tutorial.Refresh()
	if not (v3 and module.Shared.TimeChamber.Check(module.Instance)) then
		return
	end

	local tutorial3 = GetTutorialData() -- equivalent call inferred; original call site unknown
	local status = tutorial3 and tutorial3.Status
	RefreshSkipIcon(status == "Active")

	if status == "None" then
		if not renderSteppedConnection then
			renderSteppedConnection = runService.RenderStepped:Connect(Render)
		end

		if v5 ~= "Prompt" or v4 == nil then
			ShowPrompt()
		end
	elseif status == "Active" then
		if not renderSteppedConnection then
			renderSteppedConnection = runService.RenderStepped:Connect(Render)
		end

		local tutorial4 = GetTutorialData() -- equivalent call inferred; original call site unknown
		local v16, step

		if tutorial4 and tutorial4.Status == "Active" then
			v16 = tutorial.GetStep(tutorial4.Step)
			step = tutorial4.Step
		else
			step = 0
		end

		if not v16 then
			return
		end

		-- equivalent call inferred; original call site unknown
		if IsPaused(v16, step) then
			if v5 ~= "Pause" then
				ShowPause() -- equivalent call inferred; original call site unknown
			end
		else
			local formatted = `Step{step}`

			if v5 ~= formatted and (not v5 or not string.find(v5, "^Mission") or v16.Name ~= "CompleteQuest") then
				v11 = CountCompletedMissions()
				ShowStep(v16, step)
			end
		end
	else
		HideMessage() -- equivalent call inferred; original call site unknown
		v5 = nil
		SetRendering(false) -- equivalent call inferred; original call site unknown
		HideTarget() -- equivalent call inferred; original call site unknown
		HideArrow() -- equivalent call inferred; original call site unknown
		RenderMessage()
	end
end

function Tutorial.RefreshMissions()
	local tutorial3 = GetTutorialData() -- equivalent call inferred; original call site unknown
	local v15

	if tutorial3 and tutorial3.Status == "Active" then
		v15 = tutorial.GetStep(tutorial3.Step)
		local _ = tutorial3.Step
	end

	if not v15 or v15.Name ~= "CompleteQuest" then
		return
	end

	local countCompletedMissions = CountCompletedMissions()

	if countCompletedMissions <= v11 then
		return
	end

	v11 = countCompletedMissions
	ShowMissionCompleted()
end

function Tutorial.Init()
	task.spawn(function()
		while playerGui:FindFirstChild("LoadingScreen") do
			playerGui.ChildRemoved:Wait()
		end

		v3 = true
		Tutorial.Refresh()
	end)
end

message.Visible = false
target.Visible = false
arrow.Visible = false
scope:Hydrate(message)({
	Position = spring
})
scope:Hydrate(target)({
	Position = spring2,
	Size = spring3
})
scope:Hydrate(arrow)({
	Size = spring4
})
scope:Observer(spring):onBind(function()
	if v6 or math.abs(scope.peek(spring).Y.Scale - v[v8].Hidden.Y.Scale) > 0.01 then
		return
	end

	message.Visible = false

	if not v4 then
		ClearOptions()
	end
end)
module:OnDataChanged({ "Tutorial" }, Tutorial.Refresh)
module:OnDataChanged({ "Maps" }, Tutorial.Refresh)
module:OnDataChanged({ "Gamemode" }, Tutorial.Refresh)
module:OnDataChanged({ "Quests" }, Tutorial.RefreshMissions)
return Tutorial