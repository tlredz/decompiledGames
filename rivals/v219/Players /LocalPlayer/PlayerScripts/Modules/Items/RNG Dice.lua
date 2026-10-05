local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Custom = require(Players.LocalPlayer.PlayerScripts.Modules.ItemTypes.Custom)
local v = {
	Utility = "rbxassetid://134135466396929",
	Melee = "rbxassetid://78813062969940",
	Secondary = "rbxassetid://136044794858753",
	Primary = "rbxassetid://77716075365102"
}
local object = setmetatable({}, Custom)
object.__index = object

function object.new(...)
	local self = setmetatable(Custom.new(...), object)
	self._use_cooldown = 0
	self:_Init()
	return self
end

function object.GetAutoShootReactionTime(_)
	return nil
end

function object:CanQuickAttack()
	return tick() > self._use_cooldown and not self:IsEquipping()
end

function object:StartShooting(p)
	if not p and (tick() < self._use_cooldown or self:IsEquipping()) then
		return false
	end

	self._use_cooldown = tick() + self.Info.RollDuration + self.Info.Cooldown
	self.ViewModel:PlayAnimation("Use")
	self:CooldownEffect("rbxassetid://132973552546079", self.Info.RollDuration, "Rolling", true)
	task.delay(self.Info.RollDuration, function()
		if self._destroyed then
			return
		end

		self:CooldownEffect("rbxassetid://17156089790", self.Info.Cooldown, "Cooldown")
	end)
	return true, "StartShooting"
end

function object.ReplicateFromServer(object2, p, ...)
	if p ~= "RollResult" then
		Custom.ReplicateFromServer(object2, p, ...)
		return
	end

	if not object2:IsRendered() then
		return
	end

	local v2, v3 = ...
	local v4 = v3 and "rbxassetid://136831234910767" or v[ItemLibrary.Items[v2].Class] or "rbxassetid://134135466396929"

	if object2.ClientFighter.FighterInterface then
		object2.ClientFighter.FighterInterface:HotbarRollEffect(object2)
	end

	object2:CreateSound("rbxassetid://95740132815107", 1.5, 1 + 0.1 * math.random(), true, 0.4):SetAttribute(
		"DontClearSound",
		true
	)
	wait(0.4)
	object2:CreateSound(v4, 1.5, 1 + 0.2 * math.random(), true, 5):SetAttribute("DontClearSound", true)
end

function object:_Init() end

return object