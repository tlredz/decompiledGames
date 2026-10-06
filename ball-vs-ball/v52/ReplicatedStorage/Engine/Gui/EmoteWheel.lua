local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local WheelConfig = require(script.WheelConfig)
local WheelAnimator = require(script.WheelAnimator)
local WheelInventory = require(script.WheelInventory)
local EmoteMountService = require(ReplicatedStorage.Engine.Service.EmoteMountService)
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
local GamepadPages = require(ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
local ButtonHints = require(ReplicatedStorage.Engine.Service.GamepadSupport.ButtonHints)
local EmoteWheel = {}
local v = nil

function EmoteWheel.Init()
	local v2 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("表情轮盘")
	local v3 = WheelAnimator.new(v2)
	local v4 = WheelInventory.new(v2, v3)
	local flag = false
	local v5 = false
	local inputChangedConnection = nil
	local v6 = false
	local v7 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getCenter()
		local root = v3.root
		return root.AbsolutePosition + root.AbsoluteSize * 0.5
	end

	local function getPointedSlot(p)
		local root = v3.root
		local v8 = p - getCenter()
		local magnitude = v8.Magnitude
		local v9 = math.min(root.AbsoluteSize.X, root.AbsoluteSize.Y) * 0.5

		if v9 <= 0 or magnitude < v9 * WheelConfig.DeadZoneRatio then
			return nil
		end

		local v10 = math.deg((math.atan2(v8.X, -v8.Y)))

		if v10 < 0 then
			v10 += 360
		end

		return math.floor((v10 + WheelConfig.AnglePerSlot / 2) % 360 / WheelConfig.AnglePerSlot) + 1
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateHighlightFromMouse(p)
		v3:SetHighlight((getPointedSlot(p)))
	end

	local function openWheel()
		if flag then
			return
		end

		flag = true
		v2.Enabled = true
		v3:Open()

		if inputChangedConnection then
			inputChangedConnection:Disconnect()
		end

		inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			if v5 then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseMovement then
				updateHighlightFromMouse(Vector2.new(input.Position.X, input.Position.Y)) -- equivalent call inferred; original call site unknown
			elseif input.UserInputType == Enum.UserInputType.Touch and v6 then
				updateHighlightFromMouse(Vector2.new(input.Position.X, input.Position.Y)) -- equivalent call inferred; original call site unknown
			end
		end)
		updateHighlightFromMouse(UserInputService:GetMouseLocation()) -- equivalent call inferred; original call site unknown
	end

	local function closeWheel(p)
		if not flag then
			return
		end

		flag = false

		if v5 then
			v5 = false
			v4:Close()
			p = false
		end

		if inputChangedConnection then
			inputChangedConnection:Disconnect()
			inputChangedConnection = nil
		end

		local highlighted = v3.highlighted

		if p and highlighted and WheelConfig.SlotContents[highlighted] then
			v3:PulseConfirm(highlighted)
			EmoteMountService.client.playWheelSlot(highlighted)
		end

		v3:Close()
		task.delay(WheelConfig.CloseDuration, function()
			if not flag then
				v2.Enabled = false
			end
		end)
	end

	v = closeWheel

	-- equivalent calls inferred from this helper; original call sites unknown
	local function requestClose()
		if not v7 then
			closeWheel(true)
			return
		end

		v7 = false
		closeWheel(false)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setEditing(flag2: boolean)
		if v5 == flag2 then
			return
		end

		v5 = flag2

		if flag2 then
			v4:Open()
		else
			v4:Close()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function selectSlot(p: number)
		v3:SetHighlight(p)

		if WheelConfig.SlotContents[p] then
			requestClose() -- equivalent call inferred; original call site unknown
		else
			setEditing(true) -- equivalent call inferred; original call site unknown
		end
	end

	local children = {}

	for i = 1, WheelConfig.SlotCount do
		local child = v3.root:WaitForChild("槽位选择按钮" .. i)
		children[i] = child
		local v8 = i
		ButtonActions.Bind(child, function()
			if v5 then
				v3:SetHighlight(v8)
				return
			end

			selectSlot(v8) -- equivalent call inferred; original call site unknown
		end)
		local v9 = i
		child.SelectionGained:Connect(function()
			if flag then
				v3:SetHighlight(v9)
			end
		end)
	end

	for k, v8 in children do
		local v9 = children[(k - 2) % #children + 1]
		local v10 = children[k % #children + 1]
		v8.NextSelectionLeft = v9
		v8.NextSelectionUp = v9
		v8.NextSelectionRight = v10
		v8.NextSelectionDown = v10
	end

	GamepadPages.Observe(v2["屏幕居中层"], {
		available = function()
			return flag
		end,
		defaultButton = children[1]
	})
	GamepadPages.Observe(v2["库存"], {
		available = function()
			return flag and v5
		end
	})
	local RunService = game:GetService("RunService")
	RunService.Heartbeat:Connect(function()
		for _, v8 in children do
			v8.Visible = GamepadSupport.IsGamepad() and flag
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function toggleWheel()
		if not flag then
			openWheel()
			return
		end

		requestClose() -- equivalent call inferred; original call site unknown
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not flag then
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard then
			for k, slotKeyCode in pairs(WheelConfig.SlotKeyCodes) do
				if input.KeyCode ~= slotKeyCode then
					continue
				end

				v3:SetHighlight(k)
				return
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			local pointedSlot = getPointedSlot(Vector2.new(input.Position.X, input.Position.Y))

			if not pointedSlot then
				return
			end

			if v5 then
				v3:SetHighlight(pointedSlot)
				return
			end

			selectSlot(pointedSlot) -- equivalent call inferred; original call site unknown
		elseif input.UserInputType == Enum.UserInputType.Touch then
			v6 = true
			local pointedSlot = getPointedSlot(Vector2.new(input.Position.X, input.Position.Y))

			if pointedSlot then
				v3:SetHighlight(pointedSlot)
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch or not v6 then
			return
		end

		v6 = false

		if not flag or v5 then
			return
		end

		local highlighted = v3.highlighted

		if highlighted then
			selectSlot(highlighted) -- equivalent call inferred; original call site unknown
		else
			requestClose() -- equivalent call inferred; original call site unknown
		end
	end)
	local v8 = v2["屏幕居中层"]["编辑按钮"]
	ButtonHints.Shortcut(v8, "X")
	ButtonActions.Bind(v8, function()
		if not flag then
			return
		end

		setEditing(not v5) -- equivalent call inferred; original call site unknown
	end)
	local v9 = v2["库存"]["关闭按钮"]
	ButtonActions.Bind(v9, function()
		if not flag then
			return
		end

		setEditing(false) -- equivalent call inferred; original call site unknown
	end)
	local v10 = v2["屏幕居中层"]["关闭按钮"]
	ButtonActions.Bind(v10, function()
		if not flag then
			return
		end

		v7 = true
		v7 = false
		closeWheel(false)
	end)
	v2.Enabled = false
	EmoteWheel.Toggle = toggleWheel
	local v11 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("界面图标"):WaitForChild("左侧按钮区"):WaitForChild("表情按钮")
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == WheelConfig.SummonKey and GamepadSupport.CanActivate(v11) then
			toggleWheel() -- equivalent call inferred; original call site unknown
		end
	end)
end

function EmoteWheel.SetTopbarEnabled(flag: boolean)
	if not flag and v then
		v(false)
	end
end

return EmoteWheel