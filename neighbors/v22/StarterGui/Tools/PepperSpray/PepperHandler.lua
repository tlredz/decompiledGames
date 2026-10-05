local Network = require(game.ReplicatedStorage.Modules.Network)
local TweenService = game:GetService("TweenService")

if game.Lighting:FindFirstChild("PepperBlur") then
	game.Lighting.PepperBlur:Destroy()
end

if game.Lighting:FindFirstChild("PepperSpray") then
	game.Lighting.PepperSpray:Destroy()
end

Network:listen("PepperSprayed", function(duration)
	for _, child in script:GetChildren() do
		local clone = child:Clone()
		clone.Parent = game.Lighting
		local blurEffect = clone
		task.delay(duration, function()
			if blurEffect:IsA("BlurEffect") then
				TweenService:Create(blurEffect, TweenInfo.new(0.3), {
					Size = 0
				}):Play()
			else
				TweenService:Create(blurEffect, TweenInfo.new(0.3), {
					Brightness = 0,
					TintColor = Color3.new(1, 1, 1)
				}):Play()
			end
		end)
		game.Debris:AddItem(clone, duration + 0.5)
	end
end)