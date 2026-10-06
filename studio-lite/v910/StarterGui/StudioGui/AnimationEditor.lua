local createVector = vector.create
_G.AnimationEdit = false
local parent = script.Parent
local MenuHandler = require(parent.AnimationEditor.MenuHandler)
local EasingStyles = require(parent.AnimationEditor.EasingStyles)
local _ = parent.AnimationEditor.GUIs
local v = {}
local Players = game:GetService("Players")
local v2 = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
local playerGui = v2:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local guiInset, _ = GuiService:GetGuiInset()
local v3 = {
	TweenCursor = true,
	Snapping = true,
	TransparentSelect = true,
	Interpolation = true,
	Tooltips = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function Repeat(fn)
	local flag = true
	spawn(function()
		while flag do
			fn()
			task.wait()
		end
	end)
	return function()
		flag = false
	end
end

function repairedCFrameSnailVersion(object)
	local sqrt = math.sqrt
	local components, v4, v5, v6, _, v7, v8, _, v9, v10, _, v11 = object:components()
	local v12 = v9 * v10 - v8 * v11
	local v13 = v6 * v11 - v7 * v10
	local v14 = v7 * v8 - v6 * v9
	local v15 = v8 * v14 - v13 * v10
	local v16 = v12 * v10 - v14 * v6
	local v17 = v6 * v13 - v12 * v8
	local v18 = sqrt(v6 ^ 2 + v8 ^ 2 + v10 ^ 2)
	local v19 = sqrt(v12 ^ 2 + v13 ^ 2 + v14 ^ 2)
	local v20 = sqrt(v15 ^ 2 + v16 ^ 2 + v17 ^ 2)
	return CFrame.new(
		components,
		v4,
		v5,
		v6 / v18,
		v12 / v19,
		v15 / v20,
		v8 / v18,
		v13 / v19,
		v16 / v20,
		v10 / v18,
		v14 / v19,
		v17 / v20
	)
end

function repairedCFrame(object)
	local components, v4, v5, v6, _, v7, v8, _, v9, v10, _, v11 = object:components()
	local v12 = v9 * v10 - v8 * v11
	local v13 = v6 * v11 - v7 * v10
	local v14 = v7 * v8 - v6 * v9
	local v15 = v8 * v14 - v13 * v10
	local v16 = v12 * v10 - v14 * v6
	local v17 = v6 * v13 - v12 * v8
	local v18 = (v6 ^ 2 + v8 ^ 2 + v10 ^ 2) ^ 0.5
	local v19 = (v12 ^ 2 + v13 ^ 2 + v14 ^ 2) ^ 0.5
	local v20 = (v15 ^ 2 + v16 ^ 2 + v17 ^ 2) ^ 0.5
	return CFrame.new(
		components,
		v4,
		v5,
		v6 / v18,
		v12 / v19,
		v15 / v20,
		v8 / v18,
		v13 / v19,
		v16 / v20,
		v10 / v18,
		v14 / v19,
		v17 / v20
	)
end

function isCFrameBroken(object)
	local _, _, _, v4, v5, v6, v7, v8, v9, v10, v11, v12 = object:components()
	local vector2 = Vector3.new(v4, v7, v10)
	local vector3 = Vector3.new(v5, v8, v11)
	local vector4 = Vector3.new(v6, v9, v12)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fuzzyEq(magnitude, p)
		return math.abs(magnitude - p) < 0.001
	end

	local v13 = not (fuzzyEq(vector2.magnitude, 1) and fuzzyEq(vector3.magnitude, 1))

	if not v13 then
		local v14 = fuzzyEq(vector4.magnitude, 1) -- equivalent call inferred; original call site unknown
		return not v14
	end

	return v13
end

function approx(p)
	return math.floor(p * 1000) / 1000
end

function spairs(items, callback)
	local v4 = {}

	for k in pairs(items) do
		v4[#v4 + 1] = k
	end

	if callback then
		table.sort(v4, function(a, b)
			return callback(items, a, b)
		end)
	else
		table.sort(v4)
	end

	local count = 0
	return function()
		count += 1

		if v4[count] then
			return v4[count], items[v4[count]]
		end
	end
end

local function UD(p, p2, p3, p4)
	return UDim2.new(p, p2, p3, p4)
end

local function CenterPos(p, p2)
	return UD(0.5, -p / 2, 0.5, -p2 / 2)
end

local function ConstSize(p, p2)
	return UD(0, p, 0, p2)
end

function Make(className, items)
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		if type(k) == "number" then
			item.Parent = instance
		else
			instance[k] = item
		end
	end

	return instance
end

function round(p)
	return (math.floor(p + 0.5))
end

function printCFrame(p, object)
	local v4 = { object:components() }
	local v5 = ""

	for k, v6 in pairs(v4) do
		v5 ..= " " .. k .. "# " .. v6
	end

	print(p .. " " .. v5)
end

function printVector(data)
	print("X " .. data.x .. " Y " .. data.y .. " Z " .. data.z)
end

function tablelength(items)
	local count = 0

	for _ in pairs(items) do
		count += 1
	end

	return count
end

local function weldBetween(p, part, p2)
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = p
	motor6D.Part1 = part
	motor6D.C0 = CFrame.new()
	motor6D.C1 = part.CFrame:inverse() * p.CFrame

	if p2 ~= nil and p2 then
		p = p2
	end

	motor6D.Parent = p
	return motor6D
end

local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}

function safeNil(p)
	if p == nil then
		return "NIL"
	end

	return p
end

function isSafeNIL(p)
	return p == "NIL"
end

function registerOn(list, p, p2)
	local element = safeNil(p)
	local order = 1

	if isSafeNIL(element) then
		order = 0
	else
		local parent2 = element.Parent

		while parent2 ~= nil and parent2 ~= game.Workspace do
			order += 1
			parent2 = parent2.Parent
		end
	end

	local v10 = {
		Element = element,
		Function = p2,
		Order = order
	}
	table.insert(list, v10)
	return v10
end

function unregisterOn(list, p)
	local v8 = safeNil(p)
	local v9 = 1

	while v9 <= #list do
		if list[v9].Element == v8 then
			table.remove(list, v9)
		else
			v9 += 1
		end
	end
end

function unregisterEvent(list, p)
	local v8 = 1

	while v8 <= #list do
		if list[v8] == p then
			table.remove(list, v8)
		else
			v8 += 1
		end
	end
end

function clearAllEvents()
	v4 = {}
	v5 = {}
	v6 = {}
	v7 = {}
end

function isIn(p, p2, p3)
	return p.AbsolutePosition.X <= p2 and p2 <= p.AbsolutePosition.X + p.AbsoluteSize.X and p.AbsolutePosition.Y <= p3 and p3 <= p.AbsolutePosition.Y + p.AbsoluteSize.Y
end

function listEvent(list)
	print("Event List --------------------------------------")
	local v8 = 1

	while v8 <= #list do
		local _ = list[v8].Consume

		if isSafeNIL(list[v8].Element) then
			print("Nil " .. list[v8].Order)
		else
			print(list[v8].Element.Name .. " " .. list[v8].Order)
		end

		v8 += 1
	end
end

local mouse = v2:GetMouse()
wait(0.2)

local function mouseCallbackCheck(p)
	for _, v8 in spairs(p, function(p2, p3, p4)
		return p2[p3].Order > p2[p4].Order
	end) do
		if isSafeNIL(v8.Element) then
			if v8.Function(mouse.X, mouse.Y) then
				break
			end
		elseif isIn(v8.Element, mouse.X, mouse.Y) and v8.Function(
			mouse.X - v8.Element.AbsolutePosition.X,
			mouse.Y - v8.Element.AbsolutePosition.Y
		) then
			break
		end
	end
end

mouse.Button1Down:Connect(function()
	mouseCallbackCheck(v4)
end)
mouse.Button2Down:Connect(function()
	mouseCallbackCheck(v5)
end)
mouse.Button1Up:Connect(function()
	mouseCallbackCheck(v6)
end)
mouse.Button2Up:Connect(function()
	mouseCallbackCheck(v7)
end)
local vector2 = Vector2.new()
local UserInputService = game:GetService("UserInputService")
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		vector2 = Vector2.new(input.Position.X, input.Position.Y)
	end
end)

function mouseRaycast(list)
	local viewportPointToRay = workspace.CurrentCamera:ViewportPointToRay(vector2.X, vector2.Y + guiInset.Y)
	local ray = Ray.new(viewportPointToRay.Origin, viewportPointToRay.Direction.Unit * 512)
	local v8, v9, v10

	while true do
		v8, v9, v10 = workspace:FindPartOnRayWithIgnoreList(ray, list)

		if not v8 then
			break
		end

		local v11 = v8.Transparency > 0.9 and v3.TransparentSelect == false or v8.Name == "SelectionPart"
		local v12 = v8.Name == "HumanoidRootPart"
		local animatedPart = findAnimatedPart(v8)
		local v13

		if animatedPart then
			v13 = not partInclude[animatedPart.Name]
		else
			v13 = false
		end

		if v11 or v12 or v13 then
			table.insert(list, v8)
		else
			break
		end
	end

	return v8, v9, v10
end

timelineUI = nil
saveUI = nil
loadUI = nil
stopAnimUI = nil
timeChangeUI = nil
selectedLine = nil
rotateMoveUI = nil
local offset = 0
local v8 = 50
local v9 = 1
local v10 = 0.5
local count = 0
local animationLength2 = 0
local v11 = 0.05
local v12 = 0.1
local v13 = 0.05
partList = {}
undoMemory = {}
redoMemory = {}
undoPointer = 0
partListByName = {}
partToItemMap = {}
partToLineNumber = {}
local v14 = nil
animationController = nil
partInclude = {}
cursorClick = false
modal = false
rotateMode = true
partSelection = nil
selectedKeyframe = nil
rotateStep = 0
moveStep = 0
game.Workspace:WaitForChild("Camera")
screenWidth = game.Workspace.Camera.ViewportSize.X
buttonOnColor = Color3.new(0.7843137254901961, 0.7843137254901961, 0.7843137254901961)
buttonOffColor = Color3.new(0.19607843137254902, 0.19607843137254902, 0.19607843137254902)
dropDownColor = Color3.new(0.08235294117647059, 0.08235294117647059, 0.08235294117647059)
dropDownMouseClickEater = nil
dropDownMenuClearEvent = nil

function displayDropDownMenu(_, items, p, p2)
	local dropDownFrame = timelineUI.RootFrame:FindFirstChild("DropDownFrame")

	if dropDownFrame then
		dropDownFrame:Destroy()
	end

	modal = true
	local v15 = tablelength(items)
	local make = Make
	local v16 = {
		Parent = timelineUI.RootFrame,
		Name = "DropDownFrame",
		Style = "Custom",
		Position = 0,
		Size = 0,
		BackgroundColor3 = 0,
		BackgroundTransparency = 0.3,
		ZIndex = 10
	}
	local v17 = p - 100
	v16.Position = UDim2.new(0, v17, 0, p2)
	local v18 = 5 + v15 * 25
	v16.Size = UDim2.new(0, 100, 0, v18)
	v16.BackgroundColor3 = Color3.new(0.08235294117647059, 0.08235294117647059, 0.08235294117647059)
	local parent2 = make("Frame", v16)
	local count2 = 0
	local v20 = false
	local v21 = nil

	for _, item in pairs(items) do
		local make2 = Make
		local v22 = {
			Parent = parent2,
			Name = item .. "Button",
			Font = "Arial",
			FontSize = GuiSettings.TextMed,
			TextColor3 = GuiSettings.TextColor,
			Position = 0,
			Size = 0,
			BackgroundColor3 = 0,
			BackgroundTransparency = 0,
			Text = 0,
			ZIndex = 11
		}
		local v23 = count2 * 25 + 5
		v22.Position = UDim2.new(0.05, 0, 0, v23)
		v22.Size = UDim2.new(0.9, 0, 0, 20)
		v22.BackgroundColor3 = Color3.new(0.266667, 0.266667, 0.266667)
		v22.Text = item
		local v24 = item
		make2("TextButton", v22).MouseButton1Click:Connect(function()
			v20 = true
			v21 = v24
		end)
		count2 += 1
	end

	dropDownMenuClearEvent = registerOn(v4, timelineUI, function(_, _)
		task.wait(0.1)
		modal = false
		return true
	end)

	while not v20 and parent2 and modal do
		task.wait(0.1)
	end

	unregisterEvent(v4, dropDownMenuClearEvent)

	if parent2 then
		parent2:Destroy()
	end

	modal = false
	return v21
end

function showTextExtryDialog(text2, text3)
	modal = true
	local v15 = Make("ScreenGui", {
		Name = "SaveUI",
		Make("Frame", {
			Name = "RootFrame",
			Style = "Custom",
			Position = UDim2.new(0.5, -200, 0.5, 0),
			Size = UDim2.new(0, 400, 0, 105),
			BackgroundColor3 = Color3.new(0.08235294117647059, 0.08235294117647059, 0.08235294117647059),
			BackgroundTransparency = 0,
			Make("TextLabel", {
				Name = "TitleBar",
				Font = "ArialBold",
				FontSize = "Size14",
				TextColor3 = GuiSettings.TextColor,
				Position = UDim2.new(0.05, 0, 0, 5),
				Size = UDim2.new(0.9, 0, 0, 15),
				BackgroundTransparency = 1,
				Text = text2,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			Make("Frame", {
				Parent = timelineUI,
				Name = "SaveNameFrame",
				Style = "Custom",
				Position = UDim2.new(0.05, 0, 0, 25),
				Size = UDim2.new(0.9, 0, 0, 30),
				BackgroundColor3 = Color3.new(0.39215686274509803, 0.39215686274509803, 0.39215686274509803),
				BackgroundTransparency = 0,
				Make("TextBox", {
					Name = "SaveNameBox",
					Font = "ArialBold",
					FontSize = "Size14",
					TextColor3 = GuiSettings.TextColor,
					Position = UDim2.new(0.05, 0, 0, 0),
					Size = UDim2.new(0.9, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = text3,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			}),
			Make("TextButton", {
				Name = "OKButton",
				Font = "ArialBold",
				FontSize = GuiSettings.TextMed,
				TextColor3 = GuiSettings.TextColor,
				Position = UDim2.new(0.05, 0, 0, 65),
				Size = UDim2.new(0.4, 0, 0, 30),
				BackgroundColor3 = Color3.new(0.39215686274509803, 0.39215686274509803, 0.5882352941176471),
				BackgroundTransparency = 0,
				Text = "OK"
			}),
			Make("TextButton", {
				Name = "CancelButton",
				Font = "ArialBold",
				FontSize = GuiSettings.TextMed,
				TextColor3 = GuiSettings.TextColor,
				Position = UDim2.new(0.55, 0, 0, 65),
				Size = UDim2.new(0.4, 0, 0, 30),
				BackgroundColor3 = Color3.new(0.39215686274509803, 0.39215686274509803, 0.5882352941176471),
				BackgroundTransparency = 0,
				Text = "Cancel"
			})
		})
	})
	local text = text3
	local v16 = false
	v15.RootFrame.OKButton.MouseButton1Click:Connect(function()
		text = v15.RootFrame.SaveNameFrame.SaveNameBox.Text
		v16 = true
	end)
	v15.RootFrame.CancelButton.MouseButton1Click:Connect(function()
		text = nil
		v16 = true
	end)
	v15.Parent = playerGui

	while not v16 do
		task.wait(0.1)
	end

	v15.Parent = nil
	modal = false
	return text
end

default = false

function showConfirmationDialog(text)
	modal = true
	local v15 = Make("ScreenGui", {
		Name = "SaveUI",
		Make("Frame", {
			Name = "RootFrame",
			Style = "Custom",
			Position = UDim2.new(0.5, -200, 0.5, 0),
			Size = UDim2.new(0, 400, 0, 105),
			BackgroundColor3 = Color3.new(0.08235294117647059, 0.08235294117647059, 0.08235294117647059),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Make("TextLabel", {
				Name = "TitleBar",
				Font = "ArialBold",
				FontSize = "Size14",
				TextColor3 = GuiSettings.TextColor,
				Position = UDim2.new(0.05, 0, 0, 5),
				Size = UDim2.new(0.9, 0, 0, 30),
				BackgroundTransparency = 1,
				Text = text,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			Make("TextButton", {
				Name = "OKButton",
				Font = "ArialBold",
				FontSize = GuiSettings.TextMed,
				TextColor3 = GuiSettings.TextColor,
				Position = UDim2.new(0.05, 0, 0, 65),
				Size = UDim2.new(0.4, 0, 0, 30),
				BackgroundColor3 = Color3.new(0.39215686274509803, 0.39215686274509803, 0.5882352941176471),
				BackgroundTransparency = 0,
				Text = "OK"
			}),
			Make("TextButton", {
				Name = "CancelButton",
				Font = "ArialBold",
				FontSize = GuiSettings.TextMed,
				TextColor3 = GuiSettings.TextColor,
				Position = UDim2.new(0.55, 0, 0, 65),
				Size = UDim2.new(0.4, 0, 0, 30),
				BackgroundColor3 = Color3.new(0.39215686274509803, 0.39215686274509803, 0.5882352941176471),
				BackgroundTransparency = 0,
				Text = "Cancel"
			})
		})
	})
	local default2 = default
	local v16 = false
	v15.RootFrame.OKButton.MouseButton1Click:Connect(function()
		default2 = true
		v16 = true
	end)
	v15.RootFrame.CancelButton.MouseButton1Click:Connect(function()
		default2 = false
		v16 = true
	end)
	v15.Parent = playerGui

	while not v16 do
		task.wait()
	end

	v15.Parent = nil
	modal = false
	return default2
end

animationPriorityList = {
	"Core",
	"Idle",
	"Movement",
	"Action"
}
animationLength = 2
keyframeList = {}
loopAnimation = false
animationPriority = "Core"
animationFramerate = 0.05
copyPoseList = {}
poseColor = Color3.new(0, 0.7, 0)
copyPoseColor = Color3.new(0.5882352941176471, 0.5882352941176471, 0.7843137254901961)

function copyPose(p, p2)
	if copyPoseList[p.Name] == p2 then
		copyPoseList[p.Name].UI.BackgroundColor3 = poseColor
		copyPoseList[p.Name] = nil
	else
		if copyPoseList[p.Name] ~= nil then
			copyPoseList[p.Name].UI.BackgroundColor3 = poseColor
		end

		copyPoseList[p.Name] = p2
		p2.updateColor(true)
	end
end

function resetCopyPoseList()
	for _, v15 in pairs(copyPoseList) do
		v15.updateColor(false)
	end

	copyPoseList = {}
end

function pastePoses()
	if tablelength(copyPoseList) <= 0 then
		return
	end

	local keyframe = getKeyframe(animationLength2)

	if keyframe == nil then
		keyframe = createKeyframe(animationLength2)
	end

	for k, v15 in pairs(copyPoseList) do
		local v16 = partListByName[k]

		if keyframe.Poses[v16.Item] == v15 then
			continue
		end

		if keyframe.Poses[v16.Item] == nil then
			keyframe.Poses[v16.Item] = initializePose(keyframe, v16.Item)
		end

		if not keyframe.Poses[v16.Item] then
			continue
		end

		keyframe.Poses[v16.Item].CFrame = v15.CFrame
		keyframe.Poses[v16.Item].EasingDirection = v15.EasingDirection
		keyframe.Poses[v16.Item].EasingStyle = v15.EasingStyle
		keyframe.Poses[v16.Item].updateColor()
	end

	resetCopyPoseList()
	updateCursorPosition()
end

function keyframeTimeClamp(p)
	if animationLength < p then
		return animationLength
	end

	if not v3.Snapping then
		return p
	end

	local v15 = p + v13 / 2
	return v15 - v15 % v13
end

function deletePose(p, p2)
	if partInclude[p2.Name] and p ~= nil and partToItemMap[p2] ~= nil and partToItemMap[p2].Motor6D ~= nil and p.Poses[p2] ~= nil then
		if copyPoseList[p2.Name] == p.Poses[p2] then
			copyPoseList[p2.Name] = nil
		end

		p.Poses[p2] = nil
		local child = p.UI:FindFirstChild("Pose" .. p2.Name)

		if child ~= nil then
			child.Parent = nil
			unregisterOn(v5, child)
			unregisterOn(v4, child)
		end

		updateCursorPosition()
	end
end

function initializePose(data, p, p2, p3)
	if not partInclude[p.Name] and (p3 == false or p3 == nil) or data == nil then
		return nil
	end

	local pos = data.Poses[p]

	if pos ~= nil or partToItemMap[p] == nil or partToItemMap[p].Motor6D == nil then
		return pos
	end

	resetCopyPoseList()
	local closestPose = getClosestPose(data.Time, p)
	pos = {}

	if closestPose == nil then
		pos.CFrame = CFrame.new()
	else
		pos.CFrame = closestPose.CFrame
	end

	local v15 = partToItemMap[p]
	pos.CFrame = getMotorC1(v15, data.Time) * v15.OriginC1:inverse()
	pos.Item = partToItemMap[p]
	pos.Time = data.Time

	if p2 then
		pos.EasingStyle = p2.EasingStyle
		pos.EasingDirection = p2.EasingDirection
	else
		pos.EasingStyle = Enum.PoseEasingStyle.Linear
		pos.EasingDirection = Enum.PoseEasingDirection.Out
	end

	data.Poses[p] = pos
	local make = Make
	local v16 = {
		Parent = data.UI,
		Name = "Pose" .. p.Name,
		Style = "Custom",
		Position = 0,
		Size = 0,
		BackgroundColor3 = 0,
		BackgroundTransparency = 0,
		Text = "",
		TextColor3 = 0
	}
	local v17 = (partToLineNumber[p] - 1) * 20 + 6 - timelineUI.RootFrame.KeyframeContainer.CanvasPosition.Y
	v16.Position = UDim2.new(0, -6.5, 0, v17)
	v16.Size = UDim2.new(0, 15, 0, 15)
	v16.BackgroundColor3 = poseColor
	v16.TextColor3 = Color3.new(1, 1, 1)
	local UI2 = make("TextButton", v16)
	pos.UI = UI2

	function pos.updateUI()
		if partToLineNumber[p] then
			local UI = pos.UI
			local v19 = (partToLineNumber[p] - 1) * 20 + 6 - timelineUI.RootFrame.KeyframeContainer.CanvasPosition.Y
			UI.Position = UDim2.new(0, -6.5, 0, v19)
		end
	end

	UI2.MouseButton1Click:Connect(function()
		local v19 = mouse
		local v20 = displayDropDownMenu(
			timelineUI.RootFrame.KeyframeContainer.TimelineFrame,
			{ "Copy Pose", "Delete Pose", "Easing..." },
			v19.X,
			v19.Y
		)

		if v20 == "Copy Pose" then
			copyPose(p, pos)
		elseif v20 == "Delete Pose" then
			if data.Time > 0 then
				registerUndo({
					action = "deletePose"
				})
				deletePose(data, p)
			end
		elseif v20 == "Easing..." then
			modal = true
			MenuHandler.SetEasingStyle(pos, function()
				modal = false
				pos.updateColor()
			end)
			modal = false
		end
	end)

	function pos.updateNodePosition()
		local Y = timelineUI.RootFrame.KeyframeContainer.CanvasPosition.Y
		local UI = pos.UI
		local v19 = (partToLineNumber[p] - 1) * 20 + 6 - Y
		UI.Position = UDim2.new(0, -6.5, 0, v19)
	end

	function pos.updateColor(p4)
		if p4 then
			pos.UI.BackgroundColor3 = copyPoseColor
			return
		end

		local name = pos.EasingStyle.Name

		if name == "Linear" then
			pos.UI.Text = ""
			pos.UI.BackgroundColor3 = poseColor
		elseif name == "Constant" then
			pos.UI.Text = "-"
			pos.UI.BackgroundColor3 = Color3.new(0.533333, 0.533333, 0.533333)
		elseif name == "Cubic" then
			pos.UI.Text = "c"
			pos.UI.BackgroundColor3 = Color3.new(0.439216, 0.176471, 0)
		elseif name == "CubicV2" then
			pos.UI.Text = "C"
			pos.UI.BackgroundColor3 = Color3.new(1, 0.41568627450980394, 0)
		elseif name == "Elastic" then
			pos.UI.Text = "E"
			pos.UI.BackgroundColor3 = Color3.new(0.0941176, 0.27451, 0.113725)
		elseif name == "Bounce" then
			pos.UI.Text = "B"
			pos.UI.BackgroundColor3 = Color3.new(0.639216, 0.231373, 0.8)
		else
			pos.UI.Text = "?"
			pos.UI.BackgroundColor3 = Color3.new(0.443137, 0.443137, 0)
		end
	end

	pos.updateColor()
	return pos
end

function deleteKeyframe(p, p2)
	if p2 == true then
		registerUndo({
			action = "deleteKeyframe"
		})
	end

	local v15 = keyframeTimeClamp(p)
	local v16 = keyframeList[v15]

	if v16 ~= nil then
		for _, pos in pairs(v16.Poses) do
			deletePose(v16, pos.Item.Item)
		end

		v16.UI.Parent = nil
		v16.UI = nil
		keyframeList[v15] = nil
	end
end

function createKeyframe(p, p2)
	if (p2 == true or p2 == nil) and p > 0 then
		registerUndo({
			action = "createKeyframe"
		})
	end

	local time = keyframeTimeClamp(p)
	local v16 = keyframeList[time]

	if v16 ~= nil then
		return v16
	end

	local v17 = {
		Time = time,
		Poses = {},
		Name = "Keyframe",
		UI = 0
	}
	local make = Make
	local v18 = {
		Parent = timelineUI.RootFrame.KeyframeContainer.TimelineFrame,
		Name = "Keyframe" .. time,
		Style = "Custom"
	}
	local v19 = time * v11
	v18.Position = UDim2.new(0, v19, 0, nil)
	local v20 = (count + 1) * 20
	v18.Size = UDim2.new(0, 2, 0, v20)
	v18.BackgroundColor3 = poseColor
	v18.BackgroundTransparency = 0
	do local _values = table.pack(Make("TextButton", {
	Parent = timelineUI.RootFrame,
	Name = "OptionsButton",
	Size = UDim2.new(0, 15, 0, 15),
	Position = UDim2.new(0.5, -6, 0, 0),
	BackgroundColor3 = poseColor,
	TextScaled = true,
	TextColor3 = GuiSettings.TextColor,
	Text = "kf",
	ZIndex = 3
})); for _k = 1, _values.n do v18[_k] = _values[_k] end end
	v17.UI = make("Frame", v18)
	v16 = v17
	local optionsButton = v16.UI.OptionsButton

	local function getXY()
		if timelineUI:FindFirstChild("RootFrame") then
			return
				v16.UI.AbsolutePosition.X - timelineUI.RootFrame.KeyframeContainer.TimelineFrame.AbsolutePosition.X,
				0
		end

		return 0, 0
	end

	function v16.setPos(p3)
		local v21 = p3 * v11

		if v16.Time >= animationLength - 0.009 then
			v21 -= 5
		end

		v16.UI.Position = UDim2.new(0, v21, 0, 0)
	end

	function v16.adjust()
		v16.setPos(v16.Time)
	end

	v16.adjust()

	local function moveOptionsButton()
		if timelineUI and timelineUI:FindFirstChild("RootFrame") then
		end
	end

	local now = 0
	local position = nil
	optionsButton.MouseButton1Down:Connect(function()
		lockUndoStep("keyframeMove")
		now = tick()
		position = v16.Position
		selectedKeyframe = v16
	end)
	optionsButton.MouseButton1Click:Connect(function()
		mouseCallbackCheck(v6)
		local v21 = tick() - now

		if v16.Position ~= position or v21 > 0.6 then
			return
		end

		local v22

		if timelineUI:FindFirstChild("RootFrame") then
			v22 = v16.UI.AbsolutePosition.X - timelineUI.RootFrame.KeyframeContainer.TimelineFrame.AbsolutePosition.X
		else
			v22 = 0
		end

		keyframeContextMenu(v22, 0, false)
	end)
	optionsButton.MouseButton1Down:Connect(function()
		selectedKeyframe = v16
		local v21

		if timelineUI:FindFirstChild("RootFrame") then
			v21 = v16.UI.AbsolutePosition.X - timelineUI.RootFrame.KeyframeContainer.TimelineFrame.AbsolutePosition.X
		else
			v21 = 0
		end

		keyframePositionShift(v21, 0)
	end)
	v16.UI.Changed:Connect(function()
		if timelineUI and not timelineUI:FindFirstChild("RootFrame") then
		end
	end)

	if timelineUI then
		timelineUI:FindFirstChild("RootFrame")
	end

	if time <= 0 then
		for k, _ in pairs(partList) do
			initializePose(v16, k)
		end
	end

	keyframeList[time] = v16
	return v16
end

function adjustKeyframes()
	for _, v15 in pairs(keyframeList) do
		v15.adjust()

		for _, pos in pairs(v15.Poses) do
			pos.updateNodePosition()
		end
	end
end

function resetKeyframeToDefaultPose(p)
	for k, v15 in pairs(partList) do
		initializePose(p, k)
		local pos = p.Poses[k]

		if not pos then
			continue
		end

		pos.CFrame = CFrame.new()
		v15.Motor6D.C1 = v15.OriginC1
		pos.EasingStyle = Enum.PoseEasingStyle.Linear
		pos.EasingDirection = Enum.PoseEasingDirection.Out
		pos.updateColor()
	end
end

function moveKeyframe(state, time)
	if keyframeList[time] == nil then
		registerUndo({
			action = "keyframeMove",
			keyframe = state,
			oldTime = state.Time
		})
		keyframeList[state.Time] = nil
		state.Time = time

		for _, pos in pairs(state.Poses) do
			pos.Time = state.Time
		end

		state.setPos(time)
		keyframeList[time] = state
		updateCursorPosition()
		task.wait()
	end
end

function nudgeView()
	local item = v14.Item
	item.CFrame *= CFrame.new(0, 1, 0)
	item.CFrame *= CFrame.new(0, -1, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findTime(p)
	offset = math.max(
		timelineUI.RootFrame.KeyframeContainer.CanvasSize.X.Offset,
		timelineUI.RootFrame.KeyframeContainer.AbsoluteSize.X
	)
	v11 = offset / animationLength
	local v15 = p / v11
	return (keyframeTimeClamp(v15))
end

function getKeyframe(p)
	local v15 = keyframeTimeClamp(p)
	return keyframeList[v15]
end

function getKeyframeData(p, p2, p3, p4)
	local keyframe = getKeyframe(p2)

	if keyframe == nil and p3 then
		keyframe = createKeyframe(animationLength2)
	end

	if keyframe == nil or partToItemMap[p] == nil or partToItemMap[p].Motor6D == nil then
		return nil
	end

	if keyframe.Poses[p] == nil and p4 then
		initializePose(keyframe, p)
	end

	return keyframe.Poses[p]
end

function getCurrentKeyframeData(p, p2, p3)
	return getKeyframeData(p, animationLength2, p2, p3)
end

function getClosestPose(p, p2)
	local v15 = nil

	for k, v16 in spairs(keyframeList, function(p3, p4, p5)
		return p3[p4].Time < p3[p5].Time
	end) do
		if p < k then
			break
		end

		if v16.Poses[p2] then
			v15 = v16.Poses[p2]
		end
	end

	return v15
end

function getClosestNextPose(p, p2)
	local v15 = nil

	for k, v16 in spairs(keyframeList, function(p3, p4, p5)
		return p3[p4].Time > p3[p5].Time
	end) do
		if k <= p then
			break
		end

		if v16.Poses[p2] then
			v15 = v16.Poses[p2]
		end
	end

	return v15
end

function resetKeyframes()
	resetCopyPoseList()

	for k, _ in spairs(keyframeList, function(p, p2, p3)
		return p[p2].Time < p[p3].Time
	end) do
		deleteKeyframe(k)
	end

	keyframeList = {}
end

function undo()
	if #undoMemory <= 0 then
		return
	end

	local v15 = undoMemory[#undoMemory]
	table.remove(undoMemory, #undoMemory)
	local animationFromCurrentData = createAnimationFromCurrentData()
	loadImportAnim(v15.undo)
	updateTimeLabels()
	v15.undo = animationFromCurrentData
	table.insert(redoMemory, v15)
end

function redo()
	if #redoMemory > 0 then
		local v15 = redoMemory[#redoMemory]
		local animationFromCurrentData = createAnimationFromCurrentData()
		loadImportAnim(v15.undo)
		v15.undo = animationFromCurrentData
		table.remove(redoMemory, #redoMemory)
		table.insert(undoMemory, v15)
	end
end

function registerUndo(state)
	redoMemory = {}

	if #undoMemory > 0 then
		local v15 = undoMemory[#undoMemory]

		if state.action == "editTransform" or state.action == "editRotate" or state.action == "keyframeMove" then
			if v15.action ~= state.action or v15.item ~= state.item or v15.locked == true then
				state.undo = createAnimationFromCurrentData()
				table.insert(undoMemory, state)
			end
		else
			state.undo = createAnimationFromCurrentData()
			table.insert(undoMemory, state)
		end
	else
		state.undo = createAnimationFromCurrentData()
		table.insert(undoMemory, state)
	end
end

function lockUndoStep(p)
	if #undoMemory > 0 and undoMemory[#undoMemory].action == p then
		undoMemory[#undoMemory].locked = true
	end
end

doNotUpdateCursor = false

function isJustTranslation(object, object2)
	local components, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25 = object:components()
	local components2, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36 = object2:components()
	local _ = components2 - components
	local _ = v26 - v15
	local _ = v27 - v16
	local v37 = {
		v28 - v17,
		v29 - v18,
		v30 - v19,
		v31 - v20,
		v32 - v21,
		v33 - v22,
		v34 - v23,
		v35 - v24,
		v36 - v25
	}
	local v38 = true

	for _, v39 in pairs(v37) do
		if math.abs(v39) > 0.001 then
			v38 = false
		end
	end

	return v38
end

function getMotorC1(data, p)
	local v15 = keyframeTimeClamp(p)

	if not (data.Motor6D and data.Item) then
		return
	end

	local item = data.Item

	if not partInclude[item.Name] then
		return data.OriginC1
	end

	local closestPose = getClosestPose(v15, item)
	local closestNextPose = getClosestNextPose(v15, item)

	if not closestPose then
		return data.OriginC1
	end

	if not v3.Interpolation or not closestNextPose or closestPose.CFrame == closestNextPose.CFrame or v15 == closestPose.Time then
		return closestPose.CFrame * data.OriginC1
	end

	local v16 = closestNextPose.Time - closestPose.Time
	local v17 = (v15 - closestPose.Time) / v16
	local easing = EasingStyles.GetEasing(closestPose.EasingStyle.Name, closestPose.EasingDirection.Name, 1 - v17)
	local cFrame = closestPose.CFrame
	local p2 = cFrame.p
	local v18 = cFrame - p2
	local cFrame2 = closestNextPose.CFrame
	local p3 = cFrame2.p
	local v19 = cFrame2 - p3
	p2:Lerp(p3, easing)
	v18:lerp(v19, easing)
	local v20 = cFrame:inverse():lerp(cFrame2:inverse(), easing):inverse() * data.OriginC1
	return (repairedCFrame(v20))
end

function selectPartUI(p)
	if not timelineUI then
		return
	end

	selectedLine.Parent = timelineUI.RootFrame.ScrollingFrame
	local selectedLine3 = selectedLine
	local v15 = 23 + 20 * (partToLineNumber[p] - 1)
	selectedLine3.Position = UDim2.new(0, 5, 0, v15)
	selectedLine2.Parent = timelineUI.RootFrame.KeyframeContainer
	local selectedLine22 = selectedLine2
	local v16 = 23 + 20 * (partToLineNumber[p] - 1)
	selectedLine22.Position = UDim2.new(0, 5, 0, v16)
end

function unselectPartUI()
	selectedLine.Parent = nil
	selectedLine2.Parent = nil
end

function repairWholeRig()
	for _, v15 in pairs(partList) do
		local _ = v15.Motor6D
	end
end

local function MakePartSelectGui(_)
	Vector2.new(100, 30)
	Vector2.new(100, 25)

	if rotateMoveUI == nil then
		rotateMoveUI = Make("Frame", {
			Name = "rotateMoveUI",
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, 15),
			Parent = timelineUI.RootFrame,
			Make("Frame", {
				Name = "SpaceFrame",
				Style = "Custom",
				Position = UDim2.new(0, 200, 0, 2),
				Size = UDim2.new(0, 80, 0, 15),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.new(0.345098, 0.345098, 0.345098),
				BorderSizePixel = 1,
				ZIndex = 2,
				Make("TextButton", {
					Name = "SpaceButton",
					Font = "Arial",
					FontSize = "Size14",
					TextColor3 = GuiSettings.TextColor,
					Position = UDim2.new(0.05, 0, 0, 1),
					Size = UDim2.new(0.9, 0, 0, 14),
					BackgroundTransparency = 1,
					Text = "Local Space",
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 2
				})
			}),
			Make("Frame", {
				Name = "RotateFrame",
				Style = "Custom",
				Position = UDim2.new(0, 290, 0, 2),
				Size = UDim2.new(0, 55, 0, 15),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.new(0.345098, 0.345098, 0.345098),
				BorderSizePixel = 1,
				ZIndex = 2,
				Make("TextButton", {
					Name = "RotateButton",
					Font = "Arial",
					FontSize = "Size14",
					TextColor3 = GuiSettings.TextColor,
					Position = UDim2.new(0.05, 0, 0, 1),
					Size = UDim2.new(0.9, 0, 0, 14),
					BackgroundTransparency = 1,
					Text = "Rotate",
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 2
				})
			}),
			Make("Frame", {
				Name = "StepFrame",
				Style = "Custom",
				Position = UDim2.new(0, 355, 0, 2),
				Size = UDim2.new(0, 55, 0, 15),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.new(0.345098, 0.345098, 0.345098),
				BorderSizePixel = 1,
				ZIndex = 2,
				Make("TextButton", {
					Name = "StepButton",
					Font = "Arial",
					FontSize = "Size14",
					TextColor3 = GuiSettings.TextColor,
					Position = UDim2.new(0.05, 0, 0, 1),
					Size = UDim2.new(0.9, 0, 0, 14),
					BackgroundTransparency = 1,
					Text = "Step: 0",
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 2
				}),
				Make("TextButton", {
					Name = "StepOptions",
					Style = "Custom",
					Position = UDim2.new(1, 2, 0, 0),
					Size = UDim2.new(0, 15, 0, 15),
					BackgroundTransparency = 0,
					BackgroundColor3 = Color3.new(0, 0, 0),
					BorderColor3 = Color3.new(0.345098, 0.345098, 0.345098),
					BorderSizePixel = 1,
					TextColor3 = Color3.new(1, 1, 1),
					Text = "...",
					ZIndex = 2
				})
			})
		})
	end

	local v15 = Make("SelectionBox", {
		Name = "HoverBox",
		Color = parent.AnimationEditor.Customize.MouseoverColor.Value,
		Transparency = 0.5,
		LineThickness = 0.02,
		Parent = playerGui,
		Archivable = false
	})
	local v16 = {}
	local v17 = Make("SelectionBox", {
		Name = "SelectBox",
		Color = parent.AnimationEditor.Customize.SelectedColor.Value,
		Transparency = 0,
		LineThickness = 0.02,
		Parent = playerGui,
		Archivable = false
	})
	local v18 = Make("Handles", {
		Color = BrickColor.new("Black"),
		Style = "Movement",
		Parent = playerGui,
		Archivable = false
	})
	mProxyPart = Make("Part", {
		Size = createVector(0.8, 0.8, 0.8),
		Name = "ProxyPart",
		Shape = "Ball",
		Archivable = false,
		Parent = game.Workspace,
		BrickColor = BrickColor.new(23),
		Anchored = false,
		CanCollide = false,
		Transparency = 0.5,
		TopSurface = "Smooth",
		BottomSurface = "Smooth"
	})
	local v19 = Make("ArcHandles", {
		Color = BrickColor.new(23),
		Parent = playerGui,
		Archivable = false
	})
	local v20 = nil
	local v21 = nil
	local v22 = nil
	local cFrame = nil
	local v23 = nil
	local v24 = false
	local cFrame2 = nil

	function updateProxyPart()
		if partSelection then
			local partSelection2 = partSelection
			local X = partSelection2.Item.Size.X
			local Y = partSelection2.Item.Size.Y
			local Z = partSelection2.Item.Size.Z
			local v25 = math.min(math.min(X, Y), (math.min(X, Z)))
			mProxyPart.Size = Vector3.new(v25, v25, v25)

			if v23 ~= nil then
				v23:Destroy()
			end

			local v26 = partSelection2.Motor6D.Part0.CFrame * partSelection2.Motor6D.C0
			local objectSpace = (partSelection2.Motor6D.Part0.CFrame * partSelection2.Motor6D.C0 * partSelection2.OriginC1:inverse()):toObjectSpace(v26)
			local p = partSelection2.Item.CFrame:toWorldSpace(objectSpace).p

			if v24 then
				mProxyPart.CFrame = CFrame.new(p)
			else
				mProxyPart.CFrame = partSelection2.Item.CFrame + (p - partSelection2.Item.CFrame.p)
			end

			local item = partSelection2.Item
			local mProxyPart2 = mProxyPart
			local mProxyPart3 = mProxyPart
			local motor6D = Instance.new("Motor6D")
			motor6D.Part0 = item
			motor6D.Part1 = mProxyPart2
			motor6D.C0 = CFrame.new()
			motor6D.C1 = mProxyPart2.CFrame:inverse() * item.CFrame

			if mProxyPart3 ~= nil and mProxyPart3 then
				item = mProxyPart3
			end

			motor6D.Parent = item
			v23 = motor6D
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function displayHandles()
		if partSelection ~= nil then
			local _ = partSelection
			mProxyPart.Size = createVector(0.2, 0.2, 0.2)
			updateProxyPart()

			if rotateMode then
				v19.Adornee = mProxyPart
				v18.Adornee = nil
			else
				v19.Adornee = nil
				v18.Adornee = mProxyPart
			end
		end
	end

	local function updateStepDisplay()
		if rotateMode then
			if rotateStep == 0 then
				rotateMoveUI.StepFrame.StepButton.Text = "Step: 0"
			elseif rotateStep == 10 then
				rotateMoveUI.StepFrame.StepButton.Text = "Step: 10"
			elseif rotateStep == 45 then
				rotateMoveUI.StepFrame.StepButton.Text = "Step: 45"
			else
				rotateMoveUI.StepFrame.StepButton.Text = "Step: " .. tostring(rotateStep)
			end
		elseif moveStep == 0 then
			rotateMoveUI.StepFrame.StepButton.Text = "Step: 0"
		elseif moveStep == 0.2 then
			rotateMoveUI.StepFrame.StepButton.Text = "Step: 0.2"
		elseif moveStep == 1 then
			rotateMoveUI.StepFrame.StepButton.Text = "Step: 1"
		else
			rotateMoveUI.StepFrame.StepButton.Text = "Step: " .. tostring(moveStep)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function toggleHandles()
		if partSelection ~= nil then
			rotateMode = not rotateMode

			if rotateMode then
				rotateMoveUI.RotateFrame.RotateButton.Text = "Rotate"
			else
				rotateMoveUI.RotateFrame.RotateButton.Text = "Move"
			end

			updateStepDisplay()
			displayHandles() -- equivalent call inferred; original call site unknown
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function toggleTransformSpace()
		v24 = not v24

		if v24 then
			rotateMoveUI.SpaceFrame.SpaceButton.Text = "World Space"
		else
			rotateMoveUI.SpaceFrame.SpaceButton.Text = "Local Space"
		end

		updateProxyPart()
	end

	local function toggleStep()
		if partSelection ~= nil then
			if rotateMode then
				if rotateStep == 0 then
					rotateStep = 10
				elseif rotateStep == 10 then
					rotateStep = 45
				else
					rotateStep = 0
				end
			elseif moveStep == 0 then
				moveStep = 0.2
			elseif moveStep == 0.2 then
				moveStep = 1
			else
				moveStep = 0
			end

			updateStepDisplay()
			displayHandles() -- equivalent call inferred; original call site unknown
		end
	end

	local function setSelection(p, p2, p3)
		partSelection = p

		if p then
			v17.Adornee = p.Item
			selectPartUI(p.Item)
		else
			v17.Adornee = nil
			unselectPartUI()
		end

		v18.Adornee = nil
		v19.Adornee = nil
		mProxyPart.Parent = nil
		v21 = p3
		v22 = p2

		if p2 then
			if p3 then
				displayHandles() -- equivalent call inferred; original call site unknown
			else
				v17.Adornee = nil
				v19.Adornee = mProxyPart
				mProxyPart.Parent = game.Workspace

				if p then
					mProxyPart.CFrame = p.Item.CFrame * p.OriginC1
				end
			end

			if rotateMoveUI then
				rotateMoveUI.Visible = true
			end
		elseif rotateMoveUI then
			rotateMoveUI.Visible = false
		end
	end

	local function getSelection()
		return partSelection
	end

	function getHandleSelection()
		return partSelection
	end

	function resetHandleSelection()
		partSelection = nil
		v17.Adornee = nil
		unselectPartUI()
		v18.Adornee = nil
		v19.Adornee = nil
		mProxyPart.Parent = nil
		v21 = false
		v22 = false

		if rotateMoveUI then
			rotateMoveUI.Visible = false
		end
	end

	function setHandleSelection(p)
		partSelection = p

		if p then
			v17.Adornee = p.Item
			selectPartUI(p.Item)
		else
			v17.Adornee = nil
			unselectPartUI()
		end

		v18.Adornee = nil
		v19.Adornee = nil
		mProxyPart.Parent = nil
		v21 = true
		v22 = true
		displayHandles() -- equivalent call inferred; original call site unknown

		if rotateMoveUI then
			rotateMoveUI.Visible = true
		end
	end

	local _ = {
		CanOffset = true
	}
	v19.MouseDrag:Connect(function(p, p2, _)
		if not modal then
			local v25 = rotateStep / 180 * 3.141592653589793

			if v25 > 0 then
				p2 = math.floor(p2 / v25 + 0.5) * v25
			end

			local partSelection2 = partSelection
			local item = partSelection2.Item
			local currentKeyframeData = getCurrentKeyframeData(item, true, true)
			local cframe = CFrame.fromAxisAngle(Vector3.FromAxis(p), -p2)
			registerUndo({
				action = "editRotate",
				keyframe = currentKeyframeData,
				oldKeyframeCFrame = currentKeyframeData.CFrame,
				item = partSelection2,
				oldC1 = partSelection2.Motor6D.C1
			})

			if v24 then
				local cframe2 = CFrame.fromAxisAngle(Vector3.FromAxis(p), p2)
				local v26 = partSelection2.Motor6D.Part0.CFrame * partSelection2.Motor6D.C0
				local v27 = (cFrame2 * partSelection2.OriginC1).p - v26.p
				local v28 = v26 + v27
				local objectSpace = v28:toObjectSpace(cFrame2)
				local worldSpace = (cframe2 * (v28 - v28.p) + v28.p):toWorldSpace(objectSpace)
				local C1 = repairedCFrame(worldSpace:inverse() * (v28 - v27))
				currentKeyframeData.CFrame = C1 * partSelection2.OriginC1:inverse()
				partSelection2.Motor6D.C1 = C1
			else
				local _ = (partSelection2.Motor6D.Part0.CFrame * partSelection2.Motor6D.C0 * cFrame * cframe:inverse() * partSelection2.OriginC1:inverse()):inverse() * partSelection2.Motor6D.Part0.CFrame * partSelection2.Motor6D.C0 * partSelection2.OriginC1:inverse()
				local _ = partSelection2.Motor6D.Part0.CFrame
				local _ = partSelection2.Motor6D.C0
				local v26 = cFrame
				local originC1 = partSelection2.OriginC1
				local _ = item.CFrame
				local _ = partSelection2.Motor6D.Part0.CFrame - partSelection2.Motor6D.Part0.CFrame.p
				local _ = partSelection2.Motor6D.C0 - partSelection2.Motor6D.C0.p
				local _ = originC1 - originC1.p
				local cframe2 = CFrame.new(originC1.p)
				currentKeyframeData.CFrame = cframe2 * cframe * cframe2:inverse() * v26
				partSelection2.Motor6D.C1 = currentKeyframeData.CFrame * partSelection2.OriginC1
			end

			nudgeView()
			updateProxyPart()
		end
	end)
	local canvasPosition = nil
	v19.MouseButton1Down:Connect(function()
		if not modal then
			local keyframeContainer = timelineUI.RootFrame.KeyframeContainer

			if mouse.Y < keyframeContainer.AbsolutePosition.Y + keyframeContainer.CanvasSize.Y.Offset - keyframeContainer.CanvasPosition.Y then
				canvasPosition = keyframeContainer.CanvasPosition
				keyframeContainer.CanvasPosition = Vector2.new(
					keyframeContainer.CanvasPosition.X,
					keyframeContainer.AbsolutePosition.Y + keyframeContainer.CanvasSize.Y.Offset - keyframeContainer.CanvasPosition.Y - mouse.Y - 25
				)
			end

			_G.BlockCameraMovement = true
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			local item = partSelection.Item
			cFrame = getCurrentKeyframeData(item, true, true).CFrame
			cFrame2 = item.CFrame
		end
	end)
	v19.MouseButton1Up:Connect(function()
		lockUndoStep("editRotate")

		if canvasPosition then
			timelineUI.RootFrame.KeyframeContainer.CanvasPosition = canvasPosition
			canvasPosition = nil
		end

		_G.BlockCameraMovement = false
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
	v18.MouseDrag:Connect(function(p, p2)
		if not modal then
			if moveStep > 0 then
				p2 = math.floor(p2 / moveStep) * moveStep
			end

			local partSelection2 = partSelection
			local item = partSelection2.Item
			local currentKeyframeData = getCurrentKeyframeData(item, true, true)
			registerUndo({
				action = "editTransform",
				keyframe = currentKeyframeData,
				oldKeyframeCFrame = currentKeyframeData.CFrame,
				item = partSelection2,
				oldC1 = partSelection2.Motor6D.C1
			})

			if v24 then
				local v25 = Vector3.FromNormalId(p) * p2
				local v26 = cFrame2 + v25
				local v27 = partSelection2.Motor6D.Part0.CFrame * partSelection2.Motor6D.C0
				local C1 = repairedCFrame(v26:inverse() * v27)
				currentKeyframeData.CFrame = C1 * partSelection2.OriginC1:inverse()
				partSelection2.Motor6D.C1 = C1
			else
				local vector3 = Vector3.FromNormalId(p)
				currentKeyframeData.CFrame = CFrame.new(-vector3 * p2) * cFrame
				partSelection2.Motor6D.C1 = currentKeyframeData.CFrame * partSelection2.OriginC1
			end

			nudgeView()
			updateProxyPart()
		end
	end)
	v18.MouseButton1Down:Connect(function()
		if not modal then
			local keyframeContainer = timelineUI.RootFrame.KeyframeContainer

			if mouse.Y < keyframeContainer.AbsolutePosition.Y + keyframeContainer.CanvasSize.Y.Offset - keyframeContainer.CanvasPosition.Y then
				canvasPosition = keyframeContainer.CanvasPosition
				keyframeContainer.CanvasPosition = Vector2.new(
					keyframeContainer.CanvasPosition.X,
					keyframeContainer.AbsolutePosition.Y + keyframeContainer.CanvasSize.Y.Offset - keyframeContainer.CanvasPosition.Y - mouse.Y - 25
				)
			end

			_G.BlockCameraMovement = true
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			local item = partSelection.Item
			cFrame = getCurrentKeyframeData(item, true, true).CFrame
			cFrame2 = item.CFrame
		end
	end)
	v18.MouseButton1Up:Connect(function()
		lockUndoStep("editTransform")

		if canvasPosition then
			timelineUI.RootFrame.KeyframeContainer.CanvasPosition = canvasPosition
			canvasPosition = nil
		end

		_G.BlockCameraMovement = false
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function tableHasValue(items, p)
		for _, item in pairs(items) do
			if item == p then
				return true
			end
		end

		return false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getAnimatedChunk(item)
		local result = { item }
		local recurse

		recurse = function(object)
			if not object then
				return
			end

			for _, v25 in pairs(object:GetConnectedParts()) do
				if partToItemMap[v25] then
					continue
				end

				-- equivalent call inferred; original call site unknown
				if tableHasValue(result, v25) then
					continue
				end

				table.insert(result, v25)
				recurse(v25)
			end
		end

		recurse(item)
		return result
	end

	local function fn()
		local item = mouseRaycast({})

		if item then
			local animatedPart = findAnimatedPart(item)
			item = animatedPart and animatedPart.Item
		end

		if item ~= v20 and _G.AnimationEdit == true then
			v20 = item

			for _, v25 in pairs(v16) do
				v25:Destroy()
			end

			local model = Instance.new("Model")
			local animatedChunk = getAnimatedChunk(item) -- equivalent call inferred; original call site unknown

			for _, v25 in pairs(animatedChunk) do
				local clone = v25:Clone()

				if not clone then
					continue
				end

				clone.Parent = model

				if partToItemMap[v25] then
					model.PrimaryPart = clone
				end
			end

			local adornee = Make("Part", {
				Name = "SelectionPart",
				Transparency = 1,
				Anchored = true,
				CanCollide = false,
				Archivable = false,
				CFrame = model:GetModelCFrame(),
				Parent = workspace
			})
			adornee.Size = model:GetExtentsSize()
			table.insert(v16, adornee)
			local v26 = Make("SelectionBox", {
				Name = "HoverBox2",
				LineThickness = 0.02,
				Archivable = false,
				Adornee = adornee,
				Parent = playerGui,
				Color = parent.AnimationEditor.Customize.MouseoverColor.Value
			})
			table.insert(v16, v26)
		end
	end

	MouseTargeterHalt = Repeat(fn)

	function destroySelectionBoxes()
		if v17 then
			v17.Adornee = nil
			v17.Parent = nil
		end

		if v15 then
			v15.Adornee = nil
			v15.Parent = nil
		end

		if v18 then
			v18.Adornee = nil
			v18.Parent = nil
		end

		if v19 then
			v19.Adornee = nil
			v19.Parent = nil
		end

		if mProxyPart then
			mProxyPart:Destroy()
		end

		for _, v25 in pairs(v16) do
			v25:Destroy()
		end

		for _, v25 in pairs(v) do
			v25:Destroy()
		end
	end

	function findAnimatedPart(object, options)
		local v25 = options or {}

		-- equivalent call inferred; original call site unknown
		if tableHasValue(v25, object) then
			return
		end

		table.insert(v25, object)

		if partToItemMap[object] then
			return partToItemMap[object]
		end

		for _, v26 in pairs(object:GetConnectedParts()) do
			local animatedPart = findAnimatedPart(v26, v25)

			if animatedPart then
				return animatedPart
			end
		end

		return nil
	end

	registerOn(v4, nil, function()
		if not v14 then
			return
		end

		if modal then
			return false
		end

		local v25, _, _ = mouseRaycast({ mProxyPart, v14.Item })

		if v25 == nil then
			return false
		end

		local animatedPart = findAnimatedPart(v25)
		local v26

		if animatedPart then
			v26 = partInclude[animatedPart.Item.Name]
		else
			v26 = false
		end

		if v26 and animatedPart ~= v14 then
			if animatedPart == nil then
				partSelection = nil
				v17.Adornee = nil
				unselectPartUI()
				v18.Adornee = nil
				v19.Adornee = nil
				mProxyPart.Parent = nil
				v21 = false
				v22 = false

				if rotateMoveUI then
					rotateMoveUI.Visible = false
				end
			else
				partSelection = animatedPart

				if animatedPart then
					v17.Adornee = animatedPart.Item
					selectPartUI(animatedPart.Item)
				else
					v17.Adornee = nil
					unselectPartUI()
				end

				v18.Adornee = nil
				v19.Adornee = nil
				mProxyPart.Parent = nil
				v21 = true
				v22 = true
				displayHandles() -- equivalent call inferred; original call site unknown

				if rotateMoveUI then
					rotateMoveUI.Visible = true
				end
			end
		else
			partSelection = nil
			v17.Adornee = nil
			unselectPartUI()
			v18.Adornee = nil
			v19.Adornee = nil
			mProxyPart.Parent = nil
			v21 = false
			v22 = false

			if rotateMoveUI then
				rotateMoveUI.Visible = false
			end
		end

		return false
	end)
	rotateMoveUI.RotateFrame.RotateButton.MouseButton1Click:Connect(function()
		toggleHandles() -- equivalent call inferred; original call site unknown
	end)
	rotateMoveUI.StepFrame.StepButton.MouseButton1Click:Connect(function()
		toggleStep()
	end)
	rotateMoveUI.StepFrame.StepOptions.MouseButton1Click:Connect(function()
		if modal then
			return
		end

		modal = true
		local v25

		if rotateMode then
			v25 = tonumber(MenuHandler.PromptInput("Rotation step:", "<degrees>"))
		else
			v25 = tonumber(MenuHandler.PromptInput("Move step:", "<studs>"))
		end

		if v25 ~= nil and v25 > 0 then
			if rotateMode then
				rotateStep = v25
			else
				moveStep = v25
			end

			updateStepDisplay()
		end

		modal = false
	end)
	rotateMoveUI.SpaceFrame.SpaceButton.MouseButton1Click:Connect(function()
		toggleTransformSpace() -- equivalent call inferred; original call site unknown
	end)
end

function updateCursorPosition()
	if doNotUpdateCursor then
		return
	end

	local v15 = animationLength2 * v11 - 7.5

	if v3.TweenCursor then
		if timelineUI.Parent ~= nil then
			local cursor = timelineUI.RootFrame.KeyframeContainer.Cursor
			local Y = timelineUI.RootFrame.KeyframeContainer.CanvasPosition.Y
			cursor:TweenPosition(UDim2.new(0, v15, 0, Y), "Out", "Quad", 0.1, true)
		end
	else
		local cursor = timelineUI.RootFrame.KeyframeContainer.Cursor
		local Y = timelineUI.RootFrame.KeyframeContainer.CanvasPosition.Y
		cursor.Position = UDim2.new(0, v15, 0, Y)
	end

	for k, v16 in pairs(partList) do
		local _ = partInclude[k.Name]

		if not v16.Motor6D then
			continue
		end

		v16.Motor6D.C1 = getMotorC1(v16, animationLength2)
		updateProxyPart()
		nudgeView()
	end
end

GuiSettings = {}
GuiSettings.TextLarge = "Size24"
GuiSettings.TextMed = "Size18"
GuiSettings.TextSmall = "Size14"
GuiSettings.TextColor = Color3.new(0.8666666666666667, 0.8666666666666667, 0.8666666666666667)

function loadPose(p, instance)
	local v15 = partListByName[instance.Name]

	if v15 ~= nil and instance.Weight > 0 then
		local v16 = initializePose(p, v15.Item, instance, true)

		if v16 ~= nil then
			if v15.OriginC1 == nil then
				v16.CFrame = instance.CFrame
			else
				v16.CFrame = v15.OriginC1 * instance.CFrame:inverse() * v15.OriginC1:inverse()
			end

			v16.EasingStyle = instance.EasingStyle
			v16.EasingDirection = instance.EasingDirection
			v16.updateColor()

			if instance.Parent:IsA("Pose") and instance.Weight > 0 then
				importPartInclude[instance.Name] = true
			end
		end
	end

	for _, child in pairs(instance:GetChildren()) do
		loadPose(p, child)
	end
end

importPartInclude = {}

function loadImportAnim(keyframeSequenceById)
	local v15 = type(keyframeSequenceById) == "number"
	local v16 = type(keyframeSequenceById) == "userdata"

	if v15 and keyframeSequenceById > 0 or v16 then
		doNotUpdateCursor = true
		resetKeyframes()
		importPartInclude = {}

		if v15 then
			local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
			keyframeSequenceById = KeyframeSequenceProvider:GetKeyframeSequenceById(keyframeSequenceById, false)
		end

		loadKeyframeSequence(keyframeSequenceById)
	end
end

function loadKeyframeSequence(instance)
	local children = {}

	for _, child in pairs(instance:GetChildren()) do
		if child.ClassName == "Keyframe" then
			table.insert(children, child)
		end
	end

	animationLength = 0

	for _, v15 in pairs(children) do
		if v15.Time > animationLength then
			animationLength = v15.Time
		end
	end

	updateAnimationFramerate()
	updateTimeLabels()

	for _, v15 in pairs(children) do
		local keyframe = createKeyframe(v15.Time, false)
		keyframe.Name = v15.Name

		for _, child in pairs(v15:GetChildren()) do
			loadPose(keyframe, child)
		end
	end

	loopAnimation = instance.Loop
	animationPriority = instance.Priority.Name

	for k, v15 in spairs(keyframeList, function(p, p2, p3)
		return p[p2].Time < p[p3].Time
	end) do
		v15.setPos(k)
	end

	if animationLength2 > animationLength then
		animationLength2 = 0
	end

	for k, _ in pairs(partInclude) do
		if importPartInclude[k] == nil then
			partInclude[k] = false
		else
			partInclude[k] = true
		end
	end

	doNotUpdateCursor = false
	updatePartInclude()
	updateCursorPosition()
	nudgeView()
	adjustKeyframes()
end

animationLabelsList = {}

function updateTimeLabels()
	for _, v15 in pairs(animationLabelsList) do
		v15.Parent = nil
	end

	animationLabelsList = {}
	offset = timelineUI.RootFrame.KeyframeContainer.CanvasSize.X.Offset
	v10 = 0
	v8 = 0
	local count2 = 0

	while v8 < 50 do
		count2 += 1
		v9 = math.floor(animationLength / (animationFramerate * count2))
		v8 = offset / v9
		v10 = animationFramerate * count2
	end

	v11 = offset / animationLength

	if (v9 * v10 * v11 + 125) / timelineUI.RootFrame.AbsoluteSize.X > 0.97 then
		v9 -= 1
	end

	v12 = animationLength / 20
	local v15 = math.floor(animationLength / v12)
	local v16 = animationLength / v12

	for i = 0, v15 do
		local v17 = math.floor((i * v12 + 1e-9) * 100) / 100
		local make = Make
		local v18 = {
			Parent = timelineUI.RootFrame.KeyframeContainer.TimeListFrame,
			Name = "Tick" .. i,
			Font = "ArialBold",
			FontSize = "Size10",
			TextColor3 = GuiSettings.TextColor,
			ZIndex = 4,
			Active = false
		}
		local v19 = i / v16
		v18.Position = UDim2.new(v19, -2, 0, 0)
		v18.Size = UDim2.new(0, 12, 0, 15)
		v18.BackgroundTransparency = 1
		v18.Text = tostring(v17)
		v18.TextXAlignment = Enum.TextXAlignment.Left
		do local _values = table.pack(Make("TextLabel", {
	Name = "TickIndicator",
	Position = UDim2.new(0, 2, 0, 0),
	Size = UDim2.new(0, 2, 1000, 0),
	Text = "",
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.8,
	BorderSizePixel = 0
})); for _k = 1, _values.n do v18[_k] = _values[_k] end end
		local v20 = make("TextLabel", v18)
		animationLabelsList[i] = v20
	end

	local tickEnd = Make("TextLabel", {
		Parent = timelineUI.RootFrame.KeyframeContainer.TimeListFrame,
		Name = "TickEnd",
		Font = "ArialBold",
		FontSize = "Size10",
		TextColor3 = GuiSettings.TextColor,
		Position = UDim2.new(1, -3, 0, 0),
		Size = UDim2.new(0, 12, 0, 15),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Active = false,
		Text = string.format("%.2f", animationLength),
		TextXAlignment = Enum.TextXAlignment.Left,
		Make("TextLabel", {
			Name = "TickIndicator",
			Position = UDim2.new(0, 2, 0, 0),
			Size = UDim2.new(0, 2, 1000, 0),
			Text = "",
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.8,
			BorderSizePixel = 0
		})
	})
	animationLabelsList.TickEnd = tickEnd
end

function changeKeyframePosition(state, p)
	local time = keyframeTimeClamp(p)

	if keyframeList[time] == nil then
		keyframeList[state.Time] = nil
		state.Time = time
		state.setPos(time)
		keyframeList[time] = state

		for _, pos in pairs(state.Poses) do
			pos.Time = time
		end
	end
end

function addTimeAtCursor(p)
	if animationLength + p > 30 or p <= 0 then
		return
	end

	animationLength += p
	offset = timelineUI.RootFrame.KeyframeContainer.CanvasSize.X.Offset
	v11 = offset / animationLength
	updateAnimationFramerate()
	local v15 = {}

	for _, v16 in spairs(keyframeList, function(p2, p3, p4)
		return p2[p3].Time < p2[p4].Time
	end) do
		v15[v16.Time] = v16
	end

	keyframeList = {}

	for _, v16 in spairs(v15, function(p2, p3, p4)
		return p2[p3].Time < p2[p4].Time
	end) do
		local time = v16.Time
		local v17

		if animationLength2 < time then
			v17 = v16.Time + p
		else
			v17 = v16.Time
		end

		v16.setPos(v17)
	end

	setAnimationLength(animationLength)
	updateTimeLabels()
	updateCursorPosition()
end

function addTimeAtCursorNew(p)
	if tonumber(p) == nil or tonumber(p) < 0 or animationLength + p > 30 then
		return
	end

	animationLength += p
	offset = timelineUI.RootFrame.KeyframeContainer.CanvasSize.X.Offset
	v11 = offset / animationLength
	updateAnimationFramerate()
	local v15 = {}

	for k, v16 in pairs(keyframeList) do
		v15[k] = v16
	end

	keyframeList = {}

	for _, v16 in pairs(v15) do
		local time = v16.Time

		if not (animationLength2 < time) then
			continue
		end

		v16.Time += p

		for _, pos in pairs(v16.Poses) do
			pos.Time = v16.Time
		end
	end

	for _, v16 in pairs(v15) do
		keyframeList[v16.Time] = v16
	end

	setAnimationLength(animationLength)
	updateTimeLabels()
	updateCursorPosition()
end

function removeTimeAtCursorNew(p)
	if tonumber(p) == nil or tonumber(p) < 0 or animationLength - p < 0.1 then
		return
	end

	animationLength -= p
	offset = timelineUI.RootFrame.KeyframeContainer.CanvasSize.X.Offset
	v11 = offset / animationLength
	updateAnimationFramerate()
	local v15 = {}

	for k, v16 in pairs(keyframeList) do
		if not (animationLength2 < k and k < animationLength2 + p) then
			v15[k] = v16
		end
	end

	keyframeList = {}

	for _, v16 in pairs(v15) do
		local time = v16.Time

		if animationLength2 < time then
			v16.Time -= p
		end
	end

	for _, v16 in pairs(v15) do
		keyframeList[v16.Time] = v16
		v16.setPos(v16.Time)
	end

	setAnimationLength(animationLength)
	updateTimeLabels()
	updateCursorPosition()
end

function removeTimeAtCursor(p)
	if animationLength - p < 0.1 then
		return
	end

	if animationLength2 + p > animationLength then
		p = animationLength - animationLength2
	end

	if p <= 0 then
		return
	end

	local v15 = {}
	local v16 = {}
	local v17 = false

	for _, v18 in spairs(keyframeList, function(p2, p3, p4)
		return p2[p3].Time < p2[p4].Time
	end) do
		local time = v18.Time

		if animationLength2 < time and v18.Time < animationLength2 + p then
			v15[v18.Time] = v18
			v17 = true
		else
			v16[v18.Time] = v18
		end
	end

	if v17 and not showConfirmationDialog("This will remove keyframes.\nAre you sure?") then
		return
	end

	for _, v18 in pairs(v15) do
		deleteKeyframe(v18.Time)
	end

	animationLength -= p
	updateAnimationFramerate()
	updateTimeLabels()
	updateCursorPosition()
	keyframeList = {}

	for _, v18 in spairs(v16, function(p2, p3, p4)
		return p2[p3].Time < p2[p4].Time
	end) do
		local time = v18.Time
		local v19

		if animationLength2 < time then
			v19 = v18.Time - p
		else
			v19 = v18.Time
		end

		changeKeyframePosition(v18, v19)
	end

	setAnimationLength(animationLength)
end

function updateAnimationFramerate()
	animationFramerate = 1 / (50 / animationLength)
end

local function createTimelineUI(p)
	if timelineUI == nil then
		count = 0
		timelineUI = Make("ScreenGui", {
			Name = "TimelineUI",
			Make("TextButton", {
				Name = "Resize",
				Size = UDim2.new(0, 35, 0, 20),
				Position = UDim2.new(1, -35, 0, 220),
				Text = "Drag",
				TextColor3 = Color3.new(1, 1, 1),
				BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.new(1, 1, 1),
				BorderMode = Enum.BorderMode.Inset,
				BorderSizePixel = 1,
				ZIndex = 2,
				Make("UIDragDetector", {
					UIDragSpeedAxisMapping = Enum.UIDragSpeedAxisMapping.YY
				})
			}),
			Make("Frame", {
				Parent = timelineUI,
				Name = "RootFrame",
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 0, 240),
				BackgroundColor3 = Color3.new(0.3843137254901961, 0.3843137254901961, 0.3843137254901961),
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Make("ScrollingFrame", {
					Name = "ScrollingFrame",
					Position = UDim2.new(0, 0, 0, 20),
					Size = UDim2.new(0, 125, 1, -15),
					BackgroundColor3 = Color3.new(0.27450980392156865, 0.27450980392156865, 0.27450980392156865),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					ScrollBarThickness = 0,
					ScrollingDirection = Enum.ScrollingDirection.Y
				}),
				Make("ScrollingFrame", {
					Name = "KeyframeContainer",
					Position = UDim2.new(0, 130, 0, 20),
					Size = UDim2.new(1, -160, 1, -15),
					BackgroundColor3 = Color3.new(0.08235294117647059, 0.08235294117647059, 0.08235294117647059),
					BackgroundTransparency = 0.5,
					BorderSizePixel = 0,
					CanvasSize = UDim2.new(0, 2000, 1, 0),
					ScrollBarThickness = 0,
					Make("Frame", {
						Name = "TimeListFrame",
						Style = "Custom",
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(1, 0, 0, 15),
						BackgroundColor3 = Color3.new(0.3843137254901961, 0.3843137254901961, 0.3843137254901961),
						BackgroundTransparency = 0.1,
						BorderSizePixel = 0,
						ZIndex = 3
					}),
					Make("TextButton", {
						Name = "TimelineFrame",
						Style = "Custom",
						Text = "",
						Active = false,
						AutoButtonColor = false,
						Position = UDim2.new(0, 0, 0, 20),
						Size = UDim2.new(1, 0, 0, 15),
						BackgroundColor3 = Color3.new(0.7843137254901961, 0.7843137254901961, 0.7843137254901961),
						BackgroundTransparency = 0.1
					}),
					Make("Frame", {
						Name = "Cursor",
						Style = "Custom",
						Position = UDim2.new(0, 117.5, 0, 20),
						Size = UDim2.new(0, 19, 0, 19),
						BackgroundColor3 = Color3.new(0.2, 0.5, 1),
						BackgroundTransparency = 0,
						BorderColor3 = Color3.new(0.2, 0.5, 1),
						ZIndex = 4,
						Make("Frame", {
							Name = "CursorLine",
							Style = "Custom",
							Position = UDim2.new(0, 7.5, 0, 0),
							Size = UDim2.new(0, 2, 1000, 0),
							BackgroundColor3 = Color3.new(0.2, 0.5, 1),
							BackgroundTransparency = 0,
							BorderSizePixel = 0,
							ZIndex = 1
						}),
						Make("TextLabel", {
							Name = "CursorText",
							Font = "Arial",
							FontSize = "Size24",
							TextColor3 = GuiSettings.TextColor,
							Position = UDim2.new(0, 0, 0, 0),
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							Text = "↔",
							TextXAlignment = Enum.TextXAlignment.Center,
							TextYAlignment = Enum.TextYAlignment.Center,
							ZIndex = 4
						})
					})
				}),
				Make("ScrollingFrame", {
					Name = "VerticalProxy",
					Position = UDim2.new(1, -40, 0, 20),
					Size = UDim2.new(0, 15, 1, -15),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 10
				}),
				Make("ScrollingFrame", {
					Name = "HorizontalProxy",
					Position = UDim2.new(0, 130, 1, -10),
					Size = UDim2.new(1, -160, 0, 10),
					BackgroundTransparency = 1,
					BorderSizePixel = 0.5,
					ScrollBarThickness = 10
				}),
				Make("ImageButton", {
					Name = "SettingsButton",
					Position = UDim2.new(0, 45, 0, 15),
					Size = UDim2.new(0, 16.5, 0, 16.5),
					BackgroundColor3 = Color3.new(0.19607843137254902, 0.19607843137254902, 0.19607843137254902),
					BackgroundTransparency = 0,
					Image = "rbxassetid://299306324"
				}),
				Make("TextButton", {
					Name = "CloseButton",
					Font = "ArialBold",
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UDim2.new(1, -23, 0, 3),
					Size = UDim2.new(0, 20, 0, 20),
					BackgroundColor3 = Color3.new(0.6588235294117647, 0.13333333333333333, 0.13333333333333333),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					Text = "X",
					ZIndex = 5
				}),
				Make("TextButton", {
					Name = "TimelineZoomIn",
					Font = "ArialBold",
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UDim2.new(1, -26, 1, -68),
					Size = UDim2.new(0, 20, 0, 20),
					BackgroundColor3 = Color3.new(0.19607843137254902, 0.19607843137254902, 0.19607843137254902),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 1,
					Text = "+"
				}),
				Make("TextButton", {
					Name = "TimelineZoomOut",
					Font = "ArialBold",
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UDim2.new(1, -26, 1, -48),
					Size = UDim2.new(0, 20, 0, 20),
					BackgroundColor3 = Color3.new(0.19607843137254902, 0.19607843137254902, 0.19607843137254902),
					BackgroundTransparency = 0.5,
					BorderColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 1,
					Text = "-"
				}),
				Make("TextLabel", {
					Name = "ZoomLabel",
					Font = "Arial",
					FontSize = GuiSettings.TextMed,
					TextColor3 = Color3.new(1, 1, 1),
					Position = UDim2.new(1, -29, 1, -85),
					Size = UDim2.new(0, 26, 0, 18),
					BackgroundTransparency = 1,
					TextScaled = true,
					Text = "Zoom"
				})
			})
		})
		timelineUI.RootFrame.SettingsButton.Visible = false
		timelineUI.Parent = playerGui
		timelineUI.RootFrame.KeyframeContainer.CanvasSize = UDim2.new(
			0,
			timelineUI.RootFrame.KeyframeContainer.AbsoluteSize.X,
			1,
			0
		)
		MenuHandler.RegisterTooltip(timelineUI.RootFrame.TimelineZoomIn, "Zoom in to the timeline")
		MenuHandler.RegisterTooltip(timelineUI.RootFrame.TimelineZoomOut, "Zoom out of the timeline")
		task.wait(0.1)
		updateTimeLabels()
		timelineUI.RootFrame.TimelineZoomIn.MouseButton1Click:Connect(function()
			local _ = timelineUI.RootFrame.KeyframeContainer.AbsoluteSize.X
			local v15 = timelineUI.RootFrame.KeyframeContainer.CanvasSize.X.Offset + 100
			local keyframeContainer = timelineUI.RootFrame.KeyframeContainer
			local offset2 = timelineUI.RootFrame.KeyframeContainer.CanvasSize.Y.Offset
			keyframeContainer.CanvasSize = UDim2.new(0, v15, 0, offset2)
			local horizontalProxy = timelineUI.RootFrame.HorizontalProxy
			local offset3 = timelineUI.RootFrame.HorizontalProxy.CanvasSize.Y.Offset
			horizontalProxy.CanvasSize = UDim2.new(0, v15, 0, offset3)
			offset = v15
			v11 = offset / animationLength
			adjustKeyframes()
			updateCursorPosition()
		end)
		timelineUI.RootFrame.TimelineZoomOut.MouseButton1Click:Connect(function()
			local X = timelineUI.RootFrame.KeyframeContainer.AbsoluteSize.X
			local v15 = timelineUI.RootFrame.KeyframeContainer.CanvasSize.X.Offset - 100

			if v15 < X then
				v15 = X
			end

			local keyframeContainer = timelineUI.RootFrame.KeyframeContainer
			local offset2 = timelineUI.RootFrame.KeyframeContainer.CanvasSize.Y.Offset
			keyframeContainer.CanvasSize = UDim2.new(0, v15, 0, offset2)
			local horizontalProxy = timelineUI.RootFrame.HorizontalProxy
			local offset3 = timelineUI.RootFrame.HorizontalProxy.CanvasSize.Y.Offset
			horizontalProxy.CanvasSize = UDim2.new(0, v15, 0, offset3)
			offset = v15
			v11 = offset / animationLength
			adjustKeyframes()
			updateCursorPosition()
		end)
		timelineUI.Resize.Changed:Connect(function()
			local resize = timelineUI and timelineUI:FindFirstChild("Resize")

			if resize then
				local offset2 = resize.Position.Y.Offset
				resize.Position = UDim2.new(1, -resize.Size.X.Offset, 0, offset2)
				timelineUI.RootFrame.Size = UDim2.new(1, 0, 0, offset2 + 20)
			end
		end)
		local resize = timelineUI:FindFirstChild("Resize")

		if resize.Position.Y.Offset > timelineUI.AbsoluteSize.Y / 2 then
			resize.Position = UDim2.new(1, -resize.Size.X.Offset, 0, timelineUI.AbsoluteSize.Y / 2.5)
		end

		timelineUI.RootFrame.CloseButton.MouseButton1Down:Connect(function()
			if not modal then
				exitPlugin()
			end
		end)
		timelineUI.RootFrame.KeyframeContainer.TimelineFrame.MouseButton1Click:Connect(function()
			selectedKeyframe = nil
		end)
		registerOn(v4, timelineUI.RootFrame.KeyframeContainer.TimelineFrame, function(p2, p3)
			keyframePositionShift(p2, p3)
		end)
		registerOn(v5, timelineUI.RootFrame.KeyframeContainer.TimelineFrame, function(p2, p3)
			return keyframeContextMenu(p2, p3, true)
		end)
		registerOn(v4, timelineUI.RootFrame.KeyframeContainer.TimeListFrame, function(p2, _)
			task.wait()

			if modal or cursorClick then
				return false
			end

			local v15 = animationLength2

			if v15 == findTime(p2) then
				return false
			end

			animationLength2 = findTime(p2)
			updateCursorPosition()
			task.wait()
			return true
		end)
		registerOn(v4, timelineUI.RootFrame.KeyframeContainer.Cursor, function(_, _)
			if modal then
				return false
			end

			timelineUI.RootFrame.KeyframeContainer.ScrollingEnabled = false
			workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
			task.wait()

			local function fn()
				animationLength2 = findTime(mouse.X - timelineUI.RootFrame.KeyframeContainer.TimelineFrame.AbsolutePosition.X)

				if animationLength2 < 0 then
					animationLength2 = 0
				elseif animationLength2 > animationLength then
					animationLength2 = animationLength
				end

				updateCursorPosition()
				task.wait()
			end

			local v15 = Repeat(fn) -- equivalent call inferred; original call site unknown
			registerOn(v6, nil, function(_, _)
				unregisterEvent(v6, unregisterEvent)
				v15()
				timelineUI.RootFrame.KeyframeContainer.ScrollingEnabled = true
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				task.wait()
				return false
			end)
			return true
		end)
		timelineUI.RootFrame.KeyframeContainer.Cursor.InputBegan:Connect(function(input)
			if input.UserInputState == Enum.UserInputState.Begin then
				cursorClick = true
				delay(0.1, function()
					cursorClick = false
				end)
			end
		end)
	end

	local createLine

	createLine = function(p2, count2)
		if p2 == nil then
			return
		end

		local v15 = p2.Name == "HumanoidRootPart" and "" or p2.Name
		local make = Make
		local v16 = {
			Name = "Line" .. count,
			Font = "Arial",
			FontSize = GuiSettings.TextSmall,
			TextColor3 = GuiSettings.TextColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = 0,
			Size = 0,
			BackgroundTransparency = 1,
			Parent = 0,
			Text = 0
		}
		local v17 = count * 20 + 25
		v16.Position = UDim2.new(0, 10, 0, v17)
		v16.Size = UDim2.new(0, 120, 0, 15)
		v16.Parent = timelineUI.RootFrame.ScrollingFrame
		v16.Text = string.rep(" ", count2 - 1) .. v15
		local v18 = make("TextLabel", v16)
		registerOn(v4, v18, function(_, _)
			if modal or not (v18.AbsolutePosition.Y < timelineUI.RootFrame.AbsolutePosition.Y + timelineUI.RootFrame.AbsoluteSize.Y) then
				return
			end

			if getHandleSelection() == p2 or p2 == p then
				resetHandleSelection()
			else
				setHandleSelection(p2)
			end

			updateCursorPosition()
			return true
		end)
		count += 1

		for _, v19 in pairs(p2.Children) do
			createLine(v19, count2 + 1)
		end
	end

	createLine(p, 0)
	updatePartInclude()
	local make = Make
	local v16 = (count - 1) * 20 + 3.5
	selectedLine = make("Frame", {
		Name = "SelectedLineFrame",
		Style = "Custom",
		Position = UDim2.new(0, 5, 0, v16),
		Size = UDim2.new(1, -10, 0, 20),
		BackgroundColor3 = Color3.new(0.7843137254901961, 0.7843137254901961, 0.5882352941176471),
		BackgroundTransparency = 0.9
	})
	selectedLine.Parent = timelineUI.RootFrame
	local make2 = Make
	local v18 = (count - 1) * 20 + 3.5
	selectedLine2 = make2("Frame", {
		Name = "SelectedLineFrame2",
		Style = "Custom",
		Position = UDim2.new(0, 5, 0, v18),
		Size = UDim2.new(1, -10, 0, 20),
		BackgroundColor3 = Color3.new(0.7843137254901961, 0.7843137254901961, 0.5882352941176471),
		BackgroundTransparency = 0.9
	})
	selectedLine2.Parent = timelineUI.RootFrame.KeyframeContainer
	local scrollingFrame = timelineUI.RootFrame.ScrollingFrame
	local v19 = count * 20 + 35
	scrollingFrame.CanvasSize = UDim2.new(1, 0, 0, v19)
	local keyframeContainer = timelineUI.RootFrame.KeyframeContainer
	local X = timelineUI.RootFrame.KeyframeContainer.AbsoluteSize.X
	local v20 = count * 20 + 35
	keyframeContainer.CanvasSize = UDim2.new(0, X, 0, v20)
	local verticalProxy = timelineUI.RootFrame.VerticalProxy
	local v21 = count * 20 + 35
	verticalProxy.CanvasSize = UDim2.new(0, 0, 0, v21)
	local horizontalProxy = timelineUI.RootFrame.HorizontalProxy
	local X2 = timelineUI.RootFrame.KeyframeContainer.AbsoluteSize.X
	horizontalProxy.CanvasSize = UDim2.new(0, X2, 0, 0)

	local function moveTimelineBars()
		local timeListFrame = timelineUI.RootFrame.KeyframeContainer.TimeListFrame
		local Y = timelineUI.RootFrame.KeyframeContainer.CanvasPosition.Y
		timeListFrame.Position = UDim2.new(0, 0, 0, Y)
		local timelineFrame = timelineUI.RootFrame.KeyframeContainer.TimelineFrame
		local v22 = timelineUI.RootFrame.KeyframeContainer.CanvasPosition.Y + 20
		timelineFrame.Position = UDim2.new(0, 0, 0, v22)
		adjustKeyframes()
		local v23 = animationLength2 * v11 - 7.5

		if animationLength2 >= animationLength - 0.03 then
			v23 -= 5
		end

		local cursor = timelineUI.RootFrame.KeyframeContainer.Cursor
		local Y2 = timelineUI.RootFrame.KeyframeContainer.CanvasPosition.Y
		cursor.Position = UDim2.new(0, v23, 0, Y2)
	end

	timelineUI.RootFrame.KeyframeContainer.Changed:Connect(function()
		if timelineUI and timelineUI:FindFirstChild("RootFrame") then
			timelineUI.RootFrame.ScrollingFrame.CanvasPosition = Vector2.new(
				0,
				timelineUI.RootFrame.KeyframeContainer.CanvasPosition.Y
			)
			timelineUI.RootFrame.VerticalProxy.CanvasPosition = Vector2.new(
				0,
				timelineUI.RootFrame.KeyframeContainer.CanvasPosition.Y
			)
			moveTimelineBars()
		end
	end)
	timelineUI.RootFrame.ScrollingFrame.Changed:Connect(function()
		if timelineUI and timelineUI:FindFirstChild("RootFrame") then
			timelineUI.RootFrame.KeyframeContainer.CanvasPosition = Vector2.new(
				timelineUI.RootFrame.KeyframeContainer.CanvasPosition.X,
				timelineUI.RootFrame.ScrollingFrame.CanvasPosition.Y
			)
			timelineUI.RootFrame.VerticalProxy.CanvasPosition = Vector2.new(
				0,
				timelineUI.RootFrame.ScrollingFrame.CanvasPosition.Y
			)
		end
	end)
	timelineUI.RootFrame.VerticalProxy.Changed:Connect(function()
		if timelineUI and timelineUI:FindFirstChild("RootFrame") then
			timelineUI.RootFrame.KeyframeContainer.CanvasPosition = Vector2.new(
				timelineUI.RootFrame.KeyframeContainer.CanvasPosition.X,
				timelineUI.RootFrame.VerticalProxy.CanvasPosition.Y
			)
			timelineUI.RootFrame.ScrollingFrame.CanvasPosition = Vector2.new(
				0,
				timelineUI.RootFrame.KeyframeContainer.CanvasPosition.Y
			)
		end
	end)
	timelineUI.RootFrame.HorizontalProxy.Changed:Connect(function()
		if timelineUI and timelineUI:FindFirstChild("RootFrame") then
			timelineUI.RootFrame.KeyframeContainer.CanvasPosition = Vector2.new(
				timelineUI.RootFrame.HorizontalProxy.CanvasPosition.X,
				timelineUI.RootFrame.KeyframeContainer.CanvasPosition.Y
			)
		end
	end)
	timelineUI.Parent = playerGui
end

function setAnimationLength(p)
	registerUndo({
		action = "lengthChange"
	})
	local v15 = math.floor(p * 10000) / 10000
	local v16 = v15 / animationLength
	animationLength = v15
	v11 = offset / animationLength

	if animationLength > 30 then
		animationLength = 30
	end

	updateAnimationFramerate()
	local v17 = {}

	for _, v18 in spairs(keyframeList, function(p2, p3, p4)
		return p2[p3].Time < p2[p4].Time
	end) do
		v17[v18.Time] = v18
	end

	keyframeList = {}

	for k, v18 in spairs(v17, function(p2, p3, p4)
		return p2[p3].Time < p2[p4].Time
	end) do
		v18.Time = keyframeTimeClamp(v16 * k)

		for _, pos in pairs(v18.Poses) do
			pos.Time = v18.Time
		end

		keyframeList[v18.Time] = v18
		v18.adjust()
	end

	updateTimeLabels()
	animationLength2 *= v16
	task.wait(2)
	updateCursorPosition()
end

function keyframeContextMenu(p, _, _)
	if modal then
		return false
	end

	local time = findTime(p) -- equivalent call inferred; original call site unknown
	local selectedKeyframe2 = selectedKeyframe

	if selectedKeyframe2 == nil then
		createKeyframe(time)
	else
		local v15 = mouse
		local v16 = displayDropDownMenu(timelineUI.RootFrame.KeyframeContainer.TimelineFrame, {
			"Delete",
			"Rename",
			"Copy",
			"Reset"
		}, v15.X, v15.Y)

		if v16 == "Delete" then
			if time > 0 then
				deleteKeyframe(time, true)
			end
		elseif v16 == "Rename" then
			local name = showTextExtryDialog("Enter Keyframe Name:", selectedKeyframe2.Name)

			if name ~= nil then
				selectedKeyframe2.Name = name
			end
		elseif v16 == "Copy" then
			for k, pos in pairs(selectedKeyframe2.Poses) do
				copyPose(k, pos)
			end
		elseif v16 == "Reset" then
			resetKeyframeToDefaultPose(selectedKeyframe2)
		elseif v16 == "Debug" then
			print("------------------------------")

			for _, pos in pairs(selectedKeyframe2.Poses) do
				print(pos.Item.Name)
			end

			print("------------------------------")
		end
	end

	return false
end

function keyframePositionShift(p, _)
	if modal then
		return false
	end

	local time = findTime(p) -- equivalent call inferred; original call site unknown
	local selectedKeyframe2 = selectedKeyframe

	if not (selectedKeyframe2 ~= nil and time > 0) then
		return false
	end

	timelineUI.RootFrame.KeyframeContainer.ScrollingEnabled = false
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	task.wait()

	local function fn()
		local time2 = findTime(mouse.X - timelineUI.RootFrame.KeyframeContainer.TimelineFrame.AbsolutePosition.X) -- equivalent call inferred; original call site unknown

		if time2 < 0 then
			time2 = 0
		elseif animationLength < time2 then
			time2 = animationLength
		end

		getKeyframe(time2)

		while getKeyframe(time2) ~= nil and getKeyframe(time2) ~= selectedKeyframe2 do
			time2 += animationFramerate
		end

		if animationLength < time2 then
			while animationLength < time2 or getKeyframe(time2) ~= nil and getKeyframe(time2) ~= selectedKeyframe2 do
				time2 -= animationFramerate
			end
		end

		moveKeyframe(selectedKeyframe2, time2)
	end

	local v15 = Repeat(fn) -- equivalent call inferred; original call site unknown
	registerOn(v6, nil, function(_, _)
		unregisterEvent(v6, unregisterEvent)
		v15()
		timelineUI.RootFrame.KeyframeContainer.ScrollingEnabled = true
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		task.wait()
		return false
	end)
	return true
end

function saveCurrentAnimation(value, p)
	if playingAnim then
		return
	end

	local ss = _G.ss

	if not ss then
		ss = game.ReplicatedStorage
		print("No access to ServerStorage. Using ReplicatedStorage instead.")
	end

	if not ss:FindFirstChild("RBX_ANIMSAVES") then
		local folder = Instance.new("Folder")
		folder.Name = "RBX_ANIMSAVES"
		folder.Parent = ss
	end

	local _ = game
	local parts = value:split(".")

	if #parts == 1 then
		ss = ss.RBX_ANIMSAVES
	elseif parts[1] == "Workspace" then
		ss = workspace
	elseif parts[1] ~= "ServerStorage" then
		warn("Incorrect save path.name:", value)
		return
	end

	for i = 2, #parts - 1 do
		if ss:FindFirstChild(parts[i]) then
			ss = ss[parts[i]]
		else
			local folder = Instance.new("Folder")
			folder.Name = parts[i]
			folder.Parent = ss
			ss = ss[folder.Name]
		end
	end

	local part = parts[#parts]

	if ss:FindFirstChild(part) then
		ss[part]:Destroy()
	end

	local animationFromCurrentData = createAnimationFromCurrentData()
	animationFromCurrentData.Name = part
	animationFromCurrentData.Parent = ss

	if p then
		if not _G.sss:FindFirstChild("AnimationLiteService") then
			local clone = script.AnimationLiteService:Clone()
			clone.Parent = _G.sss
		end

		if v14.Item.Parent:FindFirstChild("AnimationLitePlayScript") then
			v14.Item.Parent:FindFirstChild("AnimationLitePlayScript"):Destroy()
		end

		local clone_2 = script.AnimationLitePlayScript:Clone()
		clone_2.Parent = v14.Item.Parent
		local keyframeSequence = v14.Item.Parent.AnimationLitePlayScript:WaitForChild("KeyframeSequence")
		keyframeSequence.Value = animationFromCurrentData
	end
end

function PromptSave()
	modal = true
	MenuHandler.GetSaveName(v14.Item.Parent, function(p, p2)
		modal = false

		if p ~= nil then
			saveCurrentAnimation(p, p2)
		end
	end)
end

function PromptLoad()
	modal = true
	MenuHandler.GetLoadObj(v14.Item.Parent, function(p)
		if p ~= nil then
			loadCurrentAnimation(p)
		end

		modal = false
	end)
end

function updatePartInclude()
	for k, v15 in pairs(partInclude) do
		local _ = partListByName[k]
		local child = timelineUI.RootFrame.ScrollingFrame:FindFirstChild("LineButton" .. k)

		if child == nil then
			continue
		end

		if v15 then
			child.BackgroundColor3 = buttonOnColor
		else
			child.BackgroundColor3 = buttonOffColor
		end
	end
end

function resetAnimation()
	undoMemory = {}
	redoMemory = {}
	doNotUpdateCursor = true
	resetCopyPoseList()
	resetKeyframes()
	animationLength = 2
	animationLength2 = 0
	loopAnimation = false
	animationPriority = "Core"
	createKeyframe(0)
	doNotUpdateCursor = false
	updateTimeLabels()
	updateCursorPosition()
	resetHandleSelection()

	for k, _ in pairs(partInclude) do
		partInclude[k] = true
	end

	updatePartInclude()
end

stopAnim = false

function showStopAnimUI()
	if stopAnimUI == nil then
		stopAnimUI = Make("ScreenGui", {
			Name = "StopAnimUI",
			Make("Frame", {
				Parent = timelineUI,
				Name = "RootFrame",
				Style = "Custom",
				Position = UDim2.new(0.1, 0, 0.5, 0),
				Size = UDim2.new(0, 150, 0, 50),
				BackgroundColor3 = Color3.new(0.39215686274509803, 0.39215686274509803, 0.5882352941176471),
				BackgroundTransparency = 0.3,
				Make("TextLabel", {
					Name = "TitleBar",
					Font = "ArialBold",
					FontSize = "Size14",
					TextColor3 = GuiSettings.TextColor,
					Position = UDim2.new(0.05, 0, 0, 5),
					Size = UDim2.new(0.9, 0, 0, 15),
					BackgroundTransparency = 1,
					Text = "Animation Playing",
					TextXAlignment = Enum.TextXAlignment.Center
				}),
				Make("TextButton", {
					Name = "StopButton",
					Font = "ArialBold",
					FontSize = GuiSettings.TextMed,
					TextColor3 = GuiSettings.TextColor,
					Position = UDim2.new(0.05, 0, 0, 25),
					Size = UDim2.new(0.9, 0, 0, 20),
					BackgroundColor3 = Color3.new(0.5882352941176471, 0.5882352941176471, 0.5882352941176471),
					BackgroundTransparency = 0,
					Text = "Stop"
				})
			})
		})
	end

	stopAnim = false
	stopAnimUI.Parent = playerGui
	stopAnimUI.RootFrame.StopButton.MouseButton1Click:Connect(function()
		stopAnim = true
		stopAnimUI.Parent = nil
	end)
end

function createPoseFromLastKeyframe(p, parent2, p3)
	if p3 ~= nil then
		local closestPose = getClosestPose(p, p3)

		if closestPose ~= nil then
			local item = closestPose.Item
			parent2 = Make("Pose", {
				Name = p3.Name,
				Parent = parent2,
				Weight = 1,
				CFrame = item.OriginC1 and item.OriginC1:inverse() * closestPose.CFrame:inverse() * item.OriginC1 or closestPose.CFrame
			})
			parent2.EasingStyle = closestPose.EasingStyle
			parent2.EasingDirection = closestPose.EasingDirection
		end

		for _, v15 in pairs(p3.Children) do
			createPoseFromLastKeyframe(p, parent2, v15)
		end
	end
end

function createPosesFromKeyframeHelper(p, parent2, data)
	if not data then
		return
	end

	local pos = p.Poses[data.Item]
	local v15

	if pos then
		local item = pos.Item
		parent2 = Make("Pose", {
			Name = data.Name,
			Parent = parent2,
			Weight = 1,
			MaskWeight = 0,
			CFrame = item.OriginC1 and item.OriginC1:inverse() * pos.CFrame:inverse() * item.OriginC1 or pos.CFrame
		})
		parent2.EasingStyle = pos.EasingStyle
		parent2.EasingDirection = pos.EasingDirection
		v15 = true
	else
		v15 = false
	end

	for _, v16 in pairs(data.Children) do
		if p.Poses[v16.Item] and not v15 then
			parent2 = Make("Pose", {
				Name = data.Name,
				Parent = parent2,
				Weight = 0,
				MaskWeight = 0,
				CFrame = CFrame.new()
			})
			parent2.EasingStyle = Enum.PoseEasingStyle.Linear
			parent2.EasingDirection = Enum.PoseEasingDirection.Out
			v15 = true
		end

		createPosesFromKeyframe(p, parent2, v16)
	end
end

function removeUnincludedParts(p)
	local poses = {}
	local recurse

	recurse = function(instance)
		for _, pose in pairs(instance:GetChildren()) do
			if pose:IsA("Pose") then
				table.insert(poses, pose)
			end

			recurse(pose)
		end
	end

	recurse(p)

	for _, v15 in pairs(poses) do
		local v16 = partInclude[v15.Name] and v15.Name ~= "HumanoidRootPart"
		local v17 = false

		for _, child in pairs(v15:GetChildren()) do
			if not partInclude[child.Name] then
				continue
			end

			v17 = true
			break
		end

		if v16 then
			continue
		end

		v15.Weight = 0

		if v17 then
			continue
		end

		for _, child in pairs(v15:GetChildren()) do
			child.Parent = v15.Parent
		end

		v15:Destroy()
	end
end

function createPosesFromKeyframe(p, p2, p3)
	createPosesFromKeyframeHelper(p, p2, p3)
	removeUnincludedParts(p2)
end

function createAnimationFromCurrentData()
	local parent2 = Make("KeyframeSequence", {
		Name = "Test",
		Loop = loopAnimation,
		Priority = animationPriority
	})

	for k, v16 in spairs(keyframeList, function(p, p2, p3)
		return p[p2].Time < p[p3].Time
	end) do
		local v17 = Make("Keyframe", {
			Name = v16.Name,
			Time = k,
			Parent = parent2
		})
		createPosesFromKeyframe(v16, v17, v14)
	end

	if getKeyframe(animationLength) == nil then
		local v16 = Make("Keyframe", {
			Name = "KF" .. animationLength,
			Time = animationLength,
			Parent = parent2
		})
		createPoseFromLastKeyframe(animationLength, v16, v14)
	end

	return parent2
end

playingAnim = false

function playCurrentAnimation()
	if not playingAnim then
		modal = true
		playingAnim = true
		stopAnim = false

		for _, v15 in pairs(partList) do
			if v15.Motor6D == nil then
				continue
			end

			v15.Motor6D.C1 = v15.OriginC1
			nudgeView()
		end

		local cursor = timelineUI.RootFrame.KeyframeContainer.Cursor
		local Y = timelineUI.RootFrame.KeyframeContainer.CanvasPosition.Y
		cursor.Position = UDim2.new(0, -7.5, 0, Y)
		local playImageButton = timelineUI.RootFrame.Topbar.PlayImageButton
		local v15 = 1 / (animationLength * 10)

		while true do
			local now = tick()

			for i = 0, animationLength + v15, v15 do
				if animationLength < i then
					animationLength2 = animationLength
				else
					animationLength2 = i
				end

				updateCursorPosition()

				if playImageButton.Image == "rbxassetid://87351486351798" then
					stopAnim = true
					break
				end

				while tick() < now + v15 do
					RunService.Heartbeat:wait()
				end

				now = tick()
			end

			if not (stopAnim or not loopAnimation) then
				continue
			end

			animationLength2 = 0
			updateCursorPosition()
			playImageButton.Image = "rbxassetid://87351486351798"
			playingAnim = false
			modal = false

			for _, v16 in pairs(partList) do
				if v16.Motor6D == nil then
					continue
				end

				v16.Motor6D.CurrentAngle = 0
				v16.Motor6D.C1 = v16.OriginC1
			end

			updateCursorPosition()
			break
		end
	end
end

function autoSave()
	if not v14 then
		return
	end

	spawn(function()
		local clone = script.Parent.WarningText:Clone()
		clone.Text = "Creating 'Automatic Save'"
		clone.Position = UDim2.new(0.5, -75, 1, -30)
		clone.Size = UDim2.new(0, 150, 0, 20)
		clone.Visible = true
		clone.Parent = script.Parent
		Debris:AddItem(clone, 3)
	end)
	saveCurrentAnimation("Automatic Save", false)
end

spawn(function()
	while task.wait(60) and _G.AnimationEdit do
		if #undoMemory ~= 0 then
			autoSave()
		end
	end
end)

function loadCurrentAnimation(p)
	if playingAnim then
		return
	end

	loadImportAnim(p)
end

function promptChangeLength()
	modal = true
	local v15 = promptInput("Change Animation Length", (tostring(animationLength)))

	if v15 ~= nil and tonumber(v15) ~= nil then
		setAnimationLength((tonumber(v15)))
	end

	modal = false
end

function promptTickChange()
	local v15 = tonumber(promptInput("Tick Line Increment (seconds)", (tostring(v12))))

	if v15 ~= nil and v15 >= 0.02 then
		v12 = v15
	end

	setAnimationLength(animationLength)
end

function promptSnapChange()
	local v15 = tonumber(promptInput("Cursor Snap Increment (seconds)", (tostring(v13))))

	if v15 ~= nil and v15 >= 0.02 then
		v13 = v15
	end
end

function promptAddTime()
	local v15 = tonumber(promptInput("Add Time At Cursor", "<time>"))

	if v15 ~= nil and v15 > 0 then
		addTimeAtCursorNew(v15)
	end
end

function promptRemoveTime()
	local v15 = tonumber(promptInput("Remove Time At Cursor", "<time>"))

	if v15 ~= nil and v15 > 0 then
		removeTimeAtCursorNew(v15)
	end
end

function promptChangePriority()
	modal = true
	MenuHandler.GetPriority(nil, function(p)
		modal = false
		animationPriority = p
	end)
end

function promptChangeLooping()
	modal = true
	MenuHandler.GetLoop(nil, function(p)
		modal = false
		loopAnimation = p
	end)
end

function promptInput(p, p2)
	modal = true
	local promptInput2 = MenuHandler.PromptInput(p, p2)
	modal = false
	return promptInput2
end

function promptNew()
	modal = true
	local promptOkCancel = MenuHandler.PromptOkCancel("Are you sure? Unsaved progress will be lost.")
	modal = false

	if promptOkCancel == true then
		registerUndo({
			action = "deleteKeyframe"
		})
		resetAnimation()
	end
end

function requestValue(p)
	if p == "Loop" then
		return loopAnimation
	elseif p == "Snap" then
		return v13
	elseif p == "Priority" then
		return animationPriority
	elseif p == "Lines" then
		return v12
	end
end

function importFbxAnimation()
	local parent2 = v14.Item.Parent

	if not parent2:FindFirstChild("InitialPoses") then
		warn("Rig does not have initial pose data. Rig must be imported via FBX to use this feature!")
		return
	end

	resetAnimation()
	local childAddedConnection = nil
	childAddedConnection = game.Workspace.ChildAdded:Connect(function(child)
		if child.Name == "ImportedAnimation" then
			if parent2:FindFirstChild("AnimSaves") == nil then
				local model = Instance.new("Model", parent2)
				model.Name = "AnimSaves"
			end

			task.wait()
			child.Parent = parent2.AnimSaves
			child.Priority = "Core"
			loadKeyframeSequence(child)
			childAddedConnection:disconnect()
		end
	end)
end

function exitPlugin()
	local v15

	if _G.AnimationEdit then
		modal = true
		v15 = MenuHandler.PromptOkCancel("You will lose unsaved progress. Are you sure?")
		modal = false
	else
		v15 = true
	end

	if v15 then
		pcall(function()
			destroySelectionBoxes()
		end)

		if mProxyPart ~= nil then
			mProxyPart:Destroy()
		end

		_G.AnimationEdit = false
		modal = false
		clearAllEvents()

		if MouseTargeterHalt ~= nil then
			MouseTargeterHalt()
		end

		MenuHandler.Quit()

		if destroySelectionBoxes then
			destroySelectionBoxes()
		end

		Exit()
	end
end

function Exit()
	_G.AnimationEdit = false

	if timelineUI then
		timelineUI:Destroy()
	end

	timelineUI = nil

	if saveUI then
		saveUI:Destroy()
	end

	saveUI = nil

	if loadUI then
		loadUI:Destroy()
	end

	loadUI = nil

	if stopAnimUI then
		stopAnimUI:Destroy()
	end

	stopAnimUI = nil

	if timeChangeUI then
		timeChangeUI:Destroy()
	end

	if snapChangeUI then
		snapChangeUI:Destroy()
	end

	if angleChangeUI then
		angleChangeUI:Destroy()
	end

	if tickChangeUI then
		tickChangeUI:Destroy()
	end

	timeChangeUI = nil

	if rotateMoveUI then
		rotateMoveUI:Destroy()
	end

	rotateMoveUI = nil

	if destroySelectionBoxes then
		destroySelectionBoxes()
	end

	modal = false
	rotateMode = true
	partSelection = nil
	rotateStep = 0
	moveStep = 0
	script.Parent.MainBar.Visible = true
	script.Parent.TopBar.Visible = true
	script.Parent.ExplorerPanel.Visible = true
	script.Parent.PropertiesPanel.Visible = true
	script.Parent.main.Enabled = true
	script.Enabled = false
end

function CreateGrid(adornee)
	spawn(function()
		local position = CFrame.new(0, 0, 0).Position
		local extentsSize = adornee.Parent:GetExtentsSize()
		local length = math.max(extentsSize.X, extentsSize.Z) + 3
		local v16 = length / 10
		local v17 = position - Vector3.new(
			0,
			extentsSize.Y * 0.5 + (adornee.Position.Y - adornee.Parent:GetModelCFrame().p.Y) - 0.01,
			0
		)
		local folder = Instance.new("Folder", playerGui)
		folder.Name = "AnimEdit_Lines"
		table.insert(v, folder)

		for i = -5, 5 do
			local lineHandleAdornment = Instance.new("LineHandleAdornment")
			lineHandleAdornment.Thickness = 2
			lineHandleAdornment.Color = parent.AnimationEditor.Customize.GridColor.Value
			lineHandleAdornment.Length = length
			lineHandleAdornment.Adornee = adornee
			lineHandleAdornment.CFrame = CFrame.new(v17) + Vector3.new(i * v16, 0, length / 2)
			spawn(function()
				for i2 = 1, 60 do
					if not lineHandleAdornment then
						continue
					end

					lineHandleAdornment.Length = length * (i2 / 60)
					RunService.Heartbeat:wait()
				end
			end)
			task.wait(0.05)
			lineHandleAdornment.Parent = folder
			table.insert(v, lineHandleAdornment)
		end

		for i = -5, 5 do
			local lineHandleAdornment = Instance.new("LineHandleAdornment")
			lineHandleAdornment.Thickness = 2
			lineHandleAdornment.Color = parent.AnimationEditor.Customize.GridColor.Value
			lineHandleAdornment.Length = length
			lineHandleAdornment.Adornee = adornee
			lineHandleAdornment.CFrame = (CFrame.new(v17) + Vector3.new(length / 2, 0, i * v16)) * CFrame.Angles(
				0,
				1.5707963267948966,
				0
			)
			spawn(function()
				for i2 = 1, 60 do
					if not lineHandleAdornment then
						continue
					end

					lineHandleAdornment.Length = length * (i2 / 60)
					RunService.Heartbeat:wait()
				end
			end)
			task.wait(0.05)
			lineHandleAdornment.Parent = folder
			table.insert(v, lineHandleAdornment)
		end
	end)
end

function menuRequest(p)
	task.wait()

	if modal then
		return
	end

	if p == "Save" then
		PromptSave()
	elseif p == "Load" then
		PromptLoad()
	elseif p == "Help" then
		MenuHandler.PromptHelpOk()
	elseif p == "EditHelp" then
		print("plugin:OpenWikiPage(\"Animations#Edit_Menu\")")
	elseif p == "SettingsHelp" then
		print("plugin:OpenWikiPage(\"Animations#Settings_Menu\")")
	elseif p == "New" then
		promptNew()
	elseif p == "Play" then
		modal = true
		playCurrentAnimation()
	elseif p == "Paste" then
		pastePoses()
	elseif p == "CreateKeyframe" then
		createKeyframe(animationLength2)
	elseif p == "Undo" then
		undo()
	elseif p == "Redo" then
		redo()
	elseif p == "ChangeLength" then
		promptChangeLength()
	elseif p == "Lines" then
		promptTickChange()
	elseif p == "Snap" then
		promptSnapChange()
	elseif p == "AddTime" then
		promptAddTime()
	elseif p == "RemoveTime" then
		promptRemoveTime()
	elseif p == "Priority" then
		promptChangePriority()
	elseif p == "Loop" then
		promptChangeLooping()
	elseif p == "TweenCursor" then
		v3.TweenCursor = not v3.TweenCursor
	elseif p == "Interpolation" then
		v3.Interpolation = not v3.Interpolation
	elseif p == "ShowTooltips" then
		v3.Tooltips = not v3.Tooltips
	elseif p == "SelectInvisible" then
		v3.SelectInvisible = not v3.SelectInvisible
	elseif p == "FBXImport" then
		importFbxAnimation()
	end
end

if _G.AnimationEdit == true then
	exitPlugin()
elseif MenuHandler.HasActiveWindow() then
	exitPlugin()
else
	local function fn(instance)
		if instance == nil then
			exitPlugin()
			return
		end

		_G.AnimationEdit = true
		timelineUI = nil
		saveUI = nil
		loadUI = nil
		stopAnimUI = nil
		timeChangeUI = nil
		snapChangeUI = nil
		angleChangeUI = nil
		tickChangeUI = nil
		partList = {}
		partListByName = {}
		partToItemMap = {}
		partToLineNumber = {}
		v14 = nil
		partInclude = {}
		modal = false
		rotateMode = true
		partSelection = nil
		rotateStep = 0
		moveStep = 0
		animationController = (function(instance2)
			for _, child in pairs(instance2:GetChildren()) do
				if child:IsA("Humanoid") or child:IsA("AnimationController") then
					return child
				end
			end

			return nil
		end)(instance.Parent)
		local v15 = {
			Item = instance,
			Name = instance.Name,
			Motor6D = nil,
			OriginC1 = CFrame.new(),
			Children = {},
			Parent = nil
		}
		v14 = v15
		local motor6Ds = {}
		local recurse

		recurse = function(motor6D)
			if motor6D:IsA("Motor6D") then
				table.insert(motor6Ds, motor6D)
			end

			for _, child in pairs(motor6D:GetChildren()) do
				recurse(child)
			end
		end

		recurse(v14.Item.Parent)
		local v16 = 1
		local dataByName = {}

		local function findPairedJoints(data)
			local item = data.Item
			local result = {}
			local result2 = {}

			for _, v17 in pairs(motor6Ds) do
				if v17.Part1 and v17.Part1.Name == "ProxyPart" then
					break
				end

				if v17.Part0 and v17.Part0.Name == "ProxyPart" then
					return result, result2
				end

				if v17.Part0 == item and v17.Part1 ~= nil and dataByName[v17.Part1.Name] == nil then
					table.insert(result, v17.Part1)
					table.insert(result2, v17)
				elseif v17.Part1 == item and v17.Part0 ~= nil and dataByName[v17.Part0.Name] == nil then
					table.insert(result, v17.Part0)
					table.insert(result2, v17)
				end
			end

			return result, result2
		end

		local doCalculate

		doCalculate = function(parent2)
			dataByName[parent2.Name] = parent2
			partList[parent2.Item] = parent2
			partListByName[parent2.Name] = parent2
			partToItemMap[parent2.Item] = parent2
			partToLineNumber[parent2.Item] = v16
			partInclude[parent2.Name] = true
			local pairedJoints, v17 = findPairedJoints(parent2)

			for k, pairedJoint in pairs(pairedJoints) do
				local motor6D = v17[k]
				local v19 = {
					Item = pairedJoint,
					Name = pairedJoint.Name,
					Motor6D = motor6D,
					OriginC1 = repairedCFrame(motor6D.C1),
					Children = {},
					Parent = parent2
				}
				parent2.Children[#parent2.Children + 1] = v19
				v16 += 1
				doCalculate(v19)
			end
		end

		doCalculate(v15)
		createTimelineUI(v15)
		MakePartSelectGui(v15)
		MenuHandler.InitializeSettings({
			Interpolation = v3.Interpolation,
			SelectInvisible = v3.TransparentSelect,
			TweenCursor = v3.TweenCursor,
			ShowTooltips = v3.Tooltips
		})
		MenuHandler.InitializeTopbar(timelineUI.RootFrame, function()
			return modal == false
		end, function()
			modal = true
		end, function()
			modal = false
		end, menuRequest, requestValue)
		MenuHandler.InitializeTooltips()
		resetAnimation()
		CreateGrid(instance)
		MenuHandler.PromptHelpOk()
	end

	MenuHandler.SelectRig(mouse, nil, fn)
end