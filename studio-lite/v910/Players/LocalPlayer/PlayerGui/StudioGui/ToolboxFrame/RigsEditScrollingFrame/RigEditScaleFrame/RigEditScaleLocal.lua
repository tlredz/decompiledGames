local _ = game.Players.LocalPlayer
local explorerPanel = script.Parent.Parent.Parent.Parent:WaitForChild("ExplorerPanel")
local flag = true
local text = nil
local humanoidDescription = nil

for _, child in pairs(script.Parent:GetChildren()) do
	if child.ClassName ~= "TextBox" then
		continue
	end

	local v = child
	child.FocusLost:Connect(function()
		if flag then
			flag = false
			local v2 = explorerPanel.GetSelection:Invoke()[1]

			if v2 then
				local humanoid = v2:FindFirstChild("Humanoid") or v2.Parent and (v2.Parent:FindFirstChild("Humanoid") or v2.Parent.Parent and (v2.Parent.Parent:FindFirstChild("Humanoid") or v2.Parent.Parent.Parent and v2.Parent.Parent.Parent:FindFirstChild("Humanoid")))

				if humanoid then
					text = tonumber(v.Text)

					if text then
						humanoidDescription = humanoid.HumanoidDescription
						humanoidDescription[v.Name:sub(1, -8)] = text
						humanoid:ApplyDescription(humanoidDescription)
					else
						warn("Enter a number.")
					end
				else
					warn("(scale) Select a rig, or build one.")
				end
			else
				warn("(scale) Select a rig, or build one.")
			end

			task.wait(0.5)
			flag = true
		end
	end)
end