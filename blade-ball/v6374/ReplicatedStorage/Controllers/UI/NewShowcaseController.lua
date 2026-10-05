local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Common.MarketplaceService)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Packages.Signal)
local v4 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v5 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v6 = require3(ReplicatedStorage2.Common.Utils.Utilities.Thread)
local v7 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
local v8 = require3(ReplicatedStorage2.Common.Utils.Utilities.Icons)
local v9 = require3(ReplicatedStorage2.Common.Utils.Utilities.RewardInfo)
local v10 = require3(ReplicatedStorage2.Shared.UiPresets)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v11 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteAccessories)
local v12 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteVFX)
local v13 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.SwordAccessories)
local v14 = require3(ReplicatedStorage2.Controllers.GiftingController)
local v15 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v16 = require3(ReplicatedStorage2.Controllers.VFXController)
local v17 = require3(ReplicatedStorage2.Controllers.ShowRoomController)
local v18 = require3(ReplicatedStorage2.Controllers.ShowRoomController.ShowRoomUtility)
local v19 = require3(ReplicatedStorage2.Packages.Conch)
local v20 = require3(ReplicatedStorage2.Controllers.UI.LimitedSwordPacksController)
local localPlayer = Players.LocalPlayer
local newShowcase = localPlayer.PlayerGui:WaitForChild("NewShowcase")
local normalShowcase = newShowcase:WaitForChild("NormalShowcase")
local limitedQuantity = newShowcase:WaitForChild("LimitedQuantity")
local mainShowcase = newShowcase:FindFirstChild("MainShowcase")
local v21 = {
	CameraSide = 12.95,
	SoloCameraSide = 12.16,
	CameraHeight = -2.72,
	CameraDistance = -11.8,
	PadHeight = -3,
	PadDepth = 1,
	PadSide = -2.5,
	PadScale = 0.9,
	PadBaseScale = 0.146,
	PlayerHeight = -3,
	PlayerDepth = 5,
	PlayerSide = 0,
	PlayerScale = 1,
	BackgroundDistance = 40,
	BackgroundWidth = 170,
	BackgroundHeight = 96
}

local function buildCameraOffset()
	return CFrame.new(v21.CameraSide, v21.CameraHeight, v21.CameraDistance)
end

local function buildSoloCameraOffset()
	return CFrame.new(v21.SoloCameraSide, v21.CameraHeight, v21.CameraDistance)
end

local function buildHoloPadLayout(visiblePads: number?)
	return {
		VisiblePads = visiblePads,
		SwapSides = true,
		AlignDepth = true,
		AlignHeight = true,
		HeightOffset = v21.PadHeight,
		DepthOffset = v21.PadDepth,
		SideOffset = v21.PadSide,
		PadScale = v21.PadScale,
		PadBaseScale = v21.PadBaseScale,
		PlayerHeight = v21.PlayerHeight,
		PlayerDepth = v21.PlayerDepth,
		PlayerSide = v21.PlayerSide,
		PlayerScale = v21.PlayerScale,
		ShowBackground = true,
		BackgroundDistance = v21.BackgroundDistance,
		BackgroundWidth = v21.BackgroundWidth,
		BackgroundHeight = v21.BackgroundHeight
	}
end

local v22 = nil
local v23 = {}
local v24 = {}
local nows = {}
local v25 = {}
local clone = nil
local size = nil
local scalesByParent = {}
local v26 = nil
local v27 = {}
local clonesByName = {}
local v28 = {}
local v29 = {}
local v30 = nil
local v31 = {}
local v32 = false
local NewShowcaseController = {
	WindowName = "NewShowcase",
	LegacyWindowName = "LimitedSword_SwordPacks",
	CurrentBundle = nil,
	BundleShown = v3.new(),
	_sceneBundle = nil,
	_experimentVariant = nil,
	SetExperimentVariant = function(p, experimentVariant: string)
		p._experimentVariant = experimentVariant
		v32 = true
	end,
	WaitForVariant = function(self, value: number?)
		if v32 or v5:GetKey("NewShowcaseEnabled") ~= nil then
			return
		end

		local v33 = os.clock() + (value or 3)

		while not v32 and os.clock() < v33 do
			task.wait(0.05)
		end
	end,
	IsEnabled = function(self)
		local key = v5:GetKey("NewShowcaseEnabled")

		if key == false then
			return false
		end

		if self._experimentVariant == nil then
			return key == true
		end

		return self._experimentVariant == "New"
	end,
	GetWindowName = function(self)
		self:WaitForVariant()

		if self:IsEnabled() then
			return self.WindowName
		end

		return self.LegacyWindowName
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getPackEndDate(pack)
	return pack.FFlagEndTime and v5:GetKey(pack.FFlagEndTime) or pack.RootFFlagEndTime and v5:GetKey(pack.RootFFlagEndTime) or 0
end

local function getStockKeys(p)
	local stocks = {}

	if p.Stock then
		table.insert(stocks, p.Stock)
	end

	for _, v33 in p.Rewards or {} do
		if not v33.Stock or table.find(stocks, v33.Stock) then
			continue
		end

		table.insert(stocks, v33.Stock)
	end

	return stocks
end

local function readStock(items)
	local total = 0
	local total2 = 0

	for _, item in items do
		total += v22:Get({ "Stock", item }) or 0
		total2 += v22:Get({ "InitialStock", item }) or 0
	end

	return math.max(math.ceil(total), 0), (math.ceil(total2))
end

local function isLimitedBundle(p)
	local stockKeys = getStockKeys(p)

	if #stockKeys == 0 then
		return false
	end

	local _, v33 = readStock(stockKeys)
	return v33 > 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatStock(p: number, p2: number)
	return v7:AddCommas(p) .. "/" .. v7:AddCommas(p2)
end

local color = Color3.fromRGB(40, 40, 46)
local color2 = Color3.fromRGB(150, 150, 160)
local uDim = UDim2.fromScale(0.958, 0.095)
local color3 = Color3.fromRGB(255, 255, 255)
local color4 = Color3.fromRGB(120, 120, 130)
local v33 = { "Sword", "Emote", "Explosion" }
local v34 = {
	Buy = {
		Hover = 1.06,
		Click = 0.94
	},
	Preview = {
		Hover = 1.08,
		Click = 0.92
	},
	Slot = {
		Hover = 1.05,
		Click = 0.95
	},
	Close = {
		Hover = 1.12,
		Click = 0.88
	}
}
local v35 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function animateButton(button, p: string)
	local v36 = v34[p]

	if not v36 or v35[button] or not button:IsA("GuiButton") then
		return
	end

	v35[button] = true
	v10.animateButtonHover(button, 1, v36.Hover)
	v10.animateButtonClick(button, v36.Click)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getShowRoom()
	local swordPacks = v17:Get("SwordPacks")

	if not swordPacks then
		return nil
	end

	local selected = swordPacks.Info.Selected

	if selected then
		return swordPacks.Instance.InnerShowRooms:FindFirstChild(selected)
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getShowRoomNPC()
	local showRoom = getShowRoom() -- equivalent call inferred; original call site unknown

	if showRoom then
		return showRoom.NPCS:FindFirstChild("1")
	end

	return nil
end

local function getGroundPosition(instance)
	local humanoidRootPart = instance.HumanoidRootPart
	local showRoom = getShowRoom() -- equivalent call inferred; original call site unknown
	local pad = showRoom and showRoom:FindFirstChild("Pad")
	local v36

	if pad and pad:IsA("BasePart") then
		v36 = pad.Position.Y + pad.Size.Y / 2
	else
		v36 = humanoidRootPart.Position.Y - 3
	end

	local vector = Vector3.new(humanoidRootPart.Position.X, v36, humanoidRootPart.Position.Z)
	local showRoomCamera = showRoom and v18:GetShowRoomCamera(showRoom)

	if showRoomCamera then
		vector += showRoomCamera.LookVector * 14
	end

	return vector
end

local v36 = {}

local function applySlotSelection(instance, flag: boolean)
	local base = instance:FindFirstChild("Base")

	if not (base and base:IsA("ImageLabel")) then
		return
	end

	local imageColor

	if flag then
		imageColor = color3
	else
		imageColor = color4
	end

	base.ImageColor3 = imageColor
	local uIStroke = base:FindFirstChild("UIStroke")

	if uIStroke and uIStroke:IsA("UIStroke") then
		uIStroke.Transparency = flag and 0 or 0.65
	end
end

local function refreshPreviewSelection()
	for k in v24 do
		if k.Parent then
			applySlotSelection(k, v30 == nil or k == v30)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPreviewSelection(p)
	v30 = p
	refreshPreviewSelection()
end

local function refreshBundleSelection(currentBundle)
	for k, v37 in v29 do
		if k.Parent then
			applySlotSelection(k, currentBundle == nil or v37 == currentBundle)
		end
	end
end

local function setPreviewsLocked(visible: boolean)
	for i = #v36, 1, -1 do
		local parent = v36[i]

		if parent.Parent then
			local hitbox = parent:FindFirstChild("Hitbox")

			if hitbox and hitbox:IsA("GuiButton") then
				hitbox.Active = not visible
				hitbox.Interactable = not visible
			end

			for _, childName in { "AccessoryOn", "AccessoryOff" } do
				local button = parent:FindFirstChild(childName)

				if not (button and button:IsA("GuiButton")) then
					continue
				end

				button.Active = not visible
				button.Interactable = not visible
			end

			local v38 = parent:FindFirstChild("LockOverlay")

			if not v38 then
				v38 = Instance.new("Frame")
				v38.Name = "LockOverlay"
				v38.AnchorPoint = Vector2.new(0.5, 0.5)
				v38.Position = UDim2.fromScale(0.5, 0.5)
				v38.Size = UDim2.fromScale(1, 1)
				v38.BackgroundColor3 = color
				v38.BackgroundTransparency = 0.35
				v38.BorderSizePixel = 0
				v38.ZIndex = 20
				v38.Visible = false
				v38.Parent = parent
			end

			v38.Visible = visible
			local content = parent:FindFirstChild("Content")
			local tryText = content and content:FindFirstChild("TryText")

			if tryText and tryText:IsA("TextLabel") then
				if visible then
					if not tryText:GetAttribute("UnlockedText") then
						tryText:SetAttribute("UnlockedText", tryText.Text)
					end

					tryText.Text = "LOCKED"
				else
					local unlockedText = tryText:GetAttribute("UnlockedText")

					if unlockedText then
						tryText.Text = unlockedText
					end
				end
			end

			local packText = content and content:FindFirstChild("PackText")

			if packText and packText:IsA("TextLabel") then
				if visible then
					if not packText:GetAttribute("UnlockedColor") then
						packText:SetAttribute("UnlockedColor", packText.TextColor3)
					end

					packText.TextColor3 = color2
				else
					local unlockedColor = packText:GetAttribute("UnlockedColor")

					if unlockedColor then
						packText.TextColor3 = unlockedColor
					end
				end
			end
		else
			table.remove(v36, i)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reapplyShowRoomLayout()
	local swordPacks = v17:Get("SwordPacks")
	local showRoom = swordPacks and swordPacks.Info.ShowRoom

	if showRoom and showRoom.applyLayout then
		showRoom.applyLayout()
	end
end

local function playExplosionPreview(p, showRoomNPC, value: string)
	setPreviewsLocked(true)
	setPreviewSelection(p) -- equivalent call inferred; original call site unknown
	showRoomNPC:SetAttribute("Emote", nil)
	showRoomNPC:SetAttribute("Slash", nil)
	showRoomNPC:SetAttribute("NoEmote", nil)
	showRoomNPC:SetAttribute("ForceIdle", true)
	showRoomNPC:SetAttribute("IsShown", false)
	task.spawn(function()
		task.wait()

		if not showRoomNPC.Parent then
			return
		end

		showRoomNPC:SetAttribute("IsShown", true)
		reapplyShowRoomLayout() -- equivalent call inferred; original call site unknown
		task.wait()

		if not showRoomNPC.Parent then
			return
		end

		local showRoom = getShowRoom() -- equivalent call inferred; original call site unknown
		local pad = showRoom and showRoom:FindFirstChild("Pad")
		local pivot = showRoomNPC:GetPivot()
		local pivot2

		if pad then
			pivot2 = pad:GetPivot()
		end

		local groundPosition = getGroundPosition(showRoomNPC)
		local v37 = Vector3.new(groundPosition.X, pivot.Position.Y, groundPosition.Z) - pivot.Position
		showRoomNPC:PivotTo(pivot + v37)

		if pad and pivot2 then
			pad:PivotTo(pivot2 + v37)
		end

		v16:PlayExplosion(value, groundPosition, nil, showRoomNPC, nil)
		task.delay(2.5, function()
			if not showRoomNPC.Parent then
				return
			end

			showRoomNPC:SetAttribute("ForceIdle", nil)
			reapplyShowRoomLayout() -- equivalent call inferred; original call site unknown
			setPreviewsLocked(false)
			setPreviewSelection(nil) -- equivalent call inferred; original call site unknown
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isPreviewable(p)
	local type = p and p.Type
	return type == "Emote" or type == "Sword" or type == "SwordAccessory" or type == "Explosion"
end

local function getRewardItems(p)
	if p and p.Item then
		if p.Item.Type == "List" then
			return p.Item.Value
		end

		return { p.Item }
	else
		return {}
	end
end

local v37 = {
	Pack = {
		Image = "rbxassetid://105053474568328"
	},
	Solo = {
		Image = "rbxassetid://98389294539143"
	}
}

local function previewKey(p)
	return (`{p.Type}|{tostring(p.Value)}`)
end

local function getBundlePackSword(currentBundle)
	if not currentBundle then
		return nil
	end

	local rewards = currentBundle.Rewards or {}

	for i = #rewards, 1, -1 do
		for _, v38 in getRewardItems(rewards[i]) do
			if v38.Type == "Sword" and typeof(v38.Value) == "string" then
				return v38.Value
			end
		end
	end

	return nil
end

local function getAccessorySword(p)
	if not p or typeof(p.Value) ~= "string" or p.Type ~= "Sword" and p.Type ~= "SwordAccessory" then
		return nil
	end

	if v13:GetCollection()[p.Value] then
		return p.Value
	end

	return nil
end

local function isAccessoryShown(p, p2)
	local v38

	if p2 and typeof(p2.Value) == "string" and (p2.Type == "Sword" or p2.Type == "SwordAccessory") and v13:GetCollection()[p2.Value] then
		v38 = p2.Value
	end

	if not v38 then
		return nil
	end

	local v39 = v27[p]
	return v39 == nil or v39
end

local function previewReward(p, p2)
	if not isPreviewable(p2) then
		return
	end

	local showRoomNPC = getShowRoomNPC() -- equivalent call inferred; original call site unknown

	if not showRoomNPC then
		return
	end

	if p2.Type == "Explosion" then
		local now = os.clock()

		if now - (nows[p] or 0) < 1 then
			return
		end

		nows[p] = now
		playExplosionPreview(p, showRoomNPC, p2.Value)
	elseif p2.Type == "Sword" or p2.Type == "SwordAccessory" then
		local value

		if p2 and typeof(p2.Value) == "string" and (p2.Type == "Sword" or p2.Type == "SwordAccessory") and v13:GetCollection()[p2.Value] then
			value = p2.Value
		end

		local v38

		if value then
			local v39 = v27[p]
			v38 = v39 == nil or v39
		end

		showRoomNPC:SetAttribute("IsShown", false)
		showRoomNPC:SetAttribute("ForceIdle", nil)
		local v40

		if v38 ~= nil then
			v40 = not v38
		end

		showRoomNPC:SetAttribute("IgnoreAccessory", v40)
		showRoomNPC:SetAttribute("Sword", p2.Value)
		showRoomNPC:SetAttribute("Emote", nil)

		if p2.Type == "SwordAccessory" then
			showRoomNPC:SetAttribute("Slash", nil)
			showRoomNPC:SetAttribute("NoEmote", true)
		else
			showRoomNPC:SetAttribute("NoEmote", nil)
			showRoomNPC:SetAttribute("Slash", true)
		end

		showRoomNPC:SetAttribute("IsShown", true)
		setPreviewSelection(p) -- equivalent call inferred; original call site unknown
	else
		showRoomNPC:SetAttribute("IsShown", false)
		showRoomNPC:SetAttribute("ForceIdle", nil)
		local instance = v11:GetInstance(p2.Value)

		if instance and instance:GetAttribute("HideSword") then
			showRoomNPC:SetAttribute("Sword", nil)
		else
			local instance2 = v12:GetInstance(p2.Value)
			local sword = instance2 and instance2:GetAttribute("Sword")

			if sword then
				showRoomNPC:SetAttribute("Sword", sword)
			else
				local bundlePackSword = getBundlePackSword(NewShowcaseController.CurrentBundle)

				if bundlePackSword then
					showRoomNPC:SetAttribute("Sword", bundlePackSword)
				end
			end
		end

		local v39

		if p2.Value == "Emote711" then
			v39 = false
		end

		showRoomNPC:SetAttribute("IgnoreAccessory", v39)
		showRoomNPC:SetAttribute("NoEmote", nil)
		showRoomNPC:SetAttribute("Slash", nil)
		showRoomNPC:SetAttribute("Emote", nil)
		task.spawn(function()
			task.wait()

			if not showRoomNPC.Parent then
				return
			end

			showRoomNPC:SetAttribute("Emote", p2.Value)
			showRoomNPC:SetAttribute("IsShown", true)
			setPreviewSelection(p) -- equivalent call inferred; original call site unknown
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRewardName(data)
	local item = data and data.Item

	if item and item.DisplayName then
		return item.DisplayName
	end

	if data and data.GiftName then
		return data.GiftName
	end

	if item and item.Type == "Sword" and typeof(item.Value) == "string" then
		return item.Value
	end

	return "???"
end

local function getBundleWeaponIcon(p)
	local rewards = p.Rewards or {}
	local v38 = {}

	for i = #rewards, 1, -1 do
		for _, v39 in getRewardItems(rewards[i]) do
			if v39.Icon then
				table.insert(v38, v39)
			end
		end
	end

	for _, v39 in v33 do
		for _, v40 in v38 do
			if v40.Type == v39 then
				return v40.Icon
			end
		end
	end

	if #v38 > 0 then
		return v38[math.random(#v38)].Icon
	end

	return nil
end

local function buildPreviewEntries(p)
	local rewards = p.Rewards or {}
	local rewardItems = getRewardItems(rewards[1])
	local rewardItems2 = getRewardItems(rewards[2])
	local v38 = {}
	local v39 = {}

	for _, rewardItem in rewardItems do
		v38[`{rewardItem.Type}|{tostring(rewardItem.Value)}`] = true
	end

	for _, rewardItem in rewardItems2 do
		v39[`{rewardItem.Type}|{tostring(rewardItem.Value)}`] = true
	end

	local rewardItems3 = {}
	local rewardItems4 = {}
	local rewardItems5 = {}

	for _, rewardItem in rewardItems do
		if v39[`{rewardItem.Type}|{tostring(rewardItem.Value)}`] then
			table.insert(rewardItems3, rewardItem)
		else
			table.insert(rewardItems4, rewardItem)
		end
	end

	for _, rewardItem in rewardItems2 do
		if v38[`{rewardItem.Type}|{tostring(rewardItem.Value)}`] then
			continue
		end

		table.insert(rewardItems5, rewardItem)
	end

	local v40 = rewards[2] ~= nil
	local result = {}

	for _, v41 in rewardItems4 do
		table.insert(result, {
			Item = v41,
			Tag = v40 and "Solo" or "Pack"
		})
	end

	for _, v41 in rewardItems3 do
		table.insert(result, {
			Item = v41,
			Tag = "Pack"
		})
	end

	for _, v41 in rewardItems5 do
		table.insert(result, {
			Item = v41,
			Tag = "Pack"
		})
	end

	return result
end

local function ensurePreviewSlots(container, p: number, clone2)
	local result = {}

	for _, child in container:GetChildren() do
		if child.Name == "Slot" then
			table.insert(result, child)
		end
	end

	table.sort(result, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	while #result < p do
		local clone3 = clone2:Clone()
		clone3.Name = "Slot"
		clone3.Parent = container
		table.insert(result, clone3)
	end

	while #result > math.max(p, 2) do
		local v38 = table.remove(result)

		if v38 then
			v38:Destroy()
		end
	end

	for k, v38 in result do
		v38.LayoutOrder = k
	end

	local uIListLayout = container:FindFirstChildWhichIsA("UIListLayout")
	local v38 = p > 2 and 2 or 1
	local scale = scalesByParent[container]

	if not scale then
		scale = container.Size.X.Scale
		scalesByParent[container] = scale
	end

	local size2 = container.Size
	local v39 = scale * (v38 > 1 and 1.5 or 1)
	container.Size = UDim2.new(v39, size2.X.Offset, size2.Y.Scale, size2.Y.Offset)

	if uIListLayout then
		local fillDirection

		if v38 > 1 then
			fillDirection = Enum.FillDirection.Horizontal
		else
			fillDirection = Enum.FillDirection.Vertical
		end

		uIListLayout.FillDirection = fillDirection
		uIListLayout.Wraps = v38 > 1
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		uIListLayout.Padding = UDim.new(v38 > 1 and 0.02 or 0.07, 0)
	end

	if not (size and p > 0) then
		return result
	end

	local v40 = math.ceil(p / v38)
	local v41 = v38 > 1 and 0.02 or 0.07
	local v42 = 1 - v41 * v40
	local v43 = (1 - v41 * v38) / v38
	local v44 = v42 / v40
	local v45 = math.min(size.X.Scale / (v38 > 1 and 1.5 or 1), v43)
	local v46 = math.min(size.Y.Scale, v44)

	for _, v47 in result do
		v47.Size = UDim2.fromScale(v45, v46)
	end

	return result
end

local function ensurePackText(instance)
	local content = instance:FindFirstChild("Content")

	if not content then
		return nil
	end

	local packText = content:FindFirstChild("PackText")

	if packText and packText:IsA("TextLabel") then
		return packText
	end

	local content2 = clone and clone:FindFirstChild("Content")
	local packText2 = content2 and content2:FindFirstChild("PackText")

	if packText2 and packText2:IsA("TextLabel") then
		local clone2 = packText2:Clone()
		clone2.Parent = content
		return clone2
	else
		return nil
	end
end

local function applyPreviewTag(previewSlot, tag: string?)
	local v38 = tag and v37[tag]
	local base = previewSlot:FindFirstChild("Base")

	if base and base:IsA("ImageLabel") and v38 then
		base.Image = v38.Image
		local tagStroke = base:FindFirstChild("TagStroke")

		if tagStroke and tagStroke:IsA("UIStroke") then
			tagStroke:Destroy()
		end
	end

	local packText = ensurePackText(previewSlot)

	if packText then
		packText.Visible = tag == "Pack"
	end
end

local function captureAccessoryTemplates()
	if clonesByName.AccessoryOn and clonesByName.AccessoryOff then
		return
	end

	for _, button in newShowcase:GetDescendants() do
		if not button:IsA("ImageButton") or not (button.Name == "AccessoryOn" or button.Name == "AccessoryOff") or clonesByName[button.Name] then
			continue
		end

		clonesByName[button.Name] = button:Clone()
	end
end

local function findAccessoryButton(parent, childName: string)
	local button = parent:FindFirstChild(childName)

	if button and button:IsA("ImageButton") then
		return button
	end

	local content = parent:FindFirstChild("Content")
	local button2 = content and content:FindFirstChild(childName)

	if button2 and button2:IsA("ImageButton") then
		return button2
	end

	return nil
end

local function ensureAccessoryButtons(parent, flag: boolean)
	if flag then
		captureAccessoryTemplates()
	end

	local accessoryButtons = {}

	for _, v38 in { "AccessoryOn", "AccessoryOff" } do
		local accessoryButton = findAccessoryButton(parent, v38)

		if not accessoryButton and flag then
			local v39 = clonesByName[v38]

			if not v39 then
				return nil, nil
			end

			accessoryButton = v39:Clone()
		end

		if not accessoryButton then
			return nil, nil
		end

		accessoryButton.Parent = parent
		accessoryButton.ZIndex = 15
		accessoryButtons[v38] = accessoryButton
	end

	return accessoryButtons.AccessoryOn, accessoryButtons.AccessoryOff
end

local refreshAccessoryButtons

refreshAccessoryButtons = function(parent, p2)
	local value

	if p2 and typeof(p2.Value) == "string" and (p2.Type == "Sword" or p2.Type == "SwordAccessory") and v13:GetCollection()[p2.Value] then
		value = p2.Value
	end

	local v38

	if value then
		local v39 = v27[parent]
		v38 = v39 == nil or v39
	end

	local accessoryButtons, v39 = ensureAccessoryButtons(parent, v38 ~= nil)

	if not (accessoryButtons and v39) then
		return
	end

	accessoryButtons.Visible = v38 == true
	v39.Visible = v38 == false

	for _, v40 in { accessoryButtons, v39 } do
		if v28[v40] then
			continue
		end

		v28[v40] = true
		animateButton(v40, "Preview") -- equivalent call inferred; original call site unknown
		v40.Activated:Connect(function()
			local v41 = v24[parent]
			local v42

			if v41 and typeof(v41.Value) == "string" and (v41.Type == "Sword" or v41.Type == "SwordAccessory") and v13:GetCollection()[v41.Value] then
				v42 = v41.Value
			end

			if not v42 then
				return
			end

			local v43 = v27
			local parent2 = parent
			local value2

			if v41 and typeof(v41.Value) == "string" and (v41.Type == "Sword" or v41.Type == "SwordAccessory") and v13:GetCollection()[v41.Value] then
				value2 = v41.Value
			end

			local v46

			if value2 then
				local v47 = v27[parent2]
				v46 = v47 == nil or v47
			end

			v43[parent] = not v46
			refreshAccessoryButtons(parent, v41)
			previewReward(parent, v41)
		end)
	end
end

local function bindPreviewSlot(instance, p)
	if v24[instance] ~= p then
		v27[instance] = nil
	end

	v24[instance] = p
	applySlotSelection(instance, v30 == nil or instance == v30)
	refreshAccessoryButtons(instance, p)

	if not table.find(v36, instance) then
		table.insert(v36, instance)
	end

	local content = instance:FindFirstChild("Content")

	if not content then
		return
	end

	local PH = content:FindFirstChild("PH")

	if PH and PH:IsA("ImageLabel") then
		PH.Image = p and p.Icon or v8:GetIcon("DEFAULT_MISSING")
	end

	local previewable = isPreviewable(p) -- equivalent call inferred; original call site unknown
	local eyeIcon = content:FindFirstChild("EyeIcon")

	if eyeIcon then
		eyeIcon.Visible = previewable
	end

	local tryText = content:FindFirstChild("TryText")

	if tryText then
		tryText.Visible = previewable
	end

	local hitbox = instance:FindFirstChild("Hitbox")

	if not hitbox or v25[hitbox] then
		return
	end

	v25[hitbox] = true
	animateButton(hitbox, "Preview") -- equivalent call inferred; original call site unknown
	hitbox.Activated:Connect(function()
		previewReward(instance, v24[instance])
	end)
end

local function setBuyButton(buyBTN, data, childName: string?)
	local content = buyBTN:FindFirstChild("Content")
	local hitbox = buyBTN:FindFirstChild("Hitbox")

	if not (content and hitbox) then
		return
	end

	local amnt = content:FindFirstChild("Amnt")
	local robuxIcon = content:FindFirstChild("RobuxIcon")
	local buyText = content:FindFirstChild("BuyText")
	local child = childName and content:FindFirstChild(childName)

	if child then
		child.Visible = data ~= nil

		if data then
			local rewardName = getRewardName(data) -- equivalent call inferred; original call site unknown
			child.Text = rewardName
		end
	end

	if data and data.ProductId then
		buyBTN.Visible = true
		buyBTN:SetAttribute("ProductId", data.ProductId)
		local v38 = data.Stock and { data.Stock } or {}
		local v39, v40 = readStock(v38)
		local v41

		if #v38 > 0 and v40 > 0 then
			v41 = v39 <= 0
		else
			v41 = false
		end

		local v42 = v9.playerOwnsItem(localPlayer, data.Item) and client:GetInventoryVersion() == "Old"

		if v41 or v42 then
			if amnt then
				amnt.Text = v41 and "SOLD OUT" or "PURCHASED"
			end

			if robuxIcon then
				robuxIcon.Visible = false
			end

			if buyText then
				buyText.Visible = false
			end

			hitbox.Active = false
			buyBTN:SetAttribute("ProductId", nil)
		else
			if robuxIcon then
				robuxIcon.Visible = true
			end

			if buyText then
				buyText.Visible = true
			end

			hitbox.Active = true

			if not amnt then
				return
			end

			amnt.Text = "..."
			v:GetProductInfoAsync(data.ProductId, Enum.InfoType.Product):andThen(function(p)
				if buyBTN:GetAttribute("ProductId") ~= data.ProductId then
					return
				end

				amnt.Text = not p.PriceInRobux and "?" or v7:AddCommas(p.PriceInRobux)
			end):catch(function()
				amnt.Text = "?"
			end)
		end
	else
		buyBTN.Visible = false
		buyBTN:SetAttribute("ProductId", nil)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setGiftButton(giftBTN, p)
	local giftName

	if p then
		giftName = p.GiftName

		if not giftName then
			if p.Item and p.Item.Type == "Sword" then
				giftName = p.Item.Value or nil
			else
				giftName = nil
			end
		end
	end

	giftBTN.Visible = giftName ~= nil
	giftBTN:SetAttribute("GiftName", giftName or nil)
end

local function isSwordSlot(instance)
	local content = instance:FindFirstChild("Content")
	return content ~= nil and content:FindFirstChild("PH") ~= nil and content:FindFirstChild("PHTop") == nil
end

local function collectBottomSlotTemplates(instance)
	local v38 = v23[instance]

	if v38 then
		return v38
	end

	local clones = {}
	v23[instance] = clones
	local children = {}

	for _, child in instance:GetChildren() do
		if child.Name == "Padding" then
			table.insert(children, child)
		elseif child.Name == "Slot" then
			local content = child:FindFirstChild("Content")
			local v40 = content ~= nil and content:FindFirstChild("PH") ~= nil and content:FindFirstChild("PHTop") == nil and "sword" or "pack"

			if not clones[v40] then
				local clone2 = child:Clone()
				clone2.Name = "SlotTemplate"
				clones[v40] = clone2
			end

			child:Destroy()
		end
	end

	table.sort(children, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	if children[1] then
		children[1].LayoutOrder = -1000000
	end

	if children[2] then
		children[2].LayoutOrder = 1000000000
	end

	return clones
end

local function getBottomSlotTemplate(instance, p: string)
	local v38 = collectBottomSlotTemplates(instance)

	if v38[p] then
		return v38[p]
	end

	for k, v39 in v23 do
		if k ~= instance and v39[p] then
			return v39[p]
		end
	end

	return v38.pack or v38.sword
end

local function borrowStockLabels(child, instance)
	local content = child:FindFirstChild("Content")
	local content2 = instance and instance:FindFirstChild("Content")

	if not (content and content2) then
		return
	end

	for _, childName in { "LimitedBase", "Amnt" } do
		local clone2 = content:FindFirstChild(childName)

		if not clone2 then
			local child2 = content2:FindFirstChild(childName)

			if not child2 then
				continue
			end

			clone2 = child2:Clone()
			clone2.Parent = content
		end

		clone2.ZIndex = 8

		for _, guiObject in clone2:GetDescendants() do
			if guiObject:IsA("GuiObject") then
				guiObject.ZIndex = 9
			end
		end
	end

	for _, childName in { "Name", "TimerBase" } do
		local child2 = content:FindFirstChild(childName)
		local child3 = content2:FindFirstChild(childName)

		if not (child2 and child3) then
			continue
		end

		child2.AnchorPoint = child3.AnchorPoint
		child2.Position = child3.Position
		child2.Size = child3.Size
	end
end

local function isEmoteOnlyBundle(reward)
	local v38 = false

	for _, v39 in reward.Rewards or {} do
		for _, v40 in getRewardItems(v39) do
			if v40.Type ~= "Emote" then
				return false
			end

			v38 = true
		end
	end

	return v38
end

local function buildBundleEntries()
	local innerShowRooms = ReplicatedStorage2.Misc.ShowRooms.SwordPacks.InnerShowRooms
	local v38 = {}
	local v39 = {}
	local result = {}
	local count = 0

	for k, pack in v20:GetActiveBundles() do
		local rootFFlagStartTime = pack.RootFFlagStartTime or `pack{k}`

		if not v38[rootFFlagStartTime] then
			count += 1
			v38[rootFFlagStartTime] = count
			v39[rootFFlagStartTime] = 0
		end

		for _, reward in pack.Rewards do
			if not innerShowRooms:FindFirstChild(reward.ShowRoom) then
				continue
			end

			local stockKeys = getStockKeys(reward)
			local v41, initialStock = readStock(stockKeys)
			local limited

			if #stockKeys > 0 then
				limited = initialStock > 0
			else
				limited = false
			end

			if limited and v41 <= 0 then
				continue
			end

			v39[rootFFlagStartTime] += 1
			table.insert(result, {
				Bundle = reward,
				Pack = pack,
				Key = k .. "_" .. reward.Name,
				Group = v38[rootFFlagStartTime],
				Position = v39[rootFFlagStartTime],
				Limited = limited,
				EmoteOnly = isEmoteOnlyBundle(reward),
				FullPack = (reward.TemplateType or reward.Type) ~= "Sword",
				InitialStock = initialStock,
				Name = reward.Name or ""
			})
		end
	end

	table.sort(result, function(a, b)
		if a.Limited ~= b.Limited then
			return a.Limited
		end

		if a.Limited then
			if a.EmoteOnly ~= b.EmoteOnly then
				return b.EmoteOnly
			end

			if a.InitialStock == b.InitialStock then
				return a.Name < b.Name
			end

			return a.InitialStock < b.InitialStock
		else
			if a.Group ~= b.Group then
				return a.Group < b.Group
			end

			if a.FullPack == b.FullPack then
				return a.Position > b.Position
			end

			return a.FullPack
		end
	end)
	table.clear(v31)

	for k, v40 in result do
		v31[v40.Bundle] = k
	end

	return result
end

local function getSlideDirection(p, p2)
	if not next(v31) then
		buildBundleEntries()
	end

	local v38 = p and v31[p]
	local v39 = p2 and v31[p2]

	if not v38 or not v39 or v38 == v39 then
		return nil
	end

	if v38 < v39 then
		return 1
	end

	return -1
end

function NewShowcaseController:CreateBottomSlot(instance, parent, name: string, p)
	local clone2 = instance:Clone()
	clone2.Name = name
	clone2.Parent = parent
	local hitbox = clone2:FindFirstChild("Hitbox")

	if hitbox then
		animateButton(hitbox, "Slot") -- equivalent call inferred; original call site unknown
		hitbox.Activated:Connect(function()
			self:ShowBundle(p)
		end)
	end

	table.insert(v36, clone2)
	v29[clone2] = p
	return clone2
end

function NewShowcaseController:RenderBottomSlots(instance)
	local serverTimeNow = workspace:GetServerTimeNow()
	local v38 = {}

	for k, v39 in buildBundleEntries() do
		local bundle = v39.Bundle
		local packEndDate = getPackEndDate(v39.Pack) -- equivalent call inferred; original call site unknown
		local key = v39.Key
		v38[key] = true
		local child = instance:FindFirstChild(key)

		if not child then
			local templateType = bundle.TemplateType or bundle.Type or "Sword"
			local bottomSlotTemplate = getBottomSlotTemplate(instance, templateType == "Sword" and "sword" or "pack")

			if not bottomSlotTemplate then
				continue
			end

			child = self:CreateBottomSlot(bottomSlotTemplate, instance, key, bundle)

			if #getStockKeys(bundle) > 0 then
				borrowStockLabels(child, getBottomSlotTemplate(instance, "pack"))
			end
		end

		local content = child:FindFirstChild("Content")

		if not content then
			continue
		end

		local name = content:FindFirstChild("Name")

		if name then
			name.Text = bundle.Name
		end

		if bundle.Color and (bundle.TemplateType or bundle.Type) ~= "Sword" then
			local base = child:FindFirstChild("Base")
			local uIStroke = base and base:FindFirstChild("UIStroke")

			if uIStroke and uIStroke:IsA("UIStroke") then
				uIStroke.Color = bundle.Color
			end
		end

		for _, childName in { "PH", "PHTop", "PHBtm" } do
			local image = content:FindFirstChild(childName)

			if image and image:IsA("ImageLabel") then
				image.Image = bundle.Image ~= "" and bundle.Image or v8:GetIcon("DEFAULT_MISSING")
			end
		end

		local timerBase = content:FindFirstChild("TimerBase")
		local timeText = timerBase and timerBase:FindFirstChild("TimeText")

		if timeText then
			timeText.Text = v7:FormatTimeWithDays((math.max(packEndDate - serverTimeNow, 0)))
		end

		local limitedBase = content:FindFirstChild("LimitedBase")
		local amnt = content:FindFirstChild("Amnt")
		local stockKeys = getStockKeys(bundle)

		if #stockKeys > 0 then
			local v40, v41 = readStock(stockKeys)

			if limitedBase then
				limitedBase.Visible = true
			end

			if amnt then
				amnt.Visible = true
				amnt.Text = v40 <= 0 and "SOLD OUT" or formatStock(v40, v41)
			end
		else
			if limitedBase then
				limitedBase.Visible = false
			end

			if amnt then
				amnt.Visible = false
			end
		end

		child.LayoutOrder = k
		child.Visible = true
	end

	for _, guiObject in instance:GetChildren() do
		if not guiObject:IsA("GuiObject") or guiObject.Name == "Padding" or guiObject.Name == "SlotTemplate" or v38[guiObject.Name] then
			continue
		end

		v29[guiObject] = nil
		guiObject:Destroy()
	end

	refreshBundleSelection(self.CurrentBundle)
end

function NewShowcaseController:RenderNormal(p)
	local middle = normalShowcase:WaitForChild("Middle")
	local title = middle:WaitForChild("TitleBase"):FindFirstChild("Title")

	if title then
		title.Text = p.Name
	end

	local leftSlots = middle:WaitForChild("LeftSlots")
	local rightSlots = middle:WaitForChild("RightSlots")
	local previewEntries = buildPreviewEntries(p)
	local last = math.ceil(#previewEntries / 2)

	if not clone then
		local v39 = nil

		for _, v41 in { leftSlots, rightSlots } do
			for _, child in v41:GetChildren() do
				if child.Name ~= "Slot" then
					continue
				end

				local content = child:FindFirstChild("Content")

				if content and content:FindFirstChild("PackText") then
					v39 = child
					break
				else
					v39 = v39 or child
				end
			end

			if not v39 then
				continue
			end

			local content = v39:FindFirstChild("Content")

			if content and content:FindFirstChild("PackText") then
				break
			end
		end

		if v39 then
			clone = v39:Clone()
			size = v39.Size
		end
	end

	if not clone then
		return
	end

	for _, v39 in {
		{
			container = leftSlots,
			first = 1,
			last = last
		},
		{
			container = rightSlots,
			first = last + 1,
			last = #previewEntries
		}
	} do
		local v40 = math.max(v39.last - v39.first + 1, 0)
		local previewSlots = ensurePreviewSlots(v39.container, v40, clone)

		for k, previewSlot in previewSlots do
			local previewEntry = previewEntries[v39.first + k - 1]
			previewSlot.Visible = previewEntry ~= nil
			bindPreviewSlot(previewSlot, previewEntry and previewEntry.Item)
			applyPreviewTag(previewSlot, previewEntry and previewEntry.Tag)
		end
	end

	setBuyButton(
		middle:WaitForChild("LeftButtons"):WaitForChild("BuyBTN"),
		p.Rewards and p.Rewards[1],
		"SingleWeaponText"
	)
	setGiftButton(middle:WaitForChild("LeftButtons"):WaitForChild("GiftBTN"), p.Rewards and p.Rewards[1]) -- equivalent call inferred; original call site unknown
	setBuyButton(
		middle:WaitForChild("RightButtons"):WaitForChild("BuyBTN"),
		p.Rewards and p.Rewards[2],
		"DualWeaponText"
	)
	setGiftButton(middle:WaitForChild("RightButtons"):WaitForChild("GiftBTN"), p.Rewards and p.Rewards[2]) -- equivalent call inferred; original call site unknown
	self:RenderBottomSlots(normalShowcase:WaitForChild("Bottom"):WaitForChild("Slots"))
end

function NewShowcaseController:RenderLimited(p)
	local left = limitedQuantity:WaitForChild("Left")
	local title = left:WaitForChild("TitleBase"):FindFirstChild("Title")

	if title then
		title.Text = p.Name
	end

	local v38 = p.Rewards and p.Rewards[1]
	local rewardItems = getRewardItems(v38)
	local stockText = left:FindFirstChild("StockText")

	if stockText then
		local v39, v40 = readStock(getStockKeys(p))
		stockText.Text = "Stock: " .. formatStock(v39, v40)
	end

	local v39 = {}

	for _, child in left:WaitForChild("LeftSlots"):GetChildren() do
		if child.Name == "Slot" then
			table.insert(v39, child)
		end
	end

	local rightSlot = left:FindFirstChild("RightSlot")

	if rightSlot then
		table.insert(v39, rightSlot)
	end

	for k, v40 in v39 do
		local rewardItem = rewardItems[k]
		v40.Visible = rewardItem ~= nil
		bindPreviewSlot(v40, rewardItem)
	end

	local buttons = left:WaitForChild("Buttons")
	setBuyButton(buttons:WaitForChild("BuyBTN"), v38)
	setGiftButton(buttons:WaitForChild("GiftBTN"), v38) -- equivalent call inferred; original call site unknown
	self:RenderBottomSlots(limitedQuantity:WaitForChild("Bottom"):WaitForChild("Slots"))
end

function NewShowcaseController:ShowBundle(p)
	if not p then
		return
	end

	local v38 = self._sceneBundle == p
	local _sceneBundle = self._sceneBundle

	if not next(v31) then
		buildBundleEntries()
	end

	local v39 = _sceneBundle and v31[_sceneBundle]
	local v40 = p and v31[p]
	local v41

	if v39 and v40 and v39 ~= v40 then
		v41 = v39 < v40 and 1 or -1
	end

	self.CurrentBundle = p
	self._sceneBundle = p
	v26 = #(p.Rewards or {})
	normalShowcase.Visible = true
	limitedQuantity.Visible = false

	if mainShowcase then
		mainShowcase.Visible = false
	end

	if not v38 then
		setPreviewSelection(nil) -- equivalent call inferred; original call site unknown
		v20._bundleChanged:Fire(p, v41)
	end

	self:RenderNormal(p)

	if not v38 then
		self:PlayBundleEmote(p)
		self:UpdateBackgroundWeapon(p)
	end

	self.BundleShown:Fire(p)
end

function NewShowcaseController:UpdateBackgroundWeapon(p2)
	local bundleWeaponIcon = getBundleWeaponIcon(p2)

	if not bundleWeaponIcon then
		return
	end

	task.spawn(function()
		local v38 = os.clock() + 3

		while os.clock() < v38 do
			if self.CurrentBundle ~= p2 then
				break
			end

			local showRoom = getShowRoom() -- equivalent call inferred; original call site unknown

			if showRoom and showRoom.Name == p2.ShowRoom then
				local background = showRoom:FindFirstChild("Background")
				local surfaceGui = background and background:FindFirstChildWhichIsA("SurfaceGui")
				local weaponPH = surfaceGui and surfaceGui:FindFirstChild("WeaponPH")

				if weaponPH and weaponPH:IsA("ImageLabel") then
					weaponPH.Image = bundleWeaponIcon
					break
				end
			end

			task.wait(0.05)
		end
	end)
end

function NewShowcaseController:PlayBundleEmote(p2)
	local v38 = {}

	for _, v39 in buildPreviewEntries(p2) do
		if v39.Item.Type == "Emote" then
			table.insert(v38, v39.Item.Value)
		end
	end

	if #v38 == 0 then
		return
	end

	task.defer(function()
		if self.CurrentBundle ~= p2 then
			return
		end

		local showRoomNPC = getShowRoomNPC() -- equivalent call inferred; original call site unknown

		if not showRoomNPC then
			return
		end

		showRoomNPC:SetAttribute("IsShown", false)
		showRoomNPC:SetAttribute("Slash", nil)
		showRoomNPC:SetAttribute("NoEmote", nil)
		showRoomNPC:SetAttribute("IgnoreAccessory", nil)
		showRoomNPC:SetAttribute("Emote", v38[math.random(#v38)])
		showRoomNPC:SetAttribute("IsShown", true)
	end)
end

function NewShowcaseController:Refresh()
	if v4:IsOpen(self.WindowName) and self.CurrentBundle then
		self:ShowBundle(self.CurrentBundle)
	end
end

function NewShowcaseController:ApplyTuning()
	v18.CameraOffset = CFrame.new(v21.CameraSide, v21.CameraHeight, v21.CameraDistance)
	v18.CameraOffsetSolo = CFrame.new(v21.SoloCameraSide, v21.CameraHeight, v21.CameraDistance)
	v18.HoloPadLayout = buildHoloPadLayout(v26)
	local swordPacks = v17:Get("SwordPacks")
	local showRoom = swordPacks and swordPacks.Info.ShowRoom

	if showRoom and showRoom.applyLayout then
		showRoom.applyLayout()
	end

	if swordPacks and showRoom and showRoom.moveToShowRoom and swordPacks.Info.Selected then
		showRoom.moveToShowRoom(swordPacks.Info.Selected)
	end
end

function NewShowcaseController:DumpTuning()
	local v38 = {}

	for k in v21 do
		table.insert(v38, k)
	end

	table.sort(v38)
	local v39 = {}

	for _, v40 in v38 do
		table.insert(v39, (`{v40}={v21[v40]}`))
	end

	local joined = table.concat(v39, " | ")
	print(joined)
	return joined
end

function NewShowcaseController:DumpPreviews()
	local currentBundle = self.CurrentBundle

	if not currentBundle then
		return "nenhum bundle aberto"
	end

	local previewEntries = buildPreviewEntries(currentBundle)
	local v38 = {}

	for k, previewEntry in previewEntries do
		local item = previewEntry.Item
		local v39

		if item and typeof(item.Value) == "string" and (item.Type == "Sword" or item.Type == "SwordAccessory") and v13:GetCollection()[item.Value] then
			v39 = item.Value
		end

		table.insert(
			v38,
			(`{k}. [{previewEntry.Tag}] {previewEntry.Item.Type}:{tostring(previewEntry.Item.Value)} ({v39 and "com acessorio" or "sem acessorio"})`)
		)
	end

	local formatted = `{currentBundle.Name} tem {#previewEntries} previews -> {table.concat(v38, " | ")}`
	print(formatted)
	return formatted
end

function NewShowcaseController:RegisterTuningCommands()
	local function report(p: string)
		return (`{p} = {v21[p]}`)
	end

	local function nudge(p: string)
		return function(value: number?)
			if value == nil then
				return (`{p} = {v21[p]}`)
			end

			if typeof(value) ~= "number" then
				return (`{p} precisa de um numero`)
			end

			v21[p] += value
			self:ApplyTuning()
			return (`{p} = {v21[p]}`)
		end
	end

	for k in v21 do
		local v38 = k
		v19.register_quick(`showcase_{string.lower(k)}`, function(value: number?)
			if value == nil then
				return (`{v38} = {v21[v38]}`)
			end

			if typeof(value) ~= "number" then
				return (`{v38} precisa de um numero`)
			end

			v21[v38] += value
			self:ApplyTuning()
			return (`{v38} = {v21[v38]}`)
		end)
	end

	v19.register_quick("showcase_set", function(value: string?, value2: number?)
		if typeof(value) ~= "string" then
			return "uso: showcase_set <campo> <valor>"
		end

		local v38 = nil

		for k in v21 do
			if string.lower(k) ~= string.lower(value) then
				continue
			end

			v38 = k
			break
		end

		if not v38 then
			return (`campo desconhecido: {value}`)
		end

		if typeof(value2) ~= "number" then
			return (`{v38} = {v21[v38]}`)
		end

		v21[v38] = value2
		self:ApplyTuning()
		return (`{v38} = {v21[v38]}`)
	end)
	v19.register_quick("showcase_dump", function()
		return self:DumpTuning()
	end)
	v19.register_quick("showcase_previews", function()
		return self:DumpPreviews()
	end)
	v19.register_quick("showcase_reload", function()
		self:ApplyTuning()
		return self:DumpTuning()
	end)
end

function NewShowcaseController:Hook()
	v22 = v2.Client:WaitReplion("LimitedStockItems")
	normalShowcase.Visible = false
	limitedQuantity.Visible = false
	collectBottomSlotTemplates(normalShowcase.Bottom.Slots)
	collectBottomSlotTemplates(limitedQuantity.Bottom.Slots)

	for _, childName in { "WeaponPH", "BlueEffect", "Grid" } do
		local child = normalShowcase.BG:FindFirstChild(childName)

		if child then
			child.Visible = false
		end
	end

	if mainShowcase then
		mainShowcase.Visible = false
	end

	for _, folder in { normalShowcase, limitedQuantity } do
		for _, descendant in folder:GetDescendants() do
			if descendant.Name == "CloseBTN" then
				descendant.Active = true
				descendant.Interactable = true

				if descendant.Parent == normalShowcase.BG then
					descendant.Position = uDim
				end

				animateButton(descendant, "Close") -- equivalent call inferred; original call site unknown
				descendant.Activated:Connect(function()
					v17:Close()
				end)
			elseif descendant.Name == "BuyBTN" or descendant.Name == "GiftBTN" then
				local hitbox = descendant:FindFirstChild("Hitbox")

				if hitbox then
					animateButton(hitbox, "Buy") -- equivalent call inferred; original call site unknown
					local v38 = descendant
					hitbox.Activated:Connect(function()
						if v38.Name == "BuyBTN" then
							local productId = v38:GetAttribute("ProductId")

							if productId then
								v15:PromptPurchase(productId, Enum.InfoType.Product)
							end
						else
							local giftName = v38:GetAttribute("GiftName")

							if giftName then
								v14:SetGift(giftName)
							end
						end
					end)
				end
			end
		end
	end

	v17.ShowRoomClosed:Connect(function()
		self._sceneBundle = nil
		v18.CameraOffset = nil
		v18.CameraOffsetSolo = nil
		v18.HoloPadLayout = nil
	end)
	v17.ShowRoomOpened:Connect(function(p: string)
		self._sceneBundle = nil

		if p == "SwordPacks" and self:IsEnabled() then
			v18.CameraOffset = CFrame.new(v21.CameraSide, v21.CameraHeight, v21.CameraDistance)
			v18.CameraOffsetSolo = CFrame.new(v21.SoloCameraSide, v21.CameraHeight, v21.CameraDistance)
			v18.HoloPadLayout = buildHoloPadLayout(v26)
			local topRankedBundle = v20:GetTopRankedBundle()

			if topRankedBundle then
				self:ShowBundle(topRankedBundle)
			end
		else
			v18.CameraOffset = nil
			v18.CameraOffsetSolo = nil
			v18.HoloPadLayout = nil
		end
	end)
	v6.Every(1, function()
		if not v4:IsOpen(self.WindowName) then
			return
		end

		local v38

		if limitedQuantity.Visible then
			v38 = limitedQuantity.Bottom
		else
			v38 = normalShowcase.Bottom
		end

		self:RenderBottomSlots(v38.Slots)
	end)
	v22:OnChange("Stock", function()
		self:Refresh()
	end)
	client:OnChange("Sword", function()
		self:Refresh()
	end)
	pcall(function()
		self:RegisterTuningCommands()
	end)
end

function NewShowcaseController:Start()
	v5:WaitForData()
	v2.Client:WaitReplion("Data")
	self:Hook()
end

return NewShowcaseController