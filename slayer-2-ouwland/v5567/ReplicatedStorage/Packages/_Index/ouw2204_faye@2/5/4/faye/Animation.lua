require(script.Parent.FayeTypes)
local FayeUtility = require(script.Parent.Misc.FayeUtility)
local count = 0
local ModifyAnimation = require(script.Parent.ModifyAnimation)
local class = {}
class.__index = class
local AnimatorStorage = require(script.Parent.Compile.Compilers.CompileAnimations.Player.AnimatorStorage)

function class:Destroy()
	if self.__animId then
		local v = AnimatorStorage.RegularTweenHolder ~= nil and AnimatorStorage.RegularTweenHolder[self.__animId]

		if not v then
			if AnimatorStorage.Holder == nil then
				v = nil
			else
				v = AnimatorStorage.Holder[self.__animId] or nil
			end
		end

		if v ~= nil then
			v.Delete()
		end
	end

	if self.Thread ~= nil then
		FayeUtility.RemoveFromThread(self.Thread, self)
	end
end

function class:Stop()
	if self.__animId == nil then
		return
	end

	local v = AnimatorStorage.RegularTweenHolder ~= nil and AnimatorStorage.RegularTweenHolder[self.__animId] or AnimatorStorage.Holder ~= nil and AnimatorStorage.Holder[self.__animId] or nil

	if v ~= nil then
		if v.IsValue then
			v.Delete(true, true)
		else
			v.Delete(true)
		end
	end
end

function class:Skip()
	if self.__animId == nil then
		return
	end

	local v = AnimatorStorage.RegularTweenHolder ~= nil and AnimatorStorage.RegularTweenHolder[self.__animId] or AnimatorStorage.Holder ~= nil and AnimatorStorage.Holder[self.__animId] or nil

	if v == nil then
		return
	end

	local to = v.To
	local entity = v.Entity
	local property = v.Property

	if to ~= nil then
		if v.Main == nil then
			if v.Others ~= nil then
				for _, other in ipairs(v.Others) do
					if other.Entity ~= nil and other.Entity.Parent ~= nil then
						other.Entity[other.Property] = to
					end
				end
			end
		else
			entity = v.Main.Instance

			if v.Others ~= nil then
				for _, other in ipairs(v.Others) do
					if other.Main ~= nil and other.Main.Instance ~= nil and other.Main.Instance.Parent ~= nil then
						other.Main.Instance[other.Property] = to
					end
				end
			end
		end

		if entity ~= nil and property ~= nil then
			entity[property] = to
		end
	end

	if v ~= nil then
		if v.IsValue then
			v.Delete(true, true)
		else
			v.Delete(true)
		end
	end
end

return function(goal, info, p3, thread)
	local v = {
		Goal = goal,
		Info = info,
		__type = "Animation",
		__animId = "Anim_" .. count
	}

	if thread == nil then
		v.NoThread = true
	end

	count += 1

	if p3 ~= nil then
		ModifyAnimation(v, p3)
	end

	setmetatable(v, class)

	if thread == nil or thread.__Destroying ~= nil then
		if thread ~= nil then
			v.DestroyOnClean = true
		end
	else
		v.Thread = thread
		FayeUtility.AddToThread(thread, v)
	end

	return v
end