local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("MobileOnly", function(p)
	local function update(p2)
		p.Visible = p2 == Enum.UserInputType.Touch
	end

	local lastInputTypeChangedConnection = UserInputService.LastInputTypeChanged:Connect(update)
	task.spawn(update, UserInputService:GetLastInputType())
	return function()
		lastInputTypeChangedConnection:Disconnect()
	end
end)