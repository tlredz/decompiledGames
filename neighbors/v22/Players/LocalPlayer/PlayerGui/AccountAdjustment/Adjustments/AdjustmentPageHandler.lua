local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(ReplicatedStorage.Modules.Network)
local parent = script.Parent
parent.Visible = false
parent.Close.MouseButton1Click:Connect(function()
	parent.Visible = false
end)
Network:listen("AccountAdjustedNotification", function(p, items, p2: string)
	parent.Description.Text = `@{p.Name} ({p.UserId}) made the following changes`
	parent.Note.Text = `Reason Provided: "{p2}"`

	for _, label in parent.List:GetChildren() do
		if label:IsA("TextLabel") and label.Visible then
			label:Destroy()
		end
	end

	for k, item in items do
		local clone = parent.List.Template:Clone()
		clone.Text = item
		clone.BackgroundColor3 = k % 2 == 0 and Color3.new(0.9, 0.9, 0.9) or Color3.new(0.7, 0.7, 0.7)
		clone.Visible = true
		clone.Parent = parent.List
	end

	parent.Visible = true
end)