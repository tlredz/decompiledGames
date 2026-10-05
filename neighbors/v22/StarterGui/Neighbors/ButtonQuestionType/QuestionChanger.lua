local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent
local template = script.Parent.SettingsList.Template
local Gamepad = require(ReplicatedStorage.Modules.Gamepad)
local QuestionTypes = require(ReplicatedStorage.Assets.Data.UIData.QuestionTypes)
local Network = require(ReplicatedStorage.Modules.Network)
Gamepad:CreateGroup(parent)
local v = nil

for k, questionType in next, QuestionTypes, nil do
	local clone = template:Clone()
	clone.Name = questionType.LiteralTitle
	clone.Type.Text = questionType.CategoryTitle
	clone.LayoutOrder = k
	clone.Visible = true
	local v2 = questionType
	clone.Button.MouseButton1Click:Connect(function()
		if v then
			Network:fire("SetButtonQuestionType", v, v2.LiteralTitle)
		end

		parent.Visible = false
	end)
	clone.Parent = parent.SettingsList
end

parent.Close.MouseButton1Click:Connect(function()
	parent.Visible = false
end)
Network:listen("ShowQuestionPrompt", function(p)
	v = p
	parent.Visible = true
end)