local ReplicatedStorage = game:GetService("ReplicatedStorage")
local serverFunctions = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("ServerFunctions")
local fileMenu = script.Parent.Parent:WaitForChild("FileMenu")
local openSaveFrame = script.Parent.Parent.Parent:WaitForChild("OpenSaveFrame")
local openSamplesMenu = script.Parent.Parent:WaitForChild("OpenSamplesMenu")
local saveDetailsFrame = script.Parent.Parent:WaitForChild("SaveDetailsFrame")
local ClearClientWorkspaceModule = require(script.Parent.Parent.Parent.ClearClientWorkspaceModule)
local v = os.time(os.date("*t")) - os.time(os.date("!*t"))
local v2 = false
local workingImageLabel1 = script.Parent.Parent.Parent:WaitForChild("WorkingImageLabel1")
local workingImageLabel2 = script.Parent.Parent.Parent:WaitForChild("WorkingImageLabel2")

function WorkingWaiting()
	spawn(function()
		v2 = true

		for _ = 1, 100 do
			if not v2 then
				break
			end

			if workingImageLabel1.Visible then
				workingImageLabel1.Visible = false
				workingImageLabel2.Visible = true
			else
				workingImageLabel1.Visible = true
				workingImageLabel2.Visible = false
			end

			task.wait(0.1)
		end

		v2 = false
		workingImageLabel1.Visible = false
		workingImageLabel2.Visible = false
	end)
end

fileMenu.Visible = false
openSaveFrame.Visible = false
openSamplesMenu.Visible = false
saveDetailsFrame.Visible = false
fileMenu:WaitForChild("New").MouseButton1Click:Connect(function()
	fileMenu.New.BackgroundColor3 = Color3.fromRGB(134, 255, 188)
	fileMenu.Samples.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fileMenu.Open.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fileMenu.Save.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fileMenu.Visible = false
	openSaveFrame.Visible = false
	openSamplesMenu.Visible = false
	saveDetailsFrame.Visible = false
	_G.DialogAnswer = "?"
	local dialogYesNoFrame = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("DialogYesNoFrame")
	local yesNoTextLabel = dialogYesNoFrame:WaitForChild("YesNoTextLabel")
	yesNoTextLabel.Text = "Clear workspace and restart with a fresh baseplate?"
	dialogYesNoFrame.Visible = true

	while _G.DialogAnswer == "?" do
		task.wait(0.2)
	end

	if _G.DialogAnswer ~= "No" then
		ClearClientWorkspaceModule:ClearWorkspace()
		local clone = game.ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("New"):WaitForChild("Baseplate"):Clone()
		clone.Parent = workspace
		local clone_2 = game.ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("New"):WaitForChild("SpawnLocation"):Clone()
		clone_2.Parent = workspace
		game.Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic

		if workspace:FindFirstChild("FlyCameraFocus") and _G.CameraCFrameOrig then
			local flyCameraFocus = workspace:FindFirstChild("FlyCameraFocus")
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			flyCameraFocus.CFrame = ReplicatedStorage2:WaitForChild("FlyCameraFocus", 9).CFrame
			workspace.CurrentCamera.CFrame = _G.CameraCFrameOrig
		end
	end
end)
fileMenu:WaitForChild("Samples").MouseButton1Click:Connect(function()
	fileMenu.New.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fileMenu.Samples.BackgroundColor3 = Color3.fromRGB(134, 255, 188)
	fileMenu.Open.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fileMenu.Save.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	openSaveFrame.Visible = false
	openSamplesMenu.Visible = false
	saveDetailsFrame.Visible = false
	WorkingWaiting()
	serverFunctions:InvokeServer("SamplesMenu")
	v2 = false
end)
fileMenu:WaitForChild("Open").MouseButton1Click:Connect(function()
	fileMenu.Visible = false
	openSaveFrame.Visible = false
	openSamplesMenu.Visible = false
	saveDetailsFrame.Visible = false
	WorkingWaiting()
	serverFunctions:InvokeServer("OpenMenu", v)
	v2 = false
end)
fileMenu:WaitForChild("Save").MouseButton1Click:Connect(function()
	fileMenu.Visible = false
	openSaveFrame.Visible = false
	openSamplesMenu.Visible = false
	saveDetailsFrame.Visible = false
	WorkingWaiting()
	serverFunctions:InvokeServer("SaveMenu", v)
	v2 = false
end)
fileMenu:WaitForChild("Restore").MouseButton1Click:Connect(function()
	fileMenu.Visible = false
	openSaveFrame.Visible = false
	openSamplesMenu.Visible = false
	saveDetailsFrame.Visible = false
	WorkingWaiting()
	serverFunctions:InvokeServer("RestoreMenu", v)
	v2 = false
end)