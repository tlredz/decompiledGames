local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
local Net = require(ReplicatedStorage.Packages.Net)
local Observers = require(ReplicatedStorage.Packages.Observers)
local NumberFormat = require(ReplicatedStorage.Packages.NumberFormat)
local Config = require(ReplicatedStorage.Engine.Service.Config)
local PlayerPanel = require(ReplicatedStorage.Engine.Gui.PlayerPanel)
local PlayerThumbnail = require(ReplicatedStorage.Engine.Service.PlayerThumbnail)
local PlayerTitleService = require(ReplicatedStorage.Engine.Service.PlayerTitleService)
local Trade = require(ReplicatedStorage.Engine.Gui.Trade)
local ServerTypeService = require(ReplicatedStorage.Engine.Service.ServerTypeService)
local ServerTeleport = require(ReplicatedStorage.Packages.ServerTeleport)
local remoteFunction = Net:RemoteFunction("TradeGetEligibility")
local remoteFunction2 = Net:RemoteFunction("TradeSetRequestsEnabled")
local flag = false
local v = nil
local v2 = nil
local v3 = nil
local scrollingFrame = nil
local v4 = nil
local v5 = nil
local v6 = nil
local position = nil
local v7 = {}
local visible = false
local size = nil
local count = 0
local v9 = nil
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local function scaleUDim2(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset * p, udim.Y.Scale * p, udim.Y.Offset * p)
end

local function setupButtonFeedback(data)
	local size2 = data.Size
	data.MouseEnter:Connect(function()
		local size3 = size2
		TweenService:Create(data, TweenInfo.new(0.1), {
			Size = UDim2.new(size3.X.Scale * 1.05, size3.X.Offset * 1.05, size3.Y.Scale * 1.05, size3.Y.Offset * 1.05)
		}):Play()
	end)
	data.MouseLeave:Connect(function()
		TweenService:Create(data, TweenInfo.new(0.1), {
			Size = size2
		}):Play()
	end)
end

local function textChild(instance, childName: string)
	local label = instance:FindFirstChild(childName)

	if label and label:IsA("TextLabel") then
		return label
	end

	return nil
end

local v10 = {}

local function applyTitleColor(label, instance)
	local textColor3 = v10[label]

	if not textColor3 then
		textColor3 = label.TextColor3
		v10[label] = textColor3
		label.Destroying:Connect(function()
			v10[label] = nil
		end)
	end

	local config = PlayerTitleService.getConfig((instance:GetAttribute("PlayerListTitle")))

	if config then
		textColor3 = PlayerTitleService.getColor(config)
	end

	label.TextColor3 = textColor3
end

local function revealRow(clone)
	if not GamepadSupport.IsVisible(clone) then
		return
	end

	local v11 = clone.AbsolutePosition.Y - scrollingFrame.AbsolutePosition.Y
	local v12 = v11 + clone.AbsoluteSize.Y
	local Y = scrollingFrame.AbsoluteWindowSize.Y

	if not (v11 < 0) then
		v11 = not (Y < v12) and 0 or v12 - Y
	end

	if v11 ~= 0 then
		scrollingFrame.CanvasPosition = Vector2.new(
			scrollingFrame.CanvasPosition.X,
			(math.clamp(
				scrollingFrame.CanvasPosition.Y + v11,
				0,
				(math.max(0, scrollingFrame.AbsoluteCanvasSize.Y - Y))
			))
		)
	end
end

local function updateRowNavigation()
	local buttons = {}

	for _, button in scrollingFrame:GetChildren() do
		if button:IsA("GuiButton") and button.Visible and button.Selectable then
			table.insert(buttons, button)
		end
	end

	table.sort(buttons, function(a, b)
		if a.LayoutOrder == b.LayoutOrder then
			return a.Name < b.Name
		end

		return a.LayoutOrder < b.LayoutOrder
	end)
	local firstChild = v2.Parent:FindFirstChild("顶部切换按钮")
	local button = firstChild and firstChild:FindFirstChild("交易管理按钮")
	local v11

	if button and button:IsA("GuiButton") and GamepadSupport.IsVisible(button) then
		v11 = button
	end

	for k, v12 in buttons do
		v12.NextSelectionUp = buttons[k - 1] or v11
		v12.NextSelectionDown = buttons[k + 1] or v12
	end

	if button and button:IsA("GuiButton") then
		local nextSelectionDown

		if GamepadSupport.IsVisible(v2) then
			nextSelectionDown = buttons[1]
		end

		button.NextSelectionDown = nextSelectionDown
	end

	local selectedObject = GuiService.SelectedObject

	if selectedObject and selectedObject.Parent == scrollingFrame then
		task.defer(revealRow, selectedObject)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCanvas()
	local uIListLayout = scrollingFrame:FindFirstChildOfClass("UIListLayout")

	if uIListLayout then
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uIListLayout.AbsoluteContentSize.Y)
	end

	updateRowNavigation()
end

local function sortRows()
	local v11 = {}

	for k, row in pairs(v7) do
		if k.Parent == Players then
			table.insert(v11, {
				player = k,
				row = row
			})
		end
	end

	table.sort(v11, function(a, b)
		local playerListLevel = tonumber(a.player:GetAttribute("PlayerListLevel")) or 1
		local playerListLevel2 = tonumber(b.player:GetAttribute("PlayerListLevel")) or 1

		if playerListLevel == playerListLevel2 then
			return string.lower(a.player.DisplayName) < string.lower(b.player.DisplayName)
		end

		return playerListLevel2 < playerListLevel
	end)

	for i, v12 in ipairs(v11) do
		v12.row.LayoutOrder = i
	end

	updateCanvas() -- equivalent call inferred; original call site unknown
end

local function renderRow(instance)
	local v11 = v7[instance]

	if not v11 then
		return
	end

	local label = v11:FindFirstChild("姓名")

	if not (label and label:IsA("TextLabel")) then
		label = nil
	end

	if label then
		label.Text = instance.DisplayName
		applyTitleColor(label, instance)
	end

	local label2 = v11:FindFirstChild("等级")

	if not (label2 and label2:IsA("TextLabel")) then
		label2 = nil
	end

	if label2 then
		label2.Text = tostring(tonumber(instance:GetAttribute("PlayerListLevel")) or 1)
	end

	local label3 = v11:FindFirstChild("连胜")

	if not (label3 and label3:IsA("TextLabel")) then
		label3 = nil
	end

	if label3 then
		local playerListWinStreak = tonumber(instance:GetAttribute("PlayerListWinStreak")) or 0
		label3.Visible = not visible and playerListWinStreak >= 1
		label3.Text = "🔥" .. tostring(playerListWinStreak)
	end

	local label4 = v11:FindFirstChild("钻石数量")

	if not (label4 and label4:IsA("TextLabel")) then
		label4 = nil
	end

	if label4 then
		label4.Text = NumberFormat.commaFormat(tonumber(instance:GetAttribute("PlayerListDiamonds")) or 0)
	end

	sortRows()
end

local function hideActionPanel()
	v6 = nil
	count += 1
	local v11 = count

	if v9 then
		v9:Cancel()
	end

	if not v4.Visible then
		return
	end

	v9 = TweenService:Create(v4, tweenInfo2, {
		Size = UDim2.new(0, 0, 0, 0)
	})
	v9.Completed:Connect(function(p)
		if p ~= Enum.PlaybackState.Completed or count ~= v11 then
			return
		end

		v4.Visible = false
		v4.Size = size
		v9 = nil
	end)
	v9:Play()
end

local function showActionPanel()
	count += 1

	if v9 then
		v9:Cancel()
	end

	if v4.Visible then
		v4.Size = size
		return
	end

	v4.Visible = true
	v4.Size = UDim2.new(0, 0, 0, 0)
	v9 = TweenService:Create(v4, tweenInfo, {
		Size = size
	})
	v9:Play()
end

local function positionActionPanel(p)
	local v11 = p.AbsolutePosition.Y - v2.AbsolutePosition.Y
	local Y = v4.AnchorPoint.Y
	local Y2 = v4.AbsoluteSize.Y
	local v12 = Y * Y2
	local v13 = math.clamp(v11, v12, (math.max(v12, v2.AbsoluteSize.Y - (1 - Y) * Y2)))
	v4.Position = UDim2.new(position.X.Scale, position.X.Offset, 0, v13)
end

local function refreshActionPanel()
	local v11 = v6

	if not v11 or v11.Parent ~= Players then
		hideActionPanel()
		return
	end

	local label = v4:FindFirstChild("姓名")

	if not (label and label:IsA("TextLabel")) then
		label = nil
	end

	if label then
		label.Text = v11.DisplayName
		applyTitleColor(label, v11)
	end

	local label2 = v4:FindFirstChild("账号")

	if not (label2 and label2:IsA("TextLabel")) then
		label2 = nil
	end

	if label2 then
		label2.Text = "@" .. v11.Name
	end

	local v12 = v4:WaitForChild("玩家头像")
	PlayerThumbnail.applyAsync(v12, v11.UserId)
	local scrollingFrame2 = v4:WaitForChild("ScrollingFrame")
	local v13 = scrollingFrame2:WaitForChild("交易")
	local v14 = scrollingFrame2:WaitForChild("无法交易颜色")

	if v11 ~= Players.LocalPlayer then
		task.spawn(function()
			local success, result = pcall(function()
				return remoteFunction:InvokeServer(v11.UserId)
			end)

			if v6 ~= v11 then
				return
			end

			if success then
				if typeof(result) == "table" then
					success = result.ok == true
				else
					success = false
				end
			end

			v13.Visible = success
			v14.Visible = not success
		end)
		return
	end

	v13.Visible = false
	v14.Visible = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function selectPlayer(p)
	local v11 = v7[p]

	if not v11 then
		return
	end

	if v6 == p then
		hideActionPanel()
		return
	end

	v6 = p
	positionActionPanel(v11)
	showActionPanel()
	refreshActionPanel()
end

local function addPlayer(instance)
	if v7[instance] then
		return
	end

	local clone = v5:Clone()
	clone.Name = tostring(instance.UserId)
	clone.Visible = true
	clone.Active = true
	clone.Selectable = true
	clone:SetAttribute("PlayerListGenerated", true)
	clone.Parent = scrollingFrame
	v7[instance] = clone
	ButtonActions.Bind(clone, function()
		if GamepadSupport.CanActivate(clone) then
			selectPlayer(instance) -- equivalent call inferred; original call site unknown
		end
	end)
	clone.SelectionGained:Connect(function()
		revealRow(clone)
	end)
	local v11 = Observers.observeAttribute(instance, "PlayerListLevel", function()
		renderRow(instance)
	end)
	local v12 = Observers.observeAttribute(instance, "PlayerListWinStreak", function()
		renderRow(instance)
	end)
	local v13 = Observers.observeAttribute(instance, "PlayerListDiamonds", function()
		renderRow(instance)
	end)
	local v14 = Observers.observeAttribute(instance, "PlayerListTitle", function()
		renderRow(instance)

		if v6 == instance then
			refreshActionPanel()
		end
	end)
	local v15 = Observers.observeAttribute(instance, "TradeRequestsEnabled", function()
		if v6 == instance then
			refreshActionPanel()
		end
	end)
	local displayNameChangedConnection = instance:GetPropertyChangedSignal("DisplayName"):Connect(function()
		renderRow(instance)

		if v6 == instance then
			refreshActionPanel()
		end
	end)
	renderRow(instance)
	return function()
		v11()
		v12()
		v13()
		v14()
		v15()
		displayNameChangedConnection:Disconnect()
		v7[instance] = nil

		if v6 == instance then
			hideActionPanel()
		end

		local v16 = GuiService.SelectedObject == clone
		local nextSelectionDown = clone.NextSelectionDown

		if nextSelectionDown == clone then
			nextSelectionDown = clone.NextSelectionUp
		end

		clone:Destroy()
		updateCanvas() -- equivalent call inferred; original call site unknown

		if v16 then
			GuiService.SelectedObject = nextSelectionDown
		end
	end
end

local function isTradeUnlocked()
	local allowTradeLvl = Config.misc and Config.misc.allowTradeLvl
	local v11 = (typeof(allowTradeLvl) ~= "number" or not (allowTradeLvl >= 1)) and 10 or math.floor(allowTradeLvl)
	local playerListLevel = Players.LocalPlayer:GetAttribute("PlayerListLevel")
	return typeof(playerListLevel) == "number" and v11 <= playerListLevel
end

local function setTradeRequestPreference(flag2: boolean?)
	local success, result = pcall(function()
		return remoteFunction2:InvokeServer(flag2)
	end)

	if success and typeof(result) == "table" then
		if result.ok == false then
			Trade.ShowRequestFailure({
				reason = result.reason == "ineligible" and "selfLevel" or result.reason
			})
		end

		local enabled = result.enabled == true
		local v11 = v3:WaitForChild("交易开关")
		local v12 = v11:WaitForChild("开按钮")
		local v13 = v11:WaitForChild("关按钮")
		v12.Visible = enabled
		v13.Visible = not enabled
	elseif flag2 ~= nil then
		Trade.ShowRequestFailure(nil)
	end
end

return {
	Init = function()
		if flag then
			return
		end

		flag = true
		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		end)
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		v = playerGui:WaitForChild("右侧菜单")
		local v11 = v:WaitForChild("右侧区域")
		v2 = v11:WaitForChild("大厅玩家列表")
		v3 = v11:WaitForChild("交易管理")
		scrollingFrame = v2:WaitForChild("ScrollingFrame")
		scrollingFrame.Active = true
		scrollingFrame.Selectable = false
		scrollingFrame.Visible = true
		v4 = v2:WaitForChild("二级面板")
		position = v4.Position
		size = v4.Size
		v4.Visible = false
		local textButton = scrollingFrame:FindFirstChildWhichIsA("TextButton")
		assert(textButton and textButton:IsA("TextButton"), "[PlayerList] 缺少玩家行模板")
		v5 = textButton

		for _, button in ipairs(scrollingFrame:GetChildren()) do
			if button:IsA("TextButton") then
				button.Visible = false
			end
		end

		v5.Visible = false
		v5.Selectable = true
		v2:GetPropertyChangedSignal("Visible"):Connect(updateRowNavigation)
		visible = ServerTeleport.getServerType() == ServerTypeService.TRADE_POOL_NAME
		local label = v5:FindFirstChild("等级")

		if not (label and label:IsA("TextLabel")) then
			label = nil
		end

		local label2 = v5:FindFirstChild("连胜")

		if not (label2 and label2:IsA("TextLabel")) then
			label2 = nil
		end

		local guiObject = v5:FindFirstChild("钻石图标")
		local label3 = v5:FindFirstChild("钻石数量")

		if not (label3 and label3:IsA("TextLabel")) then
			label3 = nil
		end

		if label then
			label.Visible = not visible
		end

		if label2 and visible then
			label2.Visible = false
		end

		if guiObject and guiObject:IsA("GuiObject") then
			guiObject.Visible = visible
		end

		if label3 then
			label3.Visible = visible
		end

		local uIListLayout = scrollingFrame:FindFirstChildOfClass("UIListLayout")

		if uIListLayout then
			uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				updateCanvas() -- equivalent call inferred; original call site unknown
			end)
		end

		local scrollingFrame2 = v4:WaitForChild("ScrollingFrame")
		local v12 = scrollingFrame2:WaitForChild("库存")
		local v13 = scrollingFrame2:WaitForChild("交易")
		local v14 = scrollingFrame2:WaitForChild("无法交易颜色")
		v12.Active = true
		v12.Selectable = true
		v13.Selectable = true
		v14.Selectable = true

		if scrollingFrame2:IsA("GuiObject") then
			scrollingFrame2.Selectable = false
		end

		v13.Active = true
		v14.Active = true
		ButtonActions.Bind(v12, function()
			if v6 then
				PlayerPanel.OpenPlayer(v6.UserId)
			end
		end)

		local function requestTrade()
			if v6 then
				Trade.Request(v6.UserId)
			end
		end

		ButtonActions.Bind(v13, requestTrade)
		ButtonActions.Bind(v14, requestTrade)
		local v15 = v3:WaitForChild("交易开关")
		local v16 = v15:WaitForChild("开按钮")
		local v17 = v15:WaitForChild("关按钮")
		v16.Active = true
		v17.Active = true
		setupButtonFeedback(v16)
		setupButtonFeedback(v17)
		setupButtonFeedback(v12)
		setupButtonFeedback(v13)
		ButtonActions.Bind(v16, function()
			setTradeRequestPreference(false)
		end)
		ButtonActions.Bind(v17, function()
			local allowTradeLvl = Config.misc and Config.misc.allowTradeLvl
			local v18 = (typeof(allowTradeLvl) ~= "number" or not (allowTradeLvl >= 1)) and 10 or math.floor(allowTradeLvl)
			local playerListLevel = Players.LocalPlayer:GetAttribute("PlayerListLevel")
			local v19

			if typeof(playerListLevel) == "number" then
				v19 = v18 <= playerListLevel
			else
				v19 = false
			end

			if v19 then
				setTradeRequestPreference(true)
			else
				Trade.ShowQualificationRequired()
			end
		end)
		setTradeRequestPreference(nil)
		local UserInputService = game:GetService("UserInputService")
		UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch or not (v6 and GamepadSupport.IsVisible(v4)) then
				return
			end

			for _, parent in playerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y) do
				if parent == v4 or parent:IsDescendantOf(v4) then
					return
				end

				while parent and parent.Parent ~= scrollingFrame do
					parent = parent.Parent
				end

				if parent and parent:GetAttribute("PlayerListGenerated") == true then
					return
				end
			end

			hideActionPanel()
		end)
		Observers.observePlayer(addPlayer)
	end
}