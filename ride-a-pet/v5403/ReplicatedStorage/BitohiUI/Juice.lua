local Spring = require(script.Parent:WaitForChild("Spring"))
local Ticker = require(script.Parent:WaitForChild("Ticker"))
local Store = require(script.Parent:WaitForChild("Store"))
local spr = Spring.spr
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function play(p)
	if not p then
		return
	end

	v = v or require(script.Parent:WaitForChild("SFX"))
	v.play(p)
end

local Juice = {
	Defaults = {
		Hover = 1.07,
		Press = 0.93,
		ScaleName = "JuiceScale",
		HoverSound = "Common.ButtonHover",
		Sound = nil,
		HoverTuning = "Hover",
		PressTuning = "Press",
		RotateTuning = "Rotate"
	}
}
local v2 = Store.new()

function Juice.bind(instance, options)
	if instance:GetAttribute("UIJuice") == false then
		return function() end
	end

	if v2[instance] then
		v2[instance]()
	end

	local v3 = options or {}
	local defaults = Juice.Defaults
	local hover = v3.Hover or defaults.Hover
	local press = v3.Press or defaults.Press
	local hoverRotation = v3.HoverRotation
	local sound = v3.Sound or defaults.Sound
	local hoverSound = v3.HoverSound == nil and defaults.HoverSound or v3.HoverSound
	local scaleName = v3.ScaleName or defaults.ScaleName
	local scaled = Spring.scale(instance, scaleName)
	local rotation = instance.Rotation
	local flag = false
	local flag2 = false

	local function refresh()
		local scale = 1
		local hoverTuning = defaults.HoverTuning

		if flag2 then
			scale = press
			hoverTuning = defaults.PressTuning
		elseif flag then
			scale = hover
		end

		Spring.to(scaled, hoverTuning, {
			Scale = scale
		})

		if hoverRotation then
			Spring.to(instance, defaults.RotateTuning, {
				Rotation = flag and rotation + hoverRotation or rotation
			})
		end
	end

	local v4 = {
		instance.MouseEnter:Connect(function()
			flag = true
			play(hoverSound) -- equivalent call inferred; original call site unknown
			refresh()
		end),
		instance.MouseLeave:Connect(function()
			flag = false
			flag2 = false
			refresh()
		end),
		instance.MouseButton1Down:Connect(function()
			flag2 = true
			play(sound) -- equivalent call inferred; original call site unknown
			refresh()
		end),
		instance.MouseButton1Up:Connect(function()
			flag2 = false
			refresh()
		end),
		(instance.TouchTap:Connect(function()
			spr.stop(scaled)
			scaled.Scale = press
			Spring.to(scaled, defaults.PressTuning, {
				Scale = 1
			})
		end))
	}

	local function unbind()
		for _, connection in ipairs(v4) do
			connection:Disconnect()
		end

		v2[instance] = nil
		spr.stop(scaled)
		scaled.Scale = 1
	end

	v2[instance] = unbind
	return unbind
end

function Juice.bindAll(folder, p)
	local v3 = {}

	for _, button in ipairs(folder:GetDescendants()) do
		if button:IsA("GuiButton") then
			v3[#v3 + 1] = Juice.bind(button, p)
		end
	end

	return function()
		for _, v4 in ipairs(v3) do
			v4()
		end
	end
end

function Juice.unbind(p)
	local v3 = v2[p]

	if v3 then
		v3()
	end
end

function Juice.punch(p, value, value2, value3)
	return Spring.scaleFrom(p, value or 1.22, value2 or "Punch", value3 or "AnimScale")
end

function Juice.pop(p, value, value2, value3)
	return Spring.scaleFrom(p, value or 0.4, value2 or "Pop", value3 or "AnimScale")
end

function Juice.popOut(p, value, p2, value2)
	local scaled = Spring.scale(p, value2 or "AnimScale")
	Spring.to(scaled, "PopOut", {
		Scale = value or 0
	})

	if p2 then
		spr.completed(scaled, p2)
	end

	return scaled
end

function Juice.pulse(p, value, value2, value3)
	local scaled = Spring.scale(p, value3 or "AnimScale")
	local v3 = (scaled:GetAttribute("PulseToken") or 0) + 1
	scaled:SetAttribute("PulseToken", v3)
	spr.stop(scaled)
	scaled.Scale = 1
	local v4 = true
	local beat

	beat = function()
		if scaled:GetAttribute("PulseToken") ~= v3 or not p.Parent then
			return
		end

		Spring.to(scaled, value2 or "Pulse", {
			Scale = v4 and (value or 1.05) or 1
		})
		v4 = not v4
		spr.completed(scaled, beat)
	end

	beat()
	return function()
		if scaled:GetAttribute("PulseToken") == v3 then
			scaled:SetAttribute("PulseToken", v3 + 1)
			spr.stop(scaled)
			scaled.Scale = 1
		end
	end
end

function Juice.stopPulse(p, value)
	local scale = Spring.findScale(p, value or "AnimScale")

	if scale then
		scale:SetAttribute("PulseToken", (scale:GetAttribute("PulseToken") or 0) + 1)
		spr.stop(scale)
		scale.Scale = 1
	end
end

function Juice:shake(value)
	spr.stop(self, "Rotation")
	self.Rotation = value or 6
	Spring.to(self, "Wobble", {
		Rotation = 0
	})
end

local v3 = Store.new()

function Juice:wiggle(value)
	local position = v3[self] or self.Position
	v3[self] = position
	spr.stop(self, "Position")
	self.Position = position + UDim2.fromOffset(value or 10, 0)
	Spring.to(self, "Wobble", {
		Position = position
	})
end

function Juice:float(options)
	local v4 = options or {}
	local distance = v4.Distance or 6
	local duration = v4.Duration or 1.4
	local sway = v4.Sway or 0
	local swayDuration = v4.SwayDuration or 1.9
	local position = self.Position
	local rotation = self.Rotation
	local phase = v4.Phase or 0
	local whileVisible = Ticker.whileVisible(self, function(p)
		phase += p
		self.Position = position + UDim2.fromOffset(0, -distance * math.cos(phase * 3.141592653589793 / duration))

		if sway > 0 then
			self.Rotation = rotation + sway * math.sin(phase * 3.141592653589793 / swayDuration)
		end
	end, 0, function()
		self.Position = position

		if sway > 0 then
			self.Rotation = rotation
		end
	end)
	return function()
		whileVisible:Stop()
		self.Position = position

		if sway > 0 then
			self.Rotation = rotation
		end
	end
end

local rotations = Store.new()
local v4 = Store.new()
local random = Random.new()

function Juice:jolt(options)
	local v5 = options or {}
	local scale = v5.Scale or 1.22
	local rotation = v5.Rotation or 10
	local vary = v5.Vary or 0.45
	local rotation2 = rotations[self]

	if rotation2 == nil then
		rotation2 = self.Rotation
		rotations[self] = rotation2
	end

	Juice.punch(
		self,
		scale * (1 + random:NextNumber(-vary, vary) * 0.25),
		v5.Tuning or "Punch",
		v5.ScaleName or "JoltScale"
	)

	if rotation == 0 then
		return self
	end

	local v6 = v4[self] == true
	v4[self] = not v6
	local v7 = rotation * random:NextNumber(1 - vary, 1 + vary)
	spr.stop(self, "Rotation")
	self.Rotation = rotation2 + (v6 and 1 or -1) * v7
	Spring.to(self, v5.Back or "Soft", {
		Rotation = rotation2
	})
	return self
end

return Juice