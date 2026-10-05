local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local tooltip = Players.LocalPlayer.PlayerGui.Tooltip
local tooltip2 = tooltip.Tooltip
tooltip2.Parent = nil
local TooltipController = {}
TooltipController.tooltips = {}
TooltipController.current = nil

function TooltipController.New(state, data, text)
	local current = {
		tooltip = text
	}
	state.tooltips[data] = current
	data.MouseEnter:Connect(function()
		state.current = current
		tooltip2.Position = UDim2.fromOffset(
			data.AbsolutePosition.X + data.AbsoluteSize.X / 2,
			data.AbsolutePosition.Y - 6
		)
		tooltip2.Parent = tooltip
		tooltip2.Text = text
		tooltip2.BackToolTip.Text = text
	end)
	data.MouseLeave:Connect(function()
		if state.current == current then
			state.current = nil
			tooltip2.Parent = nil
		end
	end)
end

function TooltipController.UpdateTooltip(p, p2, p3)
	local tooltip3 = p.tooltips[p2]

	if not tooltip3 then
		return
	end

	tooltip3.tooltip = p3

	if p.current == tooltip3 then
		tooltip2.Text = p3
		tooltip2.BackToolTip.Text = p3
	end
end

function TooltipController.Start(p)
	UserInputService.WindowFocusReleased:Connect(function()
		if p.current then
			p.current = nil
			tooltip2.Parent = nil
		end
	end)
end

return TooltipController