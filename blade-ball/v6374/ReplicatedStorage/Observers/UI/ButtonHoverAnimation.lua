local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local UIHover = require(ReplicatedStorage.ClientGameModules.UIHover)
return Observers.observeTagNoAncestry("UI_ButtonHoverAnimation", function(data)
	local function exit()
		UIHover.Exit(data)
	end

	local mouseEnterConnection = data.MouseEnter:Connect(function()
		UIHover.Enter(data)
	end)
	local mouseLeaveConnection = data.MouseLeave:Connect(exit)
	local activatedConnection = data.Activated:Connect(exit)
	return function()
		mouseEnterConnection:Disconnect()
		mouseLeaveConnection:Disconnect()
		activatedConnection:Disconnect()
	end
end)