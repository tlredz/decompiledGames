workspace:WaitForChild("_WorldOrigin")
game:GetService("TweenService")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage.Effect)
local Lightning = require(game.ReplicatedStorage.Util.Lightning)
return function(data)
	local proxy = data.Proxy
	local part = data.Part
	local range = data.Range or 2
	local rate = data.Rate or 0.06

	if _G.FastMode or not (proxy and part) then
		return
	end

	local magnitude = (part.Position - workspace.CurrentCamera.CFrame.p).Magnitude

	if range * 100 < magnitude then
		return
	end

	local Sound = require(game.ReplicatedStorage.Util.Sound)
	local v = Sound:Play("ElectricLoopable2", part.Position)
	local colors = data.Colors

	if not colors then
		colors = {
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 225, 255))
		}
	end

	while proxy:IsDescendantOf(workspace) do
		Lightning.new({
			Lifetime = 0.1 + math.random() * 0.1,
			DrawType = "Singular",
			Colors = colors,
			Sizes = {
				{
					Size = 0.0525,
					Time = 0
				},
				{
					Size = 0.35,
					Time = 0.5
				},
				{
					Size = 0,
					Time = 1
				}
			},
			Transparencies = {
				{
					Transparency = 0,
					Time = 0
				},
				{
					Transparency = 0,
					Time = 1
				}
			},
			Points = {
				Start = {
					Position = part.Position
				},
				End = {
					Position = part.Position + Vector3.new(
						math.random() - 0.5,
						math.random() - 0.5,
						math.random() - 0.5
					).unit * (range + range * math.random())
				}
			},
			ArcSize = {
				Min = 1.5 + range / 4,
				Max = 3 + range / 2
			},
			ChangesSegmentOffset = true,
			OffsetChangePercent = {
				EqualOrBelow = 0.15,
				Bounds = { 0, 1 }
			}
		})
		task.wait(rate)
	end

	wait()
	local Sound2 = require(game.ReplicatedStorage.Util.Sound)
	Sound2:FadeOut(v, 0.05)
	wait(0.1)
	pcall(function()
		v:Stop()
		v:Destroy()
	end)
end