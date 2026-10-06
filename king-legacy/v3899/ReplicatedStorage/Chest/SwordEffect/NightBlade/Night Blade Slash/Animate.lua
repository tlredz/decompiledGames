local _ = game.ReplicatedStorage
local v = {
	"rbxassetid://9054352395",
	"rbxassetid://9054351780",
	"rbxassetid://9054351293",
	"rbxassetid://9054350829",
	"rbxassetid://9054350217",
	"rbxassetid://9054349737",
	"rbxassetid://9054349149",
	"rbxassetid://9054348723",
	"rbxassetid://9054348176",
	"rbxassetid://9054347714",
	"rbxassetid://9054347381"
}
local v2 = {
	"rbxassetid://9054401306",
	"rbxassetid://9054401053",
	"rbxassetid://9054400499",
	"rbxassetid://9054399929",
	"rbxassetid://9054399068",
	"rbxassetid://9054398350",
	"rbxassetid://9054397700",
	"rbxassetid://9054397071",
	"rbxassetid://9054396492",
	"rbxassetid://9054396016",
	"rbxassetid://9054395811"
}
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function()
	task.spawn(function()
		local _ = script.Parent.CFrame
		local parent = script.Parent
		game.TweenService:Create(parent, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = parent.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
		}):Play()
		task.spawn(function()
			wait(0.1)
			game.TweenService:Create(
				parent,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = parent.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
				}
			):Play()
		end)
		PeodizService.ForLoop({
			Step = #v
		}, function(p)
			local v3 = math.floor(p * #v)

			if parent:FindFirstChild("Outer") then
				parent.Outer.Texture = v[v3]
			end

			if parent:FindFirstChild("Inner") then
				parent.Inner.Texture = v2[v3]
			end
		end)

		if parent:FindFirstChild("Outer") then
			parent.Outer.Texture = ""
		end

		if parent:FindFirstChild("Inner") then
			parent.Inner.Texture = ""
		end
	end)
end