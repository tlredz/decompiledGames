local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local BonusManager = require(ReplicatedStorage.BonusManager)
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local Numbers = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Numbers"))
local MarketplaceInfoCache = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("MarketplaceInfoCache"))
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local requestCheckpointTp = remotes:WaitForChild("RequestCheckpointTp")
local promptCheckpointProduct = remotes:WaitForChild("PromptCheckpointProduct")
local checkpointTpSuccess = remotes:WaitForChild("CheckpointTpSuccess")
local gameplayRestrictions = ReplicatedStorage:WaitForChild("CurrentGameplayConfigs"):WaitForChild("GameplayRestrictions")
local color = Color3.fromRGB(255, 80, 80)

-- equivalent calls inferred from this helper; original call sites unknown
local function isStageTpBlocked()
	return gameplayRestrictions:GetAttribute("StageTeleportLocked") == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function notifyBlocked()
	NotificationSystem:ShowMessage("Teleport disabled during the event", color)
end

local v = {}

for _, v2 in ipairs(Config.CHECKPOINTS) do
	if v2.RobuxProductId and v2.RobuxProductId ~= 0 then
		v[v2.RobuxProductId] = true
	end
end

for _, skipCheckpoint in ipairs(Config.SkipCheckpoints) do
	if skipCheckpoint.RobuxProductId and skipCheckpoint.RobuxProductId ~= 0 then
		v[skipCheckpoint.RobuxProductId] = true
	end
end

local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getDisplayWinPrice(winPrice)
	return (math.floor(winPrice * BonusManager:GetWinsMultiplier(localPlayer)))
end

local function applyWinPriceLabel(button, p)
	local displayWinPrice = getDisplayWinPrice(p.WinPrice) -- equivalent call inferred; original call site unknown
	local price = button:FindFirstChild("Price", true)

	if price and price:IsA("TextLabel") then
		price.Text = Numbers.formatNumber(displayWinPrice)
	elseif button:IsA("TextButton") then
		button.Text = Numbers.formatNumber(displayWinPrice)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshWinPriceLabels()
	for _, v3 in ipairs(v2) do
		applyWinPriceLabel(v3.btn, v3.entry)
	end
end

for i = 1, #Config.CHECKPOINTS do
	local v3 = "ButtonTpCheckpoint" .. i
	local entry = Config.CHECKPOINTS[i]
	local v6 = i

	local function setupButton(button)
		if not button:IsA("GuiButton") then
			return
		end

		table.insert(v2, {
			btn = button,
			entry = entry
		})
		button.MouseButton1Click:Connect(function()
			if isStageTpBlocked() then
				notifyBlocked() -- equivalent call inferred; original call site unknown
			else
				requestCheckpointTp:FireServer(v6, "wins")
			end
		end)
		applyWinPriceLabel(button, entry)
	end

	for _, v7 in ipairs(CollectionService:GetTagged(v3)) do
		setupButton(v7)
	end

	CollectionService:GetInstanceAddedSignal(v3):Connect(setupButton)
end

BonusManager.Changed:Connect(function()
	refreshWinPriceLabels() -- equivalent call inferred; original call site unknown
end)

for i = 1, #Config.CHECKPOINTS do
	local v3 = "DevButtonTpCheckpoint" .. i
	local v5 = i
	local v6 = Config.CHECKPOINTS[i]

	local function setupDevButton(button)
		if not button:IsA("GuiButton") then
			return
		end

		button.MouseButton1Click:Connect(function()
			if isStageTpBlocked() then
				notifyBlocked() -- equivalent call inferred; original call site unknown
			else
				requestCheckpointTp:FireServer(v5, "robux")
			end
		end)

		if v6.RobuxProductId and v6.RobuxProductId ~= 0 then
			MarketplaceInfoCache.Request(v6.RobuxProductId, Enum.InfoType.Product, function(p)
				if p and p.PriceInRobux then
					local price = button:FindFirstChild("Price", true)

					if price and price:IsA("TextLabel") then
						price.Text = tostring(p.PriceInRobux)
					elseif button:IsA("TextButton") then
						button.Text = tostring(p.PriceInRobux)
					end
				end
			end)
		end
	end

	for _, v7 in ipairs(CollectionService:GetTagged(v3)) do
		setupDevButton(v7)
	end

	CollectionService:GetInstanceAddedSignal(v3):Connect(setupDevButton)
end

promptCheckpointProduct.OnClientEvent:Connect(function(p, _)
	if p == 0 then
		NotificationSystem:ShowMessage("Purchase error", color)
	end
end)
MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, p2, p3)
	if p ~= localPlayer.UserId then
		return
	end

	if not p3 and v[p2] then
		NotificationSystem:ShowMessage("Purchase error", color)
	end
end)

local function getModalByTag(tag)
	for _, v3 in ipairs(CollectionService:GetTagged(tag)) do
		if v3:IsDescendantOf(playerGui) then
			return v3
		end
	end
end

checkpointTpSuccess.OnClientEvent:Connect(function()
	local modalByTag = getModalByTag("CheckpointModal")

	if modalByTag and ClientState.ActiveModal == modalByTag then
		ClientState:CloseCurrentModal()
	end

	local BUY = Config.SOUNDS.BUY
	local sound = Instance.new("Sound")
	sound.SoundId = BUY.ID
	sound.Volume = BUY.Volume
	sound.Parent = SoundService
	sound:Play()
	Debris:AddItem(sound, 5)
end)