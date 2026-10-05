local _ = game.Lighting
local RunService = game:GetService("RunService")

repeat
	wait(0.1)
until not workspace:FindFirstChild("WaterStudio")

local fogEnd = game.Lighting.FogEnd
local fogColor = game.Lighting.FogColor
wait(0.5)
local flag = false
RunService:BindToRenderStep("DarkbeardLighting", Enum.RenderPriority.Camera.Value + 2, function()
	if game.Lighting:FindFirstChild("DarkbeardLighting") then
		flag = true
		game.Lighting.FogEnd = 1250
		game.Lighting.FogColor = Color3.new()
	elseif flag then
		flag = false
		game.Lighting.FogEnd = fogEnd
		game.Lighting.FogColor = fogColor
	end
end)