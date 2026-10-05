local LightCubeController = {}
LightCubeController.__index = LightCubeController
local v = {
	ActiveColor = Color3.fromRGB(125, 182, 105),
	InactiveColor = Color3.fromRGB(0, 0, 0),
	TweenSpeed = 10,
	PatternSpeed = 1
}
local v2 = {}

local function mapPattern(p)
	if v2[p] then
		return p
	end

	if p == "Blackout" then
		return "FullOff"
	end

	if p == "Cross" or p == "ConcertScan" then
		return "Alternating"
	end

	if p == "Fan" then
		return "Pulse"
	elseif p == "SkyRise" then
		return "BottomUp"
	end

	return "Wave"
end

function v2:FullOff(_, _)
	self[1] = false
	self[2] = false
	self[3] = false
	self[4] = false
	self[5] = false
end

function v2:FullOn(_, _)
	self[1] = true
	self[2] = true
	self[3] = true
	self[4] = true
	self[5] = true
end

function v2:AudienceSweep(p, _)
	local v3 = math.floor(p * 6)
	self[1] = v3 >= 1
	self[2] = v3 >= 2
	self[3] = v3 >= 3
	self[4] = v3 >= 4
	self[5] = v3 >= 5
end

function v2:TopDown(p, _)
	local v3 = math.floor(p * 5) + 1
	self[1] = v3 == 1
	self[2] = v3 == 2
	self[3] = v3 == 3
	self[4] = v3 == 4
	self[5] = v3 == 5
end

function v2:BottomUp(p, _)
	local v3 = 5 - math.floor(p * 5)
	self[1] = v3 == 1
	self[2] = v3 == 2
	self[3] = v3 == 3
	self[4] = v3 == 4
	self[5] = v3 == 5
end

function v2:Wave(p, _)
	for i = 1, 5 do
		self[i] = math.sin(p * 3.141592653589793 * 2 + i * 0.5) > 0
	end
end

function v2:Pulse(p, _)
	local v3 = math.sin(p * 3.141592653589793 * 2) > 0
	self[1] = v3
	self[2] = v3
	self[3] = v3
	self[4] = v3
	self[5] = v3
end

function v2:Alternating(p, _)
	local v3 = math.sin(p * 3.141592653589793 * 2) > 0

	if v3 then
		self[1] = true
	else
		self[1] = false
	end

	if v3 then
		self[2] = false
	else
		self[2] = true
	end

	if v3 then
		self[3] = true
	else
		self[3] = false
	end

	if v3 then
		self[4] = false
	else
		self[4] = true
	end

	if v3 then
		self[5] = true
	else
		self[5] = false
	end
end

function v2:Mirror(p, _)
	local v3 = math.floor(p * 3)
	self[1] = false
	self[2] = false
	self[3] = false
	self[4] = false
	self[5] = false

	if v3 == 0 then
		self[3] = true
	elseif v3 == 1 then
		self[2] = true
		self[4] = true
	else
		self[1] = true
		self[5] = true
	end
end

function LightCubeController.new(items)
	local self = setmetatable({}, LightCubeController)
	self._config = {}

	for k, v3 in pairs(v) do
		self._config[k] = v3
	end

	if items then
		for k, item in pairs(items) do
			self._config[k] = item
		end
	end

	self._cubeGroups = {}
	self._activeState = {
		false,
		false,
		false,
		false,
		false
	}
	self._patternPhase = 0
	self._currentPatternName = "Wave"
	self._patternFunc = v2.Wave
	return self
end

function LightCubeController:scan(folder)
	table.clear(self._cubeGroups)

	if not folder then
		return
	end

	for _, model in ipairs(folder:GetDescendants()) do
		if not (model.Name == "LightCubes" and model:IsA("Model")) then
			continue
		end

		local v3 = {
			neonParts = {}
		}
		local flag = true

		for i = 1, 5 do
			local model2 = model:FindFirstChild((tostring(i)))

			if model2 and model2:IsA("Model") then
				local neon = model2:FindFirstChild("Neon")

				if neon and neon:IsA("BasePart") then
					v3.neonParts[i] = neon
					continue
				end
			end

			flag = false
			break
		end

		if flag then
			table.insert(self._cubeGroups, v3)
		end
	end

	warn(string.format("[LightCubeController] %d LightCubes détectés et mis en cache", #self._cubeGroups))
end

function LightCubeController:setPattern(currentPatternName)
	if not v2[currentPatternName] then
		if currentPatternName == "Blackout" then
			currentPatternName = "FullOff"
		elseif currentPatternName == "Cross" or currentPatternName == "ConcertScan" then
			currentPatternName = "Alternating"
		elseif currentPatternName == "Fan" then
			currentPatternName = "Pulse"
		elseif currentPatternName == "SkyRise" then
			currentPatternName = "BottomUp"
		else
			currentPatternName = "Wave"
		end
	end

	if v2[currentPatternName] then
		self._currentPatternName = currentPatternName
		self._patternFunc = v2[currentPatternName]
	end
end

function LightCubeController:update(p)
	if #self._cubeGroups == 0 then
		return
	end

	self._patternPhase += p * self._config.PatternSpeed

	if self._patternPhase >= 1 then
		self._patternPhase -= 1
	end

	if self._patternFunc then
		self._patternFunc(self._activeState, self._patternPhase, p)
	end

	local activeColor = self._config.ActiveColor
	local inactiveColor = self._config.InactiveColor
	local v3 = 1 - math.exp(-self._config.TweenSpeed * p)

	for _, _cubeGroup in ipairs(self._cubeGroups) do
		for i = 1, 5 do
			local neonPart = _cubeGroup.neonParts[i]
			local v4 = self._activeState[i] and activeColor or inactiveColor
			neonPart.Color = neonPart.Color:Lerp(v4, v3)
		end
	end
end

function LightCubeController:destroy()
	table.clear(self._cubeGroups)
end

return LightCubeController