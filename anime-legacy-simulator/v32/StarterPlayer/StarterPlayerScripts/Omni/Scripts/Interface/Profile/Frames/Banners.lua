local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
require(script.Parent.Parent.Controller)
local banners = module.Interface:WaitForChild("Frames"):WaitForChild("Banners")
local scroll = banners:WaitForChild("List"):WaitForChild("Scroll")
local profile = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Profile")
local v = {}
local innerScopes = {}
local Banners = {}

local function IsBannerChange(_, _, list)
	local v2 = list[1]
	return v2 == nil or v2 == "Banner" or v2 == "Banners"
end

local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.75, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = profile.Banner:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Image = self.Info.Icon
		self.Instance.Main.Header.Title.Text = self.Name
		self.Instance.Main.Header.Desc.Text = self.Info.Description
		module.Button:Create(self.Instance.Main.Equip.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Profile", "SetBanner", self.Name)
		end)
		module.Button:Create(self.Instance.Main.Unequip.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Profile", "SetBanner", self.Name)
		end)
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

				self.Position:set(UDim2.fromScale(0.5, 0.5))
			end)
		else
			self.Position:set(UDim2.fromScale(0.5, 0.5))
		end

		self:Update()
		return true
	end,
	Update = function(self)
		local banner = module.Data.Profile.Banner
		local visible = self.Name == banner
		local v3 = module.Data.Profile.Banners[self.Name] ~= nil
		self.Instance.Main.Unequip.Visible = visible
		self.Instance.Main.LockedFrame.Visible = not v3
		self.Instance.Main.Equip.Visible = v3 and not visible
	end
})

function Banners.UpdateAll()
	local v2 = {}
	local v3 = {}

	for k in module.Shared.ProfileBanners.List do
		table.insert(v2, k)
	end

	table.sort(v2)

	for k, v4 in v2 do
		v3[v4] = k
	end

	for k, info in module.Shared.ProfileBanners.List do
		local v5 = innerScopes[k]

		if v5 then
			v5:Update()
		else
			local innerScope = scope:innerScope()
			innerScope.Name = k
			innerScope.Info = info
			innerScope.Index = v3[k] or 0

			if innerScope:Build(0.05 * innerScope.Index) then
				innerScopes[k] = innerScope
			else
				innerScope:doCleanup()
			end
		end
	end
end

function Banners.Start()
	v.DataChanged = module:OnDataChangedDeferred({ "Profile" }, Banners.UpdateAll, IsBannerChange)
	Banners.UpdateAll()
end

function Banners.Stop()
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

function Banners.Init()
	module.Frame:OnFrameClosed(banners, Banners.Stop)
	module.Frame:OnFrameOpened(banners, Banners.Start)
end

return Banners