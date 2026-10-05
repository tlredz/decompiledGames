local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local v = require3(script.Parent.Lambda)
local v2 = require3(script.Parent.RankData)
local v3 = require3(script.CountryIcons)
local v4 = require3(script.Parent.AbilityIcons)
local v5 = require3(game.ReplicatedStorage.ServerInfo)
local PlayerData = {}

function PlayerData.RegisterPlayer(p)
	return v.Merge(p, {
		Rank = v2.GetRank(p.Elo).Name
	})
end

function PlayerData.Sorter(p, p2)
	return p.Elo > p2.Elo
end

function PlayerData.CreateLabelFrom(data, p: number, instance, instance2)
	local rankType = v5:GetRankType()
	local order = data.Order or p
	local clone = instance:Clone()
	clone.PlayerPlacement.Text = tostring(order)
	clone.PlayerPlacementShadow.Text = tostring(order)
	clone.PlayerPlacement.TextColor3 = order > 3 and Color3.new(1, 1, 1) or Color3.fromRGB(255, 238, 2)
	clone.PlayerPlacementShadow.UIStroke.Color = order > 3 and Color3.new(1, 1, 1) or Color3.fromRGB(255, 238, 2)
	local playerName = clone.PlayerName
	playerName.Text = v3[data.Country or "Unknown"].Emoji .. " Loading..."
	data.Player:andThen(function(p2)
		playerName.Text = v3[data.Country or "Unknown"].Emoji .. " " .. p2
	end)
	clone.PlayerRank.Text = data.Rank
	clone.PlayerRank.TextColor3 = v2.Ranks[data.Rank].TextColor
	clone.PlayerElo.Text = tostring(data.Elo) .. " ELO"

	if data.AveragePlacement then
		local v6 = math.max(0, (16 - data.AveragePlacement + 1) / 16)
		clone.AveragePlacementBar.AveragePlacementBarProgress.Size = UDim2.fromScale(v6, 1)
	else
		clone.AveragePlacementBar.Visible = false
	end

	clone.LayoutOrder = order
	clone.PlayerRankIcon.Image = v2.Ranks[data.Rank].Icon
	clone.PlayerAvatarIcon.Image = Players:GetUserThumbnailAsync(
		data.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size420x420
	)
	clone.Name = "Loading..."

	if rankType == "Normal" then
		clone.PlayerAbilityIcon.Image = v4[data.MostUsedAbility] or warn(data.Player, data.MostUsedAbility, data) or ""
	else
		clone.PlayerAbilityIcon.Image = ""
	end

	clone.Name = tostring(data.UserId)
	local clone2 = instance2:Clone()
	clone2.Visible = false
	clone2.Parent = clone

	local function Highlight(p2)
		return function()
			local uIStroke = clone2:FindFirstChildWhichIsA("UIStroke")

			if uIStroke then
				uIStroke.Thickness = 3
			end

			clone.ZIndex = 1000
			p2.BackgroundColor3 = Color3.fromRGB(41, 83, 150)
			p2.Visible = true
		end
	end

	local function Normal(p2)
		return function()
			local uIStroke = clone2:FindFirstChildWhichIsA("UIStroke")

			if uIStroke then
				uIStroke.Thickness = 1
			end

			clone.ZIndex = 100
			p2.BackgroundColor3 = Color3.fromRGB(26, 43, 98)
		end
	end

	local connections = {}
	local v6 = {
		[clone.PlayerInfo] = {
			clone.PlayerAbilityIcon.Image,
			(`Country: {data.Country} {v3[data.Country or "Unknown"].Emoji} \nMost Used Ability: {data.MostUsedAbility}`)
		},
		[clone.RankInfo] = {
			clone.PlayerRankIcon.Image,
			(`{data.Rank} ({v2.Ranks[data.Rank].MinimumElo}-{v2.Ranks[data.Rank].MaximumElo})`)
		},
		[clone.PlacementInfo] = {
			"rbxassetid://15019880691",
			(`Average Placement: #{math.floor(data.AveragePlacement * 100) / 100} \n{data.Games} Games Played`)
		}
	}

	if rankType ~= "Normal" then
		v6[clone.PlayerInfo] = { "", (`Country: {data.Country} {v3[data.Country or "Unknown"].Emoji}`) }
	end

	for k, v7 in v6 do
		local v8 = k

		local function fn()
			local uIStroke = clone2:FindFirstChildWhichIsA("UIStroke")

			if uIStroke then
				uIStroke.Thickness = 3
			end

			clone.ZIndex = 1000
			v8.BackgroundColor3 = Color3.fromRGB(41, 83, 150)
			v8.Visible = true
		end

		local v9 = k

		local function fn2()
			local uIStroke = clone2:FindFirstChildWhichIsA("UIStroke")

			if uIStroke then
				uIStroke.Thickness = 1
			end

			clone.ZIndex = 100
			v9.BackgroundColor3 = Color3.fromRGB(26, 43, 98)
		end

		local v10 = k
		local v12 = v7
		table.insert(connections, k.MouseEnter:Connect(function()
			if not clone.Parent then
				return
			end

			local parent = v10.Parent
			fn()
			v10.Parent = nil
			task.wait()
			v10.Parent = parent
			local Y = clone.Parent.AbsoluteSize.Y
			local Y2 = clone.AbsolutePosition.Y
			local v13 = clone.Parent.AbsolutePosition.Y + Y / 2
			clone2.Position = UDim2.fromScale(math.min(0.6, v10.Position.X.Scale), v13 < Y2 and -2 or 1)
			clone2.Icon.Image = v12[1]
			clone2.Info.Text = v12[2]
			clone2.Visible = true
		end))
		table.insert(connections, k.MouseLeave:Connect(function()
			fn2()
			clone2.Visible = false
		end))
	end

	clone.Destroying:Once(function()
		for _, connection in ipairs(connections) do
			if connection.Connected then
				connection:Disconnect()
			end
		end

		table.clear(connections)
		clone2:Destroy()
	end)
	return clone
end

function PlayerData:UpdateLabelTo(data, p: number)
	local rankType = v5:GetRankType()
	local order = data.Order or p
	self.PlayerPlacement.Text = tostring(order)
	self.PlayerPlacementShadow.Text = tostring(order)
	self.PlayerPlacement.TextColor3 = order > 3 and Color3.new(1, 1, 1) or Color3.fromRGB(255, 238, 2)
	self.PlayerPlacementShadow.UIStroke.Color = order > 3 and Color3.new(1, 1, 1) or Color3.fromRGB(255, 238, 2)
	local playerName = self.PlayerName
	playerName.Text = v3[data.Country or "Unknown"].Emoji .. " Loading..."
	data.Player:andThen(function(p2)
		playerName.Text = v3[data.Country or "Unknown"].Emoji .. " " .. p2
	end)
	self.PlayerRank.Text = data.Rank
	self.PlayerRank.TextColor3 = v2.Ranks[data.Rank].TextColor
	self.PlayerElo.Text = tostring(data.Elo) .. " ELO"

	if data.AveragePlacement then
		local v6 = math.max(0, (16 - data.AveragePlacement + 1) / 16)
		self.AveragePlacementBar.AveragePlacementBarProgress.Size = UDim2.fromScale(v6, 1)
	else
		self.AveragePlacementBar.Visible = false
	end

	self.LayoutOrder = order
	self.PlayerRankIcon.Image = v2.Ranks[data.Rank].Icon

	if rankType == "Normal" then
		self.PlayerAbilityIcon.Image = v4[data.MostUsedAbility] or warn(data.Player, data.MostUsedAbility, data) or ""
	else
		self.PlayerAbilityIcon.Image = ""
	end

	self.Name = tostring(data.UserId)
end

function PlayerData.MatchToPlayer(p, object: string)
	return p.Player:expect():lower() == object:expect():lower()
end

function PlayerData.MatchToRegion(p, p2: string)
	return p2 == "GLOBAL" or p.Region == "" or p.Region == p2 or p.Country == p2
end

return PlayerData