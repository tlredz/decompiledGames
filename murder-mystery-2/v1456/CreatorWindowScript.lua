local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("WindowService"))
local parent = script.Parent
local list = parent:WaitForChild("Commands"):WaitForChild("List")
local v, v2 = remotes:WaitForChild("Extras"):WaitForChild("GetCreatorStatus"):InvokeServer()

if not v then
	parent:Destroy()
	return
end

parent.Visible = false

for _, frame in list:GetChildren() do
	if not frame:IsA("Frame") then
		continue
	end

	local visible = v2[frame.Name] == true or v2[frame.Name] == "PrivateServer"

	if v2[frame.Name] == "PrivateServer" then
		local clone = script:WaitForChild("PrivateServer"):Clone()
		clone.Parent = frame.Title
		clone.Visible = true
	end

	frame.Visible = visible
end

parent:WaitForChild("Title"):WaitForChild("Close"):WaitForChild("Button").Activated:Connect(function()
	parent.Visible = false
end)
WindowService:RegisterFrame(parent, "CreatorWindow")