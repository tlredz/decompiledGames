local dFFrame = script.Parent:WaitForChild("DFFrame")
local sWFrame = script.Parent:WaitForChild("SWFrame")
local fSFrame = script.Parent:WaitForChild("FSFrame")
local UserInputService = game:GetService("UserInputService")

if UserInputService.TouchEnabled then
	for _, child in pairs(dFFrame:GetChildren()) do
		local button = child:FindFirstChild("Button")

		if button then
			button.Visible = true
		end
	end

	for _, child in pairs(sWFrame:GetChildren()) do
		local button = child:FindFirstChild("Button")

		if button then
			button.Visible = true
		end
	end

	for _, child in pairs(fSFrame:GetChildren()) do
		local button = child:FindFirstChild("Button")

		if button then
			button.Visible = true
		end
	end
end