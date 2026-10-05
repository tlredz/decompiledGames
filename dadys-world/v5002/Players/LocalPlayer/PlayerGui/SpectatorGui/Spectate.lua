local currentCamera = workspace.CurrentCamera
local parent = script.Parent
local spectateFrame = parent.BottomFrame.SpectateFrame
local children = workspace.InGamePlayers:GetChildren()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiAnimations = require(ReplicatedStorage.Modules.UI.GuiAnimations)
local v = 1
local parentChangedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePlayerList()
	children = workspace.InGamePlayers:GetChildren()
end

local updateCamera

updateCamera = function(cameraSubject)
	if #children <= 0 then
		return
	end

	if parentChangedConnection then
		parentChangedConnection:Disconnect()
	end

	local success, result = pcall(function()
		spectateFrame.PlayerName.Text = tostring(cameraSubject)
		currentCamera.CameraSubject = cameraSubject
	end)

	if not success then
		warn(result)
	end

	if cameraSubject then
		parentChangedConnection = cameraSubject:GetPropertyChangedSignal("Parent"):Connect(function()
			print("parent changed")
			updatePlayerList() -- equivalent call inferred; original call site unknown
			v -= 1

			if v < 1 then
				v = #children
			end

			updateCamera(children[v])
		end)
	end
end

parent.ActivateSpectate.Event:Connect(function()
	updatePlayerList() -- equivalent call inferred; original call site unknown
	updateCamera(children[v])
end)
updatePlayerList() -- equivalent call inferred; original call site unknown
workspace.InGamePlayers.ChildAdded:Connect(updatePlayerList)
workspace.InGamePlayers.ChildRemoved:Connect(updatePlayerList)
GuiAnimations.SetupButtonAnimationsSimple(spectateFrame.LeftButton)
GuiAnimations.SetupButtonAnimationsSimple(spectateFrame.RightButton)
spectateFrame.LeftButton.MouseButton1Click:Connect(function()
	v -= 1

	if v < 1 then
		v = #children
	end

	updateCamera(children[v])
end)
spectateFrame.RightButton.MouseButton1Click:Connect(function()
	v += 1

	if v > #children then
		v = 1
	end

	updateCamera(children[v])
end)