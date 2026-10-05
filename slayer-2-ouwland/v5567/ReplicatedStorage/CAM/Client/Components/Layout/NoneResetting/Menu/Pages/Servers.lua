local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local ServerBrowserController = require(ReplicatedStorage.CAM.Client.Controllers.ServerBrowserController)
local Searchbar = require(ReplicatedStorage.CAM.Client.Components.Misc.Utilities.Searchbar)
local PageBrowser = require(ReplicatedStorage.CAM.Client.Components.Misc.PageBrowser)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Toggle = require(ReplicatedStorage.CAM.Client.Components.Misc.Toggle)
local ServerRow = require(script.ServerRow)
local v = Platform_Handler.Platform.Value == "Mobile"
local v2 = v and 0.8775000000000001 or 0.65
local color = Color3.new(0.15, 0.15, 0.15)
local color2 = Color3.fromRGB(155, 208, 255)
local color3 = Color3.new(0.87, 0.87, 0.87)
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
local Types = require(ReplicatedStorage.Communication.ServerAndClient.ServerBrowser.Types)
local clone = table.clone(Types.Regions)
table.insert(clone, 1, Types.All)

local function optionBars(object, p: number)
	local v3 = p == 1
	local v4 = p == #clone

	if v3 and v4 then
		return object:Create("Frame")({
			Size = UDim2.fromScale(1, 1),
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			})
		})
	end

	if v3 or v4 then
		return { object:Create("Frame")({
				Size = UDim2.fromScale(1, 1),
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				})
			}), object:Create("Frame")({
				Size = UDim2.fromScale(1, 0.5),
				Position = UDim2.fromScale(0, v3 and 0.5 or 0)
			}) }
	end

	return object:Create("Frame")({
		Size = UDim2.fromScale(1, 1)
	})
end

local v3 = v and 0.34 or 0.238
local v4 = v and 1.3 or 0.9099999999999999

local function pageArrow(maid, name: string, p2: number, object, object2, object3)
	local flag = false
	local value = maid:Value(0.15)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function upd()
		if not object:Compare(true) then
			value:Set(0.7)
		elseif flag then
			value:Set(0)
		else
			value:Reset()
		end
	end

	maid:Connect(object.Changed, upd)
	upd() -- equivalent call inferred; original call site unknown
	local v5 = p2 > 0
	local v6 = maid:Create("TextButton")
	local v7 = {
		Name = name,
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(v5 and 0 or 1, 0.5)
	}
	local v8

	if v5 then
		v8 = v3 / 2 + 0.015
	else
		v8 = -(v3 / 2 + 0.015)
	end

	v7.Position = UDim2.fromScale(v8 + 0.5, 0.5)
	v7.Size = UDim2.fromScale(1, v4)
	v7[1] = (maid:Create("UIAspectRatioConstraint")({}))
	v7.BackgroundTransparency = 1
	v7[2] = (maid:Create("ImageLabel")({
	Name = "Glyph",
	Image = BunchaIcons.ServerBrowser.Arrow,
	Rotation = v5 and 0 or 180,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.6, 0.6),
	BackgroundTransparency = 1,
	ImageTransparency = maid:Animation(value, info)
}))

	function v7.MouseEnter()
		flag = true
		upd() -- equivalent call inferred; original call site unknown
	end

	function v7.MouseLeave()
		flag = false
		upd() -- equivalent call inferred; original call site unknown
	end

	function v7.MouseButton1Click()
		if not object:Compare(true) then
			return
		end

		ScreenEffects.CircleClick()
		object2:Set((math.clamp(object2:Get() + p2, 1, object3:Get())))
	end

	return v6(v7)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rank(servers)
	local clone2 = table.clone(servers)
	table.sort(clone2, function(a, b)
		local isCurrentServer = ServerBrowserController.IsCurrentServer(a)

		if isCurrentServer ~= ServerBrowserController.IsCurrentServer(b) then
			return isCurrentServer
		end

		local v5 = a.Friends and #a.Friends or 0
		local v6 = b.Friends and #b.Friends or 0

		if v5 ~= v6 then
			return v6 < v5
		end

		if a.Players == b.Players then
			return a.Name < b.Name
		end

		return a.Players > b.Players
	end)
	return clone2
end

return function(maid, _)
	local miscShowFullServers = DataValue.new("Misc/ShowFullServers", true)
	local value = maid:Value(miscShowFullServers:Get() == true)
	maid:Add(function()
		miscShowFullServers:Destroy()
	end)
	maid:Connect(miscShowFullServers.Changed, function(p)
		value:Set(p == true)
	end)
	maid:Connect(value.Changed, function()
		local compare = value:Compare(true)

		if compare == (miscShowFullServers:Get() == true) then
			return
		end

		SignalEvent.ToServer("ShowFullServers", compare)
	end)
	local cached = ServerBrowserController.GetCached()
	local clone2 = table.clone(cached)
	table.sort(clone2, function(a, b)
		local isCurrentServer = ServerBrowserController.IsCurrentServer(a)

		if isCurrentServer ~= ServerBrowserController.IsCurrentServer(b) then
			return isCurrentServer
		end

		local v5 = a.Friends and #a.Friends or 0
		local v6 = b.Friends and #b.Friends or 0

		if v5 ~= v6 then
			return v6 < v5
		end

		if a.Players == b.Players then
			return a.Name < b.Name
		end

		return a.Players > b.Players
	end)

	local function listed()
		if value:Compare(true) then
			return clone2
		end

		local result = {}

		for _, v5 in clone2 do
			if not (v5.MaxPlayers <= 0 or v5.Players < v5.MaxPlayers or ServerBrowserController.IsCurrentServer(v5)) then
				continue
			end

			table.insert(result, v5)
		end

		return result
	end

	local value2 = maid:Value(1)
	local value3 = maid:Value(1)
	local value4 = maid:Value({})
	local value5 = maid:Value({})
	local text = maid:Value("")
	local visible = maid:Value(false)
	local value8 = maid:Value(false)
	local value9 = maid:Value(false)
	local visible2 = maid:Value(#listed() == 0)
	local all = ServerBrowserController.CurrentRegion()

	if all == Types.Unknown then
		all = Types.All
	end

	local value11 = maid:Value(all)
	local value12 = maid:Value(false)
	local value13 = maid:Value(color)
	local value14 = maid:Value(Color3.new(1, 1, 1))
	maid:Connect(value12.Changed, function()
		if value12:Get() then
			value13:Set(Color3.new(1, 1, 1))
			value14:Set(Color3.new())
		else
			value13:Reset()
			value14:Reset()
		end
	end)
	local value15 = maid:Value(0.8)
	local stringValue = Instance.new("StringValue")
	maid:Add(stringValue)
	local text2 = maid:Value(value11:Get())
	local v5 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function loading(flag: boolean)
		if flag then
			if v5 == nil then
				v5 = PopUpCreator.new({
					Type = "LoadingFull"
				})
			end
		elseif v5 ~= nil then
			v5:Destroy()
			v5 = nil
		end
	end

	maid:Add(function()
		loading(false) -- equivalent call inferred; original call site unknown
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function browse()
		local v6 = value11:Get()
		loading(true) -- equivalent call inferred; original call site unknown
		ServerBrowserController.Browse(nil, v6)
	end

	local function repaint()
		local v6 = listed()
		local v7 = math.max(1, (math.ceil(#v6 / 7)))
		local v8 = math.clamp(value2:Get(), 1, v7)
		local v9 = {}

		for i = (v8 - 1) * 7 + 1, math.min(v8 * 7, #v6) do
			table.insert(v9, v6[i])
		end

		local v10 = {}

		for i = 1, v7 do
			table.insert(v10, {
				Name = tostring(i)
			})
		end

		value3:Set(v7)
		value4:Set(v10)
		value5:Set(v9)
		text:Set((`Page {v8} of {v7}`))
		visible:Set(v7 > 1)
		value8:Set(v8 > 1)
		value9:Set(v8 < v7)
	end

	maid:Connect(ServerBrowserController.Updated, function(p)
		clone2 = rank(p.Servers)
		value2:Set(1)
		repaint()

		if p.Partial then
			return
		end

		loading(false) -- equivalent call inferred; original call site unknown
		visible2:Set(#listed() == 0)
	end)
	maid:Connect(ServerBrowserController.Failed, function()
		loading(false) -- equivalent call inferred; original call site unknown
		clone2 = {}
		value2:Set(1)
		repaint()
		visible2:Set(true)
	end)
	maid:Connect(value2.Changed, repaint)
	maid:Connect(value.Changed, function()
		value2:Set(1)
		repaint()
		visible2:Set(#listed() == 0)
	end)
	maid:Connect(stringValue:GetPropertyChangedSignal("Value"), function()
		if #stringValue.Value >= Types.MinQuery and v5 == nil then
			v5 = PopUpCreator.new({
				Type = "LoadingFull"
			})
		end

		ServerBrowserController.Search(nil, stringValue.Value)
	end)
	maid:Connect(value11.Changed, function()
		text2:Set(value11:Get())
		value12:Set(false)
		stringValue.Value = ""
		browse() -- equivalent call inferred; original call site unknown
	end)
	repaint()
	browse() -- equivalent call inferred; original call site unknown
	return maid:Create("Frame")({
		Name = "Servers",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
		maid:Create("UIGradient")({
			Rotation = -90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.8),
				NumberSequenceKeypoint.new(1, 0.95)
			})
		}),
		Size = maid:Animation(UDim2.fromScale(v2, v2), maid.SpringInfo(0.35, 1, 0.65), {
			From = UDim2.fromScale(v2 * 0.9, v2 * 0.9)
		}),
		maid:Create("UIAspectRatioConstraint")({
			AspectRatio = 1.3
		}),
		maid:Create("UICorner")({
			CornerRadius = UDim.new(0.02)
		}),
		maid:Create("Frame")({
			Name = "SearchbarHolder",
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromScale(0.03, 0.04),
			Size = UDim2.fromScale(0.32, 0.06),
			BackgroundTransparency = 1,
			(Searchbar(maid, {}, stringValue, "Search by name", true))
		}),
		maid:Create("Frame")({
			Name = "RegionHolder",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(0.575, 0.04),
			Size = UDim2.fromScale(0.2, 0.06),
			BackgroundTransparency = 1,
			ZIndex = 3,
			maid:Create("TextButton")({
				Name = "Pill",
				AutoButtonColor = false,
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = maid:Animation(value13, info),
				maid:Create("UICorner")({
					CornerRadius = UDim.new(0.2)
				}),
				maid:Create("UIStroke")({
					Color = Color3.new(1, 1, 1),
					Transparency = 0.8
				}),
				maid:Create("TextLabel")({
					Name = "Label",
					Text = text2,
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(0.08, 0.5),
					Size = UDim2.fromScale(0.7, 0.55),
					BackgroundTransparency = 1,
					TextColor3 = maid:Animation(value14, info),
					Font = Enum.Font.SourceSansSemibold,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left
				}),
				maid:Create("Frame")({
					Name = "ChevronCell",
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.fromScale(1, 0.5),
					Size = UDim2.fromScale(0.3, 1),
					BackgroundTransparency = 1,
					maid:Create("ImageLabel")({
						Name = "Chevron",
						Image = BunchaIcons.ServerBrowser.Dropdown,
						ImageColor3 = maid:Animation(value14, info),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.5, 0.5),
						BackgroundTransparency = 1,
						ScaleType = Enum.ScaleType.Fit
					})
				}),
				MouseButton1Click = function()
					ScreenEffects.CircleClick()
					value12:Set(not value12:Get())
				end
			}),
			maid:State(function(callback, object)
				if callback(value12) then
					return object:Create("Frame")({
						Name = "Options",
						Position = UDim2.fromScale(0, 1.1),
						Size = UDim2.new(1, 0, 0, #clone * 25),
						BackgroundTransparency = 1,
						ZIndex = 4,
						object:Create("UIListLayout")({
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Center
						}),
						object:Iterate(clone, function(layoutOrder: number, p2: string, object2)
							local flag = false
							local value17 = object2:Value(0)
							local value18 = object2:Value(Color3.new(1, 1, 1))
							local value19 = object2:Value(Color3.new())

							local function updPlate()
								if value11:Get() == p2 then
									value18:Set(color2)
									value19:Set(Color3.new())
									value17:Set(0)
								elseif flag then
									value18:Set(color3)
									value19:Set(Color3.new())
									value17:Set(0)
								else
									value18:Reset()
									value19:Reset()
									value17:Reset()
								end
							end

							object2:Connect(value11.Changed, updPlate)
							updPlate()
							return object2:Create("TextButton")({
								Name = p2,
								AutoButtonColor = false,
								LayoutOrder = layoutOrder,
								Size = object2:Animation(UDim2.new(1, 0, 0, 25), springInfo, {
									From = UDim2.new(1, 0, 0, 8.75)
								}),
								BackgroundTransparency = 1,
								ZIndex = 5,
								ClipsDescendants = true,
								OnClean = function(object3)
									return {
										Size = object3:Animation(UDim2.new(1, 0, 0, 0), info4)
									}
								end,
								object2:Create("CanvasGroup")({
									Name = "Bg",
									Size = UDim2.fromScale(1, 1),
									BackgroundTransparency = 1,
									GroupColor3 = object2:Animation(value18, info3),
									GroupTransparency = object2:Animation(value17, info3),
									optionBars(object2, layoutOrder)
								}),
								object2:Create("TextLabel")({
									Name = "Txt",
									Text = p2,
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									Size = UDim2.fromScale(1, 0.8),
									BackgroundTransparency = 1,
									ZIndex = 6,
									TextColor3 = object2:Animation(value19, info3),
									TextTransparency = object2:Animation(0, info2, {
										From = 1
									}),
									FontFace = rbxassetfontsfamiliesSourceSansProjson,
									TextSize = 20
								}),
								MouseEnter = function()
									flag = true
									updPlate()
								end,
								MouseLeave = function()
									flag = false
									updPlate()
								end,
								MouseButton1Click = function()
									ScreenEffects.CircleClick()
									value11:Set(p2)
								end
							})
						end)
					})
				end

				return nil
			end)
		}),
		Toggle(maid, value, "Show full servers", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(0.895, 0.04),
			Size = UDim2.fromScale(0.3, 0.06)
		}),
		maid:Create("Frame")({
			Name = "RefreshHolder",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(0.97, 0.04),
			Size = UDim2.fromScale(0.06, 0.06),
			BackgroundTransparency = 1,
			maid:Create("UIAspectRatioConstraint")({}),
			maid:Create("ImageButton")({
				Name = "Refresh",
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
				maid:Create("UICorner")({
					CornerRadius = UDim.new(0.2)
				}),
				maid:Create("UIStroke")({
					Color = Color3.new(1, 1, 1),
					Transparency = maid:Animation(value15, maid.Info(0.2))
				}),
				maid:Create("ImageLabel")({
					Name = "Icon",
					Image = BunchaIcons.ServerBrowser.Refresh,
					ImageColor3 = Color3.new(1, 1, 1),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.6, 0.6),
					BackgroundTransparency = 1
				}),
				MouseEnter = function()
					value15:Set(0.2)
				end,
				MouseLeave = function()
					value15:Reset()
				end,
				MouseButton1Click = function()
					ScreenEffects.CircleClick()
					browse() -- equivalent call inferred; original call site unknown
				end
			})
		}),
		maid:Create("Frame")({
			Name = "List",
			Position = UDim2.fromScale(0.03, 0.13),
			Size = UDim2.fromScale(0.94, 0.74),
			BackgroundTransparency = 1,
			maid:Create("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0.012, 0)
			}),
			maid:Iterate(value5, function(layoutOrder: number, p2, object)
				return object:Create("Frame")({
					Name = tostring(layoutOrder),
					LayoutOrder = layoutOrder,
					Size = UDim2.fromScale(1, 0.13257142857142856),
					BackgroundTransparency = 1,
					ServerRow(object, p2)
				})
			end)
		}),
		maid:Create("Frame")({
			Name = "Footer",
			Visible = visible,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.97),
			Size = UDim2.fromScale(0.94, 0.06),
			BackgroundTransparency = 1,
			pageArrow(maid, "Prev", -1, value8, value2, value3),
			pageArrow(maid, "Next", 1, value9, value2, value3),
			maid:Create("CanvasGroup")({
				Name = "StripGroup",
				Size = UDim2.fromScale(v3, v4),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				maid:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.08, 0),
						NumberSequenceKeypoint.new(0.92, 0),
						NumberSequenceKeypoint.new(1, 1)
					})
				}),
				PageBrowser(maid, value2, value4, {
					Size = UDim2.fromScale(0.9, 1),
					Position = UDim2.fromScale(0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0),
					Padding = UDim.new(0, 6),
					HugPad = 18,
					Overflow = true,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					TextXAlignment = Enum.TextXAlignment.Center,
					Backdrop = false
				})
			}),
			function(instance)
				local function follow()
					local stripGroup = instance:FindFirstChild("StripGroup")
					local pageBrowser = stripGroup ~= nil and stripGroup:FindFirstChild("page Browser") or nil
					local pageBrowser2 = pageBrowser ~= nil and pageBrowser:FindFirstChild("page Browser") or nil

					if pageBrowser2 == nil or not pageBrowser2:IsA("ScrollingFrame") then
						return
					end

					local frames = {}

					for _, frame in pageBrowser2:GetChildren() do
						if frame:IsA("Frame") then
							table.insert(frames, frame)
						end
					end

					table.sort(frames, function(a, b)
						return a.AbsolutePosition.X < b.AbsolutePosition.X
					end)
					local v6 = frames[value2:Get()]

					if v6 == nil then
						return
					end

					local v7 = v6.AbsolutePosition.X - pageBrowser2.AbsolutePosition.X + pageBrowser2.CanvasPosition.X
					local v8 = v7 + v6.AbsoluteSize.X
					local X = pageBrowser2.AbsoluteWindowSize.X
					local X2 = pageBrowser2.CanvasPosition.X

					if v7 < X2 then
						X2 = v7
					elseif X2 + X < v8 then
						X2 = v8 - X
					end

					pageBrowser2.CanvasPosition = Vector2.new(math.max(0, X2), 0)
				end

				maid:Connect(value2.Changed, function()
					task.defer(follow)
				end)
			end,
			maid:Create("TextLabel")({
				Name = "PageLabel",
				Text = text,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromScale(0.2, 0.6),
				BackgroundTransparency = 1,
				TextColor3 = Color3.new(0.7, 0.7, 0.7),
				Font = Enum.Font.SourceSans,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right
			})
		}),
		maid:Create("Frame")({
			Name = "NoServers",
			Visible = visible2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.4, 0.25),
			BackgroundTransparency = 1,
			maid:Create("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0.05, 0)
			}),
			maid:Create("ImageLabel")({
				Name = "Icon",
				LayoutOrder = 1,
				Image = BunchaIcons.ServerBrowser.NoServers,
				ImageColor3 = Color3.new(0.45, 0.45, 0.45),
				Size = UDim2.fromScale(0.4, 0.6),
				BackgroundTransparency = 1,
				maid:Create("UIAspectRatioConstraint")({})
			}),
			maid:Create("TextLabel")({
				Name = "Label",
				LayoutOrder = 2,
				Text = "No servers were found!",
				TextColor3 = Color3.new(0.45, 0.45, 0.45),
				Font = Enum.Font.SourceSansSemibold,
				TextScaled = true,
				Size = UDim2.fromScale(1, 0.15),
				BackgroundTransparency = 1
			})
		})
	})
end