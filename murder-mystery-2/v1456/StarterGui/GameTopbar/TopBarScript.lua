local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local parent = script.Parent
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local inputContext = playerGui:WaitForChild("InputContext")
local touchEnabled = UserInputService.TouchEnabled
local container = parent:WaitForChild("Container")
local emotes = container:WaitForChild("Emotes")
local mouseLock = container:WaitForChild("MouseLock")
local button = mouseLock:WaitForChild("Container"):WaitForChild("Button")
local mouseLock2 = localPlayer.PlayerScripts:WaitForChild("MouseLock")
local crosshair = parent:WaitForChild("Crosshair")
local keyboardBinding = inputContext:WaitForChild("GameplayContext"):WaitForChild("Emotes"):WaitForChild("KeyboardBinding")
local textLabel = emotes:WaitForChild("Hotkey"):WaitForChild("ImageLabel"):WaitForChild("TextLabel")

-- equivalent calls inferred from this helper; original call sites unknown
local function updateMouseLockButton(enabled)
	crosshair.Visible = enabled and UserInputService.PreferredInput == Enum.PreferredInput.Touch
	mouseLock.Container.Background.UIStroke.Enabled = enabled
end

local function onMouseLockButtonActivated()
	updateMouseLockButton(mouseLock2:Invoke()) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateTopBar()
	local topbarInset = GuiService.TopbarInset
	container.Position = UDim2.new(0, topbarInset.Min.X + 6, 0, 12)

	if GuiService:IsTenFootInterface() then
		container.Visible = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onPreferredInputChanged()
	local hotkey = emotes:WaitForChild("Hotkey")
	hotkey.Visible = UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateKeybinds()
	textLabel.Text = keyboardBinding.KeyCode.Name
end

local function onInitialize()
	updateKeybinds() -- equivalent call inferred; original call site unknown
	keyboardBinding:GetPropertyChangedSignal("KeyCode"):Connect(updateKeybinds)
	mouseLock.Visible = touchEnabled
	button.Activated:Connect(onMouseLockButtonActivated)
	updateTopBar() -- equivalent call inferred; original call site unknown
	onPreferredInputChanged() -- equivalent call inferred; original call site unknown
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(onPreferredInputChanged)
	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(updateTopBar)
	mouseLock2:WaitForChild("MouseLockToggled").Event:Connect(updateMouseLockButton)
	task.wait(2)
	updateTopBar() -- equivalent call inferred; original call site unknown
end

onInitialize()