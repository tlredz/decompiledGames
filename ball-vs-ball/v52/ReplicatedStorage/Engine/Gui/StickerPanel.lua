local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local StickerService = require(ReplicatedStorage.Engine.Service.StickerService)
local StickerEffects = require(ReplicatedStorage.Engine.Service.StickerEffects)
local SettingsService = require(ReplicatedStorage.Engine.Service.SettingsService)
local client2 = SettingsService.client
local GamepadPages = require(ReplicatedStorage.Engine.Service.GamepadSupport.GamepadPages)
local ButtonHints = require(ReplicatedStorage.Engine.Service.GamepadSupport.ButtonHints)
local flag = false
local v = nil
local v2 = nil
local StickerPanel = {}

function StickerPanel.SetTopbarEnabled(visible: boolean)
	if not v then
		return
	end

	if not visible and v2 then
		v2(false)
	end

	v.Visible = visible
end

function StickerPanel.Init()
	if flag then
		return
	end

	flag = true
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local waitForChild = playerGui:WaitForChild("贴纸素材"):WaitForChild("素材面板")
	waitForChild.Visible = false
	local v3 = playerGui:WaitForChild("贴纸"):WaitForChild("布局容器")
	v = v3
	local v4 = v3:WaitForChild("贴纸入口")
	local v5 = v3:WaitForChild("快捷贴纸面板")
	local v6 = v5:WaitForChild("标题图标")
	local v7 = v5:WaitForChild("声音按钮")
	local v8 = v7:WaitForChild("图标")
	local v9 = v5:WaitForChild("关闭按钮")
	local v10 = v5:WaitForChild("贴纸格子")
	local children = {}
	local v11 = {}
	local v12 = {}

	for i = 1, 6 do
		local child = v10:WaitForChild("贴纸格子" .. i)
		children[i] = child
		local firstChild = child:FindFirstChild("重刷按钮")

		if firstChild then
			firstChild.Visible = false
		end
	end

	local visible = false
	GamepadPages.Observe(v3, {
		base = true,
		available = function()
			return not visible
		end
	})
	GamepadPages.Observe(v5, {
		available = function()
			return visible
		end
	})
	ButtonHints.Shortcut(v4, "R1")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setExpanded(flag2: boolean)
		visible = flag2
		v5.Visible = visible
	end

	v2 = setExpanded

	local function refreshSlots()
		local stickers = client.stickers()

		for i = 1, 6 do
			local v14 = children[i]
			local firstChild = v14:FindFirstChild("贴纸符号")
			local firstChild2 = v14:FindFirstChild("贴纸图片")
			local v15

			if typeof(stickers) == "table" then
				v15 = stickers[i]
			else
				v15 = false
			end

			local v16 = v15 and Config.skin.byCnId[v15]
			local v17 = v16 and StickerEffects.getVisual(v16.cnId)

			if v16 and v17 then
				firstChild.Text = v17.symbolText
				firstChild.Visible = v17.symbolVisible

				if firstChild2 then
					firstChild2.Image = v17.image
					firstChild2.Visible = v17.imageVisible
				end

				v11[i] = v16.cnId
				v14.AutoButtonColor = true
			else
				firstChild.Text = ""
				firstChild.Visible = true

				if firstChild2 then
					firstChild2.Image = ""
					firstChild2.Visible = false
				end

				v11[i] = nil
				v14.AutoButtonColor = false
			end
		end
	end

	for i = 1, 6 do
		local v14 = children[i]
		local v15 = i
		ButtonActions.Bind(v14, function()
			local v17 = v11[v15]

			if not v17 then
				return
			end

			local now = os.clock()

			if now < (v12[v15] or 0) then
				return
			end

			v12[v15] = now + 1
			v14.Active = false
			task.delay(1, function()
				v14.Active = true
			end)
			StickerService.client.send(v15, v17)
		end)
	end

	ButtonActions.Bind(v4, function()
		visible = not visible
		v5.Visible = visible
	end)
	ButtonActions.Bind(v6, function()
		setExpanded(false) -- equivalent call inferred; original call site unknown
	end)
	ButtonActions.Bind(v9, function()
		setExpanded(false) -- equivalent call inferred; original call site unknown
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshSoundIcon(flag2: boolean)
		v8.ImageTransparency = flag2 and 0 or 0.6
	end

	refreshSoundIcon(client.settings.soundEffectsEnabled() ~= false) -- equivalent call inferred; original call site unknown
	client.settings.soundEffectsEnabled.Changed(function(flag2: boolean)
		refreshSoundIcon(flag2) -- equivalent call inferred; original call site unknown
	end)
	ButtonActions.Bind(v7, function()
		client2.setSoundEffectsEnabled(client.settings.soundEffectsEnabled() == false)
	end)
	refreshSlots()
	client.stickers.Changed(refreshSlots)
	setExpanded(false) -- equivalent call inferred; original call site unknown
	v3.Visible = false
end

return StickerPanel