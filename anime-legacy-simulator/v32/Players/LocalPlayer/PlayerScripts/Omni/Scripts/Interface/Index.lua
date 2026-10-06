local module = require("@game/ReplicatedStorage/Omni")
local v = { "Fighters", "Accessories", "Weapons" }
local v2 = {
	Accessories = true,
	Weapons = true
}
local uDim = UDim2.fromScale(0.9, 0.9)
local uDim2 = UDim2.fromScale(0, 0)
local v3 = {
	Exclusives = {
		Name = "Exclusives",
		Icon = "rbxassetid://117603036318289"
	}
}
local fusion = module.Libs.Fusion
local index = module.Interface:WaitForChild("Frames"):WaitForChild("Index")
local buttons = index:WaitForChild("Left"):WaitForChild("Buttons")
local scroll = index:WaitForChild("Left"):WaitForChild("List"):WaitForChild("Scroll")
local scroll2 = index:WaitForChild("Right"):WaitForChild("List"):WaitForChild("Scroll")
local buttons2 = index:WaitForChild("Right"):WaitForChild("Buttons")
local index2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Index")
local v4 = {}
local innerScopes = {}
local innerScopes2 = {}
local category = "Worlds"
local v6 = nil
local Index = {}
local v7 = {
	Build = function(self, duration: number)
		self.Transparency = self:Value(0)
		self.TransparencySpring = self:Spring(self.Transparency, 10, 1)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = index2.Section:Clone()
		self.Instance.Name = self.Name
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			Index.SetSection(self.Name)
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance)({
			GroupTransparency = self.TransparencySpring
		})
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})

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
		if self.Category ~= "Worlds" or module.Utils.PlayerStats.OwnsMap(self.Name, module.Data) then
			self.Instance.Main.Title.Text = self.Info.Name or self.Name
			self.Instance.Main.Thumb.Image = self.Info.Icon or ""
		else
			self.Instance.Main.Title.Text = "???"
			self.Instance.Main.Thumb.Image = ""
		end

		self.Instance.Main.Hover.Visible = v6 == self.Name
		self.Transparency:set(v6 == self.Name and 0 or 0.4)
	end
}
local scope = fusion.scoped(fusion, v7)
local scope2 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = index2.Separator:Clone()
		self.Instance.Name = self.Type
		self.Instance.LayoutOrder = self.Order
		self.Instance.Parent = scroll2
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})

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
		local v8 = module.Shared.Index.SingularType[self.Type]
		local v9 = #self.Items
		local count = 0

		for _, item in self.Items do
			if module.Shared.Index.GetAmount(v8, item, module.Data) > 0 then
				count += 1
			end
		end

		self.Instance.Main.Info.Title.Text = `{self.Type} ({count}/{v9})`
	end
})
local scope3 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Size = self:Value(UDim2.fromScale(0, 0))
		self.SizeSpring = self:Spring(self.Size, 10, 1)
		self.Instance = index2.Slot:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Title.Text = self.Name
		self.Instance.Main.UIGradient:SetAttribute("Rarity", self.Info.Rarity)

		if self.Type == "Fighters" then
			self.Instance.Main.Icon.Visible = false
			self.Instance.Main.Viewport.Visible = true
		else
			self.Instance.Main.Icon.Visible = true
			self.Instance.Main.Viewport.Visible = false
			self.Instance.Main.Icon.Image = self.Info.Icon or ""
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function GetHoverParams()
			return {
				IsFake = true,
				IsIndex = true,
				Data = self.FakeData
			}
		end

		local v8 = module.Button:Create(self.Instance.Main, "Small")
		v8:BindFunction("Click", function()
			if not self.Discovered then
				return
			end

			local v9 = module.Libs.NeoHover.GetByIdentifier(self.Type)

			if not v9 then
				return
			end

			v9:Click(self.Instance, GetHoverParams())
		end)
		v8:BindOnEnter("Hover", function()
			if not self.Discovered then
				return
			end

			local v9 = module.Libs.NeoHover.GetByIdentifier(self.Type)

			if not v9 then
				return
			end

			v9:Open(self.Instance, GetHoverParams())
		end)
		v8:BindOnLeave("Hover", function()
			local v9 = module.Libs.NeoHover.GetByIdentifier(self.Type)

			if not v9 then
				return
			end

			v9:Close(self.Instance)
		end)
		self.Instance.LayoutOrder = self.Order
		self.Instance.Parent = scroll2
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Size = self.SizeSpring
		})

		if v2[self.Type] then
			self.AutoLockSize = self:Value(uDim2)
			self.AutoLockSizeSpring = self:Spring(self.AutoLockSize, 10, 1)
			self.AutoDeleteSize = self:Value(uDim2)
			self.AutoDeleteSizeSpring = self:Spring(self.AutoDeleteSize, 10, 1)
			self:Hydrate(self.Instance.Main.AutoLock)({
				Size = self.AutoLockSizeSpring,
				Visible = true
			})
			self:Hydrate(self.Instance.Main.AutoDelete)({
				Size = self.AutoDeleteSizeSpring,
				Visible = true
			})
		end

		if duration and duration > 0 then
			task.delay(duration, function()
				if not next(self) then
					return
				end

				self.Revealed = true
				self:Update()
				self.Size:set(UDim2.fromScale(1, 1))
			end)
		else
			self.Revealed = true
			self:Update()
			self.Size:set(UDim2.fromScale(1, 1))
		end

		return true
	end,
	Update = function(self)
		if not self.Revealed then
			return
		end

		local discovered = module.Shared.Index.GetAmount(
			module.Shared.Index.SingularType[self.Type],
			self.Name,
			module.Data
		) > 0

		if self.Discovered ~= discovered then
			self.Discovered = discovered
			local v9

			if self.Type == "Fighters" then
				v9 = module.Shared.Fighters.GetDisplayName(self.Name)
			else
				v9 = self.Name
			end

			self.Instance.Main.Title.Text = discovered and v9 or "???"

			if self.Type == "Fighters" then
				module.Utils.Camera.ViewportCharacter({
					Viewport = self.Instance.Main.Viewport,
					Locked = not discovered,
					Animation = module.Utils.Characters.GetCharacterAnimation(self.Name, "Idle"),
					Character = module.Utils.Characters.Get({
						Name = self.Name,
						Shiny = false,
						RemoveHumanoidStates = true
					})
				})
			else
				self.Instance.Main.Icon.ImageColor3 = discovered and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
			end
		end

		self:UpdateAutoState()
	end,
	UpdateAutoState = function(self)
		if not self.AutoLockSize then
			return
		end

		local v8 = module.Data[self.Type]
		local v9

		if self.Revealed == true then
			v9 = self.Discovered == true
		else
			v9 = false
		end

		local v10 = v9 and v8.AutoLock[self.Name] == true
		local v11 = v9 and v8.AutoDelete[self.Name] == true
		self.AutoLockSize:set(v10 and uDim or uDim2)
		self.AutoDeleteSize:set(v11 and uDim or uDim2)
	end
})

function Index.ClearSections()
	for _, v8 in innerScopes do
		v8.Instance:Destroy()
		v8:doCleanup()
	end

	table.clear(innerScopes)
end

function Index.GenerateSections()
	for _, name in module.Shared.Index.GetSectionsForCategory(category) do
		if innerScopes[name] then
			continue
		end

		local info = category == "Worlds" and module.Shared.Maps.List[name] or v3[name]

		if not info then
			continue
		end

		local innerScope = scope:innerScope()
		innerScope.Name = name
		innerScope.Category = category
		innerScope.Info = info

		if innerScope:Build(#innerScopes * 0.05) then
			innerScopes[name] = innerScope
		else
			innerScope:doCleanup()
		end
	end
end

function Index.UpdateSections()
	for _, v8 in innerScopes do
		v8:Update()
	end
end

function Index.ClearItems()
	for _, v8 in innerScopes2 do
		v8.Instance:Destroy()
		v8:doCleanup()
	end

	table.clear(innerScopes2)
end

function Index.GenerateItems()
	Index.ClearItems()

	if not v6 then
		return
	end

	local itemsForSection = module.Shared.Index.GetItemsForSection(category, v6)
	local count = 0
	local total = 0

	for _, v8 in v do
		local items = itemsForSection[v8]

		if not (items and #items ~= 0) then
			continue
		end

		local innerScope = scope2:innerScope()
		innerScope.Type = v8
		innerScope.Items = items
		innerScope.Order = count

		if innerScope:Build(total) then
			table.insert(innerScopes2, innerScope)
		else
			innerScope:doCleanup()
		end

		count += 1
		total += 0.05

		for _, name in items do
			local info = module.Shared.Index.TypeLists[v8][name]

			if not info then
				continue
			end

			local innerScope2 = scope3:innerScope()
			innerScope2.Type = v8
			innerScope2.Name = name
			innerScope2.Info = info
			innerScope2.Order = count
			innerScope2.FakeData = v8 == "Fighters" and ({
				Name = name,
				Level = 1,
				Shiny = false
			} or {
				Name = name
			}) or {
				Name = name
			}

			if innerScope2:Build(total) then
				table.insert(innerScopes2, innerScope2)
			else
				innerScope2:doCleanup()
			end

			count += 1
			total += 0.05
		end
	end
end

function Index.UpdateItems()
	for _, v8 in innerScopes2 do
		v8:Update()
	end
end

function Index.UpdateAutoStates()
	for _, v8 in innerScopes2 do
		if v8.UpdateAutoState then
			v8:UpdateAutoState()
		end
	end
end

function Index.RefreshCategoryButtons()
	for _, frame in buttons:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		frame.Main.UIGradient.Enabled = frame.Name == category
		frame.Main.Title.UIGradient.Enabled = frame.Name == category
	end
end

function Index.SetCategory(p: string)
	if category == p then
		return
	end

	category = p
	v6 = nil
	Index.RefreshCategoryButtons()
	Index.ClearSections()
	Index.GenerateSections()
	Index.ClearItems()
end

function Index.SetSection(p: string)
	if v6 == p then
		v6 = nil
	else
		v6 = p
	end

	Index.UpdateSections()
	Index.GenerateItems()
end

function Index.Stop()
	for _, connection in v4 do
		connection:Disconnect()
	end

	table.clear(v4)
	Index.ClearSections()
	Index.ClearItems()
end

function Index.Start()
	v4.Maps = module:OnDataChanged({ "Maps" }, Index.UpdateSections)
	v4.Index = module:OnDataChanged({ "Index" }, Index.UpdateItems)
	v4.AccessoriesAutoLock = module:OnDataChanged({ "Accessories", "AutoLock" }, Index.UpdateAutoStates)
	v4.AccessoriesAutoDelete = module:OnDataChanged({ "Accessories", "AutoDelete" }, Index.UpdateAutoStates)
	v4.WeaponsAutoLock = module:OnDataChanged({ "Weapons", "AutoLock" }, Index.UpdateAutoStates)
	v4.WeaponsAutoDelete = module:OnDataChanged({ "Weapons", "AutoDelete" }, Index.UpdateAutoStates)
	Index.GenerateSections()
	Index.GenerateItems()
end

function Index.Init()
	module.Frame:OnFrameClosed(index, Index.Stop)
	module.Frame:OnFrameOpened(index, Index.Start)
	Index.RefreshCategoryButtons()

	for _, frame in buttons:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v8 = frame
		module.Button:Create(frame.Main, "Default"):BindFunction("Click", function()
			Index.SetCategory(v8.Name)
		end)
	end

	local rewards = buttons2:FindFirstChild("Rewards")

	if rewards then
		module.Button:Create(rewards.Main, "Default"):BindFunction("Click", function()
			module.Signal:FireSelf("Interface", "IndexRewards", "Open", index)
		end)
	end
end

return Index