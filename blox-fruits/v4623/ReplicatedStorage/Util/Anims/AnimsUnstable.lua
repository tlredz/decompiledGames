local print2 = print

local function fn(...)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.TestGame then
		print2(...)
	end
end

local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local RunService2 = game:GetService("RunService")
local isServer = RunService2:IsServer()
local RunService3 = game:GetService("RunService")
local isClient = RunService3:IsClient()
local Signal2 = require(game.ReplicatedStorage.Util.Signal2)
local Maid = require(game.ReplicatedStorage.Util.Maid)
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local flag = false
local v = 0
local object = setmetatable({}, {
	__mode = "k"
})
local v2 = {
	"LionsSong",
	"LionsSongCharge",
	"HighWavesCharge",
	"TremorPunchWindUpLoop",
	"EruptChargeLoop",
	"BlackHoleChargeLoop",
	"YoruZCharge",
	"LeopardCharge",
	"ExecutionCharge",
	"StabCharge",
	"Flight",
	"SpringFlight",
	"SoulShootHold",
	"PhoenixModelFlight",
	"StringLoop",
	"GravityFlight",
	"CyborgIdle",
	"CyborgFire",
	"GumChargeLoop",
	"ElectroClawXFlightLoop",
	"ElectroClawCHold",
	"Magma2FRideLoop",
	"BirdCharge",
	"SpringSnipe",
	"ElectroTackle_Hold",
	"SnapHold",
	"GuitarIdle",
	"RubberBazookaStart",
	"RubberAxeHold",
	"RubberRocketHold",
	"RubberRocketStretchLoop",
	"LeopardDashPoseTransformed",
	"LeopardRoarPoseGhost",
	"GravXLoop",
	"MammothChargeJump"
}

function collectGarbage()
	if flag then
		return
	end

	flag = true
	v = os.clock() + 5
	task.delay(5, function()
		for k, v3 in pairs(object) do
			if k:IsDescendantOf(workspace) or k:IsDescendantOf(game.ReplicatedStorage) then
				continue
			end

			for k2, v4 in pairs(v3) do
				if not (typeof(v4) == "table" and v4.Changed) then
					continue
				end

				v3[k2] = nil
				local v5 = rawget(v4, "_Maid")

				if v5 then
					v5:DoCleaning()
				end

				table.clear(v4)
			end

			if v3.__Func then
				table.clear(v3.__Func)
			end

			object[k] = nil
		end

		flag = false
	end)
end

local RunService4 = game:GetService("RunService")

if RunService4:IsClient() then
	local RunService5 = game:GetService("RunService")

	if RunService5:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
		game.Players.LocalPlayer.Chatted:Connect(function(value)
			if value:sub(1, 6) == "anims/" then
				for _, v3 in game.Players:GetPlayers() do
					if not v3.Name:lower():find(value:sub(7):lower()) then
						continue
					end

					local animators = {}

					for _, animationController in pairs(v3.Character:GetDescendants()) do
						if animationController:IsA("AnimationController") then
							table.insert(animators, animationController.Animator)
						end
					end

					table.insert(animators, v3.Character:FindFirstChild("Humanoid").Animator)

					for _ = 1, 20 do
						task.wait(0.5)
						fn("=====================================================================================================================")

						for _, v4 in pairs(animators) do
							fn(v4:GetFullName(), "-------------------------------------------------")

							for k, v5 in v4:GetPlayingAnimationTracks() do
								fn(
									k,
									v5,
									v5.WeightCurrent,
									v5.WeightTarget,
									v5.Priority,
									v5.Animation.Name,
									v5.Animation.AnimationId
								)
							end
						end

						fn("=====================================================================================================================")
					end
				end
			end
		end)
	end
end

local class = {}

function class.new(instance, cache)
	assert(instance, "no ._Object")

	for _, item in cache do
		if typeof(item) == "table" and rawget(item, "_Object") == instance then
			return item
		end
	end

	local v3 = {
		_Maid = Maid.new(),
		_Object = instance,
		_PropertySignals = {},
		_Cache = cache,
		lastProperties = {},
		serverLock = 0
	}
	v3._TrueWeight = {
		Started = os.clock(),
		FadeTime = 0.1,
		Initial = v3._Object.WeightCurrent,
		Target = v3._Object.WeightCurrent
	}
	v3._FadedOut = false
	v3.Changed = Signal2.new()
	v3._Maid.WrapChange = v3.Changed
	local object2 = setmetatable(v3, class)
	v3._Maid.TrackChange = instance.Changed:Connect(function(p: string)
		object2:_ChangedFired(p)
	end)

	function v3._Maid.TrackDestroy()
		instance:Destroy()
		instance = nil
		task.delay(25, function()
			rawset(v3, "_Object", nil)
		end)
		task.delay(25, function()
			rawset(v3, "_Cache", nil)
			table.clear(v3)
		end)
	end

	instance.Destroying:Connect(function()
		v3._Maid:Destroy()
		v3._Maid = nil
	end)
	return object2
end

function class:setupAfterLoaded()
	if rawget(self, "setup") then
		return
	end

	rawset(self, "setup", true)
	local v3 = rawget(self, "_Object")
	local v4 = rawget(self, "_Cache")

	if v4 and v3 then
		v4[v3.Priority] = v4[v3.Priority] or {}
	end

	rawset(self, "_PreviousPrio", v3.Priority)
end

function class:PlayServerLocked(fadeTime: number?, weight: number?, speed: number?)
	local lastProperties = self.lastProperties
	lastProperties.fadeTime = fadeTime
	lastProperties.weight = weight
	lastProperties.speed = speed
	self:Play(fadeTime, weight, speed)
	self.serverLock = 2
end

function class:Play(value: number?, value2: number?, value3: number?)
	if self._Object then
		if self._Object.Length == 0 and not table.find(v2, self.Name) then
			if rawget(self, "WaitingForLoad") then
				task.cancel((rawget(self, "WaitingForLoad")))
				rawset(self, "WaitingForLoad", nil)
			end

			rawset(self, "WaitingForLoad", task.spawn(function()
				local total = 0
				local stoppedConnection = self._Object.Stopped:Once(function()
					total += 1e999
				end)

				while rawget(self, "_Object") and self._Object.Length == 0 do
					total += task.wait()

					if not (total > 10) then
						continue
					end

					if total > 1000 then
						return
					end

					local Global = require(game.ReplicatedStorage.Global)
					Global.TestGameWarn("k i give up", self._Object.Name)
					return
				end

				if not rawget(self, "_Object") then
					return
				end

				stoppedConnection:Disconnect()
				self:setupAfterLoaded()
				task.wait()
				task.wait()
				self:Play(value, value2, value3)
				self.TimePosition = total
			end))
		else
			self:setupAfterLoaded()
			self.serverLock = 0
			local isPlaying = self.IsPlaying
			local fadeTime = value or 0.1
			assert(fadeTime)
			local target = value2 or 1
			assert(target)
			local v5 = value3 or 1
			assert(v5)

			if not (rawget(self, "_Object") and rawget(self, "_Cache")) then
				return
			end

			self._FadedOut = false
			self._TrueWeight = {
				Started = os.clock(),
				FadeTime = fadeTime,
				Initial = self:_GetTrueWeight(),
				Target = target
			}
			self._Cache[self.Priority] = self._Cache[self.Priority] or {}
			local index = table.find(self._Cache[self.Priority], self)

			if index then
				table.remove(self._Cache[self.Priority], index)
			end

			table.insert(self._Cache[self.Priority], self)

			for _, v6 in pairs(self._Cache[self.Priority]) do
				if not (rawget(self, "_TrueWeight") and rawget(v6, "_TrueWeight") and v6 ~= self and v6._TrueWeight.Target <= self._TrueWeight.Target) then
					continue
				end

				if not v6.IsPlaying then
					continue
				end

				v6._FadedOut = true
				v6._Object:AdjustWeight(0.0001, fadeTime)
			end

			self._Object:Play(fadeTime, target, v5)

			if not isPlaying then
				local stoppedConnection = nil
				stoppedConnection = self._Object.Stopped:Connect(function()
					if stoppedConnection then
						stoppedConnection:Disconnect()
						stoppedConnection = nil
					end

					self:_UpdatePriority(self.Priority)
				end)
			end
		end
	elseif rawget(self, "_Object") and rawget(self, "_Cache") then
		local Global = require(game.ReplicatedStorage.Global)
		Global.TestGameWarn(
			"TrackWrapper is empty, where is the container?",
			self._Cache,
			self._Cache and self._Cache.__Animator
		)
	end
end

function class:AdjustWeight(value: number?, value2: number?)
	local target = value or 1
	assert(target)
	local fadeTime = value2 or 0.1
	assert(fadeTime)
	self._TrueWeight = {
		Started = os.clock(),
		FadeTime = fadeTime,
		Initial = self:_GetTrueWeight(),
		Target = target
	}

	if self._FadedOut then
		return
	end

	self._Object:AdjustWeight(target, fadeTime)
end

function class:Stop(value)
	if not rawget(self, "_Object") then
		return
	end

	if rawget(self, "WaitingForLoad") then
		task.cancel((rawget(self, "WaitingForLoad")))
		rawset(self, "WaitingForLoad", nil)
	end

	local v3 = value or 0.1
	assert(v3)
	local fadeTime = v3 <= 0 and 0.001 or v3
	self._TrueWeight = {
		Started = os.clock(),
		FadeTime = fadeTime,
		Initial = self:_GetTrueWeight(),
		Target = 0
	}
	self._Object:Stop(fadeTime)
end

function class:__index(p)
	if p == "WeightCurrent" then
		return self:_GetTrueWeight()
	elseif p == "WeightTarget" then
		return self._TrueWeight.Target
	elseif p == "_Object" then
		return nil
	elseif p == "_TrueWeight" then
		return (rawget(self, "_TrueWeight"))
	end

	local v3 = self and rawget(self, "_Object")
	return rawget(class, p) or v3 and v3[p]
end

function class:GetPropertyChangedSignal(p2)
	if not self._PropertySignals[p2] then
		local v3 = Signal2.new()
		self._PropertySignals[p2] = v3
		self._Maid:GiveTask(v3)
	end

	return self._PropertySignals[p2]
end

function class:__newindex(p, p2)
	if p ~= "TimePosition" and p ~= "Priority" and p ~= "Looped" then
		return warn("Animation tracks are read-only.", p, p2)
	end

	if not rawget(self, "_Object") then
		return
	end

	if p ~= "Priority" then
		self._Object[p] = p2
		return
	end

	if not rawget(self, "setup") then
		rawset(self, "_PreviousPrio", p2)
	end

	if not (rawget(self, "_Object") and rawget(self, "_Cache")) then
		return
	end

	self._Cache[self._PreviousPrio] = self._Cache[self._PreviousPrio] or {}
	local index = table.find(self._Cache[self._PreviousPrio], self)

	if index then
		table.remove(self._Cache[self._PreviousPrio], index)
	end

	self:_UpdatePriority(self._PreviousPrio)
	self._PreviousPrio = p2
	self._Object.Priority = p2
	self._Cache[self._PreviousPrio] = self._Cache[self._PreviousPrio] or {}
	local index2 = table.find(self._Cache[self._PreviousPrio], self)

	if index2 then
		table.remove(self._Cache[self._PreviousPrio], index2)
	end

	self:_UpdatePriority(self.Priority)
	table.insert(self._Cache[self.Priority], self)
	self:_UpdatePriority(p2)
end

function class:_ChangedFired(p: string)
	if p ~= "WeightCurrent" and p ~= "WeightTarget" then
		self:_ReplicateChanged(p)
		return
	end

	if self._FadedOut then
		return
	end

	self:_ReplicateChanged(p)
end

function class:_ReplicateChanged(p2: string)
	local _PropertySignal = self._PropertySignals[p2]

	if _PropertySignal then
		_PropertySignal:Fire(self[p2])
	end

	self.Changed:Fire(p2)
end

function class:_UpdatePriority(p2)
	if not (rawget(self, "_Object") and rawget(self, "_Cache")) then
		return
	end

	local target = -1
	local v3 = {}

	for _, v4 in pairs(self._Cache[p2] or {}) do
		if not v4.IsPlaying then
			continue
		end

		if target < v4._TrueWeight.Target then
			target = v4._TrueWeight.Target
			v3 = {}
		end

		if v4._TrueWeight.Target == target then
			table.insert(v3, v4)
		end
	end

	local v4 = v3[#v3]

	for _, v5 in pairs(self._Cache[p2] or {}) do
		if v5.IsPlaying and v4 ~= v5 then
			v5._FadedOut = true

			if v5._Object.WeightTarget > 0.000099 then
				v5._Object:AdjustWeight(0.0001, 0.1)
			end
		elseif v5.IsPlaying and v5._Object.WeightCurrent ~= v5._TrueWeight.Target then
			v5:_GetTrueWeight()
			local target2 = v5._TrueWeight.Target
			local v6 = math.max(v5._TrueWeight.FadeTime - (os.clock() - v5._TrueWeight.Started), 0)
			v5._FadedOut = true
			v5._Object:AdjustWeight(target2, v6 + 0.1)
			v5._FadedOut = false
		end
	end
end

function class:_GetTrueWeight()
	return math.min((os.clock() - self._TrueWeight.Started) / self._TrueWeight.FadeTime, 1) * (self._TrueWeight.Target - self._TrueWeight.Initial) + self._TrueWeight.Initial
end

function class:AdjustSpeed(...)
	return self._Object:AdjustSpeed(...)
end

function class:GetMarkerReachedSignal(...)
	return self._Object:GetMarkerReachedSignal(...)
end

function class:GetTimeOfKeyframe(...)
	return self._Object:GetTimeOfKeyframe(...)
end

function class:SetAttribute(...)
	return self._Object:SetAttribute(...)
end

function class:GetAttribute(...)
	return self._Object:GetAttribute(...)
end

function class:GetAttributeChangedSignal(...)
	return self._Object:GetAttributeChangedSignal(...)
end

function class:Destroy(...)
	return self._Object:Destroy(...)
end

function class:GetAttributes(...)
	return self._Object:GetAttributes(...)
end

local AnimsUnstable = {}
local RunService5 = game:GetService("RunService")
local v3, v4

if RunService5:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	if isServer then
		v3 = Instance.new("RemoteFunction", script)
		v3.Name = "__control"
		v4 = Instance.new("RemoteEvent", script)
		v4.Name = "__control2"
	else
		v3 = script:WaitForChild("__control")
		v4 = script:WaitForChild("__control2")

		v3.OnClientInvoke = function(p, ...)
			local v5 = { ... }

			if p == "StopLocalId" then
				local v6 = v5[1]
				local v7 = v5[2]
				local v8 = AnimsUnstable.Cached[v6]

				if not v8 then
					return
				end

				for k, v9 in pairs(v8) do
					if not (typeof(v9) == "table" and typeof(k) == "string" and k:find("local")) then
						continue
					end

					local _Object = v9._Object

					if _Object.Animation.AnimationId == v7 then
						_Object:Stop(0)
					end
				end
			end
		end
	end
else
	v3 = nil
	v4 = nil
end

AnimsUnstable.Cached = object

function AnimsUnstable:GetRaw(childName)
	local v5 = script.Storage:FindFirstChild(childName, true)

	if not v5 and childName:find("asset") then
		v5 = Instance.new("Animation")
		v5.AnimationId = childName
		v5.Name = childName
		v5.Parent = script.Storage["0"]
	end

	return v5
end

function AnimsUnstable.CollectGarbage(_) end

local RunService6 = game:GetService("RunService")

if RunService6:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	function AnimsUnstable:Preload(p)
		task.spawn(function()
			local raw = self:GetRaw(p)

			if raw then
				task.spawn(function()
					local ContentProvider2 = game:GetService("ContentProvider")
					ContentProvider2:PreloadAsync({ raw })
				end)
			end
		end)
	end

	if not isServer then
		v4.OnClientEvent:Connect(function(p, items)
			if p == "PreloadArray" then
				for _, item in pairs(items) do
					local raw = AnimsUnstable:GetRaw(item)

					if not raw then
						continue
					end

					local ContentProvider2 = game:GetService("ContentProvider")
					ContentProvider2:PreloadAsync({ raw })
				end
			end
		end)
	end

	function AnimsUnstable.PreloadOnClients(_, p)
		v4:FireAllClients("PreloadArray", p)
	end
end

local animationsByAnimationId = {}
local RunService7 = game:GetService("RunService")

if RunService7:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	for _, animation in pairs(script:GetDescendants()) do
		if animation:IsA("Animation") then
			animationsByAnimationId[animation.AnimationId] = animation
		end
	end

	if isClient then
		function AnimsUnstable:GetLocalAnimator(p)
			self:MakeCachedCharacter(p)
			local v5 = self.Cached[p]

			if v5.__LocalAnimator then
				return v5.__LocalAnimator
			end

			local __Animator = v5.__Animator

			if not __Animator:IsA("Animator") then
				warn("blah")
			end

			local animator = Instance.new("Animator")
			animator.Parent = __Animator.Parent
			animator.Name = "Animator"
			v5.LocalAnimatorCache = {
				__Animator = animator,
				__LastAnimation = {},
				__AnimationPriorities = {},
				__LastIndex = 0
			}
			v5.__LocalAnimator = animator
			return v5.__LocalAnimator
		end
	end
end

function AnimsUnstable:MakeCachedCharacter(instance)
	if not self.Cached[instance] then
		local animator = instance:FindFirstChildWhichIsA("Humanoid") and instance:FindFirstChildWhichIsA("Humanoid"):FindFirstChildWhichIsA("Animator")
		self.Cached[instance] = {
			__Animator = animator or instance:FindFirstChildWhichIsA("Animator", true) or instance:FindFirstChildWhichIsA("Humanoid") or instance:FindFirstChildWhichIsA("AnimationController"),
			__LastAnimation = {},
			__AnimationPriorities = {},
			__LastIndex = 0
		}
		local __Animator = self.Cached[instance].__Animator
		local destroyingConnection = nil
		local destroyingConnection2 = nil

		if __Animator then
			local gc

			gc = function(connection)
				local v6 = connection or self.Cached[instance]

				if v6 then
					task.delay(5, function()
						for k, connection2 in pairs(v6) do
							if typeof(connection2) == "table" then
								if rawget(connection2, "_Maid") then
									rawget(connection2, "_Maid"):Destroy()
								end
							elseif typeof(connection2) == "RBXScriptConnection" then
								connection2:Disconnect()
							elseif k == "LocalAnimatorCache" then
								gc(connection2)
							end
						end

						if destroyingConnection then
							destroyingConnection:Disconnect()
							destroyingConnection = nil
						end

						if destroyingConnection2 then
							destroyingConnection2:Disconnect()
							destroyingConnection2 = nil
						end

						task.delay(10, function()
							table.clear(v6)
						end)
					end)
				end
			end

			destroyingConnection = __Animator.Destroying:Connect(gc)
			destroyingConnection2 = instance.Destroying:Connect(gc)

			for _, v5 in __Animator:GetPlayingAnimationTracks() do
				if v5.Animation.AnimationId:find("?local=true") then
					v5:Stop(0)
				end
			end

			local animationPlayedConnection = __Animator.AnimationPlayed:Connect(function(instance2)
				local v5 = instance2.Animation.AnimationId:find("?local=true")

				if (isServer or instance ~= game.Players.LocalPlayer.Character) and v5 then
					if isServer then
						task.spawn(function()
							for _, v6 in game.Players:GetPlayers() do
								local v7 = v6
								task.spawn(function()
									v3:InvokeClient(v7, "StopLocalId", instance, instance2.Animation.AnimationId)
								end)
							end
						end)
						task.defer(function()
							local Global = require(game.ReplicatedStorage.Global)
							Global.TestGamePrint("stop other character's local track from server", instance)

							for _ = 1, 20 do
								task.wait()
								instance2:Stop(0)
							end

							task.wait()
							instance2:Destroy()
							task.wait()
						end)
					else
						local Global = require(game.ReplicatedStorage.Global)
						Global.TestGamePrint("stop other character's local track", instance)

						for _ = 1, 20 do
							task.wait()
							instance2:Stop(0)
						end

						task.wait()
						instance2:Destroy()
					end
				else
					if v5 then
						return
					end

					if isServer then
						local name = instance2.Name

						if name == "Animation" then
							local v6 = animationsByAnimationId[instance2.Animation.AnimationId]

							if v6 then
								local name2 = v6.Name
								instance2.Name = name2
								local v7 = self.Cached[instance][name2]

								if not v7 then
									class.new(instance2, self.Cached[instance])
									return
								end

								local Global = require(game.ReplicatedStorage.Global)
								Global.TestGamePrint(
									"so it WAS cached..",
									instance2,
									v7._Object,
									"isSame?",
									v7._Object == instance2
								)

								if v7._Object then
									v7._Object:Stop()
									v7._Object:Destroy()
								end

								rawset(v7, "_Object", instance2)
							end
						else
							local v6 = self.Cached[instance][name]

							if v6 and v6._Object ~= instance2 then
								local _ = v6._Object
								rawset(v6, "_Object", instance2)
								local Global = require(game.ReplicatedStorage.Global)
								Global.TestGameWarn("track had dupe?", instance2)
							end
						end
					end
				end
			end)
			self.Cached[instance].__PlayedConnection = animationPlayedConnection
		end
	end
end

if isClient then
	local RunService8 = game:GetService("RunService")

	if RunService8:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
		function AnimsUnstable:GetLocal(p, p2: string)
			self:MakeCachedCharacter(p)
			collectGarbage()
			local v5 = self.Cached[p][p2 .. "local"]

			if v5 then
				return v5
			end

			local raw = self:GetRaw(p2)

			if not raw then
				return nil
			end

			local clone = raw:Clone()
			clone.Name = "Local" .. clone.Name
			clone.AnimationId ..= "?local=true"
			local __Animator = self.Cached[p].__Animator

			if not __Animator then
				return nil
			end

			if __Animator.ClassName ~= "Humanoid" and __Animator.ClassName ~= "AnimationController" and __Animator.ClassName ~= "Animator" then
				return (setmetatable({}, {
					__index = function()
						return function() end
					end
				}))
			end

			assert(__Animator:IsA("Humanoid") or __Animator:IsA("AnimationController") or __Animator:IsA("Animator"))

			if __Animator.Parent ~= nil then
				local track

				if __Animator.Parent.Parent == nil then
					__Animator.Parent.Parent = game.ReplicatedStorage
					local ancestryChangedConnection = nil
					ancestryChangedConnection = __Animator.Parent.AncestryChanged:Once(function(_, _)
						ancestryChangedConnection = nil
					end)
					track = __Animator:LoadAnimation(clone)

					if ancestryChangedConnection then
						ancestryChangedConnection:Disconnect()
						__Animator.Parent.Parent = nil
					end
				else
					track = __Animator:LoadAnimation(clone)
				end

				local v6 = class.new(track, self.Cached[p])
				self.Cached[p][p2 .. "local"] = v6
				return v6
			end

			return nil
		end
	end
end

local function Blank(p, ...)
	warn("running blank", p.anim, p.character, ...)
end

local v5 = {
	Play = Blank,
	Stop = Blank,
	GetTimeOfKeyframe = function()
		return 0
	end,
	GetMarkerReachedSignal = function()
		local v6 = Signal2.new()
		task.defer(function()
			v6:Fire()
		end)
		return v6
	end,
	AdjustWeight = Blank,
	AdjustSpeed = Blank,
	IsPlaying = true,
	Animation = setmetatable({}, {
		__newindex = function() end,
		__index = {
			Name = "",
			AnimationId = ""
		}
	}),
	Priority = Enum.AnimationPriority.Core,
	Speed = 0,
	Looped = false,
	Length = 0.1,
	WeightCurrent = 1,
	WeightTarget = 1,
	TimePosition = 0.05
}
local object2 = setmetatable({}, {
	__index = function(p, p2)
		if p2 == "DidLoop" or p2 == "Ended" or p2 == "KeyframeReached" or p2 == "Stopped" then
			local v6 = Signal2.new()
			task.defer(function()
				v6:Fire()
			end)
			return v6
		elseif p2 == "_Object" then
			return p
		else
			return v5[p2]
		end
	end,
	__newindex = function(_, _, _) end
})

function AnimsUnstable:GetAwaited(p, p2: string, value: number)
	local v6 = self:Get(p, p2)
	local total = 0
	local v7 = value or 5

	while not (v6 and rawget(v6, "_Object")) do
		total += task.wait(0.1)
		v6 = self:Get(p, p2)

		if not rawget(v6, "_Object") then
			local v8 = rawget(v6, "_Maid")

			if v8 then
				v8:Destroy()
			end

			v6:Destroy()
			table.clear(v6)
		end

		if not (v7 < total) then
			continue
		end

		warn("Fail await anim", p2)
		return v6
	end

	return v6
end

function AnimsUnstable:Get(character, p2: string)
	self:MakeCachedCharacter(character)
	collectGarbage()
	local v6 = self.Cached[character][p2]

	if v6 then
		return v6
	end

	local raw = self:GetRaw(p2)
	local __Animator = raw and self.Cached[character].__Animator

	if not __Animator then
		return nil
	end

	if __Animator.ClassName ~= "Humanoid" and __Animator.ClassName ~= "AnimationController" and __Animator.ClassName ~= "Animator" then
		return (setmetatable({}, {
			__index = function()
				return function() end
			end
		}))
	end

	assert(__Animator:IsA("Humanoid") or __Animator:IsA("AnimationController") or __Animator:IsA("Animator"))

	if __Animator.ClassName == "Animator" and not __Animator.Parent then
		warn("returned a blank track")
		return object2
	end

	if __Animator.Parent == nil then
		return nil
	end

	local track = nil

	if __Animator.Parent.Parent == nil then
		__Animator.Parent.Parent = game.ReplicatedStorage
		local ancestryChangedConnection = nil
		ancestryChangedConnection = __Animator.Parent.AncestryChanged:Once(function(_, _)
			ancestryChangedConnection = nil
		end)
		local success, result = pcall(function()
			track = __Animator:LoadAnimation(raw)
		end)

		if not success then
			local Global = require(game.ReplicatedStorage.Global)
			Global.TestGameWarn(result)
		end

		if ancestryChangedConnection then
			ancestryChangedConnection:Disconnect()
			__Animator.Parent.Parent = nil
		end
	else
		local success, result = pcall(function()
			track = __Animator:LoadAnimation(raw)
		end)

		if not success then
			local Global = require(game.ReplicatedStorage.Global)
			Global.TestGameWarn(result)
		end
	end

	if not track then
		return (setmetatable({
			character = character,
			anim = raw
		}, (getmetatable(object2))))
	end

	local v7 = class.new(track, self.Cached[character])
	self.Cached[character][p2] = v7
	return v7
end

function AnimsUnstable:HookOnPause(p)
	local keyframeReachedConnection = self.KeyframeReached:Connect(function(p2)
		if p2 == "Pause" or p2 == p then
			self:AdjustSpeed(0)
			self.TimePosition = self:GetTimeOfKeyframe(p2)
		end
	end)
	local stoppedConnection = nil
	stoppedConnection = self.Stopped:Connect(function()
		keyframeReachedConnection:Disconnect()

		if stoppedConnection then
			stoppedConnection:Disconnect()
		end
	end)
	self._Maid:GiveTask(keyframeReachedConnection)
	self._Maid:GiveTask(stoppedConnection)
	return self
end

function AnimsUnstable.Build(p, instance)
	local func = {
		Get = function(self, p2)
			return AnimsUnstable:Get(instance, p2)
		end,
		GetAwaited = function(self, p2)
			return AnimsUnstable:GetAwaited(instance, p2)
		end,
		HookOnPause = function(p2)
			return AnimsUnstable.HookOnPause(p2)
		end,
		Clean = function(self)
			if self.cached and self.cached and self.cached.__Animator then
				for _, v7 in self.cached do
					if typeof(v7) == "table" then
						local v8 = rawget(v7, "_Maid")

						if v8 then
							v8:Destroy()
						end
					elseif typeof(v7) == "RBXScriptConnection" then
						local connection = v7
						task.delay(5, function()
							connection:Disconnect()
						end)
					end
				end

				self.cached.__Animator:Destroy()
				task.delay(15, function(list, list2)
					table.clear(list)
					table.clear(list2)
				end, self.cached, self)
			end

			self.cached = nil
		end
	}
	local total = 0
	local animator = nil

	while total < 5 do
		animator = instance:FindFirstChildWhichIsA("Animator", true) or instance:FindFirstChildWhichIsA("Humanoid") or instance:FindFirstChildWhichIsA("AnimationController")

		if animator then
			break
		else
			total += task.wait()
		end
	end

	p.Cached[instance] = {
		__Animator = animator,
		__LastAnimation = {},
		__AnimationPriorities = {},
		__LastIndex = 0,
		__Func = func
	}
	p.Cached[instance].charDestroy = instance.Destroying:Once(function()
		func:Clean()
		animator:Destroy()
		func.cached = nil

		for _, v7 in pairs(p.Cached[instance]) do
			if not (typeof(v7) == "table" and rawget(v7, "_Maid")) then
				continue
			end

			rawget(v7, "_Maid"):Destroy()
			fn("maid cleanup x char destroy")
		end
	end)
	func.cached = p.Cached[instance]
	return func
end

if RunService:IsClient() then
	local RunService8 = game:GetService("RunService")

	if RunService8:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
		task.spawn(function()
			ContentProvider:PreloadAsync({
				"rbxassetid://7152363872",
				"rbxassetid://7152367896",
				"rbxassetid://10122845177"
			})
		end)
	end
end

return AnimsUnstable