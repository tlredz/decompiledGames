while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Common.Utils)
local TextService = game:GetService("TextService")
local parent = script.Parent

local function UpdateSize(instance)
	local contentText = instance.ContentText
	local Y = instance.AbsoluteSize.Y
	local textSize = TextService:GetTextSize(tostring(contentText), Y, instance.Font, Vector2.new(1e999, Y))
	instance.Size = UDim2.new(textSize.X / parent.AbsoluteSize.X, 0, instance.Size.Y.Scale, instance.Size.Y.Offset)
end

local function Validate(child)
	if child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("TextButton") then
		UpdateSize(child)
		child:GetPropertyChangedSignal("ContentText"):Connect(function()
			UpdateSize(child)
		end)
		child:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			UpdateSize(child)
		end)
	end
end

for _, child in pairs(parent:GetChildren()) do
	Validate(child)
end

parent.ChildAdded:Connect(Validate)