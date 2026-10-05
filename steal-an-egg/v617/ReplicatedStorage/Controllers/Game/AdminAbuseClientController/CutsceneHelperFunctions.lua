local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
game:GetService("Workspace")

local function toMMSS(p: number)
	return string.format("%02i:%02i", p / 60 % 60, p % 60)
end

local function ParsePath(value: string)
	local parts = value:split(".")
	local playerGui = nil

	for k, part in parts do
		if k == #parts then
			return playerGui, part
		end

		if playerGui or part ~= "game" then
			if playerGui or part ~= "workspace" and part ~= "Workspace" then
				if playerGui or part ~= "Terrain" then
					if playerGui or part ~= "Lighting" then
						if playerGui or part ~= "Player" and part ~= "player" then
							if playerGui or part ~= "PlayerGui" then
								playerGui = playerGui[part]
							else
								playerGui = Players.LocalPlayer.PlayerGui
							end
						else
							playerGui = Players.LocalPlayer
						end
					else
						playerGui = Lighting
					end
				else
					playerGui = workspace.Terrain
				end
			else
				playerGui = workspace
			end
		else
			playerGui = game
		end
	end

	error((`[{script.Name}] Invalid Path`))
end

local function SetProperty(p: string, cframe)
	return function()
		local model, v = ParsePath(p)

		if v == "CFrame" and model:GetAttribute("OffsetCFrame") then
			cframe *= model:GetAttribute("OffsetCFrame")
		end

		if model:IsA("Model") and v == "CFrame" then
			model:PivotTo(cframe)
		else
			model[v] = cframe
		end
	end
end

local function TweenProperty(p: string, p2, p3)
	return function()
		local model, v = ParsePath(p)

		if v == "CFrame" and model:GetAttribute("OffsetCFrame") then
			p3 *= model:GetAttribute("OffsetCFrame")
		end

		if v ~= "CFrame" or not model:IsA("Model") then
			TweenService:Create(model, p2, {
				[v] = p3
			}):Play()
			return
		end

		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = model:GetPivot()
		TweenService:Create(cFrameValue, p2, {
			Value = p3
		}):Play()
		cFrameValue.Changed:Connect(function()
			model:PivotTo(cFrameValue.Value)
		end)
	end
end

local function LoadAnimationIntoRig(instance, animationId: string)
	local animationController = instance:FindFirstChild("AnimationController")
	local humanoid = instance:FindFirstChild("Humanoid")
	local animator = animationController and animationController:FindFirstChild("Animator") or humanoid and humanoid:FindFirstChild("Animator") or animationController or humanoid

	if not animator then
		error((`No usable animation controller or humanoid exists for {instance}`))
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	return animator:LoadAnimation(animation)
end

local function SetVisibility(folder, flag: boolean)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		if part:GetAttribute("OriginalTransparency") == nil then
			part:SetAttribute("OriginalTransparency", part.Transparency)
		end

		part.Transparency = not flag and 1 or part:GetAttribute("OriginalTransparency") or 1
	end
end

return {
	GetHelperFunctions = function(maid)
		return {
			toMMSS = toMMSS,
			ParsePath = ParsePath,
			SetProperty = SetProperty,
			TweenProperty = TweenProperty,
			LoadAnimationIntoRig = LoadAnimationIntoRig,
			CreateAndPlaySound = function(soundId: string, p, value: number?)
				local parent = p or workspace:FindFirstChild("Terrain")
				local sound = Instance.new("Sound")
				sound.SoundId = soundId
				sound.Parent = parent
				sound.Volume = value or 0.5
				sound.RollOffMaxDistance = 9999
				sound.RollOffMinDistance = 0
				sound.RollOffMode = Enum.RollOffMode.Linear
				task.delay(0.1, function()
					sound:Play()
				end)
				maid:Add(sound)
				return sound
			end,
			PlaySequenceAsync = function(object, p, duration: number)
				if object then
					object:Play()
				end

				local v = {}
				local total = 0
				local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
					total += dt

					for i = 0, 9 do
						local v2 = math.floor(total * 60 - i)

						if not p[v2] or v[v2] then
							continue
						end

						v[v2] = true

						for _, callback in p[v2] do
							task.spawn(callback)
						end
					end
				end)
				maid:Add(heartbeatConnection)
				task.wait(duration)
				heartbeatConnection:Disconnect()
			end,
			SetVisibility = SetVisibility,
			TweenMuteBackgroundMusic = function()
				TweenService:Create(SoundService.Music.BackgroundMusic, TweenInfo.new(1), {
					Volume = 0
				}):Play()
				maid:Add(function()
					TweenService:Create(SoundService.Music.BackgroundMusic, TweenInfo.new(1), {
						Volume = 1
					}):Play()
				end)
			end
		}
	end
}