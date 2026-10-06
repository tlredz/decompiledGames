local module = require("@game/ReplicatedStorage/Omni")
local notifications = module.Shared.Notifications
local Card = require(script.Parent.Card)
local gamemode = module.Assets.Interface.Templates.Notifications.Gamemode
local v = {}
local connection = nil
local Gamemode = {}

local function SetProgress(p, p2: number)
	local uIGradient = p.Instance.Main.ProgressBar.Slider.UIGradient

	if p2 >= 1 then
		uIGradient.Transparency = NumberSequence.new(0)
		return
	end

	if p2 <= 0 then
		uIGradient.Transparency = NumberSequence.new(1)
		return
	end

	local v2 = 1 - p2
	uIGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(v2, 1),
		NumberSequenceKeypoint.new(math.min(1, v2 + 0.005), 0),
		NumberSequenceKeypoint.new(1, 0)
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshProgress(p)
	SetProgress(p, (p.EntryClosesAt - workspace:GetServerTimeNow()) / p.EnterTime)
end

local function Join(state)
	if state.Joining or state.Destroyed or state.Closing then
		return
	end

	state.Joining = true
	local success, result = pcall(function()
		return module.Signal:Invoke("General", "Gamemodes", "Join", state.GamemodeName)
	end)
	state.Joining = false

	if success and result == true then
		Card.Close(state)
	end
end

local function Build(state, p, p2: number)
	state.Instance = gamemode:Clone()
	state.Instance.Name = "GamemodeNotification_" .. state.GamemodeName
	state.Instance.Position = UDim2.fromScale(0, 0)
	local main = state.Instance.Main
	main.Title.Text = state.GamemodeName
	main.Icon.Image = p.Icon or ""
	RefreshProgress(state) -- equivalent call inferred; original call site unknown
	local v2 = module.Button:Create(main.Buttons.Accept.Main, "Small")
	local v3 = module.Button:Create(main.Buttons.Decline.Main, "Small")
	v2:BindFunction("Click", function()
		Join(state)
	end)
	v3:BindFunction("Click", function()
		Card.Close(state)
	end)

	function state.OnDestroyed()
		if v[state.GamemodeName] == state then
			v[state.GamemodeName] = nil
		end
	end

	Card.Attach(state, "Gamemode", p2)
	table.insert(state.Scope, module.Services.RunService.Heartbeat:Connect(function()
		RefreshProgress(state) -- equivalent call inferred; original call site unknown
	end))
end

function Gamemode:Create()
	if module.Data.Settings["Gamemode Notifications"] == false or (typeof(self) ~= "table" or typeof(self.GamemodeName) ~= "string") then
		return
	end

	if not notifications.IsFinite(self.EntryClosesAt) then
		return
	end

	local v2 = module.Shared.Gamemodes.List[self.GamemodeName]

	if not v2 or not notifications.IsFinite(v2.EnterTime) or v2.EnterTime <= 0 then
		return
	end

	local v3 = self.EntryClosesAt - workspace:GetServerTimeNow()

	if v3 <= 0 then
		return
	end

	local v4 = v[self.GamemodeName]

	if v4 then
		Card.Destroy(v4)
	end

	local v5 = {
		GamemodeName = self.GamemodeName,
		EntryClosesAt = self.EntryClosesAt,
		EnterTime = v2.EnterTime
	}
	v[v5.GamemodeName] = v5
	local success, result = pcall(Build, v5, v2, v3)

	if not success then
		Card.Destroy(v5)

		if v[v5.GamemodeName] == v5 then
			v[v5.GamemodeName] = nil
		end

		warn("[NOTIFICATIONS]: Could not build gamemode notification: " .. tostring(result))
	end
end

function Gamemode.Clear()
	for _, v2 in table.clone(v) do
		Card.Destroy(v2)
	end

	table.clear(v)
end

function Gamemode.Destroy()
	if connection then
		connection:Disconnect()
		connection = nil
	end

	Gamemode.Clear()
end

function Gamemode.Init()
	if connection then
		return
	end

	connection = module:OnDataChanged({ "Settings", "Gamemode Notifications" }, function()
		if module.Data.Settings["Gamemode Notifications"] == false then
			Gamemode.Clear()
		end
	end)
end

return Gamemode