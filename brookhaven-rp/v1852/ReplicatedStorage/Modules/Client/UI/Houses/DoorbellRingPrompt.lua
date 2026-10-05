local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local LotController = require(ReplicatedStorage.Modules.Client.Lot.LotController)
local Input = require(ReplicatedStorage.Packages.Input)
local preferredInput = Input.PreferredInput
local v = Component.new({
	Tag = "DoorbellRingPrompt"
})
local v2 = false

function v.AreNotificationsHidden()
	return v2 == true
end

function v.ResetHiddenNotifications()
	v2 = false

	for _, v3 in v:GetAll() do
		v3:SetupHideButton()
		v3:Hide()
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._isShowing = false
	self._onYes = nil
	self._unbindBackAction = nil
	self._hasDisabledChat = false
end

function v:UnbindBackAction()
	if self._unbindBackAction == nil then
		return
	end

	self._unbindBackAction()
	self._unbindBackAction = nil
end

function v:RestoreChat()
	if self._hasDisabledChat == false then
		return
	end

	self._hasDisabledChat = false
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
end

function v:SetupHideButton()
	if v2 == true then
		self.Instance.HideInvites.Box:AddTag("Checked")
	else
		self.Instance.HideInvites.Box:RemoveTag("Checked")
	end
end

function v:Hide()
	self.Instance.Visible = false
	self._isShowing = false
	self._onYes = nil
	self:UnbindBackAction()
	self:RestoreChat()
end

function v:Show(p: number, onYes)
	if not (v2 ~= true and self._isShowing ~= true) then
		return
	end

	self._isShowing = true
	self._onYes = onYes
	local name = "Someone"
	local playerByUserId = Players:GetPlayerByUserId(p)

	if playerByUserId == nil then
		local success, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, p)

		if success == true and typeof(nameFromUserIdAsync) == "string" then
			name = nameFromUserIdAsync
		end
	else
		name = playerByUserId.Name
	end

	if self._isShowing ~= true then
		return
	end

	self.Instance.Username.Text = name
	self.Instance.PlayerIcon.Image = `rbxthumb://type=AvatarHeadShot&id={p}&w=150&h=150`
	self.Instance.Visible = true
	self:UnbindBackAction()
	self._unbindBackAction = BackActionRouter.Bind(function()
		self:Hide()
	end, function()
		return self.Instance.Visible == true and self._isShowing == true
	end)

	if preferredInput.Current == "Gamepad" and self._hasDisabledChat == false then
		self._hasDisabledChat = true
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	end
end

function v:Start()
	self.Instance.HideInvites.Label.Text = "Hide notifications"
	self:SetupHideButton()
	self._Janitor:Add(self.Instance.InteractButtons.Yes.Activated:Connect(function()
		local _onYes = self._onYes
		self:Hide()

		if _onYes ~= nil then
			_onYes()
		end
	end))
	self._Janitor:Add(self.Instance.InteractButtons.No.Activated:Connect(function()
		self:Hide()
	end))
	self._Janitor:Add(self.Instance.HideInvites.Box.Activated:Connect(function()
		if v2 == true then
			return
		end

		v2 = true
		self:SetupHideButton()
		self:Hide()
	end))
	self._Janitor:Add(LotController.PropertyChangedSignal:Connect(function()
		v.ResetHiddenNotifications()
	end))
end

function v:Stop()
	self:Hide()
	self._Janitor:Destroy()
end

return v