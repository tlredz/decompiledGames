local StarterPlayer = game:GetService("StarterPlayer")
local module = require("@game/ReplicatedStorage/Omni")
require(StarterPlayer.StarterPlayerScripts.Omni.Scripts.Rendering.UIGradient)
local fusion = module.Libs.Fusion
local indexRewards = module.Interface:WaitForChild("Frames"):WaitForChild("IndexRewards")
local main = indexRewards:WaitForChild("Main")
local header = main:WaitForChild("Header")
local sections = main:WaitForChild("Sections")
local progress = main:WaitForChild("Progress")
local scroll = main:WaitForChild("List"):WaitForChild("Scroll")
local indexRewards2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("IndexRewards")
local v = {}
local innerScopes = {}
local innerScopes2 = {}
local v2 = nil
local IndexRewards = {}
local v3 = {
	Build = function(self, duration: number)
		self.Instance = indexRewards2.Section:Clone()
		self.Instance.Name = self.Name
		local size = self.Instance.Main.Size
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.Transparency = self:Value(0)
		self.TransparencySpring = self:Spring(self.Transparency, 10, 1)
		self.Instance.Main.Icon.Image = self.Info.Icon or ""
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			IndexRewards.SetSection(self.Name)
		end)
		self.Instance.Parent = sections
		self.Instance.Visible = true
		self:Hydrate(self.Instance)({
			GroupTransparency = self.TransparencySpring
		})
		self:Hydrate(self.Instance.Main)({
			Size = self.SizeSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Size:set(size)
			end)
		else
			self.Size:set(size)
		end

		self:Update()
		return true
	end,
	Update = function(self)
		self.Transparency:set(v2 == self.Name and 0 or 0.4)
	end
}
local scope = fusion.scoped(fusion, v3)
local scope2 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Instance = indexRewards2.Slot:Clone()
		self.Instance.Name = self.Info.Name
		local size = self.Instance.Main.Size
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.Instance.Main.Title.Text = self.Info.Text
		self.Instance.Main.Icon.Image = self.Info.Icon or ""
		self.Instance.Main.UIGradient:SetAttribute("Rarity", self.Info.Rarity or "Common")
		local v4 = module.Button:Create(self.Instance.Main, "Small")
		v4:BindFunction("Click", function()
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
		v4:BindOnEnter("Hover", function()
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
		v4:BindOnLeave("Hover", function()
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

				self.Size:set(size)
			end)
		else
			self.Size:set(size)
		end

		return true
	end
})
local scope3 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Instance = indexRewards2.Reward:Clone()
		self.Instance.Name = tostring(self.Info.Amount)
		local position = self.Instance.Main.Position
		self.Position = self:Value(position - UDim2.fromScale(0.5, 0))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		module.Button:Create(self.Instance.Main.Claim.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "IndexRewards", "Claim", self.Section, self.Info.Amount)
		end)
		local v4 = {}

		for k, v5 in self.Info.Perks or {} do
			local perk = module.Shared.Perks[k]

			if perk then
				table.insert(v4, {
					Type = "Perk",
					Name = k,
					Text = module.Utils.Multipliers.ToStringSingle({
						Name = k,
						RemoveName = true,
						ShowPercentage = not perk.NumericOnly,
						MultiplierArray = { v5 }
					}),
					Icon = perk.Icon,
					Rarity = perk.Rarity
				})
			end
		end

		for _, v5 in self.Info.Rewards or {} do
			local v6 = module.Utils.Info:Get(v5.Type, v5.Name)

			if v6 then
				table.insert(v4, {
					Type = v5.Type,
					Name = v5.Name,
					Text = v5.Amount == 1 and v5.Type or v5.Amount .. "x",
					Icon = v5.Icon or v6.Icon,
					Rarity = v5.Rarity or v6.Rarity
				})
			end
		end

		self.Slots = {}

		for k, info in v4 do
			local innerScope = scope2:innerScope()
			innerScope.Info = info
			innerScope.Parent = self.Instance.Main.Slots
			innerScope.Hover = module.Libs.NeoHover.GetByPseudoIdentifier(info.Type)

			if not innerScope.Hover then
				innerScope.Tooltip = true
				innerScope.Hover = module.Libs.NeoHover.GetByIdentifier("Tooltip")
			end

			if innerScope:Build((k - 1) * 0.05) then
				table.insert(self.Slots, innerScope)
			else
				innerScope:doCleanup()
			end
		end

		self.Instance.LayoutOrder = self.Info.Amount
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Position:set(position)
			end)
		else
			self.Position:set(position)
		end

		self:Update()
		return true
	end,
	Update = function(self)
		local discoveredAmount = module.Shared.Index.GetDiscoveredAmount(self.Section, module.Data)
		local isRewardClaimed = module.Shared.Index.IsRewardClaimed(self.Section, self.Info.Amount, module.Data)
		local visible = not isRewardClaimed and self.Info.Amount <= discoveredAmount
		self.Instance.Main.Desc.Text = `{discoveredAmount}/{self.Info.Amount} {self.Section}`
		self.Instance.Main.Title.Text = isRewardClaimed and "Claimed" or visible and "Claim" or "Locked"
		self.Instance.Main.ClaimedFrame.UIGradient.Enabled = isRewardClaimed
		self.Instance.Main.ClaimedFrame.UIShadow.Enabled = isRewardClaimed
		self.Instance.Main.ClaimedFrame.Icon.Visible = isRewardClaimed
		self.Instance.Main.ClaimedButton.Visible = isRewardClaimed
		self.Instance.Main.Claim.Visible = visible
		self.Instance.Main.LockedButton.Visible = not (isRewardClaimed or visible)
	end
})

function IndexRewards.ClearSections()
	for _, v4 in innerScopes do
		v4.Instance:Destroy()
		v4:doCleanup()
	end

	table.clear(innerScopes)
end

function IndexRewards.GenerateSections()
	for _, name in module.Shared.Index.GetRewardSections() do
		if innerScopes[name] then
			continue
		end

		local reward = module.Shared.Index.Rewards[name]

		if not reward then
			continue
		end

		local innerScope = scope:innerScope()
		innerScope.Name = name
		innerScope.Info = reward

		if innerScope:Build(#innerScopes * 0.05) then
			innerScopes[name] = innerScope
		else
			innerScope:doCleanup()
		end
	end
end

function IndexRewards.UpdateSections()
	for _, v4 in innerScopes do
		v4:Update()
	end
end

function IndexRewards.ClearRewards()
	for _, v4 in innerScopes2 do
		for _, slot in v4.Slots do
			slot.Instance:Destroy()
			slot:doCleanup()
		end

		v4.Instance:Destroy()
		v4:doCleanup()
	end

	table.clear(innerScopes2)
end

function IndexRewards.GenerateRewards()
	IndexRewards.ClearRewards()

	if not v2 then
		return
	end

	local reward = module.Shared.Index.Rewards[v2]

	if not reward then
		return
	end

	local total = 0

	for _, info in reward.List do
		local innerScope = scope3:innerScope()
		innerScope.Section = v2
		innerScope.Info = info

		if innerScope:Build(total) then
			table.insert(innerScopes2, innerScope)
		else
			innerScope:doCleanup()
		end

		total += 0.05
	end
end

function IndexRewards.UpdateRewards()
	for _, v4 in innerScopes2 do
		v4:Update()
	end
end

function IndexRewards.UpdateProgress()
	if not v2 then
		return
	end

	header.Desc.Text = v2
	local discoveredAmount = module.Shared.Index.GetDiscoveredAmount(v2, module.Data)
	local totalAmount = module.Shared.Index.GetTotalAmount(v2)
	local v4 = not (totalAmount > 0) and 0 or discoveredAmount / totalAmount or 0
	progress.Value.Text = `{discoveredAmount}/{totalAmount}`

	if v4 >= 1 then
		progress.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0)
		})
		return
	end

	if v4 <= 0 then
		progress.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 1)
		})
		return
	end

	local numberSequenceKeypoints = {}
	table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(0, 0))
	table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v4, 0))
	table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(math.min(1, v4 + 0.1), 1))
	table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(1, 1))
	progress.Bar.Slider.UIGradient.Transparency = NumberSequence.new(numberSequenceKeypoints)
end

function IndexRewards.SetSection(p: string)
	if v2 == p then
		return
	end

	v2 = p
	IndexRewards.UpdateSections()
	IndexRewards.UpdateProgress()
	IndexRewards.GenerateRewards()
end

function IndexRewards:Open()
	if self then
		module.Frame:SetPastUI(self)
	end

	module.Frame:Open(indexRewards)
end

function IndexRewards.Stop()
	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
	IndexRewards.ClearSections()
	IndexRewards.ClearRewards()
	v2 = nil
end

function IndexRewards.Start()
	v.Index = module:OnDataChanged({ "Index" }, function()
		IndexRewards.UpdateSections()
		IndexRewards.UpdateProgress()
		IndexRewards.UpdateRewards()
	end)
	v.IndexRewards = module:OnDataChanged({ "IndexRewards" }, IndexRewards.UpdateRewards)
	IndexRewards.GenerateSections()
	local defaultRewardSection = module.Shared.Index.GetDefaultRewardSection()

	if defaultRewardSection then
		v2 = defaultRewardSection
		IndexRewards.UpdateSections()
		IndexRewards.UpdateProgress()
		IndexRewards.GenerateRewards()
	end
end

function IndexRewards.Init()
	module.Frame:OnFrameClosed(indexRewards, IndexRewards.Stop)
	module.Frame:OnFrameOpened(indexRewards, IndexRewards.Start)
end

return IndexRewards