local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PopUpCreator = require(ReplicatedStorage.CAM.Global.Subsets.Classes.PopUpCreator)
require(ReplicatedStorage.CAM.Global.gameSettings)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.25)
local info2 = faye.Info(0.6)
local info3 = faye.Info(0.3, Enum.EasingStyle.Back)
local info4 = faye.Info(0.7)
local info5 = faye.Info(0.4, Enum.EasingStyle.Back)
local info6 = faye.Info(0.8, Enum.EasingStyle.Quad)
local color = Color3.new(0.55, 0.55, 0.55)
return function(animator, p, data, p2: number)
	local content = data.Content
	local text = typeof(content) ~= "table" and (content or "") or content.Text or ""
	local color2 = data.Color or Color3.new(1, 1, 1)

	if typeof(data.Sound) == "string" then
		local assets = ReplicatedStorage:FindFirstChild("Assets")
		local sounds

		if assets ~= nil then
			sounds = assets:FindFirstChild("Sounds") or nil
		end

		local bigMessage

		if sounds ~= nil then
			bigMessage = sounds:FindFirstChild("BigMessage") or nil
		end

		local sound

		if bigMessage ~= nil then
			sound = bigMessage:FindFirstChild(data.Sound) or nil
		end

		if sound ~= nil and sound:IsA("Sound") then
			sound.TimePosition = 0
			sound:Play()
		end
	end

	local Y = GuiService:GetGuiInset().Y
	local parent = p.Parent or p
	local v2 = parent:FindFirstChild("BigMessageCounter")

	if v2 == nil then
		v2 = Instance.new("Frame")
		v2.Name = "BigMessageCounter"
		v2.Size = UDim2.new(1, 0, 1, Y)
		v2.Position = UDim2.fromOffset(0, -Y)
		v2.BackgroundColor3 = Color3.new()
		v2.BackgroundTransparency = 1
		v2.ZIndex = p.ZIndex
		v2.Parent = parent
		local frame = Instance.new("Frame", v2)
		frame.Name = "Holder"
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundTransparency = 1
		local textButton = Instance.new("TextButton", v2)
		textButton.Name = "Button"
		textButton.Size = UDim2.fromScale(1, 1)
		textButton.Text = ""
		textButton.ZIndex = -1
		textButton.BackgroundTransparency = 1
	end

	local count = v2:GetAttribute("Count") or 0

	if count < 0 then
		v2.Button.Size = UDim2.fromScale(1, 1)
		count = 0
	end

	v2:SetAttribute("Count", count + 1)
	animator:LoadAnimation(v2, {
		BackgroundTransparency = data.BackgroundTransparency or 0.2
	}, info):Play()
	animator:Add(function()
		local v4 = (v2:GetAttribute("Count") or 1) - 1
		v2:SetAttribute("Count", v4)

		if v4 == 0 then
			task.delay(0.5, function()
				if v2.Parent == nil or v2:GetAttribute("Count") ~= 0 then
					return
				end

				local v5 = math.random(-999, -1)
				v2:SetAttribute("Count", v5)
				animator:LoadAnimation(v2, {
					BackgroundTransparency = 1
				}, info2):Play()
				v2.Button.Size = UDim2.fromScale()
				task.delay(info2.Time, function()
					local count2 = v2:GetAttribute("Count")

					if v2.Parent ~= nil and count2 == v5 then
						v2:Destroy()
					end
				end)
			end)
		end
	end)

	if typeof(data.Icon) == "string" and data.Icon ~= "" then
		animator:Create("ImageLabel")({
			Parent = v2.Holder,
			Name = "Icon",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = animator:Animation(UDim2.fromScale(0.5, 0.39), info3, {
				From = UDim2.fromScale(0.5, 0.435)
			}),
			Size = UDim2.fromScale(0.14, 0.14),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			Image = data.Icon,
			ImageTransparency = animator:Animation(0, info, {
				From = 1
			}),
			OnClean = function()
				return {
					ImageTransparency = animator:Animation(1, info2)
				}
			end
		})
	end

	animator:Create("TextLabel")({
		Parent = v2.Holder,
		Name = "Message",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = animator:Animation(UDim2.fromScale(0.5, 0.5), info3, {
			From = UDim2.fromScale(0.5, 0.545)
		}),
		Size = animator:Animation(UDim2.fromScale(0.85, 0.22), info5, {
			From = UDim2.fromScale(1.29, 0.33)
		}),
		BackgroundTransparency = 1,
		Text = text,
		RichText = true,
		TextScaled = true,
		TextWrapped = true,
		Font = Enum.Font.SourceSansBold,
		TextColor3 = color2,
		TextTransparency = animator:Animation(0, info, {
			From = 1
		}),
		OnClean = function(animator2, instance)
			local uIStroke = instance:FindFirstChildOfClass("UIStroke")

			if uIStroke ~= nil then
				animator2:LoadAnimation(uIStroke, {
					Transparency = 1
				}, info4):Play()
			end

			return {
				TextTransparency = animator2:Animation(1, info2)
			}
		end,
		animator:Create("UIStroke")({
			Color = color2,
			Thickness = 2,
			animator:Create("UIGradient")({
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) }),
				Rotation = -90
			})
		})
	})

	if typeof(data.Subtext) == "string" and data.Subtext ~= "" then
		animator:Create("TextLabel")({
			Parent = v2.Holder,
			Name = "Subtext",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = animator:Animation(UDim2.fromScale(0.5, 0.6), info3, {
				From = UDim2.fromScale(0.5, 0.645)
			}),
			Size = UDim2.fromScale(0.7, 0.05),
			BackgroundTransparency = 1,
			Text = data.Subtext,
			TextScaled = true,
			TextWrapped = true,
			Font = Enum.Font.SourceSansSemibold,
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = animator:Animation(0.15, info, {
				From = 1
			}),
			OnClean = function(object)
				return {
					TextTransparency = object:Animation(1, info2)
				}
			end
		})
	end

	local progress = data.Progress

	if progress ~= nil then
		local v4 = progress.To >= progress.From
		local v5

		if v4 then
			v5 = progress.From
		else
			v5 = progress.To
		end

		local value = animator:Value(UDim2.fromScale(v5, 1))
		local v6

		if v4 then
			v6 = progress.To
		else
			v6 = progress.From
		end

		local value2 = animator:Value(UDim2.fromScale(v6, 1))
		animator:Delay(0.35, function()
			value:Set(UDim2.fromScale(progress.To, 1))
			value2:Set(UDim2.fromScale(progress.To, 1))
		end)

		local function Badge(image: string, layoutOrder: number, text2: string?)
			local v7 = animator:Create("Frame")
			local v8 = {
				Name = layoutOrder == 1 and "StartIcon" or "EndIcon",
				LayoutOrder = layoutOrder,
				Size = UDim2.fromScale(0.5, 0.5),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1
			}
			local v9 = animator:Create("Frame")({
				Name = "Glow",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.7, 0.7),
				BackgroundTransparency = 0.75,
				animator:Create("UICorner")({
					CornerRadius = UDim.new(1, 0)
				}),
				animator:Create("UIShadow")({
					BlurRadius = UDim.new(1),
					Color = Color3.new(1, 1, 1),
					Transparency = 0.5
				})
			})
			local v10 = animator:Create("ImageLabel")({
				Name = "Icon",
				ZIndex = 2,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = image
			})
			local v11

			if text2 ~= nil then
				v11 = animator:Create("TextLabel")({
					Name = "RankName",
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 1),
					Size = UDim2.fromScale(2.4, 0.36),
					BackgroundTransparency = 1,
					Text = text2,
					TextScaled = true,
					Font = Enum.Font.SourceSansBold,
					TextColor3 = Color3.new(1, 1, 1)
				})
			end

			v8[1], v8[2], v8[3] = v9, v10, v11
			return v7(v8)
		end

		local v7 = {
			Parent = v2.Holder,
			Name = "Progress",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = animator:Animation(UDim2.fromScale(0.5, 0.68), info3, {
				From = UDim2.fromScale(0.5, 0.725)
			}),
			Size = UDim2.fromScale(0.42, 0.15),
			BackgroundTransparency = 1,
			GroupTransparency = animator:Animation(0, info, {
				From = 1
			}),
			OnClean = function(object)
				return {
					GroupTransparency = object:Animation(1, info2)
				}
			end,
			animator:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0.02, 0)
			}),
			animator:Create("Frame")({
				Name = "Track",
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.75, 0.088),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundColor3 = color,
				BackgroundTransparency = 0.3,
				animator:Create("UICorner")({
					CornerRadius = UDim.new(1, 0)
				}),
				animator:Create("Frame")({
					Name = "Ghost",
					Size = animator:Animation(value2, info6),
					animator:Create("UICorner")({
						CornerRadius = UDim.new(1, 0)
					})
				}),
				animator:Create("Frame")({
					Name = "Fill",
					ZIndex = 2,
					Size = animator:Animation(value, info6),
					BackgroundColor3 = color2,
					animator:Create("UICorner")({
						CornerRadius = UDim.new(1, 0)
					})
				})
			})
		}

		if progress.StartIcon ~= nil then
			table.insert(v7, Badge(progress.StartIcon, 1, progress.StartName))
		end

		if progress.EndIcon ~= nil then
			table.insert(v7, Badge(progress.EndIcon, 3, progress.EndName))
		end

		animator:Create("CanvasGroup")(v7)
	end

	task.delay(data.Timout or 4, function()
		PopUpCreator.signal:Fire(p2)
	end)
end