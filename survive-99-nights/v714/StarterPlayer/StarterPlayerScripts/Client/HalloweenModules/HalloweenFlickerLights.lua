local HalloweenFlickerLights = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local random = Random.new()

function AddFlickeringLight(instance)
	local number = random:NextNumber()
	local flickerSpeed = instance:GetAttribute("FlickerSpeed") or 1
	task.spawn(function()
		local total = 0
		local total2 = 0

		while true do
			local v = task.wait() * 2 * flickerSpeed
			total += v

			if not instance:HasTag("FlickeringPart") then
				break
			end

			total2 += v * (math.clamp((math.noise(number, total) + 1) / 2, 0, 1) * 3.5 + 1)
			local v2 = math.clamp((math.noise(number, total2) + 1) / 2, 0, 1) * 40 + 180
			instance.Color = Color3.fromHSV(0.08235294117647059, 0.7137254901960784, v2 / 255)
		end
	end)
end

function HalloweenFlickerLights.Init()
	Client.Utility.ForAllTagged("FlickeringPart", AddFlickeringLight)
end

return HalloweenFlickerLights