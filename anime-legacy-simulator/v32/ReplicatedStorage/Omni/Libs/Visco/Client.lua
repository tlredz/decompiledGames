local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local assets = parent.Assets
local libs = parent.Libs
local use = assets.Events.Use
local request = assets.Events.Request
local Utils = require(parent.Utils)
local Charm = require(libs.Charm)
local Spring = require(libs.Spring)
local clone = assets.Interface:Clone()
clone.Name = "ViscoInterface"
clone.Enabled = false
clone.Parent = localPlayer.PlayerGui
local main = clone:WaitForChild("Main", 1e999)
local background = main:WaitForChild("Background", 1e999)
local title = main:WaitForChild("Title", 1e999)
local commands = main:WaitForChild("Commands", 1e999)
local results = main:WaitForChild("Results", 1e999)
local search = main:WaitForChild("Search", 1e999)
local credits = main:WaitForChild("Credits", 1e999)
local type = main:WaitForChild("Type", 1e999)
local main2 = type:WaitForChild("Main", 1e999)
local list = type:WaitForChild("List", 1e999)
local buttons = type:WaitForChild("Buttons", 1e999)
local selected = main:WaitForChild("Selected", 1e999)
local list2 = selected:WaitForChild("List", 1e999)
local buttons2 = selected:WaitForChild("Buttons", 1e999)
local position = title.Position
local position2 = search.Position
local position3 = credits.Position
local position4 = type.Position
local position5 = selected.Position
local position6 = commands.Position
local position7 = results.Position
local v = {}
local v2 = {}
local v3 = {
	Opened = {},
	Closed = {}
}
local v4 = nil
local v5 = {}
local v6 = nil
local atom = Charm.atom(false)
local atom2 = Charm.atom(true)
local Visco = {}
local v7 = {
	Initialize = function(self)
		while not v4 do
			v4 = request:InvokeServer()
			task.wait(1)
		end
	end,
	IsTextBoxSelected = function(self, p)
		return UserInputService:GetFocusedTextBox() == p
	end
}

function v7:SelectCommand(name: string)
	if not (v4 and v4.Commands[name]) then
		return
	end

	v6 = {
		Name = name,
		SelectedPath = {},
		Types = {}
	}

	for _, frame in list2:GetChildren() do
		if frame:IsA("Frame") then
			frame.Name = "__Destroy__"
		end
	end

	v7:RefreshInterface()
end

function v7:SelectType(p: number)
	if not (v4 and v6) then
		return
	end

	local command = v4.Commands[v6.Name]

	if not (command and command.Types[p]) then
		return
	end

	v6.SelectedPath = { p }

	for _, frame in list:GetChildren() do
		if frame:IsA("Frame") then
			frame.Name = "__Destroy__"
		end
	end

	v7:RefreshInterface()
end

function v7:SelectProperty(p)
	if not (v4 and v6 and #v6.SelectedPath ~= 0) then
		return
	end

	table.insert(v6.SelectedPath, p)

	for _, frame in list:GetChildren() do
		if frame:IsA("Frame") then
			frame.Name = "__Destroy__"
		end
	end

	v7:RefreshInterface()
end

function v7:FlattenPath(items)
	local result = {}

	for _, item in items do
		if typeof(item) == "table" then
			table.insert(result, item[1])
			table.insert(result, item[2])
		else
			table.insert(result, item)
		end
	end

	return result
end

function v7:GetTypeInfoAtPath(p, list3)
	if not (v4 and #list3 ~= 0) then
		return nil
	end

	local types = p.Types
	local v8 = nil

	for _, v9 in list3 do
		if not types then
			return nil
		end

		if typeof(v9) == "table" then
			v9 = v9[2] or v9
		end

		v8 = types[v9]

		if not v8 then
			return nil
		end

		if v8.Mode == "table" or v8.Mode == "tables" then
			types = Utils:GetPropertiesForType(v4, v8) or nil
		else
			types = nil
		end
	end

	return v8
end

function v7:GetValuesAtPath(p, flag: boolean?)
	local flattenPath = v7:FlattenPath(p)
	local types = v6.Types

	for i = 1, #flattenPath - 1 do
		local v8 = flattenPath[i]
		local type2 = types[v8]

		if type2 == nil then
			if not flag then
				return nil
			end

			type2 = {}
			types[v8] = type2
		end

		types = type2
	end

	return types
end

function v7:DescribeTable(items, p)
	local v8 = {}

	for k, item in items do
		if not Utils:CheckIfAllowed(item, p) then
			continue
		end

		local v9 = p[k]

		if not (v9 ~= nil or item.Mode == "boolean") then
			continue
		end

		local describeValue = v7:DescribeValue(item, v9)

		if typeof(v9) == "string" then
			describeValue = `"{describeValue}"`
		end

		table.insert(v8, (`{item.Name} = {describeValue}`))
	end

	if #v8 == 0 then
		return "Nothing Selected."
	end

	return "{ " .. table.concat(v8, ", ") .. " }"
end

function v7:DescribeTables(p, items)
	local v8 = {}

	for _, item in items do
		table.insert(v8, v7:DescribeTable(p, item))
	end

	if #v8 == 0 then
		return "Nothing Selected."
	end

	return "{ " .. table.concat(v8, ", ") .. " }"
end

function v7:DescribeValue(p, p2)
	if p2 == nil and p.Mode == "boolean" then
		p2 = false
	end

	if p2 == nil then
		return "Nothing Selected."
	end

	if p.Mode == "text" then
		return (tostring(p2))
	end

	if p.Mode == "number" and p.IsTime then
		return Utils:FormatTime(p2)
	end

	local propertiesForType = (p.Mode == "table" or p.Mode == "tables") and v4 and Utils:GetPropertiesForType(v4, p)

	if not propertiesForType then
		return Utils:GetDescriptionOfParameter(p2)
	end

	if p.Mode == "table" then
		return v7:DescribeTable(propertiesForType, p2)
	end

	return v7:DescribeTables(propertiesForType, p2)
end

function v7:IsValueDone(p, list3, flag: boolean?)
	if not (flag ~= false and p.Mode ~= "boolean") then
		return true
	end

	if p.Mode == "options" or p.Mode == "tables" then
		return list3 ~= nil and #list3 > 0 or p.Optional == true
	end

	return list3 ~= nil or p.Optional == true
end

function v7:ResolveOptionsFor(data, p)
	if data.Mode ~= "option" and data.Mode ~= "options" then
		return nil
	end

	if data.List then
		return data.List
	end

	local type2 = Utils:ResolveType(data.Type, p)

	if type2 then
		return Utils:GetOptionsForType(v4, type2)
	end

	return nil
end

function v7:GetPrunedValue(p, p2, p3: number)
	local v8 = p2[p3]

	if v8 == nil then
		return nil
	end

	if p.Mode ~= "option" and p.Mode ~= "options" then
		return v8
	end

	local optionsFor = v7:ResolveOptionsFor(p, p2)

	if not optionsFor then
		p2[p3] = nil
		return nil
	end

	if p.Mode == "option" then
		if table.find(optionsFor, v8) then
			return v8
		end

		p2[p3] = nil
		return nil
	else
		local result = {}

		for _, v9 in v8 do
			if table.find(optionsFor, v9) then
				table.insert(result, v9)
			end
		end

		if #result == 0 then
			p2[p3] = nil
			return nil
		end

		if #result == #v8 then
			return v8
		end

		p2[p3] = result
		return result
	end
end

function v7:RefreshTypesList(parent2, items, options, callback)
	for _, frame in parent2:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v8 = false

		for _, item in items do
			if item.Mode .. item.Name ~= frame.Name then
				continue
			end

			v8 = true
			break
		end

		if not v8 then
			frame:Destroy()
		end
	end

	local total = 0

	for k, item in items do
		local name = item.Mode .. item.Name
		local prunedValue = options and v7:GetPrunedValue(item, options, k)
		local describeValue = v7:DescribeValue(item, prunedValue)
		local v9 = Utils:CheckIfAllowed(item, options or {})

		if v9 and not v7:ResolveOptionsFor(item, options or {}) and (item.Mode == "option" or item.Mode == "options") then
			v9 = false
		end

		local isValueDone = v7:IsValueDone(item, prunedValue, v9)
		local clone2 = parent2:FindFirstChild(name)

		if not clone2 then
			clone2 = ((item.Mode == "table" or item.Mode == "tables") and assets.Templates.Table or assets.Templates.Type):Clone()
			clone2.Name = name
			clone2:SetAttribute("OriginalSize", clone2.Size)
			clone2.Size = UDim2.fromScale(0, 0)
			clone2.Main.Information.Title.Text = item.Name
			local v10 = k
			v7:CreateButton(clone2.Main.Icon.Main, function()
				callback(v10)
			end)
			clone2.Parent = parent2
			clone2.Visible = true
		end

		clone2.Main.Information.Description.Text = describeValue
		clone2.Main.StatusFrame.Main.BackgroundColor3 = isValueDone and Color3.new(0.25, 1, 0.25) or Color3.new(
			1,
			0.25,
			0.25
		)

		if clone2:GetAttribute("Visibility") == v9 then
			continue
		end

		v7:SetFrameVisible(clone2, v9, total)
		total += 0.025
	end
end

function v7:RefreshTablesList(parent2, p, p2: number, list3)
	if not v4 then
		return
	end

	local propertiesForType = Utils:GetPropertiesForType(v4, p)

	if not propertiesForType then
		return
	end

	local v8 = not list3 and 0 or #list3 or 0
	local v9 = {
		__Add = true
	}

	for i = 1, v8 do
		for _, v10 in propertiesForType do
			v9[i .. "_" .. v10.Mode .. v10.Name] = true
		end

		v9["__Remove" .. i] = true
		v9["__Divider" .. i] = true
	end

	for _, frame in parent2:GetChildren() do
		if not frame:IsA("Frame") or v9[frame.Name] then
			continue
		end

		frame:Destroy()
	end

	local layoutOrder = 0
	local total = 0

	for i = 1, v8 do
		local v11 = list3[i]

		for k, v12 in propertiesForType do
			local name = i .. "_" .. v12.Mode .. v12.Name
			local prunedValue = v11 and v7:GetPrunedValue(v12, v11, k)
			local describeValue = v7:DescribeValue(v12, prunedValue)
			local v14 = Utils:CheckIfAllowed(v12, v11 or {})

			if v14 and not v7:ResolveOptionsFor(v12, v11 or {}) and (v12.Mode == "option" or v12.Mode == "options") then
				v14 = false
			end

			local isValueDone = v7:IsValueDone(v12, prunedValue, v14)
			local clone2 = parent2:FindFirstChild(name)

			if not clone2 then
				clone2 = ((v12.Mode == "table" or v12.Mode == "tables") and assets.Templates.Table or assets.Templates.Type):Clone()
				clone2.Name = name
				clone2:SetAttribute("OriginalSize", clone2.Size)
				clone2.Size = UDim2.fromScale(0, 0)
				clone2.Main.Information.Title.Text = v12.Name
				local v15 = i
				local v16 = k
				v7:CreateButton(clone2.Main.Icon.Main, function()
					v7:SelectProperty({ v15, v16 })
				end)
				clone2.Parent = parent2
				clone2.Visible = true
			end

			clone2.Main.Information.Description.Text = describeValue
			clone2.Main.StatusFrame.Main.BackgroundColor3 = isValueDone and Color3.new(0.25, 1, 0.25) or Color3.new(
				1,
				0.25,
				0.25
			)
			clone2.LayoutOrder = layoutOrder
			layoutOrder += 1

			if clone2:GetAttribute("Visibility") == v14 then
				continue
			end

			v7:SetFrameVisible(clone2, v14, total)
			total += 0.025
		end

		local name2 = "__Remove" .. i
		local clone2 = parent2:FindFirstChild(name2)

		if not clone2 then
			clone2 = assets.Templates.TableAddOrRemove:Clone()
			clone2.Name = name2
			local add_2 = clone2.Main:FindFirstChild("Add")
			add_2.Visible = false
			local remove = clone2.Main:FindFirstChild("Remove")
			remove.Visible = true
			clone2:SetAttribute("OriginalSize", clone2.Size)
			clone2.Size = UDim2.fromScale(0, 0)
			local v13 = i
			v7:CreateButton(remove.Main, function()
				local v14 = v7:GetValuesAtPath(v6.SelectedPath, true)[p2]

				if v14 then
					table.remove(v14, v13)
				end

				v7:RefreshSelected()
			end)
			clone2.Parent = parent2
			clone2.Visible = true
		end

		clone2.LayoutOrder = layoutOrder
		local layoutOrder2 = layoutOrder + 1

		if clone2:GetAttribute("Visibility") ~= true then
			v7:SetFrameVisible(clone2, true, total)
			total += 0.025
		end

		local name3 = "__Divider" .. i
		local clone3 = parent2:FindFirstChild(name3)

		if not clone3 then
			clone3 = assets.Templates.TableDivider:Clone()
			clone3.Name = name3
			clone3:SetAttribute("OriginalSize", clone3.Size)
			clone3.Size = UDim2.fromScale(0, 0)
			clone3.Parent = parent2
			clone3.Visible = true
		end

		clone3.LayoutOrder = layoutOrder2
		layoutOrder = layoutOrder2 + 1

		if clone3:GetAttribute("Visibility") == true then
			continue
		end

		v7:SetFrameVisible(clone3, true, total)
		total += 0.025
	end

	local __Add = parent2:FindFirstChild("__Add")

	if not __Add then
		__Add = assets.Templates.TableAddOrRemove:Clone()
		__Add.Name = "__Add"
		local remove_2 = __Add.Main:FindFirstChild("Remove")
		remove_2.Visible = false
		local add = __Add.Main:FindFirstChild("Add")
		add.Visible = true
		__Add:SetAttribute("OriginalSize", __Add.Size)
		__Add.Size = UDim2.fromScale(0, 0)
		v7:CreateButton(add.Main, function()
			local valuesAtPath = v7:GetValuesAtPath(v6.SelectedPath, true)
			local v11 = valuesAtPath[p2]

			if not v11 then
				v11 = {}
				valuesAtPath[p2] = v11
			end

			table.insert(v11, {})
			v7:RefreshSelected()
		end)
		__Add.Parent = parent2
		__Add.Visible = true
	end

	__Add.LayoutOrder = layoutOrder

	if __Add:GetAttribute("Visibility") ~= true then
		v7:SetFrameVisible(__Add, true, total)
		total += 0.025
	end
end

function v7:SetFrameVisible(guiObject, visibility: boolean, value: number?)
	if not (guiObject and guiObject:IsA("GuiObject") and guiObject:GetAttribute("Visibility") ~= visibility) then
		return
	end

	local v8 = (guiObject:GetAttribute("VisibilityToken") or 0) + 1
	guiObject:SetAttribute("VisibilityToken", v8)

	local function Animate()
		if not (guiObject.Parent and guiObject:GetAttribute("VisibilityToken") == v8 and guiObject:GetAttribute("Visibility") ~= visibility) then
			return
		end

		guiObject:SetAttribute("Visibility", visibility)

		if not visibility then
			Spring.target(guiObject, 1, 2.5, {
				Size = UDim2.fromScale(0, 0)
			})
			return
		end

		local originalSize

		if guiObject:GetAttribute("OriginalSize") then
			originalSize = guiObject:GetAttribute("OriginalSize")
		else
			originalSize = guiObject.Size
			guiObject:SetAttribute("OriginalSize", originalSize)
		end

		guiObject.Visible = true
		Spring.target(guiObject, 1, 2.5, {
			Size = originalSize
		})
	end

	local v9 = value or 0

	if v9 > 0 then
		task.delay(v9, Animate)
	else
		Animate()
	end
end

function v7:RefreshResults()
	if not atom() then
		return
	end

	local now = os.time()
	local total = 0

	for k, v8 in v do
		if now - v8.Time >= 15 then
			continue
		end

		local clone2 = results:FindFirstChild(v8.Identifier)

		if not clone2 then
			clone2 = assets.Templates.Result:Clone()
			clone2.Name = v8.Identifier
			clone2:SetAttribute("OriginalSize", clone2.Size)
			clone2.Size = UDim2.fromScale(0, 0)
			clone2.Parent = results
			clone2.Visible = true
		end

		if clone2:GetAttribute("Destroying") then
			continue
		end

		clone2.Title.Text = v8.Text
		clone2.Title.TextColor3 = v8.Color
		clone2.Title.UIStroke.Color = v8.Color

		if not clone2:GetAttribute("Visibility") then
			v7:SetFrameVisible(clone2, true, total)
			total += 0.025
		end

		clone2.LayoutOrder = k
	end

	for _, frame in results:GetChildren() do
		if not frame:IsA("Frame") or frame:GetAttribute("Destroying") then
			continue
		end

		local v8 = nil

		for _, v10 in v do
			if frame.Name ~= v10.Identifier then
				continue
			end

			v8 = v10
			break
		end

		if not (not v8 or now - v8.Time >= 15) then
			continue
		end

		frame:SetAttribute("Destroying", true)
		Spring.target(frame, 1, 2.5, {
			Size = UDim2.fromScale(0, 0)
		})
		local v10 = frame
		Spring.completed(frame, function()
			v10:Destroy()
		end)
	end
end

function v7:RefreshCommands()
	if not (v4 and atom()) then
		return
	end

	local text = string.lower(search.TextBox.Text)
	local v8 = {}

	for k, command in v4.Commands do
		table.insert(v8, {
			Name = k,
			Info = command,
			LowerName = string.lower(k)
		})
	end

	table.sort(v8, function(a, b)
		return a.LowerName < b.LowerName
	end)
	local total = 0

	for _, v9 in v8 do
		local visible

		if v6 == nil then
			visible = false
		else
			visible = v6.Name == v9.Name
		end

		local v11 = visible or string.find(string.lower(v9.Name), text) ~= nil
		local clone2 = commands:FindFirstChild(v9.Name)

		if not clone2 then
			clone2 = assets.Templates.Command:Clone()
			clone2.Name = v9.Name
			clone2:SetAttribute("OriginalSize", clone2.Size)
			clone2.Size = UDim2.fromScale(0, 0)
			clone2.Main.Information.Title.Text = v9.Name
			clone2.Main.Icon.Main.Image = v9.Info.Icon or "rbxassetid://118400274613554"
			clone2.Main.Information.Description.Text = v9.Info.Description or "No description given."
			local v12 = v9
			v7:CreateButton(clone2.Main, function()
				v7:SelectCommand(v12.Name)
			end)
			clone2.Parent = commands
		end

		clone2.Main.SelectedFrame.Visible = visible
		clone2.Main.UIStroke.Transparency = visible and 0 or 0.5

		if clone2:GetAttribute("Visibility") == v11 then
			continue
		end

		v7:SetFrameVisible(clone2, v11, total)
		total += 0.025
	end
end

function v7:RefreshSelected()
	if not (v4 and atom()) then
		return
	end

	local v8 = v6 ~= nil and v4.Commands[v6.Name] or nil

	if v8 then
		local selectedPath = v6.SelectedPath
		local flattenPath = v7:FlattenPath(selectedPath)
		local v9 = flattenPath[#flattenPath]
		local typeInfoAtPath = v7:GetTypeInfoAtPath(v8, selectedPath)
		local valuesAtPath = v7:GetValuesAtPath(selectedPath)
		local v10

		if valuesAtPath then
			v10 = valuesAtPath[v9] or nil
		end

		if typeInfoAtPath then
			local v11 = Utils:CheckIfAllowed(typeInfoAtPath, valuesAtPath or {})

			if v11 and not v7:ResolveOptionsFor(typeInfoAtPath, valuesAtPath or {}) and (typeInfoAtPath.Mode == "option" or typeInfoAtPath.Mode == "options") then
				v11 = false
			end

			if v11 then
				if valuesAtPath and (typeInfoAtPath.Mode == "option" or typeInfoAtPath.Mode == "options") and v7:GetPrunedValue(
					typeInfoAtPath,
					valuesAtPath,
					v9
				) ~= v10 then
					v7:RefreshSelected()
					return
				end

				local describeValue = v7:DescribeValue(typeInfoAtPath, v10)
				local total = 0
				local isValueDone = v7:IsValueDone(typeInfoAtPath, v10)

				if typeInfoAtPath.Mode == "option" or typeInfoAtPath.Mode == "options" then
					local optionsFor = v7:ResolveOptionsFor(typeInfoAtPath, valuesAtPath)

					if not optionsFor then
						return
					end

					for _, frame in list:GetChildren() do
						if not (frame:IsA("Frame") and frame.Name ~= "__Search" and frame.Name ~= "__SelectAll" and frame.Name ~= "__DeselectAll") then
							continue
						end

						if table.find(optionsFor, frame.Name) then
							continue
						end

						frame:Destroy()
					end

					if typeInfoAtPath.Mode == "options" then
						local __SelectAll = list:FindFirstChild("__SelectAll")

						if not __SelectAll then
							__SelectAll = assets.Templates.Helper:Clone()
							__SelectAll.Name = "__SelectAll"
							__SelectAll.Main.Title.Text = "Select All"
							__SelectAll:SetAttribute("OriginalSize", __SelectAll.Size)
							__SelectAll.Size = UDim2.fromScale(0, 0)
							__SelectAll.Parent = list
							v7:CreateButton(__SelectAll.Main, function()
								local valuesAtPath2 = v7:GetValuesAtPath(v6.SelectedPath, true)
								local optionsFor2 = v7:ResolveOptionsFor(typeInfoAtPath, valuesAtPath2)

								if not optionsFor2 then
									return
								end

								local v12 = {}

								for _, v13 in optionsFor2 do
									table.insert(v12, v13)
								end

								valuesAtPath2[v9] = v12
								v7:RefreshSelected()
							end)
						end

						if __SelectAll:GetAttribute("Visibility") ~= true then
							v7:SetFrameVisible(__SelectAll, true, total)
							total += 0.025
						end

						local __DeselectAll = list:FindFirstChild("__DeselectAll")

						if not __DeselectAll then
							__DeselectAll = assets.Templates.Helper:Clone()
							__DeselectAll.Name = "__DeselectAll"
							__DeselectAll.Main.Title.Text = "Deselect All"
							__DeselectAll:SetAttribute("OriginalSize", __DeselectAll.Size)
							__DeselectAll.Size = UDim2.fromScale(0, 0)
							__DeselectAll.Parent = list
							v7:CreateButton(__DeselectAll.Main, function()
								local valuesAtPath = v7:GetValuesAtPath(v6.SelectedPath, true)
								valuesAtPath[v9] = nil
								v7:RefreshSelected()
							end)
						end

						if __DeselectAll:GetAttribute("Visibility") ~= true then
							v7:SetFrameVisible(__DeselectAll, true, total)
							total += 0.025
						end
					end

					local __Search = list:FindFirstChild("__Search")

					if not __Search then
						__Search = assets.Templates.Search:Clone()
						__Search.Name = "__Search"
						__Search:SetAttribute("OriginalSize", __Search.Size)
						__Search.Size = UDim2.fromScale(0, 0)
						__Search.Parent = list
						local v12 = {}
						v12.Destroy = __Search.AncestryChanged:Connect(function(_, parent2)
							if parent2 then
								return
							end

							for _, connection in v12 do
								connection:Disconnect()
							end

							table.clear(v12)
						end)
						v12.TextChanged = __Search.Main.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
							v7:RefreshSelected()
						end)
					end

					if __Search:GetAttribute("Visibility") ~= true then
						v7:SetFrameVisible(__Search, true, total)
						total += 0.025
					end

					local text = string.lower(__Search.Main.TextBox.Text)

					for _, childName in optionsFor do
						local v12 = string.find(string.lower(childName), text) ~= nil
						local visible = false

						if typeInfoAtPath.Mode == "option" then
							visible = childName == v10
						elseif v10 ~= nil then
							visible = table.find(v10, childName) ~= nil
						end

						local clone2 = list:FindFirstChild(childName)

						if not clone2 then
							clone2 = assets.Templates.Option:Clone()
							clone2.Name = childName
							clone2:SetAttribute("OriginalSize", clone2.Size)
							clone2.Size = UDim2.fromScale(0, 0)
							clone2.Main.Title.Text = childName
							local v14 = childName
							v7:CreateButton(clone2.Main.Select, function()
								local valuesAtPath2 = v7:GetValuesAtPath(v6.SelectedPath, true)
								local v15 = valuesAtPath2[v9]

								if typeInfoAtPath.Mode == "option" then
									local v17

									if v15 ~= v14 then
										v17 = v14 or nil
									end

									valuesAtPath2[v9] = v17
								else
									if v15 == nil then
										v15 = {}
										valuesAtPath2[v9] = v15
									end

									local index = table.find(v15, v14)

									if index then
										table.remove(v15, index)
									else
										table.insert(v15, v14)
									end
								end

								v7:RefreshSelected()
							end)
							clone2.Parent = list
						end

						clone2.Main.Select.Main.Visible = visible
						local v14 = v12 or visible

						if clone2:GetAttribute("Visibility") == v14 then
							continue
						end

						v7:SetFrameVisible(clone2, v14, total)
						total += 0.025
					end
				elseif typeInfoAtPath.Mode == "text" then
					for _, frame in list:GetChildren() do
						if frame:IsA("Frame") and frame.Name ~= "__Text" then
							frame:Destroy()
						end
					end

					local __Text = list:FindFirstChild("__Text")

					if not __Text then
						__Text = assets.Templates.Text:Clone()
						__Text.Name = "__Text"
						local size = __Text.Size
						__Text:SetAttribute("OriginalSize", size)
						__Text.Size = UDim2.fromScale(0, 0)
						__Text.Parent = list
						local v12 = {}
						v12.Destroy = __Text.AncestryChanged:Connect(function(_, parent2)
							if parent2 then
								return
							end

							for _, connection in v12 do
								connection:Disconnect()
							end
						end)
						v12.FocusLost = __Text.Main.TextBox.FocusLost:Connect(function()
							local text = __Text.Main.TextBox.Text
							local valuesAtPath2 = v7:GetValuesAtPath(v6.SelectedPath, true)

							if text == "" or not text then
								text = nil
							end

							valuesAtPath2[v9] = text
							v7:RefreshSelected()
						end)
					end

					if __Text:GetAttribute("Visibility") ~= true then
						v7:SetFrameVisible(__Text, true)
					end

					if not v7:IsTextBoxSelected(__Text.Main.TextBox) then
						__Text.Main.TextBox.Text = v10 or ""
					end
				elseif typeInfoAtPath.Mode == "number" then
					for _, frame in list:GetChildren() do
						if frame:IsA("Frame") and frame.Name ~= "__Number" then
							frame:Destroy()
						end
					end

					local __Number = list:FindFirstChild("__Number")

					if not __Number then
						__Number = assets.Templates.Number:Clone()
						__Number.Name = "__Number"
						v7:CreateButton(__Number.Main.Plus, function()
							local valuesAtPath2 = v7:GetValuesAtPath(v6.SelectedPath, true)
							local v12 = math.max(0, (valuesAtPath2[v9] or 0) + 1)
							valuesAtPath2[v9] = typeInfoAtPath.IsTime and tostring(v12) or Utils:Format(v12)
							v7:RefreshSelected()
						end)
						v7:CreateButton(__Number.Main.Minus, function()
							local valuesAtPath2 = v7:GetValuesAtPath(v6.SelectedPath, true)
							local v12 = math.max(0, (valuesAtPath2[v9] or 0) - 1)
							valuesAtPath2[v9] = typeInfoAtPath.IsTime and tostring(v12) or Utils:Format(v12)
							v7:RefreshSelected()
						end)
						local size = __Number.Size
						__Number:SetAttribute("OriginalSize", size)
						__Number.Size = UDim2.fromScale(0, 0)
						__Number.Parent = list
						local v12 = {}
						v12.Destroy = __Number.AncestryChanged:Connect(function(_, parent2)
							if parent2 then
								return
							end

							for _, connection in v12 do
								connection:Disconnect()
							end
						end)
						v12.FocusLost = __Number.Main.TextBox.FocusLost:Connect(function()
							local v13 = Utils:Unformat(__Number.Main.TextBox.Text) or 0
							local valuesAtPath = v7:GetValuesAtPath(v6.SelectedPath, true)
							valuesAtPath[v9] = typeInfoAtPath.IsTime and tostring(v13) or Utils:Format(v13)
							v7:RefreshSelected()
						end)
					end

					if __Number:GetAttribute("Visibility") ~= true then
						v7:SetFrameVisible(__Number, true)
					end

					if not v7:IsTextBoxSelected(__Number.Main.TextBox) then
						local text = v10 == nil and "" or Utils:Format(v10) or ""
						__Number.Main.TextBox.Text = text
					end
				elseif typeInfoAtPath.Mode == "boolean" then
					for _, frame in list:GetChildren() do
						if frame:IsA("Frame") and frame.Name ~= "__Boolean" then
							frame:Destroy()
						end
					end

					local __Boolean = list:FindFirstChild("__Boolean")

					if not __Boolean then
						__Boolean = assets.Templates.Boolean:Clone()
						__Boolean.Name = "__Boolean"
						__Boolean:SetAttribute("OriginalSize", __Boolean.Size)
						__Boolean.Size = UDim2.fromScale(0, 0)
						__Boolean.Main.Title.Text = typeInfoAtPath.Name
						v7:CreateButton(__Boolean.Main.Select, function()
							local valuesAtPath2 = v7:GetValuesAtPath(v6.SelectedPath, true)
							valuesAtPath2[v9] = valuesAtPath2[v9] ~= true
							v7:RefreshSelected()
						end)
						__Boolean.Parent = list
					end

					if __Boolean:GetAttribute("Visibility") ~= true then
						v7:SetFrameVisible(__Boolean, true)
					end

					__Boolean.Main.Select.Main.Visible = v10 == true
				elseif typeInfoAtPath.Mode == "table" then
					local propertiesForType = Utils:GetPropertiesForType(v4, typeInfoAtPath)

					if not propertiesForType then
						return
					end

					v7:RefreshTypesList(list, propertiesForType, v10, function(p)
						v7:SelectProperty(p)
					end)
				elseif typeInfoAtPath.Mode == "tables" then
					v7:RefreshTablesList(list, typeInfoAtPath, v9, v10)
				end

				main2.Main.Information.Title.Text = typeInfoAtPath.Name
				main2.Main.Information.Description.Text = describeValue
				main2.Main.StatusFrame.Main.BackgroundColor3 = isValueDone and Color3.new(0.25, 1, 0.25) or Color3.new(
					1,
					0.25,
					0.25
				)
			else
				table.clear(v6.SelectedPath)
				v7:RefreshSelected()
				return
			end
		end

		v7:RefreshTypesList(list2, v8.Types, v6.Types, function(p)
			v7:SelectType(p)
		end)
		type.Visible = typeInfoAtPath ~= nil
		selected.Visible = typeInfoAtPath == nil
	else
		type.Visible = false
		selected.Visible = false
	end
end

function v7:RefreshInterface()
	if not (v4 and atom()) then
		return
	end

	v7:RefreshResults()
	v7:RefreshCommands()
	v7:RefreshSelected()
end

function v7:CreateButton(button, onActivated)
	if not (button and button:IsA("GuiButton")) then
		return
	end

	button.Active = true
	button.Selectable = true
	button.Interactable = true
	local v8 = {
		Instance = button,
		Connections = {}
	}
	v8.Connections.Activated = button.Activated:Connect(onActivated)
	v8.Connections.Destroy = button.AncestryChanged:Connect(function(_, parent2)
		if parent2 then
			return
		end

		for _, connection in v8.Connections do
			connection:Disconnect()
		end

		table.clear(v8.Connections)
		v2[button] = nil
	end)
	v2[button] = v8
end

function Visco:SetUIEnabled(flag: boolean)
	if not (v4 and atom() ~= flag and atom2() and localPlayer:GetAttribute("VISCO_USER")) then
		return
	end

	atom(flag)

	if atom() then
		for _, v8 in v3.Opened do
			v8.Callback()
		end

		task.spawn(function()
			while atom() do
				v7:RefreshInterface()
				task.wait(1)
			end
		end)
		v7:RefreshInterface()
	else
		for _, v8 in v3.Closed do
			v8.Callback()
		end
	end
end

function Visco:ToggleUI()
	Visco:SetUIEnabled(not atom())
end

function Visco.OnUIOpened(_, callback)
	local v8 = {
		Callback = callback,
		ID = HttpService:GenerateGUID(false)
	}

	function v8:Disconnect()
		v3.Opened[v8.ID] = nil
	end

	v3.Opened[v8.ID] = v8
end

function Visco.OnUIClosed(_, callback)
	local v8 = {
		Callback = callback,
		ID = HttpService:GenerateGUID(false)
	}

	function v8:Disconnect()
		v3.Closed[v8.ID] = nil
	end

	v3.Closed[v8.ID] = v8
	return v8
end

function Visco.BindTo(_, p)
	table.insert(v5, p)
end

Charm.effect(function()
	if atom() then
		atom2(false)
		clone.Enabled = true
		Spring.target(background, 1, 2.5, {
			BackgroundTransparency = 0.25
		})
		Spring.target(search, 1, 2.5, {
			Position = position2
		})
		Spring.target(credits, 1, 2.5, {
			Position = position3
		})
		Spring.target(type, 1, 2.5, {
			Position = position4
		})
		Spring.target(selected, 1, 2.5, {
			Position = position5
		})
		Spring.target(commands, 1, 2.5, {
			Position = position6
		})
		Spring.target(results, 1, 2.5, {
			Position = position7
		})
		Spring.target(title, 1, 2.5, {
			Position = position,
			TextTransparency = 0
		})
		Spring.completed(title, function()
			atom2(true)
		end)
	else
		atom2(false)
		Spring.target(background, 1, 2.5, {
			BackgroundTransparency = 1
		})
		Spring.target(search, 1, 2.5, {
			Position = UDim2.fromScale(-0.5, 0.025)
		})
		Spring.target(credits, 1, 2.5, {
			Position = UDim2.fromScale(1.5, 0.025)
		})
		Spring.target(type, 1, 2.5, {
			Position = UDim2.fromScale(1.5, 0.115)
		})
		Spring.target(selected, 1, 2.5, {
			Position = UDim2.fromScale(1.5, 0.115)
		})
		Spring.target(commands, 1, 2.5, {
			Position = UDim2.fromScale(-0.5, 0.115)
		})
		Spring.target(results, 1, 2.5, {
			Position = UDim2.fromScale(0.5, 1.1)
		})
		Spring.target(title, 1, 2.5, {
			Position = UDim2.fromScale(0.5, -0.25),
			TextTransparency = 1
		})
		Spring.completed(title, function()
			clone.Enabled = false

			for _, v8 in { commands, list2, list } do
				for _, frame in v8:GetChildren() do
					if not frame:IsA("Frame") then
						continue
					end

					frame.Size = UDim2.fromScale(0, 0)
					frame:SetAttribute("Visibility", false)
					frame:SetAttribute("VisibilityToken", (frame:GetAttribute("VisibilityToken") or 0) + 1)
				end
			end

			for _, frame in results:GetChildren() do
				if not frame:IsA("Frame") then
					continue
				end

				frame.Size = UDim2.fromScale(0, 0)
				frame:SetAttribute("Visibility", false)
			end

			atom2(true)
		end)
	end
end)
search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	v7:RefreshCommands()
end)
use.OnClientEvent:Connect(function(flag: boolean, p: string)
	local now = os.time()
	local GUID = HttpService:GenerateGUID(false)
	local text = "[" .. os.date("%H:%M:%S", now) .. "] " .. p
	local color = flag and Color3.new(0.25, 1, 0.25) or Color3.new(1, 0.25, 0.25)
	table.insert(v, {
		Identifier = GUID,
		Time = os.time(),
		Text = text,
		Color = color
	})

	if #v > 10 then
		table.remove(v, 1)
	end

	v7:RefreshInterface()
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	for _, v8 in v5 do
		if input.KeyCode == v8 or input.UserInputType == v8 then
			Visco:ToggleUI()
		end
	end
end)
v7:CreateButton(buttons.Confirm, function()
	if not (v4 and v6) then
		return
	end

	table.remove(v6.SelectedPath)

	for _, frame in list:GetChildren() do
		if frame:IsA("Frame") then
			frame.Name = "__Destroy__"
		end
	end

	v7:RefreshSelected()
end)
v7:CreateButton(buttons.Reset, function()
	if not v4 or (not v6 or #v6.SelectedPath == 0) then
		return
	end

	local selectedPath = v6.SelectedPath
	local valuesAtPath = v7:GetValuesAtPath(selectedPath)

	if valuesAtPath then
		local flattenPath = v7:FlattenPath(selectedPath)
		valuesAtPath[flattenPath[#flattenPath]] = nil
	end

	v7:RefreshSelected()
end)
v7:CreateButton(buttons2.Return, function()
	if not (v4 and v6) then
		return
	end

	v6 = nil
	v7:RefreshInterface()
end)
v7:CreateButton(buttons2.Use, function()
	if not (v4 and v6) then
		return
	end

	local command = v4.Commands[v6.Name]

	if not command then
		return
	end

	local defaults = Utils:DeepCopy(v6.Types)

	for k, type2 in command.Types do
		if not (defaults[k] == nil and type2.Default ~= nil) then
			continue
		end

		local default = type2.Default

		if type2.Mode == "number" then
			default = tostring(default)
		elseif typeof(default) == "table" then
			default = Utils:DeepCopy(default)
		end

		defaults[k] = default
	end

	local v8 = {}

	for k, v9 in defaults do
		v8[tostring(k)] = v9
	end

	use:FireServer(v6.Name, v8)
end)
task.spawn(function()
	v7:Initialize()
end)
return Visco