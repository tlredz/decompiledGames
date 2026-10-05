local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gamepad = require(ReplicatedStorage.Modules.Gamepad)
local frame = script:FindFirstAncestorOfClass("Frame")
local group = Gamepad:CreateGroup(frame)
group.EnableCursorBehavior = true
group.EnableButtonExit = false
group.ExitRequested:Connect(function()
	if frame.AddComment.Visible then
		frame.AddComment.Visible = false
	else
		group:Exit()
	end
end)
return nil