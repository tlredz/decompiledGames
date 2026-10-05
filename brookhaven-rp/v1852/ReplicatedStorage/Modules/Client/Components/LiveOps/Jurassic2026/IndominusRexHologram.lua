local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "IndominusRexHologram"
})
local v2 = {
	"Idle",
	"Walk",
	"Run",
	"Roar"
}
local v3 = {
	Idle = 8,
	Walk = 6,
	Run = 6
}
local v4 = {
	ButtonIdle = "Idle",
	ButtonWalk = "Walk",
	ButtonRun = "Run",
	ButtonRoar = "Roar"
}
local color = Color3.fromRGB(63, 106, 43)

function v:Construct()
	self._Janitor = Janitor.new()
	self._isRunning = true
	self._tracks = {}
	self._buttons = {}
	self._buttonIdleColors = {}
	self._requestedAnimation = nil
	self._lastPressedAt = -1e999
	self._clickSound = nil
end

function v:_waitOrInterrupt(p2: number)
	local lastTime = os.clock()

	while self._isRunning and self._requestedAnimation == nil and os.clock() - lastTime < p2 do
		task.wait()
	end
end

function v:_setActiveButton(p2: string)
	for k, _button in self._buttons do
		local color2

		if k == p2 then
			color2 = color
		else
			color2 = self._buttonIdleColors[k]
		end

		_button.Color = color2
	end
end

function v:_playAnimation(p: string)
	local _track = self._tracks[p]
	self:_setActiveButton(p)
	_track:Play(0.5)
	local v5 = v3[p]

	if v5 == nil then
		local lastTime = os.clock()

		while self._isRunning and self._requestedAnimation == nil and _track.IsPlaying and os.clock() - lastTime < 5 do
			task.wait()
		end
	else
		self:_waitOrInterrupt(v5)
	end

	if _track.IsPlaying then
		_track:Stop(0.5)
	end

	task.wait(0.5)
end

function v:_connectButton(p, p2, requestedAnimation: string)
	self._buttons[requestedAnimation] = p
	self._buttonIdleColors[requestedAnimation] = p.Color
	self._Janitor:Add(p2.MouseClick:Connect(function()
		local now = os.clock()

		if now - self._lastPressedAt < 2 then
			return
		end

		self._lastPressedAt = now
		self._requestedAnimation = requestedAnimation
		self._clickSound:Play()
	end))
	self._Janitor:Add(function()
		p.Color = self._buttonIdleColors[requestedAnimation]
	end)
end

function v:Start()
	local instance = self.Instance
	local indominusRex = instance:WaitForChild("indominusRex")
	local animator = instance:WaitForChild("AnimationController"):WaitForChild("Animator")
	local animations = instance:WaitForChild("Animations")
	local roar = indominusRex:WaitForChild("Roar")
	self._clickSound = instance:WaitForChild("Sound"):WaitForChild("ClickSound")
	local v5 = {}

	for _, childName in v2 do
		v5[childName] = animations:WaitForChild(childName)
	end

	local children = {}
	local clickDetectors = {}

	for childName, v6 in v4 do
		local child = instance:WaitForChild(childName)
		children[v6] = child
		clickDetectors[v6] = child:WaitForChild("ClickDetector")
	end

	if not self._isRunning then
		return
	end

	for _, v6 in v2 do
		local track = animator:LoadAnimation(v5[v6])
		track.Looped = v3[v6] ~= nil
		self._tracks[v6] = track
		self._Janitor:Add(track)
	end

	self._Janitor:Add(self._tracks.Roar:GetMarkerReachedSignal("Roar"):Connect(function()
		roar:Play()
	end))

	for k, v6 in children do
		self:_connectButton(v6, clickDetectors[k], k)
	end

	local thread = task.spawn(function()
		local v6 = 1

		while self._isRunning do
			local _requestedAnimation = self._requestedAnimation

			if _requestedAnimation == nil then
				self:_playAnimation(v2[v6])
				v6 = v6 % #v2 + 1
			else
				self._requestedAnimation = nil
				self:_playAnimation(_requestedAnimation)
			end
		end
	end)
	self._Janitor:Add(function()
		task.cancel(thread)
	end)
end

function v:Stop()
	self._isRunning = false
	self._Janitor:Destroy()
end

return v