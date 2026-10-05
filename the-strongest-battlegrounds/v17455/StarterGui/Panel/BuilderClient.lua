local createVector = vector.create
local lastTime = tick()

if not workspace:GetAttribute("VIPServer") then
	repeat
		task.wait()
	until tick() - lastTime > 5 or workspace:GetAttribute("VIPServer") or workspace:GetAttribute("VIPServer") ~= game.Players.LocalPlayer.UserId
end

if tick() - lastTime > 5 then
	return script.Parent:Destroy()
end

local UserInputService = game:GetService("UserInputService")
local parent = script.Parent
local menuContainer = parent.MenuContainer
local frame = menuContainer.Frame
local sideContainerFrame = menuContainer.SideContainerFrame
local sideContainer = sideContainerFrame.SideContainer
sideContainer.Parent = script
local Info = require(game.ReplicatedStorage.Info)
local skillsets = Info.Skillsets
local localPlayer = game.Players.LocalPlayer
local fn
local getSerial = Info.GetSerial

local function fn2(p)
	local serial = getSerial(p)

	if not _G.builtblocks[serial] then
		return serial
	end

	local count = 0

	repeat
		serial = getSerial(p)
		count += 1
	until not _G.builtblocks[serial]

	return serial
end

local function fn3(communicate, p)
	communicate:FireServer(p)
end

local builder = script:WaitForChild("Builder")
local module = require(builder)
_G.builtblocks = {}
local grid = frame.Grid
grid:GetPropertyChangedSignal("Text"):Connect(function()
	local text = tonumber(grid.Text)

	if not text then
		return
	end

	module.SetGridSize(text)
end)
local v2 = {
	Delete = "caps",
	Move = "caps",
	Place = "caps",
	Resize = "caps",
	Rotate = "caps",
	Select = "caps"
}

for k, v3 in pairs(v2) do
	if v3 == "caps" then
		v2[k] = k:lower()
	end
end

local clones = {}
local onMouseButton1Clicks = {}
local buttons = {}
local clones2 = {}
local v3 = {}
local v4 = nil
local connections = {}
local v5 = nil

local function fn4(p)
	local v6 = false

	for _, v7 in pairs(p or clones) do
		if not v7.Parent then
			continue
		end

		if not v6 then
			shared.sfx({
				SoundId = ({ "rbxassetid://15675028888", "rbxassetid://15675024286", "rbxassetid://15674975792" })[math.random(
					1,
					3
				)],
				Parent = workspace,
				Volume = 0.3
			}):Play()
			v6 = true
		end

		v7:TweenPosition(
			UDim2.new(v7.Position.X.Scale, 0, 1.75, 0),
			Enum.EasingDirection.InOut,
			Enum.EasingStyle.Quad,
			0.75,
			true
		)
		local v8 = v7
		task.delay(0.5, function()
			v8:Destroy()
		end)
	end

	table.clear(p or clones)

	if not p then
		for _, connection in pairs(connections) do
			connection:Disconnect()
		end

		table.clear(connections)
	end
end

local now = 0

local function fn5(p, p2, p3, callback)
	local clones3 = p2 or clones2
	shared.sfx({
		SoundId = ({ "rbxassetid://15675028888", "rbxassetid://15675024286", "rbxassetid://15674975792" })[math.random(
			1,
			3
		)],
		Parent = workspace,
		Volume = 0.3
	}):Play()
	fn4(clones3)

	if (p3 or menuContainer.SideContainerFrameTwo):FindFirstChild("ColorFrame") then
		return
	end

	local clone = script.ColorFrame:Clone()
	clone.LocalScript.Value.Value = module.lockedTargetObjects[1]
	clone.LocalScript.Enabled = true
	clone.Position = UDim2.new(2.5, 0, 0.25, 0)
	clone.Parent = p3 or menuContainer.SideContainerFrameTwo
	clone:TweenPosition(UDim2.new(1.069, 0, 0.25, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.75, true)
	table.insert(clones, clone)
	clone.Preview:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
		if callback then
			return callback(clone.Preview.BackgroundColor3)
		end

		local communicate = localPlayer.Character:FindFirstChild("Communicate")

		if communicate then
			local list = {}

			for _, lockedTargetObject in pairs(module.lockedTargetObjects) do
				table.insert(list, {
					Serial = lockedTargetObject:GetAttribute("Serial")
				})
				lockedTargetObject.Color = clone.Preview.BackgroundColor3
			end

			communicate:FireServer({
				Goal = "PS Build",
				Todo = "Change Color",
				Color = p.Color,
				List = list
			})
		end
	end)
	table.insert(clones3, clone)
end

local fn6

fn6 = function(data)
	shared.sfx({
		SoundId = ({ "rbxassetid://15675028888", "rbxassetid://15675024286", "rbxassetid://15674975792" })[math.random(
			1,
			3
		)],
		Parent = workspace,
		Volume = 0.3
	}):Play()

	if not data.chill then
		fn4(clones2)
	end

	local parent2 = data.Parent or menuContainer.SideContainerFrameTwo

	if parent2:FindFirstChild("SideContainer" .. data.Title) then
		return
	end

	local clone = sideContainer:Clone()
	local clone2 = clone.ScrollingFrame:FindFirstChild("Transparency"):Clone()
	local clone3 = clone.ScrollingFrame.Material:Clone()
	local clone4 = nil

	for _, child in pairs(clone.ScrollingFrame:GetChildren()) do
		if child.Name ~= "ImageButton" and child.Name ~= "UIListLayout" then
			child:Destroy()
		end
	end

	if not data.chill then
		fn4(clones2)
	end

	clone.ScrollingFrame.ImageButton:Destroy()
	clone:SetAttribute("Title", data.Title)

	if data.Title == "Gears" then
		clone4 = script.Search:Clone()
		clone4.LayoutOrder = 0
		clone4.Parent = clone.ScrollingFrame
		local now2 = 0
		clone4:GetPropertyChangedSignal("Text"):Connect(function()
			now2 = tick()
			task.delay(0.3, function()
				if tick() - now2 > 0.3 then
					local text = clone4.Text

					for _, button in pairs(clone4.Parent:GetChildren()) do
						if not button:IsA("TextButton") then
							continue
						end

						local flag = false
						local text2 = button.Text

						if string.sub(string.lower(text2), 1, (string.len(text))) == string.lower(text) then
							flag = true
						else
							local parts = button.Name:split(" ")

							if #parts > 1 then
								for _, part in pairs(parts) do
									if string.sub(string.lower(part), 1, (string.len(text))) ~= string.lower(text) then
										continue
									end

									flag = true
									break
								end
							end
						end

						if flag then
							button.Visible = true
						else
							button.Visible = false
						end
					end
				end
			end)
		end)
	end

	local imageButton = clone.ScrollingFrame.ImageButton
	imageButton.LayoutOrder = 0
	imageButton.BackgroundColor3 = Color3.fromRGB(148, 255, 166)
	imageButton.TextLabel.Text = data.Title
	clone.Position = UDim2.new(1.5, 0, 0.5, 0)
	clone.Name ..= data.Title
	clone.Parent = parent2
	clone:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.75, true)
	table.insert(clones, clone)
	table.insert(clones2, clone)

	if string.sub(data.Title, 0, 4) == "Slot" then
		local title = data.Title
		local slotNames = localPlayer:GetAttribute("SlotNames")
		local v6 = tostring(title:sub(6, 6))
		local HttpService = game:GetService("HttpService")
		local jSONDecode = HttpService:JSONDecode(slotNames)

		if jSONDecode[v6] then
			imageButton.TextLabel.Text = jSONDecode[v6]
		end
	end

	local lockedTargetObject = module.lockedTargetObjects[1]
	local v6, v7

	if lockedTargetObject then
		local currentMoves = lockedTargetObject:GetAttribute("CurrentMoves") or "[]"
		local HttpService = game:GetService("HttpService")
		v6 = HttpService:JSONDecode(currentMoves)
		local currentGears = lockedTargetObject:GetAttribute("CurrentGears") or "[]"
		local HttpService2 = game:GetService("HttpService")
		v7 = HttpService2:JSONDecode(currentGears)
	end

	for _, content in pairs(data.Contents) do
		local flag = true
		local v8, v9, v10, textColor2, v12

		if typeof(content) == "table" then
			v8 = content[1]
			v9 = rawget(content, "Text")
			v10 = rawget(content, "Toggle")
			textColor2 = rawget(content, "Color")
			v12 = rawget(content, "ToolName")

			if content.Section then
				local clone5 = frame.ImageButton:Clone()
				clone5.LayoutOrder = 3
				clone5.BackgroundColor3 = Color3.fromRGB(148, 255, 166)
				clone5.TextLabel.Text = content.Section
				clone5.Parent = clone.ScrollingFrame
				flag = false
			end
		else
			v8 = content
			v12 = nil
		end

		if not flag then
			continue
		end

		local clone5

		if v9 then
			clone5 = clone2:Clone()
		else
			clone5 = clone3:Clone()
		end

		clone5.TextWrapped = true

		if clone5:IsA("TextButton") then
			clone5.Text = v8

			if string.sub(v8, 0, 4) == "Slot" then
				local slotNames = localPlayer:GetAttribute("SlotNames")
				local v13 = tostring(v8:sub(6, 6))
				local HttpService = game:GetService("HttpService")
				local jSONDecode = HttpService:JSONDecode(slotNames)

				if jSONDecode[v13] then
					clone5.Text = jSONDecode[v13]
				end
			end
		else
			clone5.PlaceholderText = v8
		end

		clone5.Name = v8
		clone5.Parent = clone.ScrollingFrame

		if textColor2 then
			clone5.TextColor3 = textColor2
		end

		local clone6

		if v10 then
			clone5.LayoutOrder = 0
			local index

			if data.Title == "Moves" then
				index = table.find(v6, v8)
			elseif data.Title == "Gears" then
				index = table.find(v7, v8)
			else
				index = module.lockedTargetObjects[1]:GetAttribute(string.gsub(clone5.Text, " ", ""))
			end

			clone6 = script.Toggle:Clone()
			clone6.Parent = clone5
			clone6.BackgroundColor3 = not index and Color3.fromRGB(255, 87, 87) or Color3.fromRGB(114, 255, 98)
		else
			clone6 = nil
		end

		if clone5:IsA("TextButton") then
			local v13 = content
			clone5.MouseButton1Click:Connect(function()
				shared.sfx({
					SoundId = "rbxassetid://15675055424",
					Parent = workspace,
					Volume = 0.3
				}):Play()
				local character = localPlayer.Character
				local communicate = character:FindFirstChild("Communicate")

				if communicate then
					if data.Title == "Object" then
						table.find(shared.prefabscache, v8)
						module.setObject(v8)
					elseif v8 == "Emit Light" then
						local emitLight = module.lockedTargetObjects[1]:GetAttribute("EmitLight")
						local list = {}

						for k, lockedTargetObject2 in pairs(module.lockedTargetObjects) do
							table.insert(list, {
								Serial = lockedTargetObject2:GetAttribute("Serial")
							})
							lockedTargetObject2:SetAttribute("EmitLight", not emitLight)
						end

						if emitLight then
							clone6.BackgroundColor3 = Color3.fromRGB(255, 87, 87)
						else
							clone6.BackgroundColor3 = Color3.fromRGB(114, 255, 98)
						end

						communicate:FireServer({
							Goal = "PS Build",
							Todo = "Property Change",
							List = list,
							Property = "EmitLight",
							New = not emitLight
						})
					elseif data.Title == "Save Menu" then
						if v13 and typeof(v13) == "table" and v13.Map then
							return fn3(communicate, {
								Goal = "PS Build",
								Todo = "New Map",
								Map = v8
							})
						end

						if v8 == "Buy Slot" then
							local MarketplaceService = game:GetService("MarketplaceService")
							return MarketplaceService:PromptProductPurchase(localPlayer, 1806370003)
						end

						if v8 == "Clear Current" then
							local bindableFunction = Instance.new("BindableFunction")

							function bindableFunction.OnInvoke(p)
								if p == "Yes" then
									communicate:FireServer({
										Goal = "PS Build",
										Todo = "Clear"
									})

									if character:GetAttribute("OPped") and workspace:GetAttribute("VIPServer") ~= localPlayer.UserId then
										return
									end

									local CollectionService = game:GetService("CollectionService")

									for k, v14 in pairs(CollectionService:GetTagged("psbuilt2")) do
										v14:Destroy()
									end

									local CollectionService2 = game:GetService("CollectionService")

									for k, v14 in pairs(CollectionService2:GetTagged("PSBuilt")) do
										v14:Destroy()
									end
								end
							end

							shared.repfire({
								Effect = "Notification",
								Title = string.sub(v8, 0, 5):upper(),
								Text = string.format("Are you sure you want to clear the current map, this cannot be undone!"),
								Duration = 5,
								Stack = true,
								Button1 = "Yes",
								Button2 = "No",
								Callback = bindableFunction
							})
						else
							local v14 = string.sub(v8, 0, 4)
							local v15 = string.sub(v8, 6, 6)

							if v14 ~= "Slot" then
								return
							end

							local children = sideContainerFrame:GetChildren()
							local chill

							if children[1] and children[1]:GetAttribute("Title") == "Save Menu" then
								chill = true
								local children2 = menuContainer.SideContainerFrameTwo:GetChildren()

								if children2[1] and children2[1]:GetAttribute("Title"):find("Slot") then
									fn4({ children2[1] })
								end
							else
								chill = false
							end

							return fn6({
								Title = "Slot " .. v15,
								Contents = {
									{
										"Save",
										Button = true
									},
									{
										"Load",
										Button = true
									},
									{
										"Slot Name",
										Text = true
									}
								},
								chill = chill
							})
						end
					elseif data.Title:find("Slot") then
						local v14 = string.sub(v8, 0, 4)

						if v14 == "Save" or v14 == "Load" then
							if tick() - (now or 0) < 6.25 then
								shared.repfire({
									Effect = "Notification",
									Text = "Please wait a little before using this again.",
									Title = "COOLDOWN",
									Stack = true
								})
								return
							end

							local bindableFunction = Instance.new("BindableFunction")

							function bindableFunction.OnInvoke(p)
								if p == "Yes" then
									now = tick() - 5
									communicate:FireServer({
										Goal = "PS Build",
										Todo = v14 .. " " .. data.Title:sub(6, 6)
									})
								end
							end

							local v15 = data.Title:sub(6, 6)
							local text = string.format(
								"Are you sure you want to %s slot %s?",
								v14 == "Save" and "save to" or "load",
								v15
							)

							if imageButton.TextLabel.Text ~= "Slot " .. v15 then
								text = string.format(
									"Are you sure you want to %s \"%s\" (Slot %s)?",
									v14 == "Save" and "save to" or "load",
									imageButton.TextLabel.Text,
									v15
								)
							end

							shared.repfire({
								Effect = "Notification",
								Title = string.sub(v8, 0, 4):upper(),
								Text = text,
								Duration = 5,
								Button1 = "Yes",
								Button2 = "No",
								Stack = true,
								Callback = bindableFunction
							})
						end
					elseif data.Title == "Text Display" then
						if v8 == "Text Color" then
							fn5(lockedTargetObject, v3, menuContainer.SideContainerFrameThree, function(textColor)
								local list = {}

								for k, lockedTargetObject2 in pairs(module.lockedTargetObjects) do
									table.insert(list, {
										Serial = lockedTargetObject2:GetAttribute("Serial")
									})
									lockedTargetObject2:SetAttribute("TextColor", textColor)
								end

								communicate:FireServer({
									Goal = "PS Build",
									Todo = "Property Change",
									List = list,
									Property = "TextColor",
									New = textColor
								})
							end)
						elseif v8 == "Text Font" then
							local names = {}

							for k, v14 in pairs(Enum.Font:GetEnumItems()) do
								table.insert(names, v14.Name)
							end

							fn6({
								Title = "Font",
								Contents = names
							})
						elseif v8 == "Text Outline" then
							local textOutline = module.lockedTargetObjects[1]:GetAttribute("TextOutline")
							local list = {}

							for k, lockedTargetObject2 in pairs(module.lockedTargetObjects) do
								table.insert(list, {
									Serial = lockedTargetObject2:GetAttribute("Serial")
								})
								lockedTargetObject2:SetAttribute("TextOutline", not textOutline)
							end

							if textOutline then
								clone6.BackgroundColor3 = Color3.fromRGB(255, 87, 87)
							else
								clone6.BackgroundColor3 = Color3.fromRGB(114, 255, 98)
							end

							communicate:FireServer({
								Goal = "PS Build",
								Todo = "Property Change",
								List = list,
								Property = "TextOutline",
								New = not textOutline
							})
						end
					elseif data.Title == "Moves" then
						local currentMoves = module.lockedTargetObjects[1]:GetAttribute("CurrentMoves") or "[]"
						local HttpService = game:GetService("HttpService")
						local jSONDecode = HttpService:JSONDecode(currentMoves)

						if table.find(jSONDecode, v8) then
							clone6.BackgroundColor3 = Color3.fromRGB(255, 87, 87)
							local index = table.find(jSONDecode, v8)

							if index then
								table.remove(jSONDecode, index)
							end
						else
							clone6.BackgroundColor3 = Color3.fromRGB(114, 255, 98)
							table.insert(jSONDecode, v8)
						end

						local HttpService2 = game:GetService("HttpService")
						local jSONEncode = HttpService2:JSONEncode(jSONDecode)
						local list = {}

						for k, lockedTargetObject2 in pairs(module.lockedTargetObjects) do
							table.insert(list, {
								Serial = lockedTargetObject2:GetAttribute("Serial")
							})
							lockedTargetObject2:SetAttribute("CurrentMoves", jSONEncode)
						end

						communicate:FireServer({
							Goal = "PS Build",
							Todo = "Change Moves",
							New = jSONEncode,
							List = list
						})
					elseif data.Title == "Gears" then
						local currentGears = module.lockedTargetObjects[1]:GetAttribute("CurrentGears") or "[]"
						local HttpService = game:GetService("HttpService")
						local jSONDecode = HttpService:JSONDecode(currentGears)

						if table.find(jSONDecode, v12) then
							clone6.BackgroundColor3 = Color3.fromRGB(255, 87, 87)
							local index = table.find(jSONDecode, v12)

							if index then
								table.remove(jSONDecode, index)
							end
						else
							clone6.BackgroundColor3 = Color3.fromRGB(114, 255, 98)
							table.insert(jSONDecode, v12)
						end

						local HttpService2 = game:GetService("HttpService")
						local jSONEncode = HttpService2:JSONEncode(jSONDecode)
						local list = {}

						for k, lockedTargetObject2 in pairs(module.lockedTargetObjects) do
							table.insert(list, {
								Serial = lockedTargetObject2:GetAttribute("Serial")
							})
							lockedTargetObject2:SetAttribute("CurrentGears", jSONEncode)
						end

						communicate:FireServer({
							Goal = "PS Build",
							Todo = "Change Gears",
							New = jSONEncode,
							List = list
						})
					else
						local list = {}

						for k, part in pairs(module.lockedTargetObjects) do
							table.insert(list, {
								Serial = part:GetAttribute("Serial")
							})

							if data.Title == "Font" then
								part:SetAttribute("TextFont", Enum.Font[v8])
							elseif data.Title == "Shape" then
								if not part:IsA("MeshPart") then
									part.Shape = Enum.PartType[v8]
								end
							else
								part.Material = Enum.Material[v8]
							end
						end

						communicate:FireServer({
							Goal = "PS Build",
							Todo = "Change " .. data.Title,
							List = list,
							New = v8
						})
					end
				end
			end)
		else
			local now2 = 0
			clone5.FocusLost:Connect(function(p)
				if not p then
					return
				end

				if clone5.Name == "Slot Name" then
					local communicate = localPlayer.Character:FindFirstChild("Communicate")
					local v13 = {
						Goal = "PS Build",
						Todo = "Slot Name Change",
						Slot = tonumber(string.match(data.Title, "%d+")),
						Name = clone5.Text
					}
					clone5.Text = ""
					communicate:FireServer(v13)
				end
			end)
			clone5:GetPropertyChangedSignal("Text"):Connect(function()
				now2 = tick()
				local communicate = localPlayer.Character:FindFirstChild("Communicate")

				if data.Title ~= "Light" and data.Title ~= "Text Display" and data.Title ~= "Mesh" then
					return
				end

				if data.Title == "Mesh" then
					clone5.Text = clone5.Text:gsub("rbxassetid://", "")
				end

				if clone5.PlaceholderText ~= "Text" and not tonumber(clone5.Text) then
					return
				end

				if clone5.PlaceholderText == "Text" then
					task.wait(0.3)
				end

				if tick() - now2 >= 0.3 or clone5.PlaceholderText ~= "Text" then
					local property = string.gsub(clone5.PlaceholderText, " ", "")
					local list = {}

					for _, lockedTargetObject2 in pairs(module.lockedTargetObjects) do
						table.insert(list, {
							Serial = lockedTargetObject2:GetAttribute("Serial")
						})

						if clone5.PlaceholderText ~= "Text" then
							lockedTargetObject2:SetAttribute(property, clone5.Text)
						end
					end

					communicate:FireServer({
						Goal = "PS Build",
						Todo = "Property Change",
						List = list,
						Property = property,
						New = clone5.Text
					})
				end
			end)
		end
	end

	local scrollingFrame = clone.ScrollingFrame
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.UIListLayout.AbsoluteContentSize.Y)
	scrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.UIListLayout.AbsoluteContentSize.Y)
	end)
end

local scrollingFrame = script.Parent.MenuContainer.Frame.ScrollingFrame
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.UIListLayout.AbsoluteContentSize.Y)
scrollingFrame.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.UIListLayout.AbsoluteContentSize.Y)
end)

local function fn7(value)
	if typeof(value) == "string" then
		value = buttons[value]
	end

	if v4 then
		v4.Frame.BackgroundTransparency = 0.7
		v4.Frame.BackgroundColor3 = Color3.new(0, 0, 0)
	end

	value.Frame.BackgroundTransparency = 0
	value.Frame.BackgroundColor3 = Color3.new(1, 1, 1)
	v4 = value
end

function separateCapLockedChars(value)
	local v6 = ""

	for i = 1, #value do
		local v7 = value:sub(i, i)

		if v7:match("%u") and i > 1 then
			v6 ..= " "
		end

		v6 ..= v7
	end

	return v6
end

local children = frame.ScrollingFrame:GetChildren()

for _, child in pairs(frame:GetChildren()) do
	table.insert(children, child)
end

for _, button in pairs(children) do
	if not button:IsA("TextButton") then
		continue
	end

	if button.Text == "Save Menu" then
		button.MouseButton1Click:Connect(function()
			shared.sfx({
				SoundId = "rbxassetid://15675055424",
				Parent = workspace,
				Volume = 0.3
			}):Play()
			local contents = {}

			for i = 1, localPlayer:GetAttribute("SaveSlots") do
				table.insert(contents, "Slot " .. i)
			end

			table.insert(contents, {
				"Buy Slot",
				Color = Color3.fromRGB(255, 216, 19)
			})
			table.insert(contents, {
				"Clear Current",
				Color = BrickColor.new("Persimmon").Color
			})
			table.insert(contents, {
				Section = "Maps"
			})
			table.insert(contents, {
				"Forest - Arena",
				Map = true
			})
			table.insert(contents, {
				"Valley",
				Map = true
			})
			table.insert(contents, {
				"Forest",
				Map = true
			})
			table.insert(contents, {
				"City",
				Map = true
			})
			table.insert(contents, {
				"Mountain",
				Map = true
			})
			table.insert(contents, {
				"Desert",
				Map = true
			})
			table.insert(contents, {
				"Beach",
				Map = true
			})
			local children2 = sideContainerFrame:GetChildren()
			return fn6({
				Title = "Save Menu",
				Parent = #(children2[1] and (children2[1]:GetAttribute("Title") == "Save Menu" or children2[1]:GetAttribute("Title") == "Object") and {} or children2) == 0 and sideContainerFrame,
				Contents = contents
			})
		end)
	elseif button.Text == "Undo" then
		button.MouseButton1Click:Connect(function()
			local snapshot = module.Snapshots[#module.Snapshots]

			if not snapshot then
				return warn("history clean")
			end

			table.remove(module.Snapshots, #module.Snapshots)
			local lockedTargetObjectsBySerial = {}

			for _, lockedTargetObject in pairs(module.lockedTargetObjects) do
				lockedTargetObjectsBySerial[lockedTargetObject:GetAttribute("Serial")] = lockedTargetObject
			end

			local deleteds = {}

			for k, v6 in pairs(snapshot.record) do
				k.CFrame = v6.CFrame

				if v6.Deleted then
					table.insert(deleteds, v6.Deleted)
				end

				local v7 = lockedTargetObjectsBySerial[k:GetAttribute("Serial")]

				if v7 then
					v7.CFrame = v6.CFrame
				end
			end

			if #deleteds > 0 then
				fn(nil, nil, deleteds)
			end
		end)
	end

	local v6 = rawget(v2, button.Name)

	if not v6 then
		continue
	end

	buttons[v6] = button
	local v7 = button
	local v8 = v6

	local function onMouseButton1Click()
		shared.sfx({
			SoundId = "rbxassetid://15675055424",
			Parent = workspace,
			Volume = 0.3
		}):Play()
		fn7(v7)
		module.SetMode(v8)

		if v8 == "place" then
			local children2 = sideContainerFrame:GetChildren()
			local v9 = #(children2[1] and (children2[1]:GetAttribute("Title") == "Save Menu" or children2[1]:GetAttribute("Title") == "Object") and {} or children2) == 0
			local contents = {
				{
					"Block",
					Button = true
				},
				{
					"Spawn Location",
					Button = true
				},
				{
					Section = "Prefabs"
				},
				{
					"Trashcan",
					Button = true
				}
			}

			if shared.prefabscache then
				for k, v11 in pairs(shared.prefabscache) do
					table.insert(contents, {
						v11,
						Button = true
					})
				end
			else
				shared.prefabscache = {}

				for i, folder in pairs(game.ReplicatedStorage.Prefabs.Models:GetChildren()) do
					local flag = true

					for i2, descendant in pairs(folder:GetDescendants()) do
						if descendant:IsA("Part") or descendant:IsA("Model") then
							continue
						end

						flag = false
						break
					end

					if not flag then
						continue
					end

					table.insert(contents, {
						folder.Name,
						Button = true
					})
					table.insert(shared.prefabscache, folder.Name)
				end
			end

			fn6({
				Title = "Object",
				Parent = sideContainerFrame,
				Contents = contents
			})
			module.Default = nil
		end
	end

	button.MouseButton1Click:Connect(onMouseButton1Click)
	onMouseButton1Clicks[v6] = onMouseButton1Click
end

local v6 = {
	[Enum.KeyCode.One] = "place",
	[Enum.KeyCode.Two] = "select",
	[Enum.KeyCode.Three] = "move",
	[Enum.KeyCode.Four] = "rotate",
	[Enum.KeyCode.Five] = "resize",
	[Enum.KeyCode.Six] = "delete"
}

fn = function(instance, _, p)
	if #module.lockedTargetObjects == 1 and not p then
		module.Clone(instance)
		local clone = instance:Clone()
		clone:SetAttribute("Serial", nil)
		module.Default = clone
		module.SetMode("place", true)
		fn7("place")
	else
		local clones3 = {}

		for _, v7 in pairs(p or module.lockedTargetObjects) do
			if typeof(v7) ~= "Instance" then
				continue
			end

			local pseudo = v7:FindFirstChild("Pseudo")
			local value = pseudo and pseudo.Value

			if not value then
				continue
			end

			local clone = value:Clone()
			clone.CanCollide = false
			clone.CanTouch = false
			clone.CanQuery = false
			clone.Transparency = 0
			clone.CastShadow = false
			clone.CFrame = v7.CFrame
			clone.Name = "Cloning"

			for _ = 1, 5 do
				local invisible = clone:FindFirstChild("Invisible")

				if invisible then
					invisible:Destroy()
				end
			end

			value:GetAttributeChangedSignal("Parent"):Connect(function()
				if not value.Parent then
					clone:Destroy()
				end
			end)
			local v9 = fn2(clone)
			clone:SetAttribute("Live", v9)
			clone:SetAttribute("Serial", v9)
			clone.Parent = workspace
			table.insert(clones3, clone)
		end

		module.ResetSelection()

		for _, v7 in pairs(clones3) do
			module.ToggleSelection(v7)
		end

		module.SetMode("move")
		fn7("move")
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.R and not module.ghostObject then
		local mode = module:GetMode()

		if (mode == "rotate" or mode == "move") and #module.lockedTargetObjects > 0 then
			module.SetMode(mode == "rotate" and "move" or "rotate")
			fn7(module:GetMode())
		end
	else
		if input.KeyCode == Enum.KeyCode.V and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and #module.lockedTargetObjects > 0 and not module.ghostObject then
			fn(module.lockedTargetObjects[1])
			return
		end

		local v7 = module.active and v6[input.KeyCode]

		if v7 then
			onMouseButton1Clicks[v7]()
		end
	end
end)

local function fn8()
	local spawnLocation = module.lockedTargetObjects[1]

	if module:GetMode() == "select" and spawnLocation then
		if v5 ~= spawnLocation then
			fn4()
			table.insert(connections, spawnLocation:GetPropertyChangedSignal("Parent"):Connect(function()
				if not spawnLocation.Parent then
					fn4()
				end
			end))
			local clone = sideContainer:Clone()

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant.Name == "Toggle" then
					local parent2 = descendant.Parent
					local property = string.gsub(parent2.Name, " ", "")
					descendant.BackgroundColor3 = not spawnLocation:GetAttribute(property) and Color3.fromRGB(
						255,
						87,
						87
					) or Color3.fromRGB(114, 255, 98)

					if spawnLocation:IsA("SpawnLocation") then
						if parent2.Name == "Destructible" or parent2.Name == "Fragile" or parent2.Name == "No Attack" then
							parent2:Destroy()
						end
					elseif parent2.Name == "Checkpoint" then
						parent2:Destroy()
					end

					if parent2.Parent then
						local property2 = property
						local v9 = descendant
						parent2.MouseButton1Click:Connect(function()
							shared.sfx({
								SoundId = "rbxassetid://15675055424",
								Parent = workspace,
								Volume = 0.3
							}):Play()
							local communicate = localPlayer.Character:FindFirstChild("Communicate")
							local attribute = spawnLocation:GetAttribute(property2)

							if not communicate then
								return
							end

							local list = {}

							for k, lockedTargetObject in pairs(module.lockedTargetObjects) do
								table.insert(list, {
									Serial = lockedTargetObject:GetAttribute("Serial")
								})
								lockedTargetObject:SetAttribute(property2, not attribute)

								if lockedTargetObject:GetAttribute("NoAttack") then
									local CollectionService = game:GetService("CollectionService")
									CollectionService:AddTag(lockedTargetObject, "NoAttackPS")
								else
									local CollectionService = game:GetService("CollectionService")
									CollectionService:RemoveTag(lockedTargetObject, "NoAttackPS")
								end
							end

							if attribute then
								v9.BackgroundColor3 = Color3.fromRGB(255, 87, 87)
							else
								v9.BackgroundColor3 = Color3.fromRGB(114, 255, 98)
							end

							communicate:FireServer({
								Goal = "PS Build",
								Todo = "Property Change",
								List = list,
								Property = property2,
								New = not attribute
							})
						end)
					end
				elseif descendant.Name == "Clone" then
					descendant.MouseButton1Click:Connect(function()
						shared.sfx({
							SoundId = "rbxassetid://15675055424",
							Parent = workspace,
							Volume = 0.3
						}):Play()
						fn(spawnLocation)
					end)
				elseif descendant.Name == "Shape" then
					descendant.MouseButton1Click:Connect(function()
						shared.sfx({
							SoundId = "rbxassetid://15675055424",
							Parent = workspace,
							Volume = 0.3
						}):Play()
						local names = {}

						for _, v7 in pairs(Enum.PartType:GetEnumItems()) do
							table.insert(names, v7.Name)
						end

						fn6({
							Title = "Shape",
							Contents = names
						})
					end)
				elseif descendant.Name == "Material" then
					descendant.MouseButton1Click:Connect(function()
						shared.sfx({
							SoundId = "rbxassetid://15675055424",
							Parent = workspace,
							Volume = 0.3
						}):Play()
						local names = {}

						for _, v7 in pairs(Enum.Material:GetEnumItems()) do
							table.insert(names, v7.Name)
						end

						fn6({
							Title = "Material",
							Contents = names
						})
					end)
				elseif descendant.Name == "Light" then
					descendant.MouseButton1Click:Connect(function()
						shared.sfx({
							SoundId = "rbxassetid://15675055424",
							Parent = workspace,
							Volume = 0.3
						}):Play()
						fn6({
							Title = "Light",
							Contents = {
								{
									"Emit Light",
									Toggle = true
								},
								{
									"Range",
									Text = true
								},
								{
									"Brightness",
									Text = true
								}
							}
						})
					end)
				elseif descendant.Name == "Text" then
					descendant.MouseButton1Click:Connect(function()
						shared.sfx({
							SoundId = "rbxassetid://15675055424",
							Parent = workspace,
							Volume = 0.3
						}):Play()
						fn6({
							Title = "Text Display",
							Contents = {
								{
									"Text",
									Text = true
								},
								{
									"Text Font",
									Button = true
								},
								{
									"Text Color",
									Button = true
								},
								{
									"Text Transparency",
									Text = true
								},
								{
									"Text Outline",
									Toggle = true
								}
							}
						})
					end)
				elseif descendant.Name == "Moveset Modifier" then
					descendant.MouseButton1Click:Connect(function()
						shared.sfx({
							SoundId = "rbxassetid://15675055424",
							Parent = workspace,
							Volume = 0.3
						}):Play()
						local contents = {
							{
								"Random Moveset",
								Toggle = true
							},
							{
								"Clear Previous",
								Toggle = true
							}
						}
						local remoteFunction = game.ReplicatedStorage:FindFirstChild("RemoteFunction")

						if remoteFunction then
							local HttpService = game:GetService("HttpService")
							local jSONDecode = HttpService:JSONDecode(remoteFunction:InvokeServer(nil, true))

							for _, v8 in pairs(jSONDecode) do
								table.insert(contents, {
									v8.Name,
									Toggle = true
								})
							end
						end

						table.insert(contents, {
							"Morph",
							Toggle = true
						})

						for k, skillset in pairs(skillsets) do
							if not Info:CanGiveMoveset(k, true) then
								continue
							end

							for _, v8 in pairs(skillset.Base) do
								table.insert(contents, {
									v8,
									Toggle = true
								})
							end

							for _, v8 in pairs(skillset.Ultimate) do
								table.insert(contents, {
									v8,
									Toggle = true
								})
							end
						end

						for _, v8 in pairs(Info.Vaulted) do
							table.insert(contents, {
								v8,
								Toggle = true
							})
						end

						fn6({
							Title = "Moves",
							Contents = contents
						})
					end)
				elseif descendant.Name == "Mesh" then
					descendant.MouseButton1Click:Connect(function()
						shared.sfx({
							SoundId = "rbxassetid://15675055424",
							Parent = workspace,
							Volume = 0.3
						}):Play()
						fn6({
							Title = "Mesh",
							Contents = {
								{
									"Mesh ID",
									Text = true
								},
								{
									"Mesh Texture ID",
									Text = true
								}
							}
						})
					end)
				elseif descendant.Name == "Gear Spawner" then
					descendant.MouseButton1Click:Connect(function()
						shared.sfx({
							SoundId = "rbxassetid://15675055424",
							Parent = workspace,
							Volume = 0.3
						}):Play()
						local children2 = game.ReplicatedStorage.Gears:GetChildren()
						table.sort(children2, function(a, b)
							return string.byte(string.sub(a.Name, 1, 1):lower()) < string.byte(string.sub(b.Name, 1, 1):lower())
						end)
						local contents = {
							{
								"Random Gears",
								Toggle = true,
								ToolName = "Random Gears"
							},
							{
								"Clear Previous",
								Toggle = true,
								ToolName = "Clear Previous"
							}
						}

						for _, v8 in pairs(children2) do
							table.insert(contents, {
								separateCapLockedChars(v8.Name),
								Toggle = true,
								ToolName = v8.Name
							})
						end

						fn6({
							Title = "Gears",
							Contents = contents
						})
					end)
				elseif descendant.Name == "Scale" then
					local v7 = descendant
					descendant:GetPropertyChangedSignal("Text"):Connect(function()
						v7.Text = v7.Text:gsub("[^%d%.]", "")
					end)
					local v8 = descendant
					descendant.FocusLost:Connect(function(p)
						local communicate = localPlayer.Character:FindFirstChild("Communicate")

						if not tonumber(v8.Text) then
							return
						end

						if tonumber(v8.Text) == 0 then
							v8.Text = 0.0001
						end

						local list = {}

						for k, lockedTargetObject in pairs(module.lockedTargetObjects) do
							table.insert(list, {
								Serial = lockedTargetObject:GetAttribute("Serial")
							})
						end

						local model = Instance.new("Model")
						local children2 = {}

						for i, child in pairs(module.groupSelectionHolder:GetChildren()) do
							if not child:GetAttribute("Pseudo") then
								continue
							end

							table.insert(children2, child)
							child.Parent = model
						end

						model:ScaleTo((tonumber(v8.Text)))

						for k, v10 in pairs(children2) do
							v10.Parent = module.groupSelectionHolder
						end

						model:Destroy()
						communicate:FireServer({
							Goal = "PS Build",
							Todo = "Scale Change",
							List = list,
							New = v8.Text
						})
						v8.Text = ""
					end)
				elseif descendant.Name == "Transparency" then
					local v7 = descendant
					descendant:GetPropertyChangedSignal("Text"):Connect(function()
						local communicate = localPlayer.Character:FindFirstChild("Communicate")

						if not communicate then
							v7.Text = spawnLocation.Transparency
							return
						end

						if not tonumber(v7.Text) then
							v7.Text = spawnLocation.Transparency
							return
						end

						if tonumber(v7.Text) > 1 then
							v7.Text = 1
						end

						local list = {}

						for k, lockedTargetObject in pairs(module.lockedTargetObjects) do
							table.insert(list, {
								Serial = lockedTargetObject:GetAttribute("Serial")
							})
							lockedTargetObject:SetAttribute("Transparency", v7.Text)
							lockedTargetObject.Transparency = v7.Text
						end

						communicate:FireServer({
							Goal = "PS Build",
							Todo = "Property Change",
							List = list,
							Property = "Transparency",
							New = v7.Text
						})
					end)
				elseif descendant.Name == "Color" then
					descendant.MouseButton1Click:Connect(function()
						shared.sfx({
							SoundId = "rbxassetid://15675055424",
							Parent = workspace,
							Volume = 0.3
						}):Play()
						fn5(spawnLocation)
					end)
				end
			end

			local scrollingFrame2 = clone.ScrollingFrame
			scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame2.UIListLayout.AbsoluteContentSize.Y)
			scrollingFrame2.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame2.UIListLayout.AbsoluteContentSize.Y)
			end)
			clone.Position = UDim2.new(1.5, 0, 0.5, 0)
			clone.Parent = sideContainerFrame
			clone:TweenPosition(
				UDim2.new(0.5, 0, 0.5, 0),
				Enum.EasingDirection.InOut,
				Enum.EasingStyle.Quad,
				0.75,
				true
			)
			table.insert(clones, clone)
			shared.sfx({
				SoundId = ({ "rbxassetid://15675028888", "rbxassetid://15675024286", "rbxassetid://15674975792" })[math.random(
					1,
					3
				)],
				Parent = workspace,
				Volume = 0.3
			}):Play()
			v5 = spawnLocation
		end
	else
		v5 = nil
		fn4()
	end
end

local v7 = false

function shared.buildmode()
	local v8 = module.Activate(fn8)
	module.SetGridSize(4)
	module.SetAngleSnap(5)
	module.SetMoveSnap(0)
	module.SetResizeSnap(0.25)
	v8.Orientation = createVector(0, -67.499, 0)
	parent.Enabled = true

	if not v7 then
		if not shared.ismobile then
			shared.repfire({
				Effect = "Notification",
				Title = "INFO",
				Text = string.format("Hold left control to multi select\n•ᴗ•"),
				Duration = 5
			})
		end

		v7 = true
		localPlayer:GetAttributeChangedSignal("SaveBuildCD"):Connect(function()
			now = tick()
		end)
	end
end

function shared.nobuildmode()
	parent.Enabled = false
	module.ResetSelection()
	module.Deactivate()

	if v4 then
		v4.Frame.BackgroundTransparency = 0.7
		v4.Frame.BackgroundColor3 = Color3.new(0, 0, 0)
	end
end

localPlayer.CharacterAdded:Connect(shared.nobuildmode)

for _, v8 in pairs({ sideContainerFrame, menuContainer.SideContainerFrameTwo, menuContainer.SideContainerFrameThree }) do
	-- equivalent calls inferred from this helper; original call sites unknown
	local v9 = v8

	local function fn9()
		if #v9:GetChildren() == 0 then
			v9.Visible = false
		else
			v9.Visible = true
		end
	end

	v8.ChildAdded:Connect(fn9)
	v8.ChildRemoved:Connect(fn9)
	fn9() -- equivalent call inferred; original call site unknown
end

module.PartCreated:Connect(function(part, p, p2)
	if part:GetAttribute("Prefab") then
		return part:SetAttribute("Created", true)
	end

	local communicate = localPlayer.Character.Communicate
	local serial = p or fn2(part)
	local v9 = {
		Goal = "PS Build",
		Todo = "Place",
		Class = part.ClassName,
		Properties = part:GetAttributes(),
		Size = part.Size,
		Shape = 0,
		Serial = 0,
		Transparency = 0,
		Material = 0,
		Color = 0,
		CFrame = 0
	}
	local shape

	if part:IsA("Part") then
		shape = part.Shape or nil
	end

	v9.Shape = shape
	v9.Serial = serial
	v9.Transparency = part:GetAttribute("Transparency")
	v9.Material = part.Material
	v9.Color = part.Color
	v9.CFrame = p2 or module.currentGoal
	communicate:FireServer(v9)
	part:SetAttribute("Serial", serial)
end)
module.PartRemoved:Connect(function(instance)
	local communicate = localPlayer.Character.Communicate
	local serial = instance:GetAttribute("Serial") or fn2(instance)

	if serial then
		communicate:FireServer({
			Goal = "PS Build",
			Todo = "Delete",
			Serial = serial
		})
		shared.sfx({
			SoundId = "rbxassetid://15675075163",
			CFrame = instance.CFrame,
			Volume = 0.2
		}):Play()
	end
end)
module.PartChanged:Connect(function(items)
	local communicate = localPlayer.Character.Communicate
	local list = {}

	for _, item in pairs(items) do
		table.insert(list, {
			Serial = item:GetAttribute("Serial"),
			Size = item.Size,
			CFrame = item.CFrame
		})
	end

	communicate:FireServer({
		Goal = "PS Build",
		Todo = "Resize",
		List = list
	})
end)