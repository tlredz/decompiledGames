game:GetService("UserInputService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("GamepadService")
game:GetService("GuiService")
require(ReplicatedStorage.packages.Trove)
local Signal = require(ReplicatedStorage.packages.Signal)
local Hook = require(ReplicatedStorage.shared.modules.Hook)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
require("../Types")
require(ReplicatedStorage.client.legacyControllers.SettingsController)
local BasePullButtons = {}

local function cancelWhenInvalid(p)
	return not p.valid
end

function BasePullButtons.new(current)
	local object = setmetatable({}, {
		__index = BasePullButtons
	})
	object.current = current
	object.trove = current.trove:Extend()
	object.Disabled = false
	object.OnButtonAdd = object.trove:Add(Signal.new())
	object.OnClickEvent = object.trove:Add(Signal.new())
	object.OnMissEvent = object.trove:Add(Signal.new())
	object.HookClickEvent = object.trove:Add(Hook.direct():SetCancelCondition(cancelWhenInvalid))
	object.HookMissEvent = object.trove:Add(Hook.direct():SetCancelCondition(cancelWhenInvalid))
	return object
end

function BasePullButtons:Start()
	self.trove:Add(self.current.OnButtonClick:Connect(function(p, p2, p3, p4)
		if self.Disabled or p.buttonType ~= "pull" then
			return
		end

		self:ProcessClickEvent(p, p2, p3, p4)
	end))
	self.trove:Add(self.current.OnButtonRemoving:Connect(function(p, p2)
		if self.Disabled or p.buttonType ~= "pull" then
			return
		end

		if not p2 and self.current.active then
			self:ProcessMissEvent(p)
		end

		local v = false

		for _, activeButton in ipairs(self.current.activeButtons) do
			if activeButton.buttonType ~= "pull" or activeButton.removing then
				continue
			end

			v = true
			break
		end

		if not v then
			self:SpawnButton()
			self.current.OnFishMove:Fire(0, 0)
		end
	end))
	self.trove:Add(self.current.OnReady:Once(function()
		self:SpawnButton()
	end))
end

function BasePullButtons:Disable()
	self.Disabled = true
end

function BasePullButtons.Stop(p)
	p.trove:Clean()
end

function BasePullButtons.TickLogic(p, p2: number)
	if p.Disabled then
		return
	end

	for _, activeButton in p.current.activeButtons do
		if activeButton.removing or activeButton.buttonType ~= "pull" or activeButton.paused then
			continue
		end

		activeButton.nextMoveChange -= p2 / p.current.movementfactor

		if not (activeButton.nextMoveChange <= 0) then
			continue
		end

		activeButton:MoveTo(p.current:GetRandomButtonPosition(activeButton.random, activeButton.size))
		activeButton.nextMoveChange += activeButton.random:NextNumber(0, activeButton.springTime)

		if activeButton._springVelocity == Vector2.zero then
			activeButton._springVelocity = GeneralUtils.safeUnit2(activeButton.moveTarget - activeButton.currentPos) * ((activeButton.springMaxSpeed or 1) / activeButton.springTime) * 0.1
		end
	end
end

function BasePullButtons.TickRender(p, _: number)
	if p.Disabled then
	end
end

function BasePullButtons:SpawnButton(point: Vector2?, p2: number?)
	if not self.current.active then
		return nil
	end

	local random = self.current:GetRandom(1001 + self.current._buttonCount)
	local v = p2 or self.current.buttonSize
	local v2 = point or self.current:GetRandomButtonPosition(random, v)
	local button = self.current:SpawnButton("pull", v2, v)
	button.random = random
	button.clicksPerProgress = 1
	button.nextMoveChange = 0
	button.progressMultiplier = 1
	button.springTime = math.clamp((self.current.resilience + 100) / 100, 0.5, 10)
	button.springMaxSpeed = 5 / button.springTime
	button:ModifyDespawnTime("add", self.current.buttonLifetime)
	self.OnButtonAdd:Fire(button)
	return button
end

function BasePullButtons:ProcessClickEvent(button, sourceType, sourceName, clickCount)
	local v = {
		button = button,
		progress = self.current.power * 0.5 * button.progressMultiplier * self.current.progressefficiency,
		valid = clickCount % button.clicksPerProgress == 0,
		clickCount = clickCount,
		sourceType = sourceType,
		sourceName = sourceName
	}
	local v2 = self.HookClickEvent:InvokeAsync(v)

	if not v2.valid then
		return v2
	end

	self.OnClickEvent:Fire(v2)
	self.current:AddProgress(v2.progress)
	return v2
end

function BasePullButtons:ProcessMissEvent(button)
	local v = {
		button = button,
		progress = (-7 - self.current.progress / 15) * self.current.progressLossMultiplier,
		valid = true
	}
	local v2 = self.HookMissEvent:InvokeAsync(v)

	if not v2.valid then
		return v2
	end

	self.OnMissEvent:Fire(v2)
	self.current:AddProgress(v2.progress)
	self.current.perfect = false
	return v2
end

return BasePullButtons