local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local PrivateServerConstants = require(ReplicatedStorage.Modules.Shared.PrivateServer.PrivateServerConstants)
require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local v = Component.new({
	Tag = "PropsPlayersTab"
})
local UIToggle = require(ReplicatedStorage.Modules.Client.UI.Utils.UIToggle)
local PSPlayerListItem = require(ReplicatedStorage.Modules.Client.UI.PrivateServer.PSPlayerListItem)
local PrivateServerControlsPanel = require(ReplicatedStorage.Modules.Client.UI.PrivateServer.PrivateServerControlsPanel)

function v:Construct()
	self._Janitor = Janitor.new()
	self.playersMap = {}
	self.adminList = {}
end

function v:UpdateTabTitle()
	local count = 0

	for _ in pairs(self.playersMap) do
		count += 1
	end

	self.tabTitle.Text = `Props/Players ({count})`
end

function v:AddPlayer(p)
	local clone = self.playerItemPrefab:Clone()
	clone.Parent = self.playersList
	clone.Visible = true
	local component = ComponentUtil.GetComponentFromInstance(clone, PSPlayerListItem)
	component:Init(p, self)
	self.playersMap[p.UserId] = component

	if self.adminList[`{p.UserId}`] then
		component:SetAdmin(self.adminList[`{p.UserId}`])
	end
end

function v:SetAdmin(p2, flag: boolean)
	self.adminList[`{p2.UserId}`] = flag
	Remotes.fireServerComponent(self.Instance, "SetAdmin", p2, flag)
end

function v.LockPlayerProps(p, p2, flag: boolean)
	Remotes.fireServerComponent(p.Instance, "LockPlayerProps", p2, flag)
end

function v:KickPlayer(p2)
	self.panelRef:KickPlayer(p2, function(p3)
		if p3 then
			Remotes.fireServerComponent(self.Instance, "KickPlayer", p2)
		end
	end)
end

function v:BanPlayer(p2)
	self.panelRef:BanPlayer(p2, function(p3)
		if p3 then
			Remotes.fireServerComponent(self.Instance, "BanPlayer", p2)
		end
	end)
end

function v:UpdateCanvasSize()
	self.playersList.CanvasSize = UDim2.new(0, 0, 0, self.UIListLayout.AbsoluteContentSize.Y)
	self.playersList.AutomaticCanvasSize = Enum.AutomaticSize.Y
end

function v:Start()
	self.panelRef = ComponentUtil.FindComponentByAncestor(
		self.Instance,
		"PrivateServerControlsPanel",
		PrivateServerControlsPanel
	)
	local bottomMenu = self.Instance:WaitForChild("BottomMenu")
	local removeProps = bottomMenu:WaitForChild("RemoveProps")
	self.tabTitle = self.Instance.Parent.Parent:WaitForChild("Top"):WaitForChild("TabsMenu"):WaitForChild("List"):WaitForChild("PropsPlayers"):WaitForChild("ItemName")
	self.playersList = self.Instance:WaitForChild("PlayersList")
	self.UIListLayout = self.playersList:WaitForChild("UIListLayout")
	self._Janitor:Add(removeProps.Activated:Connect(function()
		self.panelRef:RemoveAllProps(PrivateServerConstants.Notification.PropsClearConfirmation, function(p)
			if p then
				Remotes.fireServerComponent(self.Instance, "ClearProps")
			end
		end)
	end))
	local propOwners = bottomMenu:WaitForChild("PropOwners")
	local component = ComponentUtil.GetComponentFromInstance(propOwners, UIToggle)
	self._Janitor:Add(component.onToggle:Connect(function(_)
		Remotes.fireServerComponent(self.Instance, "ShowPropOwners", component:isOn())
	end))
	local lockProps = bottomMenu:WaitForChild("LockProps")
	local component2 = ComponentUtil.GetComponentFromInstance(lockProps, UIToggle)
	self._Janitor:Add(component2.onToggle:Connect(function(_)
		Remotes.fireServerComponent(self.Instance, "LockProps", component2:isOn())
	end))
	self.playerItemPrefab = self.Instance:WaitForChild("PlayersList"):WaitForChild("prefab")
	self.playerItemPrefab.Visible = false

	for _, v2 in Players:GetPlayers() do
		self:AddPlayer(v2)
	end

	self:UpdateCanvasSize()
	self._Janitor:Add(Players.PlayerAdded:Connect(function(player)
		self:AddPlayer(player)
		self:UpdateTabTitle()
		self:UpdateCanvasSize()
	end))
	self._Janitor:Add(Players.PlayerRemoving:Connect(function(player)
		if self.playersMap[player.UserId] and self.playersMap[player.UserId].Instance ~= nil then
			self.playersMap[player.UserId].Instance:Destroy()
		end

		self.playersMap[player.UserId] = nil
		self:UpdateTabTitle()
		self:UpdateCanvasSize()
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "UpdateAdminList", function(adminList)
		self.adminList = adminList

		for k, v2 in pairs(adminList) do
			local v3 = tonumber(k)

			if v3 and self.playersMap[v3] then
				self.playersMap[v3]:SetAdmin(v2)
			end
		end
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "UpdateLockedAllProps", function(items)
		for k, item in pairs(items) do
			local v2 = tonumber(k)

			if v2 and self.playersMap[v2] then
				self.playersMap[v2]:SetLockProps(item)
			end
		end
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(
		self.Instance,
		"UpdateLockedPlayerProps",
		function(p: number, flag: boolean)
			if not self.playersMap[p] then
				return
			end

			self.playersMap[p]:SetLockProps(flag)
		end
	))
	self:UpdateTabTitle()
	Remotes.fireServerComponent(self.Instance, "RequestAdminList")
	Remotes.fireServerComponent(self.Instance, "RequestLockedProps")
end

function v:Stop()
	self._Janitor:Destroy()
end

return v