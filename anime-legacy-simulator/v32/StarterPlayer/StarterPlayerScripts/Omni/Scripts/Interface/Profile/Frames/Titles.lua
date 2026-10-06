local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
require(script.Parent.Parent.Controller)
local titles = module.Interface:WaitForChild("Frames"):WaitForChild("Titles")
local scroll = titles:WaitForChild("List"):WaitForChild("Scroll")
local titles2 = module.Assets:WaitForChild("Interface"):WaitForChild("Titles")
local profile = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Profile")
local v = {}
local innerScopes = {}
local Titles = {}

local function IsTitleChange(_, _, list)
	local v2 = list[1]
	return v2 == nil or v2 == "Title" or v2 == "Titles"
end

local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.75, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = profile.Title:Clone()
		self.Instance.Name = self.Name
		self.Instance.LayoutOrder = self.Index
		self.Instance.Main.Header.Desc.Text = self.Info.Description
		module.Button:Create(self.Instance.Main.Equip.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Profile", "SetTitle", self.Name)
		end)
		module.Button:Create(self.Instance.Main.Unequip.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Profile", "SetTitle", self.Name)
		end)
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		local clone = titles2:FindFirstChild(self.Name) and titles2:FindFirstChild(self.Name):Clone()

		if clone then
			clone.Parent = self.Instance.Main.Header.Title
		end

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
		local title = module.Data.Profile.Title
		local visible = self.Name == title
		local v3 = module.Data.Profile.Titles[self.Name] ~= nil
		self.Instance.LayoutOrder = self.Index
		self.Instance.Main.Unequip.Visible = visible
		self.Instance.Main.LockedFrame.Visible = not v3
		self.Instance.Main.Equip.Visible = v3 and not visible
	end
})

function Titles.UpdateAll()
	local v2 = {}

	for k in module.Shared.ProfileTitles.List do
		table.insert(v2, k)
	end

	table.sort(v2, function(a, b)
		local index = module.Shared.ProfileTitles.List[a].Index or 1e999
		local index2 = module.Shared.ProfileTitles.List[b].Index or 1e999

		if index == index2 then
			return a < b
		end

		return index < index2
	end)

	for k, name in v2 do
		local info = module.Shared.ProfileTitles.List[name]
		local v5 = innerScopes[name]

		if v5 then
			v5.Index = k
			v5:Update()
		else
			local innerScope = scope:innerScope()
			innerScope.Name = name
			innerScope.Info = info
			innerScope.Index = k

			if innerScope:Build(0.05 * innerScope.Index) then
				innerScopes[name] = innerScope
			else
				innerScope:doCleanup()
			end
		end
	end
end

function Titles.Start()
	v.DataChanged = module:OnDataChangedDeferred({ "Profile" }, Titles.UpdateAll, IsTitleChange)
	Titles.UpdateAll()
end

function Titles.Stop()
	for _, v2 in innerScopes do
		v2.Instance:Destroy()
		v2:doCleanup()
	end

	table.clear(innerScopes)

	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
end

function Titles.Init()
	module.Frame:OnFrameClosed(titles, Titles.Stop)
	module.Frame:OnFrameOpened(titles, Titles.Start)
end

return Titles