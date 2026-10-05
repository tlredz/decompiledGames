local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.Utility)
require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local Bundles = {}
Bundles.__index = Bundles

function Bundles.new(pages)
	local self = setmetatable({}, Bundles)
	self.Pages = pages
	self.Frame = self.Pages.Frame:WaitForChild("Bundles")
	self.Container = self.Frame:WaitForChild("Container")
	self.PermanentFrame = self.Container:WaitForChild("Permanent")
	self.TimedFrame = self.Container:WaitForChild("Timed")
	self._is_open_hash = 0
	self._superstarterbundle_slot = nil
	self:_Init()
	return self
end

function Bundles:Open()
	if self._superstarterbundle_slot then
		self._superstarterbundle_slot:StartLoops()
	end
end

function Bundles:Close()
	if self._superstarterbundle_slot then
		self._superstarterbundle_slot:StopLoops()
	end
end

function Bundles:Setup()
	for _, childName in pairs(self.Pages.Shop.BUNDLE_NAMES) do
		self.Pages.Shop:CreateBundleSlot(childName):SetParent(self.PermanentFrame:WaitForChild(childName))
	end

	self:_SetupSuperStarterBundleSlot()
end

function Bundles:_SetupSuperStarterBundleSlot()
	self._superstarterbundle_slot = self.Pages.Shop:CreateBundleSlot("superstarter_bundle")
	self._superstarterbundle_slot:SetParent(self.TimedFrame:WaitForChild("superstarter_bundle"))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		self.TimedFrame.Visible = self._superstarterbundle_slot:IsAvailableToPurchase()
	end

	self._superstarterbundle_slot.AvailabilityChanged:Connect(update)
	update() -- equivalent call inferred; original call site unknown

	if self.Pages.Shop:IsOpen() then
		self._superstarterbundle_slot:StartLoops()
	end
end

function Bundles:_Init() end

return Bundles