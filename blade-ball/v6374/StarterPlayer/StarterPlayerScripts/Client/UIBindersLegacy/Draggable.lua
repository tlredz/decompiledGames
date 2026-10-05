local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local Utils = require(game.ReplicatedStorage.Common.Utils)
require(game.ReplicatedStorage.Packages.Replion)
local Signal = require(game.ReplicatedStorage.Packages.Signal)
local BinderCache = require(game.ReplicatedStorage.ClientGameModules.BinderCache)
local Draggable = {}
local mouseButton1 = Enum.UserInputType.MouseButton1
local touch = Enum.UserInputType.Touch
local v = Enum.UserInputState.End
local mouseMovement = Enum.UserInputType.MouseMovement
Draggable.DragStarted = Signal.new()
Draggable.DragEnded = Signal.new()

function Draggable:Binder()
	local v2 = BinderCache:Get("UI_" .. script.Name)
	local v3 = nil

	while not v3 do
		v3 = v2:Get(self)
		task.wait()
	end

	local maid = Utils.Maid.new()
	local flag = false
	local position = nil
	local position2 = nil
	local v4 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update(p)
		local v5 = p.Position - position
		self.Position = UDim2.new(
			position2.X.Scale,
			position2.X.Offset + v5.X,
			position2.Y.Scale,
			position2.Y.Offset + v5.Y
		)
	end

	local function inputBegan(p)
		local userInputType = p.UserInputType

		if userInputType == mouseButton1 or userInputType == touch then
			flag = true
			position = p.Position
			position2 = self.Position
			Draggable.DragStarted:Fire(v3, self)
		end
	end

	maid:GiveTask(self.InputBegan:Connect(inputBegan))

	local function inputChanged(p)
		local userInputType = p.UserInputType

		if userInputType == mouseMovement or userInputType == touch then
			v4 = p
		end
	end

	maid:GiveTask(self.InputChanged:Connect(inputChanged))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function inputEnded(input)
		local userInputType = input.UserInputType

		if input.UserInputState == v and (userInputType == mouseButton1 or userInputType == touch) then
			flag = false
			Draggable.DragEnded:Fire(v3, self)
		end
	end

	maid:GiveTask(self.InputEnded:Connect(inputEnded))

	local function globalInputChanged(p)
		if p == v4 and flag then
			update(p) -- equivalent call inferred; original call site unknown
		end
	end

	maid:GiveTask(UserInputService.InputChanged:Connect(globalInputChanged))
	maid:GiveTask(UserInputService.InputEnded:Connect(function(input, _: boolean)
		if flag then
			inputEnded(input) -- equivalent call inferred; original call site unknown
		end
	end))
	return maid
end

return Draggable