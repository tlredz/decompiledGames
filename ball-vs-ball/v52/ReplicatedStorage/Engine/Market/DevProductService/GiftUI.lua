local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local v = utf8.char(57346)
local UI = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local robux = nil
local v6 = nil
local parent = nil
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = {}
local v12 = nil
local v13 = {}
local fn

local function clearRows()
	for _, connection in v11 do
		connection:Disconnect()
	end

	table.clear(v11)

	for _, child in parent:GetChildren() do
		if child.Name == "用户模版" and child ~= v8 then
			child:Destroy()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function selectTarget(p)
	local v14 = v12
	fn()

	if v14 then
		v14(p)
	end
end

local function matchesFilter(p, text: string)
	if text == "" then
		return true
	end

	local lower = text:lower()
	return p.DisplayName:lower():find(lower, 1, true) ~= nil or p.Name:lower():find(lower, 1, true) ~= nil
end

local function renderRow(player)
	local clone = v8:Clone()
	clone.Name = "用户模版"
	clone.Visible = true
	clone["头像"].Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
	clone["显示名称"].Text = player.DisplayName
	clone["用户名"].Text = "@" .. player.Name
	local v14 = clone["选择按钮"]
	local v15 = ButtonActions.Bind(v14, function()
		selectTarget(player) -- equivalent call inferred; original call site unknown
	end)
	table.insert(v11, v15)
	clone.Parent = parent
end

local function fn2()
	clearRows()
	local text = v9.Text
	local count = 0

	for _, v14 in v13 do
		if not matchesFilter(v14, text) then
			continue
		end

		renderRow(v14)
		count += 1
	end

	v10.Visible = count == 0
end

fn = function()
	v2.Visible = false
	v12 = nil
	clearRows()
end

local function startPlayerObserver()
	Observers.observePlayer(function(p)
		if p == Players.LocalPlayer then
			return
		end

		table.insert(v13, p)

		if v2.Visible then
			fn2()
		end

		return function()
			local index = table.find(v13, p)

			if index then
				table.remove(v13, index)
			end

			if v2.Visible then
				fn2()
			end
		end
	end)
end

local function open(data, callback)
	if not UI then
		return
	end

	v12 = callback
	v5.Text = data.Name
	robux.Text = v .. " " .. tostring(data.PriceInRobux)
	v6.Image = `rbxassetid://{data.IconImageAssetId}`
	v9.Text = ""
	fn2()
	v2.Visible = true
end

local function buildGui()
	UI = script:WaitForChild("赠礼UI")
	UI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	v2 = UI:WaitForChild("背景")
	v3 = v2:WaitForChild("赠礼弹窗")
	v4 = v3:WaitForChild("关闭按钮")
	local v14 = v3:WaitForChild("产品预览")
	v5 = v14:WaitForChild("产品名称")
	robux = v14:WaitForChild("Robux价格")
	v6 = v14:WaitForChild("产品图片底座")
	parent = v3:WaitForChild("用户列表")
	v8 = parent:WaitForChild("用户模版")
	v8.Visible = false
	v9 = v3:WaitForChild("搜索框"):WaitForChild("输入框")
	v10 = parent:WaitForChild("空列表提示")
	v10.Visible = false
	ButtonActions.Bind(v4, fn)
	v2.Visible = false
	v9:GetPropertyChangedSignal("Text"):Connect(fn2)
end

if RunService:IsClient() then
	buildGui()
	Observers.observePlayer(function(p)
		if p == Players.LocalPlayer then
			return
		end

		table.insert(v13, p)

		if v2.Visible then
			fn2()
		end

		return function()
			local index = table.find(v13, p)

			if index then
				table.remove(v13, index)
			end

			if v2.Visible then
				fn2()
			end
		end
	end)
end

return {
	open = open,
	close = fn
}