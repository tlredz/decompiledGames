local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local QuickJoin = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Gui"):WaitForChild("QuickJoin"))
local ServerTypeService = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("ServerTypeService"))
local ServerTeleport = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServerTeleport"))
local GuiService = game:GetService("GuiService")
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
local GamepadPages = require(ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
local LobbyShortcuts = require(ReplicatedStorage.Engine.Service.GamepadSupport.LobbyShortcuts)
local PageControls = require(ReplicatedStorage.Engine.Service.GamepadSupport.PageControls)
local color = Color3.fromRGB(85, 170, 255)
local color2 = Color3.fromRGB(132, 135, 152)
local flag = false
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = true

local function applyState(visible: boolean)
	local selectedObject = GuiService.SelectedObject
	local v9 = selectedObject and (visible and (selectedObject:IsDescendantOf(v4) or selectedObject:IsDescendantOf(v5)) or not visible and selectedObject:IsDescendantOf(v3))
	v8 = visible
	v3.Visible = visible
	QuickJoin.SetTabActive(visible)
	v4.Visible = not visible
	v5.Visible = not visible
	local v10 = v6
	local backgroundColor

	if visible then
		backgroundColor = color
	else
		backgroundColor = color2
	end

	v10.BackgroundColor3 = backgroundColor
	local v12 = v7
	local backgroundColor2

	if visible then
		backgroundColor2 = color2
	else
		backgroundColor2 = color
	end

	v12.BackgroundColor3 = backgroundColor2

	if v9 then
		local v14 = GuiService
		local selectedObject2

		if visible then
			selectedObject2 = v6
		else
			selectedObject2 = v7
		end

		v14.SelectedObject = selectedObject2
	end
end

return {
	Init = function()
		if flag then
			return
		end

		flag = true
		local v9 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("右侧菜单")
		local v10 = v9:WaitForChild("右侧区域")
		v = v9
		v2 = v10
		v10.Visible = true
		GamepadPages.Observe(v10, {
			base = true,
			available = LobbyShortcuts.IsAvailable
		})
		v3 = v10:WaitForChild("每日任务")
		v4 = v10:WaitForChild("交易管理")
		v5 = v10:WaitForChild("大厅玩家列表")
		local v11 = v10:WaitForChild("顶部切换按钮")
		local lv = v5:WaitForChild("Lv")
		local v12 = v5:WaitForChild("总资产")

		if ServerTeleport.getServerType() == ServerTypeService.TRADE_POOL_NAME then
			v11.Visible = false
			v3.Visible = false
			v4.Visible = false
			v5.Visible = true
			lv.Visible = false
			v12.Visible = true
		else
			lv.Visible = true
			v12.Visible = false
			v6 = v11:WaitForChild("每日任务按钮")
			v7 = v11:WaitForChild("交易管理按钮")
			ButtonActions.Bind(v6, function()
				if not GamepadSupport.CanActivate(v6) then
					return
				end

				applyState(true)
			end)
			ButtonActions.Bind(v7, function()
				if not GamepadSupport.CanActivate(v7) then
					return
				end

				local selectedObject = GuiService.SelectedObject
				local v13 = selectedObject and selectedObject:IsDescendantOf(v3)
				v8 = false
				v3.Visible = false
				QuickJoin.SetTabActive(false)
				v4.Visible = true
				v5.Visible = true
				v6.BackgroundColor3 = color2
				v7.BackgroundColor3 = color

				if v13 then
					GuiService.SelectedObject = v7
				end
			end)
			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed or input.KeyCode ~= Enum.KeyCode.Tab then
					return
				end

				if v.Enabled and v2.Visible then
					applyState(not v8)
				end
			end)
			v6.Selectable = true
			v7.Selectable = true
			v6.NextSelectionRight = v7
			v7.NextSelectionLeft = v6
			PageControls.FromHint(v11, "手柄快捷提示", "L1", function()
				applyState(not v8)
			end)
			local selectedObject = GuiService.SelectedObject
			local v13 = selectedObject and (selectedObject:IsDescendantOf(v4) or selectedObject:IsDescendantOf(v5) or false)
			v8 = true
			v3.Visible = true
			QuickJoin.SetTabActive(true)
			v4.Visible = false
			v5.Visible = false
			v6.BackgroundColor3 = color
			v7.BackgroundColor3 = color2

			if v13 then
				GuiService.SelectedObject = v6
			end
		end
	end
}