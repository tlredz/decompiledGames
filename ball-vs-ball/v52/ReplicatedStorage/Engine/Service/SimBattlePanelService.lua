local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local BattleConfig = require(ReplicatedStorage:WaitForChild("BattleDemo"):WaitForChild("BattleConfig"))
local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))
local SimBattleClient = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("SimBattleClient"))
local UIManager = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Gui"):WaitForChild("UIManager"))
local color = Color3.fromRGB(244, 246, 250)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(226, 230, 238)
local color4 = Color3.fromRGB(28, 32, 44)
local color5 = Color3.fromRGB(124, 132, 152)
local color6 = Color3.fromRGB(58, 110, 230)
local color7 = Color3.fromRGB(226, 86, 86)
local color8 = Color3.fromRGB(58, 143, 255)
local color9 = Color3.fromRGB(214, 158, 24)
local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function make(className: string, items, parent)
	local instance = Instance.new(className)

	for k, item in items do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

-- equivalent calls inferred from this helper; original call sites unknown
local function corner(parent, p: number)
	local v = {
		CornerRadius = UDim.new(0, p)
	}
	local uICorner = Instance.new("UICorner")

	for k, v2 in v do
		uICorner[k] = v2
	end

	uICorner.Parent = parent
end

local function stroke(parent, color10: Color3?, value: number?)
	local uIStroke = Instance.new("UIStroke")

	for k, v2 in {
		Color = color10 or color3,
		Thickness = value or 1
	} do
		uIStroke[k] = v2
	end

	uIStroke.Parent = parent
	return uIStroke
end

local function padding(parent, p: number, p2: number, p3: number, p4: number)
	local v = {
		PaddingLeft = UDim.new(0, p),
		PaddingRight = UDim.new(0, p2),
		PaddingTop = UDim.new(0, p3),
		PaddingBottom = UDim.new(0, p4)
	}
	local uIPadding = Instance.new("UIPadding")

	for k, v2 in v do
		uIPadding[k] = v2
	end

	uIPadding.Parent = parent
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isValidImageValue(image)
	return typeof(image) == "string" and image ~= "" and string.match(image, "^%a+://") ~= nil
end

local function ballImage(p: string)
	local byCnId = Config.ball.byCnId
	local v = byCnId and byCnId[p]
	local image = v and v.image

	-- equivalent call inferred; original call site unknown
	if isValidImageValue(image) then
		return image
	end

	return nil
end

local v = {}
local SimBattlePanelService = {}

for _, v2 in ipairs(BattleConfig.battle.rolePool) do
	if BattleConfig.roles[v2] then
		table.insert(v, v2)
	end
end

assert(#v > 0, "BattleConfig.battle.rolePool 中没有有效角色")

-- equivalent calls inferred from this helper; original call sites unknown
local function defaultRoleIdForSlot(p: number)
	return v[math.min(p, #v)]
end

local function resolveDefaultBoardSize(flag: boolean)
	if flag then
		local _2v2 = Config.board.byCnId["2v2棋盘"]

		if _2v2 and typeof(_2v2.xSize) == "number" then
			return _2v2.xSize
		end
	end

	return BattleConfig.arena.size.X
end

local function setBackgroundUiHidden(flag: boolean)
	UIManager.SetScreenGuiEnabled("界面图标", not flag)
	UIManager.SetScreenGuiEnabled("右侧菜单", not flag)
	UIManager.SetScreenGuiEnabled("下方按钮区", not flag)
	UIManager.SetScreenGuiEnabled("货币", not flag)
	local rewardsMenu = UIManager.Get("RewardsMenu")

	if rewardsMenu then
		rewardsMenu.SetTopbarEnabled(not flag)
	end

	local playerPanel = UIManager.Get("PlayerPanel")

	if playerPanel then
		playerPanel.SetTopbarEnabled(not flag)
	end

	local emoteWheel = UIManager.Get("EmoteWheel")

	if emoteWheel then
		emoteWheel.SetTopbarEnabled(not flag)
	end

	local settings = UIManager.Get("Settings")

	if settings then
		settings.SetTopbarEnabled(not flag)
	end
end

local showHealth = true
local flag = false

local function ensureEndedHookRegistered()
	if flag or typeof(SimBattleClient.onEnded) ~= "function" then
		return
	end

	flag = true
	SimBattleClient.onEnded(function()
		task.wait(0.6)
		SimBattlePanelService.open()
	end)
end

local function build(screenGui)
	local v3 = {
		Name = "Root",
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.8, 0.8),
		ZIndex = 2
	}
	local frame = Instance.new("Frame")

	for k, v4 in v3 do
		frame[k] = v4
	end

	frame.Parent = screenGui
	corner(frame, 16) -- equivalent call inferred; original call site unknown
	local uIStroke = Instance.new("UIStroke")

	for k, v5 in {
		Color = color3 or color3,
		Thickness = 1
	} do
		uIStroke[k] = v5
	end

	uIStroke.Parent = frame
	local v5 = {
		Name = "Header",
		BackgroundColor3 = color2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 60),
		ZIndex = 3
	}
	local frame2 = Instance.new("Frame")

	for k, v6 in v5 do
		frame2[k] = v6
	end

	frame2.Parent = frame
	padding(frame2, 20, 20, 0, 0)
	local v6 = {
		Name = "HeaderBorder",
		BackgroundColor3 = color3,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 59),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 4
	}
	local frame3 = Instance.new("Frame")

	for k, v7 in v6 do
		frame3[k] = v7
	end

	frame3.Parent = frame
	local v7 = {
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 220, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "模拟对战",
		TextColor3 = color4,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4
	}
	local textLabel = Instance.new("TextLabel")

	for k, v8 in v7 do
		textLabel[k] = v8
	end

	textLabel.Parent = frame2

	local function headerButton(name: string, text: string, p3: number, p4: number)
		local v8 = {
			Name = name,
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(240, 243, 249),
			AutoButtonColor = false,
			Position = UDim2.new(1, -p3, 0.5, 0),
			Size = UDim2.fromOffset(p4, 32),
			Font = Enum.Font.GothamMedium,
			Text = text,
			TextColor3 = color4,
			TextSize = 13,
			ZIndex = 4
		}
		local textButton = Instance.new("TextButton")

		for k, v10 in v8 do
			textButton[k] = v10
		end

		textButton.Parent = frame2
		corner(textButton, 8) -- equivalent call inferred; original call site unknown
		local uIStroke2 = Instance.new("UIStroke")

		for k, v11 in {
			Color = color3,
			Thickness = 1
		} do
			uIStroke2[k] = v11
		end

		uIStroke2.Parent = textButton
		textButton.MouseEnter:Connect(function()
			TweenService:Create(textButton, tweenInfo, {
				BackgroundColor3 = Color3.fromRGB(228, 234, 246)
			}):Play()
		end)
		textButton.MouseLeave:Connect(function()
			TweenService:Create(textButton, tweenInfo, {
				BackgroundColor3 = Color3.fromRGB(240, 243, 249)
			}):Play()
		end)
		return textButton
	end

	local v8 = headerButton("CloseButton", "关闭", 8, 64)
	ButtonActions.Bind(v8, function()
		setBackgroundUiHidden(false)
		SimBattlePanelService.close()
	end)
	local v9 = headerButton("ModeButton", "切换到2v2", 84, 112)
	local v10 = {
		Name = "SizeBar",
		BackgroundColor3 = color2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 60),
		Size = UDim2.new(1, 0, 0, 40),
		ZIndex = 3
	}
	local frame4 = Instance.new("Frame")

	for k, v11 in v10 do
		frame4[k] = v11
	end

	frame4.Parent = frame
	padding(frame4, 20, 20, 0, 0)
	local v11 = {
		Name = "SizeBarBorder",
		BackgroundColor3 = color3,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 39),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 4
	}
	local frame5 = Instance.new("Frame")

	for k, v12 in v11 do
		frame5[k] = v12
	end

	frame5.Parent = frame4
	local v12 = {
		Name = "SizeLabel",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 100, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = "棋盘尺寸",
		TextColor3 = color5,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4
	}
	local textLabel2 = Instance.new("TextLabel")

	for k, v13 in v12 do
		textLabel2[k] = v13
	end

	textLabel2.Parent = frame4
	local X = BattleConfig.arena.size.X
	local v13 = {
		Name = "SizeInput",
		BackgroundColor3 = Color3.fromRGB(240, 243, 249),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 100, 0.5, 0),
		Size = UDim2.fromOffset(80, 28),
		Font = Enum.Font.GothamMedium,
		Text = string.format("%.4g", X),
		PlaceholderText = "10-100",
		TextColor3 = color4,
		TextSize = 14,
		ClearTextOnFocus = false,
		ZIndex = 4
	}
	local textBox = Instance.new("TextBox")

	for k, v14 in v13 do
		textBox[k] = v14
	end

	textBox.Parent = frame4
	corner(textBox, 8) -- equivalent call inferred; original call site unknown
	local uIStroke2 = Instance.new("UIStroke")

	for k, v15 in {
		Color = color3,
		Thickness = 1
	} do
		uIStroke2[k] = v15
	end

	uIStroke2.Parent = textBox
	local v15 = {
		Name = "SizeHint",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 190, 0, 0),
		Size = UDim2.new(0, 200, 1, 0),
		Font = Enum.Font.Gotham,
		Text = "正方形边长，10-100",
		TextColor3 = color5,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4
	}
	local textLabel3 = Instance.new("TextLabel")

	for k, v16 in v15 do
		textLabel3[k] = v16
	end

	textLabel3.Parent = frame4
	local v16 = {
		Name = "HealthToggle",
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromRGB(240, 243, 249),
		AutoButtonColor = false,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(130, 28),
		Font = Enum.Font.GothamMedium,
		TextColor3 = color4,
		TextSize = 13,
		ZIndex = 4
	}
	local textButton = Instance.new("TextButton")

	for k, v17 in v16 do
		textButton[k] = v17
	end

	textButton.Parent = frame4
	corner(textButton, 8) -- equivalent call inferred; original call site unknown
	local uIStroke3 = Instance.new("UIStroke")

	for k, v18 in {
		Color = color3,
		Thickness = 1
	} do
		uIStroke3[k] = v18
	end

	uIStroke3.Parent = textButton

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshHealthToggle()
		textButton.Text = showHealth and "显示血量：开" or "显示血量：关"
		local parent = textButton
		local textColor

		if showHealth then
			textColor = color4
		else
			textColor = color5
		end

		parent.TextColor3 = textColor
	end

	textButton.Text = showHealth and "显示血量：开" or "显示血量：关"
	local textColor2

	if showHealth then
		textColor2 = color4
	else
		textColor2 = color5
	end

	textButton.TextColor3 = textColor2
	ButtonActions.Bind(textButton, function()
		showHealth = not showHealth
		refreshHealthToggle() -- equivalent call inferred; original call site unknown
	end)
	local v19 = {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 100),
		Size = UDim2.new(1, 0, 1, -192),
		ZIndex = 2
	}
	local frame6 = Instance.new("Frame")

	for k, v20 in v19 do
		frame6[k] = v20
	end

	frame6.Parent = frame
	padding(frame6, 20, 20, 16, 12)

	local function refreshBallSelection(cards, roleId: string, color10: Color3)
		for k, item in pairs(cards) do
			if k == roleId then
				TweenService:Create(item.card, tweenInfo, {
					BackgroundColor3 = color10:Lerp(color2, 0.82)
				}):Play()
				TweenService:Create(item.stroke, tweenInfo, {
					Color = color10,
					Thickness = 2
				}):Play()
			else
				TweenService:Create(item.card, tweenInfo, {
					BackgroundColor3 = color2
				}):Play()
				TweenService:Create(item.stroke, tweenInfo, {
					Color = color3,
					Thickness = 1
				}):Play()
			end
		end
	end

	local function buildSlotSide(p: string, text: string, color10: Color3, roleId: string)
		local v20 = {
			Name = p .. "Side",
			BackgroundTransparency = 1,
			ZIndex = 3
		}
		local frame7 = Instance.new("Frame")
		local v22 = {
			roleId = roleId,
			cards = {}
		}

		for k, v23 in v20 do
			frame7[k] = v23
		end

		frame7.Parent = frame6
		v22.frame = frame7
		local v23 = {
			Name = "SideTitle",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 24),
			Font = Enum.Font.GothamBold,
			Text = text,
			TextColor3 = color10,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 4
		}
		local textLabel4 = Instance.new("TextLabel")

		for k, v24 in v23 do
			textLabel4[k] = v24
		end

		textLabel4.Parent = frame7
		v22.titleLabel = textLabel4
		local v24 = {
			Name = "BallCard",
			BackgroundColor3 = color2,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 32),
			Size = UDim2.new(1, 0, 1, -32),
			ZIndex = 3
		}
		local frame8 = Instance.new("Frame")

		for k, v25 in v24 do
			frame8[k] = v25
		end

		frame8.Parent = frame7
		corner(frame8, 10) -- equivalent call inferred; original call site unknown
		local uIStroke4 = Instance.new("UIStroke")

		for k, v26 in {
			Color = color3,
			Thickness = 1
		} do
			uIStroke4[k] = v26
		end

		uIStroke4.Parent = frame8
		local v26 = {
			Name = "BallScroll",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 6,
			ScrollBarImageColor3 = color3,
			ZIndex = 4
		}
		local scrollingFrame = Instance.new("ScrollingFrame")

		for k, v27 in v26 do
			scrollingFrame[k] = v27
		end

		scrollingFrame.Parent = frame8
		padding(scrollingFrame, 10, 10, 10, 10)
		local v27 = {
			CellSize = UDim2.fromOffset(84, 96),
			CellPadding = UDim2.fromOffset(8, 8),
			SortOrder = Enum.SortOrder.LayoutOrder
		}
		local uIGridLayout = Instance.new("UIGridLayout")

		for k, v28 in v27 do
			uIGridLayout[k] = v28
		end

		uIGridLayout.Parent = scrollingFrame

		for i, v28 in ipairs(v) do
			local role = BattleConfig.roles[v28]
			local v29 = {
				Name = "BallCard_" .. v28,
				LayoutOrder = i,
				BackgroundColor3 = color2,
				AutoButtonColor = false,
				Text = "",
				ZIndex = 5
			}
			local textButton2 = Instance.new("TextButton")

			for k, v30 in v29 do
				textButton2[k] = v30
			end

			textButton2.Parent = scrollingFrame
			corner(textButton2, 8) -- equivalent call inferred; original call site unknown
			local uIStroke5 = Instance.new("UIStroke")

			for k, v31 in {
				Color = color3,
				Thickness = 1
			} do
				uIStroke5[k] = v31
			end

			uIStroke5.Parent = textButton2
			local byCnId = Config.ball.byCnId
			local v31 = byCnId and byCnId[v28]
			local image = v31 and v31.image

			-- equivalent call inferred; original call site unknown
			if not isValidImageValue(image) then
				image = nil
			end

			if image then
				local v32 = {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 8),
					Size = UDim2.fromOffset(42, 42),
					Image = image,
					ZIndex = 6
				}
				local imageLabel = Instance.new("ImageLabel")

				for k, v33 in v32 do
					imageLabel[k] = v33
				end

				imageLabel.Parent = textButton2
			end

			local v32 = {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 4, 1, -8),
				Size = UDim2.new(1, -8, 0, 18),
				Font = Enum.Font.GothamMedium,
				Text = role.displayNameCN or role.displayName,
				TextColor3 = color4,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 6
			}
			local textLabel5 = Instance.new("TextLabel")

			for k, v33 in v32 do
				textLabel5[k] = v33
			end

			textLabel5.Parent = textButton2
			v22.cards[v28] = {
				card = textButton2,
				stroke = uIStroke5
			}
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refresh()
			refreshBallSelection(v22.cards, v22.roleId, color10)
		end

		for k, card in pairs(v22.cards) do
			local roleId2 = k
			ButtonActions.Bind(card.card, function()
				v22.roleId = roleId2
				refresh() -- equivalent call inferred; original call site unknown
			end)
		end

		refresh() -- equivalent call inferred; original call site unknown
		return v22
	end

	local slotSide = buildSlotSide("Blue1", "蓝方", color8, defaultRoleIdForSlot(1))
	local slotSide2 = buildSlotSide("Blue2", "蓝方2", color8, defaultRoleIdForSlot(2))
	local slotSide3 = buildSlotSide("Yellow1", "黄方", color9, defaultRoleIdForSlot(2))
	local slotSide4 = buildSlotSide("Yellow2", "黄方2", color9, defaultRoleIdForSlot(1))
	local v20 = false

	local function applyLayout()
		if v20 then
			slotSide.titleLabel.Text = "蓝方1"
			slotSide3.titleLabel.Text = "黄方1"
			slotSide2.frame.Visible = true
			slotSide4.frame.Visible = true
			slotSide.frame.Position = UDim2.new(0, 0, 0, 0)
			slotSide.frame.Size = UDim2.new(0.25, -6, 1, 0)
			slotSide2.frame.Position = UDim2.new(0.25, 2, 0, 0)
			slotSide2.frame.Size = UDim2.new(0.25, -6, 1, 0)
			slotSide3.frame.Position = UDim2.new(0.5, 4, 0, 0)
			slotSide3.frame.Size = UDim2.new(0.25, -6, 1, 0)
			slotSide4.frame.Position = UDim2.new(0.75, 6, 0, 0)
			slotSide4.frame.Size = UDim2.new(0.25, -6, 1, 0)
		else
			slotSide.titleLabel.Text = "蓝方"
			slotSide3.titleLabel.Text = "黄方"
			slotSide2.frame.Visible = false
			slotSide4.frame.Visible = false
			slotSide.frame.Position = UDim2.new(0, 0, 0, 0)
			slotSide.frame.Size = UDim2.new(0.5, -8, 1, 0)
			slotSide3.frame.Position = UDim2.new(0.5, 8, 0, 0)
			slotSide3.frame.Size = UDim2.new(0.5, -8, 1, 0)
		end
	end

	applyLayout()
	ButtonActions.Bind(v9, function()
		v20 = not v20
		v9.Text = v20 and "切换到1v1" or "切换到2v2"
		applyLayout()
		local parent = textBox
		local xSize

		if v20 then
			local _2v2 = Config.board.byCnId["2v2棋盘"]

			if _2v2 and typeof(_2v2.xSize) == "number" then
				xSize = _2v2.xSize
			else
				xSize = BattleConfig.arena.size.X
			end
		else
			xSize = BattleConfig.arena.size.X
		end

		parent.Text = string.format("%.4g", xSize)
	end)
	local v21 = {
		Name = "BottomBar",
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = color2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 92),
		ZIndex = 3
	}
	local frame7 = Instance.new("Frame")

	for k, v22 in v21 do
		frame7[k] = v22
	end

	frame7.Parent = frame
	local v22 = {
		Name = "BottomBarBorder",
		BackgroundColor3 = color3,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 4
	}
	local frame8 = Instance.new("Frame")

	for k, v23 in v22 do
		frame8[k] = v23
	end

	frame8.Parent = frame7
	local v23 = {
		Name = "ErrorLabel",
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = UDim2.new(1, -40, 0, 18),
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = color7,
		TextSize = 13,
		ZIndex = 4
	}
	local textLabel4 = Instance.new("TextLabel")

	for k, v24 in v23 do
		textLabel4[k] = v24
	end

	textLabel4.Parent = frame7
	local v24 = {
		Name = "StartButton",
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = color6,
		AutoButtonColor = false,
		Position = UDim2.new(0.5, 0, 0, 30),
		Size = UDim2.fromOffset(220, 44),
		Font = Enum.Font.GothamBold,
		Text = "开始模拟对战",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 15,
		ZIndex = 4
	}
	local textButton2 = Instance.new("TextButton")

	for k, v25 in v24 do
		textButton2[k] = v25
	end

	textButton2.Parent = frame7
	corner(textButton2, 10) -- equivalent call inferred; original call site unknown
	textButton2.MouseEnter:Connect(function()
		TweenService:Create(textButton2, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(78, 130, 245)
		}):Play()
	end)
	textButton2.MouseLeave:Connect(function()
		TweenService:Create(textButton2, tweenInfo, {
			BackgroundColor3 = color6
		}):Play()
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function showError(text: string)
		textLabel4.Text = text
		task.delay(3.5, function()
			if textLabel4.Text == text then
				textLabel4.Text = ""
			end
		end)
	end

	local v25 = {
		no_table = "暂无可用桌子，请稍后再试",
		already_seated = "你已经在对局中",
		no_character = "角色加载中，请稍候",
		invalid_role = "角色配置错误",
		invalid_board_size = "棋盘尺寸需为 10-100 之间的数字"
	}
	ButtonActions.Bind(textButton2, function()
		local size = textButton2.Size
		TweenService:Create(textButton2, TweenInfo.new(0.06), {
			Size = UDim2.new(size.X.Scale, size.X.Offset * 0.93, size.Y.Scale, size.Y.Offset * 0.93)
		}):Play()
		task.delay(0.12, function()
			TweenService:Create(textButton2, TweenInfo.new(0.1), {
				Size = size
			}):Play()
		end)
		local text = tonumber(textBox.Text)

		if text == nil or text < 10 or text > 100 then
			textLabel4.Text = "棋盘尺寸需为 10-100 之间的数字"
			local v26 = "棋盘尺寸需为 10-100 之间的数字"
			task.delay(3.5, function()
				if textLabel4.Text == v26 then
					textLabel4.Text = ""
				end
			end)
		else
			local v26

			if v20 then
				v26 = { slotSide.roleId, slotSide2.roleId }
			else
				v26 = { slotSide.roleId }
			end

			local v27

			if v20 then
				v27 = { slotSide3.roleId, slotSide4.roleId }
			else
				v27 = { slotSide3.roleId }
			end

			local v28, v29 = SimBattleClient.startBattle(v26, v27, text, {
				showHealth = showHealth
			})

			if v28 then
				SimBattlePanelService.close()
				return
			end

			showError(v25[v29 or ""] or "开战失败，请重试") -- equivalent call inferred; original call site unknown
		end
	end)

	if not flag and typeof(SimBattleClient.onEnded) == "function" then
		flag = true
		SimBattleClient.onEnded(function()
			task.wait(0.6)
			SimBattlePanelService.open()
		end)
	end

	return {
		root = frame,
		errorLabel = textLabel4,
		setVisible = function(visible: boolean)
			frame.Visible = visible

			if visible then
				textLabel4.Text = ""
			end
		end
	}
end

local v3 = false
local v4 = nil

function SimBattlePanelService.open()
	if not v3 then
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "SimBattlePanel"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = false
		screenGui.DisplayOrder = 50
		screenGui.Parent = playerGui
		v4 = build(screenGui)
		v3 = true
	end

	if v4 then
		v4.setVisible(true)
	end

	setBackgroundUiHidden(true)
end

function SimBattlePanelService.close()
	if v3 and v4 then
		v4.setVisible(false)
	end
end

return SimBattlePanelService