local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local Controller = require(script.Parent.Parent.Controller)
local guilds = module.Interface:WaitForChild("Frames"):WaitForChild("Guilds")
local invites = guilds:WaitForChild("Main"):WaitForChild("Invites")
local search = invites:WaitForChild("Search")
local scroll = invites:WaitForChild("Main"):WaitForChild("List"):WaitForChild("Scroll")
local invite = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Guilds"):WaitForChild("Invite")
local v = {}
local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = invite:Clone()
		self.Instance.Name = self.Info.GuildId
		self:Update()
		module.Button:Create(self.Instance.Main.Buttons.Accept.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Guilds", "AcceptInvite", self.Info.GuildId)
		end)
		module.Button:Create(self.Instance.Main.Buttons.Decline.Main, "Small"):BindFunction("Click", function()
			module.Signal:Fire("General", "Guilds", "DeclineInvite", self.Info.GuildId)
		end)
		module.Button:Create(self.Instance.Main.Buttons.View.Main, "Small"):BindFunction("Click", function()
			module.Frame:Open("Guilds")
			Controller.SetViewingGuild(self.Info.GuildId)
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
		self.Instance.Main.Title.Text = self.Info.GuildName
		self.Instance.Main.Icon.Main.Image = self.Info.GuildIcon
	end
})
local Invites = {
	Clear = function()
		for _, v2 in v do
			v2.Instance:Destroy()
			v2:doCleanup()
		end

		table.clear(v)
	end,
	Refresh = function()
		if Controller.CurrentTab ~= "Invites" then
			return
		end

		local text = string.lower(search.Text)
		local v2 = {}
		local total = 0

		for k, invite2 in module.Data.Guild.Invites do
			if not (text == "" or string.find(string.lower(invite2.GuildName), text, 1, true)) then
				continue
			end

			v2[invite2.GuildId] = true
			local v3 = v[invite2.GuildId]

			if v3 then
				v3.Info = invite2
				v3.Index = k
				v3:Update()
			else
				local innerScope = scope:innerScope()
				innerScope.Info = invite2
				innerScope.Index = k

				if innerScope:Build(total) then
					v[invite2.GuildId] = innerScope
				else
					innerScope:doCleanup()
				end

				total += 0.05
			end
		end

		for k, v3 in v do
			if v2[k] then
				continue
			end

			v3.Instance:Destroy()
			v3:doCleanup()
			v[k] = nil
		end
	end
}

function Invites.Init()
	module:OnDataChanged({ "Guild", "Invites" }, Invites.Refresh)
	search:GetPropertyChangedSignal("Text"):Connect(Invites.Refresh)
	Controller.TabChanged:Connect(function(p)
		if p == "Invites" then
			Invites.Refresh()
		else
			Invites.Clear()
		end
	end)
	module.Frame:OnFrameClosed(guilds, Invites.Clear)
end

return Invites