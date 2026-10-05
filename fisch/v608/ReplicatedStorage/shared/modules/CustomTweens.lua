game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage.packages
require(packages.Net)
local Signal = require(packages.Signal)
require(packages.Trove)
local _ = ReplicatedStorage.shared.modules
local utils = ReplicatedStorage.shared.utils
require(utils.GeneralUtils)
require(utils.NumberUtils)
require("@self/Types")
local module = require("@self/TweenInstance")
local frozen = table.freeze({
	__index = table.freeze({
		StepAll = function(self, p: number)
			debug.profilebegin("TweenManager::StepAll")
			self._stepNumber += 1

			for k, activeTween in next, self.activeTweens, nil do
				if activeTween.playing then
					activeTween:Step(p)
				end

				if activeTween._destroyed then
					self.activeTweens[k] = nil
				end
			end

			for k, activeYield in next, self.activeYields, nil do
				if activeYield.step == self._stepNumber then
					continue
				end

				activeYield.timer -= p

				if not (activeYield.timer <= 0) then
					continue
				end

				if typeof(activeYield.target) ~= "thread" or coroutine.status(activeYield.target) == "suspended" then
					task.spawn(activeYield.target)
				end

				self.activeYields[k] = nil
			end

			self._stepNumber += 1
			debug.profileend()
		end,
		Create = function(self, target, info, props)
			if typeof(target) == "table" then
				assert(not table.isfrozen(target), "Tween target cannot be frozen")
			end

			local v = module.new({
				info = info,
				type = 0,
				persistent = false,
				time = 0,
				state = Enum.PlaybackState.Begin,
				playing = false,
				target = target,
				props = props,
				originalProps = nil,
				Completed = Signal.new(),
				_destroyed = nil
			})

			if self._destroyed then
				v:Destroy()
				return v
			end

			table.insert(self.activeTweens, v)
			return v
		end,
		CreatePersistent = function(self, p, p2, p3)
			local v = self:Create(p, p2, p3)
			v.persistent = true
			return v
		end,
		CreateAndPlay = function(self, p, p2, p3, p4)
			local v = self:Create(p, p2, p3)
			v:Play(p4)
			return v
		end,
		CreateCallback = function(self, info, startValue, endValue, callback)
			local v = module.new({
				info = info,
				type = 1,
				persistent = false,
				time = 0,
				state = Enum.PlaybackState.Begin,
				playing = false,
				startValue = startValue,
				endValue = endValue,
				callback = callback,
				Completed = Signal.new(),
				_destroyed = nil
			})

			if self._destroyed then
				v:Destroy()
				return v
			end

			table.insert(self.activeTweens, v)
			return v
		end,
		CreateCallbackPersistent = function(self, p, p2, p3, callback)
			local callback2 = self:CreateCallback(p, p2, p3, callback)
			callback2.persistent = true
			return callback2
		end,
		CreateCallbackAndPlay = function(self, p, p2, p3, callback)
			local callback2 = self:CreateCallback(p, p2, p3, callback)
			callback2:Play()
			return callback2
		end,
		Wait = function(data, timer: number)
			local thread = coroutine.running()

			if data._destroyed then
				task.cancel(thread)
				return 0
			end

			table.insert(data.activeYields, {
				timer = timer,
				target = thread,
				step = data._stepNumber
			})
			local lastTime = os.clock()
			coroutine.yield()
			return os.clock() - lastTime
		end,
		Delay = function(data, timer: number, callback, ...)
			local v = table.pack(...)
			local thread = coroutine.create(function()
				return callback(table.unpack(v))
			end)

			if data._destroyed then
				task.cancel(thread)
				return thread
			end

			table.insert(data.activeYields, {
				timer = timer,
				target = thread,
				step = data._stepNumber
			})
			return thread
		end,
		Destroy = function(self)
			if self._destroyed then
				return
			end

			self._destroyed = true

			for _, activeTween in next, self.activeTweens, nil do
				activeTween:Destroy()
			end

			table.clear(self.activeTweens)

			for _, activeYield in next, self.activeYields, nil do
				if not (typeof(activeYield.target) == "thread" and coroutine.status(activeYield.target) == "suspended") then
					continue
				end

				task.cancel(activeYield.target)
			end

			table.clear(self.activeYields)
		end
	})
})
local v = {
	new = function()
		return (setmetatable({
			activeTweens = {},
			activeYields = {},
			_stepNumber = 0,
			_destroyed = nil
		}, frozen))
	end
}
v.Heartbeat = v.new()
v.PostSimulation = v.new()
v.PreAnimation = v.new()
v.PreRender = v.new()
v.PreSimulation = v.new()
v.FirstRenderStep = v.new()
v.PreCameraStep = v.new()
v.PreCharacterStep = v.new()
v.LastRenderStep = v.new()
local flag = false

function v.init()
	if flag then
		return
	end

	flag = true
	RunService.Heartbeat:Connect(function(dt: number)
		v.Heartbeat:StepAll(dt)
	end)
	RunService.PostSimulation:Connect(function(dt: number)
		v.PostSimulation:StepAll(dt)
	end)
	RunService.PreAnimation:Connect(function(dt: number)
		v.PreAnimation:StepAll(dt)
	end)
	RunService.PreSimulation:Connect(function(dt: number)
		v.PreSimulation:StepAll(dt)
	end)

	if RunService:IsClient() then
		RunService.PreRender:Connect(function(dt: number)
			v.PreRender:StepAll(dt)
		end)
		RunService:BindToRenderStep(
			"TweenManager.FirstRenderStep",
			Enum.RenderPriority.First.Value + 1,
			function(p: number)
				v.FirstRenderStep:StepAll(p)
			end
		)
		RunService:BindToRenderStep(
			"TweenManager.PreCameraStep",
			Enum.RenderPriority.Camera.Value - 1,
			function(p: number)
				v.PreCameraStep:StepAll(p)
			end
		)
		RunService:BindToRenderStep(
			"TweenManager.PreCharacterStep",
			Enum.RenderPriority.Character.Value - 1,
			function(p: number)
				v.PreCharacterStep:StepAll(p)
			end
		)
		RunService:BindToRenderStep(
			"TweenManager.LastRenderStep",
			Enum.RenderPriority.Last.Value - 1,
			function(p: number)
				v.LastRenderStep:StepAll(p)
			end
		)
	end
end

return table.freeze(v)