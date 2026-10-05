local ReplicatedStorage = game:GetService("ReplicatedStorage")
local visible, _ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Extras"):WaitForChild("GetCreatorStatus"):InvokeServer()
local creator = script.Parent:WaitForChild("Creator")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("WindowService"))
creator.Visible = visible
creator:WaitForChild("Button").Activated:Connect(function()
	WindowService:ToggleFrame("CreatorWindow")
end)