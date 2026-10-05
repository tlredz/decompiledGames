local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CurrencyLibrary)
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local Currency = {}
Currency.__index = Currency

function Currency.new(pages)
	local self = setmetatable({}, Currency)
	self.Pages = pages
	self.Frame = self.Pages.Frame:WaitForChild("Currency")
	self.Container = self.Frame:WaitForChild("Container")
	self.WeaponKeysFrame = self.Container:WaitForChild("WeaponKeys")
	self.EventCurrencyFrame = self.Container:WaitForChild("EventCurrency")
	self.EventCurrencyHeaderIcon = self.EventCurrencyFrame:WaitForChild("Header"):WaitForChild("Icon")
	self:_Init()
	return self
end

function Currency.Open(_) end

function Currency.Close(_) end

function Currency.Setup(data)
	for i = 1, 5 do
		local v = "keybundle_" .. i
		data.Pages.Shop:CreateBundleSlot(v):SetParent(data.WeaponKeysFrame:WaitForChild(v))
	end

	if EventLibrary.IS_ACTIVE then
		for i = 1, 5 do
			local v = "eventcurrencybundle_" .. i
			data.Pages.Shop:CreateBundleSlot(v):SetParent(data.EventCurrencyFrame:WaitForChild(v))
		end
	end
end

function Currency:_UpdateEvent()
	local visible = EventLibrary.IS_ACTIVE and PlayerDataController:GetStatistic("StatisticDuelsPlayed") >= EventLibrary.NUM_GAMES_NEEDED_TO_PARTICIPATE
	self.EventCurrencyFrame.Visible = visible
	self.Frame.Size = UDim2.new(1, 0, visible and 2.35 or 1, 0)
end

function Currency:_Setup()
	self.EventCurrencyHeaderIcon.Image = EventLibrary.EVENT_DETAILS.CURRENCY_IMAGE_FLAT
end

function Currency:_Init()
	PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
		self:_UpdateEvent()
	end)
	self:_Setup()
	self:_UpdateEvent()
end

return Currency