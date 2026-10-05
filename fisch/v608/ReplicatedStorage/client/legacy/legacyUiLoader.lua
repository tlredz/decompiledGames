local Players = game:GetService("Players")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
return {
	PlayerGui = playerGui,
	init = function()
		local scripts = {}

		for _, script2 in script.Parent.ui:GetDescendants() do
			if not (script2:IsA("LocalScript") and script2.Enabled) then
				continue
			end

			table.insert(scripts, script2)
			script2.Enabled = false
		end

		for _, child in script.Parent.ui:GetChildren() do
			child.Parent = playerGui
		end

		task.defer(function()
			for _, v in scripts do
				v.Enabled = true
			end
		end)
	end
}