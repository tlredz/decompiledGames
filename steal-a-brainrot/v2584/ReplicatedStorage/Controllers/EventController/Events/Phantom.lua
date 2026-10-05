local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.Shared.EventTypes)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Observers = require(ReplicatedStorage.Packages.Observers)
local name = script.Name
local maid = Trove.new()
local color = Color3.fromRGB(255, 255, 255)
local v = nil

local function getCaveParts()
	local map = workspace:FindFirstChild("Map")
	local cave = map and map:FindFirstChild("Cave")
	local collisions = cave and cave:FindFirstChild("Collisions")

	if not collisions then
		return nil
	end

	local descendants = collisions:QueryDescendants("BasePart")

	if #descendants == 0 then
		return nil
	end

	return descendants
end

local Phantom = {}

function Phantom.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	EffectController:Run("PhantomEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("PhantomEvent", "GrassRecolor")
	end)
	EffectController:Run("PhantomEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("PhantomEvent", "WallRecolor")
	end)
	EffectController:Run("PhantomEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("PhantomEvent", "WallBottomRecolor")
	end)
	maid:Add(Observers.observeTag("HideInPhantom", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	local phantomAtmosphere = script:FindFirstChild("PhantomAtmosphere")

	if phantomAtmosphere then
		local atmosphere = Lighting:FindFirstChild("Atmosphere")

		if atmosphere then
			atmosphere.Parent = script
			maid:Add(function()
				atmosphere.Parent = Lighting
			end)
		end

		local clone = maid:Clone(phantomAtmosphere)
		clone.Parent = Lighting
	end

	local phantomSky = script:FindFirstChild("PhantomSky")

	if phantomSky then
		local cartoon = Lighting:FindFirstChild("Cartoon") or Lighting:FindFirstChildOfClass("Sky")

		if cartoon then
			cartoon.Parent = script
			maid:Add(function()
				cartoon.Parent = Lighting
			end)
		end

		local clone_2 = maid:Clone(phantomSky)
		clone_2.Parent = Lighting
	end

	local phantomMap = not ServerData.IsTsunamiServer() and not ServerData.IsBiggerServer() and script:FindFirstChild("PhantomMap")

	if phantomMap then
		local clone_3 = maid:Clone(phantomMap)
		clone_3.Parent = workspace
	end

	local count = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function restoreCave()
		local v2 = v

		if not v2 then
			return
		end

		for k, color2 in v2 do
			if k.Parent then
				k.Color = color2
			end
		end
	end

	maid:Add(Net:RemoteEvent("GameService/PhantomCaveFlash").OnClientEvent:Connect(function()
		count += 1
		local v2 = count
		task.spawn(function()
			local caveParts = getCaveParts()

			if not caveParts then
				return
			end

			if not v then
				local colorsByCavePart = {}

				for _, cavePart in caveParts do
					colorsByCavePart[cavePart] = cavePart.Color
				end

				v = colorsByCavePart
			end

			assert(v)
			local v3 = v

			local function stillActive()
				return v2 == count
			end

			local lastTime = os.clock()

			while v2 == count do
				local v4 = os.clock() - lastTime

				if v4 >= 2 then
					break
				end

				local v5 = (1 - math.cos(v4 / 2 * 3.141592653589793 * 2 * 2)) / 2

				for _, cavePart in caveParts do
					local v6 = v3[cavePart]

					if v6 then
						cavePart.Color = v6:Lerp(color, v5)
					end
				end

				RunService.Heartbeat:Wait()
			end

			if v2 == count then
				restoreCave() -- equivalent call inferred; original call site unknown
			end
		end)
	end))
	maid:Add(function()
		count += 1
		restoreCave() -- equivalent call inferred; original call site unknown
	end)
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
end

function Phantom.OnStop(_)
	maid:Destroy()
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
end

function Phantom.OnLoad(_) end

return Phantom