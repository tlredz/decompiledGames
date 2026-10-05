local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = require(ReplicatedStorage.Modules.UI)
local ServerFilter = require(ReplicatedStorage.Modules.ServerFilter)
local parent = script.Parent.Parent
local parent2 = parent.Parent
local _ = parent2.Parent
local parent3 = script.Parent
local button = parent3.Button

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	button.Text = `({ServerFilter.Count} Filters Applied)`
	parent.Visible = ServerFilter.Count > 0
end

button.Activated:Connect(function()
	parent2.FilterMenu.ServerFilter.Visible = true
end)
UI:AddShadowOnHover(parent3)
UI:Bind(button)
ServerFilter.Updated:Connect(update)
update() -- equivalent call inferred; original call site unknown