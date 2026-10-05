local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventController = require(ReplicatedStorage.Controllers.EventController)
require(ReplicatedStorage.Shared.EventTypes)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local name = script.Name
local thread = nil

local function getCountdown()
	local events = workspace:FindFirstChild("Events")
	local tacoMerchant = events and events:FindFirstChild("Taco Merchant")
	local tacoMerchantModel = tacoMerchant and tacoMerchant:FindFirstChild("Model")
	local overhead = tacoMerchantModel and tacoMerchantModel:FindFirstChild("Overhead")
	local billboardGui = overhead and overhead:FindFirstChild("BillboardGui")
	local countdown = billboardGui and billboardGui:FindFirstChild("Countdown")

	if countdown and countdown:IsA("TextLabel") then
		return countdown
	end

	return nil
end

local TacoMerchant = {}

function TacoMerchant.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	local countdown = getCountdown()

	if not (activeEventData and countdown) then
		return
	end

	if thread then
		task.cancel(thread)
	end

	thread = task.spawn(function()
		while true do
			countdown.Text = TimeUtils:E((math.max(activeEventData.endsAt - workspace:GetServerTimeNow(), 0)))
			task.wait(1)
		end
	end)
end

function TacoMerchant.OnStop(_)
	if thread then
		task.cancel(thread)
		thread = nil
	end
end

return TacoMerchant