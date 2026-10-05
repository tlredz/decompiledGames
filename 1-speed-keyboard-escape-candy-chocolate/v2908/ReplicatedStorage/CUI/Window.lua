local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local maid = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("maid"))
require(script.Parent.Types)
local color = Color3.new(1, 1, 1)
local WindowUI = require(script.Parent:WaitForChild("WindowUI"))

local function escapeRichText(_Title: string)
	return _Title:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub("'", "&apos;")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateTitle(data)
	local hex = data._IndicatorColor:ToHex()
	data.UI.Topbar.Title.Text = `<font color="#{hex}">◙</font> {escapeRichText(data._Title)}`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerGuis()
	local localPlayer = Players.LocalPlayer
	assert(localPlayer, "CUI.GetWindow can only be used on the client")
	return localPlayer:WaitForChild("PlayerGui")
end

return function(p)
	local class = {}
	class.__index = class
	p.Window = class

	function class.new(p2: string)
		local object = setmetatable({}, class)
		object.ID = p2
		object._Destroyed = false
		object.ScreenGui = Instance.new("ScreenGui")
		object.UI = WindowUI()
		object.UI.Visible = false
		object.Ctn = p.CreateComponentContainer(object.UI.Content)
		object._maid = maid.new()
		object._Title = p2
		object._IndicatorColor = color
		object.ScreenGui.Name = HttpService:GenerateGUID(false)
		object.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		object.ScreenGui.ResetOnSpawn = false
		object.ScreenGui.IgnoreGuiInset = true
		object.ScreenGui.ScreenInsets = Enum.ScreenInsets.None
		object.ScreenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
		object.ScreenGui.ClipToDeviceSafeArea = false
		object.ScreenGui.DisplayOrder = 10000
		local screenGui = object.ScreenGui
		screenGui.Parent = getPlayerGuis()
		object:Setup()
		object:SetMinimize(false)
		updateTitle(object) -- equivalent call inferred; original call site unknown
		object.UI.Parent = object.ScreenGui
		object.Ctn.Components:AddBox(function(p3)
			object.Components = p3.Components
		end)
		object.Ctn.OnUpdateHeight:Connect(function()
			object:UpdateHeight()
		end)
		return object
	end

	function class:Setup()
		local v = nil
		self._maid:GiveTask(function()
			if v then
				v:Destroy()
				v = nil
			end
		end)
		self._maid:GiveTask(self.ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			self:UpdateScale()
		end))
		self:UpdateScale()
		self._maid:GiveTask(self.UI.Topbar.Buttons.Minimize.Interactibility.MouseButton1Click:Connect(function()
			self:SetMinimize(not self:IsMinimized())
		end))
		self._maid:GiveTask(self.UI.Topbar.Buttons.Close.Interactibility.MouseButton1Click:Connect(function()
			self:SetVisible(false)
		end))
		self._maid:GiveTask(self.UI.Topbar.Interactibility.InputBegan:Connect(function(input)
			local userInputType = input.UserInputType

			if userInputType ~= Enum.UserInputType.MouseButton1 and userInputType ~= Enum.UserInputType.Touch then
				return
			end

			if v then
				v:Destroy()
			end

			local maid2 = maid.new()
			v = maid2
			local vector = Vector2.new(input.Position.X, input.Position.Y)
			local vector2 = Vector2.new(self.UI.Position.X.Offset, self.UI.Position.Y.Offset)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function finishDrag()
				if v == maid2 then
					v = nil
				end

				maid2:Destroy()
			end

			maid2:GiveTask(UserInputService.InputChanged:Connect(function(input2)
				local v2

				if userInputType == Enum.UserInputType.Touch then
					v2 = input2 == input
				else
					v2 = input2.UserInputType == Enum.UserInputType.MouseMovement
				end

				if not v2 then
					return
				end

				local v3 = Vector2.new(input2.Position.X, input2.Position.Y) - vector
				self:SetPosition(vector2.X + v3.X, vector2.Y + v3.Y)
			end))
			maid2:GiveTask(UserInputService.InputEnded:Connect(function(input2)
				local v2

				if userInputType == Enum.UserInputType.Touch then
					v2 = input2 == input
				else
					v2 = input2.UserInputType == Enum.UserInputType.MouseButton1
				end

				if v2 then
					finishDrag() -- equivalent call inferred; original call site unknown
				end
			end))
			self:BumpDisplayOrder()
		end))
		self._maid:GiveTask(self.UI.Interactibility.MouseButton1Click:Connect(function()
			self:BumpDisplayOrder()
		end))
		self._maid:GiveTask(self.UI.Topbar.Interactibility.MouseEnter:Connect(function()
			self.UI.Topbar.WhiteOff.BackgroundTransparency = 0.95
		end))
		self._maid:GiveTask(self.UI.Topbar.Interactibility.MouseLeave:Connect(function()
			self.UI.Topbar.WhiteOff.BackgroundTransparency = 1
		end))

		for _, guiObject in self.UI.Content:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		self.UI.Position = UDim2.new(0.5, -self.UI.Size.X.Offset / 2, 0.5, -self.UI.Size.Y.Offset / 2)
	end

	function class:SetTitle(p2)
		self._Title = tostring(p2)
		updateTitle(self) -- equivalent call inferred; original call site unknown
		return self
	end

	function class:SetIndicatorColor(indicatorColor: Color3)
		self._IndicatorColor = indicatorColor
		updateTitle(self) -- equivalent call inferred; original call site unknown
		return self
	end

	function class:UpdateHeight()
		if self._Destroyed then
			return self
		end

		local componentsHeight = self.Ctn.Components:GetComponentsHeight()
		self.UI.Size = UDim2.new(0, self.UI.Size.X.Offset, 0, componentsHeight)
		return self
	end

	function class:UpdateScale()
		if self._Destroyed then
			return self
		end

		local Y = self.ScreenGui.AbsoluteSize.Y
		local v = Y <= 0 and 600 or Y
		self.UI.UIScale.Scale = math.clamp(v / 600, 0.75, 1)
		return self
	end

	function class:SetPosition(value: number, value2: number)
		local absoluteSize = self.ScreenGui.AbsoluteSize

		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			self.UI.Position = UDim2.fromOffset(value, value2)
			return self
		end

		local scale = self.UI.UIScale.Scale
		local v = Vector2.new(self.UI.Size.X.Offset, self.UI.Size.Y.Offset + 24) * scale
		local v2 = math.clamp(value, 0, (math.max(absoluteSize.X - v.X, 0)))
		local v3 = math.clamp(value2, 24 * scale, absoluteSize.Y)
		self.UI.Position = UDim2.fromOffset(v2, v3)
		return self
	end

	function class:SetPositionWithAnchor(p2: number, p3: number, point: Vector2)
		local scale = self.UI.UIScale.Scale
		return self:SetPosition(
			p2 - point.X * self.UI.Size.X.Offset * scale,
			p3 - point.Y * self.UI.Size.Y.Offset * scale
		)
	end

	function class:GetPosition()
		return Vector2.new(self.UI.Position.X.Offset, self.UI.Position.Y.Offset)
	end

	function class:GetPositionWithAnchor(point: Vector2)
		local position = self:GetPosition()
		local scale = self.UI.UIScale.Scale
		return Vector2.new(
			position.X + point.X * self.UI.Size.X.Offset * scale,
			position.Y + point.Y * self.UI.Size.Y.Offset * scale
		)
	end

	function class.GetSize(p2)
		return Vector2.new(p2.UI.Size.X.Offset, p2.UI.Size.Y.Offset) * p2.UI.UIScale.Scale
	end

	function class.GetScreenSize(p2)
		return p2.ScreenGui.AbsoluteSize
	end

	function class.IsVisible(p2)
		return p2.UI.Visible
	end

	function class:SetVisible(visible: boolean)
		if self.UI.Visible == visible then
			return self
		end

		self.UI.Visible = visible

		if visible then
			self:UpdateHeight()
			self:BumpDisplayOrder()
		end

		return self
	end

	function class:IsMinimized()
		return not self.UI.Content.Visible
	end

	function class:SetMinimize(flag: boolean)
		self.UI.Content.Visible = not flag
		self.UI.Content.Interactable = not flag
		self.UI.Interactibility.Visible = not flag
		self.UI.Topbar.Buttons.Minimize.TextLabel.Text = flag and "+" or "-"

		if not flag then
			self:UpdateHeight()
		end

		return self
	end

	function class:Destroy()
		if self._Destroyed then
			return self
		end

		self._Destroyed = true

		if self._OnDestroy then
			self._OnDestroy(self)
		end

		self._maid:Destroy()
		self.Ctn:Destroy()
		self.UI:Destroy()
		self.ScreenGui:Destroy()
		return self
	end

	function class.GetXSize(p2)
		return p2.UI.Size.X.Offset
	end

	function class.SetXSize(p2, p3: number)
		p2.UI.Size = UDim2.new(0, p3, 0, p2.UI.Size.Y.Offset)
		return p2
	end

	function class.SetCloseButtonVisible(p2, visible: boolean)
		p2.UI.Topbar.Buttons.Close.Visible = visible
		return p2
	end

	function class:BumpDisplayOrder()
		local localPlayer = Players.LocalPlayer
		assert(localPlayer, "CUI.GetWindow can only be used on the client")
		local displayOrder = 1

		for _, screenGui in localPlayer:WaitForChild("PlayerGui"):GetChildren() do
			if screenGui:IsA("ScreenGui") and screenGui.DisplayOrder < 100000000 then
				displayOrder = math.max(displayOrder, screenGui.DisplayOrder + 1)
			end
		end

		self.ScreenGui.DisplayOrder = displayOrder
		return self
	end

	return class
end