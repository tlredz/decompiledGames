local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local engine = ReplicatedStorage:WaitForChild("Engine")
local Config = require(engine:WaitForChild("Service"):WaitForChild("Config"))
local TimeService = require(engine:WaitForChild("Service"):WaitForChild("TimeService"))
local LimitedPackService = require(engine:WaitForChild("Service"):WaitForChild("LimitedPackService"))
local LimitedPackShowcase = require(engine:WaitForChild("Service"):WaitForChild("LimitedPackShowcase"))
local UnifiedPanel = require(engine:WaitForChild("Service"):WaitForChild("GamepadSupport"):WaitForChild("UnifiedPanel"))
local DevProductService = require(engine:WaitForChild("Market"):WaitForChild("DevProductService"))
local Observers = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Observers"))
local ClaimQueue = require(script.Parent:WaitForChild("ClaimQueue"))
local UIManager = require(script.Parent:WaitForChild("UIManager"))
local ShowcaseCamera = require(script:WaitForChild("ShowcaseCamera"))
local FullSetShowcase = require(script:WaitForChild("FullSetShowcase"))
local v = "完整套装"
local childrenByChildName = {}
local v2 = nil
local v3 = nil
local ShowcaseLighting = require(script:WaitForChild("ShowcaseLighting"))
local LobbyEntry = require(script:WaitForChild("LobbyEntry"))
local v4 = nil
local LimitedPack = {}
local v5 = {
	["限定礼包"] = true,
	["通用确认框"] = true,
	["抽奖效果"] = true,
	ClaimQueueFlightLayer = true,
	["赠礼UI"] = true,
	ProductPurchaseGui = true
}
local v6 = {
	"RewardsMenu",
	"PlayerPanel",
	"EmoteWheel",
	"Settings"
}
local flag = false
local flag2 = false
local v7 = true
local v8 = nil
local v9 = nil
local v10 = nil
local v11 = nil
local v12 = nil
local size = nil
local v13 = {}
local v14 = nil
local v15 = {}
local v16 = ""
local v17 = nil
local screenGuis = {}
local v18 = nil
local v19 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreFullSets()
	local parent = v18 and v18:FindFirstChild("全套展示")

	if not (parent and v19) then
		return
	end

	for _, child in v19:GetChildren() do
		child.Parent = parent
	end

	v19:Destroy()
	v19 = nil
end

local function showOnlyFullSet(p)
	local v20 = v18 and v18:FindFirstChild("全套展示")

	if not v20 then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "限定礼包隐藏全套展示"
	folder.Parent = ReplicatedStorage
	v19 = folder

	for _, child in v20:GetChildren() do
		if child ~= p then
			child.Parent = folder
		end
	end
end

local v20 = nil
local v21 = nil
local v22 = nil
local updates = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function isImage(value)
	return typeof(value) == "string" and string.match(value, "^%a+://") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ratingColorHex(rating: number?)
	for _, v23 in Config.rating.list do
		if v23.lvl == rating then
			return v23.colorHex
		end
	end

	return "#FFFFFF"
end

local function getRewardVisuals(p: string)
	local result = {}

	for _, v23 in Config.reward.byCnId[p] or {} do
		local v24

		if v23.itemType == "小球" then
			v24 = Config.ball.byCnId[v23.itemId]
		elseif v23.itemType == "皮肤" then
			v24 = Config.skin.byCnId[v23.itemId]
		end

		if not v24 then
			continue
		end

		for _ = 1, v23.count do
			local v25 = {
				image = not isImage(v24.image) and "" or v24.image,
				name = v24.displayName or v24.name,
				colorHex = 0
			}
			local colorHex = ratingColorHex(v24.rating) -- equivalent call inferred; original call site unknown
			v25.colorHex = colorHex
			table.insert(result, v25)
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPrice(p)
	local v23 = DevProductService.products.byProductKey[p.productKey]

	if v23 then
		return v23.PriceInRobux
	end

	return p.robuxPrice
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findGroup(p: string?)
	for _, v23 in v15 do
		if v23.group == p then
			return v23
		end
	end

	return nil
end

local getGroupRemainingSeconds = LimitedPackService.getGroupRemainingSeconds

local function setBackgroundUiHidden(flag3: boolean)
	if flag3 then
		for _, screenGui in Players.LocalPlayer.PlayerGui:GetChildren() do
			if not screenGui:IsA("ScreenGui") or not screenGui.Enabled or v5[screenGui.Name] then
				continue
			end

			screenGui.Enabled = false
			table.insert(screenGuis, screenGui)
		end
	else
		for _, v23 in screenGuis do
			if v23.Parent then
				v23.Enabled = true
			end
		end

		table.clear(screenGuis)
	end

	for _, v23 in v6 do
		local v24 = UIManager.Get(v23)

		if v24 and v24.SetTopbarEnabled then
			v24.SetTopbarEnabled(not flag3)
		end
	end
end

local function enterShowcase()
	if not v4 then
		v4 = ShowcaseLighting.Start()
	end

	if v18 then
		v18.Parent = workspace
	end

	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and not v22 then
		v22 = {
			humanoid = humanoid,
			walkSpeed = humanoid.WalkSpeed,
			jumpPower = humanoid.JumpPower,
			jumpHeight = humanoid.JumpHeight
		}
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
	end
end

local function exitShowcase()
	restoreFullSets() -- equivalent call inferred; original call site unknown

	if v4 then
		v4()
		v4 = nil
	end

	local v23 = v21 ~= nil

	if v21 then
		v21()
		v21 = nil
		v3 = nil
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera and v23 then
		local character = Players.LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid and currentCamera.CameraSubject ~= humanoid then
			currentCamera.CameraSubject = humanoid
		end
	end

	if v22 and v22.humanoid.Parent then
		v22.humanoid.WalkSpeed = v22.walkSpeed
		v22.humanoid.JumpPower = v22.jumpPower
		v22.humanoid.JumpHeight = v22.jumpHeight
	end

	v22 = nil

	if v18 then
		v18.Parent = ReplicatedStorage:WaitForChild("美术素材")
	end
end

local function findOnSalePack(p, p2: string)
	for _, v23 in not p and {} or p.packs do
		if v23.type == p2 and LimitedPackService.isOnSale(v23) then
			return v23
		end
	end

	return nil
end

local function renderPurchaseAreas(group)
	local visible = findOnSalePack(group, "单卖") ~= nil
	v12.Visible = visible
	local firstChild = v12:FindFirstChild("单卖框")
	local size2

	if findOnSalePack(group, "全套") then
		size2 = size
	else
		size2 = UDim2.fromScale(1, 0.895)
	end

	firstChild.Size = size2

	for _, pack in group.packs do
		if LimitedPackService.isOnSale(pack) and pack.type ~= "单卖" and pack.type ~= "全套" then
			warn((`[LimitedPack] {pack.cnId} 的 type={pack.type} 在 购买区列表 下找不到 {pack.type}框，不显示`))
		end
	end

	for _, v25 in v13 do
		local v26 = findOnSalePack(group, v25.packType)
		local visible2

		if v26 == nil then
			visible2 = false
		else
			visible2 = v25.dual == visible
		end

		v25.row.Visible = visible2
		v25.area.Visible = visible2
		v25.giftFrame.Visible = visible2

		if not v26 then
			continue
		end

		local rewardVisuals = getRewardVisuals(v26.rewardId)

		if #rewardVisuals > #v25.goodsCards then
			warn((`[LimitedPack] {v26.cnId} 有 {#rewardVisuals} 个物品，超过 {v25.area.Name} 预留的 {#v25.goodsCards} 个商品卡片，多出的不显示`))
		end

		for k, goodsCard in v25.goodsCards do
			local rewardVisual = rewardVisuals[k]
			goodsCard.Visible = rewardVisual ~= nil
			local child = v25.area:FindFirstChild("商品名称" .. k)

			if child then
				child.Visible = rewardVisual ~= nil
				child.Text = not rewardVisual and "" or rewardVisual.name or ""
			end

			if not rewardVisual then
				continue
			end

			local findFirstChild = goodsCard:FindFirstChild("商品图标")
			findFirstChild.Image = rewardVisual.image
		end

		local priceLabel = v25.priceLabel
		local price = getPrice(v26) -- equivalent call inferred; original call site unknown
		priceLabel.Text = tostring(price)
	end
end

local function renderPreview()
	if not (flag2 and v18) then
		return
	end

	local group = findGroup(v17) -- equivalent call inferred; original call site unknown

	if not group then
		return
	end

	LimitedPackShowcase.Close()

	if v2 then
		v2()
		v2 = nil
	end

	restoreFullSets() -- equivalent call inferred; original call site unknown

	for _, v24 in childrenByChildName do
		local v25 = v == "战斗预览"
		local findFirstChild = v24:FindFirstChild("按钮文字")
		findFirstChild.Text = v25 and "Full Set" or "Combat Preview"
	end

	local child

	if v == "完整套装" then
		local firstChild = v18:FindFirstChild("全套展示")
		child = firstChild and firstChild:FindFirstChild(group.group)
	else
		child = v18:FindFirstChild("限定包")
	end

	local v25

	if v == "完整套装" then
		v25 = child
	end

	showOnlyFullSet(v25)

	if not child then
		warn("[LimitedPack] 缺少 " .. v .. " 场景: " .. group.group)
		return
	end

	local part = child:FindFirstChild("摄像机") or v20

	if part and part:IsA("BasePart") then
		if v3 then
			v3(child, part)
		else
			v21, v3 = ShowcaseCamera.Start(child, v9, part)
		end
	end

	if v == "完整套装" then
		v2 = FullSetShowcase.Start(child, group)
	else
		LimitedPackShowcase.Open(child, group)
	end
end

local function selectGroup(p: string)
	local group = findGroup(p) -- equivalent call inferred; original call site unknown

	if not group then
		return
	end

	v17 = p
	local pack = group.packs[1]

	for _, pack2 in group.packs do
		if pack2.type ~= "全套" then
			continue
		end

		pack = pack2
		break
	end

	v11.Text = not pack and "" or pack.name
	renderPurchaseAreas(group)
	renderPreview()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshCountdowns()
	local group = findGroup(v17) -- equivalent call inferred; original call site unknown

	if group then
		v10.Text = "Ends in " .. TimeService.formatCountdown(getGroupRemainingSeconds(group))
	end
end

function LimitedPack.Close(flag3: boolean?)
	if not flag2 then
		return
	end

	if flag3 == nil then
		flag3 = v7
	end

	flag2 = false
	v8.Visible = false
	LimitedPackShowcase.Close()

	if v2 then
		v2()
		v2 = nil
	end

	exitShowcase()
	setBackgroundUiHidden(false)
	local store = flag3 ~= false and UIManager.Get("Store")

	if store then
		store.OpenHome()
	end
end

local function refreshAll()
	local activeGroups = LimitedPackService.getActiveGroups()
	local cnIds = {}

	for _, activeGroup in activeGroups do
		for _, pack in activeGroup.packs do
			table.insert(cnIds, pack.cnId)
		end
	end

	local joined = table.concat(cnIds, "|")

	if joined ~= v16 then
		v16 = joined
		v15 = activeGroups

		if v8 and flag2 then
			-- equivalent call inferred; original call site unknown
			if findGroup(v17) then
				selectGroup(v17)
			elseif activeGroups[1] then
				selectGroup(activeGroups[1].group)
			else
				LimitedPack.Close()
			end
		end
	end

	if flag2 then
		refreshCountdowns() -- equivalent call inferred; original call site unknown
	end

	for _, v23 in updates do
		v23()
	end
end

function LimitedPack.Open(p: string?, p2)
	refreshAll()
	local group = findGroup(p) -- equivalent call inferred; original call site unknown
	local v23 = group or v15[1]

	if not v23 then
		return false
	end

	if not flag2 then
		flag2 = true
		v = "完整套装"
		v7 = not p2 or p2.returnToStore ~= false
		local store = UIManager.Get("Store")

		if store and store.IsOpen() then
			store.Close()
		end

		setBackgroundUiHidden(true)
		enterShowcase()
		v8.Visible = true
	end

	selectGroup(v23.group)
	refreshCountdowns() -- equivalent call inferred; original call site unknown
	return true
end

function LimitedPack.IsOpen()
	return flag2
end

function LimitedPack:BindStoreEntries(callback)
	local v23 = {}

	for _, guiObject in self:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local v24 = {
			card = guiObject,
			cnId = guiObject.Name,
			countdown = guiObject:FindFirstChild("库存或期限")
		}
		table.insert(v23, v24)
		local firstChild = guiObject:FindFirstChild("礼包购买按钮")
		local firstChild2 = guiObject:FindFirstChild("整卡跳转按钮")

		if firstChild2 then
			firstChild2:SetAttribute("StoreGamepadAction", true)
			local v25 = v24
			ButtonActions.Bind(firstChild2, function()
				local pack = LimitedPackService.getPack(v25.cnId)

				if pack and LimitedPackService.isOnSale(pack) then
					LimitedPack.Open(pack.group)
				end
			end)
		end

		local firstChild3 = guiObject:FindFirstChild("查看按钮")

		if firstChild3 then
			callback(firstChild3)
			firstChild3:SetAttribute("StoreGamepadAction", true)
			local v25 = v24
			ButtonActions.Bind(firstChild3, function()
				local pack = LimitedPackService.getPack(v25.cnId)

				if pack and LimitedPackService.isOnSale(pack) then
					LimitedPack.Open(pack.group)
				end
			end)
		end

		if not firstChild then
			continue
		end

		callback(firstChild)
		local firstChild4 = firstChild:FindFirstChild("货币符号")
		local firstChild5 = firstChild:FindFirstChild("价格")
		local pack = LimitedPackService.getPack(v24.cnId)

		if firstChild2 and firstChild4 then
			firstChild4.Text = DevProductService.robuxEmoji
		end

		if firstChild2 and firstChild5 and pack then
			local price = getPrice(pack) -- equivalent call inferred; original call site unknown
			firstChild5.Text = tostring(price)
		end

		local v25 = v24
		local v26 = firstChild2
		ButtonActions.Bind(firstChild, function()
			local pack2 = LimitedPackService.getPack(v25.cnId)

			if pack2 and LimitedPackService.isOnSale(pack2) then
				if v26 then
					DevProductService.client.promptPurchase(pack2.productKey)
				else
					LimitedPack.Open(pack2.group)
				end
			end
		end)
	end

	local function update()
		local visible = false

		for _, v25 in v23 do
			local pack = LimitedPackService.getPack(v25.cnId)
			local visible2

			if pack == nil then
				visible2 = false
			else
				visible2 = LimitedPackService.isOnSale(pack)
			end

			v25.card.Visible = visible2

			if not visible2 then
				continue
			end

			visible = true

			if v25.countdown then
				v25.countdown.Text = "Ends in " .. TimeService.formatCountdown(LimitedPackService.getRemainingSeconds(pack))
			end
		end

		self.Visible = visible
	end

	table.insert(updates, update)
	update()
end

local function bindPurchaseGranted()
	local v23 = {}

	for _, v24 in Config.limitedPack and Config.limitedPack.list or {} do
		if typeof(v24.productKey) ~= "string" or v23[v24.productKey] then
			continue
		end

		v23[v24.productKey] = true
		local rewardId = v24.rewardId
		DevProductService.client.onPurchaseGranted(v24.productKey, function()
			for k, v26 in getRewardVisuals(rewardId) do
				ClaimQueue.enqueue(v26)
			end
		end)
	end
end

function LimitedPack.Init()
	if flag then
		return
	end

	flag = true
	v8 = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("限定礼包"):WaitForChild("背景")
	local v23 = v8:WaitForChild("全屏画布")
	v9 = v23:WaitForChild("三维展示预留区")
	v9.Visible = false
	local v24 = v23:WaitForChild("标题栏")
	v10 = v24:WaitForChild("倒计时")
	v11 = v24:WaitForChild("活动标题")
	local closeButton = v23:WaitForChild("关闭按钮")
	v8.Visible = false
	local parent = ReplicatedStorage:WaitForChild("美术素材")
	v18 = parent:FindFirstChild("物品展示区") or workspace:FindFirstChild("物品展示区")

	if v18 then
		v18.Parent = parent
	end

	local part = v18 and v18:FindFirstChild("限定包") and v18["限定包"]:FindFirstChild("摄像机")

	if part and part:IsA("BasePart") then
		v20 = part
		part.Transparency = 1
	else
		warn("[LimitedPack] 缺少 美术素材.物品展示区.限定包.摄像机，打开礼包页时不切换镜头")
	end

	v14 = UnifiedPanel.new(v8, {
		closeButton = closeButton,
		isOpen = function()
			return flag2
		end
	})
	local v27 = v23:WaitForChild("展示区边框"):WaitForChild("预览页签")

	for k, childName in { "战斗预览" } do
		local child = v27:WaitForChild(childName)
		childrenByChildName[childName] = child
		v14:Bind(child, function()
			if flag2 then
				v = v == "完整套装" and "战斗预览" or "完整套装"
				renderPreview()
			end
		end, 50 + k)
	end

	local v28 = v23:WaitForChild("购买区列表")
	v12 = v28:WaitForChild("双档布局")
	size = v12:WaitForChild("单卖框").Size

	for k, v29 in {
		{
			packType = "全套",
			dual = false,
			row = v28:WaitForChild("全套框")
		},
		{
			packType = "单卖",
			dual = true,
			row = v12:WaitForChild("单卖框")
		},
		{
			packType = "全套",
			dual = true,
			row = v12:WaitForChild("全套框")
		}
	} do
		local packType = v29.packType
		local row = v29.row
		local child = row:WaitForChild(packType .. "购买区")
		local child2 = row:WaitForChild(packType .. "购买区赠礼底板")
		local buyButton = child:WaitForChild("购买按钮")
		local v31 = child2:WaitForChild("赠礼按钮")
		local v32 = 1
		local goodsCards = {}

		while child:FindFirstChild("商品卡片" .. v32) do
			table.insert(goodsCards, (child:FindFirstChild("商品卡片" .. v32)))
			v32 += 1
		end

		local waitForChild = buyButton:WaitForChild("货币符号")
		waitForChild.Text = DevProductService.robuxEmoji
		v13[tostring(k)] = {
			packType = packType,
			dual = v29.dual,
			row = row,
			area = child,
			goodsCards = goodsCards,
			buyButton = buyButton,
			priceLabel = buyButton:WaitForChild("价格"),
			giftFrame = child2
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function currentPack()
			local group = findGroup(v17) -- equivalent call inferred; original call site unknown
			return (findOnSalePack(group, packType))
		end

		local packType2 = packType
		v14:Bind(buyButton, function()
			local v36 = currentPack() -- equivalent call inferred; original call site unknown

			if v36 then
				DevProductService.client.promptPurchase(v36.productKey)
			end
		end, 100 + k * 2)
		local packType3 = packType
		v14:Bind(v31, function()
			local v37 = currentPack() -- equivalent call inferred; original call site unknown

			if v37 then
				DevProductService.client.promptGift(v37.productKey)
			end
		end, 101 + k * 2)
	end

	v14:Bind(closeButton, function()
		LimitedPack.Close()
	end, 200)
	Observers.observeLocalCharacter(function(instance)
		if not flag2 then
			return nil
		end

		task.spawn(function()
			instance:WaitForChild("Humanoid", 5)
			LimitedPack.Close(false)
		end)
		return nil
	end)
	bindPurchaseGranted()
	LobbyEntry.Start(function(p: string)
		if not flag2 then
			LimitedPack.Open(p, {
				returnToStore = false
			})
		end
	end)
	refreshAll()
	task.spawn(function()
		while true do
			task.wait(1)
			refreshAll()
		end
	end)
end

return LimitedPack