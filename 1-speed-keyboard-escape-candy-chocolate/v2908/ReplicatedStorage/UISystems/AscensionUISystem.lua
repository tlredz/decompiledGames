local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientState = require(ReplicatedStorage.ClientState)
local Config = require(ReplicatedStorage.Config)
local ItemRewardUISystem = require(ReplicatedStorage.ItemRewardUISystem)
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
local SoundManager = require(ReplicatedStorage.SoundManager)
local color = Color3.fromRGB(255, 100, 100)
local formatMultiplier = Numbers.formatMultiplier
local formatNumber = Numbers.formatNumber
local playerGui = nil
local flag = false
local flag2 = false
local itemKey = nil
local v = {}
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local ascend = nil
local AscensionUISystem = {}

local function getTagged(tag: string)
	for _, v9 in ipairs(CollectionService:GetTagged(tag)) do
		if v9:IsDescendantOf(playerGui) then
			return v9
		end
	end

	return nil
end

local function bindAscensionTree(instance)
	return {
		fill = instance.LevelReq.Fill,
		levelReqText = instance.LevelReq.TextLabel,
		current = instance.Current,
		next = instance.Next,
		item = instance.Item,
		ascendButton = instance.AscendButton,
		ascendPrice = instance.AscendButton.WinsSpot.Price,
		inactiveAscendButton = instance.InactiveAscendButton,
		inactiveTitle = instance.InactiveAscendButton.Title
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindConfirmedTree(p)
	return {
		newTier = p.NewTier,
		confirmButton = p.ConfirmButton
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getAscensionCount(p)
	return p.GalaxyAscensions[Config.GALAXY_INDEX]
end

local function resolveDisplay(p)
	local rebirths = p.Rebirths
	local count = #Config.REBIRTH_TIERS
	local ascensionCount = getAscensionCount(p) -- equivalent call inferred; original call site unknown
	local currentMult = not (ascensionCount > 0) and 1 or Config.ASCENSION_TIERS[ascensionCount].xpMultiplier
	local nextTier = Config.ASCENSION_TIERS[ascensionCount + 1]
	local winsPrice

	if nextTier then
		winsPrice = nextTier.winsPrice
	end

	return {
		rebirths = rebirths,
		maxRebirths = count,
		currentTier = ascensionCount,
		currentMult = currentMult,
		nextTier = nextTier,
		winsPrice = winsPrice,
		buttonActive = count <= rebirths and nextTier ~= nil,
		canAfford = winsPrice ~= nil and winsPrice <= p.Wins
	}
end

local function applyAscensionDisplay()
	if not v7 then
		return
	end

	local display = resolveDisplay(ClientState:Get())
	local v9 = not (display.maxRebirths > 0) and 1 or math.clamp(display.rebirths / display.maxRebirths, 0, 1)
	v7.fill.Size = UDim2.new(v9, 0, v7.fill.Size.Y.Scale, v7.fill.Size.Y.Offset)
	v7.levelReqText.Text = string.format("REBIRTH %s/%s", display.rebirths, display.maxRebirths)
	v7.current.Text = string.format(
		"Current Tier %s - x%s speed",
		display.currentTier,
		formatMultiplier(display.currentMult)
	)

	if display.nextTier then
		v7.next.Visible = true
		v7.next.Text = string.format("x%s", formatMultiplier(display.nextTier.xpMultiplier))
		v7.item.Visible = display.nextTier.itemKey ~= nil
		local text = formatNumber(display.winsPrice)
		v7.ascendPrice.Text = text
		v7.inactiveTitle.Text = string.format("REACH MAX REBIRTH & %s Wins", text)
	else
		v7.next.Visible = false
		v7.item.Visible = false
	end

	v7.ascendButton.Visible = display.buttonActive
	v7.inactiveAscendButton.Visible = not display.buttonActive
end

local function requestAscend()
	if flag2 then
		return
	end

	local display = resolveDisplay(ClientState:Get())

	if not display.buttonActive then
		return
	end

	if display.canAfford then
		flag2 = true
		ascend:FireServer()
		task.delay(2, function()
			flag2 = false
		end)
	else
		ClientState:CloseCurrentModal()
		NotificationSystem:ShowMessage("You do not have enough wins to ascend yet.", color)
	end
end

local function confirmAscension()
	local v9 = itemKey
	itemKey = nil
	ClientState:CloseCurrentModal()

	if v9 then
		ItemRewardUISystem.playForItemKey(v9, "Rewarded for Ascending!")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isWiredAsActionBtn(instance)
	return CollectionService:HasTag(instance, "UIActionBtn") and instance:GetAttribute("Action") == "RebirthAscend"
end

local function attachAscensionModal(instance)
	if v7 or not (playerGui and instance and instance:IsDescendantOf(playerGui)) then
		return
	end

	v5 = instance
	v7 = bindAscensionTree(instance)
	local mouseButton1ClickConnection = v7.ascendButton.MouseButton1Click:Connect(requestAscend)

	if v2 then
		v2:Add(mouseButton1ClickConnection)
	else
		v3 = mouseButton1ClickConnection
	end

	applyAscensionDisplay()
end

local function attachConfirmedModal(instance)
	if v8 or not (playerGui and instance and instance:IsDescendantOf(playerGui)) then
		return
	end

	v6 = instance
	v8 = bindConfirmedTree(instance)
	local mouseButton1ClickConnection = v8.confirmButton.MouseButton1Click:Connect(confirmAscension)

	if v2 then
		v2:Add(mouseButton1ClickConnection)
	else
		v4 = mouseButton1ClickConnection
	end
end

local function openConfirmed(data)
	if not v8 then
		attachConfirmedModal(getTagged("AscensionConfirmedModal"))
	end

	if v6 and v8 then
		itemKey = data.itemKey
		v8.newTier.Text = string.format("Tier %s - x%s", data.tier, formatMultiplier(data.multiplier))
		ClientState:CloseCurrentModal()
		ClientState:ToggleModal(v6, AscensionUISystem)
		SoundManager:Play("ASCEND")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function openAscensionModal()
	if not v7 then
		attachAscensionModal(getTagged("AscensionModal"))
	end

	if v5 then
		applyAscensionDisplay()
		ClientState:ToggleModal(v5, AscensionUISystem)
	end
end

local function wireOpenButton(instance)
	if v[instance] or not instance:IsDescendantOf(playerGui) or isWiredAsActionBtn(instance) then
		return
	end

	v[instance] = true
	instance.MouseButton1Click:Connect(openAscensionModal)
end

local function initialize()
	if flag then
		return
	end

	flag = true
	playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local updateUI = remotes:WaitForChild("UpdateUI")
	ascend = remotes:WaitForChild("Ascend")
	attachAscensionModal(getTagged("AscensionModal"))
	attachConfirmedModal(getTagged("AscensionConfirmedModal"))
	local onClientEventConnection = ascend.OnClientEvent:Connect(function(p)
		flag2 = false

		if type(p) == "table" then
			openConfirmed(p)
		end
	end)
	local onClientEventConnection2 = updateUI.OnClientEvent:Connect(function(data)
		if data.Rebirths ~= nil or data.GalaxyAscensions ~= nil or data.Wins ~= nil then
			applyAscensionDisplay()
		end
	end)
	local connection = CollectionService:GetInstanceAddedSignal("RebirthAscend"):Connect(function(p)
		task.defer(wireOpenButton, p)
	end)
	local connection2 = CollectionService:GetInstanceAddedSignal("AscensionModal"):Connect(function(p)
		task.defer(attachAscensionModal, p)
	end)
	local connection3 = CollectionService:GetInstanceAddedSignal("AscensionConfirmedModal"):Connect(function(p)
		task.defer(attachConfirmedModal, p)
	end)

	for _, v9 in ipairs(CollectionService:GetTagged("RebirthAscend")) do
		if v[v9] or not v9:IsDescendantOf(playerGui) or not (not CollectionService:HasTag(v9, "UIActionBtn") or v9:GetAttribute("Action") ~= "RebirthAscend") then
			continue
		end

		v[v9] = true
		v9.MouseButton1Click:Connect(openAscensionModal)
	end

	v2 = Janitor.new()

	if v3 then
		v2:Add(v3)
	end

	if v4 then
		v2:Add(v4)
	end

	v2:Add(onClientEventConnection)
	v2:Add(onClientEventConnection2)
	v2:Add(connection)
	v2:Add(connection2)
	v2:Add(connection3)
end

function AscensionUISystem.Start()
	initialize()
end

function AscensionUISystem.InitLogic()
	initialize()
	applyAscensionDisplay()
end

function AscensionUISystem.open()
	initialize()
	openAscensionModal() -- equivalent call inferred; original call site unknown
end

function AscensionUISystem.OnClose(_)
	flag2 = false
end

return AscensionUISystem