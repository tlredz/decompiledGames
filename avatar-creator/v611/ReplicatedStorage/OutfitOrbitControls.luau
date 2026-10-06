local OutfitOrbitControls = {
	new = function(callback)
		local v = {
			yaw = 0,
			pitch = 0,
			zoom = 1,
			points = {},
			order = {}
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function emit()
			callback(v.yaw, v.pitch, v.zoom)
		end

		function v:Begin(p2, p3)
			if self.points[p2] or #self.order >= 2 then
				return
			end

			self.points[p2] = p3
			table.insert(self.order, p2)
		end

		function v:Move(p, p2)
			local point = self.points[p]

			if not point then
				return
			end

			if #self.order == 2 then
				local v2 = self.order[1]
				local v3 = self.order[2]
				local magnitude = (self.points[v2] - self.points[v3]).Magnitude
				self.points[p] = p2
				local magnitude2 = (self.points[v2] - self.points[v3]).Magnitude

				if magnitude >= 8 and magnitude2 >= 8 then
					self.zoom = math.clamp(self.zoom * magnitude / magnitude2, 0.45, 2.5)
					emit() -- equivalent call inferred; original call site unknown
				end
			else
				self.points[p] = p2
				local v2 = p2 - point
				self.yaw = (self.yaw + v2.X * 0.012) % 6.283185307179586
				self.pitch = math.clamp(self.pitch + v2.Y * 0.01, -1.15, 1.15)
				emit() -- equivalent call inferred; original call site unknown
			end
		end

		function v:End(p2)
			self.points[p2] = nil
			local index = table.find(self.order, p2)

			if index then
				table.remove(self.order, index)
			end
		end

		function v:Cancel()
			self.points = {}
			self.order = {}
		end

		function v:Wheel(p2)
			self.zoom = math.clamp(self.zoom * math.exp(-p2 * 0.12), 0.45, 2.5)
			emit() -- equivalent call inferred; original call site unknown
		end

		return v
	end
}

function OutfitOrbitControls:Bind(p)
	local UserInputService = game:GetService("UserInputService")
	local v = OutfitOrbitControls.new(p)
	local connections = {}
	local active = self.Active
	self.Active = true

	local function bind(object, p2)
		table.insert(connections, object:Connect(p2))
	end

	local function point(input)
		return Vector2.new(input.Position.X, input.Position.Y)
	end

	table.insert(connections, self.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			v:Begin("mouse", point(input))
		elseif input.UserInputType == Enum.UserInputType.Touch then
			v:Begin(input, point(input))
		end
	end))
	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			v:Move("mouse", point(input))
		elseif input.UserInputType == Enum.UserInputType.Touch then
			v:Move(input, point(input))
		end
	end))
	table.insert(connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			v:End("mouse")
		elseif input.UserInputType == Enum.UserInputType.Touch then
			v:End(input)
		end
	end))
	table.insert(connections, self.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			v:Wheel(input.Position.Z)
		end
	end))
	table.insert(connections, UserInputService.WindowFocusReleased:Connect(function()
		v:Cancel()
	end))
	table.insert(connections, self:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		v:Cancel()
	end))
	return function()
		v:Cancel()

		for _, connection in connections do
			connection:Disconnect()
		end

		self.Active = active
	end
end

return OutfitOrbitControls