local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "CharacterJobMenu"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	local scrollingFrame = instance:WaitForChild("Catalog"):WaitForChild("Container"):WaitForChild("ScrollingFrameJob"):WaitForChild("ScrollingFrame")
	local uIGridLayout = scrollingFrame:WaitForChild("UIGridLayout")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function refreshCanvasSize()
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uIGridLayout.AbsoluteContentSize.Y)
	end

	refreshCanvasSize() -- equivalent call inferred; original call site unknown
	self._Janitor:Add(instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if instance.Visible == true then
			refreshCanvasSize() -- equivalent call inferred; original call site unknown
		end
	end))
	self._Janitor:Add(uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCanvasSize))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v