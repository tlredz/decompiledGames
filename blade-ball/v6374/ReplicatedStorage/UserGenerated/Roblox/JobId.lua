local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local jobId = game.JobId

if #jobId ~= 0 and jobId ~= "00000000-0000-0000-0000-000000000000" then
	return jobId
end

assert(RunService:IsStudio())

if RunService:IsServer() then
	local lower = HttpService:GenerateGUID(false):lower()
	script:SetAttribute("Studio", lower)
	return lower
else
	local studio

	while true do
		studio = script:GetAttribute("Studio")

		if type(studio) == "string" then
			break
		end

		task.wait()
	end

	return studio
end