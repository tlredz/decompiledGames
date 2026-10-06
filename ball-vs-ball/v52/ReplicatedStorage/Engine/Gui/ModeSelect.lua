local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LoadingBattleAnimation = require(ReplicatedFirst:WaitForChild("LoadingScreen"):WaitForChild("LoadingBattleAnimation"))
local PlayerThumbnail = require(ReplicatedStorage.Engine.Service.PlayerThumbnail)
local Net = require(ReplicatedStorage.Packages.Net)
local ServerTypeService = require(ReplicatedStorage.Engine.Service.ServerTypeService)
local remoteEvent = Net:RemoteEvent("ModeTeleportRequest")
local remoteEvent2 = Net:RemoteEvent("ModeTeleportFeedback")
local PartyService = require(ReplicatedStorage.Engine.Service.PartyService)
local ModeSelect = {}
local flag = false

function ModeSelect.Init()
	if flag then
		return
	end

	flag = true
	local localPlayer = Players.LocalPlayer
	task.spawn(function()
		local v = ReplicatedStorage:WaitForChild("模式传送门", 15)
		local parent = workspace:WaitForChild("大厅", 15)

		if not (v and parent) then
			return
		end

		local ServerTeleport = require(ReplicatedStorage.Packages.ServerTeleport)
		local v3 = v:WaitForChild("悬浮UI"):WaitForChild("框"):WaitForChild("标题")
		local serverType = ServerTeleport.getServerType()

		if serverType == ServerTypeService.TWO_V_TWO_POOL_NAME then
			v3.Text = "1V1"
		elseif serverType == "standard" then
			v3.Text = "2V2"
		end

		local function syncModePortal()
			local v4 = v
			local parent2

			if parent.Parent == workspace then
				parent2 = parent
			else
				parent2 = ReplicatedStorage
			end

			v4.Parent = parent2
		end

		parent.AncestryChanged:Connect(syncModePortal)

		if parent.Parent ~= workspace then
			parent = ReplicatedStorage
		end

		v.Parent = parent
	end)
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local v = playerGui:WaitForChild("模式选择")
	local v2 = v:WaitForChild("未选中动效速度倍率")
	local v3 = v:WaitForChild("背景")
	local v4 = v3:WaitForChild("全屏画布")
	local v5 = v4:WaitForChild("模式列表")
	local v6 = playerGui:WaitForChild("下方按钮区"):WaitForChild("区域"):WaitForChild("下方区域")
	local v7 = v6:FindFirstChild("切换模式按钮", true) or v6:WaitForChild("切换模式按钮")
	local v8 = v4:WaitForChild("关闭按钮")
	local v9 = v4:WaitForChild("标题")
	local text = v9.Text
	local v10 = v4:WaitForChild("我的队伍"):WaitForChild("成员列表"):WaitForChild("成员模板"):WaitForChild("玩家头像")
	v3.Visible = false
	v3.Active = true
	v3.InputSink = Enum.InputSink.All
	v.Enabled = false
	PlayerThumbnail.applyAsync(v10, localPlayer.UserId)
	local flag2 = false
	local flag3 = false
	local v11 = nil
	local ConfirmDialogController = require(script.Parent.ConfirmDialogController)

	local function showPortalDialog(p: string, text2: string?)
		local connection = nil
		v11 = ConfirmDialogController.Show(p, {
			category = "Teleport",
			onShown = function(instance, callback)
				if text2 then
					local waitForChild = instance:WaitForChild("文本")
					waitForChild.Text = text2
				end

				local button = instance:FindFirstChild("确定按钮", true)

				if button and button:IsA("GuiButton") then
					connection = ConfirmDialogController.BindButton(button, "A", callback)
				end
			end,
			onHidden = function()
				if connection then
					connection:Disconnect()
					connection = nil
				end
			end
		})
	end

	local heartbeatConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopTeleportTitle()
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end

	local function startTeleportTitle()
		if heartbeatConnection or not (flag2 and flag3) then
			return
		end

		local v12 = {
			".",
			"..",
			"...",
			".."
		}
		local total = 0
		v9.Text = "Teleporting..."
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			total += dt
			v9.Text = "Teleporting" .. v12[(math.floor(total / 0.35) + 2) % #v12 + 1]
		end)
	end

	local v12 = {}
	local connections = {}
	local v13 = {}
	local v14 = {}
	local v15 = {}
	local v16 = {}
	local v17 = {}
	local v18 = {}
	local children = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function pauseAnimation(k)
		local v19 = v13[k]

		if v19 then
			v19.pause()
		end
	end

	local function syncAnimations()
		local v19 = nil

		for _, v21 in children do
			if next(v16[v21]) == nil then
				continue
			end

			v19 = v21
			break
		end

		if not v19 then
			for _, v22 in children do
				if not v18[v22] then
					continue
				end

				v19 = v22
				break
			end
		end

		if not v19 then
			for _, v22 in children do
				if not v17[v22] then
					continue
				end

				v19 = v22
				break
			end
		end

		for _, v21 in children do
			local enabled = flag2 and v19 == v21
			v14[v21].Enabled = not enabled
			v15[v21].Enabled = enabled

			if not flag2 then
				continue
			end

			local v23 = v13[v21]

			if not v23 then
				v23 = LoadingBattleAnimation.start(v21:WaitForChild("对战区域"))
				v13[v21] = v23
			end

			v23.resume()
			v23.setSpeedMultiplier(enabled and 1 or v2.Value)
		end
	end

	local function hideOtherGui(screenGui)
		if screenGui == v or screenGui.Name == "组队" or screenGui.Name == "通用确认框" or screenGui.Name == "ScreenNotifyGui" or v12[screenGui] ~= nil then
			return
		end

		v12[screenGui] = screenGui.Enabled
		screenGui.Enabled = false
		table.insert(connections, screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
			if flag2 and screenGui.Enabled then
				screenGui.Enabled = false
			end
		end))
	end

	local function close()
		if not flag2 then
			return
		end

		flag2 = false
		stopTeleportTitle() -- equivalent call inferred; original call site unknown

		for k in v13 do
			pauseAnimation(k) -- equivalent call inferred; original call site unknown
		end

		for k in v16 do
			table.clear(v16[k])
			v17[k] = false
			v18[k] = false
			v14[k].Enabled = true
			v15[k].Enabled = false
		end

		v3.Visible = false
		v.Enabled = false

		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)

		for k, enabled in v12 do
			if k.Parent then
				k.Enabled = enabled
			end

			v12[k] = nil
		end
	end

	local function open()
		if flag2 then
			return
		end

		flag2 = true

		if flag3 then
			startTeleportTitle()
		else
			v9.Text = localPlayer:GetAttribute("PartyId") and localPlayer:GetAttribute("PartyLeaderId") ~= localPlayer.UserId and "Only the party leader can teleport the team." or text
		end

		for _, screenGui in playerGui:GetDescendants() do
			if screenGui:IsA("ScreenGui") then
				hideOtherGui(screenGui)
			end
		end

		table.insert(connections, playerGui.DescendantAdded:Connect(function(screenGui)
			if screenGui:IsA("ScreenGui") then
				hideOtherGui(screenGui)
			end
		end))
		v.Enabled = true
		v3.Visible = true
		syncAnimations()
	end

	for _, childName in { "单人模式", "组队模式" } do
		local child = v5:WaitForChild(childName)
		local v19 = child:WaitForChild("边框")
		local v20 = child:WaitForChild("高亮描边")
		v19.Enabled = true
		v20.Enabled = false
		v14[child] = v19
		v15[child] = v20
		table.insert(children, child)
		v16[child] = {}
		child.MouseEnter:Connect(function()
			v17[child] = true
			syncAnimations()
		end)
		local v22 = child
		child.MouseLeave:Connect(function()
			v17[v22] = false
			syncAnimations()
		end)
		local v23 = child
		child.SelectionGained:Connect(function()
			v18[v23] = true
			syncAnimations()
		end)
		local v24 = child
		child.SelectionLost:Connect(function()
			v18[v24] = false
			syncAnimations()
		end)
		local v25 = child
		child.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				v16[v25][input] = true
				syncAnimations()
			end
		end)
		local v26 = childName
		ButtonActions.Bind(child, function()
			if flag3 then
				return
			end

			if localPlayer:GetAttribute("PartyId") and localPlayer:GetAttribute("PartyLeaderId") ~= localPlayer.UserId then
				v9.Text = "Only the party leader can teleport the team."
				return
			end

			flag3 = true
			startTeleportTitle()
			remoteEvent:FireServer(v26 ~= "组队模式" and "standard" or ServerTypeService.TWO_V_TWO_POOL_NAME)
		end)
	end

	remoteEvent2.OnClientEvent:Connect(function(p: string, value)
		if p == "teleporting" then
			flag3 = true

			for _, v19 in children do
				v19.Interactable = false
				v19.Active = false
			end

			startTeleportTitle()

			if not flag2 then
				showPortalDialog("传送中面板", nil)
			end
		else
			flag3 = false

			if v11 then
				ConfirmDialogController.Cancel(v11)
				v11 = nil
			end

			if p == "locked" then
				showPortalDialog("2V2解锁条件面板", "2V2 unlocks at Lv " .. tostring(value or "--"))
			elseif not flag2 then
				showPortalDialog(
					"模式传送提示面板",
					p == "leaderOnly" and "Only the party leader can teleport the team." or p ~= "busy" and "Teleport failed. Please try again." or tostring(value or "A party member") .. " is busy."
				)
			end

			stopTeleportTitle() -- equivalent call inferred; original call site unknown
			local v19 = localPlayer:GetAttribute("PartyId") and localPlayer:GetAttribute("PartyLeaderId") ~= localPlayer.UserId

			for _, v20 in children do
				v20.Interactable = not v19
				v20.Active = not v19
			end

			local v20 = v9
			local text2

			if p == "leaderOnly" then
				text2 = "Only the party leader can teleport the team."
			elseif p == "busy" then
				text2 = tostring(value or "A party member") .. " is battling or trading."
			else
				text2 = p ~= "locked" and "Teleport failed. Please try again." or "2V2 unlocks at Lv " .. tostring(value or "--")
			end

			v20.Text = text2
		end
	end)
	v2:GetPropertyChangedSignal("Value"):Connect(syncAnimations)
	UserInputService.InputEnded:Connect(function(input)
		for _, v19 in v16 do
			if not v19[input] then
				continue
			end

			v19[input] = nil
			syncAnimations()
		end
	end)
	local parent3 = v4:WaitForChild("我的队伍"):WaitForChild("成员列表")
	local v20 = parent3:WaitForChild("成员模板")
	local v21 = { parent3:WaitForChild("添加成员按钮"), parent3:WaitForChild("添加成员按钮2"), (parent3:WaitForChild("添加成员按钮3")) }
	local v22 = v4:WaitForChild("我的队伍"):WaitForChild("队伍人数")
	local clones = {}

	local function syncParty()
		local state = PartyService.client.getState()
		local members

		if #state.members > 0 then
			members = state.members
		else
			members = {
				{
					userId = localPlayer.UserId
				}
			}
		end

		for _, v23 in clones do
			v23:Destroy()
		end

		table.clear(clones)
		v20.Visible = false

		for k, member in members do
			local clone = v20:Clone()
			clone.Name = "成员_" .. tostring(member.userId)
			clone.Visible = true
			clone.LayoutOrder = k
			clone.Parent = parent3
			PlayerThumbnail.applyAsync(clone:WaitForChild("玩家头像"), member.userId)
			local v23 = clone:WaitForChild("队长皇冠")
			v23.Visible = v23.Image ~= "" and member.userId == (state.leaderId or members[1].userId)
			table.insert(clones, clone)
		end

		v22.Text = tostring(#members) .. "/4"

		for k, v23 in v21 do
			v23.LayoutOrder = #members + k
			v23.Visible = k <= 4 - #members
			v23.Active = not flag3
			v23.Interactable = not flag3
		end

		local v23

		if state.formed == true then
			v23 = state.leaderId ~= localPlayer.UserId
		else
			v23 = false
		end

		for _, v24 in children do
			v24.Interactable = not (v23 or flag3)
			v24.Active = not (v23 or flag3)
		end

		if not flag3 then
			v9.Text = v23 and "Only the party leader can teleport the team." or text
		end
	end

	PartyService.client.Changed:Connect(syncParty)
	localPlayer:GetAttributeChangedSignal("PartyLeaderId"):Connect(syncParty)

	for _, v23 in v21 do
		local v24 = v23
		ButtonActions.Bind(v23, function()
			if not v24.Active or flag3 then
				return
			end

			local Party = require(script.Parent.Party)
			Party.Init()
			Party.Open()
		end)
	end

	syncParty()
	ModeSelect.Open = open
	ModeSelect.Close = close
	ButtonActions.Bind(v7, function()
		if not v7.Active then
			return
		end

		open()
	end)
	ButtonActions.Bind(v8, close)
	ProximityPromptService.PromptTriggered:Connect(function(player, p)
		if p ~= localPlayer then
			return
		end

		local firstChild = workspace:FindFirstChild("大厅")
		local v23 = firstChild and firstChild:FindFirstChild("模式传送门")
		local v24 = v23 and v23:FindFirstChild("交互点")

		if v24 and player.Parent == v24 and player.Name == "ProximityPrompt" then
			open()
		end
	end)
end

return ModeSelect