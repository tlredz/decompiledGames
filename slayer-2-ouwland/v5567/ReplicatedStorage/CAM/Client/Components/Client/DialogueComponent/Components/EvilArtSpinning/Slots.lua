local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Slot = require(script.Slot)
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local GradientButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.GradientButton)
require(ReplicatedStorage.CAM.Global.Policies)
local BunchaIcons = require(ReplicatedStorage.CAM.Global.BunchaIcons)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local VipAccess = require(ReplicatedStorage.CAM.Global.VipAccess)
require(ReplicatedStorage.CAM.Global.Subscriptions)
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.35)
local color = Color3.fromRGB(85, 170, 255)
local color2 = Color3.fromRGB(255, 200, 60)

local function actionButton(object, text: string, color3: Color3, fn)
	return GradientButton(object, {
		GradientRotation = -90,
		Text = text,
		BgColor = color3,
		Clicked = fn,
		TextXAlignment = Enum.TextXAlignment.Center,
		Properties = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5)
		},
		GradientTransparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0.5)
		})
	})
end

return function(object, flag: boolean)
	local data = Utility.GetData(Players.LocalPlayer, true)
	local v = data.Spinning[flag and "ClanBag" or "EABag"]
	local value = object:Value("One")
	local localPlayer = Players.LocalPlayer
	local value2 = object:Value(VipAccess.Has(localPlayer))
	object:Connect(VipAccess.Changed(), function()
		value2:Set(VipAccess.Has(localPlayer))
	end)
	local clan

	if flag then
		clan = data.Clan
	else
		clan = data.Powers.DemonArt
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function nameOf(p: string)
		if p == "" or p == "None" then
			return "Nothing"
		end

		return p
	end

	local flag2 = false

	local function act(p: string)
		if flag2 or not value2.Value then
			return
		end

		flag2 = true
		task.spawn(function()
			local child = v:FindFirstChild(value.Value)

			if child == nil then
				flag2 = false
				return
			end

			local v2

			if p == "Set" then
				v2 = clan.Value
			else
				v2 = child.Value
			end

			local v3 = nameOf(v2) -- equivalent call inferred; original call site unknown
			local new = PopUpCreator.new
			local content

			if p == "Set" then
				content = `Are you sure you want to save {Utility.NameTag(v3, true)} to this slot?`
			else
				content = `Are you sure you want to load {Utility.NameTag(v3, true)}?`
			end

			if new({
				Type = "Question",
				Content = content
			}):WaitResult() ~= "Yes" then
				flag2 = false
				return
			end

			local v6 = PopUpCreator.new({
				Type = "LoadingFull"
			})
			pcall(SignalFunction.ToServer, "SpinBag", p, flag, value.Value)
			v6:Destroy()
			flag2 = false
		end)
	end

	return object:Create("Frame")({
		Name = "ActualSlotHolder",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		object:State(function(callback, object2, _)
			if callback(value2) then
				return
			else
				return object2:Create("CanvasGroup")({
					Name = "VipCover",
					ZIndex = 99,
					Size = UDim2.new(1, 4, 1, 4),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					OnClean = {
						GroupTransparency = object2:Animation(1, info)
					},
					object2:Create("TextButton")({
						ZIndex = 99,
						CleanDelay = info.Time,
						MouseButton1Click = function(p)
							if flag2 then
								return
							end

							flag2 = true
							ScreenEffects.StrokeClick(p.Parent, UDim.new(0.2))
							local v2 = PopUpCreator.new({
								Type = "LoadingFull"
							})
							VipAccess.PromptPurchase()
							v2:Destroy()
							flag2 = false
						end,
						BackgroundTransparency = 0.05,
						Selectable = true,
						AutoButtonColor = false,
						Size = UDim2.new(1, 4, 1, 4),
						BackgroundColor3 = Color3.new(),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						object2:Create("UICorner")({
							CornerRadius = UDim.new(0.2)
						}),
						object2:Create("UIGradient")({
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 0),
								NumberSequenceKeypoint.new(1, 0.5)
							}),
							Rotation = -90
						}),
						object2:Create("UIListLayout")({
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							FillDirection = Enum.FillDirection.Vertical
						}),
						object2:Create("ImageLabel")({
							Size = UDim2.fromScale(0.3, 0.3),
							Instance.new("UIAspectRatioConstraint"),
							BackgroundTransparency = 1,
							Image = BunchaIcons.Locked
						}),
						object2:Create("TextLabel")({
							Size = UDim2.new(1, -4, 0.5),
							BackgroundTransparency = 1,
							TextColor3 = Color3.new(1, 1, 1),
							Text = `Purchase VIP to load and save your {flag and "Clans" or "Evil Arts"}! (Click me)`,
							TextScaled = true,
							Font = Enum.Font.SourceSansSemibold
						})
					})
				})
			end
		end),
		object:Create("UIShadow")({
			BlurRadius = UDim.new(0.5),
			Transparency = 0.5
		}),
		object:Create("Frame")({
			Name = "Holder",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			object:Create("UIListLayout")({
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0.05)
			}),
			object:Create("Frame")({
				Name = "ASet",
				Size = UDim2.fromScale(0.8, 0.2),
				BackgroundTransparency = 1,
				actionButton(object, "Set", color, function()
					if not flag2 then
						if not value2.Value then
							return
						end

						flag2 = true
						local v2 = "Set"
						task.spawn(function()
							local child = v:FindFirstChild(value.Value)

							if child == nil then
								flag2 = false
								return
							end

							local v3

							if v2 == "Set" then
								v3 = clan.Value
							else
								v3 = child.Value
							end

							local v4 = nameOf(v3) -- equivalent call inferred; original call site unknown
							local new = PopUpCreator.new
							local content

							if v2 == "Set" then
								content = `Are you sure you want to save {Utility.NameTag(v4, true)} to this slot?`
							else
								content = `Are you sure you want to load {Utility.NameTag(v4, true)}?`
							end

							if new({
								Type = "Question",
								Content = content
							}):WaitResult() ~= "Yes" then
								flag2 = false
								return
							end

							local v7 = PopUpCreator.new({
								Type = "LoadingFull"
							})
							pcall(SignalFunction.ToServer, "SpinBag", v2, flag, value.Value)
							v7:Destroy()
							flag2 = false
						end)
					end
				end)
			}),
			object:Create("Frame")({
				Name = "BLoad",
				Size = UDim2.fromScale(0.8, 0.2),
				BackgroundTransparency = 1,
				actionButton(object, "Load", color2, function()
					if not flag2 then
						if not value2.Value then
							return
						end

						flag2 = true
						local v2 = "Load"
						task.spawn(function()
							local child = v:FindFirstChild(value.Value)

							if child == nil then
								flag2 = false
								return
							end

							local v3

							if v2 == "Set" then
								v3 = clan.Value
							else
								v3 = child.Value
							end

							local v4 = nameOf(v3) -- equivalent call inferred; original call site unknown
							local new = PopUpCreator.new
							local content

							if v2 == "Set" then
								content = `Are you sure you want to save {Utility.NameTag(v4, true)} to this slot?`
							else
								content = `Are you sure you want to load {Utility.NameTag(v4, true)}?`
							end

							if new({
								Type = "Question",
								Content = content
							}):WaitResult() ~= "Yes" then
								flag2 = false
								return
							end

							local v7 = PopUpCreator.new({
								Type = "LoadingFull"
							})
							pcall(SignalFunction.ToServer, "SpinBag", v2, flag, value.Value)
							v7:Destroy()
							flag2 = false
						end)
					end
				end)
			}),
			object:Create("Frame")({
				Name = "SlotsHolder",
				Size = UDim2.fromScale(1, 0.4),
				BackgroundTransparency = 1,
				object:State(function(callback, object2)
					if not callback(value2) then
						return
					end

					local canvasSize = object2:Value(UDim2.new())
					local v2 = nil

					local function centreCanvas()
						if v2 == nil or v2.Parent == nil then
							return
						end

						local v3 = math.max(v2.AbsoluteCanvasSize.X - v2.AbsoluteWindowSize.X, 0)
						v2.CanvasPosition = Vector2.new(v3 / 2, 0)
					end

					local v3 = object2:Create("CanvasGroup")
					local v4 = {
						Name = "Slots",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1
					}
					local v5

					if flag then
						v5 = object2:Create("UIGradient")({
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(0.25, 0),
								NumberSequenceKeypoint.new(0.75, 0),
								NumberSequenceKeypoint.new(1, 1)
							})
						}) or nil
					end

					do local _values = table.pack(v5, object2:Create("ScrollingFrame")({
	Name = "Scroller",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 0,
	ScrollingDirection = Enum.ScrollingDirection.X,
	CanvasSize = canvasSize,
	function(p)
		v2 = p
		task.defer(centreCanvas)
	end,
	object2:Create("UIListLayout")({
		Name = "List",
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 2),
		AbsoluteContentSizeOnChangedInit = function(_, point: Vector2)
			canvasSize:Set(UDim2.fromOffset(point.X * 1.3, 0))
			task.defer(centreCanvas)
		end
	}),
	object2:Iterate(v:GetChildren(), function(_, p, p2, _)
		return Slot(p2, value, p)
	end)
})); for _k = 1, _values.n do v4[_k] = _values[_k] end end
					return v3(v4)
				end)
			})
		})
	})
end