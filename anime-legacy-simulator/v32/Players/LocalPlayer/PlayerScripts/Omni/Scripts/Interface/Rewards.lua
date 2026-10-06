local TweenService = game:GetService("TweenService")
local module = require("@game/ReplicatedStorage/Omni")
local v = {
	Daily = 1,
	Time = 2
}
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(0, 255, 149)
local color3 = Color3.fromRGB(255, 78, 78)
local color4 = Color3.fromRGB(255, 220, 93)
local uDim = UDim2.fromScale(0, 0.25)
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local rewards = module.Interface:WaitForChild("Frames"):WaitForChild("Rewards")
local options = rewards:WaitForChild("Options")
local main = rewards:WaitForChild("Main")
local daily = main:WaitForChild("Daily")
local time = main:WaitForChild("Time")
local timer = time:WaitForChild("Timer")
local scroll = time:WaitForChild("List"):WaitForChild("Scroll")
local main2 = time:WaitForChild("Auto"):WaitForChild("Main")
local rewards2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Rewards")
local category = rewards2:WaitForChild("Category")
local timeReward = rewards2:WaitForChild("TimeReward")
local v2 = {}
local innerScopesByName = {}
local v3 = {}
local innerScopes = {}
local v4 = "Daily"
local value = scope:Value(color)
local spring = scope:Spring(value, 10, 1)
local Rewards = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshRewardGradients(instance, enabled: boolean)
	local normalGradient = instance:FindFirstChild("NormalGradient") or instance:FindFirstChild("AvailableGradient")
	local claimedGradient = instance:FindFirstChild("ClaimedGradient")

	if normalGradient then
		normalGradient.Enabled = not enabled
	end

	if claimedGradient then
		claimedGradient.Enabled = enabled
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsDailyAvailable(p: number)
	if module.Data.DailyRewards.Claimed[tostring(p)] then
		return true
	end

	local start = module.Data.DailyRewards.Start

	if start == 0 then
		return p == 1
	end

	local v5 = math.floor((workspace:GetServerTimeNow() - start) / 86400)
	return p - 1 <= v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsTimeAvailable(p: number, p2: number)
	if module.Data.TimeRewards.Claimed[tostring(p)] then
		return true
	end

	return p2 <= module.Data.TimeRewards.TimePlayed
end

local v5 = {
	Build = function(self, duration: number)
		self.SelectionProgress = self:Value(0)
		self.SelectionProgressSpring = self:Spring(self.SelectionProgress, 10, 1)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = category:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Title.Text = self.Name
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			Rewards.SetCategory(self.Name)
		end)
		self.Instance.LayoutOrder = self.Index or 999
		self.Instance.Parent = options
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Observer(self.SelectionProgressSpring):onBind(function()
			local selectionProgressSpring = self.peek(self.SelectionProgressSpring)

			if not selectionProgressSpring then
				return
			end

			local colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color:Lerp(color3, selectionProgressSpring)),
				ColorSequenceKeypoint.new(1, color:Lerp(color4, selectionProgressSpring))
			})
			self.Instance.Main.UIGradient.Color = colorSequence
			self.Instance.Main.Title.UIGradient.Color = colorSequence
		end)

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		self:Update()
		return true
	end,
	Update = function(self)
		self.SelectionProgress:set(self.Name == v4 and 1 or 0)
	end
}
local scope2 = fusion.scoped(fusion, v5)
local scope3 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.Instance = timeReward:Clone()
		self.Instance.Name = tostring(self.Index)
		local v6 = module.Utils.Info:Get(self.Reward.Type, self.Reward.Name)
		self.Instance.Main.Title.Text = self.Reward.Name
		self.Instance.Main.Amount.Text = "x" .. module.Utils.Number:Format(self.Reward.Amount)
		self.Instance.Main.Icon.Image = v6 and v6.Icon or ""
		self.Instance.Main.Timer.Text = module.Utils.Number:Time2(self.Time)
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "TimeRewards", "Claim", self.Index)
		end)
		self.Instance.LayoutOrder = self.Index
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Size = self.SizeSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Size:set(UDim2.fromScale(1, 1))
			end)
		else
			self.Size:set(UDim2.fromScale(1, 1))
		end

		self:Update()
		return true
	end,
	Update = function(self)
		local visible = module.Data.TimeRewards.Claimed[tostring(self.Index)] == true
		local v7

		if visible then
			v7 = visible
		else
			v7 = IsTimeAvailable(self.Index, self.Time)
		end

		self.Instance.Main.Claimed.Visible = visible
		self.Instance.GroupTransparency = v7 and 0 or 0.5
		RefreshRewardGradients(self.Instance.Main, visible) -- equivalent call inferred; original call site unknown
	end
})

function Rewards.SetupDailyControllers()
	local function SetupDay(instance, p2: number)
		local main3 = instance.Main
		local position = main3.Position
		local dailyReward = module.Shared.DailyRewards[p2]
		local reward = dailyReward and dailyReward.Reward

		if reward then
			local v6 = module.Utils.Info:Get(reward.Type, reward.Name)
			main3.Title.Text = reward.Name
			main3.Amount.Text = "x" .. module.Utils.Number:Format(reward.Amount)
			main3.Icon.Image = v6 and v6.Icon or ""
		end

		main3.Day.Text = "Day " .. p2

		if main3:IsA("GuiButton") then
			module.Button:Create(main3, "Small"):BindFunction("Click", function()
				module.Signal:Fire("General", "DailyRewards", "Claim", p2)
			end)
		else
			warn((`[Rewards] Daily day {p2}'s Main is a {main3.ClassName}, not a GuiButton - it won't be clickable until it's changed to an ImageButton in Studio.`))
		end

		v3[p2] = {
			Instance = instance,
			MainButton = main3,
			OriginalPosition = position,
			Tweens = {}
		}
	end

	for _, canvasGroup in daily:WaitForChild("Others"):GetChildren() do
		if not canvasGroup:IsA("CanvasGroup") then
			continue
		end

		local name = tonumber(canvasGroup.Name)

		if name then
			SetupDay(canvasGroup, name)
		end
	end

	local _7 = daily:FindFirstChild("7")

	if _7 then
		SetupDay(_7, 7)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CancelDailyTweens(p)
	for _, tween in p.Tweens do
		tween:Cancel()
	end

	table.clear(p.Tweens)
end

function Rewards.PlayDailyEntrance()
	local total = 0

	for i = 1, 7 do
		local v6 = v3[i]

		if not v6 then
			continue
		end

		CancelDailyTweens(v6) -- equivalent call inferred; original call site unknown
		local position = v6.OriginalPosition + uDim
		local dailyAvailable = IsDailyAvailable(i) -- equivalent call inferred; original call site unknown
		v6.MainButton.Position = position
		v6.Instance.GroupTransparency = 1
		local v10 = v6
		local groupTransparency = dailyAvailable and 0 or 0.5
		task.delay(total, function()
			local tween = TweenService:Create(v10.MainButton, tweenInfo, {
				Position = v10.OriginalPosition
			})
			local tween2 = TweenService:Create(v10.Instance, tweenInfo, {
				GroupTransparency = groupTransparency
			})
			table.insert(v10.Tweens, tween)
			table.insert(v10.Tweens, tween2)
			tween:Play()
			tween2:Play()
		end)
		total += 0.05
	end
end

function Rewards.UpdateDaily()
	for k, v6 in v3 do
		local mainButton = v6.MainButton
		local visible = module.Data.DailyRewards.Claimed[tostring(k)] == true
		mainButton.Claimed.Visible = visible
		RefreshRewardGradients(mainButton, visible) -- equivalent call inferred; original call site unknown
		local dailyAvailable = IsDailyAvailable(k) -- equivalent call inferred; original call site unknown
		CancelDailyTweens(v6) -- equivalent call inferred; original call site unknown
		local tween = TweenService:Create(v6.Instance, tweenInfo2, {
			GroupTransparency = dailyAvailable and 0 or 0.5
		})
		table.insert(v6.Tweens, tween)
		tween:Play()
	end
end

function Rewards.UpdateAuto()
	local autoTimeRewards = module.Data.Settings["Auto Time Rewards"] == true
	value:set(autoTimeRewards and color2 or color)
end

function Rewards.ClearTimeRewards()
	for _, v6 in innerScopes do
		v6.Instance:Destroy()
		v6:doCleanup()
	end

	table.clear(innerScopes)
end

function Rewards.GenerateTimeRewards()
	Rewards.ClearTimeRewards()
	local total = 0

	for i = 1, #module.Shared.TimeRewards do
		local timeReward2 = module.Shared.TimeRewards[i]

		if not timeReward2 then
			continue
		end

		local innerScope = scope3:innerScope()
		innerScope.Index = i
		innerScope.Time = timeReward2.Time
		innerScope.Reward = timeReward2.Reward

		if innerScope:Build(total) then
			table.insert(innerScopes, innerScope)
		else
			innerScope:doCleanup()
		end

		total += 0.05
	end
end

function Rewards.UpdateTimeRewards()
	for _, v6 in innerScopes do
		v6:Update()
	end
end

function Rewards.UpdateResetTimer()
	local resetAt = module.Data.TimeRewards.ResetAt

	if not resetAt then
		timer.Title.Text = module.Utils.Number:Time2(module.Data.TimeRewards.TimePlayed)
		return
	end

	local v6 = math.max(0, resetAt - workspace:GetServerTimeNow())
	timer.Title.Text = module.Utils.Number:Time2(v6)
end

function Rewards.ClearCategories()
	for _, v6 in innerScopesByName do
		v6.Instance:Destroy()
		v6:doCleanup()
	end

	table.clear(innerScopesByName)
end

function Rewards.GenerateCategories()
	local total = 0

	for _, frame in main:GetChildren() do
		if not frame:IsA("Frame") or innerScopesByName[frame.Name] then
			continue
		end

		local innerScope = scope2:innerScope()
		innerScope.Name = frame.Name
		innerScope.Index = v[frame.Name] or 999

		if innerScope:Build(total) then
			innerScopesByName[frame.Name] = innerScope
		else
			innerScope:doCleanup()
		end

		total += 0.05
	end
end

function Rewards.UpdateCategories()
	for _, v6 in innerScopesByName do
		v6:Update()
	end
end

function Rewards.SetCategory(p: string)
	if v4 == p then
		return
	end

	v4 = p
	daily.Visible = p == "Daily"
	time.Visible = p == "Time"
	Rewards.UpdateCategories()

	if p == "Daily" then
		Rewards.PlayDailyEntrance()
	else
		Rewards.GenerateTimeRewards()
	end
end

function Rewards.Stop()
	for _, connection in v2 do
		connection:Disconnect()
	end

	table.clear(v2)
	Rewards.ClearCategories()
	Rewards.ClearTimeRewards()
end

function Rewards.Start()
	v2.Auto = module:OnDataChanged({ "Settings", "Auto Time Rewards" }, Rewards.UpdateAuto)
	v2.Daily = module:OnDataChanged({ "DailyRewards" }, Rewards.UpdateDaily)
	v2.Time = module:OnDataChanged({ "TimeRewards" }, function()
		Rewards.UpdateTimeRewards()
		Rewards.UpdateResetTimer()
	end)
	v2.Loop = module.Utils.Loop:Connect({
		Time = 1,
		Callback = Rewards.UpdateResetTimer
	})
	daily.Visible = v4 == "Daily"
	time.Visible = v4 == "Time"
	Rewards.GenerateCategories()
	Rewards.UpdateDaily()
	Rewards.UpdateResetTimer()
	Rewards.UpdateAuto()

	if v4 == "Daily" then
		Rewards.PlayDailyEntrance()
	else
		Rewards.GenerateTimeRewards()
	end
end

function Rewards.Init()
	Rewards.SetupDailyControllers()
	module.Button:Create(main2, "Small"):BindFunction("Click", function()
		local autoTimeRewards = module.Data.Settings["Auto Time Rewards"] == true
		module.Signal:Fire("General", "Settings", "Set", "Auto Time Rewards", not autoTimeRewards)
	end)
	scope:Hydrate(main2.Icon)({
		ImageColor3 = spring
	})
	module.Frame:OnFrameClosed(rewards, Rewards.Stop)
	module.Frame:OnFrameOpened(rewards, Rewards.Start)
end

return Rewards