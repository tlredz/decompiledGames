local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 255, 127)
local v = {
	{
		Name = "Announce",
		Button = "Announce",
		Tip = "Announce: receive a chat announcement when anyone obtains this fighter."
	},
	{
		Name = "Auto Sell",
		Button = "Auto Sell",
		Tip = "Auto Sell: automatically sell this fighter when you obtain it."
	},
	{
		Name = "Auto Lock",
		Button = "Auto Lock",
		Tip = "Auto Lock: automatically lock this fighter when you obtain it."
	},
	{
		Name = "Auto Deconstruct",
		Button = "Auto Destruct",
		Tip = "Auto Deconstruct: automatically deconstruct this fighter when you obtain it."
	}
}
local fusion = module.Libs.Fusion
local starSettings = module.Interface:WaitForChild("Frames"):WaitForChild("StarSettings")
local scroll = starSettings:WaitForChild("List"):WaitForChild("Scroll")
local buttons = starSettings:WaitForChild("Buttons")
local starSetting = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("StarSetting")
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = nil
local flag = false
local StarSettings = {}

local function ApplyOption(name: string, flag2: boolean, p: string)
	local settings = module.Shared.StarSettings.GetSettings(name, flag2, module.Data)

	if p == "Announce" then
		module.Signal:Fire("General", "Stars", "SetSetting", name, "Announce", settings.Announce ~= true, flag2)
		return
	end

	local v6 = (settings.State == p or not p) and "None" or p
	module.Signal:Fire("General", "Stars", "SetSetting", name, "State", v6, flag2)
end

local v6 = {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = starSetting:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Rarity.Text = self.Info.Rarity
		self.Instance.Main.Rarity.UIGradient:SetAttribute("Rarity", self.Info.Rarity)
		self.Instance.Main.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(1, module.Utils.Colors:GetRarityColor(self.Info.Rarity))
		})
		module.Button:Create(self.Instance.Main.Dropdown.Main, "Small"):BindFunction("Click", function()
			if v5 then
				ApplyOption(self.Name, false, v5)
			else
				module.Dropdown:Open({
					Holder = self.Instance.Main.Dropdown,
					Options = module.Shared.StarSettings.AvailableOptions,
					Callback = function(p: string)
						ApplyOption(self.Name, false, p)
					end,
					Monitor = function(p: string)
						if p == "Announce" then
							return module.Shared.StarSettings.GetSettings(self.Name, false, module.Data).Announce == true
						end

						return module.Shared.StarSettings.GetSettings(self.Name, false, module.Data).State == p
					end
				})
			end
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self.ShinyInstance = starSetting:Clone()
		self.ShinyInstance.Name = self.ShinyName
		self.ShinyInstance.Main.Title.TextColor3 = color2
		self.ShinyInstance.Main.Rarity.Text = self.Info.Rarity
		self.ShinyInstance.Main.Rarity.UIGradient:SetAttribute("Rarity", self.Info.Rarity)
		self.ShinyInstance.Main.UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color),
			ColorSequenceKeypoint.new(1, module.Utils.Colors:GetRarityColor(self.Info.Rarity))
		})
		module.Button:Create(self.ShinyInstance.Main.Dropdown.Main, "Small"):BindFunction("Click", function()
			if v5 then
				ApplyOption(self.Name, true, v5)
			else
				module.Dropdown:Open({
					Holder = self.ShinyInstance.Main.Dropdown,
					Options = module.Shared.StarSettings.AvailableOptions,
					Callback = function(p: string)
						ApplyOption(self.Name, true, p)
					end,
					Monitor = function(p: string)
						if p == "Announce" then
							return module.Shared.StarSettings.GetSettings(self.Name, true, module.Data).Announce == true
						end

						return module.Shared.StarSettings.GetSettings(self.Name, true, module.Data).State == p
					end
				})
			end
		end)
		self.ShinyInstance.Parent = scroll
		self.ShinyInstance.Visible = true
		self:Hydrate(self.ShinyInstance.Main)({
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
		local text = v5 and "Apply" or "Open"
		self.Instance.Main.Dropdown.Main.Title.Text = text
		self.ShinyInstance.Main.Dropdown.Main.Title.Text = text
		local v8 = module.Shared.Index.GetAmount("Fighter", self.Name, module.Data) > 0
		local settings = module.Shared.StarSettings.GetSettings(self.Name, false, module.Data)
		local announce = settings.Announce == true
		local state = settings.State
		self.Instance.Main.Title.Text = v8 ~= true and "???" or self.Name or "???"
		self.Instance.Main.List.Announce.Visible = announce
		self.Instance.Main.List.AutoSell.Visible = state == "Auto Sell"
		self.Instance.Main.List.AutoLock.Visible = state == "Auto Lock"
		self.Instance.Main.List.AutoDeconstruct.Visible = state == "Auto Deconstruct"
		local v9 = module.Shared.Index.GetAmount("Fighter", self.Name, module.Data) > 0
		local settings2 = module.Shared.StarSettings.GetSettings(self.Name, true, module.Data)
		local announce2 = settings2.Announce == true
		local state2 = settings2.State
		self.ShinyInstance.Main.Title.Text = v9 ~= true and "??? Shiny" or self.ShinyName or "??? Shiny"
		self.ShinyInstance.Main.List.Announce.Visible = announce2
		self.ShinyInstance.Main.List.AutoSell.Visible = state2 == "Auto Sell"
		self.ShinyInstance.Main.List.AutoLock.Visible = state2 == "Auto Lock"
		self.ShinyInstance.Main.List.AutoDeconstruct.Visible = state2 == "Auto Deconstruct"
	end
}
local scope = fusion.scoped(fusion, v6)

function StarSettings.SelectOption(p: string)
	if not flag then
		return
	end

	if v5 == p or not p then
		p = nil
	end

	v5 = p
	module.Dropdown:Close()

	for k, v7 in v4 do
		v7.Transparency:set(k == v5 and 0 or 0.3)
	end

	StarSettings.UpdateAll()
end

function StarSettings.PlayButtonsEntrance()
	for k, v7 in v do
		local v8 = v4[v7.Name]

		if v8.Entrance then
			task.cancel(v8.Entrance)
			v8.Entrance = nil
		end

		v8.Size:set(UDim2.fromScale(0, 0))
		v8.SizeSpring:setPosition(UDim2.fromScale(0, 0))
		v8.SizeSpring:setVelocity(UDim2.fromScale(0, 0))
		v8.Entrance = task.delay((k - 1) * 0.05, function()
			v8.Entrance = nil

			if not flag then
				return
			end

			v8.Size:set(UDim2.fromScale(1, 1))
		end)
	end
end

function StarSettings.Clear()
	module.Dropdown:Close()

	for _, v7 in v3 do
		v7.Instance:Destroy()
		v7.ShinyInstance:Destroy()
		v7:doCleanup()
	end

	table.clear(v3)
end

function StarSettings.Generate()
	module.Dropdown:Close()
	local current = starSettings:GetAttribute("Current")

	if not current then
		return
	end

	local v7 = module.Shared.Stars.List[current]

	if not v7 then
		return
	end

	for k, v8 in v3 do
		local v9 = false

		for _, v11 in v7.List do
			if v11.Name ~= k then
				continue
			end

			v9 = true
			break
		end

		if v9 then
			continue
		end

		v8.Instance:Destroy()
		v8.ShinyInstance:Destroy()
		v8:doCleanup()
		v3[k] = nil
	end

	for _, v8 in v7.List do
		if v3[v8.Name] then
			continue
		end

		local info = module.Shared.Fighters.List[v8.Name]

		if not info then
			continue
		end

		local rarity = module.Utils.Order:Rarity(info.Rarity)
		local layoutOrder = rarity ^ 2
		local innerScope = scope:innerScope()
		innerScope.Name = v8.Name
		innerScope.ShinyName = v8.Name .. " Shiny"
		innerScope.Info = info

		if innerScope:Build(0.1 * (rarity - 1)) then
			innerScope.Instance.LayoutOrder = layoutOrder
			innerScope.ShinyInstance.LayoutOrder = layoutOrder + 1
			v3[v8.Name] = innerScope
		else
			innerScope:doCleanup()
		end
	end
end

function StarSettings.UpdateAll()
	module.Dropdown:Update()

	for _, v7 in v3 do
		v7:Update()
	end
end

function StarSettings.Stop()
	flag = false
	v5 = nil
	local v7 = module.Libs.NeoHover.GetByIdentifier("Tooltip")

	for _, v8 in v4 do
		if v8.Entrance then
			task.cancel(v8.Entrance)
			v8.Entrance = nil
		end

		v8.Transparency:set(0.65)

		if v7 then
			v7:Close(v8.Instance)
		end
	end

	for _, connection in v2 do
		connection:Disconnect()
	end

	table.clear(v2)
	StarSettings.Clear()
end

function StarSettings.Start()
	if flag then
		return
	end

	flag = true
	v2.Stars = module:OnDataChanged({ "Stars" }, StarSettings.UpdateAll)
	v2.Current = starSettings:GetAttributeChangedSignal("Current"):Connect(StarSettings.Generate)
	StarSettings.Generate()
	StarSettings.PlayButtonsEntrance()
end

function StarSettings.Init()
	StarSettings.SetupButtons()
	module.Frame:OnFrameClosed(starSettings, StarSettings.Stop)
	module.Frame:OnFrameOpened(starSettings, StarSettings.Start)
end

function StarSettings.SetupButtons()
	for _, v7 in v do
		if v4[v7.Name] then
			continue
		end

		local child = buttons:WaitForChild(v7.Button)
		local button = child:WaitForChild("Button")
		button.AnchorPoint = Vector2.new(0.5, 0.5)
		button.Position = UDim2.fromScale(0.5, 0.5)
		local v8 = module.Button:Create(button, "Small")
		local scope2 = v8.Scope
		local size = scope2:Value(UDim2.fromScale(0, 0))
		local spring = scope2:Spring(size, 10, 1)
		local transparency = scope2:Value(0.65)
		local spring2 = scope2:Spring(transparency, 10, 1)
		scope2:Hydrate(button)({
			Size = spring
		})
		scope2:Hydrate(child)({
			GroupTransparency = spring2
		})
		v4[v7.Name] = {
			Instance = button,
			Size = size,
			SizeSpring = spring,
			Transparency = transparency
		}
		local v9 = v7
		table.insert(scope2, function()
			local v10 = v4[v9.Name]

			if v10 and v10.Entrance then
				task.cancel(v10.Entrance)
			end

			v4[v9.Name] = nil
		end)
		local v10 = v7
		v8:BindFunction("Click", function()
			StarSettings.SelectOption(v10.Name)
		end)
		local v12 = v7
		v8:BindOnEnter("Hover", function()
			if not flag then
				return
			end

			local v13 = module.Libs.NeoHover.GetByIdentifier("Tooltip")

			if not v13 then
				return
			end

			v13:Open(button, {
				Text = v12.Tip
			})
		end)
		local instance = button
		v8:BindOnLeave("Hover", function()
			local v14 = module.Libs.NeoHover.GetByIdentifier("Tooltip")

			if not v14 then
				return
			end

			v14:Close(instance)
		end)
	end
end

return StarSettings