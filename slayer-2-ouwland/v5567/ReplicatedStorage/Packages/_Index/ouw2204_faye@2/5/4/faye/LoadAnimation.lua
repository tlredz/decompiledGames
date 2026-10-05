require(script.Parent.FayeTypes)
local AnimatorStorage = require(script.Parent.Compile.Compilers.CompileAnimations.Player.AnimatorStorage)
local OverlapFixer = require(script.Parent.Compile.Compilers.CompileAnimations.Player.OverlapFixer)
local Player = require(script.Parent.Compile.Compilers.CompileAnimations.Player)
local Info = require(script.Parent.Info)
local count = 0
local info = Info()
local FayeUtility = require(script.Parent.Misc.FayeUtility)
local class = {}
class.__index = class

function class:Play(p: number?, flag: boolean?, p2: number?)
	self:Stop(nil, true)

	local function fn(_, _, flag2: boolean)
		if self.Anim ~= nil then
			self:Stop()
			return
		end

		Player.Remove(self.__id)
		self.DeleteFunc = nil

		if flag2 then
			return
		end

		self:Stop()
	end

	local anim, connection = Player.Add(
		self.__id,
		self.To,
		self.Info,
		fn,
		self.Entity,
		self.Property,
		nil,
		nil,
		nil,
		nil,
		true,
		p,
		flag,
		p2
	)

	if anim == nil then
		self.DeleteFunc = fn
		return self
	end

	self.Connection = connection
	self.Anim = anim
	self.Anim:Play()
	return self
end

function class:Skip()
	for k, v2 in pairs(self.To) do
		self.Entity[k] = v2
	end

	if self.Anim == nil then
		if self.DeleteFunc ~= nil then
			self.DeleteFunc(nil, nil, true)
			self.DeleteFunc = nil
		end
	else
		if self.Anim.PlaybackState == Enum.PlaybackState.Playing then
			self.Anim:Cancel()
			self.Anim = nil
		end

		if self.Connection ~= nil then
			self.Connection:Disconnect()
			self.Connection = nil
		end

		OverlapFixer.Remove(self.Entity, self.Property)
	end

	self.Elapsed = nil
	self.Direction = nil
	self.ProgBefore = nil
	self:Destroy(true)
	return self
end

function class:Stop(flag: boolean?, flag2: boolean?)
	if self.Anim == nil then
		if self.DeleteFunc ~= nil then
			self.DeleteFunc(nil, nil, true)
			self.DeleteFunc = nil
		end
	else
		if flag then
			return
		end

		if self.Anim.PlaybackState == Enum.PlaybackState.Playing then
			self.Anim:Cancel()
			self.Anim = nil
		end

		if self.Connection ~= nil then
			self.Connection:Disconnect()
			self.Connection = nil
		end

		OverlapFixer.Remove(self.Entity, self.Property)
	end

	if flag then
		return
	end

	self.Elapsed = nil
	self.Direction = nil
	self.ProgBefore = nil

	if flag2 == nil then
		self:Destroy(true)
	end
end

function class:Pause()
	if self.Anim ~= nil then
		self.Anim:Pause()
		return self
	end

	local v2 = AnimatorStorage.Holder[self.__id]
	self.ProgBefore = v2.ProgBefore
	self.Elapsed = v2.Elapsed
	self.Direction = v2.Direction
	self:Stop(true)
	return self
end

function class:Resume()
	if self.Anim == nil then
		self:Play(self.Elapsed, self.Direction, self.ProgBefore)
		return self
	end

	self.Anim:Play()
	return self
end

function class:Destroy(flag: boolean?)
	if flag == nil then
		self:Stop()
	end

	if self.Thread ~= nil then
		FayeUtility.RemoveFromThread(self.Thread, self)
	end
end

return function(instance, to, info2, thread)
	if instance == nil or to == nil or FayeUtility.tof(to) ~= FayeUtility.tabletxt then
		warn("Was unable to create animation, check the parameters and retry!")
		return
	end

	if info2 == nil then
		info2 = info
	end

	if instance.ClassName == nil then
		instance = instance.Instance

		if instance.ClassName == nil then
			warn("Entity must be a roblox instance or faye instance")
			return
		end
	end

	local property = ""

	for k, _ in pairs(to) do
		property ..= k
	end

	local v3 = {
		Entity = instance,
		To = to,
		IsActive = true,
		Property = property,
		Info = info2,
		__id = "PlayedAnimation_" .. count,
		Thread = thread
	}
	setmetatable(v3, class)
	count += 1

	if thread ~= nil then
		FayeUtility.AddToThread(thread, v3)
	end

	return v3
end