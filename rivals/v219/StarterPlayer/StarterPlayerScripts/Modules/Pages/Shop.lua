local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
require(ReplicatedStorage.Modules.EventLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local ShopController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ShopController"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local Spotlight = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Spotlight"))
local ShopSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("BaseShopSlot"):WaitForChild("ShopSlot"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local BundleSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("BundleSlot"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local BottomTabs = require(script:WaitForChild("BottomTabs"))
local Pages = require(script:WaitForChild("Pages"))
local Tabs = require(script:WaitForChild("Tabs"))
local v = {
	"rpg_bundle",
	"energy_bundle",
	"starter_bundle",
	"medkit_bundle",
	"exogun_bundle",
	"heavyduty_bundle",
	"classic_bundle",
	"standardweapons_bundle"
}
local v2 = {
	"Home",
	"Bundles",
	"Skins",
	"Daily",
	"Currency",
	"Ranked",
	"Rewards",
	"Gifting",
	"Weapons"
}
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CurrentPageChanged = Signal.new()
	self.PageContainer = self.PageFrame:WaitForChild("Container")
	self.PromptsFrame = self.PageContainer:WaitForChild("Prompts")
	self.WaitingFrame = self.PageContainer:WaitForChild("Waiting")
	self.DotsFrame = self.WaitingFrame:WaitForChild("Dots")
	self.List = self.PageContainer:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.BUNDLE_NAMES = v
	self.PAGE_NAMES = v2
	self.HidePartyDisplay = true
	self.CurrentPage = nil
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self.Tabs = Tabs.new(self)
	self.Pages = Pages.new(self)
	self.BottomTabs = BottomTabs.new(self)
	self._open_animation_disabled = true
	self._setup_finished = false
	self._setup_finished_event_internal = Signal.new()
	self._bundle_slots = {}
	self:_Init()
	return self
end

function object:SetPage(currentPage)
	Spotlight:ChangeSubject(nil)

	if currentPage == "Weapons" then
		Equipment:Open(true)
		self:CloseRequest()
	else
		if currentPage == "Gifting" then
			self.OpenPage:Fire("Gifting")
			return
		elseif currentPage == "Rewards" then
			self.OpenPage:Fire("Rewards")
			return
		elseif currentPage == "BattlePass" then
			self.OpenPage:Fire("BattlePass")
			return
		end

		self.CurrentPage = currentPage
		self.CurrentPageChanged:Fire(self.CurrentPage)
	end
end

function object:InspectShopEntry(p2)
	if p2 then
		self.PromptSystem:Open("InspectShopEntry", p2)
	end
end

function object:InspectBundle(p, _)
	if not p then
		return
	end

	task.defer(function()
		if not self._setup_finished then
			self._setup_finished_event_internal:Wait()
		end

		self.PromptSystem:Open("InspectBundle", p)
	end)
end

function object:CreateShopSlot(p, parent, p2, ...)
	local table = Utility:CloneTable(ShopController:GetShopEntry(p2))

	if parent then
		parent.BackgroundTransparency = 1
	end

	for _, reward in pairs(table.Rewards) do
		local reward2 = CosmeticLibrary.Rewards[reward.Name]

		if reward2 and reward2.Type == "Lootbox" then
			ComplianceController:ArePaidRandomItemsRestricted()
		end
	end

	local v4 = (p or ShopSlot).new(table, ...)
	v4.Frame.Parent = parent
	v4:OnClick(function()
		if v4.IsLocked or v4.IsOwned then
			return
		end

		self:InspectShopEntry(v4.ShopEntry.EntryName)
	end)
	return v4
end

function object:CreateBundleSlot(p)
	local v3 = BundleSlot.new(p)
	self._bundle_slots[p] = v3
	v3.Tapped:Connect(function()
		if ControlsController.CurrentControls == "Touch" then
			self:InspectBundle(v3.Name)
		else
			v3:PurchaseRequest()
		end
	end)
	return v3
end

function object.Open(data, ...)
	Page.Open(data, ...)
	data.Tabs:Open()
	data.Pages:Open()
	data.BottomTabs:Open()
	Utility:CreateSound("rbxassetid://18100002432", 1.25, 1, script, true, 5)
end

function object.Close(data, ...)
	Page.Close(data, ...)
	data.Tabs:Close()
	data.Pages:Close()
	data.BottomTabs:Close()
end

function object:_CheckScrollDownToLoginRewards()
	if self.CurrentPage ~= "Daily" or PlayerDataController:Get("ClaimedLoginRewardToday") then
		return
	end

	local frame = self.Pages.Components.Daily.LoginRewards.Frame
	task.delay(0.15, function()
		TweenService:Create(self.List, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CanvasPosition = Vector2.new(0, frame.AbsolutePosition.Y - self.Container.AbsolutePosition.Y)
		}):Play()
	end)
end

function object:_UpdatePromptContext()
	self.List.Visible = not self.PromptSystem.CurrentPrompt
end

function object:_UpdateScale()
	local v3 = self.CurrentPage == "Home" and 0.9 or 1
	self.List.Size = UDim2.new(1 / v3, 18, 1, 0)
	self.Container.Size = UDim2.new(v3 * 1, -8, v3 * 1, -8)
end

function object:_UpdateCanvasSize()
	local componentFrame = self.Pages:GetComponentFrame(self.CurrentPage)
	self.List.Size = UDim2.new(
		1,
		18,
		0,
		(math.min(
			self.PageFrame.AbsoluteSize.Y,
			UILibrary.MainGui.AbsolutePosition.Y + UILibrary.MainGui.AbsoluteSize.Y - self.List.AbsolutePosition.Y - 20
		))
	)
	self.List.CanvasSize = componentFrame and UDim2.new(
		0,
		0,
		0,
		componentFrame.AbsolutePosition.Y + componentFrame.AbsoluteSize.Y - self.Container.AbsolutePosition.Y
	) or UDim2.new(0, 0, 0, 0)
end

function object:_UpdateSize()
	self.PageContainer.Size = UDim2.new(1, 0, 1, -GuiService.TopbarInset.Height)
end

function object:_Setup()
	self.DotsFrame:AddTag("UILoadingDots")
	self.WaitingFrame.Visible = true
	self.Tabs.Frame.Visible = false
	self.Pages.Frame.Visible = false
	self.BottomTabs.Frame.Visible = false
	task.delay(0.25, function()
		self.DotsFrame:RemoveTag("UILoadingDots")
		self.WaitingFrame.Visible = false
		self.Tabs.Frame.Visible = true
		self.Pages.Frame.Visible = true
		self.BottomTabs.Frame.Visible = true
		self.Tabs:Setup()
		self.Pages:Setup()
		self.BottomTabs:Setup()
		self:SetPage(self.CurrentPage or "Home")
		self._setup_finished = true
		self._setup_finished_event_internal:Fire()
	end)
end

function object:_Init()
	self.PromptSystem.PromptAdded:Connect(function(p)
		self.List.CanvasPosition = Vector2.new(0, 0)
		self:_UpdatePromptContext()

		if p.InspectCurrencyPage then
			p.InspectCurrencyPage:Connect(function()
				self:SetPage("Currency")
			end)
		end
	end)
	self.PromptSystem.PromptRemoved:Connect(function()
		self:_UpdatePromptContext()
	end)
	self.OpenChanged:Connect(function()
		Spotlight:ChangeSubject(nil)
	end)
	self.CurrentPageChanged:Connect(function()
		self:_CheckScrollDownToLoginRewards()
		self:_UpdateCanvasSize()
		self:_UpdateScale()
	end)
	self.List:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateCanvasSize()
	end)
	self.PageFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateCanvasSize()
	end)
	self.Container:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateCanvasSize()
	end)
	self.Pages.UpdateCanvasSize:Connect(function()
		self:_UpdateCanvasSize()
	end)
	UILibrary.MainGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateCanvasSize()
	end)
	UILibrary.MainGui:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateCanvasSize()
	end)
	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
		self:_UpdateSize()
	end)
	self:_Setup()
	self:_UpdateSize()
	self:_UpdateScale()
	self:_UpdateCanvasSize()
	self:_UpdatePromptContext()
end

return object._new()