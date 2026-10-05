local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local GamepadService = game:GetService("GamepadService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Signal)
local v2 = require3(ReplicatedStorage2.Shared.Policy)
local v3 = require3(ReplicatedStorage2.ServerInfo)
local v4 = require3(ReplicatedStorage2.Shared.Statable)
local playerGui = Players.LocalPlayer.PlayerGui
local v5 = v.new()
local v6 = v.new()
local GuiHandler = {
	CurrentGuiChanged = v.new(),
	CurrentGuiState = v4.State()
}

local function deselectTextboxesInsideScreenGui(folder)
	if folder then
		os.clock()

		for _, textBox in folder:GetDescendants() do
			if textBox:IsA("TextBox") then
				textBox:ReleaseFocus(false)
			end
		end
	end
end

function GuiHandler:GetScreenGui(childName: string)
	local screenGui = playerGui:FindFirstChild(childName)

	if screenGui and screenGui:IsA("ScreenGui") then
		return screenGui
	end

	warn((`Could not find ScreenGui "{childName}"!`))
	return nil
end

function GuiHandler:Open(p, p2, p3)
	if v3.isAFKServer() and p ~= "AFKWorld" and p ~= "InviteRewards" or self._lockId and not p2 then
		return
	end

	local screenGui = self:GetScreenGui(p)

	if not screenGui then
		return
	end

	if self._currentGui then
		if p3 then
			self._lastGui = self._currentGui
		end

		self._currentGui.Enabled = false
		deselectTextboxesInsideScreenGui(self._currentGui)
		v6:Fire(self._currentGui)

		if self._currentGui == screenGui then
			self._currentGui = nil
			self.CurrentGuiState:Set()
			self.CurrentGuiChanged:Fire()
			return
		end
	end

	screenGui.Enabled = true
	self._currentGui = screenGui
	self.CurrentGuiChanged:Fire(p)
	self.CurrentGuiState:Set(p)
	v5:Fire(screenGui)
	return true, screenGui
end

function GuiHandler:Close(p, p2)
	if self._lockId and not p2 then
		return
	end

	if p then
		local screenGui = self:GetScreenGui(p)

		if not screenGui then
			return
		end

		if self._currentGui ~= screenGui then
			return true
		end

		screenGui.Enabled = false
		deselectTextboxesInsideScreenGui(screenGui)
		self._currentGui = nil
		self.CurrentGuiChanged:Fire()
		self.CurrentGuiState:Set()
		v6:Fire(screenGui)
		local _lastGui = self._lastGui

		if _lastGui then
			self:Open(_lastGui.Name, p2, false)
			self._lastGui = nil
		end

		return true
	else
		if not self._currentGui then
			return
		end

		self._currentGui.Enabled = false
		deselectTextboxesInsideScreenGui(self._currentGui)
		v6:Fire(self._currentGui)
		self._currentGui = nil
		self.CurrentGuiChanged:Fire()
		self.CurrentGuiState:Set()
		local _lastGui = self._lastGui

		if _lastGui then
			self:Open(_lastGui.Name, p2, false)
			self._lastGui = nil
		end

		return true
	end
end

function GuiHandler:CloseCurrent(p)
	if self._lockId and not p or not self._currentGui then
		return
	end

	if self._lockId then
		self._lockId = nil
	end

	local _currentGui = self._currentGui
	_currentGui.Enabled = false
	deselectTextboxesInsideScreenGui(_currentGui)
	v6:Fire(_currentGui)
	self._currentGui = nil
	self.CurrentGuiChanged:Fire()
	self.CurrentGuiState:Set()
end

function GuiHandler:Lock(lockId, p2)
	if self._lockId and not p2 then
		return
	end

	self._lockId = lockId
end

function GuiHandler:Unlock(p2, p3)
	if self._lockId ~= p2 and not p3 then
		return
	end

	self._lockId = nil
end

function GuiHandler.OnOpen(_, p)
	return v5:Connect(p)
end

function GuiHandler.OnClose(_, p)
	return v6:Connect(p)
end

function GuiHandler.OnGuiOpen(_, p, callback)
	return v5:Connect(function(p2)
		if not p2 or p2.Name ~= p then
			return
		end

		callback(p2)
	end)
end

function GuiHandler.OnGuiClose(_, p, callback)
	return v6:Connect(function(p2)
		if not p2 or p2.Name ~= p then
			return
		end

		callback(p2)
	end)
end

function GuiHandler:IsOpen(p2)
	local _currentGui = self._currentGui

	if _currentGui then
		return _currentGui.Name == p2
	end

	return false
end

local function update(instance)
	local policy = instance:GetAttribute("Policy")
	local policyStatus = instance:GetAttribute("PolicyStatus")

	if not (policy and policyStatus) then
		return
	end

	local policyVisibility = instance:GetAttribute("PolicyVisibility")
	local visible

	if v2:GetPolicyInfo()[policy] == policyStatus then
		visible = policyVisibility and true or false
	else
		visible = not policyVisibility
	end

	instance.Visible = visible
end

local function onPolicyDisclaimerAdded(object)
	object:GetAttributeChangedSignal("Policy"):Connect(function()
		update(object)
	end)
	update(object)
end

CollectionService:GetInstanceAddedSignal("PolicyDisclaimerFrame"):Connect(onPolicyDisclaimerAdded)

for _, v7 in ipairs(CollectionService:GetTagged("PolicyDisclaimerFrame")) do
	task.defer(onPolicyDisclaimerAdded, v7)
end

v5:Connect(function(instance)
	local guiObject = instance:FindFirstChildWhichIsA("GuiObject", true)

	if guiObject then
		GamepadService:EnableGamepadCursor(guiObject)
	end
end)
v6:Connect(function(_)
	GamepadService:DisableGamepadCursor()
end)
workspace.Alive.ChildAdded:Connect(function(child)
	local _lastGui = GuiHandler._lastGui
	local character = Players.LocalPlayer.Character

	if _lastGui and (string.find(_lastGui.Name, "Battlepass") ~= nil or _lastGui.Name == "ProfileCard") and character and Players:GetPlayerFromCharacter(child) == character then
		GuiHandler._lastGui = nil
	end
end)
return GuiHandler