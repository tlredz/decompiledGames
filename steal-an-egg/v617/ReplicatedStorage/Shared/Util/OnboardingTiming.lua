local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local v = {}
local object = setmetatable({}, {
	__mode = "k"
})
return {
	Mark = function(p: string, p2, p3: number?)
		if not RunService:IsStudio() and Workspace:GetAttribute("TraceOnboarding") ~= true then
			return
		end

		local v2 = v

		if p2 then
			if object[p2] == nil then
				object[p2] = {}
			end

			v2 = object[p2]
		end

		if v2[p] then
			return
		end

		v2[p] = true
		local v3 = RunService:IsServer() and "Server" or "Client"
		local v4 = not p3 and "" or string.format(" duration=%.3fs", p3)
		print(string.format("[OnboardingTiming][%s] %s serverTime=%.3f%s", v3, p, Workspace:GetServerTimeNow(), v4))
	end
}