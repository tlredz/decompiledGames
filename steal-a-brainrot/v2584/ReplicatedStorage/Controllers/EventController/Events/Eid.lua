local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
require(ReplicatedStorage.Shared.EventTypes)
local Eid = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local SharedEventUtils = require(ReplicatedStorage.Shared.SharedEventUtils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local v = {
	Red = Color3.fromRGB(255, 50, 50),
	Green = Color3.fromRGB(50, 200, 50),
	Blue = Color3.fromRGB(50, 100, 255),
	Orange = Color3.fromRGB(255, 150, 30),
	Purple = Color3.fromRGB(160, 50, 220),
	Yellow = Color3.fromRGB(255, 230, 50),
	Rainbow = Color3.fromRGB(255, 255, 255)
}
local remoteEvent = Net:RemoteEvent("EventService/Eid/Burst")
local maid = Trove.new()

function Eid.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	CycleController:Update()
	SoundController:UpdateOST()
	EffectController:Activate("Blink")
	local clone

	if ServerData.IsBiggerServer() then
		clone = maid:Clone(script.BiggerEidMap)
	elseif ServerData.IsTsunamiServer() then
		clone = maid:Clone(script.TsunamiEidMap)
	else
		clone = maid:Clone(script.EidMap)
	end

	clone.Parent = workspace
	EffectController:Run("EidEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("EidEvent", "GrassRecolor")
	end)
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = script
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.SkyEid)
	clone_2.Parent = Lighting
	local random = Random.new()

	for _, child in clone.Lanterns:GetChildren() do
		local basePart = child:FindFirstChildWhichIsA("BasePart")

		if not basePart then
			continue
		end

		basePart.Anchored = false

		for _, v2 in child:QueryDescendants("BasePart") do
			if v2 == basePart then
				continue
			end

			v2.Anchored = false
			local v3 = maid:Add(Instance.new("WeldConstraint"))
			v3.Part0 = v2
			v3.Part1 = basePart
			v3.Parent = v2
		end

		local v2 = maid:Add(Instance.new("Motor6D"))
		v2.Part0 = workspace.Terrain
		v2.Part1 = basePart
		v2.C0 = basePart.CFrame
		v2.Parent = basePart
		local integer = random:NextInteger(0, 1000000)
		local number = random:NextNumber(4, 7)
		local v5 = random:NextNumber(0.5, 0.65)
		local v7 = random:NextNumber(0.25, 0.4)
		maid:Add(RunService.PostSimulation:Connect(function()
			local v8 = integer + os.clock()
			debug.profilebegin("Eid Lantern Update")
			v2.Transform = CFrame.new(0, math.sin(v8 * v5) * number, 0) * CFrame.Angles(
				0,
				v8 * v7 % 6.283185307179586,
				0
			)
			debug.profileend()
		end))
	end

	local v2 = {}
	maid:Add(Observers.observeTag("EidBalloon", function(parent)
		local maid2 = Trove.new()
		local balloonColor = parent:GetAttribute("BalloonColor") or "Red"

		if not v[balloonColor] then
			local _ = v.Red
		end

		local clone2 = maid2:Clone(script.Balloons[balloonColor])
		clone2.Parent = parent
		local animation = SharedEventUtils.loadAnimation(maid2, clone2.AnimationController.Animator, script.Idle)
		animation.Looped = true
		animation:Play(0, 1, (Random.new():NextNumber(0.3, 0.75)))
		local rootPart = clone2.RootPart
		v2[parent.Name] = clone2
		local lastTime = os.clock()
		local v3 = Random.new():NextNumber(0, 1) * 3.141592653589793 * 2
		maid2:Add(RunService.PreRender:Connect(function()
			debug.profilebegin("EidBalloon:visual")
			local v4 = math.sin(os.clock() - lastTime + v3) * 0.6
			local v5 = parent.CFrame * CFrame.new(0, v4, 0)
			SharedEventUtils.pushPartCFrame(rootPart, v5)
			debug.profileend()
		end))
		return function()
			v2[parent.Name] = nil
			maid2:Destroy()
		end
	end, { workspace }))
	maid:Add(function()
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
	end)
end

function Eid.OnStop(_)
	maid:Destroy()
end

function Eid.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p: string, _: string)
		maid:Add(ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events.Eid.Hit }))
	end)
end

return Eid