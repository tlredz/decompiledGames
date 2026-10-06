local BallQualityTextStyle = require(game.ReplicatedStorage.Engine.Service.BallQualityTextStyle)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local GachaPool = require(ReplicatedStorage.Engine.Service.GachaPool)
local TimeService = require(ReplicatedStorage.Engine.Service.TimeService)
local v = {}

local function refreshUpgradeRatings()
	v = {}
	local now = TimeService.now()

	for _, v2 in GachaPool.getAllEntries() do
		if not (v2.canFusion == true and GachaPool.isUnlocked(v2, now)) then
			continue
		end

		local engineItemType = GachaPool.toEngineItemType(v2.itemType)
		local definition = GachaPool.getDefinition(v2)

		if not (definition and type(definition.rating) == "number" and (engineItemType == "Ball" or definition.skinType == engineItemType)) then
			continue
		end

		v[engineItemType] = v[engineItemType] or {}
		v[engineItemType][definition.rating - 1] = true
	end
end

local PlayerData = require(ReplicatedStorage.Engine.Service.PlayerData)
local client = PlayerData.client
local BallUpgradeRules = require(ReplicatedStorage.Engine.Service.BallUpgradeRules)
local GameFlags = require(ReplicatedStorage.GameFlags)
local v2 = GameFlags.feature["小球合成"] == true
local client2

if v2 then
	local BallUpgradeService = require(ReplicatedStorage.Engine.Service.BallUpgradeService)
	client2 = BallUpgradeService.client
else
	client2 = nil
end

local Net = require(ReplicatedStorage.Packages.Net)
local remoteFunction = Net:RemoteFunction("FusionRequest")
local ButtonActions = require(ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local GamepadSupport = require(ReplicatedStorage.Engine.Service.GamepadSupport)
local ItemMetadataDisplay = require(script.Parent.ItemMetadataDisplay)
local ClaimQueue = require(script.Parent.Parent.ClaimQueue)
local ConfirmDialogController = require(script.Parent.Parent.ConfirmDialogController)
local FusionClient = {}
local LazyGrid = require(script.Parent.LazyGrid)
local v3 = nil
local v4 = {}
local fusionFrame = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = "Fusion"
local v11 = "Ball"
local id = nil
local v12 = "All"
local instanceIds = {}
local v13 = {}
local v14 = nil
local rating = nil
local flag = false
local count = 0
local v15 = {
	"全部筛选",
	"经典筛选",
	"闪光筛选",
	"彩虹筛选"
}
local v16 = {
	"All",
	"Classic",
	"Shiny",
	"Rainbow"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function definition(p)
	if p.itemType == "Ball" then
		return Config.ball.byCnId[p.itemId]
	end

	return Config.skin.byCnId[p.itemId]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rating2(rating3)
	for _, v17 in Config.rating.list do
		if v17.lvl == rating3 then
			return v17
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function nameOf(p, p2)
	if p2 == "Ball" then
		return p.displayName
	end

	return p.name
end

-- equivalent calls inferred from this helper; original call sites unknown
local function required()
	if v10 == "Fusion" then
		return 6
	end

	return 10
end

-- equivalent calls inferred from this helper; original call sites unknown
local function materialList()
	return v7[v10 == "Fusion" and "六格列表" or "十格列表"]
end

function FusionClient.GetMaterialList()
	return materialList()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reset()
	instanceIds = {}
	v13 = {}
	v14 = nil
	rating = nil
	count += 1
end

local function listed()
	local result = {}

	for _, v17 in client.boothListings() or {} do
		if type(v17) == "table" then
			result[v17.itemInstanceId or ""] = true
		end
	end

	return result
end

local function available(data, p)
	local v17

	if type(data) == "table" and data.ownerUserId == Players.LocalPlayer.UserId then
		v17 = not p[data.instanceId]

		if v17 then
			if type(data.locks or {}) == "table" then
				return next(data.locks or {}) == nil
			else
				return false
			end
		end
	else
		return false
	end

	return v17
end

local function eligible(data, p)
	if not available(data, p) or data.itemType ~= v11 then
		return false
	end

	-- equivalent call inferred; original call site unknown
	if not definition(data) then
		return false
	end

	if v10 == "Fusion" then
		return data.itemId == id and BallUpgradeRules.eligible(data, Players.LocalPlayer.UserId) and (not v14 or BallUpgradeRules.kind(data) == v14)
	else
		local v17

		if data.canFusion == true and (data.itemType ~= "Ball" or BallUpgradeRules.kind(data) == "Classic") and v[data.itemType] ~= nil then
			v17 = false
			local v18 = v[data.itemType]
			local v19 = definition(data) -- equivalent call inferred; original call site unknown

			if v18[v19.rating] == true then
				v17 = not rating

				if not v17 then
					local v20 = definition(data) -- equivalent call inferred; original call site unknown
					return v20.rating == rating
				end
			end
		else
			return false
		end

		return v17
	end

	return false
end

local v17 = {}
local _1s = {}
local v18 = {}
local object = setmetatable({}, {
	__mode = "k"
})

local function bindCell(instance, fn)
	if object[instance] then
		object[instance] = fn
		return
	end

	object[instance] = fn
	ButtonActions.Bind(instance, function(...)
		return object[instance](...)
	end)
	instance.Destroying:Connect(function()
		object[instance] = nil
	end)
end

local function clean(instance)
	if instance == v6["列表"] then
		v18 = {}

		for _, child in instance:GetChildren() do
			if not child:GetAttribute("FusionGeneratedSlot") then
				continue
			end

			local v19 = v17[child:GetAttribute("InventoryNavigationKey")]

			if not v19 or v19.cell ~= child then
				child:Destroy()
			end
		end
	else
		for _, child in instance:GetChildren() do
			if child:GetAttribute("FusionGeneratedSlot") then
				child:Destroy()
			end
		end
	end
end

local function create(parent, inventoryNavigationKey, layoutOrder)
	local v19

	if parent == v6["列表"] then
		v19 = v17[inventoryNavigationKey]
	else
		v19 = false
	end

	if v19 and v19.cell.Parent == parent then
		v18[inventoryNavigationKey] = true
		local cell = v19.cell
		cell.Name = "格子" .. layoutOrder
		cell.LayoutOrder = layoutOrder
		cell.Visible = true
		return cell
	else
		local clone = _1s[parent]:Clone()

		if parent == v6["列表"] then
			v17[inventoryNavigationKey] = {
				cell = clone
			}
			v18[inventoryNavigationKey] = true
		end

		local child = parent:FindFirstChild("预制格子" .. layoutOrder)

		if child then
			clone.Position = child.Position
			clone.Size = child.Size
			clone.AnchorPoint = child.AnchorPoint
		end

		clone.Name = "格子" .. layoutOrder
		clone.Text = ""
		clone.LayoutOrder = layoutOrder
		clone:SetAttribute("FusionGeneratedSlot", true)
		clone:SetAttribute("InventoryNavigationKey", inventoryNavigationKey)
		clone.Selectable = true
		clone.Parent = parent
		clone.Visible = true

		if v9.setupButtonFeedback then
			v9.setupButtonFeedback(clone)
		end

		return clone
	end
end

local function write(instance, item, p)
	local v19 = definition(item) -- equivalent call inferred; original call site unknown
	instance.Text = ""
	instance.ImageLabel.Image = v19.image or ""
	local v20 = instance["名称"]["文字"]
	local displayName

	if p then
		displayName = p
	elseif item.itemType == "Ball" then
		displayName = v19.displayName
	else
		displayName = v19.name
	end

	v20.Text = displayName
	BallQualityTextStyle.apply(v20, p == "Shiny" and "Shiny" or p == "Rainbow" and "Rainbow" or "Classic")
	instance["锁"].Visible = item.tradable ~= true
	instance["锁"].Active = false
	instance["锁"].Selectable = false
	ItemMetadataDisplay.apply(instance, item.serial, BallUpgradeRules.killCount(item))
	local imageLabel = instance.ImageLabel
	local firstChild = imageLabel:FindFirstChild("击杀统计效果")
	local firstChild2 = imageLabel:FindFirstChild("击杀统计+唯一编号效果")

	if firstChild then
		firstChild.Visible = item.itemType == "Ball" and BallUpgradeRules.kind(item) == "Shiny"
	end

	if firstChild2 then
		firstChild2.Visible = item.itemType == "Ball" and BallUpgradeRules.kind(item) == "Rainbow"
	end

	local v21 = rating2(v19.rating) -- equivalent call inferred; original call site unknown

	if v21 then
		for _, v22 in { instance:FindFirstChild("品质描边"), instance["名称"]:FindFirstChild("品质描边") } do
			if v22 then
				v22.Color = Color3.fromHex(v21.colorHex)
			end
		end

		local uIGradient = instance:FindFirstChildOfClass("UIGradient")

		if uIGradient and instance.Parent ~= v5["列表"] then
			uIGradient.Color = ColorSequence.new(Color3.fromRGB(29, 36, 61), Color3.fromRGB(9, 17, 34))
		end
	end
end

local function updateCanvas(scrollingFrame)
	if not scrollingFrame:IsA("ScrollingFrame") or scrollingFrame:GetAttribute("InventoryVirtualGrid") then
		return
	end

	if scrollingFrame == v5["列表"] or scrollingFrame == v6["列表"] then
		local count2 = 0

		for _, button in scrollingFrame:GetChildren() do
			if not (button:IsA("GuiButton") and button.Visible and button:GetAttribute("FusionGeneratedSlot")) then
				continue
			end

			count2 += 1
		end

		local v19 = (3 - count2 % 3) % 3 + 3

		for i = 1, 5 do
			local child = scrollingFrame:FindFirstChild("底部透明填充" .. i)

			if child then
				child.Visible = i <= v19
			end
		end
	end

	local parent = scrollingFrame
	local v19 = 1

	while parent do
		local uIScale = parent:FindFirstChildOfClass("UIScale")

		if uIScale then
			v19 *= uIScale.Scale
		end

		parent = parent.Parent
	end

	local uIGridLayout = scrollingFrame:FindFirstChildOfClass("UIGridLayout")
	scrollingFrame.CanvasSize = UDim2.fromOffset(0, uIGridLayout.AbsoluteContentSize.Y / v19)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showStatus(text)
	v7["合成效果说明"].Visible = false
	v7["状态提示"].Text = text
	v7["状态提示"].Visible = true
end

local function remove(p)
	v13[p] = nil

	for k, v19 in instanceIds do
		if v19 ~= p then
			continue
		end

		table.remove(instanceIds, k)
		break
	end

	if #instanceIds == 0 then
		v14 = nil
		rating = nil

		if v10 == "Fusion" then
			v12 = "All"
		end
	end
end

local fn

fn = function()
	if not fusionFrame then
		return
	end

	if v10 == "Upgrade" then
		refreshUpgradeRatings()
	end

	local items = client.items()
	local v19 = listed()
	local parent = materialList() -- equivalent call inferred; original call site unknown
	v7["六格列表"].Visible = v10 == "Fusion"
	v7["十格列表"].Visible = v10 == "Upgrade"
	local v21 = { v5["列表"].CanvasPosition, v6["列表"].CanvasPosition, Vector2.zero }

	for i = #instanceIds, 1, -1 do
		if not eligible(items[instanceIds[i]], v19) then
			remove(instanceIds[i])
		end
	end

	local visible

	if v10 == "Fusion" then
		visible = id == nil
	else
		visible = false
	end

	v5.Visible = visible
	v6.Visible = not visible
	v7.Visible = not visible
	local v23

	if v10 == "Fusion" then
		v23 = id ~= nil
	else
		v23 = false
	end

	fusionFrame["左侧选择栏"].Visible = not v23
	v6.Position = UDim2.fromScale(v23 and 0.335 or 0.42, 0.5)
	v6.Size = UDim2.fromScale(v23 and 0.65 or 0.49, 1)

	for _, button in fusionFrame["左侧选择栏"]["左侧选择栏"]:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v24

		if button.Name == "小球合成按钮" and v10 == "Fusion" then
			v24 = true
		elseif v10 == "Upgrade" then
			v24 = button:GetAttribute("FusionCategory") == v11
		else
			v24 = false
		end

		button.BackgroundColor3 = button:GetAttribute(v24 and "SelectedColor" or "DefaultColor")
	end

	clean(v5["列表"])
	clean(v7["六格列表"])
	clean(v7["十格列表"])

	if visible then
		v3:Set(_1s[v6["列表"]], {})
	end

	if visible then
		local v24 = {}

		for _, item in items do
			if item.itemType ~= "Ball" then
				continue
			end

			-- equivalent call inferred; original call site unknown
			if not definition(item) then
				continue
			end

			local v25 = v24[item.itemId]

			if not v25 then
				v25 = {
					item = item,
					count = 0,
					Classic = 0,
					Shiny = 0,
					Rainbow = 0
				}
				v24[item.itemId] = v25
			end

			v25.count += 1
			local kind = BallUpgradeRules.kind(item)
			v25[kind] += 1
		end

		local v25 = {}

		for k, group in v24 do
			table.insert(v25, {
				id = k,
				group = group
			})
		end

		table.sort(v25, function(a, b)
			local v26 = definition(a.group.item) -- equivalent call inferred; original call site unknown
			local v27 = definition(b.group.item) -- equivalent call inferred; original call site unknown

			if v26.rating ~= v27.rating then
				return v26.rating > v27.rating
			end

			if a.group.count == b.group.count then
				return v26.displayName < v27.displayName
			end

			return a.group.count > b.group.count
		end)

		for k, v26 in v25 do
			local group = v26.group
			local v27 = create(v5["列表"], v26.id, k)
			write(v27, group.item)
			ItemMetadataDisplay.apply(v27, nil, nil)
			v27["锁"].Visible = false

			for _, guiObject in v27.ImageLabel:GetChildren() do
				if guiObject:IsA("GuiObject") then
					guiObject.Visible = false
				end
			end

			v27["名称"]["数量"].Text = "x" .. group.count
			local v29 = v26
			bindCell(v27, function()
				if flag or not GamepadSupport.CanActivate(v27) then
					return
				end

				reset() -- equivalent call inferred; original call site unknown
				id = v29.id
				v12 = "All"
				fn()
			end)
		end
	else
		v8.Visible = v10 == "Fusion"
		local v24 = v6["选择形态"]
		v24.Visible = v10 == "Fusion" and #instanceIds > 0
		local v26 = v6["最高形态提示"]
		v26.Visible = v10 == "Fusion" and v12 == "Rainbow"
		v6["文字"].Visible = v10 == "Upgrade"
		v6["文字"].Text = "Select Same-Rarity Materials"
		local v28 = v6["列表"]
		local position

		if v10 == "Fusion" then
			position = UDim2.fromScale(0, 0.235)
		else
			position = UDim2.fromScale(0, 0.09)
		end

		v28.Position = position
		local v30 = v6["列表"]
		local size

		if v10 == "Fusion" then
			size = UDim2.fromScale(1, 0.68)
		else
			size = UDim2.fromScale(1, 0.91)
		end

		v30.Size = size
		local v32 = {}
		local v33 = {
			All = 0,
			Classic = 0,
			Shiny = 0,
			Rainbow = 0
		}

		for _, item in items do
			if v11 == "Ball" and item.itemType == "Ball" and item.itemId == id then
				v33.All += 1
				local kind = BallUpgradeRules.kind(item)
				v33[kind] += 1
			end

			local v34

			if v10 == "Fusion" then
				if item.itemType == "Ball" and item.itemId == id then
					v34 = available(item, v19)

					if v34 then
						if v12 == "All" or BallUpgradeRules.kind(item) == v12 then
							v34 = not v14 or eligible(item, v19)
						else
							v34 = false
						end
					end
				else
					v34 = false
				end
			else
				v34 = eligible(item, v19)
			end

			if not v34 then
				continue
			end

			local v35 = definition(item) -- equivalent call inferred; original call site unknown

			if not v35 or v13[item.instanceId] then
				continue
			end

			table.insert(v32, item)
		end

		table.sort(v32, function(a, b)
			if v10 == "Upgrade" then
				local v34 = definition(a) -- equivalent call inferred; original call site unknown
				local v35 = definition(b) -- equivalent call inferred; original call site unknown

				if v34.rating ~= v35.rating then
					return v34.rating > v35.rating
				end

				if a.itemId == b.itemId then
					if a.tradable == true == (b.tradable == true) then
						return a.instanceId < b.instanceId
					end

					return a.tradable == true
				else
					local v36 = nameOf(v34, a.itemType) -- equivalent call inferred; original call site unknown
					local v37 = nameOf(v35, b.itemType) -- equivalent call inferred; original call site unknown

					if v36 == v37 then
						return a.itemId < b.itemId
					end

					return v36 < v37
				end
			else
				local kind = BallUpgradeRules.kind(a)
				local kind2 = BallUpgradeRules.kind(b)
				local v34 = {
					Classic = 1,
					Shiny = 2,
					Rainbow = 3
				}

				if kind ~= kind2 then
					return v34[kind] < v34[kind2]
				end

				if a.itemId == b.itemId then
					return a.instanceId < b.instanceId
				end

				local v35 = definition(a) -- equivalent call inferred; original call site unknown
				local v36 = nameOf(v35, a.itemType) -- equivalent call inferred; original call site unknown
				local v37 = definition(b) -- equivalent call inferred; original call site unknown
				local v38 = nameOf(v37, b.itemType) -- equivalent call inferred; original call site unknown
				return v36 < v38
			end
		end)

		if v10 == "Fusion" then
			v8["标题"].Text = Config.ball.byCnId[id].displayName .. " · Owned " .. v33.All

			for k, v34 in v15 do
				local v35 = v8[v34]
				v35["文字组"]["文字"].Text = v16[k]
				v35["文字组"]["数量"].Text = tostring(v33[v16[k]])
				v35.BackgroundColor3 = v35:GetAttribute(v12 == v16[k] and "SelectedColor" or "DefaultColor")
			end

			v6["选择形态"]["形态"].Text = v14 or "Classic / Shiny"
		end

		local v34 = {}

		for k, v35 in v32 do
			local v36 = definition(v35) -- equivalent call inferred; original call site unknown
			local v37 = {
				key = v35.instanceId,
				item = v35,
				caption = 0,
				image = 0,
				rating = 0,
				tradable = 0,
				serial = 0,
				kills = 0,
				itemId = 0
			}
			local caption

			if v10 == "Fusion" then
				caption = BallUpgradeRules.kind(v35)
			end

			v37.caption = caption
			v37.image = v36.image
			v37.rating = v36.rating
			v37.tradable = v35.tradable
			v37.serial = v35.serial
			v37.kills = BallUpgradeRules.killCount(v35)
			v37.itemId = v35.itemId
			v34[k] = v37
		end

		v3:Set(_1s[v6["列表"]], v34)

		for i = 1, v10 == "Fusion" and 6 or 10 do
			local v35 = instanceIds[i]
			local v36 = create(parent, v35 or "empty:" .. i, i)

			if v35 then
				local item = items[v35]
				local v38

				if v10 == "Fusion" then
					v38 = BallUpgradeRules.kind(items[v35])
				end

				write(v36, item, v38)
				local v39 = v36
				local v40 = v35
				bindCell(v36, function()
					if not flag and GamepadSupport.CanActivate(v39) then
						remove(v40)
						fn()
					end
				end)
			else
				for _, guiObject in v36:GetChildren() do
					if guiObject:IsA("GuiObject") then
						guiObject.Visible = false
					end
				end

				v36.Active = false
				v36.Selectable = false
				v36.BackgroundTransparency = 0.6
				local firstChild = v36:FindFirstChild("品质描边")

				if firstChild then
					firstChild.Color = Color3.fromRGB(47, 66, 106)
				end
			end
		end

		v7["文字"].Text = v10 == "Fusion" and "Fusion Materials" or "Upgrade Materials"
		v7["材料进度"]["提示"].Visible = false
		v7["材料进度"]["数量"].Text = ("%d/%d"):format(#instanceIds, v10 == "Fusion" and 6 or 10)
		v7["材料进度"]["剩余"].Text = ("· Need %d More"):format((v10 == "Fusion" and 6 or 10) - #instanceIds)
		local v35 = v14 or v12 == "Shiny" and "Shiny" or "Classic"
		local v36 = v7["合成效果说明"]
		v7["状态提示"].Visible = false
		v36.Visible = true

		if v10 == "Upgrade" then
			showStatus("10 same-rarity items\n→ 1 higher-rarity item") -- equivalent call inferred; original call site unknown
		elseif v2 then
			if v12 == "Rainbow" and not v14 then
				showStatus("Rainbow is the highest form.") -- equivalent call inferred; original call site unknown
			else
				local v37 = v35 == "Shiny" and "Rainbow" or "Shiny"
				local v38 = Config.ball.byCnId[id]
				v36["获得提示"].Text = "You’ll get:"
				local v39 = v36["结果球名"]
				v39.Text = v37 .. " " .. (not v38 and "Ball" or v38.displayName)
				BallQualityTextStyle.apply(v39, v37)
				v36["外观说明"].Text = v37 .. " look + entrance FX"
				v36["特性说明"].Text = v37 == "Rainbow" and "Unique serial number" or "Tracks kills"
			end
		else
			showStatus("Ball fusion is currently unavailable.") -- equivalent call inferred; original call site unknown
		end

		for i = 1, 10 do
			local v37 = v7["进度条"]["进度" .. i]
			v37.Visible = i <= (v10 == "Fusion" and 6 or 10)
			v37.Size = UDim2.fromScale(0.9 / (v10 == "Fusion" and 6 or 10), 1)
			v37.Position = UDim2.fromScale((i - 1) / (v10 == "Fusion" and 6 or 10), 0)
			local backgroundColor

			if i <= #instanceIds then
				backgroundColor = Color3.fromRGB(36, 218, 65)
			else
				backgroundColor = Color3.fromRGB(47, 66, 106)
			end

			v37.BackgroundColor3 = backgroundColor
		end

		local visible2

		if #instanceIds == (v10 == "Fusion" and 6 or 10) then
			visible2 = not flag and (v10 ~= "Fusion" or v2)
		else
			visible2 = false
		end

		v7["合成按钮"].Visible = visible2
		v7["无法合成按钮"].Visible = not visible2

		for _, v38 in { "合成按钮", "无法合成按钮" } do
			v7[v38].text.Text = flag and "Processing..." or v10 == "Fusion" and "Fuse" or "Upgrade Rarity"
		end
	end

	updateCanvas(v5["列表"])
	updateCanvas(v6["列表"])
	updateCanvas(parent)

	for k, scrollingFrame in { v5["列表"], v6["列表"], parent } do
		if scrollingFrame:IsA("ScrollingFrame") then
			scrollingFrame.CanvasPosition = v21[k]
		end
	end

	if v9.changed then
		v9.changed()
	end
end

function FusionClient.Refresh()
	if fusionFrame and fusionFrame.Visible then
		fn()
	end
end

function FusionClient.SetVisible(visible)
	fusionFrame.Visible = visible

	if v3 then
		v3:Invalidate()
	end

	if visible then
		fn()
	end
end

function FusionClient.Clear()
	reset() -- equivalent call inferred; original call site unknown
	v10 = "Fusion"
	v11 = "Ball"
	id = nil
	v12 = "All"
	FusionClient.Refresh()
end

function FusionClient.OpenBall(p, value)
	reset() -- equivalent call inferred; original call site unknown
	v10 = "Fusion"
	v11 = "Ball"
	id = p
	v12 = value or "All"
	fn()
end

function FusionClient.Back()
	if flag then
		return true
	end

	if v10 ~= "Fusion" or not id then
		return false
	end

	reset() -- equivalent call inferred; original call site unknown
	id = nil
	v12 = "All"
	fn()
	return true
end

function FusionClient.Init(p)
	if fusionFrame then
		return
	end

	v9 = p
	fusionFrame = p.fusionFrame
	v5 = fusionFrame["球种主页"]
	v6 = fusionFrame["库存"]
	v7 = fusionFrame["合成框"]
	v8 = v6["副本标题栏"]

	for k, v19 in {
		Classic = "经典筛选",
		Shiny = "闪光筛选",
		Rainbow = "彩虹筛选"
	} do
		BallQualityTextStyle.apply(v8[v19]["文字组"]["文字"], k)
	end

	for _, v19 in {
		v5["列表"],
		v6["列表"],
		v7["六格列表"],
		v7["十格列表"]
	} do
		_1s[v19] = v19["格子1"]
		_1s[v19].Visible = false

		for _, child in v19:GetChildren() do
			if child:GetAttribute("MaterialSlotPreview") then
				child.Visible = false
			end
		end

		local uIGridLayout = v19:FindFirstChildOfClass("UIGridLayout")

		if not uIGridLayout then
			continue
		end

		local v20 = v19
		uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			updateCanvas(v20)
		end)
	end

	for _, guiObject in v6["列表"]:GetChildren() do
		if guiObject:GetAttribute("FusionGeneratedSlot") then
			guiObject:Destroy()
		elseif guiObject:IsA("GuiObject") and string.find(guiObject.Name, "底部透明填充", 1, true) then
			guiObject.Visible = false
		end
	end

	local function activate(p2)
		if not flag and GamepadSupport.CanActivate(p2) then
			local v19 = #instanceIds

			if not ((v10 == "Fusion" and 6 or 10) <= v19) and (v10 ~= "Fusion" or v2) then
				local v20 = v4[p2]

				if not v20 then
					return
				end

				local v21 = client.items()[v20.key]

				if not eligible(v21, listed()) then
					return
				end

				v14 = BallUpgradeRules.kind(v21)
				local v22 = definition(v21) -- equivalent call inferred; original call site unknown
				rating = v22.rating

				if v10 == "Fusion" then
					v12 = v14
				end

				v13[v21.instanceId] = true
				table.insert(instanceIds, v21.instanceId)
				fn()
			end
		end
	end

	v3 = LazyGrid.new(v6["列表"], v6["列表"], {
		slotAttribute = "FusionGeneratedSlot",
		active = function()
			return fusionFrame.Visible and v6.Visible and GamepadSupport.IsVisible(fusionFrame)
		end,
		assign = function(p2, p3)
			v4[p2] = p3
		end,
		equal = function(data, data2)
			if data then
				if data.key == data2.key and data.caption == data2.caption and data.image == data2.image and data.rating == data2.rating and data.tradable == data2.tradable and data.serial == data2.serial and data.kills == data2.kills then
					data = data.itemId == data2.itemId
				else
					data = false
				end
			end

			return data
		end,
		paint = function(p2, p3)
			write(p2, p3.item, p3.caption)
		end,
		bindCell = function(p2)
			bindCell(p2, function()
				activate(p2)
			end)
		end,
		bindVisual = function(p2)
			if v9.setupButtonFeedback then
				v9.setupButtonFeedback(p2)
			end

			bindCell(p2, function()
				if p2.Parent then
					activate(p2.Parent)
				end
			end)
		end,
		changed = function()
			if v9.changed then
				v9.changed()
			end
		end
	})
	local v19 = fusionFrame["左侧选择栏"]["左侧选择栏"]

	for _, v20 in {
		{ "小球合成按钮", "Fusion", "Ball" },
		{ "小球库存按钮", "Upgrade", "Ball" },
		{ "飞行器库存按钮", "Upgrade", "飞行器" },
		{ "爆炸特效库存按钮", "Upgrade", "爆炸特效" }
	} do
		local v21 = v19[v20[1]]
		local v23

		if v20[2] == "Upgrade" then
			v23 = v20[3]
		end

		v21:SetAttribute("FusionCategory", v23)

		if p.setupButtonFeedback then
			p.setupButtonFeedback(v21)
		end

		local v25 = v20
		ButtonActions.Bind(v21, function()
			if flag or not GamepadSupport.CanActivate(v21) then
				return
			end

			reset() -- equivalent call inferred; original call site unknown
			v10 = v25[2]
			v11 = v25[3]
			id = nil
			v12 = "All"
			fn()
		end)
	end

	for k, v20 in v15 do
		local v21 = v8[v20]

		if p.setupButtonFeedback then
			p.setupButtonFeedback(v21)
		end

		local v23 = k
		ButtonActions.Bind(v21, function()
			if not flag and GamepadSupport.CanActivate(v21) and (not v14 or v16[v23] == v14) then
				v12 = v16[v23]
				fn()
			end
		end)
	end

	ButtonActions.Bind(v8["返回按钮"], function()
		if GamepadSupport.CanActivate(v8["返回按钮"]) then
			FusionClient.Back()
		end
	end)

	if p.setupButtonFeedback then
		p.setupButtonFeedback(v8["返回按钮"])
		p.setupButtonFeedback(v7["合成按钮"])
		p.setupButtonFeedback(v7["无法合成按钮"])
	end

	local function submitFusion()
		if flag or #instanceIds ~= (v10 == "Fusion" and 6 or 10) then
			return
		end

		local clone = table.clone(instanceIds)
		local v20 = v10
		local cnId = id
		local v21 = count
		flag = true
		fn()
		local success, result = pcall(function()
			if v20 ~= "Fusion" then
				return remoteFunction:InvokeServer(clone)
			end

			local v22 = table.remove(clone, 1)
			return client2.upgrade(v22, clone)
		end)
		flag = false

		if success and type(result) == "table" and result.ok then
			if count == v21 then
				reset() -- equivalent call inferred; original call site unknown
				fn()
			end

			local itemType = v20 == "Fusion" and "Ball" or result.itemType

			if v20 ~= "Fusion" then
				cnId = result.cnId
			end

			local v24 = definition({
				itemType = itemType,
				itemId = cnId
			}) -- equivalent call inferred; original call site unknown
			local v25 = rating2(v24.rating) -- equivalent call inferred; original call site unknown
			local enqueue = ClaimQueue.enqueue
			local v26 = {
				image = v24.image or "",
				name = 0,
				colorHex = 0,
				serial = 0,
				killCount = 0
			}
			local name = nameOf(v24, itemType) -- equivalent call inferred; original call site unknown
			v26.name = name
			v26.colorHex = not v25 and "#FFFFFF" or v25.colorHex
			v26.serial = result.serial
			v26.killCount = result.killCount
			enqueue(v26)
		elseif count == v21 then
			fn()
			showStatus(not success and "Connection failed. Please try again." or result.reason == "no_next_rarity" and "No higher-rarity item is available." or "Materials changed or are unavailable. Please select again.") -- equivalent call inferred; original call site unknown
		end
	end

	ButtonActions.Bind(v7["合成按钮"], function()
		if flag or not GamepadSupport.CanActivate(v7["合成按钮"]) or #instanceIds ~= (v10 == "Fusion" and 6 or 10) then
			return
		end

		local v20 = required() -- equivalent call inferred; original call site unknown
		local items = client.items()
		local total = 0
		local v21 = false

		for _, v22 in instanceIds do
			local item = items[v22]
			v21 = item and item.tradable ~= true and true or v21

			if item then
				total += BallUpgradeRules.killCount(item) or 0
			end
		end

		local v22 = v14 or "Classic"
		local v23 = v22 == "Shiny" and "Rainbow" or "Shiny"
		local v24 = v10 ~= "Fusion" and "Upgrade 10 same-rarity items into 1 higher-rarity item?" or ("Fuse %d %s balls into 1 %s ball?"):format(
			v20,
			v22,
			v23
		)
		flag = true
		fn()
		local flag2 = false
		ConfirmDialogController.Enqueue("合成确认面板", {
			category = "Fusion",
			onShown = function(data, callback)
				data["普通确认"]["文本"].Text = v24 .. "\nAll " .. v20 .. " materials will be consumed."
				local visible

				if v10 == "Fusion" then
					visible = v23 == "Rainbow"
				else
					visible = false
				end

				data["击杀数合计"].Visible = visible
				data["击杀数合计"].Text = ("Combined kills: %d"):format(total)
				local visible2 = v21
				local v27 = data["交易锁提示"]
				v27["标题"].Text = v10 == "Fusion" and "Confirm Fusion?" or "Confirm Rarity Upgrade?"
				v27["提示"].RichText = false
				v27["提示"].TextColor3 = Color3.new(1, 1, 1)
				v27["提示"].Text = visible and "Includes trade-locked materials.\nThe Rainbow ball will also be trade-locked." or v10 == "Fusion" and [[
Your materials include a trade-locked ball.
The resulting ball will also be trade-locked.]] or [[
Your materials include a trade-locked item.
The resulting item will also be trade-locked.]]
				data["普通确认"].Visible = not visible2
				data["交易锁提示"].Visible = visible2
				ConfirmDialogController.BindButton(data["取消按钮"], "B", callback)
				ConfirmDialogController.BindButton(data["确定按钮"], "A", function()
					if flag2 then
						return
					end

					flag2 = true
					callback()
					flag = false
					fn()
					submitFusion()
				end)
			end,
			onHidden = function()
				if not flag2 then
					flag = false
					fn()
				end
			end
		})
	end)
	ButtonActions.Bind(v7["无法合成按钮"], function()
		if GamepadSupport.CanActivate(v7["无法合成按钮"]) and not flag then
			showStatus("Select " .. (v10 == "Fusion" and 6 or 10) .. " eligible materials to continue.") -- equivalent call inferred; original call site unknown
		end
	end)
	client.boothListings.Changed(function()
		FusionClient.Refresh()
	end)
	fusionFrame.Visible = false
end

return FusionClient