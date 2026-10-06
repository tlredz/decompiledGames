local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.fromRGB(251, 204, 19)
local color2 = Color3.fromRGB(196, 196, 196)
local color3 = Color3.fromRGB(206, 137, 70)
local color4 = Color3.fromRGB(135, 144, 153)
local color5 = Color3.fromRGB(255, 214, 25)
local color6 = Color3.fromRGB(255, 76, 190)
local fusion = module.Libs.Fusion
local Controller = require(script.Parent.Parent.Controller)
local leaderboards = module.Interface:WaitForChild("Frames"):WaitForChild("Profile"):WaitForChild("Main"):WaitForChild("Leaderboards")
local scroll = leaderboards:WaitForChild("Leaderboards"):WaitForChild("Scroll")
local categories = leaderboards:WaitForChild("Categories")
local scroll2 = leaderboards:WaitForChild("List"):WaitForChild("Scroll")
local profile = module.Assets:WaitForChild("Interface"):WaitForChild("Templates"):WaitForChild("Profile")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local innerScopes = {}
local v5 = nil
local v6 = nil
local v7 = module.Libs.DataContainerClient.New("Leaderboards")
local Leaderboards = {}
local v8 = {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(1.5, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.SelectionProgress = self:Value(0)
		self.SelectionProgressSpring = self:Spring(self.SelectionProgress, 10, 1)
		self.Instance = profile.Leaderboards.Leaderboard:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Title.Text = self.Name
		self.Instance.Main.Icon.Image = self.Info.Icon
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			Leaderboards.SetLeaderboard(self.Name)
		end)
		self.Instance.LayoutOrder = self.Info.Index
		self.Instance.Parent = scroll
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Observer(self.SelectionProgressSpring):onBind(function()
			local selectionProgressSpring = self.peek(self.SelectionProgressSpring)

			if not selectionProgressSpring then
				return
			end

			local colorSequenceKeypoints = {}

			for _, keypoint in self.Info.Gradient.Keypoints do
				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(keypoint.Time, color4:Lerp(keypoint.Value, selectionProgressSpring))
				)
			end

			local colorSequence = ColorSequence.new(colorSequenceKeypoints)
			self.Instance.Main.UIGradient.Color = colorSequence
			self.Instance.Main.Icon.UIGradient.Color = colorSequence
			self.Instance.Main.Title.UIGradient.Color = colorSequence
		end)

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
		local v9 = self.Name == v6
		self.SelectionProgress:set(v9 and 1 or 0)
	end
}
local scope = fusion.scoped(fusion, v8)
local v9 = {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(0.5, -0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.SelectionProgress = self:Value(0)
		self.SelectionProgressSpring = self:Spring(self.SelectionProgress, 10, 1)
		self.Instance = profile.Leaderboards.Category:Clone()
		self.Instance.Name = self.Name
		self.Instance.Main.Title.Text = self.Name
		module.Button:Create(self.Instance.Main, "Small"):BindFunction("Click", function()
			Leaderboards.SetCategory(self.Name)
		end)
		self.Instance.Parent = categories
		self.Instance.Visible = true
		self:Hydrate(self.Instance.Main)({
			Position = self.PositionSpring
		})
		self:Observer(self.SelectionProgressSpring):onBind(function()
			local selectionProgressSpring = self.peek(self.SelectionProgressSpring)

			if not selectionProgressSpring then
				return
			end

			local colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color4:Lerp(color5, selectionProgressSpring)),
				ColorSequenceKeypoint.new(1, color4:Lerp(color6, selectionProgressSpring))
			})
			self.Instance.Main.UIGradient.Color = colorSequence
		end)

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
		local v10 = self.Name == v5
		self.SelectionProgress:set(v10 and 1 or 0)
	end
}
local scope2 = fusion.scoped(fusion, v9)
local scope3 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.75, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = profile.Leaderboards.Player:Clone()
		self.Instance.Name = self.ID
		module.Button:Create(self.Instance.Main, "Stuck"):BindFunction("Click", function()
			Controller.SearchProfile(self.Info.UserName)
		end)
		self.Instance.Parent = scroll2
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
		local v10 = workspace:GetServerTimeNow() - self.Info.SaveTime
		self.Instance.Main.Rank.Text = "#" .. self.Index
		self.Instance.Main.Icon.Main.Image = self.Info.Icon
		self.Instance.Main.UserName.Text = self.Info.UserName
		self.Instance.Main.NickName.Text = self.Info.NickName
		self.Instance.Main.Time.Text = "Updated " .. module.Utils.Number:Time2(v10) .. " ago"
		self.Instance.Main.Border.Visible = self.Index <= 3
		self.Instance.Main.Border.UIStroke.Color = self.Index == 1 and color or self.Index == 2 and color2 or color3

		if self.Leaderboard == "Time Played" then
			self.Instance.Main.Value.Text = module.Utils.Number:Time2(self.Info.Value)
		else
			self.Instance.Main.Value.Text = module.Utils.Number:Format(self.Info.Value)
		end
	end
})
local scope4 = fusion.scoped(fusion, {
	Build = function(self, duration: number)
		self.Position = self:Value(UDim2.fromScale(-0.75, 0.5))
		self.PositionSpring = self:Spring(self.Position, 10, 1)
		self.Instance = profile.Leaderboards.Player:Clone()
		self.Instance.Name = self.Key
		self.DefaultTimeColor = self.Instance.Main.Time.TextColor3
		self.Instance.Main.Icon.Main.Size = UDim2.fromScale(0.7, 0.7)
		self.Instance.Main.Icon.Main.ImageColor3 = Color3.new(0, 0, 0)
		module.Button:Create(self.Instance.Main, "Stuck"):BindFunction("Click", function()
			module.Signal:Fire("General", "Profile", "SetChatTag", self.Info.Name, self.Info.Category)
		end)
		self.Instance.Parent = scroll2
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
		local v10 = module.Shared.Leaderboards.List[self.Info.Name]
		self.Instance.LayoutOrder = self.Order
		self.Instance.Main.Rank.Text = "#" .. self.Info.Rank
		self.Instance.Main.Icon.Main.Image = v10.Icon
		self.Instance.Main.NickName.Text = self.Info.Name
		self.Instance.Main.UserName.Text = self.Info.Category
		self.Instance.Main.Time.Text = self.Pinned and "In Chat" or "Click to show in chat"
		self.Instance.Main.Time.TextColor3 = self.Pinned and color5 or self.DefaultTimeColor
		self.Instance.Main.Border.Visible = self.Info.Rank <= 3
		self.Instance.Main.Border.UIStroke.Color = self.Info.Rank == 1 and color or self.Info.Rank == 2 and color2 or color3

		if self.Info.Name == "Time Played" then
			self.Instance.Main.Value.Text = module.Utils.Number:Time2(self.Info.Value)
		else
			self.Instance.Main.Value.Text = module.Utils.Number:Format(self.Info.Value)
		end
	end
})

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearTemplates(list)
	for _, v10 in list do
		v10.Instance:Destroy()
		v10:doCleanup()
	end

	table.clear(list)
end

local function GetOwnPositions()
	local userId = module.Services.Players.LocalPlayer.UserId
	local v10 = {}

	for k, v11 in v7.Data or {} do
		if typeof(v11) ~= "table" then
			continue
		end

		for k2, v12 in v11 do
			if typeof(v12) ~= "table" then
				continue
			end

			for k3, v13 in v12 do
				if typeof(v13) == "table" and v13.UserId == userId then
					table.insert(v10, {
						Name = k,
						Category = k2,
						Rank = k3,
						Value = v13.Value
					})
				end
			end
		end
	end

	return module.Shared.ChatTags.SortPositions(v10)
end

local function UpdateRanks()
	local ownPositions = GetOwnPositions()
	local decodeSelection = module.Shared.ChatTags.DecodeSelection(module.Services.Players.LocalPlayer:GetAttribute(module.Shared.ChatTags.SelectionAttribute))
	local v11 = {}
	local count = 0

	for k, info in ownPositions do
		local key = module.Shared.ChatTags.GetKey(info.Name, info.Category)
		v11[key] = true
		local pinned = table.find(decodeSelection, key) ~= nil

		if pinned then
			count += 1
		end

		local v14 = v3[key]

		if v14 then
			v14.Info = info
			v14.Order = k
			v14.Pinned = pinned
			v14:Update()
		else
			local innerScope = scope4:innerScope()
			innerScope.Key = key
			innerScope.Info = info
			innerScope.Order = k
			innerScope.Pinned = pinned

			if innerScope:Build(0.05 * k) then
				v3[key] = innerScope
			else
				innerScope:doCleanup()
			end
		end
	end

	for k, v12 in v3 do
		if v11[k] then
			continue
		end

		v12.Instance:Destroy()
		v12:doCleanup()
		v3[k] = nil
	end

	if #ownPositions == 0 then
		leaderboards.Header.Title.Text = "Your Ranks - Not ranked yet"
	else
		leaderboards.Header.Title.Text = `Your Ranks ({count}/{module.Shared.ChatTags.MaximumLeaderboardTags} in chat)`
	end
end

local function GetYourRanksInfo()
	return {
		Index = 0,
		Icon = "rbxassetid://133770608726419",
		Gradient = ColorSequence.new({ ColorSequenceKeypoint.new(0, color5), ColorSequenceKeypoint.new(1, color6) })
	}
end

function Leaderboards.SetLeaderboard(p: string)
	v6 = p
	v5 = nil
	ClearTemplates(v4) -- equivalent call inferred; original call site unknown
	Leaderboards.UpdateAll()
end

function Leaderboards.SetCategory(p: string)
	v5 = p
	Leaderboards.UpdateAll()
end

function Leaderboards.UpdateAll()
	if not v6 then
		for k, v10 in module.Shared.Leaderboards.List do
			if v10.Index ~= 1 then
				continue
			end

			v6 = k
			break
		end
	end

	for k, info in module.Shared.Leaderboards.List do
		local v11 = innerScopes[k]

		if v11 then
			v11:Update()
		else
			local innerScope = scope:innerScope()
			innerScope.Name = k
			innerScope.Info = info

			if innerScope:Build(0.05 * info.Index) then
				innerScopes[k] = innerScope
			else
				innerScope:doCleanup()
			end
		end
	end

	local yourRanks = innerScopes["Your Ranks"]

	if yourRanks then
		yourRanks:Update()
	else
		local innerScope = scope:innerScope()
		innerScope.Name = "Your Ranks"
		innerScope.Info = GetYourRanksInfo()

		if innerScope:Build(0) then
			innerScopes["Your Ranks"] = innerScope
		else
			innerScope:doCleanup()
		end
	end

	if v6 == "Your Ranks" then
		ClearTemplates(v4)
		ClearTemplates(v2)
		UpdateRanks()
	else
		ClearTemplates(v3)
		local v10 = module.Shared.Leaderboards.List[v6]

		if v10 then
			local total = 0

			for k, v11 in v4 do
				if v10.Categories[k] then
					continue
				end

				v11.Instance:Destroy()
				v11:doCleanup()
				v4[k] = nil
			end

			for k in v10.Categories do
				local v11 = v4[k]

				if v11 then
					v11:Update()
				else
					local innerScope = scope2:innerScope()
					innerScope.Name = k
					innerScope.Info = v10.Categories[k]

					if innerScope:Build(total) then
						v4[k] = innerScope
						total += 0.05
					else
						innerScope:doCleanup()
					end
				end
			end

			local value = v5 and v7:GetValue({ v6, v5 })

			if value then
				local leaderboardID = v6 .. v5

				for k, v12 in v2 do
					local v13 = value[v12.Index]

					if not (not v13 or v13.UserId ~= v12.Info.UserId or v12.LeaderboardID ~= leaderboardID) then
						continue
					end

					v12.Instance:Destroy()
					v12:doCleanup()
					v2[k] = nil
				end

				for k, info in value do
					local ID = v6 .. v5 .. k
					local v14 = v2[ID]

					if v14 then
						v14.Info = info
						v14:Update()
					else
						local innerScope = scope3:innerScope()
						innerScope.ID = ID
						innerScope.Leaderboard = v6
						innerScope.LeaderboardID = leaderboardID
						innerScope.Info = info
						innerScope.Index = k

						if innerScope:Build(0.05 * k) then
							v2[ID] = innerScope
						else
							innerScope:doCleanup()
						end
					end
				end
			else
				ClearTemplates(v2) -- equivalent call inferred; original call site unknown
			end

			leaderboards.Header.Title.Text = v6
		else
			leaderboards.Header.Title.Text = "Nothing Selected"
			ClearTemplates(v4) -- equivalent call inferred; original call site unknown
		end
	end
end

function Leaderboards.Clear()
	v5 = nil
	v6 = nil
	ClearTemplates(innerScopes) -- equivalent call inferred; original call site unknown
	ClearTemplates(v4) -- equivalent call inferred; original call site unknown
	ClearTemplates(v2) -- equivalent call inferred; original call site unknown
	ClearTemplates(v3)
end

function Leaderboards.Start()
	v.Changed = v7:OnChange({}, Leaderboards.UpdateAll)
	v.ChatTags = module.Services.Players.LocalPlayer:GetAttributeChangedSignal(module.Shared.ChatTags.SelectionAttribute):Connect(Leaderboards.UpdateAll)
	v.Loop = module.Utils.Loop:Connect({
		Time = 1,
		Callback = Leaderboards.UpdateAll
	})
end

function Leaderboards.Stop()
	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
	Leaderboards.Clear()
end

function Leaderboards.Init()
	Controller.FrameChanged:Connect(function(p: string)
		if p == script.Name then
			Leaderboards.Start()
		else
			Leaderboards.Stop()
		end
	end)
end

return Leaderboards