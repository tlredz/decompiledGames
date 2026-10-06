local v = {
	"rbxassetid://10876087378",
	"rbxassetid://10876086890",
	"rbxassetid://10876086389",
	"rbxassetid://10876085848",
	"rbxassetid://10876085228",
	"rbxassetid://10876084672",
	"rbxassetid://10876084223",
	"rbxassetid://10876083639",
	"rbxassetid://10876083168",
	"rbxassetid://10876082672",
	"rbxassetid://10876082280",
	"rbxassetid://10876081766",
	"rbxassetid://10876081331",
	"rbxassetid://10876080849",
	"rbxassetid://10876081331",
	"rbxassetid://10876080849",
	"rbxassetid://10876080349",
	"rbxassetid://10876079917",
	"rbxassetid://10876079536",
	"rbxassetid://10876079067",
	"rbxassetid://10876078747",
	"rbxassetid://10876078353",
	""
}
local v2 = {
	"rbxassetid://10876125418",
	"rbxassetid://10876124774",
	"rbxassetid://10876124190",
	"rbxassetid://10876123758",
	"rbxassetid://10876123298",
	"rbxassetid://10876122943",
	"rbxassetid://10876122565",
	"rbxassetid://10876122059",
	"rbxassetid://10876121361",
	"rbxassetid://10876120967",
	"rbxassetid://10876120529",
	"rbxassetid://10876120120",
	"rbxassetid://10876119739",
	"rbxassetid://10876119198",
	"rbxassetid://10876118479",
	"rbxassetid://10876117922",
	"rbxassetid://10876117362",
	"rbxassetid://10876116765",
	"rbxassetid://10876116251",
	"rbxassetid://10876115874",
	""
}

function preload(childName)
	if not workspace.Effects.preload:FindFirstChild(childName) then
		local decal = Instance.new("Decal")
		decal.Name = childName
		decal.Parent = workspace.Effects.preload
		decal.Texture = childName
	end
end

return function()
	task.spawn(function()
		for i = 1, #v do
			script.Parent.Decal.Texture = v[i]
			preload(v[i])
			task.wait(0.02)
		end

		script.Parent.Decal.Texture = ""
	end)
	task.spawn(function()
		for i = 1, #v2 do
			script.Parent.Decal2.Texture = v2[i]
			preload(v2[i])
			task.wait(0.02)
		end

		script.Parent.Decal2.Texture = ""
	end)
end