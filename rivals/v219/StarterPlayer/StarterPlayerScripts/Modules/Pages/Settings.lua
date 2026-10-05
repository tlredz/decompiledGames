local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.SettingsInfo)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local SettingsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SettingsController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local Profiles = require(script:WaitForChild("Profiles"))
local Inspect = require(script:WaitForChild("Inspect"))
local List = require(script:WaitForChild("List"))
local Tabs = require(script:WaitForChild("Tabs"))
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.Container = self.PageFrame:WaitForChild("Container")
	self.CloseButton = self.Container:WaitForChild("Close")
	self.HidePartyDisplay = true
	self.CurrentPage = nil
	self.Profiles = Profiles.new(self)
	self.Inspect = Inspect.new(self)
	self.Tabs = Tabs.new(self)
	self.List = List.new(self)
	self._open_animation_disabled = true
	self:_Init()
	return self
end

function object:SetPage(currentPage)
	self.CurrentPage = currentPage
	self.Tabs:SetPage(self.CurrentPage)
	self.List:SetPage(self.CurrentPage)
	self.Inspect:SetPage(self.CurrentPage)
	self.Profiles:SetPage(self.CurrentPage)
end

function object.Open(p, ...)
	Page.Open(p, ...)
	p.Inspect:Open()
	p.Profiles:Open()
end

function object.Close(p, ...)
	p.List:Close()
	p.Inspect:Close()
	Page.Close(p, ...)
end

function object:_VerifyPage()
	local v = ControlsController.CurrentControls == "Touch"

	if v and self.CurrentPage == "Hotkeys" then
		self:SetPage("Touch")
	elseif not v and self.CurrentPage == "Touch" then
		self:SetPage("Hotkeys")
	end
end

function object:_UpdateSize()
	self.Container.Size = UDim2.new(1, 0, 1, -GuiService.TopbarInset.Height)
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.List.ResetSettings:Connect(function()
		SettingsController:DefaultSettings(self.CurrentPage)
	end)
	self.List.Hovered:Connect(function(p)
		self.Inspect:Inspect(p.SettingsInfo)
	end)
	self.Tabs.Clicked:Connect(function(p)
		self:SetPage(p)
	end)
	self.Profiles.Clicked:Connect(function(p)
		if p == PlayerDataController:Get("SettingsProfile") then
			return
		end

		self.Inspect:Inspect(nil)
		SettingsController:SwitchSettingsProfile(p)
	end)
	ControlsController.ControlsChanged:Connect(function()
		self:_VerifyPage()
	end)
	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
		self:_UpdateSize()
	end)
	self:_UpdateSize()
	self:SetPage("Audio")
	ButtonEffect:Add(self.CloseButton)
end

return object._new()