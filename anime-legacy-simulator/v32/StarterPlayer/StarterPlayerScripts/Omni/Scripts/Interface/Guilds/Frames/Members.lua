local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local Controller = require(script.Parent.Parent.Controller)
local guilds = module.Interface:WaitForChild("Frames"):WaitForChild("Guilds")
local scroll = guilds:WaitForChild("Main"):WaitForChild("Members"):WaitForChild("Scroll")
local member = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Guilds"):WaitForChild("Member")
local color = Color3.new(0, 1, 0)
local color2 = Color3.new(1, 0, 0)
local v = {}
local v2 = nil
local thread = nil
local v3 = {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = member:Clone()
		self.Instance.Name = tostring(self.UserId)
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			self:Click()
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
		local userName = self.Info.UserName or `User {self.UserId}`
		self.Instance.Main.Info.Title.Text = self.Info.NickName or userName
		self.Instance.Main.Info.Desc.Text = `@{userName}`
		self.Instance.Main.Info.Rank.Text = self.Info.Rank
		self.Instance.Main.Info.Rank.TextColor3 = module.Shared.Guilds.GetRankColor(self.Info.Rank)
		self.Instance.Main.Power.Text = `{module.Utils.Number:Format(self.Info.LastKnownPower or 0)} Power`
		self.Instance.Main.Yen.Text = `{module.Utils.Number:Format(self.Info.TotalDonated or 0)} Yen Donated`
		self.Instance.Main.Icon.Main.Image = self.Info.Icon or ""
		local v4 = self.Info.Banner and module.Shared.ProfileBanners.List[self.Info.Banner]
		self.Instance.Main.Banner.Image = v4 and v4.Icon or ""
		self:UpdateStatus()
	end,
	UpdateStatus = function(self)
		local status = self.Instance.Main.Status
		status.Visible = v2 ~= nil

		if not v2 then
			return
		end

		local v4 = v2[tostring(self.UserId)]
		local lastOnline = v4 and tonumber(v4.LastOnline)
		local v5 = lastOnline and workspace:GetServerTimeNow() - lastOnline
		local v6

		if v4 == nil or v4.Online ~= true or v5 == nil then
			v6 = false
		else
			v6 = v5 < module.Shared.Guilds.OnlineTimeout
		end

		if v6 then
			status.Text = "Online"
			status.TextColor3 = color
		else
			if v5 then
				status.Text = `Offline ({module.Shared.Guilds.FormatOfflineTime(v5)})`
			else
				status.Text = "Offline"
			end

			status.TextColor3 = color2
		end
	end,
	Click = function(self)
		local rank = module.Data.Guild.Rank
		local v4

		if Controller.IsViewingOwnGuild() then
			v4 = module.Shared.Guilds.GetPermissions(rank)
		end

		local v5

		if v4 == nil then
			v5 = false
		else
			v5 = module.Shared.Guilds.CanActOn(rank, self.Info.Rank)
		end

		if self.UserId == module.Instance.UserId then
			return
		end

		if v5 then
			local options = {
				{
					Name = "Open Profile",
					ID = "OpenProfile"
				}
			}

			if self.Info.Rank == "Recruit" and v4.PromoteRecruitToVeteran then
				table.insert(options, {
					Name = "Promote to Veteran",
					ID = "Promote"
				})
			elseif self.Info.Rank == "Veteran" and v4.PromoteVeteranToCoLeader then
				table.insert(options, {
					Name = "Promote to Co-Leader",
					ID = "Promote"
				})
			end

			if self.Info.Rank == "Co-Leader" and v4.PromoteVeteranToCoLeader then
				table.insert(options, {
					Name = "Demote to Veteran",
					ID = "Demote"
				})
			elseif self.Info.Rank == "Veteran" and v4.PromoteRecruitToVeteran then
				table.insert(options, {
					Name = "Demote to Recruit",
					ID = "Demote"
				})
			end

			if v4.Kick then
				table.insert(options, {
					Name = "Kick",
					ID = "Kick"
				})
			end

			local userId = self.UserId
			module.Dropdown:Open({
				Holder = self.Instance.Main,
				Callback = function(p: string?)
					if p == "OpenProfile" then
						local v7 = module.Signal:InvokeSelf("Interface", "Profile", "GetController")

						if v7 then
							v7.SearchProfile(self.Info.UserName)
						end
					elseif p == "Promote" then
						module.Signal:Fire("General", "Guilds", "Promote", userId)
					elseif p == "Demote" then
						module.Signal:Fire("General", "Guilds", "Demote", userId)
					elseif p == "Kick" then
						module.Scripts.Interface.Confirmation.Start({
							Description = "Are you sure you want to kick this member?",
							ConfirmText = "Kick",
							Callback = function(flag: boolean)
								if not flag then
									return
								end

								module.Signal:Fire("General", "Guilds", "Kick", userId)
							end
						})
					end

					module.Dropdown:Close()
				end,
				Options = options
			})
		else
			local v6 = module.Signal:InvokeSelf("Interface", "Profile", "GetController")

			if v6 then
				v6.SearchProfile(self.Info.UserName)
			end
		end
	end
}
local scope = fusion.scoped(fusion, v3)
local Members = {
	StopStatusRefresh = function()
		if thread then
			task.cancel(thread)
			thread = nil
		end

		v2 = nil
	end,
	RefreshStatus = function()
		local viewingGuildId = Controller.ViewingGuildId

		if not viewingGuildId then
			return
		end

		local v4 = module.Signal:Invoke("General", "Guilds", "GetMembersStatus", viewingGuildId)

		if viewingGuildId ~= Controller.ViewingGuildId or Controller.CurrentTab ~= "Members" then
			return
		end

		if typeof(v4) == "table" then
			v2 = v4
		end

		for _, v5 in v do
			v5:UpdateStatus()
		end
	end
}

function Members.StartStatusRefresh()
	Members.StopStatusRefresh()
	thread = task.spawn(function()
		while true do
			Members.RefreshStatus()
			task.wait(v2 and 60 or 3)
		end
	end)
end

function Members.Clear()
	Members.StopStatusRefresh()
	module.Dropdown:Close()

	for _, v4 in v do
		v4.Instance:Destroy()
		v4:doCleanup()
	end

	table.clear(v)
end

function Members.Refresh()
	local viewingGuildData = Controller.ViewingGuildData

	if not viewingGuildData then
		Members.Clear()
		return
	end

	local v4 = {}
	local total = 0

	for k, member2 in viewingGuildData.Members do
		local userId = tonumber(k)

		if not userId then
			continue
		end

		v4[userId] = true
		local v6 = v[userId]

		if v6 then
			v6.Info = member2
			v6:Update()
		else
			local innerScope = scope:innerScope()
			innerScope.UserId = userId
			innerScope.Info = member2

			if innerScope:Build(total) then
				v[userId] = innerScope
			else
				innerScope:doCleanup()
			end

			total += 0.05
		end
	end

	for k, v5 in v do
		if v4[k] then
			continue
		end

		v5.Instance:Destroy()
		v5:doCleanup()
		v[k] = nil
	end
end

function Members.Init()
	Controller.GuildDataChanged:Connect(function()
		if Controller.CurrentTab ~= "Members" then
			return
		end

		Members.Refresh()
	end)
	Controller.TabChanged:Connect(function(p)
		if p ~= "Members" then
			Members.Clear()
			return
		end

		Members.Refresh()
		Members.StartStatusRefresh()
	end)
	module.Frame:OnFrameClosed(guilds, Members.Clear)
end

return Members