local ReplicatedStorage = game:GetService("ReplicatedStorage")
local visible = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Extras"):WaitForChild("CanChangeServerSettings"):InvokeServer()
local serverSettings = script.Parent:WaitForChild("ServerSettings")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("WindowService"))
serverSettings.Visible = visible
serverSettings:WaitForChild("Button").Activated:Connect(function()
	WindowService:ToggleFrame("PrivateServer")
end)