local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local packages = ReplicatedStorage.packages
local Timer = require(packages.Timer)
local Trove = require(packages.Trove)
local Replion = require(packages.Replion)
local Debounce = require(packages.Debounce)
local Net = require(packages.Net)
local module = require("../HudController")
local module2 = require("./GiftController")
local module3 = require("./BundleController")
local module4 = require("../PlayerController")
local module5 = require("../RAPController")
local remoteEvent = Net:RemoteEvent("SalesBoothService/PurchaseItem")
local Monetization = require(ReplicatedStorage.shared.Monetization)
require(ReplicatedStorage.shared.utils.assets)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local FFlags = require(ReplicatedStorage.shared.modules.FFlags)
local Observers = require(ReplicatedStorage.packages.Observers)
require("@self/Types")
local v = Replion.Client:WaitReplion("LimitedStockItems")
local confirmPrompt = ReplicatedStorage:WaitForChild("events"):WaitForChild("ConfirmPrompt")
local playerGui = module:GetPlayerGui()
local deviceInsetGui = module:GetDeviceInsetGui()
local maid = Trove.new()
local maid2 = Trove.new()
local showroom = playerGui:WaitForChild("Showroom")
local frame = showroom.Frame
local clone = script:WaitForChild("ShopShowroomV2"):Clone()
local random = Random.new()
clone:PivotTo(CFrame.new(random:NextInteger(-10000, -10000), -10000, random:NextInteger(-10000, -10000)))
clone.Parent = workspace:WaitForChild("world")
local container = clone:WaitForChild("Container")
local UI = script:WaitForChild("UI")
local v2 = false
local ShowroomController = {
	ActiveBundles = {},
	_ActivePodiums = {},
	_ShowroomModel = clone,
	_PodiumOrigin = clone:WaitForChild("CenterThing"):WaitForChild("PodiumOrigin"),
	_PlayingVfx = false,
	_CameraTargetRotation = createVector(0, 0, 0),
	_CameraTargetZoom = 0,
	_CameraCurrentRotation = createVector(0, 0, 0),
	_CameraCurrentZoom = 0,
	_CameraVelocityRotation = createVector(0, 0, 0),
	_CameraVelocityZoom = 0,
	IsEnabled = false,
	CurrentMode = "bundle",
	CurrentlySelected = nil,
	CurrentBoothOwner = nil,
	CurrentBoothUID = nil
}
local worldPosition = ShowroomController._PodiumOrigin.WorldPosition

local function copyStyle(instance, instance2, flag: boolean?)
	if not (instance and instance2) then
		return
	end

	if instance.ClassName ~= instance2.ClassName then
		warn("can't copyStyle because 'from' has to be the same class as 'to'")
		return
	end

	if flag then
		instance2:ClearAllChildren()
	end

	if instance2:IsA("ImageLabel") and instance:IsA("ImageLabel") then
		instance2.ImageColor3 = instance.ImageColor3
		instance2.ImageTransparency = instance.Transparency
	elseif instance2:IsA("UIStroke") and instance:IsA("UIStroke") then
		instance2.Color = instance.Color
		instance2.Transparency = instance.Transparency
	elseif instance2:IsA("TextLabel") and instance:IsA("TextLabel") then
		instance2.Text = instance.Text
		instance2.TextColor3 = instance.TextColor3
		instance2.TextTransparency = instance.TextTransparency
	end

	for _, child in instance:GetChildren() do
		if child:IsA("UIPadding") or child:IsA("UITextSizeConstraint") then
			continue
		end

		local clone2 = child:Clone()

		if clone2.Name == "Flare" and clone2:IsA("GuiObject") and instance2:IsA("GuiObject") then
			clone2.Position = UDim2.fromScale(0.5, 0.5)
			clone2.ZIndex = instance2.ZIndex - 1
		end

		clone2.Parent = instance2
	end
end

function ShowroomController:_SortPodiums()
	local count = #self._ActivePodiums
	local worldCFrame = self._PodiumOrigin.WorldCFrame
	local v3 = (count - 1) * 10

	for k, _ActivePodium in self._ActivePodiums do
		if count <= 1 then
			_ActivePodium:PivotTo(worldCFrame)
		else
			_ActivePodium:PivotTo(worldCFrame * CFrame.new(math.lerp(-v3, v3, (k - 1) / (count - 1)), 0, 0))
		end
	end
end

function ShowroomController:ShowItem(p2)
	local moduleScript = script.ItemViews:FindFirstChild(p2.Type)

	if moduleScript and moduleScript:IsA("ModuleScript") then
		local module6 = require(moduleScript)
		maid:Add(task.spawn(module6.LoadScene, self, p2, false))
	end
end

function ShowroomController:ShowBoothItem(data)
	container:ClearAllChildren()
	table.clear(self._ActivePodiums)
	local selectedBundle = frame.SelectedBundle
	local container2 = selectedBundle.Container

	for _, uIListLayout in container2:GetChildren() do
		if not uIListLayout:IsA("UIListLayout") then
			uIListLayout:Destroy()
		end
	end

	local clone2 = UI.Item:Clone()
	clone2.Name = data.Name
	clone2.Icon.Image = data.Icon
	clone2.Type.Text = data.Type
	clone2.Title.Text = data.Name
	clone2.Active = false
	clone2.Selectable = false
	clone2.Interactable = false
	clone2.AutoButtonColor = false
	clone2.Parent = container2
	selectedBundle.Gift.Visible = false

	if data.Price == -1 then
		selectedBundle.BuyButton.Text = "Send Offer"
	else
		selectedBundle.BuyButton.Text = `S$ {NumberUtils:ToString(data.Price, 1)}`
	end

	selectedBundle.BuyButton.TextColor3 = Color3.fromRGB(202, 128, 129)
	selectedBundle.BuyButton.corner.ImageColor3 = Color3.fromRGB(202, 128, 129)
	selectedBundle.BuyButton.border.Color = Color3.fromRGB(202, 128, 129)
	selectedBundle.Visible = true
	maid:Add(selectedBundle.BuyButton.Activated:Connect(function()
		if self.CurrentBoothOwner == localPlayer or v2 then
			return
		end

		local v3 = data.Type == "RodSkin" and "RodSkins" or data.Type == "Item" and "Glider" or data.Type

		if data.Price == -1 then
			self:Close()
		else
			v2 = true
			local rAPAsync = module5:GetRAPAsync(v3, data.Name)
			local v4 = rAPAsync and `\n<font color="#00FF00">Sales Average: {NumberUtils:ToString(rAPAsync, 2)} S$</font>` or ""
			local hud = module:GetHud()
			hud.Enabled = true
			local v5 = confirmPrompt:Invoke(
				"Confirm Purchase",
				`Are you sure you want to purchase {data.Name} for {NumberUtils:ToString(data.Price, 2)} S$?{v4}`,
				"Cannot be undone!"
			)
			local hud_2 = module:GetHud()
			hud_2.Enabled = false
			v2 = false

			if not v5 then
				return
			end
		end

		remoteEvent:FireServer(self.CurrentBoothUID, v3, data.Index, data.Price)
	end))
	self:ShowItem(data)
end

function ShowroomController:SetInfo(data)
	local info = frame.info

	if data.Description and data.Description ~= "" then
		info.desc.Text = data.Description
		info.desc.Visible = true
	else
		info.desc.Visible = false
		info.desc.Text = ""
	end

	if data.Stats and #data.Stats > 0 then
		info.stats.Text = table.concat(data.Stats, "\n")
		info.stats.Visible = true
	else
		info.stats.Visible = false
		info.stats.Text = ""
	end

	if not (data.VfxButtonName and data.TriggerVfx) then
		info.altViewButton.Visible = false
		return
	end

	info.altViewButton.Text = data.VfxButtonName
	info.altViewButton.Visible = true
	maid:Add(info.altViewButton.Activated:Connect(function()
		if self._PlayingVfx then
			return
		end

		self._PlayingVfx = true
		xpcall(data.TriggerVfx, warn)
		self._PlayingVfx = false
	end))
end

function ShowroomController.IgnorePerformance(_, object)
	for _, v3 in object:QueryDescendants("ParticleEmitter, Beam, Trail, Highlight") do
		v3:AddTag("IgnorePerformance")
	end
end

function ShowroomController.FadeModelAsync(_, object, localTransparencyModifier: number)
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
	local v3 = {
		LocalTransparencyModifier = localTransparencyModifier
	}
	local v4 = nil

	for _, v5 in object:QueryDescendants("BasePart, Decal, ParticleEmitter, Trail, Beam, Fire, Smoke, Sparkles, Explosion") do
		v4 = TweenService:Create(v5, tweenInfo, v3)
		v4:Play()
	end

	if v4 then
		v4.Completed:Wait()
	end
end

local function rotCF(vector2: Vector3)
	return CFrame.fromOrientation(math.rad(vector2.X), math.rad(vector2.Y), 0)
end

local raycastParams = RaycastParams.new()
raycastParams.IncludeInstances = { ShowroomController._ShowroomModel }
raycastParams.ExcludeInstances = { container }

function ShowroomController:_SetupCamera()
	self._CameraTargetRotation = createVector(-27, 0, 0)
	self._CameraTargetZoom = 42
	self._CameraCurrentRotation = createVector(-27, 0, 0)
	self._CameraCurrentZoom = 42
	self._CameraVelocityRotation = createVector(0, 0, 0)
	self._CameraVelocityZoom = 0
	local flag = false
	local _CameraTargetZoom = 42
	local position = createVector(0, 0, 0)
	local Z = 0
	local Z2 = 0
	maid2:Add(UserInputService.InputChanged:Connect(function(input, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			self._CameraTargetZoom = math.clamp(self._CameraTargetZoom + input.Position.Z * -5, 1, 50)
		elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
			position = input.Position
		elseif input.KeyCode == Enum.KeyCode.ButtonL2 then
			Z = input.Position.Z
		elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
			Z2 = input.Position.Z
		end
	end))
	maid2:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			flag = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
			position = input.Position
		elseif input.KeyCode == Enum.KeyCode.ButtonL2 then
			Z = input.Position.Z
		elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
			Z2 = input.Position.Z
		end
	end))
	maid2:Add(UserInputService.InputEnded:Connect(function(input, _: boolean)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			flag = false
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
			position = createVector(0, 0, 0)
		elseif input.KeyCode == Enum.KeyCode.ButtonL2 then
			Z = 0
		elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
			Z2 = 0
		end
	end))
	maid2:Add(UserInputService.TouchPan:Connect(function(_, _, point: Vector2, _, p)
		if p then
			return
		end

		self._CameraTargetRotation += Vector3.new(point.Y * -0.01, point.X * -0.01, 0)
	end))
	maid2:Add(UserInputService.TouchPinch:Connect(function(_, p, _, p2, _)
		if p2 == Enum.UserInputState.Begin then
			_CameraTargetZoom = self._CameraTargetZoom
		end

		self._CameraTargetZoom = math.clamp(_CameraTargetZoom * (1 / p), 1, 50)
	end))
	maid2:Add(RunService.PreRender:Connect(function(dt: number)
		debug.profilebegin("ShowroomController::UpdateCamera")
		local v3 = UserGameSettings.GamepadCameraSensitivity * 25
		self._CameraTargetRotation += Vector3.new(-position.Y * v3 * dt, position.X * v3 * dt, 0)

		if flag then
			local v5 = UserInputService:GetMouseDelta() * UserGameSettings:GetCameraYInvertValue() * UserGameSettings.MouseSensitivity * -0.2
			self._CameraTargetRotation += Vector3.new(v5.Y, v5.X, 0)
		end

		self._CameraTargetRotation = Vector3.new(
			math.clamp(self._CameraTargetRotation.X, -89, 89),
			self._CameraTargetRotation.Y,
			0
		)
		self._CameraTargetZoom = math.clamp(self._CameraTargetZoom + (Z2 - Z) * 25 * dt, 1, 50)
		local cframe = CFrame.new(worldPosition)
		local _CameraTargetRotation = self._CameraTargetRotation
		local v5 = cframe * CFrame.fromOrientation(
			math.rad(_CameraTargetRotation.X),
			math.rad(_CameraTargetRotation.Y),
			0
		) * CFrame.new(0, 0, self._CameraTargetZoom + 3)
		local raycastResult = workspace:Raycast(worldPosition, v5.Position - worldPosition, raycastParams)

		if raycastResult then
			self._CameraTargetZoom = math.clamp(self._CameraTargetZoom, 1, (math.min(raycastResult.Distance - 3, 50)))
		end

		local v6 = self
		local v7 = self
		local smoothDamp, cameraVelocityZoom = TweenService:SmoothDamp(
			self._CameraCurrentZoom,
			self._CameraTargetZoom,
			self._CameraVelocityZoom,
			0.25,
			nil,
			dt
		)
		v6._CameraCurrentZoom = smoothDamp
		v7._CameraVelocityZoom = cameraVelocityZoom
		local v9 = self
		local v10 = self
		local smoothDamp2, cameraVelocityRotation = TweenService:SmoothDamp(
			self._CameraCurrentRotation,
			self._CameraTargetRotation,
			self._CameraVelocityRotation,
			0.15,
			nil,
			dt
		)
		v9._CameraCurrentRotation = smoothDamp2
		v10._CameraVelocityRotation = cameraVelocityRotation
		self._CameraCurrentRotation = Vector3.new(
			math.clamp(self._CameraCurrentRotation.X, -89, 89),
			self._CameraCurrentRotation.Y,
			0
		)
		local cframe2 = CFrame.new(worldPosition)
		local _CameraCurrentRotation = self._CameraCurrentRotation
		local cFrame = cframe2 * CFrame.fromOrientation(
			math.rad(_CameraCurrentRotation.X),
			math.rad(_CameraCurrentRotation.Y),
			0
		) * CFrame.new(0, 0, self._CameraCurrentZoom + 3)
		local raycastResult2 = workspace:Raycast(worldPosition, cFrame.Position - worldPosition, raycastParams)

		if raycastResult2 then
			self._CameraCurrentZoom = math.clamp(
				self._CameraCurrentZoom,
				1,
				(math.min(raycastResult2.Distance - 1, 50))
			)
			local cframe3 = CFrame.new(worldPosition)
			local _CameraCurrentRotation2 = self._CameraCurrentRotation
			cFrame = cframe3 * CFrame.fromOrientation(
				math.rad(_CameraCurrentRotation2.X),
				math.rad(_CameraCurrentRotation2.Y),
				0
			) * CFrame.new(0, 0, self._CameraCurrentZoom + 3)
		end

		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = cFrame
		currentCamera.Focus = CFrame.new(worldPosition)
		local localTransparencyModifier = math.clamp(
			math.map(math.deg((currentCamera.CFrame:ToOrientation())), 0, 30, 0, 1),
			0,
			1
		)

		for _, _ActivePodium in self._ActivePodiums do
			for _, part in _ActivePodium:GetChildren() do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = localTransparencyModifier
				end
			end
		end

		debug.profileend()
	end))
end

function ShowroomController:CreatePodium(instance, flag: boolean?, vector2: Vector3?)
	local scale = instance:GetScale()
	local v3 = 2
	local v4 = flag and 16 or 32
	local v5 = instance:GetExtentsSize() * 2
	local v6 = math.max(v5.X, v5.Y, v5.Z)

	if v4 < v6 then
		v3 /= v6 / v4
	end

	instance:ScaleTo(v3 * scale)
	local primaryPart = instance.PrimaryPart

	if not primaryPart then
		primaryPart = instance:FindFirstChild("Center") or instance:FindFirstChild("handle") or instance:FindFirstChild("Root") or instance:FindFirstChild("RootPart") or instance:FindFirstChild("Handle") or instance:FindFirstChildWhichIsA(
			"BasePart",
			true
		)

		if not (primaryPart and primaryPart:IsA("BasePart")) then
			primaryPart = instance:FindFirstChildWhichIsA("BasePart", true)
		end

		instance.PrimaryPart = primaryPart
	end

	assert(primaryPart ~= nil, (`Display model has no root part: {instance:GetFullName()}`))
	local v7

	if vector2 then
		v7 = vector2 * v3
	else
		local boundingBox
		boundingBox, v7 = instance:GetBoundingBox()
		primaryPart.PivotOffset = primaryPart.CFrame:ToObjectSpace(boundingBox)
	end

	local clone2 = script.Podium:Clone()
	instance:PivotTo(clone2:GetPivot() + Vector3.new(0, v7.Y / 2, 0))
	instance.Parent = clone2
	clone2.Parent = container
	maid:Add(clone2)
	table.insert(self._ActivePodiums, clone2)
	self:_SortPodiums()

	if flag then
		worldPosition = self._PodiumOrigin.WorldPosition
		return clone2
	end

	worldPosition = (clone2:GetPivot() + Vector3.new(0, v7.Y / 2, 0)).Position
	return clone2
end

function ShowroomController:ShowBundle(value)
	if typeof(value) == "string" then
		value = self.ActiveBundles[value]
	end

	if self.CurrentlySelected == value.Name and self.IsEnabled and self.CurrentMode == "bundle" or Debounce(
		"ClickCooldown",
		0.25
	) or self._PlayingVfx then
		return
	end

	self.CurrentlySelected = value.Name

	if not self.IsEnabled then
		self:Open()
	end

	maid:Clean()
	maid:Add(function()
		table.clear(self._ActivePodiums)
	end)
	local maid3 = maid:Extend()
	container:ClearAllChildren()
	frame.Header.Visible = false
	frame.AmountLeft.Visible = false
	frame.Bundles.Visible = true
	frame.boothContents.Visible = false
	local selectedBundle = frame.SelectedBundle
	local container2 = selectedBundle.Container
	selectedBundle.Visible = true

	if #value.Contains == 1 then
		self:ShowItem(value.Contains[1])
	else
		self:ShowItem(value)
	end

	local child = frame.Bundles:FindFirstChild(value.Name)

	if child then
		copyStyle(child:WaitForChild("Title"), selectedBundle.Title, true)
		copyStyle(child:WaitForChild("corner"), selectedBundle.corner, true)
		copyStyle(child:WaitForChild("stroke"), selectedBundle.stroke, true)
	end

	for _, uIListLayout in container2:GetChildren() do
		if not uIListLayout:IsA("UIListLayout") then
			uIListLayout:Destroy()
		end
	end

	local name = nil

	for _, contain in ipairs(value.Contains) do
		local clone2 = UI:FindFirstChild("Item"):Clone()
		clone2.Name = contain.Name
		clone2.Icon.Image = contain.Icon
		clone2.Type.Text = contain.Type
		clone2.Title.Text = contain.Name
		local v3 = contain
		maid:Add(clone2.Activated:Connect(function()
			if self._PlayingVfx or name == v3.Name then
				return
			end

			name = v3.Name

			for i, guiObject in container2:GetChildren() do
				if not guiObject:IsA("GuiObject") then
					continue
				end

				local color

				if guiObject == clone2 then
					color = Color3.fromRGB(83, 186, 255)
				else
					color = Color3.fromRGB(255, 255, 255)
				end

				guiObject.stroke.Color = color
				guiObject.corner.ImageColor3 = color
			end

			container:ClearAllChildren()
			table.clear(self._ActivePodiums)
			self:ShowItem(v3)
		end))
		clone2.Parent = container2
	end

	local v3 = true
	local v4 = Timer.new(1)
	local buyButton = selectedBundle.BuyButton
	local robuxPrice = Monetization:GetRobuxPrice(value.ProductId)
	buyButton.Text = utf8.char(57346) .. tostring(robuxPrice)
	buyButton.TextColor3 = Color3.fromRGB(162, 234, 166)
	buyButton.corner.ImageColor3 = Color3.fromRGB(162, 234, 166)
	buyButton.border.Color = Color3.fromRGB(162, 234, 166)
	selectedBundle.Gift.Visible = true
	maid3:Add(buyButton.Activated:Connect(function()
		if not v3 then
			return
		end

		Monetization.BuyProduct:FireServer(value.ProductId)
	end))
	maid3:Add(selectedBundle.Gift.Activated:Connect(function()
		if not v3 then
			return
		end

		local v5 = {}

		for _, contain in value.Contains do
			table.insert(v5, (`{contain.Name} ({contain.Type})`))
		end

		module2:PromptGift(value.ProductId, value.Name, `Contains: {table.concat(v5, ", ")}`, nil)
	end))

	local function disableBundle()
		maid3:Clean()
		buyButton.Text = "Off Sale"
		buyButton.TextColor3 = Color3.fromRGB(74, 74, 74)
		local border = buyButton:WaitForChild("border")
		border.Color = Color3.fromRGB(74, 74, 74)
		local corner = buyButton:WaitForChild("corner")
		corner.ImageColor3 = Color3.fromRGB(74, 74, 74)
	end

	if value.IsBundle then
		if module3:RequestState(value.Name) == true then
			maid3:Add(module3.OnBundleDisabled:Connect(function(p: string)
				if p ~= value.Name then
					return
				end

				disableBundle()
			end))
		else
			disableBundle()
		end
	end

	local expect = nil
	local expect2 = nil
	local success, _ = pcall(function()
		expect = v:GetExpect({ "Stocks", value.Name })
		expect2 = v:GetExpect({ "InitialStocks", value.Name })
	end)

	local function updateTimer()
		if success then
			expect = v:GetExpect({ "Stocks", value.Name })
			expect2 = v:GetExpect({ "InitialStocks", value.Name })
			frame.AmountLeft.Text = `{NumberUtils:Comma(expect)} / {NumberUtils:Comma(expect2)}`

			if expect <= 0 then
				v3 = false
				buyButton.Text = "Out of Stock!"
			end

			local showLimitedStock = FFlags:Get("ShowLimitedStock", true)
			frame.AmountLeft.Visible = showLimitedStock
			frame.Header.Visible = showLimitedStock
		end
	end

	if success then
		maid:Add(FFlags:OnChange("ShowLimitedStock", function(visible)
			frame.AmountLeft.Visible = visible
			frame.Header.Visible = visible
		end))
	else
		frame.AmountLeft.Visible = false
		frame.Header.Visible = false
	end

	maid3:Add(v4, "Destroy")
	maid:Add(v4.Tick:Connect(updateTimer))
	v4:StartNow()
end

function ShowroomController:ShowBooth(data, p: number)
	if self.IsEnabled or #data.Items == 0 or self._PlayingVfx or Debounce("ClickCooldown", 0.25) then
		return
	end

	self:Open()
	maid:Clean()
	maid:Add(function()
		table.clear(self._ActivePodiums)
	end)
	container:ClearAllChildren()
	maid:Add(data.Owner.AncestryChanged:Once(function()
		if not data.Owner.Parent then
			self:Close()
			ReplicatedStorage.events.anno_localthought:Fire((`{data.Owner.DisplayName} left the server.`))
		end
	end))
	self.CurrentBoothOwner = data.Owner
	self.CurrentBoothUID = data.UID
	frame.Header.Visible = false
	frame.AmountLeft.Visible = false
	frame.Bundles.Visible = false
	frame.Timer.Visible = false
	frame.SelectedBundle.Title.Text = `{data.Owner.DisplayName}'s Booth`
	frame.boothContents.Visible = true

	for i, item in ipairs(data.Items) do
		local moduleScript = script.ItemViews:FindFirstChild(item.Type)

		if not (moduleScript and moduleScript:IsA("ModuleScript")) then
			continue
		end

		local module6 = require(moduleScript)
		local boothButton = module6.GetBoothButton(self, item)
		boothButton.LayoutOrder = i
		boothButton.Name = item.Name
		local v3 = item
		maid2:Add(boothButton.Activated:Connect(function()
			self:ShowBoothItem(v3)
		end))
		boothButton.Parent = frame.boothContents
		maid2:Add(boothButton)
	end

	self:ShowBoothItem(data.Items[p] or data.Items[1])
end

function ShowroomController:AddBundle(state, instance)
	if self.ActiveBundles[state.Name] then
		return
	end

	state.Type = "Bundle"
	local clone2 = UI:FindFirstChild("Bundle"):Clone()
	clone2.Name = state.Name
	copyStyle(instance:WaitForChild("Title"), clone2.Title)
	copyStyle(instance:WaitForChild("corner"), clone2.corner)
	copyStyle(instance:WaitForChild("stroke"), clone2.stroke)

	for _, contain in state.Contains do
		local clone3 = UI:FindFirstChild("ItemIcon"):Clone()
		clone3.Name = contain.Name
		clone3.Image = contain.Icon

		if not table.find({
			"RodSkin",
			"Boat",
			"CompanionSkin",
			"BoothSkin"
		}, contain.Type) then
			clone3.Size = UDim2.fromScale(1, 0.65)
		end

		clone3.Parent = clone2.Items
	end

	clone2.LayoutOrder = state.Order
	clone2.Parent = frame.Bundles
	self.ActiveBundles[state.Name] = state
	clone2.Activated:Connect(function()
		self:ShowBundle(state)
	end)
end

function ShowroomController:Open()
	local character = localPlayer.Character

	if not character or self.IsEnabled then
		return
	end

	if playerGui:FindFirstChild("reel") or playerGui:FindFirstChild("stab") or playerGui:FindFirstChild("harpoonMinigame") then
		return
	end

	self.IsEnabled = true
	showroom.Enabled = true
	module4:ToggleControls(false)

	for _, screenGui in playerGui:GetChildren() do
		if screenGui:IsA("ScreenGui") and screenGui.Name == "TopbarStandard" then
			screenGui.Enabled = false
		end
	end

	playerGui.hud.Enabled = false
	playerGui.hud.safezone.shop.Visible = false
	playerGui.backpack.Enabled = false
	deviceInsetGui.Enabled = false
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")

	if humanoid then
		humanoid:UnequipTools()
	end

	self:_SetupCamera()
	task.spawn(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	end)
end

function ShowroomController:Close()
	if not self.IsEnabled then
		return
	end

	maid:Clean()
	maid2:Clean()
	self.IsEnabled = false
	showroom.Enabled = false
	module4:ToggleControls(true)

	for _, screenGui in playerGui:GetChildren() do
		if screenGui:IsA("ScreenGui") and screenGui.Name == "TopbarStandard" then
			screenGui.Enabled = true
		end
	end

	playerGui.hud.Enabled = true
	playerGui.backpack.Enabled = true
	deviceInsetGui.Enabled = true
	currentCamera.CameraType = Enum.CameraType.Custom
	task.spawn(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
	end)
end

function ShowroomController:Start()
	frame.Close.Activated:Connect(function()
		self:Close()
	end)
	Observers.observeCharacter(localPlayer, function(_, instance)
		local diedConnection = instance:WaitForChild("Humanoid").Died:Once(function()
			self:Close()
		end)
		return function()
			diedConnection:Disconnect()
			diedConnection = nil
		end
	end)
end

return ShowroomController