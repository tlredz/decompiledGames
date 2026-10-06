local module = require("@game/ReplicatedStorage/Omni")
local vector = Vector2.new(137, 43)
local fusion = module.Libs.Fusion
local scope = fusion.scoped(fusion)
local value = scope:Value(Vector2.new(0, 0))
local spring = scope:Spring(value, 40, 1)
local currentCamera = workspace.CurrentCamera
local dropdown = module.Inset:WaitForChild("Dropdown")
local list = dropdown:WaitForChild("List")
local scroll = list:WaitForChild("Scroll")
local clone = dropdown:WaitForChild("Option"):Clone()
dropdown:WaitForChild("Option"):Destroy()
local v = {
	Update = function(self)
		if self.Holder and not self.Holder:IsDescendantOf(game) then
			self:Stop()
			return
		end

		if not self.Holder then
			value:set(Vector2.new(0, 0))
			return
		end

		if not self.Options then
			return
		end

		local v2 = #self.Options
		local viewportSize = currentCamera.ViewportSize
		local absolutePosition = self.Holder.AbsolutePosition
		local absoluteSize = self.Holder.AbsoluteSize
		local uDim = UDim2.fromOffset(
			absolutePosition.X + absoluteSize.X / 2,
			absolutePosition.Y + absoluteSize.Y * 1.05
		)
		local v3 = math.min(
			viewportSize.X / module.Settings.ReferenceSize.X,
			viewportSize.Y / module.Settings.ReferenceSize.Y
		)
		local v4 = v3 * vector.X
		local v5 = v3 * vector.Y
		local v6 = v5 * math.min(v2, 3)
		local uDim2 = UDim2.fromOffset(v4 * list.Size.X.Scale, v5)

		for _, template in self.Templates do
			local visible

			if self.Monitor then
				visible = self.Monitor(template.Name) or false
			else
				visible = false
			end

			template.Size = uDim2
			template.Main.List.SelectedIcon.Visible = visible
		end

		dropdown.Position = uDim
		value:set(Vector2.new(v4, v6))
	end
}

function v:Start(holder, callback, options, monitor)
	if self.Holder then
		self:Stop()
		return
	end

	self.Holder = holder
	self.Options = options
	self.Monitor = monitor
	self.Callback = callback
	self.HolderConnection = holder.Destroying:Connect(function()
		self:Stop()
	end)

	if self.Templates then
		for _, template in self.Templates do
			template:Destroy()
		end

		table.clear(self.Templates)
	else
		self.Templates = {}
	end

	for k, option in self.Options do
		local clone2 = clone:Clone()
		clone2.Name = option.Name
		clone2.Main.List.Title.Text = option.Name
		clone2.Main.List.Icon.Image = option.Icon or ""
		clone2.Main.List.Icon.Visible = clone2.Main.List.Icon.Image ~= ""
		local v3 = option
		module.Button:Create(clone2.Main, "Small"):BindFunction("Click", function()
			if self.Holder ~= holder or not (clone2.Parent and holder:IsDescendantOf(game)) then
				return
			end

			if self.Callback then
				self.Callback(v3.ID or v3.Name)
			end
		end)
		clone2.Size = UDim2.fromScale(0, 0)
		clone2.LayoutOrder = k
		clone2.Parent = scroll
		clone2.Visible = true
		self.Templates[k] = clone2
	end

	v:Update()
end

function v:Stop()
	if self.HolderConnection then
		self.HolderConnection:Disconnect()
		self.HolderConnection = nil
	end

	self.Holder = nil
	self.Callback = nil
	self.Monitor = nil
	self.Options = nil
	self:Update()
end

currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	v:Update()
end)
scope:Observer(spring):onBind(function()
	local currentSpring = scope.peek(spring)

	if not currentSpring then
		return
	end

	dropdown.Size = UDim2.fromOffset(currentSpring.X, currentSpring.Y)
	scroll.Size = UDim2.fromOffset(currentSpring.X * list.Size.X.Scale, currentSpring.Y)
	dropdown.Visible = currentSpring.X >= 0 and currentSpring.Y >= 0
end)
local Dropdown = {}

function Dropdown.Open(_, data)
	if typeof(data) ~= "table" or (typeof(data.Holder) ~= "Instance" or not data.Holder:IsA("GuiObject")) then
		return
	end

	if not (typeof(data.Callback) == "function" and typeof(data.Options) == "table") then
		return
	end

	local v2 = {}

	for i, option in ipairs(data.Options) do
		if not (typeof(option) == "table" and typeof(option.Name) == "string") then
			continue
		end

		local v3 = {
			Name = option.Name,
			Icon = 0,
			ID = 0
		}
		local icon

		if typeof(option.Icon) == "string" then
			icon = option.Icon or nil
		end

		v3.Icon = icon
		local ID

		if typeof(option.ID) == "string" then
			ID = option.ID or nil
		end

		v3.ID = ID
		v2[i] = v3
	end

	if #v2 == 0 then
		return
	end

	local holder = data.Holder
	local callback = data.Callback
	local v4

	if typeof(data.Monitor) == "function" then
		v4 = data.Monitor or nil
	end

	v:Start(holder, callback, v2, v4)
end

function Dropdown:Update()
	v:Update()
end

function Dropdown.Close(_)
	v:Stop()
end

return Dropdown