local WarningClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
WarningClient.ConfirmedEvents = {}
WarningClient.CancelledEvents = {}
local v = {}

function ShowWarning(options)
	local v2 = options or {}
	local id = v2.Id or v2.Description or "Warning"

	if v[id] then
		return "Cancel"
	end

	local warning = Client.Interface.Warning
	local clone = warning:Clone()

	if v2.Header ~= nil then
		clone.Header.Text = v2.Header
	end

	if v2.Description ~= nil then
		clone.Description.Text = v2.Description
	end

	if v2.ConfirmText ~= nil then
		clone.Buttons.ConfirmButton_Lower.Upper.TextLabel.Text = v2.ConfirmText
	end

	if v2.CancelText ~= nil then
		clone.Buttons.CancelButton_Lower.Upper.TextLabel.Text = v2.CancelText
	end

	local count = 0

	for _ in pairs(v) do
		count += 1
	end

	clone.Position += UDim2.fromOffset(count * 20, count * 20)
	clone.Visible = true
	clone.Parent = warning.Parent
	v[id] = clone
	local bindableEvent = Client.BindableEvent.new()
	clone.Buttons.ConfirmButton_Lower.Upper.Activated:Connect(function()
		bindableEvent:Fire("Confirm")
	end)
	clone.Buttons.CancelButton_Lower.Upper.Activated:Connect(function()
		bindableEvent:Fire("Cancel")
	end)
	clone.CloseButton.Activated:Connect(function()
		bindableEvent:Fire("Cancel")
	end)

	if v2.Timeout then
		task.delay(v2.Timeout, function()
			bindableEvent:Fire("Cancel")
		end)
	end

	local v3 = bindableEvent:Wait()
	v[id] = nil
	clone:Destroy()

	if v3 == "Confirm" and v2.Id and WarningClient.ConfirmedEvents[v2.Id] then
		task.spawn(WarningClient.ConfirmedEvents[v2.Id], v2)
		return "Confirm"
	end

	if v3 == "Cancel" and v2.Id and WarningClient.CancelledEvents[v2.Id] then
		task.spawn(WarningClient.CancelledEvents[v2.Id], v2)
	end

	return v3
end

WarningClient.ShowWarning = ShowWarning

function WarningClient.Init()
	Client.Events.ShowWarning:OnClientInvoke(function(p)
		return ShowWarning(p)
	end)
end

return WarningClient