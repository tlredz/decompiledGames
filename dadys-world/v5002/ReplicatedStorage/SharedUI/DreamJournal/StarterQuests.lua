local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MyDataController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MyDataController"))
local DandysBudsMissions = require(ReplicatedStorage:WaitForChild("SharedData"):WaitForChild("DandysBudsMissions"))
return function(object)
	local page = object:FindPage("StarterQuests")
	local margin = page and page:FindFirstChild("Margin")
	local quests = margin and margin:FindFirstChild("Quests")
	local scrollingFrame = quests and quests:FindFirstChild("ScrollingFrame")
	local template = scrollingFrame and scrollingFrame:FindFirstChild("Template")

	if not template then
		warn("[StarterQuests] ScrollingFrame.Template not found")
		return
	end

	template.Parent = nil
	local details = margin and margin:FindFirstChild("Details")
	local progressFrame = details and details:FindFirstChild("ProgressFrame")
	local imageLabel = details and details:FindFirstChild("ImageLabel")

	if progressFrame then
		object.styleController:Apply(progressFrame, "Shared.Journal.progressFrame")
	end

	local missions = nil

	local function calculateQuestProgress()
		local count = #DandysBudsMissions

		if count == 0 then
			return 0
		end

		local count2 = 0

		for _, dandysBudsMission in ipairs(DandysBudsMissions) do
			if (not missions and 0 or missions[dandysBudsMission.MissionKey] or 0) >= dandysBudsMission.MaxValue then
				count2 += 1
			end
		end

		return (math.floor(count2 / count * 100))
	end

	local function setRowProgress(instance, p, maxValue, description)
		local v = maxValue <= p
		local description2 = instance:FindFirstChild("Description", true)

		if description2 and (description2:IsA("TextLabel") or description2:IsA("TextButton")) and not v then
			if maxValue > 1 then
				description2.Text = string.format("%s (%d/%d)", description, p, maxValue)
			else
				description2.Text = description
			end
		end

		if v then
			description2.Text = description
			local margin2 = instance:FindFirstChild("Margin")

			if margin2 then
				margin2.BackgroundColor3 = Color3.fromRGB(149, 249, 149)
				margin2.BackgroundTransparency = 0.62
			end

			local status = instance:FindFirstChild("Status", true)

			if status then
				local complete = status:FindFirstChild("Complete")
				local incomplete = status:FindFirstChild("Incomplete")

				if complete then
					complete.Visible = true
				end

				if incomplete then
					incomplete.Visible = false
				end
			end

			local title = instance:FindFirstChild("Title", true)

			if title and (title:IsA("TextLabel") or title:IsA("TextButton")) then
				title.TextColor3 = Color3.fromRGB(5, 63, 1)
				title.TextTransparency = 0.735
			end

			if description2 and (description2:IsA("TextLabel") or description2:IsA("TextButton")) then
				description2.TextColor3 = Color3.fromRGB(5, 63, 1)
				description2.TextTransparency = 0.53
			end
		end
	end

	local clonesByMissionKey = {}

	for _, dandysBudsMission in ipairs(DandysBudsMissions) do
		local clone = template:Clone()
		clone.Name = dandysBudsMission.MissionKey
		clone.LayoutOrder = dandysBudsMission.LayoutOrder
		clone.Visible = true
		local title = clone:FindFirstChild("Title", true)

		if title and (title:IsA("TextLabel") or title:IsA("TextButton")) then
			title.Text = dandysBudsMission.Title
		end

		setRowProgress(clone, 0, dandysBudsMission.MaxValue, dandysBudsMission.Description)
		clone.Parent = scrollingFrame
		clonesByMissionKey[dandysBudsMission.MissionKey] = clone
	end

	MyDataController:onReplicaReady(function(object2)
		missions = object2.Data and object2.Data.DandysBud and object2.Data.DandysBud.Missions

		local function updateTotalProgress()
			local v = calculateQuestProgress()
			progressFrame:SetAttribute("Progress", v)
			local uIGradient = imageLabel.ProgressShadow:WaitForChild("UIGradient")
			uIGradient.Offset = Vector2.new(0, 1 - v / 100)
			imageLabel.ProgressHint.UIGradient.Offset = Vector2.new(0, 1 - v / 100)
			imageLabel.ImageLabel.UIGradient.Offset = Vector2.new(0, 1 - v / 100)
			imageLabel.ImageShadow.UIGradient.Offset = Vector2.new(0, 1 - v / 100)
		end

		updateTotalProgress()

		for _, dandysBudsMission in ipairs(DandysBudsMissions) do
			local v = clonesByMissionKey[dandysBudsMission.MissionKey]

			if not v then
				continue
			end

			local missions2 = object2.Data and object2.Data.DandysBud and object2.Data.DandysBud.Missions
			setRowProgress(
				v,
				not missions2 and 0 or missions2[dandysBudsMission.MissionKey] or 0,
				dandysBudsMission.MaxValue,
				dandysBudsMission.Description
			)
			local v3 = v
			local v4 = dandysBudsMission
			object2:ListenToChange("DandysBud.Missions." .. dandysBudsMission.MissionKey, function(value)
				if v3.Parent then
					setRowProgress(v3, value or 0, v4.MaxValue, v4.Description)
					updateTotalProgress()
				end
			end)
		end

		local noOp = margin and margin:FindFirstChild("NoOp")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateQuestVisibility()
			local currentStep = object2.Data and object2.Data.TutorialProgress and object2.Data.TutorialProgress.CurrentStep or 0

			if noOp then
				noOp.Visible = currentStep < 10
			end

			if quests then
				quests.Visible = currentStep >= 10
			end
		end

		local v = not (object2.Data and object2.Data.TutorialProgress) and 0 or object2.Data.TutorialProgress.CurrentStep or 0

		if noOp then
			noOp.Visible = v < 10
		end

		if quests then
			quests.Visible = v >= 10
		end

		object2:ListenToChange("TutorialProgress.CurrentStep.", function(_)
			updateQuestVisibility() -- equivalent call inferred; original call site unknown
		end)
	end, function()
		warn("[StarterQuests] Replica unavailable; rows will show 0")
	end)
end