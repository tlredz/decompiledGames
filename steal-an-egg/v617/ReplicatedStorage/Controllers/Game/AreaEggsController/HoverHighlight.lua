local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local t = require(ReplicatedStorage.Packages.t)
require(ReplicatedStorage.Packages.Trove)

local function showHighlight(p)
	local highlight = Instance.new("Highlight")
	highlight.Name = "AreaEggHover"
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Adornee = p
	highlight.Parent = p
	return highlight
end

return {
	Bind = function(p, p2, object)
		t.strict(t.instanceIsA("Model"))(p)
		t.strict(t.Instance)(p2)
		local v = nil
		object:Connect(p2.PromptShown, function()
			if v ~= nil then
				v:Destroy()
			end

			local v2 = p
			local highlight = Instance.new("Highlight")
			highlight.Name = "AreaEggHover"
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Adornee = v2
			highlight.Parent = v2
			v = highlight
			TweenService:Create(v, TweenInfo.new(0.15), {
				OutlineTransparency = 0
			}):Play()
		end)
		object:Connect(p2.PromptHidden, function()
			local v2 = v
			v = nil

			if v2 == nil then
				return
			end

			local tween = TweenService:Create(v2, TweenInfo.new(0.12), {
				OutlineTransparency = 1
			})
			tween.Completed:Once(function()
				v2:Destroy()
			end)
			tween:Play()
		end)
	end
}