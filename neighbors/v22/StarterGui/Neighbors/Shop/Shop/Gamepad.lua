local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gamepad = require(ReplicatedStorage.Modules.Gamepad)
local parent = script.Parent
local group = Gamepad:CreateGroup(parent)
group.EnableCursorBehavior = true
group.EnableButtonExit = false
local v = { parent.InspectItemPage, parent.ItemSkinsPage, parent.ItemTitlesPage }
group.ExitRequested:Connect(function()
	for _, v2 in next, v, nil do
		if not v2.Visible then
			continue
		end

		v2.Visible = false
		return
	end

	group:Exit()
end)