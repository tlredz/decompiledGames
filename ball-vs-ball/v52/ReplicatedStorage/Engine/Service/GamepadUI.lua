local Players = game:GetService("Players")
local GamepadPages = require(script.Parent.GamepadSupport.GamepadPages)
require(script.Parent.GamepadSupport)
local ButtonActions = require(script.Parent.GamepadSupport.ButtonActions)
local LobbyShortcuts = require(script.Parent.GamepadSupport.LobbyShortcuts)
local flag = false
local v = {
	["界面图标"] = true,
	["下方按钮区"] = true,
	["右侧菜单"] = true,
	["货币"] = true,
	["经验条"] = true
}
local v2 = {
	["战斗匹配UI"] = true,
	["背包"] = true,
	["商店"] = true,
	["每日签到"] = true,
	["玩家面板"] = true,
	["交易"] = true,
	["表情轮盘"] = true,
	["设置界面"] = true,
	["更新日志"] = true,
	["小摊"] = true,
	["图鉴"] = true,
	["贴纸"] = true,
	["限定礼包"] = true,
	["在线奖励"] = true,
	["邮件"] = true,
	["全服抽奖活动"] = true,
	["模式选择"] = true,
	["组队"] = true,
	["模拟对战"] = true,
	["对局分析"] = true,
	["赠礼UI"] = true,
	["管理员指令界面"] = true,
	RedeemCodeGui = true
}
local v3 = {
	["贴纸"] = true,
	["战斗匹配UI"] = true,
	["手柄图标素材"] = true,
	["贴纸素材"] = true,
	["抽奖转盘"] = true,
	["抽奖效果"] = true,
	["通用确认框"] = true,
	["战斗3选1"] = true,
	TopbarPlus = true
}
return {
	Init = function()
		if flag then
			return
		end

		flag = true
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local v4 = {}

		local function inputButton(textBox)
			if not textBox:IsA("TextBox") or textBox:FindFirstChild("手柄输入按钮") then
				return
			end

			local v5 = textBox:FindFirstChild("输入按钮")

			if not v5 then
				v5 = Instance.new("ImageButton")
				v5.Name = "输入按钮"
				v5.BackgroundTransparency = 1
				v5.Image = ""
				v5.AnchorPoint = Vector2.new(1, 0.5)
				v5.Position = UDim2.fromScale(0.98, 0.5)
				v5.SizeConstraint = Enum.SizeConstraint.RelativeYY
				v5.Size = UDim2.fromScale(0.45, 0.45)
				v5.ZIndex = textBox.ZIndex + 2
				v5.Parent = textBox
			end

			if not ButtonActions.Has(v5) then
				ButtonActions.Bind(v5, function()
					textBox:CaptureFocus()
				end)
			end
		end

		local function mount(guiObject)
			local screenGui = guiObject:FindFirstAncestorOfClass("ScreenGui")

			if not screenGui or v3[screenGui.Name] or not guiObject:IsA("GuiObject") or guiObject.Parent ~= screenGui or GamepadPages.IsRegistered(guiObject) then
				return
			end

			if not guiObject:IsA("GuiButton") and guiObject:FindFirstChildWhichIsA("GuiButton", true) == nil and not (v2[screenGui.Name] or v[screenGui.Name]) then
				return
			end

			local observe = GamepadPages.Observe
			local v5 = {
				base = v[screenGui.Name] == true,
				available = 0
			}
			local available

			if v[screenGui.Name] then
				available = LobbyShortcuts.IsAvailable
			end

			v5.available = available
			observe(guiObject, v5)
		end

		local function watch(screenGui)
			if not screenGui:IsA("ScreenGui") or v4[screenGui] or v3[screenGui.Name] or not (v2[screenGui.Name] or v[screenGui.Name]) then
				return
			end

			v4[screenGui] = true

			for _, child in screenGui:GetChildren() do
				mount(child)
			end

			for _, descendant in screenGui:GetDescendants() do
				inputButton(descendant)
			end

			screenGui.DescendantAdded:Connect(function(parent)
				inputButton(parent)

				while parent.Parent and parent.Parent ~= screenGui do
					parent = parent.Parent
				end

				if parent.Parent == screenGui then
					mount(parent)
				end
			end)
		end

		for _, child in playerGui:GetChildren() do
			watch(child)
		end

		local firstChild = playerGui:FindFirstChild("小摊")

		if firstChild then
			local v5 = firstChild["背景"]["面板"]

			for _, v6 in { v5["我的摊位"]["已上架"], v5["我的摊位"]["选择上架物品"], v5["查看摊位"] } do
				GamepadPages.Observe(v6)
			end
		end

		playerGui.ChildAdded:Connect(watch)
	end
}