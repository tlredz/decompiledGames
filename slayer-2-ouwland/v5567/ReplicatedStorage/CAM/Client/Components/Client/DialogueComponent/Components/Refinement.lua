local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local RefinementPanel = require(ReplicatedStorage.CAM.Client.Components.NonePackagedMisc.RefinementPanel)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.45)
local uDim = UDim2.fromScale(0.5, 0.7475)
local uDim2 = UDim2.fromScale(1, 0.69)
local uDim3 = UDim2.fromScale(0.5, 0.66)
local uDim4 = UDim2.new(1, 0, 0.66, 25)
return function()
	return function(maid, instance, _, _)
		local v = Platform_Handler.Platform.Value == "Mobile"
		local screenGui = instance:FindFirstAncestorWhichIsA("ScreenGui")

		if v and screenGui ~= nil then
			local modeBar = screenGui:FindFirstChild("ModeBar")

			if modeBar ~= nil then
				modeBar.Visible = false
				maid:Add(function()
					if modeBar.Parent ~= nil then
						modeBar.Visible = true
					end
				end)
			end
		end

		local v2 = maid:Create("CanvasGroup")
		local v3 = {
			Parent = screenGui or instance,
			AnchorPoint = Vector2.new(0.5, 1)
		}
		local position

		if v then
			position = uDim3
		else
			position = uDim
		end

		v3.Position = position
		local size

		if v then
			size = uDim4
		else
			size = uDim2
		end

		v3.Size = size
		v3.BackgroundTransparency = 1
		v3.CleanDelay = info.Time
		v3.GroupTransparency = maid:Animation(0, info, {
			From = 1
		})

		function v3.OnClean(object)
			return {
				GroupTransparency = object:Animation(1, info)
			}
		end

		do local _values = table.pack(RefinementPanel(maid)); for _k = 1, _values.n do v3[_k] = _values[_k] end end
		return v2(v3)
	end
end