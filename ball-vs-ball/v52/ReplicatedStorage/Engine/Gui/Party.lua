local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local HttpService = game:GetService("HttpService")
local PartyService = require(ReplicatedStorage.Engine.Service.PartyService)
local PartyConfig = require(ReplicatedStorage.Engine.Service.PartyConfig)
local PlayerThumbnail = require(ReplicatedStorage.Engine.Service.PlayerThumbnail)
local ConfirmDialogController = require(script.Parent.ConfirmDialogController)
local Party = {}
local flag = false

function Party.Init()
	if flag then
		return
	end

	flag = true
	local localPlayer = Players.LocalPlayer
	local v = localPlayer:WaitForChild("PlayerGui"):WaitForChild("组队")
	local v2 = v:WaitForChild("背景")
	local v3 = v2:WaitForChild("面板")
	local v4 = v3:WaitForChild("队伍区域")
	local parent = v4:WaitForChild("队伍列表")
	local v6 = parent:WaitForChild("队长卡片")
	local v7 = {}

	for i = 1, PartyConfig.maxMembers - 1 do
		v7[i] = parent:WaitForChild("空位" .. i)
	end

	local v8 = v3:WaitForChild("玩家区域")
	local parent2 = v8:WaitForChild("玩家列表")
	local v10 = {
		available = parent2:WaitForChild("玩家卡片模板"),
		sending = parent2:WaitForChild("邀请中卡片模板"),
		invited = parent2:WaitForChild("已邀请卡片模板"),
		inParty = parent2:WaitForChild("已组队卡片模板"),
		targetBusy = parent2:WaitForChild("对方忙碌卡片模板"),
		selfBusy = parent2:WaitForChild("自己忙碌卡片模板"),
		transferring = parent2:WaitForChild("传送中卡片模板"),
		full = parent2:WaitForChild("队伍已满卡片模板")
	}
	local v11 = {}

	for _, v12 in v10 do
		v11[v12] = true
	end

	local function applyCardState(p, p2)
		local v12 = v10[p2]
		local v13 = p["邀请按钮"]
		local v14 = v12["邀请按钮"]

		for _, v15 in {
			"Visible",
			"BackgroundColor3",
			"BackgroundTransparency",
			"Active",
			"Interactable",
			"Selectable",
			"AutoButtonColor"
		} do
			v13[v15] = v14[v15]
		end

		v13["文字"].Text = v14["文字"].Text
		v13["文字"].TextColor3 = v14["文字"].TextColor3
		p["组队状态"].Visible = v12["组队状态"].Visible
		p["组队状态"].Text = v12["组队状态"].Text
	end

	local v12 = v8:WaitForChild("筛选栏")
	local v13 = v8:WaitForChild("搜索栏"):WaitForChild("输入框")
	local state = PartyService.client.getState()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function request(p, p2)
		return (PartyService.client.request(p, p2))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setEnabled(p, p2)
		p.Active = p2
		p.Interactable = p2
		p.Selectable = p2
		p.AutoButtonColor = p2
	end

	local v14 = {}
	local v15 = {}
	local status = {}
	local v16 = "All"
	local v17 = {}
	local flag2 = false
	local flag3 = false

	for _, guiObject in parent2:GetChildren() do
		if not guiObject:IsA("GuiObject") or v11[guiObject] or guiObject:GetAttribute("PartyListBottomSpacer") == true then
			continue
		end

		guiObject:Destroy()
	end

	for _, v18 in v10 do
		v18.Visible = false
	end

	v6.Visible = false

	for _, v18 in v7 do
		v18.Visible = false
	end

	local clones = {}
	local clones2 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clear(list)
		for _, v18 in list do
			v18:Destroy()
		end

		table.clear(list)
	end

	local function currentMembers()
		if #state.members > 0 then
			return state.members
		end

		return {
			{
				userId = localPlayer.UserId,
				name = localPlayer.DisplayName,
				username = localPlayer.Name
			}
		}
	end

	local function renderMembers()
		clear(clones) -- equivalent call inferred; original call site unknown
		local v19 = currentMembers()
		v4["人数"].Text = tostring(#v19) .. " / " .. tostring(PartyConfig.maxMembers)

		for k, v20 in v19 do
			local clone = v6:Clone()
			clone.Name = "成员_" .. v20.userId
			clone.LayoutOrder = k
			clone.Visible = true
			clone.Parent = parent
			clone["显示名"].Text = v20.name
			clone["用户名"].Text = "@" .. v20.username
			clone["身份"].Text = not state.formed and "You" or k == 1 and "Leader" or "Member"
			PlayerThumbnail.applyAsync(clone["头像"], v20.userId)
			local v21 = clone["成员操作按钮"]
			local v22 = v20.userId == localPlayer.UserId
			v21.Visible = state.formed == true and (v22 or state.leaderId == localPlayer.UserId)
			v21.Text = v22 and "Leave" or "Remove"
			setEnabled(v21, not state.transferring and localPlayer:GetAttribute("ModeTeleportPending") ~= true) -- equivalent call inferred; original call site unknown
			local v27 = v20
			ButtonActions.Bind(v21, function()
				if not v21.Active then
					return
				end

				local v29

				if not v22 then
					v29 = v27.userId
				end

				PartyService.client.request(v22 and "leave" or "kick", v29)
			end)
			table.insert(clones, clone)
		end

		for i = #v19 + 1, PartyConfig.maxMembers do
			local clone = v7[math.min(i - 1, #v7)]:Clone()
			clone.Name = "空位_" .. i
			clone.LayoutOrder = i
			clone.Visible = true
			clone.Parent = parent
			table.insert(clones, clone)
		end
	end

	local renderPlayers

	renderPlayers = function()
		clear(clones2) -- equivalent call inferred; original call site unknown
		local v19 = {}
		local v20 = {}
		local v21 = {}

		for _, v22 in currentMembers() do
			v19[v22.userId] = true
		end

		for _, localPlayer2 in Players:GetPlayers() do
			if v19[localPlayer2.UserId] then
				continue
			end

			v20[#v20 + 1] = {
				id = localPlayer2.UserId,
				name = localPlayer2.DisplayName,
				username = localPlayer2.Name,
				localPlayer = localPlayer2,
				friend = v14[localPlayer2.UserId] == true,
				inParty = localPlayer2:GetAttribute("PartyId") ~= nil,
				busy = PartyService.isBusy(localPlayer2)
			}
			v21[localPlayer2.UserId] = true
		end

		for _, v22 in v15 do
			local visitorId = v22.VisitorId

			if type(visitorId) ~= "number" or (v21[visitorId] or v19[visitorId]) then
				continue
			end

			local v23 = status[tostring(visitorId)] or {}
			v20[#v20 + 1] = {
				id = visitorId,
				name = v22.DisplayName or v22.UserName,
				username = v22.UserName,
				friend = true,
				inParty = v23.inParty == true,
				busy = v23.busy == true
			}
			v21[visitorId] = true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function priority(data)
			if data.localPlayer and data.friend then
				return 1
			end

			if data.localPlayer and not data.inParty then
				return 2
			end

			if data.localPlayer then
				return 4
			end

			return 3
		end

		table.sort(v20, function(a, b)
			local v22 = priority(a) -- equivalent call inferred; original call site unknown
			local v23 = priority(b) -- equivalent call inferred; original call site unknown

			if v22 ~= v23 then
				return v22 < v23
			end

			local name = string.lower(a.name or "")
			local name2 = string.lower(b.name or "")

			if name == name2 then
				return a.id < b.id
			end

			return name < name2
		end)
		local text = string.lower(v13.Text)

		for _, v22 in v20 do
			if not (text == "" or string.find(string.lower(v22.name or ""), text, 1, true) or string.find(
				string.lower(v22.username or ""),
				text,
				1,
				true
			)) then
				continue
			end

			if not (v16 == "All" or v16 == "Friends" and v22.friend or v16 == "Lobby" and v22.localPlayer) then
				continue
			end

			local clone = v10[v22.inParty and "inParty" or v22.busy and "targetBusy" or PartyService.isBusy(localPlayer) and "selfBusy" or state.transferring and "transferring" or #currentMembers() >= PartyConfig.maxMembers and "full" or v17[v22.id] or "available"]:Clone()
			clone.Name = "玩家_" .. v22.id
			clone.LayoutOrder = #clones2 + 1
			clone.Visible = true
			clone.Parent = parent2
			clone["显示名"].Text = v22.name
			clone["用户名"].Text = "@" .. (v22.username or "")
			PlayerThumbnail.applyAsync(clone["头像"], v22.id)
			local v24 = clone["邀请按钮"]
			local v25 = v17[v22.id] ~= nil
			local v27 = v22
			ButtonActions.Bind(v24, function()
				if not v24.Active or v25 or v17[v27.id] ~= nil then
					return
				end

				v25 = true
				v17[v27.id] = "sending"
				applyCardState(clone, "sending")
				task.spawn(function()
					local token = nil

					local function log(p, value, p2)
						local v29 = tostring(value or "")

						if token then
							v29 = string.gsub(v29, string.gsub(token, "(%W)", "%%%1"), "[redacted]")
						end

						local v30 = string.format("[PartyInvite] target=%s stage=%s %s", tostring(v27.id), p, v29)

						if p2 then
							warn(v30)
						else
							print(v30)
						end
					end

					-- equivalent calls inferred from this helper; original call sites unknown
					local function reset()
						v25 = false
						v17[v27.id] = nil

						if flag2 then
							renderPlayers()
						end
					end

					-- equivalent calls inferred from this helper; original call sites unknown
					local function fail(p, p2, result)
						log(p, result or p2, true)
						reset() -- equivalent call inferred; original call site unknown
					end

					local success, result = pcall(function()
						log("request", "开始请求")
						local v29 = request("invite", v27.id) -- equivalent call inferred; original call site unknown

						if type(v29) == "table" and v29.ok then
							token = v29.token
							log("request", v29.localInvite and "已投递同服邀请" or "跨服邀请已批准")

							if v29.localInvite then
								v17[v27.id] = "invited"

								if flag2 then
									renderPlayers()
								end
							else
								local success2, result2 = pcall(function()
									return SocialService:CanSendGameInviteAsync(localPlayer)
								end)
								local v32

								if success2 then
									v32 = "returned " .. tostring(result2)
								else
									v32 = result2
								end

								log("eligibility-general", v32, not (success2 and result2))
								local success3, result3 = pcall(function()
									return SocialService:CanSendGameInviteAsync(localPlayer, v27.id)
								end)
								local v35

								if success3 then
									v35 = "returned " .. tostring(result3)
								else
									v35 = result3
								end

								log("eligibility-recipient", v35, not (success3 and result3))

								if success3 then
									if result3 then
										log("eligibility", "通过")

										if type(v29.token) == "string" and v29.token ~= "" then
											local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
											experienceInviteOptions.InviteUser = v27.id
											experienceInviteOptions.PromptMessage = "Invite this friend to your party!"
											experienceInviteOptions.LaunchData = HttpService:JSONEncode({
												partyInvite = v29.token
											})
											local success4, result4 = pcall(function()
												SocialService:PromptGameInvite(localPlayer, experienceInviteOptions)
											end)

											if success4 then
												log("prompt", "调用完成；发送结果未确认")
											else
												fail("prompt", "无法打开 Roblox 邀请窗口，请稍后再试", result4) -- equivalent call inferred; original call site unknown
												return
											end
										else
											fail("ticket", "邀请凭证无效，请重新邀请") -- equivalent call inferred; original call site unknown
											return
										end
									else
										fail("eligibility", "returned false") -- equivalent call inferred; original call site unknown
										return
									end
								else
									fail("eligibility", "邀请资格查询失败，请稍后再试", result3) -- equivalent call inferred; original call site unknown
									return
								end
							end

							task.delay(PartyConfig.inviteCooldownSeconds, reset)
						else
							fail("request", type(v29) ~= "table" and "邀请失败，请稍后再试" or v29.reason or "邀请失败，请稍后再试") -- equivalent call inferred; original call site unknown
						end
					end)

					if not success then
						fail("unexpected", "邀请失败，请稍后再试", result) -- equivalent call inferred; original call site unknown
					end
				end)
			end)
			table.insert(clones2, clone)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function render()
		renderMembers()

		if flag2 then
			renderPlayers()
		end
	end

	local function refreshFriends()
		if flag3 then
			return
		end

		flag3 = true
		local success, friendsOnlineAsync = pcall(localPlayer.GetFriendsOnlineAsync, localPlayer, 200)

		if success then
			v15 = friendsOnlineAsync
		end

		local v18 = {}

		for _, v19 in v15 do
			v18[v19.VisitorId] = true
		end

		for _, v19 in Players:GetPlayers() do
			if v19 == localPlayer then
				continue
			end

			local success2, result = pcall(localPlayer.IsFriendsWithAsync, localPlayer, v19.UserId)

			if success2 and result then
				v18[v19.UserId] = true
			end
		end

		v14 = v18
		local visitorIds = {}

		for _, v19 in v15 do
			if not Players:GetPlayerByUserId(v19.VisitorId) then
				table.insert(visitorIds, v19.VisitorId)
			end
		end

		if #visitorIds > 0 then
			local v19 = request("status", visitorIds) -- equivalent call inferred; original call site unknown

			if v19.ok then
				status = v19.status
			end
		end

		flag3 = false

		if flag2 then
			renderPlayers()
		end
	end

	function Party.Open()
		flag2 = true
		v.Enabled = true
		v2.Visible = true
		render() -- equivalent call inferred; original call site unknown
		task.spawn(refreshFriends)
	end

	function Party.Close()
		flag2 = false
		v2.Visible = false
		v.Enabled = false
	end

	ButtonActions.Bind(v3["关闭按钮"], Party.Close)

	for k, v18 in {
		["全部按钮"] = "All",
		["好友按钮"] = "Friends",
		["大厅按钮"] = "Lobby"
	} do
		local v19 = v12[k]
		local v20 = v18
		ButtonActions.Bind(v19, function()
			v16 = v20

			for k2, v21 in {
				["全部按钮"] = "All",
				["好友按钮"] = "Friends",
				["大厅按钮"] = "Lobby"
			} do
				local v22 = v12[k2]
				local v23 = v21 == v20
				local backgroundColor

				if v23 then
					backgroundColor = Color3.fromRGB(245, 245, 247)
				else
					backgroundColor = Color3.fromRGB(29, 32, 40)
				end

				v22.BackgroundColor3 = backgroundColor
				local v25 = v22["文字"]
				local textColor

				if v23 then
					textColor = Color3.fromRGB(29, 32, 40)
				else
					textColor = Color3.fromRGB(245, 245, 247)
				end

				v25.TextColor3 = textColor
			end

			renderPlayers()
		end)
	end

	v13:GetPropertyChangedSignal("Text"):Connect(function()
		if flag2 then
			renderPlayers()
		end
	end)
	PartyService.client.Changed:Connect(function(p)
		state = p
		render() -- equivalent call inferred; original call site unknown
	end)
	local v18 = {}
	PartyService.client.Invited:Connect(function(data)
		if data.cancelToken then
			local v19 = v18[data.cancelToken]

			if v19 then
				v19.finished = true
				ConfirmDialogController.Cancel(v19.id)
				v18[data.cancelToken] = nil
			end
		else
			local v19 = {
				connections = {},
				finished = false
			}
			v18[data.token] = v19

			-- equivalent calls inferred from this helper; original call sites unknown
			local function cleanup()
				for _, connection in v19.connections do
					connection:Disconnect()
				end

				table.clear(v19.connections)
			end

			v19.id = ConfirmDialogController.Enqueue("确认组队面板", {
				category = "party",
				priority = 5,
				onShown = function(data2, callback)
					if v19.finished or data.expires <= workspace:GetServerTimeNow() then
						task.defer(callback)
						return
					end

					data2["玩家名字"].Text = data.inviterName
					PlayerThumbnail.applyAsync(data2["图片"], data.inviterId)

					local function respond(accept)
						if v19.finished then
							return
						end

						v19.finished = true
						task.spawn(function()
							local v20 = {
								token = data.token,
								accept = accept
							}
							PartyService.client.request("respond", v20)
						end)
						callback()
					end

					table.insert(v19.connections, ConfirmDialogController.BindButton(data2["接受按钮"], "A", function()
						if v19.finished then
							return
						end

						v19.finished = true
						local accept = true
						task.spawn(function()
							local v21 = {
								token = data.token,
								accept = accept
							}
							PartyService.client.request("respond", v21)
						end)
						callback()
					end))
					table.insert(v19.connections, ConfirmDialogController.BindButton(data2["拒绝按钮"], "B", function()
						if v19.finished then
							return
						end

						v19.finished = true
						local accept = false
						task.spawn(function()
							local v21 = {
								token = data.token,
								accept = accept
							}
							PartyService.client.request("respond", v21)
						end)
						callback()
					end))
				end,
				onHidden = cleanup
			})
			task.delay(math.max(0, data.expires - workspace:GetServerTimeNow()), function()
				v19.finished = true
				ConfirmDialogController.Cancel(v19.id)
				cleanup() -- equivalent call inferred; original call site unknown
				v18[data.token] = nil
			end)
		end
	end)

	local function watch(object)
		for _, v19 in {
			"PartyId",
			"InDuelTable",
			"InTrade",
			"ModeTeleportPending"
		} do
			object:GetAttributeChangedSignal(v19):Connect(function()
				if flag2 then
					renderPlayers()
				end
			end)
		end
	end

	Players.PlayerAdded:Connect(function(player)
		watch(player)

		if flag2 then
			renderPlayers()
			task.spawn(refreshFriends)
		end
	end)
	Players.PlayerRemoving:Connect(function()
		task.defer(function()
			if flag2 then
				renderPlayers()
			end
		end)
	end)

	for _, v19 in Players:GetPlayers() do
		watch(v19)
	end

	task.spawn(function()
		local request2 = PartyService.client.request("state")

		if request2.ok then
			state = request2.state
			renderMembers()
		end

		while true do
			task.wait(30)

			if flag2 then
				refreshFriends()
			end
		end
	end)
	Party.Close()
	renderMembers()
end

return Party