local ReplicatedStorage = game:GetService("ReplicatedStorage")
local visible = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Extras"):WaitForChild("CanChangeServerSettings"):InvokeServer()
local privateServer = script.Parent:WaitForChild("Main"):WaitForChild("PrivateServer")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("WindowService"))
privateServer.Visible = visible
privateServer:WaitForChild("Button").Activated:Connect(function()
	WindowService:ToggleFrame("PrivateServer")
end)