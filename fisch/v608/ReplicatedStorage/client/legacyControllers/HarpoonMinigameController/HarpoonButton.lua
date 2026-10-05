game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
require(packages.Net)
local Signal = require(packages.Signal)
require(packages.Trove)
local modules = ReplicatedStorage.shared.modules
local fx = require(modules.fx)
local _ = ReplicatedStorage.shared.utils
require("./Types")
local buttonTemplates = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing"):WaitForChild("customharpoons"):WaitForChild("default"):WaitForChild("safezone"):WaitForChild("buttonTemplates")
local sfx = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx")
local HarpoonButton = {}

function HarpoonButton:new(childName, p, size)
	local maid = self.trove:Extend()
	local buttonObject = maid:Add((self.ui_buttonTemplates:FindFirstChild(childName) or buttonTemplates:FindFirstChild(childName)):Clone())
	buttonObject.Selectable = false
	buttonObject.Active = false
	buttonObject.Interactable = false
	buttonObject.Size = UDim2.fromScale(size, size)
	self._buttonCount += 1
	local _buttonCount = self._buttonCount
	local object = setmetatable({
		trove = maid,
		OnClick = maid:Add(Signal.new()),
		OnRemoving = maid:Add(Signal.new()),
		current = self,
		buttonObject = buttonObject,
		id = _buttonCount,
		buttonType = childName,
		currentPos = p,
		moveTarget = p,
		springTime = 1,
		springMaxSpeed = nil,
		_springVelocity = Vector2.zero,
		_lastRemaining = 0,
		_originalTitle = buttonObject.title.Text,
		_clickGlowAlpha = 0,
		absoutePosition = self.safezone_topLeft + self.safezone_absSize * p,
		absoluteSize = math.min(self.safezone_absSize.X, self.safezone_absSize.Y) * size,
		paused = false,
		removing = false,
		destroyed = false,
		despawnTimer = nil,
		requiredClicks = 1,
		clicksRemaining = 1,
		timesClicked = 0,
		size = size
	}, {
		__index = HarpoonButton
	})
	maid:Add(function()
		object.removing = true
		object.destroyed = true
		local index = table.find(object.current.activeButtons, object)

		if index then
			table.remove(object.current.activeButtons, index)
		end

		object.buttonObject = nil
	end)
	maid:Add(object.current.OnMinigameEnd:Once(function(p3)
		object:Remove(p3)
	end))
	buttonObject.Position = UDim2.fromScale(p.X, p.Y)
	buttonObject.ZIndex = -object.id
	buttonObject.Visible = true
	buttonObject.UIScale.Scale = 0
	buttonObject.Parent = self.ui_safezone
	fx:PlaySound(sfx.fishing.buttonspawn, object.current.ui, true)
	table.insert(self.activeButtons, object)
	self.OnButtonAdded:FireDeferred(object)
	TweenService:Create(buttonObject.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Scale = 1
	}):Play()
	fx:PlaySound(sfx.fishing.buttonspawn, object.current.ui, true)
	return object
end

function HarpoonButton:TickLogic(p: number)
	if self.removing or self.paused then
		return
	end

	debug.profilebegin("HarpoonButton::TickLogic")
	local smoothDamp, springVelocity = TweenService:SmoothDamp(
		self.currentPos,
		self.moveTarget,
		self._springVelocity,
		self.springTime,
		self.springMaxSpeed,
		p / self.current.movementfactor
	)
	self.currentPos = smoothDamp
	self._springVelocity = springVelocity
	self.absoutePosition = self.current.safezone_topLeft + self.current.safezone_absSize * self.currentPos
	self.absoluteSize = math.min(self.current.safezone_absSize.X, self.current.safezone_absSize.Y) * self.size

	if self.despawnTimer then
		self.despawnTimer -= p

		if self.despawnTimer <= 0 then
			self:Remove(false)
		end
	end

	debug.profileend()
end

function HarpoonButton:TickRender(p: number)
	debug.profilebegin("HarpoonButton::TickRender")
	self.buttonObject.Position = UDim2.fromScale(self.currentPos.X, self.currentPos.Y)
	self.buttonObject.hoverStroke.Enabled = self.isHovered
	self.buttonObject.GamepadIcon.Visible = self.isHovered

	if self._lastRemaining ~= self.clicksRemaining then
		self._lastRemaining = self.clicksRemaining

		if self.clicksRemaining > 1 and math.isfinite(self.clicksRemaining) then
			self.buttonObject.title.Text = `{self._originalTitle} <font size='48'>({self.clicksRemaining})</font>`
		else
			self.buttonObject.title.Text = self._originalTitle
		end
	end

	if self._clickGlowAlpha > 0 then
		self._clickGlowAlpha = math.clamp(self._clickGlowAlpha - p * 2, 0, 1)
		self.buttonObject.UIShadow.Color = self.buttonObject.UIShadow:GetAttribute("BaseColor"):Lerp(
			self.buttonObject.UIShadow:GetAttribute("ClickColor"),
			self._clickGlowAlpha
		)
	end

	debug.profileend()
end

function HarpoonButton:Click(p, p2: string)
	if self.clicksRemaining <= 0 then
		return false
	end

	self.timesClicked += 1
	self.clicksRemaining -= 1
	self.OnClick:Fire(p, p2, self.timesClicked)
	self.current.OnButtonClick:Fire(self, p, p2, self.timesClicked)
	self._clickGlowAlpha = 1

	if self.clicksRemaining <= 0 then
		self:Remove(true)
	end

	if p == "player" then
		fx:PlaySound(sfx.ui.clank2, self.current.ui, true)
	end

	return true
end

function HarpoonButton:ModifyDespawnTime(p2, despawnTimer: number)
	if p2 == "set" then
		self.despawnTimer = despawnTimer
	elseif p2 == "min" then
		if not self.despawnTimer or self.despawnTimer < despawnTimer then
			self.despawnTimer = despawnTimer
		end
	elseif p2 == "max" then
		if not self.despawnTimer or despawnTimer < self.despawnTimer then
			self.despawnTimer = despawnTimer
		end
	elseif p2 == "add" then
		self.despawnTimer = (self.despawnTimer or 0) + despawnTimer
	else
		error(`Unknown "mode" option for ModifyDespawnTime: "{p2}"`, 1)
	end
end

function HarpoonButton:Remove(flag: boolean)
	if self.removing then
		return
	end

	self.removing = true
	self.current.lastInputWasMiss = not flag
	self.OnRemoving:Fire(flag)
	self.current.OnButtonRemoving:Fire(self, flag)

	if not flag then
		self.current.OnButtonMissed:Fire(self)
	end

	task.spawn(function()
		local WAIT_INTERVAL = 1

		if self.current.active then
			if flag then
				local clone = script.hitfx:Clone()
				clone.Position = self.buttonObject.Position
				clone.Size = self.buttonObject.Size
				clone.ZIndex = self.buttonObject.ZIndex + 1

				if self.buttonObject:FindFirstChild("hoverStroke") and self.buttonObject.hoverStroke:FindFirstChild("UIGradient") then
					clone.hoverStroke.UIGradient.Color = self.buttonObject.hoverStroke.UIGradient.Color
				end

				if self.buttonObject:GetAttribute("HitColor1") then
					clone.UIShadow.Color = self.buttonObject:GetAttribute("HitColor1")
				end

				if self.buttonObject:GetAttribute("HitColor2") then
					clone.UIShadow2.Color = self.buttonObject:GetAttribute("HitColor2")
				end

				clone.Visible = true
				clone.Parent = self.current.ui_safezone
				self.buttonObject.Visible = false
				TweenService:Create(clone.hoverStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
					BorderOffset = UDim.new(1, 0)
				}):Play()
				TweenService:Create(clone.hoverStroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					Thickness = 0
				}):Play()
				TweenService:Create(clone.UIShadow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
					BlurRadius = UDim.new(1, 0)
				}):Play()
				TweenService:Create(clone.UIShadow, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
					Transparency = 1
				}):Play()
				TweenService:Create(clone.UIShadow2, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
					Transparency = 1
				}):Play()
				task.wait(WAIT_INTERVAL)
				clone:Destroy()
			else
				local clone = script.missfx:Clone()
				clone.Position = self.buttonObject.Position
				clone.Size = self.buttonObject.Size
				clone.ZIndex = self.buttonObject.ZIndex + 1
				fx:PlaySound(sfx.fishing.buttonmiss, self.current.ui, true)

				if self.buttonObject:GetAttribute("MissColor1") then
					clone.UIShadow.Color = self.buttonObject:GetAttribute("MissColor1")
				end

				if self.buttonObject:GetAttribute("MissColor2") then
					clone.UIShadow2.Color = self.buttonObject:GetAttribute("MissColor2")
				end

				clone.Visible = true
				clone.Parent = self.current.ui_safezone
				TweenService:Create(self.buttonObject.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
					Scale = 0
				}):Play()
				TweenService:Create(clone.UIShadow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
					BlurRadius = UDim.new(1, 0)
				}):Play()
				TweenService:Create(clone.UIShadow, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
					Transparency = 1
				}):Play()
				TweenService:Create(clone.UIShadow2, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
					Transparency = 1
				}):Play()
				task.wait(WAIT_INTERVAL)
				clone:Destroy()
			end
		else
			TweenService:Create(self.buttonObject.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
				Scale = 0
			}):Play()
			task.wait(WAIT_INTERVAL)
		end

		self:Destroy()
	end)
end

function HarpoonButton:Destroy()
	self.current.trove:Remove(self.trove)
end

function HarpoonButton:MoveTo(moveTarget: Vector2)
	self.moveTarget = moveTarget
end

return HarpoonButton