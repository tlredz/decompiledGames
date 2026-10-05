local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local CAM = ReplicatedStorage.CAM
local client = CAM.Client
local global = CAM.Global
local Platform_Handler = require(client.Controllers.Platform_Handler)
local Utility = require(global.Utility)
local ManuelCancel = require(global.Subsets.Gameplay.ManuelCancel)
local DebrisModule = require(CAM.DebrisModule)
local Checker = require(global.Checker)
local RaycastHelper = require(global.RaycastHelper)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local maid = require(ReplicatedStorage2.Packages.cleanit).new()
local Config = require(script.Parent.Config)

local function fn(character, lookVector: Vector3)
	local rootPart = character:FindFirstChild("Humanoid").RootPart
	local spherecast = workspace:Spherecast(
		rootPart.Position - lookVector * 5,
		4,
		lookVector * (Config.RADIUS + 5),
		RaycastHelper.EveryHumanoidExceptPlayer
	)

	if not spherecast then
		return
	end

	local find_character_from_descendant = Utility.find_character_from_descendant(spherecast.Instance)

	if Checker.check_can_select(script, character, find_character_from_descendant) then
		return find_character_from_descendant
	end
end

local vfxUtility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("vfxUtility"))
local track = nil
local HeelBash = {
	Id = 0,
	Hold = function(player)
		local character = player.Character
		local humanoid = character:FindFirstChild("Humanoid")
		local rootPart = humanoid.RootPart
		track = humanoid:FindFirstChild("Animator"):LoadAnimation(script.Startup)
		track:Play()
		maid:Add(task.delay(Config.HOLD_FREEZE_AT, function()
			if track then
				track:AdjustSpeed(0)
			end
		end))
		vfxUtility.TweenFOV(0.4, 60)
		local add = maid:Add(script.Parent.Parent.Parent.holder.skill_stand_still:Clone())
		add.Parent = rootPart
		local v = maid:Add(script.aimHighlight:Clone())
		local mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
		local alignOrientationWithAttachment, v2 = Utility.CreateAlignOrientationWithAttachment(
			rootPart,
			"skill_look_at",
			{
				AlignType = Enum.AlignType.PrimaryAxisParallel,
				Responsiveness = 75,
				MaxTorque = 3000,
				CFrame = Utility.SafeLookAt(rootPart.Position, mousepos, rootPart.CFrame)
			}
		)
		maid:Add(v2)
		local v3 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function lockStillValid()
			if v3 == nil or not v3:IsDescendantOf(workspace) then
				return false
			end

			if Checker.check_can_select(script, character, v3) then
				return true
			end

			return false
		end

		maid:Add(RunService.PostSimulation:Connect(function(_: number)
			mousepos = Platform_Handler.mousepos(Config.MOUSE_RANGE)
			alignOrientationWithAttachment.CFrame = Utility.SafeLookAt(
				rootPart.Position,
				mousepos,
				alignOrientationWithAttachment.CFrame
			)

			-- equivalent call inferred; original call site unknown
			if not lockStillValid() then
				v3 = nil
			end

			local v4 = fn(character, rootPart.CFrame.LookVector)

			if v4 ~= nil and v4 ~= v3 then
				v3 = v4
			end

			v.FillTransparency = math.abs(math.sin(os.clock() * 15) / 2) + 0.5
			v.Adornee = v3
			v.Parent = v3
		end))
	end
}
local ServerClientPortal = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("ServerClientPortal"))

function HeelBash.UnHold(player)
	local humanoid = player.Character:FindFirstChild("Humanoid")
	local _ = humanoid.RootPart
	local animator = humanoid:FindFirstChild("Animator")
	maid:Clean()
	local v, _ = ManuelCancel.new(player, Config.CANCEL_WINDOW)
	v:Connect(function()
		HeelBash.Cancel(player)
	end)
	local track2 = nil
	spawn(function()
		ServerClientPortal.Link(script.Parent.Name, 2):Once(function()
			HeelBash.Cancel(player)
			task.wait(0.5)

			if track2 ~= nil then
				track2:Stop()
			end
		end)
	end)

	if track then
		track.TimePosition = Config.HOLD_FREEZE_AT
		track:AdjustSpeed(1)
		DebrisModule:AddItem(track, Config.TELEPORT_AT)
	end

	task.delay(Config.RELEASE_ANIM_AT, function()
		track2 = animator:LoadAnimation(script.Release)
		track2:Play()
		DebrisModule:AddItem(track2, track2.Length)
	end)
end

function HeelBash.Cancel(_)
	maid:Clean()

	if track then
		track:Stop()
		track:Destroy()
		track = nil
	end

	vfxUtility.TweenFOV(0.4, 70)
end

return HeelBash