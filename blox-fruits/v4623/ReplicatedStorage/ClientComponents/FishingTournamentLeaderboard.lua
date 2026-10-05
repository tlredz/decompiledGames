local FishHelper = require(game.ReplicatedStorage.Modules.FishHelper)
local FishingTournamentClient = require(game.ReplicatedStorage.Controllers.FishingTournamentClient)
local Realm = require(game.ReplicatedStorage.Util.Realm)
local Summer25FishingTournament = require(game.ReplicatedStorage.Modules.Data.Summer25FishingTournament)
local v = {
	Sea1 = {
		Leaderboard = {
			CFrame.new(
				1114.78711,
				17.3362179,
				-1238.7041,
				-0.754974604,
				0,
				0.655753493,
				0,
				1,
				0,
				-0.655753493,
				0,
				-0.754974604
			),
			CFrame.new(
				-1170.19421,
				17.68437,
				1693.01001,
				-0.25881955,
				0,
				0.965925694,
				0,
				1,
				0,
				-0.965925694,
				0,
				-0.25881955
			)
		},
		NPC = {
			CFrame.new(
				-1174.59192,
				7.00346088,
				1679.57153,
				-0.258819908,
				0,
				0.965925634,
				0,
				1,
				0,
				-0.965925634,
				0,
				-0.258819908
			),
			CFrame.new(
				1090.23486,
				6.65531397,
				-1241.62219,
				-0.874625385,
				4.0514216e-8,
				-0.484805852,
				-2.98023757e-8,
				1.00000191,
				-2.98023508e-8,
				0.484807312,
				1.16174066e-8,
				-0.874621928
			)
		}
	},
	Sea2 = {
		Leaderboard = {
			CFrame.new(
				-297.852386,
				83.0536423,
				302.784149,
				-1.1920929e-7,
				-7.45058415e-9,
				1.00000143,
				-2.98023402e-8,
				1,
				-7.45058415e-9,
				-1.00000155,
				2.98023402e-8,
				1.1920929e-7
			),
			CFrame.new(120.954102, 24.3106384, 2867.10889, -1, 0, 0, 0, 1, 0, 0, 0, -1),
			CFrame.new(
				-5875.25391,
				16.3559875,
				-5238.20361,
				-0.517001867,
				0,
				-0.85598433,
				0,
				1,
				0,
				0.85598433,
				0,
				-0.517001867
			)
		},
		NPC = {
			CFrame.new(108.683441, 13.6284599, 2873.02197, -1, 0, 0, 0, 1, 0, 0, 0, -1),
			CFrame.new(
				-5877.23975,
				5.67380905,
				-5223.71875,
				-0.447590619,
				1.59016142e-15,
				-0.894239068,
				-3.55271368e-15,
				1,
				0,
				0.89423877,
				-3.17697431e-15,
				-0.447590977
			)
		}
	},
	Sea3 = {
		Leaderboard = {
			CFrame.new(
				-9586.91016,
				20.2250862,
				-8322.98145,
				-0.0348990001,
				0,
				-0.999391019,
				0,
				1,
				0,
				0.999391019,
				0,
				-0.0348990001
			),
			CFrame.new(
				3278.73535,
				22.0669136,
				2164.25488,
				-0.925970554,
				0,
				-0.377595693,
				0,
				1,
				0,
				0.377595901,
				0,
				-0.925970554
			),
			CFrame.new(
				-6035.5752,
				26.4541473,
				-2199.71924,
				-0.374603182,
				0,
				0.927185476,
				0,
				1,
				0,
				-0.927185476,
				0,
				-0.374603093
			),
			CFrame.new(
				4.67944336,
				20.6440659,
				5435.27344,
				0.258831143,
				0,
				0.965923309,
				0,
				1,
				0,
				-0.965923548,
				0,
				0.258831412
			),
			CFrame.new(-12613.0684, 346.948029, -7452.40283, 0, 0, -1, 0, 1, 0, 1, 0, 0),
			CFrame.new(
				11406.7021,
				-2145.01367,
				9823.61035,
				-0.0491409898,
				-5.71257942e-7,
				-0.998791873,
				-0.000205972479,
				1,
				0.0000106813986,
				0.998791814,
				0.000206248529,
				-0.0491409935
			),
			CFrame.new(
				10047.2949,
				-2133.62256,
				10125.4287,
				-0.740015447,
				0.00211258396,
				0.672586799,
				0.00200700061,
				0.999998152,
				-0.000932766125,
				-0.672587514,
				0.000659621845,
				-0.740017653
			)
		},
		NPC = {
			CFrame.new(
				-9581.42969,
				9.54290771,
				-8310.51074,
				-0.0348990001,
				0,
				-0.999391019,
				0,
				1,
				0,
				0.999391019,
				0,
				-0.0348990001
			),
			CFrame.new(
				3269.60474,
				11.3847351,
				2174.36304,
				-0.925970554,
				0,
				-0.377595693,
				0,
				1,
				0,
				0.377595901,
				0,
				-0.925970554
			),
			CFrame.new(
				-6045.65381,
				15.7719679,
				-2208.88232,
				-0.374603182,
				0,
				0.927185476,
				0,
				1,
				0,
				-0.927185476,
				0,
				-0.374603093
			),
			CFrame.new(
				2.14526367,
				9.96188641,
				5421.89014,
				0.258831143,
				0,
				0.965923309,
				0,
				1,
				0,
				-0.965923548,
				0,
				0.258831412
			),
			CFrame.new(
				11412.0059,
				-2155.69849,
				9836.1543,
				-0.0491409898,
				-5.71257942e-7,
				-0.998791873,
				-0.000205972479,
				1,
				0.0000106813986,
				0.998791814,
				0.000206248529,
				-0.0491409935
			),
			CFrame.new(
				10034.2158,
				-2144.27515,
				10121.5449,
				-0.740015447,
				0.00211258396,
				0.672586799,
				0.00200700061,
				0.999998152,
				-0.000932766125,
				-0.672587514,
				0.000659621845,
				-0.740017653
			)
		}
	}
}
local scrollingFrame = nil
local virtual = nil
local clone = nil
local v2 = {}
local v3 = {}
local clones = {}
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)

local function updateUserMapFromLeaderboard(items)
	local v4 = {}
	local v5 = {}

	for _, item in pairs(items) do
		local key = tonumber(item.Key)

		if not key then
			continue
		end

		if v3[key] and v3[key].Username ~= "n/a" then
			v4[key] = v3[key]
		else
			v4[key] = {
				Id = key,
				Username = "n/a",
				DisplayName = "n/a"
			}
			table.insert(v5, key)
		end
	end

	local success, result = pcall(function()
		local UserService = game:GetService("UserService")
		local userInfosByUserIdsAsync = UserService:GetUserInfosByUserIdsAsync(v5)

		for _, v6 in pairs(userInfosByUserIdsAsync) do
			v4[v6.Id] = v6
		end
	end)

	if not success then
		warn(result)
	end

	v3 = v4
end

local function safeSet(p, p2, p3)
	if p[p2] ~= p3 then
		p[p2] = p3
	end
end

local function UpdateVirtualScroll()
	scrollingFrame.CanvasSize = UDim2.fromOffset(0, math.min(#v2, 3) * 65 + math.max(#v2 - 3, 0) * 55)
	local v4 = nil
	local Y = scrollingFrame.CanvasPosition.Y
	local v5 = math.max(Y, 195)
	local v6 = Y < 195 and Y / 65 or (Y - 195) / 55 + 3

	if v6 >= 3 then
		v5 -= v6 % 1 * 55
	end

	virtual.Position = UDim2.fromOffset(0, v5)

	for k, v8 in pairs(v2) do
		if assert((tonumber(v8.Key))) ~= game.Players.LocalPlayer.UserId then
			continue
		end

		v4 = k
		break
	end

	local v8 = { "FirstPlace", "SecondPlace", "ThirdPlace" }

	for k, v9 in pairs(v8) do
		local v10 = v2[k]
		local v11 = scrollingFrame[v9]

		if v10 and k ~= v4 then
			v11.Visible = true
			local v12 = assert((tonumber(v10.Key)))
			local v13 = assert(v3[v12])
			local username = v11.Username
			local username2 = v13.Username

			if username.Text ~= username2 then
				username.Text = username2
			end

			local pointValue = v11.PointValue
			local formatTrueWeight = FishHelper.FormatTrueWeight(v10.Value)

			if pointValue.Text ~= formatTrueWeight then
				pointValue.Text = formatTrueWeight
			end

			local placeNumber = v11.PlaceNumber
			local text = "#" .. v10.Index

			if placeNumber.Text ~= text then
				placeNumber.Text = text
			end
		else
			v11.Visible = false
		end
	end

	for i = 1, #clones do
		local v9 = clones[i]
		local v10 = math.max(math.floor(v6), 3) + i
		local v11 = v2[v10]

		if v11 and v10 ~= v4 then
			local backgroundTransparency = v10 % 2 == 0 and 1 or 0.75

			if v9.BackgroundTransparency ~= backgroundTransparency then
				v9.BackgroundTransparency = backgroundTransparency
			end

			local v13 = assert((tonumber(v11.Key)))
			local v14 = assert(v3[v13])
			local username = v9.Username
			local username2 = v14.Username

			if username.Text ~= username2 then
				username.Text = username2
			end

			local pointValue = v9.PointValue
			local formatTrueWeight = FishHelper.FormatTrueWeight(v11.Value)

			if pointValue.Text ~= formatTrueWeight then
				pointValue.Text = formatTrueWeight
			end

			local placeNumber = v9.PlaceNumber
			local text = "#" .. v11.Index

			if placeNumber.Text ~= text then
				placeNumber.Text = text
			end
		else
			local username = v9.Username

			if username.Text ~= "" then
				username.Text = ""
			end

			local pointValue = v9.PointValue

			if pointValue.Text ~= "" then
				pointValue.Text = ""
			end

			local placeNumber = v9.PlaceNumber

			if placeNumber.Text ~= "" then
				placeNumber.Text = ""
			end

			if v9.BackgroundTransparency ~= 1 then
				v9.BackgroundTransparency = 1
			end
		end
	end

	if v4 then
		local v9 = v2[v4]
		local v10 = clone

		if v10.Visible ~= true then
			v10.Visible = true
		end

		local odd

		if v4 <= 3 then
			odd = scrollingFrame[v8[v4]]
		else
			odd = virtual.Odd
		end

		if v4 <= 3 then
			local icon = clone.Icon
			local image = odd.Icon.Image

			if icon.Image ~= image then
				icon.Image = image
			end

			local uIGradient = clone.PlaceNumber.UIGradient
			local color = odd.PlaceNumber.UIGradient.Color

			if uIGradient.Color ~= color then
				uIGradient.Color = color
			end

			local uIGradient2 = clone.Username.UIGradient
			local color2 = odd.Username.UIGradient.Color

			if uIGradient2.Color ~= color2 then
				uIGradient2.Color = color2
			end

			local v11 = clone
			local backgroundColor3 = odd.BackgroundColor3

			if v11.BackgroundColor3 ~= backgroundColor3 then
				v11.BackgroundColor3 = backgroundColor3
			end
		else
			local v11 = clone
			local color = Color3.fromRGB(0, 107, 0)

			if v11.BackgroundColor3 ~= color then
				v11.BackgroundColor3 = color
			end
		end

		local v11 = clone

		if v11.BackgroundTransparency ~= 0.75 then
			v11.BackgroundTransparency = 0.75
		end

		local icon = clone.Icon
		local visible = v4 <= 3

		if icon.Visible ~= visible then
			icon.Visible = visible
		end

		local uIGradient = clone.PlaceNumber.UIGradient
		local enabled = v4 <= 3

		if uIGradient.Enabled ~= enabled then
			uIGradient.Enabled = enabled
		end

		local uIGradient2 = clone.Username.UIGradient
		local enabled2 = v4 <= 3

		if uIGradient2.Enabled ~= enabled2 then
			uIGradient2.Enabled = enabled2
		end

		local placeNumber = clone.PlaceNumber
		local position = odd.PlaceNumber.Position

		if placeNumber.Position ~= position then
			placeNumber.Position = position
		end

		local v15 = clone
		local size = odd.Size

		if v15.Size ~= size then
			v15.Size = size
		end

		local v16 = clone
		local uDim = UDim2.fromOffset(
			0,
			(math.clamp(
				math.min(v4 - 1, 3) * 65 + math.max(v4 - 4, 0) * 55,
				Y,
				Y + scrollingFrame.AbsoluteSize.Y - clone.AbsoluteSize.Y
			))
		)

		if v16.Position ~= uDim then
			v16.Position = uDim
		end

		local username = clone.Username
		local name = game.Players.LocalPlayer.Name

		if username.Text ~= name then
			username.Text = name
		end

		local pointValue = clone.PointValue
		local formatTrueWeight = FishHelper.FormatTrueWeight(v9.Value)

		if pointValue.Text ~= formatTrueWeight then
			pointValue.Text = formatTrueWeight
		end

		local placeNumber2 = clone.PlaceNumber
		local text = "#" .. v4

		if placeNumber2.Text ~= text then
			placeNumber2.Text = text
		end
	else
		local v9 = clone

		if v9.Visible ~= false then
			v9.Visible = false
		end
	end
end

local function construct(p)
	local currentSeaAsync = Realm.getCurrentSeaAsync()
	local v4

	if currentSeaAsync then
		v4 = v[currentSeaAsync]
	else
		v4 = nil
	end

	if not v4 then
		return p
	end

	local clone2 = script.FishingLeaderboard:Clone()
	clone2:SetPrimaryPartCFrame(CFrame.new(123123, -5000, -123122))
	clone2.Parent = workspace
	p.Maid:Add(clone2)
	scrollingFrame = clone2.PrimaryPart.SurfaceGui.ScrollingFrame
	virtual = scrollingFrame.Virtual
	clones = { virtual.Odd }

	for i = 1, 20 do
		local clone3 = virtual.Odd:Clone()
		clone3.Parent = virtual
		clone3.LayoutOrder = i
		table.insert(clones, clone3)
	end

	clone = scrollingFrame.FirstPlace:Clone()
	clone.Parent = scrollingFrame
	p.Maid:Add(clone)
	task.spawn(function()
		while task.wait(1) and clone2.Parent do
			if not (game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
				continue
			end

			local position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
			table.sort(v4.Leaderboard, function(a, b)
				return (a.Position - position).Magnitude < (b.Position - position).Magnitude
			end)
			local vector = v4.Leaderboard[1]

			if not vector:FuzzyEq(clone2.PrimaryPart.CFrame, 0.01) then
				clone2:SetPrimaryPartCFrame(vector)
			end
		end
	end)
	return p
end

function start(p)
	p.Maid:Add((FishingTournamentClient.leaderboardUpdated(function(p2)
		v2 = p2
		updateUserMapFromLeaderboard(v2)
		UpdateVirtualScroll()
	end)))

	if scrollingFrame then
		p.Maid:Add(scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateVirtualScroll))
		UpdateVirtualScroll()
	end
end

if Summer25FishingTournament.EVENT_ENABLED then
	task.spawn(start, (construct({
		Maid = Trove.new()
	})))
end

return {}