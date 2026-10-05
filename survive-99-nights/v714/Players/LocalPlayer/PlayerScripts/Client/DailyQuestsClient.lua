local DailyQuestsClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local thread = nil
local questLabel = Client.Interface.QuestLabel
local flag = false
local v = {}

function UpdateQuestProgress()
	local v2 = CollectionService:GetTagged("QuestProgressBoard")[1]
	local dailyQuests = localPlayer:FindFirstChild("DailyQuests")
	print("QUESTS", v2, dailyQuests)

	if not v2 then
		return
	end

	if not dailyQuests then
		v2.Parent = game.ReplicatedStorage
		return
	end

	local count = 0

	for _, child in pairs(dailyQuests:GetChildren()) do
		local v3 = v2:WaitForChild("Main").SurfaceGui.Frame[child.Name]
		local description = child:GetAttribute("Description") or ""

		if description and description ~= "" then
			count += 1
			v3.Visible = true
		else
			v3.Visible = false
		end

		local v4 = tonumber((string.sub(child.Name, 6)))

		if child:GetAttribute("Goal1") then
			description ..= "<br/>" .. (child:GetAttribute("Progress1") or 0) .. "/" .. child:GetAttribute("Goal1")
		end

		if child:GetAttribute("Completed") then
			description = "<s>" .. description .. "</s>"
		end

		local text = "<b>" .. v4 .. ". </b>" .. description
		v3.TextLabel.Text = text
	end

	if count > 0 then
		v2.Parent = workspace.Map.Campground.NoticeBoard
	else
		v2.Parent = game.ReplicatedStorage
	end
end

function GuiHide(p)
	if thread then
		task.cancel(thread)
		thread = nil
	end

	if p then
		flag = true
	end

	thread = task.delay(p and 9 or 5.5, function()
		questLabel.Visible = false
		thread = nil
		flag = false
	end)
end

function QuestProgressNotification()
	if flag then
		return
	end

	questLabel.Visible = true
	questLabel.Text = "+ quest"
	questLabel.TextColor3 = Color3.fromRGB(0, 236, 216)
	GuiHide()
end

function QuestCompleteNotification()
	questLabel.Visible = true
	questLabel.Text = "quest complete"
	questLabel.TextColor3 = Color3.fromRGB(236, 216, 0)
	GuiHide(true)
end

Client.Events.DailyQuestUpdated:Connect(function(_)
	QuestProgressNotification()
end)
Client.Events.DailyQuestComplete:Connect(function(p)
	if v[p] then
		return
	end

	v[p] = true
	QuestCompleteNotification()
end)

function DailyQuestsClient.Init()
	task.spawn(function()
		UpdateQuestProgress()
		CollectionService:GetInstanceAddedSignal("QuestProgressBoard"):Connect(UpdateQuestProgress)
		local dailyQuests = localPlayer:WaitForChild("DailyQuests")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function childAdded(child)
			child.AttributeChanged:Connect(UpdateQuestProgress)
		end

		dailyQuests.ChildAdded:Connect(childAdded)

		for _, child in pairs(dailyQuests:GetChildren()) do
			childAdded(child) -- equivalent call inferred; original call site unknown
		end

		UpdateQuestProgress()
	end)
end

return DailyQuestsClient