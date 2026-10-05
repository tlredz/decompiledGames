local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local faye = require(ReplicatedStorage.Packages.faye)
local v = RunService:IsStudio() and not RunService:IsRunning()
local v2 = {
	"Player1",
	"Player2",
	"Playful",
	"Tanjiro",
	"Zenitsu",
	"Nezuko"
}
local color = Color3.new(0.15, 0.15, 0.15)
local color2 = Color3.new(0.2, 0.2, 0.2)
local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.85) })
local numberSequence2 = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0) })
local color3 = Color3.new(0.87, 0.87, 0.87)
local color4 = Color3.fromRGB(130, 255, 160)
local color5 = Color3.fromRGB(20, 48, 30)
local color6 = Color3.new(1, 1, 1)
local color7 = Color3.new(0.6, 0.6, 0.6)
local info = faye.Info(0.15)
local rbxassetfontsfamiliesSourceSansProjson = Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.SemiBold,
	Enum.FontStyle.Normal
)
local springInfo = faye.SpringInfo(0.3, 1, 0.5)
local info2 = faye.Info(0.3)
local info3 = faye.Info(0.2)
local info4 = faye.Info(0.125)

local function namesHere()
	local names = {}

	for _, v3 in Players:GetPlayers() do
		if v3 ~= Players.LocalPlayer then
			table.insert(names, v3.Name)
		end
	end

	return names
end

local function findPlayer(value: string)
	if value == "" then
		return nil
	end

	local v3 = string.lower(value)

	for _, v4 in Players:GetPlayers() do
		if v4 ~= Players.LocalPlayer and string.lower(v4.Name) == v3 then
			return v4.Name
		end
	end

	local name = nil

	for _, v4 in Players:GetPlayers() do
		if not (v4 ~= Players.LocalPlayer and string.lower(v4.DisplayName) == v3) then
			continue
		end

		if name ~= nil then
			return nil
		end

		name = v4.Name
	end

	if name ~= nil then
		return name
	end

	if v then
		for _, v4 in v2 do
			if string.lower(v4) == v3 then
				return v4
			end
		end
	end

	return nil
end

local function matchesFor(value: string)
	local result = {}

	if value == "" then
		return result
	end

	local v3 = string.lower(value)

	for _, v4 in namesHere() do
		if string.sub(string.lower(v4), 1, #v3) ~= v3 then
			continue
		end

		table.insert(result, v4)
	end

	table.sort(result, function(a, b)
		if #a == #b then
			return a < b
		end

		return #a < #b
	end)

	while #result > 5 do
		table.remove(result)
	end

	return result
end

local function sameNames(list, list2)
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

return function(object, object2, object3)
	local text2 = object:Value("")
	local value2 = object:Value(color)
	local value3 = object:Value(0.25)
	local value4 = object:Value(numberSequence)
	local value5 = object:Value(1)
	local value6 = object:Value(color6)
	local size = object:Value(UDim2.new(1, -40, 0.8, 0))
	local value8 = object:Value({})
	local size2 = object:Value(UDim2.new(1, 0, 0, 0))
	local value10 = object:Value(false)
	local flag = false
	local v3 = nil

	local function applyLook()
		if object2:Compare("") then
			if flag then
				value2:Set(color2)
				value3:Set(0)
				value4:Set(numberSequence2)
			else
				value2:Reset()
				value3:Reset()
				value4:Reset()
			end

			value5:Reset()
			value6:Reset()
		else
			value2:Set(color5)
			value3:Set(0)
			value4:Set(numberSequence2)
			value5:Set(0.15)
			value6:Set(color4)
		end
	end

	local function clear()
		object2:Set("")
		object3:Set("")
		text2:Set("")
		value8:Set({})
		size2:Set(UDim2.new(1, 0, 0, 0))
		value10:Set(false)

		if v3 ~= nil then
			v3.Text = ""
		end

		applyLook()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resolve(value11: string)
		object2:Set(findPlayer(value11) or "")
		object3:Set((string.gsub(value11, "^%s*(.-)%s*$", "%1")))
		applyLook()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function take(text: string)
		if v3 ~= nil then
			v3.Text = text
		end

		text2:Set("")
		value10:Set(false)
		resolve(text) -- equivalent call inferred; original call site unknown
	end

	object:Connect(Players.ChildRemoved, function(player)
		if player:IsA("Player") and object2:Compare(player.Name) then
			clear()
		end
	end)
	return object:Create("Frame")({
		Name = "GiftBox",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = object:Animation(value2, info),
		BackgroundTransparency = object:Animation(value3, info),
		AbsoluteSizeOnChangedInit = function(_, point: Vector2)
			local v4 = point.Y * 0.5616
			size:Set(UDim2.new(1, -(10 + v4 + 16), 0.8, 0))
		end,
		object:Create("UIShadow")({
			Color = Color3.new(0.7, 0.7, 0.75),
			BlurRadius = UDim.new(0.8, 0),
			Transparency = 0.85
		}),
		object:Create("UIGradient")({
			Transparency = object:Animation(value4, info),
			Rotation = -90
		}),
		object:Create("UICorner")({
			CornerRadius = UDim.new(1)
		}),
		object:Create("UIStroke")({
			Color = color4,
			Thickness = 1,
			Transparency = object:Animation(value5, info)
		}),
		object:Create("ImageLabel")({
			Name = "Glyph",
			Size = UDim2.fromScale(0.5616, 0.5616),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 0.5, 0),
			BackgroundTransparency = 1,
			Image = BunchaIcons.Gift,
			ScaleType = Enum.ScaleType.Fit,
			object:Create("UIShadow")({
				BlurRadius = UDim.new(0.8, 0),
				Transparency = 0.7
			})
		}),
		object:Create("Frame")({
			Name = "Textboxholder",
			Size = size,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			BackgroundTransparency = 1,
			AbsoluteSizeOnChangedInit = function(instance)
				local textSize = math.max(math.floor(instance.AbsoluteSize.Y * 0.75), 1)

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
				TextColor3 = object:Animation(value6, info),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				Font = Enum.Font.SourceSansSemibold,
				PlaceholderColor3 = color7,
				PlaceholderText = "Gift to...",
				ClearTextOnFocus = false,
				function(p)
					v3 = p
					return {
						Focused = function()
							flag = true
							applyLook()
						end,
						FocusLost = function(p2, flag2: boolean)
							if flag2 and text2.Value ~= "" then
								p2.Text = text2.Value
							end

							text2:Set("")
							flag = false
							resolve(p2.Text) -- equivalent call inferred; original call site unknown
							task.delay(0.25, function()
								if object.IsActive and not flag then
									value10:Set(false)
								end
							end)
						end
					}
				end,
				TextOnChanged = function(object4, list: string)
					resolve(list) -- equivalent call inferred; original call site unknown

					if not object4:IsFocused() then
						text2:Set("")
						return
					end

					local v4 = matchesFor(list)
					local v5 = value8:Get()
					local v6

					if #v4 == #v5 then
						local flag2 = true

						for i = 1, #v4 do
							if v4[i] == v5[i] then
								continue
							end

							v6 = false
							flag2 = false
							break
						end

						if flag2 then
							v6 = true
						end
					else
						v6 = false
					end

					if not v6 then
						value8:Set(v4)
						size2:Set(UDim2.new(1, 0, 0, #v4 * 25))
					end

					value10:Set(#v4 > 0)
					local v7 = v4[1]
					text2:Set(v7 == nil and "" or list .. string.sub(v7, #list + 1, #v7))
				end
			}),
			object:Create("TextLabel")({
				Name = "AutoComplete",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				TextColor3 = color7,
				ZIndex = -1,
				Text = text2,
				TextTransparency = 0.35,
				Font = Enum.Font.SourceSansSemibold,
				TextScaled = false,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		}),
		object:State(function(callback, object4)
			if callback(value10) then
				return object4:Create("CanvasGroup")({
					Name = "Options",
					Position = UDim2.fromScale(0, 1.1),
					Size = size2,
					BackgroundTransparency = 1,
					ZIndex = 4,
					OnClean = {
						GroupTransparency = object4:Animation(1, info4)
					},
					object4:Create("UICorner")({
						CornerRadius = UDim.new(0, 12)
					}),
					object4:Create("Frame")({
						Name = "Holder",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						CleanDelay = info4.Time,
						object4:Create("UIListLayout")({
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center
						}),
						object4:AdvancedIterate(value8, function(layoutOrder: number, p2: string, object5)
							local flag2 = false
							local value11 = object5:Value(Color3.new(1, 1, 1))
							local value12 = object5:Value(Color3.new())

							local function updPlate()
								if flag2 then
									value11:Set(color3)
								else
									value11:Reset()
								end
							end

							return object5:Create("TextButton")({
								Name = p2,
								AutoButtonColor = false,
								LayoutOrder = layoutOrder,
								Size = object5:Animation(UDim2.new(1, 0, 0, 25), springInfo, {
									From = UDim2.new(1, 0, 0, 8.75)
								}),
								BackgroundColor3 = object5:Animation(value11, info3),
								ZIndex = 5,
								ClipsDescendants = true,
								CleanDelay = info4.Time,
								object5:Create("TextLabel")({
									Name = "Txt",
									Text = p2,
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(1, 0.8),
									BackgroundTransparency = 1,
									ZIndex = 6,
									TextColor3 = object5:Animation(value12, info3),
									TextTransparency = object5:Animation(0, info2, {
										From = 1
									}),
									FontFace = rbxassetfontsfamiliesSourceSansProjson,
									TextSize = 20
								}),
								MouseEnter = function()
									flag2 = true
									value11:Set(color3)
								end,
								MouseLeave = function()
									flag2 = false
									value11:Reset()
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