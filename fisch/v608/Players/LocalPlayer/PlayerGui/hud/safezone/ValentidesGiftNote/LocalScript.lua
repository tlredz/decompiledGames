local ReplicatedStorage = game:GetService("ReplicatedStorage")
local events = ReplicatedStorage:WaitForChild("events")
local parent = script.Parent
local list = parent:WaitForChild("List")
local description = list:WaitForChild("Description")
local from = list:WaitForChild("From")
local close = parent:WaitForChild("Close")
parent.Visible = false
close.Activated:Connect(function()
	parent.Visible = false
end)
events:WaitForChild("ReceiveNote").OnClientEvent:Connect(function(p: string, text: string?)
	if not text or #text == 0 then
		return
	end

	description.Text = text
	from.Text = `From: {p}`
	parent.Visible = true
end)