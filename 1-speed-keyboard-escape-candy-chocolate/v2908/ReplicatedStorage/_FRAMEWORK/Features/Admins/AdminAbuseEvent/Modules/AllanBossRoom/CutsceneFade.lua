local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local quad = Enum.EasingStyle.Quad
local inOut = Enum.EasingDirection.InOut
local source = Vide.source(0)
local v = nil
local v2 = nil
local count = 0

local function ensureMounted()
	if v then
		return true
	end

	local localPlayer = Players.LocalPlayer
	local playerGui

	if localPlayer then
		playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	end

	if playerGui then
		v2 = Vide.mount(function()
			local v3 = create("ScreenGui")({
				Name = "AllanBossRoomCutsceneFade",
				DisplayOrder = 3200000,
				IgnoreGuiInset = true,
				ResetOnSpawn = false,
				ScreenInsets = Enum.ScreenInsets.None,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				create("Frame")({
					Name = "Cover",
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = function()
						return 1 - source()
					end,
					BorderSizePixel = 0,
					Visible = function()
						return source() > 0
					end
				})
			})
			v = v3
			return v3
		end, playerGui)
		return true
	end

	warn("[AllanBossRoom] CutsceneFade could not resolve the local PlayerGui; cutscene fades are disabled")
	return false
end

local function animate(p: number, p2: number)
	count += 1
	local v3 = count
	local v4 = source()

	if p2 <= 0 then
		source(p)
		return count == v3
	end

	local lastTime = os.clock()

	while count == v3 do
		local v5 = math.clamp((os.clock() - lastTime) / p2, 0, 1)
		local value = TweenService:GetValue(v5, quad, inOut)
		source(v4 + (p - v4) * value)

		if v5 >= 1 then
			break
		else
			task.wait()
		end
	end

	return count == v3
end

local CutsceneFade = {}

function CutsceneFade.toBlack(p: number)
	if RunService:IsServer() or not ensureMounted() then
		return
	end

	animate(1, p)
end

function CutsceneFade.fromBlack(p: number)
	if RunService:IsServer() or not v then
		return
	end

	animate(0, p)
end

function CutsceneFade.cleanup()
	count += 1
	source(0)

	if v2 then
		v2()
		v2 = nil
	end

	if v then
		v:Destroy()
		v = nil
	end
end

return CutsceneFade