local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local v = Component.new({
	Tag = "SnowboardMobileUI"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._moveVector = createVector(0, 0, 0)
	self._mobileUIActive = true
	self._pitchDisabled = false
	self.JumpSignal = self._Janitor:Add(Signal.new())
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
	self._Janitor:Add(self.Instance.Jump.InputBegan:Connect(function()
		self._jumpDown = true
	end))
	self._Janitor:Add(self.Instance.Jump.InputEnded:Connect(function()
		self._jumpDown = false
	end))
	self._Janitor:Add(self.Instance.Jump.MouseButton1Down:Connect(function()
		self.JumpSignal:Fire()
	end))
	self._Janitor:Add(Platform.PlatformChangedSignal:Connect(function()
		self:Open()
	end))
	self:Close()
end

function v:Open()
	if Platform.IsMobile() and self._mobileUIActive then
		PanelController.OpenPanelByContext("Snowboard", "SnowboardMobileUI")
	else
		PanelController.Close("Snowboard", "SnowboardMobileUI")
	end
end

function v:Close()
	PanelController.Close("Snowboard", "SnowboardMobileUI")
	self._moveVector = createVector(0, 0, 0)
end

function v:GetMoveVector()
	return self._moveVector
end

function v:IsMobileUIActive()
	return self._mobileUIActive and Platform.IsMobile()
end

function v:GetJumpDown()
	return self._jumpDown
end

function v:IsPitchDisabled()
	return self._pitchDisabled
end

function v:Stop()
	self._Janitor:Destroy()
end

return v