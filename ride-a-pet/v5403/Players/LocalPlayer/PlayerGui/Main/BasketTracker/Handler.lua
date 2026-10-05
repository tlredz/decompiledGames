local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local Eggs = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Eggs"))
local EggBaskets = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("EggBaskets"))
local EggLuckBillboard = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("EggLuckBillboard"))
local eggs = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Eggs")
local game2 = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local eggPickup = game2:WaitForChild("EggPickup")
local basketDrop = game2:WaitForChild("BasketDrop")
local basket = localPlayer:WaitForChild("Basket")
local equippedEggBasket = localPlayer:WaitForChild("SavedData"):WaitForChild("EquippedEggBasket")
local SFX = SoundService:WaitForChild("SFX")
local ding = SFX:WaitForChild("Reward"):WaitForChild("Ding")
local parent = script.Parent
local eggsHolder = parent:WaitForChild("EggsHolder")
local capacity = parent:WaitForChild("Capacity")
local eggFrame = script:WaitForChild("EggFrame")
local openRequest = parent:WaitForChild("OpenRequest")
local closeRequest = parent:WaitForChild("CloseRequest")
local v = {}
local v2 = {}

for k in Eggs do
	table.insert(v, k)
end

table.sort(v, function(a, b)
	return (Eggs[a].Luck or 0) < (Eggs[b].Luck or 0)
end)

for k, v3 in v do
	v2[v3] = k
end

local function BuildViewport(viewportFrame, name)
	local folder = eggs:FindFirstChild(name)

	if not folder then
		return false
	end

	local model = Instance.new("Model")

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local clone = part:Clone()
		clone.Anchored = true
		clone.Parent = model
	end

	if not model:FindFirstChildWhichIsA("BasePart") then
		model:Destroy()
		return false
	end

	model.Parent = viewportFrame
	local boundingBox, v3 = model:GetBoundingBox()
	local position = boundingBox.Position
	local v4 = math.max(v3.Magnitude / 2, 0.1)
	local v5 = v4 / 0.36397023426620234 * 1.15
	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	camera.CFrame = CFrame.lookAt(position + Vector3.new(0, v4 * 0.35, v5), position)
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	return true
end

local v3 = {}
local v4 = {}

local function BuildFrame(name)
	local egg = Eggs[name]
	local clone = eggFrame:Clone()
	clone.Name = name
	clone.LayoutOrder = v2[name] or 99
	local luckDisplay = clone:FindFirstChild("LuckDisplay")
	local luck = luckDisplay and luckDisplay:FindFirstChild("Luck")

	if luck then
		luck.Text = EggLuckBillboard.FormatLuck(not egg and 0 or egg.Luck or 0)
	end

	local visible = egg and egg.Image ~= nil

	if visible then
		clone.ImageLabel.Image = egg.Image
		task.spawn(function()
			local v6 = nil
			pcall(function()
				ContentProvider:PreloadAsync({ clone.ImageLabel }, function(_, p)
					v6 = p
				end)
			end)

			if not clone.Parent then
				return
			end

			if v6 == Enum.AssetFetchStatus.Failure and BuildViewport(clone.ViewportFrame, name) then
				clone.ImageLabel.Visible = false
				clone.ViewportFrame.Visible = true
			end
		end)
	else
		visible = not BuildViewport(clone.ViewportFrame, name)
	end

	clone.ImageLabel.Visible = visible
	clone.ViewportFrame.Visible = not visible
	clone.Drop.Visible = localPlayer:GetAttribute("TutorialActive") ~= true
	clone.Drop.Activated:Connect(function()
		SFX.Pop:Play()
		basketDrop:FireServer(name)
	end)
	clone.Parent = eggsHolder
	v3[name] = clone
	return clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateFrame(name)
	local v5 = v4[name] or 0
	local v6 = v3[name]

	if not (v5 <= 0) then
		(v6 or BuildFrame(name)).Count.Text = "x" .. v5
	elseif v6 then
		v3[name] = nil
		v6:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateCapacity()
	local eggBasket = EggBaskets[equippedEggBasket.Value]
	local capacity2 = eggBasket and eggBasket.Capacity or 1
	capacity.Text = #basket:GetChildren() .. "/" .. (capacity2 == 1e999 and "∞" or tostring(capacity2))
end

local v5 = {}
local v6 = {}

local function InVolcano(instance)
	local volcanoUntil = instance:GetAttribute("VolcanoUntil")
	return type(volcanoUntil) == "number" and workspace:GetServerTimeNow() < volcanoUntil
end

local function SyncEntry(instance)
	local egg = instance:GetAttribute("Egg")
	local v7

	if egg == nil or instance.Parent ~= basket then
		v7 = false
	else
		local volcanoUntil = instance:GetAttribute("VolcanoUntil")
		v7 = type(volcanoUntil) ~= "number" or not (workspace:GetServerTimeNow() < volcanoUntil)
	end

	local name = v5[instance]

	if v7 and not name then
		v5[instance] = egg
		v4[egg] = (v4[egg] or 0) + 1
		UpdateFrame(egg) -- equivalent call inferred; original call site unknown
	elseif not v7 and name then
		v5[instance] = nil
		v4[name] = math.max((v4[name] or 1) - 1, 0)
		UpdateFrame(name) -- equivalent call inferred; original call site unknown
	end
end

local function OnCarriedAdded(child)
	if not child:GetAttribute("Egg") then
		return
	end

	v6[child] = child:GetAttributeChangedSignal("VolcanoUntil"):Connect(function()
		SyncEntry(child)
	end)
	SyncEntry(child)
	UpdateCapacity() -- equivalent call inferred; original call site unknown

	if parent:GetAttribute("Open") ~= true then
		openRequest:Fire()
	end
end

local function OnCarriedRemoved(p)
	local connection = v6[p]

	if connection then
		connection:Disconnect()
		v6[p] = nil
	end

	local name = v5[p]

	if name then
		v5[p] = nil
		v4[name] = math.max((v4[name] or 1) - 1, 0)
		UpdateFrame(name) -- equivalent call inferred; original call site unknown
	end

	UpdateCapacity() -- equivalent call inferred; original call site unknown
end

for _, child in basket:GetChildren() do
	OnCarriedAdded(child)
end

basket.ChildAdded:Connect(OnCarriedAdded)
basket.ChildRemoved:Connect(OnCarriedRemoved)

local function RefreshDropButtons()
	local visible = localPlayer:GetAttribute("TutorialActive") ~= true

	for _, v8 in v3 do
		local drop = v8:FindFirstChild("Drop")

		if drop then
			drop.Visible = visible
		end
	end
end

localPlayer:GetAttributeChangedSignal("TutorialActive"):Connect(RefreshDropButtons)
RefreshDropButtons()
equippedEggBasket:GetPropertyChangedSignal("Value"):Connect(UpdateCapacity)
local eggBasket = EggBaskets[equippedEggBasket.Value]
local capacity2 = eggBasket and eggBasket.Capacity or 1
capacity.Text = #basket:GetChildren() .. "/" .. (capacity2 == 1e999 and "∞" or tostring(capacity2))
local color = Color3.fromRGB(255, 221, 74)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EggDeliveryFlash"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 100
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Name = "Flash"
frame.Size = UDim2.fromScale(1, 1)
frame.BackgroundColor3 = color
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Active = false
frame.Parent = screenGui
local v7 = nil

local function PlayFlash()
	if v7 then
		v7:Cancel()
	end

	frame.BackgroundTransparency = 0.55
	v7 = TweenService:Create(frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	})
	v7:Play()
end

local lastTime = nil

local function ZoomOffsetAt(p)
	if p < 0.08 then
		return 12 * (1 - (1 - p / 0.08) ^ 2)
	end

	local v8 = (p - 0.08) / 0.16

	if v8 >= 1 then
		return 0
	end

	return 12 * (1 - v8) ^ 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayZoom()
	local v8 = lastTime ~= nil
	lastTime = os.clock()

	if v8 then
		return
	end

	local v9 = 0
	RunService:BindToRenderStep("EggDeliveryZoom", Enum.RenderPriority.Camera.Value + 1, function()
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			local v10

			if lastTime then
				local v11 = os.clock() - lastTime
				local v12

				if v11 < 0.08 then
					v12 = 12 * (1 - (1 - v11 / 0.08) ^ 2)
				else
					local v13 = (v11 - 0.08) / 0.16
					v12 = v13 >= 1 and 0 or 12 * (1 - v13) ^ 2
				end

				v10 = v12 or 0
			else
				v10 = 0
			end

			currentCamera.FieldOfView += v10 - v9
			v9 = v10

			if v10 == 0 then
				lastTime = nil
				RunService:UnbindFromRenderStep("EggDeliveryZoom")
			end
		else
			lastTime = nil
			RunService:UnbindFromRenderStep("EggDeliveryZoom")
		end
	end)
end

eggPickup.OnClientEvent:Connect(function(p)
	if p == "BasketFull" and parent:GetAttribute("Open") ~= true then
		openRequest:Fire()
	elseif p == "Deposited" then
		ding:Play()
		PlayFlash()
		PlayZoom() -- equivalent call inferred; original call site unknown
		closeRequest:Fire()
	end
end)