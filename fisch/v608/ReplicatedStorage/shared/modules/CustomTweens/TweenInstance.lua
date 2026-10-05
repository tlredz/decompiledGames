game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local packages = ReplicatedStorage.packages
require(packages.Net)
require(packages.Signal)
require(packages.Trove)
local _ = ReplicatedStorage.shared.modules
local utils = ReplicatedStorage.shared.utils
local Easing = require(utils.Easing)
local v = {}
require("./Types")

local function lerp(value, data, alpha: number)
	if value == data then
		return value
	end

	if typeof(value) == "number" then
		return (math.lerp(value, data, alpha))
	end

	if typeof(value) ~= "boolean" then
		if typeof(value) == "Vector2" or typeof(value) == "Vector3" or typeof(value) == "CFrame" or typeof(value) == "Color3" then
			return value:Lerp(data, alpha)
		end

		if typeof(value) == "UDim" then
			return UDim.new(math.lerp(value.Scale, data.Scale, alpha), (math.lerp(value.Offset, data.Offset, alpha)))
		end

		if typeof(value) == "UDim2" then
			return UDim2.new(
				math.lerp(value.X.Scale, data.X.Scale, alpha),
				math.lerp(value.X.Offset, data.X.Offset, alpha),
				math.lerp(value.Y.Scale, data.Y.Scale, alpha),
				(math.lerp(value.Y.Offset, data.Y.Offset, alpha))
			)
		end

		if typeof(value) == "Rect" then
			return Rect.new(value.Min:Lerp(data.Min, alpha), value.Max:Lerp(data.Max, alpha))
		end

		if typeof(value) == "Vector3int16" then
			return Vector3int16.new(
				math.lerp(value.X, data.X, alpha),
				math.lerp(value.Y, data.Y, alpha),
				(math.lerp(value.Z, data.Z, alpha))
			)
		end

		if typeof(value) == "Vector2int16" then
			return Vector2int16.new(math.lerp(value.X, data.X, alpha), (math.lerp(value.Y, data.Y, alpha)))
		end

		if typeof(value) == "NumberRange" then
			return NumberRange.new(math.lerp(value.Min, data.Min, alpha), (math.lerp(value.Max, data.Max, alpha)))
		end

		if typeof(value) == "table" and typeof(value.Lerp) == "function" then
			return value:Lerp(data, alpha)
		end
	end

	if alpha >= 1 then
		return data
	end

	return value
end

local function releaseProperties(p)
	local v3 = p.type == 0 and v[p.target]

	if v3 then
		for k, v4 in next, v3, nil do
			if v4 ~= p then
				continue
			end

			v3[k] = nil
			v3._n -= 1
		end

		if v3._n <= 0 then
			v[p.target] = nil
		end
	end
end

local function claimProperties(object)
	if object.type == 0 then
		local data = v[object.target]

		if not data then
			data = {
				_n = 0
			}
			v[object.target] = data
		end

		for k in object.props do
			local v3 = data[k]
			data[k] = object

			if v3 == nil then
				data._n += 1
			elseif v3 ~= object then
				v3:Cancel()
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function endTween(instance)
	instance.playing = false
	instance.time = 0
	instance.Completed:Fire(Enum.PlaybackState.Completed)
	releaseProperties(instance)

	if not instance.persistent then
		instance:Destroy()
	end
end

local frozen = table.freeze({
	__index = table.freeze({
		GetAlpha = function(self)
			if self.time >= self._totalTime then
				if self.info.Reverses then
					return 0
				end

				return 1
			else
				local v3 = self.time % self._cycleTime - self.info.DelayTime

				if v3 <= 0 then
					return 0
				end

				if self.info.Reverses then
					v3 = self.info.Time - math.abs(self.info.Time - v3)
				end

				local v4 = math.clamp(v3 / self.info.Time, 0, 1)
				return self._ease(v4, 0, 1, 1)
			end
		end,
		Step = function(self, p: number)
			if self._destroyed or not self.playing then
				return
			end

			self.time += p
			local alpha = self:GetAlpha()

			if self.type == 0 then
				local target = self.target
				local original_props = self.original_props

				for k, v3 in self.props do
					target[k] = lerp(original_props[k], v3, alpha)
				end
			elseif self.type == 1 then
				self.callback(lerp(self.startValue, self.endValue, alpha), alpha, p)
			end

			if self.time >= self._totalTime then
				endTween(self) -- equivalent call inferred; original call site unknown
			end
		end,
		Play = function(self, original_props)
			if self._destroyed then
				return
			end

			if original_props then
				self.original_props = original_props
			elseif self.type == 0 then
				local target = self.target
				local original_props2 = {}

				for k in self.props do
					original_props2[k] = target[k]
				end

				self.original_props = original_props2
			end

			self.playing = true
			self.state = Enum.PlaybackState.Playing
			self.time = 0
			claimProperties(self)

			if original_props or self.type == 1 then
				self:Step(0)
			end
		end,
		Pause = function(self)
			if self._destroyed then
				return
			end

			self.playing = false
			self.state = Enum.PlaybackState.Paused
			releaseProperties(self)
		end,
		Resume = function(self)
			if self._destroyed then
				return
			end

			if self.state ~= Enum.PlaybackState.Paused then
				self:Play()
				return
			end

			self.playing = true
			self.state = Enum.PlaybackState.Playing
			claimProperties(self)
			self:Step(0)
		end,
		Cancel = function(self)
			if self.playing then
				self.playing = false
				self.state = Enum.PlaybackState.Cancelled
				self.time = 0
				releaseProperties(self)

				if self.type == 0 and self.original_props and self.target then
					for k, original_prop in self.original_props do
						self.target[k] = original_prop
					end
				end

				self.Completed:Fire(Enum.PlaybackState.Cancelled)
			end

			if not self.persistent then
				self:Destroy()
			end
		end,
		Destroy = function(self)
			if self._destroyed then
				return
			end

			self._destroyed = true

			if self._destroyConn then
				self._destroyConn:Disconnect()
				self._destroyConn = nil
			end

			if self.playing then
				self:Cancel()
			end

			self.target = nil
			self.callback = nil
			self.startValue = nil
			self.endValue = nil
			self.props = nil
			self.original_props = nil
			task.delay(1, function()
				self.Completed:Destroy()
			end)
		end
	})
})
return {
	new = function(p)
		local object = setmetatable(p, frozen)

		if typeof(p.target) == "Instance" then
			object._destroyConn = p.target.Destroying:Once(function()
				object:Destroy()
			end)
		end

		local info = p.info
		object._ease = Easing[info.EasingDirection.Name][info.EasingStyle.Name]
		local time = info.Time

		if info.Reverses then
			time *= 2
		end

		if info.DelayTime > 0 then
			time += info.DelayTime
		end

		object._cycleTime = time

		if info.RepeatCount == -1 then
			object._totalTime = 1e999
			return object
		end

		object._totalTime = time * (info.RepeatCount + 1)
		return object
	end
}