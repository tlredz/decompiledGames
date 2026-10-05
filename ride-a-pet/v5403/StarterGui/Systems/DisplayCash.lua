local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local services = game.ReplicatedStorage:WaitForChild("Services")
local String = require(services:WaitForChild("String"))
local Passes = require(game.ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("Passes"))
local SFX = game.SoundService:WaitForChild("SFX")
local cashEarned = SFX:WaitForChild("CashEarned")
local purchase = SFX:WaitForChild("Purchase")
local AutoCollect = require(game.ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("AutoCollect"))
local localPlayer = game.Players.LocalPlayer
local now = 0
local hasFinishedTutorial = localPlayer:WaitForChild("SavedData"):WaitForChild("HasFinishedTutorial")
localPlayer:WaitForChild("NoSaveData"):WaitForChild("DataLoaded")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("PetCollect").OnClientEvent:Connect(function(p)
	if typeof(p) == "table" and p.Auto and p.Owner == localPlayer.UserId then
		now = os.clock()
	end
end)
local playerGui = localPlayer:WaitForChild("PlayerGui")
local cash = localPlayer:WaitForChild("SavedData"):WaitForChild("Cash")
local dataLoaded = localPlayer:WaitForChild("NoSaveData"):WaitForChild("DataLoaded")
local cashLog = script:WaitForChild("CashLog")

local function TaggedInGui(tag)
	local result = {}

	for _, v in ipairs(CollectionService:GetTagged(tag)) do
		if v:IsDescendantOf(playerGui) then
			table.insert(result, v)
		end
	end

	return result
end

local v = {
	"M",
	"B",
	"T",
	"Qa",
	"Qi",
	"Sx",
	"Sp",
	"Oc",
	"No",
	"Dc"
}

local function FormatCash(p)
	local v2 = math.floor(p + 0.5)

	if v2 < 1000000 then
		return String:AddComma(v2)
	end

	local v3 = math.min(math.floor(math.log10(v2) / 3), #v + 1)
	local v4 = math.floor(v2 / 10 ^ (v3 * 3) * 100) / 100
	return string.format("%.2f%s", v4, v[v3 - 1])
end

local value = 0
local count = 0
local instances = TaggedInGui("CashDisplay")
CollectionService:GetInstanceAddedSignal("CashDisplay"):Connect(function(instance)
	if instance:IsDescendantOf(playerGui) and not table.find(instances, instance) then
		table.insert(instances, instance)
	end
end)
CollectionService:GetInstanceRemovedSignal("CashDisplay"):Connect(function(p)
	local index = table.find(instances, p)

	if index then
		table.remove(instances, index)
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function SetDisplays(p)
	local text = FormatCash(p)

	for _, v3 in ipairs(instances) do
		v3.Text = text
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RollTo(value2)
	count += 1
	local v2 = count
	local v3 = value

	if v3 ~= value2 then
		task.spawn(function()
			local lastTime = os.clock()

			while v2 == count do
				local v4 = (os.clock() - lastTime) / 0.5

				if v4 >= 1 then
					break
				end

				local v5 = 1 - (1 - v4) ^ 3
				local v6 = v3 + (value2 - v3) * v5
				value = v6
				SetDisplays(math.floor(v6 + 0.5)) -- equivalent call inferred; original call site unknown
				RunService.RenderStepped:Wait()
			end

			if v2 ~= count then
				return
			end

			value = value2
			SetDisplays(value2) -- equivalent call inferred; original call site unknown
		end)
		return
	end

	value = value2
	SetDisplays(value2) -- equivalent call inferred; original call site unknown
end

CollectionService:GetInstanceAddedSignal("CashDisplay"):Connect(function(instance)
	if instance:IsDescendantOf(playerGui) then
		instance.Text = FormatCash(value)
	end
end)
local count2 = 0
local income = playerGui:WaitForChild("Main"):WaitForChild("Income")
local uIStroke = income:FindFirstChildOfClass("UIStroke")
local desktopIncomeSize = income:GetAttribute("DesktopIncomeSize") or income.Size
income:SetAttribute("DesktopIncomeSize", desktopIncomeSize)
local uDim = UDim2.new(
	desktopIncomeSize.X.Scale * 0.75,
	desktopIncomeSize.X.Offset * 0.75,
	desktopIncomeSize.Y.Scale * 0.75,
	desktopIncomeSize.Y.Offset * 0.75
)
local position = income.Position
local position3 = position
local currencyMobile = playerGui:WaitForChild("Main"):WaitForChild("CurrencyMobile")
local imageLabel = currencyMobile:WaitForChild("ImageLabel")

local function GetIncomeHome()
	local v3 = income
	local size3

	if currencyMobile.Visible then
		size3 = uDim
	else
		size3 = desktopIncomeSize
	end

	v3.Size = size3

	if not currencyMobile.Visible then
		return position
	end

	local position2 = imageLabel.Position
	local size = imageLabel.Size
	local anchorPoint = imageLabel.AnchorPoint
	local size2 = income.Size
	local anchorPoint2 = income.AnchorPoint
	return UDim2.new(
		position2.X.Scale + size.X.Scale * (1 - anchorPoint.X) - size2.X.Scale * (1 - anchorPoint2.X),
		position2.X.Offset + size.X.Offset * (1 - anchorPoint.X) - size2.X.Offset * (1 - anchorPoint2.X),
		position2.Y.Scale - size.Y.Scale * anchorPoint.Y - size2.Y.Scale * (1 - anchorPoint2.Y),
		position2.Y.Offset - size.Y.Offset * anchorPoint.Y - size2.Y.Offset * (1 - anchorPoint2.Y) - 2
	)
end

local color = Color3.fromRGB(170, 255, 0)
local color2 = Color3.fromRGB(255, 70, 70)
local color3 = Color3.fromRGB(0, 79, 0)
local color4 = Color3.fromRGB(54, 0, 0)
local v3 = 0
local v4 = -1e999
local count3 = 0
local tweens = {}
income.Visible = false

local function StopIncomeTweens()
	for _, v5 in ipairs(tweens) do
		v5:Cancel()
		v5:Destroy()
	end

	table.clear(tweens)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function TweenIncome(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	table.insert(tweens, tween)
	tween:Play()
end

local function FlashIncome(p)
	if p == 0 then
		return
	end

	local now2 = os.clock()
	local v5

	if p > 0 and v3 > 0 then
		v5 = true
	elseif p < 0 then
		v5 = v3 < 0
	else
		v5 = false
	end

	if income.Visible and v5 and now2 - v4 <= 0.1 then
		v3 += p
	else
		v3 = p
		v4 = now2
	end

	count3 += 1
	local v6 = count3
	StopIncomeTweens()
	local v7 = v3 > 0
	income.Text = (v7 and "+$" or "-$") .. FormatCash(math.abs(v3))
	local v8 = income
	local textColor

	if v7 then
		textColor = color
	else
		textColor = color2
	end

	v8.TextColor3 = textColor
	income.TextTransparency = 0

	if uIStroke then
		local v10 = uIStroke
		local color5

		if v7 then
			color5 = color3
		else
			color5 = color4
		end

		v10.Color = color5
		uIStroke.Transparency = 0
	end

	position3 = GetIncomeHome()
	income.Position = position3
	income.Visible = true
	local uDim2 = UDim2.new(position3.X.Scale, position3.X.Offset, position3.Y.Scale - 0.018, position3.Y.Offset)
	TweenIncome(income, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = uDim2
	}) -- equivalent call inferred; original call site unknown
	task.delay(0.5, function()
		if count3 ~= v6 then
			return
		end

		local uDim3 = UDim2.new(uDim2.X.Scale, uDim2.X.Offset, uDim2.Y.Scale - 0.018, uDim2.Y.Offset)
		local tweenInfo2 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenIncome(income, tweenInfo2, {
			Position = uDim3,
			TextTransparency = 1
		}) -- equivalent call inferred; original call site unknown

		if uIStroke then
			TweenIncome(uIStroke, tweenInfo2, {
				Transparency = 1
			}) -- equivalent call inferred; original call site unknown
		end

		task.delay(0.35, function()
			if count3 ~= v6 then
				return
			end

			StopIncomeTweens()
			income.Visible = false
			income.Position = position3
			v3 = 0
		end)
	end)
end

currencyMobile:GetPropertyChangedSignal("Visible"):Connect(function()
	count3 += 1
	StopIncomeTweens()
	income.Visible = false
	v3 = 0
	v4 = -1e999
	position3 = GetIncomeHome()
	income.Position = position3
end)

local function SpawnLog(p)
	if p == 0 then
		return
	end

	local enabled = p > 0
	local text = FormatCash(math.abs(p))
	count2 += 1

	for _, parent in ipairs((TaggedInGui("CashLog"))) do
		local clone = cashLog:Clone()
		clone.Text = text
		clone.LayoutOrder = count2
		clone.TextTransparency = 0
		local profit = clone:FindFirstChild("Profit")
		local loss = clone:FindFirstChild("Loss")

		if profit then
			profit.Enabled = enabled
		end

		if loss then
			loss.Enabled = not enabled
		end

		local uIStroke2 = clone:FindFirstChild("UIStroke")

		if uIStroke2 then
			uIStroke2.Transparency = 0
		end

		clone.Parent = parent
		Debris:AddItem(clone, 3.6)
		task.spawn(function()
			task.wait(3)
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(clone, tweenInfo, {
				TextTransparency = 1
			}):Play()

			if uIStroke2 then
				TweenService:Create(uIStroke2, tweenInfo, {
					Transparency = 1
				}):Play()
			end

			task.wait(0.5)

			if clone.Parent then
				clone:Destroy()
			end
		end)
	end
end

repeat
	task.wait()
until dataLoaded.Value == true

for _, v5 in ipairs((TaggedInGui("CashLog"))) do
	for _, label in ipairs(v5:GetChildren()) do
		if label:IsA("TextLabel") then
			label:Destroy()
		end
	end
end

value = cash.Value
SetDisplays(math.floor(value + 0.5)) -- equivalent call inferred; original call site unknown
local value2 = cash.Value
cash:GetPropertyChangedSignal("Value"):Connect(function()
	local value3 = cash.Value
	local v5 = value3 - value2
	value2 = value3

	if v5 > 0 then
		local now2 = os.clock()
		task.delay(0.15, function()
			local v6 = math.abs(now - now2) <= 0.35
			local value4 = hasFinishedTutorial.Value == true
			local v7 = dataLoaded.Value ~= true

			if AutoCollect.Enabled() then
				if value4 then
					v7 = value4
				elseif not v7 then
					v7 = Passes.Has(localPlayer, "AutoCollect")
				end
			else
				v7 = Passes.Has(localPlayer, "AutoCollect")
			end

			if v6 and v7 then
				return
			end

			if cashEarned:HasTag("ComboSound") then
				cashEarned:SetAttribute("Play", (tonumber(cashEarned:GetAttribute("Play")) or 0) + 1)
			else
				cashEarned:Play()
			end
		end)
	elseif v5 < 0 then
		purchase:Play()
	end

	RollTo(value3) -- equivalent call inferred; original call site unknown
	SpawnLog(v5)
	FlashIncome(v5)
end)