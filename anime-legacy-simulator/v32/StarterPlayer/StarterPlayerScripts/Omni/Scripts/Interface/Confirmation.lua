local module = require("@game/ReplicatedStorage/Omni")
local confirmation = module.Interface:WaitForChild("Frames"):WaitForChild("Confirmation")
local main = confirmation:WaitForChild("Main")
local title = main:WaitForChild("Title")
local desc = main:WaitForChild("Desc")
local buttons = main:WaitForChild("Buttons")
local v = nil
local enableds = {}
local Confirmation = {}

local function BlockHovers()
	for _, child in module.Inset:GetChildren() do
		local v2 = module.Libs.NeoHover.GetByInstance(child)

		if not v2 then
			continue
		end

		if enableds[v2] == nil then
			enableds[v2] = v2.Enabled
		end

		v2:Close(nil, true)
		v2:SetEnabled(false)
		v2.CurrentScale:set(0)
		v2.ScalerSpring:setPosition(0)
		v2.ScalerSpring:setVelocity(0)
		child.Visible = false
	end
end

local function RestoreHovers()
	for k, v2 in enableds do
		if k.Instance and k.Instance.Parent and k.State ~= "Destroyed" then
			k:SetEnabled(v2)
		end
	end

	table.clear(enableds)
end

function Confirmation.Start(data)
	v = {
		Callback = data.Callback
	}
	title.Text = data.Title or "Confirm"
	desc.Text = data.Description or ""
	buttons.Confirm.Title.Text = data.ConfirmText or "Confirm"
	buttons.Cancel.Title.Text = data.CancelText or "Cancel"
	module.Frame:Open(confirmation)
end

function Confirmation.Stop(flag: boolean)
	local callback = v and v.Callback
	v = nil
	module.Frame:Close(confirmation)

	if callback then
		callback(flag)
	end
end

module.Button:Create(buttons.Confirm, "Small"):BindFunction("Click", function()
	Confirmation.Stop(true)
end)
module.Button:Create(buttons.Cancel, "Small"):BindFunction("Click", function()
	Confirmation.Stop(false)
end)
module.Frame:OnFrameOpened(confirmation, BlockHovers)
module.Frame:OnFrameClosed(confirmation, function()
	v = nil
	RestoreHovers()
end)
return Confirmation