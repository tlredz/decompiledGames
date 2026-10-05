local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local gameServices = ReplicatedStorage:WaitForChild("GameServices")
local General = require(gameServices:WaitForChild("General"))
local PetAging = require(gameServices:WaitForChild("PetAging"))
local StringService = require(gameServices:WaitForChild("StringService"))
local DayNight = require(gameServices:WaitForChild("DayNight"))
local PurchaseCue = require(gameServices:WaitForChild("PurchaseCue"))
local String = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("String"))
local Eggs = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Eggs"))
local General2 = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("General"))
local Monetization = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Monetization"))
local game2 = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local hatch = game2:WaitForChild("Hatch")
local parent = script.Parent
local holder = parent:WaitForChild("Holder")
local growAll = parent:WaitForChild("GrowAll")
local eggFrame = script:WaitForChild("EggFrame")
local size = eggFrame:WaitForChild("Progress").Size
local skipSize = eggFrame.Progress:GetAttribute("SkipSize") or size
local sideBar = parent.Parent:FindFirstChild("SideBar")
local egg = sideBar and sideBar:FindFirstChild("Egg")
local notification = egg and egg:FindFirstChild("Notification")
local count = notification and notification:FindFirstChild("Count")
local v = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Mythic = 6,
	Mythical = 6,
	Divine = 7,
	Ethereal = 8
}
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function PlotEggs()
	local plot = General:GetPlot(localPlayer)
	return plot and plot:FindFirstChild("Eggs")
end

local function StateOf(instance)
	local egg2 = Eggs[instance.Name]
	local eggData = instance:FindFirstChild("EggData")
	local placeTime = eggData and eggData:FindFirstChild("PlaceTime")

	if not egg2 or not placeTime or placeTime.Value <= 0 then
		return nil
	end

	local weight = eggData:FindFirstChild("Weight")
	local weight2 = weight and tonumber(weight.Value) or 1
	local growthTimeFor = General2.GrowthTimeFor(egg2.GrowthTime, weight2)
	local v3 = instance:GetAttribute("FlatGrow") == true and workspace:GetServerTimeNow() - placeTime.Value or DayNight.GrowthElapsed(placeTime.Value)
	return {
		Config = egg2,
		Weight = weight2,
		Total = growthTimeFor,
		Progress = not (growthTimeFor > 0) and 1 or math.clamp(v3 / growthTimeFor, 0, 1) or 1,
		TimeLeft = growthTimeFor - v3
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HatchLocked(instance)
	if localPlayer:GetAttribute("TutorialHatchLocked") ~= true then
		return false
	end

	local tutorialLockedEggKey = localPlayer:GetAttribute("TutorialLockedEggKey")
	return tutorialLockedEggKey == nil or tutorialLockedEggKey == instance:GetAttribute("EggKey")
end

local function CanSkip(instance, p)
	if p.TimeLeft >= 300 and localPlayer:GetAttribute("TutorialActive") ~= true then
		local hatchLocked = HatchLocked(instance) -- equivalent call inferred; original call site unknown
		return not hatchLocked
	else
		return false
	end
end

local function PromptSkip(instance, name)
	if not instance.Parent then
		return
	end

	local state = StateOf(instance)

	if state then
		local v4

		if state.TimeLeft >= 300 and localPlayer:GetAttribute("TutorialActive") ~= true then
			local hatchLocked = HatchLocked(instance) -- equivalent call inferred; original call site unknown
			v4 = not hatchLocked
		else
			v4 = false
		end

		if v4 then
			local skipTierFor = Monetization.SkipTierFor(state.TimeLeft)
			local v5 = skipTierFor and Monetization[skipTierFor.Product]
			local registerSkipTarget = game2:FindFirstChild("RegisterSkipTarget")

			if not (v5 and registerSkipTarget) then
				return
			end

			registerSkipTarget:FireServer(name, instance:GetAttribute("OwnerUserId") or localPlayer.UserId)
			PurchaseCue.Play()
			MarketplaceService:PromptProductPurchase(localPlayer, v5)
		end
	end
end

local nowsByEggKey = {}

local function Hatch(instance)
	-- equivalent call inferred; original call site unknown
	if HatchLocked(instance) then
		return
	end

	local eggKey = instance:GetAttribute("EggKey")

	if not eggKey then
		return
	end

	local v3 = nowsByEggKey[eggKey]

	if v3 and os.clock() - v3 < 1 then
		return
	end

	nowsByEggKey[eggKey] = os.clock()
	instance:AddTag("Hatching")
	hatch:FireServer({
		EggKey = eggKey
	})
end

local v3 = {}

local function BuildFrame(child, eggKey, p)
	local clone = eggFrame:Clone()
	clone.Name = eggKey
	clone.Holder.EggImage.Image = p.Config.Image or ""
	clone.Open.Visible = false
	clone.Skip.Visible = false
	clone.Skip.Activated:Connect(function()
		PromptSkip(child, eggKey)
	end)
	local eggWeight = clone.Holder.EggImage.EggWeight
	eggWeight.TextScaled = true
	eggWeight.TextWrapped = true
	clone.Open.Activated:Connect(function()
		if not child.Parent then
			return
		end

		local state = StateOf(child)

		if not state or state.TimeLeft > 0 then
			return
		end

		Hatch(child)
		v3[eggKey] = os.clock()

		if v2[eggKey] == clone then
			v2[eggKey] = nil
		end

		clone:Destroy()
	end)
	clone.Parent = holder
	v2[eggKey] = clone
	return clone
end

local function UpdateFrame(instance, state, data)
	local visible = data.TimeLeft <= 0
	state.Holder.EggImage.EggWeight.Text = StringService.Abbreviate(PetAging.InflateEggWeight(data.Weight), 2, true) .. " KG"
	state.Progress.Bar.Size = UDim2.new(data.Progress, 0, 1, 0)

	if visible then
		state.Progress.TimeLeft.Text = "Ready"
	else
		state.Progress.TimeLeft.Text = String:ConvertToUnits(data.TimeLeft)
	end

	if visible then
		local hatchLocked = HatchLocked(instance) -- equivalent call inferred; original call site unknown
		visible = not hatchLocked
	end

	state.Open.Visible = visible
	state.Progress.Visible = not visible
	local visible2 = not visible

	if visible2 then
		if data.TimeLeft >= 300 and localPlayer:GetAttribute("TutorialActive") ~= true then
			local hatchLocked = HatchLocked(instance) -- equivalent call inferred; original call site unknown
			visible2 = not hatchLocked
		else
			visible2 = false
		end
	end

	state.Skip.Visible = visible2
	state.Progress.Size = visible2 and skipSize or size
	local v6 = v[data.Config.Rarity] or 0
	local v7 = math.clamp(math.floor(data.Weight * 100), 0, 99999)
	state.LayoutOrder = -(v6 * 100000 + v7)
end

local v4 = {}
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshBadge()
	if not notification then
		return
	end

	local count2 = 0

	for _ in v4 do
		count2 += 1
	end

	if count then
		count.Text = tostring(count2)
	end

	notification.Visible = count2 > 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearBadge()
	table.clear(v4)
	RefreshBadge() -- equivalent call inferred; original call site unknown
end

if egg then
	egg.Activated:Connect(ClearBadge)
end

parent:GetAttributeChangedSignal("Open"):Connect(function()
	if parent:GetAttribute("Open") == true then
		ClearBadge() -- equivalent call inferred; original call site unknown
	end
end)
RefreshBadge() -- equivalent call inferred; original call site unknown

local function CountEggs()
	local count2 = 0
	local count3 = 0
	local plotEggs = PlotEggs() -- equivalent call inferred; original call site unknown

	if not plotEggs then
		return count2, count3
	end

	for _, child in plotEggs:GetChildren() do
		local v7 = child:GetAttribute("EggKey") and StateOf(child)

		if not v7 then
			continue
		end

		count2 += 1

		if v7.TimeLeft > 0 then
			count3 += 1
		end
	end

	return count2, count3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowMessage(p)
	pcall(function()
		local Handler = require(localPlayer.PlayerGui.Reusable.GameMessages.Handler)
		Handler:AddMessage(p)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowGrowAll(visible)
	if growAll.Visible ~= visible then
		growAll.Visible = visible
	end
end

growAll.Activated:Connect(function()
	local _, v6 = CountEggs()

	if v6 == 0 then
		ShowMessage("No eggs are growing on your plot right now") -- equivalent call inferred; original call site unknown
	else
		local registerSkipAllTarget = game2:FindFirstChild("RegisterSkipAllTarget")

		if registerSkipAllTarget then
			registerSkipAllTarget:FireServer(localPlayer.UserId)
		end

		PurchaseCue.Play()
		MarketplaceService:PromptProductPurchase(localPlayer, Monetization.SkipEggGrowthAll)
	end
end)

for _, guiObject in holder:GetChildren() do
	if guiObject:IsA("GuiObject") then
		guiObject:Destroy()
	end
end

local uIListLayout = holder:WaitForChild("UIListLayout")
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
local total = 0.5
local total2 = 0
RunService.Heartbeat:Connect(function(dt)
	total2 += dt
	total += dt

	if total2 < 0.1 then
		return
	end

	total2 = 0
	local open = parent:GetAttribute("Open") ~= false
	local v6 = total >= 0.5

	if not (open or v6) then
		return
	end

	if v6 then
		total = 0
	end

	local plotEggs = PlotEggs() -- equivalent call inferred; original call site unknown
	local v8 = {}
	local v9 = false
	local count2 = 0

	if plotEggs then
		for _, child in plotEggs:GetChildren() do
			local eggKey = child:GetAttribute("EggKey")
			local v10 = eggKey and StateOf(child)

			if not v10 then
				continue
			end

			count2 += 1
			local v11 = v10.TimeLeft <= 0
			local v12 = v5[eggKey]

			if v12 == nil then
				v4[eggKey] = true
				v9 = true
			elseif v11 and not (v12 or v4[eggKey]) then
				v4[eggKey] = true
				v9 = true
			end

			v5[eggKey] = v11
			local v13 = v3[eggKey]

			if v13 and os.clock() - v13 >= 5 then
				v3[eggKey] = nil
				v13 = nil
			end

			v8[eggKey] = true

			if not open or v13 then
				continue
			end

			local v14 = v2[eggKey]

			if not (v14 and v14.Parent) then
				v14 = BuildFrame(child, eggKey, v10)
			end

			if pcall(UpdateFrame, child, v14, v10) then
				continue
			end

			v2[eggKey] = nil
			v14:Destroy()
		end
	end

	if v9 and notification then
		local count3 = 0

		for _ in v4 do
			count3 += 1
		end

		if count then
			count.Text = tostring(count3)
		end

		notification.Visible = count3 > 0
	end

	ShowGrowAll(count2 > 0) -- equivalent call inferred; original call site unknown

	if not v6 then
		return
	end

	for _, guiObject in holder:GetChildren() do
		if not guiObject:IsA("GuiObject") or v8[guiObject.Name] then
			continue
		end

		if v2[guiObject.Name] == guiObject then
			v2[guiObject.Name] = nil
		end

		guiObject:Destroy()
	end

	for k in v3 do
		if not v8[k] then
			v3[k] = nil
		end
	end

	for k in v5 do
		if v8[k] then
			continue
		end

		v5[k] = nil

		if not v4[k] then
			continue
		end

		v4[k] = nil
		RefreshBadge() -- equivalent call inferred; original call site unknown
	end
end)