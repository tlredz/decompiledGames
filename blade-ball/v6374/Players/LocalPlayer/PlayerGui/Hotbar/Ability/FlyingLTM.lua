while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local ServerInfo = require(game.ReplicatedStorage.ServerInfo)

if ServerInfo.isLTMServer() then
	local LTM = require(game.ReplicatedStorage.Shared.LTM)

	if LTM.getPriorityLTM().Id == "Flying" then
		script.Parent.BlockText.Text = "BOOST"
		script.Parent.Red.Visible = false
		script.Parent.Red:GetPropertyChangedSignal("Visible"):Connect(function()
			script.Parent.Red.Visible = false
		end)
		script.Parent.Vector.Image = "rbxassetid://16809868999"
		script.Parent.Vector:GetPropertyChangedSignal("Image"):Connect(function()
			script.Parent.Vector.Image = "rbxassetid://16809868999"
		end)
	end
end