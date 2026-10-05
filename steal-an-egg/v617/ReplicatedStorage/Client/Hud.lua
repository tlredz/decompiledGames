local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUI = require(ReplicatedStorage.Client.GUI)
local v = {
	Game = "GameHUD",
	Treadmill = "TradmilHud"
}
local v2 = {
	EggsButton = { "RightButtons", "EggsButton" },
	ExperimentTimer = { "BottomRight", "ExperimentTimer" },
	ExperimentTimerValue = { "BottomRight", "ExperimentTimer", "Value" },
	IndexButton = { "LeftControls", "IndexBTN" },
	IndexNotificationBadge = { "LeftControls", "IndexBTN", "NotificationBadge" },
	Money = { "BottomLeft", "Money" },
	MoneyIcon = { "BottomLeft", "Money", "Icon" },
	MoneyValue = { "BottomLeft", "Money", "Value" },
	NightTimer = { "BottomRight", "NightTimer" },
	NightTimerIcon = { "BottomRight", "NightTimer", "ImageLabel" },
	NightTimerValue = { "BottomRight", "NightTimer", "Value" },
	PetsButton = { "RightButtons", "PetsButton" },
	QuestlineBadge = { "RightButtons", "QuestlineButton", "Badge" },
	QuestlineButton = { "RightButtons", "QuestlineButton" },
	RiftButton = { "RightButtons", "RiftButton" },
	ShopButton = { "LeftControls", "ShopBTN" },
	SlowToggle = { "LeftControls", "Slowmode" },
	SlowToggleHitbox = { "LeftControls", "Slowmode", "Hitbox" },
	SlowToggleKnob = { "LeftControls", "Slowmode", "Btn" },
	SlowToggleLabel = { "LeftControls", "Slowmode", "txt" },
	Speed = { "BottomLeft", "Speed" },
	SpeedMultiButton = { "LeftControls", "SpeedMulti" },
	SpeedMultiShine = { "LeftControls", "SpeedMulti", "Glow" },
	SpeedShopButton = { "BottomLeft", "Speed", "ShopBTN" },
	SpeedValue = { "BottomLeft", "Speed", "Value" },
	FriendBoost = { "BottomLeft", "FriendBoost" },
	TemporarySpeedBoost = { "BottomLeft", "TemporarySpeedBoost" }
}
local HUD = GUI.HUD()
HUD.ResetOnSpawn = false
local frames = {}
local v3 = {}
local v4 = {}
local walk

walk = function(child, p, p2: number)
	local v5 = p[p2]

	if v5 == nil then
		return child
	end

	for _, child2 in child:GetChildren() do
		if child2.Name ~= v5 then
			continue
		end

		local v6 = walk(child2, p, p2 + 1)

		if v6 ~= nil then
			return v6
		end
	end

	return nil
end

local function variantFrame(p: string)
	local v5 = frames[p]

	if v5 then
		return v5
	end

	local v6 = v[p]
	assert(v6 ~= nil, (`no HUD variant named {p}`))
	local frame = HUD:FindFirstChild(v6)
	local v7

	if frame == nil then
		v7 = false
	else
		v7 = frame:IsA("Frame")
	end

	assert(v7, (`HUD.{v6} must be a Frame`))
	frames[p] = frame
	return frame
end

-- equivalent calls inferred from this helper; original call sites unknown
local function chainFor(p: string)
	local v5 = v2[p]
	assert(v5 ~= nil, (`no HUD role is registered under {p}`))
	return v5
end

function v4.Screen()
	return HUD
end

function v4.Frame(value: string?)
	local v5 = value or "Game"
	local v6 = frames[v5]

	if v6 then
		return v6
	end

	local v7 = v[v5]
	assert(v7 ~= nil, (`no HUD variant named {v5}`))
	local frame = HUD:FindFirstChild(v7)
	local v8

	if frame == nil then
		v8 = false
	else
		v8 = frame:IsA("Frame")
	end

	assert(v8, (`HUD.{v7} must be a Frame`))
	frames[v5] = frame
	return frame
end

function v4.Find(p: string, value: string?)
	local v5 = value or "Game"
	local v6 = v3[v5]

	if v6 == nil then
		v6 = {}
		v3[v5] = v6
	end

	if v6[p] ~= nil then
		return v6[p]
	end

	local frame = frames[v5]

	if not frame then
		local v8 = v[v5]
		assert(v8 ~= nil, (`no HUD variant named {v5}`))
		frame = HUD:FindFirstChild(v8)
		local v9

		if frame == nil then
			v9 = false
		else
			v9 = frame:IsA("Frame")
		end

		assert(v9, (`HUD.{v8} must be a Frame`))
		frames[v5] = frame
	end

	v6[p] = walk(frame, chainFor(p), 1)
	return v6[p]
end

function v4.Get(p: string, value: string?)
	local v5 = v4.Find(p, value)
	local v6 = v5 ~= nil
	local v7 = v[value or "Game"]
	assert(v6, (`HUD.{v7}.{table.concat(chainFor(p), ".")} is missing`))
	return v5
end

function v4.Every(p: string)
	local result = {}

	for k in v do
		local v5 = v4.Find(p, k)

		if v5 ~= nil then
			table.insert(result, v5)
		end
	end

	return result
end

function v4.SetTreadmillActive(visible: boolean)
	local game2 = frames.Game

	if not game2 then
		local game3 = v.Game
		assert(game3 ~= nil, "no HUD variant named Game")
		game2 = HUD:FindFirstChild(game3)
		local v5

		if game2 == nil then
			v5 = false
		else
			v5 = game2:IsA("Frame")
		end

		assert(v5, (`HUD.{game3} must be a Frame`))
		frames.Game = game2
	end

	game2.Visible = not visible
	local treadmill = frames.Treadmill

	if not treadmill then
		local treadmill2 = v.Treadmill
		assert(treadmill2 ~= nil, "no HUD variant named Treadmill")
		treadmill = HUD:FindFirstChild(treadmill2)
		local v5

		if treadmill == nil then
			v5 = false
		else
			v5 = treadmill:IsA("Frame")
		end

		assert(v5, (`HUD.{treadmill2} must be a Frame`))
		frames.Treadmill = treadmill
	end

	treadmill.Visible = visible
end

return table.freeze(v4)