local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local datas = ReplicatedStorage:WaitForChild("Datas")
local EclipseSpinWheel = require(datas.EclipseSpinWheel)
local Shop = require(datas.Shop)
local utils = ReplicatedStorage:WaitForChild("Utils")
local TimeUtils = require(utils.TimeUtils)
local NumberUtils = require(utils.NumberUtils)
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local InterfaceController = require(controllers.InterfaceController)
local CustomRichTextController = require(controllers.CustomRichTextController)
local shared = ReplicatedStorage:WaitForChild("Shared")
local Marketplace = require(shared.Marketplace)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(packages.Trove)
local Timer = require(packages.Timer)
local Synchronizer = require(packages.Synchronizer)
local localPlayer = Players.LocalPlayer
local EclipseSpinWheel2 = {}
EclipseSpinWheel2.__index = EclipseSpinWheel2

local function IsEnabled()
	return ReplicatedStorage:GetAttribute("EclipseEvent")
end

function EclipseSpinWheel2.new(instance)
	local v = Synchronizer:Wait(localPlayer)
	local object = setmetatable({}, EclipseSpinWheel2)
	object.Instance = instance
	object.Collector = Trove.new()
	local main = instance:FindFirstChild("Main")
	local surfaceGui = main and main:FindFirstChild("SurfaceGui")
	local wheel = surfaceGui and surfaceGui:FindFirstChild("Wheel")
	local items = wheel and wheel:FindFirstChild("Items")
	local names = wheel and wheel:FindFirstChild("Names")
	local odds = wheel and wheel:FindFirstChild("Odds")
	local root = instance:FindFirstChild("Root")
	local proximityPrompt = root and root:FindFirstChildOfClass("ProximityPrompt")
	local overhead = instance:FindFirstChild("Overhead")
	local billboardGui = overhead and overhead:FindFirstChildOfClass("BillboardGui")
	local countdown = billboardGui and billboardGui:FindFirstChild("Countdown")

	if not (main and main:IsA("BasePart") and wheel and wheel:IsA("GuiObject") and items and names and odds and proximityPrompt and countdown and countdown:IsA("TextLabel")) then
		return object
	end

	local function setup()
		for i = 1, #EclipseSpinWheel.Rewards do
			local reward = EclipseSpinWheel.Rewards[i]

			if not reward then
				continue
			end

			if reward.Type == "Item" and v:Get((`Items.{reward.Index}`)) and EclipseSpinWheel.AltRewards[i] then
				reward = EclipseSpinWheel.AltRewards[i]
			end

			local child = items:FindFirstChild((tostring(i)))
			local child2 = names:FindFirstChild((tostring(i)))
			local child3 = odds:FindFirstChild((tostring(i)))
			local v2 = ""
			local icon

			if reward.Type == "Cash-Pack" then
				local value = Shop[reward.Index].Value
				local rebirth = v:Get("Rebirth") or 0

				if rebirth > 0 then
					value *= rebirth <= 1 and 1.5 or rebirth
				end

				v2 = `${NumberUtils:ToString(value, 2)}`
				icon = Marketplace:GetProductInfo(reward.Index, "Product").Icon
			else
				icon = reward.Icon
			end

			local display = reward.Display
			local v3 = v2 == "" and display or v2
			local formatted = `{reward.Weight}%`
			child.Image = icon or ""
			CustomRichTextController.apply(child2, v3, {
				attachToInstance = true
			})
			child3.Text = formatted
		end
	end

	setup()
	object.Collector:Add(v:OnDictionaryInserted("Items", function(_: boolean, p: string)
		local flag = false

		for i = 1, #EclipseSpinWheel.Rewards do
			local reward = EclipseSpinWheel.Rewards[i]

			if not (reward.Type == "Item" and p == reward.Index) then
				continue
			end

			flag = true
			break
		end

		if flag then
			setup()
		end
	end))
	object.Collector:Add(RunService.RenderStepped:Connect(function(dt: number)
		debug.profilebegin("EclipseSpinWheel:Rotate3D")
		wheel.Rotation = (wheel.Rotation + dt * 45) % 360
		debug.profileend()
	end))
	object.Collector:Add(proximityPrompt.Triggered:Connect(function()
		InterfaceController:Toggle("EclipseWheel", true)
	end))
	local v2 = Timer.new(1)
	object.Collector:Add(v2, "Destroy")
	object.Collector:Add(v2.Tick:Connect(function()
		if not ReplicatedStorage:GetAttribute("EclipseEvent") then
			countdown.Text = `Free Spin in {TimeUtils:D((ReplicatedStorage:GetAttribute("NextEclipseEvent") or 0) - workspace:GetServerTimeNow())}`
		elseif v:Get("EclipseSpinWheel.LastFreeClaimed") == ReplicatedStorage:GetAttribute("EclipseEventLastTime") then
			countdown.Text = `Free Spin in {TimeUtils:D((ReplicatedStorage:GetAttribute("NextEclipseEvent") or 0) - workspace:GetServerTimeNow())}`
		else
			countdown.Text = "SPIN NOW"
		end
	end))
	v2:StartNow()
	return object
end

function EclipseSpinWheel2:Destroy()
	self.Collector:Destroy()
end

return EclipseSpinWheel2