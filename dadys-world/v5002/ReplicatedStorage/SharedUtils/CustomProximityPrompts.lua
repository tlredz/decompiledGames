local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.SharedUtils.Maid)
local KeyCodeNames = require(ReplicatedStorage.SharedUtils.KeyCodeNames)
local DefaultWidget = require(script.DefaultWidget)
local v = {
	"container",
	"background",
	"inputFrame",
	"keyBackground",
	"buttonImage",
	"buttonText",
	"actionText",
	"objectText",
	"holdRing",
	"holdFill"
}
local CustomProximityPrompts = {}
local flag = false
local styles = nil
local playerGui = nil
local v2 = {}
local v3 = {}
local object = setmetatable({}, {
	__mode = "k"
})
local v4 = {}

local function resolveStyle(styleKey)
	local v5 = v2[styleKey]

	if v5 ~= nil then
		return v5 or nil
	end

	local moduleScript = styles and styles:FindFirstChild(styleKey)

	if moduleScript and moduleScript:IsA("ModuleScript") then
		local success, result = pcall(require, moduleScript)

		if success and type(result) == "table" then
			v2[styleKey] = result
			return result
		end

		v2[styleKey] = false

		if not v3[styleKey] then
			v3[styleKey] = true
			warn(string.format(
				"%s style module %q failed to load: %s",
				"[CustomProximityPrompts]",
				styleKey,
				(tostring(result))
			))
		end

		return nil
	else
		v2[styleKey] = false

		if not v3[styleKey] then
			v3[styleKey] = true
			warn(string.format(
				"%s no style module named %q under Styles — prompt left undrawn",
				"[CustomProximityPrompts]",
				styleKey
			))
		end

		return nil
	end
end

local function callHook(data, p, ...)
	local v5 = data.style[p]

	if type(v5) ~= "function" then
		return false
	end

	local success, result = pcall(v5, data.context, ...)

	if not success then
		warn(string.format(
			"%s style %q hook %s errored: %s",
			"[CustomProximityPrompts]",
			data.styleKey,
			p,
			(tostring(result))
		))
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function deviceFor(p)
	if p == Enum.ProximityPromptInputType.Gamepad then
		return "Gamepad"
	end

	if p == Enum.ProximityPromptInputType.Touch then
		return "Touch"
	end

	return "Keyboard"
end

local function buildTemplateWidget(style, instance)
	local result = style.template

	if type(result) == "function" then
		local success
		success, result = pcall(result, instance)

		if not success then
			warn(string.format("%s template function errored: %s", "[CustomProximityPrompts]", (tostring(result))))
			return nil
		end
	end

	if typeof(result) ~= "Instance" or not result:IsA("BillboardGui") then
		warn(string.format(
			"%s template must be a BillboardGui (got %s) — falling back to the default widget",
			"[CustomProximityPrompts]",
			typeof(result) == "Instance" and result.ClassName or typeof(result)
		))
		return nil
	end

	local clone = result:Clone()
	local partNames = style.partNames
	local result2 = {}

	for _, v5 in ipairs(v) do
		result2[v5] = clone:FindFirstChild(partNames and partNames[v5] or v5:sub(1, 1):upper() .. v5:sub(2), true)
	end

	local holdRing = result2.holdRing

	if not holdRing then
		return clone, result2
	end

	local rightHalf = holdRing:FindFirstChild("RightHalf")
	local leftHalf = holdRing:FindFirstChild("LeftHalf")
	local fill = rightHalf and rightHalf:FindFirstChild("Fill")
	local fill2 = leftHalf and leftHalf:FindFirstChild("Fill")
	result2._rightGradient = fill and fill:FindFirstChildOfClass("UIGradient")
	result2._leftGradient = fill2 and fill2:FindFirstChildOfClass("UIGradient")
	return clone, result2
end

local function refreshInput(data)
	local parts = data.parts
	local prompt = data.prompt
	local imageForKeyCode = ""
	local text = ""

	if data.device == "Gamepad" then
		imageForKeyCode = UserInputService:GetImageForKeyCode(prompt.GamepadKeyCode)
	elseif data.device == "Touch" then
		imageForKeyCode = data.style.touchImage or "rbxassetid://109374558641787"
	elseif data.style.keyboardImage then
		imageForKeyCode = data.style.keyboardImage
	else
		text = KeyCodeNames.toDisplay(prompt.KeyboardKeyCode) or ""
		local formatKeyText = data.style.formatKeyText

		if text ~= "" and type(formatKeyText) == "function" then
			local success, result = pcall(formatKeyText, text)

			if success then
				if type(result) == "string" then
					text = result
				end
			else
				warn(string.format(
					"%s style %q hook formatKeyText errored: %s",
					"[CustomProximityPrompts]",
					data.styleKey,
					(tostring(result))
				))
			end
		end
	end

	if parts.buttonImage then
		parts.buttonImage.Image = imageForKeyCode
		parts.buttonImage.Visible = imageForKeyCode ~= ""
	end

	if parts.buttonText then
		parts.buttonText.Text = text
		parts.buttonText.Visible = text ~= ""
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshText(data)
	local parts = data.parts
	local prompt = data.prompt

	if parts.actionText then
		parts.actionText.Text = prompt.ActionText
	end

	if parts.objectText then
		parts.objectText.Text = prompt.ObjectText
	end

	if not data.isTemplate then
		DefaultWidget.resize(data.gui, parts, prompt)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function paintProgress(p, p2)
	if callHook(p, "onHoldProgress", p2) then
		return
	end

	DefaultWidget.setProgress(p.parts, p2)
end

local function beginHold(state)
	state.holding = true
	callHook(state, "onHoldBegan")
	local holdDuration = state.prompt.HoldDuration

	if holdDuration <= 0 then
		paintProgress(state, 1) -- equivalent call inferred; original call site unknown
	else
		local lastTime = os.clock()
		state.maid.HoldLoop = RunService.RenderStepped:Connect(function()
			if not state.holding then
				return
			end

			local v5 = math.clamp((os.clock() - lastTime) / holdDuration, 0, 1)
			paintProgress(state, v5) -- equivalent call inferred; original call site unknown

			if v5 >= 1 then
				state.maid.HoldLoop = nil
			end
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function endHold(state)
	if not state.holding then
		return
	end

	state.holding = false
	state.maid.HoldLoop = nil
	paintProgress(state, 0) -- equivalent call inferred; original call site unknown
	callHook(state, "onHoldEnded")
end

local function hide(instance)
	local v5 = v4[instance]

	if not v5 then
		return
	end

	v4[instance] = nil
	v5.holding = false
	callHook(v5, "onHidden")
	callHook(v5, "destroy")
	v5.maid:Destroy()
end

local show

show = function(instance, inputType)
	if instance.Style ~= Enum.ProximityPromptStyle.Custom then
		return
	end

	local styleKey = instance:GetAttribute("StyleKey")

	if styleKey == nil then
		return
	end

	if type(styleKey) == "string" and styleKey ~= "" then
		local style = resolveStyle(styleKey)

		if not style then
			return
		end

		if v4[instance] then
			hide(instance)
		end

		local parent = instance.Parent

		if not (parent and (parent:IsA("BasePart") or parent:IsA("Attachment"))) then
			warn(string.format(
				"%s %s is not parented to a BasePart or Attachment — cannot adorn",
				"[CustomProximityPrompts]",
				instance:GetFullName()
			))
			return
		end

		local gui, parts, isTemplate

		if style.template == nil then
			parts = nil
			isTemplate = false
		else
			gui, parts = buildTemplateWidget(style, instance)

			if gui == nil then
				isTemplate = false
			else
				isTemplate = true
			end
		end

		if not gui then
			gui, parts = DefaultWidget.build(instance)
		end

		local maid = Maid.new()
		maid:GiveTask(gui)
		local v8 = {
			prompt = instance,
			styleKey = styleKey,
			style = style,
			inputType = inputType,
			device = deviceFor(inputType),
			gui = gui,
			parts = parts,
			isTemplate = isTemplate,
			maid = maid,
			holding = false
		}
		local context = {
			prompt = instance,
			styleKey = styleKey,
			inputType = inputType,
			device = v8.device,
			gui = gui,
			parts = parts,
			isTemplate = isTemplate,
			maid = maid,
			setProgress = function(p2)
				DefaultWidget.setProgress(parts, p2)
			end
		}

		for _, v10 in ipairs(v) do
			context[v10] = parts[v10]
		end

		v8.context = context
		v4[instance] = v8

		if instance.ClickablePrompt then
			gui.Active = true
			local textButton = Instance.new("TextButton")
			textButton.Name = "ClickTarget"
			textButton.Size = UDim2.fromScale(1, 1)
			textButton.BackgroundTransparency = 1
			textButton.Text = ""
			textButton.ZIndex = 10
			textButton.Modal = v8.device == "Touch"
			textButton.Parent = parts.container or gui
			maid:GiveTask(textButton.MouseButton1Down:Connect(function()
				instance:InputHoldBegin()
			end))
			maid:GiveTask(textButton.MouseButton1Up:Connect(function()
				instance:InputHoldEnd()
			end))
			maid:GiveTask(textButton.MouseLeave:Connect(function()
				instance:InputHoldEnd()
			end))
			parts.clickButton = textButton
			context.clickButton = textButton
		end

		refreshInput(v8)
		paintProgress(v8, 0) -- equivalent call inferred; original call site unknown
		callHook(v8, "apply")
		gui.Adornee = parent
		gui.Parent = playerGui
		callHook(v8, "onShown")
		maid:GiveTask(instance.PromptHidden:Connect(function()
			hide(instance)
		end))
		maid:GiveTask(instance.PromptButtonHoldBegan:Connect(function()
			beginHold(v8)
		end))
		maid:GiveTask(instance.PromptButtonHoldEnded:Connect(function()
			endHold(v8) -- equivalent call inferred; original call site unknown
		end))
		maid:GiveTask(instance.Triggered:Connect(function()
			v8.holding = false
			maid.HoldLoop = nil
			callHook(v8, "onTriggered")
		end))
		maid:GiveTask(instance.TriggerEnded:Connect(function()
			callHook(v8, "onTriggerEnded")
			paintProgress(v8, 0) -- equivalent call inferred; original call site unknown
		end))
		maid:GiveTask(instance.Destroying:Connect(function()
			hide(instance)
		end))
		maid:GiveTask(instance:GetPropertyChangedSignal("KeyboardKeyCode"):Connect(function()
			refreshInput(v8)
		end))
		maid:GiveTask(instance:GetPropertyChangedSignal("GamepadKeyCode"):Connect(function()
			refreshInput(v8)
		end))
		maid:GiveTask(instance:GetPropertyChangedSignal("ActionText"):Connect(function()
			refreshText(v8) -- equivalent call inferred; original call site unknown
		end))
		maid:GiveTask(instance:GetPropertyChangedSignal("ObjectText"):Connect(function()
			refreshText(v8) -- equivalent call inferred; original call site unknown
		end))
		maid:GiveTask(UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
			local preferredInput = UserInputService.PreferredInput
			v8.device = preferredInput == Enum.PreferredInput.Gamepad and "Gamepad" or preferredInput == Enum.PreferredInput.Touch and "Touch" or "Keyboard"
			context.device = v8.device
			refreshInput(v8)
		end))
		maid:GiveTask(instance:GetAttributeChangedSignal("StyleKey"):Connect(function()
			task.defer(function()
				if v4[instance] ~= v8 then
					return
				end

				hide(instance)
				show(instance, inputType)
			end)
		end))
	elseif not object[instance] then
		object[instance] = true
		warn(string.format(
			"%s %s has a non-string %s (%s) — expected a style module name",
			"[CustomProximityPrompts]",
			instance:GetFullName(),
			"StyleKey",
			(typeof(styleKey))
		))
	end
end

function CustomProximityPrompts.setup()
	if flag then
		return
	end

	if not RunService:IsClient() then
		warn("[CustomProximityPrompts] setup() is client-only — ignoring server call")
		return
	end

	flag = true
	playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	styles = script:FindFirstChild("Styles")

	if not styles then
		warn("[CustomProximityPrompts] no Styles folder — every Custom prompt will be left undrawn")
	end

	ProximityPromptService.PromptShown:Connect(show)
end

return CustomProximityPrompts