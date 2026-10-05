local object = setmetatable({}, {
	__mode = "k"
})
return {
	bind = function(self, instance2)
		if object[instance2] then
			return
		end

		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = self.Name .. "_" .. instance2.Name .. "_Edges"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.ScreenInsets = Enum.ScreenInsets.None
		screenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
		screenGui.ClipToDeviceSafeArea = false
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Enabled = false
		local v = {}

		for _, name in {
			"Top",
			"Bottom",
			"Left",
			"Right"
		} do
			local frame = Instance.new("Frame")
			frame.Name = name
			frame.BorderSizePixel = 0
			frame.Active = false
			frame.Parent = screenGui
			v[name] = frame
		end

		local connections = {}
		local v2 = true
		object[instance2] = screenGui
		self.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None

		local function sync()
			if not v2 then
				return
			end

			if screenGui.Parent ~= self.Parent then
				screenGui.Parent = self.Parent
			end

			screenGui.DisplayOrder = self.DisplayOrder - 1
			local visible = self.Enabled and instance2.Visible
			local parent = instance2.Parent

			while parent and parent ~= self do
				if parent:IsA("GuiObject") and not parent.Visible then
					visible = false
				end

				parent = parent.Parent
			end

			screenGui.Enabled = visible and parent == self
			local absoluteSize = screenGui.AbsoluteSize
			local v3 = instance2.AbsolutePosition - screenGui.AbsolutePosition
			local v4 = math.clamp(v3.X, 0, absoluteSize.X)
			local v5 = math.clamp(v3.Y, 0, absoluteSize.Y)
			local v6 = math.clamp(v3.X + instance2.AbsoluteSize.X, v4, absoluteSize.X)
			local v7 = math.clamp(v3.Y + instance2.AbsoluteSize.Y, v5, absoluteSize.Y)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function rect(p, p2, p3, p4, p5)
				p.Position = UDim2.fromOffset(p2, p3)
				p.Size = UDim2.fromOffset(p4, p5)
				p.BackgroundColor3 = instance2.BackgroundColor3
				p.BackgroundTransparency = instance2.BackgroundTransparency
			end

			rect(v.Top, 0, 0, absoluteSize.X, v5) -- equivalent call inferred; original call site unknown
			rect(v.Bottom, 0, v7, absoluteSize.X, absoluteSize.Y - v7) -- equivalent call inferred; original call site unknown
			rect(v.Left, 0, v5, v4, v7 - v5) -- equivalent call inferred; original call site unknown
			rect(v.Right, v6, v5, absoluteSize.X - v6, v7 - v5) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function watch(instance3, propertyName)
			table.insert(connections, instance3:GetPropertyChangedSignal(propertyName):Connect(sync))
		end

		for _, v3 in {
			"Visible",
			"AbsolutePosition",
			"AbsoluteSize",
			"BackgroundColor3",
			"BackgroundTransparency"
		} do
			watch(instance2, v3) -- equivalent call inferred; original call site unknown
		end

		for _, v3 in {
			"Enabled",
			"DisplayOrder",
			"AbsolutePosition",
			"AbsoluteSize"
		} do
			watch(self, v3) -- equivalent call inferred; original call site unknown
		end

		watch(screenGui, "AbsoluteSize") -- equivalent call inferred; original call site unknown
		watch(screenGui, "AbsolutePosition") -- equivalent call inferred; original call site unknown
		table.insert(connections, self.AncestryChanged:Connect(sync))
		local parent = instance2.Parent

		while parent and parent ~= self do
			if parent:IsA("GuiObject") then
				watch(parent, "Visible") -- equivalent call inferred; original call site unknown
			end

			parent = parent.Parent
		end

		local function destroy()
			if not v2 then
				return
			end

			v2 = false
			object[instance2] = nil

			for _, connection in connections do
				connection:Disconnect()
			end

			screenGui:Destroy()
		end

		table.insert(connections, instance2.Destroying:Connect(destroy))
		table.insert(connections, self.Destroying:Connect(destroy))
		sync()
		return screenGui
	end
}