local parent = script.Parent
local v = false
parent.FocusLost:Connect(function()
	if v == false then
		v = true
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		ReplicatedStorage.events.runcode:FireServer(parent.Text)
		task.wait(0.5)
		v = false
	end
end)