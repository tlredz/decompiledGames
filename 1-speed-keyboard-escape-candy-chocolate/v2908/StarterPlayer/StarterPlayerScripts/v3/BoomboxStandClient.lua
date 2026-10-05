local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function waitForRelics(p: number)
	local v = os.clock() + p

	while os.clock() < v do
		local relicsXYZ = ReplicatedStorage:FindFirstChild("RelicsXYZ", true)

		if relicsXYZ and relicsXYZ:IsA("ModuleScript") then
			return relicsXYZ
		else
			task.wait(0.5)
		end
	end

	return nil
end

local v = waitForRelics(30)

if not v then
	warn("[BoomboxStand] RelicsXYZ module not found in ReplicatedStorage — stands disabled.")
	return
end

local module = require(v)
local boombox = module.Boombox
local Marketplace = require(v.Shared.Marketplace)
local RobuxShopConfig = require(ReplicatedStorage.FeatureConfigs.RobuxShopConfig)
local RelicsPlayerClient = require(ReplicatedStorage.UISystems.RelicsPlayerClient)
local assetId = RobuxShopConfig.Boombox.AssetId
local v2 = {
	ProductId = assetId,
	ProductType = Enum.InfoType.Asset,
	AssetId = assetId,
	AccessoryType = Enum.AccessoryType.Back,
	Priority = 0,
	Name = RobuxShopConfig.Boombox.Name or "Boombox"
}

local function getStandTop(stand)
	local cFrame, size

	if stand:IsA("BasePart") then
		cFrame = stand.CFrame
		size = stand.Size
	elseif stand:IsA("Model") then
		cFrame, size = stand:GetBoundingBox()
	else
		return nil
	end

	local rotation = cFrame.Rotation
	local v3 = (math.abs(rotation.XVector.Y) * size.X + math.abs(rotation.YVector.Y) * size.Y + math.abs(rotation.ZVector.Y) * size.Z) * 0.5
	local lookVector = cFrame.LookVector
	local vector = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector.Magnitude < 0.01 then
		local rightVector = cFrame.RightVector
		vector = Vector3.new(rightVector.Z, 0, -rightVector.X)
	end

	local v4 = not (vector.Magnitude > 0.01) and 0 or math.atan2(-vector.X, -vector.Z)
	local v5 = cFrame.Position + Vector3.new(0, v3, 0)
	return CFrame.new(v5) * CFrame.Angles(0, v4, 0)
end

local function getPromptParent(model)
	if model:IsA("Model") then
		return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model
	end

	return model
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getActiveConfig()
	local boomboxConfigs = boombox.GetBoomboxConfigs()

	if #boomboxConfigs > 0 then
		return boomboxConfigs[1]
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getConfigName(config)
	if type(config.Name) == "string" and config.Name ~= "" then
		return config.Name
	end

	local source = config.Source

	if source and type(source.Name) == "string" and source.Name ~= "" then
		return source.Name
	end

	return "Boombox"
end

local function playerOwnsBoombox()
	local rELICSxyz_OwnsBoombox = localPlayer:GetAttribute("RELICSxyz_OwnsBoombox") or boombox.PlayerOwnsBoomboxAsync(localPlayer)

	if not rELICSxyz_OwnsBoombox then
		local success, result = pcall(function()
			return MarketplaceService:PlayerOwnsAsset(localPlayer, assetId)
		end)
		rELICSxyz_OwnsBoombox = success and result == true
	end

	return rELICSxyz_OwnsBoombox == true
end

local v3 = {}

local function getBuyText(config)
	local productId = config.ProductId or config.AssetId

	if v3[productId] then
		return v3[productId]
	end

	local productType = config.ProductType or Enum.InfoType.Asset
	local v4, v5 = Marketplace.GetProductInfo(productId, productType):await()
	local v6

	if v4 and v5 and v5.PriceInRobux then
		v6 = `Buy {v5.PriceInRobux} R$`
		v3[productId] = v6
	else
		return "Buy"
	end

	return v6
end

local v4 = {}

local function updatePrompt(data)
	local prompt = data.prompt
	local config = data.config

	if not (prompt and config) then
		return
	end

	local configName = getConfigName(config) -- equivalent call inferred; original call site unknown
	prompt.ObjectText = configName

	if data.owns then
		prompt.ActionText = "Open"
		return
	end

	prompt.ActionText = "Buy"
	task.spawn(function()
		local buyText = getBuyText(config)

		if data.prompt == prompt and not data.owns then
			prompt.ActionText = buyText
		end
	end)
end

local function promptPurchase(config)
	local productId = config.ProductId or config.AssetId
	local productType = config.ProductType or Enum.InfoType.Asset

	if productType == Enum.InfoType.GamePass then
		MarketplaceService:PromptGamePassPurchase(localPlayer, productId)
	elseif productType == Enum.InfoType.Product then
		MarketplaceService:PromptProductPurchase(localPlayer, productId)
	else
		MarketplaceService:PromptPurchase(localPlayer, productId)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openRelicsPlayer()
	RelicsPlayerClient.Init()
	local v5 = RelicsPlayerClient.Get()

	if v5 then
		v5:SetWindowState("Full")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onTriggered(p)
	local config = p.config

	if config then
		if p.owns then
			openRelicsPlayer() -- equivalent call inferred; original call site unknown
		else
			promptPurchase(config)
		end
	end
end

local function clearBuild(state)
	state.config = nil
	state.buildId += 1

	for _, buildConnection in state.buildConnections do
		buildConnection:Disconnect()
	end

	table.clear(state.buildConnections)

	if state.prompt then
		state.prompt:Destroy()
		state.prompt = nil
	end

	if state.promptAttachment then
		state.promptAttachment:Destroy()
		state.promptAttachment = nil
	end
end

local function buildStand(state, config)
	if state.destroyed or state.config then
		return
	end

	state.config = config
	state.buildId += 1
	local buildId = state.buildId
	local stand = state.stand
	task.spawn(function()
		local standTop = getStandTop(stand)

		if standTop and not state.destroyed and state.buildId == buildId then
			state.owns = playerOwnsBoombox()
			local proximityPrompt = Instance.new("ProximityPrompt")
			proximityPrompt.Name = "BoomboxStandPrompt"
			proximityPrompt.MaxActivationDistance = 20
			proximityPrompt.RequiresLineOfSight = false
			local primaryPart = stand

			if primaryPart:IsA("Model") then
				primaryPart = primaryPart.PrimaryPart or primaryPart:FindFirstChildWhichIsA("BasePart") or primaryPart
			end

			local attachment = Instance.new("Attachment")
			attachment.Name = "BoomboxStandPromptAttachment"
			attachment.Parent = primaryPart
			attachment.WorldCFrame = standTop * CFrame.new(0, 2.5, 0)
			state.promptAttachment = attachment
			proximityPrompt.Parent = attachment
			state.prompt = proximityPrompt
			table.insert(state.buildConnections, proximityPrompt.Triggered:Connect(function()
				onTriggered(state) -- equivalent call inferred; original call site unknown
			end))
			updatePrompt(state)
		elseif not standTop then
			warn((`[BoomboxStand] {stand:GetFullName()} is neither a BasePart nor a Model.`))

			if state.buildId == buildId then
				state.config = nil
			end
		end
	end)
end

local function refreshOwnership()
	local owns = playerOwnsBoombox()

	for _, v6 in v4 do
		if not (v6.config and v6.owns ~= owns) then
			continue
		end

		v6.owns = owns
		updatePrompt(v6)
	end
end

local function setupStand(stand)
	if v4[stand] then
		return
	end

	local v5 = {
		stand = stand,
		config = nil,
		prompt = nil,
		promptAttachment = nil,
		buildConnections = {},
		buildId = 0,
		destroyed = false,
		owns = false
	}
	v4[stand] = v5
	local activeConfig = getActiveConfig() -- equivalent call inferred; original call site unknown
	task.spawn(buildStand, v5, activeConfig)
end

local function teardownStand(p)
	local v5 = v4[p]

	if v5 then
		v5.destroyed = true
		v4[p] = nil
		clearBuild(v5)
	end
end

local function rebuildAllStands()
	local activeConfig = getActiveConfig() -- equivalent call inferred; original call site unknown

	for _, v5 in v4 do
		if v5.destroyed then
			continue
		end

		clearBuild(v5)
		task.spawn(buildStand, v5, activeConfig)
	end
end

for _, v5 in CollectionService:GetTagged("BoomboxStand") do
	task.spawn(setupStand, v5)
end

CollectionService:GetInstanceAddedSignal("BoomboxStand"):Connect(function(p)
	task.spawn(setupStand, p)
end)
CollectionService:GetInstanceRemovedSignal("BoomboxStand"):Connect(teardownStand)
boombox.BoomboxConfigAdded:Connect(rebuildAllStands)
boombox.BoomboxConfigRemoved:Connect(rebuildAllStands)
task.spawn(function()
	boombox.GetBoomboxOwnershipChangedSignal(localPlayer):Connect(refreshOwnership)
end)
localPlayer:GetAttributeChangedSignal("RELICSxyz_OwnsBoombox"):Connect(refreshOwnership)

local function onPurchaseFinished(p, _: number, flag: boolean)
	if p == localPlayer and flag then
		task.defer(refreshOwnership)
	end
end

MarketplaceService.PromptPurchaseFinished:Connect(onPurchaseFinished)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(onPurchaseFinished)