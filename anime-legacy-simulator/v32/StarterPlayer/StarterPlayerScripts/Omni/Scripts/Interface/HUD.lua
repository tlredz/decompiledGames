local module = require("@game/ReplicatedStorage/Omni")
local color = Color3.fromRGB(255, 8, 204)
local color2 = Color3.fromRGB(255, 0, 4)
local color3 = Color3.fromRGB(255, 255, 0)
local color4 = Color3.fromRGB(21, 255, 0)
local fusion = module.Libs.Fusion
local HUD = module.Interface:WaitForChild("HUD")
local left = HUD:WaitForChild("Left")
local bottom = HUD:WaitForChild("Bottom")
local bottomLeftButtons = HUD:WaitForChild("BottomLeftButtons")
local buttons = left:WaitForChild("Buttons")
local currencies = left:WaitForChild("Currencies")
local level = bottom:WaitForChild("Level")
local buttons2 = bottom:WaitForChild("Buttons")
local scope = fusion.scoped(fusion)
local v = nil
local value = scope:Value(0)
local spring = scope:Spring(value, 10, 1)
local value2 = scope:Value(0)
local spring2 = scope:Spring(value2, 10, 1)
local value3 = scope:Value(0)
local spring3 = scope:Spring(value3, 10, 1)
local HUD2 = {}

local function SetupTopBar()
	local topBarPluses = {}
	local topBarPlus = module.Libs.TopBarPlus.new()
	topBarPlus:setName("Menu")
	topBarPlus:setLabel("Menu")
	topBarPlus:align("Left")
	local topBarPlus2 = module.Libs.TopBarPlus.new()
	topBarPlus2:setName("Settings")
	topBarPlus2:setLabel("Settings")
	topBarPlus2:setImage("rbxassetid://136371292922830")
	topBarPlus2:oneClick(true)
	topBarPlus2:bindEvent("deselected", function()
		topBarPlus:deselect()
		module.Frame:Toggle("Settings")
	end)
	table.insert(topBarPluses, topBarPlus2)
	local topBarPlus3 = module.Libs.TopBarPlus.new()
	topBarPlus3:setName("Inbox")
	topBarPlus3:setLabel("Inbox")
	topBarPlus3:setImage("rbxassetid://86938177535806")
	topBarPlus3:oneClick(true)
	topBarPlus3:bindEvent("deselected", function()
		topBarPlus:deselect()
		module.Frame:Toggle("Inbox")
	end)
	table.insert(topBarPluses, topBarPlus3)
	local topBarPlus4 = module.Libs.TopBarPlus.new()
	topBarPlus4:setName("Trade")
	topBarPlus4:setLabel("Trade")
	topBarPlus4:setImage("rbxassetid://82066814675025")
	topBarPlus4:oneClick(true)
	topBarPlus4:bindEvent("deselected", function()
		topBarPlus:deselect()
		module.Frame:Toggle("Trade")
	end)
	table.insert(topBarPluses, topBarPlus4)
	local topBarPlus5 = module.Libs.TopBarPlus.new()
	topBarPlus5:setName("Guilds")
	topBarPlus5:setLabel("Guilds")
	topBarPlus5:setImage("rbxassetid://89187327245839")
	topBarPlus5:oneClick(true)
	topBarPlus5:bindEvent("deselected", function()
		topBarPlus:deselect()
		module.Frame:Toggle("Guilds")
	end)
	table.insert(topBarPluses, topBarPlus5)
	local topBarPlus6 = module.Libs.TopBarPlus.new()
	topBarPlus6:setName("DropsHistory")
	topBarPlus6:setLabel("Drops")
	topBarPlus6:setImage("rbxassetid://115931044599379")
	topBarPlus6:oneClick(true)
	topBarPlus6:bindEvent("deselected", function()
		topBarPlus:deselect()
		module.Frame:Toggle("DropsHistory")
	end)
	table.insert(topBarPluses, topBarPlus6)
	topBarPlus:modifyTheme({ "Dropdown", "MaxIcons", 4 })
	topBarPlus:setDropdown(topBarPluses)
	local MenuNotices = require(script.MenuNotices)
	MenuNotices.Bind(topBarPlus, {
		Inbox = topBarPlus3,
		Guilds = topBarPlus5,
		Trade = topBarPlus4
	})
end

local function SetupLevelBar()
	scope:Observer(spring):onBind(function()
		local currentSpring = scope.peek(spring)

		if not currentSpring then
			return
		end

		if currentSpring == 1 then
			level.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0)
			})
			return
		elseif currentSpring == 0 then
			level.Bar.Slider.UIGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
			return
		end

		local numberSequenceKeypoints = {}
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(0, 0))
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(currentSpring, 0))
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(math.min(1, currentSpring + 0.1), 1))
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(1, 1))
		level.Bar.Slider.UIGradient.Transparency = NumberSequence.new(numberSequenceKeypoints)
	end)
	module:OnDataChangedDeferred({ "Level" }, HUD2.RefreshLevel)
	HUD2.RefreshLevel()
end

local function SetupCurrencies()
	for _, frame in currencies:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local name = frame.Name
		local text = scope:Value("")
		local value5 = scope:Value(0)
		local spring4 = scope:Spring(value5, 10, 1)
		scope:Observer(spring4):onBind(function()
			local currentSpring = scope.peek(spring4)

			if not currentSpring then
				return
			end

			text:set(module.Utils.Number:Format(module.Utils.Number:Round(currentSpring)))
		end)
		scope:Hydrate(frame.Amount)({
			Text = text
		})

		if name == "Power" then
			value5:set(module.Data.Profile.Stats["Total Power"] or 0)
			local v4 = value5
			module:OnDataChanged({ "Profile", "Stats", "Total Power" }, function(value6)
				if typeof(value6) ~= "number" then
					return
				end

				v4:set(value6)
			end)
		else
			value5:set(module.Data[name] or 0)
			local v4 = value5
			module:OnDataChanged({ name }, function(value6)
				if typeof(value6) ~= "number" then
					return
				end

				v4:set(value6)
			end)
		end
	end
end

local function SetupLeftButtons()
	for _, frame in buttons:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v2 = frame
		module.Button:Create(frame.Main, "HUD"):BindFunction("Click", function()
			module.Frame:Open(v2.Name)
		end)
	end

	for _, frame in bottomLeftButtons:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local v2 = frame
		module.Button:Create(frame.Main, "HUD"):BindFunction("Click", function()
			module.Frame:Open(v2.Name)
		end)
	end
end

local function SetupBottomButtons()
	module.Button:Create(buttons2.AutoAttack.Main, "HUD"):BindFunction("Click", function()
		local autoAttack = module.Data.Settings["Auto Attack"] == true
		module.Signal:Fire("General", "Settings", "Set", "Auto Attack", not autoAttack)
	end)
	module.Button:Create(buttons2.AutoClicker.Main, "HUD"):BindFunction("Click", function()
		local autoClicker = module.Data.Settings["Auto Clicker"] == true
		module.Signal:Fire("General", "Settings", "Set", "Auto Clicker", not autoClicker)
	end)
	scope:Observer(spring2):onBind(function()
		local currentSpring = scope.peek(spring2)

		if not currentSpring then
			return
		end

		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color:Lerp(color3, currentSpring)),
			ColorSequenceKeypoint.new(1, color2:Lerp(color4, currentSpring))
		})
		buttons2.AutoAttack.Main.Point.UIGradient.Color = colorSequence
	end)
	scope:Observer(spring3):onBind(function()
		local currentSpring = scope.peek(spring3)

		if not currentSpring then
			return
		end

		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color:Lerp(color3, currentSpring)),
			ColorSequenceKeypoint.new(1, color2:Lerp(color4, currentSpring))
		})
		buttons2.AutoClicker.Main.Point.UIGradient.Color = colorSequence
	end)
	module:OnDataChanged({ "Settings" }, HUD2.RefreshBottomButtons)
	HUD2.RefreshBottomButtons()
end

function HUD2.UseSkill()
	local Skill = require(script.Skill)
	Skill.Use()
end

function HUD2.RefreshLevel()
	local exp = module.Data.Level.Exp
	local amount = module.Data.Level.Amount

	if v and v < amount then
		module.Sound:PlayEffect("Others.LevelUp", {
			Cooldown = 0.15,
			MaxVoices = 1
		})
		module.Scripts.Rendering.LevelUp.Play()
	end

	v = amount
	local maxLevel = module.Shared.PlayerLevel.GetMaxLevel(module.Data)
	local expForNextLevel = module.Shared.PlayerLevel.GetExpForNextLevel(amount + 1)
	level.Level.Text = "Lv. " .. amount

	if maxLevel <= amount then
		level.Exp.Text = "(MAXED)"
		value:set(1)
	else
		level.Exp.Text = `({module.Utils.Number:Format(exp)}/{module.Utils.Number:Format(expForNextLevel)} EXP)`
		value:set(exp / expForNextLevel)
	end
end

function HUD2.RefreshBottomButtons()
	local autoAttack = module.Data.Settings["Auto Attack"] == true
	local autoClicker = module.Data.Settings["Auto Clicker"] == true
	value2:set(autoAttack and 1 or 0)
	value3:set(autoClicker and 1 or 0)
end

function HUD2.Init()
	SetupTopBar()
	SetupLevelBar()
	SetupCurrencies()
	SetupLeftButtons()
	SetupBottomButtons()

	for _, moduleScript in script:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local v2 = moduleScript
		task.spawn(function()
			local module2 = require(v2)

			if not module2 then
				return
			end

			if module2.Init then
				module2.Init()
			end
		end)
	end
end

return HUD2