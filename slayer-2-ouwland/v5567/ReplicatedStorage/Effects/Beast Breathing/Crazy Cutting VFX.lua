local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local effects = script:WaitForChild("Effects")
local sounds = script:WaitForChild("Sounds")
local DebrisModule = require(CAM.DebrisModule)
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local Ouwmit = require(CAM.Client.Modules.Effects.Ouwmit)
local RaycastHelper = require(CAM.Global.RaycastHelper)
local Cam_Shaker = require(CAM.Client.Modules.Effects.Cam_Shaker)
local Config = require(ReplicatedStorage.Skills["Beast Breathing"]["Crazy Cutting"].Config)
local v = {
	{
		at = 0.21666666666666667,
		name = "Emit"
	},
	{
		at = 0.25,
		name = "Spin"
	},
	{
		at = 0.55,
		name = "SpinSlowmo"
	},
	{
		at = Config.SLASH_AT,
		name = "Slash",
		ground = true
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyFolder(p)
	local child = workspace.Debree:FindFirstChild((`{p.Name}-CrazyCuttingVFX`))

	if child and child.Parent then
		Ouwmit.Enable(child, false)
		child.Name = "--"
		DebrisModule:AddItem(child, 1.3)
	end
end

local function createFolder(p, p2: number)
	destroyFolder(p) -- equivalent call inferred; original call site unknown
	local configuration = Instance.new("Configuration")
	configuration.Name = `{p.Name}-CrazyCuttingVFX`
	configuration.Parent = workspace.Debree
	DebrisModule:AddItem(configuration, p2)
	return configuration
end

-- equivalent calls inferred from this helper; original call sites unknown
local function groundDust(position: Vector3)
	local raycastResult = workspace:Raycast(
		position + createVector(0, 5, 0),
		createVector(-0, -15, -0),
		RaycastHelper.Crater
	)
	return raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
end

return function(instance, p: string, _)
	if instance == nil then
		return
	end

	if p == "Cancel" then
		destroyFolder(instance) -- equivalent call inferred; original call site unknown
	else
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart == nil then
			return
		end

		if p == "Start" then
			destroyFolder(instance) -- equivalent call inferred; original call site unknown
			local configuration = Instance.new("Configuration")
			configuration.Name = `{instance.Name}-CrazyCuttingVFX`
			configuration.Parent = workspace.Debree
			DebrisModule:AddItem(configuration, 3)
		elseif p == "Counter" then
			destroyFolder(instance) -- equivalent call inferred; original call site unknown
			local configuration = Instance.new("Configuration")
			configuration.Name = `{instance.Name}-CrazyCuttingVFX`
			configuration.Parent = workspace.Debree
			DebrisModule:AddItem(configuration, 2.13)
			Cam_Shaker(humanoidRootPart.Position, "activate_shake")
			vfxUtility.PlaySound(sounds, "PS2beastCRAZYCUTTINGteleport", humanoidRootPart, true)
			task.delay(Config.BARRAGE_START, function()
				if configuration.Parent == nil or configuration.Name == "--" then
					return
				end

				vfxUtility.PlaySound(sounds, "PS2beastCRAZYCUTTINGbarrage", humanoidRootPart, true)
				Cam_Shaker(humanoidRootPart.Position, {
					FadeInTime = 0,
					Frequency = 0.082,
					Amplitude = 0.12,
					SustainTime = Config.BARRAGE_END - Config.BARRAGE_START,
					FadeOutTime = 0.5,
					RotationInfluence = createVector(0.1, 0.1, 0.1),
					PositionInfluence = createVector(0.4, 0.4, 0.4)
				})
			end)
			task.delay(Config.SLASH_AT, function()
				if configuration.Parent == nil or configuration.Name == "--" then
					return
				end

				Cam_Shaker(humanoidRootPart.Position, "activate_shake")
				vfxUtility.PlaySound(sounds, "PS2beastCRAZYCUTTINGfinalslash", humanoidRootPart, true)
			end)

			for _, v2 in v do
				local v3 = v2
				task.delay(v2.at, function()
					if configuration.Parent == nil or configuration.Name == "--" then
						return
					end

					local cFrame = humanoidRootPart.CFrame
					local asset = vfxUtility.cloneAsset(effects, configuration, v3.name, cFrame, 1)

					if asset == nil then
						return
					end

					local v4

					if v3.ground then
						v4 = groundDust(cFrame.Position)
					end

					Ouwmit.Emit(asset, Ouwmit.Owned(instance, v4))
				end)
			end
		end
	end
end