local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Charm)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local assets = script.Parent.Assets
local v3 = { "UI_NameLayoutOrder", "UI_ResizeYWithUILayout" }

local function create(data)
	local holder = data.Holder
	local root = data.Root
	local readonly = data.Readonly
	local parent = holder.Parent
	assert(parent and parent:IsA("ScrollingFrame"), "DataViewer holder must be parented to a ScrollingFrame")
	local maid = v2.new()
	local folder = Instance.new("Folder")
	folder.Name = "VirtualRows"
	folder.Parent = holder
	maid:Add(folder)
	local automaticSize = holder.AutomaticSize
	local size = holder.Size
	holder.AutomaticSize = Enum.AutomaticSize.None
	maid:Add(function()
		if holder.Parent then
			holder.AutomaticSize = automaticSize
			holder.Size = size
		end
	end)
	local v4 = {}

	local function acquire(instance)
		local v5 = v4[instance]
		local v6 = v5 and table.remove(v5)

		if v6 then
			v6.Visible = true
			return v6
		end

		local clone = instance:Clone()

		for _, tag in v3 do
			if CollectionService:HasTag(clone, tag) then
				CollectionService:RemoveTag(clone, tag)
			end
		end

		for _, instance2 in clone:GetDescendants() do
			for _, tag in v3 do
				if CollectionService:HasTag(instance2, tag) then
					CollectionService:RemoveTag(instance2, tag)
				end
			end
		end

		clone.AnchorPoint = Vector2.zero
		clone.Visible = true
		clone.Parent = folder
		return clone
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function release(template, slot)
		slot.Visible = false
		local v5 = v4[template]

		if not v5 then
			v5 = {}
			v4[template] = v5
		end

		table.insert(v5, slot)
	end

	local flag = true
	local v5 = true

	-- equivalent calls inferred from this helper; original call sites unknown
	local function markStructureDirty()
		flag = true
		v5 = true
	end

	local function markRenderDirty()
		v5 = true
	end

	local function bindStatus(property, parent2, delete, addingFrame, removingFrame)
		local maid2 = v2.new()
		delete.Active = not readonly
		delete.Visible = not readonly
		maid2:Add(v.effect(function()
			local status = property.Status()
			delete.Text = status == -1 and "+" or "X"
			removingFrame.Visible = status == -1
			addingFrame.Visible = status == 1
		end))
		maid2:Add(delete.Activated:Connect(function()
			if readonly then
				return
			end

			if property._initialStatus == 1 then
				property.Status(-1)

				if parent2 then
					parent2.Value(function(p)
						p[property._key] = nil
						return p
					end)
				end

				data.RequestUpdate()
				markStructureDirty() -- equivalent call inferred; original call site unknown
			else
				property.Status(function(p)
					if p == -1 then
						return property._initialStatus or 0
					end

					return -1
				end)
				data.RequestUpdate()
			end
		end))
		return maid2
	end

	local function bindLeaf(p, data2)
		local property = p.Property
		local maid2 = v2.new()
		data2.Title.Text = tostring(property.Name)
		local visible = type(v.untracked(property.Value)) == "boolean"
		data2.ToggleBox.Visible = visible
		data2.TextBox.Visible = not visible

		if visible then
			maid2:Add(v.effect(function()
				local value = property.Value()
				data2.ToggleBox.Button.BackgroundTransparency = value and 0 or 1
				data2.ToggleBox.Button.ImageTransparency = value and 0 or 1
			end))
			data2.ToggleBox.Button.Active = not readonly
			maid2:Add(data2.ToggleBox.Button.Activated:Connect(function()
				if readonly then
					return
				end

				property.Value(function(p2)
					return not p2
				end)
				data.RequestUpdate()
			end))
		else
			maid2:Add(v.effect(function()
				data2.TextBox.Text = tostring(property.Value())
			end))
			data2.TextBox.TextEditable = not readonly
			maid2:Add(data2.TextBox.FocusLost:Connect(function()
				if readonly then
					return
				end

				if type(v.untracked(property.Value)) == "number" then
					property.Value(tonumber(data2.TextBox.Text) or 0)
				else
					property.Value(data2.TextBox.Text)
				end

				data.RequestUpdate()
			end))
		end

		maid2:Add((bindStatus(property, p.Parent, data2.Delete, data2.AddingFrame, data2.RemovingFrame)))
		return function()
			maid2:Destroy()
		end
	end

	local function bindTable(p, data2)
		local property = p.Property
		local maid2 = v2.new()
		data2.Top.Title.Text = tostring(property.Name)
		data2.Content.Visible = false
		maid2:Add(v.effect(function()
			data2.Top.Drop.Image = property.Collapsed() and "rbxassetid://11965723580" or "rbxassetid://11962873301"
		end))
		maid2:Add(data2.Activated:Connect(function()
			local userExpanded = not v.untracked(property.Collapsed)
			property._userExpanded = userExpanded
			property.Collapsed(userExpanded)
			markStructureDirty() -- equivalent call inferred; original call site unknown
		end))
		maid2:Add((bindStatus(property, p.Parent, data2.Top.Delete, data2.Top.AddingFrame, data2.Top.RemovingFrame)))
		return function()
			maid2:Destroy()
		end
	end

	local function bindWrite(p, p2)
		local property = p.Property
		local maid2 = v2.new()
		local text2 = property._isArray and "#array" or ""
		p2.IndexFrame.IndexBox.Text = text2
		p2.ValueFrame.ValueBox.Text = ""
		local atom = v.atom("string")
		local atom2 = v.atom(false)
		maid2:Add(v.effect(function()
			local text = atom()
			local v8 = atom2()
			p2.ValueFrame.ValueBox.Visible = text == "string" or text == "number"
			p2.ValueFrame.PropertyTypes.CurrentButton.Text = text
			p2.ValueFrame.PropertyTypes.ClipsDescendants = not v8
			p2.ValueFrame.PropertyTypes.Drop.Image = v8 and "rbxassetid://11965723580" or "rbxassetid://11962873301"
		end))

		for _, v7 in {
			"boolean",
			"number",
			"string",
			"table"
		} do
			local v8 = v7
			maid2:Add(p2.ValueFrame.PropertyTypes.Areas[v7].Activated:Connect(function()
				atom(v8)
				atom2(false)
			end))
		end

		maid2:Add(p2.ValueFrame.PropertyTypes.CurrentButton.Activated:Connect(function()
			atom2(function(p3)
				return not p3
			end)
		end))
		maid2:Add(p2.IndexFrame.Add.Activated:Connect(function()
			local text = p2.IndexFrame.IndexBox.Text

			if text == "#array" then
				local count = 0

				for _ in v.untracked(property.Value), nil, nil do
					count += 1
				end

				text = count + 1
			end

			property._addChild(text, data.ParseValue(atom(), p2.ValueFrame.ValueBox.Text))
			atom("string")
			atom2(false)
			p2.IndexFrame.IndexBox.Text = text2
			p2.ValueFrame.ValueBox.Text = ""
			data.RequestUpdate()
			markStructureDirty() -- equivalent call inferred; original call site unknown
		end))
		return function()
			maid2:Destroy()
		end
	end

	local v6 = {
		Leaf = assets.TemplateProperty,
		Table = assets.TemplateTable,
		Write = assets.TableContents
	}
	local v7 = {
		Leaf = bindLeaf,
		Table = bindTable,
		Write = bindWrite
	}
	local v8 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function destroyRendered(k: number)
		local v9 = v8[k]

		if not v9 then
			return
		end

		v8[k] = nil
		xpcall(v9.Destroy, function(p)
			task.spawn(error, debug.traceback(p, 2))
		end)
		release(v9.Template, v9.Slot) -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function destroyAllRendered()
		for k in v8 do
			destroyRendered(k) -- equivalent call inferred; original call site unknown
		end
	end

	local v9 = {}
	local v10 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function childRank(p)
		if type(v.untracked(p.Value)) == "table" then
			return 3
		end

		if v.untracked(p.Status) == 1 then
			return 1
		end

		return 2
	end

	local function sortedChildren(p)
		local result = {}

		for _, v11 in v.untracked(p.Value), nil, nil do
			table.insert(result, v.untracked(v11))
		end

		if p._isArray then
			table.sort(result, function(a, b)
				return (tonumber(a.Name) or 0) < (tonumber(b.Name) or 0)
			end)
			return result
		end

		table.sort(result, function(a, b)
			local v11 = childRank(a) -- equivalent call inferred; original call site unknown
			local v12 = childRank(b) -- equivalent call inferred; original call site unknown

			if v11 == v12 then
				return tostring(a.Name) < tostring(b.Name)
			end

			return v11 < v12
		end)
		return result
	end

	local function rebuildRows()
		destroyAllRendered() -- equivalent call inferred; original call site unknown
		table.clear(v9)
		local total = 0
		local walk

		walk = function(p, depth: number)
			if not readonly then
				table.insert(v9, {
					Property = p,
					Parent = p,
					Kind = "Write",
					Depth = depth,
					Y = total,
					Height = 23
				})
				total += 23
			end

			for _, property in sortedChildren(p) do
				if v.untracked(property.Hidden) then
					continue
				end

				local v12 = type(v.untracked(property.Value)) == "table"
				local height = v12 and 24 or 23
				table.insert(v9, {
					Property = property,
					Parent = p,
					Kind = v12 and "Table" or "Leaf",
					Depth = depth,
					Y = total,
					Height = height
				})
				total += height

				if v12 and v.untracked(property.Collapsed) then
					walk(property, depth + 1)
				end
			end
		end

		walk(root(), 0)
		v10 = total
		holder.Size = UDim2.new(size.X.Scale, size.X.Offset, 0, v10)
		flag = false
	end

	local function firstRowEndingAtOrAfter(p: number)
		local count = #v9
		local v11 = #v9 + 1
		local v12 = 1

		while v12 <= count do
			local v13 = (v12 + count) // 2
			local v14 = v9[v13]

			if p <= v14.Y + v14.Height then
				count = v13 - 1
				v11 = v13
			else
				v12 = v13 + 1
			end
		end

		return v11
	end

	local function render()
		if flag then
			rebuildRows()
		end

		if #v9 == 0 then
			destroyAllRendered() -- equivalent call inferred; original call site unknown
		else
			local Y = parent.CanvasPosition.Y
			local v11 = Y - 92
			local v12 = Y + parent.AbsoluteWindowSize.Y + 92

			for k in v8 do
				local v13 = v9[k]

				if not (not v13 or v12 < v13.Y or v13.Y + v13.Height < v11) then
					continue
				end

				destroyRendered(k) -- equivalent call inferred; original call site unknown
			end

			for i = firstRowEndingAtOrAfter(v11), #v9 do
				local v13 = v9[i]

				if v12 < v13.Y then
					break
				end

				local v14 = v8[i]

				if not v14 then
					local template = v6[v13.Kind]
					local slot = acquire(template)
					v14 = {
						Slot = slot,
						Template = template,
						Destroy = v7[v13.Kind](v13, slot)
					}
					v8[i] = v14
				end

				local v15 = v13.Depth * 12
				v14.Slot.Position = UDim2.fromOffset(v15, v13.Y)
				v14.Slot.Size = UDim2.new(1, -v15, 0, v13.Height)
			end
		end
	end

	local v11 = false
	maid:Add(RunService.PreRender:Connect(function()
		if not v5 then
			return
		end

		v5 = false
		debug.profilebegin("DataViewer::VirtualRender")
		local v12, v13 = xpcall(render, debug.traceback)
		debug.profileend()

		if not (v12 or v11) then
			v11 = true
			warn((`[DataViewer] virtual render failed (further errors suppressed):\n{v13}`))
		end
	end))

	for _, propertyName in {
		"CanvasPosition",
		"AbsoluteWindowSize",
		"AbsoluteSize",
		"Visible"
	} do
		maid:Add(parent:GetPropertyChangedSignal(propertyName):Connect(markRenderDirty))
	end

	maid:Add(function()
		destroyAllRendered() -- equivalent call inferred; original call site unknown
		table.clear(v4)
		table.clear(v9)
	end)
	return {
		Invalidate = markStructureDirty,
		Destroy = function()
			maid:Destroy()
		end
	}
end

return create