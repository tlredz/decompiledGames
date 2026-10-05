local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("UI_TextAlign", function(instance)
	local maid = Utils.Maid.new()

	local function UpdateSize(instance2)
		local contentText = instance2.ContentText
		local Y = instance2.AbsoluteSize.Y
		local textSize = TextService:GetTextSize(tostring(contentText), Y, instance2.Font, Vector2.new(1e999, Y))
		instance2.Size = UDim2.new(
			textSize.X / instance.AbsoluteSize.X,
			0,
			instance2.Size.Y.Scale,
			instance2.Size.Y.Offset
		)
	end

	local function Validate(child)
		if child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("TextButton") then
			UpdateSize(child)

			if not maid[child] then
				local maid2 = Utils.Maid.new()
				maid2:GiveTask(child:GetPropertyChangedSignal("ContentText"):Connect(function()
					UpdateSize(child)
				end))
				maid2:GiveTask(child:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					UpdateSize(child)
				end))
				maid[child] = maid2
			end
		end
	end

	for _, child in pairs(instance:GetChildren()) do
		Validate(child)
	end

	maid.ChildAdded = instance.ChildAdded:Connect(Validate)
	maid.ChildRemoved = instance.ChildRemoved:Connect(function(child)
		maid[child] = nil
	end)
	return function()
		maid:Destroy()
	end
end)