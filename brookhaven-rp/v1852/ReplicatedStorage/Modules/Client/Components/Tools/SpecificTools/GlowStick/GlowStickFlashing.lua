local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "GlowStickFlashing"
})

local function readPalette(instance)
	local result = {}
	local flashingColors = instance:FindFirstChild("FlashingColors")

	if flashingColors == nil then
		return result
	end

	local color3Values = {}

	for _, color3Value in flashingColors:GetChildren() do
		if color3Value:IsA("Color3Value") then
			table.insert(color3Values, color3Value)
		end
	end

	table.sort(color3Values, function(a, b)
		local name = tonumber(a.Name)
		local name2 = tonumber(b.Name)

		if name == nil or name2 == nil then
			return a.Name < b.Name
		end

		return name < name2
	end)

	for _, v2 in color3Values do
		table.insert(result, v2.Value)
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveInterval(instance)
	local BPM = instance:GetAttribute("BPM")

	if type(BPM) == "number" and BPM > 0 then
		return 60 / BPM
	end

	local flashingInterval = instance:GetAttribute("FlashingInterval")

	if type(flashingInterval) == "number" then
		return flashingInterval
	end

	return 0.15
end

local function checkStateChanged(state)
	local instance = state.Instance
	local flashing = instance:GetAttribute("Flashing")

	if state._task ~= nil then
		task.cancel(state._task)
		state._task = nil
	end

	if not flashing then
		return
	end

	local descendants = {}

	for _, descendant in instance:GetDescendants() do
		if descendant:HasTag("UIColorPicker_ChangeColor") then
			table.insert(descendants, descendant)
		end
	end

	local interval = resolveInterval(instance) -- equivalent call inferred; original call site unknown
	local v2 = readPalette(instance)
	state._task = task.spawn(function()
		local v3 = 1

		while RunService:IsRunning() do
			local color

			if #v2 > 0 then
				color = v2[v3]
				v3 = v3 % #v2 + 1
			else
				color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
			end

			for _, v4 in descendants do
				v4.Color = color
			end

			task.wait(interval)
		end
	end)
end

function v:Construct()
	self._janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("Tool") then
		return
	end

	self._janitor:Add(instance:GetAttributeChangedSignal("Flashing"):Connect(function()
		checkStateChanged(self)
	end))
	checkStateChanged(self)
end

function v:Stop()
	if self._task ~= nil then
		task.cancel(self._task)
		self._task = nil
	end

	self._janitor:Destroy()
end

return v