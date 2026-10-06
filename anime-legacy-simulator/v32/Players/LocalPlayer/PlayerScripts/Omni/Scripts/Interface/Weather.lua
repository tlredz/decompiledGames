local module = require("@game/ReplicatedStorage/Omni")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local color = Color3.new(1, 1, 1)
local color2 = Color3.fromRGB(37, 41, 44)
local color3 = Color3.fromRGB(44, 51, 56)
local color4 = Color3.fromRGB(74, 80, 83)
local v = {
	["Player Damage"] = Color3.fromRGB(255, 75, 75),
	Damage = Color3.fromRGB(255, 75, 75),
	["Fighter Damage"] = Color3.fromRGB(255, 145, 55),
	Luck = Color3.fromRGB(85, 255, 85),
	["Gacha Luck"] = Color3.fromRGB(180, 100, 255),
	Drops = Color3.fromRGB(60, 225, 255),
	Yen = Color3.fromRGB(255, 205, 55),
	["Player Exp"] = Color3.fromRGB(90, 155, 255),
	["Shiny Chance"] = Color3.fromRGB(255, 255, 120)
}
local fusion = module.Libs.Fusion
local weather = module.Shared.Weather
local WeatherColors = require(ReplicatedStorage.Omni.Shared.WeatherColors)
local Presentation = require(ReplicatedStorage.Omni.Shared.Mutations.Presentation)
local weather2 = module.Interface:WaitForChild("Frames"):WaitForChild("Weather")
local main = weather2:WaitForChild("Main")
local title = main:WaitForChild("Title")
local accentStroke = main:WaitForChild("Background"):WaitForChild("AccentStroke")
local main2 = main:WaitForChild("Close"):WaitForChild("Main")
local list = main:WaitForChild("List")
local time = list:WaitForChild("Time")
local fill = time:WaitForChild("Bar"):WaitForChild("Fill")
local uIGradient = fill:WaitForChild("UIGradient")
local uIGradient2 = fill:WaitForChild("Slider"):WaitForChild("UIGradient")
local v2 = { list:WaitForChild("BuffsHeader"), list:WaitForChild("MutationsHeader") }
local empty = list:WaitForChild("Empty")
local v3 = { list:WaitForChild("Divider"), list:WaitForChild("Spacer5"), list:WaitForChild("Source") }
local tooltip = main:WaitForChild("Tooltip")
local uIScale = tooltip:WaitForChild("UIScale")
local content = tooltip:WaitForChild("Content")
local header = content:WaitForChild("Header")
local weather3 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Weather")
local buff = weather3:WaitForChild("Buff")
local mutation = weather3:WaitForChild("Mutation")
local scope = fusion.scoped(fusion)
local value = scope:Value(0)
local spring = scope:Spring(value, 10, 1)
local value2 = scope:Value(0)
local spring2 = scope:Spring(value2, 25, 1)
local value3 = scope:Value(UDim2.fromScale(1.035, 0.5))
local spring3 = scope:Spring(value3, 25, 1)
local v4 = {}
local v5 = {}
local v6 = false
local name = nil
local startedAt = nil
local v7 = color
local textColor = color
local v9 = nil
local v10 = nil
local count = 0
local loopConnection = nil
local Weather = {}

local function AttachScale(scope2, duration: number)
	scope2.Scale = scope2:Value(0)
	scope2.ScaleSpring = scope2:Spring(scope2.Scale, 15, 1)
	local uIScale2 = Instance.new("UIScale")
	uIScale2.Scale = 0
	uIScale2.Parent = scope2.Instance
	scope2:Hydrate(uIScale2)({
		Scale = scope2.ScaleSpring
	})
	task.delay(duration, function()
		if not next(scope2) then
			return
		end

		scope2.Scale:set(1)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetSelected(state, flag: boolean)
	local main3 = state.Instance.Main
	local backgroundColor

	if flag then
		backgroundColor = color3
	else
		backgroundColor = color2
	end

	main3.BackgroundColor3 = backgroundColor
	local uIStroke = main3.UIStroke
	local color5

	if flag then
		color5 = v7
	else
		color5 = color4
	end

	uIStroke.Color = color5
end

local function GetRowPosition(p)
	local Y = main.AbsoluteSize.Y

	if Y <= 0 then
		return UDim2.fromScale(1.035, 0.5)
	end

	local main3 = p.Instance.Main
	local v11 = main3.AbsolutePosition.Y + main3.AbsoluteSize.Y / 2 - main.AbsolutePosition.Y
	return UDim2.fromScale(1.035, v11 / Y)
end

local function ShowTooltip(p: string)
	local v11 = v5[p]

	if not v11 then
		return
	end

	local v12 = Presentation.List[p]
	local hex = textColor:ToHex()
	header.Icon.Image = not v12 and "" or v12.Icon
	header.Title.Text = `{p} Mutation`
	content.Chance.Text = `Fighters obtained from Stars during this weather have a <font color="#{hex}"><b>{v11.Chance}%</b></font> chance to roll the <font color="#{hex}"><b>{p}</b></font> mutation.`
	content.Effect.Text = not v12 and "" or `<font color="#{hex}"><b>Effect:</b></font> {v12.Description}`
	count += 1
	local rowPosition = GetRowPosition(v11)

	if tooltip.Visible then
		value3:set(rowPosition)
	else
		value3:set(rowPosition)
		spring3:setPosition(rowPosition)
		tooltip.Visible = true
	end

	value2:set(1)
end

local function HideTooltip(flag: boolean?)
	count += 1
	value2:set(0)

	if flag then
		spring2:setPosition(0)
		tooltip.Visible = false
	else
		local v11 = count
		task.delay(0.25, function()
			if v11 ~= count then
				return
			end

			tooltip.Visible = false
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Unpin()
	if not v9 then
		return
	end

	local v11 = v5[v9]
	v9 = nil

	if v11 then
		local main3 = v11.Instance.Main
		main3.BackgroundColor3 = color2
		main3.UIStroke.Color = color4
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function EnterMutation(name2: string)
	v10 = name2

	if v9 then
		return
	end

	ShowTooltip(name2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function LeaveMutation(name2: string)
	if v10 ~= name2 then
		return
	end

	v10 = nil

	if v9 then
		return
	end

	HideTooltip()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClickMutation(name2: string)
	if v9 == name2 then
		Unpin() -- equivalent call inferred; original call site unknown
		HideTooltip()
	else
		Unpin() -- equivalent call inferred; original call site unknown
		local v11 = v5[name2]

		if not v11 then
			return
		end

		v9 = name2
		local main3 = v11.Instance.Main
		main3.BackgroundColor3 = color3
		main3.UIStroke.Color = v7
		ShowTooltip(name2)
	end
end

local scope2 = fusion.scoped(fusion, {
	Build = function(self, p: number)
		local perk = module.Shared.Perks[self.Name]
		self.Instance = buff:Clone()
		self.Instance.Name = `Buff_{self.Name}`
		self.Instance.Main.Icon.Image = not perk and "" or perk.Icon
		AttachScale(self, p)
		self.Instance.Parent = list
		self.Instance.Visible = true
	end,
	Update = function(self, p2, layoutOrder: number)
		local v11

		if p2.Type == "Multi" then
			v11 = p2.Amount - 1
		else
			v11 = p2.Amount
		end

		local v12 = v11 * 100
		local v13 = v[self.Name] or color
		self.Instance.Main.Title.Text = `+{module.Utils.Number:FormatDecimal(v12)}% <font color="#{v13:ToHex()}">{self.Name}</font>`
		self.Instance.LayoutOrder = layoutOrder
	end
})
local v11 = {
	Build = function(self, p: number)
		local v12 = Presentation.List[self.Name]
		self.Instance = mutation:Clone()
		self.Instance.Name = `Mutation_{self.Name}`
		local main3 = self.Instance.Main
		main3.Icon.Image = not v12 and "" or v12.Icon
		main3.Title.Text = self.Name
		local v13 = module.Button:Create(main3, "Small")
		v13:BindFunction("Click", function()
			ClickMutation(self.Name) -- equivalent call inferred; original call site unknown
		end)
		v13:BindOnEnter("Tooltip", function()
			EnterMutation(self.Name) -- equivalent call inferred; original call site unknown
		end)
		v13:BindOnLeave("Tooltip", function()
			LeaveMutation(self.Name) -- equivalent call inferred; original call site unknown
		end)
		AttachScale(self, p)
		self.Instance.Parent = list
		self.Instance.Visible = true
	end,
	Update = function(self, p: number, layoutOrder: number)
		local main3 = self.Instance.Main
		self.Chance = module.Utils.Number:FormatDecimal(p)
		main3.Chance.Text = `{self.Chance}%`
		main3.Chance.TextColor3 = textColor
		main3.Info.BackgroundColor3 = v7
		self.Instance.LayoutOrder = layoutOrder
		SetSelected(self, v9 == self.Name) -- equivalent call inferred; original call site unknown
	end
}
local scope3 = fusion.scoped(fusion, v11)

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyBuff(k: string)
	local v12 = v4[k]

	if not v12 then
		return
	end

	v12.Instance:Destroy()
	v12:doCleanup()
	v4[k] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyMutation(k: string)
	local v12 = v5[k]

	if not v12 then
		return
	end

	if v9 == k then
		Unpin() -- equivalent call inferred; original call site unknown
		count += 1
		value2:set(0)
		spring2:setPosition(0)
		tooltip.Visible = false
	end

	if v10 == k then
		v10 = nil
	end

	v12.Instance:Destroy()
	v12:doCleanup()
	v5[k] = nil
end

local function ClearTemplates()
	for k in v4 do
		DestroyBuff(k) -- equivalent call inferred; original call site unknown
	end

	for k in v5 do
		DestroyMutation(k) -- equivalent call inferred; original call site unknown
	end
end

local function GetSortedNames(items)
	local result = {}

	for k in items do
		table.insert(result, k)
	end

	table.sort(result)
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatTime(p: number)
	local v12 = math.floor(p / 3600)
	local v13 = math.floor(p % 3600 / 60)
	local v14 = p % 60

	if v12 > 0 then
		return string.format("%02d:%02d:%02d", v12, v13, v14)
	end

	return string.format("%02d:%02d", v13, v14)
end

local function SetBarProgress(value4: number)
	local v12 = math.clamp(value4, 0, 1)

	if v12 >= 1 then
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0)
		})
		return
	end

	if v12 <= 0 then
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 1)
		})
		return
	end

	local numberSequenceKeypoints = {}
	table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(0, 0))
	table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v12, 0))
	table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(math.min(1, v12 + 0.1), 1))
	table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(1, 1))
	uIGradient.Transparency = NumberSequence.new(numberSequenceKeypoints)
end

local function UpdateTime()
	local state = weather.GetState()

	if not state then
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()
	local v12 = math.max(0, (math.ceil(state.EndsAt - serverTimeNow)))
	local v13 = math.max(1, state.EndsAt - state.StartedAt)
	local value4 = time.Value
	local text = FormatTime(v12) -- equivalent call inferred; original call site unknown
	value4.Text = text
	value:set((math.clamp((state.EndsAt - serverTimeNow) / v13, 0, 1)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ApplyAccent(name2: string)
	title.Text = name2
	accentStroke.Color = v7
	uIGradient2.Color = ColorSequence.new(v7:Lerp(color, 0.45), v7)

	for _, v12 in v2 do
		v12.Title.TextColor3 = textColor
	end
end

local function RefreshBuffs(perks)
	local v12 = {}
	local v13 = {}
	local count2 = 0

	for k in perks do
		table.insert(v12, k)
	end

	table.sort(v12)

	for k, name2 in v12 do
		v13[name2] = true
		local v15 = v4[name2]

		if not v15 then
			v15 = scope2:innerScope()
			v15.Name = name2
			v15:Build(count2 * 0.05)
			v4[name2] = v15
			count2 += 1
		end

		v15:Update(perks[name2], 60 + k)
	end

	for k in v4 do
		if v13[k] then
			continue
		end

		DestroyBuff(k) -- equivalent call inferred; original call site unknown
	end
end

local function RefreshMutations(mutations)
	local v12 = {}

	for k in mutations do
		table.insert(v12, k)
	end

	table.sort(v12)
	local v13 = {}
	local count2 = 0

	for k, name2 in v12 do
		v13[name2] = true
		local v15 = v5[name2]

		if not v15 then
			v15 = scope3:innerScope()
			v15.Name = name2
			v15:Build(count2 * 0.05)
			v5[name2] = v15
			count2 += 1
		end

		v15:Update(mutations[name2], k + 100)
	end

	for k in v5 do
		if v13[k] then
			continue
		end

		DestroyMutation(k) -- equivalent call inferred; original call site unknown
	end

	local visible = #v12 > 0
	empty.Visible = not visible

	for _, v15 in v3 do
		v15.Visible = visible
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopRefreshLoop()
	if not loopConnection then
		return
	end

	loopConnection:Disconnect()
	loopConnection = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartRefreshLoop()
	StopRefreshLoop() -- equivalent call inferred; original call site unknown
	loopConnection = module.Utils.Loop:Connect({
		Time = 1,
		Callback = UpdateTime
	})
end

function Weather.Refresh()
	local state = weather.GetState()
	local v12 = state and weather.List[state.Name]

	if not v12 then
		module.Frame:Close(weather2)
		return
	end

	local v13 = name ~= state.Name or startedAt ~= state.StartedAt
	name = state.Name
	startedAt = state.StartedAt
	v7 = WeatherColors.GetAccent(state.Name)
	textColor = WeatherColors.GetTextColor(state.Name)

	if v13 then
		Unpin() -- equivalent call inferred; original call site unknown
		count += 1
		value2:set(0)
		spring2:setPosition(0)
		tooltip.Visible = false
		spring:setPosition(0)
	end

	ApplyAccent(state.Name) -- equivalent call inferred; original call site unknown
	RefreshBuffs(v12.Perks)
	RefreshMutations(v12.Mutations)
	UpdateTime()
end

function Weather.Start()
	v6 = true
	name = nil
	startedAt = nil
	Weather.Refresh()

	if not v6 then
		return
	end

	StartRefreshLoop() -- equivalent call inferred; original call site unknown
end

function Weather.Stop()
	v6 = false
	StopRefreshLoop() -- equivalent call inferred; original call site unknown
	Unpin() -- equivalent call inferred; original call site unknown
	count += 1
	value2:set(0)
	spring2:setPosition(0)
	tooltip.Visible = false
	ClearTemplates()
	v10 = nil
	name = nil
	startedAt = nil
end

function Weather.Init()
	scope:Hydrate(uIScale)({
		Scale = spring2
	})
	scope:Hydrate(tooltip)({
		Position = spring3
	})
	scope:Observer(spring):onBind(function()
		local currentSpring = scope.peek(spring)

		if not currentSpring then
			return
		end

		SetBarProgress(currentSpring)
	end)
	module.Button:Create(main2, "Small"):BindFunction("Click", function()
		module.Frame:Close(weather2)
	end)
	ReplicatedStorage:GetAttributeChangedSignal(weather.AttributeName):Connect(function()
		if not v6 then
			return
		end

		Weather.Refresh()
	end)
	module.Frame:OnFrameOpened(weather2, Weather.Start)
	module.Frame:OnFrameClosed(weather2, Weather.Stop)
end

return Weather