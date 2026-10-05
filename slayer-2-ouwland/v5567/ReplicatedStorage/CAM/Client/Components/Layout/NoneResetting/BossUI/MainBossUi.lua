local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.MiscTypes)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local DayAndNightHandler = require(ReplicatedStorage.CAM.Global.DayAndNightHandler)
local Countdownmode = require(script.Parent.Countdownmode)
local Regularmode = require(script.Parent.Regularmode)
local faye = require(ReplicatedStorage.Packages.faye)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local info = faye.Info(0.2)

-- equivalent calls inferred from this helper; original call sites unknown
local function panelWidth()
	if Platform_Handler.Platform.Value == "Mobile" then
		return 0.6000000000000001
	end

	local viewportSize = workspace.CurrentCamera.ViewportSize

	if viewportSize.X <= 0 then
		return 0.5
	end

	return (math.clamp(math.max(0.5, 672 / viewportSize.X), 0.5, 0.9))
end

return function(object, parent2, data, p2: number, value: number?)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function nightWaiting(p3: number)
		return p3 <= 0 and data.Folder ~= nil and data.Folder:GetAttribute("OnlyAtNight") == true and DayAndNightHandler.IsEnabled() and not DayAndNightHandler.IsNight()
	end

	local v = panelWidth() -- equivalent call inferred; original call site unknown
	local value2 = object:Value(v)
	object:Connect(Platform_Handler.Platform.Changed.Event, function()
		local v3 = panelWidth() -- equivalent call inferred; original call site unknown
		value2:Set(v3)
	end)
	object:Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
		local v3 = panelWidth() -- equivalent call inferred; original call site unknown
		value2:Set(v3)
	end)
	local value3 = object:Value(value or 0)
	local v2

	if (value or 0) <= 0 and data.Folder ~= nil and data.Folder:GetAttribute("OnlyAtNight") == true then
		v2 = DayAndNightHandler.IsEnabled() and not DayAndNightHandler.IsNight()
	else
		v2 = false
	end

	local value4 = object:Value(v2)
	local value5 = object:Value(p2)
	object:Create("Frame")({
		Name = "BossUi",
		ZIndex = -1,
		CleanDelay = 0.2,
		Size = object:Do(function(callback)
			local v3 = callback(value2)
			return UDim2.fromScale(v3, v3)
		end),
		Parent = parent2,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.05),
		BackgroundTransparency = 1,
		object:Create("UIAspectRatioConstraint")({
			AspectRatio = 1.6
		}),
		object:Create("Frame")({
			Name = "Identity",
			Size = UDim2.fromScale(0.1, 0.085),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0.05),
			BackgroundTransparency = 1,
			object:Create("Frame")({
				Size = UDim2.new(1, 16, 1, 12),
				BackgroundTransparency = object:Animation(0.75, info, {
					From = 1
				}),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.new(),
				OnClean = function()
					return {
						BackgroundTransparency = object:Animation(1, info)
					}
				end,
				object:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 0.9)
					}),
					Rotation = 110
				}),
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				})
			}),
			object:Create("Frame")({
				Name = "Holder",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				object:Create("UIListLayout")({
					Name = "List",
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 5)
				}),
				object:Create("Frame")({
					Name = "IconHolder",
					Instance.new("UIAspectRatioConstraint"),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					function()
						local icon = data.Folder.Parent:GetAttribute("Icon")

						if icon == nil then
							return
						else
							return object:Create("ImageLabel")({
								Size = UDim2.fromScale(1, 1),
								object:Create("UIAspectRatioConstraint")({}),
								BackgroundTransparency = 1,
								Image = "rbxassetid://16873598266",
								ImageColor3 = Color3.new(0.5, 0.5, 0.5),
								object:Create("ImageLabel")({
									Size = UDim2.fromScale(1.25, 1.25),
									BackgroundTransparency = 1,
									Image = "rbxassetid://73740284823020",
									ImageColor3 = Color3.new(0.15, 0.15, 0.15),
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0.5, 0.5),
									ImageTransparency = object:Animation(0.5, info, {
										From = 1
									}),
									OnClean = function()
										return {
											ImageTransparency = object:Animation(1, info)
										}
									end
								}),
								object:Create("ImageLabel")({
									ZIndex = 2,
									BackgroundTransparency = 1,
									Size = UDim2.fromScale(1, 1),
									Image = icon,
									ImageTransparency = object:Animation(0, info, {
										From = 1
									}),
									OnClean = function()
										return {
											ImageTransparency = object:Animation(1, info)
										}
									end,
									object:Create("UICorner")({
										CornerRadius = UDim.new(1)
									})
								})
							})
						end
					end
				}),
				object:Create("Frame")({
					Size = UDim2.fromScale(200, 1),
					Name = "zText",
					BackgroundTransparency = 1,
					object:Create("TextLabel")({
						Position = UDim2.fromScale(0, 0.05),
						Size = UDim2.fromScale(1, 0.4),
						BackgroundTransparency = 1,
						TextScaled = true,
						TextColor3 = Color3.new(1, 1, 1),
						TextTransparency = object:Animation(0.25, info, {
							From = 1
						}),
						Text = data.Title or "Boss",
						TextXAlignment = Enum.TextXAlignment.Left,
						Font = Enum.Font.SourceSansBold,
						OnClean = function()
							return {
								TextTransparency = object:Animation(1, info)
							}
						end,
						object:Create("UIStroke")({
							Thickness = 2,
							Transparency = 0.925,
							Color = Color3.new()
						})
					}),
					object:Create("TextLabel")({
						Size = UDim2.fromScale(1, 0.6),
						Name = "Txt",
						Position = UDim2.fromScale(0, 0.4),
						BackgroundTransparency = 1,
						TextScaled = true,
						Text = data.Folder.Parent.Name,
						TextColor3 = Color3.new(1, 1, 1),
						FontFace = Font.new("rbxassetid://12187365769", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
						TextTransparency = object:Animation(0, info, {
							From = 1
						}),
						OnClean = function()
							return {
								TextTransparency = object:Animation(1, info)
							}
						end,
						object:Create("UIStroke")({
							Thickness = 3,
							Transparency = 0.925,
							Color = Color3.new()
						})
					})
				}),
				After = function(p3)
					local parent = p3.Parent
					local zText = parent.Holder.zText
					local v3 = math.max(zText.Txt.TextBounds.X, zText.TextLabel.TextBounds.X)
					zText.Size = UDim2.new(0, v3, 1)
					parent.Size = UDim2.fromScale(
						parent.Holder.List.AbsoluteContentSize.X / parent.Parent.AbsoluteSize.X,
						parent.Size.Y.Scale
					)
					zText.Size = UDim2.fromScale(v3 / parent.AbsoluteSize.X, 1)
				end
			})
		}),
		object:State(function(callback, p3, _)
			if callback(value5) == 2 then
				return Countdownmode(p3, value3, value4)
			end

			return Regularmode(p3, data)
		end)
	})

	local function updatemode()
		value5:Set(data.Mode)
	end

	local function updatetime()
		if data.Mode == 2 then
			local despawnedAt = data.Folder.Parent:GetAttribute("DespawnedAt")
			local v3 = despawnedAt == nil and 0 or math.floor((data.Folder:GetAttribute("SpawnTime") or 0) - (Utility.Tick() - despawnedAt))
			value3:Set(v3)
			value4:Set(nightWaiting(v3))
		end
	end

	return updatemode, updatetime
end