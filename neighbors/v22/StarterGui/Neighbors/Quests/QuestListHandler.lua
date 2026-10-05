local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
local parent = script.Parent
local inspectItem = parent.InspectItem
local questList = parent.QuestList
local quest = questList.Quest
parent.Close.Activated:Connect(function()
	parent.Visible = false
end)
inspectItem.Buttons.Cancel.Activated:Connect(function()
	inspectItem.Visible = false
end)
Network:listen("UpdateQuestsV2", function(items)
	for _, child in pairs(questList:GetChildren()) do
		if child ~= quest then
			child:Destroy()
		end
	end

	for k, item in pairs(items) do
		local clone = quest:Clone()
		local info = clone.Info
		clone.Name = k
		clone.Visible = true
		clone.Picture.Visible = item.Image and true or false

		if item.Image then
			clone.Picture.Image = item.Image
		end

		local visible = item.InProgress and item.ProgressAmount > 0
		info.Begin.Visible = not item.InProgress
		info.Cancel.Visible = item.InProgress
		info.Title.Text = item.DisplayName
		info.Progress.Texture.Visible = visible
		info.Progress.Text.Visible = item.InProgress

		if visible then
			info.Progress.Texture.Size = UDim2.new(math.min(item.ProgressAmount / item.MaxProgress, 1), 0, 1, 0)
		end

		if item.InProgress then
			info.Progress.Text.Text = `{item.ProgressAmount}/{item.MaxProgress}`
		end

		local v2 = k
		info.Begin.Activated:Connect(function()
			Network:fire("QuestSetStateV2", v2, true)
		end)
		local v3 = k
		info.Cancel.Activated:Connect(function()
			Network:fire("QuestSetStateV2", v3, false)
		end)
		local v4 = item
		info.Title.InspectButton.Activated:Connect(function()
			inspectItem.Description.Text = v4.Description or "No description!"
			inspectItem.ItemName.Text = v4.DisplayName
			inspectItem.Visible = true
		end)
		clone.Parent = questList
	end
end)