local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)
local CommandSchema = require(ReplicatedStorage.Engine.Service.AdminPanel.CommandSchema)
local flag = false

local function makeLabel(parent, text: string, size: UDim2, position: UDim2, textSize: number, textColor: Color3)
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = size
	textLabel.Position = position
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = textColor
	textLabel.TextSize = textSize
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextScaled = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = parent
	return textLabel
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTextInset(parent, p: number)
	local v = parent:FindFirstChildOfClass("UIPadding")

	if not v then
		v = Instance.new("UIPadding")
		v.Name = "文本内边距"
		v.Parent = parent
	end

	v.PaddingLeft = UDim.new(p, 0)
end

local function setIconText(parent, text: string, text2: string)
	parent.Text = ""
	local designTextSize = parent:GetAttribute("DesignTextSize") or parent.TextSize
	local uDim = UDim2.fromScale(0.1, 1)
	local uDim2 = UDim2.fromScale(0.04, 0)
	local textColor3 = parent.TextColor3
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = uDim
	textLabel.Position = uDim2
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text2
	textLabel.TextColor3 = textColor3
	textLabel.TextSize = designTextSize
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextScaled = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Parent = parent
	textLabel.Name = "图标"
	textLabel.Font = parent.Font
	textLabel.ZIndex = parent.ZIndex
	local uDim3 = UDim2.fromScale(0.8, 1)
	local uDim4 = UDim2.fromScale(0.16, 0)
	local textColor32 = parent.TextColor3
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Size = uDim3
	textLabel2.Position = uDim4
	textLabel2.BackgroundTransparency = 1
	textLabel2.Text = text
	textLabel2.TextColor3 = textColor32
	textLabel2.TextSize = designTextSize
	textLabel2.Font = Enum.Font.Gotham
	textLabel2.TextScaled = true
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	textLabel2.Parent = parent
	textLabel2.Name = "本地化文本"
	textLabel2.Font = parent.Font
	textLabel2.ZIndex = parent.ZIndex
	textLabel2.TextWrapped = parent.TextWrapped
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveCandidateGetter(param)
	local param2 = CommandSchema.param(param)
	local candidates = param2.candidates or param2.choices
	local v = param2.type == "player" and "playerName" or candidates

	if v then
		return function()
			return CommandSchema.candidates(v)
		end
	end

	return nil
end

local function filterCandidates(text: string, list)
	if text == "" then
		return list
	end

	local lower = text:lower()
	local v = {}

	for i, v2 in ipairs(list) do
		local lower2 = v2:lower()
		local score

		if lower2 == lower then
			score = 0
		elseif lower2:sub(1, #lower) == lower then
			score = 1
		elseif lower2:find(lower, 1, true) then
			score = 2
		else
			score = nil
		end

		if score then
			table.insert(v, {
				value = v2,
				score = score,
				index = i
			})
		end
	end

	table.sort(v, function(a, b)
		if a.score == b.score then
			return a.index < b.index
		end

		return a.score < b.score
	end)
	local result = {}

	for _, v2 in ipairs(v) do
		table.insert(result, v2.value)
	end

	return result
end

local function addAutocomplete(instance, parent, candidateGetter)
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "参数候选列表"
	scrollingFrame.Position = UDim2.fromOffset(0, 0)
	scrollingFrame.Size = UDim2.fromScale(0, 0.22)
	scrollingFrame.BackgroundColor3 = Color3.fromRGB(38, 41, 49)
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 4
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.CanvasSize = UDim2.new()
	scrollingFrame.Visible = false
	scrollingFrame.ZIndex = 10
	scrollingFrame.Parent = parent
	local uICorner = Instance.new("UICorner", scrollingFrame)
	uICorner.Name = "圆角"
	uICorner.CornerRadius = UDim.new(0.06, 0)
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "候选排列"
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = scrollingFrame
	local v = {}

	local function reposition()
		local absolutePosition = parent.AbsolutePosition
		local absoluteSize = parent.AbsoluteSize

		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return
		end

		local absolutePosition2 = instance.AbsolutePosition
		local absoluteSize2 = instance.AbsoluteSize
		local v2 = (absolutePosition2.Y - absolutePosition.Y + absoluteSize2.Y) / absoluteSize.Y + 0.004
		local v3 = math.min(0.22, (math.max(0.05, 1 - v2)))
		scrollingFrame.Position = UDim2.fromScale((absolutePosition2.X - absolutePosition.X) / absoluteSize.X, v2)
		scrollingFrame.Size = UDim2.fromScale(absoluteSize2.X / absoluteSize.X, v3)
		scrollingFrame.ScrollBarThickness = math.max(1, (math.floor(absoluteSize.Y * 0.006)))
	end

	local function refresh()
		for _, button in ipairs(scrollingFrame:GetChildren()) do
			if button:IsA("GuiButton") then
				button:Destroy()
			end
		end

		local v2 = filterCandidates(instance.Text, v)
		scrollingFrame.Visible = instance:IsFocused() and #v2 > 0

		for i, text in ipairs(v2) do
			local textButton = Instance.new("TextButton")
			textButton.Name = "候选项"
			textButton.Size = UDim2.fromScale(0.97, 0.28)
			textButton.BackgroundTransparency = 1
			textButton.Text = text
			textButton.TextColor3 = Color3.fromRGB(235, 235, 245)
			textButton.TextSize = 24
			textButton.TextScaled = true
			textButton.TextWrapped = true
			textButton.Font = Enum.Font.Gotham
			textButton.LayoutOrder = i
			textButton.ZIndex = 11
			textButton.Parent = scrollingFrame
			local text2 = text
			ButtonActions.Bind(textButton, function()
				instance.Text = text2
				scrollingFrame.Visible = false
			end)
		end
	end

	instance.Focused:Connect(function()
		v = candidateGetter()
		reposition()
		refresh()
	end)
	instance:GetPropertyChangedSignal("Text"):Connect(function()
		if instance:IsFocused() then
			refresh()
		end
	end)
	instance.Destroying:Connect(function()
		scrollingFrame:Destroy()
	end)
	instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(reposition)
	instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(reposition)
	instance.FocusLost:Connect(function()
		task.delay(0.15, function()
			if scrollingFrame.Parent then
				scrollingFrame.Visible = false
			end
		end)
	end)
end

local function configureResponsive(folder)
	local function updateText(instance)
		if not (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox")) then
			return
		end

		local designTextSize = instance:GetAttribute("DesignTextSize") or instance.TextSize
		instance.AutoLocalize = true
		instance:SetAttribute("DesignTextSize", designTextSize)
		instance.TextScaled = true
		local v = instance:FindFirstChildOfClass("UITextSizeConstraint")

		if not v then
			v = Instance.new("UITextSizeConstraint")
			v.Name = "字号约束"
			v.MinTextSize = 1
			v.Parent = instance
		end

		v.MaxTextSize = math.max(1, (math.floor(designTextSize * folder.AbsoluteSize.Y / 666.67)))
	end

	local function refresh()
		for _, scrollingFrame in folder:GetDescendants() do
			updateText(scrollingFrame)

			if scrollingFrame:IsA("ScrollingFrame") then
				scrollingFrame.ScrollBarThickness = math.max(1, (math.floor(folder.AbsoluteSize.Y * 0.007)))
			end
		end
	end

	folder:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
	folder.DescendantAdded:Connect(function(guiBase2d)
		if guiBase2d:IsA("GuiBase2d") then
			guiBase2d.AutoLocalize = true
		end

		updateText(guiBase2d)
	end)
	refresh()
end

return {
	init = function(instance, items, callback, _)
		if flag then
			return
		end

		flag = true
		local clone = instance:Clone()
		clone.AutoLocalize = true

		for _, guiBase2d in clone:GetDescendants() do
			if guiBase2d:IsA("GuiBase2d") then
				guiBase2d.AutoLocalize = true
			end
		end

		clone.Name = "管理员指令界面"
		clone.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		local parent = clone:WaitForChild("管理员面板")
		parent.Visible = false
		configureResponsive(parent)
		local parent2 = parent:WaitForChild("全局搜索")
		parent2.PlaceholderText = "Search commands…"
		setTextInset(parent2, 0.012) -- equivalent call inferred; original call site unknown
		local parent3 = parent:WaitForChild("指令列表")
		local parent4 = parent:WaitForChild("分类列表")
		local parent5 = parent:WaitForChild("详情区")
		local v6 = parent5:WaitForChild("指令标题")
		local v7 = parent5:WaitForChild("指令说明")
		local v8 = parent5:WaitForChild("执行结果")
		local v9 = parent5:WaitForChild("执行按钮")
		local v10 = parent3:WaitForChild("指令模板")
		local v11 = parent4:WaitForChild("分类模板")
		local v12 = parent5:WaitForChild("参数模板")
		local v13 = parent:WaitForChild("受益人选择")
		local parent6 = parent:WaitForChild("受益人下拉列表")
		local localPlayer = Players.LocalPlayer
		local list = CommandSchema.list(items)
		local v15 = {}
		local v16 = nil
		local v17 = {}
		local v18 = {}
		local v19 = {}
		local v20 = false
		local v21 = {}
		local name = "All Commands"
		local clonesByName = {}
		local v22 = nil

		for _, item in items do
			local category = item.category or "Other"

			if not v15[category] then
				v15[category] = {
					name = category,
					emoji = item.categoryEmoji or "🔧",
					order = item.categoryOrder or 999
				}
			end
		end

		local v23 = {}

		for _, v24 in v15 do
			table.insert(v23, v24)
		end

		table.sort(v23, function(a, b)
			if a.order == b.order then
				return a.name < b.name
			end

			return a.order < b.order
		end)
		table.insert(v23, 1, {
			name = "All Commands",
			emoji = "📋",
			order = 0
		})

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hideCandidates()
			for _, child in parent:GetChildren() do
				if child.Name == "参数候选列表" then
					child.Visible = false
				end
			end
		end

		local function saveDraft()
			if not v16 then
				return
			end

			local textsByName = {}

			for _, v24 in v17 do
				textsByName[v24.name] = v24.input.Text
			end

			v18[v16] = textsByName
		end

		local function selectCommand(value: string?)
			saveDraft()
			hideCandidates() -- equivalent call inferred; original call site unknown

			for _, v24 in v17 do
				v24.container:Destroy()
			end

			table.clear(v17)
			v16 = value
			v13.Visible = value ~= nil and items[value].beneficiary == true
			parent6.Visible = false
			parent5.CanvasPosition = Vector2.zero
			v9.Visible = value ~= nil
			v6.Text = value or "No matching commands"
			v7.Text = not value and "Try another search or clear the search box." or items[value].desc or ""

			for _, v26 in v19 do
				v26.pick.BackgroundTransparency = v26.name == value and 0 or 1
				v26.pick.BackgroundColor3 = Color3.fromRGB(57, 61, 73)
			end

			if not value then
				return
			end

			local item = items[value]
			local count = 0

			for _, v26 in CommandSchema.paramNames(item) do
				if v26 == item.beneficiaryParam then
					continue
				end

				count += 1
				local param = CommandSchema.param(item.params[v26])
				local clone2 = v12:Clone()
				clone2.Name = "参数_" .. v26
				clone2.LayoutOrder = count + 10
				clone2.Visible = true
				clone2.Parent = parent5
				clone2["参数名称"].Text = v26
				local input = clone2["输入框"]
				input.Text = (v18[value] or {})[v26] or ""
				local placeholderText

				if param.default == nil then
					placeholderText = "Enter " .. v26
				else
					placeholderText = "Default: " .. tostring(param.default)
				end

				input.PlaceholderText = placeholderText
				local candidateGetter = resolveCandidateGetter(item.params[v26]) -- equivalent call inferred; original call site unknown

				if candidateGetter then
					addAutocomplete(input, parent, candidateGetter)
				end

				table.insert(v17, {
					name = v26,
					input = input,
					container = clone2
				})
			end

			v9.Text = v20 and "Running…" or v21[value] and "Stop" or "Run"
		end

		local function refreshList()
			local v24 = parent2.Text:lower():match("^%s*(.-)%s*$") or ""
			local v25 = nil
			local v26 = false

			for _, v27 in v19 do
				local item = items[v27.name]
				local category = item.category or "Other"
				local visible

				if v24 == "" then
					visible = name == "All Commands" or category == name
				else
					visible = v27.name:lower():find(v24, 1, true) ~= nil or (item.desc or ""):lower():find(v24, 1, true) ~= nil
				end

				v27.row.Visible = visible
				v27.tag.Visible = v24 ~= ""
				local pick = v27.pick
				local size

				if v24 == "" then
					size = UDim2.fromScale(0.96, 0.9)
				else
					size = UDim2.fromScale(0.96, 0.58)
				end

				pick.Size = size

				if not visible then
					continue
				end

				v25 = v25 or v27.name

				if v27.name == v16 then
					v26 = true
				end
			end

			for k, v27 in clonesByName do
				v27.BackgroundTransparency = k == name and 0 or 1
			end

			parent3.CanvasPosition = Vector2.zero

			if not v26 then
				selectCommand(v25)
			end
		end

		for k, v24 in list do
			local name2 = v24.name
			local clone2 = v10:Clone()
			clone2.Name = "指令_" .. name2
			clone2.LayoutOrder = k
			clone2.Visible = true
			clone2.Parent = parent3
			local pick = clone2["选择按钮"]
			pick.Text = name2
			setTextInset(pick, 0.025) -- equivalent call inferred; original call site unknown
			local tag = clone2["分类标签"]
			tag.TextColor3 = Color3.fromRGB(166, 172, 186)
			setIconText(tag, items[name2].category or "Other", items[name2].categoryEmoji or "")
			table.insert(v19, {
				name = name2,
				row = clone2,
				pick = pick,
				tag = tag
			})
			ButtonActions.Bind(pick, function()
				selectCommand(name2)
			end)
		end

		for k, v24 in v23 do
			local clone2 = v11:Clone()
			clone2.Name = "分类_" .. v24.name
			setIconText(clone2, v24.name, v24.emoji)
			clone2.LayoutOrder = k
			clone2.Visible = true
			clone2.Parent = parent4
			clonesByName[v24.name] = clone2
			local v25 = v24
			ButtonActions.Bind(clone2, function()
				name = v25.name
				parent2.Text = ""
				refreshList()
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateTargetText()
			v13.Text = "  Target: " .. (localPlayer == Players.LocalPlayer and "Self" or localPlayer.Name) .. "  ▼"
		end

		local function refreshTargets()
			for _, button in parent6:GetChildren() do
				if button:IsA("TextButton") then
					button:Destroy()
				end
			end

			local players = Players:GetPlayers()
			table.sort(players, function(a, b)
				if a == b then
					return false
				end

				return a == Players.LocalPlayer or b ~= Players.LocalPlayer and a.Name:lower() < b.Name:lower()
			end)

			for k, player in players do
				local textButton = Instance.new("TextButton")
				textButton.Name = "受益人_" .. player.Name
				textButton.Size = UDim2.fromScale(0.97, 0.14)
				textButton.BackgroundTransparency = 1
				textButton.Text = player.DisplayName .. " (@" .. player.Name .. ")"
				textButton.TextColor3 = Color3.fromRGB(242, 243, 245)
				textButton.TextScaled = true
				textButton.Font = Enum.Font.Gotham
				textButton.ZIndex = 21
				textButton.LayoutOrder = k
				textButton.Parent = parent6
				local v24 = player
				ButtonActions.Bind(textButton, function()
					if v24.Parent ~= Players then
						return
					end

					localPlayer = v24
					updateTargetText() -- equivalent call inferred; original call site unknown
					parent6.Visible = false
				end)
			end
		end

		ButtonActions.Bind(v13, function()
			hideCandidates() -- equivalent call inferred; original call site unknown
			refreshTargets()
			parent6.Visible = not parent6.Visible
		end)
		Players.PlayerAdded:Connect(refreshTargets)
		Players.PlayerRemoving:Connect(function(player)
			if localPlayer == player then
				localPlayer = Players.LocalPlayer
				updateTargetText() -- equivalent call inferred; original call site unknown
				v8.Text = "The target left. Target reset to Self."
			end

			task.defer(refreshTargets)
		end)
		ButtonActions.Bind(v9, function()
			if v20 or not v16 then
				return
			end

			local v24 = v16
			local item = items[v24]
			local v25 = {}

			for _, v26 in v17 do
				if v26.input.Text ~= "" then
					v25[v26.name] = v26.input.Text
				end
			end

			local v26 = localPlayer

			if item.beneficiary and v26.Parent ~= Players then
				v8.Text = "The target left. Choose another player."
				return
			end

			if item.beneficiaryParam then
				v25[item.beneficiaryParam] = v26.Name
			end

			if item.toggle then
				v25.enabled = not v21[v24]
			end

			v20 = true
			v9.Text = "Running…"
			hideCandidates() -- equivalent call inferred; original call site unknown
			parent6.Visible = false
			v8.TextColor3 = Color3.fromRGB(210, 215, 225)
			v8.Text = v24 .. ": Running…"
			local v28

			if item.beneficiary then
				v28 = v26.UserId
			end

			local success, result = pcall(callback, v24, v25, v28)
			local v29 = not success and {
				ok = false,
				message = "Could not complete the command."
			} or result
			local v30 = type(v29) ~= "table" and {
				ok = false,
				message = "No result received."
			} or v29

			if v30.ok and item.toggle then
				v21[v24] = not v21[v24]
			end

			v20 = false
			v9.Text = v16 and v21[v16] and "Stop" or "Run"
			v8.Text = v24 .. (not item.beneficiary and "" or " → @" .. v26.Name) .. ": " .. tostring(v30.message)
			local v31 = v8
			local textColor

			if v30.ok then
				textColor = Color3.fromRGB(120, 235, 160)
			else
				textColor = Color3.fromRGB(255, 135, 135)
			end

			v31.TextColor3 = textColor

			if v30.ok and item.hideUIAfterExec and v22 then
				v22:deselect()
			end
		end)
		parent2:GetPropertyChangedSignal("Text"):Connect(refreshList)
		updateTargetText() -- equivalent call inferred; original call site unknown
		refreshList()
		v22 = TopbarPlus.new()
		v22:setLabel("🕹️")
		v22:setLeft()
		v22:setOrder(10)
		v22.selected:Connect(function()
			parent.Visible = true
		end)
		v22.deselected:Connect(function()
			parent.Visible = false
			parent6.Visible = false
			hideCandidates() -- equivalent call inferred; original call site unknown
		end)
		local rightShift = Enum.KeyCode.RightShift
		v22:bindToggleKey(rightShift)
		ButtonActions.Bind(parent["关闭按钮"], function()
			v22:deselect()
		end)
		ContextActionService:BindAction("AdminPanelClose", function(_, p)
			if p ~= Enum.UserInputState.Begin or not parent.Visible then
				return Enum.ContextActionResult.Pass
			end

			v22:deselect()
			return Enum.ContextActionResult.Sink
		end, false, Enum.KeyCode.Escape)
	end
}