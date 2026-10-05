local print2 = print

local function fn(...)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.TestGame then
		print2(...)
	end
end

local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local RunService2 = game:GetService("RunService")
local isServer = RunService2:IsServer()
local RunService3 = game:GetService("RunService")
local isClient = RunService3:IsClient()
local AnimationClipProvider = game:GetService("AnimationClipProvider")
local Signal2 = require(game.ReplicatedStorage.Util.Signal2)
local Maid = require(game.ReplicatedStorage.Util.Maid)
require(script.Types)
local flag = false
local v = 0
local anims = game.ReplicatedStorage.Storage:WaitForChild("Anims", 1) or Instance.new("Folder")
local cached = {}
local v3 = {
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
	"ElectroClawCHold",
	"Magma2FRideLoop",
	"BirdCharge",
	"SpringSnipe",
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
local v4 = { "PreloadTest" }

local function __Blank() end

function collectGarbage()
	if flag then
		v = os.clock() + 5
		return
	end

	flag = true
	v = os.clock() + 5
	task.delay(5, function()
		for k, v5 in pairs(cached) do
			if k:IsDescendantOf(workspace) or k:IsDescendantOf(game.ReplicatedStorage) then
				continue
			end

			for k2, v6 in pairs(v5) do
				if not (typeof(v6) == "table" and v6.Changed) then
					continue
				end

				v5[k2] = nil
				v6._Maid:DoCleaning()
				table.clear(v6)
				rawset(v6, "Play", __Blank)
				rawset(v6, "Stop", __Blank)
				rawset(v6, "AdjustWeight", __Blank)
				rawset(v6, "AdjustSpeed", __Blank)
			end

			if v5.__Func then
				table.clear(v5.__Func)
			end

			cached[k] = nil
			setmetatable(v5, {
				__mode = "kv"
			})
			local v6 = v5
			task.delay(5, function()
				if v6.__PlayedConnection then
					v6.__PlayedConnection:Disconnect()
					v6.__PlayedConnection = nil
					v6.__Animator = nil
				end
			end)
		end

		flag = false
	end)
end

task.spawn(function()
	while task.wait(5) do
		if os.clock() - v > 14 then
			collectGarbage()
		end
	end
end)
local RunService4 = game:GetService("RunService")

if RunService4:IsClient() then
	local RunService5 = game:GetService("RunService")

	if RunService5:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
		game.Players.LocalPlayer.Chatted:Connect(function(value)
			if value:sub(1, 6) == "anims/" then
				for _, v5 in game.Players:GetPlayers() do
					if not v5.Name:lower():find(value:sub(7):lower()) then
						continue
					end

					local animators = {}

					for _, animationController in pairs(v5.Character:GetDescendants()) do
						if animationController:IsA("AnimationController") then
							table.insert(animators, animationController.Animator)
						end
					end

					table.insert(animators, v5.Character:FindFirstChild("Humanoid").Animator)

					for _ = 1, 20 do
						task.wait(0.5)
						fn("=====================================================================================================================")

						for _, v6 in pairs(animators) do
							fn(v6:GetFullName(), "-------------------------------------------------")

							for k, v7 in v6:GetPlayingAnimationTracks() do
								fn(
									k,
									v7,
									v7.WeightCurrent,
									v7.WeightTarget,
									v7.Priority,
									v7.Animation.Name,
									v7.Animation.AnimationId
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

local v5 = {
	new = function(instance, cache)
		assert(instance, "no ._Object")
		local v6 = {
			_Maid = Maid.new(),
			_Object = instance,
			_Cache = cache
		}
		v6._Maid:GiveTask(function()
			instance:Destroy()
			instance = nil
			local v7 = rawget(v6, "_Cache")

			if v7 then
				for k, v8 in v7 do
					if v8 == v6 then
						v7[k] = nil
					end
				end
			end
		end)
		instance.Destroying:Connect(function()
			v6._Maid:Destroy()
		end)
		return (setmetatable(v6, {
			__index = function(p2, p3)
				local v7 = rawget(p2, "_Object")

				if p3 == "_Object" then
					return v7
				end

				local v8 = v7 and v7[p3]

				if typeof(v8) == "function" then
					return function(_, ...)
						return v8(v7, ...)
					end
				end

				return v8 == nil and function()
					warn("running method on anim object that has been garbage collected", p2, p3)
				end or v8
			end,
			__newindex = function(p2, p3, p4)
				local v7 = rawget(p2, "_Object")

				if v7 then
					v7[p3] = p4
				end
			end
		}))
	end,
	setupAfterLoaded = function(self)
		if rawget(self, "setup") then
			return
		end

		rawset(self, "setup", true)
		local _Object = self._Object
		self._Cache[_Object.Priority] = self._Cache[_Object.Priority] or {}
		rawset(self, "_PreviousPrio", _Object.Priority)
	end,
	PlayServerLocked = function(self, fadeTime: number?, weight: number?, speed: number?)
		local lastProperties = self.lastProperties
		lastProperties.fadeTime = fadeTime
		lastProperties.weight = weight
		lastProperties.speed = speed
		self:Play(fadeTime, weight, speed)
		self.serverLock = 2
	end,
	Play = function(self, value: number?, value2: number?, value3: number?)
		if self._Object then
			if self._Object.Length == 0 and not table.find(v3, self.Name) then
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
				local v8 = value3 or 1
				assert(v8)
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

				for _, v9 in pairs(self._Cache[self.Priority]) do
					if not (v9 ~= self and v9._TrueWeight.Target <= self._TrueWeight.Target and v9.IsPlaying) then
						continue
					end

					v9._FadedOut = true
					v9._Object:AdjustWeight(0.0001, fadeTime)
				end

				self._Object:Play(fadeTime, target, v8)

				if not isPlaying then
					local stoppedConnection = nil
					stoppedConnection = self._Object.Stopped:Connect(function()
						if stoppedConnection then
							stoppedConnection:Disconnect()
							stoppedConnection = nil
						end

						self:_UpdatePriority(self.Priority)
					end)
					self._Maid:GiveTask(function()
						if stoppedConnection then
							stoppedConnection:Disconnect()
							stoppedConnection = nil
						end
					end)
				end
			end
		else
			local Global = require(game.ReplicatedStorage.Global)
			Global.TestGameWarn(
				"TrackWrapper is empty, where is the container?",
				self._Cache,
				self._Cache and self._Cache.__Animator
			)
		end
	end,
	AdjustWeight = function(self, value: number?, value2: number?)
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
	end,
	Stop = function(self, value)
		if rawget(self, "WaitingForLoad") then
			task.cancel((rawget(self, "WaitingForLoad")))
			rawset(self, "WaitingForLoad", nil)
		end

		local v6 = value or 0.1
		assert(v6)
		local fadeTime = v6 <= 0 and 0.001 or v6
		self._TrueWeight = {
			Started = os.clock(),
			FadeTime = fadeTime,
			Initial = self:_GetTrueWeight(),
			Target = 0
		}
		self._Object:Stop(fadeTime)
	end
}

function v5:__index(p)
	if p == "WeightCurrent" then
		return self:_GetTrueWeight()
	elseif p == "WeightTarget" then
		return self._TrueWeight.Target
	elseif p == "_Object" then
		return nil
	end

	return rawget(v5, p) or (self and rawget(self, "_Object"))[p]
end

function v5:GetPropertyChangedSignal(p2)
	if not self._PropertySignals[p2] then
		local v6 = Signal2.new()
		self._PropertySignals[p2] = v6
		self._Maid:GiveTask(v6)
	end

	return self._PropertySignals[p2]
end

function v5:__newindex(p, p2)
	if p ~= "TimePosition" and p ~= "Priority" and p ~= "Looped" then
		return warn("Animation tracks are read-only.", p, p2)
	end

	if p ~= "Priority" then
		self._Object[p] = p2
		return
	end

	if not rawget(self, "setup") then
		rawset(self, "_PreviousPrio", p2)
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

function v5:_ChangedFired(p: string)
	if p ~= "WeightCurrent" and p ~= "WeightTarget" then
		self:_ReplicateChanged(p)
		return
	end

	if self._FadedOut then
		return
	end

	self:_ReplicateChanged(p)
end

function v5:_ReplicateChanged(p2: string)
	local _PropertySignal = self._PropertySignals[p2]

	if _PropertySignal then
		_PropertySignal:Fire(self[p2])
	end

	self.Changed:Fire(p2)
end

function v5:_UpdatePriority(p2)
	local target = -1
	local v6 = {}

	for _, v7 in pairs(self._Cache[p2] or {}) do
		if not v7.IsPlaying then
			continue
		end

		if target < v7._TrueWeight.Target then
			target = v7._TrueWeight.Target
			v6 = {}
		end

		if v7._TrueWeight.Target == target then
			table.insert(v6, v7)
		end
	end

	local v7 = v6[#v6]

	for _, v8 in pairs(self._Cache[p2] or {}) do
		if v8.IsPlaying and v7 ~= v8 then
			v8._FadedOut = true

			if v8._Object.WeightTarget > 0.000099 then
				v8._Object:AdjustWeight(0.0001, 0.1)
			end
		elseif v8.IsPlaying and v8._Object.WeightCurrent ~= v8._TrueWeight.Target then
			v8:_GetTrueWeight()
			local target2 = v8._TrueWeight.Target
			local v9 = math.max(v8._TrueWeight.FadeTime - (os.clock() - v8._TrueWeight.Started), 0)
			v8._FadedOut = true
			v8._Object:AdjustWeight(target2, v9 + 0.1)
			v8._FadedOut = false
		end
	end
end

function v5:_GetTrueWeight()
	return math.min((os.clock() - self._TrueWeight.Started) / self._TrueWeight.FadeTime, 1) * (self._TrueWeight.Target - self._TrueWeight.Initial) + self._TrueWeight.Initial
end

function v5:AdjustSpeed(...)
	return self._Object:AdjustSpeed(...)
end

function v5:GetMarkerReachedSignal(...)
	return self._Object:GetMarkerReachedSignal(...)
end

function v5:GetTimeOfKeyframe(...)
	return self._Object:GetTimeOfKeyframe(...)
end

function v5:SetAttribute(...)
	return self._Object:SetAttribute(...)
end

function v5:GetAttribute(...)
	return self._Object:GetAttribute(...)
end

function v5:GetAttributeChangedSignal(...)
	return self._Object:GetAttributeChangedSignal(...)
end

function v5:Destroy(...)
	return self._Object:Destroy(...)
end

function v5:GetAttributes(...)
	return self._Object:GetAttributes(...)
end

local Anims = {}
local RunService5 = game:GetService("RunService")
local v6, v7

if RunService5:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	if isServer then
		v6 = Instance.new("RemoteFunction", script)
		v6.Name = "__control"
		v7 = Instance.new("RemoteEvent", script)
		v7.Name = "__control2"
	else
		v6 = script:WaitForChild("__control")
		v7 = script:WaitForChild("__control2")

		v6.OnClientInvoke = function(p, ...)
			local v8 = { ... }

			if p == "StopLocalId" then
				local v9 = v8[1]
				local v10 = v8[2]
				local v11 = Anims.Cached[v9]

				if not v11 then
					return
				end

				for k, v12 in pairs(v11) do
					if not (typeof(v12) == "table" and typeof(k) == "string" and k:find("local")) then
						continue
					end

					local _Object = v12._Object

					if _Object.Animation.AnimationId == v10 then
						_Object:Stop(0)
					end
				end
			end
		end
	end
else
	v7 = nil
	v6 = nil
end

Anims.Cached = cached

function Anims:GetRaw(childName)
	local v8 = anims:FindFirstChild(childName, true)

	if not v8 and childName:find("asset") then
		v8 = Instance.new("Animation")
		v8.AnimationId = childName
		v8.Name = childName
		v8.Parent = anims["0"]
	end

	return v8
end

function Anims.CollectGarbage(_) end

function Anims:Preload(p)
	if isServer then
		return
	end

	task.spawn(function()
		local raw = self:GetRaw(p)

		if raw then
			task.spawn(function()
				local character = game.Players.LocalPlayer.Character
				local humanoid = character and character:FindFirstChild("Humanoid")

				if humanoid then
					humanoid:LoadAnimation(raw)
				end
			end)
		end
	end)
end

local RunService6 = game:GetService("RunService")

if RunService6:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false and not isServer then
	v7.OnClientEvent:Connect(function(p, items)
		if p == "PreloadArray" then
			for _, item in pairs(items) do
				local raw = Anims:GetRaw(item)

				if not raw then
					continue
				end

				local ContentProvider2 = game:GetService("ContentProvider")
				ContentProvider2:PreloadAsync({ raw })
			end
		end
	end)
end

function Anims.PreloadOnClients(_, p)
	v7:FireAllClients("PreloadArray", p)
end

local animationsByAnimationId = {}
local RunService7 = game:GetService("RunService")

if RunService7:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	for _, animation in pairs(anims:GetDescendants()) do
		if animation:IsA("Animation") then
			animationsByAnimationId[animation.AnimationId] = animation
		end
	end
end

if isClient then
	local RunService8 = game:GetService("RunService")

	if RunService8:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
		function Anims:GetLocalAnimator(p)
			self:MakeCachedCharacter(p)
			local v8 = self.Cached[p]

			if v8.__LocalAnimator then
				return v8.__LocalAnimator
			end

			local __Animator = v8.__Animator

			if not __Animator:IsA("Animator") then
				warn("blah")
			end

			local animator = Instance.new("Animator")
			animator.Parent = __Animator.Parent
			animator.Name = "Animator"
			v8.LocalAnimatorCache = {
				__Animator = animator,
				__LastAnimation = {},
				__AnimationPriorities = {},
				__LastIndex = 0
			}
			v8.__LocalAnimator = animator
			return v8.__LocalAnimator
		end
	end
end

function Anims:MakeCachedCharacter(instance)
	if not self.Cached[instance] then
		local animator = instance:FindFirstChildWhichIsA("Humanoid") and instance:FindFirstChildWhichIsA("Humanoid"):FindFirstChildWhichIsA("Animator")
		self.Cached[instance] = {
			__Animator = animator or instance:FindFirstChildWhichIsA("Animator", true) or instance:FindFirstChildWhichIsA("Humanoid") or instance:FindFirstChildWhichIsA("AnimationController"),
			__LastAnimation = {},
			__AnimationPriorities = {},
			__LastIndex = 0
		}
		local __Animator = self.Cached[instance].__Animator

		if __Animator then
			for _, v8 in __Animator:GetPlayingAnimationTracks() do
				if v8.Animation.AnimationId:find("?local=true") then
					v8:Stop(0)
				end
			end

			local animationPlayedConnection = __Animator.AnimationPlayed:Connect(function(instance2)
				local v8 = instance2.Animation.AnimationId:find("?local=true")

				if (isServer or instance ~= game.Players.LocalPlayer.Character) and v8 then
					if isServer then
						task.spawn(function()
							for _, v9 in game.Players:GetPlayers() do
								local v10 = v9
								task.spawn(function()
									v6:InvokeClient(v10, "StopLocalId", instance, instance2.Animation.AnimationId)
								end)
							end
						end)
						task.defer(function()
							for _ = 1, 20 do
								task.wait()
								instance2:Stop(0)
							end

							task.wait()
							instance2:Destroy()
							task.wait()
						end)
					else
						for _ = 1, 20 do
							task.wait()
							instance2:Stop(0)
						end

						task.wait()
						instance2:Destroy()
					end
				else
					if v8 then
						return
					end

					if isServer then
						local name = instance2.Name

						if name == "Animation" then
							local v9 = animationsByAnimationId[instance2.Animation.AnimationId]

							if v9 then
								local name2 = v9.Name
								instance2.Name = name2
								local v10 = self.Cached[instance][name2]

								if not v10 then
									v5.new(instance2, self.Cached[instance])
									return
								end

								v10._Object:Stop()
								v10._Object:Destroy()
								rawset(v10, "_Object", instance2)
							end
						else
							local v9 = self.Cached[instance][name]

							if v9 and v9._Object ~= instance2 then
								if v9._Object then
									v9._Object:Stop()
									v9._Object:Destroy()
								end

								rawset(v9, "_Object", instance2)
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
		function Anims:GetLocal(p, p2: string)
			self:MakeCachedCharacter(p)
			collectGarbage()
			local v8 = self.Cached[p][p2 .. "local"]

			if v8 then
				return v8
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

				local v9 = v5.new(track, self.Cached[p])
				self.Cached[p][p2 .. "local"] = v9
				return v9
			end

			return nil
		end
	end
end

local function Blank(_, ...) end

local v8 = {
	Play = Blank,
	Stop = Blank,
	GetTimeOfKeyframe = function()
		return 0
	end,
	GetMarkerReachedSignal = function()
		local v9 = Signal2.new()
		task.defer(function()
			v9:Fire()
		end)
		return v9
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
local object = setmetatable({}, {
	__index = function(p, p2)
		if p2 == "DidLoop" or p2 == "Ended" or p2 == "KeyframeReached" or p2 == "Stopped" then
			local v9 = Signal2.new()
			task.defer(function()
				v9:Fire()
			end)
			return v9
		elseif p2 == "_Object" then
			return p
		else
			return v8[p2]
		end
	end,
	__newindex = function(_, _, _) end
})

function Anims:GetAwaited(p, p2: string, value: number)
	local v9 = self:Get(p, p2)
	local total = 0
	local v10 = value or 5

	while not (v9 and rawget(v9, "_Object")) do
		total += task.wait()
		v9 = self:Get(p, p2)

		if not (v10 < total) then
			continue
		end

		warn("Fail await anim", p2)
		return v9
	end

	return v9
end

function Anims:Get(character, p2: string)
	self:MakeCachedCharacter(character)
	local v9 = self.Cached[character][p2]
	local v10 = nil

	if v9 then
		return v9
	end

	local raw = self:GetRaw(p2)

	if raw then
		v10 = raw
		local __Animator = self.Cached[character].__Animator

		if __Animator then
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
				return object
			end

			if __Animator.Parent ~= nil then
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
					}, (getmetatable(object))))
				end

				local v11 = v5.new(track, self.Cached[character])
				self.Cached[character][p2] = v11
				return v11
			end
		end
	end

	return (setmetatable({}, {
		__index = function()
			return function()
				warn("anims error..", v10, debug.traceback())
			end
		end
	}))
end

function Anims:HookOnPause(p)
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

function Anims.Build(p, instance)
	local func = {
		Get = function(self, p2)
			return Anims:Get(instance, p2)
		end,
		GetAwaited = function(self, p2)
			return Anims:GetAwaited(instance, p2)
		end,
		HookOnPause = function(p2)
			return Anims.HookOnPause(p2)
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
	return func
end

if RunService:IsClient() then
	local RunService8 = game:GetService("RunService")

	if RunService8:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
		local v9 = { "rbxassetid://10122845177" }

		if workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Dressrosa") then
			table.insert(v9, "rbxassetid://7152363872")
			table.insert(v9, "rbxassetid://7152367896")
		end

		task.spawn(function()
			ContentProvider:PreloadAsync(v9)
		end)
	end
end

if isServer then
	task.defer(function()
		local ConfigService = require(game.ServerScriptService.ConfigService)
		local flag2 = false
		ConfigService.handleConfigUpdate("ServerClipPreload", function(p)
			if flag2 or not p then
				return
			end

			flag2 = true
			task.spawn(function()
				for _, v9 in v4 do
					local v10 = v9
					fn(pcall(function()
						local animationId = Anims:GetRaw(v10).AnimationId
						task.spawn(function()
							ContentProvider:PreloadAsync({ animationId })
						end)
						local animationClipAsync = AnimationClipProvider:GetAnimationClipAsync(animationId)

						if animationClipAsync then
							local parent = script:FindFirstChildOfClass("Camera")

							if not parent then
								parent = Instance.new("Camera")
								parent.Name = "ServerPreload"
								parent.Parent = script
							end

							animationClipAsync.Parent = parent
							task.delay(1, function()
								animationClipAsync.Parent = nil
							end)
						end
					end))
				end
			end)
		end)
	end)
end

return Anims