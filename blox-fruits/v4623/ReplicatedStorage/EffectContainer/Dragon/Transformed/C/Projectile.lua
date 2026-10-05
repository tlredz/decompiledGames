require(game.ReplicatedStorage.Effect)
local currentCamera = workspace.CurrentCamera
local Sound = require(game.ReplicatedStorage.Util.Sound)
local Lightning = require(game.ReplicatedStorage.Util.Lightning)
return function(data)
	local pointA = data.PointA
	local pointB = data.PointB
	local halfMagnitude = (pointA - pointB).Magnitude / 2
	CFrame.new(pointA, pointB)
	local _ = data.Scale or 10
	local duration = data.Duration or 1
	local color = data.Color or Color3.new(1, 1, 1)
	local magnitude = (currentCamera.CFrame.p - pointB).Magnitude

	if 100 + 10 * halfMagnitude < magnitude then
		return
	end

	local v2 = (pointB - pointA).Magnitude * 0.5773502691896257 * 1.3333333333333333
	Sound:Play("Dragon.ElectricShot", pointA, v2 * 1.5)
	local v3 = Sound:Play("Dragon.Zap_Looped", pointA, v2 * 1.5)
	Lightning.new({
		Lifetime = 0.25 + math.random() * 0.075,
		DrawType = "Singular",
		Colors = { color.Keypoints[1], color.Keypoints[2] },
		Sizes = {
			{
				Size = 0,
				Time = 0
			},
			{
				Size = data.Width,
				Time = 0.7
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
				Position = pointA
			},
			End = {
				Position = pointB
			}
		},
		ArcSize = {
			Min = 70,
			Max = 100
		},
		ChangesSegmentOffset = true,
		OffsetChangePercent = {
			EqualOrBelow = 0.15,
			Bounds = { 0, 1 }
		}
	})
	wait(duration * 0.5)
	Sound:FadeOut(v3, duration * 0.5)
end