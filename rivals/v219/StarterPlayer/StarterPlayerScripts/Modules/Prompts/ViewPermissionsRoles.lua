local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PermissionsLibrary = require(ReplicatedStorage.Modules.PermissionsLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local object = setmetatable({}, Prompt)
object.__index = object

function object.new(_, _)
	local self = setmetatable(Prompt.new(script.Name), object)
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.List = self.PromptFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self._description_template = self.Container:WaitForChild("Description")
	self._title_template = self.Container:WaitForChild("Title")
	self:_Init()
	return self
end

function object:_Update()
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
end

function object:_Setup()
	self._description_template.Parent = nil
	self._title_template.Parent = nil
	local v = {}

	for k in pairs(PermissionsLibrary.Roles) do
		table.insert(v, k)
	end

	table.sort(v, function(a, b)
		local teamValue = PermissionsLibrary.Teams[PermissionsLibrary.Roles[a].TeamName].TeamValue
		local teamValue2 = PermissionsLibrary.Teams[PermissionsLibrary.Roles[b].TeamName].TeamValue

		if teamValue ~= teamValue2 then
			return teamValue2 < teamValue
		end

		local roleValue = PermissionsLibrary.Roles[a].RoleValue
		local roleValue2 = PermissionsLibrary.Roles[b].RoleValue

		if roleValue == roleValue2 then
			return Utility:StringLessThan(
				PermissionsLibrary.Roles[a].DisplayName,
				PermissionsLibrary.Roles[b].DisplayName
			)
		end

		return roleValue2 < roleValue
	end)
	local v2 = tick() + 3
	local count = 0

	for _, v3 in pairs(v) do
		count += 1
		local role = PermissionsLibrary.Roles[v3]
		local clone = self._title_template:Clone()
		clone.Text = role.DisplayName
		clone.TextColor3 = role.Color
		clone.LayoutOrder = count
		clone.Parent = self.Container

		for _, permissionName in pairs(role.PermissionNames) do
			count += 1
			local permission = PermissionsLibrary.Permissions[permissionName]
			local clone2 = self._description_template:Clone()
			clone2.Container.Guide.Text = " • " .. permission.DisplayName .. " — " .. permission.Description
			clone2.Description.Text = clone2.Container.Guide.Text
			clone2.LayoutOrder = count
			clone2.Parent = self.Container

			local function update()
				local v5 = math.ceil(clone2.Container.Guide.TextBounds.X / clone2.Description.AbsoluteSize.X)
				local v6 = v5 > 5 and tick() < v2 and 1 or v5
				clone2.Size = UDim2.new(0.975, 0, v6 * 0.04, 0)
			end

			clone2.Container.Guide:GetPropertyChangedSignal("TextBounds"):Connect(update)
			clone2.Description:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
			update()
		end
	end
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_Update()
	end)
	self:_Setup()
	self:_Update()
	ButtonEffect:Add(self.CloseButton)
end

return object