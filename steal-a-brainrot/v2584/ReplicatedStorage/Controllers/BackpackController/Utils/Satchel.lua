local ContextActionService = game:GetService("ContextActionService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local VRService = game:GetService("VRService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("InventoryService/Sort")
local ServerAuthority = require(ReplicatedStorage.Shared.ServerAuthority)
local remoteEvent2 = Net:RemoteEvent("Tools/Equip")
local v = false
local Satchel = {
	OpenClose = nil,
	IsOpen = false,
	StateChanged = Instance.new("BindableEvent"),
	ModuleName = "Backpack",
	KeepVRTopbarOpen = true,
	VRIsExclusive = true,
	VRClosesNonExclusive = true,
	BackpackEmpty = Instance.new("BindableEvent")
}
Satchel.BackpackEmpty.Name = "BackpackEmpty"
Satchel.BackpackItemAdded = Instance.new("BindableEvent")
Satchel.BackpackItemAdded.Name = "BackpackAdded"
Satchel.BackpackItemRemoved = Instance.new("BindableEvent")
Satchel.BackpackItemRemoved.Name = "BackpackRemoved"
local script2 = script
local preferredTransparency = GuiService.PreferredTransparency or 1
local v2 = not script2:GetAttribute("OutlineEquipBorder") or false
local insetIconPadding = script2:GetAttribute("InsetIconPadding")
local backgroundTransparency = script2:GetAttribute("BackgroundTransparency") or 0.3
local backgroundTransparency3 = backgroundTransparency * preferredTransparency
local cornerRadius = script2:GetAttribute("CornerRadius") or UDim.new(0, 8)
local backgroundColor3 = script2:GetAttribute("BackgroundColor3") or Color3.new(
	0.09803921568627451,
	0.10588235294117647,
	0.11372549019607843
)
local equipBorderColor3 = script2:GetAttribute("EquipBorderColor3") or Color3.new(0, 0.6352941176470588, 1)
local backgroundTransparency2 = script2:GetAttribute("BackgroundTransparency") or 0.3
local backgroundTransparency4 = backgroundTransparency2 * preferredTransparency
local equipBorderSizePixel = script2:GetAttribute("EquipBorderSizePixel") or 2.5
local cornerRadius2 = script2:GetAttribute("CornerRadius") or UDim.new(0, 8)
local color = Color3.new(1, 1, 1)
local cornerRadius3 = cornerRadius2 - UDim.new(0, 5) or UDim.new(0, 3)
local backgroundColor32 = script2:GetAttribute("BackgroundColor3") or Color3.new(
	0.09803921568627451,
	0.10588235294117647,
	0.11372549019607843
)
local textColor3 = script2:GetAttribute("TextColor3") or Color3.new(1, 1, 1)
local textStrokeTransparency = script2:GetAttribute("TextStrokeTransparency") or 0.5
local textStrokeColor3 = script2:GetAttribute("TextStrokeColor3") or Color3.new(0, 0, 0)
local color2 = Color3.new(0.09803921568627451, 0.10588235294117647, 0.11372549019607843)
local backgroundTransparency5 = preferredTransparency * 0.2
local color3 = Color3.new(1, 1, 1)
local cornerRadius4 = cornerRadius2 - UDim.new(0, 5) or UDim.new(0, 3)
local fontFace = script2:GetAttribute("FontFace") or Font.new("rbxasset://fonts/families/BuilderSans.json")
local textSize = script2:GetAttribute("TextSize") or 16
local value = Enum.KeyCode.Backspace.Value
local value2 = Enum.KeyCode.Zero.Value
local v8 = {
	[Enum.UserInputType.MouseButton1] = true,
	[Enum.UserInputType.MouseButton2] = true,
	[Enum.UserInputType.MouseButton3] = true,
	[Enum.UserInputType.MouseMovement] = true,
	[Enum.UserInputType.MouseWheel] = true
}
local v9 = {
	[Enum.UserInputType.Gamepad1] = true,
	[Enum.UserInputType.Gamepad2] = true,
	[Enum.UserInputType.Gamepad3] = true,
	[Enum.UserInputType.Gamepad4] = true,
	[Enum.UserInputType.Gamepad5] = true,
	[Enum.UserInputType.Gamepad6] = true,
	[Enum.UserInputType.Gamepad7] = true,
	[Enum.UserInputType.Gamepad8] = true
}
local v10 = true
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local v11 = TopbarPlus.new():setName("Inventory"):setImage("rbxasset://textures/ui/TopBar/inventoryOn.png", "Selected"):setImage(
	"rbxasset://textures/ui/TopBar/inventoryOff.png",
	"Deselected"
):setImageScale(1):setCaption("Inventory"):bindToggleKey(Enum.KeyCode.Backquote):autoDeselect(false):setOrder(-1)
v11.toggled:Connect(function()
	if not GuiService.MenuIsOpen then
		Satchel.OpenClose()
	end
end)
local screenGui = Instance.new("ScreenGui")
screenGui.DisplayOrder = 120
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Name = "BackpackGui"
screenGui.Parent = playerGui
local isTenFootInterface = GuiService:IsTenFootInterface()
local v12

if isTenFootInterface then
	v12 = 100
	textSize = 24
else
	v12 = 60
end

local v13 = false
local v14 = UserInputService.TouchEnabled and workspace.CurrentCamera.ViewportSize.X < 1024
local localPlayer = Players.LocalPlayer
local frame = nil
local frame2 = nil
local frame3 = nil
local textButton = nil
local scrollingFrame = nil
local frame4 = nil
local fn
local character = localPlayer.Character and localPlayer.Character.Parent == workspace and localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local backpack = localPlayer:WaitForChild("Backpack")
local v15 = {}
local v16 = nil
local v17 = {}
local v18 = {}
local v19 = {}
local v20 = 0
local v21 = nil
local v22 = false
local v23 = false
local v24 = false
local flag = false
local connections = {}
local flag2 = false
local vREnabled = VRService.VREnabled
local v25 = vREnabled and 6 or v14 and 6 or 10
local v26 = vREnabled and 3 or v14 and 2 or 4
local v27 = nil

local function EvaluateBackpackPanelVisibility(flag3: boolean)
	return flag3 and v11.enabled and v10 and VRService.VREnabled
end

local function ShowVRBackpackPopup() end

local function FindLowestEmpty()
	for i = 1, v25 do
		local v28 = v15[i]

		if not v28.Tool then
			return v28
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isInventoryEmpty()
	for i = v25 + 1, #v15 do
		local v28 = v15[i]

		if v28 and v28.Tool then
			return false
		end
	end

	return true
end

Satchel.IsInventoryEmpty = isInventoryEmpty

local function UseGazeSelection()
	return false
end

local function AdjustHotbarFrames()
	local visible = frame3.Visible
	local v28 = visible and v25 or v20
	local count = 0

	for i = 1, v25 do
		local v29 = v15[i]

		if v29.Tool or visible then
			count += 1
			v29:Readjust(count, v28)
			v29.Frame.Visible = true
		else
			v29.Frame.Visible = false
		end
	end
end

local function UpdateScrollingFrameCanvasSize()
	local v28 = math.floor(scrollingFrame.AbsoluteSize.X / (v12 + 5))
	local v29 = math.ceil((#frame4:GetChildren() - 1) / v28) * (v12 + 5) + 5
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, v29)
end

local function AdjustInventoryFrames()
	for i = v25 + 1, #v15 do
		local v28 = v15[i]
		v28.Frame.LayoutOrder = v28.Index
		v28.Frame.Visible = v28.Tool ~= nil
	end

	UpdateScrollingFrameCanvasSize()
end

local function UpdateBackpackLayout()
	frame2.Size = UDim2.new(0, v25 * (v12 + 5) + 5, 0, v12 + 5 + 5)
	frame2.Position = UDim2.new(0.5, -frame2.Size.X.Offset / 2, 1, -frame2.Size.Y.Offset)
	frame3.Size = UDim2.new(0, frame2.Size.X.Offset, 0, frame2.Size.Y.Offset * v26 + 40 + (vREnabled and 80 or 0))
	frame3.Position = UDim2.new(0.5, -frame3.Size.X.Offset / 2, 1, frame2.Position.Y.Offset - frame3.Size.Y.Offset)
	scrollingFrame.Size = UDim2.new(1, scrollingFrame.ScrollBarThickness + 1, 1, -40 - (vREnabled and 80 or 0))
	scrollingFrame.Position = UDim2.new(0, 0, 0, 40 + (vREnabled and 40 or 0))
	AdjustHotbarFrames()
	AdjustInventoryFrames()
end

local function Clamp(p: number, p2: number, p3: number)
	return (math.min(p2, (math.max(p, p3))))
end

local function CheckBounds(p, p2: number, p3: number)
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	return absolutePosition.X < p2 and p2 <= absolutePosition.X + absoluteSize.X and absolutePosition.Y < p3 and p3 <= absolutePosition.Y + absoluteSize.Y
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetOffset(frame5, vector: Vector2)
	return (frame5.AbsolutePosition + frame5.AbsoluteSize / 2 - vector).Magnitude
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DisableActiveHopper()
	v21:ToggleSelect()
	v17[v21]:UpdateEquipView()
	v21 = nil
end

local function UnequipAllTools()
	if ServerAuthority.isEnabled() then
		remoteEvent2:FireServer(nil)

		if humanoid then
			humanoid:UnequipTools()
		end

		if v21 then
			DisableActiveHopper() -- equivalent call inferred; original call site unknown
		end
	elseif humanoid then
		humanoid:UnequipTools()

		if v21 then
			DisableActiveHopper() -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function EquipNewTool(tool)
	UnequipAllTools()

	if not ServerAuthority.isEnabled() then
		humanoid:EquipTool(tool)
		return
	end

	remoteEvent2:FireServer(tool)
	tool.Parent = character
end

local function IsEquipped(p)
	return p and p.Parent == character
end

local MakeSlot

MakeSlot = function(frame5, p: number?)
	local v28 = p or #v15 + 1
	local v29 = {
		Tool = nil,
		Index = v28,
		Frame = nil
	}
	local textButton2 = nil
	local frame6 = nil
	local imageLabel = nil
	local textLabel = nil
	local changedConnection = nil
	local uIStroke = nil
	local textLabel2 = nil
	local textLabel3 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateSlotFading()
		textButton2.SelectionImageObject = nil
		textButton2.BackgroundTransparency = textButton2.Draggable and 0 or backgroundTransparency4
	end

	function v29:Readjust(p2: number, p3: number)
		local halfOffset = frame2.Size.X.Offset / 2
		local v31 = v12 + 5
		local v32 = p2 - (p3 / 2 + 0.5)
		textButton2.Position = UDim2.new(0, halfOffset - v12 / 2 + v31 * v32, 0, 5)
	end

	function v29:Fill(tool)
		if not tool then
			return self:Clear()
		end

		self.Tool = tool

		if not v then
			remoteEvent:FireServer(tool.Name, self.Index)
		end

		local function assignToolData()
			local textureId = tool.TextureId
			imageLabel.Image = textureId

			if textureId == "" then
				textLabel.Visible = true
			else
				textLabel.Visible = false
			end

			textLabel.Text = tool.Name

			if tool:GetAttribute("CurrentSlot") then
				local currentSlot = tool:GetAttribute("CurrentSlot")
				local child = frame2:FindFirstChild(currentSlot)

				if child then
					local icon = child:FindFirstChild("Icon")
					local cooldownTextLabel = icon and icon:FindFirstChild("CooldownTextLabel")

					if cooldownTextLabel then
						cooldownTextLabel.Text = ""
						cooldownTextLabel.Visible = false
					end
				end
			end

			tool:SetAttribute("CurrentSlot", textButton2.Name)

			if textLabel2 and tool:IsA("Tool") then
				textLabel2.Text = tool.ToolTip
				textLabel2.Size = UDim2.new(0, 0, 0, 16)
				textLabel2.Position = UDim2.new(0.5, 0, 0, -5)
			end
		end

		assignToolData()

		if changedConnection then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		changedConnection = tool.Changed:Connect(function(p2: string)
			if p2 == "TextureId" or p2 == "Name" or p2 == "ToolTip" then
				assignToolData()
			end
		end)
		local v30 = self.Index <= v25
		local visible = frame3.Visible

		if (not v30 or visible) and not UserInputService.VREnabled then
			textButton2.Draggable = true
		end

		self:UpdateEquipView()

		if v30 then
			v20 += 1

			if v23 and v20 >= 1 and not v13 then
				v13 = true
				ContextActionService:BindAction(
					"BackpackHotbarEquip",
					fn,
					false,
					Enum.KeyCode.ButtonL1,
					Enum.KeyCode.ButtonR1
				)
			end
		end

		v17[tool] = self
		local flag3 = true
		local v31

		for i = 1, v25 do
			v31 = v15[i]

			if v31.Tool then
				continue
			end

			flag3 = false
			break
		end

		if flag3 then
			v31 = nil
		end

		v16 = v31
	end

	function v29:Clear()
		if not self.Tool then
			return
		end

		if changedConnection then
			changedConnection:Disconnect()
			changedConnection = nil
		end

		imageLabel.Image = ""
		textLabel.Text = ""

		if textLabel2 then
			textLabel2.Text = ""
			textLabel2.Visible = false
		end

		textButton2.Draggable = false
		self:UpdateEquipView(true)

		if self.Index <= v25 then
			v20 -= 1

			if v20 < 1 then
				v13 = false
				ContextActionService:UnbindAction("BackpackHotbarEquip")
			end
		end

		v17[self.Tool] = nil
		self.Tool = nil
		local flag3 = true
		local v30

		for i = 1, v25 do
			v30 = v15[i]

			if v30.Tool then
				continue
			end

			flag3 = false
			break
		end

		if flag3 then
			v30 = nil
		end

		v16 = v30
	end

	function v29:UpdateEquipView(flag3: boolean?)
		if flag3 then
			if uIStroke then
				uIStroke.Parent = nil
			end
		else
			local tool = self.Tool

			if tool and tool.Parent == character then
				v27 = v29

				if not uIStroke then
					uIStroke = Instance.new("UIStroke")
					uIStroke.Name = "Border"
					uIStroke.Thickness = equipBorderSizePixel
					uIStroke.Color = equipBorderColor3
					uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				end

				if v2 == true then
					uIStroke.Parent = imageLabel
				else
					uIStroke.Parent = textButton2
				end
			elseif uIStroke then
				uIStroke.Parent = nil
			end
		end

		UpdateSlotFading() -- equivalent call inferred; original call site unknown
	end

	function v29:IsEquipped()
		local tool = self.Tool
		return tool and tool.Parent == character
	end

	function v29:Delete()
		textButton2:Destroy()
		table.remove(v15, self.Index)
		local v30 = #v15

		for i = self.Index, v30 do
			v15[i]:SlideBack()
		end

		UpdateScrollingFrameCanvasSize()
	end

	function v29:Swap(object2)
		local tool = self.Tool
		local tool2 = object2.Tool

		if tool2 then
			remoteEvent:FireServer(tool2.Name, self.Index)
		end

		if tool then
			remoteEvent:FireServer(tool.Name, object2.Index)
		end

		self:Clear()

		if tool2 then
			object2:Clear()
			self:Fill(tool2)
		end

		if tool then
			object2:Fill(tool)
		else
			object2:Clear()
		end
	end

	function v29:SlideBack()
		self.Index -= 1
		textButton2.Name = self.Index
		textButton2.LayoutOrder = self.Index
	end

	function v29:TurnNumber(visible: boolean)
		if textLabel3 then
			textLabel3.Visible = visible
		end
	end

	function v29:SetClickability(flag3: boolean)
		if self.Tool then
			if UserInputService.VREnabled then
				textButton2.Draggable = false
			else
				textButton2.Draggable = not flag3
			end

			UpdateSlotFading() -- equivalent call inferred; original call site unknown
		end
	end

	function v29:CheckTerms(items)
		local total = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function checkEm(text: string, k)
			local _, v30 = text:lower():gsub(k, "")
			total += v30
		end

		local tool = self.Tool

		if not tool then
			return total
		end

		for k in pairs(items) do
			checkEm(textLabel.Text, k) -- equivalent call inferred; original call site unknown

			if not tool:IsA("Tool") then
				continue
			end

			checkEm(textLabel2 and textLabel2.Text or "", k) -- equivalent call inferred; original call site unknown
		end

		return total
	end

	function v29:Select()
		local tool = v29.Tool

		if tool then
			if tool and tool.Parent == character then
				UnequipAllTools()
			elseif tool.Parent == backpack then
				EquipNewTool(tool) -- equivalent call inferred; original call site unknown
			end
		end
	end

	textButton2 = Instance.new("TextButton")
	textButton2.Name = tostring(v28)
	textButton2.BackgroundColor3 = backgroundColor3
	textButton2.BorderColor3 = color
	textButton2.Text = ""
	textButton2.BorderSizePixel = 0
	textButton2.Size = UDim2.new(0, v12, 0, v12)
	textButton2.Active = true
	textButton2.Draggable = false
	textButton2.BackgroundTransparency = backgroundTransparency4
	textButton2.MouseButton1Click:Connect(function()
		changeSlot(v29)
	end)
	local uICorner = Instance.new("UICorner")
	uICorner.Name = "Corner"
	uICorner.CornerRadius = cornerRadius2
	uICorner.Parent = textButton2
	v29.Frame = textButton2
	local frame7 = Instance.new("Frame")
	frame7.Name = "SelectionObjectClipper"
	frame7.BackgroundTransparency = 1
	frame7.Visible = false
	frame7.Parent = textButton2
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Name = "Selector"
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Size = UDim2.new(1, 0, 1, 0)
	imageLabel2.Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png"
	imageLabel2.ScaleType = Enum.ScaleType.Slice
	imageLabel2.SliceCenter = Rect.new(12, 12, 52, 52)
	imageLabel2.Parent = frame7
	local textLabel4 = Instance.new("TextLabel")
	textLabel4.BackgroundTransparency = 1
	textLabel4.TextScaled = true
	textLabel4.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel4.FontFace = Font.new(
		"rbxasset://fonts/families/RobotoMono.json",
		Enum.FontWeight.Bold,
		Enum.FontStyle.Normal
	)
	textLabel4.Name = "CooldownTextLabel"
	textLabel4.Text = "1"
	textLabel4.Size = UDim2.new(0.65, 0, 0.65, 0)
	textLabel4.Position = UDim2.new(0.5, 0, 0.5, 0)
	textLabel4.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel4.Visible = false
	local uIStroke2 = Instance.new("UIStroke")
	uIStroke2.Thickness = 1.5
	uIStroke2.Color = Color3.fromRGB(0, 0, 0)
	uIStroke2.Transparency = 0.35
	uIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	uIStroke2.Parent = textLabel4
	imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.Name = "Icon"
	imageLabel.Size = UDim2.new(1, 0, 1, 0)
	imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)

	if insetIconPadding == true then
		imageLabel.Size = UDim2.new(1, -equipBorderSizePixel * 2, 1, -equipBorderSizePixel * 2)
	else
		imageLabel.Size = UDim2.new(1, 0, 1, 0)
	end

	imageLabel.Parent = textButton2
	textLabel4.Parent = imageLabel
	local uICorner2 = Instance.new("UICorner")
	uICorner2.Name = "Corner"

	if insetIconPadding == true then
		uICorner2.CornerRadius = cornerRadius2 - UDim.new(0, equipBorderSizePixel)
	else
		uICorner2.CornerRadius = cornerRadius2
	end

	uICorner2.Parent = imageLabel
	textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Name = "ToolName"
	textLabel.Text = ""
	textLabel.TextColor3 = textColor3
	textLabel.TextStrokeTransparency = textStrokeTransparency
	textLabel.TextStrokeColor3 = textStrokeColor3
	textLabel.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	textLabel.TextSize = textSize
	textLabel.Size = UDim2.new(1, -equipBorderSizePixel * 2, 1, -equipBorderSizePixel * 2)
	textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.Parent = textButton2
	v29.Frame.LayoutOrder = v29.Index

	if v28 <= v25 then
		textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "ToolTip"
		textLabel2.Text = ""
		textLabel2.Size = UDim2.new(1, 0, 1, 0)
		textLabel2.TextColor3 = textColor3
		textLabel2.TextStrokeTransparency = textStrokeTransparency
		textLabel2.TextStrokeColor3 = textStrokeColor3
		textLabel2.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		textLabel2.TextSize = textSize
		textLabel2.ZIndex = 2
		textLabel2.TextWrapped = false
		textLabel2.TextYAlignment = Enum.TextYAlignment.Center
		textLabel2.BackgroundColor3 = backgroundColor32
		textLabel2.BackgroundTransparency = backgroundTransparency4
		textLabel2.AnchorPoint = Vector2.new(0.5, 1)
		textLabel2.BorderSizePixel = 0
		textLabel2.Visible = false
		textLabel2.AutomaticSize = Enum.AutomaticSize.X
		textLabel2.Parent = textButton2
		local uICorner3 = Instance.new("UICorner")
		uICorner3.Name = "Corner"
		uICorner3.CornerRadius = cornerRadius3
		uICorner3.Parent = textLabel2
		local uIPadding = Instance.new("UIPadding")
		uIPadding.PaddingLeft = UDim.new(0, 4)
		uIPadding.PaddingRight = UDim.new(0, 4)
		uIPadding.PaddingTop = UDim.new(0, 4)
		uIPadding.PaddingBottom = UDim.new(0, 4)
		uIPadding.Parent = textLabel2
		textButton2.MouseEnter:Connect(function()
			if textLabel2.Text ~= "" then
				textLabel2.Visible = true
			end
		end)
		textButton2.MouseLeave:Connect(function()
			textLabel2.Visible = false
		end)

		function v29:MoveToInventory()
			if v29.Index <= v25 then
				local tool = v29.Tool
				self:Clear()
				local slot = MakeSlot(frame4)
				slot:Fill(tool)

				if tool then
					remoteEvent:FireServer(tool.Name, slot.Index)
				end

				if tool and tool.Parent == character then
					UnequipAllTools()
				end

				if flag then
					slot.Frame.Visible = false
					slot.Parent = frame3
				end
			end
		end

		if v28 < 10 or v28 == v25 then
			local v30 = v28 < 10 and (v28 or 0) or 0
			textLabel3 = Instance.new("TextLabel")
			textLabel3.BackgroundTransparency = 1
			textLabel3.Name = "Number"
			textLabel3.TextColor3 = textColor3
			textLabel3.TextStrokeTransparency = textStrokeTransparency
			textLabel3.TextStrokeColor3 = textStrokeColor3
			textLabel3.TextSize = textSize
			textLabel3.Text = tostring(v30)
			textLabel3.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Heavy, Enum.FontStyle.Normal)
			textLabel3.Size = UDim2.new(0.4, 0, 0.4, 0)
			textLabel3.Visible = false
			textLabel3.Parent = textButton2
			v18[value2 + v30] = v29.Select
		end
	end

	local position = textButton2.Position
	local v30 = 0
	local parent = nil
	textButton2.DragBegin:Connect(function(udim: UDim2)
		v19[textButton2] = true
		position = udim
		textButton2.BorderSizePixel = 2
		v11:lock()
		textButton2.ZIndex = 2
		imageLabel.ZIndex = 2
		textLabel.ZIndex = 2
		textButton2.Parent.ZIndex = 2

		if textLabel3 then
			textLabel3.ZIndex = 2
		end

		parent = textButton2.Parent

		if parent == frame4 then
			local uDim = UDim2.new(
				0,
				textButton2.AbsolutePosition.X - frame3.AbsolutePosition.X,
				0,
				textButton2.AbsolutePosition.Y - frame3.AbsolutePosition.Y
			)
			textButton2.Parent = frame3
			textButton2.Position = uDim
			frame6 = Instance.new("Frame")
			frame6.Name = "FakeSlot"
			frame6.LayoutOrder = textButton2.LayoutOrder
			frame6.Size = textButton2.Size
			frame6.BackgroundTransparency = 1
			frame6.Parent = frame4
		end
	end)
	textButton2.DragStopped:Connect(function(p2: number, p3: number)
		if frame6 then
			frame6:Destroy()
		end

		local now = os.clock()
		textButton2.Position = position
		textButton2.Parent = parent
		textButton2.BorderSizePixel = 0
		v11:unlock()
		textButton2.ZIndex = 1
		imageLabel.ZIndex = 1
		textLabel.ZIndex = 1
		parent.ZIndex = 1

		if textLabel3 then
			textLabel3.ZIndex = 1
		end

		v19[textButton2] = nil

		if not v29.Tool then
			return
		end

		local v31 = frame3
		local absolutePosition = v31.AbsolutePosition
		local absoluteSize = v31.AbsoluteSize
		local v32

		if absolutePosition.X < p2 and p2 <= absolutePosition.X + absoluteSize.X and absolutePosition.Y < p3 then
			v32 = p3 <= absolutePosition.Y + absoluteSize.Y
		else
			v32 = false
		end

		if v32 then
			if v29.Index <= v25 then
				v29:MoveToInventory()
			end

			if v25 < v29.Index and now - v30 < 0.5 then
				if v16 then
					local tool = v29.Tool
					v29:Clear()
					v16:Fill(tool)
					v29:Delete()

					if tool then
						remoteEvent:FireServer(tool.Name, v16.Index)
					end
				end

				now = 0
			end
		else
			local v33 = frame2
			local absolutePosition2 = v33.AbsolutePosition
			local absoluteSize2 = v33.AbsoluteSize
			local v34

			if absolutePosition2.X < p2 and p2 <= absolutePosition2.X + absoluteSize2.X and absolutePosition2.Y < p3 then
				v34 = p3 <= absolutePosition2.Y + absoluteSize2.Y
			else
				v34 = false
			end

			if v34 then
				local v35 = { 1e999, nil }

				for i = 1, v25 do
					local v36 = v15[i]
					local offset = GetOffset(v36.Frame, Vector2.new(p2, p3)) -- equivalent call inferred; original call site unknown

					if offset < v35[1] then
						v35 = { offset, v36 }
					end
				end

				local v36 = v35[2]

				if v36 ~= v29 then
					v29:Swap(v36)

					if v25 < v29.Index then
						local tool = v29.Tool

						if tool then
							if tool and tool.Parent == character then
								UnequipAllTools()
							end

							if flag then
								v29.Frame.Visible = false
								v29.Frame.Parent = frame3
							end
						else
							v29:Delete()
						end
					end
				end
			elseif v29.Index <= v25 then
				v29:MoveToInventory()
			end
		end

		v30 = now
	end)
	textButton2.Parent = frame5
	v15[v28] = v29

	if v25 < v28 then
		UpdateScrollingFrameCanvasSize()

		if frame3.Visible and not flag then
			local v31 = scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteSize.Y
			scrollingFrame.CanvasPosition = Vector2.new(0, (math.max(0, v31)))
		end
	end

	return v29
end

local function OnChildAdded(child)
	if child:IsA("Tool") or child:IsA("HopperBin") then
		local _ = child.Parent == character

		if v21 and child.Parent == character then
			DisableActiveHopper() -- equivalent call inferred; original call site unknown
		end

		if not v22 and child.Parent == character and not v17[child] then
			local starterGear = localPlayer:FindFirstChild("StarterGear")

			if starterGear and starterGear:FindFirstChild(child.Name) then
				v22 = true

				for i = (v16 or MakeSlot(frame4)).Index, 1, -1 do
					local v28 = v15[i]
					local v29 = i - 1

					if v29 > 0 then
						v15[v29]:Swap(v28)
					else
						v28:Fill(child)
					end
				end

				for _, tool in pairs(character:GetChildren()) do
					if tool:IsA("Tool") and tool ~= child then
						tool.Parent = backpack
					end
				end

				AdjustHotbarFrames()
				return
			end
		end

		local v28 = v17[child]

		if v28 then
			v28:UpdateEquipView()
		else
			local v29 = v16 or MakeSlot(frame4)
			v29:Fill(child)

			if v29.Index <= v25 and not frame3.Visible then
				AdjustHotbarFrames()
			end

			if child:IsA("HopperBin") and child.Active then
				UnequipAllTools()
				v21 = child
			end
		end

		Satchel.BackpackItemAdded:Fire()
	elseif child:IsA("Humanoid") and child.Parent == character then
		humanoid = child
	end
end

local function OnChildRemoved(instance)
	if not (instance:IsA("Tool") or instance:IsA("HopperBin")) then
		return
	end

	local parent = instance.Parent

	if parent == character or parent == backpack then
		return
	end

	local v28 = v17[instance]

	if v28 then
		v28:Clear()

		if v25 < v28.Index then
			v28:Delete()
		elseif not frame3.Visible then
			AdjustHotbarFrames()
		end
	end

	if instance == v21 then
		v21 = nil
	end

	Satchel.BackpackItemRemoved:Fire()

	-- equivalent call inferred; original call site unknown
	if isInventoryEmpty() then
		Satchel.BackpackEmpty:Fire()
	end
end

local function ReconcileBackpackSlots()
	local function createNewSlot()
		local slot = MakeSlot(frame4)

		if flag then
			slot.Frame.Visible = false
			slot.Parent = frame3
		end

		return slot
	end

	local flag3 = false

	local function ensureSlotted(instance)
		if not instance then
			return
		end

		for _, child in instance:GetChildren() do
			if not (child:IsA("Tool") or child:IsA("HopperBin")) or v17[child] then
				continue
			end

			local v28 = v16

			if not v28 then
				v28 = MakeSlot(frame4)

				if flag then
					v28.Frame.Visible = false
					v28.Parent = frame3
				end
			end

			if v28.Tool then
				v28 = MakeSlot(frame4)

				if flag then
					v28.Frame.Visible = false
					v28.Parent = frame3
				end
			end

			v28:Fill(child)
			flag3 = true
		end
	end

	ensureSlotted(backpack)
	ensureSlotted(character)

	if flag3 then
		AdjustHotbarFrames()
	end
end

local function OnCharacterAdded(instance)
	while not instance:GetAttribute("BackpackReady") and Players:GetPlayerFromCharacter(instance) and not workspace:GetAttribute("BackpackIgnoreSave") do
		task.wait()
	end

	for i = #v15, 1, -1 do
		local v28 = v15[i]

		if v28.Tool then
			v28:Clear()
		end

		if v25 < i then
			v28:Delete()
		end
	end

	v21 = nil

	for _, connection in pairs(connections) do
		connection:Disconnect()
	end

	connections = {}
	character = instance
	table.insert(connections, instance.ChildRemoved:Connect(OnChildRemoved))
	table.insert(connections, instance.ChildAdded:Connect(OnChildAdded))

	for _, child in pairs(instance:GetChildren()) do
		OnChildAdded(child)
	end

	backpack = localPlayer:WaitForChild("Backpack")
	table.insert(connections, backpack.ChildRemoved:Connect(OnChildRemoved))
	table.insert(connections, backpack.ChildAdded:Connect(OnChildAdded))
	local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
	local v28 = Synchronizer:Get(localPlayer)
	local inventoryLayoutOrder = v28 and v28:Get("InventoryLayoutOrder") or {}
	local backpackIgnoreSave = workspace:GetAttribute("BackpackIgnoreSave")
	local v29 = {}

	for k, v30 in inventoryLayoutOrder do
		v29[v30] = k

		if v30 == "Bat" and backpackIgnoreSave then
			v29.Bat = -1
		end
	end

	local v30 = {}

	for _, tool in pairs(backpack:GetChildren()) do
		if tool:IsA("Tool") then
			table.insert(v30, {
				index = v29[tool.Name] or 1e999,
				tool = tool
			})
		end
	end

	table.sort(v30, function(a, b)
		return a.index < b.index
	end)

	local function createNewSlot()
		local slot = MakeSlot(frame4)

		if flag then
			slot.Frame.Visible = false
			slot.Parent = frame3
		end

		return slot
	end

	v = true

	for k, v31 in v30 do
		if v17[v31.tool] then
			continue
		end

		local index = v31.index

		if backpackIgnoreSave then
			index = k
		end

		local v32

		if v31.tool:GetAttribute("TradePlazaSign") then
			v32 = v16

			if not v32 then
				v32 = MakeSlot(frame4)

				if flag then
					v32.Frame.Visible = false
					v32.Parent = frame3
				end
			end

			if v32.Tool then
				v32 = MakeSlot(frame4)

				if flag then
					v32.Frame.Visible = false
					v32.Parent = frame3
				end
			end
		else
			if index <= v25 then
				v32 = v15[index]
			else
				v32 = MakeSlot(frame4)

				if flag then
					v32.Frame.Visible = false
					v32.Parent = frame3
				end
			end

			if not v32 or v32.Tool then
				v32 = v16

				if not v32 then
					v32 = MakeSlot(frame4)

					if flag then
						v32.Frame.Visible = false
						v32.Parent = frame3
					end
				end

				if v32.Tool then
					v32 = MakeSlot(frame4)

					if flag then
						v32.Frame.Visible = false
						v32.Parent = frame3
					end
				end
			end
		end

		v32:Fill(v31.tool)
	end

	v = false
	AdjustHotbarFrames()
	ReconcileBackpackSlots()

	for _, duration in {
		0.25,
		0.5,
		1,
		2,
		4,
		8
	} do
		task.delay(duration, function()
			if localPlayer.Character ~= instance then
				return
			end

			ReconcileBackpackSlots()
		end)
	end
end

local function OnInputBegan(p, flag3: boolean)
	local chatInputBarConfiguration = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")
	local v28 = p.UserInputType == Enum.UserInputType.Keyboard and not v24 and not chatInputBarConfiguration.IsFocused and (v23 or p.KeyCode.Value == value) and v18[p.KeyCode.Value]

	if v28 then
		v28(flag3)
	end

	local userInputType = p.UserInputType

	if not flag3 and (userInputType == Enum.UserInputType.MouseButton1 or userInputType == Enum.UserInputType.Touch) and frame3.Visible then
		v11:deselect()
	end
end

local function OnUISChanged()
	if UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
		for i = 1, v25 do
			v15[i]:TurnNumber(false)
		end
	elseif UserInputService:GetLastInputType() == Enum.UserInputType.Keyboard then
		for i = 1, v25 do
			v15[i]:TurnNumber(true)
		end
	else
		for _, v28 in pairs(v8) do
			if UserInputService:GetLastInputType() ~= v28 then
				continue
			end

			for i = 1, v25 do
				v15[i]:TurnNumber(true)
			end

			return
		end

		for _, v28 in pairs(v9) do
			if UserInputService:GetLastInputType() ~= v28 then
				continue
			end

			for i = 1, v25 do
				v15[i]:TurnNumber(false)
			end

			return
		end
	end
end

local v28 = nil
local lastTime = nil

local function fn2() end

function unbindAllGamepadEquipActions()
	ContextActionService:UnbindAction("BackpackHasGamepadFocus")
	ContextActionService:UnbindAction("BackpackCloseInventory")
end

fn = function(_: string, p, p2)
	if p ~= Enum.UserInputState.Begin then
		return
	end

	if v28 and (v28.KeyCode == Enum.KeyCode.ButtonR1 and p2.KeyCode == Enum.KeyCode.ButtonL1 or v28.KeyCode == Enum.KeyCode.ButtonL1 and p2.KeyCode == Enum.KeyCode.ButtonR1) and os.clock() - lastTime <= 0.06 then
		UnequipAllTools()
		v28 = p2
		lastTime = os.clock()
	else
		v28 = p2
		lastTime = os.clock()
		task.delay(0.06, function()
			if v28 ~= p2 then
				return
			end

			local v29 = p2.KeyCode == Enum.KeyCode.ButtonL1 and -1 or 1

			for i = 1, v25 do
				if not v15[i]:IsEquipped() then
					continue
				end

				local v30 = v29 + i
				local v31 = false

				if v25 < v30 then
					v30 = 1
					v31 = true
				elseif v30 < 1 then
					v30 = v25
					v31 = true
				end

				local v32 = v30

				while not v15[v30].Tool do
					v30 += v29

					if v30 == v32 then
						return
					end

					if v25 < v30 then
						v30 = 1
						v31 = true
					elseif v30 < 1 then
						v30 = v25
						v31 = true
					end
				end

				if not v31 then
					v15[v30]:Select()
					return
				end

				UnequipAllTools()
				v27 = nil
				return
			end

			if v27 and v27.Tool then
				v27:Select()
				return
			end

			for i = v29 == -1 and (v25 or 1) or 1, v29 == -1 and 1 or v25, v29 do
				if not v15[i].Tool then
					continue
				end

				v15[i]:Select()
				break
			end
		end)
	end
end

function getGamepadSwapSlot()
	for i = 1, #v15 do
		if v15[i].Frame.BorderSizePixel > 0 then
			return v15[i]
		end
	end
end

function changeSlot(object)
	local v29 = not VRService.VREnabled or frame3.Visible

	if object.Frame == GuiService.SelectedObject and v29 then
		local gamepadSwapSlot = getGamepadSwapSlot()

		if gamepadSwapSlot then
			gamepadSwapSlot.Frame.BorderSizePixel = 0

			if gamepadSwapSlot ~= object then
				object:Swap(gamepadSwapSlot)
				textButton.SelectionImageObject.Visible = false

				if v25 < object.Index and not object.Tool then
					if GuiService.SelectedObject == object.Frame then
						GuiService.SelectedObject = gamepadSwapSlot.Frame
					end

					object:Delete()
				end

				if v25 < gamepadSwapSlot.Index and not gamepadSwapSlot.Tool then
					if GuiService.SelectedObject == gamepadSwapSlot.Frame then
						GuiService.SelectedObject = object.Frame
					end

					gamepadSwapSlot:Delete()
				end
			end
		else
			local size = object.Frame.Size
			local position = object.Frame.Position
			object.Frame:TweenSizeAndPosition(
				size + UDim2.new(0, 10, 0, 10),
				position - UDim2.new(0, 5, 0, 5),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true,
				function()
					object.Frame:TweenSizeAndPosition(
						size,
						position,
						Enum.EasingDirection.In,
						Enum.EasingStyle.Quad,
						0.1,
						true
					)
				end
			)
			object.Frame.BorderSizePixel = 3
			textButton.SelectionImageObject.Visible = true
		end
	else
		object:Select()
		textButton.SelectionImageObject.Visible = false
	end
end

function vrMoveSlotToInventory()
	if not VRService.VREnabled then
		return
	end

	local gamepadSwapSlot = getGamepadSwapSlot()

	if gamepadSwapSlot and gamepadSwapSlot.Tool then
		gamepadSwapSlot.Frame.BorderSizePixel = 0
		gamepadSwapSlot:MoveToInventory()
		textButton.SelectionImageObject.Visible = false
	end
end

function enableGamepadInventoryControl()
	local function fn3()
		if getGamepadSwapSlot() then
			local gamepadSwapSlot = getGamepadSwapSlot()

			if gamepadSwapSlot then
				gamepadSwapSlot.Frame.BorderSizePixel = 0
			end
		elseif frame3.Visible then
			v11:deselect()
		end
	end

	ContextActionService:BindAction("BackpackHasGamepadFocus", fn2, false, Enum.UserInputType.Gamepad1)
	ContextActionService:BindAction(
		"BackpackCloseInventory",
		fn3,
		false,
		Enum.KeyCode.ButtonB,
		Enum.KeyCode.ButtonStart
	)
	GuiService.SelectedObject = frame2:FindFirstChild("1")
end

function disableGamepadInventoryControl()
	unbindAllGamepadEquipActions()

	for i = 1, v25 do
		local v29 = v15[i]

		if v29 and v29.Frame then
			v29.Frame.BorderSizePixel = 0
		end
	end

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(frame) then
		GuiService.SelectedObject = nil
	end
end

local function bindBackpackHotbarAction()
	if v23 and not v13 then
		v13 = true
		ContextActionService:BindAction("BackpackHotbarEquip", fn, false, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unbindBackpackHotbarAction()
	disableGamepadInventoryControl()
	v13 = false
	ContextActionService:UnbindAction("BackpackHotbarEquip")
end

function gamepadDisconnected()
	flag2 = false
	disableGamepadInventoryControl()
end

function gamepadConnected()
	flag2 = true
	GuiService:AddSelectionParent("BackpackSelection", frame)

	if v20 >= 1 and v23 and not v13 then
		v13 = true
		ContextActionService:BindAction("BackpackHotbarEquip", fn, false, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1)
	end

	if frame3.Visible then
		enableGamepadInventoryControl()
	end
end

local function OnIconChanged(flag3: boolean)
	local core = flag3 and StarterGui:GetCore("TopbarEnabled")
	v23 = core
	frame.Visible = core

	if core then
		if v20 >= 1 and v23 and not v13 then
			v13 = true
			ContextActionService:BindAction(
				"BackpackHotbarEquip",
				fn,
				false,
				Enum.KeyCode.ButtonL1,
				Enum.KeyCode.ButtonR1
			)
		end
	else
		unbindBackpackHotbarAction() -- equivalent call inferred; original call site unknown
	end
end

local function MakeVRRoundButton(name: string, image: string)
	local imageButton = Instance.new("ImageButton")
	imageButton.BackgroundTransparency = 1
	imageButton.Name = name
	imageButton.Size = UDim2.new(0, 40, 0, 40)
	imageButton.Image = "rbxasset://textures/ui/Keyboard/close_button_background.png"
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Icon"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel.Position = UDim2.new(0.25, 0, 0.25, 0)
	imageLabel.Image = image
	imageLabel.Parent = imageButton
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Name = "Selection"
	imageLabel2.Size = UDim2.new(0.9, 0, 0.9, 0)
	imageLabel2.Position = UDim2.new(0.05, 0, 0.05, 0)
	imageLabel2.Image = "rbxasset://textures/ui/Keyboard/close_button_selection.png"
	imageButton.SelectionImageObject = imageLabel2
	return imageButton, imageLabel, imageLabel2
end

frame = Instance.new("Frame")
frame.BackgroundTransparency = 1
frame.Name = "Backpack"
frame.Size = UDim2.new(1, 0, 1, 0)
frame.Visible = false
frame.Parent = screenGui
frame2 = Instance.new("Frame")
frame2.BackgroundTransparency = 1
frame2.Name = "Hotbar"
frame2.Size = UDim2.new(1, 0, 1, 0)
frame2.Parent = frame

for i = 1, v25 do
	local slot = MakeSlot(frame2, i)
	slot.Frame.Visible = false

	if not v16 then
		v16 = slot
	end
end

local imageLabel = Instance.new("ImageLabel")
imageLabel.BackgroundTransparency = 1
imageLabel.Name = "LeftBumper"
imageLabel.Size = UDim2.new(0, 40, 0, 40)
imageLabel.Position = UDim2.new(0, -imageLabel.Size.X.Offset, 0.5, -imageLabel.Size.Y.Offset / 2)
local imageLabel2 = Instance.new("ImageLabel")
imageLabel2.BackgroundTransparency = 1
imageLabel2.Name = "RightBumper"
imageLabel2.Size = UDim2.new(0, 40, 0, 40)
imageLabel2.Position = UDim2.new(1, 0, 0.5, -imageLabel2.Size.Y.Offset / 2)
frame3 = Instance.new("Frame")
frame3.Name = "Inventory"
frame3.Size = UDim2.new(1, 0, 1, 0)
frame3.BackgroundTransparency = backgroundTransparency3
frame3.BackgroundColor3 = backgroundColor3
frame3.Active = true
frame3.Visible = false
frame3.Parent = frame
local uICorner = Instance.new("UICorner")
uICorner.Name = "Corner"
uICorner.CornerRadius = cornerRadius
uICorner.Parent = frame3
textButton = Instance.new("TextButton")
textButton.Name = "VRInventorySelector"
textButton.Position = UDim2.new(0, 0, 0, 0)
textButton.Size = UDim2.new(1, 0, 1, 0)
textButton.BackgroundTransparency = 1
textButton.Text = ""
textButton.Parent = frame3
local imageLabel3 = Instance.new("ImageLabel")
imageLabel3.BackgroundTransparency = 1
imageLabel3.Name = "Selector"
imageLabel3.Size = UDim2.new(1, 0, 1, 0)
imageLabel3.Image = "rbxasset://textures/ui/Keyboard/key_selection_9slice.png"
imageLabel3.ScaleType = Enum.ScaleType.Slice
imageLabel3.SliceCenter = Rect.new(12, 12, 52, 52)
imageLabel3.Visible = false
textButton.SelectionImageObject = imageLabel3
textButton.MouseButton1Click:Connect(function()
	vrMoveSlotToInventory()
end)
scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.Name = "ScrollingFrame"
scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
scrollingFrame.Selectable = false
scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.ScrollBarImageColor3 = Color3.new(1, 1, 1)
scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Parent = frame3
frame4 = Instance.new("Frame")
frame4.BackgroundTransparency = 1
frame4.Name = "UIGridFrame"
frame4.Selectable = false
frame4.Size = UDim2.new(1, -10, 1, 0)
frame4.Position = UDim2.new(0, 5, 0, 0)
frame4.Parent = scrollingFrame
local uIGridLayout = Instance.new("UIGridLayout")
uIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIGridLayout.CellSize = UDim2.new(0, v12, 0, v12)
uIGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
uIGridLayout.Parent = frame4
local vRRoundButton = MakeVRRoundButton("ScrollUpButton", "rbxasset://textures/ui/Backpack/ScrollUpArrow.png")
vRRoundButton.Size = UDim2.new(0, 34, 0, 34)
vRRoundButton.Position = UDim2.new(0.5, -vRRoundButton.Size.X.Offset / 2, 0, 43)
local icon = vRRoundButton.Icon
icon.Position = vRRoundButton.Icon.Position - UDim2.new(0, 0, 0, 2)
vRRoundButton.MouseButton1Click:Connect(function()
	scrollingFrame.CanvasPosition = Vector2.new(
		scrollingFrame.CanvasPosition.X,
		(math.min(
			scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteWindowSize.Y,
			(math.max(0, scrollingFrame.CanvasPosition.Y - (v12 + 5)))
		))
	)
end)
local vRRoundButton2 = MakeVRRoundButton("ScrollDownButton", "rbxasset://textures/ui/Backpack/ScrollUpArrow.png")
vRRoundButton2.Rotation = 180
local icon2 = vRRoundButton2.Icon
icon2.Position = vRRoundButton2.Icon.Position - UDim2.new(0, 0, 0, 2)
vRRoundButton2.Size = UDim2.new(0, 34, 0, 34)
vRRoundButton2.Position = UDim2.new(0.5, -vRRoundButton2.Size.X.Offset / 2, 1, -vRRoundButton2.Size.Y.Offset - 3)
vRRoundButton2.MouseButton1Click:Connect(function()
	scrollingFrame.CanvasPosition = Vector2.new(
		scrollingFrame.CanvasPosition.X,
		(math.min(
			scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteWindowSize.Y,
			(math.max(0, scrollingFrame.CanvasPosition.Y + (v12 + 5)))
		))
	)
end)
scrollingFrame.Changed:Connect(function(p: string)
	if p == "AbsoluteWindowSize" or p == "CanvasPosition" or p == "CanvasSize" then
		local visible = scrollingFrame.CanvasPosition.Y ~= 0
		local visible2 = scrollingFrame.CanvasPosition.Y < scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.AbsoluteWindowSize.Y
		vRRoundButton.Visible = visible
		vRRoundButton2.Visible = visible2
	end
end)
task.spawn(UpdateBackpackLayout)
local frame5 = Instance.new("Frame")
frame5.Name = "GamepadHintsFrame"
frame5.Size = UDim2.new(0, frame2.Size.X.Offset, 0, isTenFootInterface and 95 or 60)
frame5.BackgroundTransparency = backgroundTransparency3
frame5.BackgroundColor3 = backgroundColor3
frame5.Visible = false
frame5.Parent = frame
local uIListLayout = Instance.new("UIListLayout")
uIListLayout.Name = "Layout"
uIListLayout.Padding = UDim.new(0, 25)
uIListLayout.FillDirection = Enum.FillDirection.Horizontal
uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.Parent = frame5
local uICorner2 = Instance.new("UICorner")
uICorner2.Name = "Corner"
uICorner2.CornerRadius = cornerRadius
uICorner2.Parent = frame5

local function addGamepadHint(imageForKeyCode: string, text: string)
	local frame6 = Instance.new("Frame")
	frame6.Name = "HintFrame"
	frame6.AutomaticSize = Enum.AutomaticSize.XY
	frame6.BackgroundTransparency = 1
	frame6.Parent = frame5
	local uIListLayout2 = Instance.new("UIListLayout")
	uIListLayout2.Name = "Layout"
	uIListLayout2.Padding = isTenFootInterface and UDim.new(0, 20) or UDim.new(0, 12)
	uIListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout2.Parent = frame6
	local imageLabel4 = Instance.new("ImageLabel")
	imageLabel4.Name = "HintImage"
	imageLabel4.Size = isTenFootInterface and UDim2.new(0, 60, 0, 60) or UDim2.new(0, 30, 0, 30)
	imageLabel4.BackgroundTransparency = 1
	imageLabel4.Image = imageForKeyCode
	imageLabel4.Parent = frame6
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "HintText"
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	textLabel.TextSize = isTenFootInterface and 32 or 19
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.TextWrapped = true
	textLabel.Parent = frame6
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint.MaxTextSize = textLabel.TextSize
	uITextSizeConstraint.Parent = textLabel
end

addGamepadHint(UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonX), "Remove From Hotbar")
addGamepadHint(UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonA), "Select/Swap")
addGamepadHint(UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonB), "Close Backpack")

local function resizeGamepadHintsFrame()
	frame5.Size = UDim2.new(frame2.Size.X.Scale, frame2.Size.X.Offset, 0, isTenFootInterface and 95 or 60)
	frame5.Position = UDim2.new(
		frame2.Position.X.Scale,
		frame2.Position.X.Offset,
		frame3.Position.Y.Scale,
		frame3.Position.Y.Offset - frame5.Size.Y.Offset - 5
	)
	local children = frame5:GetChildren()
	local guiObjects = {}
	local total = 0

	for _, guiObject in pairs(children) do
		if guiObject:IsA("GuiObject") then
			table.insert(guiObjects, guiObject)
		end
	end

	for i = 1, #guiObjects do
		if not guiObjects[i]:IsA("GuiObject") then
			continue
		end

		guiObjects[i].Size = UDim2.new(1, 0, 1, -5)
		guiObjects[i].Position = UDim2.new(0, 0, 0, 0)
		total += guiObjects[i].HintText.Position.X.Offset + guiObjects[i].HintText.TextBounds.X
	end

	local v31 = (frame5.AbsoluteSize.X - total) / (#guiObjects - 1)

	for i = 1, #guiObjects do
		guiObjects[i].Position = i == 1 and UDim2.new(0, 0, 0, 0) or UDim2.new(
			0,
			guiObjects[i - 1].Position.X.Offset + guiObjects[i - 1].Size.X.Offset + v31,
			0,
			0
		)
		guiObjects[i].Size = UDim2.new(
			0,
			guiObjects[i].HintText.Position.X.Offset + guiObjects[i].HintText.TextBounds.X,
			1,
			-5
		)
	end
end

local frame6 = Instance.new("Frame")
frame6.Name = "Search"
frame6.BackgroundColor3 = color2
frame6.BackgroundTransparency = backgroundTransparency5
frame6.Size = UDim2.new(0, 190, 0, 30)
frame6.Position = UDim2.new(1, -frame6.Size.X.Offset - 5, 0, 5)
frame6.Parent = frame3
local uICorner3 = Instance.new("UICorner")
uICorner3.Name = "Corner"
uICorner3.CornerRadius = cornerRadius4
uICorner3.Parent = frame6
local uIStroke = Instance.new("UIStroke")
uIStroke.Name = "Border"
uIStroke.Color = color3
uIStroke.Thickness = 1
uIStroke.Transparency = 0.8
uIStroke.Parent = frame6
local textBox = Instance.new("TextBox")
textBox.BackgroundTransparency = 1
textBox.Name = "TextBox"
textBox.Text = ""
textBox.TextColor3 = textColor3
textBox.TextStrokeTransparency = textStrokeTransparency
textBox.TextStrokeColor3 = textStrokeColor3
textBox.FontFace = Font.new(fontFace.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
textBox.PlaceholderText = "Search"
textBox.TextColor3 = textColor3
textBox.TextTransparency = textStrokeTransparency
textBox.TextStrokeColor3 = textStrokeColor3
textBox.ClearTextOnFocus = false
textBox.TextTruncate = Enum.TextTruncate.AtEnd
textBox.TextSize = textSize
textBox.TextXAlignment = Enum.TextXAlignment.Left
textBox.TextYAlignment = Enum.TextYAlignment.Center
textBox.Size = UDim2.new(0, 154, 0, 14)
textBox.AnchorPoint = Vector2.new(0, 0.5)
textBox.Position = UDim2.new(0, 8, 0.5, 0)
textBox.ZIndex = 2
textBox.Parent = frame6
local textButton2 = Instance.new("TextButton")
textButton2.Name = "X"
textButton2.Text = ""
textButton2.Size = UDim2.new(0, 30, 0, 30)
textButton2.Position = UDim2.new(1, -textButton2.Size.X.Offset, 0.5, -textButton2.Size.Y.Offset / 2)
textButton2.ZIndex = 4
textButton2.Visible = false
textButton2.BackgroundTransparency = 1
textButton2.Parent = frame6
local imageButton = Instance.new("ImageButton")
imageButton.Name = "X"
imageButton.Image = "rbxasset://textures/ui/InspectMenu/x.png"
imageButton.BackgroundTransparency = 1
imageButton.Size = UDim2.new(0, frame6.Size.Y.Offset - 20, 0, frame6.Size.Y.Offset - 20)
imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
imageButton.Position = UDim2.new(0.5, 0, 0.5, 0)
imageButton.ZIndex = 1
imageButton.BorderSizePixel = 0
imageButton.Parent = textButton2

local function search()
	local v31 = {}

	for k in textBox.Text:gmatch("%S+") do
		v31[k:lower()] = true
	end

	local v32 = {}

	for i = v25 + 1, #v15 do
		local v33 = v15[i]
		table.insert(v32, { v33, (v33:CheckTerms(v31)) })
		v33.Frame.Visible = false
		v33.Frame.Parent = frame3
	end

	table.sort(v32, function(a, b)
		return a[2] > b[2]
	end)
	flag = true
	local count = 0

	for _, v33 in ipairs(v32) do
		local v34 = v33[1]

		if not (v33[2] > 0) then
			continue
		end

		v34.Frame.Visible = true
		v34.Frame.Parent = frame4
		v34.Frame.LayoutOrder = v25 + count
		count += 1
	end

	scrollingFrame.CanvasPosition = Vector2.new(0, 0)
	UpdateScrollingFrameCanvasSize()
	textButton2.ZIndex = 3
end

local function clearResults()
	if textButton2.ZIndex > 0 then
		flag = false

		for i = v25 + 1, #v15 do
			local v31 = v15[i]
			v31.Frame.LayoutOrder = v31.Index
			v31.Frame.Parent = frame4
			v31.Frame.Visible = true
		end

		textButton2.ZIndex = 0
	end

	UpdateScrollingFrameCanvasSize()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reset()
	clearResults()
	textBox.Text = ""
end

local function onChanged(p: string)
	if p == "Text" then
		local text = textBox.Text

		if text == "" then
			textBox.TextTransparency = textStrokeTransparency
			clearResults()
		elseif text ~= "" then
			textBox.TextTransparency = 0
			search()
		end

		textButton2.Visible = text ~= "" and text ~= ""
	end
end

local function focusLost(flag3: boolean)
	if flag3 then
		search()
	end
end

textButton2.MouseButton1Click:Connect(reset)
textBox.Changed:Connect(onChanged)
textBox.FocusLost:Connect(focusLost)
Satchel.StateChanged.Event:Connect(function(flag3: boolean)
	if not flag3 then
		reset() -- equivalent call inferred; original call site unknown
	end
end)

v18[Enum.KeyCode.Escape.Value] = function(p)
	if p then
		reset() -- equivalent call inferred; original call site unknown
	end
end

local function detectGamepad(p)
	if p == Enum.UserInputType.Gamepad1 and not UserInputService.VREnabled then
		frame6.Visible = false
	else
		frame6.Visible = true
	end
end

UserInputService.LastInputTypeChanged:Connect(detectGamepad)
GuiService.MenuOpened:Connect(function()
	screenGui.Enabled = false
	v11:setEnabled(false)
end)
GuiService.MenuClosed:Connect(function()
	screenGui.Enabled = true
	v11:setEnabled(true)
end)

local function fn3(_: string, p, _)
	if not (p == Enum.UserInputState.Begin and GuiService.SelectedObject) then
		return
	end

	for i = 1, v25 do
		if not (v15[i].Frame == GuiService.SelectedObject and v15[i].Tool) then
			continue
		end

		v15[i]:MoveToInventory()
		break
	end
end

local function openClose()
	if not next(v19) then
		frame3.Visible = not frame3.Visible
		local visible = frame3.Visible
		AdjustHotbarFrames()
		frame2.Active = not frame2.Active

		for i = 1, v25 do
			v15[i]:SetClickability(not visible)
		end
	end

	if frame3.Visible then
		if flag2 then
			if v9[UserInputService:GetLastInputType()] then
				resizeGamepadHintsFrame()
				frame5.Visible = not UserInputService.VREnabled
			end

			enableGamepadInventoryControl()
		end
	else
		if flag2 then
			frame5.Visible = false
		end

		disableGamepadInventoryControl()
	end

	if frame3.Visible then
		ContextActionService:BindAction("BackpackRemoveSlot", fn3, false, Enum.KeyCode.ButtonX)
	else
		ContextActionService:UnbindAction("BackpackRemoveSlot")
	end

	Satchel.IsOpen = frame3.Visible
	Satchel.StateChanged:Fire(frame3.Visible)
end

task.spawn(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)
Satchel.OpenClose = openClose

while not localPlayer do
	task.wait()
	localPlayer = Players.LocalPlayer
end

localPlayer.CharacterAdded:Connect(OnCharacterAdded)

if localPlayer.Character then
	task.spawn(OnCharacterAdded, localPlayer.Character)
end

UserInputService.InputBegan:Connect(OnInputBegan)
UserInputService.TextBoxFocused:Connect(function()
	v24 = true
end)
UserInputService.TextBoxFocusReleased:Connect(function()
	v24 = false
end)

v18[value] = function()
	if v21 then
		UnequipAllTools()
	end
end

UserInputService.LastInputTypeChanged:Connect(OnUISChanged)
OnUISChanged()

if UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1) then
	gamepadConnected()
end

UserInputService.GamepadConnected:Connect(function(p)
	if p == Enum.UserInputType.Gamepad1 then
		gamepadConnected()
	end
end)
UserInputService.GamepadDisconnected:Connect(function(p)
	if p == Enum.UserInputType.Gamepad1 then
		gamepadDisconnected()
	end
end)

function Satchel.SetBackpackEnabled(_, flag3: boolean)
	v10 = flag3
end

function Satchel.IsOpened(_)
	return Satchel.IsOpen
end

function Satchel.GetBackpackEnabled(_)
	return v10
end

function Satchel.GetStateChangedEvent(_)
	return Satchel.StateChanged
end

task.spawn(function()
	local v31 = 30

	while v31 > 0 and not pcall(function()
		StarterGui:GetCore("TopbarEnabled")
	end) do
		v31 -= task.wait()
	end

	RunService.Heartbeat:Connect(function()
		local core = v10 and StarterGui:GetCore("TopbarEnabled")
		v23 = core
		frame.Visible = core

		if core then
			if v20 >= 1 and v23 and not v13 then
				v13 = true
				ContextActionService:BindAction(
					"BackpackHotbarEquip",
					fn,
					false,
					Enum.KeyCode.ButtonL1,
					Enum.KeyCode.ButtonR1
				)
			end
		else
			unbindBackpackHotbarAction() -- equivalent call inferred; original call site unknown
		end
	end)
end)

local function OnPreferredTransparencyChanged()
	local preferredTransparency2 = GuiService.PreferredTransparency
	backgroundTransparency3 = backgroundTransparency * preferredTransparency2
	frame3.BackgroundTransparency = backgroundTransparency3
	backgroundTransparency4 = backgroundTransparency2 * preferredTransparency2

	for _, v31 in ipairs(v15) do
		v31.Frame.BackgroundTransparency = backgroundTransparency4
	end

	backgroundTransparency5 = preferredTransparency2 * 0.2
	frame6.BackgroundTransparency = backgroundTransparency5
end

GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(OnPreferredTransparencyChanged)
return Satchel