local CloneStarterGuiForEditOrPlayModule = require(script.Parent.Parent:WaitForChild("CloneStarterGuiForEditOrPlayModule"))
wait(1)
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local studioLiteFolder = ReplicatedStorage:WaitForChild("StudioLiteFolder")
local getMeshInfoServerFunction = studioLiteFolder:WaitForChild("GetMeshInfoServerFunction")
local explorerPanel = script.Parent.Parent:WaitForChild("ExplorerPanel")
explorerPanel:WaitForChild("List", 9)
local explorerSelectionChanged = workspace:WaitForChild("ExplorerSelectionChanged", 9)
local guiBase = nil
local parent = script.Parent
local materialVariantFrame = parent.Parent:WaitForChild("MaterialVariantFrame")
local property = parent:WaitForChild("property")
property.Size = UDim2.new(1, 0, 0, 24)
game.Workspace.AllowThirdPartySales = true
local sL_UIDragFolder = studioLiteFolder:WaitForChild("SL_UIDragFolder")
local sL_ImageLabelsFolder = sL_UIDragFolder:WaitForChild("SL_ImageLabelsFolder")
local sL_SelectedValue = sL_UIDragFolder:WaitForChild("SL_SelectedValue")
_G.SL_ImageLabelsFolderClone = nil
local v = {
	"VideoDeviceInput",
	"StudioAttachment",
	"PluginAction",
	"PluginMenu",
	"ParabolaAdornment",
	"DebuggerWatch"
}
local v2 = {
	"LeftParamA",
	"LeftParamB",
	"TopParamA",
	"TopParamB",
	"BottomParamA",
	"BottomParamB",
	"RightParamA",
	"RightParamB",
	"FrontParamA",
	"FrontParamB",
	"BackParamA",
	"BackParamB",
	"LeftSurfaceInput",
	"TopSurfaceInput",
	"BottomSurfaceInput",
	"RightSurfaceInput",
	"FrontSurfaceInput",
	"BackSurfaceInput",
	"Source",
	"ResizeableFaces",
	"clone",
	"Disabled",
	"Sandboxed",
	"Capabilities",
	"CustomPhysicalProperties",
	"RootLocalizationTable",
	"SelectionImageObject",
	"NextSelectionDown",
	"NextSelectionLeft",
	"NextSelectionRight",
	"NextSelectionUp",
	"className",
	"brickColor",
	"maxHealth"
}
local v3 = {}
local v4 = {
	["Workspace.Studio"] = 1,
	["Workspace.Terrain"] = 1,
	["Workspace.Camera"] = 1,
	Players = 1
}
local v5 = {
	PlayerToHideFrom = 1,
	CameraSubject = 1,
	SideChain = 1,
	WalkToPart = 1,
	PrimaryPart = 1,
	Part0 = 1,
	Part1 = 1,
	ReplicationFocus = 1,
	Target = 1,
	Adornee = 1,
	Attachment0 = 1,
	Attachment1 = 1,
	ReferenceInstance = 1,
	Instance = 1,
	Parent = 1,
	CurrentCamera = 1,
	BoundingUI = 1,
	HoverHapticEffect = 1,
	PressHapticEffect = 1,
	ReferenceUIInstance = 1
}
local HttpService = game:GetService("HttpService")
local OfflineAPI = require(game.ReplicatedStorage.StudioLiteFolder.MainConvertModule.OfflineAPI)
local APISTRING = OfflineAPI.APISTRING

function InsertAlpha(list, value)
	if not (typeof(list) == "table" and typeof(value) == "string") then
		return
	end

	local v6 = nil

	for i = 1, #list do
		if value:find(" ", 1, true) or value == list[i] then
			v6 = true
			break
		end

		if not (value < list[i]) then
			continue
		end

		table.insert(list, i, value)
		v6 = true
		break
	end

	if not v6 then
		table.insert(list, value)
	end
end

local v6 = {}
local success, result = pcall(function()
	v6 = HttpService:JSONDecode(APISTRING)
end)

if not success then
	error("An error occured while trying to decode properties from the API. " .. result)
end

local GetPropertiesFromClassItem

GetPropertiesFromClassItem = function(p, p2)
	local v7 = {}

	for _, class in pairs(v6.Classes) do
		if not (class and class.Name and class.Name == p) then
			continue
		end

		if typeof(class.Members) == "table" then
			for _, member in pairs(class.Members) do
				if not member.MemberType or member.MemberType ~= "Property" or typeof(member.Name) ~= "string" or table.find(
					v2,
					member.Name
				) then
					continue
				end

				if member.Name == "FontFace" then
					InsertAlpha(v7, "Font")
				elseif member.Name == "Position" or member.Name == "Orientation" then
					InsertAlpha(v7, member.Name)
				elseif not (member.Tags and (table.find(member.Tags, "Hidden") or table.find(
					member.Tags,
					"NotScriptable"
				))) and (not member.Security or member.Security.Read and member.Security.Read:sub(-8) ~= "Security" or member.Security.Write and member.Security.Write:sub(-8) ~= "Security") then
					if member.Tags and table.find(member.Tags, "ReadOnly") and member.Name ~= "CurrentPhysicalProperties" then
						v3[p2 .. "." .. member.Name] = 1
					end

					InsertAlpha(v7, member.Name)
				end
			end
		end

		if not class.Superclass then
			continue
		end

		for _, v8 in pairs(GetPropertiesFromClassItem(class.Superclass, p2)) do
			if not v8 or table.find(v7, v8) then
				continue
			end

			InsertAlpha(v7, v8)
		end
	end

	return v7
end

local v7 = {}
local v8 = {}

for _, class in pairs(v6.Classes) do
	if not class.Name or not class.Members or (table.find(v, class.Name) or class.Tags and table.find(
		class.Tags,
		"NotBrowsable"
	)) then
		continue
	end

	local v9 = false

	for _, member in pairs(class.Members) do
		if not (member.MemberType == "Property" and member.Name) then
			continue
		end

		if table.find(v2, member.Name) or member.Tags and (table.find(member.Tags, "Hidden") or table.find(
			member.Tags,
			"Deprecated"
		) or table.find(member.Tags, "NotScriptable")) then
			continue
		end

		if not (not member.Security or member.Security.Read and member.Security.Read:sub(-8) ~= "Security" or member.Security.Write and member.Security.Write:sub(-8) ~= "Security") then
			continue
		end

		InsertAlpha(v7, class.Name)
		v9 = true
		break
	end

	if v9 or not class.Superclass then
		continue
	end

	InsertAlpha(v7, class.Name)
end

for _, v9 in pairs(v7) do
	v8[v9] = GetPropertiesFromClassItem(v9, v9)
end

script.Parent.Parent:WaitForChild("MainBar")
script.Parent.Parent:WaitForChild("TopBar")
local sLWorkspaceFrame = script.Parent.Parent:WaitForChild("SLWorkspaceFrame")
local dragToResize = parent:WaitForChild("DragToResize")
local X = -999
local v9 = false
local offset = -251
local offset2 = 250
local textSize = 9
local mouse = game.Players.LocalPlayer:GetMouse()
dragToResize.MouseButton1Down:Connect(function(p, _)
	X = p
	offset = explorerPanel.Position.X.Offset
	offset2 = explorerPanel.Size.X.Offset
	v9 = true
end)
dragToResize.MouseButton1Up:Connect(function(_, _)
	v9 = false
end)
UserInputService.TouchEnded:Connect(function()
	v9 = false
end)
mouse.Button1Up:Connect(function()
	v9 = false
end)
local v11 = true
mouse.Move:Connect(function()
	if not (v9 and v11) then
		task.wait()
		return
	end

	v11 = false
	local v12 = mouse.X - X

	if offset + v12 > -500 and offset + v12 < -20 then
		offset += v12
		offset2 -= v12
		X = mouse.X
		textSize = math.clamp(offset2 / 25, 5, 9)
		explorerPanel.Position = UDim2.new(
			explorerPanel.Position.X.Scale,
			offset,
			explorerPanel.Position.Y.Scale,
			explorerPanel.Position.Y.Offset
		)
		explorerPanel.Size = UDim2.new(
			explorerPanel.Size.X.Scale,
			offset2,
			explorerPanel.Size.Y.Scale,
			explorerPanel.Size.Y.Offset
		)
		parent.Position = UDim2.new(parent.Position.X.Scale, offset, parent.Position.Y.Scale, parent.Position.Y.Offset)
		parent.Size = UDim2.new(parent.Size.X.Scale, offset2, parent.Size.Y.Scale, parent.Size.Y.Offset)
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
		sLWorkspaceFrame.Size = UDim2.new(
			sLWorkspaceFrame.Size.X.Scale,
			offset - 2,
			sLWorkspaceFrame.Size.Y.Scale,
			sLWorkspaceFrame.Size.Y.Offset
		)
		local insertScriptFrame = explorerPanel.Parent:WaitForChild("InsertScriptFrame")
		insertScriptFrame.Position = UDim2.new(0, 3, 0, 79)
		explorerPanel.Parent.InsertScriptFrame.Size = UDim2.new(1, offset - 2, 1, -84)
		local insertLocalScriptFrame = explorerPanel.Parent:WaitForChild("InsertLocalScriptFrame")
		insertLocalScriptFrame.Position = UDim2.new(0, 3, 0, 79)
		explorerPanel.Parent.InsertLocalScriptFrame.Size = UDim2.new(1, offset - 2, 1, -84)
	end

	v11 = true
end)

function GetPropertiesAndValues(instance)
	assert(pcall(function()
		assert(game.IsA(instance, "Instance"))
	end), "Should be ROBLOX instance")
	local result2 = {}

	for _, childName in pairs(v8[instance.ClassName] or {}) do
		local v12 = childName

		if not pcall(function()
			return instance[v12]
		end) then
			continue
		end

		if not (type(instance[childName]) ~= "userdata" or not instance:FindFirstChild(childName)) then
			continue
		end

		table.insert(result2, { childName, instance[childName] })
	end

	return result2
end

local scrollFrame = parent.ScrollFrame
local v12 = 0
scrollFrame.ScrollBar.ScrollThumb.Changed:Connect(function()
	local v13 = scrollFrame.ScrollBar.AbsoluteSize.Y - scrollFrame.ScrollBar.ScrollThumb.AbsoluteSize.Y
	scrollFrame.ScrollBar.ScrollThumb.Position = UDim2.new(0, 0, 0, scrollFrame.ScrollBar.ScrollThumb.Position.Y.Offset)

	if scrollFrame.ScrollBar.ScrollThumb.Position.Y.Offset < 0 then
		scrollFrame.ScrollBar.ScrollThumb.Position = UDim2.new(0, 0, 0, 0)
	elseif v13 < scrollFrame.ScrollBar.ScrollThumb.Position.Y.Offset then
		scrollFrame.ScrollBar.ScrollThumb.Position = UDim2.new(0, 0, 0, v13)
	end

	if scrollFrame.ScrollBar.ScrollThumb.Position.Y.Offset == 0 then
		for _, child in pairs(scrollFrame.ScrollUp["Arrow Graphic"]:GetChildren()) do
			child.BackgroundTransparency = 0.7
		end
	else
		for _, child in pairs(scrollFrame.ScrollUp["Arrow Graphic"]:GetChildren()) do
			child.BackgroundTransparency = 0
		end
	end

	if scrollFrame.ScrollBar.ScrollThumb.Position.Y.Offset == v13 then
		for _, child in pairs(scrollFrame.ScrollDown["Arrow Graphic"]:GetChildren()) do
			child.BackgroundTransparency = 0.7
		end
	else
		for _, child in pairs(scrollFrame.ScrollDown["Arrow Graphic"]:GetChildren()) do
			child.BackgroundTransparency = 0
		end
	end

	for _, child in pairs(parent.List:GetChildren()) do
		child.Position = UDim2.new(
			child.Position.X.Scale,
			child.Position.X.Offset,
			0,
			child.P.Value - scrollFrame.ScrollBar.ScrollThumb.Position.Y.Offset * 25
		)
	end
end)
scrollFrame.ScrollDown.MouseButton1Down:Connect(function()
	ScrollProperties("Down")
end)
scrollFrame.ScrollDown.MouseButton1Up:Connect(function()
	ScrollProperties("Stop")
end)
scrollFrame.ScrollDown.MouseLeave:Connect(function()
	ScrollProperties("Stop")
end)
scrollFrame.ScrollUp.MouseButton1Down:Connect(function()
	ScrollProperties("Up")
end)
scrollFrame.ScrollUp.MouseButton1Up:Connect(function()
	ScrollProperties("Stop")
end)
scrollFrame.ScrollUp.MouseLeave:Connect(function()
	ScrollProperties("Stop")
end)
parent.MouseWheelForward:Connect(function()
	ScrollProperties("Up")
	task.wait(0.2)
	ScrollProperties("Stop")
end)
parent.MouseWheelBackward:Connect(function()
	ScrollProperties("Down")
	task.wait(0.2)
	ScrollProperties("Stop")
end)
local v13 = -999
local flag = false
parent.InvisibleTextButtonForMouseDown.MouseButton1Down:Connect(function(_, p)
	v13 = p
	flag = true
end)
parent.InvisibleTextButtonForMouseDown.MouseButton1Up:Connect(function()
	flag = false
end)
parent.InvisibleTextButtonForMouseDown.MouseLeave:Connect(function()
	flag = false
end)
parent.InvisibleTextButtonForMouseDown.MouseMoved:Connect(function(_, p)
	if flag then
		local v14 = p - v13

		if v14 > 10 then
			ScrollProperties("Up")
			task.wait()
			ScrollProperties("Stop")
			v13 = p
		elseif v14 < -10 then
			ScrollProperties("Down")
			task.wait()
			ScrollProperties("Stop")
			v13 = p
		end
	end
end)
local v14 = "Stop"

function ScrollProperties(p)
	if p ~= v14 then
		v14 = p

		if v14 ~= "Stop" then
			spawn(function()
				while v14 == "Up" do
					task.wait()
					scrollFrame.ScrollBar.ScrollThumb.Position = UDim2.new(
						0,
						0,
						0,
						scrollFrame.ScrollBar.ScrollThumb.Position.Y.Offset - 1
					)
				end

				while v14 == "Down" do
					task.wait()
					scrollFrame.ScrollBar.ScrollThumb.Position = UDim2.new(
						0,
						0,
						0,
						scrollFrame.ScrollBar.ScrollThumb.Position.Y.Offset + 1
					)
				end
			end)
		end
	end
end

function CheckMultiSelect(instance, p)
	local v15 = explorerPanel.GetSelection:Invoke()

	if #v15 > 1 then
		if p == "Anchored" then
			for i = 1, #v15 do
				if v15[i] == instance then
					continue
				end

				local v16 = i
				pcall(function()
					v15[v16].Anchored = instance.Anchored

					if instance:GetAttribute("SL_Anchored") ~= nil then
						v15[v16]:SetAttribute("SL_Anchored", instance:GetAttribute("SL_Anchored"))
					end
				end)
			end
		elseif p == "CanCollide" then
			for i = 1, #v15 do
				if v15[i] == instance then
					continue
				end

				local v16 = i
				pcall(function()
					v15[v16].CanCollide = instance.CanCollide

					if instance:GetAttribute("SL_CanCollide") ~= nil then
						v15[v16]:SetAttribute("SL_CanCollide", instance:GetAttribute("SL_CanCollide"))
					end
				end)
			end
		else
			local v16 = p == "CurrentPhysicalProperties" and "CustomPhysicalProperties" or p

			for i = 1, #v15 do
				if v15[i] == instance then
					continue
				end

				local v17 = i
				pcall(function()
					v15[v17][v16] = instance[v16]
				end)
			end
		end
	end
end

function CheckScreenGuiUpdate(instance)
	if instance:IsDescendantOf(game.StarterGui) then
		CloneStarterGuiForEditOrPlayModule:Edit()
	end
end

local connections = {}
explorerSelectionChanged.Event:Connect(function()
	local IMAGE_ID = "http://www.roblox.com/asset/?id=293296862"
	guiBase = explorerPanel.GetSelection:Invoke()[1]
	v12 = 0
	scrollFrame.ScrollBar.ScrollThumb.Position = UDim2.new(0, 0, 0, 0)

	for _, connection in pairs(connections) do
		connection:disconnect()
	end

	connections = {}

	for _, child in pairs(parent.List:GetChildren()) do
		child:Destroy()
	end

	local colorPalette = script.Parent.Parent:WaitForChild("ColorPalette")
	colorPalette.Visible = false
	_G.GetObjectValue = false
	_G.ObjectValue = nil

	if guiBase then
		local color = Color3.new(0.8666666666666667, 0.8666666666666667, 0.8705882352941177)
		local color2 = Color3.new(0.9372549019607843, 0.9372549019607843, 0.9411764705882353)
		local v15 = true
		local character = game.Players.LocalPlayer.Character

		if character:FindFirstChild("SL_MoveLocal") then
			character:FindFirstChild("SL_MoveLocal"):Destroy()
		end

		if character:FindFirstChild("SL_SizeLocal") then
			character:FindFirstChild("SL_SizeLocal"):Destroy()
		end

		local function IsDescendantOfClass(parent2, p)
			while parent2.Parent.ClassName ~= p and parent2.Parent ~= game do
				parent2 = parent2.Parent
			end

			return parent2.Parent.ClassName == p
		end

		if guiBase:IsA("GuiBase") and guiBase.ClassName ~= "ScreenGui" and guiBase.ClassName ~= "SurfaceGui" then
			if _G.SL_ImageLabelsFolderClone then
				_G.SL_ImageLabelsFolderClone:Destroy()
			end

			_G.SL_ImageLabelsFolderClone = sL_ImageLabelsFolder:Clone()
			_G.SL_ImageLabelsFolderClone.Parent = guiBase
			sL_SelectedValue.Value = guiBase

			if IsDescendantOfClass(guiBase, "SurfaceGui") then
				local sL_MoveLocal = _G.SL_ImageLabelsFolderClone:WaitForChild("SL_MoveImageLabel"):WaitForChild("SL_MoveUIDragDetector"):WaitForChild("SL_MoveLocal")
				sL_MoveLocal.Parent = character
				local sL_SizeLocal = _G.SL_ImageLabelsFolderClone:WaitForChild("SL_SizeImageLabel"):WaitForChild("SL_SizeUIDragDetector"):WaitForChild("SL_SizeLocal")
				sL_SizeLocal.Parent = character
			else
				CheckScreenGuiUpdate(guiBase)
			end
		elseif _G.SL_ImageLabelsFolderClone then
			_G.SL_ImageLabelsFolderClone:Destroy()
			CloneStarterGuiForEditOrPlayModule:Edit()
		end

		local v16 = GetPropertiesAndValues(guiBase)

		if v16 and type(v16) == "table" then
			for _, v17 in ipairs(v16) do
				local text2 = v17[1]
				local sL_Anchored = v17[2]

				if not (type(sL_Anchored) == "string" or type(sL_Anchored) == "number" or type(sL_Anchored) == "userdata" or type(sL_Anchored) == "boolean" or type(sL_Anchored) == "vector" or sL_Anchored == nil) then
					continue
				end

				local clone = script.Parent.property:Clone()
				clone.Parent = parent.List

				if v15 then
					clone.BackgroundColor3 = color
				else
					clone.BackgroundColor3 = color2
				end

				v15 = not v15
				clone.Position = UDim2.new(0, 0, 0, (#parent.List:GetChildren() - 1) * 24 + 1)
				local numberValue = Instance.new("NumberValue", clone)
				numberValue.Name = "P"
				numberValue.Value = clone.Position.Y.Offset
				clone.name.locked.Text = text2
				clone.name.unlocked.Text = text2
				clone.Visible = true
				local v19 = v3[guiBase.ClassName .. "." .. text2]
				local v20 = v4[guiBase:GetFullName()] and true or v19

				if v20 then
					clone.name.locked.Visible = true
				else
					clone.name.unlocked.Visible = true
				end

				local text = sL_Anchored

				if type(sL_Anchored) == "userdata" or type(sL_Anchored) == "vector" or sL_Anchored == nil then
					if v5[text2] or text2 == "ObjectValue" or guiBase.ClassName == "ObjectValue" and text2 == "Value" then
						local locked = clone.edit.locked

						if v20 then
							locked = clone.edit.locked
						end

						locked.TextColor3 = Color3.fromRGB(25, 25, 25)
						locked.Visible = true

						if not v20 then
							local v21 = text2
							connections[#connections + 1] = locked.MouseButton1Click:Connect(function()
								if not _G.GetObjectValue then
									_G.GetObjectValue = true
									_G.ObjectValue = nil
									text = locked.Text
									locked.Text = "Click object above"
									task.wait(0.8)
									locked.Text = text

									while _G.ObjectValue == nil do
										task.wait(0.2)
									end

									if not pcall(function()
										guiBase[v21] = _G.ObjectValue
										text = tostring(_G.ObjectValue)
										locked.Text = tostring(_G.ObjectValue)
										CheckMultiSelect(guiBase, v21)
										CheckScreenGuiUpdate(guiBase)
										task.wait()
									end) then
										pcall(function()
											locked.Text = text
										end)
									end

									_G.ObjectValue = nil
								end
							end)
						end

						pcall(function()
							locked.Text = tostring(sL_Anchored)
						end)
					elseif pcall(function()
						local _ = sL_Anchored.lookVector
					end) then
						local box = clone.edit.box

						if v20 then
							box = clone.edit.locked
						end

						box.Visible = true

						if not v20 then
							local v21 = text2
							connections[#connections + 1] = box.FocusLost:Connect(function()
								if not pcall(function()
									local v22 = {}

									for k in box.Text:gsub(" ", ""):gmatch("[%-?%d%.]+") do
										table.insert(v22, (tonumber(k)))
									end

									if #v22 ~= 6 then
										error()
										return
									end

									local v23 = CFrame.new(v22[1], v22[2], v22[3]) * CFrame.fromOrientation(
										math.rad(v22[4]),
										math.rad(v22[5]),
										(math.rad(v22[6]))
									)
									guiBase[v21] = v23
									text = v23
									local orientation, v24, v25 = text:ToOrientation()
									box.Text = "p(" .. math.floor(text.Position.X * 1000) / 1000 .. ", " .. math.floor(text.Position.Y * 1000) / 1000 .. ", " .. math.floor(text.Position.Z * 1000) / 1000 .. "),o(" .. math.floor(math.deg(orientation) * 10 + 0.001) / 10 .. ", " .. math.floor(math.deg(v24) * 10 + 0.001) / 10 .. ", " .. math.floor(math.deg(v25) * 10 + 0.001) / 10 .. ")"
								end) then
									pcall(function()
										local orientation, v22, v23 = text:ToOrientation()
										box.Text = "p(" .. math.floor(text.Position.X * 1000) / 1000 .. ", " .. math.floor(text.Position.Y * 1000) / 1000 .. ", " .. math.floor(text.Position.Z * 1000) / 1000 .. "),o(" .. math.floor(math.deg(orientation) * 10 + 0.001) / 10 .. ", " .. math.floor(math.deg(v22) * 10 + 0.001) / 10 .. ", " .. math.floor(math.deg(v23) * 10 + 0.001) / 10 .. ")"
									end)
								end
							end)
						end

						pcall(function()
							local orientation, v21, v22 = sL_Anchored:ToOrientation()
							box.Text = "p(" .. math.floor(sL_Anchored.Position.X * 1000) / 1000 .. ", " .. math.floor(sL_Anchored.Position.Y * 1000) / 1000 .. ", " .. math.floor(sL_Anchored.Position.Z * 1000) / 1000 .. "),o(" .. math.floor(math.deg(orientation) * 10 + 0.001) / 10 .. ", " .. math.floor(math.deg(v21) * 10 + 0.001) / 10 .. ", " .. math.floor(math.deg(v22) * 10 + 0.001) / 10 .. ")"
						end)
					elseif pcall(function()
						local _ = sL_Anchored.X
						local _ = sL_Anchored.Y
						local _ = sL_Anchored.Z
					end) then
						local box = clone.edit.box

						if v20 then
							box = clone.edit.locked
						end

						box.Visible = true

						if not v20 then
							local v21 = text2
							connections[#connections + 1] = box.FocusLost:Connect(function()
								if not pcall(function()
									local v22 = {}

									for k in box.Text:gsub(" ", ""):gmatch("[^,]+") do
										table.insert(v22, (tonumber(k)))
									end

									if #v22 ~= 3 then
										error()
										return
									end

									if not (v22[1] and v22[2] and v22[3]) then
										error()
										return
									end

									local vector = Vector3.new(v22[1], v22[2], v22[3])
									guiBase[v21] = vector
									text = vector
									box.Text = math.floor(vector.X * 1000) / 1000 .. ", " .. math.floor(vector.Y * 1000) / 1000 .. ", " .. math.floor(vector.Z * 1000) / 1000

									if v21 == "AssemblyLinearVelocity" then
										guiBase:SetAttribute("SL_AssemblyLinearVelocity", vector)
									elseif v21 == "AssemblyAngularVelocity" then
										guiBase:SetAttribute("SL_AssemblyAngularVelocity", vector)
									end

									CheckMultiSelect(guiBase, v21)
									CheckScreenGuiUpdate(guiBase)
								end) then
									pcall(function()
										box.Text = math.floor(text.X * 1000) / 1000 .. ", " .. math.floor(text.Y * 1000) / 1000 .. ", " .. math.floor(text.Z * 1000) / 1000
									end)
								end
							end)
						end

						pcall(function()
							box.Text = math.floor(sL_Anchored.X * 1000) / 1000 .. ", " .. math.floor(sL_Anchored.Y * 1000) / 1000 .. ", " .. math.floor(sL_Anchored.Z * 1000) / 1000
						end)
					elseif pcall(function()
						local _ = sL_Anchored.X.Scale
						local _ = sL_Anchored.X.Offset
					end) then
						local box = clone.edit.box

						if v20 then
							box = clone.edit.locked
						end

						box.Visible = true

						if not v20 then
							local v21 = text2
							connections[#connections + 1] = box.FocusLost:Connect(function()
								if not pcall(function()
									local v22 = {}

									for k in box.Text:gsub(" ", ""):gsub("{", ""):gsub("}", ""):gmatch("[^,]+") do
										table.insert(v22, (tonumber(k)))
									end

									if #v22 ~= 4 then
										error()
										return
									end

									if not (v22[1] and v22[2] and v22[3] and v22[4]) then
										error()
										return
									end

									local uDim = UDim2.new(v22[1], v22[2], v22[3], v22[4])
									guiBase[v21] = uDim
									text = uDim
									box.Text = "{" .. math.floor(uDim.X.Scale * 1000) / 1000 .. ", " .. math.floor(uDim.X.Offset * 1000) / 1000 .. "}, {" .. math.floor(uDim.Y.Scale * 1000) / 1000 .. ", " .. math.floor(uDim.Y.Offset * 1000) / 1000 .. "}"
									CheckMultiSelect(guiBase, v21)
									CheckScreenGuiUpdate(guiBase)
								end) then
									pcall(function()
										box.Text = "{" .. math.floor(text.X.Scale * 1000) / 1000 .. ", " .. math.floor(text.X.Offset * 1000) / 1000 .. "}, {" .. math.floor(text.Y.Scale * 1000) / 1000 .. ", " .. math.floor(text.Y.Offset * 1000) / 1000 .. "}"
									end)
								end
							end)
						end

						pcall(function()
							box.Text = "{" .. math.floor(sL_Anchored.X.Scale * 1000) / 1000 .. ", " .. math.floor(sL_Anchored.X.Offset * 1000) / 1000 .. "}, {" .. math.floor(sL_Anchored.Y.Scale * 1000) / 1000 .. ", " .. math.floor(sL_Anchored.Y.Offset * 1000) / 1000 .. "}"
						end)
					elseif pcall(function()
						local _ = sL_Anchored.X
						local _ = sL_Anchored.Y
					end) then
						local box = clone.edit.box

						if v20 then
							box = clone.edit.locked
						end

						box.Visible = true

						if not v20 then
							local v21 = text2
							connections[#connections + 1] = box.FocusLost:Connect(function()
								if not pcall(function()
									local v22 = {}

									for k in box.Text:gsub(" ", ""):gmatch("[^,]+") do
										table.insert(v22, (tonumber(k)))
									end

									if #v22 ~= 2 then
										error()
										return
									end

									if not (v22[1] and v22[2]) then
										error()
										return
									end

									local vector = Vector2.new(v22[1], v22[2])
									guiBase[v21] = vector
									text = vector
									box.Text = math.floor(vector.X * 1000) / 1000 .. ", " .. math.floor(vector.Y * 1000) / 1000
									CheckMultiSelect(guiBase, v21)
									CheckScreenGuiUpdate(guiBase)
								end) then
									pcall(function()
										box.Text = math.floor(text.X * 1000) / 1000 .. ", " .. math.floor(text.Y * 1000) / 1000
									end)
								end
							end)
						end

						pcall(function()
							box.Text = math.floor(sL_Anchored.X * 1000) / 1000 .. ", " .. math.floor(sL_Anchored.Y * 1000) / 1000
						end)
					elseif pcall(function()
						local _ = sL_Anchored.Scale
						local _ = sL_Anchored.Offset
					end) then
						local box = clone.edit.box

						if v20 then
							box = clone.edit.locked
						end

						box.Visible = true

						if not v20 then
							local v21 = text2
							connections[#connections + 1] = box.FocusLost:Connect(function()
								if not pcall(function()
									local v22 = {}

									for k in box.Text:gsub(" ", ""):gmatch("[^,]+") do
										table.insert(v22, (tonumber(k)))
									end

									if #v22 ~= 2 then
										error()
										return
									end

									if not (v22[1] and v22[2]) then
										error()
										return
									end

									local uDim = UDim.new(v22[1], v22[2])
									guiBase[v21] = uDim
									text = uDim
									box.Text = math.floor(uDim.Scale * 1000) / 1000 .. ", " .. math.floor(uDim.Offset * 1000) / 1000
									CheckMultiSelect(guiBase, v21)
									CheckScreenGuiUpdate(guiBase)
								end) then
									pcall(function()
										box.Text = math.floor(text.Scale * 1000) / 1000 .. ", " .. math.floor(text.Offset * 1000) / 1000
									end)
								end
							end)
						end

						pcall(function()
							box.Text = math.floor(sL_Anchored.Scale * 1000) / 1000 .. ", " .. math.floor(sL_Anchored.Offset * 1000) / 1000
						end)
					elseif pcall(function()
						local _ = sL_Anchored.Min
						local _ = sL_Anchored.Max
					end) then
						local box = clone.edit.box

						if v20 then
							box = clone.edit.locked
						end

						box.Visible = true

						if not v20 then
							local v21 = text2
							connections[#connections + 1] = box.FocusLost:Connect(function()
								if not pcall(function()
									local v22 = {}

									for k in box.Text:gsub(" ", ""):gmatch("[^,]+") do
										table.insert(v22, (tonumber(k)))
									end

									if #v22 ~= 2 then
										error()
										return
									end

									if not (v22[1] and v22[2]) then
										error()
										return
									end

									local numberRange = NumberRange.new(v22[1], v22[2])
									guiBase[v21] = numberRange
									text = numberRange
									box.Text = math.floor(numberRange.Min * 1000) / 1000 .. ", " .. math.floor(numberRange.Max * 1000) / 1000
									CheckMultiSelect(guiBase, v21)
									CheckScreenGuiUpdate(guiBase)
								end) then
									pcall(function()
										box.Text = math.floor(text.Min * 1000) / 1000 .. ", " .. math.floor(text.Max * 1000) / 1000
									end)
								end
							end)
						end

						pcall(function()
							box.Text = math.floor(sL_Anchored.Min * 1000) / 1000 .. ", " .. math.floor(sL_Anchored.Max * 1000) / 1000
						end)
					elseif typeof(sL_Anchored) == "NumberSequence" then
						local box = clone.edit.box

						if v20 then
							box = clone.edit.locked
						end

						box.Visible = true

						if not v20 then
							local v21 = text2
							connections[#connections + 1] = box.FocusLost:Connect(function()
								if not pcall(function()
									text = box.Text
									local numberSequenceKeypoints = {}

									for k, v22 in box.Text:gmatch("%((.-),(.-)%)") do
										table.insert(
											numberSequenceKeypoints,
											NumberSequenceKeypoint.new(
												math.floor(tonumber(k) * 1000) / 1000,
												math.floor(tonumber(v22) * 1000) / 1000
											)
										)
									end

									guiBase[v21] = NumberSequence.new(numberSequenceKeypoints)
									CheckMultiSelect(guiBase, v21)
									CheckScreenGuiUpdate(guiBase)
								end) then
									pcall(function()
										box.Text = text
									end)
								end
							end)
						end

						local v21 = ""

						for _, keypoint in sL_Anchored.Keypoints do
							v21 ..= "(" .. tostring(math.floor(keypoint.Time * 1000) / 1000) .. "," .. tostring(math.floor(keypoint.Value * 1000) / 1000) .. "),"
						end

						box.Text = v21:sub(1, #v21 - 1)
					elseif typeof(sL_Anchored) == "PhysicalProperties" then
						local box = clone.edit.box

						if v20 then
							box = clone.edit.locked
						end

						box.Visible = true

						if not v20 then
							local v21 = text2
							connections[#connections + 1] = box.FocusLost:Connect(function()
								local success2, result2 = pcall(function()
									text = box.Text
									local match, v22, v23, v24, v25, v26 = box.Text:match("d:(.-),f:(.-),e:(.-),fw:(.-),ew:(.-),a:(.-)$")
									guiBase.CustomPhysicalProperties = PhysicalProperties.new(
										math.floor((tonumber(match) or 0) * 100 + 0.00001) / 100,
										math.floor((tonumber(v22) or 0) * 100 + 0.00001) / 100,
										math.floor((tonumber(v23) or 0) * 100 + 0.00001) / 100,
										math.floor((tonumber(v24) or 0) * 100 + 0.00001) / 100,
										math.floor((tonumber(v25) or 0) * 100 + 0.00001) / 100,
										math.floor((tonumber(v26) or 0) * 100 + 0.00001) / 100
									)
									CheckMultiSelect(guiBase, v21)
									CheckScreenGuiUpdate(guiBase)
								end)

								if not success2 then
									warn("PhysicalProperties issue:", result2)
									pcall(function()
										box.Text = text
									end)
								end
							end)
						end

						box.Text = "d:" .. tostring(math.floor(sL_Anchored.Density * 100 + 0.00001) / 100) .. ",f:" .. tostring(math.floor(sL_Anchored.Friction * 100 + 0.00001) / 100) .. ",e:" .. tostring(math.floor(sL_Anchored.Elasticity * 100 + 0.00001) / 100) .. ",fw:" .. tostring(math.floor(sL_Anchored.FrictionWeight * 100 + 0.00001) / 100) .. ",ew:" .. tostring(math.floor(sL_Anchored.ElasticityWeight * 100 + 0.00001) / 100) .. ",a:" .. tostring(math.floor(sL_Anchored.AcousticAbsorption * 100 + 0.00001) / 100)
					elseif typeof(sL_Anchored) == "ColorSequence" then
						local box = clone.edit.box

						if v20 then
							box = clone.edit.locked
						end

						box.Visible = true
						local textButton = Instance.new("TextButton")
						textButton.ZIndex = 1
						textButton.Parent = clone.edit
						textButton.Position = UDim2.new(0, 1, 0, 1)
						textButton.Size = UDim2.new(0, 24, 1, -2)
						textButton.BackgroundColor3 = sL_Anchored.Keypoints[1].Value
						textButton.Text = ""
						local textButton2 = Instance.new("TextButton")
						textButton2.ZIndex = 1
						textButton2.Parent = clone.edit
						textButton2.Position = UDim2.new(0, 29, 0, 1)
						textButton2.Size = UDim2.new(0, 24, 1, -2)
						textButton2.BackgroundColor3 = sL_Anchored.Keypoints[#sL_Anchored.Keypoints].Value
						textButton2.Text = ""

						if not v20 then
							local v21 = textButton
							local v22 = text2
							local v23 = textButton2
							connections[#connections + 1] = textButton.MouseButton1Click:Connect(function()
								local selectedColor = colorPalette:WaitForChild("SelectedColor")
								local selectedColorText = colorPalette:WaitForChild("SelectedColorText")
								local selectedBrickColorText = colorPalette:WaitForChild("SelectedBrickColorText")
								local colorPaletteCrosshairs = colorPalette:WaitForChild("Palette"):WaitForChild("ColorPaletteCrosshairs")
								local darknessPointer = colorPalette:WaitForChild("DarknessAppearance"):WaitForChild("DarknessPointer")
								local uIGradient = colorPalette:WaitForChild("DarknessAppearance"):WaitForChild("UIGradient")
								selectedColor.BackgroundColor3 = v21.BackgroundColor3
								selectedColor.Text = "Color"
								selectedColorText.Text = "r,g,b:  " .. box.Text
								selectedBrickColorText.Text = tostring(BrickColor.new(v21.BackgroundColor3))
								local HSV, v24, v25 = v21.BackgroundColor3:ToHSV()
								colorPaletteCrosshairs.Position = UDim2.new(
									0,
									220 - HSV * 220 - 14,
									0,
									200 - v24 * 200 - 14
								)
								darknessPointer.Position = UDim2.new(0, 14, 0, 200 - v25 * 200 - 6)
								uIGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(HSV, v24, 1))
								colorPalette.Visible = true
								local okButton = colorPalette:WaitForChild("OkButton")
								local cancelButton = colorPalette:WaitForChild("CancelButton")
								local v26 = #connections + 1
								local v27 = #connections + 1
								connections[#connections + 1] = cancelButton.MouseButton1Click:Connect(function()
									colorPalette.Visible = false
									connections[v26]:disconnect()
									connections[v27]:disconnect()
								end)
								v27 = #connections + 1
								connections[#connections + 1] = okButton.MouseButton1Click:Connect(function()
									v21.BackgroundColor3 = selectedColor.BackgroundColor3
									guiBase[v22] = ColorSequence.new(v21.BackgroundColor3, v23.BackgroundColor3)
									CheckMultiSelect(guiBase, v22)
									CheckScreenGuiUpdate(guiBase)
									colorPalette.Visible = false
									connections[v26]:disconnect()
									connections[v27]:disconnect()
								end)
							end)
							local v24 = textButton2
							local v25 = text2
							local v26 = textButton
							connections[#connections + 1] = textButton2.MouseButton1Click:Connect(function()
								local selectedColor = colorPalette:WaitForChild("SelectedColor")
								local selectedColorText = colorPalette:WaitForChild("SelectedColorText")
								local selectedBrickColorText = colorPalette:WaitForChild("SelectedBrickColorText")
								local colorPaletteCrosshairs = colorPalette:WaitForChild("Palette"):WaitForChild("ColorPaletteCrosshairs")
								local darknessPointer = colorPalette:WaitForChild("DarknessAppearance"):WaitForChild("DarknessPointer")
								local uIGradient = colorPalette:WaitForChild("DarknessAppearance"):WaitForChild("UIGradient")
								selectedColor.BackgroundColor3 = v24.BackgroundColor3
								selectedColor.Text = "Color"
								selectedColorText.Text = "r,g,b:  " .. box.Text
								selectedBrickColorText.Text = tostring(BrickColor.new(v24.BackgroundColor3))
								local HSV, v27, v28 = v24.BackgroundColor3:ToHSV()
								colorPaletteCrosshairs.Position = UDim2.new(
									0,
									220 - HSV * 220 - 14,
									0,
									200 - v27 * 200 - 14
								)
								darknessPointer.Position = UDim2.new(0, 14, 0, 200 - v28 * 200 - 6)
								uIGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(HSV, v27, 1))
								colorPalette.Visible = true
								local okButton = colorPalette:WaitForChild("OkButton")
								local cancelButton = colorPalette:WaitForChild("CancelButton")
								local v29 = #connections + 1
								local v30 = #connections + 1
								connections[#connections + 1] = cancelButton.MouseButton1Click:Connect(function()
									colorPalette.Visible = false
									connections[v29]:disconnect()
									connections[v30]:disconnect()
								end)
								v30 = #connections + 1
								connections[#connections + 1] = okButton.MouseButton1Click:Connect(function()
									v24.BackgroundColor3 = selectedColor.BackgroundColor3
									guiBase[v25] = ColorSequence.new(v26.BackgroundColor3, v24.BackgroundColor3)
									CheckMultiSelect(guiBase, v25)
									CheckScreenGuiUpdate(guiBase)
									colorPalette.Visible = false
									connections[v29]:disconnect()
									connections[v30]:disconnect()
								end)
							end)
						end

						pcall(function()
							box.Text = math.floor(sL_Anchored.r * 255) .. ", " .. math.floor(sL_Anchored.g * 255) .. ", " .. math.floor(sL_Anchored.b * 255)
						end)
					elseif pcall(function()
						local _ = sL_Anchored.Color
						local _ = sL_Anchored.Color.r
						local _ = sL_Anchored.Color.g
						local _ = sL_Anchored.Color.b
					end) then
						local box = clone.edit.box

						if v20 then
							box = clone.edit.locked
						end

						box.Visible = true

						if not v20 then
							local textButton = Instance.new("TextButton")
							textButton.ZIndex = 1
							textButton.Parent = clone.edit
							textButton.Position = UDim2.new(0, 0, 0, 0)
							textButton.Size = UDim2.new(1, 0, 1, 0)
							textButton.BackgroundTransparency = 0.9
							textButton.Text = ""
							local v21 = text2
							connections[#connections + 1] = textButton.MouseButton1Click:Connect(function()
								local selectedColor = colorPalette:WaitForChild("SelectedColor")
								local selectedColorText = colorPalette:WaitForChild("SelectedColorText")
								local selectedBrickColorText = colorPalette:WaitForChild("SelectedBrickColorText")
								local colorPaletteCrosshairs = colorPalette:WaitForChild("Palette"):WaitForChild("ColorPaletteCrosshairs")
								local darknessPointer = colorPalette:WaitForChild("DarknessAppearance"):WaitForChild("DarknessPointer")
								local uIGradient = colorPalette:WaitForChild("DarknessAppearance"):WaitForChild("UIGradient")
								selectedColor.BackgroundColor3 = BrickColor.new(box.Text).Color
								selectedColor.Text = "BrickColor"
								selectedColorText.Text = "r,g,b:  " .. math.floor(selectedColor.BackgroundColor3.R * 255) .. ", " .. math.floor(selectedColor.BackgroundColor3.G * 255) .. ", " .. math.floor(selectedColor.BackgroundColor3.B * 255)
								selectedBrickColorText.Text = box.Text
								local HSV, v22, v23 = selectedColor.BackgroundColor3:ToHSV()
								colorPaletteCrosshairs.Position = UDim2.new(
									0,
									220 - HSV * 220 - 14,
									0,
									200 - v22 * 200 - 14
								)
								darknessPointer.Position = UDim2.new(0, 14, 0, 200 - v23 * 200 - 6)
								uIGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(HSV, v22, 1))
								colorPalette.Visible = true
								local okButton = colorPalette:WaitForChild("OkButton")
								local cancelButton = colorPalette:WaitForChild("CancelButton")
								local v24 = #connections + 1
								local v25 = #connections + 1
								connections[#connections + 1] = cancelButton.MouseButton1Click:Connect(function()
									colorPalette.Visible = false
									connections[v24]:disconnect()
									connections[v25]:disconnect()
								end)
								v25 = #connections + 1
								connections[#connections + 1] = okButton.MouseButton1Click:Connect(function()
									box.Text = selectedBrickColorText.Text
									guiBase[v21] = BrickColor.new(selectedColor.BackgroundColor3)
									local v26 = v21 == "BrickColor" and "Color" or v21 .. "3"

									for i, child in ipairs(parent.List:GetChildren()) do
										if child:WaitForChild("name"):WaitForChild("unlocked").Text ~= v26 then
											continue
										end

										local box_2 = child:WaitForChild("edit"):WaitForChild("box")
										box_2.Text = selectedColorText.Text:sub(8)
										local textButton = child:WaitForChild("edit"):WaitForChild("TextButton")
										textButton.BackgroundColor3 = selectedColor.BackgroundColor3
										break
									end

									CheckMultiSelect(guiBase, v21)
									CheckScreenGuiUpdate(guiBase)
									colorPalette.Visible = false
									connections[v24]:disconnect()
									connections[v25]:disconnect()
								end)
							end)
						end

						pcall(function()
							box.Text = tostring(sL_Anchored)
						end)
					elseif pcall(function()
						local _ = sL_Anchored.r
						local _ = sL_Anchored.g
						local _ = sL_Anchored.b
					end) then
						local box = clone.edit.box

						if v20 then
							box = clone.edit.locked
						end

						box.Visible = true
						box.TextXAlignment = Enum.TextXAlignment.Center
						local textButton = Instance.new("TextButton")
						textButton.ZIndex = 1
						textButton.Parent = clone.edit
						textButton.Position = UDim2.new(0, 1, 0, 1)
						textButton.Size = UDim2.new(0, 24, 1, -2)
						textButton.BackgroundColor3 = sL_Anchored
						textButton.Text = ""
						box.Position = UDim2.new(0, 26, 0, 0)
						box.Size = UDim2.new(1, -39, 1, 0)

						if not v20 then
							local v21 = text2
							local v22 = textButton
							connections[#connections + 1] = box.FocusLost:Connect(function()
								if not pcall(function()
									local v23 = {}

									for k in box.Text:gsub(" ", ""):gmatch("[^,]+") do
										table.insert(v23, (math.clamp(math.floor((tonumber(k))), 0, 255)))
									end

									if #v23 ~= 3 then
										error("Wrong number of Color3 values.")
										return
									end

									if not (v23[1] and v23[2] and v23[3]) then
										error("Wrong Color3 values.")
										return
									end

									local color3 = Color3.fromRGB(v23[1], v23[2], v23[3])
									guiBase[v21] = color3
									box.Text = v23[1] .. ", " .. v23[2] .. ", " .. v23[3]
									v22.BackgroundColor3 = color3
									local v24 = ""

									if v21 == "Color" then
										v24 = "BrickColor"
									elseif v21:sub(-1) == "3" then
										v24 = v21:sub(1, -2)
									end

									for i, child in ipairs(parent.List:GetChildren()) do
										if child:WaitForChild("name"):WaitForChild("unlocked").Text ~= v24 then
											continue
										end

										local box_2 = child:WaitForChild("edit"):WaitForChild("box")
										box_2.Text = tostring(BrickColor.new(v22.BackgroundColor3))
										break
									end

									CheckMultiSelect(guiBase, v21)
									CheckScreenGuiUpdate(guiBase)
								end) then
									pcall(function()
										box.Text = math.floor(sL_Anchored.r * 255) .. ", " .. math.floor(sL_Anchored.g * 255) .. ", " .. math.floor(sL_Anchored.b * 255)
									end)
								end
							end)
							local v23 = textButton
							local v24 = text2
							connections[#connections + 1] = textButton.MouseButton1Click:Connect(function()
								local selectedColor = colorPalette:WaitForChild("SelectedColor")
								local selectedColorText = colorPalette:WaitForChild("SelectedColorText")
								local selectedBrickColorText = colorPalette:WaitForChild("SelectedBrickColorText")
								local colorPaletteCrosshairs = colorPalette:WaitForChild("Palette"):WaitForChild("ColorPaletteCrosshairs")
								local darknessPointer = colorPalette:WaitForChild("DarknessAppearance"):WaitForChild("DarknessPointer")
								local uIGradient = colorPalette:WaitForChild("DarknessAppearance"):WaitForChild("UIGradient")
								selectedColor.BackgroundColor3 = v23.BackgroundColor3
								selectedColor.Text = "Color"
								selectedColorText.Text = "r,g,b:  " .. box.Text
								selectedBrickColorText.Text = tostring(BrickColor.new(v23.BackgroundColor3))
								local HSV, v25, v26 = v23.BackgroundColor3:ToHSV()
								colorPaletteCrosshairs.Position = UDim2.new(
									0,
									220 - HSV * 220 - 14,
									0,
									200 - v25 * 200 - 14
								)
								darknessPointer.Position = UDim2.new(0, 14, 0, 200 - v26 * 200 - 6)
								uIGradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(HSV, v25, 1))
								colorPalette.Visible = true
								local okButton = colorPalette:WaitForChild("OkButton")
								local cancelButton = colorPalette:WaitForChild("CancelButton")
								local v27 = #connections + 1
								local v28 = #connections + 1
								connections[#connections + 1] = cancelButton.MouseButton1Click:Connect(function()
									colorPalette.Visible = false
									connections[v27]:disconnect()
									connections[v28]:disconnect()
								end)
								v28 = #connections + 1
								connections[#connections + 1] = okButton.MouseButton1Click:Connect(function()
									v23.BackgroundColor3 = selectedColor.BackgroundColor3
									box.Text = selectedColorText.Text:sub(8)
									guiBase[v24] = selectedColor.BackgroundColor3
									local v29 = ""

									if v24 == "Color" then
										v29 = "BrickColor"
									elseif v24:sub(-1) == "3" then
										v29 = v24:sub(1, -2)
									end

									for i, child in ipairs(parent.List:GetChildren()) do
										if child:WaitForChild("name"):WaitForChild("unlocked").Text ~= v29 then
											continue
										end

										local box_2 = child:WaitForChild("edit"):WaitForChild("box")
										box_2.Text = selectedBrickColorText.Text
										break
									end

									CheckMultiSelect(guiBase, v24)
									CheckScreenGuiUpdate(guiBase)
									colorPalette.Visible = false
									connections[v27]:disconnect()
									connections[v28]:disconnect()
								end)
							end)
						end

						pcall(function()
							box.Text = math.floor(sL_Anchored.r * 255) .. ", " .. math.floor(sL_Anchored.g * 255) .. ", " .. math.floor(sL_Anchored.b * 255)
						end)
					elseif pcall(function()
						local _ = sL_Anchored.Top
						local _ = sL_Anchored.Bottom
						local _ = sL_Anchored.Left
						local _ = sL_Anchored.Right
						local _ = sL_Anchored.Front
						local _ = sL_Anchored.Back
					end) then
						local box = clone.edit.box

						if v20 then
							box = clone.edit.locked
						end

						box.Visible = true

						if not v20 then
							local v21 = text2
							connections[#connections + 1] = box.FocusLost:Connect(function()
								if not pcall(function()
									text = box.Text
									text = text:gsub("%s", "")
									local v22 = {}

									for i, v23 in ipairs(text:split()) do
										table.insert(v22, Enum.NormalId[v23])
									end

									guiBase[v21] = Faces.new(table.unpack(v22))
									CheckMultiSelect(guiBase, v21)
									CheckScreenGuiUpdate(guiBase)
								end) then
									pcall(function()
										box.Text = text
									end)
								end
							end)
						end

						box.Text = tostring(sL_Anchored)
					elseif tostring(sL_Anchored):sub(1, 5) == "Enum." then
						local locked = clone.edit.locked
						locked.TextColor3 = Color3.fromRGB(25, 25, 25)
						locked.Visible = true

						if not v20 then
							local imageLabel = Instance.new("ImageLabel")
							imageLabel.Image = IMAGE_ID
							imageLabel.ZIndex = 9
							imageLabel.Parent = clone.edit
							imageLabel.Position = UDim2.new(1, -23, 1, -8)
							imageLabel.Size = UDim2.new(0, 16, 0, 12)
							imageLabel.ImageColor3 = Color3.fromRGB(117, 117, 117)
							imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							imageLabel.BorderSizePixel = 0
							imageLabel.BackgroundTransparency = 1
							local v21 = clone
							local v22 = text2
							local v23 = locked
							connections[#connections + 1] = locked.MouseButton1Click:Connect(function()
								if v21.Parent:FindFirstChild("DropDownScrollingFrame") then
									v21.Parent:FindFirstChild("DropDownScrollingFrame"):Destroy()
									return
								end

								local scrollingFrame = Instance.new("ScrollingFrame")
								scrollingFrame.Name = "DropDownScrollingFrame"
								scrollingFrame.Size = UDim2.new(0, 130, 0, 140)
								scrollingFrame.Position = UDim2.new(0, 30, 0, v21.Position.Y.Offset + 24)
								scrollingFrame.Active = true
								scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
								scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
								scrollingFrame.ScrollBarThickness = 10
								scrollingFrame.Parent = v21.Parent
								local clone2 = v21.P:Clone()
								clone2.Value += 24
								clone2.Parent = scrollingFrame
								local uIListLayout = Instance.new("UIListLayout")
								uIListLayout.SortOrder = Enum.SortOrder.Name
								uIListLayout.Parent = scrollingFrame
								local v24 = tostring(sL_Anchored):split(".")[2]
								local enumItems = Enum[v24]:GetEnumItems()
								scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #enumItems * 24)
								local v25 = #connections + 1

								for i, enumItem in ipairs(enumItems) do
									local textButton = Instance.new("TextButton")
									textButton.Size = v21.Size
									textButton.TextScaled = true
									textButton.TextXAlignment = Enum.TextXAlignment.Left
									textButton.ZIndex = 9
									textButton.Name = tostring(enumItem):split(".")[3]
									textButton.Text = textButton.Name
									textButton.Parent = scrollingFrame
									local uIPadding = Instance.new("UIPadding")
									uIPadding.PaddingLeft = UDim.new(0, 3)
									uIPadding.PaddingRight = UDim.new(0, 10)
									uIPadding.PaddingBottom = UDim.new(0, 3)
									uIPadding.PaddingTop = UDim.new(0, 3)
									uIPadding.Parent = textButton
									local v26 = enumItem
									connections[#connections + 1] = textButton.MouseButton1Click:Connect(function()
										guiBase[v22] = v26
										v23.Text = tostring(v26):split(".")[3]
										CheckMultiSelect(guiBase, v22)
										CheckScreenGuiUpdate(guiBase)

										for i2 = v25, #connections do
											connections[i2]:disconnect()
										end

										scrollingFrame:Destroy()
									end)
								end
							end)
						end

						pcall(function()
							locked.Text = tostring(sL_Anchored):split(".")[3]
						end)
					elseif pcall(function()
						sL_Anchored:IsA("")
					end) then
						local locked = clone.edit.locked
						locked.Visible = true
						pcall(function()
							locked.Text = sL_Anchored.Name
						end)
					elseif text2 ~= "SeatPart" and text2 ~= "Parent" and text2 ~= "Occupant" then
						print("SL_Unknown property:", text2, sL_Anchored)
					end
				elseif type(sL_Anchored) == "string" then
					if text2 == "MaterialVariant" then
						local locked = clone.edit.locked
						locked.TextColor3 = Color3.fromRGB(25, 25, 25)
						locked.Visible = true
						local imageLabel = Instance.new("ImageLabel")
						imageLabel.Image = IMAGE_ID
						imageLabel.ZIndex = 9
						imageLabel.Parent = clone.edit
						imageLabel.Position = UDim2.new(1, -23, 1, -8)
						imageLabel.Size = UDim2.new(0, 16, 0, 12)
						imageLabel.ImageColor3 = Color3.fromRGB(117, 117, 117)
						imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						imageLabel.BorderSizePixel = 0
						imageLabel.BackgroundTransparency = 1
						connections[#connections + 1] = locked.MouseButton1Click:Connect(function()
							materialVariantFrame.Visible = true
						end)
						locked.Text = tostring(sL_Anchored)
					else
						local box = clone.edit.box

						if v20 then
							box = clone.edit.locked
						end

						box.Visible = true

						if not v20 then
							local v21 = text2
							connections[#connections + 1] = box.FocusLost:Connect(function()
								if v21:sub(1, 7) == "Texture" or v21:sub(-9) == "TextureId" or v21 == "Image" or v21:sub(
									1,
									6
								) == "Skybox" then
									local match = box.Text:match("^%d+")

									if match then
										box.Text = "rbxthumb://type=Asset&id=" .. match .. "&w=420&h=420"
									else
										print("Tip: If you paste the image/decal/texture number by itself, Studio Lite will convert to a rbxthumb so it will be accessible even if it's not in your inventory.")
									end
								elseif v21 == "SoundId" then
									local match = box.Text:match("%d+")

									if match then
										sL_Anchored = "rbxassetid://" .. tostring(match)
										box.Text = sL_Anchored
									end
								elseif v21 == "MeshId" then
									if guiBase.ClassName == "MeshPart" then
										if text ~= box.Text then
											warn("Can't change MeshId. But you can use the Toolbox to insert any MeshPart from create.roblox.com/store")
										end
									else
										local v22 = guiBase.ClassName == "SpecialMesh" and box.Text:match("%d+")

										if v22 then
											local v23, v24, textureId = getMeshInfoServerFunction:InvokeServer(v22)

											if v24 then
												box.Text = v24
												guiBase.MeshId = v24
												guiBase.TextureId = textureId
												guiBase.MeshType = Enum.MeshType.FileMesh
											else
												box.Text = "rbxassetid://" .. tostring(v22)
											end
										end
									end
								end

								if not pcall(function()
									text = box.Text
									guiBase[v21] = box.Text
									CheckMultiSelect(guiBase, v21)
									CheckScreenGuiUpdate(guiBase)
								end) then
									pcall(function()
										box.Text = text
									end)
								end
							end)
						end

						box.Text = tostring(sL_Anchored)

						if box.Text:len() > 25 then
							box.TextScaled = false
							box.TextSize = 10
							box.TextTruncate = Enum.TextTruncate.None
							box.RichText = true
						end
					end
				elseif type(sL_Anchored) == "number" then
					local box = clone.edit.box

					if v20 then
						box = clone.edit.locked
					end

					box.Visible = true

					if not v20 then
						local v21 = text2
						connections[#connections + 1] = box.FocusLost:Connect(function()
							if not pcall(function()
								text = box.Text
								guiBase[v21] = math.floor(tonumber(box.Text) * 1000) / 1000
								CheckMultiSelect(guiBase, v21)
								CheckScreenGuiUpdate(guiBase)
							end) then
								pcall(function()
									box.Text = text
								end)
							end
						end)
					end

					box.Text = tostring(math.floor(sL_Anchored * 1000) / 1000)
				elseif type(sL_Anchored) == "boolean" then
					local check = clone.edit.check
					check.Visible = true

					if text2 == "Anchored" then
						sL_Anchored = guiBase:GetAttribute("SL_Anchored")
					elseif text2 == "CanCollide" then
						sL_Anchored = guiBase:GetAttribute("SL_CanCollide")
					elseif guiBase.ClassName == "LocalScript" and not guiBase:FindFirstChild("SL_CodeTextBox") and (text2 == "Enabled" or text2 == "Disabled") then
						sL_Anchored = true
						v20 = true
					end

					if sL_Anchored then
						check.Image = "http://www.roblox.com/asset/?id=48138491"
					else
						check.Image = "http://www.roblox.com/asset/?id=48138474"
					end

					if not v20 then
						local text3 = text2
						local check2 = check
						connections[#connections + 1] = check.MouseButton1Click:Connect(function()
							if text3 == "Anchored" then
								guiBase:SetAttribute("SL_Anchored", not guiBase:GetAttribute("SL_Anchored"))
								sL_Anchored = guiBase:GetAttribute("SL_Anchored")
								guiBase.Anchored = true
							elseif text3 == "CanCollide" then
								guiBase:SetAttribute("SL_CanCollide", not guiBase:GetAttribute("SL_CanCollide"))
								sL_Anchored = guiBase:GetAttribute("SL_CanCollide")
							else
								guiBase[text3] = not guiBase[text3]
								sL_Anchored = guiBase[text3]
							end

							if sL_Anchored then
								check2.Image = "http://www.roblox.com/asset/?id=48138491"
							else
								check2.Image = "http://www.roblox.com/asset/?id=48138474"
							end

							if text3 == "IgnoreGuiInset" then
								if sL_Anchored then
									if guiBase.ScreenInsets == Enum.ScreenInsets.CoreUISafeInsets then
										guiBase.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
									end
								else
									guiBase.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
								end
							end

							CheckMultiSelect(guiBase, text3)
							CheckScreenGuiUpdate(guiBase)
						end)
					end
				else
					print("MISSED:", text2, sL_Anchored)
				end
			end

			if guiBase.ClassName == "Lighting" then
				local clone = script.Parent.property:Clone()
				clone.Parent = parent.List

				if v15 then
					clone.BackgroundColor3 = color
				else
					clone.BackgroundColor3 = color2
				end

				clone.Position = UDim2.new(0, 0, 0, (#parent.List:GetChildren() - 1) * 24 + 1)
				local numberValue = Instance.new("NumberValue", clone)
				numberValue.Name = "P"
				numberValue.Value = clone.Position.Y.Offset
				clone.name.unlocked.Text = "Technology Pub Only"
				clone.name.unlocked.Visible = true
				clone.Visible = true
				local sL_Technology = guiBase:GetAttribute("SL_Technology") or "Enum.Technology.Future"
				local locked = clone.edit.locked
				locked.Text = tostring(sL_Technology):split(".")[3]
				locked.TextColor3 = Color3.fromRGB(25, 25, 25)
				locked.Visible = true
				local imageLabel = Instance.new("ImageLabel")
				imageLabel.Image = IMAGE_ID
				imageLabel.ZIndex = 9
				imageLabel.Parent = clone.edit
				imageLabel.Position = UDim2.new(1, -23, 1, -8)
				imageLabel.Size = UDim2.new(0, 16, 0, 12)
				imageLabel.ImageColor3 = Color3.fromRGB(117, 117, 117)
				imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				imageLabel.BorderSizePixel = 0
				imageLabel.BackgroundTransparency = 1
				connections[#connections + 1] = locked.MouseButton1Click:Connect(function()
					if clone.Parent:FindFirstChild("DropDownScrollingFrame") then
						clone.Parent:FindFirstChild("DropDownScrollingFrame"):Destroy()
						return
					end

					local scrollingFrame = Instance.new("ScrollingFrame")
					scrollingFrame.Name = "DropDownScrollingFrame"
					scrollingFrame.Size = UDim2.new(0, 130, 0, 140)
					scrollingFrame.Position = UDim2.new(0, 30, 0, clone.Position.Y.Offset + 24)
					scrollingFrame.Active = true
					scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
					scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
					scrollingFrame.ScrollBarThickness = 10
					scrollingFrame.Parent = clone.Parent
					local clone2 = clone.P:Clone()
					clone2.Value += 24
					clone2.Parent = scrollingFrame
					local uIListLayout = Instance.new("UIListLayout")
					uIListLayout.SortOrder = Enum.SortOrder.Name
					uIListLayout.Parent = scrollingFrame
					local v17 = tostring(sL_Technology):split(".")[2]
					local enumItems = Enum[v17]:GetEnumItems()
					scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #enumItems * 24)
					local v18 = #connections + 1

					for _, enumItem in ipairs(enumItems) do
						if tostring(enumItem) == "Enum.Technology.Legacy" or tostring(enumItem) == "Enum.Technology.Compatibility" or tostring(enumItem) == "Enum.Technology.Unified" then
							scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, (#enumItems - 1) * 24)
						else
							local textButton = Instance.new("TextButton")
							textButton.Size = clone.Size
							textButton.TextScaled = true
							textButton.TextXAlignment = Enum.TextXAlignment.Left
							textButton.ZIndex = 9
							textButton.Name = tostring(enumItem):split(".")[3]
							textButton.Text = textButton.Name
							textButton.Parent = scrollingFrame
							local uIPadding = Instance.new("UIPadding")
							uIPadding.PaddingLeft = UDim.new(0, 3)
							uIPadding.PaddingRight = UDim.new(0, 10)
							uIPadding.PaddingBottom = UDim.new(0, 3)
							uIPadding.PaddingTop = UDim.new(0, 3)
							uIPadding.Parent = textButton
							local v19 = enumItem
							connections[#connections + 1] = textButton.MouseButton1Click:Connect(function()
								guiBase:SetAttribute("SL_Technology", v19)
								locked.Text = tostring(v19):split(".")[3]

								for i = v18, #connections do
									connections[i]:disconnect()
								end

								scrollingFrame:Destroy()
							end)
						end
					end
				end)
			end
		end
	end
end)