local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local AnimatedButton = require(ReplicatedStorage.Classes.AnimatedButton)
local ConfirmationController = require(ReplicatedStorage.Controllers.ConfirmationController)
local Net = require(ReplicatedStorage.Packages.Net)
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Timer = require(ReplicatedStorage.Packages.Timer)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Animals = require(ReplicatedStorage.Datas.Animals)
local Bases = require(ReplicatedStorage.Datas.Bases)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Animals2 = require(ReplicatedStorage.Shared.Animals)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local remoteEvent = Net:RemoteEvent("JumpLTMService/RequestEggHatch")
local remoteEvent2 = Net:RemoteEvent("JumpLTMService/RequestHatchSkip")
local remoteEvent3 = Net:RemoteEvent("PlotService/Sell")
local localPlayer = Players.LocalPlayer
local uDim = UDim2.fromScale(0.99, 0.5)
local color = Color3.fromRGB(80, 158, 87)
Color3.fromRGB(110, 112, 120)
local color2 = Color3.fromRGB(233, 66, 65)
local color3 = Color3.fromRGB(119, 12, 12)
local color4 = Color3.fromRGB(88, 218, 98)
local myBase = nil
local myBase2 = nil
local list = nil
local uIListLayout = nil
local emptyLabel = nil
local template = nil
local toggle = nil
local rows = {}
local v = {}
local v2 = true

local function isEggEntry(p)
	local animal = Animals[p.Index]
	return animal ~= nil and (animal.LuckyBlock ~= nil or animal.Egg ~= nil)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatRemaining(timer: number)
	local v3 = math.max(math.ceil(timer), 0)
	return (`{v3 // 60}:{string.format("%02d", v3 % 60)}`)
end

local function updateProgressWidth(data)
	local count = 0

	for _, button in data.ButtonsFrame:GetChildren() do
		if button:IsA("GuiButton") and button.Visible then
			count += 1
		end
	end

	local size = data.ProgressFrame.Size
	local v3 = count == 1 and 0.3 or 0.235
	data.ProgressFrame.Size = UDim2.new(v3, size.X.Offset, size.Y.Scale, size.Y.Offset)
	local uIListLayout2 = data.ButtonsFrame:FindFirstChildOfClass("UIListLayout")

	if count == 1 then
		data.SellButton.Size = UDim2.new(0.6, 0, data.SellDefaultSize.Y.Scale, data.SellDefaultSize.Y.Offset)

		if uIListLayout2 then
			uIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
		end
	else
		data.SellButton.Size = data.SellDefaultSize

		if uIListLayout2 then
			uIListLayout2.HorizontalAlignment = Enum.HorizontalAlignment.Right
		end
	end
end

local function updateEggRow(state, p)
	local timer = p.Timer
	local v3 = type(timer) ~= "number" or timer <= 0 or Animals2:IsLuckyBlockTimerDisabled(p.Index)
	local progressLabel = state.ProgressLabel

	if progressLabel then
		local text

		if v3 then
			text = "READY!"
		else
			text = formatRemaining(timer)
		end

		progressLabel.Text = text
	end

	state.HatchReady = v3
	local hatchButton = state.HatchButton

	if hatchButton then
		hatchButton.Visible = v3
		hatchButton.BackgroundColor3 = color
		hatchButton.AutoButtonColor = true
	end

	local skipButton = state.SkipButton

	if skipButton then
		skipButton.Visible = not v3
	end

	updateProgressWidth(state)
end

local function armSellConfirm(state)
	state.SellArmedUntil = os.clock() + 3
	state.SellLabel.Text = "CONFIRM?"
	state.SellButton.BackgroundColor3 = color3
	local sellArmedUntil = state.SellArmedUntil
	task.delay(3, function()
		if state.SellArmedUntil == sellArmedUntil and state.SellButton.Parent then
			state.SellArmedUntil = 0
			state.SellLabel.Text = "SELL"
			state.SellButton.BackgroundColor3 = color2
		end
	end)
end

local function createRow(podiumIndex: number, entry, layoutOrder: number)
	local animal = Animals[entry.Index]
	local isEgg

	if animal == nil then
		isEgg = false
	else
		isEgg = animal.LuckyBlock ~= nil or animal.Egg ~= nil
	end

	local clone = template:Clone()
	clone.Name = `Row{podiumIndex}`
	clone.LayoutOrder = layoutOrder
	local frame = clone:WaitForChild("Frame")
	local viewport = frame:WaitForChild("Viewport")
	Animals2:AttachOnViewportWithOptimizations(entry.Index, viewport, nil, entry.Mutation)
	local label = frame:WaitForChild("Label")
	local text

	if entry.Mutation then
		text = `{entry.Mutation} {entry.Index}`
	else
		text = entry.Index
	end

	label.Text = text
	local progress = frame:WaitForChild("Progress")
	local buttons = frame:WaitForChild("Buttons")
	local hatch = buttons:WaitForChild("Hatch")
	local skip = buttons:WaitForChild("Skip")
	local sell = buttons:WaitForChild("Sell")
	local label2 = sell:WaitForChild("Label")
	skip.Visible = false
	local label3 = nil
	local hatchButton = nil
	local skipButton = nil
	local fill = progress:FindFirstChild("Fill")

	if fill and fill:IsA("GuiObject") then
		fill.Visible = false
	end

	hatch.LayoutOrder = 1
	skip.LayoutOrder = 1
	sell.LayoutOrder = 2

	if isEgg then
		label3 = progress:WaitForChild("Label")
		skip.Size = hatch.Size
		skipButton = skip
		hatchButton = hatch
	else
		local traits

		if type(entry.Traits) == "table" then
			traits = entry.Traits
		end

		local label4 = progress:WaitForChild("Label")
		label4.Text = `${NumberUtils:ToString(Animals2:GetGeneration(entry.Index, entry.Mutation, traits))}/s`
		label4.TextColor3 = color4
		hatch.Visible = false
	end

	clone.Visible = true
	clone.Parent = list
	local v7 = {
		PodiumIndex = podiumIndex,
		IsEgg = isEgg,
		Frame = clone,
		ProgressFrame = progress,
		ButtonsFrame = buttons,
		ProgressLabel = label3,
		HatchButton = hatchButton,
		HatchReady = false,
		SellButton = sell,
		SellLabel = label2,
		SellDefaultSize = sell.Size,
		SellArmedUntil = 0,
		SkipButton = skipButton
	}

	if hatchButton then
		local v8 = AnimatedButton.new(hatchButton):Animate()
		table.insert(v, v8)
		v8.OnActivated:Connect(function()
			if v7.HatchReady then
				remoteEvent:FireServer(v7.PodiumIndex)
			end
		end)
	end

	if skipButton then
		local v8 = AnimatedButton.new(skipButton):Animate()
		table.insert(v, v8)
		v8.OnActivated:Connect(function()
			if not v7.HatchReady then
				remoteEvent2:FireServer(v7.PodiumIndex)
			end
		end)
	end

	if hatchButton then
		updateEggRow(v7, entry)
	end

	local v8 = AnimatedButton.new(sell):Animate()
	table.insert(v, v8)
	v8.OnActivated:Connect(function()
		if not (os.clock() < v7.SellArmedUntil) then
			armSellConfirm(v7)
			return
		end

		v7.SellArmedUntil = 0
		local animal2 = Animals[entry.Index]

		if animal2 and Animals2:GetRarityWeight(animal2.Rarity) > 5 then
			task.spawn(function()
				local formatted = `Do you want to sell {entry.Index}?`
				local v9 = not ConfirmationController:IsInPrompt() and ConfirmationController:Show(formatted) or false

				if not v7.SellButton.Parent then
					return
				end

				if v9 then
					remoteEvent3:FireServer(v7.PodiumIndex)
					return
				end

				v7.SellLabel.Text = "SELL"
				v7.SellButton.BackgroundColor3 = color2
			end)
		else
			remoteEvent3:FireServer(v7.PodiumIndex)
		end
	end)
	updateProgressWidth(v7)
	return v7
end

local function clearRows()
	for _, v3 in v do
		v3:Destroy()
	end

	table.clear(v)

	for _, v3 in rows do
		v3.Frame:Destroy()
	end

	table.clear(rows)
end

local function rebuildRows(object)
	clearRows()
	local animalPodiums = object:Get("AnimalPodiums")

	if not animalPodiums then
		emptyLabel.Visible = true
		return
	end

	local maxAnimals = Bases[object:Get("Rebirth") or 0].MaxAnimals
	local v3 = {}

	for k, animalPodium in animalPodiums do
		if not (type(animalPodium) == "table" and type(k) == "number") then
			continue
		end

		if k < 1 or maxAnimals < k or animalPodium.Machine and animalPodium.Machine.Active then
			continue
		end

		local animal = Animals[animalPodium.Index]
		local v4 = {
			PodiumIndex = k,
			Entry = animalPodium,
			IsEgg = animal ~= nil and (animal.LuckyBlock ~= nil or animal.Egg ~= nil)
		}
		table.insert(v3, v4)
	end

	table.sort(v3, function(a, b)
		if a.IsEgg == b.IsEgg then
			return a.PodiumIndex < b.PodiumIndex
		end

		return a.IsEgg
	end)

	for k, v4 in v3 do
		local row = createRow(v4.PodiumIndex, v4.Entry, k)
		table.insert(rows, row)
	end

	emptyLabel.Visible = #rows == 0
end

local function refreshEggRows(object)
	local animalPodiums = object:Get("AnimalPodiums")

	if not animalPodiums then
		return
	end

	for _, v3 in rows do
		if not v3.IsEgg then
			continue
		end

		local animalPodium = animalPodiums[v3.PodiumIndex]

		if type(animalPodium) == "table" then
			updateEggRow(v3, animalPodium)
		end
	end
end

local function setupPanel()
	myBase = localPlayer:WaitForChild("PlayerGui"):WaitForChild("MyBase")
	myBase2 = myBase:WaitForChild("MyBase")
	list = myBase2:WaitForChild("List")
	uIListLayout = list:WaitForChild("UIListLayout")
	template = list:WaitForChild("Template")
	toggle = myBase2:WaitForChild("Toggle")
	emptyLabel = myBase2:WaitForChild("EmptyLabel")
	template.Visible = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCanvas()
		list.CanvasSize = UDim2.fromOffset(0, uIListLayout.AbsoluteContentSize.Y)
	end

	uIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
	updateCanvas() -- equivalent call inferred; original call site unknown
	local label = toggle:WaitForChild("Label")
	AnimatedButton.new(toggle):Animate().OnActivated:Connect(function()
		v2 = not v2
		label.Text = v2 and ">" or "<"
		local uDim2 = UDim2.new(0.99, myBase2.AbsoluteSize.X, 0.5, 0)
		local v4 = myBase2
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

		if v2 then
			uDim2 = uDim
		end

		CreateTween(v4, tweenInfo, {
			Position = uDim2
		})
	end)
	myBase2.Position = uDim
	myBase.Enabled = true
end

return {
	Start = function(_)
		if not ServerData.IsJumpLTMServer() then
			return
		end

		task.spawn(function()
			local v3 = Synchronizer:Wait(localPlayer)

			if not v3 then
				return
			end

			setupPanel()
			rebuildRows(v3)
			v3:OnChanged("AnimalAddedOrRemoved", function()
				rebuildRows(v3)
			end)
			Timer.Simple(1, function()
				refreshEggRows(v3)
			end)
		end)
	end
}