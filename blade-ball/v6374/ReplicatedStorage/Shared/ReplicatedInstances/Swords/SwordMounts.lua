local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ReplicatedStorage")
local v = require3("@game/ReplicatedStorage/Common/Utils/Utilities/Physics")
local v2 = {
	Single = function(p)
		local sword = p.Sword
		local torso = p.Torso
		sword:PivotTo(torso.CFrame * CFrame.new(-1.025, -1.2, 1.016) * CFrame.Angles(121.3, 0, 0))
		v.CreateMotor(torso, sword.sord, {
			Name = "Motor6D",
			[".SwordMotor"] = true
		})
	end,
	Fist = function(data)
		local sword = data.Sword
		local cframe = CFrame.new(0, -0.45, 0)
		local C1

		if data.SwordName == "Flowing Fists" then
			C1 = cframe * CFrame.Angles(0, -3.141592653589793, 0)
		else
			C1 = cframe
		end

		v.CreateMotor(sword.Cestus.PrimaryPart, data.LeftArm, {
			Name = "Cestus",
			C1 = cframe,
			[".SwordMotor"] = true
		})
		v.CreateMotor(sword.Cestus2.PrimaryPart, data.RightArm, {
			Name = "Cestus2",
			C1 = C1,
			[".SwordMotor"] = true
		})
		v.CreateMotor(data.Torso, sword.sord, {
			Name = "Motor6D",
			[".SwordMotor"] = true
		})
	end,
	Dual = function(p)
		local sword = p.Sword
		v.CreateMotor(p.Torso, sword.blade.sord, {
			Name = "Motor6D",
			[".SwordMotor"] = true
		})
		v.CreateMotor(p.Torso, sword.blade1.sordz2, {
			Name = "Motor6D2",
			[".SwordMotor"] = true
		})
	end,
	Gauntlets = function(data)
		local sword = data.Sword
		local height = sword:GetAttribute("Height") or 0.18
		local C1 = CFrame.new(0, -height, 0) * CFrame.Angles(0, 3.141592653589793, 0)

		if sword:FindFirstChild("Left") then
			v.CreateMotor(sword.Left.PrimaryPart, data.LeftArm, {
				Name = "Left",
				C1 = C1,
				[".SwordMotor"] = true
			})
		end

		v.CreateMotor(sword.Right.PrimaryPart, data.RightArm, {
			Name = "Right",
			C1 = C1,
			[".SwordMotor"] = true
		})
		v.CreateMotor(data.Torso, sword.sord, {
			Name = "Motor6D",
			[".SwordMotor"] = true
		})
	end,
	Shield = function(player)
		local sword = player.Sword
		local v3 = sword.Name == "Empyrean Fortress"
		local cframe = CFrame.new(0.65, -0.2, 0)
		local C1

		if v3 then
			C1 = cframe * CFrame.Angles(-1.5707963267948966, -1.5707963267948966, 0)
		else
			C1 = cframe * CFrame.Angles(-1.5707963267948966, 0, 0)
		end

		local motor = v.CreateMotor(sword.Model.PrimaryPart, player.RightArm, {
			Name = "Right",
			C1 = C1,
			[".SwordMotor"] = true
		})

		for _, v5 in player.Character:QueryDescendants("> CharacterMesh"), nil, nil do
			if v5.BodyPart.Name ~= "RightArm" then
				continue
			end

			motor.C1 = CFrame.new(0.5, -0.2, 0) * CFrame.Angles(
				-1.5707963267948966,
				v3 and -1.7453292519943295 or -0.17453292519943295,
				0
			)
			break
		end

		v.CreateMotor(player.Torso, sword.sord, {
			Name = "Motor6D",
			[".SwordMotor"] = true
		})
	end
}
local SwordMounts = {}

function SwordMounts.mount(p)
	local v3 = v2[p.SwordType]

	if not v3 then
		return false
	end

	v3(p)
	return true
end

function SwordMounts.getHandler(p: string)
	return v2[p]
end

return SwordMounts