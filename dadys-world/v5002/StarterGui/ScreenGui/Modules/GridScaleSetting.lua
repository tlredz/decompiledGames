local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local parent = script.Parent.Parent
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local v = {
	S = UDim2.new(0, 60, 0, 60),
	M = UDim2.new(0, 80, 0, 80),
	L = UDim2.new(0, 100, 0, 100)
}
local v2 = { "S", "M", "L" }
return {
	Start = function(_)
		local playerData = ReplicatedStorage:FindFirstChild("PlayerData")
		local child = playerData and playerData:FindFirstChild((tostring(localPlayer.UserId)))
		local events = ReplicatedStorage:FindFirstChild("Events")
		local settingsChangeEvent = events and events:FindFirstChild("SettingsChangeEvent")

		local function addButton(guiObject)
			if not (guiObject:IsA("GuiObject") and guiObject:IsDescendantOf(localPlayer)) then
				return
			end

			local target = guiObject:FindFirstChild("Target")

			if not (target and target:IsA("ObjectValue") and target.Value and target.Value:IsA("UIGridLayout")) then
				return
			end

			local currentCamera = workspace.CurrentCamera
			local v3 = currentCamera and (currentCamera.ViewportSize.X < 1280 or currentCamera.ViewportSize.Y < 720)
			local value = target.Value
			local largeScreenDefault = value:GetAttribute("LargeScreenDefault")
			local smallScreenDefault = value:GetAttribute("SmallScreenDefault")
			local attributes = {}
			local v4 = 2
			local options = value:GetAttribute("Options")
			local v5

			if options and options ~= "" then
				v5 = options:gsub(" ", ""):split(",")

				if #v5 <= 0 then
					v5 = v2
					attributes = v
				else
					for i = #v5, 1, -1 do
						local v6 = v5[i]
						local attribute = value:GetAttribute(v6) or v[v6]

						if attribute then
							attributes[v6] = attribute

							if v6 == largeScreenDefault and not v3 or v6 == smallScreenDefault and v3 then
								v4 = i
							end
						else
							table.remove(v5, i)
						end
					end

					if #v5 <= 0 then
						v5 = v2
						attributes = v
					end
				end
			else
				v5 = v2
				attributes = v
				v4 = v3 and 1 or 2
			end

			local settingKey = guiObject:GetAttribute("SettingKey")

			if settingKey and child then
				local numberValue = child:FindFirstChild(settingKey)

				if numberValue and numberValue:IsA("NumberValue") and numberValue.Value > 0 then
					v4 = math.clamp(numberValue.Value, 1, #v5)
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateSetting(p, p2)
				if settingsChangeEvent then
					settingsChangeEvent:FireServer(p, p2)
				end
			end

			local function onUpdate()
				local cellSize = attributes[v5[math.clamp(guiObject:GetAttribute("Index") or v4, 1, #v5)]]

				if cellSize then
					TweenService:Create(value, tweenInfo, {
						CellSize = cellSize
					}):Play()
				end
			end

			guiObject.Visible = true
			guiObject:SetAttribute("Index", v4)
			guiObject:GetAttributeChangedSignal("Index"):Connect(onUpdate)
			task.spawn(onUpdate)
			guiObject.Activated:Connect(function()
				local index = guiObject:GetAttribute("Index") or v4
				local v6 = index < #v5 and index + 1 or 1

				if settingKey then
					updateSetting(settingKey, v6) -- equivalent call inferred; original call site unknown
				end

				local click = parent:FindFirstChild("Click")

				if click then
					click:Play()
				end

				guiObject:SetAttribute("Index", v6)
			end)
		end

		CollectionService:GetInstanceAddedSignal("GridSizeSetterButton"):Connect(addButton)

		for _, v3 in pairs(CollectionService:GetTagged("GridSizeSetterButton")) do
			task.spawn(addButton, v3)
		end
	end
}