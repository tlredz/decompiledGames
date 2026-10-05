local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals)
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it
local VRCameraTeleportDetector = require(script.Parent.VRCameraTeleportDetector)
local shouldRecenter = VRCameraTeleportDetector.shouldRecenter
local JUMP_STUDS = VRCameraTeleportDetector.JUMP_STUDS
local SETTLED_STUDS = VRCameraTeleportDetector.SETTLED_STUDS
local DEBOUNCE_SECONDS = VRCameraTeleportDetector.DEBOUNCE_SECONDS
describe("VRCameraTeleportDetector.shouldRecenter", function()
	it("fires on a discrete jump from rest (no prior step, never recentered)", function()
		expect(shouldRecenter(nil, JUMP_STUDS + 10, nil, 100)).toBe(true)
	end)
	it("fires on a discrete jump preceded by a near-still frame", function()
		expect(shouldRecenter(SETTLED_STUDS - 0.5, JUMP_STUDS + 10, nil, 100)).toBe(true)
	end)
	it("does not fire for sub-threshold motion", function()
		expect(shouldRecenter(0, JUMP_STUDS - 0.1, nil, 100)).toBe(false)
		expect(shouldRecenter(0, 0, nil, 100)).toBe(false)
	end)
	it("does not fire when the previous frame was already moving (continuous motion)", function()
		expect(shouldRecenter(SETTLED_STUDS + 0.1, JUMP_STUDS + 10, nil, 100)).toBe(false)
	end)
	it("does not fire within the debounce interval", function()
		expect(shouldRecenter(nil, JUMP_STUDS + 10, 100, 100 + DEBOUNCE_SECONDS - 0.01)).toBe(false)
	end)
	it("fires again once the debounce interval has elapsed", function()
		expect(shouldRecenter(nil, JUMP_STUDS + 10, 100, 100 + DEBOUNCE_SECONDS + 0.01)).toBe(true)
	end)
	it("does not retrigger every frame under continuous per-frame CFrame writes (oscillation guard)", function()
		local v = JUMP_STUDS + 10
		local v2 = nil
		local v3 = nil
		local total = 0
		local count = 0

		for _ = 1, 120 do
			if shouldRecenter(v2, v, v3, total) then
				count += 1
				v3 = total
			end

			total += 0.016666666666666666
			v2 = v
		end

		expect(count).toBe(1)
	end)
end)