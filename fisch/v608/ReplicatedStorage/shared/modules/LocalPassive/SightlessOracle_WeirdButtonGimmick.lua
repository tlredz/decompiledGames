game:GetService("ContentProvider")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
require(ReplicatedStorage.client.legacyControllers.HarpoonMinigameController.Types)
local SightlessOracleWeirdButtonGimmick = {
	MorphHarpoon = function(_, _, _) end,
	TickRender_Harpoon = function(p, data, _: number)
		local buttonLifetime = data.buttonLifetime
		local buttonSize = data.buttonSize

		for _, activeButton in ipairs(data.activeButtons) do
			if not (activeButton.buttonType == "pull" and activeButton.despawnTimer) then
				continue
			end

			local buttonObject = activeButton.buttonObject
			local v = math.clamp(activeButton.despawnTimer / buttonLifetime, 0, 1)
			local v2 = (1 - math.clamp(activeButton.despawnTimer / (buttonLifetime - 0.5), 0, 1)) * p.config.MaxTransparency
			local size = buttonSize * math.lerp(v, 1, p.config.MaxSize)
			activeButton.size = size
			buttonObject.Size = UDim2.fromScale(size, size)
			buttonObject.hoverStroke.Transparency = v2 * 0.5

			if buttonObject:FindFirstChild("bevel") then
				buttonObject.bevel.ImageTransparency = v2
			end

			buttonObject.title.TextTransparency = v2
			buttonObject.BackgroundTransparency = 0.5 + v2 * 0.5
			buttonObject.UIShadow.Transparency = 0.75 + v2 * 0.25
			buttonObject.GamepadIcon.ImageTransparency = v2
		end
	end
}
setmetatable(SightlessOracleWeirdButtonGimmick, module)
return SightlessOracleWeirdButtonGimmick