local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local gamemodes = module.Interface:WaitForChild("Frames"):WaitForChild("Gamemodes")
local title = gamemodes:WaitForChild("Header"):WaitForChild("Title")
local main = gamemodes:WaitForChild("Main")
local currency = gamemodes:WaitForChild("Currency")
local title2 = currency:WaitForChild("Title")
local icon = currency:WaitForChild("Icon")
local party = main:WaitForChild("Party")
local scroll = party:WaitForChild("List"):WaitForChild("Scroll")
local main2 = party:WaitForChild("Create"):WaitForChild("Main"):WaitForChild("Create"):WaitForChild("Main")
local setup = main:WaitForChild("Setup")
local gamemode = setup:WaitForChild("Gamemode")
local thumb = gamemode:WaitForChild("Thumb")
local gamemodeName = gamemode:WaitForChild("GamemodeName")
local information = gamemode:WaitForChild("Information")
local data = gamemode:WaitForChild("Data")
local difficulties = data:WaitForChild("Difficulties")
local difficultiesLabel = data:WaitForChild("DifficultiesLabel")
local drops = data:WaitForChild("Drops")
local time = setup:WaitForChild("Time")
local value = time:WaitForChild("Value")
local friendsOnly = setup:WaitForChild("FriendsOnly")
local on = friendsOnly:WaitForChild("On")
local main3 = on:WaitForChild("Main")
local off = friendsOnly:WaitForChild("Off")
local main4 = off:WaitForChild("Main")
local buttons = setup:WaitForChild("Buttons")
local play = buttons:WaitForChild("Play")
local main5 = play:WaitForChild("Main")
local leave = buttons:WaitForChild("Leave")
local main6 = leave:WaitForChild("Main")
local playersAmount = setup:WaitForChild("PlayersAmount")
local scroll2 = setup:WaitForChild("Players"):WaitForChild("Scroll")
local gamemodes2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Gamemodes")
local party2 = gamemodes2:WaitForChild("Party")
local drop = gamemodes2:WaitForChild("Drop")
local difficulty = gamemodes2:WaitForChild("Difficulty")
local information2 = gamemodes2:WaitForChild("Information")
local player = gamemodes2:WaitForChild("Player")
local gamemodeName2 = nil
local v = nil
local v2 = {}
local v3 = {}
local clones = {}
local v4 = {}
local v5 = nil
local v6 = nil
local v7 = {}
local count = 0
local count2 = 0
local flag = false
local flag2 = false
local v8 = 0
local connection = nil
local connection2 = nil
local v9 = nil
local v10 = nil
local v11 = {}
local count3 = 0
local v12 = nil
local heartbeatConnection = nil
local v13 = 0
local v14 = 0
local v15 = nil
local connection3 = nil
local Controller = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function LoadPlayerIcon(main7, p: number)
	task.spawn(function()
		local playerIcon = module.Utils.Players.GetPlayerIcon(p)

		if main7.Parent then
			main7.Image = playerIcon
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetActiveGamemodeName()
	if v9 then
		return v9
	end

	if v then
		return v.GamemodeName
	end

	return gamemodeName2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetActiveDifficulty(p)
	if v9 or not v then
		return module.Shared.Gamemodes.GetOrderedDifficulties(p)[1]
	end

	return v.Difficulty
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetActiveGamemodeInfo()
	local activeGamemodeName = GetActiveGamemodeName() -- equivalent call inferred; original call site unknown

	if activeGamemodeName then
		return module.Shared.Gamemodes.List[activeGamemodeName]
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetDifficultyInfo(p, p2: string?)
	return module.Shared.Gamemodes.GetDifficultyInfo(p, p2)
end

local function RefreshCurrency()
	local getPrice = module.Shared.Gamemodes.GetPrice
	local activeGamemodeInfo = GetActiveGamemodeInfo() -- equivalent call inferred; original call site unknown
	local price = getPrice(activeGamemodeInfo)
	local v17 = price and module.Utils.Info:Get(price.Type, price.Name)
	currency.Visible = v17 ~= nil

	if not v17 then
		return
	end

	local priceAmount = module.Shared.Gamemodes.GetPriceAmount(module.Data, price)
	title2.Text = `{module.Utils.Number:Format(priceAmount)} / {module.Utils.Number:Format(price.Amount)}`
	icon.Visible = typeof(v17.Icon) == "string" and v17.Icon ~= ""
	icon.Image = icon.Visible and v17.Icon or ""
end

local function GetGamemodeDrops(p, p2: string?)
	local difficultyInfo = GetDifficultyInfo(p, p2) -- equivalent call inferred; original call site unknown

	if not difficultyInfo or typeof(difficultyInfo.Drops) ~= "table" then
		return {}
	end

	local v17 = {}
	local result = {}

	for _, v18 in { "Normal", "Boss" } do
		local drop2 = difficultyInfo.Drops[v18]

		if typeof(drop2) ~= "table" then
			continue
		end

		for _, v19 in drop2 do
			if not module.Utils.PlayerStats.CanObtainDrop(v19, module.Data) then
				continue
			end

			local formatted = `{#v19.Type}:{v19.Type}{#v19.Name}:{v19.Name}:{v19.Shiny == true}`
			local v20 = v17[formatted]

			if v20 then
				v20.MinimumChance = math.min(v20.MinimumChance, v19.Chance)
				v20.MaximumChance = math.max(v20.MaximumChance, v19.Chance)
				v20.Minimum = math.min(v20.Minimum, v19.Minimum)
				v20.Maximum = math.max(v20.Maximum, v19.Maximum)
			else
				local v21 = {
					Key = formatted,
					Type = v19.Type,
					Name = v19.Name,
					Shiny = v19.Shiny == true,
					MinimumChance = v19.Chance,
					MaximumChance = v19.Chance,
					Minimum = v19.Minimum,
					Maximum = v19.Maximum
				}
				v17[formatted] = v21
				table.insert(result, v21)
			end
		end
	end

	table.sort(result, function(a, b)
		if a.MinimumChance == b.MinimumChance then
			return a.Key < b.Key
		end

		return a.MinimumChance < b.MinimumChance
	end)
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HasMapAccess(p)
	if p then
		return module.Utils.PlayerStats.OwnsMap(p.MapName, module.Data)
	end

	return false
end

local function NotifyMapLocked()
	module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
		Message = "You haven't unlocked this map yet.",
		Color = Color3.new(1, 0, 0)
	})
end

local function NotifyAlreadyInOtherParty()
	module.Signal:FireSelf("Interface", "Notifications", "Create", "Text", {
		Message = "You're already in a party for another gamemode.",
		Color = Color3.new(1, 1, 0)
	})
end

local function ToggleFriendsOnly()
	if v9 or not v then
		return
	end

	local v16 = v.Visibility == "Friends" and "Public" or "Friends"
	module.Signal:Fire("General", "Parties", "SetVisibility", v16)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearDifficultyRows()
	for _, v16 in clones do
		v16:Destroy()
	end

	table.clear(clones)
end

local function BuildDifficultyButtons(p)
	ClearDifficultyRows() -- equivalent call inferred; original call site unknown

	if not p or p.Style == "Scheduled" then
		return
	end

	for _, v16 in module.Shared.Gamemodes.GetOrderedDifficulties(p) do
		local clone = difficulty:Clone()
		clone.Name = v16
		clone.Visible = true
		clone.Main.Title.Text = v16
		local v17 = v16
		module.Button:Create(clone.Main, "Small"):BindFunction("Click", function()
			if v9 then
				return
			end

			module.Signal:Fire("General", "Parties", "SetDifficulty", v17)
		end)
		clone.Parent = difficulties
		table.insert(clones, clone)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshDifficultySelection()
	for _, v16 in clones do
		v16.Main.UIGradient.Enabled = v ~= nil and v.Difficulty == v16.Name
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CloseDropHover(p)
	if p.Hover and p.Hover.Element == p.Row then
		p.Hover:Close(nil, true)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CloseDropHovers()
	for _, v16 in v4 do
		CloseDropHover(v16) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoveDropRow(k: string)
	local v16 = v4[k]

	if not v16 then
		return
	end

	v4[k] = nil
	CloseDropHover(v16) -- equivalent call inferred; original call site unknown
	module.Utils.Camera.ClearViewport(v16.Row.Main.Viewport)
	v16.Scope:doCleanup()
	v16.Row:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearDropRows()
	for k in v4 do
		RemoveDropRow(k) -- equivalent call inferred; original call site unknown
	end

	v5 = nil
	v6 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatDropChance(p: number)
	return p >= 0.1 and `{module.Utils.Number:Round(p)}%` or "???"
end

local function BuildDrops(p)
	if p then
		local activeDifficulty = GetActiveDifficulty(p) -- equivalent call inferred; original call site unknown
		local activeGamemodeName = GetActiveGamemodeName() -- equivalent call inferred; original call site unknown
		local v18 = {}
		local count4 = 0

		if v5 ~= activeGamemodeName or v6 ~= activeDifficulty then
			CloseDropHovers() -- equivalent call inferred; original call site unknown
			v5 = activeGamemodeName
			v6 = activeDifficulty
		end

		for k, v19 in GetGamemodeDrops(p, activeDifficulty) do
			local v20 = module.Utils.Info:Get(v19.Type, v19.Name)

			if not v20 then
				continue
			end

			local key = v19.Key
			v18[key] = true
			local v21 = v4[key]

			if not v21 then
				local clone = drop:Clone()
				clone.Name = key
				clone.Visible = true
				clone.Main.UIGradient:SetAttribute("Rarity", v20.Rarity or "Common")

				if v20.Icon then
					clone.Main.Icon.Visible = true
					clone.Main.Viewport.Visible = false
					clone.Main.Icon.Image = v20.Icon
				else
					clone.Main.Icon.Visible = false
					clone.Main.Viewport.Visible = true
					module.Utils.Camera.ViewportCharacter({
						Viewport = clone.Main.Viewport,
						Animation = module.Utils.Characters.GetCharacterAnimation(v19.Name, "Idle"),
						Character = module.Utils.Characters.Get({
							Name = v19.Name,
							Shiny = v19.Shiny,
							RemoveHumanoidStates = true
						})
					})
				end

				local scope = fusion.scoped(fusion)
				local value2 = scope:Value(0)
				local uIScale = Instance.new("UIScale")
				uIScale.Scale = 0
				uIScale.Parent = clone
				scope:Hydrate(uIScale)({
					Scale = scope:Spring(value2, 10, 1)
				})
				local hover = module.Libs.NeoHover.GetByPseudoIdentifier(v19.Type)
				local clone2 = table.clone(v20)
				clone2.Name = v19.Name
				clone2.Shiny = v19.Shiny
				local v23 = {
					IsFake = true,
					Data = clone2,
					Name = v19.Name
				}

				if not hover then
					hover = module.Libs.NeoHover.GetByIdentifier("Tooltip")
					v23 = {
						Text = v19.Name
					}
				end

				v21 = {
					Row = clone,
					Scope = scope,
					Hover = hover
				}
				v4[key] = v21
				local v24 = module.Button:Create(clone.Main, "Small")
				v24:BindFunction("Click", function()
					if not hover then
						return
					end

					hover:Click(clone, v23)
				end)
				local v26 = clone
				v24:BindOnEnter("Hover", function()
					if not hover then
						return
					end

					hover:Open(v26, v23)
				end)
				local v27 = clone
				v24:BindOnLeave("Hover", function()
					if not hover then
						return
					end

					hover:Close(v27)
				end)
				clone.Parent = drops
				local name = key
				local v29 = v21
				task.delay(count4 * 0.05, function()
					if v4[name] ~= v29 then
						return
					end

					value2:set(1)
				end)
				count4 += 1
			end

			local row = v21.Row
			local formatDropChance = FormatDropChance(v19.MinimumChance) -- equivalent call inferred; original call site unknown
			local formatDropChance2 = FormatDropChance(v19.MaximumChance) -- equivalent call inferred; original call site unknown
			row.LayoutOrder = k
			row.Main.Chance.Text = v19.MinimumChance == v19.MaximumChance and formatDropChance or `{formatDropChance}~{formatDropChance2}`
			row.Main.Amount.Text = v19.Minimum == v19.Maximum and `{module.Utils.Number:Format(v19.Maximum)}x` or `{module.Utils.Number:Format(v19.Minimum)}~{module.Utils.Number:Format(v19.Maximum)}x`
		end

		for k in v4 do
			if v18[k] then
				continue
			end

			RemoveDropRow(k) -- equivalent call inferred; original call site unknown
		end
	else
		ClearDropRows() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearInfoRows()
	for _, v16 in v7 do
		v16:Destroy()
	end

	table.clear(v7)
end

local function GetEnemyHealthRange(data2)
	local waveMultiplier = data2.WaveMultiplier or 1
	local maxWave = data2.MaxWave or 1
	local v16 = (data2.StarterHealth or 0) * (data2.HealthMultiplier or 1)
	return v16, v16 * waveMultiplier ^ math.max(0, maxWave - 1)
end

local v16 = {
	Raid = function(data2)
		local waveMultiplier = data2.WaveMultiplier or 1
		local maxWave = data2.MaxWave or 1
		local v17 = (data2.StarterHealth or 0) * (data2.HealthMultiplier or 1)
		local v18 = v17 * waveMultiplier ^ math.max(0, maxWave - 1)
		return {
			`Enemies HP: {module.Utils.Number:Format(v17)}~{module.Utils.Number:Format(v18)}`,
			`Max Wave: {data2.MaxWave or "-"}`,
			(`Wave Time: {data2.WaveTime and module.Utils.Number:Time2(data2.WaveTime) or "-"}`)
		}
	end
}

function v16.ShieldedRaid(p)
	local raid = v16.Raid(p)

	if p.ShieldWaveInterval then
		table.insert(raid, (`Boss Every: {p.ShieldWaveInterval} waves`))
	end

	if p.ShieldBreakCount then
		table.insert(raid, (`Shield Phases: {p.ShieldBreakCount}`))
	end

	return raid
end

function v16.Defense(data2)
	local waveMultiplier = data2.WaveMultiplier or 1
	local maxWave = data2.MaxWave or 1
	local v17 = (data2.StarterHealth or 0) * (data2.HealthMultiplier or 1)
	local v18 = v17 * waveMultiplier ^ math.max(0, maxWave - 1)
	return {
		`Max Wave: {data2.MaxWave or "-"}`,
		`Base Lives: {data2.BaseHealth or "-"}`,
		(`Enemies HP: {module.Utils.Number:Format(v17)}~{module.Utils.Number:Format(v18)}`)
	}
end

function v16.Trial(data2)
	local waveMultiplier = data2.WaveMultiplier or 1
	local maxWave = data2.MaxWave or 1
	local v17 = (data2.StarterHealth or 0) * (data2.HealthMultiplier or 1)
	local v18 = v17 * waveMultiplier ^ math.max(0, maxWave - 1)
	return {
		`Enemies HP: {module.Utils.Number:Format(v17)}~{module.Utils.Number:Format(v18)}`,
		`Max Wave: {data2.MaxWave or "-"}`,
		(`Total Time: {module.Utils.Number:Time2(data2.TotalTime or 0)}`)
	}
end

function v16.Dungeon(data2)
	local v17 = (data2.StarterHealth or 0) * (data2.HealthMultiplier or 1)
	return {
		`Starting HP: {module.Utils.Number:Format(v17)}`,
		`Rooms: {data2.MinimumRooms or "-"}~{data2.MaximumRooms or "-"}`,
		(`Total Time: {module.Utils.Number:Time2(data2.TotalTime or 0)}`)
	}
end

local function RefreshInformation(p)
	if not p then
		return
	end

	local activeDifficulty = GetActiveDifficulty(p) -- equivalent call inferred; original call site unknown
	local difficultyInfo = GetDifficultyInfo(p, activeDifficulty) -- equivalent call inferred; original call site unknown

	if not difficultyInfo then
		return
	end

	local v19 = (v16[p.Type] or v16.Raid)(difficultyInfo)

	for k, text in v19 do
		local clone = v7[k]

		if not clone then
			clone = information2:Clone()
			clone.Name = `Info{k}`
			clone.Visible = true
			clone.LayoutOrder = k
			clone.Parent = information
			v7[k] = clone
		end

		clone.Text = text
	end

	for k, v20 in v7 do
		if v19[k] then
			continue
		end

		v20:Destroy()
		v7[k] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshFriendsOnly()
	if not v then
		return
	end

	local visible = v.Visibility == "Friends"
	on.Visible = visible
	off.Visible = not visible
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearMemberRows()
	for _, v17 in v3 do
		v17:Destroy()
	end

	table.clear(v3)
end

local function RefreshMembers()
	if not v then
		return
	end

	local v17 = v.Leader == module.Instance.UserId
	local v18 = {}

	for k, v19 in v.MemberOrder do
		v18[v19] = true
		local clone = v3[v19]

		if not clone then
			clone = player:Clone()
			clone.Name = tostring(v19)
			clone.Visible = true
			v3[v19] = clone
			LoadPlayerIcon(clone.Main.Icon.Main, v19) -- equivalent call inferred; original call site unknown
			local v20 = v19
			module.Button:Create(clone.Main.Buttons.Kick.Main, "Small"):BindFunction("Click", function()
				if v9 then
					return
				end

				module.Signal:Fire("General", "Parties", "Kick", v20)
			end)
			clone.Parent = scroll2
		end

		local playerByUserId = module.Services.Players:GetPlayerByUserId(v19)
		local displayName = playerByUserId and playerByUserId.DisplayName or `User {v19}`
		local name = playerByUserId and playerByUserId.Name or tostring(v19)
		clone.LayoutOrder = k
		clone.Main.NickName.Text = displayName
		clone.Main.UserName.Text = `(@{name})`
		clone.Main.Buttons.LeaderIcon.Visible = v19 == v.Leader
		local v20 = v19 == module.Instance.UserId
		clone.Main.Buttons.Kick.Visible = v17 and not v20
	end

	for k, v19 in v3 do
		if v18[k] then
			continue
		end

		v19:Destroy()
		v3[k] = nil
	end

	playersAmount.Text = `Players ({#v.MemberOrder}/{v.MaxMembers})`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RemoveScheduledRow(k: number)
	local v17 = v11[k]

	if not v17 then
		return
	end

	v11[k] = nil
	v17.Scope:doCleanup()
	v17.Row:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearScheduledRows()
	for k in v11 do
		RemoveScheduledRow(k) -- equivalent call inferred; original call site unknown
	end
end

local function RefreshScheduledMembers()
	local players = v10 and v10.Players or {}
	local v17 = {}
	local count4 = 0

	for k, player2 in players do
		local userId = player2.UserId
		v17[userId] = true
		local v18 = v11[userId]

		if not v18 then
			local clone = player:Clone()
			clone.Name = tostring(userId)
			clone.Visible = true
			clone.Main.Buttons.LeaderIcon.Visible = false
			clone.Main.Buttons.Kick.Visible = false
			local scope = fusion.scoped(fusion)
			local value2 = scope:Value(UDim2.fromScale(0.5, 1.5))
			scope:Hydrate(clone.Main)({
				Position = scope:Spring(value2, 10, 1)
			})
			v18 = {
				Row = clone,
				Scope = scope
			}
			v11[userId] = v18
			clone.Parent = scroll2
			LoadPlayerIcon(clone.Main.Icon.Main, userId) -- equivalent call inferred; original call site unknown
			local userId2 = userId
			local v20 = v18
			task.delay(count4 * 0.05, function()
				if v11[userId2] ~= v20 then
					return
				end

				value2:set(UDim2.fromScale(0.5, 0.5))
			end)
			count4 += 1
		end

		v18.Row.LayoutOrder = k
		v18.Row.Main.NickName.Text = player2.DisplayName
		v18.Row.Main.UserName.Text = `(@{player2.Name})`
	end

	for k in v11 do
		if v17[k] then
			continue
		end

		RemoveScheduledRow(k) -- equivalent call inferred; original call site unknown
	end

	playersAmount.Text = `Players ({#players})`
end

local function CanJoinScheduled()
	if not (v9 and v10) or (v15 or module.Data.Gamemode == v9) then
		return false
	end

	return v10.Status == "Opened" and workspace:GetServerTimeNow() < v10.EntryClosesAt
end

local function RefreshScheduledTime()
	if not v9 then
		return
	end

	local v17 = main5
	local interactable

	if v9 and v10 and not v15 and module.Data.Gamemode ~= v9 and v10.Status == "Opened" then
		interactable = workspace:GetServerTimeNow() < v10.EntryClosesAt
	else
		interactable = false
	end

	v17.Interactable = interactable
	main5.Selectable = main5.Interactable

	if not v10 then
		value.Text = "Loading..."
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local v19

	if v10.Status == "Opened" then
		v19 = serverTimeNow < v10.EntryClosesAt
	else
		v19 = false
	end

	local entryClosesAt = v19 and v10.EntryClosesAt or v10.NextOpensAt

	if not entryClosesAt then
		value.Text = "--:--"
		return
	end

	local v20 = math.max(0, (math.ceil(entryClosesAt - serverTimeNow)))
	local formatted = ("%02i:%02i"):format(math.floor(v20 / 60), v20 % 60)
	value.Text = v19 and `Join within {formatted}` or `Opens in {formatted}`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopPreview()
	count3 += 1
	v15 = nil
	v10 = nil

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	ClearScheduledRows() -- equivalent call inferred; original call site unknown
end

local function RefreshScheduledPreview()
	if v12 or not v9 or not module.Frame:IsFrameOpened(gamemodes) then
		return
	end

	local v17 = v9
	local v18 = count3
	local v19 = {}
	v12 = v19
	v13 = os.clock() + 1
	task.spawn(function()
		local success, result = pcall(function()
			return module.Signal:Invoke("General", "Gamemodes", "Preview", v17)
		end)

		if v12 == v19 then
			v12 = nil
		end

		if v18 ~= count3 or v9 ~= v17 or not module.Frame:IsFrameOpened(gamemodes) then
			return
		end

		if success and typeof(result) == "table" and result.GamemodeName == v17 then
			v10 = result
			RefreshScheduledMembers()
		else
			v10 = nil
		end

		RefreshScheduledTime()
	end)
end

local function StartPreview()
	StopPreview() -- equivalent call inferred; original call site unknown
	v13 = 0
	v14 = 0
	RefreshScheduledTime()
	RefreshScheduledMembers()
	RefreshScheduledPreview()
	heartbeatConnection = module.Services.RunService.Heartbeat:Connect(function()
		local now = os.clock()

		if v14 <= now then
			v14 = now + 1
			RefreshScheduledTime()
		end

		if v13 <= now then
			RefreshScheduledPreview()
		end
	end)
end

local function JoinScheduled()
	local v17

	if v9 and v10 and not v15 and module.Data.Gamemode ~= v9 and v10.Status == "Opened" then
		v17 = workspace:GetServerTimeNow() < v10.EntryClosesAt
	else
		v17 = false
	end

	if not v17 then
		return
	end

	local activeGamemodeInfo = GetActiveGamemodeInfo() -- equivalent call inferred; original call site unknown

	-- equivalent call inferred; original call site unknown
	if not HasMapAccess(activeGamemodeInfo) then
		NotifyMapLocked()
		return
	end

	local v19 = v9
	local v20 = count3
	local v21 = {}
	v15 = v21
	RefreshScheduledTime()
	task.delay(8, function()
		if v15 ~= v21 then
			return
		end

		v15 = nil
		RefreshScheduledTime()
	end)
	local success, result = pcall(function()
		return module.Signal:Invoke("General", "Gamemodes", "Join", v19)
	end)

	if v20 ~= count3 or v15 ~= v21 then
		return
	end

	if success and result then
		if module.Data.Gamemode == v19 then
			module.Frame:RemovePastUI()
			module.Frame:Close(gamemodes)
		end
	else
		v15 = nil
		RefreshScheduledTime()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearPartyRows()
	for _, v17 in v2 do
		v17:Destroy()
	end

	table.clear(v2)
end

local function PopulatePartyList(items)
	local activeGamemodeInfo = GetActiveGamemodeInfo() -- equivalent call inferred; original call site unknown
	local v18 = {}

	for k, item in items do
		local ID = item.ID
		v18[ID] = true
		local clone = v2[ID]

		if not clone then
			clone = party2:Clone()
			clone.Name = ID
			clone.Visible = true
			v2[ID] = clone
			local v19 = ID
			module.Button:Create(clone.Main.Join.Main, "Small"):BindFunction("Click", function()
				if v9 then
					return
				end

				local activeGamemodeInfo2 = GetActiveGamemodeInfo() -- equivalent call inferred; original call site unknown

				-- equivalent call inferred; original call site unknown
				if HasMapAccess(activeGamemodeInfo2) then
					module.Signal:Fire("General", "Parties", "Join", v19)
				else
					NotifyMapLocked()
				end
			end)
			clone.Parent = scroll
		end

		clone.LayoutOrder = k
		local playerByUserId = module.Services.Players:GetPlayerByUserId(item.Leader)
		local name = playerByUserId and playerByUserId.Name or tostring(item.Leader)

		if clone:GetAttribute("Leader") ~= item.Leader then
			clone:SetAttribute("Leader", item.Leader)
			LoadPlayerIcon(clone.Main.LeaderIcon.Main, item.Leader) -- equivalent call inferred; original call site unknown
		end

		if activeGamemodeInfo and activeGamemodeInfo.Thumb then
			clone.Main.Thumb.Image = activeGamemodeInfo.Thumb
		end

		clone.Main.Title.Value.Text = `@{name}`
		clone.Main.Members.Text = `Members: {#item.MemberOrder}/{item.MaxMembers}`
		clone.Main.Difficulty.Text = item.Difficulty
		clone.Main.Difficulty.TextColor3 = module.Utils.Colors:GetDifficultColor(item.Difficulty)
	end

	for k, v19 in v2 do
		if v18[k] then
			continue
		end

		v19:Destroy()
		v2[k] = nil
	end
end

local function RefreshPartyList()
	if v9 or v then
		return
	end

	count2 += 1
	flag = true

	if flag2 then
		return
	end

	flag2 = true
	task.defer(function()
		while flag do
			local v17 = v8 - os.clock()

			if v17 > 0 then
				task.wait(v17)
			end

			flag = false

			if v9 or v or not module.Frame:IsFrameOpened(gamemodes) then
				break
			end

			local activeGamemodeName = GetActiveGamemodeName() -- equivalent call inferred; original call site unknown

			if not activeGamemodeName then
				PopulatePartyList({})
				break
			end

			local v19 = count
			local v20 = count2
			local success, result = pcall(function()
				return module.Signal:Invoke("General", "Parties", "Browse", activeGamemodeName)
			end)
			v8 = os.clock() + 0.55

			if not success or typeof(result) ~= "table" or (v or v9) then
				continue
			end

			if not (v19 == count and v20 == count2) then
				continue
			end

			local activeGamemodeName2 = GetActiveGamemodeName() -- equivalent call inferred; original call site unknown

			if activeGamemodeName == activeGamemodeName2 and module.Frame:IsFrameOpened(gamemodes) then
				PopulatePartyList(result)
			end
		end

		flag2 = false
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartBrowseLoop()
	count += 1
	local v17 = count
	task.spawn(function()
		while v17 == count and module.Frame:IsFrameOpened(gamemodes) do
			if not (v or v9 or v) then
				count2 += 1
				flag = true

				if not flag2 then
					flag2 = true
					task.defer(function()
						while flag do
							local v18 = v8 - os.clock()

							if v18 > 0 then
								task.wait(v18)
							end

							flag = false

							if v9 or v or not module.Frame:IsFrameOpened(gamemodes) then
								break
							end

							local activeGamemodeName = GetActiveGamemodeName() -- equivalent call inferred; original call site unknown

							if not activeGamemodeName then
								PopulatePartyList({})
								break
							end

							local v20 = count
							local v21 = count2
							local success, result = pcall(function()
								return module.Signal:Invoke("General", "Parties", "Browse", activeGamemodeName)
							end)
							v8 = os.clock() + 0.55

							if not success or typeof(result) ~= "table" or (v or v9) then
								continue
							end

							if not (v20 == count and v21 == count2) then
								continue
							end

							local activeGamemodeName2 = GetActiveGamemodeName() -- equivalent call inferred; original call site unknown

							if activeGamemodeName == activeGamemodeName2 and module.Frame:IsFrameOpened(gamemodes) then
								PopulatePartyList(result)
							end
						end

						flag2 = false
					end)
				end
			end

			task.wait(3)
		end
	end)
end

local v17 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshGamemodeChrome(value2: string?, p)
	if value2 == v17 then
		return
	end

	v17 = value2
	thumb.Image = p and p.Thumb or thumb.Image
	gamemodeName.Text = value2 or ""
	title.Text = value2 or "Gamemode"
	BuildDifficultyButtons(p)
end

local function Refresh()
	local activeGamemodeName = GetActiveGamemodeName() -- equivalent call inferred; original call site unknown
	local activeGamemodeInfo = GetActiveGamemodeInfo() -- equivalent call inferred; original call site unknown
	RefreshGamemodeChrome(activeGamemodeName, activeGamemodeInfo) -- equivalent call inferred; original call site unknown
	RefreshCurrency()
	local v20 = v ~= nil
	local visible = v9 ~= nil
	party.Visible = not (visible or v20)
	setup.Visible = visible or v20
	difficultiesLabel.Visible = not visible
	difficulties.Visible = not visible
	friendsOnly.Visible = not visible
	time.Visible = visible
	leave.Visible = not visible

	if visible then
		play.Visible = true
		RefreshInformation(activeGamemodeInfo)
		BuildDrops(activeGamemodeInfo)
		RefreshScheduledTime()
	else
		main5.Interactable = true
		main5.Selectable = true

		if v20 then
			play.Visible = v.Leader == module.Instance.UserId
			RefreshInformation(activeGamemodeInfo)
			BuildDrops(activeGamemodeInfo)
			RefreshDifficultySelection() -- equivalent call inferred; original call site unknown
			RefreshFriendsOnly() -- equivalent call inferred; original call site unknown
			RefreshMembers()
		else
			ClearDropRows() -- equivalent call inferred; original call site unknown

			if not v9 then
				if v then
					return
				end

				count2 += 1
				flag = true

				if flag2 then
					return
				end

				flag2 = true
				task.defer(function()
					while flag do
						local v22 = v8 - os.clock()

						if v22 > 0 then
							task.wait(v22)
						end

						flag = false

						if v9 or v or not module.Frame:IsFrameOpened(gamemodes) then
							break
						end

						local activeGamemodeName2 = GetActiveGamemodeName() -- equivalent call inferred; original call site unknown

						if not activeGamemodeName2 then
							PopulatePartyList({})
							break
						end

						local v24 = count
						local v25 = count2
						local success, result = pcall(function()
							return module.Signal:Invoke("General", "Parties", "Browse", activeGamemodeName2)
						end)
						v8 = os.clock() + 0.55

						if not success or typeof(result) ~= "table" or (v or v9) then
							continue
						end

						if not (v24 == count and v25 == count2) then
							continue
						end

						local activeGamemodeName3 = GetActiveGamemodeName() -- equivalent call inferred; original call site unknown

						if activeGamemodeName2 == activeGamemodeName3 and module.Frame:IsFrameOpened(gamemodes) then
							PopulatePartyList(result)
						end
					end

					flag2 = false
				end)
			end
		end
	end
end

function Controller.OnSync(p)
	if not table.find(p.MemberOrder, module.Instance.UserId) then
		Controller.OnLeft(p.ID)
		return
	end

	v = p

	if v9 or not module.Frame:IsFrameOpened(gamemodes) then
		return
	end

	Refresh()
end

function Controller.OnLeft(p: string)
	if not v or v.ID ~= p then
		return
	end

	gamemodeName2 = v.GamemodeName
	v = nil

	if v9 then
		return
	end

	ClearMemberRows() -- equivalent call inferred; original call site unknown

	if not module.Frame:IsFrameOpened(gamemodes) then
		return
	end

	Refresh()
end

function Controller.OnDisbanded(p: string)
	Controller.OnLeft(p)
end

function Controller.OnKicked(p: string)
	Controller.OnLeft(p)
end

function Controller.OnBrowseChanged(p: string)
	if v9 or v or p ~= gamemodeName2 or not module.Frame:IsFrameOpened(gamemodes) then
		return
	end

	if not v9 then
		if v then
			return
		end

		count2 += 1
		flag = true

		if flag2 then
			return
		end

		flag2 = true
		task.defer(function()
			while flag do
				local v18 = v8 - os.clock()

				if v18 > 0 then
					task.wait(v18)
				end

				flag = false

				if v9 or v or not module.Frame:IsFrameOpened(gamemodes) then
					break
				end

				local activeGamemodeName = GetActiveGamemodeName() -- equivalent call inferred; original call site unknown

				if not activeGamemodeName then
					PopulatePartyList({})
					break
				end

				local v20 = count
				local v21 = count2
				local success, result = pcall(function()
					return module.Signal:Invoke("General", "Parties", "Browse", activeGamemodeName)
				end)
				v8 = os.clock() + 0.55

				if not success or typeof(result) ~= "table" or (v or v9) then
					continue
				end

				if not (v20 == count and v21 == count2) then
					continue
				end

				local activeGamemodeName2 = GetActiveGamemodeName() -- equivalent call inferred; original call site unknown

				if activeGamemodeName == activeGamemodeName2 and module.Frame:IsFrameOpened(gamemodes) then
					PopulatePartyList(result)
				end
			end

			flag2 = false
		end)
	end
end

function Controller.Start(value2: string)
	if typeof(value2) ~= "string" then
		return
	end

	local v18 = module.Shared.Gamemodes.List[value2]

	if not v18 then
		return
	end

	if v18.Style ~= "Scheduled" and v and v.GamemodeName ~= value2 then
		NotifyAlreadyInOtherParty()
		return
	end

	StopPreview() -- equivalent call inferred; original call site unknown
	ClearMemberRows() -- equivalent call inferred; original call site unknown
	ClearPartyRows() -- equivalent call inferred; original call site unknown
	count += 1
	flag = false
	v9 = v18.Style == "Scheduled" and value2 or nil
	gamemodeName2 = value2
	Refresh()
	local isFrameOpened = module.Frame:IsFrameOpened(gamemodes)
	module.Frame:Open(gamemodes)

	if isFrameOpened then
		if v9 then
			StartPreview()
			return
		end

		StartBrowseLoop() -- equivalent call inferred; original call site unknown
	end
end

function Controller.Init()
	for _, v18 in {
		difficulties,
		drops,
		information,
		scroll2
	} do
		for _, guiObject in v18:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end
	end

	if not connection3 then
		connection3 = module:OnDataChanged({ "Gamemode" }, function()
			if not (v9 and module.Frame:IsFrameOpened(gamemodes)) then
				return
			end

			if not v15 or module.Data.Gamemode ~= v9 then
				RefreshScheduledTime()
				return
			end

			module.Frame:RemovePastUI()
			module.Frame:Close(gamemodes)
		end)
	end

	if not connection then
		connection = module:OnDataChanged({}, function(_, _, list)
			if not module.Frame:IsFrameOpened(gamemodes) then
				return
			end

			local getPrice = module.Shared.Gamemodes.GetPrice
			local activeGamemodeInfo = GetActiveGamemodeInfo() -- equivalent call inferred; original call site unknown
			local price = getPrice(activeGamemodeInfo)

			if not price then
				return
			end

			local v19 = list and list[1]

			if not v19 or price.Type == "Item" and v19 == "Items" or price.Type == "Currency" and (v19 == price.Name or price.Name == "Gems" and v19 == "Items") then
				RefreshCurrency()
			end
		end)
	end

	if not connection2 then
		connection2 = module:OnDataChanged({ "Maps" }, function()
			if not (v5 and module.Frame:IsFrameOpened(gamemodes)) then
				return
			end

			local activeGamemodeInfo = GetActiveGamemodeInfo() -- equivalent call inferred; original call site unknown
			BuildDrops(activeGamemodeInfo)
		end)
	end

	module.Button:Create(main2, "Small"):BindFunction("Click", function()
		if v9 then
			return
		end

		local activeGamemodeName = GetActiveGamemodeName() -- equivalent call inferred; original call site unknown

		if not activeGamemodeName then
			return
		end

		local activeGamemodeInfo = GetActiveGamemodeInfo() -- equivalent call inferred; original call site unknown

		-- equivalent call inferred; original call site unknown
		if HasMapAccess(activeGamemodeInfo) then
			module.Signal:Fire("General", "Parties", "Create", activeGamemodeName)
		else
			NotifyMapLocked()
		end
	end)
	module.Button:Create(main5, "Small"):BindFunction("Click", function()
		if v9 then
			JoinScheduled()
		else
			module.Signal:Fire("General", "Parties", "Start")
		end
	end)
	module.Button:Create(main6, "Small"):BindFunction("Click", function()
		if v9 then
			return
		end

		module.Signal:Fire("General", "Parties", "Leave")
	end)
	module.Button:Create(main3, "Small"):BindFunction("Click", ToggleFriendsOnly)
	module.Button:Create(main4, "Small"):BindFunction("Click", ToggleFriendsOnly)
	module.Frame:OnFrameOpened(gamemodes, function()
		Refresh()

		if v9 then
			StartPreview()
			return
		end

		StartBrowseLoop() -- equivalent call inferred; original call site unknown
	end)
	module.Frame:OnFrameClosed(gamemodes, function()
		count += 1
		flag = false
		StopPreview() -- equivalent call inferred; original call site unknown
		ClearMemberRows() -- equivalent call inferred; original call site unknown
		ClearPartyRows() -- equivalent call inferred; original call site unknown
		ClearDropRows() -- equivalent call inferred; original call site unknown
		ClearInfoRows() -- equivalent call inferred; original call site unknown
	end)
	script.Destroying:Connect(function()
		count += 1
		flag = false
		StopPreview() -- equivalent call inferred; original call site unknown
		ClearMemberRows() -- equivalent call inferred; original call site unknown
		ClearPartyRows() -- equivalent call inferred; original call site unknown
		ClearDropRows() -- equivalent call inferred; original call site unknown
		ClearInfoRows() -- equivalent call inferred; original call site unknown
		ClearDifficultyRows() -- equivalent call inferred; original call site unknown

		if connection3 then
			connection3:Disconnect()
			connection3 = nil
		end

		if connection then
			connection:Disconnect()
			connection = nil
		end

		if connection2 then
			connection2:Disconnect()
			connection2 = nil
		end
	end)
end

return Controller