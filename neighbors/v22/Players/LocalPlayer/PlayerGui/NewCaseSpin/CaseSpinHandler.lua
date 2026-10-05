game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Network = require(ReplicatedStorage.Modules.Network)
local Case = require(ReplicatedStorage.Assets.Data.Case)
local Title = require(ReplicatedStorage.Modules.Title)
local UI = require(ReplicatedStorage.Modules.UI)
local WeeklyStore = require(ReplicatedStorage.Assets.Data.WeeklyStore)
local Decoration = require(ReplicatedStorage.Assets.Data.Store.Decoration)
local Items = require(ReplicatedStorage.Assets.Data.Store.Items)
local Emotes = require(ReplicatedStorage.Assets.Data.Store.Emotes)
local background = script.Parent.Background
local spinner = background.Spinner
local items = spinner.Items
local sample = items.Sample
local result = background.Result
background.Visible = false

if game.Lighting:FindFirstChild("CaseBlur") then
	game.Lighting.CaseBlur:Destroy()
end

local blurEffect = Instance.new("BlurEffect", game.Lighting)
blurEffect.Size = 0
blurEffect.Name = "CaseBlur"
local v = { 75, 80 }
local v2 = {}
local v3 = false
local text = result.Owned.Text

local function ClearSpinnerItems()
	for _, frame in items:GetChildren() do
		if frame:IsA("Frame") and frame ~= sample then
			frame:Destroy()
		end
	end
end

local function UpdateSample(randomItem: string, clone, p: number)
	local itemInfo = Case:GetItemInfo(randomItem) or Items[randomItem] or Decoration.Avatar[randomItem]
	local rarity = itemInfo and itemInfo.Rarity

	if rarity == "Collectible" or not rarity then
		for _, allBanner in WeeklyStore.AllBanners do
			for k, list in allBanner.Items do
				if not table.find(list, randomItem) then
					continue
				end

				rarity = k
				break
			end
		end
	end

	local backgroundColor = Case:GetColors()[rarity]

	if Emotes[randomItem] then
		clone.Title.Visible = false
		clone.SkinIcon.Visible = false
		local camera = Instance.new("Camera")
		camera.CFrame = CFrame.new(0, 0, -350) * CFrame.Angles(0, 3.141592653589793, 0)
		camera.FieldOfView = 1
		local viewportFrame = Instance.new("ViewportFrame")
		viewportFrame.Size = UDim2.fromScale(1, 1)
		viewportFrame.CurrentCamera = camera
		viewportFrame.Name = "EmoteDisplay"
		viewportFrame.BackgroundTransparency = 1
		viewportFrame.Parent = clone
		camera.Parent = viewportFrame
		local worldModel = Instance.new("WorldModel", viewportFrame)
		local clone2 = ReplicatedStorage.Assets.Models.Dummy:Clone()
		clone2:PivotTo(CFrame.new(0, -2.5, 0))
		clone2.Parent = worldModel
		local animation = Instance.new("Animation", clone2)
		animation.AnimationId = `rbxassetid://{Emotes[randomItem].AnimationId}`
		task.defer(function()
			local track = clone2:WaitForChild("Controller", 1e999):LoadAnimation(animation)
			track.Looped = true
			track:Play()

			if UserInputService.TouchEnabled then
				track.TimePosition = track.Length * 0.5
				track:AdjustSpeed(0)
			end
		end)
	elseif itemInfo.ItemType == "Titles" then
		Title:Construct(Players.LocalPlayer, clone.Title, itemInfo.Display)
	else
		clone.Title.Visible = false
		clone.SkinIcon.Visible = true
		local skinIcon = clone.SkinIcon
		local image

		if itemInfo.Image then
			image = itemInfo.Image
		else
			image = not itemInfo.Icon and "" or itemInfo.Icon
		end

		skinIcon.Image = image
	end

	clone.Chance.Label.Text = `{math.round((Case:GetRarities()[rarity] or 0) / p * 100 * 10) / 10}%`
	clone.Rarity.Label.Text = rarity
	clone.Rarity.BackgroundColor3 = backgroundColor
	clone.BackgroundColor3 = backgroundColor
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsCaseAWeekly(p)
	for _, v4 in next, WeeklyStore, nil do
		if v4 == p then
			return true
		end
	end

	return false
end

local function GenerateSpinnerItemsFromCase(p, p2)
	local v4 = math.random(v[1], v[2])
	local total = 0
	local result2 = {}

	for k, item in next, p.Items, nil do
		total += (Case:GetRarities()[k] or 0) * #item
	end

	local caseAWeekly = IsCaseAWeekly(p) -- equivalent call inferred; original call site unknown
	local v6 = not caseAWeekly and 100 or total

	for i = 1, 120 do
		local randomItem

		if i == v4 then
			randomItem = p2
		else
			randomItem = Case:GetRandomItem(p)
		end

		local clone = sample:Clone()
		UpdateSample(randomItem, clone, v6)
		table.insert(result2, {
			Winner = i == v4,
			ItemInfo = randomItem,
			Frame = clone
		})
	end

	return result2
end

local function ShowResult(instance, value)
	if result:FindFirstChild("Icon") then
		result.Icon:Destroy()
	end

	result.Success:Play()
	local clone = instance:Clone()

	if instance:FindFirstChild("EmoteDisplay") then
		instance.EmoteDisplay.Parent = clone
		clone.EmoteDisplay:Destroy()
	end

	clone.Name = "Icon"
	clone.Overlay:Destroy()
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.Position = UDim2.new(0.5, 0, 0.5, -5)
	clone.Parent = result
	result.Owned.Text = typeof(value) == "string" and value or text
	result.Owned.Visible = value ~= nil and value ~= false
	result.Visible = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetItemPosition(p)
	local absolutePosition = items.AbsolutePosition
	local absolutePosition2 = p.AbsolutePosition
	local halfAbsoluteSize = items.AbsoluteSize / 2
	return absolutePosition2 - absolutePosition - halfAbsoluteSize
end

local function DoSpin(p, p2, flag: boolean)
	items.CanvasPosition = Vector2.new(0, 0)
	local generateSpinnerItemsFromCase = GenerateSpinnerItemsFromCase(p, p2)
	ClearSpinnerItems()
	local v5 = nil

	for k, v6 in generateSpinnerItemsFromCase do
		local frame = v6.Frame

		if v6.Winner then
			v5 = frame
		end

		frame.Parent = items
		frame.Visible = true
		frame.LayoutOrder = k
		local absolutePositionChangedConnection = nil
		absolutePositionChangedConnection = frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			if frame.AbsolutePosition.X < items.AbsolutePosition.X then
				frame.Tick:Play()
				absolutePositionChangedConnection:Disconnect()
			end
		end)
	end

	result.Visible = false
	background.Visible = true
	spinner.Visible = true
	RunService.RenderStepped:Wait()
	local vector = Vector2.new(math.random(15, v5.AbsoluteSize.X - 15), 0)
	local canvasPosition = GetItemPosition(v5) + vector
	local v8 = math.floor(canvasPosition.X / 2000 + 0.5)
	local tween = TweenService:Create(items, TweenInfo.new(v8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
		CanvasPosition = canvasPosition
	})
	tween:Play()
	TweenService:Create(blurEffect, TweenInfo.new(1), {
		Size = 24
	}):Play()
	local mouseButton1ClickConnection = spinner.Close.MouseButton1Click:Once(function()
		tween:Cancel()
	end)
	tween.Completed:Once(function()
		spinner.Visible = false
		TweenService:Create(blurEffect, TweenInfo.new(1), {
			Size = 0
		}):Play()
		ShowResult(v5, flag)

		if mouseButton1ClickConnection.Connected then
			mouseButton1ClickConnection:Disconnect()
		end

		Players.LocalPlayer.PlayerGui.Neighbors.Shop.Visible = true
	end)
end

result.Close.MouseButton1Click:Connect(function()
	background.Visible = false
	result.Visible = false
end)
UI:Bind(spinner.Close)
UI:Bind(result.Close)
Network:listen("RunCaseAnimation", function(p, p2, p3)
	DoSpin(Case:GetCrateFromName(p), p2, p3)
end)
Network:listen("RunBannerCaseAnimation", function(p, winningItem, alreadyOwned)
	table.insert(v2, {
		WinningItem = winningItem,
		AlreadyOwned = alreadyOwned
	})

	if not v3 then
		v3 = true

		while #v2 > 0 do
			local v4 = table.remove(v2, 1)
			DoSpin(WeeklyStore.AllBanners[p], v4.WinningItem, v4.AlreadyOwned)

			while spinner.Visible do
				task.wait(0.05)
			end

			while result.Visible do
				task.wait(0.05)
			end
		end

		v3 = false
	end
end)