local Spring = require(script.Parent:WaitForChild("Spring"))
local Ticker = require(script.Parent:WaitForChild("Ticker"))
local Juice = require(script.Parent:WaitForChild("Juice"))
local Store = require(script.Parent:WaitForChild("Store"))
local spr = Spring.spr
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function play(sound)
	if not sound then
		return
	end

	v = v or require(script.Parent:WaitForChild("SFX"))
	v.play(sound)
end

local TextFX = {}
local v2 = {
	"",
	"K",
	"M",
	"B",
	"T",
	"Qa",
	"Qi",
	"Sx",
	"Sp",
	"Oc"
}

function TextFX.abbreviate(p, p2)
	local v3 = tonumber(p) or 0
	local v4 = v3 < 0 and "-" or ""
	local v5 = math.abs(v3)

	if v5 < 1000 then
		return v4 .. tostring((math.floor(v5 + 0.5)))
	end

	local v6 = math.min(math.floor(math.log10(v5) / 3), #v2 - 1)
	local v7 = v5 / 1000 ^ v6
	local v8 = p2 or v7 < 10 and 2 or v7 < 100 and 1 or 0
	local v9 = string.format("%." .. v8 .. "f", v7)

	if v9:find(".", 1, true) then
		v9 = v9:gsub("0+$", ""):gsub("%.$", "")
	end

	return v4 .. v9 .. v2[v6 + 1]
end

function TextFX.money(p)
	return "$" .. TextFX.abbreviate(p)
end

function TextFX.rate(p)
	return "$" .. TextFX.abbreviate(p) .. "/s"
end

function TextFX.commas(p)
	return (tostring((math.floor(tonumber(p) or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

function TextFX.setAll(list, text)
	for _, v3 in ipairs(list) do
		v3.Text = text
	end
end

local v3 = Store.new()
local class = {}
class.__index = class

function class:Set(target, p)
	self.target = target
	Spring.to(self.driver, self.tuning, {
		Value = target
	})

	if p ~= false and self.punch then
		Juice.punch(self.label, self.punch, "Punch", "OdometerScale")
	end
end

function class:Snap(target)
	self.target = target
	spr.stop(self.driver)
	self.driver.Value = target
	self.label.Text = self.format(target)
end

function class:Stop()
	spr.stop(self.driver)
	self.connection:Disconnect()
	self.driver:Destroy()
	v3[self.label] = nil
end

function TextFX:odometer(p2, options)
	local v4 = options or {}
	local v5 = v3[self]

	if v5 then
		if v4.Format then
			v5.format = v4.Format
		end

		if v4.Tuning then
			v5.tuning = v4.Tuning
		end

		if v4.From then
			v5:Snap(v4.From)
		end
	else
		v5 = setmetatable({}, class)
		v5.label = self
		v5.format = v4.Format or TextFX.money
		v5.tuning = v4.Tuning or "Number"
		v5.punch = v4.Punch == nil and 1.12 or v4.Punch
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "OdometerDriver"
		numberValue.Value = v4.From or 0
		numberValue.Parent = self
		v5.driver = numberValue
		v5.connection = numberValue.Changed:Connect(function(p3)
			self.Text = v5.format(p3)
		end)
		v3[self] = v5

		if v4.From then
			self.Text = v5.format(v4.From)
		end
	end

	if p2 == nil then
		return v5
	end

	if v4.Instant then
		v5:Snap(p2)
	else
		local punch = v4.Punch
		v5:Set(p2, punch)
	end

	return v5
end

local v4 = Store.new()

function TextFX:typewriter(text, options)
	local v5 = options or {}
	local v6 = v4[self]

	if v6 then
		v6:Stop()
	end

	if text ~= nil then
		self.Text = text
	end

	local v7 = utf8.len(self.Text) or #self.Text
	local CPS = v5.CPS or 45
	local total = 0
	self.MaxVisibleGraphemes = 0
	local class2 = {}
	local v8 = 0
	local whileVisible = Ticker.whileVisible(self, function(p2)
		total += p2 * CPS
		local maxVisibleGraphemes = math.min(math.floor(total), v7)

		if maxVisibleGraphemes ~= v8 then
			self.MaxVisibleGraphemes = maxVisibleGraphemes
			local sound = v5.Sound and v5.Sound
			play(sound) -- equivalent call inferred; original call site unknown
			v8 = maxVisibleGraphemes
		end

		if v7 <= maxVisibleGraphemes then
			class2:Stop()

			if v5.Punch ~= false then
				Juice.punch(self, v5.Punch or 1.06, "Punch", "OdometerScale")
			end

			if v5.OnDone then
				v5.OnDone()
			end
		end
	end)

	function class2.Stop(_)
		if whileVisible then
			whileVisible:Stop()
			whileVisible = nil
		end

		self.MaxVisibleGraphemes = -1
		v4[self] = nil
	end

	function class2.Skip(_)
		class2:Stop()
	end

	v4[self] = class2
	return class2
end

function TextFX:scramble(p2, options)
	local v5 = options or {}
	local v6 = v4[self]

	if v6 then
		v6:Stop()
	end

	local text = p2 or self.Text
	local v8 = {}

	for _, v9 in utf8.codes(text) do
		v8[#v8 + 1] = utf8.char(v9)
	end

	local count = #v8
	local duration = v5.Duration or 0.5
	local chars = v5.Chars or "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#%&@$*+=<>/\\|"
	local random = Random.new()
	local total = 0
	self.MaxVisibleGraphemes = -1
	local mirror = v5.Mirror
	local class2 = {}
	local v9 = table.create(count)
	local whileVisible = Ticker.whileVisible(self, function(p3)
		total += p3
		local v10 = math.clamp(total / duration, 0, 1)
		local v11 = math.floor(v10 * count + 0.0001)

		for i = 1, count do
			local v12 = v8[i]

			if i <= v11 or v12 == " " then
				v9[i] = v12
			else
				local integer = random:NextInteger(1, #chars)
				v9[i] = chars:sub(integer, integer)
			end
		end

		local joined = table.concat(v9)
		self.Text = joined

		if mirror then
			for _, v12 in ipairs(mirror) do
				v12.Text = joined
			end
		end

		if v10 >= 1 then
			class2:Stop()

			if v5.OnDone then
				v5.OnDone()
			end
		end
	end, 1 / (v5.Rate or 30), function()
		self.Text = text

		if mirror then
			for _, v10 in ipairs(mirror) do
				v10.Text = text
			end
		end
	end)

	function class2.Stop(_)
		if whileVisible then
			whileVisible:Stop()
			whileVisible = nil
		end

		self.Text = text

		if mirror then
			for _, v10 in ipairs(mirror) do
				v10.Text = text
			end
		end

		v4[self] = nil
	end

	v4[self] = class2
	return class2
end

function TextFX.pop(p, value)
	return Juice.punch(p, value or 1.15, "Punch", "OdometerScale")
end

function TextFX.wave(p, p2)
	local Wave = require(script.Parent:WaitForChild("Wave"))
	return Wave.attach(p, p2)
end

function TextFX.revealAll(folder, options)
	local result = {}

	local function excluded(parent)
		while parent and parent ~= folder do
			if parent:GetAttribute("NoScramble") == true then
				return true
			else
				parent = parent.Parent
			end
		end

		return folder:GetAttribute("NoScramble") == true
	end

	local function consider(guiObject)
		if not ((guiObject:IsA("TextLabel") or guiObject:IsA("TextButton")) and guiObject.Name ~= "Shadow" and guiObject:GetAttribute("RiftText") ~= true and guiObject.Text ~= "") then
			return
		end

		if excluded(guiObject) then
			return
		end

		result[#result + 1] = guiObject
	end

	consider(folder)
	local v5 = options or {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		consider(descendant)
	end

	if #result == 0 then
		return result
	end

	if (v5.Order or "Grid") == "Grid" then
		local v6 = {}

		for _, v7 in ipairs(result) do
			local absolutePosition = v7.AbsolutePosition
			v6[v7] = absolutePosition.X + absolutePosition.Y * 1.35
		end

		table.sort(result, function(a, b)
			return v6[a] < v6[b]
		end)
	end

	local maxLabels = v5.MaxLabels or 24

	if maxLabels < #result then
		for i = #result, maxLabels + 1, -1 do
			result[i] = nil
		end
	end

	local delay = v5.Delay or 0
	local step = v5.Step or 0.02
	local maxTotal = v5.MaxTotal or 0.28
	local count = #result

	if count > 1 and maxTotal < delay + step * (count - 1) then
		step = math.max(0, (maxTotal - delay) / (count - 1))
	end

	for i, v6 in ipairs(result) do
		local shadow = v6:FindFirstChild("Shadow")
		local mirror = shadow and shadow:IsA("TextLabel") and { shadow } or nil
		local v8 = delay + step * (i - 1)
		local v9 = v6

		local function fire()
			if not v9.Parent then
				return
			end

			TextFX.scramble(v9, v9.Text, {
				Duration = v5.Duration or 0.34,
				Rate = v5.Rate or 30,
				Chars = v5.Chars,
				Mirror = mirror
			})
		end

		if v8 <= 0 then
			fire()
		else
			task.delay(v8, fire)
		end
	end

	return result
end

return TextFX