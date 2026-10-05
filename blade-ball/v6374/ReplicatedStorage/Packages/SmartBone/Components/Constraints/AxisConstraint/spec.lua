local createVector = vector.create
local AxisConstraint = require(script.Parent:WaitForChild("AxisConstraint"))
return function()
	local v = {
		Radius = 0,
		XAxisLimits = NumberRange.new(-1e999, 1e999),
		YAxisLimits = NumberRange.new(-1e999, 1e999),
		ZAxisLimits = NumberRange.new(-1e999, 1e999),
		AxisLocked = { false, false, false },
		ClipVelocity = function() end
	}
	afterEach(function()
		v.AxisLocked = { false, false, false }
	end)
	describe("Axis Lock", function()
		it("Should lock X Axis", function()
			v.AxisLocked = { true, false, false }
			local axisConstraint = AxisConstraint(v, createVector(-10, 0, 0), createVector(0, 0, 0), CFrame.identity)
			expect(axisConstraint.X).to.equal(0)
		end)
		it("Should lock Y Axis", function()
			v.AxisLocked = { false, true, false }
			local axisConstraint = AxisConstraint(v, createVector(0, -10, 0), createVector(0, 0, 0), CFrame.identity)
			expect(axisConstraint.Y).to.equal(0)
		end)
		it("Should lock Z Axis", function()
			v.AxisLocked = { false, false, true }
			local axisConstraint = AxisConstraint(v, createVector(0, 0, -10), createVector(0, 0, 0), CFrame.identity)
			expect(axisConstraint.Z).to.equal(0)
		end)
	end)
	describe("Axis Limit", function()
		describe("Should limit X Axis", function()
			it("Min Limit", function()
				v.XAxisLimits = NumberRange.new(-5, 1e999)
				local axisConstraint = AxisConstraint(
					v,
					createVector(-10, 0, 0),
					createVector(0, 0, 0),
					CFrame.identity
				)
				expect(axisConstraint.X).to.equal(-5)
			end)
			it("Max Limit", function()
				v.XAxisLimits = NumberRange.new(-1e999, 5)
				local axisConstraint = AxisConstraint(v, createVector(10, 0, 0), createVector(0, 0, 0), CFrame.identity)
				expect(axisConstraint.X).to.equal(5)
			end)
		end)
		describe("Should limit Y Axis", function()
			it("Min Limit", function()
				v.YAxisLimits = NumberRange.new(-5, 1e999)
				local axisConstraint = AxisConstraint(
					v,
					createVector(0, -10, 0),
					createVector(0, 0, 0),
					CFrame.identity
				)
				expect(axisConstraint.Y).to.equal(-5)
			end)
			it("Max Limit", function()
				v.YAxisLimits = NumberRange.new(-1e999, 5)
				local axisConstraint = AxisConstraint(v, createVector(0, 10, 0), createVector(0, 0, 0), CFrame.identity)
				expect(axisConstraint.Y).to.equal(5)
			end)
		end)
		describe("Should limit Z Axis", function()
			it("Min Limit", function()
				v.ZAxisLimits = NumberRange.new(-5, 1e999)
				local axisConstraint = AxisConstraint(
					v,
					createVector(0, 0, -10),
					createVector(0, 0, 0),
					CFrame.identity
				)
				expect(axisConstraint.Z).to.equal(-5)
			end)
			it("Max Limit", function()
				v.ZAxisLimits = NumberRange.new(-1e999, 5)
				local axisConstraint = AxisConstraint(v, createVector(0, 0, 10), createVector(0, 0, 0), CFrame.identity)
				expect(axisConstraint.Z).to.equal(5)
			end)
		end)
	end)
end