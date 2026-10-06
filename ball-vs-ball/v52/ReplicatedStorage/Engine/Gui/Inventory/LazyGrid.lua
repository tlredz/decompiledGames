local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
return {
	new = function(parent, instance, data)
		local v = assert(parent:FindFirstChildOfClass("UIGridLayout"))
		local uIPadding = parent:FindFirstChildOfClass("UIPadding")
		local v2 = {
			entries = {},
			records = {},
			spares = {},
			pools = {},
			dirty = true
		}
		local template = nil
		local v4 = parent == instance
		parent:SetAttribute("InventoryVirtualGrid", true)
		parent:SetAttribute("NavigationColumns", 3)
		v.Parent = nil

		if uIPadding then
			uIPadding.Parent = nil
		end

		parent.AutomaticSize = Enum.AutomaticSize.None

		if v4 then
			parent.AutomaticCanvasSize = Enum.AutomaticSize.None
		end

		local function release(record, p)
			data.assign(record.cell, nil)

			if record.visual then
				local visual = record.visual
				visual.Visible = false
				visual.Parent = nil
				local visuals = v2.pools[record.template]

				if not visuals then
					visuals = {}
					v2.pools[record.template] = visuals
				end

				if #visuals < 24 then
					table.insert(visuals, visual)
				else
					visual:Destroy()
				end

				record.visual = nil
			end

			record.cell.Visible = false

			if not p then
				table.insert(v2.spares, record)
			end
		end

		local function geometry()
			local parent2 = parent
			local scale = 1

			while parent2 do
				local uIScale = parent2:FindFirstChildOfClass("UIScale")

				if uIScale then
					scale *= uIScale.Scale
				end

				parent2 = parent2.Parent
			end

			if scale <= 0 then
				return
			end

			local v6

			if v4 then
				v6 = instance.AbsoluteWindowSize.X
			else
				v6 = parent.AbsoluteSize.X
			end

			local v7 = v6 / scale
			local v8 = instance.AbsoluteWindowSize.Y / scale

			if v7 <= 0 or v8 <= 0 then
				return
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function px(p, p2)
				return p.Scale * p2 + p.Offset
			end

			local v9

			if uIPadding then
				v9 = px(uIPadding.PaddingLeft, v7)
			else
				v9 = 0
			end

			local v10

			if uIPadding then
				v10 = px(uIPadding.PaddingRight, v7)
			else
				v10 = 0
			end

			local v11

			if uIPadding then
				v11 = px(uIPadding.PaddingTop, v8)
			else
				v11 = 0
			end

			local v12

			if uIPadding then
				v12 = px(uIPadding.PaddingBottom, v8)
			else
				v12 = 0
			end

			local v13 = px(v.CellSize.X, v7) -- equivalent call inferred; original call site unknown
			local v14 = px(v.CellSize.Y, v8) -- equivalent call inferred; original call site unknown
			local layoutTemplate = data.layoutTemplate or template
			local uIAspectRatioConstraint = layoutTemplate and layoutTemplate:FindFirstChildOfClass("UIAspectRatioConstraint")

			if uIAspectRatioConstraint then
				v14 = v13 / uIAspectRatioConstraint.AspectRatio
			end

			if v13 <= 0 or v14 <= 0 then
				return
			end

			local dx = px(v.CellPadding.X, v7) -- equivalent call inferred; original call site unknown
			local dy = px(v.CellPadding.Y, v8) -- equivalent call inferred; original call site unknown
			local columns = math.max(
				1,
				(math.min(
					v.FillDirectionMaxCells > 0 and v.FillDirectionMaxCells or 1e999,
					(math.floor((v7 - v9 - v10 + dx) / (v13 + dx) + 0.001))
				))
			)
			local v18 = columns * v13 + (columns - 1) * dx

			if v.HorizontalAlignment == Enum.HorizontalAlignment.Center then
				v9 += (v7 - v9 - v10 - v18) / 2
			elseif v.HorizontalAlignment == Enum.HorizontalAlignment.Right then
				v9 += v7 - v9 - v10 - v18
			end

			return {
				scale = scale,
				w = v13,
				h = v14,
				dx = dx,
				dy = dy,
				columns = columns,
				x = v9,
				t = v11,
				b = v12
			}
		end

		function v2:Set(p2, entries)
			if template ~= p2 then
				for _, record in self.records do
					release(record)
				end

				self.records = {}
			end

			template = p2
			self.entries = entries

			for _, record in self.records do
				data.assign(record.cell, record.entry)
			end

			self.dirty = true
		end

		function v2:Invalidate()
			self.dirty = true
		end

		function v2:Update()
			if not self.dirty then
				return
			end

			self.dirty = false

			if data.active() and parent.Visible then
				local v5 = geometry()

				if not v5 then
					self.dirty = true
					return
				end

				local v6 = math.ceil(#self.entries / v5.columns)
				local v7 = v5.t + math.max(0, v6 * (v5.h + v5.dy) - v5.dy) + v5.b

				if v4 then
					parent.CanvasSize = UDim2.fromOffset(0, v7 + (not (v6 > 0) and 0 or v5.h + v5.dy))
				else
					parent.Size = UDim2.new(parent.Size.X.Scale, parent.Size.X.Offset, 0, v7)
				end

				parent:SetAttribute("NavigationColumns", v5.columns)
				local v8 = (instance.AbsolutePosition.Y - parent.AbsolutePosition.Y) / v5.scale

				if v4 then
					v8 = instance.CanvasPosition.Y / v5.scale
				end

				local v9 = instance.AbsoluteWindowSize.Y / v5.scale
				local v10 = math.max(0, math.floor((v8 - v5.t) / (v5.h + v5.dy)) - 1)
				local v11 = math.min(v6 - 1, math.floor((v8 + v9 - v5.t) / (v5.h + v5.dy)) + 1)
				local v12 = {}

				for i = v10 * v5.columns + 1, math.min(#self.entries, (v11 + 1) * v5.columns) do
					v12[i] = true
				end

				local v13 = false

				for k, record in self.records do
					if v12[k] then
						continue
					end

					if GuiService.SelectedObject == record.cell then
						GuiService.SelectedObject = nil
					end

					release(record)
					self.records[k] = nil
					v13 = true
				end

				for i = v10 * v5.columns + 1, math.min(#self.entries, (v11 + 1) * v5.columns) do
					local entry = self.entries[i]
					local record = self.records[i]

					if not record then
						record = table.remove(self.spares)

						if not record then
							local textButton = Instance.new("TextButton")
							textButton.Text = ""
							textButton.BackgroundTransparency = 1
							textButton.BorderSizePixel = 0
							textButton.AutoButtonColor = false
							textButton:SetAttribute(data.slotAttribute or "InventoryGeneratedSlot", true)
							data.bindCell(textButton)
							record = {
								cell = textButton
							}
						end

						self.records[i] = record
						v13 = true
					end

					local cell = record.cell
					local v14 = record.template ~= template or not data.equal(record.entry, entry)

					if record.template ~= template and record.visual then
						release(record, true)
					end

					record.template = template
					record.entry = entry
					cell.Name = "格子" .. i
					cell.LayoutOrder = i
					cell:SetAttribute("InventoryNavigationKey", entry.key)
					cell.Position = UDim2.fromOffset(
						v5.x + (i - 1) % v5.columns * (v5.w + v5.dx),
						v5.t + math.floor((i - 1) / v5.columns) * (v5.h + v5.dy)
					)
					cell.Size = UDim2.fromOffset(v5.w, v5.h)
					cell.Visible = true
					cell.Parent = parent
					data.assign(cell, entry)

					if record.visual then
						if v14 then
							data.paint(record.visual, entry)
						end
					else
						local pool = self.pools[template]
						local clone = pool and table.remove(pool)

						if not clone then
							clone = template:Clone()
							clone.Name = "卡片内容"
							clone.AnchorPoint = Vector2.new(0.5, 0.5)
							clone.Position = UDim2.fromScale(0.5, 0.5)
							clone.Size = UDim2.fromScale(1, 1)
							data.bindVisual(clone)
							clone.Selectable = false
						end

						record.visual = clone
						clone.Visible = false
						data.paint(clone, entry)
						clone.Parent = cell
						clone.Visible = true
					end
				end

				if v13 and data.changed then
					data.changed()
				end
			else
				for _, record in self.records do
					release(record)
				end

				self.records = {}
			end
		end

		local connections = {}

		local function watch(instance2, propertyName)
			table.insert(connections, instance2:GetPropertyChangedSignal(propertyName):Connect(function()
				v2.dirty = true
			end))
		end

		table.insert(connections, instance:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			v2.dirty = true
		end))
		table.insert(connections, instance:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(function()
			v2.dirty = true
		end))
		table.insert(connections, parent:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			v2.dirty = true
		end))
		table.insert(connections, parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			v2.dirty = true
		end))
		table.insert(connections, parent:GetPropertyChangedSignal("Visible"):Connect(function()
			v2.dirty = true
		end))
		table.insert(connections, v:GetPropertyChangedSignal("CellSize"):Connect(function()
			v2.dirty = true
		end))
		table.insert(connections, v:GetPropertyChangedSignal("CellPadding"):Connect(function()
			v2.dirty = true
		end))
		local parent2 = parent.Parent

		while parent2 do
			if parent2:IsA("GuiObject") then
				table.insert(connections, parent2:GetPropertyChangedSignal("Visible"):Connect(function()
					v2.dirty = true
				end))
			elseif parent2:IsA("ScreenGui") then
				table.insert(connections, parent2:GetPropertyChangedSignal("Enabled"):Connect(function()
					v2.dirty = true
				end))
			end

			parent2 = parent2.Parent
		end

		table.insert(connections, RunService.RenderStepped:Connect(function()
			v2:Update()
		end))
		table.insert(connections, parent.Destroying:Connect(function()
			for _, connection in connections do
				connection:Disconnect()
			end

			for _, pool in v2.pools do
				for _, v5 in pool do
					v5:Destroy()
				end
			end

			for _, spare in v2.spares do
				spare.cell:Destroy()
			end

			v:Destroy()

			if uIPadding then
				uIPadding:Destroy()
			end
		end))
		return v2
	end
}