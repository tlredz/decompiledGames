local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local faye = require(ReplicatedStorage.Packages.faye)
local PlayerCommands = require(ReplicatedStorage.CAM.Global.PlayerCommands)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local CommandSegment = require(ReplicatedStorage.CAM.Client.Components.Misc.CommandSegment)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local v = RunService:IsStudio() and not RunService:IsRunning()
local Platform_Handler

if not v then
	Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
end

local scale = Platform_Handler ~= nil and Platform_Handler.Platform.Value == "Mobile" and 0.55 or 0.8
local v4 = scale * 0.663
local pad = math.floor(scale * 12)
local v6 = math.floor(scale * 6)
local uDim = UDim.new(0.5)
local rbxassetfontsfamiliesSourceSansProjson = Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.SemiBold,
	Enum.FontStyle.Normal
)
local color = Color3.new(0.06, 0.06, 0.06)
local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.45) })
local color2 = Color3.new()
local uDim2 = UDim.new(0.6, 0)
local v7 = math.floor(scale * 5)
local v8 = math.max(math.floor(scale * 3), 2)
local v9 = scale * 0.14
local uDim3 = UDim.new(0.5)
local v10 = math.floor(scale * 44)
local v11 = {
	Height = 1,
	TextOfHeight = 0.7764705882352941,
	Pad = pad,
	Corner = uDim,
	Font = rbxassetfontsfamiliesSourceSansProjson,
	Scale = scale
}
local color3 = Color3.fromRGB(64, 196, 108)
local color4 = Color3.fromRGB(26, 122, 60)
local color5 = Color3.new(1, 1, 1)
local colorSequence = ColorSequence.new(color3, color4)
local color6 = Color3.new(0.13, 0.13, 0.13)
local color7 = Color3.new(1, 1, 1)
local color8 = Color3.fromRGB(196, 64, 64)
local color9 = Color3.new(1, 1, 1)
local info = faye.Info(0.15)

local function build(object)
	local value = object:Value({})
	local value2 = object:Value(false)
	local value3 = object:Value(false)
	local value4 = object:Value("Spawn")
	local text = object:Value("Spawn")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyLabel()
		text:Set(value3:Get() and "" or value4:Get())
	end

	object:Connect(value3.Changed, applyLabel)
	object:Connect(value4.Changed, applyLabel)
	local value6 = object:Value("")
	local v12 = {}
	local value7 = object:Value(false)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function picked()
		if value6:Compare("") then
			return nil
		end

		return PlayerCommands.ByName(value6:Get())
	end

	local function recompute()
		local v13 = picked() -- equivalent call inferred; original call site unknown

		if v13 == nil then
			value7:Set(false)
			return
		end

		for k, arg in v13.Args do
			if not (arg.Required and (v12[k] == nil or v12[k] == "")) then
				continue
			end

			value7:Set(false)
			return
		end

		value7:Set(true)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clear()
		table.clear(v12)
		value6:Set("")
		recompute()
	end

	local function commandOptions()
		local v13 = value:Get()
		local names = {}

		for _, v14 in PlayerCommands.List do
			if v13[v14.Name] then
				table.insert(names, v14.Name)
			end
		end

		return names
	end

	local function run()
		local v13 = picked() -- equivalent call inferred; original call site unknown

		if v13 == nil or not value7:Compare(true) then
			return
		end

		local line = "/" .. v13.Name

		for _, v15 in v12 do
			if v15 ~= "" then
				line ..= " " .. v15
			end
		end

		clear() -- equivalent call inferred; original call site unknown
		value3:Set(false)

		if v then
			return
		end

		object:Spawn(function()
			pcall(SignalFunction.ToServer, "PlayerCommands", {
				action = "run",
				line = line
			})
		end)
	end

	local function retitle(p)
		for _, v13 in PlayerCommands.List do
			if not (p[v13.Name] and v13.Set == PlayerCommands.Sets.Private) then
				continue
			end

			value4:Set("Commands")
			return
		end

		value4:Set("Spawn")
	end

	if v then
		local v13 = {}

		for _, v14 in PlayerCommands.List do
			v13[v14.Name] = true
		end

		value:Set(v13)
		value2:Set(true)
		retitle(v13)
		applyLabel() -- equivalent call inferred; original call site unknown
	else
		object:Spawn(function()
			for _ = 1, 5 do
				local success, result = pcall(SignalFunction.ToServer, "PlayerCommands", {
					action = "list"
				})

				if not object.IsActive then
					break
				end

				if success and typeof(result) == "table" then
					value:Set(result)
					retitle(result)
					applyLabel() -- equivalent call inferred; original call site unknown
					local v13 = false

					for _ in result do
						v13 = true
						break
					end

					value2:Set(v13)
					break
				else
					task.wait(1)
				end
			end
		end)
	end

	return object:State(function(callback, object2)
		if not callback(value2) then
			return nil
		end

		local value8 = object2:Value(color6)
		local value9 = object2:Value(color7)
		local value10 = object2:Value(0.6)
		local value11 = object2:Value(1)
		local value12 = object2:Value(0.88)
		local value13 = object2:Value(0.85)

		local function applyPill()
			if value3:Get() then
				value8:Set(color8)
				value9:Set(color9)
				value10:Set(0.05)
				value11:Set(0)
				value12:Set(0.55)
				value13:Set(0.55)
			else
				value8:Reset()
				value9:Reset()
				value10:Reset()
				value11:Reset()
				value12:Reset()
				value13:Reset()
			end
		end

		object2:Connect(value3.Changed, applyPill)
		applyPill()
		local textSize = object2:Value(12)
		local size = object2:Value(UDim2.new(0, 0, 1, 0))
		local value16 = object2:Value(0)
		local value17 = object2:Value(0)

		local function remeasure()
			local v13 = value16:Get()
			local v14 = value17:Get()

			if not (v14 <= 0) then
				v13 = math.ceil(v14) + pad * 2
			end

			size:Set(UDim2.new(0, math.max(v13, 1), 1, 0))
		end

		return object2:Create("Frame")({
			Name = "2CommandsButton",
			Size = UDim2.new(0, 0, v4 + v9, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = color,
			BackgroundTransparency = object2:Animation(value12, info),
			object2:Create("UICorner")({
				CornerRadius = uDim3
			}),
			object2:Create("UIGradient")({
				Transparency = numberSequence,
				Rotation = 90
			}),
			object2:Create("UIShadow")({
				Color = color2,
				BlurRadius = uDim2,
				Transparency = object2:Animation(value13, info)
			}),
			object2:Create("UIPadding")({
				PaddingLeft = UDim.new(0, v7),
				PaddingRight = UDim.new(0, v7),
				PaddingTop = UDim.new(0, v8),
				PaddingBottom = UDim.new(0, v8)
			}),
			object2:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, v6)
			}),
			object2:Create("TextButton")({
				Name = "Pill",
				LayoutOrder = 1,
				AutoButtonColor = false,
				Size = size,
				BackgroundColor3 = object2:Animation(value8, info),
				BackgroundTransparency = object2:Animation(value10, info),
				AbsoluteSizeOnChangedInit = function(_, point: Vector2)
					textSize:Set((math.max(math.floor(point.Y * 0.7764705882352941), 1)))
					value16:Set(point.Y)
					remeasure()
				end,
				object2:Create("UICorner")({
					CornerRadius = uDim
				}),
				object2:Create("UIShadow")({
					Color = color2,
					BlurRadius = uDim2,
					Transparency = 0.55
				}),
				object2:Create("TextLabel")({
					Name = "Label",
					Text = text,
					Size = UDim2.new(1, -pad * 2, 1, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					TextColor3 = object2:Animation(value9, info),
					TextSize = textSize,
					TextScaled = false,
					TextWrapped = false,
					FontFace = rbxassetfontsfamiliesSourceSansProjson,
					TextBoundsOnChangedInit = function(p)
						value17:Set(p.TextBounds.X)
						remeasure()
					end
				}),
				object2:Create("ImageLabel")({
					Name = "Close",
					Image = "rbxassetid://120986271206642",
					ImageColor3 = object2:Animation(value9, info),
					ImageTransparency = object2:Animation(value11, info),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					ScaleType = Enum.ScaleType.Fit,
					Instance.new("UIAspectRatioConstraint")
				}),
				MouseButton1Click = function()
					ScreenEffects.CircleClick()
					local v13 = not value3:Get()
					value3:Set(v13)

					if not v13 then
						clear() -- equivalent call inferred; original call site unknown
					end
				end
			}),
			object2:State(function(callback2, object3)
				if not callback2(value3) then
					return nil
				end

				local initial = callback2(value6)
				local v14

				if initial ~= "" then
					v14 = PlayerCommands.ByName(initial)
				end

				return object3:Create("Frame")({
					Name = "Line",
					LayoutOrder = 2,
					Size = UDim2.new(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					object3:Create("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, v6)
					}),
					CommandSegment(object3, v11, {
						LayoutOrder = 1,
						Initial = initial,
						Placeholder = "command",
						Options = commandOptions,
						OnCommit = function(p: string)
							table.clear(v12)
							value6:Set(PlayerCommands.ByName(p) == nil and "" or p)
							recompute()
						end
					}),
					object3:Iterate(v14 == nil and {} or v14.Args, function(p: number, p2, p3)
						return CommandSegment(p3, v11, {
							LayoutOrder = p + 1,
							Initial = v12[p],
							Placeholder = p2.Name,
							Options = p2.Suggester ~= nil and function()
								local v15 = table.move(v12, 1, #v12, 1, {})
								return p2.Suggester(v15) or {}
							end or nil,
							OnCommit = function(p4: string)
								v12[p] = p4
								recompute()
							end
						})
					end),
					object3:State(function(callback3, object4)
						if callback3(value7) then
							return object4:Create("TextButton")({
								Name = "Run",
								LayoutOrder = 99,
								AutoButtonColor = false,
								Size = object4:Animation(UDim2.new(0, v10, 1, 0), info, {
									From = UDim2.new(0, v10 * 0.6, 1, 0)
								}),
								BackgroundColor3 = Color3.new(1, 1, 1),
								object4:Create("UICorner")({
									CornerRadius = uDim
								}),
								object4:Create("UIGradient")({
									Color = colorSequence,
									Rotation = 90
								}),
								object4:Create("ImageLabel")({
									Name = "Tick",
									Image = BunchaIcons.Checkmark,
									ImageColor3 = color5,
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(0.55, 0.55),
									SizeConstraint = Enum.SizeConstraint.RelativeYY,
									BackgroundTransparency = 1,
									ScaleType = Enum.ScaleType.Fit
								}),
								object4:Create("UIShadow")({
									Color = color2,
									BlurRadius = uDim2,
									Transparency = 0.55
								}),
								MouseButton1Click = function()
									ScreenEffects.CircleClick()
									run()
								end
							})
						end

						return nil
					end)
				})
			end)
		})
	end)
end

return function(instance)
	if typeof(instance) == "Instance" then
		local v12 = faye.new()
		return v12:Create("Frame")({
			Parent = instance,
			Name = "CommandBarPreview",
			Position = UDim2.fromOffset(16, 16),
			Size = UDim2.new(0, 400, 0, 36),
			BackgroundTransparency = 1,
			v12:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.Name
			}),
			build(v12)
		})
	end

	if instance ~= nil then
		return build(instance)
	end

	warn("[CommandBar] entry got nil. A viewer must pass the Instance to parent into.")
	return nil
end