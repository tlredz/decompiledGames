local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = {
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.Ragdoll,
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.Jumping,
	Enum.HumanoidStateType.Swimming,
	Enum.HumanoidStateType.Freefall,
	Enum.HumanoidStateType.Flying,
	Enum.HumanoidStateType.Running,
	Enum.HumanoidStateType.Climbing,
	Enum.HumanoidStateType.Physics
}
local _ = Players.LocalPlayer

local function usingEmotes(instance)
	local usingEmotes2 = instance:WaitForChild("UsingEmotes", 30)

	if not usingEmotes2 then
		return
	end

	local animationController = instance:FindFirstChildWhichIsA("AnimationController", true)
	local humanoid

	if not animationController then
		humanoid = instance:WaitForChild("Humanoid")
	end

	if not animationController and humanoid then
		animationController = humanoid:WaitForChild("Animator")
	end

	if not animationController then
		return
	end

	if humanoid then
		for _, v2 in v do
			humanoid:SetStateEnabled(v2, false)
		end
	end

	local tracks = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function loadAnimation(animation)
		if not animation:IsA("Animation") then
			return false
		end

		local track = animationController:LoadAnimation(animation)

		if animation:GetAttribute("Looped") then
			track.Looped = true
		end

		table.insert(tracks, track)
		return true
	end

	for _, animation in usingEmotes2:GetChildren() do
		if not animation:IsA("Animation") then
			continue
		end

		local track = animationController:LoadAnimation(animation)

		if animation:GetAttribute("Looped") then
			track.Looped = true
		end

		table.insert(tracks, track)
	end

	if #tracks == 0 then
		local v2 = Signal.new()
		usingEmotes2.ChildAdded:Once(function(child)
			-- equivalent call inferred; original call site unknown
			if loadAnimation(child) then
				v2:Fire()
			end
		end)
		v2:Wait()
		v2:Destroy()
	else
		for _, v2 in tracks do
			local v3 = {}
			local timePositions = v3
			local v4 = v2
			v2:GetMarkerReachedSignal("Pin"):Connect(function(p: string)
				timePositions[p] = v4.TimePosition
			end)
			local v6 = v2
			v2:GetMarkerReachedSignal("GOTO"):Connect(function(p: string)
				local timePosition = v3[p]

				if timePosition then
					v6.TimePosition = timePosition
				end
			end)
			v2:Play()
		end
	end
end

return Observers.observeTag("PlayAnimationNPC", function(p)
	task.spawn(usingEmotes, p)
end, { workspace })