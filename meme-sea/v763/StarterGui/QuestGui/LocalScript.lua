local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local questEvents = otherEvent:WaitForChild("QuestEvents")
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
local quest = questEvents:WaitForChild("Quest")
local localPlayer = Players.LocalPlayer
local questFolder = localPlayer:WaitForChild("QuestFolder", 60)
local playerData = localPlayer:WaitForChild("PlayerData")
local thaiLanguage = localPlayer:WaitForChild("PlayerSettings"):WaitForChild("ThaiLanguage")
local currentQuest = playerData:WaitForChild("CurrentQuest")
local maxQuest = playerData:WaitForChild("MaxQuest")
local questSlot1 = questFolder:WaitForChild("QuestSlot1")
local questSlot2 = questFolder:WaitForChild("QuestSlot2")
local target = questSlot1:WaitForChild("Target")
local target2 = questSlot2:WaitForChild("Target")
local amount = questSlot1:WaitForChild("Amount")
local amount2 = questSlot2:WaitForChild("Amount")
questSlot1:WaitForChild("Need")
questSlot2:WaitForChild("Need")
local holder = script.Parent.Holder
local questText = holder.QuestText
local questSlot12 = holder.QuestSlot1
local questSlot22 = holder.QuestSlot2

if UserInputService.TouchEnabled == true then
	holder.Position = UDim2.new(0.01, 0, 0.14, -100)
else
	holder.Position = UDim2.new(0.01, 0, 0.1, 0)
end

local function QuestChanged(data, state)
	if data.Target.Value == "None" then
		if state.Visible == true then
			state.Visible = false
		end
	else
		if state.Visible == false then
			state.Visible = true
		end

		if data.Amount.Value >= data.Need.Value then
			TweenService:Create(
				state.ProgressBar.Bar,
				TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Size = UDim2.new(1, 0, 1, 0)
				}
			):Play()
		else
			TweenService:Create(
				state.ProgressBar.Bar,
				TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
				{
					Size = UDim2.new(data.Amount.Value / data.Need.Value, 1, 1, 0)
				}
			):Play()
		end

		local formatted

		if string.len((localPlayer:GetAttribute("MoneyBoost"))) >= 5 then
			formatted = Abbreviate.Format(localPlayer:GetAttribute("MoneyBoost"), 2)
		else
			formatted = localPlayer:GetAttribute("MoneyBoost")
		end

		local formatted2

		if string.len((localPlayer:GetAttribute("ExpBoost"))) >= 5 then
			formatted2 = Abbreviate.Format(localPlayer:GetAttribute("ExpBoost"), 2)
		else
			formatted2 = localPlayer:GetAttribute("ExpBoost")
		end

		state.Money.Text = `${Abbreviate.Comma(data.MoneyReward.Value)} ({formatted}x)`
		state.QuestGiver.Text = `{data.QuestGiver.Value}`

		if localPlayer:GetAttribute("TH") then
			if data.QuestGiver.Value == "Cool Floppa Quest" then
				state.Target.Text = `คลิก {data.Target.Value} ({data.Amount.Value}/{data.Need.Value}) `
				state.Exp.Text = "x1 Floppa (อาวุธ)"
			elseif data.QuestGiver.Value == "Dancing Banana Quest" then
				state.Target.Text = `จัดการ {data.Target.Value} ({data.Amount.Value}/{data.Need.Value}) `
				state.Exp.Text = "x1 Awakening Orb"
			else
				state.Target.Text = `จัดการ {data.Target.Value} ({data.Amount.Value}/{data.Need.Value}) `
				state.Exp.Text = `{Abbreviate.Comma(data.ExpReward.Value)} ค่าประสบการณ์ ({formatted2}x)`
			end
		elseif data.QuestGiver.Value == "Cool Floppa Quest" then
			state.Target.Text = `Click {data.Target.Value} ({data.Amount.Value}/{data.Need.Value}) `
			state.Exp.Text = "1x Floppa (Weapon)"
		elseif data.QuestGiver.Value == "Dancing Banana Quest" then
			state.Target.Text = `Defeat {data.Target.Value} ({data.Amount.Value}/{data.Need.Value}) `
			state.Exp.Text = "1x Awakening Orb"
		else
			state.Target.Text = `Defeat {data.Target.Value} ({data.Amount.Value}/{data.Need.Value}) `
			state.Exp.Text = `{Abbreviate.Comma(data.ExpReward.Value)} Exp ({formatted2}x)`
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AbandonQuest(name)
	quest:FireServer("Abandon_Quest", {
		QuestSlot = name
	})
end

local function ShowQuestTasks()
	if currentQuest.Value < 1 then
		if questText.Visible == true then
			questText.Visible = false
		end
	elseif currentQuest.Value >= 1 then
		QuestChanged(questSlot1, questSlot12)
		QuestChanged(questSlot2, questSlot22)

		if questText.Visible == false then
			questText.Visible = true
		end

		if thaiLanguage.Value == true then
			questText.Text = `แถบภารกิจ [{currentQuest.Value}/{maxQuest.Value}]`
		else
			questText.Text = `Quest Tasks [{currentQuest.Value}/{maxQuest.Value}]`
		end
	end
end

QuestChanged(questSlot1, questSlot12)
QuestChanged(questSlot2, questSlot22)
questSlot12.CloseFrame.Close.Activated:Connect(function()
	AbandonQuest(questSlot1.Name) -- equivalent call inferred; original call site unknown
end)
questSlot22.CloseFrame.Close.Activated:Connect(function()
	AbandonQuest(questSlot2.Name) -- equivalent call inferred; original call site unknown
end)
target.Changed:Connect(function()
	QuestChanged(questSlot1, questSlot12)
end)
target2.Changed:Connect(function()
	QuestChanged(questSlot2, questSlot22)
end)
amount.Changed:Connect(function()
	QuestChanged(questSlot1, questSlot12)
end)
amount2.Changed:Connect(function()
	QuestChanged(questSlot2, questSlot22)
end)
currentQuest.Changed:Connect(ShowQuestTasks)
maxQuest.Changed:Connect(ShowQuestTasks)