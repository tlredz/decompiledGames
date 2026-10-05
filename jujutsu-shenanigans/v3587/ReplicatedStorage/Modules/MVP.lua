local MVP = {}
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local localPlayer = game.Players.LocalPlayer

function MVP.MVP_Play(_, p, childName)
	if not p then
		return
	end

	local child = script:FindFirstChild(childName)

	if not child then
		return
	end

	_G.MVP_PLAYING = true
	local v = {}
	local success, result = pcall(function()
		local clone = script.Fade:Clone()
		clone.Parent = localPlayer.PlayerGui
		TweenService:Create(clone.Frame, TweenInfo.new(2), {
			BackgroundTransparency = 0
		}):Play()
		Debris:AddItem(clone, 3)
		task.delay(2.5, function()
			TweenService:Create(clone.Frame, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			}):Play()
		end)
		local module = require(child)
		module:Start(p, v)
	end)

	if not success then
		MVP:MVP_End(v, true)
		warn(result)
	end

	_G.MVP_PLAYING = nil
	return v
end

function MVP:MVP_End(list, p)
	if not p then
		local clone = script.Fade:Clone()
		clone.Parent = localPlayer.PlayerGui
		TweenService:Create(clone.Frame, TweenInfo.new(2), {
			BackgroundTransparency = 0
		}):Play()
		Debris:AddItem(clone, 2.5)
		task.wait(2)
		TweenService:Create(clone.Frame, TweenInfo.new(0.5), {
			BackgroundTransparency = 1
		}):Play()
	end

	for i = #list, 1, -1 do
		local animationTrack = list[i]

		if not animationTrack then
			continue
		end

		table.remove(list, i)

		if typeof(animationTrack) == "RBXScriptConnection" then
			animationTrack:Disconnect()
		elseif type(animationTrack) == "function" then
			pcall(animationTrack)
		elseif animationTrack:IsA("AnimationTrack") then
			animationTrack:Stop()
		else
			animationTrack:Destroy()
		end
	end

	local currentCamera = workspace.CurrentCamera
	currentCamera.CameraType = Enum.CameraType.Custom
	currentCamera.FieldOfView = 70

	if localPlayer.Character then
		currentCamera.CameraSubject = localPlayer.Character.Humanoid
	end

	localPlayer.PlayerGui.Main.Enabled = true
end

return MVP