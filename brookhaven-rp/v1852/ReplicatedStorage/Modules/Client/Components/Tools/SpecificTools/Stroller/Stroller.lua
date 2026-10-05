local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "Stroller",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self._tracks = {}
	self._animationDebounce = false
	self._fallbackTrickValue = 1
	self.tool = self.Instance
	self.trickValue = nil
	self.gui = nil
	self.animationButton = nil
	self.noBabyButton = nil
	self.deleteButton = nil
	self.numberLabel = nil
	self._isEquipped = false
end

function v:GetCurrentTrickValue()
	if self.trickValue == nil then
		return self._fallbackTrickValue
	end

	return self.trickValue.Value
end

function v:SetCurrentTrickValue(fallbackTrickValue: number)
	if self.trickValue == nil then
		self._fallbackTrickValue = fallbackTrickValue
	else
		self.trickValue.Value = fallbackTrickValue
	end
end

function v:SetAnimationLabel(p2: number)
	if self.numberLabel ~= nil then
		self.numberLabel.Text = tostring(p2)
	end
end

function v:StopAnimations()
	for _, _track in self._tracks do
		if _track.IsPlaying then
			_track:Stop()
		end
	end
end

function v:PlayCurrentAnimation()
	local currentTrickValue = self:GetCurrentTrickValue()

	if currentTrickValue ~= 1 and currentTrickValue ~= 2 and currentTrickValue ~= 3 then
		currentTrickValue = 1
		self:SetCurrentTrickValue(currentTrickValue)
	end

	local _track = self._tracks[currentTrickValue]

	if _track == nil then
		return
	end

	if _track.IsPlaying == false then
		self:StopAnimations()
		_track:Play()
	else
		_track:Stop()
	end

	self:SetAnimationLabel(currentTrickValue)
end

function v:CycleAnimation()
	if self._animationDebounce == true then
		return
	end

	self._animationDebounce = true
	local currentTrickValue = self:GetCurrentTrickValue()
	local v2

	if currentTrickValue == 3 then
		v2 = 1
	elseif currentTrickValue == 1 then
		v2 = 2
	elseif currentTrickValue == 2 then
		v2 = 3
	else
		v2 = 1
	end

	local _track = self._tracks[v2]

	if _track ~= nil then
		if _track.IsPlaying then
			_track:Stop()
		else
			self:StopAnimations()
			_track:Play()
			self:SetCurrentTrickValue(v2)
			self:SetAnimationLabel(v2)
		end
	end

	task.delay(0.2, function()
		self._animationDebounce = false
	end)
end

function v:LoadAnimations(instance)
	table.clear(self._tracks)
	local animator = instance:FindFirstChildOfClass("Animator")

	if animator == nil then
		return
	end

	local idle1Anim = self.tool:FindFirstChild("Idle1Anim")

	if idle1Anim ~= nil and idle1Anim:IsA("Animation") then
		self._tracks[1] = animator:LoadAnimation(idle1Anim)
	end

	local idle2Anim = self.tool:FindFirstChild("Idle2Anim")

	if idle2Anim ~= nil and idle2Anim:IsA("Animation") then
		self._tracks[2] = animator:LoadAnimation(idle2Anim)
	end

	local idle3Anim = self.tool:FindFirstChild("Idle3Anim")

	if idle3Anim ~= nil and idle3Anim:IsA("Animation") then
		self._tracks[3] = animator:LoadAnimation(idle3Anim)
	end
end

function v:ResolveTrickValue()
	self.trickValue = nil
	local trickBool = self.tool:FindFirstChild("TrickBool", true)

	if trickBool ~= nil and (trickBool:IsA("IntValue") or trickBool:IsA("NumberValue")) then
		self.trickValue = trickBool
		self._fallbackTrickValue = trickBool.Value
	end
end

function v:ResolveGuiReferences()
	local gui = self.gui
	self.gui = nil
	self.animationButton = nil
	self.noBabyButton = nil
	self.deleteButton = nil
	self.numberLabel = nil
	local gunGUI = self.tool:FindFirstChild("GunGUI", true)

	if gunGUI == nil or not gunGUI:IsA("ScreenGui") then
		if gui ~= nil then
			self.gui = gui
		end
	else
		self.gui = gunGUI
		local animationButton = gunGUI:FindFirstChild("AnimationButton")
		local mainOpen

		if animationButton ~= nil then
			mainOpen = animationButton:FindFirstChild("MainOpen")
		end

		local open

		if mainOpen ~= nil then
			open = mainOpen:FindFirstChild("Open")
		end

		if open ~= nil and open:IsA("GuiButton") then
			self.animationButton = open
			local number = open:FindFirstChild("Number")

			if number ~= nil and number:IsA("TextLabel") then
				self.numberLabel = number
			end

			local noBaby = open:FindFirstChild("NoBaby")

			if noBaby ~= nil and noBaby:IsA("GuiButton") then
				self.noBabyButton = noBaby
			end
		end

		local frame = gunGUI:FindFirstChild("Frame")

		if frame ~= nil then
			local delete = frame:FindFirstChild("Delete")

			if delete ~= nil and delete:IsA("GuiButton") then
				self.deleteButton = delete
			end
		end
	end
end

function v:BindActions()
	ContextActionService:UnbindAction("StrollerCycleAnimation")
	ContextActionService:BindAction("StrollerCycleAnimation", function(p: string, p2)
		if not (p == "StrollerCycleAnimation" and p2 == Enum.UserInputState.Begin) then
			return
		end

		self:CycleAnimation()
	end, false, Enum.KeyCode.F, Enum.KeyCode.ButtonX)
	self._equipJanitor:Add(function()
		ContextActionService:UnbindAction("StrollerCycleAnimation")
	end)
end

function v:OnEquipped()
	if self._isEquipped == true then
		return
	end

	self._equipJanitor:Cleanup()
	local localPlayer = Players.LocalPlayer
	local parent = self.tool.Parent

	if not (parent ~= nil and parent:IsA("Model") and localPlayer.Character == parent) then
		return
	end

	local humanoid = parent:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		return
	end

	self._isEquipped = true
	self:ResolveTrickValue()
	self:LoadAnimations(humanoid)
	self:ResolveGuiReferences()
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if self.gui ~= nil and playerGui ~= nil then
		self.gui.Parent = playerGui
	end

	self:BindActions()
	self:PlayCurrentAnimation()

	if self.animationButton ~= nil then
		self._equipJanitor:Add(self.animationButton.MouseButton1Click:Connect(function()
			self:CycleAnimation()
		end))
	end

	if self.deleteButton ~= nil then
		self._equipJanitor:Add(self.deleteButton.MouseButton1Click:Connect(function()
			Remotes.fireServerComponent(self.tool, "QuickDelete")
		end))
	end

	if self.noBabyButton ~= nil then
		self._equipJanitor:Add(self.noBabyButton.MouseButton1Click:Connect(function()
			Remotes.fireServerComponent(self.tool, "ToggleBaby")
		end))
	end

	self._equipJanitor:Add(humanoid.Died:Connect(function()
		self:OnUnequipped()
	end))
end

function v:OnUnequipped()
	self._isEquipped = false
	self._equipJanitor:Cleanup()
	self:StopAnimations()

	if self.gui ~= nil then
		self.gui.Parent = self.tool
	end
end

function v:Start()
	self._Janitor:Add(self.tool.Equipped:Connect(function()
		self:OnEquipped()
	end))
	self._Janitor:Add(self.tool.Unequipped:Connect(function()
		self:OnUnequipped()
	end))

	if Players.LocalPlayer.Character ~= nil and self.tool.Parent == Players.LocalPlayer.Character then
		self:OnEquipped()
	end
end

function v:Stop()
	self:OnUnequipped()
	self._equipJanitor:Destroy()
	self._Janitor:Destroy()
end

return v