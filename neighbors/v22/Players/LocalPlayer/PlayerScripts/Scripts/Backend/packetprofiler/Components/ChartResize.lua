local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local modules = script.Parent.Parent.Modules
local Packages = require(modules.Packages)
local Roact = require(Packages.Directory.Roact)
local extended = Roact.Component:extend("ChartResize")

function extended:init()
	local binding, setSize = Roact.createBinding(UDim2.fromOffset(650, 290))
	self.Size = binding
	self.SetSize = setSize

	if not Packages.IsPlugin then
		self.Connections = {}
		local mouseIcon = UserInputService.MouseIcon
		local renderSteppedConnection = nil
		local v2 = false
		local flag = false
		local v3 = {
			SizeWE = "rbxassetid://18699453492",
			SizeNS = "rbxassetid://18700045701",
			SizeAll = "rbxassetid://18700129047"
		}

		function self.AddIcon(p)
			if flag or v2 == p then
				return
			end

			if v2 == false then
				mouseIcon = UserInputService.MouseIcon
			end

			v2 = p
			UserInputService.MouseIcon = v3[p]
		end

		function self.RemoveIcon()
			if flag or not v2 then
				return
			end

			v2 = false
			UserInputService.MouseIcon = mouseIcon
		end

		function self.SetSizeTarget(p)
			if not p then
				return
			end

			for _, connection in self.Connections do
				connection:Disconnect()
			end

			table.clear(self.Connections)
			table.insert(self.Connections, RunService.RenderStepped:Connect(function()
				local guiInset = GuiService:GetGuiInset()
				local mouseLocation = UserInputService:GetMouseLocation()
				local v4 = p.AbsolutePosition + guiInset
				local absoluteSize = p.AbsoluteSize
				local v5 = v4.Y + absoluteSize.Y + 8
				local v6 = v4.X + absoluteSize.X

				if mouseLocation.X < v4.X - 8 or v6 < mouseLocation.X or mouseLocation.Y < v4.Y or v5 < mouseLocation.Y then
					self.RemoveIcon()
					return
				end

				local Y = mouseLocation.Y
				local v7

				if v5 - 8 < Y then
					v7 = mouseLocation.Y < v5 + 8
				else
					v7 = false
				end

				local v8

				if mouseLocation.X < v4.X + 8 then
					v8 = mouseLocation.X > v4.X - 8
				else
					v8 = false
				end

				if v7 or v8 then
					self.AddIcon(v7 and (v8 and "SizeAll" or "SizeNS") or "SizeWE")
				else
					self.RemoveIcon()
				end
			end))
			table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and v2 then
					self.StartResizing()
				end
			end))
			table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					self.StopResizing()
				end
			end))
		end

		function self.StartResizing()
			if flag then
				return
			end

			flag = true
			local value = self.Size:getValue()
			local mouseLocation = UserInputService:GetMouseLocation()
			local vector = Vector2.new(mouseLocation.X, mouseLocation.Y)
			renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local v4 = UserInputService:GetMouseLocation() - vector

				if v2 == "SizeNS" then
					v4 *= Vector2.new(0, 1)
				elseif v2 == "SizeWE" then
					v4 *= Vector2.new(1, 0)
				end

				local uDim = UDim2.fromOffset(
					math.max(value.X.Offset - v4.X, 300),
					(math.max(value.Y.Offset + v4.Y, 100))
				)
				self.SetSize(uDim)
			end)
		end

		function self.StopResizing()
			if not flag then
				return
			end

			flag = false
			self.RemoveIcon()
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end
	end
end

function extended.render(data)
	return Roact.oneChild(data.props[Roact.Children])({
		UISize = data.Size,
		StartResizing = data.StartResizing,
		StopResizing = data.StopResizing,
		AddIcon = data.AddIcon,
		RemoveIcon = data.RemoveIcon,
		SetSizeTarget = data.SetSizeTarget
	})
end

function extended.willUnmount(p)
	if p.StopResizing then
		p.StopResizing()
	end

	if p.Connections then
		for _, connection in p.Connections do
			connection:Disconnect()
		end

		table.clear(p.Connections)
	end
end

local function ChartResizeInit(packetChart)
	return Roact.createElement(extended, {}, {
		PacketChart = packetChart
	})
end

return ChartResizeInit