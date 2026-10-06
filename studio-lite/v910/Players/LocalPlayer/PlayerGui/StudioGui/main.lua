local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local mainBar = script.Parent:WaitForChild("MainBar")
local topBar = script.Parent:WaitForChild("TopBar")
local explorerPanel = script.Parent:WaitForChild("ExplorerPanel")
local propertiesPanel = explorerPanel.Parent:WaitForChild("PropertiesPanel")
local sLWorkspaceFrame = explorerPanel.Parent:WaitForChild("SLWorkspaceFrame")
local textSize = 9
local v2 = 0
local GuiService = game:GetService("GuiService")

function IndentForRobloxMenu()
	local topbarInset = GuiService.TopbarInset
	topBar.Position = UDim2.new(0, topbarInset.Min.X, 0, 1)
	mainBar.Position = UDim2.new(0, topbarInset.Min.X, 0, 20)

	if propertiesPanel.Parent.AbsoluteSize.X <= 640 then
		v2 = math.clamp(topbarInset.Min.X - 40, 0, 100)
		textSize = math.clamp(450 / math.clamp(v2, 40, 100), 5, 9)
		explorerPanel.Position = UDim2.new(
			1,
			v2 + -251,
			explorerPanel.Position.Y.Scale,
			explorerPanel.Position.Y.Offset
		)
		explorerPanel.Size = UDim2.new(0, 250 - v2, explorerPanel.Size.Y.Scale, explorerPanel.Size.Y.Offset)
		propertiesPanel.Position = UDim2.new(
			1,
			v2 + -251,
			propertiesPanel.Position.Y.Scale,
			propertiesPanel.Position.Y.Offset
		)
		propertiesPanel.Size = UDim2.new(0, 250 - v2, propertiesPanel.Size.Y.Scale, propertiesPanel.Size.Y.Offset)
		sLWorkspaceFrame.Size = UDim2.new(1, v2 + -251, sLWorkspaceFrame.Size.Y.Scale, sLWorkspaceFrame.Size.Y.Offset)
		local copyButton = explorerPanel:WaitForChild("Header", 9):WaitForChild("CopyButton")
		copyButton.TextSize = textSize
		local cutdeleteButton = explorerPanel.Header:WaitForChild("Cut/ deleteButton")
		cutdeleteButton.TextSize = textSize
		local dupliButton = explorerPanel.Header:WaitForChild("DupliButton")
		dupliButton.TextSize = textSize
		local groupButton = explorerPanel.Header:WaitForChild("GroupButton")
		groupButton.TextSize = textSize
		local pasteintoButton = explorerPanel.Header:WaitForChild("Paste intoButton")
		pasteintoButton.TextSize = textSize
		local selectMultiButton = explorerPanel.Header:WaitForChild("Select MultiButton")
		selectMultiButton.TextSize = textSize
	end
end

GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(IndentForRobloxMenu)
IndentForRobloxMenu()
local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")

if GuiService:IsTenFootInterface() then
	_G.DynamicThumb = true
	_G.GamepadService = true
elseif VRService.VREnabled then
	_G.DynamicThumb = true
else
	_G.DynamicThumb = nil
	spawn(function()
		if localPlayer:WaitForChild("PlayerGui", 30):WaitForChild("TouchGui", 30) and localPlayer.PlayerGui.TouchGui:WaitForChild(
			"TouchControlFrame",
			30
		) and localPlayer.PlayerGui.TouchGui.TouchControlFrame:WaitForChild("DynamicThumbstickFrame", 30) then
			_G.DynamicThumb = localPlayer.PlayerGui.TouchGui.TouchControlFrame.DynamicThumbstickFrame
			_G.DynamicThumb.Position = UDim2.new(0, -100, 0.6, 0)
			_G.DynamicThumb.Size = UDim2.new(0.2, 100, 0.666, 0)
			;(localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid"):SetStateEnabled(
				Enum.HumanoidStateType.Jumping,
				false
			)
			localPlayer.PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeRight
			task.wait(30)
			localPlayer.PlayerGui.ScreenOrientation = Enum.ScreenOrientation.Sensor
		end
	end)
end

local mouse = localPlayer:GetMouse()
local setSelection = explorerPanel:WaitForChild("SetSelection")
local explorerSelectionChangedToMain = workspace:WaitForChild("ExplorerSelectionChangedToMain", 9)
local target = nil
local v3 = {}
local flag = true
local handlesR = script.Parent:WaitForChild("HandlesR")
local handlesG = script.Parent:WaitForChild("HandlesG")
local handlesB = script.Parent:WaitForChild("HandlesB")
local arcHandles = script.Parent:WaitForChild("ArcHandles")
local selectionBox = script.Parent:WaitForChild("SelectionBox")
local select = mainBar:WaitForChild("select")
local move = mainBar:WaitForChild("move")
local scale = mainBar:WaitForChild("scale")
local rotate = mainBar:WaitForChild("rotate")
local partsel = mainBar:WaitForChild("partsel")
local sel = mainBar:WaitForChild("sel")
local rotateTextBox = mainBar:WaitForChild("Snap"):WaitForChild("RotateTextBox")
local moveTextBox = mainBar.Snap:WaitForChild("MoveTextBox")
local pivot = nil
local v4 = "Select"

if GuiService:IsTenFootInterface() then
	mainBar.Snap.Position = UDim2.new(0, 670, 0, 3)
	sel.Position = UDim2.new(0, 600, 0, 90)
	move.Position = UDim2.new(0, 393, 0, 3)
	partsel.Position = UDim2.new(0, 600, 0, 3)
	local play = mainBar:WaitForChild("play")
	play.Position = UDim2.new(0, 513, 0, 3)
	rotate.Position = UDim2.new(0, 473, 0, 3)
	scale.Position = UDim2.new(0, 433, 0, 3)
	select.Position = UDim2.new(0, 354, 0, 3)
	local toolbox = mainBar:WaitForChild("toolbox")
	toolbox.Position = UDim2.new(0, 553, 0, 3)
end

function ChoosePrimaryPart()
	local boundingBox, _ = target:GetBoundingBox()
	local v5 = 0
	local v6 = 9999
	local primaryPart = nil

	for _, part in pairs(target:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local mass = part:GetMass()
		local magnitude = (part.Position - boundingBox.Position).magnitude

		if v5 < mass then
			primaryPart = part
			v6 = magnitude
			v5 = mass
		elseif mass == v5 and magnitude < v6 then
			primaryPart = part
			v6 = magnitude
		end
	end

	if primaryPart then
		target.PrimaryPart = primaryPart
	end
end

local adornee = nil

function ChooseFolderOrToolPrimaryPart()
	adornee = nil
	local v6 = createVector(0, 0, 0)
	local v7 = nil
	local v8 = 9999
	local v9 = 0
	local count = 0
	v3 = {}

	for _, part in pairs(target:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		table.insert(v3, part)
		count += 1
		v6 += part.Position
	end

	local v10 = v6 / count

	for _, part in pairs(target:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local mass = part:GetMass()
		local magnitude = (part.Position - v10).magnitude

		if v9 < mass then
			v7 = part
			v8 = magnitude
			v9 = mass
		elseif mass == v9 and magnitude < v8 then
			v7 = part
			v8 = magnitude
		end
	end

	if v7 then
		adornee = v7
	end
end

function AdornSelected(p)
	if handlesR.Adornee and handlesR.Adornee.Name == "SL_AttachmentAdornee" then
		handlesR.Adornee:Destroy()
	end

	if arcHandles.Adornee and arcHandles.Adornee.Name == "SL_AttachmentAdornee" then
		arcHandles.Adornee:Destroy()
	end

	handlesR.Adornee = nil
	handlesG.Adornee = nil
	handlesB.Adornee = nil
	arcHandles.Adornee = nil
	selectionBox.Adornee = nil
	select.BackgroundColor3 = mainBar.BackgroundColor3
	move.BackgroundColor3 = mainBar.BackgroundColor3
	scale.BackgroundColor3 = mainBar.BackgroundColor3
	rotate.BackgroundColor3 = mainBar.BackgroundColor3

	if target then
		if v4 == "Select" then
			selectionBox.Adornee = target
			select.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		elseif v4 == "Move" then
			if target.ClassName == "Model" then
				if not target.PrimaryPart then
					ChoosePrimaryPart()
				end

				if target.PrimaryPart then
					handlesR.Adornee = target.PrimaryPart
					handlesG.Adornee = target.PrimaryPart
					handlesB.Adornee = target.PrimaryPart
				end
			elseif target:IsA("BasePart") then
				handlesR.Adornee = target
				handlesG.Adornee = target
				handlesB.Adornee = target
			elseif target.ClassName == "Folder" or target.ClassName == "Tool" then
				ChooseFolderOrToolPrimaryPart()
				handlesR.Adornee = adornee
				handlesG.Adornee = adornee
				handlesB.Adornee = adornee
			elseif target.ClassName == "Attachment" then
				local part = Instance.new("Part")
				part.Anchored = true
				part.Name = "SL_AttachmentAdornee"
				part.Size = createVector(0.3, 0.3, 0.3)
				part.Color = Color3.new(0, 1, 0)
				part.CFrame = target.WorldCFrame
				part.Parent = target
				handlesR.Adornee = part
				handlesG.Adornee = part
				handlesB.Adornee = part
			end

			handlesR.Style = Enum.HandlesStyle.Movement
			handlesG.Style = Enum.HandlesStyle.Movement
			handlesB.Style = Enum.HandlesStyle.Movement
			move.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		elseif v4 == "Scale" then
			if target.ClassName == "Model" then
				if not target.PrimaryPart then
					ChoosePrimaryPart()
				end

				if target.PrimaryPart then
					handlesR.Adornee = target.PrimaryPart
					handlesG.Adornee = target.PrimaryPart
					handlesB.Adornee = target.PrimaryPart
				end
			elseif target:IsA("BasePart") then
				handlesR.Adornee = target
				handlesG.Adornee = target
				handlesB.Adornee = target
			elseif target.ClassName == "Folder" or target.ClassName == "Tool" then
				ChooseFolderOrToolPrimaryPart()
				handlesR.Adornee = adornee
				handlesG.Adornee = adornee
				handlesB.Adornee = adornee
			end

			handlesR.Style = Enum.HandlesStyle.Resize
			handlesG.Style = Enum.HandlesStyle.Resize
			handlesB.Style = Enum.HandlesStyle.Resize
			scale.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		elseif v4 == "Rotate" then
			if target.ClassName == "Model" then
				if not target.PrimaryPart then
					ChoosePrimaryPart()
				end

				if target.PrimaryPart then
					arcHandles.Adornee = target.PrimaryPart
					pivot = target:GetPivot()
				end
			elseif target:IsA("BasePart") then
				arcHandles.Adornee = target
				pivot = target:GetPivot()
			elseif target.ClassName == "Attachment" then
				local part = Instance.new("Part")
				part.Anchored = true
				part.Name = "SL_AttachmentAdornee"
				part.Size = createVector(0.3, 0.3, 0.3)
				part.Color = Color3.new(0, 1, 0)
				part.CFrame = target.WorldCFrame
				part.Parent = target
				arcHandles.Adornee = part
				pivot = target.WorldCFrame
			end

			rotate.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		end

		if p then
			task.wait(0.1)

			if explorerPanel:WaitForChild("Header", 9):WaitForChild("Select MultiButton").BackgroundColor3 == Color3.new(
				1,
				1,
				1
			) then
				v3 = { target }
				setSelection:Invoke(v3)
			else
				local v6 = false

				for k in v3 do
					if k ~= target then
						continue
					end

					v6 = true
					break
				end

				if not v6 then
					table.insert(v3, target)
					setSelection:Invoke(v3)
				end
			end
		end
	end
end

select.MouseButton1Click:Connect(function()
	v4 = "Select"
	AdornSelected(false)
end)
move.MouseButton1Click:Connect(function()
	v4 = "Move"
	AdornSelected(false)
end)
scale.MouseButton1Click:Connect(function()
	v4 = "Scale"
	AdornSelected(false)
end)
rotate.MouseButton1Click:Connect(function()
	v4 = "Rotate"
	AdornSelected(false)
end)
partsel.MouseButton1Click:Connect(function()
	topBar:WaitForChild("FileMenu")
	local openSaveFrame = topBar.Parent:WaitForChild("OpenSaveFrame")
	local openSamplesMenu = topBar:WaitForChild("OpenSamplesMenu")
	local saveDetailsFrame = topBar:WaitForChild("SaveDetailsFrame")
	local viewScriptFrame = script.Parent:WaitForChild("ViewScriptFrame")
	local toolboxFrame = script.Parent:WaitForChild("ToolboxFrame")
	openSaveFrame.Visible = false
	openSamplesMenu.Visible = false
	saveDetailsFrame.Visible = false
	viewScriptFrame.Visible = false
	toolboxFrame.Visible = false

	if mainBar.sel.Visible == true then
		mainBar.sel.Visible = false
	else
		mainBar.sel.Visible = true
	end
end)

function NewPart(p)
	selectionBox.Adornee = nil
	handlesR.Adornee = nil
	handlesG.Adornee = nil
	handlesB.Adornee = nil
	arcHandles.Adornee = nil
	local part = nil

	if p == "create_part_block" then
		part = Instance.new("Part")
		part.Size = createVector(4, 1, 2)
	elseif p == "create_part_sphere" then
		part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Size = createVector(4, 4, 4)
	elseif p == "create_part_wedge" then
		part = Instance.new("Part")
		part.Shape = Enum.PartType.Wedge
		part.Size = createVector(4, 1, 2)
	elseif p == "create_part_cornerwedge" then
		part = Instance.new("Part")
		part.Shape = Enum.PartType.CornerWedge
		part.Size = createVector(2, 2, 2)
	elseif p == "create_part_cyl" then
		part = Instance.new("Part")
		part.Shape = Enum.PartType.Cylinder
		part.Size = createVector(4, 1, 1)
	end

	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = workspace
	part:SetAttribute("SL_Anchored", false)
	part:SetAttribute("SL_CanCollide", true)
	local cFrame = workspace.CurrentCamera.CFrame
	local vector2 = Vector3.new(
		math.floor((cFrame.X + cFrame.lookVector.X * 30) * 2) / 2,
		part.Size.Y / 2,
		math.floor((cFrame.Z + cFrame.lookVector.Z * 30) * 2) / 2
	)
	local raycastResult = workspace:Raycast(Vector3.new(vector2.X, cFrame.Y, vector2.Z), (Vector3.new(0, -cFrame.Y, 0)))

	if raycastResult then
		vector2 = Vector3.new(
			vector2.X,
			raycastResult.Instance.Position.Y + raycastResult.Instance.Size.Y / 2 + part.Size.Y / 2,
			vector2.Z
		)
	end

	script.Parent.MainBar.sel.Visible = false
	part.Position = vector2
	target = part
	v3 = { part }
	AdornSelected(true)
end

sel:WaitForChild("b").MouseButton1Click:Connect(function()
	NewPart("create_part_block")
end)
sel:WaitForChild("s").MouseButton1Click:Connect(function()
	NewPart("create_part_sphere")
end)
sel:WaitForChild("w").MouseButton1Click:Connect(function()
	NewPart("create_part_wedge")
end)
sel:WaitForChild("cw").MouseButton1Click:Connect(function()
	NewPart("create_part_cornerwedge")
end)
sel:WaitForChild("c").MouseButton1Click:Connect(function()
	NewPart("create_part_cyl")
end)

function scaleModelWithJoints(instance, p)
	local boundingBox, v6 = instance:GetBoundingBox()
	local v7 = boundingBox.Y - v6.Y / 2

	if instance:GetScale() + (p - 1) > 0 then
		instance:ScaleTo(instance:GetScale() + (p - 1))
		local boundingBox2, v8 = instance:GetBoundingBox()
		instance:TranslateBy((Vector3.new(0, v7 - (boundingBox2.Y - v8.Y / 2), 0)))
	end
end

function scaleMultiSelected(list, p)
	local vector2 = Vector3.new()

	for _, part in list do
		if part:IsA("BasePart") then
			vector2 += part.Position
		elseif part.ClassName == "Model" then
			local boundingBox, _ = part:GetBoundingBox()
			vector2 += boundingBox.Position
		end
	end

	local v6 = vector2 / #list
	local v7 = 0

	for _, part in list do
		if part:IsA("BasePart") then
			local v8 = part.Position.Y - v6.Y + part.Size.Y / 2

			if v7 < v8 then
				v7 = v8
			end
		elseif part.ClassName == "Model" then
			local boundingBox, v8 = part:GetBoundingBox()
			local v9 = boundingBox.Position.Y - v6.Y + v8.Y / 2

			if v7 < v9 then
				v7 = v9
			end
		end
	end

	for _, part in list do
		if part.ClassName == "Model" then
			scaleModelWithJoints(part, p)
		elseif part:IsA("BasePart") then
			part.Size *= p
			local vector3 = Vector3.new(v6.X, v6.Y - v7, v6.Z)
			part.Position = vector3 + (part.Position - vector3) * p
		end
	end
end

local cFrame = nil
local RunService = game:GetService("RunService")
local v6 = 5
rotateTextBox.Text = "5"
rotateTextBox.FocusLost:Connect(function()
	local text = tonumber(rotateTextBox.Text)

	if text and text >= 0.1 and text <= 90 then
		v6 = text
	else
		rotateTextBox.Text = tostring(math.floor(v6 * 100) / 100)
	end
end)
local flag2 = true

function round(p)
	return math.floor(p / v6 + 0.5) * v6
end

function AngleFromAxis(p, p2)
	local rounded = math.rad((round((math.deg(p2)))))
	return p == Enum.Axis.X and { rounded, 0, 0 } or p == Enum.Axis.Y and { 0, rounded, 0 } or p == Enum.Axis.Z and {
		0,
		0,
		rounded
	} or false
end

arcHandles.MouseDrag:Connect(function(p, p2, _)
	if flag2 then
		flag2 = false
		local parents = {}

		if #v3 > 1 then
			for i = 2, #v3 do
				if not (v3[i]:IsA("BasePart") or v3[i]:IsA("Model")) then
					continue
				end

				parents[v3[i]] = v3[i].Parent
				v3[i].Parent = target
			end
		end

		if target.ClassName == "Attachment" then
			target.SL_AttachmentAdornee:PivotTo(pivot * CFrame.Angles(unpack(AngleFromAxis(p, p2))))
			target.WorldCFrame = target.SL_AttachmentAdornee.CFrame
		else
			target:PivotTo(pivot * CFrame.Angles(unpack(AngleFromAxis(p, p2))))
		end

		if #v3 > 1 then
			for i = 2, #v3 do
				if not (v3[i]:IsA("BasePart") or v3[i]:IsA("Model")) then
					continue
				end

				v3[i].Parent = parents[v3[i]]
			end
		end

		flag2 = true
	end
end)
arcHandles.MouseButton1Down:Connect(function()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	_G.BlockCameraMovement = true
end)
arcHandles.MouseButton1Up:Connect(function()
	cFrame = workspace.CurrentCamera.CFrame
	workspace.CurrentCamera.CameraType = Enum.CameraType.Track
	RunService.RenderStepped:Wait()
	workspace.CurrentCamera.CFrame = cFrame
	_G.BlockCameraMovement = false

	if target then
		if target.ClassName == "Attachment" then
			pivot = target.WorldCFrame
		else
			pivot = target:GetPivot()
		end
	end
end)
local v7 = 1
moveTextBox.Text = "1"
moveTextBox.FocusLost:Connect(function()
	local text = tonumber(moveTextBox.Text)

	if text and text >= 0.001 and text <= 20 then
		v7 = text
	else
		moveTextBox.Text = tostring(math.floor(v7 * 1000) / 1000)
	end
end)
local v8 = 0
local v9 = nil
local v10 = nil

function MoveScale(p, p2)
	task.wait()

	if flag then
		flag = false

		if p == v9 and v10 == target then
			local v11 = p2 - v8 + v7 / 2
			local v12 = v11 - v11 % v7

			if v7 <= v12 or v12 <= -v7 then
				local v13 = math.sign(v11) * v7 * (handlesR.Adornee.CFrame.RightVector * Vector3.FromNormalId(p).X + handlesR.Adornee.CFrame.UpVector * Vector3.FromNormalId(p).Y + handlesR.Adornee.CFrame.LookVector * -Vector3.FromNormalId(p).Z)

				if v7 * 2 <= v12 or v12 <= -v7 * 2 then
					v13 *= 3
				end

				if v4 == "Move" then
					if #v3 == 1 and target.ClassName == "Attachment" then
						target.SL_AttachmentAdornee.Position += v13
						target.WorldCFrame = target.SL_AttachmentAdornee.CFrame
					else
						for _, v14 in v3 do
							v14:PivotTo(v14:GetPivot() + v13)
						end
					end
				elseif #v3 > 1 or #v3 == 1 and target.ClassName == "Part" and target.Shape == Enum.PartType.Ball then
					if math.sign(v12) > 0 then
						scaleMultiSelected(v3, 1.1111111111111112)
					else
						scaleMultiSelected(v3, 0.9)
					end
				elseif target:IsA("Model") then
					if math.sign(v12) > 0 then
						scaleMultiSelected({ target }, 1.1111111111111112)
					else
						scaleMultiSelected({ target }, 0.9)
					end
				elseif target:IsA("BasePart") then
					local size = target.Size
					local vector2 = Vector3.FromNormalId(p)
					local vector3 = Vector3.new(math.abs(vector2.X), math.abs(vector2.Y), (math.abs(vector2.Z)))
					local v14 = size + vector3 * v12
					local v15 = (v14.X < 0 or v14.Y < 0 or v14.Z < 0 or v14.X > 2048 or v14.Y > 2048 or v14.Z > 2048) and 0 or v12
					target.Size += vector3 * v15
					target.CFrame *= CFrame.new(vector2 * v15 / 2)

					for _, child in pairs(target:GetChildren()) do
						if child.ClassName == "Attachment" then
							child.Position *= target.Size / (size + createVector(0.001, 0.001, 0.001))
						end
					end
				end

				target = v3[1]
				v8 = p2
			end
		else
			v9 = p
			v10 = target
			v8 = p2
		end

		task.wait()
		flag = true
	end
end

local flag3 = false
local v11 = false
handlesR.MouseDrag:Connect(MoveScale)
handlesG.MouseDrag:Connect(MoveScale)
handlesB.MouseDrag:Connect(MoveScale)
handlesR.MouseButton1Down:Connect(function()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	_G.BlockCameraMovement = true
end)
handlesG.MouseButton1Down:Connect(function()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	_G.BlockCameraMovement = true
end)
handlesB.MouseButton1Down:Connect(function()
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	_G.BlockCameraMovement = true
end)
handlesR.MouseButton1Up:Connect(function()
	cFrame = workspace.CurrentCamera.CFrame
	workspace.CurrentCamera.CameraType = Enum.CameraType.Track
	RunService.RenderStepped:Wait()
	workspace.CurrentCamera.CFrame = cFrame
	_G.BlockCameraMovement = false
	flag3 = false
	v11 = false
	v10 = nil
end)
handlesG.MouseButton1Up:Connect(function()
	cFrame = workspace.CurrentCamera.CFrame
	workspace.CurrentCamera.CameraType = Enum.CameraType.Track
	RunService.RenderStepped:Wait()
	workspace.CurrentCamera.CFrame = cFrame
	_G.BlockCameraMovement = false
	flag3 = false
	v11 = false
	v10 = nil
end)
handlesB.MouseButton1Up:Connect(function()
	cFrame = workspace.CurrentCamera.CFrame
	workspace.CurrentCamera.CameraType = Enum.CameraType.Track
	RunService.RenderStepped:Wait()
	workspace.CurrentCamera.CFrame = cFrame
	_G.BlockCameraMovement = false
	flag3 = false
	v11 = false
	v10 = nil
end)
local X = 0
local Y = 0
local v12 = 0
local v13 = 0
local X2 = 0
local Y2 = 0
local v14 = nil
local v15 = nil
local top = nil
local v16 = nil
local v17 = nil
local unit = nil
local top2 = nil
local v18 = nil
local v19 = nil
local unit2 = nil
mouse.Move:Connect(function()
	if flag3 and v4 == "Move" and v11 and top and top2 then
		v14 = mouse.X - X
		v15 = mouse.Y - Y
		v12 = mouse.X - X2
		v13 = mouse.Y - Y2
		X2 = mouse.X
		Y2 = mouse.Y

		if v16 < 0.86 then
			local X3 = v19.X
			local Z = v19.Z
			local v20 = Z == 0 and 1e-6 or Z
			local X4 = unit2.X
			local Z2 = unit2.Z
			local v21 = Z2 == 0 and 1e-6 or Z2
			local v22 = X3 / v20
			local v23 = X4 / v21
			local v24 = math.atan((v22 - v23) / (1 + v22 * v23))

			if v12 > 0 and v13 > 0 or v12 < 0 and v13 < 0 then
				if v24 > 0 then
					MoveScale(top, v15 / 8)
				else
					MoveScale(top2, v14 / 10)
				end
			elseif v12 ~= 0 and v13 ~= 0 then
				if v24 > 0 then
					MoveScale(top2, v14 / 10)
				else
					MoveScale(top, v15 / 8)
				end
			end
		elseif math.abs(v12) > math.abs(v13) then
			MoveScale(top2, v14 / 10)
		else
			MoveScale(top, v15 / 8)
		end
	end
end)
local topBar2 = script.Parent:WaitForChild("TopBar")
local fileMenu = topBar2:WaitForChild("FileMenu")
local openSaveFrame = topBar2.Parent:WaitForChild("OpenSaveFrame")
local openSamplesMenu = topBar2:WaitForChild("OpenSamplesMenu")
local saveDetailsFrame = topBar2:WaitForChild("SaveDetailsFrame")
mouse.Button1Down:Connect(function()
	local WAIT_INTERVAL = 0.2
	flag3 = true

	if not saveDetailsFrame.Visible then
		fileMenu.Visible = false
		openSaveFrame.Visible = false
		openSamplesMenu.Visible = false
	end

	if mouse.Target and mouse.Target.Name ~= "Baseplate" and mouse.Target.Locked == false and mouse.Target ~= handlesR and mouse.Target ~= handlesG and mouse.Target ~= handlesB and mouse.Target ~= arcHandles and mouse.Target ~= selectionBox then
		if handlesB.Adornee == nil and arcHandles.Adornee == nil then
			target = mouse.Target

			if target.ClassName ~= "Model" or target.ClassName ~= "Tool" then
				while true do
					local targetModel = target:FindFirstAncestorWhichIsA("Model") or target:FindFirstAncestorWhichIsA("Tool")

					if not targetModel or targetModel.ClassName ~= "Model" and targetModel.ClassName ~= "Tool" then
						break
					end

					target = targetModel
				end
			end

			AdornSelected(true)

			if v4 == "Move" and handlesB.Adornee then
				workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
				_G.BlockCameraMovement = true
				unit = (workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)).Unit
				local dot = unit:Dot(-handlesB.Adornee.CFrame.UpVector)
				local dot2 = unit:Dot(-handlesB.Adornee.CFrame.RightVector)
				local dot3 = unit:Dot(handlesB.Adornee.CFrame.LookVector)
				local dot4 = unit:Dot(handlesB.Adornee.CFrame.UpVector)
				local dot5 = unit:Dot(handlesB.Adornee.CFrame.RightVector)
				local dot6 = unit:Dot(-handlesB.Adornee.CFrame.LookVector)
				v16 = dot
				top = Enum.NormalId.Top
				v17 = -handlesB.Adornee.CFrame.UpVector * (createVector(1, 0, 1)).Unit

				if v16 < dot2 then
					v16 = dot2
					top = Enum.NormalId.Right
					v17 = -handlesB.Adornee.CFrame.RightVector * (createVector(1, 0, 1)).Unit
				end

				if v16 < dot3 then
					v16 = dot3
					top = Enum.NormalId.Back
					v17 = handlesB.Adornee.CFrame.LookVector * (createVector(1, 0, 1)).Unit
				end

				if v16 < dot4 then
					v16 = dot4
					top = Enum.NormalId.Bottom
					v17 = handlesB.Adornee.CFrame.UpVector * (createVector(1, 0, 1)).Unit
				end

				if v16 < dot5 then
					v16 = dot5
					top = Enum.NormalId.Left
					v17 = -handlesB.Adornee.CFrame.UpVector * (createVector(1, 0, 1)).Unit
				end

				if v16 < dot6 then
					v16 = dot6
					top = Enum.NormalId.Front
					v17 = -handlesB.Adornee.CFrame.LookVector * (createVector(1, 0, 1)).Unit
				end

				unit2 = (workspace.CurrentCamera.CFrame.RightVector * createVector(1, 0, 1)).Unit
				local dot7 = unit2:Dot(handlesB.Adornee.CFrame.UpVector)
				local dot8 = unit2:Dot(handlesB.Adornee.CFrame.RightVector)
				local dot9 = unit2:Dot(-handlesB.Adornee.CFrame.LookVector)
				local dot10 = unit2:Dot(-handlesB.Adornee.CFrame.UpVector)
				local dot11 = unit2:Dot(-handlesB.Adornee.CFrame.RightVector)
				local dot12 = unit2:Dot(handlesB.Adornee.CFrame.LookVector)
				v18 = dot7
				top2 = Enum.NormalId.Top
				v19 = handlesB.Adornee.CFrame.UpVector * (createVector(1, 0, 1)).Unit

				if v18 < dot8 then
					v18 = dot8
					top2 = Enum.NormalId.Right
					v19 = handlesB.Adornee.CFrame.RightVector * (createVector(1, 0, 1)).Unit
				end

				if v18 < dot9 then
					v18 = dot9
					top2 = Enum.NormalId.Back
					v19 = -handlesB.Adornee.CFrame.LookVector * (createVector(1, 0, 1)).Unit
				end

				if v18 < dot10 then
					v18 = dot10
					top2 = Enum.NormalId.Bottom
					v19 = -handlesB.Adornee.CFrame.UpVector * (createVector(1, 0, 1)).Unit
				end

				if v18 < dot11 then
					v18 = dot11
					top2 = Enum.NormalId.Left
					v19 = -handlesB.Adornee.CFrame.RightVector * (createVector(1, 0, 1)).Unit
				end

				if v18 < dot12 then
					v18 = dot12
					top2 = Enum.NormalId.Front
					v19 = handlesB.Adornee.CFrame.LookVector * (createVector(1, 0, 1)).Unit
				end

				X = mouse.X
				Y = mouse.Y
				X2 = mouse.X
				Y2 = mouse.Y
				v10 = nil
				v8 = 0

				if flag3 then
					v11 = true
				end
			end
		else
			local backgroundColor3 = select.BackgroundColor3
			select.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			task.wait(WAIT_INTERVAL)
			select.BackgroundColor3 = backgroundColor3
			task.wait(WAIT_INTERVAL)
			select.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			task.wait(WAIT_INTERVAL)
			select.BackgroundColor3 = backgroundColor3
		end
	end
end)
UserInputService.TouchEnded:Connect(function()
	cFrame = workspace.CurrentCamera.CFrame
	workspace.CurrentCamera.CameraType = Enum.CameraType.Track
	RunService.RenderStepped:Wait()
	workspace.CurrentCamera.CFrame = cFrame
	_G.BlockCameraMovement = false
	v10 = nil
	flag3 = false
	v11 = false
end)
mouse.Button1Up:Connect(function()
	cFrame = workspace.CurrentCamera.CFrame
	workspace.CurrentCamera.CameraType = Enum.CameraType.Track
	RunService.RenderStepped:Wait()
	workspace.CurrentCamera.CFrame = cFrame
	_G.BlockCameraMovement = false
	v10 = nil
	flag3 = false
	v11 = false
end)
explorerSelectionChangedToMain.Event:Connect(function()
	v3 = explorerPanel.GetSelection:Invoke()
	target = v3[1]
	AdornSelected(false)
end)