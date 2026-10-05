local ContentProvider = game:GetService("ContentProvider")
local v = {
	FinalResultsCamera = "rbxassetid://18110142424",
	FinalResultsPlayer1 = "rbxassetid://18110150396",
	FinalResultsPlayer2 = "rbxassetid://18110151901",
	FinalResultsPlayer3 = "rbxassetid://18110154615",
	FinalResultsPlayer4 = "rbxassetid://18110156683",
	FinalResultsPlayer5 = "rbxassetid://18110158144",
	SlidingStartForward = "rbxassetid://17702562791",
	SlidingStartRightward = "rbxassetid://18887331786",
	SlidingStartBackward = "rbxassetid://18887315202",
	SlidingStartLeftward = "rbxassetid://18887335228",
	SlidingLoopForward = "rbxassetid://17702566891",
	SlidingLoopRightward = "rbxassetid://18887328608",
	SlidingLoopBackward = "rbxassetid://18887323938",
	SlidingLoopLeftward = "rbxassetid://18887339224",
	SlidingJump = "rbxassetid://17704241464",
	SlidingJumpFall = "rbxassetid://17704252963",
	WeaponUnlockIdle = "rbxassetid://17652443406",
	WeaponUnlockPlay = "rbxassetid://17652360108",
	LobbyPortalFalling = "rbxassetid://111331261961557",
	ZombieSpawn = "rbxassetid://81895123077452"
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._preloaded_animations_by_name = {}
	self._preloaded_animations_by_animation_id = {}
	self:_Init()
	return self
end

function class.GetPreloadedAnimationID(_, p)
	return v[p]
end

function class:GetPreloadedAnimation(p2)
	return self._preloaded_animations_by_name[p2]
end

function class:_PreloadAnimations()
	local v2 = {}

	for k, animationId in pairs(v) do
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		self._preloaded_animations_by_name[k] = animation
		self._preloaded_animations_by_animation_id[animationId] = animation
		table.insert(v2, animation)
	end

	while #v2 > 0 do
		local v3 = v2
		v2 = {}
		ContentProvider:PreloadAsync(v3, function(p2, p3)
			if p3 ~= Enum.AssetFetchStatus.Success then
				table.insert(v2, self._preloaded_animations_by_animation_id[p2])
			end
		end)
		wait(1)
	end
end

function class:_Init()
	task.defer(self._PreloadAnimations, self)
end

return class._new()