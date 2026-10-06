local ReplicatedStorage = game:GetService("ReplicatedStorage")
local serverFunctions = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("ServerFunctions")
local ClearClientWorkspaceModule = require(script.Parent.Parent.Parent.ClearClientWorkspaceModule)
local ClonePathGameToLocalWorkspaceModule = require(script.Parent.Parent.Parent.ClonePathGameToLocalWorkspaceModule)
local CloneStarterGuiForEditOrPlayModule = require(script.Parent.Parent.Parent:WaitForChild("CloneStarterGuiForEditOrPlayModule"))

function LoadGame(p, childName)
	local warningText = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("WarningText")
	script.Parent.Visible = false
	script.Parent.Parent.FileMenu.Visible = false
	warningText.Text = "Loading " .. childName .. "..."
	warningText.Visible = true
	serverFunctions:InvokeServer("LoadDbGameToPlayerGui", p)
	ClearClientWorkspaceModule:ClearWorkspace()
	ClonePathGameToLocalWorkspaceModule:Load(game.Players.LocalPlayer.PlayerGui:FindFirstChild(childName))
	CloneStarterGuiForEditOrPlayModule:Edit()
	warningText.Text = "Ready"
	serverFunctions:InvokeServer("ClearGameFromPlayerGui")
	task.wait(1)
	warningText.Visible = false
end

for i = 1, 10 do
	local v = i
	script.Parent["Game" .. i].MouseButton1Click:Connect(function()
		if v == 1 and script.Parent["Game" .. v].Text == "No saved games found." then
			return
		end

		LoadGame(v, script.Parent["Game" .. v].Text)
	end)
end