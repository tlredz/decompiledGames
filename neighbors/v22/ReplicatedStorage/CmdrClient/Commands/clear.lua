local Players = game:GetService("Players")
return {
	Name = "clear",
	Aliases = {},
	Description = "Clear all lines above the entry line of the Cmdr window.",
	Group = "DefaultUtil",
	Args = {},
	ClientRun = function()
		local cmdr = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Cmdr")
		local frame = cmdr:WaitForChild("Frame")

		if cmdr and frame then
			for _, textBox in pairs(frame:GetChildren()) do
				if textBox.Name == "Line" and textBox:IsA("TextBox") then
					textBox:Destroy()
				end
			end
		end

		return ""
	end
}