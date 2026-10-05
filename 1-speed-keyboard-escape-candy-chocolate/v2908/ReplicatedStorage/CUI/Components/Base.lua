local class = {}
class.__index = class
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("maid"))
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
require(script.Parent.Parent.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function collectGuiObjects(UI)
	local descendants = UI:QueryDescendants("GuiObject")
	table.insert(descendants, UI)
	return descendants
end

local function createBase(p)
	function class.extend(componentName: string, p2: string?)
		local class2 = {}

		function class2.__index(_, p3)
			return class2[p3] or class[p3]
		end

		class2.__componentName = componentName
		class2.__templateName = p2 or componentName
		setmetatable(class2, class)

		function class2.new(p3, p4: string)
			local object = setmetatable({}, class2)
			object:_construct(p3, p4, componentName, class2.__templateName)
			local init = object.Init

			if init then
				init(object)
			end

			return object
		end

		function class2.extend(_, componentName2: string, p3: string?)
			local class3 = {}

			function class3.__index(_, p4)
				return class3[p4] or class2[p4]
			end

			class3.__componentName = componentName2
			class3.__templateName = p3 or class2.__templateName
			setmetatable(class3, {
				__index = class2
			})

			function class3.new(p4, p5: string)
				local object = setmetatable({}, class3)
				object:_construct(p4, p5, componentName2, class3.__templateName)
				local init = object.Init

				if init then
					init(object)
				end

				return object
			end

			return class3
		end

		return class2
	end

	function class:_construct(manager, ID: string, name: string, childName: string)
		local module = require(script.Parent.Parent.ComponentUIs:WaitForChild(childName))
		self.Manager = manager
		self.ID = ID
		self.OriginalUI = module()
		self.UI = self.OriginalUI:Clone()
		self.UI.Name = name
		self.UI.Visible = true
		self.AllGuiObjects = collectGuiObjects(self.UI)
		self.Task = maid.new()
		self.Destroyed = false
		self.ZOffset = 0
		self.EnabledPermission = nil
		self.PermissionRefreshConnected = false
		self.EnabledRank = nil
		self.EnabledTarget = true
		self.Enabled = true
		self.OnEnabledChanged = p.Signal.new()
		self:SetZIndex(1000 * self:GetDepth())
		p.DefineComponent(ID, self)
		self.UI.Parent = manager.ContentFrame
	end

	function class:OnCreate()
		self:UpdateEnabledDisplay()
	end

	function class:GetDepth()
		return self.Manager.Parent:GetDepth() + 1
	end

	function class:GetWidth()
		return self.Manager:GetWidth()
	end

	function class:SetZIndex(zOffset: number)
		self.ZOffset = zOffset

		for _, allGuiObject in self.AllGuiObjects do
			if allGuiObject:GetAttribute("DefaultZIndex") == nil then
				allGuiObject:SetAttribute("DefaultZIndex", allGuiObject.ZIndex)
			end

			allGuiObject.ZIndex = allGuiObject:GetAttribute("DefaultZIndex") + zOffset + self:GetMainContainer():GetZIndex()
		end

		return self
	end

	function class:UpdateZIndex()
		return self:SetZIndex(self.ZOffset)
	end

	function class:SetVisible(visible: boolean)
		if self:GetVisible() == visible then
			return self
		end

		self.UI.Visible = visible
		self:UpdateParentHeight()
		return self
	end

	function class.GetYSize(p2)
		return p2.UI.Size.Y.Offset
	end

	function class:GetVisible()
		return self.UI.Visible
	end

	function class.SetBackgroundColor(p2, backgroundColor: Color3)
		p2.UI.BackgroundColor3 = backgroundColor
		return p2
	end

	function class.GetBackgroundColor(p2)
		return p2.UI.BackgroundColor3
	end

	function class.SetBackgroundTransparency(p2, backgroundTransparency: number)
		p2.UI.BackgroundTransparency = backgroundTransparency
		return p2
	end

	function class.GetBackgroundTransparency(p2)
		return p2.UI.BackgroundTransparency
	end

	function class:UpdateParentHeight()
		self.Manager.Parent:UpdateHeight()
		return self
	end

	function class:UpdateHeight(flag: boolean?)
		if not flag then
			self:UpdateParentHeight()
		end

		return self
	end

	function class:GetMainContainer()
		return self.Manager.Parent:GetMainContainer()
	end

	function class.GetHeight(p2)
		return p2.UI.Size.Y.Offset
	end

	function class.GetUI(p2)
		return p2.UI
	end

	function class.GetID(p2)
		return p2.ID
	end

	function class.SetLayoutOrder(p2, layoutOrder: number)
		p2.UI.LayoutOrder = layoutOrder
		return p2
	end

	function class.GetLayoutOrder(p2)
		return p2.UI.LayoutOrder
	end

	function class:IsDestroyed()
		if not self.UI.Parent then
			self.Destroyed = true
		end

		return self.Destroyed
	end

	function class:Destroy()
		if self.Destroyed then
			return
		end

		self.Destroyed = true
		self:OnDestroy()
	end

	function class:OnDestroy()
		self.UI:Destroy()
		self.OriginalUI:Destroy()
		self.Task:Destroy()
		self.OnEnabledChanged:DisconnectAll()
		self.Manager:_RemoveOnly(self.ID)
		self:UpdateParentHeight()
	end

	function class:GetEnabled()
		if not self.EnabledTarget then
			return false
		end

		local localPlayer = Players.LocalPlayer

		if self.EnabledPermission == nil then
			return self.EnabledRank == nil or localPlayer ~= nil and not (AdminPermissions.getRank(localPlayer.UserId) < self.EnabledRank)
		end

		if localPlayer == nil then
			return false
		end

		local enabledPermission = self.EnabledPermission
		local v

		if type(enabledPermission) == "string" then
			v = AdminPermissions.hasPermission(localPlayer.UserId, enabledPermission)
		else
			v = AdminPermissions.hasAnyPermission(localPlayer.UserId, enabledPermission)
		end

		if v then
			return self.EnabledRank == nil or localPlayer ~= nil and not (AdminPermissions.getRank(localPlayer.UserId) < self.EnabledRank)
		end

		return false
	end

	function class:SetEnabled(enabledTarget: boolean)
		self.EnabledTarget = enabledTarget
		self:UpdateEnabled()
		return self
	end

	function class:SetEnabledPermission(enabledPermission)
		self.EnabledPermission = enabledPermission

		if not self.PermissionRefreshConnected then
			self.PermissionRefreshConnected = true
			self.Task:GiveTask(AdminPermissions.subscribeToPermissionChanges(function()
				if not self.Destroyed then
					self:UpdateEnabled()
				end
			end))
		end

		self:UpdateEnabled()
		return self
	end

	function class:SetEnabledRank(enabledRank: number)
		self.EnabledRank = enabledRank
		self:UpdateEnabled()
		return self
	end

	function class:UpdateEnabled()
		local enabled = self:GetEnabled()

		if enabled == self.Enabled then
			return self
		end

		self.Enabled = enabled
		self:UpdateEnabledDisplay()
		self.OnEnabledChanged:Fire(enabled)
		return self
	end

	function class:UpdateEnabledDisplay() end

	return class
end

return createBase