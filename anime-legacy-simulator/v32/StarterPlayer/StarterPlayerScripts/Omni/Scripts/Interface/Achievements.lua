local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local achievements = module.Interface:WaitForChild("Frames"):WaitForChild("Achievements")
local scroll = achievements:WaitForChild("CategoryList"):WaitForChild("Scroll")
local scroll2 = achievements:WaitForChild("AchievementsList"):WaitForChild("Scroll")
local categoryButtons = achievements:WaitForChild("CategoryButtons")
local main = achievements:WaitForChild("AutoClaim"):WaitForChild("Main")
local exclamation = module.Interface:WaitForChild("HUD"):WaitForChild("Left"):WaitForChild("Buttons"):WaitForChild("Achievements"):WaitForChild("Main"):WaitForChild("Exclamation")
local achievements2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Achievements")
local color = Color3.fromRGB(120, 120, 120)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(255, 255, 255)
local color4 = Color3.fromRGB(0, 255, 149)
local innerScopesByType = {}
local v = {}
local count = 0
local v2 = {}
local flag = false
local v3 = nil
local v4 = "Worlds"
local v5 = {}
local v6 = {}
local flag2 = true
local value = scope:Value(color3)
local spring = scope:Spring(value, 10, 1)
local Achievements = {}

local function HasClaimableAchievement(items)
	for _, item in items do
		if module.Data.Achievements[item.Name] ~= true and select(
			3,
			module.Shared.Achievements.GetProgress(module.Data, item)
		) == 1 then
			return true
		end
	end

	return false
end

local function StatsFilter(_, _, list)
	local v7 = list[1]

	if not v7 then
		flag2 = true
		return true
	end

	local types = module.Shared.Achievements.GetTypesFromStat(v7)

	if not types then
		return false
	end

	for _, type in types do
		v6[type] = true
	end

	return true
end

local function AchievementsFilter()
	flag2 = true
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RunDestroyQueue()
	if flag then
		return
	end

	flag = true
	task.defer(function()
		local lastTime = os.clock()

		while #v2 > 0 do
			if os.clock() - lastTime >= 0.004 then
				task.wait()
				lastTime = os.clock()
			end

			local v7 = table.remove(v2)

			if v7.Rewards then
				for _, reward in v7.Rewards do
					reward.Instance:Destroy()
					reward:doCleanup()
				end
			end

			v7.Instance:Destroy()
			v7:doCleanup()
		end

		flag = false
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ReleaseTemplate(p)
	p.Instance.Visible = false
	table.insert(v2, p)
	RunDestroyQueue() -- equivalent call inferred; original call site unknown
end

local v7 = {
	Build = function(self, duration: number)
		self.Transparency = self:Value(0)
		self.TransparencySpring = self:Spring(self.Transparency, 10, 1)
		self.Progress = self:Value(0)
		self.ProgressSpring = self:Spring(self.Progress, 10, 1)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = achievements2.Category:Clone()
		self.Instance.Name = self.Type
		self.Instance.Main.Info.Title.Text = self.Type
		self.Instance.Main.Info.Desc.Text = module.Shared.Achievements.GetTypeDescription(self.Type)
		self.Instance.Main.Info.Icon.Icon.Image = module.Shared.Achievements.GetTypeIcon(self.Type)
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			Achievements.SetType(self.Type)
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance)({
			GroupTransparency = self.TransparencySpring
		})
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Observer(self.ProgressSpring):onBind(function()
			local progressSpring = self.peek(self.ProgressSpring)

			if not progressSpring then
				return
			end

			self.Instance.Main.Progress.Value.Text = module.Utils.Number:Round(progressSpring * 100, 1) .. "%"

			if progressSpring == 1 then
				self.Instance.Main.Progress.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 0)
				})
				return
			elseif progressSpring == 0 then
				self.Instance.Main.Progress.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
				return
			end

			local numberSequenceKeypoints = {}
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(0, 0))
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(progressSpring, 0))
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(math.min(1, progressSpring + 0.1), 1))
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(1, 1))
			self.Instance.Main.Progress.Bar.Slider.UIGradient.Transparency = NumberSequence.new(numberSequenceKeypoints)
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
		local count2 = 0

		for _, v8 in self.Info do
			if module.Data.Achievements[v8.Name] then
				count2 += 1
			end
		end

		self.Instance.Main.Hover.Visible = v3 == self.Type
		self.Instance.Main.Exclamation.Visible = v5[self.Type] == true
		self.Progress:set(count2 / #self.Info)
		self.Transparency:set(v3 == self.Type and 0 or 0.4)
	end
}
local scope2 = fusion.scoped(fusion, v7)
local scope3 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.Instance = achievements2.Reward:Clone()
		self.Instance.Name = self.Info.Name
		self.Instance.Main.Amount.Text = self.Info.Text
		self.Instance.Main.UIGradient:SetAttribute("Rarity", self.Info.Rarity or "Common")

		if self.Info.Icon then
			self.Instance.Main.Icon.Visible = true
			self.Instance.Main.Viewport.Visible = false
			self.Instance.Main.Icon.Image = self.Info.Icon or ""
		else
			self.Instance.Main.Icon.Visible = false
			self.Instance.Main.Viewport.Visible = true
			module.Utils.Camera.ViewportCharacter({
				Viewport = self.Instance.Main.Viewport,
				Animation = module.Utils.Characters.GetCharacterAnimation(self.Info.Name, "Idle"),
				Character = module.Utils.Characters.Get({
					Name = self.Info.Name,
					Shiny = self.Info.Shiny,
					RemoveHumanoidStates = true
				})
			})
		end

		local v8 = module.Button:Create(self.Instance.Main, "Small")
		v8:BindFunction("Click", function()
			if not self.Hover then
				return
			end

			if self.Tooltip then
				self.Hover:Click(self.Instance, {
					Text = self.Info.Name
				})
			else
				self.Hover:Click(self.Instance, {
					IsFake = true,
					Data = self.Info,
					Name = self.Info.Name
				})
			end
		end)
		v8:BindOnEnter("Hover", function()
			if not self.Hover then
				return
			end

			if self.Tooltip then
				self.Hover:Open(self.Instance, {
					Text = self.Info.Name
				})
			else
				self.Hover:Open(self.Instance, {
					IsFake = true,
					Data = self.Info,
					Name = self.Info.Name
				})
			end
		end)
		v8:BindOnLeave("Hover", function()
			if not self.Hover then
				return
			end

			self.Hover:Close(self.Instance)
		end)
		self.Instance.Parent = self.Parent
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

		return true
	end
})
local scope4 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		local _, needed, _, text, isTime = module.Shared.Achievements.GetInformation(module.Data, self.Info)
		self.Needed = needed
		self.IsTime = isTime
		self.NeededText = self.IsTime and module.Utils.Number:Time2(needed * 60) or module.Utils.Number:Format(needed)
		self.Progress = self:Value(0)
		self.ProgressSpring = self:Spring(self.Progress, 10, 1)
		self.Position = self:Value(UDim2.fromScale(1.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = achievements2.Achievement:Clone()
		self.Instance.Name = self.Type
		self.Instance.Main.Title.Text = self.Info.Name
		self.Instance.Main.Desc.Text = text
		module.Button:Create(self.Instance.Main.Claim, "Small"):BindFunction("Click", function()
			if module.Data.Achievements[self.Info.Name] == true then
				return
			end

			module.Signal:Fire("General", "Achievements", "Claim", self.Info.Name)
		end)
		local v11 = {}

		for k, perk in self.Info.Perks do
			local perk2 = module.Shared.Perks[k]

			if perk2 then
				table.insert(v11, {
					Type = "Perk",
					Name = k,
					Text = module.Utils.Multipliers.ToStringSingle({
						Name = k,
						RemoveName = true,
						ShowPercentage = not perk2.NumericOnly,
						MultiplierArray = { perk }
					}),
					Icon = perk2.Icon,
					Rarity = perk2.Rarity
				})
			end
		end

		for _, reward in self.Info.Rewards do
			local v12 = module.Utils.Info:Get(reward.Type, reward.Name)

			if v12 then
				table.insert(v11, {
					Type = reward.Type,
					Name = reward.Name,
					Text = reward.Amount == 1 and reward.Type or reward.Amount .. "x",
					Icon = reward.Icon or v12.Icon,
					Rarity = reward.Rarity or v12.Rarity
				})
			end
		end

		self.Rewards = {}

		for k, info in v11 do
			local innerScope = scope3:innerScope()
			innerScope.Info = info
			innerScope.Parent = self.Instance.Main.Rewards.Main
			innerScope.Hover = module.Libs.NeoHover.GetByPseudoIdentifier(info.Type)

			if not innerScope.Hover then
				innerScope.Tooltip = true
				innerScope.Hover = module.Libs.NeoHover.GetByIdentifier("Tooltip")
			end

			if innerScope:Build((k - 1) * 0.05) then
				table.insert(self.Rewards, innerScope)
			else
				innerScope:doCleanup()
			end
		end

		self.Instance.Parent = scroll2
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Observer(self.ProgressSpring):onBind(function()
			local progressSpring = self.peek(self.ProgressSpring)

			if not progressSpring then
				return
			end

			local v12 = self.IsTime and self.Needed * progressSpring or module.Utils.Number:Round(self.Needed * progressSpring)
			local v13 = self.IsTime and module.Utils.Number:Time2(v12 * 60) or module.Utils.Number:Format(v12)
			self.Instance.Main.Progress.Value.Text = v13 .. " / " .. self.NeededText

			if progressSpring == 1 then
				self.Instance.Main.Progress.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 0)
				})
				return
			elseif progressSpring == 0 then
				self.Instance.Main.Progress.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
				return
			end

			local numberSequenceKeypoints = {}
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(0, 0))
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(progressSpring, 0))
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(math.min(1, progressSpring + 0.1), 1))
			table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(1, 1))
			self.Instance.Main.Progress.Bar.Slider.UIGradient.Transparency = NumberSequence.new(numberSequenceKeypoints)
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
		local v8 = module.Data.Achievements[self.Info.Name] == true
		local v9 = select(3, module.Shared.Achievements.GetProgress(module.Data, self.Info))
		self.Instance.LayoutOrder = v8 and self.Index + #module.Shared.Achievements.List[self.Type] or self.Index
		self.Instance.Main.Claimed.Visible = false
		self.Instance.Main.Claim.Visible = v8 or v9 == 1
		self.Instance.Main.Claim.Title.Text = v8 and "Claimed" or "Claim"
		self.Instance.Main.Claim.Title.UIGradient.Enabled = not v8
		self.Instance.Main.Claim.BG.UIGradient.Enabled = not v8
		self.Instance.Main.Claim.BG.ImageColor3 = v8 and color or color2
		self.Instance.Main.Progress.Visible = not v8 and v9 ~= 1
		self.Instance.Main.Line2.Visible = not v8 and v9 ~= 1
		self.Progress:set(v9)
	end
})

function Achievements.UpdateAuto()
	local autoAchievements = module.Data.Settings["Auto Achievements"] == true
	value:set(autoAchievements and color4 or color3)
end

function Achievements.Clear()
	count += 1

	for _, v8 in innerScopesByType do
		ReleaseTemplate(v8) -- equivalent call inferred; original call site unknown
	end

	for _, v8 in v do
		ReleaseTemplate(v8) -- equivalent call inferred; original call site unknown
	end

	table.clear(innerScopesByType)
	table.clear(v)
end

function Achievements.Generate()
	local types = module.Shared.Achievements.GetTypesFromCategory(v4)
	local total = 0

	for _, type in types do
		if innerScopesByType[type] then
			continue
		end

		local info = module.Shared.Achievements.List[type]

		if not info then
			continue
		end

		local innerScope = scope2:innerScope()
		innerScope.Type = type
		innerScope.Info = info

		if innerScope:Build(total) then
			innerScopesByType[type] = innerScope
			total += 0.05
		else
			innerScope:doCleanup()
		end
	end

	local v8 = module.Shared.Achievements.List[v3] or {}
	local v9 = {}

	for _, v10 in v8 do
		v9[v10.Name] = true
	end

	for k, v10 in v do
		if v9[k] then
			continue
		end

		ReleaseTemplate(v10) -- equivalent call inferred; original call site unknown
		v[k] = nil
	end

	count += 1
	local v10 = count
	local v11 = v3
	local v12 = {}

	for k, info in v8 do
		if not v[info.Name] then
			table.insert(v12, {
				Index = k,
				Info = info
			})
		end
	end

	if #v12 == 0 then
		return
	end

	task.spawn(function()
		local lastTime = os.clock()
		local now = lastTime

		for k, v13 in v12 do
			if os.clock() - now >= 0.004 then
				task.wait()
				now = os.clock()
			end

			if v10 ~= count then
				break
			end

			if v[v13.Info.Name] then
				continue
			end

			local v14 = math.max(0, (k - 1) * 0.05 - (os.clock() - lastTime))
			local innerScope = scope4:innerScope()
			innerScope.Type = v11
			innerScope.Index = v13.Index
			innerScope.Info = v13.Info

			if innerScope:Build(v14) then
				v[v13.Info.Name] = innerScope
			else
				innerScope:doCleanup()
			end
		end
	end)
end

function Achievements.RefreshClaimable()
	if flag2 then
		flag2 = false

		for k in module.Shared.Achievements.List do
			v6[k] = true
		end
	end

	for k in v6 do
		local v8 = module.Shared.Achievements.List[k]
		v5[k] = v8 and HasClaimableAchievement(v8) or nil
	end

	table.clear(v6)
	exclamation.Visible = next(v5) ~= nil
end

function Achievements.UpdateAll()
	Achievements.RefreshClaimable()

	for _, v8 in innerScopesByType do
		v8:Update()
	end

	for _, v8 in v do
		v8:Update()
	end
end

function Achievements.SetCategory(p: string)
	if v4 == p then
		return
	end

	v3 = nil
	v4 = p
	Achievements.Clear()
	Achievements.Generate()
end

function Achievements.SetType(p: string)
	if v3 == p then
		v3 = nil
	else
		v3 = p
	end

	Achievements.Generate()
	Achievements.UpdateAll()
end

function Achievements.Stop()
	Achievements.Clear()
end

function Achievements.Start()
	Achievements.Generate()
end

function Achievements.Init()
	module.Button:Create(achievements.ClaimAll.Main, "Small"):BindFunction("Click", function()
		module.Signal:Fire("General", "Achievements", "ClaimAll")
	end)
	module.Button:Create(main, "Small"):BindFunction("Click", function()
		local autoAchievements = module.Data.Settings["Auto Achievements"] == true
		module.Signal:Fire("General", "Settings", "Set", "Auto Achievements", not autoAchievements)
	end)
	scope:Hydrate(main.Icon)({
		ImageColor3 = spring
	})
	module.Frame:OnFrameClosed(achievements, Achievements.Stop)
	module.Frame:OnFrameOpened(achievements, Achievements.Start)
	module:OnDataChangedDeferred({ "Profile", "Stats" }, Achievements.UpdateAll, StatsFilter)
	module:OnDataChangedDeferred({ "Achievements" }, Achievements.UpdateAll, AchievementsFilter)
	module:OnDataChanged({ "Settings", "Auto Achievements" }, Achievements.UpdateAuto)
	Achievements.UpdateAll()
	Achievements.UpdateAuto()

	for _, frame in categoryButtons:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v8 = frame
		module.Button:Create(frame.Main, "Default"):BindFunction("Click", function()
			Achievements.SetCategory(v8.Name)
		end)
	end
end

return Achievements