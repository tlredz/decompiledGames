local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local weapons = chickenOrHero:WaitForChild("Weapons")
local ShopConfig = require(weapons:WaitForChild("ShopConfig"))
local SkinCatalog = require(weapons:WaitForChild("SkinCatalog"))
local OfferRules = require(weapons:WaitForChild("OfferRules"))
local KnifeDisplayRig = require(weapons:WaitForChild("KnifeDisplayRig"))
local armoryNavigation = weapons:WaitForChild("ArmoryNavigation")
local armoryEvent = weapons:WaitForChild("ArmoryEvent")
local playerGui = localPlayer:WaitForChild("PlayerGui")
local MapLocator = require(chickenOrHero.Game:WaitForChild("MapLocator"))
local v = nil
local connections = {}
local folder = Instance.new("Folder")
folder.Name = "LocalKnifeDisplays"
folder.Parent = workspace
local folder2 = Instance.new("Folder")
folder2.Name = "LobbyKnifeLabels"
folder2.Parent = playerGui
local v2 = {}
local v3 = {}
local connections2 = {}
local v4 = {}
local v5 = {
	owned = 0,
	loaded = false
}
v5.owned = {}
local v6 = nil
local v7 = true
local count = 0
local binding = ShopConfig.binding(game.GameId)
local audio = chickenOrHero:WaitForChild("Audio")
local clone = table.clone(require(audio.AudioConfig))
clone.MaxVoices = 6
clone.MaxOneShotSeconds = 4
local AudioPlayback = require(audio.AudioPlayback)
local new = AudioPlayback.new
local gameAudio = game.SoundService:WaitForChild("GameAudio")
local AudioCatalog = require(audio.AudioCatalog)
local v8 = new(gameAudio, AudioCatalog, clone)
v8.folder.Name = "ShowroomAudioPlayback"
local v9 = nil
local v10 = {
	Equip = true,
	Windup = true,
	Swing = true,
	Dive = true,
	Hit = true,
	Sheath = true,
	Cancel = true
}
local v11 = {
	Balloon = Color3.fromRGB(255, 147, 197),
	Featured = Color3.fromRGB(192, 143, 255),
	Earnable = Color3.fromRGB(119, 194, 255),
	VIP = Color3.fromRGB(246, 202, 102)
}
local v12 = {
	Balloon = Color3.fromRGB(61, 29, 55),
	Featured = Color3.fromRGB(42, 25, 67),
	Earnable = Color3.fromRGB(18, 43, 67),
	VIP = Color3.fromRGB(57, 43, 22)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function connect(object, p)
	table.insert(connections2, object:Connect(p))
end

local function comma(p)
	return tostring((math.floor(p))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function info(p)
	if p == "Balloon" then
		return "BalloonDagger", nil, "FREE · BRING A FRIEND"
	elseif p == "Featured" then
		local featured = ShopConfig.featured(workspace:GetServerTimeNow())
		return featured.SkinId, featured.OfferKey, "ROBUX EXCLUSIVE"
	elseif p == "VIP" then
		return ShopConfig.Passes.VIP.RewardSkinId, "VIP", "VIP EXCLUSIVE"
	end

	return ShopConfig.Earnable.SkinId, nil, "EARN WITH GEMS"
end

local function permitted()
	return localPlayer:GetAttribute("ClientReady") == true and localPlayer:GetAttribute("InMatch") ~= true and localPlayer:GetAttribute("TutorialRouting") ~= true and localPlayer:GetAttribute("ScreenPresentationActive") ~= true and localPlayer:GetAttribute("AdminRefreshActive") ~= true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function open(p)
	if permitted() then
		armoryNavigation:Fire(p)
	end
end

local function text(billboardGui, name, text2, size, position, textColor)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.Text = text2
	textLabel.Size = size
	textLabel.Position = position
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextColor3 = textColor
	textLabel.TextScaled = true
	textLabel.TextWrapped = true
	textLabel.TextStrokeTransparency = 0.35
	textLabel.TextStrokeColor3 = Color3.fromRGB(12, 14, 22)
	textLabel.Parent = billboardGui
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint.MinTextSize = 8
	uITextSizeConstraint.MaxTextSize = 24
	uITextSizeConstraint.Parent = textLabel
	return textLabel
end

local function billboard(adornee, name, p, studsOffsetWorldSpace)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = name
	billboardGui.Adornee = adornee
	billboardGui.Size = UDim2.fromScale(p.X, p.Y)
	billboardGui.StudsOffsetWorldSpace = studsOffsetWorldSpace
	billboardGui.AlwaysOnTop = false
	billboardGui.LightInfluence = 0
	billboardGui.MaxDistance = ShopConfig.Display.MaxDistance
	billboardGui.Active = true
	billboardGui.ResetOnSpawn = false
	billboardGui.Parent = folder2
	return billboardGui
end

local function priceText(p)
	local slot = p.slot
	local skinId, offerKey

	if slot == "Balloon" then
		skinId = "BalloonDagger"
	elseif slot == "Featured" then
		local featured = ShopConfig.featured(workspace:GetServerTimeNow())
		skinId = featured.SkinId
		offerKey = featured.OfferKey
	elseif slot == "VIP" then
		skinId = ShopConfig.Passes.VIP.RewardSkinId
		offerKey = "VIP"
	else
		skinId = ShopConfig.Earnable.SkinId
	end

	local v13

	if v5.owned[skinId] == true then
		v13 = true
	elseif p.slot == "VIP" then
		v13 = localPlayer:GetAttribute("HasVIP") == true
	else
		v13 = false
	end

	if v13 then
		return "OWNED  ·  VIEW"
	end

	if p.slot == "Balloon" then
		return "FREE  ·  CLAIM"
	end

	local flagship = p.slot == "Featured" and ShopConfig.Flagship

	if not flagship then
		if p.slot == "Earnable" then
			flagship = ShopConfig.Earnable
		else
			flagship = false
		end
	end

	if flagship then
		local status = OfferRules.status(flagship, workspace:GetServerTimeNow())

		if status ~= "Active" then
			if status == "Expired" then
				return "OFFER ENDED"
			end

			return "NOT AVAILABLE YET"
		end
	end

	if p.slot == "Earnable" then
		local v14 = SkinCatalog.get(skinId)
		local offer = v14 and v14.Offer

		if v14 and v14.Available and offer and offer.Currency == "gems" then
			return "◆  " .. tostring((math.floor(offer.Price))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
				"^,",
				""
			) .. "  ·  VIEW"
		end

		return "COMING SOON"
	else
		local passId = binding.PassIds[offerKey]

		if not passId or passId <= 0 then
			return "COMING SOON"
		end

		local v14 = v4[passId]

		if v14 == false then
			return "VIEW IN SHOP"
		end

		if type(v14) ~= "table" then
			return "CHECKING PRICE…"
		end

		if not v14.IsForSale then
			return "NOT ON SALE"
		end

		if type(v14.PriceInRobux) == "number" then
			return " " .. tostring((math.floor(v14.PriceInRobux))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
				"^,",
				""
			) .. "  ·  VIEW"
		end

		return "VIEW IN SHOP"
	end
end

local function update()
	for _, v13 in v2 do
		v13.button.Text = priceText(v13)
		v13.prompt.Enabled = permitted()
		local flagship = v13.slot == "Featured" and ShopConfig.Flagship

		if not flagship then
			if v13.slot == "Earnable" then
				flagship = ShopConfig.Earnable
			else
				flagship = false
			end
		end

		v13.timer.Text = flagship and OfferRules.countdown(flagship, workspace:GetServerTimeNow()) or ""
		v13.timer.Visible = v13.timer.Text ~= ""
		v13.button.Active = permitted()
		v13.button.AutoButtonColor = v13.button.Active
	end
end

local function remove(folder3)
	local v13 = v2[folder3]

	if not v13 then
		return
	end

	v2[folder3] = nil
	v13.activated:Disconnect()
	v13.triggered:Disconnect()

	if v9 == v13 then
		v9 = nil

		for k in v8.voices do
			v8:remove(k)
		end
	end

	for _, label in v13.labels do
		label:Destroy()
	end

	KnifeDisplayRig.destroy(v13.rig)

	if folder3.Parent then
		for k, transparency in v13.hiddenVisuals or {} do
			if k.Parent then
				k.Transparency = transparency
			end
		end

		for _, part in folder3:GetDescendants() do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 0
			end
		end
	end
end

local function completeStand(model)
	for _, childName in {
		"Humanoid",
		"HumanoidRootPart",
		"Torso",
		"Head",
		"Right Arm",
		"Left Arm",
		"Right Leg",
		"Left Leg"
	} do
		if not model:FindFirstChild(childName) then
			return false
		end
	end

	return true
end

local add

add = function(model)
	if not v7 or not v or model.Parent ~= v or not model:IsA("Model") then
		return
	end

	local shopSlot = model:GetAttribute("ShopSlot")

	if not v11[shopSlot] then
		return
	end

	if completeStand(model) then
		local skinId, v13

		if shopSlot == "Balloon" then
			skinId = "BalloonDagger"
			v13 = "FREE · BRING A FRIEND"
		elseif shopSlot == "Featured" then
			local featured = ShopConfig.featured(workspace:GetServerTimeNow())
			skinId = featured.SkinId
			local _ = featured.OfferKey
			v13 = "ROBUX EXCLUSIVE"
		elseif shopSlot == "VIP" then
			skinId = ShopConfig.Passes.VIP.RewardSkinId
			v13 = "VIP EXCLUSIVE"
		else
			skinId = ShopConfig.Earnable.SkinId
			v13 = "EARN WITH GEMS"
		end

		local v14 = SkinCatalog.get(skinId)
		local child = v14 and weapons.Models:FindFirstChild(v14.Model)
		local success, result = pcall(KnifeDisplayRig.create, v6 or model, model, child)

		if not success then
			warn("Lobby knife display:", result)
			return
		end

		remove(model)
		result.model.Parent = folder
		local transparenciesByDescendant = {}

		for _, descendant in model:GetDescendants() do
			if descendant:IsA("BasePart") then
				descendant.LocalTransparencyModifier = 1
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				transparenciesByDescendant[descendant] = descendant.Transparency
				descendant.Transparency = 1
			end
		end

		KnifeDisplayRig.animate(result, ({
			Balloon = 14,
			Earnable = 1,
			Featured = 4,
			VIP = 9
		})[shopSlot])
		local v15 = v11[shopSlot]
		local root = result.root
		local name = shopSlot .. "_Title"
		local vector2 = Vector2.new(4.5, 1.65)
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = name
		billboardGui.Adornee = root
		billboardGui.Size = UDim2.fromScale(vector2.X, vector2.Y)
		billboardGui.StudsOffsetWorldSpace = createVector(0, 4.4, 0)
		billboardGui.AlwaysOnTop = false
		billboardGui.LightInfluence = 0
		billboardGui.MaxDistance = ShopConfig.Display.MaxDistance
		billboardGui.Active = true
		billboardGui.ResetOnSpawn = false
		billboardGui.Parent = folder2
		text(billboardGui, "Category", v13, UDim2.fromScale(1, 0.18), UDim2.fromScale(0, 0), v15)
		text(
			billboardGui,
			"KnifeName",
			not v14 and "NEXT GEM KNIFE" or v14.Name or "NEXT GEM KNIFE",
			UDim2.fromScale(1, 0.31),
			UDim2.fromScale(0, 0.22),
			Color3.new(1, 1, 1)
		)
		local demo = text(
			billboardGui,
			"DemoAction",
			"PREVIEW · IDLE",
			UDim2.fromScale(1, 0.17),
			UDim2.fromScale(0, 0.6),
			Color3.fromRGB(214, 219, 228)
		)
		local timer = text(billboardGui, "OfferTimer", "", UDim2.fromScale(1, 0.18), UDim2.fromScale(0, 0.82), v15)
		local root2 = result.root
		local name2 = shopSlot .. "_Price"
		local vector3 = Vector2.new(3.35, 0.66)
		local studsOffsetWorldSpace = result.root.CFrame.LookVector * 0.85 + createVector(0, -0.65, 0)
		local billboardGui2 = Instance.new("BillboardGui")
		billboardGui2.Name = name2
		billboardGui2.Adornee = root2
		billboardGui2.Size = UDim2.fromScale(vector3.X, vector3.Y)
		billboardGui2.StudsOffsetWorldSpace = studsOffsetWorldSpace
		billboardGui2.AlwaysOnTop = false
		billboardGui2.LightInfluence = 0
		billboardGui2.MaxDistance = ShopConfig.Display.MaxDistance
		billboardGui2.Active = true
		billboardGui2.ResetOnSpawn = false
		billboardGui2.Parent = folder2
		billboardGui2.AlwaysOnTop = true
		local textButton = Instance.new("TextButton")
		textButton.Name = "ViewOffer"
		textButton.Size = UDim2.fromScale(1, 1)
		textButton.BackgroundColor3 = v12[shopSlot]
		textButton.BackgroundTransparency = 0.1
		textButton.TextColor3 = v15
		textButton.Font = Enum.Font.GothamBold
		textButton.TextScaled = true
		textButton.Parent = billboardGui2
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0.16, 0)
		uICorner.Parent = textButton
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Color = v15
		uIStroke.Transparency = 0.3
		uIStroke.Thickness = 1
		uIStroke.Parent = textButton
		local uIPadding = Instance.new("UIPadding")
		uIPadding.PaddingLeft = UDim.new(0.055, 0)
		uIPadding.PaddingRight = UDim.new(0.055, 0)
		uIPadding.PaddingTop = UDim.new(0.18, 0)
		uIPadding.PaddingBottom = UDim.new(0.18, 0)
		uIPadding.Parent = textButton
		local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
		uITextSizeConstraint.MinTextSize = 8
		uITextSizeConstraint.MaxTextSize = 22
		uITextSizeConstraint.Parent = textButton
		local proximityPrompt = Instance.new("ProximityPrompt")
		proximityPrompt.Name = "ViewKnife"
		proximityPrompt.ActionText = shopSlot == "Balloon" and "Get free dagger" or "View in shop"
		proximityPrompt.ObjectText = not v14 and "Gem knives" or v14.Name or "Gem knives"
		proximityPrompt.MaxActivationDistance = ShopConfig.Display.PromptDistance
		proximityPrompt.RequiresLineOfSight = false
		proximityPrompt.HoldDuration = 0
		proximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
		proximityPrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
		proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
		proximityPrompt.UIOffset = Vector2.new(0, 70)
		proximityPrompt.Parent = result.root
		local v21 = {
			slot = shopSlot,
			skin = skinId,
			rig = result,
			labels = { billboardGui, billboardGui2 },
			button = textButton,
			prompt = proximityPrompt,
			timer = timer,
			demo = demo,
			hiddenVisuals = transparenciesByDescendant
		}

		function v21.cue(p)
			if v9 ~= v21 or not permitted() or localPlayer:GetAttribute("ArmoryOpen") == true or localPlayer:GetAttribute("BalloonOfferOpen") == true then
				return
			end

			local v22

			if v10[p] then
				v22 = "Knife_" .. (v14 and v14.SoundProfile or "BaseDagger") .. "_" .. p or p
			else
				v22 = p
			end

			v8:one(v22, result.root, v10[p] and 0.65 or 0.2)
		end

		v21.activated = textButton.Activated:Connect(function()
			open(shopSlot) -- equivalent call inferred; original call site unknown
		end)
		v21.triggered = proximityPrompt.Triggered:Connect(function()
			open(shopSlot) -- equivalent call inferred; original call site unknown
		end)
		v2[model] = v21
		update()
	elseif not v3[model] then
		v3[model] = true
		task.spawn(function()
			local v13 = os.clock() + 10

			while v7 and model.Parent == v and not completeStand(model) and os.clock() < v13 do
				task.wait(0.1)
			end

			v3[model] = nil

			if v7 and model.Parent == v and completeStand(model) then
				add(model)
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rebuild()
	if v then
		for _, child in v:GetChildren() do
			add(child)
		end
	end
end

local function refreshStands()
	local lobby = MapLocator.lobby()
	local knifeDisplays = lobby and lobby:FindFirstChild("KnifeDisplays")

	if knifeDisplays ~= v then
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
		local v13 = {}

		for k in v2 do
			table.insert(v13, k)
		end

		for _, v14 in v13 do
			remove(v14)
		end

		v = knifeDisplays

		if v then
			table.insert(connections, v.ChildAdded:Connect(add))
			table.insert(connections, v.ChildRemoved:Connect(remove))
		end
	end

	if v then
		for _, child in v:GetChildren() do
			if not (v2[child] or v3[child]) then
				add(child)
			end
		end
	end
end

local function dress(instance)
	count += 1
	local v13 = count
	task.spawn(function()
		local humanoid = instance:WaitForChild("Humanoid", 8)

		if not humanoid then
			return
		end

		local v14 = os.clock() + 8

		while v7 and v13 == count and localPlayer.Character == instance and not localPlayer:HasAppearanceLoaded() and os.clock() < v14 do
			task.wait(0.1)
		end

		if not v7 or v13 ~= count or localPlayer.Character ~= instance then
			return
		end

		local success, result = pcall(function()
			local appliedDescription = humanoid:GetAppliedDescription()
			local humanoidModelFromDescriptionAsync = Players:CreateHumanoidModelFromDescriptionAsync(
				appliedDescription,
				Enum.HumanoidRigType.R6
			)
			appliedDescription:Destroy()
			return humanoidModelFromDescriptionAsync
		end)

		if v7 and v13 == count then
			if not success then
				warn("Lobby avatar preview unavailable; keeping display rigs:", result)
				return
			end

			if v6 then
				v6:Destroy()
			end

			v6 = result
			rebuild() -- equivalent call inferred; original call site unknown
		elseif success then
			result:Destroy()
		end
	end)
end

refreshStands()
connect(localPlayer.CharacterAdded, dress) -- equivalent call inferred; original call site unknown
table.insert(connections2, armoryEvent.OnClientEvent:Connect(function(p, p2)
	if p == "State" and type(p2) == "table" then
		v5 = p2
		update()
	end
end))

for _, v13 in {
	"HasVIP",
	"ClientReady",
	"InMatch",
	"TutorialRouting",
	"ScreenPresentationActive",
	"AdminRefreshActive"
} do
	connect(localPlayer:GetAttributeChangedSignal(v13), update) -- equivalent call inferred; original call site unknown
end

local total = 0
local skinId = ShopConfig.featured(workspace:GetServerTimeNow()).SkinId
table.insert(connections2, RunService.PreAnimation:Connect(function()
	for _, v13 in v2 do
		KnifeDisplayRig.preAnimation(v13.rig)
	end
end))
table.insert(connections2, RunService.PreSimulation:Connect(function(dt)
	total += dt

	if total > 0.2 then
		total = 0
		refreshStands()
		v8:update()
		update()
		local skinId2 = ShopConfig.featured(workspace:GetServerTimeNow()).SkinId

		if skinId2 ~= skinId then
			skinId = skinId2
			rebuild() -- equivalent call inferred; original call site unknown
		end

		local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
		local soundDistance = ShopConfig.Display.SoundDistance
		local v13 = nil

		for _, v14 in v2 do
			local v15 = not humanoidRootPart and 1e999 or (humanoidRootPart.Position - v14.rig.root.Position).Magnitude or 1e999
			v14.near = v15 < ShopConfig.Display.AnimationDistance

			if not (permitted() and localPlayer:GetAttribute("ArmoryOpen") ~= true and localPlayer:GetAttribute("BalloonOfferOpen") ~= true and v15 < soundDistance) then
				continue
			end

			v13 = v14
			soundDistance = v15
		end

		if v13 ~= v9 then
			for k in v8.voices do
				v8:remove(k)
			end

			v9 = v13
		end
	end

	for _, v13 in v2 do
		KnifeDisplayRig.step(v13.rig, v13.near ~= false, dt, v9 == v13, v13.cue)
		local text2 = "PREVIEW · " .. (v13.rig.model:GetAttribute("PreviewAction") or "IDLE")

		if v13.demo.Text ~= text2 then
			v13.demo.Text = text2
		end
	end
end))
rebuild() -- equivalent call inferred; original call site unknown

if localPlayer.Character then
	local character = localPlayer.Character
	count += 1
	local v13 = count
	task.spawn(function()
		local humanoid = character:WaitForChild("Humanoid", 8)

		if not humanoid then
			return
		end

		local v14 = os.clock() + 8

		while v7 and v13 == count and localPlayer.Character == character and not localPlayer:HasAppearanceLoaded() and os.clock() < v14 do
			task.wait(0.1)
		end

		if not v7 or v13 ~= count or localPlayer.Character ~= character then
			return
		end

		local success, result = pcall(function()
			local appliedDescription = humanoid:GetAppliedDescription()
			local humanoidModelFromDescriptionAsync = Players:CreateHumanoidModelFromDescriptionAsync(
				appliedDescription,
				Enum.HumanoidRigType.R6
			)
			appliedDescription:Destroy()
			return humanoidModelFromDescriptionAsync
		end)

		if v7 and v13 == count then
			if not success then
				warn("Lobby avatar preview unavailable; keeping display rigs:", result)
				return
			end

			if v6 then
				v6:Destroy()
			end

			v6 = result
			rebuild() -- equivalent call inferred; original call site unknown
		elseif success then
			result:Destroy()
		end
	end)
end

armoryEvent:FireServer("Get")
task.spawn(function()
	for _, v13 in { ShopConfig.Flagship.OfferKey, ShopConfig.GhostFlagship.OfferKey, "VIP" } do
		local passId = binding.PassIds[v13]

		if not (passId and passId > 0 and v4[passId] == nil) then
			continue
		end

		local success, productInfoAsync = pcall(
			MarketplaceService.GetProductInfoAsync,
			MarketplaceService,
			passId,
			Enum.InfoType.GamePass
		)

		if not v7 then
			break
		end

		v4[passId] = success and productInfoAsync or false
		update()
	end
end)
script.Destroying:Connect(function()
	v7 = false
	count += 1

	for _, connection in connections2 do
		connection:Disconnect()
	end

	for _, connection in connections do
		connection:Disconnect()
	end

	local v13 = {}

	for k in v2 do
		table.insert(v13, k)
	end

	for _, v14 in v13 do
		remove(v14)
	end

	if v6 then
		v6:Destroy()
	end

	v8:destroy()
	folder:Destroy()
	folder2:Destroy()
end)