-- failed to load script (decompiled with syntax error):
-- iWADmWnvvEuQLyiQOKQHcniXe:140: Expected identifier when parsing expression, got ';'

local Spring = require(script.Parent:WaitForChild("Spring"))
local Fade = require(script.Parent:WaitForChild("Fade"))
local Ticker = require(script.Parent:WaitForChild("Ticker"))
local spr = Spring.spr
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function sfx()
	v = v or require(script.Parent:WaitForChild("SFX"))
	return v
end

local Panel = {}
Panel.__index = Panel
local defaults = {
	ScaleName = "RevealScale",
	OpenFrom = 0.66,
	CloseTo = 0.8,
	Settle = 0.22,
	Open = "Open",
	OpenFade = "OpenFade",
	Close = "Close",
	CloseFade = "CloseFade",
	Fade = true,
	BackdropTransparency = 0.45,
	CloseSound = "Common.CloseFrame",
	DisableGui = true
}

function Panel:new(main, options)
	local object = setmetatable({}, Panel)
	object.gui = self
	object.main = main
	object.opts = setmetatable(options or {}, {
		__index = defaults
	})
	object.IsOpen = false
	object.token = 0
	object.warm = false
	object.ambientFns = {}
	object.ambientHandle = nil
	object.scale = Spring.scale(main, object.opts.ScaleName)
	local fade

	if object.opts.Fade then
		fade = Fade.group(main) or nil
	end

	object.fade = fade
	object.Opened = Instance.new("BindableEvent")
	object.Closed = Instance.new("BindableEvent")
	object.Hidden = Instance.new("BindableEvent")
	local backdrop = object.opts.Backdrop

	if backdrop then
		object.backdropRest = backdrop.BackgroundTransparency < 1 and backdrop.BackgroundTransparency or object.opts.BackdropTransparency
		backdrop.BackgroundTransparency = 1
		backdrop.Visible = false

		if backdrop:IsA("GuiButton") then
			backdrop.Activated:Connect(function()
				if object.opts.BackdropCloses ~= false then
					object:Close()
				end
			end)
		end
	end

	main.Visible = false

	if object.fade then
		object.fade:Apply(0)
	end

	if object.opts.DisableGui then
		self.Enabled = false
	end

	self.ResetOnSpawn = false
	return object
end

function Panel:_startAmbient()
	if self.ambientHandle or #self.ambientFns == 0 then
		return
	end

	local ambientFns = self.ambientFns
	self.ambientHandle = Ticker.add(function(p)
		for i = 1, #ambientFns do
			ambientFns[i](p)
		end
	end)
end

function Panel:_stopAmbient()
	if self.ambientHandle then
		self.ambientHandle:Stop()
		self.ambientHandle = nil
	end
end

function Panel:Ambient(p)
	local ambientFns = self.ambientFns
	ambientFns[#ambientFns + 1] = p

	if self.IsOpen then
		self:_startAmbient()
	end

	return {
		Stop = function(self)
			local index = table.find(ambientFns, p)

			if index then
				table.remove(ambientFns, index)
			end
		end
	}
end

function Panel:Open()
	if self.IsOpen then
		return false
	end

	self.IsOpen = true
	self.token += 1
	local opts = self.opts

	if not self.warm then
		self.warm = true

		if opts.Preload then
			for _, v3 in ipairs(opts.Preload) do
				;(sfx()).preload(v3)
			end
		end
	end

	if opts.OpenSound then
		;(sfx()).play(opts.OpenSound)
	end

	local v3 = not self.main.Visible

	if opts.DisableGui then
		self.gui.Enabled = true
	end

	self.main.Visible = true

	if v3 then
		spr.stop(self.scale)
		self.scale.Scale = opts.OpenFrom
	end

	Spring.to(self.scale, opts.Open, {
		Scale = 1
	})

	if self.fade then
		self.fade:Spring(0, opts.OpenFade)
	end

	local backdrop = opts.Backdrop

	if backdrop then
		backdrop.Visible = true
		Spring.to(backdrop, opts.OpenFade, {
			BackgroundTransparency = self.backdropRest
		})
	end

	self:_startAmbient()
	self.Opened:Fire()
	return true
end

function Panel:Close()
	if not self.IsOpen then
		return false
	end

	self.IsOpen = false
	self.token += 1
	local token = self.token
	local opts = self.opts

	if opts.CloseSound then
		;(sfx()).play(opts.CloseSound)
	end

	Spring.to(self.scale, opts.Close, {
		Scale = opts.CloseTo
	})

	if self.fade then
		self.fade:Spring(1, opts.CloseFade)
	end

	local backdrop = opts.Backdrop

	if backdrop then
		Spring.to(backdrop, opts.CloseFade, {
			BackgroundTransparency = 1
		})
	end

	self.Closed:Fire()
	task.delay(opts.Settle, function()
		if token ~= self.token or self.IsOpen then
			return
		end

		spr.stop(self.scale)
		self.main.Visible = false

		if self.fade then
			self.fade:Apply(0)
		end

		self.scale.Scale = 1

		if backdrop then
			spr.stop(backdrop)
			backdrop.Visible = false
			backdrop.BackgroundTransparency = 1
		end

		self:_stopAmbient()

		if opts.DisableGui then
			self.gui.Enabled = false
		end

		self.Hidden:Fire()
	end)
	return true
end

function Panel:Toggle()
	if self.IsOpen then
		self:Close()
	else
		self:Open()
	end

	return self.IsOpen
end

function Panel.OnOpen(p, onEvent)
	return p.Opened.Event:Connect(onEvent)
end

function Panel.OnClose(p, onEvent)
	return p.Closed.Event:Connect(onEvent)
end

function Panel.OnHidden(p, onEvent)
	return p.Hidden.Event:Connect(onEvent)
end

function Panel:Destroy()
	self:_stopAmbient()
	self.Opened:Destroy()
	self.Closed:Destroy()
	self.Hidden:Destroy()
end

Panel.Defaults = defaults
return Panel