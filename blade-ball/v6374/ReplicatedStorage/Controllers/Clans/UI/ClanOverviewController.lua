local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TextService")
local v = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v3 = require3(script.Parent.Parent.ClanController)
local v4 = require3(script.Parent.ClanPagesController)
local v5 = require3(script.Parent.ClanPopupController)
local v6 = require3(ReplicatedStorage2.Shared.ClansData)
local v7 = require3(ReplicatedStorage2.Shared.ClansUpgradeData)
local v8 = require3(ReplicatedStorage2.Shared.ClansActivityData)
local v9 = require3(ReplicatedStorage2.Shared.ClansRankData)
local v10 = require3(ReplicatedStorage2.Shared.PlayerUtility)
local v11 = require3(ReplicatedStorage2.Shared.PlayerNameUtility)
local spring = require3(ReplicatedStorage2.Common.Utils).Spring
local v12 = require3(ReplicatedStorage2.Shared.ReplionUtils)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v13 = require3(script.Dropdown)
local v14 = {
	Online = Color3.fromRGB(170, 255, 127),
	Offline = Color3.fromRGB(153, 153, 153)
}
local maid = v2.new()
local maid2 = v2.new()
local localPlayer = Players.LocalPlayer
local clanGui = v4.ClanGui
local pages = clanGui.Pages
local main = pages.Overview.Main
local main2 = pages.ManageMember.Main
local buttons = main2.Buttons
local selectedOption = "Status"
local cache2 = {}
local template = main.MembersScroll.UIListLayout.Template

local function formatOfflineTime(lastOnline: number)
	local v16 = workspace:GetServerTimeNow() - lastOnline

	if v16 >= 86400 then
		return (`{math.ceil(v16 / 86400)} DAY(S) AGO`)
	end

	if v16 >= 3600 then
		local v17 = math.ceil(v16 / 3600)
		return (`{v17} HOUR{v17 > 1 and "S" or ""} AGO`)
	end

	if v16 >= 60 then
		local v17 = math.max(1, (math.ceil(v16 / 60)))
		return (`{v17} MINUTE{v17 > 1 and "S" or ""} AGO`)
	end

	local v17 = math.round(v16)
	return (`{v17} SECOND{math.round(v17) > 1 and "S" or ""} AGO`)
end

local ClanOverviewController = {}

function ClanOverviewController:ManageMember(p)
	if v4:IsOpen("ManageMember") then
		return
	end

	local clanReplion = v3.ClanReplion

	if not clanReplion then
		return
	end

	local info = clanReplion.Data.Info
	local rank = v9.getRank(localPlayer, info)
	local permissionFor = v9.hasPermissionFor(localPlayer, "KICK_MEMBERS", info)
	local visible = rank == "Owner"

	if not (permissionFor or visible) then
		return
	end

	local members = info.members

	if not table.find(members, p) or v6.getFormattedUserId(localPlayer) == p then
		return
	end

	local index = table.find(v9.Ranks, rank) or 1
	local rank2 = v9.getRank(p, info)
	local index2 = table.find(v9.Ranks, rank2) or 1

	if index <= index2 then
		ReplicatedStorage2.Misc.error:Play()
		return
	end

	local rank3 = v9.Ranks[index2 + 1]
	local rank4 = v9.Ranks[index2 - 1]
	local visible2

	if rank3 then
		if rank3 == "Owner" then
			visible2 = false
		else
			visible2 = visible
		end
	else
		visible2 = rank3
	end

	if rank4 == nil then
		visible = false
	end

	maid2:AddPromise(v10:GetUser((v6.parseUserId(p)))):andThen(function(player)
		if typeof(player) == "Instance" and player:IsA("Player") then
			main2.Username.Text = `{v11:GetHumanoidName(player, false)}`
		else
			main2.Username.Text = `{v11:GetUserName(player)}`
		end
	end):catch(function()
		main2.Username.Text = "[Failed to load]"
	end)
	buttons.Promote.Visible = visible2
	buttons.Demote.Visible = visible
	buttons.Kick.Visible = permissionFor
	maid2:Add(main2.Close.Activated:Connect(function()
		v4:RemovePage("ManageMember")
	end))

	if visible then
		maid2:Add(buttons.Demote.Activated:Connect(function()
			if not v5:Prompt({
				title = "DEMOTE MEMBER",
				text = "Are you sure you want to demote this member?",
				returnTo = "Overview"
			}) then
				return
			end

			if not v:Invoke("ClanUpdatePlayerRank", p, rank4) then
				ReplicatedStorage2.Misc.error:Play()
			end

			v4:RemovePage("ManageMember")
		end))
	end

	if visible2 then
		maid2:Add(buttons.Promote.Activated:Connect(function()
			if not v5:Prompt({
				title = "PROMOTE MEMBER",
				text = "Are you sure you want to promote this member?",
				returnTo = "Overview"
			}) then
				return
			end

			if not v:Invoke("ClanUpdatePlayerRank", p, rank3) then
				ReplicatedStorage2.Misc.error:Play()
			end

			v4:RemovePage("ManageMember")
		end))
	end

	if permissionFor then
		maid2:Add(buttons.Kick.Activated:Connect(function()
			if not v5:Prompt({
				title = "KICK MEMBER",
				text = "Are you sure you want to kick this member?",
				returnTo = "Overview"
			}) then
				return
			end

			if not v:Invoke("ClanKickPlayer", p) then
				ReplicatedStorage2.Misc.error:Play()
			end
		end))
	end

	v4:PushPage("ManageMember")
end

function ClanOverviewController:RenderMembers(data)
	local clone = table.clone(data.clanInfo.members)
	local clanContributions = data.clanInfo.clanContributions or {}
	local clanMemberStatuses = data.clanInfo.clanMemberStatuses or {}
	local v16 = {}

	if clanMemberStatuses then
		for _, clanMemberStatus in clanMemberStatuses do
			local v17 = string.split(clanMemberStatus, ":")
			local v18 = v17[1]
			v16[v18] = {}
			table.remove(v17, 1)

			for _, v19 in v17 do
				local v20 = string.split(v19, "/")

				if v20[1] == "Online" then
					if v20[2] == "false" then
						v16[v18][v20[1]] = false
					else
						v16[v18][v20[1]] = true
					end
				else
					v16[v18][v20[1]] = tonumber(v20[2])
				end
			end
		end
	end

	if data.sortOrder == "Status" then
		table.sort(clone, function(a, b)
			local userId = v6.parseUserId(a)
			local userId2 = v6.parseUserId(b)
			local playerByUserId = Players:GetPlayerByUserId(userId)
			local playerByUserId2 = Players:GetPlayerByUserId(userId2)

			if playerByUserId and not playerByUserId2 then
				return true
			end

			if not playerByUserId and playerByUserId2 then
				return false
			end

			local v17 = v16[userId]
			local v18 = v16[userId2]
			local online

			if v17 then
				online = v17.Online
			else
				online = false
			end

			local v19 = not v17 and 0 or v17.LastOnline
			local online2

			if v18 then
				online2 = v18.Online
			else
				online2 = false
			end

			local v20 = not v18 and 0 or v18.LastOnline

			if online ~= online2 then
				return online and not online2
			end

			if v19 and v20 then
				return v20 < v19
			end

			local rank = v9.getRank(a, data.clanInfo)
			local rank2 = v9.getRank(b, data.clanInfo)
			return (table.find(v9.Ranks, rank) or 1) > (table.find(v9.Ranks, rank2) or 1)
		end)
	elseif data.sortOrder == "Rank" then
		local _ = data.clanInfo.ranks
		table.sort(clone, function(a, b)
			local rank = v9.getRank(a, data.clanInfo)
			local rank2 = v9.getRank(b, data.clanInfo)
			return (table.find(v9.Ranks, rank) or 1) > (table.find(v9.Ranks, rank2) or 1)
		end)
	end

	local cache = data.cache

	if cache then
		local v17 = #cache - #clone

		if v17 > 0 then
			for i = #cache, #cache - v17 + 1, -1 do
				local v18 = cache[i]

				if v18 then
					v18.Visible = false
				end
			end
		end
	end

	local parent = assert(data.parent:FindFirstChild("MembersScroll"))
	local template2 = data.template or template
	local count = 0

	for k, name in clone do
		local clone2

		if data.cache then
			clone2 = data.cache[k]
		else
			clone2 = nil
		end

		if not clone2 then
			if data.trove and not data.cache then
				clone2 = data.trove:Clone(template2)
			else
				clone2 = template2:Clone()
			end

			clone2.Name = name
			clone2.Visible = true
			clone2.Active = data.viewOnly ~= true
			clone2.Selectable = data.viewOnly ~= true

			if data.onCreated then
				task.defer(data.onCreated, clone2)
			end

			clone2.Parent = parent

			if not data.viewOnly and clone2:IsA("GuiButton") then
				local v19 = clone2
				clone2.Activated:Connect(function()
					if not v4:IsLastPage("Overview") then
						return
					end

					self:ManageMember(v19.Name)
				end)
			end

			if data.cache then
				data.cache[k] = clone2
			end
		end

		local rank = v9.getRank(name, data.clanInfo)
		local userId = v6.parseUserId(name)
		local v19 = tonumber(userId)
		clone2.Name = name
		clone2.PlayerHeadshot.Image = `rbxthumb://type=AvatarHeadShot&id={userId}&w=100&h=100`
		clone2.Rank.Text = `[{rank}]`
		clone2.LayoutOrder = k
		clone2.Rank.TextColor3 = v9.RanksColor[rank] or Color3.fromRGB(255, 255, 255)

		if v19 <= 0 then
			clone2.Username.Text = `@Player{userId}`
		else
			data.trove:AddPromise(v10:GetUser(userId)):andThen(function(player)
				if typeof(player) == "Instance" and player:IsA("Player") then
					clone2.Username.Text = `@{v11:GetHumanoidName(player, false)}`
				else
					clone2.Username.Text = `@{v11:GetUserName(player)}`
				end
			end):catch(function()
				clone2.Username.Text = "[Failed to load]"
			end)
		end

		local v20 = v16[userId]
		local online

		if v20 then
			online = v20.Online
		end

		local lastOnline

		if v20 then
			lastOnline = v20.LastOnline
		end

		local text = clanContributions[name] or 0
		local playerByUserId = Players:GetPlayerByUserId(v19)
		local v22 = v19 == localPlayer.UserId
		local amount = clone2:FindFirstChild("Amount")

		if amount then
			amount.Text = text
		end

		if online or v22 or playerByUserId then
			clone2.Status.Text = "Online"
			clone2.Status.TextColor3 = v14.Online
			count += 1
		else
			if lastOnline then
				clone2.Status.Text = formatOfflineTime(lastOnline)
			else
				clone2.Status.Text = "Offline"
			end

			clone2.Status.TextColor3 = v14.Offline
		end

		clone2.Visible = true
	end

	local value = v7.getClanUpgrade(data.clanInfo, "Size").Value
	local memberAmount = data.parent:FindFirstChild("MemberAmount")
	local onlineStatus = data.parent:FindFirstChild("OnlineStatus")

	if memberAmount then
		memberAmount.Text = `Members: {#clone}/{value}`
	end

	if onlineStatus then
		onlineStatus.Text = `Online: {count}/{value}`
	end
end

function ClanOverviewController:UpdateLevel(object)
	local v16 = object:Get("Info.clanLevel") or 0
	local v17 = object:Get("Info.clanXp") or 0
	local clanLevel = v8.ClanLevels[v16 + 1]

	if clanLevel then
		main.ClanLogo.Bar.Fill.Size = UDim2.fromScale(v17 / clanLevel, 1)
	else
		main.ClanLogo.Bar.Fill.Size = UDim2.fromScale(0, 1)
	end

	main.ClanLogo.Header.Text = `Level: {v16}`
end

function ClanOverviewController:Setup(object2, _)
	local serverTimeNow = workspace:GetServerTimeNow()

	local function updateClan()
		if not v4:IsOpen("ManageMember") then
			maid2:Clean()
		end

		if not v4:IsOpen("Overview") then
			return
		end

		serverTimeNow = workspace:GetServerTimeNow()
		self:RenderMembers({
			clanInfo = object2:Get("Info"),
			parent = main,
			cache = cache2,
			sortOrder = selectedOption,
			trove = maid
		})
		self:UpdateLevel(object2)
	end

	local v16 = v13({
		root = main.Activity,
		scroll = main.DropdownList,
		options = { "Status", "Rank" }
	})
	selectedOption = v16.selectedOption
	maid:Add(v16.destroy)
	maid:Add(v16.optionChanged:Connect(function(p)
		selectedOption = p
		updateClan()
	end))
	maid:Add(main.Invite.Activated:Connect(function()
		v4:PushPage("Invite")
	end))
	maid:Add(task.spawn(function()
		while true do
			if workspace:GetServerTimeNow() - serverTimeNow >= 60 then
				updateClan()
			end

			task.wait(5)
		end
	end))
	maid:Add(main.Dropdown.Activated:Connect(v16.switch))

	local function updateInviteButton()
		local permissionFor = v9.hasPermissionFor(localPlayer, "INVITE_MEMBERS", object2.Data.Info)
		main.Invite.Visible = permissionFor
	end

	maid:Add(v12.observeReplionPath(object2, "Info.ranks", updateInviteButton))
	maid:Add(v12.observeReplionPath(object2, "Info.ranksPermission", updateInviteButton))
	maid:Add(v12.observeReplionPath(object2, "Info.privacySettings", function(p)
		main.ClanStatus.Text = p == "Public" and "Open" or "Closed"
		local clanStatus = main.ClanStatus
		local textColor

		if p == "Public" then
			textColor = Color3.fromRGB(170, 255, 127)
		else
			textColor = Color3.fromRGB(255, 127, 127)
		end

		clanStatus.TextColor3 = textColor
	end))
	maid:Add(v12.observeReplionPath(object2, "Info.members", updateClan))
	maid:Add(v12.observeReplionPath(object2, "Info.clanLevel", updateClan))
	maid:Add(v12.observeReplionPath(object2, "Info.clanContributions", updateClan))
	maid:Add(v12.observeReplionPath(object2, "Info.ranks", updateClan))
	maid:Add(v12.observeReplionPath(object2, "Info.clanMemberStatuses", updateClan))
	maid:Add(v4.PageStackChanged:Connect(updateClan))

	local function updateClanName()
		local v17 = object2:Get("Info.title")
		local v18 = object2:Get("Info.tag")
		main.ClanName.Text = `[{v18}] {v17}`
	end

	maid:Add(v12.observeReplionPath(object2, "Info.title", updateClanName))
	maid:Add(v12.observeReplionPath(object2, "Info.tag", updateClanName))
	maid:Add(main.DropdownList:GetPropertyChangedSignal("Visible"):Connect(function()
		spring.target(main.Dropdown, 0.75, 2.5, {
			Rotation = main.DropdownList.Visible and 180 or 0
		})
	end))
	maid:Add(main.Settings.Activated:Connect(function()
		v4:SetPage("Manager")
	end))
	maid:Add(v12.observeReplionPath(object2, "Info.clanEmblem", function()
		local info = object2.Data.Info

		if not info then
			return
		end

		main.ClanLogo.ImageLabel.Image = v6.getClanEmblem(info)
	end))
	maid:Add(v12.observeReplionPath(object2, "Info.owner", function(p)
		local v17 = tostring(localPlayer.UserId) == v6.parseUserId(p)
		main.Leave.TextLabel.Text = v17 and "Delete Clan" or "Leave Clan"
	end))
	maid:Add(function()
		main.ClanName.Text = "[TAG] Loading..."
		main.Leave.TextLabel.Text = "Leave Clan"

		for _, v17 in cache2 do
			v17:Destroy()
		end

		table.clear(cache2)
	end)
	maid:Add(v4.PageStackChanged:Connect(function()
		local isLastPage = v4:IsLastPage("Overview")
		main.Leave.Active = isLastPage
		main.Leave.Selectable = isLastPage
		main.Invite.Active = isLastPage
		main.Selectable = isLastPage
	end))
end

function ClanOverviewController:Enable()
	local isEnabled = v3.CurrentClanId and v3:IsVersion(v3.Versions.new)

	if self._isEnabled == isEnabled then
		return
	end

	self._isEnabled = isEnabled

	if not isEnabled then
		maid:Clean()
		return
	end

	maid:Add(main.Leave.Activated:Connect(function()
		local clanReplion = v3.ClanReplion

		if not clanReplion then
			return
		end

		local v17 = clanReplion:Get("Info.owner")
		local v18 = tostring(localPlayer.UserId) == v6.parseUserId(v17)
		local v19

		if v18 then
			v19 = v5:Prompt({
				title = "DELETE CLAN",
				text = "Are you sure you want to permanently delete your clan?"
			})
		else
			v19 = v5:Prompt({
				title = "LEAVE CLAN",
				text = "Would you like to leave your clan?"
			})
		end

		if not v19 then
			return
		end

		local v20, text = v:Invoke(v18 and "DeleteClan" or "LeaveClan")

		if v20 then
			v4:Close()
		elseif v18 and text then
			v5:Prompt({
				title = "DELETE FAILED",
				text = text,
				acceptOnly = true,
				acceptText = "Ok"
			})
		end
	end))
	maid:Add(v3:ObserveClan(function(p, p2)
		self:Setup(p, p2)
		return function()
			maid:Clean()
		end
	end))
end

function ClanOverviewController:Start()
	clanGui.Close.Activated:Connect(function()
		v4:Close()
	end)
	v3:BindToVersion(v3.Versions.new, self.Enable, self)
	v3.ClanUpdated:Connect(function()
		self:Enable()
	end)
end

return ClanOverviewController