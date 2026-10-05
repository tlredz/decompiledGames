local Players = game:GetService("Players")
local UIKit = require(script.Parent.UI.UIKit)
local CameraTools = require(script.Parent.UI.CameraTools)
local SpectateSection = require(script.Parent.UI.SpectateSection)
local FreecamSection = require(script.Parent.UI.FreecamSection)
local TrollSection = require(script.Parent.UI.TrollSection)
local GiftTreadmillSection = require(script.Parent.UI.GiftTreadmillSection)
local CCWorldsSection = require(script.Parent.UI.CCWorldsSection)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v = nil
local refresh = nil
local refresh2 = nil
local refresh3 = nil
local CCPanelUISystem = {}

function CCPanelUISystem.createPanel(callback)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CCPanelGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 300
	screenGui.Enabled = false
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Name = "Panel"
	frame.Size = UDim2.new(0, 480, 0, 420)
	frame.Position = UDim2.new(0.5, -240, 0.5, -210)
	frame.BackgroundColor3 = UIKit.C_BG
	frame.BorderSizePixel = 0
	UIKit.corner(frame, 8)
	frame.Parent = screenGui
	local uIDragDetector = Instance.new("UIDragDetector")
	uIDragDetector.DragStyle = Enum.UIDragDetectorDragStyle.TranslatePlane
	uIDragDetector.Parent = frame
	local frame2 = Instance.new("Frame")
	frame2.Name = "Header"
	frame2.Size = UDim2.new(1, 0, 0, 44)
	frame2.BackgroundColor3 = UIKit.C_HEADER
	frame2.BorderSizePixel = 0
	UIKit.corner(frame2, 8)
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Size = UDim2.new(1, 0, 0.5, 0)
	frame3.Position = UDim2.new(0, 0, 0.5, 0)
	frame3.BackgroundColor3 = UIKit.C_HEADER
	frame3.BorderSizePixel = 0
	frame3.Parent = frame2
	UIKit.label(
		frame2,
		"Title",
		"CC Panel",
		UDim2.new(1, -50, 1, 0),
		UDim2.new(0, 14, 0, 0),
		16,
		UIKit.C_TEXT,
		UIKit.FONT_BOLD
	)
	local textButton = Instance.new("TextButton")
	textButton.Size = UDim2.new(0, 32, 0, 32)
	textButton.Position = UDim2.new(1, -38, 0.5, -16)
	textButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	textButton.Text = "✕"
	textButton.TextSize = 16
	textButton.Font = UIKit.FONT_BOLD
	textButton.TextColor3 = Color3.new(1, 1, 1)
	textButton.BorderSizePixel = 0
	UIKit.corner(textButton, 5)
	textButton.Parent = frame2
	textButton.MouseButton1Click:Connect(function()
		screenGui.Enabled = false

		if callback then
			callback()
		end
	end)
	local frame4 = Instance.new("Frame")
	frame4.Name = "Body"
	frame4.Size = UDim2.new(1, -12, 1, -72)
	frame4.Position = UDim2.new(0, 6, 0, 48)
	frame4.BackgroundTransparency = 1
	frame4.Parent = frame
	local frame5 = Instance.new("Frame")
	frame5.Name = "LeftCol"
	frame5.Size = UDim2.new(0, 160, 1, 0)
	frame5.BackgroundColor3 = UIKit.C_SECTION
	frame5.BorderSizePixel = 0
	UIKit.corner(frame5, 6)
	frame5.Parent = frame4
	UIKit.label(
		frame5,
		"ListTitle",
		"Players",
		UDim2.new(1, -8, 0, 22),
		UDim2.new(0, 4, 0, 4),
		11,
		UIKit.C_SUB,
		UIKit.FONT_BOLD,
		Enum.TextXAlignment.Center
	)
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "PlayerList"
	scrollingFrame.Size = UDim2.new(1, -6, 1, -30)
	scrollingFrame.Position = UDim2.new(0, 3, 0, 26)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 3
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.Parent = frame5
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Padding = UDim.new(0, 2)
	uIListLayout.SortOrder = Enum.SortOrder.Name
	uIListLayout.Parent = scrollingFrame
	uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uIListLayout.AbsoluteContentSize.Y + 4)
	end)
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingTop = UDim.new(0, 2)
	uIPadding.PaddingLeft = UDim.new(0, 2)
	uIPadding.PaddingRight = UDim.new(0, 2)
	uIPadding.Parent = scrollingFrame
	local scrollingFrame2 = Instance.new("ScrollingFrame")
	scrollingFrame2.Name = "RightScroll"
	scrollingFrame2.Size = UDim2.new(1, -168, 1, 0)
	scrollingFrame2.Position = UDim2.new(0, 166, 0, 0)
	scrollingFrame2.BackgroundTransparency = 1
	scrollingFrame2.BorderSizePixel = 0
	scrollingFrame2.ScrollBarThickness = 3
	scrollingFrame2.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame2.Parent = frame4
	local uIListLayout2 = Instance.new("UIListLayout")
	uIListLayout2.Padding = UDim.new(0, 6)
	uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout2.Parent = scrollingFrame2
	uIListLayout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, uIListLayout2.AbsoluteContentSize.Y + 6)
	end)
	local uIPadding2 = Instance.new("UIPadding")
	uIPadding2.PaddingTop = UDim.new(0, 3)
	uIPadding2.PaddingRight = UDim.new(0, 3)
	uIPadding2.Parent = scrollingFrame2

	local function makeSection(layoutOrder: number, p: number)
		local frame6 = Instance.new("Frame")
		frame6.Size = UDim2.new(1, 0, 0, p)
		frame6.LayoutOrder = layoutOrder
		frame6.BackgroundColor3 = UIKit.C_SECTION
		frame6.BorderSizePixel = 0
		UIKit.corner(frame6, 6)
		frame6.Parent = scrollingFrame2
		return frame6
	end

	local label = UIKit.label(
		frame,
		"Status",
		"",
		UDim2.new(1, -20, 0, 20),
		UDim2.new(0, 10, 1, -24),
		11,
		UIKit.C_ON,
		UIKit.FONT
	)

	local function setStatus(text: string, flag: boolean?)
		label.Text = text
		label.TextColor3 = flag and UIKit.C_OFF or UIKit.C_ON
		task.delay(3, function()
			if label.Text == text then
				label.Text = ""
			end
		end)
	end

	local v2 = nil
	local v3 = nil
	local v4 = {}

	local function notifySelection()
		for _, v5 in v4 do
			v5()
		end
	end

	local selection = {
		get = function()
			return v2
		end,
		getOffline = function()
			return v3
		end,
		select = function(p)
			v2 = p
			v3 = nil

			for _, v6 in v4 do
				v6()
			end
		end,
		selectOffline = function(userId, name)
			v2 = nil
			v3 = {
				userId = userId,
				name = name
			}

			for _, v6 in v4 do
				v6()
			end
		end,
		onChanged = function(p)
			table.insert(v4, p)
		end
	}
	local v6 = {}

	local function updateHighlights()
		for k, v7 in v6 do
			v7.BackgroundColor3 = (v2 == k or CameraTools.getSpectateTarget() == k) and UIKit.C_SEL or UIKit.C_ENTRY
		end
	end

	selection.onChanged(updateHighlights)

	local function buildPlayerList()
		for _, child in scrollingFrame:GetChildren() do
			if not (child:IsA("UIListLayout") or child:IsA("UIPadding")) then
				child:Destroy()
			end
		end

		v6 = {}
		local v7 = false

		for _, v8 in Players:GetPlayers() do
			if v8 == localPlayer then
				continue
			end

			local textButton2 = Instance.new("TextButton")
			textButton2.Name = v8.Name
			textButton2.Size = UDim2.new(1, 0, 0, 30)
			textButton2.BackgroundColor3 = UIKit.C_ENTRY
			textButton2.Text = v8.Name
			textButton2.TextSize = 12
			textButton2.Font = UIKit.FONT
			textButton2.TextColor3 = UIKit.C_TEXT
			textButton2.BorderSizePixel = 0
			textButton2.AutoButtonColor = false
			textButton2.TextTruncate = Enum.TextTruncate.AtEnd
			UIKit.corner(textButton2, 4)
			textButton2.Parent = scrollingFrame
			v6[v8] = textButton2
			local v9 = v8
			textButton2.MouseEnter:Connect(function()
				if v2 ~= v9 then
					textButton2.BackgroundColor3 = UIKit.C_HOVER
				end
			end)
			local v11 = v8
			local v12 = textButton2
			textButton2.MouseLeave:Connect(function()
				if v2 ~= v11 then
					v12.BackgroundColor3 = UIKit.C_ENTRY
				end
			end)
			local v13 = v8
			textButton2.MouseButton1Click:Connect(function()
				selection.select(v13)
			end)
			v7 = true
		end

		if not v7 then
			UIKit.label(
				scrollingFrame,
				"Empty",
				"No players",
				UDim2.new(1, 0, 0, 28),
				UDim2.new(0, 0, 0, 0),
				11,
				UIKit.C_SUB,
				UIKit.FONT,
				Enum.TextXAlignment.Center
			)
		end

		updateHighlights()
	end

	v = buildPlayerList
	local v7 = {
		gui = screenGui,
		makeSection = makeSection,
		setStatus = setStatus,
		selection = selection
	}
	SpectateSection.build(v7)
	FreecamSection.build(v7)
	local v8 = TrollSection.build(v7)
	local v9 = GiftTreadmillSection.build(v7)
	local v10 = CCWorldsSection.build(v7)
	refresh2 = v8.refresh
	refresh = v9.refresh
	refresh3 = v10.refresh
	Players.PlayerAdded:Connect(function()
		if screenGui.Enabled then
			buildPlayerList()
		end
	end)
	Players.PlayerRemoving:Connect(function()
		if screenGui.Enabled then
			buildPlayerList()
		end
	end)
	return screenGui
end

function CCPanelUISystem:toggle()
	self.Enabled = not self.Enabled

	if self.Enabled then
		if v then
			v()
		end

		if refresh then
			refresh()
		end

		if refresh2 then
			refresh2()
		end

		if refresh3 then
			refresh3()
		end
	end
end

return CCPanelUISystem