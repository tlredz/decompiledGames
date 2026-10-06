local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local guilds = module.Interface:WaitForChild("Frames"):WaitForChild("Guilds")
local scroll = guilds:WaitForChild("Categories"):WaitForChild("Scroll")
local main = guilds:WaitForChild("Main")
local back = guilds:WaitForChild("Back")
local category = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Guilds"):WaitForChild("Category")
local v = {
	"Home",
	"Members",
	"Vault",
	"Invites",
	"Leaderboards"
}
local v2 = { "Create", "Invites", "Leaderboards" }
local v3 = {
	Home = "Overview and announcements",
	Members = "View and manage members",
	Vault = "Donate Yen and buy upgrades",
	Invites = "Manage guild invites",
	Leaderboards = "Top guilds worldwide",
	Create = "Create your own guild",
	Edit = "Edit icon and description"
}
local innerScopesByAvailableTab = {}
local Controller = {
	ViewingGuildId = nil,
	ViewingGuildData = nil,
	CurrentTab = nil,
	TabChanged = module.Libs.GoodSignal.new(),
	GuildDataChanged = module.Libs.GoodSignal.new()
}
local scope = fusion.scoped(fusion, {
	Build = function(self, p: string, layoutOrder: number, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.SelectionTransparency = self:Value(0.5)
		self.SelectionTransparencySpring = self:Spring(self.SelectionTransparency, 10, 1)
		self.Instance = category:Clone()
		self.Instance.Name = p
		self.Instance.Main.Title.Text = p
		self.Instance.Main.Desc.Text = v3[p] or ""
		self.Instance.LayoutOrder = layoutOrder
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			Controller.SetTab(p)
		end)
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring,
			ImageTransparency = self.SelectionTransparencySpring
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

		return true
	end
})

function Controller.GetMyGuildId()
	return module.Data.Guild.GuildId
end

function Controller.IsViewingOwnGuild()
	local myGuildId = Controller.GetMyGuildId()
	return myGuildId ~= nil and myGuildId == Controller.ViewingGuildId
end

function Controller.CanEditGuild()
	if not Controller.IsViewingOwnGuild() then
		return false
	end

	local permissions = module.Shared.Guilds.GetPermissions(module.Data.Guild.Rank)
	return permissions ~= nil and permissions.Edit == true
end

function Controller.GetAvailableTabs()
	if not Controller.ViewingGuildId then
		return v2
	end

	if not Controller.CanEditGuild() then
		return v
	end

	local clone = table.clone(v)
	table.insert(clone, "Edit")
	return clone
end

function Controller.RefreshCategories()
	for _, v4 in innerScopesByAvailableTab do
		v4.Instance:Destroy()
		v4:doCleanup()
	end

	table.clear(innerScopesByAvailableTab)
	local availableTabs = Controller.GetAvailableTabs()
	local total = 0

	for k, availableTab in availableTabs do
		local innerScope = scope:innerScope()

		if innerScope:Build(availableTab, k, total) then
			innerScopesByAvailableTab[availableTab] = innerScope
		else
			innerScope:doCleanup()
		end

		total += 0.05
	end

	Controller.RefreshCategorySelection()
end

function Controller.RefreshCategorySelection()
	for k, v4 in innerScopesByAvailableTab do
		local enabled = k == Controller.CurrentTab
		local uIGradient = v4.Instance.Main:FindFirstChildWhichIsA("UIGradient")

		if uIGradient then
			uIGradient.Enabled = enabled
		end

		v4.SelectionTransparency:set(enabled and 0 or 0.5)
	end
end

function Controller.SetTab(currentTab: string)
	local availableTabs = Controller.GetAvailableTabs()

	if not table.find(availableTabs, currentTab) then
		currentTab = availableTabs[1]
	end

	if Controller.CurrentTab == currentTab then
		return
	end

	Controller.CurrentTab = currentTab

	for _, guiObject in main:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = guiObject.Name == currentTab
		end
	end

	Controller.RefreshCategorySelection()
	Controller.TabChanged:Fire(currentTab)
end

function Controller.RequestGuildData(p: string)
	local viewingGuildData = module.Signal:Invoke("General", "Guilds", "GetGuildData", p)

	if not viewingGuildData then
		return nil
	end

	if p == Controller.ViewingGuildId then
		Controller.ViewingGuildData = viewingGuildData
		Controller.GuildDataChanged:Fire(viewingGuildData)
	end

	return viewingGuildData
end

function Controller.SetViewingGuild(viewingGuildId: string?, flag: boolean?)
	if Controller.ViewingGuildId == viewingGuildId and Controller.CurrentTab ~= nil and not flag then
		return
	end

	Controller.ViewingGuildId = viewingGuildId
	Controller.ViewingGuildData = nil
	back.Visible = viewingGuildId ~= nil and viewingGuildId ~= Controller.GetMyGuildId()
	Controller.RefreshCategories()
	Controller.SetTab("Home")

	if viewingGuildId then
		task.spawn(Controller.RequestGuildData, viewingGuildId)
	end
end

function Controller.ReturnToMyGuild()
	Controller.SetViewingGuild(Controller.GetMyGuildId())
end

module.Frame:OnFrameOpened(guilds, function()
	Controller.SetViewingGuild(Controller.GetMyGuildId())
end)
module.Frame:OnFrameClosed(guilds, function()
	Controller.CurrentTab = nil
end)
module.Button:Create(back.Main, "Small"):BindFunction("Click", function()
	Controller.ReturnToMyGuild()
end)
module:OnDataChanged({ "Guild", "GuildId" }, function(p, p2)
	if not module.Frame:IsFrameOpened(guilds) or Controller.ViewingGuildId ~= nil and Controller.ViewingGuildId ~= p2 and Controller.ViewingGuildId ~= p then
		return
	end

	Controller.SetViewingGuild(p, true)
end)
module:OnDataChanged({ "Guild", "Rank" }, function()
	if not (module.Frame:IsFrameOpened(guilds) and Controller.IsViewingOwnGuild() and innerScopesByAvailableTab.Edit ~= nil ~= Controller.CanEditGuild()) then
		return
	end

	Controller.RefreshCategories()

	if Controller.CurrentTab == "Edit" and not Controller.CanEditGuild() then
		Controller.SetTab("Home")
	end
end)

function Controller.OnServerSync(p: string)
	if not (p == Controller.ViewingGuildId and module.Frame:IsFrameOpened(guilds)) then
		return
	end

	task.spawn(Controller.RequestGuildData, p)
end

return Controller