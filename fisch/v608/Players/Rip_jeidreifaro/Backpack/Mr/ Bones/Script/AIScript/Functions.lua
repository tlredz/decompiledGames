local Players2 = game:GetService("Players")
Players = Players2
local Debris2 = game:GetService("Debris")
Debris = Debris2
ProjectileNames = {
	"Water",
	"Arrow",
	"Projectile",
	"Effect",
	"Rail",
	"Laser",
	"Ray",
	"Bullet",
	"ParticlePart"
}
Functions = {
	CheckTableForString = function(items, value)
		for _, item in pairs(items) do
			if string.lower(item) == string.lower(value) then
				return true
			end
		end

		return false
	end,
	CheckIntangible = function(instance)
		if instance and instance.Parent then
			if instance.Transparency >= 1 and not instance.CanCollide or Functions.CheckTableForString(
				ProjectileNames,
				instance.Name
			) then
				return true
			end

			local parent = instance.Parent
			local humanoid = parent.Parent:FindFirstChild("Humanoid")

			if humanoid and humanoid.Health > 0 and parent:IsA("Hat") then
				return true
			end
		end

		return false
	end,
	CastRay = function(p, p2, p3, p4, p5)
		local Workspace = game:GetService("Workspace")
		local part, v, v2 = Workspace:FindPartOnRayWithIgnoreList(Ray.new(p, p2 * p3), p4)

		if part and Functions.CheckIntangible(part) then
			if p5 then
				wait()
			end

			part, v, v2 = Functions.CastRay(v + p2 * 0.01, p2, p3 - (p - v).magnitude, p4, p5)
		end

		return part, v, v2
	end,
	IsTeamMate = function(p, p2)
		return p and p2 and not (p.Neutral or p2.Neutral) and p.TeamColor == p2.TeamColor
	end,
	TagHumanoid = function(parent, p)
		local objectValue = Instance.new("ObjectValue")
		objectValue.Name = "creator"
		objectValue.Value = p
		Debris:AddItem(objectValue, 2)
		objectValue.Parent = parent
	end,
	UntagHumanoid = function(instance)
		for _, objectValue in pairs(instance:GetChildren()) do
			if objectValue:IsA("ObjectValue") and objectValue.Name == "creator" then
				objectValue:Destroy()
			end
		end
	end
}
return Functions