local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v5 = require3(ReplicatedStorage2.Common.Utils)
local clans = ReplicatedStorage2.Controllers.Clans
local v6 = require3(clans.ClanController)
local v7 = require3(clans.ClanPageController)
local v8 = require3(script.Parent.ClanPagesController)
local v9 = require3(ReplicatedStorage2.Shared.ClansData)
local v10 = require3(ReplicatedStorage2.Shared.ClansRankData)
local v11 = require3(ReplicatedStorage2.Shared.PlayerUtility)
local v12 = require3(ReplicatedStorage2.ServerInfo)
local remoteFunction = v:RemoteFunction("PatchClanInfo")
local remoteFunction2 = v:RemoteFunction("RenameClan")
local remoteFunction3 = v:RemoteFunction("ChangeClanTag")
local remoteFunction4 = v:RemoteFunction("GetUsersData")
local remoteFunction5 = v:RemoteFunction("AcceptJoinRequest")
local remoteFunction6 = v:RemoteFunction("RejectJoinRequest")
local remoteFunction7 = v:RemoteFunction("ClanUpdateRankPermission")
local remoteFunction8 = v:RemoteFunction("TransferClanOwnership")
local localPlayer = Players.LocalPlayer
local clanGUI = v7.ClanGUI
local overview = clanGUI.Overview
local _ = overview.Views
local frame = clanGUI.Pages.Manager.Frame
local tabs = frame.Tabs
local topBar = frame.TopBar
local list = tabs.Settings.List
local uIListLayout = list.UIListLayout
local editDescription = clanGUI.Pages.EditDescription
local changeClanName = clanGUI.Pages.ChangeClanName
local changeClanTag = clanGUI.Pages.ChangeClanTag
local list2 = tabs.AdminLogs.List
local uIListLayout2 = list2.UIListLayout
local memberPromoted = uIListLayout2.MemberPromoted
local memberDemoted = uIListLayout2.MemberDemoted
local emblemChanged = uIListLayout2.EmblemChanged
local descriptionChanged = uIListLayout2.DescriptionChanged
local shouted = uIListLayout2.Shouted
local changedPrivacySettings = uIListLayout2.ChangedPrivacySettings
local memberKicked = uIListLayout2.MemberKicked
local requestAccepted = uIListLayout2.RequestAccepted
local requestRejected = uIListLayout2.RequestRejected
local joinRequests = tabs.JoinRequests
local list3 = joinRequests.List
local template = list3.UIListLayout.Template
local info = joinRequests.Info
local permissions = tabs.Permissions
local template2 = permissions.Roles.UIListLayout.Template
local template3 = permissions.List.UIListLayout.Template
local v13 = {
	[false] = {
		HoverImage = "rbxassetid://15980673647",
		Image = "rbxassetid://15973217588",
		["Label.UIStroke.Color"] = Color3.fromRGB(0, 22, 88)
	},
	[true] = {
		HoverImage = "rbxassetid://15980672448",
		Image = "rbxassetid://15973217019",
		["Label.UIStroke.Color"] = Color3.fromRGB(116, 60, 0)
	}
}
local v14 = {
	CHANGE_BADGE = true,
	CHANGE_DESCRIPTION = true,
	CHANGE_PERMISSIONS = true,
	CHANGE_REQUIREMENTS = true
}
local v15 = {}
local v16 = {
	[false] = {
		HoverImage = "rbxassetid://15980507828",
		Image = "rbxassetid://15971493895"
	},
	[true] = {
		HoverImage = "rbxassetid://15980507595",
		Image = "rbxassetid://15971493628"
	}
}
local v17 = {}
local v18 = {}
local v19 = {}
local v20 = {}
local v21 = {
	EditDescription = {
		Type = "EditDescription",
		Title = "Edit Description",
		Get = function(self)
			return self:Get("Info.description")
		end,
		Set = function(self, description: string)
			return remoteFunction:InvokeServer(self:Get("Info.id"), {
				description = description
			})
		end,
		Update = function(_, _, _) end,
		Listen = function(object, p)
			local connection = object:OnChange("Info.description", p)
			return function()
				connection:Disconnect()
			end
		end
	},
	EditName = {
		Type = "EditName",
		Title = "Edit Name",
		Get = function(self)
			return self:Get("Info.title")
		end,
		Set = function(_, p: string)
			return remoteFunction2:InvokeServer(p, (v2.Client:GetReplion("Data"):Get("FreeClanRename") or 0) > 0)
		end,
		Update = function(_, _, _) end,
		Listen = function(object, p)
			local connection = object:OnChange("Info.title", p)
			return function()
				connection:Disconnect()
			end
		end
	},
	EditTag = {
		Type = "EditTag",
		Title = "Edit Tag",
		Get = function(self)
			return self:Get("Info.tag")
		end,
		Set = function(_, p: string)
			return remoteFunction3:InvokeServer(p, (v2.Client:GetReplion("Data"):Get("FreeClanTagChange") or 0) > 0)
		end,
		Update = function(_, _, _) end,
		Listen = function(object, p)
			local connection = object:OnChange("Info.tag", p)
			return function()
				connection:Disconnect()
			end
		end
	},
	WinsRequirement = {
		Type = "Number",
		Title = "Wins Requirement",
		Get = function(self)
			return self:Get("Info.requirements") and self:Get("Info.requirements.wins") or 0
		end,
		Set = function(self, wins: number)
			return remoteFunction:InvokeServer(self:Get("Info.id"), {
				requirements = {
					wins = wins
				}
			})
		end,
		Update = function(_, p, p2)
			p.Number.Value.Text = v5.ValueConvertor:AddCommas(p2)
			p.Number.Value:SetAttribute("Value", p2)
		end,
		Listen = function(object, p)
			local connection = object:OnChange("Info.requirements", p)
			return function()
				connection:Disconnect()
			end
		end
	},
	KillsRequirement = {
		Type = "Number",
		Title = "Kills Requirement",
		Get = function(self)
			return self:Get("Info.requirements") and self:Get("Info.requirements.kills") or 0
		end,
		Set = function(self, kills: number)
			return remoteFunction:InvokeServer(self:Get("Info.id"), {
				requirements = {
					kills = kills
				}
			})
		end,
		Update = function(_, p, p2)
			p.Number.Value.Text = v5.ValueConvertor:AddCommas(p2)
			p.Number.Value:SetAttribute("Value", p2)
		end,
		Listen = function(object, p)
			local connection = object:OnChange("Info.requirements", p)
			return function()
				connection:Disconnect()
			end
		end
	},
	TransferOwnership = {
		Type = "TransferOwnership",
		Title = "Transfer Ownership",
		Get = function()
			return nil
		end,
		Set = function(_, p: string)
			local v22, v23 = remoteFunction8:InvokeServer((tonumber(v9.parseUserId(p))))

			if not v22 then
				ReplicatedStorage2.Misc.error:Play()
				return v22, v23
			end

			if v6:IsVersion(v6.Versions.new) then
				v8:SetPage("Overview")
				return v22, v23
			end

			v7:OpenPage("Overview")
			return v22, v23
		end,
		Update = function() end,
		Listen = function()
			return function() end
		end
	}
}
local v22 = {
	"EditName",
	"EditTag",
	"EditDescription",
	"WinsRequirement",
	"KillsRequirement",
	"TransferOwnership"
}
local v23 = {
	[true] = {
		HoverImage = "rbxassetid://15980673317",
		Image = "rbxassetid://15973217306"
	},
	[false] = {
		HoverImage = "rbxassetid://15980672952",
		Image = "rbxassetid://15973220710"
	}
}
local v24 = {
	"INVITE_MEMBERS",
	"SET_RECOMMENDED_UPGRADE",
	"MANAGE_APPLICATIONS",
	"POST_SHOUT",
	"VIEW_AUDIT_LOGS",
	"VIEW_PERMISSIONS"
}

for k in v10.Permissions do
	if v14[k] then
		continue
	end

	local v25 = k:lower():gsub("_%w", function(value)
		return " " .. value:upper():sub(2)
	end)
	v15[k] = v25:sub(1, 1):upper() .. v25:sub(2)
end

local function getPerms(info2)
	local result = {
		ManageApplications = v10.hasPermissionFor(localPlayer, "MANAGE_APPLICATIONS", info2),
		ViewLogs = v10.hasPermissionFor(localPlayer, "VIEW_AUDIT_LOGS", info2),
		ViewPermissions = v10.hasPermissionFor(localPlayer, "VIEW_PERMISSIONS", info2),
		ChangePermissions = v10.hasPermissionFor(localPlayer, "CHANGE_PERMISSIONS", info2),
		HostClanBattle = v10.hasPermissionFor(localPlayer, "HOST_CLAN_BATTLE", info2),
		Settings = v10.getRank(localPlayer, info2) == "Owner",
		SeeManager = false
	}

	for _, v25 in result do
		if not v25 then
			continue
		end

		result.SeeManager = true
		return result
	end

	return result
end

local transferOwnership = clanGUI.Pages.TransferOwnership
local transferConfirmation = clanGUI.Pages.TransferConfirmation

local function timeAgo(p: number)
	local v25 = math.floor(p / 60)
	local v26 = math.floor(v25 / 60)
	local v27 = math.floor(v26 / 24)
	local v28 = math.floor(v27 / 7)
	local v29 = math.floor(v27 / 30)
	local v30 = math.floor(v27 / 365)

	if p < 60 then
		return "just now"
	end

	if v25 < 60 then
		return v25 .. " minute(s) ago"
	end

	if v26 < 24 then
		return v26 .. " hour(s) ago"
	end

	if v27 == 1 then
		return "yesterday"
	end

	if v27 < 7 then
		return v27 .. " day(s) ago"
	end

	if v28 == 1 then
		return "a week ago"
	end

	if v28 < 4 then
		return v28 .. " week(s) ago"
	end

	if v29 == 1 then
		return "a month ago"
	end

	if v29 < 12 then
		return v29 .. " month(s) ago"
	end

	if v30 == 1 then
		return "a year ago"
	end

	return v30 .. " year(s) ago"
end

local ClanManagerController = {
	ClanReplion = nil,
	Init = function(_)
		v7:RegisterPage("TransferOwnership", transferOwnership)
		v7:RegisterPage("TransferConfirmation", transferConfirmation)
	end
}
local v25 = nil

function ClanManagerController:SwitchPage(childName: string)
	if not tabs:FindFirstChild(childName) then
		warn((`Tried to switch to page "{childName}", which doesn't exist`))
		return
	end

	v25 = childName

	for _, guiObject in topBar:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local v26 = guiObject.Name == childName
		local v27 = v16[v26]
		guiObject.Active = not v26

		for k, v28 in v27 do
			guiObject[k] = v28
		end

		guiObject.Label.UIStroke.Color = v26 and Color3.fromRGB(34, 120, 31) or Color3.fromRGB(37, 78, 169)
	end

	for _, guiObject in tabs:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = guiObject.Name == childName
		end
	end
end

function ClanManagerController:GetPlayerUsername(value)
	if type(value) == "string" then
		value = v9.parseUserId(value)
	end

	local v26, v27 = v11:GetUsername(value):await()
	return v26 and v27 or "???"
end

function ClanManagerController:UpdateLogs()
	local clanReplion = v6.ClanReplion

	if not clanReplion then
		return
	end

	local v26 = clanReplion:Get("Info.auditLogs")

	for k, v27 in v17 do
		if v26 and table.find(v26, k) then
			continue
		end

		v18[k]:Destroy()
		v18[k] = nil
		v27:Destroy()
		v17[k] = nil
	end

	if not v26 then
		return
	end

	for _, v27 in v26 do
		if v17[v27] then
			continue
		end

		local maid = v3.new()
		local type2 = v27.type
		local clone

		if type2 == "promote" then
			clone = memberPromoted:Clone()
			clone.Label.Text = `[{self:GetPlayerUsername(v27.affectedUser)}] to`
			local text = v27.values[1]
			clone.Rank.Text = text
			clone.Rank.TextColor3 = v10.RanksColor[text]
		elseif type2 == "demote" then
			clone = memberDemoted:Clone()
			clone.Label.Text = `[{self:GetPlayerUsername(v27.affectedUser)}] to`
			local text = v27.values[1]
			clone.Rank.Text = text
			clone.Rank.TextColor3 = v10.RanksColor[text]
		elseif type2 == "clanEmblem" then
			clone = emblemChanged:Clone()
			clone.Emblem.Text = v9.Emblems[v27.values[1]].DisplayName
		elseif type2 == "description" then
			clone = descriptionChanged:Clone()
		elseif type2 == "clanShout" then
			clone = shouted:Clone()
		elseif type2 == "privacySettings" then
			clone = changedPrivacySettings:Clone()
			clone.Label.Text = v27.values[1]
		elseif type2 == "kick" then
			clone = memberKicked:Clone()
			clone.FromTheClan.Text = `[{self:GetPlayerUsername(v27.affectedUser)}] from the clan`
		elseif type2 == "acceptRequest" then
			clone = requestAccepted:Clone()
			clone.Label.Text = `[{self:GetPlayerUsername(v27.affectedUser)}]`
		elseif type2 == "rejectRequest" then
			clone = requestRejected:Clone()
			clone.Label.Text = `[{self:GetPlayerUsername(v27.affectedUser)}]`
		else
			if v12.isTestGame() then
				warn((`Couldn't create clan audit log of type "{v27.type}", found no template for that`))
			end

			continue
		end

		local v28 = v27
		maid:Add(task.spawn(function()
			while true do
				clone.Date.Text = timeAgo(workspace:GetServerTimeNow() - v28.timestamp)
				task.wait(10)
			end
		end))
		clone.Name = v27.type
		clone.Username.Text = self:GetPlayerUsername(v27.userId)
		clone.Thumbnail.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={v27.userId}&w=150&h=150`
		clone.Date.Text = timeAgo(workspace:GetServerTimeNow() - v27.timestamp)
		clone.Parent = list2
		clone.LayoutOrder = -v27.timestamp
		v17[v27] = clone
		v18[v27] = maid
	end
end

local v26 = nil

function ClanManagerController:SelectRequest(data)
	local v27 = data and v9.parseUserId(data.userId)

	if v26 == v27 then
		v27 = nil
		data = nil
	end

	v26 = v27

	if not v27 then
		info.Visible = false
	end

	for k, v28 in v19 do
		v28.Glow.Visible = v27 == k
	end

	if not (data and v27) then
		return
	end

	info.Headshot.PlayerPortrait.Image = `rbxthumb://type=AvatarHeadShot&id={v27}&w=150&h=150`
	info.ELO.Text = not data.elo and "???" or v5.ValueConvertor:AddCommas(data.elo) or "???"
	info.Kills.Text = not data.kills and "???" or v5.ValueConvertor:AddCommas(data.kills) or "???"
	info.Wins.Text = not data.wins and "???" or v5.ValueConvertor:AddCommas(data.wins) or "???"
	info.Language.Text = `Country: {data.country}`
	info.Message.Text = ""
	info.Username.Text = "..."
	v11:GetUsername((tonumber(v27))):andThen(function(text)
		info.Username.Text = text
	end)
	info.Visible = true
end

local thread = nil

local function promptError(p: string?)
	if thread then
		task.cancel(thread)
	end

	frame.Error.Text = p == nil and "" or tostring(p) or ""
	thread = task.delay(5, function()
		frame.Error.Text = ""
	end)
end

function ClanManagerController:UpdateRequests()
	local clanReplion = v6.ClanReplion

	if not clanReplion then
		return
	end

	local v27 = clanReplion:Get("Info.receivedRequests")

	for k, v28 in v19 do
		if v27 and v9.findUserIdInArray(v27, k) then
			continue
		end

		v20[k]:Destroy()
		v20[k] = nil
		v28:Destroy()
		v19[k] = nil

		if k == v26 then
			self:SelectRequest()
		end
	end

	if not v27 then
		return
	end

	local v28 = remoteFunction4:InvokeServer(v27)

	for k, v29 in v28 do
		v28[k] = nil
		v28[v9.parseUserId(k)] = v29
	end

	for k, v29 in v27 do
		local userId = v9.parseUserId(v29)
		local clone = v19[userId]

		if not clone then
			local v30 = v28[userId] or {}
			local v31 = v3.new()
			clone = template:Clone()
			clone.PlayerPortrait.Image = `rbxthumb://type=AvatarHeadShot&id={userId}&w=150&h=150`
			clone.ELO.Text = not v30.elo and "???" or v5.ValueConvertor:AddCommas(v30.elo) or "???"
			clone.Kills.Text = not v30.kills and "???" or v5.ValueConvertor:AddCommas(v30.kills) or "???"
			clone.Wins.Text = not v30.wins and "???" or v5.ValueConvertor:AddCommas(v30.wins) or "???"
			clone.Username.Text = "..."
			v11:GetUsername((tonumber(userId))):andThen(function(text)
				clone.Username.Text = text
			end)
			clone.Activated:Connect(function()
				self:SelectRequest(v30)
			end)
			clone.Name = userId
			clone.Parent = list3
			v19[userId] = clone
			v20[userId] = v31
		end

		clone.LayoutOrder = -k
	end
end

function ClanManagerController:Start()
	local manager = overview.ChatBoxContainer.Buttons.Manager
	manager.Activated:Connect(function()
		v7:OpenPage("Manager")
	end)

	for _, button in topBar:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v27 = button
		button.Activated:Connect(function()
			self:SwitchPage(v27.Name)
		end)
	end

	self:SwitchPage("Settings")
	frame.Close.Activated:Connect(function()
		if v6:IsVersion(v6.Versions.new) then
			v8:SetPage("Overview")
		else
			v7:OpenPage("Overview")
		end
	end)
	local maid = v3.new()
	local v27 = nil
	local v28 = nil
	local v29 = nil

	for k, v30 in v21 do
		local clone = uIListLayout[v30.Type]:Clone()
		clone.Name = k
		clone.Label.Text = v30.Title
		clone.LayoutOrder = table.find(v22, k) or 0

		if v30.Type == "Switch" then
			local action = clone.Action
			local v31 = v30
			local v33 = k
			action.Activated:Connect(function()
				local clanReplion = v6.ClanReplion

				if not clanReplion or v6:IsVersion(v6.Versions.new) and not v8:IsLastPage("Manager") then
					return
				end

				local v34 = v31.Get(clanReplion)
				local v35 = (table.find(v31.Values, v34) or 0) % #v31.Values + 1
				action.Active = false
				action.ImageColor3 = Color3.new(0.5, 0.5, 0.5)
				local success, result = pcall(v31.Set, clanReplion, v31.Values[v35])
				action.Active = true
				action.ImageColor3 = Color3.new(1, 1, 1)

				if success then
					return
				end

				warn(`Setting {v33}`, success, result)
				ReplicatedStorage2.Misc.error:Play()
			end)
		elseif v30.Type == "EditDescription" then
			local v31 = v30
			clone.Write.Activated:Connect(function()
				local clanReplion = v6.ClanReplion

				if not clanReplion or v6:IsVersion(v6.Versions.new) and not v8:IsLastPage("Manager") then
					return
				end

				editDescription.Description.Text = clanReplion:Get("Info.description")
				editDescription.Error.Text = ""
				v8:PushPage("EditDescription")
				editDescription.Visible = true
				editDescription.Description:CaptureFocus()
				v29 = v31
			end)
		elseif v30.Type == "EditName" then
			local v31 = v30
			clone.Write.Activated:Connect(function()
				local clanReplion = v6.ClanReplion

				if not clanReplion or v6:IsVersion(v6.Versions.new) and not v8:IsLastPage("Manager") then
					return
				end

				changeClanName.Frame.Input.TextBox.Text = clanReplion:Get("Info.title")
				changeClanName.Frame.Error.Text = ""
				v8:PushPage("ChangeClanName")
				changeClanName.Visible = true
				changeClanName.Frame.Input.TextBox:CaptureFocus()
				v28 = v31
			end)
		elseif v30.Type == "EditTag" then
			local v31 = v30
			clone.Write.Activated:Connect(function()
				local clanReplion = v6.ClanReplion

				if not clanReplion or v6:IsVersion(v6.Versions.new) and not v8:IsLastPage("Manager") then
					return
				end

				changeClanTag.Frame.Input.TextBox.Text = clanReplion:Get("Info.tag")
				changeClanTag.Frame.Error.Text = ""
				v8:PushPage("ChangeClanTag")
				changeClanTag.Visible = true
				changeClanTag.Frame.Input.TextBox:CaptureFocus()
				v27 = v31
			end)
		elseif v30.Type == "Number" then
			local number = clone.Number
			number.Value:SetAttribute("Value", 0)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function getIncrement()
				local value = number.Value:GetAttribute("Value")

				if value >= 20000 then
					return 1000
				end

				if value >= 200 then
					return 100
				end

				if value >= 50 then
					return 5
				end

				return 1
			end

			local v32 = false
			local thread2 = nil
			local hoverImage = nil
			local hoverImage2 = nil
			local v33 = number
			local v34 = v30
			local frame2 = clone

			local function updateNumber(value: number)
				local clanReplion = v6.ClanReplion

				if not clanReplion or v6:IsVersion(v6.Versions.new) and not v8:IsLastPage("Manager") then
					return
				end

				v33.Value:GetAttribute("Value")
				local v36 = math.clamp(value, 0, 100000)
				v34.Update(clanReplion, frame2, v36)

				if not (hoverImage and hoverImage2) then
					v32 = true
					v33.Minus.ImageColor3 = Color3.new(0.5, 0.5, 0.5)
					hoverImage = v33.Minus.HoverImage
					v33.Minus.HoverImage = ""
					v33.Plus.ImageColor3 = Color3.new(0.5, 0.5, 0.5)
					hoverImage2 = v33.Plus.HoverImage
					v33.Plus.HoverImage = ""
				end

				if thread2 then
					task.cancel(thread2)
					thread2 = nil
				end

				thread2 = task.delay(1, function()
					local success, result = pcall(v34.Set, clanReplion, v36)
					v33.Minus.ImageColor3 = Color3.new(1, 1, 1)
					v33.Minus.HoverImage = hoverImage
					hoverImage = nil
					v33.Plus.ImageColor3 = Color3.new(1, 1, 1)
					v33.Plus.HoverImage = hoverImage2
					hoverImage2 = nil
					v32 = false

					if not success then
						ReplicatedStorage2.Misc.error:Play()
					end
				end)
			end

			local updateNumber2 = updateNumber
			local number2 = number
			number.Minus.Activated:Connect(function()
				updateNumber2(number2.Value:GetAttribute("Value") - getIncrement())
			end)
			local updateNumber3 = updateNumber
			local number3 = number
			number.Plus.Activated:Connect(function()
				updateNumber3(number3.Value:GetAttribute("Value") + getIncrement())
			end)
		elseif v30.Type == "TransferOwnership" then
			clone.Select.Activated:Connect(function()
				if v6:IsVersion(v6.Versions.new) then
					v8:PushPage("TransferOwnership")
				else
					v7:OpenPage("TransferOwnership")
				end
			end)
		else
			warn((`Couldn't create setting "{v30.Title}" of invalid type "{v30.Type}"`))
		end

		clone.Parent = list
		v30.Frame = clone
	end

	list.CanvasSize = UDim2.fromOffset(0, 1)
	editDescription.ConfirmButton.Activated:Connect(function()
		local clanReplion = v6.ClanReplion

		if not clanReplion then
			return
		end

		local text = editDescription.Description.Text
		local v30, v31 = v29.Set(clanReplion, text)

		if v30 then
			v8:RemovePage("EditDescription")
			editDescription.Visible = false
		else
			editDescription.Error.Text = v31 or ""
			ReplicatedStorage2.Misc.error:Play()
		end
	end)
	editDescription.CancelButton.Activated:Connect(function()
		v8:RemovePage("EditDescription")
		editDescription.Visible = false
	end)
	changeClanName.Frame.ConfirmButton.Activated:Connect(function()
		local clanReplion = v6.ClanReplion

		if not clanReplion then
			return
		end

		local text = changeClanName.Frame.Input.TextBox.Text
		local v30, v31 = v28.Set(clanReplion, text)

		if v30 then
			v8:RemovePage("ChangeClanName")
			changeClanName.Visible = false
		else
			changeClanName.Frame.Error.Text = v31 or ""
			ReplicatedStorage2.Misc.error:Play()
		end
	end)
	changeClanName.Frame.CancelButton.Activated:Connect(function()
		v8:RemovePage("ChangeClanName")
		changeClanName.Visible = false
	end)
	changeClanTag.Frame.ConfirmButton.Activated:Connect(function()
		local clanReplion = v6.ClanReplion

		if not clanReplion then
			return
		end

		local text = changeClanTag.Frame.Input.TextBox.Text
		local v30, v31 = v27.Set(clanReplion, text)

		if v30 then
			v8:RemovePage("ChangeClanTag")
			changeClanTag.Visible = false
		else
			changeClanTag.Frame.Error.Text = v31 or ""
			ReplicatedStorage2.Misc.error:Play()
		end
	end)
	changeClanTag.Frame.CancelButton.Activated:Connect(function()
		v8:RemovePage("ChangeClanTag")
		changeClanTag.Visible = false
	end)
	info.Visible = false
	info.Accept.Activated:Connect(function()
		if not v26 then
			return
		end

		local v30, v31 = remoteFunction5:InvokeServer(v26)

		if v30 then
			self:SelectRequest()
		else
			promptError(v31)
		end
	end)
	info.Decline.Activated:Connect(function()
		if not v26 then
			return
		end

		local v30, v31 = remoteFunction6:InvokeServer(v26)

		if v30 then
			self:SelectRequest()
		else
			promptError(v31)
		end
	end)

	local function applyInstanceProperties(p, items)
		for k, item in items do
			local v30 = string.split(k, ".")
			local v31 = p

			for i = 1, #v30 - 1 do
				v31 = v31[v30[i]]
			end

			v31[v30[#v30]] = item
		end
	end

	local v30 = nil

	local function updatePermissionsChange()
		local v31 = v30 or "Member"
		local info2 = v6.ClanReplion:Get("Info")
		local perms = getPerms(info2)
		local index = table.find(v10.Ranks, v10.getRank(localPlayer, info2)) or 0
		local index2 = table.find(v10.Ranks, v31) or 4

		for k in v15 do
			permissions.List[k].Checkbox.icon.Active = perms.ChangePermissions and index2 < index
		end

		for _, childName in v10.Ranks do
			local index3 = table.find(v10.Ranks, childName) or 4
			local child = permissions.Roles:FindFirstChild(childName)

			if child then
				child.Visible = index3 <= index
			end
		end
	end

	local function openRank(p: string?)
		v30 = p
		permissions.SelectedRole.Visible = p and true or false
		permissions.List.Visible = p and true or false

		if not p then
			return
		end

		permissions.SelectedRole.Text = `<font color="#{v10.RanksColor[p]:ToHex()}">[{p}]</font> Permissions`

		for _, childName in v10.Ranks do
			local child = permissions.Roles:FindFirstChild(childName)

			if child then
				applyInstanceProperties(child, v13[false])
			end
		end

		applyInstanceProperties(permissions.Roles[p], v13[true])
		local info2 = v6.ClanReplion:Get("Info")
		local v31 = info2.ranksPermission and info2.ranksPermission[p] or v10.DefaultPermissions[p] or 0

		for k in v15 do
			local v32 = permissions.List[k]
			local permission = v10.hasPermission(k, v31)
			applyInstanceProperties(v32.Checkbox.icon, v23[permission])
		end

		updatePermissionsChange()
	end

	openRank()

	for _, rank in v10.Ranks do
		if rank == "Owner" then
			continue
		end

		local clone = template2:Clone()
		clone.Name = rank
		clone.Parent = permissions.Roles
		clone.Label.Text = rank
		applyInstanceProperties(clone, v13[false])
		local v31 = rank
		clone.Activated:Connect(function()
			openRank(v31)
		end)
	end

	for k, text in v15 do
		local clone = template3:Clone()
		clone.Parent = permissions.List
		clone.Name = k
		clone.LayoutOrder = table.find(v24, k) or 0
		local v32 = k
		clone.Checkbox.icon.Activated:Connect(function()
			local info2 = v6.ClanReplion:Get("Info")
			local v33 = v30
			local v34 = info2.ranksPermission and info2.ranksPermission[v33] or v10.DefaultPermissions[v33] or 0
			local bitfieldPermissions = v10.getBitfieldPermissions(v34)
			local index = table.find(bitfieldPermissions, v32)

			if index then
				table.remove(bitfieldPermissions, index)

				if not remoteFunction7:InvokeServer(v33, v10.getPermissionsBitfield(bitfieldPermissions)) then
					ReplicatedStorage2.Misc.error:Play()
				end
			else
				table.insert(bitfieldPermissions, v32)

				if not remoteFunction7:InvokeServer(v33, v10.getPermissionsBitfield(bitfieldPermissions)) then
					ReplicatedStorage2.Misc.error:Play()
				end
			end
		end)
		clone.Label.Text = text
	end

	v6:ObserveClan(function(object2)
		openRank("Member")

		local function updatePermsStuff()
			local perms = getPerms(v6.ClanReplion:Get("Info"))
			manager.Visible = perms.SeeManager
			clanGUI.Pages.Overview.Main.Settings.Visible = perms.SeeManager

			if v6:IsVersion(v6.Versions.new) then
				if v8:IsOpen("Manager") and not perms.SeeManager then
					v8:SetPage("Overview")
				end
			elseif v7:IsOpen("Manager") and not perms.SeeManager then
				v7:OpenPage("Overview")
			end

			topBar.AdminLogs.Visible = perms.ViewLogs
			topBar.Permissions.Visible = perms.ViewPermissions
			topBar.JoinRequests.Visible = perms.ManageApplications
			topBar.Settings.Visible = perms.Settings
			updatePermissionsChange()
			openRank(v30)

			if v25 == "Permissions" and not perms.ViewPermissions or v25 == "JoinRequests" and not perms.ManageApplications or v25 == "AdminLogs" and not perms.ViewLogs or v25 == "Settings" and not perms.Settings then
				if perms.ViewPermissions then
					self:SwitchPage("Permissions")
				elseif perms.ManageApplications then
					self:SwitchPage("JoinRequests")
				elseif perms.ViewLogs then
					self:SwitchPage("AdminLogs")
				else
					self:SwitchPage("Settings")
				end
			end
		end

		local connection = object2:OnChange("Info.ranksPermission", updatePermsStuff)
		local connection2 = object2:OnChange("Info.ranks", updatePermsStuff)
		updatePermsStuff()
		return function()
			connection:Disconnect()
			connection2:Disconnect()
		end
	end)
	transferOwnership.Close.Activated:Connect(function()
		if v6:IsVersion(v6.Versions.new) then
			v8:SetPage("Manager")
		else
			v7:OpenPage("Manager")
		end
	end)
	local v31 = nil
	transferConfirmation.ConfirmButton.Activated:Connect(function()
		if v6.ClanReplion and v31 then
			v21.TransferOwnership.Set(v6.ClanReplion, v31)
		end
	end)
	transferConfirmation.CancelButton.Activated:Connect(function()
		if v6:IsVersion(v6.Versions.new) then
			v8:RemovePage("TransferConfirmation")
		else
			v7:OpenPage("TransferOwnership")
		end

		v31 = nil
	end)
	local maid2 = v3.new()
	v6:ObserveClan(function(object2)
		local function update()
			local v32 = object2:Get("Info.members")
			maid2:Clean()
			local info2 = object2:Get("Info")

			for _, v33 in v32 do
				local userId = v9.parseUserId(v33)

				if tostring(userId) == tostring(localPlayer.UserId) then
					continue
				end

				local v34 = maid2:Add(transferOwnership.List.UIListLayout.Member:Clone())
				local frame2 = v34.Frame
				local rank = v10.getRank(userId, info2)
				frame2.Rank.Text = `[{rank}]`
				frame2.Rank.TextColor3 = v10.RanksColor[rank] or Color3.fromRGB(255, 255, 255)
				frame2.ProfilePicture.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={userId}&w=150&h=150`
				frame2.Username.Text = "???"
				local v35 = nil
				maid2:AddPromise(v11:GetUsername(userId):andThen(function(p)
					frame2.Username.Text = `@{p}`
					v35 = p
				end))
				maid2:Add(frame2.MakeOwner.Activated:Connect(function()
					transferConfirmation.Label.Text = `<stroke color="rgb(16, 30, 93)" joins="round" thickness="3"> Are you sure you would like to transfer your <font color="rgb(251, 91, 92)">group ownership </font>of the clan '{object2:Get("Info.title")}' to {v35 or "???"}? You will be <font color="rgb(251, 91, 92)">demoted</font> to member</stroke>`
					v31 = userId

					if v6:IsVersion(v6.Versions.new) then
						v8:PushPage("TransferConfirmation")
					else
						v7:OpenPage("TransferConfirmation")
					end
				end))
				v34.Parent = transferOwnership.List
			end
		end

		local connection = v4.observeReplionPath(object2, "Info.members", update)
		local connection2 = object2:OnChange("Info.ranks", update)
		local connection3 = v4.observeReplionPath(object2, "Info.owner", function(p)
			v21.TransferOwnership.Frame.Visible = v9.parseUserId(p) == tostring(localPlayer.UserId)
		end)
		return function()
			maid2:Clean()
			connection:Disconnect()
			connection2:Disconnect()
			connection3:Disconnect()
		end
	end)
	v6:ObserveClan(function(object2)
		self:UpdateLogs()
		self:UpdateRequests()
		local connection = object2:OnChange("Info.auditLogs", function()
			self:UpdateLogs()
		end)
		local connection2 = object2:OnChange("Info.receivedRequests", function()
			self:UpdateRequests()
		end)

		for k, v32 in v21 do
			local v33 = list[k]
			v32.Update(object2, v33, v32.Get(object2))
			local v34 = v32
			maid:Add(v32.Listen(object2, function()
				v34.Update(object2, v33, v34.Get(object2))
			end))
		end

		return function()
			maid:Clean()
			connection:Disconnect()
			connection2:Disconnect()
			self:UpdateLogs()
		end
	end)
end

return ClanManagerController