local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Config = require(script.Parent.Config)
local v = { "LevelFrame", "BoostFrame" }
local ParticipantEffects = {
	lockSpeed = function(instance)
		local walkSpeed = instance.WalkSpeed
		local v2 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function apply()
			if not v2 and instance.WalkSpeed ~= Config.participantSpeed then
				walkSpeed = instance.WalkSpeed
				v2 = true
				instance.WalkSpeed = Config.participantSpeed
				v2 = false
			end
		end

		local walkSpeedChangedConnection = instance:GetPropertyChangedSignal("WalkSpeed"):Connect(apply)
		apply() -- equivalent call inferred; original call site unknown
		return function()
			walkSpeedChangedConnection:Disconnect()

			if instance.Parent then
				instance.WalkSpeed = walkSpeed
			end
		end
	end
}

function ParticipantEffects.startClient()
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer.PlayerGui
	local visibilityByGuiObject = {}
	local v2 = nil
	local v3 = nil
	local v4 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function restore()
		if v3 then
			v3()
			v3 = nil
		end

		v2 = nil

		for k, visible in visibilityByGuiObject do
			if k.Parent then
				k.Visible = visible
			end
		end

		table.clear(visibilityByGuiObject)
	end

	local function hidePanel(guiObject)
		if guiObject:IsA("GuiObject") and guiObject:IsDescendantOf(playerGui) then
			if visibilityByGuiObject[guiObject] == nil then
				visibilityByGuiObject[guiObject] = guiObject.Visible
			end

			guiObject.Visible = false
		end
	end

	RunService:BindToRenderStep("AnniversaryParticipantEffects", Enum.RenderPriority.Last.Value, function()
		if localPlayer:GetAttribute(Config.participantAttribute) == true then
			local character = localPlayer.Character
			local humanoid

			if character then
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			if humanoid ~= v2 then
				if v3 then
					v3()
					v3 = nil
				end

				v2 = humanoid

				if humanoid then
					v3 = ParticipantEffects.lockSpeed(humanoid)
				end
			end

			if humanoid then
				humanoid.WalkSpeed = Config.participantSpeed
			end

			local now = os.clock()

			if v4 <= now then
				v4 = os.clock() + 0.25
				local speedGameUI = playerGui:FindFirstChild("SpeedGameUI")
				local frames

				if speedGameUI then
					frames = speedGameUI:FindFirstChild("Frames")
				end

				if frames then
					for _, childName in v do
						local guiObject = frames:FindFirstChild(childName)

						if not (guiObject and guiObject:IsA("GuiObject") and guiObject:IsDescendantOf(playerGui)) then
							continue
						end

						if visibilityByGuiObject[guiObject] == nil then
							visibilityByGuiObject[guiObject] = guiObject.Visible
						end

						guiObject.Visible = false
					end
				end
			end

			for k in visibilityByGuiObject do
				if k.Parent then
					k.Visible = false
				end
			end
		else
			restore() -- equivalent call inferred; original call site unknown
		end
	end)
	return function()
		RunService:UnbindFromRenderStep("AnniversaryParticipantEffects")
		restore() -- equivalent call inferred; original call site unknown
	end
end

return ParticipantEffects