local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = require(ReplicatedStorage.Modules.UI)
local Network = require(ReplicatedStorage.Modules.Network)
local parent = script.Parent
local description = parent.Description
local buttons = parent.Buttons
local cancel = buttons.Cancel
local confirm = buttons.Confirm

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanup()
	parent:SetAttribute("TargetNotificationId", nil)
	parent:SetAttribute("TargetReserveId", nil)
	parent:SetAttribute("TargetName", nil)
	parent.Visible = false
end

confirm.Button.Activated:Connect(function()
	local targetPlaceId = parent:GetAttribute("TargetPlaceId")
	local targetReserveId = parent:GetAttribute("TargetReserveId")

	if not (targetPlaceId and targetReserveId) then
		return
	end

	Network:fire("JoinServerByReserveId", targetPlaceId, targetReserveId)
	cleanup() -- equivalent call inferred; original call site unknown
end)
cancel.Button.Activated:Connect(function()
	cleanup() -- equivalent call inferred; original call site unknown
end)
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if not parent.Visible then
		return
	end

	local targetName = parent:GetAttribute("TargetName") or "Unknown Name"
	description.Text = `Are you sure you want to join the custom server {targetName}?`
end)
UI:Bind(cancel.Button)
UI:Bind(confirm.Button)
UI:AddShadowOnHover(cancel)
UI:AddShadowOnHover(confirm)