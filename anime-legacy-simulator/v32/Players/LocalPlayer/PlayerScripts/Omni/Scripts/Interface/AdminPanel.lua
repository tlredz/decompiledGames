local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local adminPanel = module.Shared.AdminPanel
local adminPanel2 = module.Interface:WaitForChild("Frames"):WaitForChild("AdminPanel")
local scroll = adminPanel2:WaitForChild("CategoryList"):WaitForChild("Scroll")
local scroll2 = adminPanel2:WaitForChild("MetricsList"):WaitForChild("Scroll")
local adminPanel3 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("AdminPanel")
local main = adminPanel3:WaitForChild("Metric"):WaitForChild("Main")
local position = main:WaitForChild("Day").Position
local position2 = main:WaitForChild("DayTitle").Position
local uDim = UDim2.new(main:WaitForChild("Week").Position.X, position.Y)
local uDim2 = UDim2.new(main:WaitForChild("WeekTitle").Position.X, position2.Y)
local innerScopesByName = {}
local v = {}
local name = adminPanel.Categories[1].Name
local v2 = nil
local v3 = false
local count = 0
local thread = nil
local AdminPanel = {}

local function Reveal(p, duration: number)
	if duration > 0 then
		task.delay(duration, function()
			if not next(p) then
				return
			end

			p.Position:set(UDim2.fromScale(0.5, 0.5))
		end)
	else
		p.Position:set(UDim2.fromScale(0.5, 0.5))
	end
end

local v4 = {
	Build = function(self, p: number)
		self.Transparency = self:Value(0)
		self.TransparencySpring = self:Spring(self.Transparency, 10, 1)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = adminPanel3.Category:Clone()
		self.Instance.Name = self.Category
		self.Instance.Main.Icon.Image = self.Info.Icon
		self.Instance.Main.Title.Text = self.Category
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			AdminPanel.SetCategory(self.Category)
		end)
		table.insert(self, self.Instance.Main.Activated:Connect(function(p2)
			if p2 and p2.UserInputType.Name:match("^Gamepad") then
				AdminPanel.SetCategory(self.Category)
			end
		end))
		self.Instance.LayoutOrder = self.Info.Index
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance)({
			GroupTransparency = self.TransparencySpring
		})
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		Reveal(self, p)
		self:Update()
		return true
	end,
	Update = function(self)
		self.Transparency:set(name == self.Category and 0 or 0.65)
		self.Instance.Main.Desc.Text = adminPanel.FormatStatus(v2, os.time())
	end
}
local scope = fusion.scoped(fusion, v4)
local scope2 = fusion.scoped(fusion, {
	Build = function(self, p: number)
		local child = adminPanel3:FindFirstChild(self.Row.Kind)

		if not child then
			return false
		end

		self.Position = self:Value(UDim2.fromScale(1.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = child:Clone()
		self.Instance.Name = self.Row.Key
		self.Instance.Parent = scroll2
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Update(self.Row)
		Reveal(self, p)
		return true
	end,
	Update = function(self, row)
		self.Row = row
		local main2 = self.Instance.Main
		main2.Title.Text = row.Title

		if row.Kind ~= "Metric" then
			return
		end

		local visible = row.Week ~= nil
		main2.Desc.Text = row.Desc
		main2.Day.Text = row.Value
		local day = main2.Day
		local position3

		if visible then
			position3 = position
		else
			position3 = uDim
		end

		day.Position = position3
		main2.DayTitle.Text = visible and "Day" or row.Label or "Now"
		local dayTitle = main2.DayTitle
		local position4

		if visible then
			position4 = position2
		else
			position4 = uDim2
		end

		dayTitle.Position = position4
		main2.Week.Visible = visible
		main2.Week.Text = row.Week or ""
		main2.WeekTitle.Visible = visible
	end
})

function AdminPanel.ClearRows()
	for _, v5 in v do
		v5.Instance:Destroy()
		v5:doCleanup()
	end

	table.clear(v)
end

function AdminPanel.Clear()
	AdminPanel.ClearRows()

	for _, v5 in innerScopesByName do
		v5.Instance:Destroy()
		v5:doCleanup()
	end

	table.clear(innerScopesByName)
end

function AdminPanel.GenerateCategories()
	local total = 0

	for _, category in adminPanel.Categories do
		if innerScopesByName[category.Name] then
			continue
		end

		local innerScope = scope:innerScope()
		innerScope.Category = category.Name
		innerScope.Info = category

		if innerScope:Build(total) then
			innerScopesByName[category.Name] = innerScope
			total += 0.05
		else
			innerScope:doCleanup()
		end
	end
end

function AdminPanel.UpdateCategories()
	for _, v5 in innerScopesByName do
		v5:Update()
	end
end

function AdminPanel.GenerateRows()
	local v5 = (not v2 or v2.Category ~= name) and {} or v2.Rows
	local v6 = {}
	local total = 0

	for _, v7 in v5 do
		v6[v7.Key] = true
	end

	for k, v7 in v do
		if v6[k] then
			continue
		end

		v7.Instance:Destroy()
		v7:doCleanup()
		v[k] = nil
	end

	for k, row in v5 do
		local v8 = v[row.Key]

		if v8 then
			v8:Update(row)
			v8.Instance.LayoutOrder = k
		else
			local innerScope = scope2:innerScope()
			innerScope.Row = row

			if innerScope:Build(total) then
				innerScope.Instance.LayoutOrder = k
				v[row.Key] = innerScope
				total += 0.05
			else
				innerScope:doCleanup()
			end
		end
	end
end

function AdminPanel.SetCategory(p: string)
	if name == p then
		return
	end

	name = p
	AdminPanel.ClearRows()
	AdminPanel.GenerateRows()
	AdminPanel.UpdateCategories()
	local v5 = count
	task.spawn(function()
		if AdminPanel.Fetch(v5) or not v3 or count ~= v5 or name ~= p then
			return
		end

		task.wait(adminPanel.RequestCooldown + 0.1)

		if not v3 or count ~= v5 or name ~= p then
			return
		end

		AdminPanel.Fetch(v5)
	end)
end

function AdminPanel.Fetch(p: number)
	local v5 = name
	local v6 = module.Signal:Invoke("General", "AdminPanel", "Get", v5)

	if not v3 or count ~= p or (typeof(v6) ~= "table" or typeof(v6.Rows) ~= "table") then
		return false
	end

	if v6.Category ~= name then
		return false
	end

	v2 = v6
	AdminPanel.GenerateRows()
	AdminPanel.UpdateCategories()
	return true
end

function AdminPanel.Stop()
	v3 = false
	count += 1

	if thread then
		task.cancel(thread)
		thread = nil
	end

	AdminPanel.Clear()
end

function AdminPanel.Setup()
	AdminPanel.Stop()
	v3 = true
	local v5 = count
	AdminPanel.GenerateCategories()
	AdminPanel.GenerateRows()
	task.spawn(function()
		while v3 and count == v5 do
			local fetched = AdminPanel.Fetch(v5)
			local v6

			if fetched then
				v6 = adminPanel.PollInterval
			else
				v6 = adminPanel.RequestCooldown + 0.1
			end

			task.wait(v6)
		end
	end)
	thread = task.spawn(function()
		while v3 and count == v5 do
			task.wait(1)

			if not v3 or count ~= v5 then
				break
			end

			AdminPanel.UpdateCategories()
		end
	end)
end

function AdminPanel.Start()
	if module.Frame:IsFrameOpened(adminPanel2) then
		return
	end

	module.Frame:Open(adminPanel2)
end

function AdminPanel.Init()
	module.Frame:OnFrameClosed(adminPanel2, AdminPanel.Stop)
	module.Frame:OnFrameOpened(adminPanel2, AdminPanel.Setup)
end

return AdminPanel