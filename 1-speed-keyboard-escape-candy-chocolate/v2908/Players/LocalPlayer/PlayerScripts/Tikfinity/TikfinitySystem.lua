local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local Vide = require(ReplicatedStorage.Packages.Vide)
local TikfinityMobileEquipButton = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.TikfinityMobileEquipButton)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local tikfinityAction = remotes:WaitForChild("TikfinityAction")
local tikfinitySaveBinds = remotes:WaitForChild("TikfinitySaveBinds")
local tikfinityLoadBinds = remotes:WaitForChild("TikfinityLoadBinds")
local tikfinitySaveMobileSlots = remotes:WaitForChild("TikfinitySaveMobileSlots")
local tikfinityLoadMobileSlots = remotes:WaitForChild("TikfinityLoadMobileSlots")
local tikfinityModules = ReplicatedStorage:FindFirstChild("TikfinityModules")
local v = {
	Explode = 7,
	Chicken = 3,
	Jail = 5,
	Ragdoll = 3,
	Turtle = 5,
	Tiny = 5,
	Invisible = 5,
	Disco = 5,
	Blur = 5,
	Earthquake = 4,
	BecomeNoob = 7,
	ScreenFlip = 6,
	GreyEffect = 6,
	ReverseControls = 6,
	RandomKey = 4,
	SlipperyFloor = 8,
	BigHead = 6,
	FirstPerson = 6
}
local v2 = false
local v3 = {}
local v4 = {}
local namesByText = {}
local v5 = {}
local v6 = {}
local name = nil
local fn
local fn2
local fn3
local v7 = { "TikfinityMobileSlot1", "TikfinityMobileSlot2", "TikfinityMobileSlot3" }
local v8 = { UDim2.fromScale(0.2, 0.13), UDim2.fromScale(0.4, 0.45), UDim2.fromScale(0.4, 0.7) }
local uDim = UDim2.fromOffset(44, 44)
local v9 = {
	Explode = "💥",
	Chicken = "🐔",
	Jail = "⛓️",
	Ragdoll = "🧍",
	Turtle = "🐢",
	Tiny = "👶",
	Invisible = "👻",
	Disco = "💃",
	Blur = "🌫️",
	Earthquake = "🌋",
	BecomeNoob = "🤓",
	ScreenFlip = "🔄",
	GreyEffect = "⚫",
	ReverseControls = "🔀",
	RandomKey = "🎲",
	SlipperyFloor = "🍌",
	BigHead = "🤯",
	FirstPerson = "👁️"
}
local v10 = {}

local function getUI(tag)
	if v10[tag] and v10[tag].Parent then
		return v10[tag]
	end

	for _, v11 in ipairs(CollectionService:GetTagged(tag)) do
		if not v11:IsDescendantOf(playerGui) then
			continue
		end

		v10[tag] = v11
		return v11
	end

	v10[tag] = nil
	return v10[tag]
end

local flag = false
local object = setmetatable({}, {
	__mode = "k"
})

local function updateBinds()
	namesByText = {}
	local UI = getUI("TikfinityScroll")

	if not UI then
		return
	end

	for _, frame in ipairs(UI:GetChildren()) do
		if not (frame:IsA("Frame") and frame:FindFirstChild("TextBox")) then
			continue
		end

		local text = frame.TextBox.Text:upper()

		if text ~= "" then
			namesByText[text] = frame.Name
		end
	end
end

local function saveBindsToServer()
	local UI = getUI("TikfinityScroll")

	if not UI then
		return
	end

	local textsByName = {}

	for _, frame in ipairs(UI:GetChildren()) do
		if not (frame:IsA("Frame") and frame:FindFirstChild("TextBox")) then
			continue
		end

		local text = frame.TextBox.Text:upper()

		if text ~= "" then
			textsByName[frame.Name] = text
		end
	end

	tikfinitySaveBinds:FireServer(textsByName)
end

local function loadBindsFromServer()
	local UI = getUI("TikfinityScroll")

	if not UI then
		return
	end

	local success, result = pcall(function()
		return tikfinityLoadBinds:InvokeServer()
	end)

	if not success or type(result) ~= "table" then
		return
	end

	for _, frame in ipairs(UI:GetChildren()) do
		if not (frame:IsA("Frame") and frame:FindFirstChild("TextBox")) then
			continue
		end

		local text = result[frame.Name]

		if type(text) == "string" and text ~= "" then
			frame.TextBox.Text = text
		end
	end

	updateBinds()
end

local function connectScrollBinds()
	if flag then
		return
	end

	local UI = getUI("TikfinityScroll")

	if not UI then
		return
	end

	flag = true

	local function connectFrame(frame)
		if not frame:IsA("Frame") then
			return
		end

		local textBox = frame:FindFirstChild("TextBox")

		if not textBox or not textBox:IsA("TextBox") or object[textBox] then
			return
		end

		object[textBox] = true
		local text = textBox.Text:upper()
		textBox.Focused:Connect(function()
			text = textBox.Text:upper()
		end)
		textBox.FocusLost:Connect(function(p)
			local text2 = textBox.Text:upper()
			textBox.Text = text2
			updateBinds()
			saveBindsToServer()

			if p and text2 ~= text then
				local v11

				if text2 == "" then
					v11 = `Tikfinity: {frame.Name} keybind removed`
				else
					v11 = `Tikfinity: {frame.Name} set to {text2}`
				end

				NotificationSystem:ShowGeneralNotification(v11, Color3.fromRGB(100, 255, 100), 3)
				text = text2
			end
		end)
	end

	loadBindsFromServer()

	for _, child in ipairs(UI:GetChildren()) do
		connectFrame(child)
	end

	UI.ChildAdded:Connect(function(child)
		connectFrame(child)
		updateBinds()

		if fn3 then
			fn3()
		end
	end)
end

local function processQueue(childName)
	if v4[childName] then
		return
	end

	v4[childName] = true

	while (v3[childName] or 0) > 0 do
		v3[childName] -= 1

		if v2 then
			local child = tikfinityModules and tikfinityModules:FindFirstChild(childName)

			if child then
				local v11 = child
				task.spawn(function()
					local success, result = pcall(function()
						local module = require(v11)
						module.Run(localPlayer)
					end)

					if not success then
						warn("[Tikfinity] Erreur module local : " .. result)
					end
				end)
			else
				tikfinityAction:FireServer(childName)
			end
		end

		local v11 = v[childName] or 3
		task.wait(v11)
	end

	v4[childName] = false
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not v2 then
		return
	end

	local v11 = input.UserInputType == Enum.UserInputType.Keyboard and namesByText[input.KeyCode.Name:upper()]

	if v11 then
		fn(v11)
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function setupToggle(p)
	p.Activated:Connect(function()
		v2 = not v2
		p.BackgroundColor3 = v2 and Color3.fromRGB(85, 255, 127) or Color3.fromRGB(255, 85, 85)
		p.Text = v2 and "Tikfinity : ON" or "Tikfinity : OFF"
		name = nil
		fn2()
	end)
end

for _, v11 in ipairs(CollectionService:GetTagged("TikfinityToggle")) do
	setupToggle(v11) -- equivalent call inferred; original call site unknown
end

CollectionService:GetInstanceAddedSignal("TikfinityToggle"):Connect(setupToggle)

local function onCloseBtnAdded(p)
	p.MouseButton1Click:Connect(function()
		local UI = getUI("TikfinityModal")

		if UI and ClientState.ActiveModal == UI then
			ClientState:CloseCurrentModal()
		end
	end)
end

local function fn4()
	return UserInputService.PreferredInput == Enum.PreferredInput.Touch
end

fn = function(p)
	if p then
		v3[p] = (v3[p] or 0) + 1
		task.spawn(processQueue, p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function saveMobileSlotsToServer()
	tikfinitySaveMobileSlots:FireServer(v5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function loadMobileSlotsFromServer()
	local success, result = pcall(function()
		return tikfinityLoadMobileSlots:InvokeServer()
	end)

	if success and type(result) == "table" then
		v5 = result
	end
end

local function findMobileSlot(p)
	if v5[1] == p then
		return 1
	end

	if v5[2] == p then
		return 2
	end

	if v5[3] == p then
		return 3
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unbindMobileActions()
	for _, v11 in ipairs(v7) do
		ContextActionService:UnbindAction(v11)
	end
end

local function equipSelectedAction(p)
	local v11 = name

	if not v11 then
		return
	end

	if v5[1] == v11 then
		v5[1] = nil
	end

	if v5[2] == v11 then
		v5[2] = nil
	end

	if v5[3] == v11 then
		v5[3] = nil
	end

	v5[p] = v11
	name = nil
	saveMobileSlotsToServer() -- equivalent call inferred; original call site unknown
	fn3()
	fn2()
	NotificationSystem:ShowGeneralNotification(
		`Tikfinity: {v11} equipped in mobile slot {p}`,
		Color3.fromRGB(100, 255, 100),
		3
	)
end

fn2 = function()
	unbindMobileActions() -- equivalent call inferred; original call site unknown

	if not (fn4() and (v2 or name)) then
		return
	end

	for i, v11 in ipairs(v7) do
		local v12 = i
		ContextActionService:BindAction(v11, function(p, p2)
			if p2 ~= Enum.UserInputState.Begin then
				return
			end

			if name then
				equipSelectedAction(v12)
			elseif v2 then
				fn(v5[v12])
			end
		end, true)
		local v13

		if name then
			v13 = `SLOT {i}`
		else
			v13 = v9[v5[i]] or `SLOT {i}`
		end

		ContextActionService:SetTitle(v11, v13)
		ContextActionService:SetPosition(v11, v8[i])
		local button = ContextActionService:GetButton(v11)

		if button then
			button.Size = uDim
		end
	end
end

local function removeMobileEquipButtons()
	for k, v11 in pairs(v6) do
		if k.Parent then
			k.Visible = true
		end

		v11.unmount()
	end

	v6 = {}
end

fn3 = function()
	if not fn4() then
		removeMobileEquipButtons()
		return
	end

	local UI = getUI("TikfinityScroll")

	if not UI then
		return
	end

	for _, frame in ipairs(UI:GetChildren()) do
		local textBox

		if frame:IsA("Frame") then
			textBox = frame:FindFirstChild("TextBox")
		end

		if textBox and textBox:IsA("TextBox") and not v6[textBox] then
			local source = Vide.source("EQUIP")
			local v11 = textBox
			local v13 = frame
			local unmount = Vide.mount(function()
				return TikfinityMobileEquipButton({
					position = v11.Position,
					size = v11.Size,
					zIndex = v11.ZIndex + 1,
					text = source,
					onActivated = function()
						local name2 = v13.Name
						local v15

						if v5[1] == name2 then
							v15 = 1
						elseif v5[2] == name2 then
							v15 = 2
						elseif v5[3] == name2 then
							v15 = 3
						else
							v15 = nil
						end

						if v15 then
							v5[v15] = nil
							name = nil
							saveMobileSlotsToServer() -- equivalent call inferred; original call site unknown
							fn3()
							fn2()
							NotificationSystem:ShowGeneralNotification(
								`Tikfinity: {v13.Name} removed from mobile slot {v15}`,
								Color3.fromRGB(255, 170, 80),
								3
							)
						else
							name = v13.Name
							fn2()
							NotificationSystem:ShowGeneralNotification(
								`Tikfinity: choose a slot for {v13.Name}`,
								Color3.fromRGB(100, 200, 255),
								3
							)
						end
					end
				})
			end, frame)
			textBox.Visible = false
			v6[textBox] = {
				text = source,
				unmount = unmount
			}
		end

		if not (textBox and v6[textBox]) then
			continue
		end

		local name2 = frame.Name
		local v11

		if v5[1] == name2 then
			v11 = 1
		elseif v5[2] == name2 then
			v11 = 2
		elseif v5[3] == name2 then
			v11 = 3
		else
			v11 = nil
		end

		v6[textBox].text(not v11 and "EQUIP" or `SLOT {v11}`)
	end
end

for _, v11 in ipairs(CollectionService:GetTagged("TikfinityCloseBtn")) do
	v11.MouseButton1Click:Connect(function()
		local UI = getUI("TikfinityModal")

		if UI and ClientState.ActiveModal == UI then
			ClientState:CloseCurrentModal()
		end
	end)
end

CollectionService:GetInstanceAddedSignal("TikfinityCloseBtn"):Connect(onCloseBtnAdded)
task.spawn(function()
	task.wait(2)
	loadMobileSlotsFromServer() -- equivalent call inferred; original call site unknown
	connectScrollBinds()
	fn3()
	fn2()
end)
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
	name = nil
	fn3()
	fn2()
end)
localPlayer.CharacterAdded:Connect(function()
	v10 = {}
	flag = false
	object = setmetatable({}, {
		__mode = "k"
	})
	task.wait(1)
	connectScrollBinds()
	fn3()
	fn2()
end)