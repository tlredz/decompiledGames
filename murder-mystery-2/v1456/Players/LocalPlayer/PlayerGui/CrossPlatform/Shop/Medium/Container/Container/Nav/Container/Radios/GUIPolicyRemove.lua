local ChinaPolicyService = require(game.ReplicatedFirst:WaitForChild("ChinaPolicyService"))

if ChinaPolicyService:IsActive() then
	script.Parent.Changed:Connect(function()
		script.Parent.Visible = false
	end)
end