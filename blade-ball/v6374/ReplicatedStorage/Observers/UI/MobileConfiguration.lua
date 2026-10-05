local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local DeviceChecker = require(localPlayer.PlayerScripts:WaitForChild("Client"):WaitForChild("DeviceChecker"))
return Observers.observeTagNoAncestry("UI_MobileConfiguration", function(instance)
	local maid = Utils.Maid.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdatePosition(position: UDim2)
		if not (position and DeviceChecker:IsMobile()) then
			maid.ResetPosition = nil
			return
		end

		local position2 = instance.Position

		function maid.ResetPosition()
			instance.Position = position2
		end

		instance.Position = position
	end

	local movingPosition = instance:GetAttribute("MovingPosition")

	if movingPosition and DeviceChecker:IsMobile() then
		local position = instance.Position

		function maid.ResetPosition()
			instance.Position = position
		end

		instance.Position = movingPosition
	else
		UpdatePosition() -- equivalent call inferred; original call site unknown
	end

	maid.OnMovingPositionChanged = instance:GetAttributeChangedSignal("MovingPosition"):Connect(function()
		local movingPosition2 = instance:GetAttribute("MovingPosition")

		if not (movingPosition2 and DeviceChecker:IsMobile()) then
			UpdatePosition() -- equivalent call inferred; original call site unknown
			return
		end

		local position = instance.Position

		function maid.ResetPosition()
			instance.Position = position
		end

		instance.Position = movingPosition2
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateSize(size)
		if not (size and DeviceChecker:IsMobile()) then
			maid.ResetSize = nil
			return
		end

		local size2 = instance.Size

		function maid.ResetSize()
			instance.Size = size2
		end

		instance.Size = size
	end

	local movingSize = instance:GetAttribute("MovingSize")

	if movingSize and DeviceChecker:IsMobile() then
		local size = instance.Size

		function maid.ResetSize()
			instance.Size = size
		end

		instance.Size = movingSize
	else
		UpdateSize() -- equivalent call inferred; original call site unknown
	end

	maid.OnMovingSizeChanged = instance:GetAttributeChangedSignal("MovingSize"):Connect(function()
		local movingSize2 = instance:GetAttribute("MovingSize")

		if not (movingSize2 and DeviceChecker:IsMobile()) then
			UpdateSize() -- equivalent call inferred; original call site unknown
			return
		end

		local size = instance.Size

		function maid.ResetSize()
			instance.Size = size
		end

		instance.Size = movingSize2
	end)
	return function()
		maid:Destroy()
	end
end)