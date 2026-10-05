local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "MobileControlUI"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.OnJumpStarted = self._Janitor:Add(Signal.new())
	self.OnJumpEnded = self._Janitor:Add(Signal.new())
	self.MoveVectorUpdated = self._Janitor:Add(Signal.new())
end

function v:Start()
	local v2 = false
	local v3 = false
	local v4 = false
	local v5 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateMoveVector()
		local v6 = (v2 and -1 or 0) + (v3 and 1 or 0)
		local v7 = (v4 and -1 or 0) + (v5 and 1 or 0)
		self._moveVector = Vector3.new(v7, 0, v6)
		self.MoveVectorUpdated:Fire(self._moveVector)
	end

	self._Janitor:Add(self.Instance.Up.InputBegan:Connect(function(_)
		v2 = true
		updateMoveVector() -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(self.Instance.Down.InputBegan:Connect(function(_)
		v3 = true
		updateMoveVector() -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(self.Instance.Left.InputBegan:Connect(function(_)
		v4 = true
		updateMoveVector() -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(self.Instance.Right.InputBegan:Connect(function(_)
		v5 = true
		updateMoveVector() -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(self.Instance.Up.InputEnded:Connect(function(_)
		v2 = false
		updateMoveVector() -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(self.Instance.Down.InputEnded:Connect(function(_)
		v3 = false
		updateMoveVector() -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(self.Instance.Left.InputEnded:Connect(function(_)
		v4 = false
		updateMoveVector() -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(self.Instance.Right.InputEnded:Connect(function(_)
		v5 = false
		updateMoveVector() -- equivalent call inferred; original call site unknown
	end))
	self._Janitor:Add(self.Instance.Jump.MouseButton1Down:Connect(function()
		self.OnJumpStarted:Fire()
	end))
	self._Janitor:Add(self.Instance.Jump.MouseButton1Up:Connect(function()
		self.OnJumpEnded:Fire()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v