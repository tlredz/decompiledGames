local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local UIHover = require(ReplicatedStorage.ClientGameModules.UIHover)
local anchorPoint = Vector2.one * 0.5
return Observers.observeTagNoAncestry("UI_ButtonHoverAnimation2", function(state)
	local function exit()
		UIHover.Exit(state)
	end

	local mouseEnterConnection = state.MouseEnter:Connect(function()
		UIHover.Enter(state)
	end)
	local mouseLeaveConnection = state.MouseLeave:Connect(exit)
	local activatedConnection = state.Activated:Connect(exit)

	if (state.AnchorPoint - anchorPoint).Magnitude >= 0.01 then
		local v2 = anchorPoint - state.AnchorPoint
		local size = state.Size
		local position = state.Position
		state.AnchorPoint = anchorPoint
		state.Position = UDim2.new(
			position.X.Scale + size.X.Scale * v2.X,
			position.X.Offset + size.X.Offset * v2.X,
			position.Y.Scale + size.Y.Scale * v2.Y,
			position.Y.Offset + size.Y.Offset * v2.Y
		)
	end

	return function()
		mouseEnterConnection:Disconnect()
		mouseLeaveConnection:Disconnect()
		activatedConnection:Disconnect()
	end
end)