local ConversationHandler = {}
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local v = nil
local v2 = nil
local uuid = nil
local v3 = nil
local v4 = {}
local v5 = {}
local cameraType = nil
local cameraSubject = nil
local localPlayer = Players.LocalPlayer
local v6 = {}
local absoluteSizeChangedConnection = nil
local flag = false
local v7 = {
	questionSetInit = {},
	questionSetQuestion = {},
	questionSetResponse = {}
}

function deepClone(items)
	if type(items) ~= "table" then
		return items
	end

	local clonesByClone = {}

	for k, item in items do
		clonesByClone[deepClone(k)] = deepClone(item)
	end

	return clonesByClone
end

local clone = deepClone(v7)
local v8 = nil
local now = 0
local serverTimeNow = 0
local v9 = {
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9"
}
local v10 = { "1", "2", "3" }
local v11 = { 6484864709 }
local aDMSurvey = game.ReplicatedStorage:WaitForChild("ADM-Survey")
local v12 = nil
local v13 = {
	screenGui = script.Parent.AdTechSurveyUI,
	mainHolder = script.Parent.AdTechSurveyUI.MainHolder,
	question = script.Parent.AdTechSurveyUI.MainHolder.DialogBox.Contents,
	npcName = script.Parent.AdTechSurveyUI.MainHolder.DialogBox.NpcName.Contents,
	["1"] = script.Parent.AdTechSurveyUI.MainHolder.Answers12.Answer1.Contents,
	["2"] = script.Parent.AdTechSurveyUI.MainHolder.Answers12.Answer2.Contents,
	["3"] = script.Parent.AdTechSurveyUI.MainHolder.Answers34.Answer3.Contents,
	["4"] = script.Parent.AdTechSurveyUI.MainHolder.Answers34.Answer4.Contents,
	["5"] = script.Parent.AdTechSurveyUI.MainHolder.Answers56.Answer5.Contents,
	["6"] = script.Parent.AdTechSurveyUI.MainHolder.Answers56.Answer6.Contents,
	["7"] = script.Parent.AdTechSurveyUI.MainHolder.Answers78.Answer7.Contents,
	["8"] = script.Parent.AdTechSurveyUI.MainHolder.Answers78.Answer8.Contents,
	["9"] = script.Parent.AdTechSurveyUI.MainHolder.Answers910.Answer9.Contents,
	["10"] = script.Parent.AdTechSurveyUI.MainHolder.Answers910.Answer10.Contents,
	submitBtn1 = script.Parent.AdTechSurveyUI.MainHolder.Answers56.SubmitBtn.Contents,
	submitBtn2 = script.Parent.AdTechSurveyUI.MainHolder.Answers78.SubmitBtn.Contents,
	submitBtn3 = script.Parent.AdTechSurveyUI.MainHolder.Answers910.SubmitBtn.Contents,
	exitBtn = script.Parent.AdTechSurveyUI.MainHolder.DialogBox.ExitFrame.Trigger
}
ConversationHandler.dialogClosed = Instance.new("BindableEvent")

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentTimeStamp()
	return serverTimeNow + (os.time() - now)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function trackQuestionSetStart(flag2: boolean, completed: boolean)
	if not v3 then
		return
	end

	if flag2 then
		clone.questionSetInit.endTime = getCurrentTimeStamp()
		clone.questionSetInit.completed = completed
	else
		clone.questionSetInit.uuid = v3.uuid
		clone.questionSetInit.startTime = getCurrentTimeStamp()
	end
end

local function trackQuestionAsked(flag2: boolean)
	if clone.questionSetQuestion[v8.uuid] then
		clone.questionSetQuestion[v8.uuid].endTime = getCurrentTimeStamp()
		return
	end

	if flag2 then
		return
	end

	clone.questionSetQuestion[v8.uuid] = {
		startTime = getCurrentTimeStamp()
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function trackQuestionResponse(uuid2: string)
	clone.questionSetResponse[uuid2] = v8.uuid
end

local function sendCachedEvents(p)
	if not (clone.questionSetInit.startTime and clone.questionSetInit.endTime and clone.questionSetInit.uuid) then
		return
	end

	aDMSurvey:FireServer("Conversation", clone)
	clone = deepClone(v7)

	if p then
		v12(uuid)
	end
end

local v14 = {
	star = "🤩",
	slightSmile = "🙂",
	neutral = "😐",
	confused = "😕",
	check = "✅",
	cross = "❌",
	thinking = "🤔",
	sunglasses = "😎",
	prohibited = "🚫",
	grinning = "😀"
}
local v15 = {
	[Enum.CreatorType.User] = {
		[68816760] = "Barry's Prison Run",
		[3339860557] = "Blade Ball"
	},
	[Enum.CreatorType.Group] = {
		[7381705] = "FISCH",
		[12836673] = "Blade Ball",
		[35639019] = "Group owned"
	}
}
local v16 = v15[game.CreatorType] and v15[game.CreatorType][game.CreatorId] or "this game"

local function translateToEmojis(value)
	return (value:gsub("%[(%w+)%]", function(p)
		return v14[p] or ""
	end):gsub("{GameName}", v16))
end

local function convertCodesInQuestionSet(p)
	for _, question in p.questions do
		question.text = question.text:gsub("%[(%w+)%]", function(p2)
			return v14[p2] or ""
		end):gsub("{GameName}", v16)

		for _, respons in question.responses do
			respons.text = respons.text:gsub("%[(%w+)%]", function(p2)
				return v14[p2] or ""
			end):gsub("{GameName}", v16)
		end
	end

	return p
end

local function getBestTextSize(_1, text: string)
	local v17 = 0

	for i = 1, 38 do
		local textSize = TextService:GetTextSize(text, i, _1.Font, Vector2.new(_1.AbsoluteSize.X, 1e999))

		if textSize.X + 1 > _1.AbsoluteSize.X or textSize.Y + 1 > _1.AbsoluteSize.Y then
			return v17
		end

		v17 = i
	end

	return v17
end

local function calculateQuestionSize(textSize: number)
	local v17 = math.clamp(
		TextService:GetTextSize(v8.text, textSize, v13.question.Font, Vector2.new(v13.question.AbsoluteSize.X, 1e999)).Y / (v13.question.Size.Y.Scale * 0.9),
		v13.question.Parent.NpcName.AbsoluteSize.Y * 2.5,
		1e999
	)
	v13.question.Parent.Size = UDim2.new(1, 0, 0, v17)
	v13.question.TextSize = textSize
end

local function calculateBestGlobalSize()
	if not v3 then
		return
	end

	local textSize = 500

	for _, question in v3.questions do
		for _, respons in question.responses do
			local bestTextSize = getBestTextSize(v13["1"], respons.text)

			if bestTextSize < textSize then
				textSize = bestTextSize
			end
		end
	end

	for _, v18 in pairs(v9) do
		v13[v18].TextSize = textSize
	end

	for _, v18 in pairs(v10) do
		v13["submitBtn" .. v18].TextSize = textSize
	end

	calculateQuestionSize(textSize)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshDialogUiSize()
	if v8 and v3 then
		calculateBestGlobalSize()
	end
end

local function checkSubmitBtn()
	if next(v4) then
		for _, v17 in v10 do
			v13["submitBtn" .. v17].Parent.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
			v13["submitBtn" .. v17].TextColor3 = Color3.fromRGB(0, 208, 101)
		end
	else
		for _, v17 in v10 do
			v13["submitBtn" .. v17].Parent.BackgroundColor3 = Color3.fromRGB(159, 159, 159)
			v13["submitBtn" .. v17].TextColor3 = Color3.fromRGB(93, 93, 93)
		end
	end
end

local function toggleSelectionUI(p: string, flag2: boolean)
	local parent = v13[p].Parent

	if flag2 then
		v4[p] = true
		v5[p .. "Activated"]:Play()
		parent.Contents.TextColor3 = Color3.fromRGB(255, 255, 255)
		parent.UIStroke.Enabled = true
	else
		v4[p] = nil
		v5[p .. "Activated"]:Cancel()
		parent.Contents.TextColor3 = Color3.fromRGB(0, 0, 0)
		parent.UIGradient.Offset = Vector2.new(0, 1)
		parent.UIStroke.Enabled = false
	end

	checkSubmitBtn()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearSelectionUI()
	for _, v17 in v9 do
		local parent = v13[v17].Parent
		v4[v17] = nil
		v5[v17 .. "Activated"]:Cancel()
		parent.Contents.TextColor3 = Color3.fromRGB(0, 0, 0)
		parent.UIGradient.Offset = Vector2.new(0, 1)
		parent.UIStroke.Enabled = false
		checkSubmitBtn()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleProximityPrompts(enabled: boolean)
	for _, v17 in v6 do
		v17.Enabled = enabled
	end
end

local function closeDialog(completed: boolean)
	if not v2 then
		return
	end

	trackQuestionSetStart(true, completed) -- equivalent call inferred; original call site unknown
	v2 = nil
	task.spawn(sendCachedEvents, completed)
	v13.screenGui.Enabled = false
	v13.screenGui.MainHolder.Visible = false
	ConversationHandler.dialogClosed:Fire()
	toggleProximityPrompts(true) -- equivalent call inferred; original call site unknown

	if absoluteSizeChangedConnection then
		absoluteSizeChangedConnection:Disconnect()
		absoluteSizeChangedConnection = nil
	end

	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = cameraType

	if cameraSubject and cameraSubject:IsDescendantOf(workspace) then
		currentCamera.CameraSubject = cameraSubject
	else
		currentCamera.CameraSubject = localPlayer.Character
	end
end

local function askQuestion()
	local v17 = v2
	trackQuestionAsked()
	clearSelectionUI() -- equivalent call inferred; original call site unknown
	refreshDialogUiSize() -- equivalent call inferred; original call site unknown

	for i = 1, 9 do
		if v8.responses[i] then
			v13[tostring(i)].Text = v8.responses[i].text
		end

		v13[tostring(i)].Parent.Visible = false
	end

	for _, v18 in v10 do
		v13["submitBtn" .. v18].Parent.Visible = false
	end

	v13["3"].Parent.Parent.Visible = v8.responses[3] and true or false
	v13["5"].Parent.Parent.Visible = v8.responses[5] and true or false
	v13["7"].Parent.Parent.Visible = v8.responses[7] and true or false
	v13["9"].Parent.Parent.Visible = v8.responses[9] and true or false
	flag = false

	for i = 1, #v8.text do
		if flag then
			v13.question.Text = v8.text
			break
		end

		if v2 ~= v17 then
			return
		end

		v13.question.Text = string.sub(v8.text, 1, i)
		task.wait(0.02)
	end

	for i = 1, #v8.responses do
		v13[tostring(i)].Parent.Visible = true
	end

	if not v8.is_multiple_choice then
		return
	end

	if v8.responses[8] or v8.responses[9] then
		v13.submitBtn3.Parent.Visible = true
		v13.submitBtn3.Parent.Parent.Visible = true
	elseif v8.responses[7] or v8.responses[6] then
		v13.submitBtn2.Parent.Visible = true
		v13.submitBtn2.Parent.Parent.Visible = true
	else
		v13.submitBtn1.Parent.Visible = true
		v13.submitBtn1.Parent.Parent.Visible = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function nextQuestion()
	if clone.questionSetQuestion[v8.uuid] then
		clone.questionSetQuestion[v8.uuid].endTime = getCurrentTimeStamp()
	end

	local v17

	if v3.questions[v + 1] then
		v17 = v + 1
	end

	if not v17 then
		closeDialog(true)
		return
	end

	v8 = v3.questions[v17]
	v = v17
	askQuestion()
end

function ConversationHandler.startDialog(p, p2, cFrame)
	if not absoluteSizeChangedConnection then
		absoluteSizeChangedConnection = v13.screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshDialogUiSize)
	end

	closeDialog()
	clearSelectionUI() -- equivalent call inferred; original call site unknown
	toggleProximityPrompts(false) -- equivalent call inferred; original call site unknown
	v = 1
	local v17 = convertCodesInQuestionSet(p)
	v3 = v17
	v8 = v17.questions[v]

	if v3 then
		clone.questionSetInit.uuid = v3.uuid
		clone.questionSetInit.startTime = getCurrentTimeStamp()
	end

	local GUID = HttpService:GenerateGUID(false)
	v2 = GUID
	uuid = p2.uuid
	cameraType = game.Workspace.CurrentCamera.CameraType
	cameraSubject = game.Workspace.CurrentCamera.CameraSubject
	local tween = TweenService:Create(game.Workspace.CurrentCamera, TweenInfo.new(0.5), {
		CFrame = cFrame
	})
	game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	tween:Play()
	tween.Completed:Wait()
	v13.screenGui.Enabled = true
	v13.screenGui.MainHolder.Visible = true
	v13.npcName.Text = p2.name
	task.spawn(function()
		while v2 == GUID do
			if not localPlayer.Character then
				closeDialog()
				break
			end

			local humanoid = localPlayer.Character:FindFirstChild("Humanoid")

			if humanoid and humanoid.Health > 0 or table.find(v11, game.PlaceId) then
				task.wait(0.5)
			else
				closeDialog()
				break
			end
		end
	end)
	askQuestion()
end

function ConversationHandler.addProximityPrompt(p)
	table.insert(v6, p)
end

function ConversationHandler.init(p)
	serverTimeNow = math.floor((workspace:GetServerTimeNow()))
	now = os.time()
	v12 = p

	for _, v17 in v9 do
		v5[v17 .. "Activated"] = TweenService:Create(v13[v17].Parent.UIGradient, TweenInfo.new(0.35), {
			Offset = Vector2.new(0, -1)
		})
		local tween = TweenService:Create(v13[v17].Parent.UIGradient, TweenInfo.new(0.35), {
			Offset = Vector2.new(0, 0.5)
		})
		local tween2 = TweenService:Create(v13[v17].Parent.UIGradient, TweenInfo.new(0.35), {
			Offset = Vector2.new(0, 1)
		})
		local v18 = v17
		v13[v17].Parent.Trigger.MouseEnter:Connect(function()
			if not v4[v18] then
				tween:Play()
			end
		end)
		local v20 = v17
		v13[v17].Parent.Trigger.MouseLeave:Connect(function()
			if not v4[v20] then
				tween2:Play()
			end
		end)
		local v22 = v17
		v13[v17].Parent.Trigger.Activated:Connect(function()
			if v4[v22] then
				local v23 = v22
				local parent = v13[v23].Parent
				v4[v23] = nil
				v5[v23 .. "Activated"]:Cancel()
				parent.Contents.TextColor3 = Color3.fromRGB(0, 0, 0)
				parent.UIGradient.Offset = Vector2.new(0, 1)
				parent.UIStroke.Enabled = false
				checkSubmitBtn()
			elseif v8.is_multiple_choice then
				local v23 = v22
				local parent = v13[v23].Parent
				v4[v23] = true
				v5[v23 .. "Activated"]:Play()
				parent.Contents.TextColor3 = Color3.fromRGB(255, 255, 255)
				parent.UIStroke.Enabled = true
				checkSubmitBtn()

				for k, v24 in v4 do
					if not (v24 and k ~= v22 and (v8.responses[tonumber(v22)].is_single_choice or v8.responses[tonumber(k)].is_single_choice)) then
						continue
					end

					local parent2 = v13[k].Parent
					v4[k] = nil
					v5[k .. "Activated"]:Cancel()
					parent2.Contents.TextColor3 = Color3.fromRGB(0, 0, 0)
					parent2.UIGradient.Offset = Vector2.new(0, 1)
					parent2.UIStroke.Enabled = false
					checkSubmitBtn()
				end
			else
				trackQuestionResponse(v8.responses[tonumber(v22)].uuid) -- equivalent call inferred; original call site unknown

				if v8.responses[tonumber(v22)].termination then
					closeDialog()
					return
				end

				nextQuestion() -- equivalent call inferred; original call site unknown
			end
		end)
	end

	for _, v17 in v10 do
		v13["submitBtn" .. v17].Parent.Trigger.Activated:Connect(function()
			if next(v4) == nil then
				return
			end

			for k, v18 in v4 do
				if not v18 then
					continue
				end

				trackQuestionResponse(v8.responses[tonumber(k)].uuid) -- equivalent call inferred; original call site unknown
			end

			nextQuestion() -- equivalent call inferred; original call site unknown
		end)
	end

	v13.screenGui.Enabled = false
	v13.screenGui.MainHolder.Visible = false
	v13.screenGui.Parent = localPlayer.PlayerGui
	v13.exitBtn.Activated:Connect(function()
		closeDialog()
	end)
end

refreshDialogUiSize() -- equivalent call inferred; original call site unknown
return ConversationHandler