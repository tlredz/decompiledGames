local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local Controller = require(script.Parent.Parent.Controller)
local guilds = module.Interface:WaitForChild("Frames"):WaitForChild("Guilds")
local home = guilds:WaitForChild("Main"):WaitForChild("Home")
local header = home:WaitForChild("Header")
local info = header:WaitForChild("Info")
local scroll = home:WaitForChild("Announcements"):WaitForChild("List"):WaitForChild("Scroll")
local buttons = home:WaitForChild("Buttons")
local announcement = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Guilds"):WaitForChild("Announcement")
local v = {}
local scope = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = announcement:Clone()
		self.Instance.Name = tostring(self.Info.Timestamp)
		self.Instance.Main.Icon.Main.Image = self.Info.AuthorIcon or ""
		self.Instance.Main.Info.Owner.Text = (self.Info.AuthorName or "Unknown") .. (not self.Info.AuthorRank and "" or " - " .. self.Info.AuthorRank or "")
		self.Instance.Main.Info.Owner.TextColor3 = module.Shared.Guilds.GetRankColor(self.Info.AuthorRank)
		self.Instance.Main.Info.Message.Text = self.Info.Message
		self.Instance.Main.Info.Data.Text = os.date("%m/%d/%Y", self.Info.Timestamp)
		local announce = Controller.IsViewingOwnGuild() and module.Shared.Guilds.GetPermissions(module.Data.Guild.Rank) and module.Shared.Guilds.GetPermissions(module.Data.Guild.Rank).Announce
		self.Instance.Main.Delete.Visible = announce == true
		module.Button:Create(self.Instance.Main.Delete.Main, "Small"):BindFunction("Click", function()
			local timestamp = self.Info.Timestamp
			module.Scripts.Interface.Confirmation.Start({
				Title = "Delete",
				Description = "Delete this announcement? This cannot be undone.",
				ConfirmText = "Delete",
				CancelText = "Cancel",
				Callback = function(flag: boolean)
					if not flag then
						return
					end

					module.Signal:Fire("General", "Guilds", "DeleteAnnouncement", timestamp)
				end
			})
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
	end
})
local Home = {
	ClearAnnouncements = function()
		for _, v2 in v do
			v2.Instance:Destroy()
			v2:doCleanup()
		end

		table.clear(v)
	end
}

function Home.RefreshAnnouncements(p)
	if not p then
		Home.ClearAnnouncements()
		return
	end

	local v2 = {}
	local total = 0

	for i = #p.Announcements, 1, -1 do
		local announcement2 = p.Announcements[i]
		v2[announcement2.Timestamp] = true

		if v[announcement2.Timestamp] then
			continue
		end

		local innerScope = scope:innerScope()
		innerScope.Info = announcement2

		if innerScope:Build(total) then
			v[announcement2.Timestamp] = innerScope
		else
			innerScope:doCleanup()
		end

		total += 0.05
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

function Home.RefreshHeader(data)
	if not data then
		return
	end

	info.GuildName.Text = data.Name
	header.GuildIcon.Image = data.Icon
	info.GuildDesc.Text = data.Description
	local count = 0
	local v2 = "Unknown"

	for k, member in data.Members do
		count += 1

		if tostring(data.OwnerId) == k then
			v2 = member.UserName and "@" .. member.UserName or member.NickName or v2
		end
	end

	info.GuildLeader.Text = "By: " .. v2
	info.GuildMembers.Text = `{count}/{data.MaxMembers} Members`
end

function Home.RefreshButtons()
	local isViewingOwnGuild = Controller.IsViewingOwnGuild()
	local v2

	if isViewingOwnGuild then
		v2 = module.Shared.Guilds.GetPermissions(module.Data.Guild.Rank)
	end

	local invite = buttons.Invite
	invite.Visible = v2 ~= nil and v2.Invite == true
	local announce = buttons.Announce
	announce.Visible = v2 ~= nil and v2.Announce == true
	buttons.Leave.Visible = isViewingOwnGuild
end

function Home.Refresh()
	Home.RefreshHeader(Controller.ViewingGuildData)
	Home.RefreshAnnouncements(Controller.ViewingGuildData)
	Home.RefreshButtons()
end

function Home.Init()
	Controller.GuildDataChanged:Connect(function()
		if Controller.CurrentTab ~= "Home" then
			return
		end

		Home.Refresh()
	end)
	Controller.TabChanged:Connect(function(p)
		if p == "Home" then
			Home.Refresh()
		else
			Home.ClearAnnouncements()
		end
	end)
	module.Frame:OnFrameClosed(guilds, Home.ClearAnnouncements)
	module.Button:Create(buttons.Invite.Main, "Small"):BindFunction("Click", function()
		module.Scripts.Interface.PlayerSelector.Start({
			PastUI = "Guilds",
			Callback = function(p: number)
				module.Signal:Fire("General", "Guilds", "Invite", p)
			end,
			GlobalSearch = function(p: string)
				return module.Signal:Invoke("General", "Guilds", "FindPlayer", p)
			end
		})
	end)
	module.Button:Create(buttons.Announce.Main, "Small"):BindFunction("Click", function()
		module.Scripts.Interface.TextSelector.Start({
			Title = "Announce",
			Placeholder = "Type your announcement...",
			MaxLength = module.Shared.Guilds.AnnouncementMaxLength,
			Callback = function(list: string)
				if #list == 0 or #list > module.Shared.Guilds.AnnouncementMaxLength then
					return
				end

				module.Signal:Fire("General", "Guilds", "Announce", list)
			end
		})
	end)
	module.Button:Create(buttons.Leave.Main, "Small"):BindFunction("Click", function()
		local viewingGuildData = Controller.ViewingGuildData

		if viewingGuildData and viewingGuildData.OwnerId == module.Instance.UserId then
			module.Scripts.Interface.Confirmation.Start({
				Title = "You are the Leader of this guild.",
				Description = "If someone else can lead, they'll take over. If not, the guild will be deleted.",
				ConfirmText = "Continue",
				Callback = function(flag: boolean)
					if not flag then
						return
					end

					module.Scripts.Interface.Confirmation.Start({
						Description = "Are you sure you want to leave the guild?",
						ConfirmText = "Leave",
						Callback = function(flag2: boolean)
							if not flag2 then
								return
							end

							module.Signal:Fire("General", "Guilds", "Leave")
						end
					})
				end
			})
		else
			module.Scripts.Interface.Confirmation.Start({
				Description = "Are you sure you want to leave the guild?",
				ConfirmText = "Leave",
				Callback = function(flag: boolean)
					if not flag then
						return
					end

					module.Signal:Fire("General", "Guilds", "Leave")
				end
			})
		end
	end)
end

return Home