local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local Promise = require(ReplicatedStorage.Packages.Promise)
local v = Component.new({
	Tag = "PSPlayerListItem"
})
local color = Color3.fromRGB(233, 96, 107)
local color2 = Color3.fromRGB(85, 85, 85)
local UIToggle = require(ReplicatedStorage.Modules.Client.UI.Utils.UIToggle)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(_) end

function v:Init(player, tabRef)
	self.player = player
	self.tabRef = tabRef
	self.playerIcon = self.Instance:WaitForChild("PlayerIcon")
	self.kickButton = self.Instance:WaitForChild("Kick")
	self.banButton = self.Instance:WaitForChild("Ban")
	local name = self.Instance:WaitForChild("Name")
	local longName = name:WaitForChild("LongName")
	local userName = name:WaitForChild("UserName")
	local admin = self.Instance:WaitForChild("Admin")
	local propsLock = self.Instance:WaitForChild("PropsLock")
	longName.Text = player.DisplayName
	userName.Text = `@{player.Name}`
	self._Janitor:Add(self.kickButton.Activated:Connect(function()
		self.tabRef:KickPlayer(player)
	end))
	self._Janitor:AddPromise(Promise.new(function(callback, callback2, _)
		local userThumbnailAsync, v2 = Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size60x60
		)

		if v2 then
			callback(userThumbnailAsync)
		else
			callback2()
		end
	end):timeout(3):andThen(function(image)
		self.playerIcon.Image = image
	end, function()
		self.playerIcon.Image = ""
	end))
	local component = ComponentUtil.GetComponentFromInstance(propsLock, UIToggle)
	self.lockPropsCheckmark = propsLock:WaitForChild("Toggle"):WaitForChild("Checkmark")
	self._Janitor:Add(component.onToggle:Connect(function(_)
		self.tabRef:LockPlayerProps(player, component:isOn())
	end))
	self.adminToggle = ComponentUtil.GetComponentFromInstance(admin, UIToggle)

	if GameUtil.IsPrivateServerOwner() then
		admin.Visible = true

		if player == Players.LocalPlayer then
			self.adminToggle:SetInteractable(false)
		end

		self._Janitor:Add(self.adminToggle.onToggle:Connect(function(_)
			self.tabRef:SetAdmin(player, self.adminToggle:isOn())
		end))
		self.adminCheckmark = admin:WaitForChild("Toggle"):WaitForChild("Checkmark")
		self.adminCheckmark.Visible = player == Players.LocalPlayer
		self.banButton.Visible = true
		self._Janitor:Add(self.banButton.Activated:Connect(function()
			self.tabRef:BanPlayer(player)
		end))
	else
		admin.Visible = false
		self.banButton.Visible = false
	end

	if GameUtil.IsPrivateServerOwner(player) then
		component:SetInteractable(false)
		self.adminToggle:SetInteractable(false)
	end
end

function v:DisableKickAndBan(flag: boolean)
	if flag then
		self.kickButton.BackgroundColor3 = color2
		self.banButton.BackgroundColor3 = color2
		self.kickButton.Interactable = false
		self.banButton.Interactable = false
	else
		self.kickButton.BackgroundColor3 = color
		self.banButton.BackgroundColor3 = color
		self.kickButton.Interactable = true
		self.banButton.Interactable = true
	end
end

function v:SetAdmin(visible: boolean)
	if self.adminCheckmark then
		self.adminCheckmark.Visible = visible
	end

	self:DisableKickAndBan(visible)
end

function v.SetLockProps(p, flag: boolean)
	if p.lockPropsCheckmark then
		p.lockPropsCheckmark.Visible = not flag
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v