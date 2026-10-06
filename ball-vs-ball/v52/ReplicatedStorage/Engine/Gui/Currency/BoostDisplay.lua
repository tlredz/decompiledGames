local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.Packages.Net)
local Config = require(ReplicatedStorage.Engine.Service.Config)
local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local TimeService = require(ReplicatedStorage.Engine.Service.TimeService)
local BoostService = require(ReplicatedStorage.Engine.Service.BoostService)
local ClaimQueue = require(ReplicatedStorage.Engine.Gui.ClaimQueue)
local v = {}
local v2 = false
local v3 = {}
local flag = false

local function getView(p)
	assert(BoostService.definitions[p], "Unknown boost")

	if not v[p] then
		v[p] = {
			hold = 0,
			releasedTokens = {}
		}
	end

	return v[p]
end

local function render(p)
	local view = getView(p)

	if not view.badge then
		return
	end

	local v4 = client[BoostService.definitions[p].field]()
	local v5 = math.ceil((BoostService.getRemainingSeconds(v4)))
	local revealToken = v4 and v4.revealToken
	local v6

	if typeof(revealToken) == "string" and revealToken ~= "" then
		v6 = not view.releasedTokens[revealToken]
	else
		v6 = false
	end

	local badge = view.badge
	badge.Visible = v5 > 0 and not v6 and (view.hold == 0 or view.badge.Visible)

	if view.badge.Visible then
		view.countdown.Text = TimeService.formatClock(v5)
		local activeMultiplier = BoostService.getActiveMultiplier(v4)
		view.multiplier.Text = (p == "经验加成" and "EXPx" or "×") .. tostring(activeMultiplier)
	end
end

local function pop(p)
	local view = getView(p)

	if not view.scale then
		return
	end

	view.scale.Scale = 1
	local tween = TweenService:Create(
		view.scale,
		TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Scale = 1.25
		}
	)
	tween.Completed:Once(function(p2)
		if p2 == Enum.PlaybackState.Completed then
			TweenService:Create(view.scale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Scale = 1
			}):Play()
		end
	end)
	tween:Play()
end

local BoostDisplay = {
	HoldReveal = function(p)
		local view = getView(p)
		view.hold += 1
		render(p)
		local flag2 = false
		return function(p2)
			if flag2 then
				return
			end

			flag2 = true

			-- equivalent calls inferred from this helper; original call sites unknown
			local function release(p3)
				view.hold = math.max(0, view.hold - 1)
				render(p)

				if p3 and view.hold == 0 then
					pop(p)
				end
			end

			if p2 and view.badge then
				ClaimQueue.flyToInventory(p2, view.badge, function()
					view.hold = math.max(0, view.hold - 1)
					render(p)

					if view.hold == 0 then
						pop(p)
					end
				end)
				return
			end

			release(false) -- equivalent call inferred; original call site unknown
		end
	end
}

local function enqueueCard(p)
	local reward = p.reward
	local view = getView(reward.itemId)
	local v4 = Config.asset.byCnId[reward.assetCnId]

	if v4 then
		local _, v5 = BoostService.parseRewardArgs(reward.extraArgs, reward.count)
		local success, result = pcall(string.format, v4.txt, (math.floor((v5 or 0) / 60)))
		local colorHex = "#FFFFFF"

		for _, v7 in Config.rating.list do
			if v7.lvl ~= reward.rating then
				continue
			end

			colorHex = v7.colorHex
			break
		end

		local enqueue = ClaimQueue.enqueue
		local v7 = {
			image = (typeof(v4.image) ~= "string" or not string.match(v4.image, "^%a+://")) and "" or v4.image,
			name = 0,
			colorHex = 0,
			flyTarget = 0,
			onLanded = 0
		}

		if not success then
			result = v4.txt
		end

		v7.name = result
		v7.colorHex = colorHex
		v7.flyTarget = view.badge

		function v7.onLanded()
			if p.revealToken then
				view.releasedTokens[p.revealToken] = true
			end

			view.hold = math.max(0, view.hold - 1)
			render(reward.itemId)

			if view.hold == 0 then
				pop(reward.itemId)
			end
		end

		enqueue(v7)
	else
		if p.revealToken then
			view.releasedTokens[p.revealToken] = true
		end

		view.hold = math.max(0, view.hold - 1)
		render(reward.itemId)
	end
end

local function flush()
	if v2 or not flag then
		return
	end

	local v4 = v3
	v3 = {}

	for _, v5 in v4 do
		enqueueCard(v5)
	end
end

function BoostDisplay.SetSuppressed(p)
	v2 = p
	flush()
end

function BoostDisplay.Init(instance)
	if flag then
		return
	end

	local v4 = instance:WaitForChild("加成列表")

	for k, definition in BoostService.definitions do
		local view = getView(k)
		view.badge = v4:WaitForChild(definition.badge)
		view.multiplier = view.badge:WaitForChild("倍率")
		view.countdown = view.badge:WaitForChild("倒计时")
		view.scale = view.badge:FindFirstChild("动效缩放") or Instance.new("UIScale")
		view.scale.Name = "动效缩放"
		view.scale.Parent = view.badge
		view.badge.Visible = false
		local v5 = k
		client[definition.field].Changed(function()
			render(v5)
		end)
		render(k)
	end

	flag = true
	local total = 0
	RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total < 0.2 then
			return
		end

		total = 0

		for k in BoostService.definitions do
			render(k)
		end
	end)
	Net:RemoteEvent(BoostService.DAILY_FIRST_MATCH_GRANTED_EVENT).OnClientEvent:Connect(function(value, value2)
		if typeof(value) ~= "string" then
			return
		end

		for _, reward in Config.reward.byCnId[value] or {} do
			if not (reward.itemType == "加成" and BoostService.definitions[reward.itemId]) then
				continue
			end

			local view = getView(reward.itemId)
			view.hold += 1
			render(reward.itemId)
			local v6 = v3
			local revealToken

			if typeof(value2) == "string" then
				revealToken = value2
			end

			table.insert(v6, {
				reward = reward,
				revealToken = revealToken
			})
		end

		flush()
	end)
	flush()
end

return BoostDisplay