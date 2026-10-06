local parent = script.Parent.Parent.Parent
local localPlayer = game.Players.LocalPlayer
local studioGui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9)

function DialogOk(text, text2)
	_G.DialogAnswer = "?"
	local dialogOkFrame = localPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("DialogOkFrame")
	local okTextLabel = dialogOkFrame:WaitForChild("OkTextLabel")
	okTextLabel.Text = text
	local okTextButton = dialogOkFrame:WaitForChild("OkTextButton")
	okTextButton.Text = text2
	dialogOkFrame.Visible = true

	while _G.DialogAnswer == "?" do
		task.wait(0.2)
	end
end

script.Parent.Activated:Connect(function()
	parent.AudioScrollingFrame.Visible = false
	parent.ImagesScrollingFrame.Visible = false
	parent.MeshesScrollingFrame.Visible = false
	parent.ModelsScrollingFrame.Visible = false
	parent.RigsScrollingFrame.Visible = false
	parent.RigsEditScrollingFrame.Visible = false
	parent.ToolboxCategoryFrame.ToolboxCategoryButton.Text = "Animation Lite"
	local v = false

	for _, descendant in pairs(workspace:GetDescendants()) do
		if not (descendant.ClassName == "Humanoid" and descendant.Parent ~= localPlayer.Character) then
			continue
		end

		v = true
		break
	end

	if not v then
		DialogOk("No rig found. Use the Studio Lite \"Rig Builder\" to make one.", "Ok")
		return
	end

	script.Parent.Parent.Visible = false
	script.Parent.Parent.Parent.Visible = false

	for _, child in pairs(studioGui:GetChildren()) do
		if child.ClassName == "Frame" then
			child.Visible = false
		end
	end

	studioGui.main.Enabled = false
	studioGui.HandlesB.Adornee = nil
	studioGui.HandlesG.Adornee = nil
	studioGui.HandlesR.Adornee = nil
	studioGui.ArcHandles.Adornee = nil
	studioGui.SelectionBox.Adornee = nil
	studioGui.AnimationEditor.Enabled = true
end)