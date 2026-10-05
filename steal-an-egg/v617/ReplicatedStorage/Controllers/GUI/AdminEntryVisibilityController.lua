local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminPanelEntry = require(ReplicatedStorage.Client.AdminPanelEntry)
local GUI = require(ReplicatedStorage.Client.GUI)
return {
	Start = function()
		local playerGui = GUI.PlayerGui()

		local function bindAdminPanelEntry(screenGui)
			if screenGui.Name ~= "AdminPanel" then
				return
			end

			assert(screenGui:IsA("ScreenGui"), "PlayerGui.AdminPanel must be a ScreenGui")
			local toggle = screenGui.Toggle
			assert(toggle:IsA("TextButton"), "PlayerGui.AdminPanel.Toggle must be a TextButton")
			toggle.Visible = AdminPanelEntry.CanShowPanel()
			AdminPanelEntry.Changed:Connect(function(visible: boolean)
				if toggle.Parent ~= nil then
					toggle.Visible = visible
				end
			end)
		end

		for _, child in playerGui:GetChildren() do
			bindAdminPanelEntry(child)
		end

		playerGui.ChildAdded:Connect(bindAdminPanelEntry)
	end
}