local createVector = vector.create
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, false, 0.2)
local tweenInfo2 = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, false, 0.2)
local folder = Instance.new("Folder")
folder.Name = "marker3DFolder"
folder.Parent = workspace
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local MarkerHandler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("MarkerHandler"))
local RunService = game:GetService("RunService")
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 1
screenGui.Name = "markergui"
screenGui.Parent = playerGui
screenGui.ScreenInsets = Enum.ScreenInsets.None
local currentCamera = workspace.CurrentCamera

-- equivalent calls inferred from this helper; original call sites unknown
local function getCompass()
	local componentsHolder = playerGui:FindFirstChild("ComponentsHolder")

	if componentsHolder then
		return componentsHolder:FindFirstChild("Compass")
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerPosition()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart and humanoidRootPart.Position or currentCamera.CFrame.Position
end

local function fullName_toAddress(value)
	local v = string.split(value, ".")
	local game2 = game
	local index = table.find(v, "game")

	if index then
		table.remove(v, index)
	end

	for i = 1, #v do
		game2 = game2:FindFirstChild(v[i])

		if game2 == nil then
			return
		end
	end

	return game2
end

local function extractPosition(value)
	if typeof(value) == "Instance" then
		return value.Position
	end

	if typeof(value) ~= "string" then
		return value
	end

	local v = fullName_toAddress(value)
	return v and v.Position
end

local function transparency(child, currentMarker, magnitude, style, p)
	local margin = currentMarker.margin or 10
	local v = not currentMarker.maxDistance and 0 or math.clamp(
		magnitude - currentMarker.maxDistance - margin,
		0,
		margin
	) / margin
	local currenttransparencyvalue = math.max(
		not currentMarker.minDistance and 0 or 1 - math.clamp(magnitude - currentMarker.minDistance - margin, 0, margin) / margin,
		v
	)

	if currentMarker.currenttransparencyvalue ~= currenttransparencyvalue then
		currentMarker.currenttransparencyvalue = currenttransparencyvalue
		MarkerHandler.Styles[style].applyOpacity(child, currenttransparencyvalue, p)
	end
end

local v = {}

local function claim(name: string, instance, parent)
	local child = parent:FindFirstChild(name)

	if instance == nil then
		return child
	end

	if child ~= nil then
		instance:Destroy()
		return child
	end

	instance.Name = name
	instance.Parent = parent
	return instance
end

local function mainLoop(p)
	local Y = game.GuiService:GetGuiInset().Y
	local cFrame = currentCamera.CFrame
	local viewportSize = currentCamera.ViewportSize

	for childName, currentMarker in pairs(MarkerHandler.currentMarkers) do
		if MarkerHandler.allDisabled or MarkerHandler.disabledTags[currentMarker.tag] then
			continue
		end

		local position = currentMarker.position

		if typeof(position) == "Instance" then
			position = position.Position
		elseif typeof(position) == "string" then
			local v2 = fullName_toAddress(position)
			position = v2 and v2.Position
		end

		local v2 = (position or createVector(0, 0, 0)) + (currentMarker.offset or createVector(0, 0, 0))

		if currentMarker.markerType == MarkerHandler.markerType.Regular then
			local child = screenGui:FindFirstChild(childName)
			local style = currentMarker.style or "Default"
			local style2 = MarkerHandler.Styles[style]

			if child == nil then
				if v[childName] then
					continue
				end

				v[childName] = true
				child = style2.createInterface(currentMarker, childName)
				v[childName] = nil
				local parent = screenGui
				local child2 = parent:FindFirstChild(childName)

				if child == nil then
					child = child2
				elseif child2 == nil then
					child.Name = childName
					child.Parent = parent
				else
					child:Destroy()
					child = child2
				end
			end

			if child ~= nil then
				local magnitude

				if currentMarker.displayDistance or currentMarker.minDistance or currentMarker.maxDistance then
					magnitude = math.floor((v2 - getPlayerPosition()).Magnitude)
				else
					magnitude = 0
				end

				if currentMarker.displayDistance then
					child.dist.Text = magnitude .. "m"
				end

				local indicator = currentMarker.indicator or (currentMarker.count or 1) > 1
				local hasCountLabel = child:GetAttribute("hasCountLabel") == true

				if indicator and not hasCountLabel then
					local frame = Instance.new("Frame")
					frame.Name = "countlabel"
					frame.ZIndex = -10
					frame.Size = UDim2.fromScale(1, 1)
					frame.BorderSizePixel = 0
					frame.BackgroundTransparency = 1
					frame.Parent = child
					local imageLabel = Instance.new("ImageLabel")
					imageLabel.BackgroundTransparency = 1
					imageLabel.Parent = frame
					imageLabel.Size = UDim2.fromScale(0.7, 0.7)
					imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
					imageLabel.Position = UDim2.fromScale(0.5, 0.5)
					imageLabel.ImageTransparency = 0
					imageLabel.ImageColor3 = currentMarker.indicatorColor or Color3.new(1, 0.2, 0.2)
					imageLabel.Image = "rbxassetid://17359135613"
					TweenService:Create(imageLabel, tweenInfo, {
						Size = UDim2.fromScale(1, 1)
					}):Play()
					TweenService:Create(imageLabel, tweenInfo2, {
						ImageTransparency = 1
					}):Play()
					child:SetAttribute("hasCountLabel", true)
				elseif not indicator and hasCountLabel then
					local countlabel = child:FindFirstChild("countlabel")

					if countlabel then
						countlabel:Destroy()
					end

					child:SetAttribute("hasCountLabel", false)
				end

				local worldToScreenPoint, v3 = currentCamera:WorldToScreenPoint(v2)
				local X = child.AbsoluteSize.X
				local v4 = viewportSize.X - X
				local v5 = viewportSize.Y - X
				local v6 = worldToScreenPoint + Vector3.new(0, Y, 0)
				local _compassX = math.clamp(v6.X, 0, (math.max(X, v4)))
				local posY = math.clamp(v6.Y, 0, (math.max(X, v5)))
				local v8 = _compassX ~= v6.X or posY ~= v6.Y or v3 == false
				local v9

				if currentMarker.offScreenMode == MarkerHandler.offScreenMode.Compass and v8 then
					local compass = getCompass() -- equivalent call inferred; original call site unknown
					v9 = compass or nil
				end

				local v10 = v2 - cFrame.Position
				local vectorToObjectSpace = cFrame:VectorToObjectSpace(v10)

				if v9 then
					local absolutePosition = v9.AbsolutePosition
					local absoluteSize = v9.AbsoluteSize
					local lookVector = cFrame.LookVector
					local unit = Vector2.new(lookVector.X, lookVector.Z).Unit
					local unit2 = Vector2.new(v10.X, v10.Z).Unit
					local v11 = math.deg((math.atan2(unit.X * unit2.Y - unit.Y * unit2.X, (unit:Dot(unit2)))))
					local v12 = absoluteSize.X / currentCamera.FieldOfView
					local compassX = math.clamp(
						absolutePosition.X + absoluteSize.X / 2 + v11 * v12,
						absolutePosition.X,
						absolutePosition.X + absoluteSize.X
					)
					local v14 = 1 - math.exp(-15 * p)

					if currentMarker._compassX then
						compassX = currentMarker._compassX + (compassX - currentMarker._compassX) * v14 or compassX
					end

					currentMarker._compassX = compassX
					_compassX = currentMarker._compassX
					posY = absolutePosition.Y + absoluteSize.Y + Y + absoluteSize.Y * 0.5 + 4

					if style2.setPointer then
						local unit3 = Vector2.new(vectorToObjectSpace.X, vectorToObjectSpace.Y).Unit
						style2.setPointer(child, true, math.deg((math.atan2(unit3.X, unit3.Y))) - 90)
					end
				elseif style2.setPointer then
					if v8 then
						local unit = Vector2.new(vectorToObjectSpace.X, vectorToObjectSpace.Y).Unit
						local v11 = math.atan2(unit.X, unit.Y)
						local v12

						if math.abs(unit.Y * v4) > math.abs(unit.X * v5) then
							v12 = unit * math.abs(v5 / 2 / unit.Y)
						else
							v12 = unit * math.abs(v4 / 2 / unit.X)
						end

						_compassX = viewportSize.X / 2 + v12.X
						posY = viewportSize.Y / 2 - v12.Y
						style2.setPointer(child, true, math.deg(v11) - 90)
					else
						style2.setPointer(child, false, 0)
					end
				end

				local inCompass = v9 ~= nil

				if currentMarker._inCompass ~= inCompass and currentMarker._inCompass ~= nil then
					currentMarker._lerpTimer = 0.25
				end

				currentMarker._inCompass = inCompass

				if currentMarker.maxDistance or currentMarker.minDistance then
					transparency(child, currentMarker, magnitude, style)
				end

				if currentMarker._lerpTimer and currentMarker._lerpTimer > 0 then
					currentMarker._lerpTimer -= p
					local v12 = 1 - math.exp(-15 * p)
					currentMarker._posX = (currentMarker._posX or _compassX) + (_compassX - (currentMarker._posX or _compassX)) * v12
					currentMarker._posY = (currentMarker._posY or posY) + (posY - (currentMarker._posY or posY)) * v12
				else
					currentMarker._posX = _compassX
					currentMarker._posY = posY
					currentMarker._lerpTimer = nil
				end

				child.Position = UDim2.fromOffset(currentMarker._posX, currentMarker._posY)
			end
		elseif currentMarker.markerType == MarkerHandler.markerType.PointerMarker then
			local child = screenGui:FindFirstChild(childName)

			if child == nil and currentMarker.in3DSpace == true then
				child = folder:FindFirstChild(childName)
			end

			local style

			if child == nil then
				if v[childName] then
					continue
				end

				style = currentMarker.style or "PointerMarkerDefault"
				v[childName] = true
				child = MarkerHandler.Styles[style].createInterface(currentMarker, childName)
				v[childName] = nil
				local parent = currentMarker.in3DSpace == true and folder or screenGui
				local child2 = parent:FindFirstChild(childName)

				if child == nil then
					child = child2
				elseif child2 == nil then
					child.Name = childName
					child.Parent = parent
				else
					child:Destroy()
					child = child2
				end
			else
				style = "PointerMarkerDefault"
			end

			if child ~= nil then
				if currentMarker.in3DSpace then
					local character = localPlayer.Character
					local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
					local position2 = humanoidRootPart and humanoidRootPart.Position or currentCamera.CFrame.Position
					local v3

					if humanoidRootPart then
						local v4
						v4, v3 = humanoidRootPart.CFrame:ToOrientation()
					else
						v3 = 0
					end

					local _, v4, _ = CFrame.new(position2, v2):ToOrientation()

					if child:FindFirstChild("Weld") == nil and humanoidRootPart then
						MarkerHandler.Styles[style].createWeld(humanoidRootPart, child, character)
					end

					child.Weld.C1 = CFrame.Angles(0, math.rad(math.deg(v3) - math.deg(v4) + 90), 0)

					if currentMarker.maxDistance or currentMarker.minDistance then
						transparency(
							child,
							currentMarker,
							math.floor((v2 - position2).Magnitude),
							style,
							currentMarker.in3DSpace
						)
					end
				else
					local playerPosition = getPlayerPosition() -- equivalent call inferred; original call site unknown
					local _, v3, _ = cFrame:ToOrientation()
					local _, v4, _ = CFrame.new(playerPosition, v2):ToOrientation()
					child.Holder.Rotation = math.deg(v3) - math.deg(v4)

					if currentMarker.maxDistance or currentMarker.minDistance then
						transparency(child, currentMarker, math.floor((v2 - playerPosition).Magnitude), style)
					end
				end
			end
		end
	end
end

local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function updv()
	local v3 = MarkerHandler.markerCount.value > 0

	if v3 ~= v2 then
		if v3 == true then
			RunService:BindToRenderStep("markerbind", Enum.RenderPriority.Last.Value, mainLoop)
		else
			RunService:UnbindFromRenderStep("markerbind")
		end

		v2 = v3
	end
end

updv() -- equivalent call inferred; original call site unknown
MarkerHandler.markerCount.Changed:Connect(updv)