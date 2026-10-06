local module = require("@game/ReplicatedStorage/Omni")
local v = {}
local currentCamera = workspace.CurrentCamera
local AutoScaledText = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function CalculateScaleFactor()
	local viewportSize = currentCamera.ViewportSize
	return (math.min(viewportSize.X / module.Settings.ReferenceSize.X, viewportSize.Y / module.Settings.ReferenceSize.Y))
end

local function UpdateScale(data, p: number)
	local parent = data.Instance.Parent

	if parent and parent.Parent and data.OriginalTextSize then
		if parent:IsA("UITextSizeConstraint") then
			parent.MaxTextSize = data.OriginalTextSize * p
		elseif parent:IsA("TextLabel") then
			parent.TextSize = data.OriginalTextSize * p
		end
	else
		data.Instance.Scale = data.OriginalScale * p
	end
end

function AutoScaledText.UpdateScale()
	local calculateScaleFactor = CalculateScaleFactor() -- equivalent call inferred; original call site unknown

	for _, v3 in v do
		UpdateScale(v3, calculateScaleFactor)
	end
end

function AutoScaledText.Init()
	currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(AutoScaledText.UpdateScale)
	module.Utils.Instance:ObserveTaggedObject("AutoScaledText", function(uIScale)
		if not uIScale:IsA("UIScale") or uIScale:IsDescendantOf(module.Services.ReplicatedStorage) then
			return
		end

		local maxTextSize = nil
		local scale = uIScale.Scale
		local calculateScaleFactor = CalculateScaleFactor() -- equivalent call inferred; original call site unknown

		if uIScale.Parent then
			if uIScale.Parent:IsA("UITextSizeConstraint") then
				maxTextSize = uIScale.Parent.MaxTextSize
			elseif uIScale.Parent:IsA("TextLabel") then
				maxTextSize = uIScale.Parent.TextSize
			end
		end

		local v3 = {
			Instance = uIScale,
			OriginalScale = scale,
			OriginalTextSize = maxTextSize
		}
		v[uIScale] = v3
		UpdateScale(v3, calculateScaleFactor)
	end)
	module.Services.CollectionService:GetInstanceRemovedSignal("AutoScaledText"):Connect(function(uIScale)
		if not uIScale:IsA("UIScale") then
			return
		end

		v[uIScale] = nil
	end)
	AutoScaledText.UpdateScale()
end

return AutoScaledText