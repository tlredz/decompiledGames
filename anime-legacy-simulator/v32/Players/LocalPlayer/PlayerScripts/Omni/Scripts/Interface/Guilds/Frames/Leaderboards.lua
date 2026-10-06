local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local Controller = require(script.Parent.Parent.Controller)
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(135, 144, 153)
local guilds = module.Interface:WaitForChild("Frames"):WaitForChild("Guilds")
local leaderboards = guilds:WaitForChild("Main"):WaitForChild("Leaderboards")
local buttons = leaderboards:WaitForChild("Buttons")
local scroll = leaderboards:WaitForChild("List"):WaitForChild("Scroll")
local leaderboards2 = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Guilds"):WaitForChild("Leaderboards")
local leaderboard = leaderboards2:WaitForChild("Leaderboard")
local guild = leaderboards2:WaitForChild("Guild")
local v = module.Libs.DataContainerClient.New("GuildLeaderboards")
local clones = {}
local v2 = {}
local v3 = nil
local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = guild:Clone()
		self.Instance.Name = tostring(self.Info.UserId)
		self:Update()
		local userId = self.Info.UserId
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			module.Frame:Open("Guilds")
			Controller.SetViewingGuild(userId)
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

		return true
	end,
	Update = function(self)
		self.Instance.LayoutOrder = self.Index
		self.Instance.Main.Title.Text = self.Info.UserName
		self.Instance.Main.Desc.Text = self.Info.Description or ""
		self.Instance.Main.Rank.Text = `#{self.Index}`
		self.Instance.Main.Amount.Text = module.Utils.Number:Format(self.Info.Value)
		self.Instance.Main.Icon.Main.Image = self.Info.Icon or ""
	end
})
local Leaderboards = {
	ClearEntries = function()
		for _, v4 in v2 do
			v4.Instance:Destroy()
			v4:doCleanup()
		end

		table.clear(v2)
	end,
	RefreshButtons = function()
		for k, v4 in clones do
			local enabled = k == v3
			local uIGradient = v4.Main:FindFirstChildWhichIsA("UIGradient")

			if uIGradient then
				uIGradient.Enabled = enabled
			end

			v4.Main.ImageColor3 = enabled and color or color2
		end
	end
}

function Leaderboards.SetLeaderboard(p: string)
	if v3 == p then
		return
	end

	v3 = p
	Leaderboards.RefreshButtons()
	Leaderboards.ClearEntries()
	Leaderboards.LoadEntries()
end

function Leaderboards.LoadEntries()
	if not v3 then
		Leaderboards.ClearEntries()
		return
	end

	local v4 = {}
	local total = 0

	for k, info in v:GetValue({ v3, "Global" }) or {} do
		local userId = info.UserId

		if userId == nil then
			continue
		end

		v4[userId] = true
		local v6 = v2[userId]

		if v6 then
			v6.Info = info
			v6.Index = k
			v6:Update()
		else
			local innerScope = scope:innerScope()
			innerScope.Info = info
			innerScope.Index = k

			if innerScope:Build(total) then
				v2[userId] = innerScope
			else
				innerScope:doCleanup()
			end

			total += 0.05
		end
	end

	for k, v5 in v2 do
		if v4[k] then
			continue
		end

		v5.Instance:Destroy()
		v5:doCleanup()
		v2[k] = nil
	end
end

function Leaderboards.CreateButtons()
	if next(clones) then
		return
	end

	local count = 0

	for k in module.Shared.Guilds.Leaderboards do
		count += 1
		local clone = leaderboard:Clone()
		clone.Name = k
		clone.Main.Title.Text = k
		clone.LayoutOrder = count
		clone.Parent = buttons
		clone.Visible = true
		local v4 = k
		module.Button:Create(clone.Main, "Small"):BindFunction("Click", function()
			Leaderboards.SetLeaderboard(v4)
		end)
		clones[k] = clone
	end

	local v4 = next(module.Shared.Guilds.Leaderboards)

	if v4 then
		Leaderboards.SetLeaderboard(v4)
	end
end

function Leaderboards.Init()
	local uIListLayout = scroll:WaitForChild("UIListLayout")
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	v:OnChange({}, function(_, _, list)
		if not (Controller.CurrentTab == "Leaderboards" and v3) then
			return
		end

		local v4 = list and list[1]

		if v4 ~= nil and v4 ~= v3 then
			return
		end

		Leaderboards.LoadEntries()
	end)
	Controller.TabChanged:Connect(function(p)
		if p ~= "Leaderboards" then
			Leaderboards.ClearEntries()
			return
		end

		local v4 = next(clones) ~= nil
		Leaderboards.CreateButtons()
		Leaderboards.RefreshButtons()

		if v4 then
			Leaderboards.LoadEntries()
		end
	end)
	module.Frame:OnFrameClosed(guilds, Leaderboards.ClearEntries)
end

return Leaderboards