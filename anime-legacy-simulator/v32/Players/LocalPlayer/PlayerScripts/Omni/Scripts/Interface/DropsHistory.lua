local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local dropsHistory = module.Interface:WaitForChild("Frames"):WaitForChild("DropsHistory")
local scroll = dropsHistory:WaitForChild("Options"):WaitForChild("Scroll")
local scroll2 = dropsHistory:WaitForChild("List"):WaitForChild("Scroll")
local title = dropsHistory:WaitForChild("_Header"):WaitForChild("Title")
local main = dropsHistory:WaitForChild("Reset"):WaitForChild("Main")
local dropHistory = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("DropHistory")
local drop = dropHistory:WaitForChild("Drop")
local option = dropHistory:WaitForChild("Option")
local allCategory = module.Shared.DropsHistory.AllCategory
local v = allCategory
local v2 = false
local v3 = {}
local v4 = {}
local thread = nil
local DropsHistory = {}

local function AttachScale(scope, duration: number)
	scope.Scale = scope:Value(0)
	scope.ScaleSpring = scope:Spring(scope.Scale, 15, 1)
	local uIScale = Instance.new("UIScale")
	uIScale.Scale = 0
	uIScale.Parent = scope.Instance
	scope:Hydrate(uIScale)({
		Scale = scope.ScaleSpring
	})
	task.delay(duration, function()
		if not next(scope) then
			return
		end

		scope.Scale:set(1)
	end)
end

local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = option:Clone()
		self.Instance.Name = self.Source
		self.Instance.Main.Title.Text = self.Source
		module.Button:Create(self.Instance.Main, "Default"):BindFunction("Click", function()
			DropsHistory.SetCategory(self.Source)
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		task.delay(duration, function()
			if not next(self) then
				return
			end

			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end)
	end,
	SetSelected = function(self, enabled: boolean)
		self.Instance.Main.UIGradient.Enabled = enabled
		self.Instance.Main.Title.UIGradient.Enabled = enabled
	end
})
local scope2 = fusion.scoped(fusion, {
	Build = function(self, p: number)
		local info = self.Data.Info
		self.Instance = drop:Clone()
		self.Instance.Name = self.Data.Key
		local main2 = self.Instance.Main
		local name

		if self.Data.Type == "Fighter" then
			name = module.Shared.Fighters.GetDisplayName(self.Data.Name)
		else
			name = self.Data.Name
		end

		local title2 = main2.Title
		local text

		if self.Data.Shiny then
			text = `Shiny {name}`
		else
			text = name
		end

		title2.Text = text
		main2.Icon.Image = info.Icon or ""
		main2.UIGradient:SetAttribute("Rarity", info.Rarity or "Common")
		self.Hover = module.Libs.NeoHover.GetByPseudoIdentifier(self.Data.Type)

		if not self.Hover then
			self.Tooltip = true
			self.Hover = module.Libs.NeoHover.GetByIdentifier("Tooltip")
		end

		local v6 = self.Tooltip and {
			Text = name
		} or {
			IsFake = true,
			Name = self.Data.Name,
			Data = table.clone(info)
		}

		if v6.Data then
			v6.Data.Name = self.Data.Name
			v6.Data.Shiny = self.Data.Shiny
		end

		local v7 = module.Button:Create(main2, "Small")
		v7:BindFunction("Click", function()
			if not self.Hover then
				return
			end

			self.Hover:Click(self.Instance, v6)
		end)
		v7:BindOnEnter("Hover", function()
			if not self.Hover then
				return
			end

			self.Hover:Open(self.Instance, v6)
		end)
		v7:BindOnLeave("Hover", function()
			if not self.Hover then
				return
			end

			self.Hover:Close(self.Instance)
		end)
		AttachScale(self, p)
		self.Instance.Parent = scroll2
		self.Instance.Visible = true
	end,
	Update = function(self, p2: number, layoutOrder: number)
		local formatted = module.Utils.Number:Format(p2)

		if typeof(formatted) == "number" then
			formatted = string.format("%.2f", formatted):gsub("0+$", ""):gsub("%.$", "")
		end

		self.Instance.Main.Amount.Text = `{formatted}x`
		self.Instance.LayoutOrder = layoutOrder
	end
})

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyOption(k: string)
	local v5 = v3[k]

	if not v5 then
		return
	end

	v5.Instance:Destroy()
	v5:doCleanup()
	v3[k] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyDrop(k: string)
	local v5 = v4[k]

	if not v5 then
		return
	end

	if v5.Hover then
		v5.Hover:Close(v5.Instance)
	end

	v5.Instance:Destroy()
	v5:doCleanup()
	v4[k] = nil
end

local function ClearTemplates()
	for k in v3 do
		DestroyOption(k) -- equivalent call inferred; original call site unknown
	end

	for k in v4 do
		DestroyDrop(k) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetSources()
	local dropsHistory2 = module.Data.DropsHistory
	return dropsHistory2 and dropsHistory2.Sources or {}
end

local function GetCategoryAmounts(p: string)
	if p ~= allCategory then
		return (GetSources())[p] or {}
	end

	local dropsHistory2 = module.Data.DropsHistory
	local result = {}

	for _, v5 in dropsHistory2 and dropsHistory2.Sources or {} do
		for k, v6 in v5 do
			result[k] = (result[k] or 0) + v6
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateDuration()
	local dropsHistory2 = module.Data.DropsHistory
	local startedAt = dropsHistory2 and dropsHistory2.StartedAt or 0
	local v5 = not (startedAt > 0) and 0 or workspace:GetServerTimeNow() - startedAt
	title.Text = `Record Duration: {module.Shared.DropsHistory.FormatDuration(v5)}`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopDurationLoop()
	if not thread then
		return
	end

	task.cancel(thread)
	thread = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartDurationLoop()
	StopDurationLoop() -- equivalent call inferred; original call site unknown
	thread = task.spawn(function()
		while true do
			UpdateDuration() -- equivalent call inferred; original call site unknown
			task.wait(60)
		end
	end)
end

function DropsHistory.RefreshOptions()
	local v5 = { allCategory }
	local dropsHistory2 = module.Data.DropsHistory

	for k, v6 in dropsHistory2 and dropsHistory2.Sources or {} do
		if next(v6) then
			table.insert(v5, k)
		end
	end

	table.sort(v5, function(a, b)
		local sourceOrder = module.Shared.DropsHistory.GetSourceOrder(a)
		local sourceOrder2 = module.Shared.DropsHistory.GetSourceOrder(b)

		if sourceOrder == sourceOrder2 then
			return a < b
		end

		return sourceOrder < sourceOrder2
	end)
	local v6 = {}
	local count = 0

	for k, source in v5 do
		v6[source] = true
		local v8 = v3[source]

		if not v8 then
			v8 = scope:innerScope()
			v8.Source = source
			v8:Build(count * 0.05)
			v3[source] = v8
			count += 1
		end

		v8.Instance.LayoutOrder = k
		v8:SetSelected(source == v)
	end

	for k in v3 do
		if v6[k] then
			continue
		end

		DestroyOption(k) -- equivalent call inferred; original call site unknown
	end

	if not v6[v] then
		DropsHistory.SetCategory(allCategory)
	end
end

function DropsHistory.RefreshDrops()
	local v5 = {}

	for k, amount in GetCategoryAmounts(v) do
		local key, name, shiny = module.Shared.DropsHistory.ParseKey(k)

		if not (key and name) then
			continue
		end

		local info = module.Utils.Info:Get(key, name)

		if info then
			table.insert(v5, {
				Key = k,
				Type = key,
				Name = name,
				Shiny = shiny,
				Info = info,
				Amount = amount,
				RarityOrder = module.Utils.Order:Rarity(info.Rarity or "Common")
			})
		end
	end

	table.sort(v5, function(a, b)
		if a.RarityOrder ~= b.RarityOrder then
			return a.RarityOrder > b.RarityOrder
		end

		if a.Amount == b.Amount then
			return a.Key < b.Key
		end

		return a.Amount > b.Amount
	end)
	local v6 = {}
	local count = 0

	for k, v7 in v5 do
		v6[v7.Key] = true
		local v8 = v4[v7.Key]

		if not v8 then
			v8 = scope2:innerScope()
			v8.Data = v7
			v8:Build(count * 0.05)
			v4[v7.Key] = v8
			count += 1
		end

		v8:Update(v7.Amount, k)
	end

	for k in v4 do
		if v6[k] then
			continue
		end

		DestroyDrop(k) -- equivalent call inferred; original call site unknown
	end
end

function DropsHistory.SetCategory(p: string)
	if v == p then
		return
	end

	v = p

	for k, v5 in v3 do
		v5:SetSelected(k == p)
	end

	for k in v4 do
		DestroyDrop(k) -- equivalent call inferred; original call site unknown
	end

	DropsHistory.RefreshDrops()
end

function DropsHistory.Refresh()
	if not v2 then
		return
	end

	DropsHistory.RefreshOptions()
	DropsHistory.RefreshDrops()
	UpdateDuration() -- equivalent call inferred; original call site unknown
end

function DropsHistory.Start()
	v2 = true
	v = allCategory
	DropsHistory.Refresh()
	StartDurationLoop() -- equivalent call inferred; original call site unknown
end

function DropsHistory.Stop()
	v2 = false
	StopDurationLoop() -- equivalent call inferred; original call site unknown
	ClearTemplates()
end

function DropsHistory.Init()
	module.Button:Create(main, "Small"):BindFunction("Click", function()
		module.Signal:FireSelf("Interface", "Confirmation", "Start", {
			Title = "Reset History",
			Description = "Reset your drops history? This cannot be undone.",
			ConfirmText = "Reset",
			CancelText = "Cancel",
			Callback = function(p)
				if not p then
					return
				end

				module.Signal:Fire("General", "DropsHistory", "Reset")
			end
		})
	end)
	module.Frame:OnFrameOpened(dropsHistory, DropsHistory.Start)
	module.Frame:OnFrameClosed(dropsHistory, DropsHistory.Stop)
	module:OnDataChangedDeferred({ "DropsHistory" }, DropsHistory.Refresh, function()
		return v2
	end)
end

return DropsHistory