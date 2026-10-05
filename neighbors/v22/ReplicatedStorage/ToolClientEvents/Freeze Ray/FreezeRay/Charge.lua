local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tool = require(ReplicatedStorage.Modules.Tool)
return Tool.Event(function(p)
	local attachment = p.Tool:FindFirstChild("Shooty"):FindFirstChild("Attachment")
	local charge = attachment:FindFirstChild("Charge")

	if attachment and charge then
		charge.Enabled = true
		task.delay(1.4, function()
			charge.Enabled = false
		end)
	end
end)