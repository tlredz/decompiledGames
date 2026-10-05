local ReplicatedStorage = game:GetService("ReplicatedStorage")
local effect = ReplicatedStorage:WaitForChild("Effect")
local Payload = require(effect.Payload)
local Mouse = require(ReplicatedStorage.Mouse)
local ClockBudget = require(ReplicatedStorage.Util.ClockBudget)
local clockBudget = ClockBudget(0.016666666666666666)
local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer and localPlayer:GetMouse()
local lastTime = tick()
local v2 = 0.03333333333333333
local v3 = 1 / v2
local v4 = 0
local v5 = 0
local v6 = 0
local v7 = 1
local v8 = 0
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	local v9 = tick() - lastTime
	v4 += v9
	v5 += 1

	if v5 > 500 then
		v4 /= v5
		v2 = math.max(v4 * 1.1, 0.008333333333333333)
		v3 = 1 / v2
		v5 = 1
	end

	v6 += v9
	v7 *= 0.5

	if v7 <= 0.25 then
		v6 *= v7
		v7 = 1
	end

	lastTime = tick()
end)
local Global = require(ReplicatedStorage.Global)

function Global.isClientFramedropping()
	local now = tick()
	local v9 = v6 * v7

	if v2 < v9 then
		v8 = now + 2
		return v9 * v3
	end

	if now < v8 then
		return v9 * v3
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function makeDisconnectedConnection(fn)
	local v9 = {
		Connected = true,
		Disconnect = function(self)
			if not self.Connected then
				return
			end

			self.Connected = false
			fn()
		end
	}
	v9.disconnect = v9.Disconnect
	return v9
end

local function makeCharacterRemovedSignal(character, fn)
	local v9 = {
		Connect = function(self, callback)
			local ancestryChangedConnection = nil
			local flag = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function fire()
				if flag then
					return
				end

				flag = true

				if ancestryChangedConnection then
					ancestryChangedConnection:Disconnect()
				end

				task.spawn(callback, fn())
			end

			if character.Parent ~= nil then
				ancestryChangedConnection = character.AncestryChanged:Connect(function(_, parent)
					if parent == nil then
						fire() -- equivalent call inferred; original call site unknown
					end
				end)
				return ancestryChangedConnection
			end

			task.defer(fire)

			local function fn2()
				flag = true
			end

			return makeDisconnectedConnection(fn2)
		end,
		Once = function(self, callback)
			return self:Connect(callback)
		end
	}
	v9.connect = v9.Connect
	v9.once = v9.Once
	return v9
end

-- equivalent calls inferred from this helper; original call sites unknown
local function parentOfInstance(HRP)
	if not (typeof(HRP) ~= "Instance" and type(HRP) ~= "table") then
		return HRP.Parent
	end

	return nil
end

local function hydrateFakeEffectPlayer(Mouses)
	local character = Mouses.Character

	if typeof(character) ~= "Instance" or not character:IsA("Model") then
		return
	end

	Mouses.CharacterRemoving = makeCharacterRemovedSignal(character, function()
		return character
	end)
	Mouses.PlayerRemoving = makeCharacterRemovedSignal(character, function()
		return Mouses
	end)
	Mouses.Name = character.Name
	Mouses.ClassName = "Player"
	Mouses.Parent = game.Players

	function Mouses:IsA(p: string)
		return p == "Player"
	end

	function Mouses:GetAttribute(attributeName: string)
		return character:GetAttribute(attributeName)
	end

	function Mouses:SetAttribute(p: string, p2)
		return character:SetAttribute(p, p2)
	end

	function Mouses:FindFirstChild(childName: string, flag: boolean?)
		return character:FindFirstChild(childName, flag)
	end

	function Mouses:WaitForChild(childName: string, p: number?)
		if p == nil then
			return character:WaitForChild(childName)
		end

		return character:WaitForChild(childName, p)
	end

	function Mouses:GetFullName()
		return character:GetFullName()
	end

	return Mouses
end

local prepareEffectData

prepareEffectData = function(Mouses, p)
	if type(Mouses) ~= "table" or p[Mouses] then
		return
	end

	p[Mouses] = true

	if rawget(Mouses, "__EffectFakePlayer") == true then
		hydrateFakeEffectPlayer(Mouses)
		return
	end

	if rawget(Mouses, "SourcePlayer") then
		Payload.hydrateSourcePlayerProxy(Mouses)
	end

	for k, item in Mouses do
		if item == mouse then
			Mouses[k] = Mouse
		else
			prepareEffectData(item, p)
		end
	end
end

local function onEffectSpawn(value, value2, p, p2)
	if value == "spawn" then
		value = value2
		value2 = p
		p = p2
	end

	if typeof(value) == "function" then
		return value()
	end

	if typeof(value) == "Instance" and value.ClassName ~= "ModuleScript" and typeof(value2) == "number" then
		task.delay(value2, function()
			value:Destroy()
		end)
		return
	end

	while clockBudget() do

	end

	prepareEffectData(value2, {})

	if type(value2) == "table" and (not value2.player or typeof(value2.player) ~= "Instance" or not value2.player:IsA("Player")) then
		local char = value2.char or value2.Character

		if not char then
			local root = value2.root

			if typeof(root) == "Instance" then
				char = root.Parent
			elseif type(root) == "table" then
				char = root.Parent
			else
				char = nil
			end

			if not char then
				local hrp = value2.hrp

				if typeof(hrp) == "Instance" then
					char = hrp.Parent
				elseif type(hrp) == "table" then
					char = hrp.Parent
				else
					char = nil
				end

				if not char then
					local root2 = value2.Root

					if typeof(root2) == "Instance" then
						char = root2.Parent
					elseif type(root2) == "table" then
						char = root2.Parent
					else
						char = nil
					end

					if not char then
						local v11 = parentOfInstance(value2.HRP) -- equivalent call inferred; original call site unknown
						char = v11 or value2.plr or value2.player
					end
				end
			end
		end

		value2.player = hydrateFakeEffectPlayer({
			Character = char
		})

		if not value2.Player or typeof(value2.Player) ~= "Instance" or not value2.Player:IsA("Player") then
			value2.Player = value2.player
		end

		if not value2.plr or typeof(value2.plr) ~= "Instance" or not value2.plr:IsA("Player") then
			value2.plr = value2.player
		end
	end

	local module = require(value)

	if type(module) == "function" then
		module(value2, p)
	else
		module.new(value2):Run()
	end
end

return {
	start = function()
		local eventConnection = effect:WaitForChild("Bindable").Event:Connect(onEffectSpawn)
		return function()
			eventConnection:Disconnect()
		end
	end
}