local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ConsoleSignals = require(ReplicatedStorage.Client.ConsoleSignals)
require(ReplicatedStorage.Client.Types.GUI)
require(ReplicatedStorage.Packages.Signal)
local v = RunService:IsStudio() and 20 or nil
local v2 = {
	ActivePets = true,
	AreaGui = true,
	AssetEggData = true,
	AssetHoverData = true,
	AutoSell = true,
	Backpack = "BackpackGui",
	BossMastery = true,
	BossShop = true,
	CaptureTheEggUI = true,
	DrScrambleEvent = "DrScrambleEventUI",
	DropHeldEgg = true,
	Fade = true,
	GetMoreSpeedOnHit = true,
	GreatBloomBanner = true,
	GroupReward = "FreeGift",
	GrowingEggs = true,
	HUD = true,
	Index = true,
	LightVsDarknessUI = true,
	Message = true,
	MonsterCharge = "MonsterChargeUI",
	MonsterChestRewards = true,
	MonsterEventTutorialFrame = true,
	Notifications = true,
	OfflineMoneyInPlot = true,
	PetFuse = true,
	PopupPrompt = true,
	RescueDragonFTUEQuest = true,
	ResetStartTimer = true,
	RiftTradeIn = true,
	DrScrambleTradeIn = true,
	RollbackReward = "RollbackRewardUI",
	SakuraCrystalCounter = true,
	SakuraEggCharge = true,
	SakuraEventTutorialFrame = true,
	SammyEventUI = true,
	ScrambleBossMastery = true,
	SellPrompt = true,
	Settings = true,
	Shop = "RobuxShop",
	SpeedGainAnimation = true,
	StaticTreadmillImageSurfaceGui = true,
	StolenVaultEvent = "StolenVaultEventUI",
	TopBarStandard = "TopbarStandard",
	TrailShop = true,
	TreadmillScreenButtonShare = true,
	TreadmillScreenButtonSwapLeft = true,
	TreadmillScreenButtonSwapRight = true,
	TreadmillScreenComments = true,
	TreadmillScreenFriendLikes = true,
	TreadmillScreenSideButtons = true,
	TreadmillVideoSurfaceGui = true,
	TutorialInstructions = true
}
local v3 = {
	AssetHoverData = "ScreenGui",
	GetMoreSpeedOnHit = "ScreenGui",
	MonsterCharge = "ScreenGui"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function shape(class2: string, children)
	return {
		class = class2,
		children = children
	}
end

local v4 = shape("Frame", {
	Icon = {
		class = "ImageButton",
		children = nil
	},
	Timer = {
		class = "TextLabel",
		children = nil
	}
}) -- equivalent call inferred; original call site unknown
local v5 = shape("ScreenGui", {
	BottomFrame = {
		class = "Frame",
		children = {
			Holder = {
				class = "Frame",
				children = {
					List = {
						class = "Frame",
						children = {
							Luck = {
								class = "Frame",
								children = {
									Button = {
										class = "ImageButton",
										children = {
											Content = {
												class = "Frame",
												children = {
													Value = {
														class = "Frame",
														children = {
															TextLabel = {
																class = "TextLabel",
																children = nil
															}
														}
													}
												}
											}
										}
									}
								}
							},
							x2Growth = v4,
							x2Luck = v4
						}
					}
				}
			}
		}
	}
}) -- equivalent call inferred; original call site unknown

local function awaitChild(instance, childName: string)
	local v6

	if v == nil then
		v6 = instance:WaitForChild(childName)
	else
		v6 = instance:WaitForChild(childName, v)
	end

	return v6 or error(`{instance:GetFullName()} has no child named {childName}`, 2)
end

local localPlayer = Players.LocalPlayer
local v6

if v == nil then
	v6 = localPlayer:WaitForChild("PlayerGui")
else
	v6 = localPlayer:WaitForChild("PlayerGui", v)
end

local v7 = v6 or error(`{localPlayer:GetFullName()} has no child named PlayerGui`, 2)

local function descend(instance, items)
	for _, childName in items do
		local child

		if v == nil then
			child = instance:WaitForChild(childName)
		else
			child = instance:WaitForChild(childName, v)
		end

		if child then
			instance = child
		else
			instance = error(`{instance:GetFullName()} has no child named {childName}`, 2)
		end
	end

	return instance
end

local conform

conform = function(instance, p, p2: string)
	assert(instance:IsA(p.class), (`{p2} is a {instance.ClassName}, not the expected {p.class}`))

	for childName, v8 in p.children or {} do
		local v10

		if v == nil then
			v10 = instance:WaitForChild(childName)
		else
			v10 = instance:WaitForChild(childName, v)
		end

		conform(v10 or error(`{instance:GetFullName()} has no child named {childName}`, 2), v8, (`{p2}.{childName}`))
	end
end

local function screenNamed(p: string)
	local v8 = v2[p]

	if v8 == true then
		v8 = p
	end

	local v9 = v7
	local v10

	if v == nil then
		v10 = v9:WaitForChild(v8)
	else
		v10 = v9:WaitForChild(v8, v)
	end

	local v11 = v10 or error(`{v9:GetFullName()} has no child named {v8}`, 2)
	local v12 = v3[p]

	if v12 ~= nil then
		assert(v11:IsA(v12), (`{v8} is a {v11.ClassName}, not the {v12} that GUI.{p} promises`))
	end

	return v11
end

local function adoptScale(parent)
	local uIScale = parent:FindFirstChildOfClass("UIScale")

	if uIScale ~= nil then
		return uIScale
	end

	local uIScale2 = Instance.new("UIScale")
	uIScale2.Scale = 0
	uIScale2.Parent = parent
	return uIScale2
end

local function resetTimerLabel()
	local resetStartTimer = v2.ResetStartTimer
	local v8 = resetStartTimer == true and "ResetStartTimer" or resetStartTimer
	local v9 = v7
	local v10

	if v == nil then
		v10 = v9:WaitForChild(v8)
	else
		v10 = v9:WaitForChild(v8, v)
	end

	local v11 = v10 or error(`{v9:GetFullName()} has no child named {v8}`, 2)
	local resetStartTimer2 = v3.ResetStartTimer

	if resetStartTimer2 ~= nil then
		assert(
			v11:IsA(resetStartTimer2),
			(`{v8} is a {v11.ClassName}, not the {resetStartTimer2} that GUI.ResetStartTimer promises`)
		)
	end

	for _, childName in { "Frame", "TextLabel" } do
		local child

		if v == nil then
			child = v11:WaitForChild(childName)
		else
			child = v11:WaitForChild(childName, v)
		end

		if child then
			v11 = child
		else
			v11 = error(`{v11:GetFullName()} has no child named {childName}`, 2)
		end
	end

	return v11
end

local v8 = {
	BottomUI = function()
		local v9 = v7
		local v10

		if v == nil then
			v10 = v9:WaitForChild("BottomUI")
		else
			v10 = v9:WaitForChild("BottomUI", v)
		end

		local selected = v10 or error(`{v9:GetFullName()} has no child named BottomUI`, 2)
		conform(selected, v5, "BottomUI")
		return selected
	end,
	FadeFrame = function()
		local fade = v2.Fade
		local v9 = fade == true and "Fade" or fade
		local v10 = v7
		local v11

		if v == nil then
			v11 = v10:WaitForChild(v9)
		else
			v11 = v10:WaitForChild(v9, v)
		end

		local v12 = v11 or error(`{v10:GetFullName()} has no child named {v9}`, 2)
		local fade2 = v3.Fade

		if fade2 ~= nil then
			assert(v12:IsA(fade2), (`{v9} is a {v12.ClassName}, not the {fade2} that GUI.Fade promises`))
		end

		for _, childName in { "Fade" } do
			local child

			if v == nil then
				child = v12:WaitForChild(childName)
			else
				child = v12:WaitForChild(childName, v)
			end

			if child then
				v12 = child
			else
				v12 = error(`{v12:GetFullName()} has no child named {childName}`, 2)
			end
		end

		return v12
	end,
	PlayerGui = function()
		return v7
	end,
	ResetStartTimerLabel = resetTimerLabel,
	ResetStartTimerLabelScale = function()
		local resetStartTimer = v2.ResetStartTimer
		local v9 = resetStartTimer == true and "ResetStartTimer" or resetStartTimer
		local v10 = v7
		local v11

		if v == nil then
			v11 = v10:WaitForChild(v9)
		else
			v11 = v10:WaitForChild(v9, v)
		end

		local parent = v11 or error(`{v10:GetFullName()} has no child named {v9}`, 2)
		local resetStartTimer2 = v3.ResetStartTimer

		if resetStartTimer2 ~= nil then
			assert(
				parent:IsA(resetStartTimer2),
				(`{v9} is a {parent.ClassName}, not the {resetStartTimer2} that GUI.ResetStartTimer promises`)
			)
		end

		for _, childName in { "Frame", "TextLabel" } do
			local child

			if v == nil then
				child = parent:WaitForChild(childName)
			else
				child = parent:WaitForChild(childName, v)
			end

			if child then
				parent = child
			else
				parent = error(`{parent:GetFullName()} has no child named {childName}`, 2)
			end
		end

		local uIScale = parent:FindFirstChildOfClass("UIScale")

		if uIScale ~= nil then
			return uIScale
		end

		local uIScale2 = Instance.new("UIScale")
		uIScale2.Scale = 0
		uIScale2.Parent = parent
		return uIScale2
	end
}
local v9 = {}

local function accessorNamed(p: string)
	local v10 = v9[p]

	if v10 ~= nil then
		return v10
	end

	local v11 = v8[p]
	local fn = v11 == nil and v2[p] ~= nil and function()
		local v12 = p
		local v13 = v2[v12]

		if v13 == true then
			v13 = v12
		end

		local v14 = v7
		local v15

		if v == nil then
			v15 = v14:WaitForChild(v13)
		else
			v15 = v14:WaitForChild(v13, v)
		end

		local v16 = v15 or error(`{v14:GetFullName()} has no child named {v13}`, 2)
		local v17 = v3[v12]

		if v17 ~= nil then
			assert(v16:IsA(v17), (`{v13} is a {v16.ClassName}, not the {v17} that GUI.{v12} promises`))
		end

		return v16
	end or v11
	v9[p] = fn
	return fn
end

local class = {}
class.__index = class
local v10 = {}
local v11 = {}

function class:Disconnect()
	for _, link in self.links do
		link:Disconnect()
	end

	table.clear(self.links)

	if v10[self.button] == self then
		v10[self.button] = nil
	end
end

return (setmetatable({
	OnActivated = function(instance, onActivated)
		local connection = v10[instance]

		if connection ~= nil then
			connection:Disconnect()
		end

		local object = setmetatable({
			button = instance,
			links = {}
		}, class)
		table.insert(object.links, instance.Activated:Connect(onActivated))
		table.insert(object.links, ConsoleSignals.ButtonUp:Connect(function(p)
			if p == instance then
				onActivated()
			end
		end))
		v10[instance] = object
		instance.Destroying:Once(function()
			if v10[instance] == object then
				object:Disconnect()
			end
		end)
		return object
	end,
	Get = function(p: string)
		local v12 = v11[p]

		if v12 ~= nil and v12.Parent ~= nil then
			return v12
		end

		local fn = v9[p]

		if fn == nil then
			local v13 = v8[p]
			fn = v13 == nil and v2[p] ~= nil and function()
				local v14 = p
				local v15 = v2[v14]

				if v15 == true then
					v15 = v14
				end

				local v16 = v7
				local v17

				if v == nil then
					v17 = v16:WaitForChild(v15)
				else
					v17 = v16:WaitForChild(v15, v)
				end

				local v18 = v17 or error(`{v16:GetFullName()} has no child named {v15}`, 2)
				local v19 = v3[v14]

				if v19 ~= nil then
					assert(v18:IsA(v19), (`{v15} is a {v18.ClassName}, not the {v19} that GUI.{v14} promises`))
				end

				return v18
			end or v13
			v9[p] = fn
		end

		if fn == nil then
			error(`GUI.Get: nothing is registered under {p}`, 2)
		end

		local v13 = fn()
		v11[p] = v13
		return v13
	end
}, {
	__index = function(_, p: string)
		local fn = v9[p]

		if fn == nil then
			local v12 = v8[p]
			fn = v12 == nil and v2[p] ~= nil and function()
				local v13 = p
				local v14 = v2[v13]

				if v14 == true then
					v14 = v13
				end

				local v15 = v7
				local v16

				if v == nil then
					v16 = v15:WaitForChild(v14)
				else
					v16 = v15:WaitForChild(v14, v)
				end

				local v17 = v16 or error(`{v15:GetFullName()} has no child named {v14}`, 2)
				local v18 = v3[v13]

				if v18 ~= nil then
					assert(v17:IsA(v18), (`{v14} is a {v17.ClassName}, not the {v18} that GUI.{v13} promises`))
				end

				return v17
			end or v12
			v9[p] = fn
		end

		return fn or error(`GUI has no accessor named {p}`, 2)
	end
}))