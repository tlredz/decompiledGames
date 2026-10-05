local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local FamilyController = require(ReplicatedStorage.Modules.Client.UI.Family.FamilyController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local BackActionRouter = require(ReplicatedStorage.Modules.Client.UI.BackActionRouter)
local LeaveFamily = require(script.Parent.LeaveFamily)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Input = require(ReplicatedStorage.Packages.Input)
local preferredInput = Input.PreferredInput
local v = Component.new({
	Tag = "FamilyInvited"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._activeGuid = nil
	self._unbindBackAction = nil
end

function v:UnbindBackAction()
	if not self._unbindBackAction then
		return
	end

	self._unbindBackAction()
	self._unbindBackAction = nil
end

function v:SetupHideInvitesButton()
	if FamilyController.AreInvitesHidden() then
		self.Instance.HideInvites.Box:AddTag("Checked")
	else
		self.Instance.HideInvites.Box:RemoveTag("Checked")
	end
end

function v:Start()
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function declineInvite()
		if flag then
			flag = false
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		end

		Remotes.fireServer("FamilyInviteDeclined", self._activeGuid)
		self.Instance.Visible = false
		self._activeGuid = nil
		self:UnbindBackAction()
	end

	self._Janitor:Add(Remotes.connect("FamilyInviteReceived", function(p)
		if FamilyController.AreInvitesHidden() or self._activeGuid then
			return
		end

		self._activeGuid = p.inviteGuid
		self.Instance.Username.Text = p.sender.Name
		self.Instance.PlayerIcon.Image = `rbxthumb://type=AvatarHeadShot&id={p.sender.UserId}&w=150&h=150`
		self.Instance.Visible = true
		self:UnbindBackAction()
		self._unbindBackAction = BackActionRouter.Bind(function()
			declineInvite() -- equivalent call inferred; original call site unknown
		end, function()
			return self.Instance.Visible and self._activeGuid ~= nil
		end)

		if preferredInput.Current == "Gamepad" and not flag then
			flag = true
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		end
	end))
	self._Janitor:Add(self.Instance.InteractButtons.Yes.Activated:Connect(function()
		if flag then
			flag = false
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		end

		local maid = self._Janitor:AddObject(Janitor, "Destroy")
		local familyState = FamilyController.GetFamilyState()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function accept()
			Remotes.fireServer("FamilyInviteAccepted", self._activeGuid)
			self.Instance.Visible = false
			self._activeGuid = nil
			self:UnbindBackAction()
			maid:Destroy()
		end

		if familyState and #familyState > 1 then
			local component = ComponentUtil.GetComponentFromInstance(
				self.Instance.Parent.Parent.LeaveFamily,
				LeaveFamily
			)
			maid:Add(component.Accept:Connect(accept))
			maid:Add(component.Decline:Connect(function()
				maid:Destroy()
			end))
			PanelController.ToggleGroup("FamilyPrompts", false)
			PanelController.OpenPanelByContext("MainGUIHandler", "LeaveFamily")
		else
			accept() -- equivalent call inferred; original call site unknown
		end
	end))
	self._Janitor:Add(self.Instance.InteractButtons.No.Activated:Connect(declineInvite))
	self._Janitor:Add(self.Instance.HideInvites.Box.Activated:Connect(function()
		FamilyController.ToggleHideInvites()
	end))
	self:SetupHideInvitesButton()
	FamilyController.HideInvitesChanged:Connect(function()
		self:SetupHideInvitesButton()
	end)
end

function v:Stop()
	self:UnbindBackAction()
	self._Janitor:Destroy()
end

return v