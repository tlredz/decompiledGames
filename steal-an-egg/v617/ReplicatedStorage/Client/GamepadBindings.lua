local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ConsoleSignals = require(ReplicatedStorage.Client.ConsoleSignals)
local GUI = require(ReplicatedStorage.Client.GUI)
local InputIconsConfig = require(ReplicatedStorage.Client.InputIconsConfig)
local Log = require(ReplicatedStorage.Packages.Log)
local MenuNavigation = require(ReplicatedStorage.Client.MenuNavigation)
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local buttonB = Enum.KeyCode.ButtonB
local v = {
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.ButtonB,
	Enum.KeyCode.ButtonX,
	Enum.KeyCode.ButtonY,
	Enum.KeyCode.ButtonL1,
	Enum.KeyCode.ButtonL2,
	Enum.KeyCode.ButtonL3,
	Enum.KeyCode.ButtonR1,
	Enum.KeyCode.ButtonR2,
	Enum.KeyCode.ButtonR3,
	Enum.KeyCode.ButtonSelect,
	Enum.KeyCode.ButtonStart,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadRight,
	Enum.KeyCode.DPadUp
}
local v2 = {
	[Enum.KeyCode.ButtonStart] = true
}
local v3 = {
	[Enum.KeyCode.DPadDown] = true,
	[Enum.KeyCode.DPadLeft] = true,
	[Enum.KeyCode.DPadRight] = true,
	[Enum.KeyCode.DPadUp] = true
}
local v4 = {}
local v5 = {}

for _, v6 in v do
	v4[v6.Name] = v6
	v5[v6] = true
end

assert(v5[buttonB], "the close key has to be a routable key")
local v6 = {
	ActivePets = {
		rank = 900,
		captionedClose = true
	},
	BackpackGui = {
		blocked = true
	},
	BossMastery = {
		captionedClose = true
	},
	BossShop = {
		captionedClose = true
	},
	DropHeldEgg = {
		rank = 200
	},
	FreeGift = {
		captionedClose = true
	},
	GrowingEggs = {
		rank = 900,
		captionedClose = true
	},
	Index = {
		captionedClose = true
	},
	LimitedTimePopupsUI = {
		captionedClose = true
	},
	Message = {
		rank = 1000
	},
	MonsterChestRewards = {
		captionedClose = true
	},
	PetFuse = {
		captionedClose = true
	},
	PhoneVideoUI = {
		blocked = true
	},
	PopupPrompt = {
		captionedClose = true
	},
	RescueDragonFTUEQuest = {
		captionedClose = true
	},
	RiftTradeIn = {
		captionedClose = true
	},
	DrScrambleTradeIn = {
		captionedClose = true
	},
	RobuxShop = {
		captionedClose = true
	},
	RobuxShopOLD = {
		blocked = true
	},
	OldRobuxShop = {
		blocked = true
	},
	RunButton = {
		rank = 100
	},
	ScrambleBossMastery = {
		captionedClose = true
	},
	SellPrompt = {
		captionedClose = true
	},
	Settings = {
		captionedClose = true
	},
	SpeedShop = {
		blocked = true
	},
	TrailShop = {
		captionedClose = true
	},
	Treadmill = {
		blocked = true
	},
	TreadmillScreenButtonSwapLeft = {
		blocked = true
	},
	TreadmillScreenButtonSwapRight = {
		blocked = true
	},
	TreadmillScreenComments = {
		blocked = true
	},
	TreadmillUI = {
		blocked = true
	}
}
local frozen = table.freeze({})
local v7 = {
	microsoft = "B",
	sony = "O"
}
local GamepadBindings = {}
local v8 = Log.new()
local folder = GUI.PlayerGui()
local v9 = {}
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = nil
local v14 = nil
local v15 = nil
local v16 = true

-- equivalent calls inferred from this helper; original call sites unknown
local function describe(instance)
	if instance == nil then
		return "none"
	end

	return (instance:GetFullName())
end

local function policyOf(p: string)
	return v6[p] or frozen
end

-- equivalent calls inferred from this helper; original call sites unknown
local function screenOf(screenGui)
	if screenGui:IsA("ScreenGui") then
		return screenGui
	end

	return (screenGui:FindFirstAncestorOfClass("ScreenGui"))
end

local function blocked(layerCollector)
	if not layerCollector:IsA("LayerCollector") then
		layerCollector = layerCollector:FindFirstAncestorWhichIsA("LayerCollector")
	end

	return layerCollector ~= nil and (v6[layerCollector.Name] or frozen).blocked == true
end

local showing

showing = function(parent)
	if parent:IsA("ScreenGui") then
		return parent.Enabled
	end

	if parent:IsA("GuiObject") and not parent.Visible then
		return false
	end

	local parent2 = parent.Parent
	return parent2 ~= nil and showing(parent2)
end

local ownerAbove

ownerAbove = function(parent)
	local parent2 = parent.Parent

	if parent2 == nil or parent2:IsA("ScreenGui") then
		return nil
	end

	if parent2:IsA("GuiButton") then
		return parent2
	end

	return (ownerAbove(parent2))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rankOf(screen)
	return (v6[screen.Name] or frozen).rank or screen.DisplayOrder
end

local function keyFrom(p)
	local v17

	if typeof(p) == "EnumItem" then
		v17 = p
	else
		v17 = v4[p]
	end

	if v17 == nil or not v5[v17] then
		error(`{tostring(p)} is not a key this router knows`, 3)
	end

	return v17
end

local function closeCaption()
	return v7[v15 or InputIconsConfig.Vendor()]
end

local function artFor(p)
	local v17 = v11[p]

	if v17 ~= nil then
		return v17
	end

	local v18 = InputIconsConfig.Image(p) or ""
	v11[p] = v18
	return v18
end

local function applyLook(guiObject)
	local v17 = v10[guiObject]

	if v17 == nil then
		return
	end

	local isConsole = PlatformController.IsConsole()
	local image = v17.image
	local caption = v17.caption

	if image == nil or not guiObject:IsA("ImageLabel") then
		if caption ~= nil and guiObject:IsA("TextLabel") then
			if isConsole then
				caption = v7[v15 or InputIconsConfig.Vendor()]
			end

			guiObject.Text = caption
		end
	else
		if isConsole then
			image = InputIconsConfig.Image(buttonB) or image
		end

		guiObject.Image = image
	end

	guiObject.Visible = isConsole or v17.visible
end

-- equivalent calls inferred from this helper; original call sites unknown
local function remember(instance, p)
	if v10[instance] == nil then
		v10[instance] = p
		instance.Destroying:Once(function()
			v10[instance] = nil
		end)
	end

	applyLook(instance)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rememberCaption(label)
	if label ~= nil and label:IsA("TextLabel") then
		remember(label, {
			visible = label.Visible,
			caption = label.Text
		}) -- equivalent call inferred; original call site unknown
	end
end

local function decorateClose(instance, flag: boolean)
	local textButton

	if not flag then
		textButton = instance:FindFirstChild("TextButton")
	end

	if textButton == nil or not textButton:IsA("ImageLabel") then
		local textLabel = instance:FindFirstChild("TextLabel")
		rememberCaption(textLabel) -- equivalent call inferred; original call site unknown

		if flag and textLabel ~= nil then
			rememberCaption(textLabel:FindFirstChild("TextLabel")) -- equivalent call inferred; original call site unknown
		end
	else
		remember(textButton, {
			visible = textButton.Visible,
			image = textButton.Image
		}) -- equivalent call inferred; original call site unknown
	end
end

local function paintGlyph(guiObject, p)
	local isConsole = PlatformController.IsConsole()
	guiObject.Visible = isConsole and guiObject:GetAttribute("ManualVisibility") ~= true

	if isConsole and (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
		local image = v11[p]

		if image == nil then
			image = InputIconsConfig.Image(p) or ""
			v11[p] = image
		end

		guiObject.Image = image
	end
end

local function releaseClaimsOn(p)
	for k, v17 in v12 do
		if v17 == p then
			v12[k] = nil
		end
	end
end

local function bind(instance, p, glyph, closes: boolean)
	local v17 = screenOf(instance) -- equivalent call inferred; original call site unknown
	local screen = assert(v17, (("%* needs a ScreenGui above it to take gamepad input"):format(describe(instance))))

	if v9[instance] == nil then
		instance.Destroying:Once(function()
			v9[instance] = nil
			local owner = instance

			for k, v20 in v12 do
				if v20 == owner then
					v12[k] = nil
				end
			end
		end)
	end

	v9[instance] = {
		key = p,
		closes = closes,
		glyph = glyph,
		owner = instance,
		screen = screen
	}
end

local function adoptGlyph(instance)
	local gamepadKey = instance:GetAttribute("GamepadKey")
	assert(typeof(gamepadKey) == "string", (("%* needs a string GamepadKey attribute"):format(describe(instance))))
	local v17 = v4[gamepadKey]
	assert(v17 ~= nil, (`{describe(instance)}: {gamepadKey} is not a key this router knows`))
	local parent = instance.Parent

	if parent == nil or parent:IsA("ScreenGui") then
		parent = nil
	elseif not parent:IsA("GuiButton") then
		parent = ownerAbove(parent)
	end

	bind(assert(parent, (("%* has to sit under a GuiButton"):format(describe(instance)))), v17, instance, false)
	paintGlyph(instance, v17)
end

local function adoptClose(instance)
	local v17 = screenOf(instance) -- equivalent call inferred; original call site unknown
	decorateClose(
		instance,
		(v6[assert(v17, (("close button %* needs a ScreenGui above it"):format(describe(instance)))).Name] or frozen).captionedClose == true
	)
	bind(instance, buttonB, nil, true)
end

local function eligible(data, p)
	if data.key ~= p then
		return false
	end

	local owner = data.owner
	local enabled

	if owner:IsA("ScreenGui") then
		enabled = owner.Enabled
	elseif owner:IsA("GuiObject") and not owner.Visible then
		enabled = false
	else
		local parent = owner.Parent

		if parent == nil then
			enabled = false
		else
			enabled = showing(parent)
		end
	end

	if not enabled then
		return false
	end

	local glyph = data.glyph

	if glyph ~= nil and not glyph.Visible then
		return false
	end

	return (v13 == nil or data.screen == v13) and (v14 == nil or data.owner:IsDescendantOf(v14))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function score(p)
	return rankOf(p.screen) * 2 + (p.closes and 0 or 1)
end

local function claimantFor(p)
	local v17 = -1e999
	local v18 = nil

	for k, v19 in v9 do
		if not eligible(v19, p) then
			continue
		end

		local v20 = score(v19) -- equivalent call inferred; original call site unknown

		if not (v17 < v20) then
			continue
		end

		v18 = k
		v17 = v20
	end

	return v18
end

local function selectionTakesA()
	local selectedObject = GuiService.SelectedObject
	local v17

	if selectedObject == nil then
		v17 = false
		return false
	end

	if selectedObject:IsA("ScreenGui") then
		return selectedObject.Enabled
	end

	if selectedObject:IsA("GuiObject") and not selectedObject.Visible then
		return false
	end

	local parent = selectedObject.Parent
	return parent ~= nil and showing(parent)
end

local function routes(p)
	if not v5[p] or not v16 or not PlatformController.IsConsole() or MenuNavigation.IsSuspended() then
		return false
	end

	if p ~= Enum.KeyCode.ButtonA then
		return true
	end

	local selectedObject = GuiService.SelectedObject
	local enabled

	if selectedObject == nil then
		enabled = false
	elseif selectedObject:IsA("ScreenGui") then
		enabled = selectedObject.Enabled
	elseif selectedObject:IsA("GuiObject") and not selectedObject.Visible then
		enabled = false
	else
		local parent = selectedObject.Parent

		if parent == nil then
			enabled = false
		else
			enabled = showing(parent)
		end
	end

	return not (enabled or MenuNavigation.IsCursorActive())
end

local function press(keyCode)
	if v12[keyCode] ~= nil then
		return true
	end

	if not routes(keyCode) then
		return false
	end

	local v17 = claimantFor(keyCode)

	if v17 == nil then
		local v18 = v8:AtDebug()
		local name = keyCode.Name
		local v20 = describe(v13) -- equivalent call inferred; original call site unknown
		v18:Log((("%*: no button answered (focus %*, selection %*)"):format(
			name,
			v20,
			describe(GuiService.SelectedObject)
		)))
		return false
	else
		v12[keyCode] = v17
		ConsoleSignals.ButtonDown:Fire(v17, keyCode)
		return true
	end
end

local function release(p, flag: boolean)
	local instance = v12[p]
	v12[p] = nil

	if instance == nil then
		return false
	end

	if not (flag and v5[p] and PlatformController.IsConsole() and instance.Active) then
		return true
	end

	local enabled

	if instance:IsA("ScreenGui") then
		enabled = instance.Enabled
	elseif instance:IsA("GuiObject") and not instance.Visible then
		enabled = false
	else
		local parent = instance.Parent

		if parent == nil then
			enabled = false
		else
			enabled = showing(parent)
		end
	end

	if enabled then
		ConsoleSignals.ButtonUp:Fire(instance, p)
	end

	return true
end

local function onRoutedKey(_: string, p, p2)
	local v17

	if p == Enum.UserInputState.Begin then
		v17 = press(p2.KeyCode)
	else
		local keyCode = p2.KeyCode
		local v18 = p ~= Enum.UserInputState.Cancel
		local instance = v12[keyCode]
		v12[keyCode] = nil

		if instance == nil then
			v17 = false
		else
			if v18 and v5[keyCode] and PlatformController.IsConsole() and instance.Active then
				local enabled

				if instance:IsA("ScreenGui") then
					enabled = instance.Enabled
				elseif instance:IsA("GuiObject") and not instance.Visible then
					enabled = false
				else
					local parent = instance.Parent

					if parent == nil then
						enabled = false
					else
						enabled = showing(parent)
					end
				end

				if enabled then
					ConsoleSignals.ButtonUp:Fire(instance, keyCode)
				end
			end

			v17 = true
		end
	end

	if v17 then
		return Enum.ContextActionResult.Sink
	end

	return Enum.ContextActionResult.Pass
end

local function repaint()
	for k in v10 do
		if k.Parent ~= nil then
			applyLook(k)
		end
	end

	for _, v17 in v9 do
		local glyph = v17.glyph

		if glyph ~= nil then
			paintGlyph(glyph, v17.key)
		end
	end
end

function GamepadBindings.GlyphFor(p)
	local v17

	if typeof(p) == "EnumItem" then
		v17 = p
	else
		v17 = v4[p]
	end

	if v17 == nil or not v5[v17] then
		error(`{tostring(p)} is not a key this router knows`, 3)
	end

	local v18 = v11[v17]

	if v18 ~= nil then
		return v18
	end

	local v19 = InputIconsConfig.Image(v17) or ""
	v11[v17] = v19
	return v19
end

function GamepadBindings.IsOnScreen(instance)
	if instance:IsA("ScreenGui") then
		return instance.Enabled
	end

	if instance:IsA("GuiObject") and not instance.Visible then
		return false
	end

	local parent = instance.Parent
	return parent ~= nil and showing(parent)
end

function GamepadBindings.TrackCloseButton(layerCollector)
	local layerCollector2

	if layerCollector:IsA("LayerCollector") then
		layerCollector2 = layerCollector
	else
		layerCollector2 = layerCollector:FindFirstAncestorWhichIsA("LayerCollector")
	end

	local v17

	if layerCollector2 == nil then
		v17 = false
	else
		v17 = (v6[layerCollector2.Name] or frozen).blocked == true
	end

	if not v17 then
		adoptClose(layerCollector)
	end
end

function GamepadBindings.Inspect(instance)
	local layerCollector

	if instance:IsA("LayerCollector") then
		layerCollector = instance
	else
		layerCollector = instance:FindFirstAncestorWhichIsA("LayerCollector")
	end

	local v17

	if layerCollector == nil then
		v17 = false
	else
		v17 = (v6[layerCollector.Name] or frozen).blocked == true
	end

	if v17 then
		return
	end

	if instance.Name == "GamepadGlyph" and instance:IsA("GuiObject") then
		adoptGlyph(instance)
	elseif instance.Name == "Close" and instance:IsA("GuiButton") then
		local v18 = screenOf(instance) -- equivalent call inferred; original call site unknown

		if v18 ~= nil then
			adoptClose(instance)
		end
	end
end

function GamepadBindings.FocusScreen(instance, p)
	assert(
		instance == nil or instance:IsDescendantOf(folder),
		"only a screen inside the local PlayerGui can take focus"
	)

	if v13 == instance and v14 == p then
		return
	end

	v13 = instance
	v14 = p
	table.clear(v12)
end

function GamepadBindings.EnableMarkers(flag: boolean)
	v16 = flag

	if not flag then
		table.clear(v12)
	end
end

function GamepadBindings.Rescan(p: string?)
	local v17

	if (p or PlatformController.Platform()) == "Console" then
		v17 = InputIconsConfig.Vendor()
	end

	v15 = v17
	table.clear(v11)

	for _, descendant in folder:GetDescendants() do
		GamepadBindings.Inspect(descendant)
	end

	repaint()
end

MenuNavigation.CursorChanged:Connect(function()
	table.clear(v12)
end)
PlatformController.Changed:Connect(function(p: string)
	table.clear(v12)
	GamepadBindings.Rescan(p)
end)
InputIconsConfig.Changed:Connect(function()
	GamepadBindings.Rescan()
end)
local v17 = {}

for _, v18 in v do
	if not v2[v18] then
		table.insert(v17, v18)
	end
end

ContextActionService:BindActionAtPriority(
	"GamepadGlyphRouting",
	onRoutedKey,
	false,
	Enum.ContextActionPriority.High.Value,
	table.unpack(v17)
)
UserInputService.InputBegan:Connect(function(input)
	if v13 ~= nil and v3[input.KeyCode] then
		press(input.KeyCode)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if v13 ~= nil and v3[input.KeyCode] then
		local keyCode = input.KeyCode
		local instance = v12[keyCode]
		v12[keyCode] = nil

		if instance == nil then
			return
		end

		if v5[keyCode] and PlatformController.IsConsole() and instance.Active then
			local enabled

			if instance:IsA("ScreenGui") then
				enabled = instance.Enabled
			elseif instance:IsA("GuiObject") and not instance.Visible then
				enabled = false
			else
				local parent = instance.Parent

				if parent == nil then
					enabled = false
				else
					enabled = showing(parent)
				end
			end

			if enabled then
				ConsoleSignals.ButtonUp:Fire(instance, keyCode)
			end
		end
	end
end)
v8:AtInfo():Log("gamepad routing online")
return GamepadBindings