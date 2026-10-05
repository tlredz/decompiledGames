local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("GamepadService")
game:GetService("TweenService")
game:GetService("RunService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Signal)
require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Common.Utils)
require3(script.Parent.Parent.ShowRoomUtility)
require3(script.Parent.Templates.ShowRoom3D)
require3(script.Parent.Parent)
require3(ReplicatedStorage2.Shared.RNG.Emotes)
local v = require3(ReplicatedStorage2.Shared.EmoteTypes.Passive)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local AFK = {}
AFK.Template = ReplicatedStorage2.Misc.ShowRooms.AFK

function AFK.AfterInit(data)
	local instance = data.Instance
	local _ = data.Trove
	local character = localPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildWhichIsA("Humanoid")
	end

	local appliedDescription

	if humanoid then
		appliedDescription = humanoid:GetAppliedDescription()
	else
		appliedDescription = nil
	end

	if not appliedDescription then
		pcall(function()
			appliedDescription = Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
		end)
	end

	if not appliedDescription then
		return
	end

	local rig = instance.Rig
	pcall(function()
		rig.Humanoid:ApplyDescription(appliedDescription)
	end)
	local folder = Instance.new("Folder")
	folder.Name = "EmoteVFX_Storage"
	folder.Parent = rig
	local v2 = nil
	local v3 = nil
	local v4 = nil
	local v5 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearLastEmote()
		if v4 then
			v4:Stop()
			v4:Destroy()
			v4 = nil
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearVFX()
		folder:ClearAllChildren()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clearCurrentEmote()
		clearLastEmote() -- equivalent call inferred; original call site unknown
		clearVFX() -- equivalent call inferred; original call site unknown
	end

	local function loadAnimation(animation)
		local track = rig.Humanoid.Animator:LoadAnimation(animation)
		track.Looped = true
		track:Play()
		local timePositions = {}
		track:GetMarkerReachedSignal("Pin"):Connect(function(p)
			timePositions[p] = track.TimePosition
		end)
		track:GetMarkerReachedSignal("GOTO"):Connect(function(p)
			if timePositions[p] then
				track.TimePosition = timePositions[p]
			end
		end)
		return track
	end

	local function updateEmote()
		if v2 then
			local v6 = tonumber(string.match(v2.Emote.AnimationId, "(%d+)"))

			if v5 ~= v6 then
				clearLastEmote() -- equivalent call inferred; original call site unknown
				v4 = loadAnimation(v2.Emote)
				v5 = v6
			end

			if v2 ~= v3 then
				rig:SetAttribute("PassiveRNGEmote", nil)

				if v3 and v3.Play then
					v3.Play(v3, rig, false)
				end

				clearVFX() -- equivalent call inferred; original call site unknown

				if v2.Play then
					local v7 = v2.Play(v2, rig, true)

					if v2.Play == v and type(v7) == "function" then
						v7()
					end
				end

				v3 = v2
			end
		else
			clearCurrentEmote() -- equivalent call inferred; original call site unknown
		end
	end

	function data.Info.SetEmote(p)
		v2 = p
		updateEmote()
	end

	v4 = loadAnimation(ReplicatedStorage2.Misc.Emotes.Emote183)
end

function AFK.BeforeShow(p)
	currentCamera.CFrame = p.Instance.Camera.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
end

return AFK