local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Maid = require(ReplicatedStorage.SharedUtils.Maid)
local SettingsFlags = require(ReplicatedStorage.SharedUtils.SettingsFlags)
local HighlightController = require(ReplicatedStorage.SharedUtils.HighlightController)
local CameraModeController = require(ReplicatedStorage.SharedUtils.CameraModeController)
local ShieldSourceIcon = require(ReplicatedStorage.SharedUtils.ShieldSourceIcon)
local v = { "Players", "InGamePlayers" }
local uDim = UDim2.new(10.4, 0, 2.4, 0)
local color = Color3.new(1, 1, 1)
local v2 = {
	[Enum.PreferredInput.KeyboardAndMouse] = 0.3,
	[Enum.PreferredInput.Gamepad] = 0.15,
	[Enum.PreferredInput.Touch] = 0.2
}
local LoadoutClient = {}
local flag = false
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local maid = Maid.new()
local maid2 = Maid.new()
local maid3 = Maid.new()
local assets = nil
local clone = nil
local trinketData = nil
local size = nil
local iconsByChildName = {}
local visible = false
local visible2 = false
local v5 = false
local v6 = true
local v7 = false
local flag2 = false
local heartbeatConnection = nil
local touchTapConnection = nil
local total = 0
local parts = {}
local v8 = nil
local v9 = nil
local v10 = 0
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

-- equivalent calls inferred from this helper; original call sites unknown
local function localHRP()
	local character = localPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isValidPart(instance)
	return instance and instance.Parent and instance:IsDescendantOf(workspace)
end

local function getPointer()
	local preferredInput = UserInputService.PreferredInput

	if preferredInput == Enum.PreferredInput.Touch then
		if v9 and os.clock() < v10 then
			return v9
		end

		return currentCamera.ViewportSize * 0.5
	elseif preferredInput == Enum.PreferredInput.Gamepad then
		return currentCamera.ViewportSize * 0.5
	else
		return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	end
end

local function intervalForMode()
	return v2[UserInputService.PreferredInput] or 0.2
end

local function rebuildTagged()
	parts = {}

	for _, part in ipairs(CollectionService:GetTagged("LoadoutTargets")) do
		if part:IsA("BasePart") and isValidPart(part) then
			table.insert(parts, part)
		end
	end
end

local function refreshOccludeFilter()
	local filterDescendantsInstances = {}

	for _, childName in ipairs(v) do
		local child = workspace:FindFirstChild(childName)

		if child then
			table.insert(filterDescendantsInstances, child)
		end
	end

	for _, v12 in ipairs(CollectionService:GetTagged("Obstacle")) do
		table.insert(filterDescendantsInstances, v12)
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isVisible(hrp)
	local position = currentCamera.CFrame.Position
	local v11 = hrp.Position - position
	return v11.Magnitude < 0.001 or workspace:Raycast(position, v11, raycastParams) == nil
end

local function collectCandidates(pointer)
	local v11 = 0.25 * currentCamera.ViewportSize.Y
	local position = currentCamera.CFrame.Position
	local v12 = localHRP() -- equivalent call inferred; original call site unknown
	local result = {}

	for _, hrp in ipairs(parts) do
		if not (hrp ~= v12 and isValidPart(hrp) and hrp.Parent and (hrp.Position - position).Magnitude <= 50) then
			continue
		end

		local worldToViewportPoint = currentCamera:WorldToViewportPoint(hrp.Position)

		if not (worldToViewportPoint.Z > 0) then
			continue
		end

		local magnitude = (Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y) - pointer).Magnitude

		if magnitude <= v11 then
			table.insert(result, {
				char = hrp.Parent,
				hrp = hrp,
				pixel = magnitude,
				depth = worldToViewportPoint.Z
			})
		end
	end

	table.sort(result, function(a, b)
		if math.abs(a.pixel - b.pixel) < 4 then
			return a.depth < b.depth
		end

		return a.pixel < b.pixel
	end)
	return result
end

local function scan()
	local pointer = getPointer()

	if not pointer then
		return nil
	end

	local v11 = collectCandidates(pointer)

	if #v11 == 0 then
		return nil
	end

	local v12 = nil

	for _, v14 in ipairs(v11) do
		if not isVisible(v14.hrp) then
			continue
		end

		v12 = v14
		break
	end

	if not v12 then
		return nil
	end

	if not v8 or v12.char == v8 then
		return v12.char
	end

	for _, v15 in ipairs(v11) do
		if v15.char ~= v8 then
			continue
		end

		if isVisible(v15.hrp) and v12.pixel >= v15.pixel / 1.2 then
			return v8
		end

		break
	end

	return v12.char
end

local function applyBillboardSize()
	if not (clone and clone.Parent) then
		return
	end

	if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
		clone.Size = uDim
	elseif size then
		clone.Size = size
	end
end

local function ensureBillboard()
	if clone and clone.Parent then
		return true
	end

	if not assets then
		return false
	end

	clone = assets:Clone()
	clone.Enabled = false
	clone.Adornee = nil
	local frame = clone:FindFirstChild("Frame")
	local healthFrame = frame and frame:FindFirstChild("HealthFrame")

	if healthFrame then
		healthFrame.Visible = visible
	end

	local child = frame and frame:FindFirstChild("Slot" .. 1)

	if child then
		child.Visible = visible2
	end

	local child2 = frame and frame:FindFirstChild("Slot" .. 2)

	if child2 then
		child2.Visible = visible2
	end

	clone.Parent = currentCamera

	if clone and clone.Parent then
		if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
			clone.Size = uDim
		elseif size then
			clone.Size = size
		end
	end

	return true
end

local function resolveIcon(attribute)
	if not attribute or attribute == "None" or attribute == "" then
		return nil
	end

	if iconsByChildName[attribute] ~= nil then
		return iconsByChildName[attribute] or nil
	end

	trinketData = trinketData or ReplicatedStorage:FindFirstChild("TrinketData")

	if not trinketData then
		return nil
	end

	local icon = false
	local child = trinketData:FindFirstChild(attribute)

	if child then
		local success, result = pcall(require, child)

		if success and type(result) == "table" and type(result.Icon) == "string" and result.Icon ~= "" then
			icon = result.Icon
		end
	end

	iconsByChildName[attribute] = icon
	return icon or nil
end

local function repaintIcons(instance)
	if not (clone and clone.Parent) then
		return
	end

	local frame = clone:FindFirstChild("Frame")

	if not frame then
		return
	end

	for i = 1, 2 do
		local child = frame:FindFirstChild("Slot" .. i)
		local itemImage = child and child:FindFirstChild("ItemImage")

		if not itemImage then
			continue
		end

		local icon = resolveIcon(instance:GetAttribute("EquippedTrinket" .. i))

		if icon then
			itemImage.Image = icon
			itemImage.Visible = true
		else
			itemImage.Visible = false
		end
	end
end

local function refreshSlotVisibility()
	if not (clone and clone.Parent) then
		return
	end

	local frame = clone:FindFirstChild("Frame")

	if not frame then
		return
	end

	local child = frame:FindFirstChild("Slot" .. 1)

	if child then
		child.Visible = visible2
	end

	local child2 = frame:FindFirstChild("Slot" .. 2)

	if child2 then
		child2.Visible = visible2
	end
end

local color2 = Color3.fromRGB(96, 140, 210)
local color3 = Color3.fromRGB(180, 210, 255)
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 4)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.2124, 1),
	NumberSequenceKeypoint.new(0.213548, 0),
	NumberSequenceKeypoint.new(0.334099, 0),
	NumberSequenceKeypoint.new(0.336395, 1),
	NumberSequenceKeypoint.new(0.402985, 1),
	NumberSequenceKeypoint.new(0.405281, 0),
	NumberSequenceKeypoint.new(0.461538, 0),
	NumberSequenceKeypoint.new(0.464983, 1),
	NumberSequenceKeypoint.new(1, 1)
})

local function ensureShieldHeart(parent)
	local shieldHeart = parent:FindFirstChild("ShieldHeart")

	if shieldHeart then
		return shieldHeart
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ShieldHeart"
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://121908174722814"
	imageLabel.ImageColor3 = color3
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.ZIndex = parent.ZIndex + 1
	imageLabel.Visible = false
	imageLabel.Parent = parent
	local clone2 = imageLabel:Clone()
	clone2.Name = "Shine"
	clone2.Image = "rbxassetid://77637387117626"
	clone2.ZIndex = imageLabel.ZIndex + 1
	clone2.Visible = true
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Transparency = numberSequence
	uIGradient.Rotation = 10
	uIGradient.Offset = Vector2.new(-0.5, 0)
	uIGradient.Parent = clone2
	clone2.Parent = imageLabel
	TweenService:Create(uIGradient, tweenInfo, {
		Offset = Vector2.new(1, 0)
	}):Play()
	return imageLabel
end

local function ensureHeartShield(parent)
	local heartShield = parent:FindFirstChild("HeartShield")

	if heartShield then
		return heartShield
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "HeartShield"
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(1, 0)
	imageLabel.Position = UDim2.fromScale(1.05, -0.1)
	imageLabel.Size = UDim2.fromScale(0.55, 0.55)
	imageLabel.ZIndex = parent.ZIndex + 3
	imageLabel.Visible = false
	imageLabel.Parent = parent
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "HeartShieldCount"
	textLabel.BackgroundTransparency = 1
	textLabel.AnchorPoint = Vector2.new(1, 1)
	textLabel.Position = UDim2.fromScale(1.1, 1.1)
	textLabel.Size = UDim2.fromScale(0.7, 0.7)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0.3
	textLabel.ZIndex = imageLabel.ZIndex + 1
	textLabel.Visible = false
	textLabel.Parent = imageLabel
	return imageLabel
end

local function growHearts(hearts, clones, p)
	local v11 = math.min(p, 8)
	local v12 = 0
	local layoutOrder = 0

	for k, v14 in pairs(clones) do
		v12 = math.max(v12, k)
		layoutOrder = math.max(layoutOrder, v14.LayoutOrder)
	end

	local v14 = clones[v12]

	if not v14 then
		return
	end

	for i = v12 + 1, v11 do
		local clone2 = v14:Clone()
		clone2.Name = "Heart" .. i
		layoutOrder += 1
		clone2.LayoutOrder = layoutOrder
		clone2.Visible = false

		for _, childName in ipairs({ "ShieldHeart", "HeartShield" }) do
			local child = clone2:FindFirstChild(childName)

			if child then
				child:Destroy()
			end
		end

		clone2.Parent = hearts
		clones[i] = clone2
	end
end

local function updateHearts(instance)
	if not (visible and (clone and clone.Parent)) then
		return
	end

	local frame = clone:FindFirstChild("Frame")
	local healthFrame = frame and frame:FindFirstChild("HealthFrame")
	local hearts = healthFrame and healthFrame:FindFirstChild("Hearts")
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not (hearts and humanoid) then
		return
	end

	local images = {}

	for _, image in ipairs(hearts:GetChildren()) do
		if not image:IsA("ImageLabel") then
			continue
		end

		local v11 = tonumber(image.Name:match("%d+"))

		if v11 then
			images[v11] = image
		end
	end

	local stats = instance:FindFirstChild("Stats")
	local mainCharacter = stats and stats:FindFirstChild("MainCharacter")
	local visible3

	if mainCharacter then
		visible3 = mainCharacter.Value == true
	else
		visible3 = false
	end

	local heartIchor = images[1] and images[1]:FindFirstChild("HeartIchor")

	if heartIchor then
		heartIchor.Visible = visible3
	end

	local v12 = humanoid.Health + (visible3 and 1 or 0)
	local v13 = humanoid.MaxHealth + (visible3 and 1 or 0)
	local shieldHearts = instance:GetAttribute("ShieldHearts")
	local visible4

	if type(shieldHearts) == "number" then
		visible4 = shieldHearts > 0
	else
		visible4 = false
	end

	if visible4 and not images[v13 + 1] then
		growHearts(hearts, images, v13 + 1)
	end

	local image2 = visible4 and ShieldSourceIcon.Get(instance) or nil
	local v16 = images[v13 + 1]

	for k, v17 in pairs(images) do
		local v18

		if visible3 then
			v18 = k - 1 or k
		else
			v18 = k
		end

		local shieldHeart = ensureShieldHeart(v17)
		shieldHeart.Visible = visible4 and v17 == v16
		local heartShield = ensureHeartShield(v17)
		heartShield.Visible = visible4 and (v17 == v16 or not v16 and k == v12) and image2 ~= nil

		if image2 then
			heartShield.Image = image2
		end

		local heartShieldCount = heartShield:FindFirstChild("HeartShieldCount")

		if heartShieldCount then
			heartShieldCount.Visible = heartShield.Visible and shieldHearts > 1
			heartShieldCount.Text = not heartShield.Visible and "" or tostring(shieldHearts) or ""
		end

		if v17 == v16 then
			v17.Visible = visible4
			v17.Image = "rbxassetid://16790556042"
			v17.ImageColor3 = visible4 and color2 or Color3.fromRGB(255, 255, 255)
			v17.ImageTransparency = visible4 and 1 or 0
		else
			v17.Visible = v18 <= humanoid.MaxHealth
			local v19 = k <= v12
			local activated = v17:FindFirstChild("Activated")

			if activated then
				activated.Value = v19
			end

			v17.Image = "rbxassetid://16790556042"
			v17.ImageColor3 = Color3.fromRGB(255, 255, 255)
			v17.ImageTransparency = v19 and 0 or 1
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideBillboard()
	if clone then
		clone.Enabled = false
		clone.Adornee = nil
	end
end

local function refreshHighlight()
	maid3:DoCleaning()

	if v5 and visible2 and v8 then
		HighlightController:PlayHighlight(v8, "Target", {
			FillColor = color,
			OutlineColor = color,
			FillTransparency = 1,
			OutlineTransparency = 0.5,
			DepthMode = Enum.HighlightDepthMode.Occluded,
			ForceColor = true,
			Priority = HighlightController.Priority.VIEW_TARGET
		}, "LoadoutViewTarget")
		maid3:GiveTask(function()
			HighlightController:ClearHighlight("LoadoutViewTarget")
		end)
	end
end

local setActiveTarget

setActiveTarget = function(instance)
	if instance == v8 then
		return
	end

	maid2:DoCleaning()
	maid3:DoCleaning()
	v8 = instance

	if instance then
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if v6 then
				if not ensureBillboard() then
					v8 = nil
					return
				end

				clone.Adornee = humanoidRootPart
				repaintIcons(instance)
				clone.Enabled = true
				maid2:GiveTask(instance:GetAttributeChangedSignal("EquippedTrinket1"):Connect(function()
					repaintIcons(instance)
				end))
				maid2:GiveTask(instance:GetAttributeChangedSignal("EquippedTrinket2"):Connect(function()
					repaintIcons(instance)
				end))
			end

			refreshHighlight()

			if visible then
				updateHearts(instance)
				local humanoid = instance:FindFirstChildOfClass("Humanoid")

				if humanoid then
					maid2:GiveTask(humanoid:GetPropertyChangedSignal("Health"):Connect(function()
						updateHearts(instance)
					end))
					maid2:GiveTask(humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
						updateHearts(instance)
					end))
				end

				local stats = instance:FindFirstChild("Stats")
				local mainCharacter = stats and stats:FindFirstChild("MainCharacter")

				if mainCharacter then
					maid2:GiveTask(mainCharacter:GetPropertyChangedSignal("Value"):Connect(function()
						updateHearts(instance)
					end))
				end

				maid2:GiveTask(instance:GetAttributeChangedSignal("ShieldHearts"):Connect(function()
					updateHearts(instance)
				end))
			end

			maid2:GiveTask(instance.AncestryChanged:Connect(function()
				if not instance:IsDescendantOf(workspace) then
					setActiveTarget(nil)
				end
			end))
		else
			v8 = nil
			hideBillboard() -- equivalent call inferred; original call site unknown
		end
	else
		hideBillboard() -- equivalent call inferred; original call site unknown
	end
end

local function updateOnce()
	currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	if not CameraModeController.IsActive() then
		setActiveTarget((scan()))
		return
	end

	if v8 == nil then
		return
	end

	maid2:DoCleaning()
	maid3:DoCleaning()
	v8 = nil
	hideBillboard() -- equivalent call inferred; original call site unknown
end

local function onTouchTap(list, p)
	if p or UserInputService.PreferredInput ~= Enum.PreferredInput.Touch then
		return
	end

	local v11 = list and list[1]

	if not v11 then
		return
	end

	v9 = Vector2.new(v11.X, v11.Y) - GuiService:GetGuiInset()
	v10 = os.clock() + 5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enable()
	if flag2 then
		return
	end

	flag2 = true
	total = 0
	v9 = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total < (v2[UserInputService.PreferredInput] or 0.2) then
			return
		end

		total = 0
		local success, result = pcall(updateOnce)

		if not success then
			warn("[LoadoutClient] scan error:", result)
		end
	end)
	touchTapConnection = UserInputService.TouchTap:Connect(onTouchTap)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disable()
	if not flag2 then
		return
	end

	flag2 = false

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if touchTapConnection then
		touchTapConnection:Disconnect()
		touchTapConnection = nil
	end

	if v8 ~= nil then
		maid2:DoCleaning()
		maid3:DoCleaning()
		v8 = nil
		hideBillboard() -- equivalent call inferred; original call site unknown
	end

	v9 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setEnabled(p)
	if p then
		enable() -- equivalent call inferred; original call site unknown
	else
		disable() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyLoadoutSetting(p)
	visible2 = p and true or false

	if v7 then
		enable() -- equivalent call inferred; original call site unknown
		local frame = clone and clone.Parent and clone:FindFirstChild("Frame")

		if frame then
			local child = frame:FindFirstChild("Slot" .. 1)

			if child then
				child.Visible = visible2
			end

			local child2 = frame:FindFirstChild("Slot" .. 2)

			if child2 then
				child2.Visible = visible2
			end
		end
	else
		setEnabled(visible2) -- equivalent call inferred; original call site unknown
	end

	refreshHighlight()
end

local function hookSetting()
	local modules = ReplicatedStorage:WaitForChild("Modules", 30)
	local replicaController = modules and modules:FindFirstChild("ReplicaController", true)

	if not replicaController then
		warn("[LoadoutClient] ReplicaController not found; LoadoutToggle gating disabled (feature stays off).")
		return
	end

	local module = require(replicaController)
	local connection = module.ReplicaOfClassCreated("PlayerProfile", function(object)
		if object.Tags.Player ~= localPlayer then
			return
		end

		local settings = object.Data.Settings
		local loadoutToggle = settings and settings.LoadoutToggle
		visible2 = SettingsFlags:GetEffective(loadoutToggle, "LoadoutToggle") and true or false

		if v7 then
			enable() -- equivalent call inferred; original call site unknown
			local cloneFrame = clone and clone.Parent and clone:FindFirstChild("Frame")

			if cloneFrame then
				local child = cloneFrame:FindFirstChild("Slot" .. 1)

				if child then
					child.Visible = visible2
				end

				local child2 = cloneFrame:FindFirstChild("Slot" .. 2)

				if child2 then
					child2.Visible = visible2
				end
			end
		else
			setEnabled(visible2) -- equivalent call inferred; original call site unknown
		end

		refreshHighlight()
		local connection2 = object:ListenToChange({ "Settings", "LoadoutToggle" }, function(p)
			applyLoadoutSetting(SettingsFlags:GetEffective(p, "LoadoutToggle") and true or false) -- equivalent call inferred; original call site unknown
		end)
		maid:GiveTask(function()
			connection2:Disconnect()
		end)
	end)
	maid:GiveTask(function()
		connection:Disconnect()
	end)
end

function LoadoutClient.Init(data)
	if flag then
		return
	end

	flag = true
	visible = data ~= nil and data.showHealth == true
	v5 = data ~= nil and data.showHighlight == true
	v6 = data == nil or data.showBillboard ~= false
	v7 = visible
	currentCamera = workspace.CurrentCamera
	trinketData = ReplicatedStorage:FindFirstChild("TrinketData")
	assets = ReplicatedStorage:WaitForChild("Assets", 30)
	assets = assets and assets:WaitForChild("LoadoutFrame", 30)

	if not assets then
		warn("[LoadoutClient] Assets.LoadoutFrame template missing; aborting init.")
		return
	end

	size = assets.Size
	maid:GiveTask(UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(applyBillboardSize))
	refreshOccludeFilter()
	rebuildTagged()
	maid:GiveTask(CollectionService:GetInstanceAddedSignal("LoadoutTargets"):Connect(rebuildTagged))
	maid:GiveTask(CollectionService:GetInstanceRemovedSignal("LoadoutTargets"):Connect(rebuildTagged))
	maid:GiveTask(CollectionService:GetInstanceAddedSignal("Obstacle"):Connect(refreshOccludeFilter))
	maid:GiveTask(CollectionService:GetInstanceRemovedSignal("Obstacle"):Connect(refreshOccludeFilter))
	maid:GiveTask(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		currentCamera = workspace.CurrentCamera
	end))
	hookSetting()

	if v7 then
		enable() -- equivalent call inferred; original call site unknown
	end
end

return LoadoutClient