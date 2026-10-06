local module = require("@game/ReplicatedStorage/Omni")
local fighters = module.Assets:WaitForChild("Effects"):WaitForChild("Fighters")
local ultimates = module.Assets:WaitForChild("Sounds"):FindFirstChild("Ultimates")
local class = {}
class.__index = class

function class.new(fighter, effectsFolder)
	local object = setmetatable({}, class)
	object.Fighter = fighter
	object.Enemy = fighter.Target
	object.EnemyHRP = fighter.Target and fighter.Target.HRP
	object.HRP = fighter.HRP
	object.Model = fighter.Model
	object.Animator = fighter.Animator
	object.Animation = fighter.UltimateAnimation
	object.SourceInfo = fighter.UltimateInfo or fighter.Info
	object.EffectsFolder = effectsFolder
	object.Omni = module
	local child = ultimates and ultimates:FindFirstChild(object.SourceInfo.MapName)
	object.SoundsFolder = child and child:FindFirstChild(object.SourceInfo.Name)
	object.Goal = object.EnemyHRP and object.EnemyHRP.Position
	object.GoalCFrame = object.EnemyHRP and object.EnemyHRP.CFrame
	object.Origin = object.HRP and object.HRP.CFrame
	object._tracked = {}
	object._cleanupCallbacks = {}
	object._sounds = {}
	return object
end

function class:Track(p2)
	if p2 then
		table.insert(self._tracked, p2)
	end

	return p2
end

function class:Untrack(p2)
	if not p2 then
		return
	end

	local index = table.find(self._tracked, p2)

	if index then
		table.remove(self._tracked, index)
	end
end

function class:Clone(childName: string)
	local child = self.EffectsFolder:FindFirstChild(childName)

	if child then
		return self:Track(child:Clone())
	end

	module:Debug((`[UltimateRunner] {self.Fighter.Name}: missing effect '{childName}'`))
	return nil
end

function class.Cache(_, p)
	if p then
		p.Parent = workspace.Cache
	end

	return p
end

function class.AttachToModel(p, p2)
	if p2 then
		p2.Parent = p.Model
	end

	return p2
end

function class.SetPart0(_, instance, part)
	if not (instance and part) then
		return
	end

	local motor6D = instance:FindFirstChildWhichIsA("Motor6D")

	if motor6D then
		motor6D.Part0 = part
	end
end

function class:Weld(part, part2, cframe: CFrame?, flag: boolean?)
	if typeof(part) ~= "Instance" or typeof(part2) ~= "Instance" or not (part:IsA("BasePart") and part2:IsA("BasePart")) then
		return
	end

	if flag == true then
		local position = part.Position

		if typeof(cframe) == "Vector3" then
			position += cframe
		end

		part2.Position = position
	else
		local cFrame = part.CFrame

		if typeof(cframe) == "CFrame" then
			cFrame *= cframe
		end

		part2.CFrame = cFrame
	end

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = part
	weldConstraint.Part1 = part2
	weldConstraint.Parent = part2

	if not table.find(self._tracked, part2) then
		self:Track(weldConstraint)
	end

	return weldConstraint
end

function class:Emit(p)
	if p then
		module.Utils.Particles:Emit(p)
	end
end

function class.Enable(_, p)
	if p then
		module.Utils.Particles:EnableAll(p)
	end
end

function class.Disable(_, p)
	if p then
		module.Utils.Particles:DisableAll(p)
	end
end

function class.Shake(p, options)
	local v = options or {}

	if v.Position == nil then
		v.Position = p.Goal or p.HRP and p.HRP.Position
	end

	return module.Utils.CameraShake:Play(v)
end

function class.Impact(p, options)
	local v = options or {}

	if v.Position == nil then
		v.Position = p.Goal or p.HRP and p.HRP.Position
	end

	module.Utils.Lighting:ImpactFrame(v)
end

function class:Blur(options)
	local v = options or {}

	if v.Position == nil then
		v.Position = self.Goal or self.HRP and self.HRP.Position
	end

	module.Utils.Lighting:Blur(v)
end

function class:Sound(childName: string, p)
	local child = self.SoundsFolder and self.SoundsFolder:FindFirstChild(childName)

	if child and self.HRP then
		local v = module.Sound:Play(child, self.HRP, false, p)
		table.insert(self._sounds, v)
		return v
	else
		module:Debug((`[UltimateRunner] {self.Fighter.Name}: missing sound '{childName}'`))
	end
end

function class:StopSounds()
	for _, _sound in self._sounds do
		_sound:cancel()
	end

	table.clear(self._sounds)
end

function class.Rock(p, p2: string, ...)
	local v = module.Libs.RockModule[p2]

	if type(v) == "function" then
		v(...)
	else
		module:Debug((`[UltimateRunner] {p.Fighter.Name}: unknown RockModule '{p2}'`))
	end
end

function class:Debris(p, value: number?)
	if not p then
		return
	end

	self:Untrack(p)
	module.Services.Debris:AddItem(p, value or 3)
end

function class:Destroy(instance)
	if not instance then
		return
	end

	self:Untrack(instance)
	instance:Destroy()
end

function class:OnCleanup(p2)
	table.insert(self._cleanupCallbacks, p2)
end

function class:CleanupAll()
	local _cleanupCallbacks = self._cleanupCallbacks
	self._cleanupCallbacks = {}

	for _, callback in _cleanupCallbacks do
		local success, result = pcall(callback)

		if not success then
			module:Debug((`[UltimateRunner] {self.Fighter.Name} cleanup: {result}`))
		end
	end

	for _, v in self._tracked do
		if v then
			v:Destroy()
		end
	end

	table.clear(self._tracked)
	table.clear(self._sounds)
end

local function WaitForMarker(state, ultimateAnimation, marker: string, timeout: number)
	local v = false
	local v2 = false
	local connection = ultimateAnimation:GetMarkerReachedSignal(marker):Connect(function()
		v = true
	end)
	local stoppedConnection = ultimateAnimation.Stopped:Connect(function()
		v2 = true
	end)
	local lastTime = os.clock()

	while not (v or v2 or state.Destroyed or timeout and timeout <= os.clock() - lastTime) do
		task.wait()
	end

	connection:Disconnect()
	stoppedConnection:Disconnect()
	return v
end

local function WaitForTime(state, ultimateAnimation, time: number)
	while ultimateAnimation.IsPlaying and ultimateAnimation.TimePosition < time and not state.Destroyed do
		task.wait()
	end
end

local function WaitForStopped(state, ultimateAnimation, ultimateSpeed: number)
	local v = false
	local stoppedConnection = ultimateAnimation.Stopped:Connect(function()
		v = true
	end)
	local lastTime = os.clock()
	local v2 = ultimateAnimation.Length / ultimateSpeed + 1

	while not v and ultimateAnimation.IsPlaying and not (state.Destroyed or v2 <= os.clock() - lastTime) do
		task.wait()
	end

	stoppedConnection:Disconnect()
end

local function Run(state, data, _)
	local target = state.Target

	if not target or target.Destroyed then
		return
	end

	if not target.HRP then
		module:Debug((`[UltimateRunner] {state.Name}: aborted, Enemy has no HRP`))
		return
	end

	local ultimateInfo = state.UltimateInfo or state.Info

	if state.UltimateAnimation and state.UltimateAnimationSource ~= ultimateInfo.Name then
		state.UltimateAnimation:Stop(0)
		state.UltimateAnimation:Destroy()
		state.UltimateAnimation = nil
	end

	if not state.UltimateAnimation then
		local characterAnimation = module.Utils.Characters.GetCharacterAnimation(ultimateInfo.Name, "Ultimate")

		if not characterAnimation then
			module:Debug((`[UltimateRunner] {state.Name}: aborted, missing 'Ultimate' animation asset`))
			return
		end

		state.UltimateAnimation = state.Animator:LoadAnimation(characterAnimation)
		state.UltimateAnimation.Looped = false
		state.UltimateAnimation.Priority = Enum.AnimationPriority.Action4
		state.UltimateAnimationSource = ultimateInfo.Name
	end

	local ultimateAnimation = state.UltimateAnimation

	if ultimateAnimation.Length == 0 then
		module:Debug((`[UltimateRunner] {state.Name}: aborted, Animation.Length is 0`))
		return
	end

	local ultimateSpeed = ultimateInfo.UltimateSpeed or 1
	local child = fighters:FindFirstChild(ultimateInfo.MapName)
	local child2 = child and child:FindFirstChild(ultimateInfo.Name)

	if not child2 then
		module:Debug((`[UltimateRunner] {state.Name}: missing effects folder for '{state.Info.MapName}'`))
		return
	end

	local ultimateContext = class.new(state, child2)
	state.UltimateContext = ultimateContext

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Finish()
		if state.UltimateContext == ultimateContext then
			state.UltimateContext = nil
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Guard(callback, p: string)
		if type(callback) ~= "function" then
			return
		end

		local success, result = pcall(callback, ultimateContext)

		if not success then
			module:Debug((`[UltimateRunner] {state.Name} {p}: {result}`))
		end
	end

	local setup = data.Setup

	if type(setup) == "function" then
		local success, result = pcall(setup, ultimateContext)

		if not success then
			module:Debug((`[UltimateRunner] {state.Name} Setup: {result}`))
		end
	end

	ultimateAnimation:Play(0.1, 1, ultimateSpeed)
	local connections = {}

	if type(data.OnMarker) == "table" then
		for k, v2 in data.OnMarker do
			if type(v2) ~= "function" then
				continue
			end

			local v3 = v2
			local v4 = `OnMarker[{k}]`
			table.insert(connections, (ultimateAnimation:GetMarkerReachedSignal(k):Connect(function()
				if state.Destroyed then
					return
				end

				Guard(v3, v4) -- equivalent call inferred; original call site unknown
			end)))
		end
	end

	for i, v2 in ipairs(data.Steps or {}) do
		if state.Destroyed then
			break
		end

		if v2.Marker then
			WaitForMarker(
				state,
				ultimateAnimation,
				v2.Marker,
				v2.Timeout or ultimateAnimation.Length / ultimateSpeed + 1
			)
		elseif v2.Time then
			WaitForTime(state, ultimateAnimation, v2.Time)
		end

		if state.Destroyed then
			break
		end

		Guard(v2.Run, `Step {i}`) -- equivalent call inferred; original call site unknown
	end

	WaitForStopped(state, ultimateAnimation, ultimateSpeed)

	for _, connection in connections do
		connection:Disconnect()
	end

	if state.Destroyed then
		ultimateContext:CleanupAll()
		Finish() -- equivalent call inferred; original call site unknown
	else
		local cleanup = data.Cleanup

		if type(cleanup) == "function" then
			local success, result = pcall(cleanup, ultimateContext)

			if not success then
				module:Debug((`[UltimateRunner] {state.Name} Cleanup: {result}`))
			end
		end

		ultimateContext:CleanupAll()
		Finish() -- equivalent call inferred; original call site unknown
	end
end

for _, part in fighters:GetDescendants() do
	if part:IsA("BasePart") then
		part.CanCollide = false
	end
end

return Run