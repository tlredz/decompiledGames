local parent = script.Parent
local parent2 = parent.Parent.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local serverFunctions = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("ServerFunctions")

function LoadGame(p, instance)
	local gameTitleTextLabel = instance:WaitForChild("Frame1"):WaitForChild("GameTitleTextLabel")
	local studioGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui")
	local ClearClientWorkspaceModule = require(studioGui:WaitForChild("ClearClientWorkspaceModule"))
	local ClonePathGameToLocalWorkspaceModule = require(studioGui:WaitForChild("ClonePathGameToLocalWorkspaceModule"))
	local CloneStarterGuiForEditOrPlayModule = require(studioGui:WaitForChild("CloneStarterGuiForEditOrPlayModule"))
	local warningText = studioGui:WaitForChild("WarningText")
	studioGui.OpenSaveFrame.Visible = false
	warningText.Text = "Loading " .. gameTitleTextLabel.Text .. "..."
	warningText.Visible = true
	serverFunctions:InvokeServer("LoadDbGameToPlayerGui", p)
	ClearClientWorkspaceModule:ClearWorkspace()
	ClonePathGameToLocalWorkspaceModule:Load(game.Players.LocalPlayer.PlayerGui:FindFirstChild(gameTitleTextLabel.Text))
	CloneStarterGuiForEditOrPlayModule:Edit()
	warningText.Text = "Ready"
	serverFunctions:InvokeServer("ClearGameFromPlayerGui")
	task.wait(1)
	warningText.Visible = false
end

function SaveGame(p, instance)
	local gameTitleTextLabel = instance:WaitForChild("Frame1"):WaitForChild("GameTitleTextLabel")
	local descriptionTextLabel = instance:WaitForChild("Frame3"):WaitForChild("DescriptionTextLabel")
	local publishedTFValue = instance:WaitForChild("Frame3"):WaitForChild("PublishedTFValue")
	local shareFromOwnerStringValue = instance:WaitForChild("Frame4"):WaitForChild("ShareFromOwnerStringValue")
	local saveDetailsFrame = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("TopBar"):WaitForChild("SaveDetailsFrame")

	if #workspace:GetChildren() < 9 and #_G.sss:GetChildren() == 0 then
		_G.DialogAnswer = "?"
		local dialogYesNoFrame = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("DialogYesNoFrame")
		local yesNoTextLabel = dialogYesNoFrame:WaitForChild("YesNoTextLabel")
		yesNoTextLabel.Text = "WARNING: Are you sure you want to overwrite your previous work with a mostly empty baseplate?"
		dialogYesNoFrame.Visible = true

		while _G.DialogAnswer == "?" do
			task.wait(0.2)
		end

		if _G.DialogAnswer == "No" then
			return
		end
	end

	local gameNameTextBox = saveDetailsFrame:WaitForChild("GameNameTextBox")
	gameNameTextBox.Text = gameTitleTextLabel.Text
	local descriptionTextBox = saveDetailsFrame:WaitForChild("DescriptionTextBox")
	descriptionTextBox.Text = descriptionTextLabel.Text

	if publishedTFValue.Value then
		local publishCheckboxImageButton = saveDetailsFrame:WaitForChild("PublishCheckboxImageButton")
		publishCheckboxImageButton.Image = "http://www.roblox.com/asset/?id=48138491"
		local publishDescTextLabel = saveDetailsFrame:WaitForChild("PublishDescTextLabel")
		publishDescTextLabel.Text = "(Everyone can play it together.)"
	else
		local publishCheckboxImageButton_2 = saveDetailsFrame:WaitForChild("PublishCheckboxImageButton")
		publishCheckboxImageButton_2.Image = "http://www.roblox.com/asset/?id=48138474"
		local publishDescTextLabel_2 = saveDetailsFrame:WaitForChild("PublishDescTextLabel")
		publishDescTextLabel_2.Text = "(Save for later.)"
	end

	local ownerTextLabel = saveDetailsFrame:WaitForChild("OwnerTextLabel")
	ownerTextLabel.Text = shareFromOwnerStringValue.Value
	local gameNumberValue = saveDetailsFrame:WaitForChild("GameNumberValue")
	gameNumberValue.Value = p
	saveDetailsFrame.Visible = true
end

parent.Activated:Connect(function()
	local match, v = parent2.Name:match("(%a+)(%d.*)")

	if match and v then
		if parent.Text == "Open" then
			LoadGame(v, parent2)
		elseif parent.Text:sub(1, 4) == "Save" then
			SaveGame(v, parent2)
		elseif parent.Text:sub(1, 7) == "Restore" then
			LoadGame(parent2.Name, parent2)
		else
			print("unexpected OpenSaveButton.Text", parent.Text)
		end
	end
end)