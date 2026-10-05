local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerFilter = require(ReplicatedStorage.Modules.ServerFilter)
local info = script.Parent.Parent.Parent.Parent.Info
local parent = script.Parent

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCount()
	parent.ActiveCount.Label.Text = ServerFilter.Count
	parent.ActiveCount.Visible = ServerFilter.Count > 0
end

parent.Button.Activated:Connect(function()
	info.FilterMenu.ServerFilter.Visible = true
end)
updateCount() -- equivalent call inferred; original call site unknown
ServerFilter.Updated:Connect(updateCount)