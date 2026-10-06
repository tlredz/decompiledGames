local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
task.spawn(function()
	local success, _ = pcall(function()
		StarterGui:SetCore("ResetButtonCallback", false)
	end)

	if not success then
		repeat
			local success2, _ = pcall(function()
				StarterGui:SetCore("ResetButtonCallback", false)
			end)
			RunService.Stepped:Wait()
		until success2
	end
end)