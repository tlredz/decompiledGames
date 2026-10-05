local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local currentCamera = workspace.CurrentCamera
local _ = Players.LocalPlayer
local v = require3(ReplicatedStorage2.Packages.Net)
Color3.fromRGB(255, 255, 255)
local v2 = 0
local _ = ReplicatedStorage2.Remotes.RoundEnded
local remoteEvent = v:RemoteEvent("LTMTileFalling")
local remoteEvent2 = v:RemoteEvent("LTMSpawnTileFalling")

function MarkTilesAsFalling(list, p: number, flag: boolean)
	local count = 0

	if flag then
		task.delay(p * 0.4, function()
			for _, v3 in ipairs(list) do
				if not v3.Parent or v2 >= 26 then
					continue
				end

				v2 += 1
				count += 1
				local highlight = Instance.new("Highlight")
				highlight.FillColor = Color3.fromRGB(255, 255, 255)
				highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
				highlight.FillTransparency = 0
				highlight.OutlineTransparency = 0
				highlight.DepthMode = Enum.HighlightDepthMode.Occluded
				highlight.Adornee = v3
				highlight.Parent = v3
			end
		end)
	end

	local tweenInfo = TweenInfo.new(p * 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, flag)
	local v3 = {}

	for _, parent in list do
		local clone = ReplicatedStorage2.Misc.fallingPlatePop:Clone()
		clone.Parent = parent
		clone:Play()
		table.insert(v3, TweenService:Create(parent, tweenInfo, {
			CFrame = parent.CFrame - createVector(0, 1.5, 0)
		}))
	end

	for _, v4 in v3 do
		v4:Play()
	end

	if v3[#v3] then
		v3[#v3].Completed:Wait()
	end

	local tweenInfo2 = TweenInfo.new(p * 0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	local v4 = {}

	for _, v5 in list do
		table.insert(v4, TweenService:Create(v5, tweenInfo2, {
			Transparency = 1
		}))
	end

	for _, v5 in ipairs(v4) do
		v5:Play()
	end

	if count > 0 then
		v4[#v4].Completed:Once(function()
			v2 -= count
		end)
	end
end

return {
	Start = function(_)
		remoteEvent2.OnClientEvent:Connect(function(p, p2: number, flag: boolean)
			MarkTilesAsFalling(p, p2, flag and true or false)
		end)
		remoteEvent.OnClientEvent:Connect(function(p, p2: number, flag: boolean)
			if (currentCamera.CFrame.Position - p.Position).Magnitude < 1000 then
				MarkTilesAsFalling({ p }, p2, flag and true or false)
			end
		end)
	end
}