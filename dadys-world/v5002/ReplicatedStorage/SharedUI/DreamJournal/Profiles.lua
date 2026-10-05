local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MyDataController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MyDataController"))
local Maid = require(ReplicatedStorage.SharedUtils.Maid)
local MenuManager = require(ReplicatedStorage.SharedUtils.MenuManager)
local ProfileCardConfig = require(ReplicatedStorage.SharedData.ProfileCardConfig)
local UITemplates = require(ReplicatedStorage.SharedUtils.UITemplates)
local ToonViewport = require(ReplicatedStorage.SharedUtils.ToonViewport)
local Network = require(ReplicatedStorage.SharedUtils.Network)
local DisplayMessage = require(ReplicatedStorage.Modules.DisplayMessage)
local Render = require(script.Render)
local Edit = require(script.Edit)
local Takeover = require(script.Takeover)
local localPlayer = Players.LocalPlayer

local function hasDandysBudTitle()
	local myReplica = MyDataController:getMyReplica()
	local data = myReplica and myReplica.Data
	return data ~= nil and data.EquippedTitle == "DandysBud"
end

local function buildSnapshot(object)
	local data = object.Data
	return {
		UserId = localPlayer.UserId,
		DisplayName = localPlayer.DisplayName,
		Username = localPlayer.Name,
		IsSelf = true,
		EquippedTitle = data.EquippedTitle,
		EquippedTrinkets = { data.EquippedTrinket1 or "", data.EquippedTrinket2 or "" },
		Statistics = data.Statistics,
		Titles = data.Titles,
		DreamJournal = data.DreamJournal,
		Towers = data.Towers,
		Mastery = data.Mastery,
		Trinkets = data.Trinkets,
		Research = data.Research,
		StickersOwned = data.StickersOwned,
		BackgroundsOwned = data.BackgroundsOwned,
		FramesOwned = data.FramesOwned,
		BackdropsOwned = data.BackdropsOwned,
		ProfileCard = data.ProfileCard,
		Coin = data.Coin,
		Skins = data.Skins,
		Blackouts = data.Blackouts,
		DandyItemsPurchased = data.DandyItemsPurchased
	}
end

local function selectedStatKeys(profileCard)
	local result = {}
	local sections

	if type(profileCard) == "table" then
		sections = profileCard.Sections or nil
	end

	if type(sections) ~= "table" then
		return result
	end

	for _, v in ipairs(ProfileCardConfig.SlotOrder) do
		local section = sections[v]

		if not (type(section) == "table" and section.Type == "Stats" and type(section.Items) == "table") then
			continue
		end

		for _, item in ipairs(section.Items) do
			table.insert(result, item)
		end
	end

	return result
end

return function(object)
	local page = object:FindPage("Profiles")

	if not page then
		warn("[Profiles] no Profiles page frame found")
		return
	end

	local v = Render.Mount(object, page)

	if not v then
		return
	end

	v.editingEnabled = object:IsCapabilityEnabled("profileEditing")
	local v2 = Edit.new(object, v, page)
	local v3 = nil
	local v4 = nil
	local name = nil
	local v5 = {}
	local flag = false

	local function pruneFetchCache()
		local now = os.clock()

		for k, v6 in pairs(v5) do
			if now - v6.at >= 30 then
				v5[k] = nil
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function currentSnapshot()
		return v3 or v2:GetDisplaySnapshot()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function repaint()
		local v6 = currentSnapshot() -- equivalent call inferred; original call site unknown

		if v6 then
			Render.Apply(v, v6)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function showCurrent()
		if v3 and v3 ~= v4 then
			v3 = nil
		end

		Render.Invalidate(v)
		repaint() -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function leavePage()
		v2:Exit(true)
		v4 = nil
		Render.StopThumbnailEffects(v)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function showOwnProfile()
		v4 = nil

		if not v3 then
			return
		end

		v3 = nil
		Render.Invalidate(v)
		repaint() -- equivalent call inferred; original call site unknown
	end

	local v6 = Takeover.Bind(object, page, {
		isViewingOther = function()
			return v3 ~= nil
		end,
		guardLeave = function(p)
			return v2:GuardLeave(p)
		end
	})
	MenuManager:SetBackGuard("DreamJournal", function(p)
		return v2:GuardLeave(p)
	end)
	local RunService = game:GetService("RunService")

	if RunService:IsStudio() then
		print("[Profiles] Back guard registered for", "DreamJournal")
	end

	local titleEditButton = v.titleEditButton

	if v6 and titleEditButton and titleEditButton:IsA("GuiButton") then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function goToTitles()
			v6.GoToPage("Titles")
		end

		object:BindButton(titleEditButton, function()
			if v2:GuardLeave(goToTitles) then
				return
			end

			goToTitles() -- equivalent call inferred; original call site unknown
		end)
	end

	local function showProfile(value: number)
		if type(value) ~= "number" then
			return false, "Invalid user id"
		end

		local myReplica = MyDataController:getMyReplica()
		local data = myReplica and myReplica.Data
		local v7

		if data == nil then
			v7 = false
		else
			v7 = data.EquippedTitle == "DandysBud"
		end

		if v7 then
			DisplayMessage("You must complete Dandy's Quests first!", nil, nil, true)
			return false, "Dandy's Bud"
		end

		if value == localPlayer.UserId then
			showOwnProfile() -- equivalent call inferred; original call site unknown
			object:Open()
			object:ShowPage("Profiles")
			return true
		else
			local v8 = v5[value]
			local snapshot = v8 and os.clock() - v8.at < 30 and v8.snapshot or nil

			if not snapshot then
				if flag then
					return false, "Already loading a profile"
				end

				flag = true
				local success, result
				success, result, snapshot = pcall(Network.Get, Network, "GetProfileCard", value)
				flag = false

				if not success then
					DisplayMessage("Couldn't load that profile just now.", nil, nil, true)
					return false, "Request failed"
				end

				if result == true then
					pruneFetchCache()
					v5[value] = {
						snapshot = snapshot,
						at = os.clock()
					}
				else
					local v9 = (result ~= false or type(snapshot) ~= "string" or not snapshot) and "Couldn't load that profile just now." or snapshot
					DisplayMessage(v9, nil, nil, true)
					return false, v9
				end
			end

			v2:Exit(true)

			if not v3 then
				name = object.activePage and object.activePage.Name or nil
			end

			v3 = snapshot
			v4 = snapshot
			Render.Invalidate(v)
			repaint() -- equivalent call inferred; original call site unknown
			object:Open()
			object:ShowPage("Profiles")
			return true
		end
	end

	object.ShowProfile = showProfile
	object.ShowOwnProfile = showOwnProfile
	object.gui:GetPropertyChangedSignal("Visible"):Connect(function()
		if object.gui.Visible then
			if page.Visible then
				showCurrent() -- equivalent call inferred; original call site unknown
			end
		else
			local v8 = v3 ~= nil and object.activePage == page and (name or "Overview") or nil
			leavePage() -- equivalent call inferred; original call site unknown

			if v8 and object:FindPage(v8) then
				name = nil
				object:ShowPage(v8)
			end
		end
	end)
	MyDataController:onReplicaReady(function(object2)
		local maid = Maid.new()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refresh()
			v2:SetSnapshot((buildSnapshot(object2)))

			if v3 then
				return
			end

			repaint() -- equivalent call inferred; original call site unknown
		end

		local function rebindStatListeners()
			maid:DoCleaning()
			local profileCard = object2.Data.ProfileCard

			for _, v7 in ipairs((selectedStatKeys(profileCard))) do
				local connection = object2:ListenToChange("Statistics." .. v7, refresh)
				maid:GiveTask(function()
					connection:Disconnect()
				end)
			end
		end

		object2:ListenToChange("ProfileCard", function()
			rebindStatListeners()
			Render.Invalidate(v)
			refresh() -- equivalent call inferred; original call site unknown
		end)
		object2:ListenToChange("EquippedTitle", refresh)
		object2:ListenToChange("EquippedTrinket1", refresh)
		object2:ListenToChange("EquippedTrinket2", refresh)
		object2:ListenToChange("BackgroundsOwned", refresh)
		object2:ListenToChange("FramesOwned", refresh)
		object2:ListenToChange("BackdropsOwned", refresh)
		rebindStatListeners()
		refresh() -- equivalent call inferred; original call site unknown
	end, function()
		warn("[Profiles] replica unavailable; rendering empty card")
		Render.Apply(v, {
			IsSelf = false,
			ProfileCard = nil
		})
	end)
	page:GetAttributeChangedSignal("EditMode"):Connect(function()
		local v7 = currentSnapshot() -- equivalent call inferred; original call site unknown
		Render.SetEditable(v, v7 ~= nil and v7.IsSelf == true and v.editingEnabled ~= false, v7)
	end)
	page:GetPropertyChangedSignal("Visible"):Connect(function()
		if page.Visible then
			if object.gui.Visible then
				showCurrent() -- equivalent call inferred; original call site unknown
			end
		else
			name = nil
			leavePage() -- equivalent call inferred; original call site unknown

			for _, v7 in ipairs(ProfileCardConfig.SlotOrder) do
				local section = v.sections[v7]
				local thumbnail = section and section.types and section.types.Thumbnail
				local thumbnail2 = thumbnail and thumbnail.thumbnail

				if not thumbnail2 then
					continue
				end

				if thumbnail2.sticker then
					UITemplates.Release(thumbnail2.sticker)
				end

				if thumbnail2.viewport then
					ToonViewport.Clear(thumbnail2.viewport)
				end
			end
		end
	end)
end