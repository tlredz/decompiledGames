local ReplicatedStorage = game:GetService("ReplicatedStorage")
local unique = ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("SharedAdminEvent"):WaitForChild("Events"):WaitForChild("Unique")
local admin_event = ReplicatedStorage:WaitForChild("world"):WaitForChild("admin_event")
local AdminEventClientReplicate = {}
local value = admin_event.Value

function CloseLastEvent()
	if value ~= "None" and unique:FindFirstChild(value) and unique:FindFirstChild(value):FindFirstChild("ClientEffects") then
		local ClientEffects = require(unique:FindFirstChild(value).ClientEffects)
		ClientEffects.Close()
	end

	value = admin_event.Value
end

function UpdateEvent()
	CloseLastEvent()

	if admin_event.Value ~= "None" and unique:FindFirstChild(admin_event.Value) and unique:FindFirstChild(admin_event.Value):FindFirstChild("ClientEffects") then
		local ClientEffects = require(unique:FindFirstChild(admin_event.Value).ClientEffects)
		ClientEffects.Open()
	end
end

function AdminEventClientReplicate.Start(_)
	UpdateEvent()
	admin_event.Changed:Connect(function()
		UpdateEvent()
	end)
end

return AdminEventClientReplicate