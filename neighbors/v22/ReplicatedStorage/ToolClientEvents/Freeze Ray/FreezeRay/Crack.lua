local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Debris")
local Tool = require(ReplicatedStorage.Modules.Tool)
local _ = ReplicatedStorage.Assets.Tools.FreezeRay
return Tool.Event(function(_, instance)
	local iceCube = instance:FindFirstChild("IceCube")

	if not iceCube then
		return
	end

	if iceCube:FindFirstChild("Crack") then
		iceCube.Crack:Play()
	end

	for _, texture in iceCube:GetChildren() do
		if texture:IsA("Texture") then
			texture.Transparency = 0.85
		end
	end
end)