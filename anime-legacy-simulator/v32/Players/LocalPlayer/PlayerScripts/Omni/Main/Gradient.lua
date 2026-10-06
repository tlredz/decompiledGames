local module = require("@game/ReplicatedStorage/Omni")
local playerGui = module.Instance:WaitForChild("PlayerGui")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local flag = false
local v7 = 0
local class = {}
class.__index = class
local Gradient = {}
local GetBlocker

GetBlocker = function(parent)
	if not parent then
		return true
	end

	local v8 = v5[parent]

	if v8 ~= nil then
		return v8
	end

	local v9

	if parent:IsA("LayerCollector") then
		if parent:IsDescendantOf(playerGui) or parent:IsDescendantOf(workspace) then
			if parent.Enabled then
				v9 = false
			else
				v9 = parent
			end
		else
			v9 = true
		end
	elseif parent:IsA("GuiObject") and not parent.Visible or parent:IsA("UIStroke") and not parent.Enabled then
		v9 = parent
	else
		v9 = GetBlocker(parent.Parent)
	end

	v5[parent] = v9
	return v9
end

-- equivalent calls inferred from this helper; original call sites unknown
local function SetBlocker(object, guiObject)
	local blocker = object.Blocker

	if blocker == guiObject then
		return
	end

	local v8 = blocker and v4[blocker]

	if v8 then
		v8.Gradients[object] = nil

		if next(v8.Gradients) == nil then
			v8.Connection:Disconnect()
			v4[blocker] = nil
		end
	end

	object.Blocker = guiObject

	if not guiObject then
		return
	end

	local v9 = v4[guiObject]

	if not v9 then
		local v10 = guiObject:IsA("GuiObject") and "Visible" or "Enabled"
		v9 = {
			Gradients = {}
		}
		v9.Connection = guiObject:GetPropertyChangedSignal(v10):Connect(function()
			for k in v9.Gradients do
				v3[k] = true
			end
		end)
		v4[guiObject] = v9
	end

	v9.Gradients[object] = true
end

local function GetRarityResult(rarity, now: number)
	local mode = rarity.Mode or "Default"
	local v8 = nil

	if mode == "Default" then
		return {
			Rotation = now % 5 / 5 * 360,
			Color = rarity.Gradient
		}
	end

	if mode == "Wave" and rarity.Wave then
		local v9 = now % 3 / 3
		local colorSequenceKeypoints = {}

		for i = 0, 1, 0.1 do
			local v10 = math.sin((i - v9) * 3.141592653589793 * 2) * 0.5 + 0.5
			local lerped = rarity.Color:Lerp(rarity.Wave, v10)
			table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(i, lerped))
		end

		return {
			Color = ColorSequence.new(colorSequenceKeypoints)
		}
	elseif mode == "Matrix" then
		local v9 = now % 5 / 5
		local rotation, v11

		if v9 < 0.5 then
			local v12 = v9 * 2
			rotation = 90

			if v12 < 0.5 then
				v11 = v12 / 0.5 + -0.5
			else
				v11 = 0.5
			end
		else
			local v12 = (v9 - 0.5) * 2
			rotation = -90

			if v12 < 0.5 then
				v11 = v12 / 0.5 + -0.5
			else
				v11 = 0.5
			end
		end

		return {
			Rotation = rotation,
			Color = rarity.Gradient,
			Offset = Vector2.new(0, v11)
		}
	else
		if mode ~= "Rainbow" then
			return v8
		end

		local v9 = now % 5 / 5
		local colorSequenceKeypoints = {}

		for i = 0, 1, 0.1 do
			local v10 = (v9 - i) % 1
			local v11 = math.sin(v10 * 3.141592653589793 * 2) * 0.5 + 0.5
			local v12 = math.sin(v10 * 3.141592653589793 * 2 + 2.0943951023931953) * 0.5 + 0.5
			local v13 = math.sin(v10 * 3.141592653589793 * 2 + 4.1887902047863905) * 0.5 + 0.5
			local color = Color3.new(v11, v12, v13)
			table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(i, color))
		end

		return {
			Color = ColorSequence.new(colorSequenceKeypoints)
		}
	end
end

function Gradient.CreateGradient(_, uIGradient)
	if not (uIGradient and uIGradient:IsA("UIGradient")) then
		return
	end

	local v8 = v[uIGradient]

	if v8 then
		return v8
	end

	local object = setmetatable({}, class)
	object.Instance = uIGradient
	object.Connections = {}
	object.Paused = false
	object.Originals = {
		Color = uIGradient.Color,
		Offset = uIGradient.Offset,
		Rotation = uIGradient.Rotation
	}
	object.Connections.Changed = uIGradient:GetAttributeChangedSignal("Rarity"):Connect(function()
		object:Update()
	end)
	object.Connections.Enabled = uIGradient:GetPropertyChangedSignal("Enabled"):Connect(function()
		v3[object] = true
	end)
	object.Connections.Destroyed = uIGradient.AncestryChanged:Connect(function(_, parent)
		if object.Instance and parent then
			v3[object] = true
		else
			object:Destroy()
		end
	end)
	v[uIGradient] = object
	object:Update()
	return object
end

function class:Update()
	local rarity = self.Instance:GetAttribute("Rarity")
	self:SetupOriginals()
	v3[self] = true

	if rarity == "" or rarity == nil then
		self.Rarity = nil
		return
	end

	local colorSequenceFromRarity = module.Utils.Colors:GetColorSequenceFromRarity(rarity)

	if not colorSequenceFromRarity then
		return
	end

	self.Rarity = rarity
	self.Instance.Color = colorSequenceFromRarity
	self.Instance.Rotation = self.Originals.Rotation
end

function class:Play()
	if not self.Instance then
		return
	end

	self.Paused = false
	v3[self] = true
end

function class:Pause()
	if not self.Instance then
		return
	end

	self.Paused = true
	v2[self] = nil
	v3[self] = true
end

function class:RefreshVisibility()
	if not self.Instance then
		return
	end

	local v8 = (self.Ended or self.Paused or not (self.Rarity and self.Instance.Enabled)) and true or GetBlocker(self.Instance.Parent)
	local v10

	if typeof(v8) == "Instance" then
		v10 = v8
	end

	SetBlocker(self, v10)

	if v8 == false then
		v2[self] = true
	else
		v2[self] = nil
	end
end

function class:SetupOriginals()
	if not self.Instance then
		return
	end

	self.Instance.Color = self.Originals.Color
	self.Instance.Offset = self.Originals.Offset
	self.Instance.Rotation = self.Originals.Rotation
end

function class:Destroy()
	self.Ended = true

	for k, connection in self.Connections do
		connection:Disconnect()
		self.Connections[k] = nil
	end

	v2[self] = nil
	v3[self] = nil
	SetBlocker(self, nil) -- equivalent call inferred; original call site unknown
	self:SetupOriginals()
	v[self.Instance] = nil
	self.Instance = nil
end

module.Services.RunService.Heartbeat:Connect(function()
	if module.Data.Settings["Low Mode"] or module.Data.Settings["Static Gradients"] then
		if flag then
			return
		end

		flag = true

		for _, v8 in v do
			v8:Update()
		end
	else
		flag = false
		local now = os.clock()

		if now - v7 >= 0.25 then
			v7 = now

			for _, v8 in v do
				v8:RefreshVisibility()
			end

			table.clear(v3)
		elseif next(v3) then
			for k in v3 do
				k:RefreshVisibility()
			end

			table.clear(v3)
		end

		table.clear(v5)
		table.clear(v6)
		local now2 = tick()
		local rarities = module.Utils.Colors.Rarities

		for k in v2 do
			local rarity = k.Rarity

			if not rarity then
				continue
			end

			local v8 = v6[rarity]

			if v8 == nil then
				local rarity2 = rarities[rarity]

				if rarity2 then
					v8 = GetRarityResult(rarity2, now2) or false
				else
					v8 = false
				end

				v6[rarity] = v8
			end

			if not v8 then
				continue
			end

			local instance = k.Instance

			if v8.Color then
				instance.Color = v8.Color
			end

			if v8.Offset then
				instance.Offset = v8.Offset
			end

			if v8.Rotation then
				instance.Rotation = v8.Rotation
			end
		end
	end
end)
return Gradient