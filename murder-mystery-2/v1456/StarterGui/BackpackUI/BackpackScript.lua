local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DeviceService = require(ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("DeviceService"))
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local backpackFrame = parent:WaitForChild("BackpackFrame")
local backpackItem = backpackFrame:WaitForChild("BackpackItem")
backpackItem.Parent = script
local backpackContext = parent.Parent:WaitForChild("InputContext"):WaitForChild("BackpackContext")
local v = { "Weapon" }
local clonesByTool = {}
local v2 = 10

-- equivalent calls inferred from this helper; original call sites unknown
local function getBackpackIndex(p)
	for k, v3 in v do
		if v3 == p then
			return k
		end
	end
end

local function updateItemFrame(p)
	local v3 = clonesByTool[p]

	if not v3 then
		return
	end

	local backpackIndex = getBackpackIndex(p) -- equivalent call inferred; original call site unknown
	v3.Container.Hotkey.Text = backpackIndex == 10 and 0 or backpackIndex
	v3.Container.Hotkey.Visible = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
	v3.Container.NameLabel.Text = p.TextureId ~= "" and "" or p.Name or ""
	v3.Container.ToolIcon.Image = p.TextureId
	v3.LayoutOrder = backpackIndex
	v3.Visible = backpackIndex <= v2

	if backpackIndex <= 10 then
		local touchBinding = backpackContext:FindFirstChild("Item" .. backpackIndex):FindFirstChild("TouchBinding")
		touchBinding.UIButton = v3.EquipButton
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onItemUnequipped(tool)
	clonesByTool[tool].Equipped.Visible = false
end

local function onItemEquipped(tool)
	local backpackIndex = getBackpackIndex(tool) -- equivalent call inferred; original call site unknown

	if v2 < backpackIndex then
		table.remove(v, backpackIndex)
		table.insert(v, 2, tool)

		for _, v3 in v do
			updateItemFrame(v3)
		end
	end

	clonesByTool[tool].Equipped.Visible = true
end

local function findBackpackIndex(instance)
	if instance:HasTag("Weapon") then
		return 1
	end

	for k, v3 in v do
		if v3 == "Empty" then
			return k
		end
	end

	return nil
end

local function onItemAdded(tool)
	if not tool:IsA("Tool") then
		return
	end

	-- equivalent call inferred; original call site unknown
	if getBackpackIndex(tool) then
		if tool.Parent == localPlayer.Backpack then
			onItemUnequipped(tool) -- equivalent call inferred; original call site unknown
		elseif tool.Parent == localPlayer.Character then
			onItemEquipped(tool)
		end
	else
		local v3

		if tool:HasTag("Weapon") then
			v3 = 1
		else
			for k, v5 in v do
				if v5 ~= "Empty" then
					continue
				end

				v3 = k
				break
			end
		end

		if v3 and v[1] == "Weapon" then
			v[v3] = tool
		else
			table.insert(v, tool)
		end

		local clone = backpackItem:Clone()
		clone.Visible = false
		clonesByTool[tool] = clone
		clone.Parent = backpackFrame

		for _, v4 in v do
			if v4 ~= tool then
				updateItemFrame(v4)
			end
		end

		updateItemFrame(tool)
		clone:GetPropertyChangedSignal("Name"):Connect(function()
			clone.Container.NameLabel.Text = tool.Name
		end)
		local parentChangedConnection = nil
		parentChangedConnection = tool:GetPropertyChangedSignal("Parent"):Connect(function()
			local backpackIndex = getBackpackIndex(tool) -- equivalent call inferred; original call site unknown

			if localPlayer:FindFirstChildOfClass("Backpack") and (tool.Parent ~= nil or tool.Parent == localPlayer.Backpack or tool.Parent == localPlayer.Character) then
				return
			end

			parentChangedConnection:Disconnect()
			clone:Destroy()

			if backpackIndex == 1 then
				v[1] = "Weapon"
			else
				v[backpackIndex] = "Empty"
			end
		end)
	end
end

local function onCharacterAdded(character)
	local backpack = localPlayer.Backpack

	for _, child in backpack:GetChildren() do
		onItemAdded(child)
	end

	for _, child in character:GetChildren() do
		onItemAdded(child)
	end

	backpack.ChildAdded:Connect(onItemAdded)
	character.ChildAdded:Connect(onItemAdded)
end

local function equipItemInDirection(p: number)
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if not tool then
		local v3 = v[1]

		if type(v3) ~= "userdata" then
			v3 = v[2]

			if type(v3) ~= "userdata" then
				return
			end
		end

		if v3.Parent == localPlayer.Backpack then
			humanoid:EquipTool(v3)
			return
		end
	end

	local backpackIndex = getBackpackIndex(tool) -- equivalent call inferred; original call site unknown
	local v3 = v[backpackIndex + p]

	if type(v3) ~= "userdata" then
		humanoid:UnequipTools()
		return
	end

	if v3.Parent ~= localPlayer.Backpack then
		return
	end

	humanoid:EquipTool(v3)
end

local function onInitialize()
	if GuiService:IsTenFootInterface() then
		return
	end

	if DeviceService:IsMobileDevice() then
		v2 = 3
	end

	onCharacterAdded(localPlayer.Character)
	localPlayer.CharacterAdded:Connect(onCharacterAdded)

	for _, child in backpackContext:GetChildren() do
		local v4 = tonumber((string.sub(child.Name, 5)))
		child.Pressed:Connect(function()
			local v5 = v[v4]

			if not (v5 and type(v5) == "userdata") then
				return
			end

			local character = localPlayer.Character

			if not character then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if not humanoid then
				return
			end

			if v5.Parent == localPlayer.Backpack then
				humanoid:EquipTool(v5)
			else
				humanoid:UnequipTools()
			end
		end)
	end

	backpackContext:WaitForChild("GamepadLeft").Pressed:Connect(function()
		equipItemInDirection(-1)
	end)
	backpackContext:WaitForChild("GamepadRight").Pressed:Connect(function()
		equipItemInDirection(1)
	end)
	task.spawn(function()
		while task.wait() do
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		end
	end)
end

onInitialize()