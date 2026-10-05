local Skins = {}
Skins.__index = Skins
local v = {
	bobetteCalendar = { "rbxassetid://112151148035544", "rbxassetid://135880851911520" },
	testCalendar = { "rbxassetid://120093658287542", "rbxassetid://126974560313613" },
	bobette = { "rbxassetid://132797563012180", "rbxassetid://85986138335794" },
	coal = { "rbxassetid://73773748665942", "rbxassetid://120709767971119" },
	rudie = { "rbxassetid://91885693403881", "rbxassetid://104511664862009" },
	ginger = { "rbxassetid://124778399952648", "rbxassetid://88889448003584" },
	bassieCalendar = { "rbxassetid://114386942900231", "rbxassetid://85557248291223" },
	cocoaCalendar = { "rbxassetid://95727526425750", "rbxassetid://117232687817082" },
	bassie = { "rbxassetid://77499648805842", "rbxassetid://92003337277986" },
	cocoa = { "rbxassetid://115646604290443", "rbxassetid://92661617005025" },
	flyte = { "rbxassetid://140554622668760", "rbxassetid://91219918783202" },
	eggson = { "rbxassetid://76137781319130", "rbxassetid://132744816320537" }
}

function Skins.Init(_, helpers)
	local self = setmetatable({}, Skins)
	self.helpers = helpers
	self.tweens = helpers.tweens
	self:LoadStylesheet()
	return self
end

function Skins:LoadStylesheet()
	local tweens = self.tweens

	function Skins.base(data, object)
		tweens.saveInitials(data)
		data.Glow.Visible = true
		data.Glow.ImageTransparency = 1
		object:AddConnection(data, "state", data.MouseEnter:Connect(function()
			tweens.playTween(data.Glow, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				ImageTransparency = 0
			})
		end))
		object:AddConnection(data, "state", data.MouseLeave:Connect(function()
			tweens.playTween(data.Glow, TweenInfo.new(0.15, Enum.EasingStyle.Circular), {
				ImageTransparency = 1
			})
		end))
	end

	Skins.states = {}

	for k, v2 in pairs(v) do
		local v3 = v2

		Skins.states[k] = function(data)
			data.Thumbnail.Image = v3[1]
			data.Shadow.Image = v3[1]
			data.Glow.Image = v3[2]
		end
	end

	Skins.flags = {}
end

return Skins