local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local localPlayer = Players.LocalPlayer
local Trove = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage.packages.Signal)
local Net = require(ReplicatedStorage.packages.Net)
local Hook = require(ReplicatedStorage.shared.modules.Hook)
local CustomTweens = require(ReplicatedStorage.shared.modules.CustomTweens)
local WindowController = require(ReplicatedStorage.client.legacyControllers.WindowController)
local library = require(ReplicatedStorage.shared.modules.library)
local LocalPassive = require(ReplicatedStorage.shared.modules.LocalPassive)
local customreels = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing"):WaitForChild("customreels")
require("@self/Types")
local module = require("@self/ReelFX")
local source = LocalPassive:GetSource("FishBehavior")
local source2 = LocalPassive:GetSource("ServerInjected")
local StabController = {}
StabController.__index = StabController
StabController.type = "stab"
StabController.ActiveReel = nil
StabController.Aborted = {}

function StabController.new(reel, data)
	local object = setmetatable(data, StabController)
	object.fx = setmetatable({
		current = object
	}, module)
	object.trove = Trove.new()
	object._active_modifiers = {}
	object.logicTweens = object.trove:Add(CustomTweens.new())
	object.renderTweens = object.trove:Add(CustomTweens.new())
	object._preload_tasks = 0
	object._awaiting_preload = false
	object.reel = reel
	object.reel_bar = reel:WaitForChild("bar")
	object.reel_playerbar = reel.bar:WaitForChild("playerbar")
	object.reel_progress = reel.bar:WaitForChild("progress")
	object.reel_progspeed = reel.bar:WaitForChild("progressspeed")
	object.reel_trueprogspeed = reel.bar:WaitForChild("trueprogressspeed")
	object.reel_trueprogspeed_pos = object.reel_trueprogspeed:FindFirstChild("positiveGradient", true)
	object.reel_trueprogspeed_neg = object.reel_trueprogspeed:FindFirstChild("negativeGradient", true)
	object.progspeed_format = reel:GetAttribute("progspeed_format") or "%+.0f%% Progress Speed"
	object.trueprogspeed_format = reel:GetAttribute("trueprogspeed_format") or "%+.0f%% True Progress Speed"
	object.cleanup_delay = 1.25
	object._progressVelocity = 0
	object.barSize = reel.bar.playerbar.Size.X.Scale
	object.barPosition = reel.bar.playerbar.Position.X.Scale
	object.minBarSize = 0
	object.minBarPosition = 0
	object.frozenUntil = 0
	object:AddModifier("maxBarPosition", "add", 1)
	object.fishPosition = 0.5
	object:AddModifier("progressLossMultiplier", "add", 1)
	object:AddModifier("moveIntervalFactor", "add", 1)
	object:AddModifier("movementfactor", "add", 1)
	object:AddModifier("accel", "add", data.accel)
	object:AddModifier("barMoveSpeed", "add", data.barMoveSpeed)

	if library.fish[data.fish.Name].ForcedProgressEfficiency and (data.fish.Name ~= "Scylla" or data.rodName ~= "Leviathan's Fang Rod") then
		object:AddModifier("progressefficiency", "force", 1)
	end

	object:AddModifier("trueprogressefficiency", "add", data.stats.TrueProgressSpeed / 100 + 1)
	object:AddModifier("progressefficiency", "add", data.stats.ProgressSpeed / 100 + 1)
	object:AddModifier("progressefficiency", "force_add", data.stats.ForcedProgressSpeed / 100)
	object:AddModifier("resilience", "add", data.stats.Resilience)
	object:AddModifier("power", "add", data.stats.Power)
	object:AddModifier("handling", "add", data.stats.Handling)
	object:AddModifier("piercing", "add", data.stats.Piercing)
	object.trueprogressefficiency = data.stats.TrueProgressSpeed / 100 + 1
	object._trueProgressModifier = object:CreateModifier("progress", "force_multiply")
	object._trueProgressModifier.Value = object.trueprogressefficiency
	object.OnLoad = object.trove:Add(Signal.new())
	object.OnReady = object.trove:Add(Signal.new())
	object.OnFishMove = object.trove:Add(Signal.new())
	object.PreMinigameEnd = object.trove:Add(Signal.new())
	object.OnMinigameEnd = object.trove:Add(Signal.new())
	object.Destroying = Signal.new()
	object.OnFishEnterBar = object.trove:Add(Signal.new())
	object.OnFishExitBar = object.trove:Add(Signal.new())
	object.OnSlash = object.trove:Add(Signal.new())
	object.OnRenderStep = object.trove:Add(Signal.new())
	object.OnLogicStep = object.trove:Add(Signal.new())
	object.OnBarBounce = object.trove:Add(Signal.new())
	object.OnBarDirectionChange = object.trove:Add(Signal.new())
	object.BuildSnapshot = object.trove:Add(Hook.new(function()
		return {}
	end))
	object.BuildEndingData = object.trove:Add(Hook.new(function()
		return {}
	end))
	object.ActivePassives = {}
	object.trove:AttachToInstance(reel)
	local module2 = require("@self/Core")
	object.core = {
		ui = module2.ui.new(object),
		simplifiedInput = module2.simplifiedInput.new(object),
		simplifiedMinigame = module2.simplifiedMinigame.new(object)
	}
	object.trove:Add(Net:RemoteEvent("Stab/Abort").OnClientEvent:Once(function(p)
		StabController.Aborted[p] = true

		if object.base_seed ~= p then
			return
		end

		if not object.loaded and object.OnLoad then
			object.OnLoad:Wait()
		end

		object:Destroy()

		if localPlayer.Character then
			localPlayer.Character:SetAttribute("ReelActive", nil)
		end

		local localPlayer2 = Players.LocalPlayer
		local hud = localPlayer2.PlayerGui:FindFirstChild("hud")
		local backpack = localPlayer2.PlayerGui:FindFirstChild("backpack")

		if hud then
			hud.Enabled = true
			local deviceinset = hud:FindFirstChild("deviceinset")

			if deviceinset then
				deviceinset.Enabled = true
			end
		end

		if backpack then
			backpack.Enabled = true
		end
	end))
	return object
end

local function getValue(value)
	if typeof(value) == "Instance" then
		value = value.Value or value
	end

	return value
end

function StabController:Update(_: number)
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
							value2 = value2.Value or value2
						end

						value += value2
					end
				end

				if _active_modifier.multiply then
					for _, value2 in _active_modifier.multiply do
						if typeof(value2) == "Instance" then
							value2 = value2.Value or value2
						end

						value *= value2
					end
				end
			end

			if _active_modifier.force then
				for _, v3 in _active_modifier.force do
					value = typeof(v3) == "Instance" and v3.Value

					if not value then
						value = v3
					end
				end
			end

			if _active_modifier.force_add then
				for _, value2 in _active_modifier.force_add do
					if typeof(value2) == "Instance" then
						value2 = value2.Value or value2
					end

					value += value2
				end
			end

			if _active_modifier.force_multiply then
				for _, value2 in _active_modifier.force_multiply do
					if typeof(value2) == "Instance" then
						value2 = value2.Value or value2
					end

					value *= value2
				end
			end
		end

		if _active_modifier.force_final then
			for _, v2 in _active_modifier.force_final do
				value = typeof(v2) == "Instance" and v2.Value

				if not value then
					value = v2
				end
			end
		end

		self[k] = value
	end

	self.barSize = math.max(self.barSize, self.minBarSize)

	if self.barSize >= 1 then
		self.barPosition = 0.5
	else
		self.barPosition = math.clamp(
			self.barPosition,
			self.minBarPosition + self.barSize / 2,
			self.maxBarPosition - self.barSize / 2
		)
	end
end

function StabController:UpdateUI(p: number)
	if not self.isSimplified then
		self.reel_playerbar.Size = UDim2.fromScale(self.barSize, self.reel_playerbar.Size.Y.Scale)
	end

	self.reel_playerbar.Position = UDim2.fromScale(self.barPosition, 0.5)
	self.reel_bar.fish.Position = UDim2.fromScale(self.fishPosition, self.reel_bar.fish.Position.Y.Scale)
	local smoothDamp, progressVelocity = TweenService:SmoothDamp(
		self.reel_progress.bar.Size.X.Scale,
		math.clamp(self.progress, 0, 100) / 100,
		self._progressVelocity,
		self.ready and 0.1 or 1,
		nil,
		p
	)
	self._progressVelocity = progressVelocity
	self.reel_progress.bar.Size = UDim2.fromScale(math.clamp(smoothDamp, 0, 1), 1)
	local visible = math.abs(self.progressefficiency - 1) > 0.0001
	self.reel_progspeed.Visible = visible

	if visible then
		self.reel_progspeed.Text = self.progspeed_format:format((self.progressefficiency - 1) * 100)
	end

	local visible2 = math.abs(self.trueprogressefficiency - 1) > 0.0001
	self.reel_trueprogspeed.Visible = visible2

	if visible2 then
		self.reel_trueprogspeed.Text = self.trueprogspeed_format:format((self.trueprogressefficiency - 1) * 100)

		if self.reel_trueprogspeed_pos then
			self.reel_trueprogspeed_pos.Enabled = self.trueprogressefficiency >= 1
		end

		if self.reel_trueprogspeed_neg then
			self.reel_trueprogspeed_neg.Enabled = self.trueprogressefficiency < 1
		end
	end
end

function StabController:AddModifier(p2, p3, value)
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

function StabController:CreateModifier(p, p2)
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = `{p}_{p2}`

	if p2 == "multiply" or p2 == "force_multiply" then
		numberValue.Value = 1
	end

	self.trove:Add(numberValue)
	self:AddModifier(p, p2, numberValue)
	return numberValue
end

function StabController:Destroy()
	if StabController.ActiveReel == self then
		StabController.ActiveReel = nil
	end

	local destroying = self.Destroying
	destroying:Fire()
	self.trove:Clean()
	self.reel = nil
	self.reel_bar = nil
	self.reel_playerbar = nil
	self.reel_progress = nil
	self.reel_progspeed = nil
	self.active = false
	table.clear(self.ActivePassives)
	table.clear(self._active_modifiers)
	task.delay(0.1, function()
		destroying:Destroy()
	end)
	local source3

	if self.mock then
		source3 = LocalPassive:GetSource((`FishBehavior.{self.mock}`))
	else
		source3 = source
	end

	local source4

	if self.mock then
		source4 = LocalPassive:GetSource((`ServerInjected.{self.mock}`))
	else
		source4 = source2
	end

	source3:SetActivePassives({}, true)
	source4:SetActivePassives({}, true)
end

function StabController.GetRandom(p, value: number)
	return Random.new(p.base_seed + (value or 0))
end

function StabController:AddProgress(p: number, p2: number?)
	if p2 and p2 <= self.progress then
		return self
	end

	if p2 then
		p = math.min(p, p2 - self.progress)
	end

	return self:AddModifier("progress", "add", p)
end

function StabController:TweenModifier(p, p2, p3: number, p4: number, p5)
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

function StabController.IsInBar(p, p2: number, value: number?)
	if p.barSize <= 0 then
		return false
	end

	local v = (value or 0) / 2
	return p.barPosition - p.barSize / 2 - v < p2 and p2 < p.barPosition + p.barSize / 2 + v
end

function StabController:FreezeFish(p2: number)
	self.frozenUntil = math.max(tick() + p2, self.frozenUntil + p2)
end

function StabController:Preload(list)
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

function StabController.WaitUntilReady(p)
	if not p.ready then
		p.OnReady:Wait()
	end
end

function StabController:AddCleanupDelay(p2: number)
	self.cleanup_delay = math.max(p2, self.cleanup_delay)
end

function StabController.StartReel(data)
	if not data.mock then
		local lastTime = tick()

		while StabController.ActiveReel and tick() - lastTime < (StabController.ActiveReel.cleanup_delay or 10) do
			task.wait()
		end

		if StabController.ActiveReel then
			task.spawn(StabController.ActiveReel.Destroy, StabController.ActiveReel)
			task.wait()
		end
	end

	local v = library.fish[data.fish.Name]

	if v then
		local v2

		if data.mock then
			v2 = LocalPassive:GetSource((`FishBehavior.{data.mock}`))
		else
			v2 = source
		end

		v2:SetActivePassives(v.ClientFishingPassives or {}, true)
	end

	local v2

	if data.mock then
		v2 = LocalPassive:GetSource((`ServerInjected.{data.mock}`))
	else
		v2 = source2
	end

	v2:SetActivePassives(data.data.InjectedPassives or {}, true)
	local clone = (customreels:FindFirstChild(data.reel_name or "default") or customreels:FindFirstChild("default")):Clone()
	clone:SetAttribute("reelstyle", clone.Name)
	clone.Name = "stab"
	clone.Enabled = false
	clone.bar.progress.bar.Size = UDim2.fromScale(0, 1)
	clone.Parent = localPlayer.PlayerGui
	local v3 = StabController.new(clone, {
		fish = data.fish,
		stats = data.stats,
		loaded = false,
		accel = 1,
		barMoveSpeed = 1,
		active = false,
		bait = data.bait,
		isPaused = false,
		logicPaused = false,
		movementfactor = 1,
		perfect = true,
		progress = 20,
		progressefficiency = 1,
		trueprogressefficiency = 1,
		ready = false,
		onbar = true,
		resilience = 0,
		rodName = data.rod,
		rodSkin = data.skin,
		start = tick(),
		base_seed = data.seed,
		fishmove = tick(),
		cast_power = data.cast_power,
		isSimplified = true,
		data = data.data,
		mock = data.mock,
		reel_name = data.reel_name or "default",
		fishPos = data.fishPos,
		power = 0,
		handling = 0,
		piercing = 0
	})

	if StabController.Aborted[v3.base_seed] then
		v3:Destroy()
		clone:Destroy()
		return v3
	else
		if not data.mock then
			StabController.ActiveReel = v3

			if localPlayer.Character then
				localPlayer.Character:SetAttribute("ReelActive", 0)
			end
		end

		WindowController:CloseActiveWindow()
		clone.Enabled = true
		local localPlayer2 = Players.LocalPlayer
		local character = localPlayer2.Character

		if character then
			local tool = character:FindFirstChildWhichIsA("Tool")

			if tool and tool.Name == v3.rodName then
				v3.rod = tool
			end
		end

		v3.trove:Add(clone)
		v3:Update(0)
		v3:UpdateUI(0)

		if data.preload_callback then
			data.preload_callback(v3)
		end

		v3.isSimplified = true
		local v4 = {
			"FishingRod",
			"Enchantment",
			"SecondaryEnchantment",
			"KeeperAffix1",
			"KeeperAffix2",
			"KeeperAffix3",
			"Masterline1",
			"Masterline2",
			"Masterline3",
			"HarpoonGun",
			"HarpoonGun_Enchantment",
			"HarpoonGun_SecondaryEnchantment"
		}

		if v3.mock then
			table.insert(v4, "FishBehavior")
			table.insert(v4, "ServerInjected")
		end

		for _, v5 in LocalPassive:GetActivePassives(v4, data.data.OnlyPassiveSources) do
			if not v5.MorphSpear then
				continue
			end

			if v3.mock then
				if v5.NoMock then
					continue
				end

				local v6 = v5
				v5 = getmetatable(v5).__index:new(v5.config, v5.env)
				v5.env = v6.env
				v3.trove:Add(function()
					task.defer(v5.Destroy, v5)
				end)
			end

			v5.current = v3
			v5.reel = v3.reel_bar
			table.insert(v3.ActivePassives, v5)

			if typeof(v5.MorphSpear) == "function" then
				local reel_bar = v3.reel_bar
				v5:MorphSpear(reel_bar, v3)
			elseif typeof(v5.Morph) == "function" then
				local reel_bar = v3.reel_bar
				v5:Morph(reel_bar, v3)
			end

			v3.trove:Add(v5, "Cleanup")
		end

		if data.precore_callback then
			data.precore_callback(v3)
		end

		for _, v5 in v3.core do
			if v5.Disabled then
				continue
			end

			v5:Start()
			v3.trove:Add(v5, "Stop")
		end

		v3:Update(0)
		v3:UpdateUI(0)
		local minigameSpeedMulti = localPlayer:GetAttribute("MinigameSpeedMulti") or 1
		v3.trove:Add(localPlayer:GetAttributeChangedSignal("MinigameSpeedMulti"):Connect(function()
			minigameSpeedMulti = localPlayer:GetAttribute("MinigameSpeedMulti") or 1
		end))
		v3.trove:Add(RunService.PreRender:Connect(function(dt: number)
			if v3.isPaused then
				return
			end

			if not clone.Parent then
				v3:Destroy()
				return
			end

			local v5 = dt * minigameSpeedMulti

			for _, v6 in v3.core do
				if not v6.Disabled then
					v6:Tick(v5)
				end
			end

			v3.renderTweens:StepAll(v5)

			for _, activePassive in v3.ActivePassives do
				if typeof(activePassive.TickRender_Spear) == "function" then
					activePassive:TickRender_Spear(v3, v5)
				elseif typeof(activePassive.TickRender) == "function" then
					activePassive:TickRender(v3, v5)
				end
			end

			v3.OnRenderStep:Fire(v5)
			v3:Update(v5)
			v3:UpdateUI(v5)
		end))
		v3.trove:Add(RunService.Heartbeat:Connect(function(dt: number)
			if v3.isPaused or v3.logicPaused then
				return
			end

			local v5 = dt * minigameSpeedMulti
			v3.logicTweens:StepAll(v5)

			for _, activePassive in v3.ActivePassives do
				if typeof(activePassive.TickLogic_Spear) == "function" then
					activePassive:TickLogic_Spear(v3, v5)
				elseif typeof(activePassive.TickLogic) == "function" then
					activePassive:TickLogic(v3, v5)
				end
			end

			v3.OnLogicStep:Fire(v5)
		end))
		v3.reel_bar.fish.Visible = false
		local hud = localPlayer2.PlayerGui:FindFirstChild("hud")

		if hud then
			hud.Enabled = false
			local deviceinset = hud:FindFirstChild("deviceinset")

			if deviceinset then
				deviceinset.Enabled = false
			end
		end

		local backpack = localPlayer2.PlayerGui:FindFirstChild("backpack")

		if backpack then
			backpack.Enabled = false
		end

		v3.loaded = true
		v3.OnLoad:FireDeferred()
		v3.trove:Add(task.spawn(function()
			local character2 = localPlayer.Character

			if not character2 then
				return
			end

			task.wait(2)

			if not character2:GetAttribute("Reeling") then
				character2:GetAttributeChangedSignal("Reeling"):Wait()
			end

			if v3._preload_tasks > 0 then
				v3._awaiting_preload = true
				return
			end

			v3.active = true
			v3.ready = true
			v3.OnReady:Fire()
		end))
		return v3
	end
end

function StabController:EndMinigame(flag: boolean?)
	local progress = self.progress
	self.active = false

	while self.isPaused do
		task.wait()
	end

	local v = flag == true and 100 or flag == false and 0 or progress
	self.PreMinigameEnd:Fire(v >= 100, self.perfect)
	local v2 = self.BuildEndingData:InvokeAsync()
	self.OnMinigameEnd:Fire(v >= 100, self.perfect, v2)

	if not self.mock then
		local localPlayer2 = Players.LocalPlayer
		local hud = localPlayer2.PlayerGui:FindFirstChild("hud")

		if hud then
			hud.Enabled = true
			local deviceinset = hud:FindFirstChild("deviceinset")

			if deviceinset then
				deviceinset.Enabled = true
			end
		end

		local backpack = localPlayer2.PlayerGui:FindFirstChild("backpack")

		if backpack then
			backpack.Enabled = true
		end

		if localPlayer.Character then
			localPlayer.Character:SetAttribute("ReelActive", nil)
		end

		ReplicatedStorage.events.bindable_reel_finished:Fire(v >= 100)
		Net:RemoteEvent("Stab/Finish"):FireServer({
			e = v,
			p = self.perfect,
			l = {},
			d = v2
		})
		task.delay(self.cleanup_delay, function()
			self:Destroy()
		end)
	end
end

function StabController.QueryPassives(data, p: string?, p2: string?)
	if not data.loaded then
		data.OnLoad:Wait()
	end

	local activePassives = {}

	for _, activePassive in data.ActivePassives do
		if (not p or activePassive.env.PassiveName == p) and (not p2 or activePassive.env.SourceName == p2) then
			table.insert(activePassives, activePassive)
		end
	end

	return activePassives
end

function StabController.FindFirstPassive(data, p: string?, p2: string?)
	if not data.loaded then
		data.OnLoad:Wait()
	end

	for _, activePassive in data.ActivePassives do
		if (not p or activePassive.env.PassiveName == p) and (not p2 or activePassive.env.SourceName == p2) then
			return activePassive
		end
	end

	return nil
end

function StabController.GetPassiveByUid(data, p: string)
	if not data.loaded then
		data.OnLoad:Wait()
	end

	for _, activePassive in data.ActivePassives do
		if activePassive.uid == p then
			return activePassive
		end
	end

	return nil
end

function StabController.WaitLogic(p, p2: number)
	return p.logicTweens:Wait(p2)
end

function StabController.WaitRender(p, p2: number)
	return p.renderTweens:Wait(p2)
end

function StabController.DelayLogic(p, ...)
	return p.logicTweens:Delay(...)
end

function StabController.DelayRender(p, ...)
	return p.renderTweens:Delay(...)
end

function StabController:Start()
	local remoteFunction = Net:RemoteFunction("Stab/Start", -1)

	remoteFunction.OnClientInvoke = function(...)
		StabController.StartReel(...)
		return true
	end

	Net:RemoteEvent("SpearFishing/Minigame/ProgressGain").OnClientEvent:Connect(function(p: number)
		local activeReel = StabController.ActiveReel

		if activeReel then
			activeReel:AddProgress(p)
		end
	end)
end

return StabController