local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AutoOpenModalConfig = require(ReplicatedStorage.FeatureConfigs.AutoOpenModalConfig)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local Config = require(script.Config)
local speedBoostV3Notice = AutoOpenModalConfig.Ids.SpeedBoostV3Notice

local function startClientNotice()
	local AutoOpenModalSystem = require(ReplicatedStorage.UISystems.AutoOpenModalSystem)
	local InfoModalUISystem = require(ReplicatedStorage.UISystems.InfoModalUISystem)
	local ItemRewardUISystem = require(ReplicatedStorage.ItemRewardUISystem)
	local updateUI = ReplicatedStorage.Remotes:WaitForChild("UpdateUI")
	local v = false
	local extraSpeedBoostTier = 0
	local v2 = false
	local v3 = false

	local function playGrantedItems(p: number)
		local v4 = Items.ITEMS[Config.itemKey]
		local name = v4.name

		if p > 1 then
			name = v4.name .. " x" .. p
		end

		ItemRewardUISystem.play({
			icon = v4.icon,
			topText = "Granted for G2 Speed Boosts:",
			itemName = name,
			nameColor = Items.RARITY_COLORS[v4.rarity],
			tier = 0
		})
	end

	local function openNotice()
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

		while playerGui:FindFirstChild("Loading") do
			task.wait(0.2)
		end

		task.wait(0.3)

		if not AutoOpenModalSystem.IsSeen(speedBoostV3Notice) then
			local v4 = extraSpeedBoostTier
			InfoModalUISystem:Open(Config.title, string.format(Config.description, v4), Config.containerSize, function()
				playGrantedItems(v4)
			end)
			AutoOpenModalSystem.MarkSeen(speedBoostV3Notice)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function tryOpen()
		if v and v2 and extraSpeedBoostTier > 0 and not (v3 or AutoOpenModalSystem.IsSeen(speedBoostV3Notice)) then
			v3 = true
			task.spawn(openNotice)
		end
	end

	updateUI.OnClientEvent:Connect(function(p)
		if p then
			if p.ExtraSpeedBoostTier ~= nil then
				extraSpeedBoostTier = p.ExtraSpeedBoostTier
				v = true
			end

			if p.SeenAutoOpenModals ~= nil then
				v2 = true
			end

			tryOpen() -- equivalent call inferred; original call site unknown
		end
	end)
	local ClientState = require(ReplicatedStorage.ClientState)
	local v4 = ClientState:Get()

	if AutoOpenModalSystem.HasSeenData() or v4.SeenAutoOpenModals ~= nil then
		v2 = true
	end

	if v4.ExtraSpeedBoostTier > 0 then
		extraSpeedBoostTier = v4.ExtraSpeedBoostTier
		v = true
	end

	tryOpen() -- equivalent call inferred; original call site unknown
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsClient() then
			startClientNotice()
		end
	end
})
return {}