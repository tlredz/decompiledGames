local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local PlayerCommands = require(ReplicatedStorage.CAM.Global.PlayerCommands)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local v = Platform_Handler.Platform.Value == "Mobile"
local color = Color3.new(0.15, 0.15, 0.15)
local color2 = Color3.new(0.2, 0.2, 0.2)
local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.85) })
local numberSequence2 = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0) })
local color3 = Color3.new(1, 1, 1)
local color4 = Color3.new(0.6, 0.6, 0.6)
local info = faye.Info(0.15)
local v2 = v and 32 or 25
local rbxassetfontsfamiliesSourceSansProjson = Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.SemiBold,
	Enum.FontStyle.Normal
)
local color5 = Color3.new(0.87, 0.87, 0.87)
local springInfo = faye.SpringInfo(0.3, 1, 0.5)
local info2 = faye.Info(0.3)
local info3 = faye.Info(0.2)
local info4 = faye.Info(0.125)

local function split(value: string)
	local result = {}

	for k in value:gmatch("%S+") do
		table.insert(result, k)
	end

	return result, value:sub(-1) == " "
end

local function starting(items, value: string)
	local lower = value:lower()
	local result = {}

	for _, item in items do
		if not (lower == "" or item.Word:lower():sub(1, #lower) == lower) then
			continue
		end

		table.insert(result, item)
	end

	table.sort(result, function(a, b)
		if #a.Word == #b.Word then
			return a.Word < b.Word
		end

		return #a.Word < #b.Word
	end)

	while #result > 6 do
		table.remove(result)
	end

	return result
end

local function optionsFor(p: string, p2)
	local v3, v4 = split(p)

	if #v3 == 0 or #v3 == 1 and not v4 then
		local v5 = (v3[1] or ""):gsub("^/", "")
		local v6 = {}

		for _, v7 in PlayerCommands.List do
			if p2[v7.Name] then
				table.insert(v6, {
					Text = "/" .. v7.Name,
					Word = v7.Name
				})
			end
		end

		return starting(v6, v5), v5
	else
		local v5 = PlayerCommands.ByName(v3[1])

		if v5 == nil or not p2[v5.Name] then
			return {}, ""
		end

		local v6 = #v3 - 1
		local args = v5.Args

		if v4 then
			v6 += 1
		end

		local arg = args[v6]

		if arg == nil or arg.Suggester == nil then
			return {}, ""
		end

		local v7 = table.move(v3, 2, #v3, 1, {})
		local suggester = arg.Suggester(v7)

		if suggester == nil then
			return {}, ""
		end

		local v8 = {}

		for _, v9 in suggester do
			table.insert(v8, {
				Text = v9,
				Word = v9
			})
		end

		local selected = v4 and "" or v3[#v3]
		return starting(v8, selected), selected
	end
end

local function same(list, list2)
	if #list ~= #list2 then
		return false
	end

	for i = 1, #list do
		if list[i].Text ~= list2[i].Text then
			return false
		end
	end

	return true
end

local function replaceLast(value: string, list: string, p: string)
	return value:sub(1, #value - #list) .. p
end

return function(object, object2, callback)
	local text2 = object:Value("")
	local value2 = object:Value(color)
	local value3 = object:Value(0.25)
	local value4 = object:Value(numberSequence)
	local size = object:Value(UDim2.new(1, -40, 0.8, 0))
	local value6 = object:Value({})
	local size2 = object:Value(UDim2.new(1, 0, 0, 0))
	local value8 = object:Value(false)
	local flag = false
	local v3 = nil

	local function applyLook()
		if flag then
			value2:Set(color2)
			value3:Set(0)
			value4:Set(numberSequence2)
		else
			value2:Reset()
			value3:Reset()
			value4:Reset()
		end
	end

	local function reread(value9: string)
		local v4, v5 = optionsFor(value9, object2:Get())
		local v6 = value6:Get()
		local v7

		if #v4 == #v6 then
			local flag2 = true

			for i = 1, #v4 do
				if v4[i].Text == v6[i].Text then
					continue
				end

				v7 = false
				flag2 = false
				break
			end

			if flag2 then
				v7 = true
			end
		else
			v7 = false
		end

		if not v7 then
			value6:Set(v4)
			size2:Set(UDim2.new(1, 0, 0, #v4 * v2))
		end

		value8:Set(#v4 > 0)
		local v8 = v4[1]

		if v8 == nil or not (#v5 > 0 and #v8.Word > #v5) then
			text2:Set("")
			return
		end

		local word = v8.Word
		text2:Set(value9:sub(1, #value9 - #v5) .. word)
	end

	local function clear()
		text2:Set("")
		value6:Set({})
		size2:Set(UDim2.new(1, 0, 0, 0))
		value8:Set(false)

		if v3 ~= nil then
			v3.Text = ""
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function take(p)
		if v3 == nil then
			return
		end

		local _, v4 = optionsFor(v3.Text, object2:Get())
		local v5 = v3
		local text = v3.Text
		local word = p.Word
		v5.Text = (text:sub(1, #text - #v4) .. word) .. " "
		v3:CaptureFocus()
		reread(v3.Text)
	end

	object:Connect(Players.ChildRemoved, function()
		if v3 ~= nil and flag then
			reread(v3.Text)
		end
	end)
	object:Connect(object2.Changed, function()
		if v3 ~= nil then
			reread(v3.Text)
		end
	end)
	return object:Create("Frame")({
		Name = "Input",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = object:Animation(value2, info),
		BackgroundTransparency = object:Animation(value3, info),
		AbsoluteSizeOnChangedInit = function(_, point: Vector2)
			local v4 = point.Y * 0.5
			size:Set(UDim2.new(1, -(12 + v4 + 16), 0.8, 0))
		end,
		object:Create("UIGradient")({
			Transparency = object:Animation(value4, info),
			Rotation = -90
		}),
		object:Create("UICorner")({
			CornerRadius = UDim.new(1)
		}),
		object:Create("UIStroke")({
			Color = Color3.new(1, 1, 1),
			Transparency = 0.95
		}),
		object:Create("TextLabel")({
			Name = "Caret",
			Text = ">",
			Size = UDim2.fromScale(0.5, 0.5),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0),
			BackgroundTransparency = 1,
			TextColor3 = color4,
			TextScaled = true,
			FontFace = rbxassetfontsfamiliesSourceSansProjson
		}),
		object:Create("Frame")({
			Name = "Textboxholder",
			Size = size,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			BackgroundTransparency = 1,
			AbsoluteSizeOnChangedInit = function(instance)
				local textSize = math.max(math.floor(instance.AbsoluteSize.Y * 0.7), 1)

				for _, child in instance:GetChildren() do
					if child:IsA("TextBox") or child:IsA("TextLabel") then
						child.TextSize = textSize
					end
				end
			end,
			object:Create("TextBox")({
				Name = "Textbox",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				TextScaled = false,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextColor3 = color3,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				FontFace = rbxassetfontsfamiliesSourceSansProjson,
				PlaceholderColor3 = color4,
				PlaceholderText = "type a command",
				ClearTextOnFocus = false,
				function(p)
					v3 = p
					return {
						Focused = function()
							flag = true
							applyLook()
							reread(p.Text)
						end,
						FocusLost = function(p2, flag2: boolean)
							flag = false
							applyLook()

							if flag2 then
								local text

								if text2.Value == "" then
									text = p2.Text
								else
									text = text2.Value
								end

								clear()

								if text:match("%S") ~= nil then
									callback(text)
								end

								task.defer(function()
									if not object.IsActive or v3 == nil then
										return
									end

									v3:CaptureFocus()
								end)
							else
								text2:Set("")
								task.delay(0.25, function()
									if object.IsActive and not flag then
										value8:Set(false)
									end
								end)
							end
						end
					}
				end,
				TextOnChanged = function(object3, p: string)
					if object3:IsFocused() then
						reread(p)
					else
						text2:Set("")
					end
				end
			}),
			object:Create("TextLabel")({
				Name = "AutoComplete",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				TextColor3 = color4,
				ZIndex = -1,
				Text = text2,
				TextTransparency = 0.35,
				FontFace = rbxassetfontsfamiliesSourceSansProjson,
				TextScaled = false,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		}),
		object:State(function(callback2, object3)
			if callback2(value8) then
				return object3:Create("CanvasGroup")({
					Name = "Options",
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.fromScale(0, -0.1),
					Size = size2,
					BackgroundTransparency = 1,
					ZIndex = 4,
					OnClean = {
						GroupTransparency = object3:Animation(1, info4)
					},
					object3:Create("UICorner")({
						CornerRadius = UDim.new(0, (math.floor(v2 * 0.5)))
					}),
					object3:Create("Frame")({
						Name = "Holder",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						CleanDelay = info4.Time,
						object3:Create("UIListLayout")({
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center
						}),
						object3:AdvancedIterate(value6, function(layoutOrder: number, p2, object4)
							local flag2 = false
							local value9 = object4:Value(Color3.new(1, 1, 1))

							local function updPlate()
								if flag2 then
									value9:Set(color5)
								else
									value9:Reset()
								end
							end

							return object4:Create("TextButton")({
								Name = p2.Text,
								AutoButtonColor = false,
								LayoutOrder = layoutOrder,
								Size = object4:Animation(UDim2.new(1, 0, 0, v2), springInfo, {
									From = UDim2.new(1, 0, 0, v2 * 0.35)
								}),
								BackgroundColor3 = object4:Animation(value9, info3),
								ZIndex = 5,
								ClipsDescendants = true,
								CleanDelay = info4.Time,
								object4:Create("TextLabel")({
									Name = "Txt",
									Text = p2.Text,
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(1, 0.8),
									BackgroundTransparency = 1,
									ZIndex = 6,
									TextColor3 = Color3.new(),
									TextTransparency = object4:Animation(0, info2, {
										From = 1
									}),
									FontFace = rbxassetfontsfamiliesSourceSansProjson,
									TextSize = v2 * 0.8
								}),
								MouseEnter = function()
									flag2 = true
									value9:Set(color5)
								end,
								MouseLeave = function()
									flag2 = false
									value9:Reset()
								end,
								MouseButton1Click = function()
									ScreenEffects.CircleClick()
									take(p2) -- equivalent call inferred; original call site unknown
								end
							})
						end)
					})
				})
			end

			return nil
		end)
	})
end