local createVector = vector.create
local Frustum = require(script.Parent:WaitForChild("Frustum"))
return function()
	local v = {
		CFrame = CFrame.identity,
		FieldOfView = 70,
		ViewportSize = Vector2.new(1920, 1080)
	}
	local v2 = {}
	describe("Generates CFrames", function()
		local now = os.clock()
		v2 = table.pack(Frustum.GetCFrames(v, 500))
		local now2 = os.clock()
		v2.n = nil
		print((`Solved view frustum in {string.format("%.2f", (now2 - now) * 1000000)}μs`))
	end)
	describe("Point In View", function()
		it("Close In View Point", function()
			expect(Frustum.InViewFrustum(createVector(0, 0, -5), table.unpack(v2))).to.equal(true)
		end)
		it("Past FarPlane Point", function()
			expect(Frustum.InViewFrustum(createVector(0, 0, -550), table.unpack(v2))).to.equal(false)
		end)
		it("Out Of View Point", function()
			expect(Frustum.InViewFrustum(createVector(0, 0, 5), table.unpack(v2))).to.equal(false)
		end)
	end)
	describe("Object In View", function()
		local v3 = {
			CFrame = CFrame.new(0, 0, -5),
			Size = createVector(1, 1, 3)
		}
		local v4 = {
			CFrame = CFrame.new(0, 0, -550),
			Size = createVector(1, 1, 3)
		}
		local v5 = {
			CFrame = CFrame.new(0, 0, 5),
			Size = createVector(1, 1, 3)
		}
		it("Close In View Object", function()
			expect(Frustum.ObjectInFrustum(v3, table.unpack(v2))).to.equal(true)
		end)
		it("Past FarPlane Object", function()
			expect(Frustum.ObjectInFrustum(v4, table.unpack(v2))).to.equal(false)
		end)
		it("Out Of View Object", function()
			expect(Frustum.ObjectInFrustum(v5, table.unpack(v2))).to.equal(false)
		end)
	end)
end