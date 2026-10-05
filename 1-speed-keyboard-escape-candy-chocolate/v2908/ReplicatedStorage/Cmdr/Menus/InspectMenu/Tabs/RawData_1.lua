local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
local ProfileAccess = require(script.Parent.Parent.ProfileAccess)
require(ReplicatedStorage.Cmdr.Menus.InspectMenu.Types)
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local v = {
	Background = Color3.fromRGB(35, 35, 35),
	AlternateBackground = Color3.fromRGB(40, 40, 40),
	TableBackground = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 55, 62)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(36, 41, 47)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 28, 33))
	}),
	TableHover = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(61, 68, 77)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(46, 53, 61)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(32, 38, 44))
	}),
	TableBorder = Color3.fromRGB(48, 56, 65),
	TableText = Color3.fromRGB(238, 241, 245),
	TableMuted = Color3.fromRGB(182, 192, 203),
	TableAccent = Color3.fromRGB(104, 178, 238),
	Border = Color3.fromRGB(27, 27, 27),
	Key = Color3.fromRGB(218, 218, 218),
	Muted = Color3.fromRGB(145, 145, 145),
	String = Color3.fromRGB(166, 214, 166),
	Number = Color3.fromRGB(137, 196, 255),
	Boolean = Color3.fromRGB(255, 196, 112),
	Nil = Color3.fromRGB(155, 155, 155),
	Other = Color3.fromRGB(214, 174, 255),
	Guide = Color3.fromRGB(77, 83, 92)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function FormatKey(value)
	if type(value) == "number" then
		return (`[{value}]`)
	end

	return (tostring(value))
end

local function FormatValue(value)
	local typeName = typeof(value)

	if typeName == "string" then
		return (`"{value:gsub("\\", "\\\\"):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t"):gsub("\"", "\\\"")}"`)
	elseif typeName == "nil" then
		return "nil"
	end

	return (tostring(value))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetValueColor(p)
	local typeName = typeof(p)

	if typeName == "string" then
		return v.String
	elseif typeName == "number" then
		return v.Number
	elseif typeName == "boolean" then
		return v.Boolean
	elseif typeName == "nil" then
		return v.Nil
	end

	return v.Other
end

local function GetVerticalRenderScale(parent)
	while parent do
		if parent:IsA("GuiObject") and parent.Size.Y.Scale == 0 then
			local offset = parent.Size.Y.Offset
			local Y = parent.AbsoluteSize.Y

			if offset > 0 and Y > 0 then
				return Y / offset
			end
		end

		parent = parent.Parent
	end

	return 1
end

local function GetSortedKeys(items)
	local result = {}

	for k in items do
		table.insert(result, k)
	end

	table.sort(result, function(a, b)
		local typeName = type(a)
		local typeName2 = type(b)

		if typeName == typeName2 then
			if typeName == "number" then
				return a < b
			end

			return tostring(a) < tostring(b)
		else
			return typeName == "number" or typeName2 ~= "number" and typeName < typeName2
		end
	end)
	return result
end

local fn

local function EntryMatches(value, p, p2: string, clone)
	local formatKey = FormatKey(value) -- equivalent call inferred; original call site unknown

	if string.find(string.lower(formatKey), p2, 1, true) then
		return true
	end

	if type(p) == "table" then
		return fn(p, p2, clone)
	end

	local v3 = string.lower((`{typeof(p)} {FormatValue(p)}`))
	return string.find(v3, p2, 1, true) ~= nil
end

fn = function(items, p: string, p2)
	if p2[items] then
		return false
	end

	local clone = table.clone(p2)
	clone[items] = true

	for k, item in items do
		if EntryMatches(k, item, p, clone) then
			return true
		end
	end

	return false
end

local function GetVisibleKeys(p, p2: string, p3)
	local sortedKeys = GetSortedKeys(p)

	if p2 == "" then
		return sortedKeys
	end

	local clone = table.clone(p3)
	clone[p] = true
	local result = {}

	for _, v3 in sortedKeys do
		if EntryMatches(v3, p[v3], p2, clone) then
			table.insert(result, v3)
		end
	end

	return result
end

local function CreateScalarRow(text: string, p2, layoutOrder: number)
	local v2 = create("Frame")
	local v3 = {
		Name = "ValueRow",
		AutomaticSize = Enum.AutomaticSize.Y
	}
	local backgroundColor

	if layoutOrder % 2 == 0 then
		backgroundColor = v.Background
	else
		backgroundColor = v.AlternateBackground
	end

	v3.BackgroundColor3 = backgroundColor
	v3.BorderColor3 = v.Border
	v3.BorderMode = Enum.BorderMode.Inset
	v3.LayoutOrder = layoutOrder
	v3.Size = UDim2.new(1, 0, 0, 24)
	local v5 = create("TextLabel")({
		Name = "Key",
		BackgroundTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
		Position = UDim2.fromOffset(7, 0),
		Size = UDim2.new(0.44, -7, 0, 24),
		Text = text,
		TextColor3 = v.Key,
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local v6 = create("TextLabel")({
		Name = "Type",
		BackgroundTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
		Position = UDim2.new(0.44, 0, 0, 0),
		Size = UDim2.new(0.16, -5, 0, 24),
		Text = typeof(p2),
		TextColor3 = v.Muted,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local v7 = create("TextLabel")
	local v8 = {
		Name = "Value",
		BackgroundTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json"),
		Position = UDim2.new(0.6, 0, 0, 0),
		Size = UDim2.new(0.4, -7, 0, 24),
		Text = FormatValue(p2),
		TextColor3 = 0,
		TextSize = 13,
		TextTruncate = 0,
		TextXAlignment = 0
	}
	local textColor = GetValueColor(p2) -- equivalent call inferred; original call site unknown
	v8.TextColor3 = textColor
	v8.TextTruncate = Enum.TextTruncate.AtEnd
	v8.TextXAlignment = Enum.TextXAlignment.Left
	do local _values = table.pack(v5, v6, v7(v8)); for _k = 1, _values.n do v3[_k] = _values[_k] end end
	return (v2(v3))
end

local fn2

local function CreateIndentedContent(list, spring)
	local v2 = spring or function()
		return 1
	end
	local source = Vide.source(0)
	return (create("Frame")({
		Name = "NestedContent",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		LayoutOrder = 2,
		Size = function()
			return UDim2.new(1, 0, 0, (math.round(source() * math.clamp(v2(), 0, 1))))
		end,
		create("Frame")({
			Name = "RevealContent",
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			create("Frame")({
				Name = "IndentGuide",
				BackgroundColor3 = v.Guide,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(7, 0),
				Size = UDim2.new(0, 1, 1, 0)
			}),
			create("Frame")({
				Name = "Children",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -14, 0, 0),
				create("UIListLayout")({
					Padding = UDim.new(0, 1),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				Vide.action(function(instance)
					-- equivalent calls inferred from this helper; original call sites unknown
					local function UpdateHeight()
						source(instance.AbsoluteSize.Y / GetVerticalRenderScale(instance))
					end

					local absoluteSizeChangedConnection = instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateHeight)
					Vide.cleanup(function()
						absoluteSizeChangedConnection:Disconnect()
					end)
					UpdateHeight() -- equivalent call inferred; original call site unknown
					task.defer(UpdateHeight)
				end),
				table.unpack(list)
			})
		})
	}))
end

local function CreateRangeNode(p, p2, i: number, p3: number, clone, p4: string, list, layoutOrder: number)
	local source = Vide.source(false)
	table.insert(list, source)
	local source2 = Vide.source(false)
	local spring = Vide.spring(function()
		if source() then
			return 1
		end

		return 0
	end, 0.18, 0.9)
	return (create("Frame")({
		Name = "RangeNode",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 0),
		create("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		create("TextButton")({
			Name = "Header",
			AutoButtonColor = false,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = v.TableBorder,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 24),
			Text = "",
			MouseButton1Click = function()
				source(not source())
			end,
			MouseEnter = function()
				source2(true)
			end,
			MouseLeave = function()
				source2(false)
			end,
			create("UIGradient")({
				Color = function()
					if source2() then
						return v.TableHover
					end

					return v.TableBackground
				end,
				Rotation = 90
			}),
			create("Frame")({
				Name = "Accent",
				BackgroundColor3 = v.TableAccent,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 2, 1, 0)
			}),
			create("TextLabel")({
				Name = "Arrow",
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(7, 0),
				Rotation = function()
					return 90 * spring()
				end,
				Size = UDim2.fromOffset(14, 24),
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold),
				Text = "›",
				TextColor3 = v.TableAccent,
				TextSize = 15
			}),
			create("TextLabel")({
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(23, 0),
				Size = UDim2.new(1, -30, 1, 0),
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold),
				Text = `Entries {i}–{p3}`,
				TextColor3 = v.TableText,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		}),
		Vide.show(source, function()
			return (CreateIndentedContent(fn2(p, p2, i, p3, clone, p4, list), spring))
		end)
	}))
end

local function fn3(text: string, p2, p3, p4: string, list, flag: boolean?, value: number?)
	local source = Vide.source(flag == true)
	table.insert(list, source)
	local source2 = Vide.source(false)
	local spring = Vide.spring(function()
		if source() then
			return 1
		end

		return 0
	end, 0.18, 0.9)
	local sortedKeys = GetSortedKeys(p2)
	local visibleKeys = GetVisibleKeys(p2, p4, p3)
	local v4 = create("Frame")
	local v5 = {
		Name = "TableNode",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = value or 1,
		Size = UDim2.new(1, 0, 0, 0)
	}
	local v6 = create("UIListLayout")({
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	local v7 = create("TextButton")
	local v8 = {
		Name = "Header",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = v.TableBorder,
		LayoutOrder = 1,
		Size = UDim2.new(1, 0, 0, 24),
		Text = "",
		MouseButton1Click = function()
			source(not source())
		end,
		MouseEnter = function()
			source2(true)
		end,
		MouseLeave = function()
			source2(false)
		end
	}
	local v9 = create("UIGradient")({
		Color = function()
			if source2() then
				return v.TableHover
			end

			return v.TableBackground
		end,
		Rotation = 90
	})
	local v10 = create("Frame")({
		Name = "Accent",
		BackgroundColor3 = v.TableAccent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 2, 1, 0)
	})
	local v11 = create("TextLabel")({
		Name = "Arrow",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(7, 0),
		Rotation = function()
			return 90 * spring()
		end,
		Size = UDim2.fromOffset(14, 24),
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold),
		Text = "›",
		TextColor3 = v.TableAccent,
		TextSize = 15
	})
	local v12 = create("TextLabel")({
		Name = "Key",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(23, 0),
		Size = UDim2.new(1, -90, 1, 0),
		FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold),
		Text = text,
		TextColor3 = v.TableText,
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local v13 = create("TextLabel")
	local v14 = {
		Name = "Count",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(62, 24),
		FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json"),
		Text = 0,
		TextColor3 = 0,
		TextSize = 11,
		TextXAlignment = 0
	}
	local text2

	if p4 == "" then
		text2 = `{#sortedKeys} items`
	else
		text2 = `{#visibleKeys}/{#sortedKeys}`
	end

	v14.Text = text2
	v14.TextColor3 = v.TableMuted
	v14.TextXAlignment = Enum.TextXAlignment.Right
	do local _values = table.pack(v9, v10, v11, v12, v13(v14)); for _k = 1, _values.n do v8[_k] = _values[_k] end end
	do local _values = table.pack(v6, v7(v8), Vide.show(source, function()
	local clone = table.clone(p3)
	clone[p2] = true
	local v16

	if #visibleKeys == 0 then
		v16 = { (CreateScalarRow(p4 == "" and "empty table" or "no matches", nil, 1)) }
	elseif #visibleKeys <= 100 then
		v16 = fn2(p2, visibleKeys, 1, #visibleKeys, clone, p4, list)
	else
		local v17 = 1
		v16 = {}

		for i = 1, #visibleKeys, 100 do
			local v18 = math.min(i + 100 - 1, #visibleKeys)
			table.insert(v16, (CreateRangeNode(p2, visibleKeys, i, v18, clone, p4, list, v17)))
			v17 += 1
		end
	end

	return (CreateIndentedContent(v16, spring))
end)); for _k = 1, _values.n do v5[_k] = _values[_k] end end
	return (v4(v5))
end

fn2 = function(p, list, p2: number, p3: number, p4, p5: string, list2)
	local result = {}

	for i = p2, p3 do
		local v2 = list[i]
		local v3 = p[v2]
		local text = FormatKey(v2) -- equivalent call inferred; original call site unknown
		local v5

		if type(v3) == "table" and not p4[v3] then
			local v6

			if p5 == "" then
				v6 = false
			else
				v6 = string.find(string.lower(text), p5, 1, true) ~= nil
			end

			v5 = fn3(text, v3, p4, v6 and "" or p5, list2, p5 ~= "", i - p2 + 1)
		elseif type(v3) == "table" then
			v5 = CreateScalarRow(text, "<cyclic reference>", i - p2 + 1)
		else
			v5 = CreateScalarRow(text, v3, i - p2 + 1)
		end

		table.insert(result, v5)
	end

	return result
end

local function CreateRawDataTree(data, p: string, p2)
	local v2 = create("Frame")({
		Name = "RawDataTree",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -4, 0, 0),
		create("UIListLayout")({
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		fn3("Profile Data", data, {}, p, p2, true, 1)
	})
	Vide.cleanup(v2)
	return v2
end

local clientEvent = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_GetRawData`,
	"cui.inspect.rawData",
	false,
	function(_, p)
		local v2 = ProfileAccess.Read(p.UserId)
		return {
			Ok = v2.Ok,
			Message = v2.Message,
			Data = v2.Data
		}
	end
)
return {
	DisplayName = "Raw Data",
	Permission = "cui.inspect.rawData",
	Order = 80,
	Setup = function(object, data)
		local NotificationSystem

		if RunService:IsClient() then
			NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		else
			NotificationSystem = nil
		end

		local v2 = ""

		local function fn4() end

		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search..."):SetOnChangedRaw(function(value)
				v2 = string.lower(value)
				fn4()
			end)
		end)
		local v3 = object:AddList(function(object2)
			object2:SetSizeY(320)
		end)
		local content = v3:GetUI():FindFirstChild("Content")
		content.AutomaticCanvasSize = Enum.AutomaticSize.Y
		content.CanvasSize = UDim2.fromOffset(0, 0)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function ApplyTreeZIndex(guiObject)
			if not guiObject:IsA("GuiObject") then
				return
			end

			local v4 = guiObject:IsA("TextButton") and 2 or guiObject:IsA("TextLabel") and 3 or 1
			guiObject.ZIndex = content.ZIndex + v4
		end

		local descendantAddedConnection = content.DescendantAdded:Connect(ApplyTreeZIndex)
		local data2 = nil
		local v4 = {}
		local v5 = nil
		v3:GetUI().Destroying:Connect(function()
			descendantAddedConnection:Disconnect()

			if v5 then
				v5()
			end

			v5 = nil
		end)

		local function Notify(p: string)
			if not NotificationSystem or p == "" then
				return
			end

			NotificationSystem:ShowGeneralNotification(p, Color3.fromRGB(255, 100, 100), 4)
		end

		fn4 = function()
			if not data2 then
				return
			end

			if v5 then
				v5()
			end

			for _, child in content:GetChildren() do
				if child.Name == "RawDataTree" then
					child:Destroy()
				end
			end

			v4 = {}
			v5 = Vide.mount(function()
				return (CreateRawDataTree(data2, v2, v4))
			end, content)

			for _, descendant in content:GetDescendants() do
				ApplyTreeZIndex(descendant) -- equivalent call inferred; original call site unknown
			end
		end

		local function Refresh()
			if RunService:IsServer() or not clientEvent then
				return
			end

			clientEvent:Fire({
				UserId = data.UserId
			}):andThen(function(data3)
				if data3.Ok and data3.Data then
					data2 = data3.Data
					fn4()
				else
					data.NotifyProfileError(data3.Message)
				end
			end):catch(function(p)
				local formatted = `Failed to load raw data: {tostring(p)}`

				if NotificationSystem then
					if formatted == "" then
						return
					else
						NotificationSystem:ShowGeneralNotification(formatted, Color3.fromRGB(255, 100, 100), 4)
					end
				end
			end)
		end

		object:AddSplit(function(object2)
			object2:SetLeftSizePercent(0.75)
			object2.LeftComponents:AddButton(function(object3)
				object3:SetButtonText("Refresh raw data"):SetYSize(22):SetEnabledPermission("cui.inspect.rawData"):SetButtonCallback(Refresh)
			end)
			object2.RightComponents:AddButton(function(object3)
				object3:SetButtonText("Collapse all"):SetYSize(22):SetEnabledPermission("cui.inspect.rawData"):SetButtonCallback(function()
					for i = #v4, 1, -1 do
						v4[i](false)
					end
				end)
			end)
		end)
		data.PresenceChanged:Connect(Refresh)
		Refresh()
	end
}