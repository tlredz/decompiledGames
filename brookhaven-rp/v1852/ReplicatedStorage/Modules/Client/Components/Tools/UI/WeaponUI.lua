local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Input = require(ReplicatedStorage.Packages.Input)
local Signal = require(ReplicatedStorage.Packages.Signal)
local preferredInput = Input.PreferredInput
local touch = Input.Touch
local v = Component.new({
	Tag = "WeaponUI"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._touch = self._Janitor:Add(touch.new())
	self.MobileFired = self._Janitor:Add(Signal.new())
	self._mobileFireDown = false
	self._heldInputObject = nil
end

function v:Start()
	local openWeaponUI = self.Instance:WaitForChild("AnimationButton"):WaitForChild("MainOpen"):WaitForChild("OpenWeaponUI")
	local scrollingFrame = PanelController.GetPanel("NoResetGUIHandler", "GunWeaponMenu"):GetInstance():WaitForChild("Catalog"):WaitForChild("Container"):WaitForChild("ScrollingFrame")
	local fire = self.Instance:WaitForChild("Frame"):WaitForChild("Delete"):WaitForChild("Fire")
	self._Janitor:Add(openWeaponUI.Activated:connect(function()
		scrollingFrame.CanvasSize = UDim2.fromOffset(0, scrollingFrame.UIGridLayout.AbsoluteContentSize.Y)
		self:ClearCheckMarksGunSkins()
		PanelController.OpenPanelByContext("NoResetGUIHandler", "GunWeaponMenu")
	end))
	self._Janitor:Add(fire.InputBegan:Connect(function(heldInputObject)
		if heldInputObject.UserInputType == Enum.UserInputType.Touch and heldInputObject.UserInputState == Enum.UserInputState.Begin then
			self._mobileFireDown = true
			self._heldInputObject = heldInputObject
		end
	end))
	self._Janitor:Add(fire.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch and input.UserInputState == Enum.UserInputState.End then
			self._mobileFireDown = false
			self._heldInputObject = nil
		end
	end))
	self._Janitor:Add(fire.Activated:Connect(function()
		self.MobileFired:Fire()
	end))
	self._Janitor:Add(preferredInput.Observe(function(p: string)
		fire.Visible = p == "Touch"
		fire.Active = p == "Touch"
	end))
	self._Janitor:Add(self._touch.TouchEnded:Connect(function(otherPart)
		if otherPart == self._heldInputObject then
			self._mobileFireDown = false
			self._heldInputObject = nil
		end
	end))
end

function v:ClearCheckMarksGunSkins()
	for _, child in PanelController.GetPanel("NoResetGUIHandler", "GunSkinsMenu"):GetInstance().Catalog.Container.Skins:GetChildren() do
		if child:isA("ImageButton") then
			child.GreenCheckMark.Visible = false
		end
	end
end

function v:IsMobileFireDown()
	return self._mobileFireDown
end

function v:Stop()
	self._Janitor:Destroy()
end

return v