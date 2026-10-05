local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local rbxassetfontsfamiliesSourceSansProjson = Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.SemiBold,
	Enum.FontStyle.Normal
)
local color = Color3.new(0.87, 0.87, 0.87)
local springInfo = faye.SpringInfo(0.3, 1, 0.5)
local info = faye.Info(0.3)
local info2 = faye.Info(0.2)
local info3 = faye.Info(0.125)
local color2 = Color3.new(0.14, 0.14, 0.14)
local color3 = Color3.new(0.24, 0.24, 0.24)
local color4 = Color3.new(1, 1, 1)
local color5 = Color3.new()
local uDim = UDim.new(0.6, 0)
local color6 = Color3.new(1, 1, 1)
local color7 = Color3.new()
local color8 = Color3.new(0.62, 0.62, 0.62)
local info4 = faye.Info(0.15)

local function starting(items, value: string)
	local lower = value:lower()
	local result = {}

	for _, item in items do
		if not (lower == "" or item:lower():sub(1, #lower) == lower) then
			continue
		end

		table.insert(result, item)
	end

	table.sort(result, function(a: string, b: string)
		return a:lower() < b:lower()
	end)

	while #result > 16 do
		table.remove(result)
	end

	return result
end

local function same(list, list2)
	if #list ~= #list2 then
		return false
	end

	for i = 1, #list do
		if list[i] ~= list2[i] then
			return false
		end
	end

	return true
end

return function(object, data, data2)
	local v = math.floor(data.Scale * 25)
	local v2 = math.floor(data.Scale * 10)
	local v3 = math.floor(data.Scale * 34)
	local value = object:Value({})
	local value2 = object:Value(0)
	local value3 = object:Value(false)
	local value4 = object:Value(data2.Initial or "")
	local flag = false
	local v4 = nil
	local textSize = object:Value(12)
	local size = object:Value(UDim2.new(0, v3, data.Height, 0))
	local value7 = object:Value(color2)
	local value8 = object:Value(0.12)
	local value9 = object:Value(color8)

	local function applyLook()
		if value4:Compare("") then
			if flag then
				value7:Set(color3)
				value8:Set(0.05)
				value9:Set(color6)
			else
				value7:Reset()
				value8:Reset()
				value9:Reset()
			end
		else
			value7:Set(color4)
			value8:Set(0)
			value9:Set(color7)
		end
	end

	local function reread(p: string)
		if data2.Locked or data2.Options == nil then
			value3:Set(false)
			return
		end

		local v5 = starting(data2.Options(), p)
		local v6 = value:Get()
		local v7

		if #v5 == #v6 then
			local flag2 = true

			for i = 1, #v5 do
				if v5[i] == v6[i] then
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
			value2:Set(0)
			value:Set(v5)
		end

		value3:Set(#v5 > 0)
	end

	applyLook()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function widen(X: number)
		local v5 = math.max(math.ceil(X) + v2 * 2 - size:Get().X.Offset, 0)

		if value2:Get() < v5 then
			value2:Set(v5)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function commit(text: string)
		value4:Set(text)
		value3:Set(false)

		if v4 ~= nil then
			v4.Text = text
		end

		applyLook()
		data2.OnCommit(text)
	end

	return object:Create("TextBox")({
		Name = "Segment",
		LayoutOrder = data2.LayoutOrder,
		Size = size,
		BackgroundColor3 = object:Animation(value7, info4),
		BackgroundTransparency = object:Animation(value8, info4),
		Text = data2.Initial or "",
		PlaceholderText = data2.Placeholder,
		PlaceholderColor3 = color8,
		TextColor3 = object:Animation(value9, info4),
		TextSize = textSize,
		FontFace = data.Font,
		TextEditable = not data2.Locked,
		ClearTextOnFocus = false,
		TextScaled = false,
		TextWrapped = false,
		TextXAlignment = Enum.TextXAlignment.Center,
		object:Create("UICorner")({
			CornerRadius = data.Corner
		}),
		object:Create("UIShadow")({
			Color = color5,
			BlurRadius = uDim,
			Transparency = 0.6
		}),
		AbsoluteSizeOnChangedInit = function(_, point: Vector2)
			textSize:Set((math.max(math.floor(point.Y * data.TextOfHeight), 1)))
		end,
		TextBoundsOnChangedInit = function(p)
			local v5 = math.max(math.ceil(p.TextBounds.X) + data.Pad * 2, v3)
			size:Set(UDim2.new(0, v5, data.Height, 0))
		end,
		function(p)
			v4 = p
			return {
				Focused = function()
					flag = true
					applyLook()
					reread(p.Text)
				end,
				FocusLost = function(p2, flag2: boolean)
					flag = false
					applyLook()

					if not flag2 then
						task.delay(0.25, function()
							if object.IsActive and not flag then
								value3:Set(false)
							end
						end)
						return
					end

					local v5 = value:Get()
					local v6

					if #v5 == 1 then
						v6 = v5[1]
					else
						v6 = p2.Text
					end

					commit(v6) -- equivalent call inferred; original call site unknown
				end
			}
		end,
		TextOnChanged = function(object2, p: string)
			if not object2:IsFocused() then
				return
			end

			if not value4:Compare(p) then
				value4:Set("")
				applyLook()
				data2.OnCommit("")
			end

			reread(p)
		end,
		object:State(function(callback, object2)
			if callback(value3) then
				return object2:Create("CanvasGroup")({
					Name = "Options",
					Position = UDim2.new(0, 0, 1, 4),
					Size = object2:Do(function(callback2)
						return UDim2.new(1, callback2(value2), 0, #callback2(value) * v)
					end),
					BackgroundTransparency = 1,
					ZIndex = 10,
					OnClean = {
						GroupTransparency = object2:Animation(1, info3)
					},
					object2:Create("UICorner")({
						CornerRadius = UDim.new(0, (math.floor(v * 0.5)))
					}),
					object2:Create("Frame")({
						Name = "Holder",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						CleanDelay = info3.Time,
						object2:Create("UIListLayout")({
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center
						}),
						object2:AdvancedIterate(value, function(layoutOrder: number, p2: string, object3)
							local flag2 = false
							local value10 = object3:Value(Color3.new(1, 1, 1))

							local function updPlate()
								if flag2 then
									value10:Set(color)
								else
									value10:Reset()
								end
							end

							return object3:Create("TextButton")({
								Name = p2,
								AutoButtonColor = false,
								LayoutOrder = layoutOrder,
								Size = object3:Animation(UDim2.new(1, 0, 0, v), springInfo, {
									From = UDim2.new(1, 0, 0, v * 0.35)
								}),
								BackgroundColor3 = object3:Animation(value10, info2),
								ZIndex = 11,
								ClipsDescendants = true,
								CleanDelay = info3.Time,
								object3:Create("TextLabel")({
									Name = "Txt",
									Text = p2,
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(1, 0.8),
									BackgroundTransparency = 1,
									ZIndex = 12,
									TextColor3 = Color3.new(),
									TextTransparency = object3:Animation(0, info, {
										From = 1
									}),
									FontFace = rbxassetfontsfamiliesSourceSansProjson,
									TextSize = math.floor(v * 0.8),
									TextBoundsOnChangedInit = function(p3)
										widen(p3.TextBounds.X) -- equivalent call inferred; original call site unknown
									end
								}),
								MouseEnter = function()
									flag2 = true
									value10:Set(color)
								end,
								MouseLeave = function()
									flag2 = false
									value10:Reset()
								end,
								MouseButton1Click = function()
									ScreenEffects.CircleClick()
									commit(p2) -- equivalent call inferred; original call site unknown
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