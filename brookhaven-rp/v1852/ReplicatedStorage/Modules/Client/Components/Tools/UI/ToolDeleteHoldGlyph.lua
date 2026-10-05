local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Radial = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Radial)
local ToolRoot = require(ReplicatedStorage.Modules.Client.Components.Tools.ToolRoot)
local ConsoleControlsConstructGate = require(ReplicatedStorage.Modules.Client.Components.UI.Console.ConsoleControlsConstructGate)
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = Component.new({
	Tag = "ToolDeleteHoldGlyph",
	Extensions = { ConsoleControlsConstructGate }
})

function v:Construct()
	self._janitor = Janitor.new()
	self._characterJanitor = Janitor.new()
	self._janitor:Add(self._characterJanitor)
	self._rootJanitor = Janitor.new()
	self._janitor:Add(self._rootJanitor)
	self._radial = nil
	self._uiScale = nil
	self._scaleTween = nil
	self._isActive = false
	self._isDpadNavigationEnabled = false
	self._toolBindToken = 0

	if self.Instance:GetAttribute("ConsoleGlyphKeyCode") == nil then
		self.Instance:SetAttribute("ConsoleGlyphKeyCode", "ButtonB")
	end

	if not self.Instance:HasTag("ConsoleGlyphImage") then
		self.Instance:AddTag("ConsoleGlyphImage")
	end

	if not self.Instance:HasTag("Radial") then
		self.Instance:AddTag("Radial")
	end

	task.spawn(function()
		local v2, isDpadNavigationEnabled = ABTest.GetExperimentVariable("console-controls", "dpadNavigation"):timeout(7):await()

		if v2 and typeof(isDpadNavigationEnabled) == "boolean" then
			self._isDpadNavigationEnabled = isDpadNavigationEnabled
		end
	end)
end

function v:_applyProgress(p: number)
	if self._radial ~= nil then
		self._radial:SetProgress(p)
	end

	local isActive = p > 0

	if isActive ~= self._isActive then
		self._isActive = isActive
		self:_applyScale(isActive)
	end
end

function v:_trackRoot(object2)
	self._rootJanitor:Add(object2.HoldDeleteProgressChanged:Connect(function(p: number)
		self:_applyProgress(p)
	end))
	self:_applyProgress((object2:GetHoldDeleteProgress()))
end

function v:_handleToolUnequipped()
	self._rootJanitor:Cleanup()
	self._toolBindToken += 1
	self:_applyProgress(0)
end

function v:_handleToolEquipped(p)
	self._rootJanitor:Cleanup()
	self._toolBindToken += 1
	local _toolBindToken = self._toolBindToken
	self:_applyProgress(0)
	task.spawn(function()
		local component = ComponentUtil.GetComponentFromInstance(p, ToolRoot, 5)

		if _toolBindToken ~= self._toolBindToken or component == nil or (p.Parent == nil or Players:GetPlayerFromCharacter(p.Parent) ~= Players.LocalPlayer) then
			return
		end

		self:_trackRoot(component)
	end)
end

function v:_bindToCharacter(instance)
	self._characterJanitor:Cleanup()
	self:_handleToolUnequipped()
	self._characterJanitor:Add(instance.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") then
			self:_handleToolEquipped(tool)
		end
	end))
	self._characterJanitor:Add(instance.ChildRemoved:Connect(function(tool)
		if tool:IsA("Tool") then
			self:_handleToolUnequipped()
		end
	end))
	local tool = instance:FindFirstChildOfClass("Tool")

	if tool ~= nil then
		self:_handleToolEquipped(tool)
	end
end

function v:_applyScale(flag: boolean)
	local _uiScale = self._uiScale

	if _uiScale == nil then
		return
	end

	if self._scaleTween ~= nil then
		self._scaleTween:Cancel()
	end

	self._scaleTween = TweenService:Create(_uiScale, tweenInfo, {
		Scale = flag and 1.2 or 1
	})
	self._scaleTween:Play()
end

function v:Start()
	self._radial = ComponentUtil.GetComponentFromInstance(self.Instance, Radial, 5)
	local uiScale = self.Instance:FindFirstChildOfClass("UIScale")

	if uiScale == nil then
		uiScale = Instance.new("UIScale")
		uiScale.Name = "ToolDeleteHoldGlyphScale"
		uiScale.Scale = 1
		uiScale.Parent = self.Instance
		self._janitor:Add(uiScale)
	end

	self._uiScale = uiScale
	self._janitor:Add(Players.LocalPlayer.CharacterAdded:Connect(function(character)
		self:_bindToCharacter(character)
	end))
	self._janitor:Add(Players.LocalPlayer.CharacterRemoving:Connect(function()
		self._characterJanitor:Cleanup()
		self:_handleToolUnequipped()
	end))
	local character = Players.LocalPlayer.Character

	if character ~= nil then
		self:_bindToCharacter(character)
	end
end

function v:Stop()
	if self._scaleTween ~= nil then
		self._scaleTween:Cancel()
		self._scaleTween = nil
	end

	self._janitor:Destroy()

	if self._radial ~= nil then
		self._radial:SetProgress(0)
		self._radial = nil
	end

	self._uiScale = nil
	self._isActive = false
end

return v