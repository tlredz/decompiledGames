local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parent = script.Parent

if not parent:IsA("Tool") then
	return
end

parent.Activated:Connect(function()
	ReplicatedStorage.events.opencharms:Fire()
end)