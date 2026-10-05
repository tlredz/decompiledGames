local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local StarterGui = game:GetService("StarterGui")
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Packages.Trove)
local v5 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v6 = require3(ReplicatedStorage2.Common.Utils)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.TradeRequestController)
local v8 = require3(ReplicatedStorage2.Controllers.ViewInventoryController)
local v9 = require3(ReplicatedStorage2.Shared.TitleData)
local v10 = require3(ReplicatedStorage2.Shared.EmoteIds)
local v11 = require3(ReplicatedStorage2.ServerInfo)
local v12 = require3("@game/ReplicatedStorage/Shared/PlayerData/CountryIcons")
local v13 = require3("@game/ReplicatedStorage/Shared/TitleData")
local v14 = require3("@game/ReplicatedStorage/Packages/Chroma")
local v15 = require3(ReplicatedStorage2.Shared.RankData)
require3(ReplicatedStorage2.Shared.RankedSeasonData)
local v16 = require3(ReplicatedStorage2.Packages.Charm)
local v17 = require3(ReplicatedStorage2.ClientGameModules.DeviceListener)
require3(ReplicatedStorage2.Shared.PlayerProfile)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v18 = require3(ReplicatedStorage2.Common.ProfileCards)
local profileCard = playerGui.ProfileCard
local customize = profileCard.Customize
local profile = customize.Profile
local playerCard = customize.PlayerCard
local backgrounds = customize.Backgrounds
local uDim = UDim2.fromScale(0, 0.5)
local vector = Vector2.new(0, 0.5)
local uDim2 = UDim2.fromScale(0.5, 0.5)
local vector2 = Vector2.new(0.5, 0.5)
local playerProfile = profile.PlayerProfile
local details = playerProfile.Details
local stats = playerProfile.Stats
local buttons = profile.Buttons
local _ = profile.Background.Image
local _ = playerCard.Bg.Image
local scrollingframe = profile.Achievements.Scrollingframe
local template = scrollingframe.Template
template.Visible = false
local currentCamera = workspace.CurrentCamera
local maid = v4.new()
local remoteEvent = v3:RemoteEvent("PlayerProfile/UpdateDevice")
local remoteEvent2 = v3:RemoteEvent("PlayerProfile/SetActiveBackground")
local remoteEvent3 = v3:RemoteEvent("PlayerProfile/ToggleStat")
local remoteEvent4 = v3:RemoteEvent("DuelPartyInvite")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Dead }
local highlight = Instance.new("Highlight")
highlight.Name = "LobbyProfile"
highlight.FillTransparency = 1
highlight.OutlineTransparency = 0
highlight.OutlineColor = Color3.fromRGB(255, 170, 0)
highlight.Parent = ReplicatedStorage2
local atom = v16.atom(true)
local atom2 = v16.atom(nil)
local v19 = nil
local PlayerProfileController = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function isFriendsWith(player)
	local success, result = pcall(function()
		return localPlayer:IsFriendsWith(player.UserId)
	end)
	return success and result
end

local function raycastPlayer(point: Vector2?)
	if not atom() then
		return nil
	end

	local v20 = point or v:GetMouseLocation()
	local viewportPointToRay = currentCamera:ViewportPointToRay(v20.X, v20.Y)
	local raycastResult = workspace:Raycast(
		viewportPointToRay.Origin,
		viewportPointToRay.Direction * 300,
		raycastParams
	)

	if not (raycastResult and raycastResult.Instance) then
		return nil
	end

	local model = raycastResult.Instance:FindFirstAncestorWhichIsA("Model")

	if model then
		return Players:GetPlayerFromCharacter(model)
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBackgroundInfo(value: string?)
	local backgrounds2 = v18.Backgrounds
	return backgrounds2[value or "Default"] or backgrounds2.Default
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setProfileBackground(value: string?)
	local backgroundInfo = getBackgroundInfo(value) -- equivalent call inferred; original call site unknown
	profile.Background.Image = backgroundInfo.ProfileImage
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPlayerCardBackground(value: string?)
	local backgroundInfo = getBackgroundInfo(value) -- equivalent call inferred; original call site unknown
	playerCard.Bg.Image = backgroundInfo.PlayerImage
end

local v20 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function setCustomizingProfile(visible: boolean)
	v20 = visible
	playerCard.Visible = visible
	backgrounds.Visible = visible
	local v21 = profile
	local anchorPoint

	if visible then
		anchorPoint = vector
	else
		anchorPoint = vector2
	end

	v21.AnchorPoint = anchorPoint
	local v23 = profile
	local position

	if visible then
		position = uDim
	else
		position = uDim2
	end

	v23.Position = position
end

v20 = false
playerCard.Visible = false
backgrounds.Visible = false
profile.AnchorPoint = vector2
profile.Position = uDim2
profileCard:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not profileCard.Enabled then
		v20 = false
		playerCard.Visible = false
		backgrounds.Visible = false
		profile.AnchorPoint = vector2
		profile.Position = uDim2
	end
end)

local function bindStatToggle(button, p: string, flag: boolean, p2)
	local state = button:FindFirstChild("State")

	if flag then
		button.Visible = true

		local function updateToggleState()
			if not state then
				return
			end

			state.Image = v19:Get({ "DisabledProfileStats", p }) == true and "rbxassetid://117471958252774" or "rbxassetid://137974401557996"
			state.Visible = true
		end

		maid:Add(v19:OnChange({ "DisabledProfileStats", p }, updateToggleState))
		task.defer(updateToggleState)

		if button:IsA("GuiButton") then
			maid:Add(button.Activated:Connect(function()
				remoteEvent3:FireServer(p)
			end))
		end
	else
		button.Visible = p2 ~= nil

		if state then
			state.Visible = false
		end
	end
end

function PlayerProfileController:ViewProfile(player)
	if v5._currentGui ~= nil then
		return
	end

	local v21 = v3:Invoke("PlayerProfile/GetProfile", player)

	if not v21 then
		ReplicatedStorage2.Misc.error:Play()
		return
	end

	local active = localPlayer == player
	maid:Clean()
	atom2(player)
	local count = 0

	local function addAchievement(text: string, text2: string, image: string, p: string, p2)
		if p2 == nil and not active then
			return
		end

		count += 1
		local clone = template:Clone()
		clone.Active = active
		clone.Name = string.format("Achievement%02d", count)
		clone.LayoutOrder = count
		clone.Title.Text = text
		clone.Description.Text = text2
		clone.Icon.Image = image
		clone.Visible = true
		clone.Parent = scrollingframe
		bindStatToggle(clone, p, active, p2)
		maid:Add(clone)
	end

	playerProfile.Player.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
	setProfileBackground(v21.ActiveProfileBackground) -- equivalent call inferred; original call site unknown
	local clanTag

	if player:GetAttribute("ShowClanTagInChat") then
		clanTag = player:GetAttribute("ClanTag")
	end

	local username1 = details.Username1
	local text3

	if clanTag then
		text3 = `[{clanTag}] {player.DisplayName}`
	else
		text3 = player.DisplayName
	end

	username1.Text = text3
	details.Username.Text = `@{player.Name}`
	local v24 = v21.Country and v12[v21.Country]
	details.Country.Text = not v24 and "" or v24.Emoji

	if v21.Device then
		details.Device.Image = v6.Icons:GetIcon(v21.Device or "DEFAULT_MISSING")
		details.Device.Visible = true
	else
		details.Device.Visible = false
	end

	addAchievement(
		"Time Played",
		v6.ValueConvertor:FormatShortTime(v21.TimePlayed or 0),
		"rbxassetid://15418299869",
		"TimePlayed",
		v21.TimePlayed
	)
	addAchievement(
		"Games Played",
		v6.ValueConvertor:AddCommas(v21.Matches or 0),
		"rbxassetid://15418300727",
		"Matches",
		v21.Matches
	)
	addAchievement(
		"Best Win Streak",
		v6.ValueConvertor:AddCommas(v21.BestWinStreak or 0),
		"rbxassetid://15418301957",
		"BestWinStreak",
		v21.BestWinStreak
	)

	if v21.MostValuableItem then
		local type = v21.MostValuableItem.Type
		local name = v21.MostValuableItem.Item.Name
		local swordIcon

		if type == "Sword" then
			swordIcon = v6.Icons:GetSwordIcon(name)
		elseif type == "Emote" then
			swordIcon = v6.Icons:GetEmoteIcon(name)
		elseif type == "Explosion" then
			swordIcon = v6.Icons:GetExplosionIcon(name)
		else
			swordIcon = v6.Icons:GetIcon("DEFAULT_MISSING")
		end

		if type == "Emote" then
			name = v10.IdsToEmotes[name] or name
		end

		local RAP = v21.MostValuableItem.RAP
		addAchievement(
			"Most Valuable Item",
			`{name}\n{`{v6.ValueConvertor:ShrinkNumber(RAP)}{RAP > 1000 and "+" or ""} RAP`}`,
			swordIcon,
			"MostValuableItem",
			v21.MostValuableItem
		)
	end

	if v21.MostUsedAbility then
		local name = v21.MostUsedAbility.Name
		local times = v21.MostUsedAbility.Times
		addAchievement(
			"Most Used Ability",
			`{name}\n{v6.ValueConvertor:AddCommas(times)} Games`,
			v6.Icons:GetAbilityIcon(name),
			"MostUsedAbility",
			v21.MostUsedAbility
		)
	end

	if v21.FFAElo then
		local rank = v15.GetRank(v21.FFAElo)
		playerProfile.Icon.Image = rank.Icon
		playerProfile.Icon.Visible = true
	else
		playerProfile.Icon.Visible = false
	end

	local v25 = nil

	if v21.Title then
		for _, v27 in v9 do
			if v27.Name ~= v21.Title then
				continue
			end

			v25 = v27
			break
		end
	end

	if v25 then
		details.Title.Text = v25.Tag.Text
		details.Title.TextColor3 = v25.Tag.Color
		details.Title.Visible = true
	else
		details.Title.Visible = false
	end

	v20 = false
	playerCard.Visible = false
	backgrounds.Visible = false
	profile.AnchorPoint = vector2
	profile.Position = uDim2

	if active then
		playerProfile.Addplayer.Visible = false
		buttons.Trade.Visible = false
		buttons.Invite.Visible = false
		buttons.Customise.Visible = false
		buttons.Customise.Button.Customize.Text = "Customize"
		maid:Add(buttons.Customise.Button.Activated:Connect(function()
			setCustomizingProfile(not v20) -- equivalent call inferred; original call site unknown
		end))
	else
		local friendsWith = isFriendsWith(player) -- equivalent call inferred; original call site unknown
		playerProfile.Addplayer.Visible = not friendsWith
		buttons.Trade.Visible = true
		buttons.Invite.Visible = true
		buttons.Customise.Visible = true
		buttons.Customise.Button.Customize.Text = "Inventory"

		if not friendsWith then
			maid:Add(playerProfile.Addplayer.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end

				xpcall(function()
					StarterGui:SetCore("PromptSendFriendRequest", player)
				end, warn)
			end))
		end

		maid:Add(buttons.Trade.Button.Activated:Connect(function()
			v7:SendTrade(player)
		end))
		maid:Add(buttons.Invite.Button.Activated:Connect(function()
			remoteEvent4:FireServer(player)
		end))
		maid:Add(buttons.Customise.Button.Activated:Connect(function()
			v8:ViewInventory(player)
		end))
	end

	if v21.VoiceChatEnabled == nil then
		details.Mic.Visible = false
	else
		details.Mic.Image = v21.VoiceChatEnabled and "rbxassetid://95476590782674" or "rbxassetid://88871599347249"
		details.Mic.Visible = true
	end

	stats.Kills.Amount.Text = v6.ValueConvertor:AddCommas(v21.Kills or 0)
	stats.Wins.Amount.Text = v6.ValueConvertor:AddCommas(v21.Wins or 0)
	local RAP = v21.RAP or 0
	stats.Rap.Amount.Text = `{v6.ValueConvertor:ShrinkNumber(RAP)}{RAP > 1000 and "+" or ""}`
	bindStatToggle(stats.Kills, "Kills", active, v21.Kills)
	bindStatToggle(stats.Wins, "Wins", active, v21.Wins)
	bindStatToggle(stats.Rap, "RAP", active, v21.RAP)
	local v26 = nil

	if v21.Title then
		for _, v28 in v13 do
			if v28.Name ~= v21.Title then
				continue
			end

			v26 = v28
			break
		end
	end

	playerCard.Title.Text = not v26 and "" or v26.Tag.Text or ""
	playerCard.Title.TextColor3 = v26 and v26.Tag.Color or Color3.fromRGB(255, 255, 255)
	playerCard.Title.UIStroke.Color = v26 and v14.roblox(v26.Tag.Color):darken(1):roblox() or Color3.fromRGB(
		255,
		255,
		255
	)
	playerCard.Username.Text = player.DisplayName
	playerCard.Pfp.Avatar.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
	playerCard.Kills.Amount.Text = `{v6.ValueConvertor:AddCommas(v21.Kills or 0)} Elims`
	playerCard.Kills.Shadow.Text = playerCard.Kills.Amount.Text
	playerCard.Wins.Amount.Text = `{v6.ValueConvertor:AddCommas(v21.Wins or 0)} Wins`
	playerCard.Wins.Shadow.Text = playerCard.Wins.Amount.Text
	playerCard.Icons.Device.Image = v6.Icons:GetIcon(v21.Device or "DEFAULT_MISSING")
	playerCard.Icons.Country.Text = not v24 and "" or v24.Emoji
	maid:Add(profile.Close.Activated:Connect(function()
		v5:Close("ProfileCard")
		v20 = false
		playerCard.Visible = false
		backgrounds.Visible = false
		profile.AnchorPoint = vector2
		profile.Position = uDim2
		maid:Clean()
	end))
	v5:Open("ProfileCard")
end

function PlayerProfileController.Init(_) end

function PlayerProfileController:Start()
	if v11.isRegionalTournamentMatch() then
		return
	end

	local function updateIsDead(p)
		local character = localPlayer.Character
		atom(not character or not character.Parent or character:IsDescendantOf(workspace.Dead))

		if p == character then
			v5:Close("ProfileCard", true)
			v20 = false
			playerCard.Visible = false
			backgrounds.Visible = false
			profile.AnchorPoint = vector2
			profile.Position = uDim2
		end
	end

	local character = localPlayer.Character
	atom(not character or not character.Parent or character:IsDescendantOf(workspace.Dead))

	if character == nil then
		v5:Close("ProfileCard", true)
		v20 = false
		playerCard.Visible = false
		backgrounds.Visible = false
		profile.AnchorPoint = vector2
		profile.Position = uDim2
	end

	workspace.Dead.ChildAdded:Connect(updateIsDead)
	workspace.Dead.ChildRemoved:Connect(updateIsDead)
	localPlayer.CharacterAdded:Connect(updateIsDead)
	localPlayer.CharacterRemoving:Connect(updateIsDead)
	workspace.Alive.ChildAdded:Connect(updateIsDead)
	workspace.Alive.ChildRemoved:Connect(updateIsDead)
	v16.effect(function()
		local v21 = atom()
		atom2()

		if not v21 then
			highlight.Adornee = nil
			v5:Close("ViewInventory", true)
			v5:Close("ProfileCard", true)
			v20 = false
			playerCard.Visible = false
			backgrounds.Visible = false
			profile.AnchorPoint = vector2
			profile.Position = uDim2
			maid:Clean()
		end
	end)
	v19 = v2.Client:WaitReplion("Data")
	local template2 = backgrounds.Scrollingframe.Template
	local image = template2.Map.Image
	local clones = {}
	template2.Parent = script

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ownsBackground(k: string)
		return k == "Default" or v19:Get({ "OwnedProfileBackgrounds", k }) == true
	end

	local function updateBackgroundButtons()
		local activeProfileBackground = v19:Get("ActiveProfileBackground")
		local v21 = not v18.Backgrounds[activeProfileBackground or "Default"] and "Default" or activeProfileBackground

		for k, v22 in clones do
			local v23 = ownsBackground(k) -- equivalent call inferred; original call site unknown
			v22.Map.ImageTransparency = v23 and 0 or 0.5
			v22.Lock.Visible = not v23
			v22.IsSelected.Visible = v21 == k
		end
	end

	for k, background in v18.Backgrounds do
		local clone = template2:Clone()
		local profileImage = background.ProfileImage
		clone.Name = k
		local map = clone.Map

		if profileImage == "" then
			profileImage = image
		end

		map.Image = profileImage
		clone.Parent = backgrounds.Scrollingframe
		clones[k] = clone
		local v21 = k
		clone.Activated:Connect(function()
			if not ownsBackground(v21) then
				return
			end

			remoteEvent2:FireServer(v21)
		end)
	end

	setPlayerCardBackground(v19:Get("ActiveProfileBackground")) -- equivalent call inferred; original call site unknown
	updateBackgroundButtons()
	v19:OnChange("ActiveProfileBackground", function(p)
		setPlayerCardBackground(p) -- equivalent call inferred; original call site unknown

		if atom2() == localPlayer then
			setProfileBackground(p) -- equivalent call inferred; original call site unknown
		end

		updateBackgroundButtons()
	end)
	v19:OnChange("OwnedProfileBackgrounds", updateBackgroundButtons)
	local maid2 = v4.new()
	v17:Observe(function(p)
		maid2:Clean()
		local v21 = 0
		local count = 0
		local thread = nil

		if p == "PC" or p == "Console" then
			local total = 0
			maid2:Add(RunService.Heartbeat:Connect(function(dt)
				if atom() and not localPlayer:GetAttribute("LobbyTraining") and v.MouseBehavior == Enum.MouseBehavior.Default then
					total += dt

					if total <= 0.03333333333333333 then
						return
					end

					total = 0
					local v22 = raycastPlayer()

					if highlight.Adornee ~= v22 then
						local v23 = highlight
						local adornee

						if v22 and v22.Character then
							adornee = v22.Character
						end

						v23.Adornee = adornee
					end
				elseif highlight.Adornee then
					highlight.Adornee = nil
				end
			end))
			maid2:Add(v.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed or not atom() or localPlayer:GetAttribute("LobbyTraining") or v.MouseBehavior ~= Enum.MouseBehavior.Default then
					return
				end

				if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.KeyCode ~= Enum.KeyCode.ButtonX then
					return
				end

				local now = os.clock()
				local _ = now - v21
				v21 = now

				if thread then
					task.cancel(thread)
				end

				thread = task.delay(1, function()
					count = 0
					thread = nil
				end)
				count += 1

				if count >= 2 then
					local v22 = raycastPlayer()

					if v22 ~= nil then
						self:ViewProfile(v22)
					end

					count = 0
				end
			end))
		else
			maid2:Add(v.TouchTapInWorld:Connect(function(p2)
				thread = task.delay(1, function()
					count = 0
					thread = nil
				end)
				count += 1

				if count >= 2 then
					local v22 = raycastPlayer(p2)

					if v22 ~= nil then
						self:ViewProfile(v22)
					end
				end
			end))
		end

		remoteEvent:FireServer(p)
	end)
end

return PlayerProfileController