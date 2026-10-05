game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ContentProvider = game:GetService("ContentProvider")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Signal = require(packages.Signal)
local Trove = require(packages.Trove)
local modules = ReplicatedStorage.shared.modules
local Hook = require(modules.Hook)
local fish = require(modules.library.fish)
local utils = ReplicatedStorage.shared.utils
require(utils.GeneralUtils)
require(utils.NumberUtils)
require(utils.FischUtils)
local LocalPassive = require(ReplicatedStorage.shared.modules.LocalPassive)
local CustomTweens = require(ReplicatedStorage.shared.modules.CustomTweens)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local HudController = require(legacyControllers.HudController)
local WindowController = require(legacyControllers.WindowController)
local module = require("@self/HarpoonButton")
require("@self/Types")
local module2 = require("@self/ReelFX")
local customharpoons = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing"):WaitForChild("customharpoons")
local HarpoonMinigameController = {
	type = "harpoon",
	Aborted = {}
}
local source = LocalPassive:GetSource("FishBehavior")
local source2 = LocalPassive:GetSource("ServerInjected")

function HarpoonMinigameController.new(instance, p)
	local object = setmetatable(p, {
		__index = HarpoonMinigameController
	})
	object.fx = setmetatable({
		current = object
	}, module2)
	object.trove = Trove.new()
	object._active_modifiers = {}
	object.logicTweens = object.trove:Add(CustomTweens.new())
	object.renderTweens = object.trove:Add(CustomTweens.new())
	object._preload_tasks = 0
	object._awaiting_preload = false
	object.progspeed_format = instance:GetAttribute("progspeed_format") or "%+.0f%% Progress Speed"
	object.trueprogspeed_format = instance:GetAttribute("trueprogspeed_format") or "%+.0f%% True Progress Speed"
	object.cleanup_delay = 1.25
	object._progressVelocity = 0
	object.ui = instance
	object.ui_progress = instance.progress
	object.ui_safezone = instance.safezone
	object.ui_buttonTemplates = instance.safezone.buttonTemplates
	object.ui_thumbstick = instance.safezone.thumbstick
	object.reel = instance
	object.reel_progress = instance.progress
	object.ui_progspeed = instance.progress.statlist.progressspeed
	object.ui_trueprogspeed = instance.progress.statlist.trueprogressspeed
	object.ui_trueprogspeed_pos = object.ui_trueprogspeed:FindFirstChild("positiveGradient", true)
	object.ui_trueprogspeed_neg = object.ui_trueprogspeed:FindFirstChild("negativeGradient", true)
	object.activeButtons = {}
	object.activeBars = {}
	object._buttonCount = 0
	object:AddModifier("progressLossMultiplier", "add", 1)
	object:AddModifier("movementfactor", "add", 1)

	if fish[object.fish.Name].ForcedProgressEfficiency then
		object:AddModifier("progressefficiency", "force", 1)
	end

	object:AddModifier("trueprogressefficiency", "add", object.stats.TrueProgressSpeed / 100 + 1)
	object:AddModifier("progressefficiency", "add", object.stats.ProgressSpeed / 100 + 1)
	object:AddModifier("progressefficiency", "force_add", object.stats.ForcedProgressSpeed / 100)
	object:AddModifier("resilience", "add", object.stats.Resilience)
	object:AddModifier("buttonLifetime", "add", 1 + object.stats.Velocity / 100)
	object:AddModifier("buttonSize", "add", 0.15 + object.stats.Accuracy / 100 * 0.15)
	object:AddModifier("power", "add", object.stats.Power)
	object:AddModifier("progress", "add", object.stats.StartingProgress)
	object.trueprogressefficiency = object.stats.TrueProgressSpeed / 100 + 1
	object._trueProgressModifier = object:CreateModifier("progress", "force_multiply")
	object._trueProgressModifier.Value = object.trueprogressefficiency
	object.OnLoad = object.trove:Add(Signal.new())
	object.OnReady = object.trove:Add(Signal.new())
	object.OnFishMove = object.trove:Add(Signal.new())
	object.PreMinigameEnd = object.trove:Add(Signal.new())
	object.OnMinigameEnd = object.trove:Add(Signal.new())
	object.OnButtonAdded = object.trove:Add(Signal.new())
	object.OnButtonClick = object.trove:Add(Signal.new())
	object.OnButtonMissed = object.trove:Add(Signal.new())
	object.OnButtonRemoving = object.trove:Add(Signal.new())
	object.OnSlash = object.trove:Add(Signal.new())
	object.Destroying = Signal.new()
	object.OnRenderStep = object.trove:Add(Signal.new())
	object.OnLogicStep = object.trove:Add(Signal.new())
	object.BuildEndingData = object.trove:Add(Hook.new(function()
		return {}
	end))
	object.lastInputWasMiss = true
	object.ActivePassives = {}
	object.trove:AttachToInstance(instance)
	local module3 = require("@self/Core")
	object.core = {
		gamepadInput = module3.gamepadInput.new(object),
		mouseTouchInput = module3.mouseTouchInput.new(object),
		pullButtons = module3.pullButtons.new(object),
		ui = module3.ui.new(object),
		genericDataHandlers = module3.genericDataHandlers.new(object)
	}
	object.trove:Add(Net:RemoteEvent("HarpoonMinigame/Abort").OnClientEvent:Once(function(p2)
		HarpoonMinigameController.Aborted[p2] = true

		if object.base_seed ~= p2 then
			return
		end

		if not object.loaded and object.OnLoad then
			object.OnLoad:Wait()
		end

		object:Destroy()

		if localPlayer.Character then
			localPlayer.Character:SetAttribute("HarpoonMinigameActive", nil)
		end

		local hud = HudController:GetHud()
		local backpackGui = HudController:GetBackpackGui()

		if hud then
			hud.Enabled = true
			local deviceInsetGui = HudController:GetDeviceInsetGui()

			if deviceInsetGui then
				deviceInsetGui.Enabled = true
			end
		end

		if backpackGui then
			backpackGui.Enabled = true
		end
	end))

	local function updateSafezoneData()
		if not (object.ui_safezone and object.ui_safezone.Parent) then
			return
		end

		local absolutePosition = object.ui_safezone.AbsolutePosition
		local absoluteSize = object.ui_safezone.AbsoluteSize
		object.safezone_topLeft = absolutePosition
		object.safezone_bottomRight = absolutePosition + absoluteSize
		object.safezone_absSize = absoluteSize
	end

	object.trove:Add(object.ui_safezone:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateSafezoneData))
	object.trove:Add(object.ui_safezone:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSafezoneData))

	if not (object.ui_safezone and object.ui_safezone.Parent) then
		return object
	end

	local absolutePosition = object.ui_safezone.AbsolutePosition
	local absoluteSize = object.ui_safezone.AbsoluteSize
	object.safezone_topLeft = absolutePosition
	object.safezone_bottomRight = absolutePosition + absoluteSize
	object.safezone_absSize = absoluteSize
	return object
end

function HarpoonMinigameController.StartMinigame(data)
	local lastTime = tick()

	while HarpoonMinigameController.ActiveMinigame and tick() - lastTime < (HarpoonMinigameController.ActiveMinigame.cleanup_delay or 10) do
		task.wait()
	end

	if HarpoonMinigameController.ActiveMinigame then
		task.spawn(HarpoonMinigameController.ActiveMinigame.Destroy, HarpoonMinigameController.ActiveMinigame)
		task.wait()
	end

	local v = fish[data.fish.Name]

	if v then
		source:SetActivePassives(v.ClientFishingPassives or {}, true)
	end

	source2:SetActivePassives(data.data.InjectedPassives or {}, true)
	local clone = (customharpoons:FindFirstChild(data.gui_name or "default") or customharpoons:FindFirstChild("default")):Clone()
	clone:SetAttribute("MinigameStyle", clone.Name)
	clone.Name = "harpoonMinigame"
	clone.Enabled = false
	clone.progress.bar.Size = UDim2.fromScale(0, 1)
	clone.Parent = localPlayer.PlayerGui
	local v2 = HarpoonMinigameController.new(clone, {
		fish = data.fish,
		stats = data.stats,
		loaded = false,
		active = false,
		isPaused = false,
		logicPaused = false,
		perfect = true,
		progress = 20,
		progressefficiency = 1,
		trueprogressefficiency = 1,
		ready = false,
		resilience = 0,
		harpoonName = data.harpoon,
		harpoonSkin = data.skin,
		start = tick(),
		base_seed = data.seed,
		data = data.data,
		gui_name = data.gui_name or "default",
		buttonSize = 0.15,
		fishPos = data.fishPos
	})

	if HarpoonMinigameController.Aborted[v2.base_seed] then
		v2:Destroy()
		clone:Destroy()
		return v2
	else
		HarpoonMinigameController.ActiveMinigame = v2
		local character = localPlayer.Character

		if character then
			character:SetAttribute("HarpoonMinigameActive", 0)
			local tool = character:FindFirstChildWhichIsA("Tool")

			if tool and tool.Name == v2.harpoonName then
				v2.harpoon = tool
			end
		end

		WindowController:CloseActiveWindow()
		clone.Enabled = true
		v2.trove:Add(clone)
		v2:TickLogic(0)
		v2:TickRender(0)

		if data.preload_callback then
			data.preload_callback(v2)
		end

		for _, v3 in LocalPassive:GetActivePassives({
			"FishingRod",
			"Enchantment",
			"SecondaryEnchantment",
			"KeeperAffix1",
			"KeeperAffix2",
			"KeeperAffix3",
			"Masterline1",
			"Masterline2",
			"Masterline3",
			"Spear",
			"Spear_Enchantment",
			"Spear_SecondaryEnchantment"
		}, data.data.OnlyPassiveSources) do
			if not v3.MorphHarpoon then
				continue
			end

			if typeof(v3.MorphHarpoon) == "function" then
				v3:MorphHarpoon(v2.ui, v2)
			elseif typeof(v3.Morph) == "function" then
				v3:Morph(v2.ui, v2)
			end

			v3.harpoon_current = v2
			v3.harpoon_ui = v2.ui
			table.insert(v2.ActivePassives, v3)
			v2.trove:Add(v3, "Cleanup")
		end

		if data.precore_callback then
			data.precore_callback(v2)
		end

		for _, v3 in v2.core do
			if v3.Disabled then
				continue
			end

			v3:Start()
			v2.trove:Add(v3, "Stop")
		end

		v2:TickLogic(0)
		v2:TickRender(0)
		local minigameSpeedMulti = localPlayer:GetAttribute("MinigameSpeedMulti") or 1
		v2.trove:Add(localPlayer:GetAttributeChangedSignal("MinigameSpeedMulti"):Connect(function()
			minigameSpeedMulti = localPlayer:GetAttribute("MinigameSpeedMulti") or 1
		end))
		v2.trove:Add(RunService.Heartbeat:Connect(function(dt: number)
			if not clone.Parent then
				v2:Destroy()
				return
			end

			if v2.isPaused or v2.logicPaused then
				return
			end

			local v3 = dt * minigameSpeedMulti

			if v2.active then
				for _, v4 in v2.core do
					if not v4.Disabled then
						v4:TickLogic(v3)
					end
				end

				for _, activeButton in v2.activeButtons do
					activeButton:TickLogic(v3)
				end
			end

			v2.logicTweens:StepAll(v3)

			if v2.active then
				for _, activePassive in v2.ActivePassives do
					if typeof(activePassive.TickLogic_Harpoon) == "function" then
						activePassive:TickLogic_Harpoon(v2, v3)
					elseif typeof(activePassive.TickLogic) == "function" then
						activePassive:TickLogic(v2, v3)
					end
				end
			end

			v2.OnLogicStep:Fire(v3)
			v2:TickLogic(v3)
		end))
		v2.trove:Add(RunService.PreRender:Connect(function(dt: number)
			if not clone.Parent then
				v2:Destroy()
				return
			end

			local v3 = dt * minigameSpeedMulti

			for _, v4 in v2.core do
				if not v4.Disabled then
					v4:TickRender(v3)
				end
			end

			for _, activeButton in v2.activeButtons do
				activeButton:TickRender(v3)
			end

			v2.renderTweens:StepAll(v3)

			for _, activePassive in v2.ActivePassives do
				if typeof(activePassive.TickRender_Harpoon) == "function" then
					activePassive:TickRender_Harpoon(v2, v3)
				elseif typeof(activePassive.TickRender) == "function" then
					activePassive:TickRender(v2, v3)
				end
			end

			v2.OnRenderStep:Fire(v3)
			v2:TickRender(v3)
		end))
		local hud = HudController:GetHud()

		if hud then
			hud.Enabled = false
			local deviceInsetGui = HudController:GetDeviceInsetGui()

			if deviceInsetGui then
				deviceInsetGui.Enabled = false
			end
		end

		local backpackGui = HudController:GetBackpackGui()

		if backpackGui then
			backpackGui.Enabled = false
		end

		v2.loaded = true
		v2.OnLoad:FireDeferred()
		v2.trove:Add(task.spawn(function()
			local character2 = localPlayer.Character

			if not character2 then
				return
			end

			task.wait(1)

			if not character2:GetAttribute("HarpoonMinigame") then
				character2:GetAttributeChangedSignal("HarpoonMinigame"):Wait()
			end

			if v2._preload_tasks > 0 then
				v2._awaiting_preload = true
				return
			end

			v2.active = true
			v2.ready = true
			v2.OnReady:Fire()
		end))
		return v2
	end
end

local function getValue(instance)
	if typeof(instance) == "Instance" then
		return instance.Value
	end

	return instance
end

function HarpoonMinigameController:TickLogic(_: number)
	self._trueProgressModifier.Value = math.max(self.trueprogressefficiency, 0)

	for k, _active_modifier in self._active_modifiers do
		local value = 0
		local v

		if _active_modifier.force_final == nil then
			v = false
		else
			v = #_active_modifier.force_final > 0
		end

		if not v then
			local v2

			if _active_modifier.force == nil then
				v2 = false
			else
				v2 = #_active_modifier.force > 0
			end

			if not v2 then
				if _active_modifier.add then
					for _, value2 in _active_modifier.add do
						if typeof(value2) == "Instance" then
							value2 = value2.Value
						end

						value += value2
					end
				end

				if _active_modifier.multiply then
					for _, value2 in _active_modifier.multiply do
						if typeof(value2) == "Instance" then
							value2 = value2.Value
						end

						value *= value2
					end
				end
			end

			if _active_modifier.force then
				for _, v3 in _active_modifier.force do
					if typeof(v3) == "Instance" then
						value = v3.Value
					else
						value = v3
					end
				end
			end

			if _active_modifier.force_add then
				for _, value2 in _active_modifier.force_add do
					if typeof(value2) == "Instance" then
						value2 = value2.Value
					end

					value += value2
				end
			end

			if _active_modifier.force_multiply then
				for _, value2 in _active_modifier.force_multiply do
					if typeof(value2) == "Instance" then
						value2 = value2.Value
					end

					value *= value2
				end
			end
		end

		if _active_modifier.force_final then
			for _, v2 in _active_modifier.force_final do
				if typeof(v2) == "Instance" then
					value = v2.Value
				else
					value = v2
				end
			end
		end

		self[k] = value
	end

	if (self.progress >= 100 or self.progress <= 0) and self.active then
		self:EndMinigame()
	end
end

function HarpoonMinigameController:TickRender(p: number)
	for _, activeBar in ipairs(self.activeBars) do
		local v = math.clamp((activeBar.value - activeBar.min) / (activeBar.max - activeBar.min), 0, 1)
		local smoothDamp, springVelocity = TweenService:SmoothDamp(
			activeBar._displayedValue,
			v,
			activeBar._springVelocity,
			activeBar.springTime,
			nil,
			p
		)
		activeBar._displayedValue = smoothDamp
		activeBar._springVelocity = springVelocity
		activeBar.bar.bar.Size = UDim2.fromScale(1, activeBar._displayedValue)
	end

	local visible = math.abs(self.progressefficiency - 1) > 0.0001
	self.ui_progspeed.Visible = visible

	if visible then
		self.ui_progspeed.Text = self.progspeed_format:format((self.progressefficiency - 1) * 100)
	end

	local visible2 = math.abs(self.trueprogressefficiency - 1) > 0.0001
	self.ui_trueprogspeed.Visible = visible2

	if visible2 then
		self.ui_trueprogspeed.Text = self.trueprogspeed_format:format((self.trueprogressefficiency - 1) * 100)

		if self.ui_trueprogspeed_pos then
			self.ui_trueprogspeed_pos.Enabled = self.trueprogressefficiency >= 1
		end

		if self.ui_trueprogspeed_neg then
			self.ui_trueprogspeed_neg.Enabled = self.trueprogressefficiency < 1
		end
	end
end

function HarpoonMinigameController:EndMinigame(flag: boolean?)
	local progress = self.progress
	self.active = false

	while self.isPaused do
		task.wait()
	end

	local v = flag == true and 100 or flag == false and 0 or progress
	self.PreMinigameEnd:Fire(v >= 100, self.perfect)
	local v2 = self.BuildEndingData:InvokeAsync()
	self.OnMinigameEnd:Fire(v >= 100, self.perfect, v2)
	local hud = HudController:GetHud()

	if hud then
		hud.Enabled = true
		local deviceInsetGui = HudController:GetDeviceInsetGui()

		if deviceInsetGui then
			deviceInsetGui.Enabled = true
		end
	end

	local backpackGui = HudController:GetBackpackGui()

	if backpackGui then
		backpackGui.Enabled = true
	end

	if localPlayer.Character then
		task.delay(UserInputService.PreferredInput == Enum.PreferredInput.Gamepad and 1.5 or 0, function()
			localPlayer.Character:SetAttribute("HarpoonMinigameActive", nil)
		end)
	end

	Net:RemoteEvent("HarpoonMinigame/Finish"):FireServer({
		e = v,
		p = self.perfect,
		l = {},
		d = v2
	})
	task.delay(self.cleanup_delay, function()
		self:Destroy()
	end)
end

function HarpoonMinigameController:Destroy()
	if HarpoonMinigameController.ActiveMinigame == self then
		HarpoonMinigameController.ActiveMinigame = nil
	end

	local destroying = self.Destroying
	destroying:Fire()
	self.trove:Clean()
	self.ui = nil
	self.ui_progress = nil
	self.ui_safezone = nil
	self.ui_buttonTemplates = nil
	self.ui_thumbstick = nil
	self.active = false
	table.clear(self.ActivePassives)
	table.clear(self._active_modifiers)
	table.clear(self.activeButtons)
	table.clear(self.activeBars)
	task.delay(0.1, function()
		destroying:Destroy()
	end)
	source:SetActivePassives({}, true)
	source2:SetActivePassives({}, true)
end

function HarpoonMinigameController.GetRandomButtonPosition(p, object, p2: number)
	local number = object:NextNumber(p2 * 0.37037037037037035, 1 - p2 * 0.37037037037037035)
	local number2 = object:NextNumber(p2 * 0.5, 1 - p2 * 0.5)
	local vector = Vector2.new(number - 0.5, number2 - 0.5)
	local vector2 = Vector2.new(number, number2)

	if not (p.ui_thumbstick.Visible and vector.Magnitude < p2 * 0.5 + 0.1) then
		return vector2
	end

	if number == 0.5 and number2 == 0.5 then
		return vector2 + Vector2.new(0, 0.5)
	end

	vector2 += vector.Unit * (p2 * 0.5 + 0.1)
	return vector2
end

function HarpoonMinigameController.CreatePassiveBar(data, name: string, instance, data2)
	local bar = data.trove:Add(instance:Clone())
	bar.Name = name
	local v2 = {
		name = name,
		bar = bar,
		value = not data2 and 0 or data2.value or 0,
		min = not data2 and 0 or data2.min or 0,
		max = not data2 and 100 or data2.max or 100,
		springTime = data2 and data2.springTime or 0.25,
		_displayedValue = 0,
		_springVelocity = 0
	}
	table.insert(data.activeBars, v2)
	local displayedValue = math.clamp((v2.value - v2.min) / (v2.max - v2.min), 0, 1)
	v2._displayedValue = displayedValue
	bar.bar.Size = UDim2.fromScale(1, displayedValue)
	bar.Parent = data.ui.passivebars
	return v2
end

function HarpoonMinigameController:AddModifier(p2, p3, value)
	if self._active_modifiers[p2] then
		if not self._active_modifiers[p2][p3] then
			self._active_modifiers[p2][p3] = {}
		end
	else
		self._active_modifiers[p2] = {
			[p3] = {}
		}
	end

	local v = self._active_modifiers[p2][p3]

	if typeof(value) == "Instance" then
		self.trove:Add(value.Destroying:Once(function()
			local index = table.find(v, value)

			if index then
				table.remove(v, index)
			end
		end))
		table.insert(v, value)
	elseif typeof(value) == "number" then
		local v2 = v[1]

		if typeof(v2) == "number" then
			if p3 == "add" or p3 == "force_add" then
				v[1] = v2 + value
				return self
			end

			if p3 == "multiply" or p3 == "force_multiply" then
				v[1] = v2 * value
				return self
			end

			if p3 == "force" or p3 == "force_final" then
				v[1] = value
				return self
			end

			table.insert(v, value)
			return self
		else
			table.insert(v, 1, value)
		end
	end

	return self
end

function HarpoonMinigameController:CreateModifier(p, p2)
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = `{p}_{p2}`

	if p2 == "multiply" or p2 == "force_multiply" then
		numberValue.Value = 1
	end

	self.trove:Add(numberValue)
	self:AddModifier(p, p2, numberValue)
	return numberValue
end

function HarpoonMinigameController.GetRandom(p, value: number)
	return Random.new(p.base_seed + (value or 0))
end

function HarpoonMinigameController:AddProgress(p: number, p2: number?)
	if p2 and p2 <= self.progress then
		return self
	end

	if p2 then
		p = math.min(p, p2 - self.progress)
	end

	return self:AddModifier("progress", "add", p)
end

function HarpoonMinigameController:TweenModifier(p, p2, p3: number, p4: number, p5)
	local modifier = self:CreateModifier(p, p2)
	modifier.Value = p3
	local v = self.logicTweens:Create(modifier, p5, {
		Value = p4
	})
	v.Completed:Once(function()
		self:AddModifier(p, p2, p4)
		modifier:Destroy()
	end)
	v:Play()
	return v
end

function HarpoonMinigameController:Preload(list)
	self._preload_tasks += 1
	self.trove:Add(task.spawn(function()
		for _, sound in ipairs(list) do
			if not (typeof(sound) == "Instance" and sound:IsA("Sound") and sound:HasTag("LazyLoadSound") and sound:GetAttribute("SoundId")) then
				continue
			end

			sound.SoundId = sound:GetAttribute("SoundId")
			sound:RemoveTag("LazyLoadSound")
		end

		ContentProvider:PreloadAsync(list)
		self._preload_tasks -= 1

		if self._preload_tasks <= 0 and self._awaiting_preload and not self.ready then
			self._awaiting_preload = false
			self.active = true
			self.ready = true
			self.OnReady:Fire()
		end
	end))
end

function HarpoonMinigameController.WaitUntilReady(p)
	if not p.ready then
		p.OnReady:Wait()
	end
end

function HarpoonMinigameController:AddCleanupDelay(p2: number)
	self.cleanup_delay = math.max(p2, self.cleanup_delay)
end

function HarpoonMinigameController.SpawnButton(p, p2, p3, p4)
	return module.new(p, p2, p3, p4 or p.buttonSize)
end

function HarpoonMinigameController.WaitLogic(p, p2: number)
	return p.logicTweens:Wait(p2)
end

function HarpoonMinigameController.WaitRender(p, p2: number)
	return p.renderTweens:Wait(p2)
end

function HarpoonMinigameController.DelayLogic(p, ...)
	return p.logicTweens:Delay(...)
end

function HarpoonMinigameController.DelayRender(p, ...)
	return p.renderTweens:Delay(...)
end

function HarpoonMinigameController:Start()
	local remoteFunction = Net:RemoteFunction("HarpoonMinigame/Start", -1)

	remoteFunction.OnClientInvoke = function(...)
		HarpoonMinigameController.StartMinigame(...)
		return true
	end
end

return HarpoonMinigameController