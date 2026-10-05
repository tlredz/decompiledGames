local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local Strawberry = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.TsunamiEventController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
require(ReplicatedStorage.Controllers.SoundController)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Strawberry/Burst")
local maid = Trove.new()

local function growBush(folder, p: number, callback)
	local function growPart(state, size: Vector3, p2: number, flag: boolean?)
		local cFrame = state.CFrame
		local vector = Vector3.new(flag and 0 or size.X, 0, flag and 0 or size.Z)
		local cFrame2 = cFrame * CFrame.new(0, -(size.Y - vector.Y) / 2, 0)
		state.Size = vector
		state.CFrame = cFrame2
		local transparency = state.Transparency
		state.Transparency = 1
		local maid2 = maid
		local v2

		if callback then
			v2 = callback(p2)
		else
			v2 = p2
		end

		maid2:Add(task.delay(v2, function()
			state.Transparency = transparency
			local v3 = math.max(not callback and 1 or callback(p2 + 1), 0.05)
			CreateTween(state, TweenInfo.new(v3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = size,
				CFrame = cFrame
			})
		end))
	end

	local parts = {}
	local v = 1e999
	local v2 = -1e999

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.Transparency < 1) then
			continue
		end

		table.insert(parts, part)
		v = math.min(v, part.Position.Y)
		v2 = math.max(v2, part.Position.Y)
	end

	table.sort(parts, function(a, b)
		return a.Position.Y < b.Position.Y
	end)
	local v3 = math.max(v2 - v, 0.001)

	for _, v4 in parts do
		local v5 = (v4.Position.Y - v) / v3 * p + 0.25
		local model = v4:FindFirstAncestorOfClass("Model")
		local v6

		if model == nil then
			v6 = false
		else
			v6 = model.Name == "strawberry"
		end

		if v6 then
			v5 += 1
		end

		growPart(v4, v4.Size, v5, v6)
	end
end

local function spawnBushesIncrementally(fn)
	local modelsByName = {}

	for _, model in script.BushTemplates:GetChildren() do
		if model:IsA("Model") then
			modelsByName[model.Name] = model
		end
	end

	local v = ServerData.IsTsunamiServer() and "Tsunami" or ServerData.IsBiggerServer() and "Bigger" or "Default"
	local child = script.BushPlacements:FindFirstChild(v)

	if not child then
		warn((`[Strawberry] missing bush placements for variant "{v}"`))
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "StrawberryBushes"
	maid:Add(folder)
	folder.Parent = workspace
	local random = Random.new()
	maid:Add(task.spawn(function()
		local lastTime = os.clock()

		for _, part in child:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			local v2 = modelsByName[part.Name]

			if not v2 then
				continue
			end

			local clone = v2:Clone()
			clone:PivotTo(part.CFrame)
			growBush(clone, random:NextNumber(5, 7), fn)
			clone.Parent = folder

			if not (os.clock() - lastTime >= 0.002) then
				continue
			end

			task.wait()
			lastTime = os.clock()
		end
	end))
end

function Strawberry.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	ReplicatedStorage:SetAttribute("StrawberryEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("StrawberryEvent", nil)
	end)
	EffectController:Activate("Blink")
	EffectController:Run("StrawberryEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("StrawberryEvent", "GrassRecolor")
		EffectController:Activate("Blink")
	end)
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.Atmosphere)
	clone_2.Parent = Lighting
	local sky = Lighting:FindFirstChildOfClass("Sky")

	if sky then
		sky.Parent = script
		maid:Add(function()
			sky.Parent = Lighting
		end)
	end

	local clone_3 = maid:Clone(script.Sky)
	clone_3.Parent = Lighting

	if ServerData.IsJumpLTMServer() then
		maid:Add(JumpLTMWeather.Cover(script.StrawberryVFX))
	else
		local clone

		if ServerData.IsTsunamiServer() then
			clone = maid:Clone(script.StrawberryVFXTsunami)
		else
			clone = maid:Clone(script.StrawberryVFX)
		end

		clone.Parent = workspace

		if ServerData.IsBiggerServer() then
			ClientEventUtils.resizeEffects(clone, 2)
		end

		VFX.enable(clone)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function calculateTimeLeftFor(p)
		return activeEventData.startedAt + p - workspace:GetServerTimeNow()
	end

	if not ServerData.IsJumpLTMServer() then
		spawnBushesIncrementally(function(p: number)
			return calculateTimeLeftFor(p)
		end)
	end
end

function Strawberry.OnStop(_)
	maid:Destroy()
end

function Strawberry.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events.Strawberry.BrainrotHit })
	end)
end

return Strawberry