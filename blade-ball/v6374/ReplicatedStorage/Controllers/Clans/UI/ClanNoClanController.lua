local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("GuiService")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Packages.Freeze)
require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v5 = require3(script.Parent.Parent.ClanController)
local v6 = require3(script.Parent.ClanPagesController)
local v7 = require3(script.Parent.ClanOverviewController)
local v8 = require3(script.Parent.Parent.Utils)
local v9 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v10 = require3(ReplicatedStorage2.Shared.ClansData)
local v11 = require3(ReplicatedStorage2.Shared.ClansUpgradeData)
require3(ReplicatedStorage2.Shared.ClansRankData)
local v12 = require3(ReplicatedStorage2.Shared.ClansSearchUtils)
require3(ReplicatedStorage2.Shared.PlayerUtility)
require3(ReplicatedStorage2.Shared.PlayerNameUtility)
local v13 = require3(ReplicatedStorage2.Common.Utils)
local _ = v13.Spring
require3(ReplicatedStorage2.Shared.ReplionUtils)
local maid = v3.new()
local v14 = nil
local _ = Players.LocalPlayer.PlayerGui
local v15 = nil
local replion = nil
local noClan = v6.ClanGui.Pages.NoClan
local views = noClan.Views
local main = views.JoinClan.Main
local _ = views.Create
local clanInfo = views.ClanInfo
local main2 = clanInfo.Main
local scrollingFrame = main.ClanList.ScrollingFrame
local template = scrollingFrame.UIListLayout.Template
local clones = {}
local v16 = {}
local v17 = {}
local v18 = {
	requestThread = nil,
	lastSearchTerm = nil,
	page = 1,
	result = nil
}
local serverTimeNow = workspace:GetServerTimeNow()
local v19 = false
local v20 = {
	root = {
		buttons = noClan.TabButtons,
		frames = views,
		options = { "JoinClan", "Create" },
		current = nil
	},
	joinClan = {
		buttons = main.TopBar,
		options = { "Invites", "Search" },
		current = nil
	}
}
local ClanNoClanController = {}

function ClanNoClanController:_onTabChanged(p, p2)
	local v21 = v17[p]

	if v21 then
		table.insert(v21, p2)
	else
		v17[p] = { p2 }
	end

	return function()
		local v22 = v17[p]

		if not v22 then
			return
		end

		local index = table.find(v22, p2)

		if not index then
			return
		end

		table.remove(v22, index)
	end
end

function ClanNoClanController:ShowClanInfo(clanInfo2)
	if v14 then
		maid:Remove(v14)
		v14 = nil
	end

	if clanInfo2 then
		local maid2 = maid:Extend()
		v14 = maid2
		v7:RenderMembers({
			clanInfo = clanInfo2,
			parent = main2,
			trove = maid2,
			viewOnly = true,
			sortOrder = "Rank"
		})
		local v21 = clanInfo2.privacySettings == "Public"
		local v22

		if v21 then
			v22 = false
		else
			local clanInvites = replion and replion:Get("clanInvites") or {}
			v22 = table.find(clanInvites, clanInfo2.id) ~= nil
		end

		main2.ClanName.Text = `[{clanInfo2.tag}] {clanInfo2.title}`
		main2.ClanStatus.Text = v21 and "Open" or "Closed"
		local clanStatus = main2.ClanStatus
		local textColor

		if v21 then
			textColor = Color3.fromRGB(170, 255, 127)
		else
			textColor = Color3.fromRGB(255, 127, 127)
		end

		clanStatus.TextColor3 = textColor
		main2.ClanLogo.ImageLabel.Image = v10.getClanEmblem(clanInfo2)
		main2.ClanLogo.ClanLevel.Text = `Level: {clanInfo2.clanLevel}`

		if v22 or v21 then
			if v22 or not v21 then
				main2.Join.TextLabel.Text = "Join"
			end
		else
			main2.Join.TextLabel.Text = "Send Request"
		end

		maid2:Add(main2.Join.Activated:Connect(function()
			main2.Join.Active = false
			local v24 = nil
			local v25 = nil

			if v22 or v21 then
				v24, v25 = v:Invoke("JoinClan", clanInfo2.id)
			elseif not (v22 or v21) then
				v24, v25 = v:Invoke("SendClanJoinRequest", clanInfo2.id)
			end

			if not v24 then
				v9:SendNotification(v25)
				ReplicatedStorage2.Misc.error:Play()
			end

			task.wait(2.5)
			main2.Join.Active = true
		end))
		maid2:Add(main2.Close.Activated:Connect(function()
			self:ShowClanInfo(nil)
		end))
		views.JoinClan.Visible = false
		clanInfo.Visible = true
	else
		clanInfo.Visible = false
		views.JoinClan.Visible = v20.root.current == "JoinClan"
	end
end

function ClanNoClanController:RenderClans(list)
	serverTimeNow = workspace:GetServerTimeNow()
	main.BG.NoClans.Visible = next(list) == nil
	main.BG.Create.Visible = next(list) == nil
	noClan.TabButtons.Create.Visible = next(list) ~= nil

	if v4.List.equals(list, v16) then
		return
	end

	v16 = list
	local v21 = #clones - #list

	if v21 > 0 then
		for i = #clones, #clones - v21 + 1, -1 do
			local v22 = clones[i]

			if v22 then
				v22.Visible = false
			end
		end
	end

	for k, v22 in list do
		local clone = clones[k]

		if not clone then
			clone = template:Clone()
			clone.LayoutOrder = k
			clone.Name = k
			local v23 = k
			maid:Add(clone.Activated:Connect(function()
				local v24 = v16[v23]

				if not v24 then
					ReplicatedStorage2.Misc.error:Play()
					return
				end

				self:ShowClanInfo(v:Invoke("GetClanInfo", v24.id) or v24)
			end))
			clone.Parent = scrollingFrame
			clones[k] = clone
		end

		local recommendationInfo = v22.recommendationInfo
		local value

		if recommendationInfo then
			local size = recommendationInfo.size or 0
			local upgradeLevel = v11.getUpgradeLevel("Size", size)

			if size ~= 0 then
				value = tostring(upgradeLevel.Value)
			end
		end

		local members

		if type(v22.members) == "number" then
			members = v22.members
		else
			members = #v22.members
		end

		clone.ClanName.Text = `[{v22.tag}] {v22.title}`
		local members2 = clone.Members
		local text

		if value then
			text = `Members: {members}/{value}`
		else
			text = `Members: {members}`
		end

		members2.Text = text
		clone.Icon.Image = v10.getClanEmblem(v22)
		clone.Status.Text = v22.privacySettings == "Public" and "Open" or "Closed"
		local status = clone.Status
		local textColor

		if v22.privacySettings == "Public" then
			textColor = Color3.fromRGB(170, 255, 127)
		else
			textColor = Color3.fromRGB(255, 127, 127)
		end

		status.TextColor3 = textColor
		clone.Visible = true
	end
end

function ClanNoClanController:SearchClans()
	if v18.requestThread then
		task.cancel(v18.requestThread)
		v18.requestThread = nil
	end

	local trimmed = v13.String.Trim(main.Search.TextBox.Text)

	if trimmed == "" then
		return
	end

	local v21 = v18.lastSearchTerm == trimmed

	if not v21 then
		v18.page = 1
		v18.lastSearchTerm = trimmed
		v18.result = nil
		main.Pages.Page.Text = "0/0"
		self:RenderClans({})
	end

	if v18.result and v18.result.pages > 0 then
		v18.page = math.clamp(v18.page, 1, v18.result.pages)
		main.Pages.Page.Text = `{v18.page}/{v18.result.pages}`
	else
		main.Pages.Page.Text = "0/0"
	end

	local page = v18.page
	self:SetTab("Search", "joinClan")
	local thread = nil
	thread = task.delay(v21 and 0 or 1, function()
		local v22, v23 = v:Invoke("SearchClan", trimmed, page)

		if not (v22 and v23) then
			v9:SendNotification("Failed to search clans, try again later!")
			return
		end

		if v18.requestThread ~= thread then
			return
		end

		local decodeSearchResult = v12.decodeSearchResult(v23)
		v18.result = decodeSearchResult
		main.Pages.Page.Text = `{v18.page}/{decodeSearchResult.pages}`
		main.Pages.Visible = true
		self:RenderClans(decodeSearchResult.clans)
		v18.requestThread = nil
	end)
	v18.requestThread = thread
end

function ClanNoClanController:UpdateMyInvites()
	local clanInvites

	if replion then
		clanInvites = replion:Get("clanInvites")
	end

	local v21 = (not clanInvites or #clanInvites == 0) and {} or v:Invoke("GetClansInfo", clanInvites)
	local v22 = v21 or {}
	main.TopBar.Invites.Visible = next(v22) ~= nil
	main.TopBar.Invites.NotificationLabel.Visible = next(v22) ~= nil
	main.TopBar.Invites.NotificationLabel.Label.Text = #v22
	self:RenderClans(v21)
end

function ClanNoClanController:SetTab(current, p)
	local v21 = v20[p]

	if not v21 or v21.current == current then
		return
	end

	local v22 = v17[p]

	if v22 then
		for _, callback in v22 do
			task.defer(callback, current)
		end
	end

	v21.current = current

	for _, button in v21.buttons:GetChildren() do
		if not (button:IsA("ImageButton") and table.find(v21.options, button.Name)) then
			continue
		end

		local visible = v21.current == button.Name
		local child

		if v21.frames then
			child = v21.frames:FindFirstChild(button.Name)
		end

		if child then
			child.Visible = visible
		end

		v8.setButtonImages(button, visible)
	end
end

function ClanNoClanController:Setup()
	replion = v2.Client:GetReplion("UserClanData")

	for _, button in main.TopBar:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		if table.find(v20.joinClan.options, button.Name) then
			local v21 = button
			maid:Add(button.Activated:Connect(function()
				self:SetTab(v21.Name, "joinClan")
			end))
		else
			button.Visible = false
		end
	end

	maid:Add(main.BG.Create.Activated:Connect(function()
		self:SetTab("Create", "root")
	end))
	maid:Add(main.Search.TextBox.FocusLost:Connect(function(p)
		if not p then
			return
		end

		self:SearchClans()
	end))
	maid:Add(main.Pages.Next.Activated:Connect(function()
		if not v18.result then
			return
		end

		v18.page += 1
		self:SearchClans()
	end))
	maid:Add(main.Pages.Previous.Activated:Connect(function()
		if not v18.result then
			return
		end

		v18.page -= 1
		self:SearchClans()
	end))
	maid:Add(self:_onTabChanged("root", function(p)
		if p == "Create" then
			self:ShowClanInfo(nil)
		end
	end))
	maid:Add(self:_onTabChanged("joinClan", function(_: string)
		main.Pages.Visible = false

		if replion then
			self:UpdateMyInvites()
		end
	end))
	local v21 = true
	maid:Add(v6.PageStackChanged:Connect(function()
		if v21 and v6:IsOpen("NoClan") then
			v21 = false
			self:SetTab(v20.joinClan.options[1], "joinClan")
		end
	end))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateUserDataReplion(object2)
		replion = object2
		maid:Add(object2:OnChange("clanInvites", function()
			if v20.joinClan.current ~= "Invites" then
				return
			end

			self:UpdateMyInvites()
		end))
		self:UpdateMyInvites()
	end

	if replion then
		local v22 = replion
		replion = v22
		maid:Add(v22:OnChange("clanInvites", function()
			if v20.joinClan.current ~= "Invites" then
				return
			end

			self:UpdateMyInvites()
		end))
		self:UpdateMyInvites()
	else
		maid:Add(v2.Client:OnReplionAdded(function(object2)
			if object2._channel ~= "UserClanData" then
				return
			end

			updateUserDataReplion(object2) -- equivalent call inferred; original call site unknown
		end))
	end

	self:UpdateMyInvites()
end

function ClanNoClanController:Enable(p)
	local v21 = p and v15:Get("ClanId") == nil

	if v21 then
		if v19 == v21 then
			return
		end

		v19 = v21
		maid:Add(function()
			for _, v22 in clones do
				v22:Destroy()
			end

			clones = {}

			if v14 then
				v14:Destroy()
				v14 = nil
			end

			self:ShowClanInfo(nil)
			v16 = {}
			v20.joinClan.current = nil
			v20.root.current = nil
		end)

		for _, button in noClan.TabButtons:GetChildren() do
			local child = views:FindFirstChild(button.Name)

			if not button:IsA("GuiButton") then
				continue
			end

			if child then
				local v22 = button
				maid:Add(button.Activated:Connect(function()
					self:SetTab(v22.Name, "root")
				end))
			else
				button.Visible = false
			end
		end

		self:Setup()
		self:SetTab("JoinClan", "root")
	else
		maid:Clean()
		v19 = false
	end
end

function ClanNoClanController:Start()
	v15 = v2.Client:WaitReplion("Data")

	local function updateEnabled()
		self:Enable(v5:IsVersion(v5.Versions.new))
	end

	v5:BindToVersion(v5.Versions.new, updateEnabled)
	v5.ClanUpdated:Connect(updateEnabled)
	task.defer(updateEnabled)
end

return ClanNoClanController