local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local Keybinds = require(script.Parent.HUD.Keybinds)
local settings = module.Interface:WaitForChild("Frames"):WaitForChild("Settings")
local scroll = settings:WaitForChild("CategoryList"):WaitForChild("Scroll")
settings:WaitForChild("SettingsList"):WaitForChild("Scroll")
local settings2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Settings")
local v = {}
local v2 = {}
local v3 = {}
local innerScopesByName = {}
local v4 = {}
local v5 = "All"
local Settings = {}
local v6 = {
	Build = function(self, duration: number)
		self.Transparency = self:Value(0)
		self.TransparencySpring = self:Spring(self.Transparency, 10, 1)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = settings2.Category:Clone()
		self.Instance.Name = self.Category
		self.Instance.Main.Icon.Image = self.Info.Icon
		self.Instance.Main.Title.Text = self.Category
		self.Instance.Main.Desc.Text = self.Info.Description
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			Settings.SetCategory(self.Category)
		end)
		table.insert(self, self.Instance.Main.Activated:Connect(function(p)
			if p and p.UserInputType.Name:match("^Gamepad") then
				Settings.SetCategory(self.Category)
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
		self.Transparency:set(v5 == self.Category and 0 or 0.65)
	end
}
local scope = fusion.scoped(fusion, v6)

function Settings.Clear()
	for _, v7 in v3 do
		v7.Instance:Destroy()
		v7:doCleanup()
	end

	for _, v7 in innerScopesByName do
		v7.Instance:Destroy()
		v7:doCleanup()
	end

	for _, v7 in v4 do
		v7.Instance:Destroy()
		v7:doCleanup()
	end

	table.clear(v3)
	table.clear(innerScopesByName)
	table.clear(v4)
end

function Settings.Generate()
	local device = Keybinds.GetDevice()
	local total = 0
	local total2 = 0
	local total3 = 0

	if device == "Mobile" then
		if v5 == "Keybinds" then
			v5 = "All"
		end

		local keybinds = innerScopesByName.Keybinds

		if keybinds then
			keybinds.Instance:Destroy()
			keybinds:doCleanup()
			innerScopesByName.Keybinds = nil
		end
	end

	for _, category in module.Shared.Settings.Categories do
		if not (category.Name ~= "Keybinds" or device ~= "Mobile") or innerScopesByName[category.Name] then
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

	local categorySettings = module.Shared.Settings.GetCategorySettings(v5, device)

	for k, v7 in v3 do
		local v8 = false

		for _, categorySetting in categorySettings do
			if categorySetting.Name ~= k then
				continue
			end

			v8 = true
			break
		end

		if v8 then
			continue
		end

		v7.Instance:Destroy()
		v7:doCleanup()
		v3[k] = nil
	end

	for k, v7 in v4 do
		local v8 = nil

		for _, categorySetting in categorySettings do
			if not categorySetting.List[k] then
				continue
			end

			v8 = true
			break
		end

		if v8 then
			continue
		end

		v7.Instance:Destroy()
		v7:doCleanup()
		v4[k] = nil
	end

	for _, categorySetting in ipairs(categorySettings) do
		local index = 0
		local v7 = 0
		local divider = v2.Divider
		local v8 = v3[categorySetting.Name]

		if divider and not v8 then
			local innerScope = divider:innerScope()
			innerScope.Name = categorySetting.Name

			if innerScope:Build(total2) then
				innerScope.Instance.LayoutOrder = total3
				v3[categorySetting.Name] = innerScope
				total2 += 0.05
			else
				innerScope:doCleanup()
			end
		elseif v8 then
			v8.Instance.LayoutOrder = total3
		end

		for k, info in categorySetting.List do
			if index < info.Index then
				index = info.Index
			end

			local v10 = v4[k]

			if v10 then
				v10.Instance.LayoutOrder = total3 + info.Index
			else
				local outerScope = v2[info.Type]

				if outerScope then
					local v11 = info.Index * 0.05

					if v7 < v11 then
						v7 = v11
					end

					local innerScope = outerScope:innerScope()
					innerScope.Name = k
					innerScope.Info = info

					if innerScope:Build(total2 + v11) then
						innerScope.Instance.LayoutOrder = total3 + info.Index
						v4[k] = innerScope
					else
						innerScope:doCleanup()
					end
				end
			end
		end

		total2 += v7
		total3 += index + 1
	end
end

function Settings.UpdateAll()
	for _, v7 in innerScopesByName do
		v7:Update()
	end

	for _, v7 in v4 do
		v7:Update()
	end
end

function Settings.SetCategory(p: string)
	Keybinds.Cancel()

	if v5 == p then
		v5 = nil
	else
		v5 = p
	end

	Settings.Generate()
	Settings.UpdateAll()
end

function Settings.Stop()
	Keybinds.Cancel()

	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
	Settings.Clear()
end

function Settings.Start()
	Settings.Stop()
	v.Settings = module:OnDataChanged({ "Settings" }, Settings.UpdateAll)
	v.Keybinds = Keybinds.Changed:Connect(Settings.UpdateAll)
	v.Device = Keybinds.DeviceChanged:Connect(function()
		Settings.Generate()
		Settings.UpdateAll()
	end)
	Settings.Generate()
end

function Settings.Init()
	module.Frame:OnFrameClosed(settings, Settings.Stop)
	module.Frame:OnFrameOpened(settings, Settings.Start)

	for _, moduleScript in script:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local v7 = v2
		local name = moduleScript.Name
		local module2 = require(moduleScript)
		v7[name] = module2
	end
end

return Settings