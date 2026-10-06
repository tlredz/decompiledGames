local module = require("@game/ReplicatedStorage/Omni")
local notifications = module.Shared.Notifications
local Card = require(script.Parent.Card)
local drop = module.Assets.Interface.Templates.Notifications.Drop
local v = {}
local v2 = {}
local v3 = {}
local count = 0
local thread = nil
local connection = nil
local framesChangedSignalConnection = nil
local v4 = false
local v5 = false
local Drop = {}

local function GetInfo(data)
	if data.Type == "Gacha" then
		local v6 = module.Shared.Gacha.List[data.GachaName]

		if v6 and v6.Source.Type == "Normal" then
			return v6.Source.Normal[data.Name]
		end
	else
		if data.Type == "Trait" then
			return module.Shared.Traits.List[data.Name]
		end

		if data.Type ~= "Breathing" then
			return module.Utils.Info:Get(data.Type, data.Name)
		end

		local v6 = module.Shared.Breathings.List[data.Name]

		if v6 and v6.Rarities[data.Rarity] then
			return v6
		end
	end
end

local function SetAmount(p)
	local formatted = module.Utils.Number:Format(p.Params.Amount)

	if typeof(formatted) == "number" then
		formatted = string.format("%.2f", formatted):gsub("0+$", ""):gsub("%.$", "")
	end

	p.Instance.Main.Amount.Text = formatted .. "x"
end

local function RenderViewport(data)
	local params = data.Params
	local character = module.Utils.Characters.Get({
		Name = params.Name,
		Shiny = params.Shiny,
		RemoveHumanoidStates = true
	})

	if not character then
		return
	end

	if data.Destroyed or data.Hidden then
		character:Destroy()
	else
		module.Utils.Camera.ViewportCharacter({
			Viewport = data.Instance.Main.Viewport,
			Animation = module.Utils.Characters.GetCharacterAnimation(params.Name, "Idle"),
			Character = character
		})
	end
end

local function Build(state, p: number)
	local params = state.Params
	local info = GetInfo(params)

	if not info then
		return false
	end

	state.Instance = drop:Clone()
	state.Instance.Name = "DropNotification_" .. tostring(state.Sequence)
	state.Instance.Position = UDim2.fromScale(0, 0)
	local main = state.Instance.Main
	main.UIGradient:SetAttribute("Rarity", params.Rarity)
	main.Title.Visible = true
	local name

	if params.Type == "Fighter" then
		name = module.Shared.Fighters.GetDisplayName(params.Name)
	else
		name = params.Name
	end

	main.Title.Text = notifications.Escape(name)
	main.Sold.Visible = params.Status == "Sold"
	main.Deconstructed.Visible = params.Status == "Deconstructed"
	local visible

	if typeof(info.Icon) == "string" then
		visible = info.Icon ~= ""
	else
		visible = false
	end

	main.Icon.Visible = visible
	main.Viewport.Visible = not visible

	if visible then
		main.Icon.Image = info.Icon
	elseif params.Type == "Fighter" then
		RenderViewport(state)

		function state.OnShown()
			RenderViewport(state)
		end
	end

	local v8

	if not (params.Type == "Gacha" or params.Type == "Trait" or params.Type == "Breathing") then
		v8 = module.Libs.NeoHover.GetByPseudoIdentifier(params.Type) or nil
	end

	local v9 = v8 == nil
	local v10 = v8 or module.Libs.NeoHover.GetByIdentifier("Tooltip")
	local v11 = v9 and {
		Text = name
	} or {
		IsFake = true,
		Name = params.Name,
		Data = table.clone(info)
	}

	if v11.Data then
		v11.Data.Name = params.Name
		v11.Data.Shiny = params.Shiny
	end

	local v12 = module.Button:Create(main, "Small")
	v12:BindFunction("Click", function()
		if v10 then
			v10:Click(state.Instance, v11)
		end
	end)
	v12:BindOnEnter("Hover", function()
		if v10 then
			v10:Open(state.Instance, v11)
		end
	end)
	v12:BindOnLeave("Hover", function()
		if v10 then
			v10:Close(state.Instance)
		end
	end)

	function state.OnHidden()
		if v10 then
			v10:Close(state.Instance)
		end

		module.Utils.Camera.ClearViewport(main.Viewport)
	end

	state.OnCleanup = state.OnHidden
	SetAmount(state)
	Card.Attach(state, "Drop", params.Time, p)
	return true
end

local function CountActive()
	local count2 = 0

	for _ in v do
		count2 += 1
	end

	return count2
end

local function MakeRoom()
	local v6 = nil

	for _, v7 in v do
		if not v6 or v7.Sequence < v6.Sequence then
			v6 = v7
		end
	end

	if v6 then
		Card.Close(v6)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetRemainingTime(data)
	if data.StartsAt or not data.ExpiresAt then
		return data.Params.Time
	end

	return data.ExpiresAt - os.clock()
end

local function Suspend()
	v5 = true

	if thread then
		task.cancel(thread)
		thread = nil
	end

	for k, v6 in v do
		if v6.Scope and not (v6.Closing or v6.Destroyed) then
			local params = v6.Params
			local remainingTime = GetRemainingTime(v6) -- equivalent call inferred; original call site unknown
			params.Time = math.max(remainingTime, notifications.ResumedDropMinimumTime)
			Card.Suspend(v6)
		else
			v[k] = nil
			v6.OnDestroyed = nil

			if not (v6.Scope or v6.Destroyed) then
				v3[k] = v6
				table.insert(v2, 1, v6)
			end
		end
	end
end

local function Resume()
	v5 = false
	local v6 = {}

	for _, v7 in v do
		if v7.Suspended then
			table.insert(v6, v7)
		end
	end

	table.sort(v6, function(a, b)
		return a.Sequence < b.Sequence
	end)
	local total = 0

	for _, v7 in v6 do
		Card.Resume(v7, v7.Params.Time, total)
		total += 0.05
	end

	Drop.Pump(total)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshPause()
	local isBlockingFrameOpened = module.Frame:IsBlockingFrameOpened()

	if isBlockingFrameOpened == v5 then
		return
	end

	if isBlockingFrameOpened then
		Suspend()
	else
		Resume()
	end
end

function Drop.Pump(value: number?)
	if thread or v4 or v5 then
		return
	end

	thread = task.defer(function()
		local v6 = value or 0

		while #v2 > 0 do
			local count2 = 0

			for _ in v do
				count2 += 1
			end

			if not (count2 < notifications.MaximumDrops) then
				break
			end

			local v7 = table.remove(v2, 1)
			v3[v7.ID] = nil
			v[v7.ID] = v7

			function v7.OnDestroyed()
				if v[v7.ID] == v7 then
					v[v7.ID] = nil
				end

				Drop.Pump()
			end

			local success, result = pcall(Build, v7, v6)

			if success and result then
				v6 += 0.05
			else
				Card.Destroy(v7)

				if not success then
					warn("[NOTIFICATIONS]: Could not build drop: " .. tostring(result))
				end
			end
		end

		thread = nil

		if #v2 > 0 then
			MakeRoom()
		end
	end)
end

function Drop:Create()
	if module.Data.Settings["Drop Notifications"] == false then
		return
	end

	local drop2 = notifications.NormalizeDrop(self)

	if not drop2 then
		return
	end

	local info = GetInfo(drop2)

	if not info then
		return
	end

	if drop2.Type == "Gacha" or drop2.Type == "Trait" then
		drop2.Rarity = info.Rarity
	else
		drop2.Rarity = drop2.Rarity or info.Rarity or "Common"
	end

	local ID = notifications.DropIdentifier(drop2)
	local v8 = v[ID] or v3[ID]

	if v8 then
		local amount = v8.Params.Amount + drop2.Amount

		if not notifications.IsFinite(amount) then
			return
		end

		v8.Params.Amount = amount
		v8.Params.Time = drop2.Time

		if v8.Scope then
			SetAmount(v8)
			Card.Refresh(v8, drop2.Time)
		end
	else
		if #v2 >= notifications.MaximumPendingDrops then
			local v9 = table.remove(v2, 1)
			v3[v9.ID] = nil
		end

		count += 1
		local v9 = {
			ID = ID,
			Sequence = count,
			Params = drop2
		}
		v3[ID] = v9
		table.insert(v2, v9)
		Drop.Pump()
	end
end

function Drop.Clear()
	v4 = true

	if thread then
		task.cancel(thread)
		thread = nil
	end

	table.clear(v2)
	table.clear(v3)

	for _, v6 in v do
		Card.Destroy(v6)
	end

	table.clear(v)
	count = 0
	v4 = false
end

function Drop.Destroy()
	if connection then
		connection:Disconnect()
		connection = nil
	end

	if framesChangedSignalConnection then
		framesChangedSignalConnection:Disconnect()
		framesChangedSignalConnection = nil
	end

	v5 = false
	Drop.Clear()
end

function Drop.Init()
	if connection then
		return
	end

	connection = module:OnDataChanged({ "Settings", "Drop Notifications" }, function()
		if module.Data.Settings["Drop Notifications"] == false then
			Drop.Clear()
		end
	end)
	framesChangedSignalConnection = module.Frame.FramesChangedSignal:Connect(RefreshPause)
	RefreshPause() -- equivalent call inferred; original call site unknown
end

return Drop