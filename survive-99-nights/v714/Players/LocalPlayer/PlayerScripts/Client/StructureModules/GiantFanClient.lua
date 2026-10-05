local createVector = vector.create
local GiantFanClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)

local function isPlayerTouching(windZone)
	local partBoundsInBox = workspace:GetPartBoundsInBox(windZone.CFrame, windZone.Size)

	for _, v in pairs(partBoundsInBox) do
		if game.Players:GetPlayerFromCharacter(v.Parent) == localPlayer then
			return true
		end
	end
end

function GiantFanAdded(instance)
	instance:GetAttribute("Enabled")
	local flag = false
	local windZone = instance:WaitForChild("WindZone")
	local fanBlades = instance:WaitForChild("FanBlades")
	local pivot = fanBlades:GetPivot()
	local checkWindZone
	local v = 0
	local total = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function startSpinning()
		if flag then
			return
		end

		flag = true
		checkWindZone()
		task.spawn(function()
			while true do
				local enabled = instance:GetAttribute("Enabled")
				local v2 = task.wait()
				local v3 = enabled and 350 * v2 or -350 * v2
				v = math.clamp(v + v3, 0, 800)

				if not enabled and v <= 0 then
					break
				end

				total += v * v2
				fanBlades:PivotTo(pivot * CFrame.Angles(0, math.rad(total), 0))
			end

			print("spinning false")
			flag = false
		end)
	end

	instance:GetAttributeChangedSignal("Enabled"):Connect(function()
		if instance:GetAttribute("Enabled") then
			startSpinning() -- equivalent call inferred; original call site unknown
		end
	end)

	if instance:GetAttribute("Enabled") and not flag then
		flag = true
		checkWindZone()
		task.spawn(function()
			while true do
				local enabled = instance:GetAttribute("Enabled")
				local v2 = task.wait()
				local v3 = enabled and 350 * v2 or -350 * v2
				v = math.clamp(v + v3, 0, 800)

				if not enabled and v <= 0 then
					break
				end

				total += v * v2
				fanBlades:PivotTo(pivot * CFrame.Angles(0, math.rad(total), 0))
			end

			print("spinning false")
			flag = false
		end)
	end

	local flag2 = false
	local v2 = -windZone.CFrame.RightVector
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
	linearVelocity.LineDirection = (v2 * createVector(1, 0, 1)).Unit
	linearVelocity.MaxForce = 8000
	linearVelocity.LineVelocity = 25

	checkWindZone = function()
		if flag2 or not flag then
			return
		end

		if isPlayerTouching(windZone) then
			flag2 = true
			linearVelocity.Parent = localPlayer.Character.HumanoidRootPart
			linearVelocity.Attachment0 = localPlayer.Character.HumanoidRootPart.RootAttachment
			task.spawn(function()
				repeat
					task.wait(0.5)
				until not (isPlayerTouching(windZone) and flag)

				flag2 = false
				linearVelocity.Parent = nil
				linearVelocity.Attachment0 = nil
			end)
		end
	end

	windZone.Touched:Connect(function(_)
		checkWindZone()
	end)
end

Client.InteractionHandler.RegisterInteraction("ToggleGiantFan", function(p)
	print("toggle")
	Client.Events.RequestToggleGiantFan:FireServer(p)
end)

function GiantFanClient.Init()
	Client.Utility.ForAllTagged("GiantFan", GiantFanAdded)
end

return GiantFanClient