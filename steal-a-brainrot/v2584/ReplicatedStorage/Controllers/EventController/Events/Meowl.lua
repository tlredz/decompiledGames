local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Meowl/Burst")
local maid = Trove.new()

local function loadAnimation(animator, animation, p)
	local track = animator:LoadAnimation(animation);
	(p or maid):Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

local Meowl = {}

function Meowl.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	ReplicatedStorage:SetAttribute("MeowlEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("MeowlEvent", nil)
	end)
	local clone

	if ServerData.IsTsunamiServer() then
		clone = maid:Clone(script.MapTsunami)
	elseif ServerData.IsBiggerServer() then
		clone = maid:Clone(script.MapBigger)
	else
		clone = maid:Clone(script.Map)
	end

	clone.Parent = workspace

	if ServerData.IsBiggerServer() then
		ClientEventUtils.resizeEffects(clone.MapVFX, 2)
	end

	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.AtmosphereMeowl)
	clone_2.Parent = Lighting
	maid:Add(Observers.observeTag("HideInMeowl", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	maid:Add(task.spawn(function()
		if ServerData.IsTsunamiServer() then
			return
		end

		local random = Random.new(912341342)
		local vectors = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isPositionValid(vector: Vector3)
			for _, v in vectors do
				if (vector - v).Magnitude < 20 then
					return false
				end
			end

			return true
		end

		local v = { script.Trees["1"], script.Trees["2"], script.Trees["3"] }
		local children = workspace.Events.Matteo:GetChildren()
		table.sort(children, function(a, b)
			local position = a.Position
			local v2 = position.X + position.Y + position.Z
			local position2 = b.Position
			return position2.X + position2.Y + position2.Z < v2
		end)

		for _, v2 in children do
			local position = v2.Position
			local size = v2.Size

			for _ = 1, math.floor(size.X * size.Z * 0.0007) do
				local count = 0

				while count < 10 do
					count += 1
					local vector = Vector3.new(
						position.X + random:NextNumber(-size.X * 0.5, size.X * 0.5),
						position.Y + size.Y * 0.5,
						position.Z + random:NextNumber(-size.Z * 0.5, size.Z * 0.5)
					)

					-- equivalent call inferred; original call site unknown
					if not isPositionValid(vector) then
						continue
					end

					local clone2 = maid:Clone(v[random:NextInteger(1, #v)])
					clone2:PivotTo(CFrame.new(vector + Vector3.new(0, clone2:GetExtentsSize().Y * 0.5, 0)) * CFrame.Angles(
						0,
						random:NextNumber(0, 6.283185307179586),
						0
					))
					clone2.Parent = workspace
					table.insert(vectors, vector)
					break
				end
			end
		end
	end))
	maid:Add(Observers.observeTag("MeowlEventMeowl", function(part)
		local maid2 = Trove.new()
		local clone2 = maid2:Clone(script.Meowl)
		clone2.Parent = workspace
		local weld = Instance.new("Weld")
		weld.Part0 = clone2.PrimaryPart
		weld.Part1 = part
		weld.C0 = clone2.PrimaryPart.PivotOffset
		weld.Parent = clone2.PrimaryPart
		local track = clone2.AnimationController.Animator:LoadAnimation(script.Idle)
		maid:Add(function()
			track:Stop(0)
			track:Destroy()
		end)
		track.Priority = Enum.AnimationPriority.Idle
		track.Looped = true
		track:Play()
		local track2 = clone2.AnimationController.Animator:LoadAnimation(script.Fly)
		maid:Add(function()
			track2:Stop(0)
			track2:Destroy()
		end)
		track2.Priority = Enum.AnimationPriority.Action
		track2.Looped = true
		local track3 = clone2.AnimationController.Animator:LoadAnimation(script.Attack)
		maid:Add(function()
			track3:Stop(0)
			track3:Destroy()
		end)
		track3.Priority = Enum.AnimationPriority.Action2
		track3.Looped = false
		maid2:Add(Observers.observeAttribute(part, "Flying", function(p)
			if p then
				track2:Play()
			else
				track2:Stop()
			end

			return nil
		end))
		maid2:Add(part:GetAttributeChangedSignal("Attack"):Connect(function()
			track3:Play()
		end))
		return maid2:WrapClean()
	end, { workspace }))
	EffectController:Activate("Blink")
	EffectController:Run("MeowlEvent", "GrassRecolor")
	EffectController:Run("MeowlEvent", "WallRecolor")
	EffectController:Run("MeowlEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("MeowlEvent", "GrassRecolor")
		EffectController:Stop("MeowlEvent", "WallRecolor")
		EffectController:Stop("MeowlEvent", "WallBottomRecolor")
		EffectController:Activate("Blink")
	end)
end

function Meowl.OnStop(_)
	maid:Destroy()
end

function Meowl.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p: string)
		local v = { ReplicatedStorage.Sounds.Events.Meowl.BrainrotHit, ReplicatedStorage.Sounds.Events.Meowl.Flap }
		maid:Add(ClientEventUtils.playBurst(script.Burst, p, v))
	end)
end

return Meowl