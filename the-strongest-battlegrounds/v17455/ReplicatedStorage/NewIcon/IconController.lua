local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local HapticService = game:GetService("HapticService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VRService = game:GetService("VRService")
local VoiceChatService = game:GetService("VoiceChatService")
local LocalizationService = game:GetService("LocalizationService")
local parent = script.Parent
local TopbarPlusReference = require(parent.TopbarPlusReference)
local object = TopbarPlusReference.getObject()
local value = object and object.Value

if value and value.IconController ~= script then
	return require(value.IconController)
end

if not object then
	TopbarPlusReference.addToReplicatedStorage()
end

local IconController = {}
local Signal = require(parent.Signal)
local TopbarPlusGui = require(parent.TopbarPlusGui)
local v = {}
local v2 = false
local v3 = nil
local flag = false
local viewportSizeChangedConnection = nil
local inputBeganConnection = nil
local isStudio = RunService:IsStudio()
local localPlayer = Players.LocalPlayer
local v4 = false
local v5 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function checkTopbarEnabled()
	local v6, v7 = xpcall(function()
		return StarterGui:GetCore("TopbarEnabled")
	end, function(_)
		return true
	end)
	return v6 and v7
end

local function checkTopbarEnabledAccountingForMimic()
	local v6, v7 = xpcall(function()
		return StarterGui:GetCore("TopbarEnabled")
	end, function(_)
		return true
	end)
	return v6 and v7 or not IconController.mimicCoreGui
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindCamera()
	if not workspace.CurrentCamera then
		return
	end

	if viewportSizeChangedConnection and viewportSizeChangedConnection.Connected then
		viewportSizeChangedConnection:Disconnect()
	end

	viewportSizeChangedConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(IconController.updateTopbar)
end

local v6 = {}
v6.left = {
	startScale = 0,
	getOffset = function()
		local leftOffset = IconController.leftOffset
		local _, _ = xpcall(function()
			return StarterGui:GetCore("TopbarEnabled")
		end, function(_)
			return true
		end)
		return leftOffset
	end,
	getStartOffset = function()
		local leftGap = IconController.leftGap
		return v6.left.getOffset() + leftGap
	end,
	records = {}
}
v6.mid = {
	startScale = 0.5,
	getOffset = function()
		return 0
	end,
	getStartOffset = function(p)
		local midGap = IconController.midGap
		return -p / 2 + midGap / 2
	end,
	records = {}
}
v6.right = {
	startScale = 1,
	getOffset = function()
		local rightOffset = IconController.rightOffset
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChild("Humanoid")
		local v7 = humanoid and humanoid.RigType == Enum.HumanoidRigType.R6 and true or false

		if (checkTopbarEnabled() or VRService.VREnabled) and (StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList) or StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) or not v7 and StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu)) then
			rightOffset += 48
		end

		return rightOffset
	end,
	getStartOffset = function(p)
		return -p - v6.right.getOffset()
	end,
	records = {}
}
local UserInputService2 = game:GetService("UserInputService")
local touchEnabled = UserInputService2.TouchEnabled
IconController.topbarEnabled = true
IconController.controllerModeEnabled = false
local v7, v8 = xpcall(function()
	return StarterGui:GetCore("TopbarEnabled")
end, function(_)
	return true
end)
IconController.previousTopbarEnabled = v7 and v8
IconController.leftGap = 12 - (touchEnabled and 6 or 0)
IconController.midGap = 12
IconController.rightGap = 12
IconController.leftOffset = 0
IconController.rightOffset = 0
IconController.voiceChatEnabled = true
IconController.mimicCoreGui = true
IconController.healthbarDisabled = false
IconController.activeButtonBCallbacks = 0
IconController.disableButtonB = false
IconController.translator = LocalizationService:GetTranslatorForPlayer(localPlayer)
IconController.iconAdded = Signal.new()
IconController.iconRemoved = Signal.new()
IconController.controllerModeStarted = Signal.new()
IconController.controllerModeEnded = Signal.new()
IconController.healthbarDisabledSignal = Signal.new()
local count = 0
IconController.iconAdded:Connect(function(object2)
	v[object2] = true

	if IconController.gameTheme then
		object2:setTheme(IconController.gameTheme)
	end

	object2.updated:Connect(function()
		IconController.updateTopbar()
	end)
	object2.selected:Connect(function()
		local icons = IconController.getIcons()

		for _, icon in pairs(icons) do
			if object2.deselectWhenOtherIconSelected and icon ~= object2 and icon.deselectWhenOtherIconSelected and icon:getToggleState() == "selected" then
				icon:deselect(object2)
			end
		end
	end)
	count += 1
	object2:setOrder(count)

	if IconController.controllerModeEnabled then
		IconController._enableControllerModeForIcon(object2, true)
	end

	IconController:_updateSelectionGroup()
	IconController.updateTopbar()
end)
IconController.iconRemoved:Connect(function(object2)
	v[object2] = nil
	object2:setEnabled(false)
	object2:deselect()
	object2.updated:Fire()
	IconController:_updateSelectionGroup()
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)

function IconController.setGameTheme(gameTheme)
	IconController.gameTheme = gameTheme
	local icons = IconController.getIcons()

	for _, icon in pairs(icons) do
		icon:setTheme(gameTheme)
	end
end

function IconController.setDisplayOrder(p)
	TopbarPlusGui.DisplayOrder = tonumber(p) or TopbarPlusGui.DisplayOrder
end

IconController.setDisplayOrder(2147483647)

function IconController.getIcons()
	local result = {}

	for k, _ in pairs(v) do
		table.insert(result, k)
	end

	return result
end

function IconController.getIcon(p)
	for k, _ in pairs(v) do
		if k.name == p then
			return k
		end
	end

	return false
end

function IconController.disableHealthbar(p)
	local healthbarDisabled = p == nil or p
	IconController.healthbarDisabled = healthbarDisabled
	IconController.healthbarDisabledSignal:Fire(healthbarDisabled)
end

function IconController.disableControllerOption(p)
	v5 = p == nil or p

	if IconController.getIcon("_TopbarControllerOption") then
		IconController._determineControllerDisplay()
	end
end

function IconController.canShowIconOnTopbar(data)
	if (data.enabled == true or data.accountForWhenDisabled) and data.presentOnTopbar then
		return true
	end

	return false
end

function IconController.getMenuOffset(object2)
	local v9 = IconController[object2:get("alignment") .. "Gap"]
	local v10 = 0
	local total = 0
	local v11 = 0

	if not object2.menuOpen then
		return v10, total, v11
	end

	local offset = object2:get("menuSize").X.Offset
	local _getMenuDirection = object2:_getMenuDirection()

	if _getMenuDirection == "right" then
		return v10, total + (offset + v9 / 6), v11
	end

	if _getMenuDirection == "left" then
		v10 = offset + 4
		total += v9 / 3
		v11 = offset
	end

	return v10, total, v11
end

local flag2 = false

function IconController.updateTopbar()
	local function getIncrement(record, k)
		local v9 = (record:get("iconSize", record:getIconState()) or UDim2.new(0, 32, 0, 32)).X.Offset + IconController[k .. "Gap"]
		local total = 0

		if record._parentIcon == nil then
			local menuOffset, v10, v11 = IconController.getMenuOffset(record)
			total += menuOffset
			v9 += v10 + v11
		end

		return v9, total
	end

	if flag then
		flag2 = true
		return false
	else
		task.defer(function()
			flag = true
			RunService.Heartbeat:Wait()
			flag = false

			for _, v9 in pairs(v6) do
				v9.records = {}
			end

			for k, _ in pairs(v) do
				if not IconController.canShowIconOnTopbar(k) then
					continue
				end

				local alignment = k:get("alignment")
				table.insert(v6[alignment].records, k)
			end

			local viewportSize = workspace.CurrentCamera.ViewportSize

			for k, v9 in pairs(v6) do
				local records = v9.records

				if #records > 1 then
					if v9.reverseSort then
						table.sort(records, function(a, b)
							return a:get("order") > b:get("order")
						end)
					else
						table.sort(records, function(a, b)
							return a:get("order") < b:get("order")
						end)
					end
				end

				local total = 0

				for _, record in pairs(records) do
					total += getIncrement(record, k)
				end

				local startOffset = v9.getStartOffset(total, k)
				local X = TopbarPlusGui.TopbarContainer.AbsoluteSize.X
				local v10 = startOffset

				for _, record in pairs(records) do
					local increment, v11 = getIncrement(record, k)
					local _ = v9.startScale * X + v10 + v11
					v10 += increment
				end

				for _, record in pairs(records) do
					local iconContainer = record.instances.iconContainer
					local increment, v11 = getIncrement(record, k)
					local topPadding = record.topPadding
					local uDim = UDim2.new(v9.startScale, startOffset + v11, topPadding.Scale, topPadding.Offset)
					string.match(record.name, "_overflowIcon-")
					local repositionInfo = record:get("repositionInfo")

					if repositionInfo then
						TweenService:Create(iconContainer, repositionInfo, {
							Position = uDim
						}):Play()
					else
						iconContainer.Position = uDim
					end

					startOffset += increment
					record.targetPosition = UDim2.new(
						0,
						uDim.X.Scale * viewportSize.X + uDim.X.Offset,
						0,
						uDim.Y.Scale * viewportSize.Y + uDim.Y.Offset
					)
				end
			end

			local function getBoundaryX(object2, p, value2)
				local v9 = value2 or 0
				local offset = object2:get("iconSize", object2:getIconState()).X.Offset
				local menuOffset, v10 = IconController.getMenuOffset(object2)
				local v11 = p == "left" and -v9 - menuOffset

				if not v11 then
					if p == "right" then
						v11 = offset + v9 + v10
					else
						v11 = false
					end
				end

				return object2.targetPosition.X.Offset + v11
			end

			local function getSizeX(object2, p)
				local v9, v10 = object2:get("iconSize", object2:getIconState(), "beforeDropdown")
				local v11 = object2:get("iconSize", "hovering")

				if object2.wasHoveringBeforeOverflow and v10 and v11 and v11.X.Offset > v10.X.Offset then
					v10 = v11
				end

				if p then
					v9 = v10 or v9
				end

				local menuOffset, v12 = IconController.getMenuOffset(object2)
				return v9.X.Offset + menuOffset + v12
			end

			for k, v9 in pairs(v6) do
				local overflowIcon = v9.overflowIcon

				if not overflowIcon then
					continue
				end

				local v10 = IconController[k .. "Gap"]
				local v11 = k == "left" and "right" or "left"
				local v12 = v6[v11]
				local icon = IconController.getIcon("_overflowIcon-" .. v11)
				local offset = overflowIcon:get("iconSize", overflowIcon:getIconState()).X.Offset
				local menuOffset, v13 = IconController.getMenuOffset(overflowIcon)
				local v14 = k == "left" and -0 - menuOffset

				if not v14 then
					if k == "right" then
						v14 = offset + 0 + v13
					else
						v14 = false
					end
				end

				local v15 = overflowIcon.targetPosition.X.Offset + v14

				if overflowIcon.enabled then
					v15 = getBoundaryX(overflowIcon, v11, v10)
				end

				local v16 = k

				local function doesExceed(p)
					if v16 == "left" and p < v15 then
						return true
					elseif v16 == "right" then
						return v15 < p
					else
						return false
					end
				end

				local offset2 = v12.getOffset()

				if not overflowIcon.enabled then
					offset2 += 10
				end

				local v17 = k == "left" and viewportSize.X - offset2

				if not v17 then
					if k == "right" then
						v17 = offset2
					else
						v17 = false
					end
				end

				local v18 = v17
				local v19 = v18
				local v20

				if k == "left" and v19 < v15 then
					v20 = true
				elseif k == "right" then
					v20 = v15 < v19
				else
					v20 = false
				end

				local overflowIcon2 = overflowIcon
				local v22 = k

				local function checkBoundaryExceeded(records)
					local count2 = #records

					for i = 1, count2 do
						local v23 = records[count2 + 1 - i]

						if not IconController.canShowIconOnTopbar(v23) then
							continue
						end

						local v24 = string.match(v23.name, "_overflowIcon-")

						if v24 and count2 ~= 1 then
							break
						end

						if not (not v24 or v23.enabled) then
							continue
						end

						local boundaryX = getBoundaryX(v23, v22, overflowIcon2.enabled and 0 or 10)
						local v26

						if v22 == "left" and boundaryX < v18 then
							v26 = true
						elseif v22 == "right" then
							v26 = v18 < boundaryX
						else
							v26 = false
						end

						if not v26 then
							continue
						end

						v18 = boundaryX
						local v27

						if v22 == "left" and boundaryX < v15 then
							v27 = true
						elseif v22 == "right" then
							v27 = v15 < boundaryX
						else
							v27 = false
						end

						if v27 then
							v20 = true
						end
					end
				end

				checkBoundaryExceeded(v6[v11].records)
				checkBoundaryExceeded(v6.mid.records)

				if v20 then
					local records = v9.records
					local count2 = #records

					for i = 1, count2 do
						local v23 = k == "left" and records[count2 + 1 - i]

						if not v23 then
							if k == "right" then
								v23 = records[i]
							else
								v23 = false
							end
						end

						if not (v23 ~= overflowIcon and IconController.canShowIconOnTopbar(v23)) then
							continue
						end

						local offset3 = overflowIcon:get("iconSize", overflowIcon:getIconState()).X.Offset

						if overflowIcon.enabled then
							v10 += v10 + offset3
						end

						local boundaryX = getBoundaryX(v23, v11, v10)
						local v24

						if k == "left" and v18 <= boundaryX then
							v24 = true
						elseif k == "right" then
							v24 = boundaryX <= v18
						else
							v24 = false
						end

						if not v24 then
							break
						end

						if not overflowIcon.enabled then
							local iconContainer = overflowIcon.instances.iconContainer
							local Y = iconContainer.Position.Y
							local boundaryX2 = getBoundaryX(
								v23,
								v11,
								k ~= "left" and 0 or -iconContainer.Size.X.Offset or 0
							)
							iconContainer.Position = UDim2.new(0, boundaryX2, Y.Scale, Y.Offset)
							overflowIcon:setEnabled(true)
						end

						if #v23.dropdownIcons > 0 then
							v23._overflowConvertedToMenu = true
							local isSelected = v23.isSelected
							v23:deselect()
							local dropdownIcons = {}

							for _, dropdownIcon in pairs(v23.dropdownIcons) do
								table.insert(dropdownIcons, dropdownIcon)
							end

							for _, dropdownIcon in pairs(v23.dropdownIcons) do
								dropdownIcon:leave()
							end

							v23:setMenu(dropdownIcons)

							if isSelected and overflowIcon.isSelected then
								v23:select()
							end
						end

						if v23.hovering then
							v23.wasHoveringBeforeOverflow = true
						end

						v23:join(overflowIcon, "dropdown")

						if not (#v23.menuIcons > 0 and v23.menuOpen) then
							break
						end

						v23:deselect()
						v23:select()
						overflowIcon:select()
						break
					end
				else
					local v23 = nil
					local v24 = nil
					local v25 = #overflowIcon.dropdownIcons

					if not icon or not icon.enabled or #v9.records ~= 1 or #v12.records == 1 then
						for _, dropdownIcon in pairs(overflowIcon.dropdownIcons) do
							local order = dropdownIcon:get("order")

							if not (v24 == nil or k == "left" and order < v23 or k == "right" and v23 < order) then
								continue
							end

							v23 = order
							v24 = dropdownIcon
						end
					end

					if v24 then
						local sizeX = getSizeX(v24, true)
						local offset3 = overflowIcon:get("iconSize", overflowIcon:getIconState()).X.Offset
						local menuOffset2, v26 = IconController.getMenuOffset(overflowIcon)
						local v27 = v11 == "left" and -0 - menuOffset2

						if not v27 then
							if v11 == "right" then
								v27 = offset3 + 0 + v26
							else
								v27 = false
							end
						end

						local v28 = overflowIcon.targetPosition.X.Offset + v27

						if v25 == 1 then
							v28 = getBoundaryX(overflowIcon, k, v10 - 10)
						end

						if sizeX < math.abs(v18 - v28) - v10 * 2 then
							if #overflowIcon.dropdownIcons == 1 then
								overflowIcon:setEnabled(false)
							end

							local iconContainer = overflowIcon.instances.iconContainer
							local Y = iconContainer.Position.Y
							iconContainer.Position = UDim2.new(0, v28, Y.Scale, Y.Offset)
							v24:leave()
							v24.wasHoveringBeforeOverflow = nil

							if v24._overflowConvertedToMenu then
								v24._overflowConvertedToMenu = nil
								local menuIcons = {}

								for _, menuIcon in pairs(v24.menuIcons) do
									table.insert(menuIcons, menuIcon)
								end

								for _, menuIcon in pairs(v24.menuIcons) do
									menuIcon:leave()
								end

								v24:setDropdown(menuIcons)
							end
						end
					end
				end
			end

			if flag2 then
				flag2 = false
				IconController.updateTopbar()
			end

			return true
		end)
	end
end

function IconController.setTopbarEnabled(visible, p)
	local v9 = p == nil or p
	local indicator = TopbarPlusGui.Indicator

	if v9 and not visible then
		v2 = true
	elseif v9 and visible then
		v2 = false
	end

	local v10, v11 = xpcall(function()
		return StarterGui:GetCore("TopbarEnabled")
	end, function(_)
		return true
	end)
	local visible2 = v10 and v11 or not IconController.mimicCoreGui

	if IconController.controllerModeEnabled then
		if visible then
			if TopbarPlusGui.TopbarContainer.Visible or v2 or v3 or not visible2 then
				return
			end

			if v9 then
				indicator.Visible = visible2
				return
			end

			indicator.Active = false

			if inputBeganConnection and inputBeganConnection.Connected then
				inputBeganConnection:Disconnect()
			end

			if HapticService:IsVibrationSupported(Enum.UserInputType.Gamepad1) and HapticService:IsMotorSupported(
				Enum.UserInputType.Gamepad1,
				Enum.VibrationMotor.Small
			) then
				HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 1)
				delay(0.2, function()
					pcall(function()
						HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
					end)
				end)
			end

			TopbarPlusGui.TopbarContainer.Visible = true
			TopbarPlusGui.TopbarContainer:TweenPosition(
				UDim2.new(0, 0, 0, 37),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true
			)
			IconController:_updateSelectionGroup()
			RunService.Heartbeat:Wait()
			local v13 = nil
			local v14 = 0

			for k, _ in pairs(v) do
				if IconController.canShowIconOnTopbar(k) and (v13 == nil or k:get("order") < v13:get("order")) and k.enabled then
					v13 = k
				end

				local v15 = -27 + k.instances.iconContainer.AbsoluteSize.Y + 50

				if v14 < v15 then
					v14 = v15
				end
			end

			if GuiService:GetEmotesMenuOpen() then
				GuiService:SetEmotesMenuOpen(false)
			end

			if GuiService:GetInspectMenuEnabled() then
				GuiService:CloseInspectMenu()
			end

			local _previousSelectedObject = IconController._previousSelectedObject or v13 and v13.instances.iconButton
			IconController._setControllerSelectedObject(_previousSelectedObject)
			local UserInputService3 = game:GetService("UserInputService")
			indicator.Image = ({
				ButtonB = "rbxassetid://5278151071",
				ButtonCircle = "rbxassetid://15030650284"
			})[UserInputService3:GetStringForKeyCode(Enum.KeyCode.ButtonB)]
			indicator:TweenPosition(
				UDim2.new(0.5, 0, 0, v14 + 32),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true
			)
		else
			if v9 then
				indicator.Visible = false
			elseif visible2 then
				indicator.Visible = true
				indicator.Active = true
				inputBeganConnection = indicator.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						IconController.setTopbarEnabled(true, false)
					end
				end)
			else
				indicator.Visible = false
			end

			if not TopbarPlusGui.TopbarContainer.Visible then
				return
			end

			GuiService.AutoSelectGuiEnabled = true
			IconController:_updateSelectionGroup(true)
			TopbarPlusGui.TopbarContainer:TweenPosition(
				UDim2.new(0, 0, 0, -TopbarPlusGui.TopbarContainer.Size.Y.Offset + 32),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true,
				function()
					TopbarPlusGui.TopbarContainer.Visible = false
				end
			)
			indicator.Image = "rbxassetid://5278151556"
			indicator:TweenPosition(UDim2.new(0.5, 0, 0, 5), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
		end
	else
		local topbarContainer = TopbarPlusGui.TopbarContainer

		if visible2 then
			topbarContainer.Visible = visible
		else
			topbarContainer.Visible = false
		end
	end
end

function IconController.setGap(p, p2)
	local v9 = tonumber(p) or 12
	local lower = tostring(p2):lower()

	if lower == "left" or lower == "mid" or lower == "right" then
		IconController[lower .. "Gap"] = v9
	else
		IconController.leftGap = v9
		IconController.midGap = v9
		IconController.rightGap = v9
	end

	IconController.updateTopbar()
end

function IconController.setLeftOffset(p)
	IconController.leftOffset = tonumber(p) or 0
	IconController.updateTopbar()
end

function IconController.setRightOffset(p)
	IconController.rightOffset = tonumber(p) or 0
	IconController.updateTopbar()
end

local localPlayer2 = Players.LocalPlayer
local v9 = {}
localPlayer2.CharacterAdded:Connect(function()
	for _, v10 in pairs(v9) do
		v10:destroy()
	end

	v9 = {}
end)

function IconController.clearIconOnSpawn(p)
	coroutine.wrap(function()
		if not localPlayer2.Character then
			localPlayer2.CharacterAdded:Wait()
		end

		table.insert(v9, p)
	end)()
end

function IconController:_updateSelectionGroup(p)
	if IconController._navigationEnabled then
		GuiService:RemoveSelectionGroup("TopbarPlusIcons")
	end

	if p then
		GuiService.CoreGuiNavigationEnabled = IconController._originalCoreGuiNavigationEnabled
		GuiService.GuiNavigationEnabled = IconController._originalGuiNavigationEnabled
		IconController._navigationEnabled = nil
	elseif IconController.controllerModeEnabled then
		local icons = IconController.getIcons()
		local iconButtons = {}

		for _, icon in pairs(icons) do
			if not icon.joinedFeatureName or icon._parentIcon[icon.joinedFeatureName .. "Open"] == true then
				table.insert(iconButtons, icon.instances.iconButton)
			end
		end

		GuiService:AddSelectionTuple("TopbarPlusIcons", table.unpack(iconButtons))

		if not IconController._navigationEnabled then
			IconController._originalCoreGuiNavigationEnabled = GuiService.CoreGuiNavigationEnabled
			IconController._originalGuiNavigationEnabled = GuiService.GuiNavigationEnabled
			GuiService.CoreGuiNavigationEnabled = false
			GuiService.GuiNavigationEnabled = true
			IconController._navigationEnabled = true
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getScaleMultiplier()
	if GuiService:IsTenFootInterface() then
		return 3
	end

	return 1.3
end

function IconController._setControllerSelectedObject(selectedObject)
	local controllerSetCount = IconController._controllerSetCount and IconController._controllerSetCount + 1 or 0
	IconController._controllerSetCount = controllerSetCount
	GuiService.SelectedObject = selectedObject
	task.delay(0.1, function()
		if controllerSetCount == IconController._controllerSetCountS then
			GuiService.SelectedObject = selectedObject
		end
	end)
end

function IconController._enableControllerMode(controllerModeEnabled)
	local indicator = TopbarPlusGui.Indicator
	IconController.getIcon("_TopbarControllerOption")

	if IconController.controllerModeEnabled == controllerModeEnabled then
		return
	end

	IconController.controllerModeEnabled = controllerModeEnabled

	if controllerModeEnabled then
		TopbarPlusGui.TopbarContainer.Position = UDim2.new(0, 0, 0, 5)
		TopbarPlusGui.TopbarContainer.Visible = false
		local scaleMultiplier = getScaleMultiplier() -- equivalent call inferred; original call site unknown
		indicator.Position = UDim2.new(0.5, 0, 0, 5)
		indicator.Size = UDim2.new(0, 18 * scaleMultiplier, 0, 18 * scaleMultiplier)
		indicator.Image = "rbxassetid://5278151556"
		local v10, v11 = xpcall(function()
			return StarterGui:GetCore("TopbarEnabled")
		end, function(_)
			return true
		end)
		indicator.Visible = v10 and v11 or not IconController.mimicCoreGui
		indicator.Position = UDim2.new(0.5, 0, 0, 5)
		indicator.Active = true
		inputBeganConnection = indicator.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				IconController.setTopbarEnabled(true, false)
			end
		end)
	else
		TopbarPlusGui.TopbarContainer.Position = UDim2.new(0, 0, 0, 0)
		local topbarContainer = TopbarPlusGui.TopbarContainer
		local v10, v11 = xpcall(function()
			return StarterGui:GetCore("TopbarEnabled")
		end, function(_)
			return true
		end)
		topbarContainer.Visible = v10 and v11 or not IconController.mimicCoreGui
		indicator.Visible = false
		IconController._setControllerSelectedObject(nil)
	end

	for k, _ in pairs(v) do
		IconController._enableControllerModeForIcon(k, controllerModeEnabled)
	end
end

function IconController:_enableControllerModeForIcon(p)
	local _parentIcon = self._parentIcon
	local joinedFeatureName = self.joinedFeatureName

	if _parentIcon then
		self:leave()
	end

	if p then
		local scaleMultiplier = getScaleMultiplier() -- equivalent call inferred; original call site unknown
		local v10 = self:get("iconSize", "deselected")
		local v11 = self:get("iconSize", "selected")
		local hovering = self:getHovering("iconSize")
		self:set(
			"iconSize",
			UDim2.new(0, v10.X.Offset * scaleMultiplier, 0, v10.Y.Offset * scaleMultiplier),
			"deselected",
			"controllerMode"
		)
		self:set(
			"iconSize",
			UDim2.new(0, v11.X.Offset * scaleMultiplier, 0, v11.Y.Offset * scaleMultiplier),
			"selected",
			"controllerMode"
		)

		if hovering then
			self:set(
				"iconSize",
				UDim2.new(0, v11.X.Offset * scaleMultiplier, 0, v11.Y.Offset * scaleMultiplier),
				"hovering",
				"controllerMode"
			)
		end

		self:set("alignment", "mid", "deselected", "controllerMode")
		self:set("alignment", "mid", "selected", "controllerMode")
	else
		for _, v10 in pairs({ "deselected", "selected", "hovering" }) do
			local _, v11 = self:get("alignment", v10, "controllerMode")

			if v11 then
				self:set("alignment", v11, v10)
			end

			local _, v12 = self:get("iconSize", v10, "controllerMode")

			if v12 then
				self:set("iconSize", v12, v10)
			end
		end
	end

	if _parentIcon then
		self:join(_parentIcon, joinedFeatureName)
	end
end

local flag3 = false

function IconController.setupHealthbar()
	if flag3 then
		return
	end

	flag3 = true
	task.defer(function()
		RunService.Heartbeat:Wait()
		local module = require(parent)
		module.new():setProperty("internalIcon", true):setName("_FakeHealthbar"):setRight():setOrder(-420):setSize(
			80,
			32
		):lock():set(
			"iconBackgroundTransparency",
			1
		):give(function(object2)
			local frame = Instance.new("Frame")
			frame.Name = "HealthContainer"
			frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			frame.BorderSizePixel = 0
			frame.AnchorPoint = Vector2.new(0, 0.5)
			frame.Position = UDim2.new(0, 0, 0.5, 0)
			frame.Size = UDim2.new(1, 0, 0.2, 0)
			frame.Visible = true
			frame.ZIndex = 11
			frame.Parent = object2.instances.iconButton
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(1, 0)
			uICorner.Parent = frame
			local clone = frame:Clone()
			clone.Name = "HealthFrame"
			clone.BackgroundColor3 = Color3.fromRGB(167, 167, 167)
			clone.BorderSizePixel = 0
			clone.AnchorPoint = Vector2.new(0.5, 0.5)
			clone.Position = UDim2.new(0.5, 0, 0.5, 0)
			clone.Size = UDim2.new(1, -2, 1, -2)
			clone.Visible = true
			clone.ZIndex = 12
			clone.Parent = frame
			local clone2 = clone:Clone()
			clone2.Name = "HealthBar"
			clone2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			clone2.BorderSizePixel = 0
			clone2.AnchorPoint = Vector2.new(0, 0.5)
			clone2.Position = UDim2.new(0, 0, 0.5, 0)
			clone2.Size = UDim2.new(0.5, 0, 1, 0)
			clone2.Visible = true
			clone2.ZIndex = 13
			clone2.Parent = clone
			local color = Color3.fromRGB(27, 252, 107)
			local color2 = Color3.fromRGB(250, 235, 0)
			local color3 = Color3.fromRGB(255, 28, 0)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function powColor3(data, p)
				return Color3.new(math.pow(data.R, p), math.pow(data.G, p), (math.pow(data.B, p)))
			end

			local function lerpColor(data, data2, p, value2)
				local v10 = value2 or 2
				local v11 = powColor3(data, v10) -- equivalent call inferred; original call site unknown
				local v12 = powColor3(data2, v10) -- equivalent call inferred; original call site unknown
				return powColor3(v11:Lerp(v12, p), 1 / v10)
			end

			local v10 = true
			local healthbarDisabledSignalConnection = nil

			local function listenToHealth(character)
				if not character then
					return
				end

				local humanoid = character:WaitForChild("Humanoid", 10)

				if not humanoid then
					return
				end

				local function updateHealthBar()
					local coreGuiEnabled = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Health)
					local v11 = humanoid.Health / humanoid.MaxHealth

					if v11 == 1 or IconController.healthbarDisabled or v10 and coreGuiEnabled == false then
						if object2.enabled then
							object2:setEnabled(false)
						end
					else
						if v11 < 1 then
							if not object2.enabled then
								object2:setEnabled(true)
							end

							v10 = false

							if coreGuiEnabled then
								StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
							end
						end

						local v12 = 1.25 * v11 + -0.125
						local v13 = v12 > 1 and 1 or v12 < 0 and 0 or v12
						local v14 = v11 > 0.5 and color or color2
						local v15 = v11 > 0.5 and color2 or color3
						local v16 = (1 - v13) * 2
						local v17 = v11 > 0.5 and 1 - v16 or 2 - v16
						local v18 = nil or 2
						local backgroundColor = powColor3(
							Color3.new(math.pow(v15.R, v18), math.pow(v15.G, v18), (math.pow(v15.B, v18))):Lerp(
								Color3.new(math.pow(v14.R, v18), math.pow(v14.G, v18), (math.pow(v14.B, v18))),
								v17
							),
							1 / v18
						) -- equivalent call inferred; original call site unknown
						local uDim = UDim2.new(v11, 0, 1, 0)
						clone2.BackgroundColor3 = backgroundColor
						clone2.Size = uDim
					end
				end

				humanoid.HealthChanged:Connect(updateHealthBar)

				if healthbarDisabledSignalConnection then
					healthbarDisabledSignalConnection:Disconnect()
				end

				healthbarDisabledSignalConnection = IconController.healthbarDisabledSignal:Connect(updateHealthBar)
				updateHealthBar()
			end

			localPlayer2.CharacterAdded:Connect(function(character)
				listenToHealth(character)
			end)
			task.spawn(listenToHealth, localPlayer2.Character)
		end)
	end)
end

function IconController._determineControllerDisplay()
	local mouseEnabled = UserInputService.MouseEnabled
	local gamepadEnabled = UserInputService.GamepadEnabled
	local icon = IconController.getIcon("_TopbarControllerOption")

	if mouseEnabled and gamepadEnabled then
		if v5 then
			icon:setEnabled(false)
		else
			icon:setEnabled(true)
		end
	elseif mouseEnabled and not gamepadEnabled then
		icon:setEnabled(false)
		IconController._enableControllerMode(false)
		icon:deselect()
	elseif not mouseEnabled and gamepadEnabled then
		icon:setEnabled(false)
		IconController._enableControllerMode(true)
	end
end

coroutine.wrap(function()
	RunService.Heartbeat:Wait()
	local module = require(parent)
	local v10 = module.new():setProperty("internalIcon", true):setName("_TopbarControllerOption"):setOrder(100):setImage(11162828670):setRight():setEnabled(false):setTip("Controller mode"):setProperty(
		"deselectWhenOtherIconSelected",
		false
	)
	UserInputService:GetPropertyChangedSignal("MouseEnabled"):Connect(IconController._determineControllerDisplay)
	UserInputService.GamepadConnected:Connect(IconController._determineControllerDisplay)
	UserInputService.GamepadDisconnected:Connect(IconController._determineControllerDisplay)
	IconController._determineControllerDisplay()

	local function iconClicked()
		local isSelected = v10.isSelected
		v10:setTip(isSelected and "Normal mode" or "Controller mode")
		IconController._enableControllerMode(isSelected)
	end

	v10.selected:Connect(iconClicked)
	v10.deselected:Connect(iconClicked)
	UserInputService.InputBegan:Connect(function(input, _)
		if not IconController.controllerModeEnabled then
			return
		end

		if input.KeyCode == Enum.KeyCode.DPadDown then
			if not GuiService.SelectedObject then
				local v11, v12 = xpcall(function()
					return StarterGui:GetCore("TopbarEnabled")
				end, function(_)
					return true
				end)

				if v11 and v12 or not IconController.mimicCoreGui then
					IconController.setTopbarEnabled(true, false)
				end
			end
		elseif input.KeyCode == Enum.KeyCode.ButtonB and not IconController.disableButtonB then
			if IconController.activeButtonBCallbacks == 1 and TopbarPlusGui.Indicator.Image == "rbxassetid://5278151556" then
				IconController.activeButtonBCallbacks = 0
				GuiService.SelectedObject = nil
			end

			if IconController.activeButtonBCallbacks == 0 then
				IconController._previousSelectedObject = GuiService.SelectedObject
				IconController._setControllerSelectedObject(nil)
				IconController.setTopbarEnabled(false, false)
			end
		end

		input:Destroy()
	end)

	for k, v11 in pairs(v6) do
		if k == "mid" then
			continue
		end

		local v12 = "_overflowIcon-" .. k
		local overflowIcon = module.new():setProperty("internalIcon", true):setImage(6069276526):setName(v12):setEnabled(false)
		v11.overflowIcon = overflowIcon
		overflowIcon.accountForWhenDisabled = true

		if k == "left" then
			overflowIcon:setOrder(1e999)
			overflowIcon:setLeft()
			overflowIcon:set("dropdownAlignment", "right")
		elseif k == "right" then
			overflowIcon:setOrder(-1e999)
			overflowIcon:setRight()
			overflowIcon:set("dropdownAlignment", "left")
		end

		overflowIcon.lockedSettings = {
			iconImage = true,
			order = true,
			alignment = true
		}
	end

	task.defer(function()
		local success, result

		while true do
			success, result = pcall(function()
				return VoiceChatService:IsVoiceEnabledForUserIdAsync(localPlayer2.UserId)
			end)

			if success then
				break
			end

			task.wait(1)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function checkVoiceChatManuallyEnabled()
			if IconController.voiceChatEnabled and success and result then
				v4 = true
				IconController.updateTopbar()
			end
		end

		checkVoiceChatManuallyEnabled() -- equivalent call inferred; original call site unknown
		localPlayer2.PlayerGui:WaitForChild("TopbarPlus", 999)
		task.delay(10, function()
			checkVoiceChatManuallyEnabled() -- equivalent call inferred; original call site unknown

			if IconController.voiceChatEnabled == nil and success and result and isStudio then
				warn("⚠️TopbarPlus Action Required⚠️ If VoiceChat is enabled within your experience it's vital you set IconController.voiceChatEnabled to true ``require(game.ReplicatedStorage.Icon.IconController).voiceChatEnabled = true`` otherwise the BETA label will not be accounted for within your live servers. This warning will disappear after doing so. Feel free to delete this warning or to set to false if you don't have VoiceChat enabled within your experience.")
			end
		end)
	end)

	if not isStudio then
		local creatorId = game.CreatorId
		local GroupService = game:GetService("GroupService")

		if game.CreatorType == Enum.CreatorType.Group then
			local success, result = pcall(function()
				return GroupService:GetGroupInfoAsync(game.CreatorId).Owner
			end)

			if success then
				creatorId = result.Id
			end
		end

		local VERSION = require(parent.VERSION)

		if localPlayer2.UserId ~= creatorId then
			local MarketplaceService = game:GetService("MarketplaceService")
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfo(game.PlaceId)
			end)

			if success and result then
				local name = result.Name
				print(([[



⚽ %s uses TopbarPlus %s
🍍 TopbarPlus was developed by ForeverHD and the Nanoblox Team
🚀 You can learn more and take a free copy by searching for 'TopbarPlus' on the DevForum

]]):format(name, VERSION))
			end
		end
	end
end)()
GuiService.MenuClosed:Connect(function()
	if VRService.VREnabled then
		return
	end

	v3 = false

	if not IconController.controllerModeEnabled then
		IconController.setTopbarEnabled(IconController.topbarEnabled, false)
	end
end)
GuiService.MenuOpened:Connect(function()
	if VRService.VREnabled then
		return
	end

	v3 = true
	IconController.setTopbarEnabled(false, false)
end)
bindCamera() -- equivalent call inferred; original call site unknown
task.spawn(function()
	local success, result = pcall(function()
		return LocalizationService:GetTranslatorForPlayerAsync(localPlayer2)
	end)

	local function updateAllIcons()
		local icons = IconController.getIcons()

		for _, icon in pairs(icons) do
			icon:_updateAll()
		end
	end

	if success then
		IconController.translator = result
		result:GetPropertyChangedSignal("LocaleId"):Connect(updateAllIcons)
		task.spawn(updateAllIcons)
		task.delay(1, updateAllIcons)
		task.delay(10, updateAllIcons)
	end
end)
return IconController