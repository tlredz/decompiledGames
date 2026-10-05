local ReplicatedStorage = game:GetService("ReplicatedStorage")
return function(instance, p)
	local v = math.floor(tonumber(p) or 0)

	if instance == nil or v == 0 then
		return
	end

	local minigamesPlace = ReplicatedStorage:FindFirstChild("Minigames Place")
	local minigames

	if minigamesPlace ~= nil then
		minigames = minigamesPlace:FindFirstChild("Minigames") or nil
	end

	local ouwigahara

	if minigames ~= nil then
		ouwigahara = minigames:FindFirstChild("Ouwigahara") or nil
	end

	if ouwigahara == nil then
		error("Points: only inside the Minigames place")
	end

	local Run = require(ouwigahara.Run)
	local Score = require(ouwigahara.Score)

	if Run.Current == nil then
		instance:SetAttribute(
			Score.ATTRIBUTE,
			(math.max((tonumber(instance:GetAttribute(Score.ATTRIBUTE)) or 0) + v, 0))
		)
	else
		Score.Award(Run.Current, instance, v)
	end
end