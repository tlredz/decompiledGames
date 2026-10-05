local createVector = vector.create
return function()
	require(script.Parent.types)
	local createMotion = require(script.Parent.createMotion)
	local linear = require(script.Parent.solvers.linear)
	local spy = require(script.Parent.utils.spy)
	it("should return a Motion", function()
		local motion = createMotion(0)
		expect(motion).to.be.ok()
		expect(motion.state).to.be.a("table")
		expect(motion.start).to.be.a("function")
		expect(motion.stop).to.be.a("function")
		expect(motion.get).to.be.a("function")
		expect(motion.set).to.be.a("function")
		expect(motion.getVelocity).to.be.a("function")
		expect(motion.setVelocity).to.be.a("function")
		expect(motion.patch).to.be.a("function")
		expect(motion.impulse).to.be.a("function")
		expect(motion.to).to.be.a("function")
		expect(motion.step).to.be.a("function")
		expect(motion.isComplete).to.be.a("function")
		expect(motion.onComplete).to.be.a("function")
		expect(motion.onStep).to.be.a("function")
		expect(motion.destroy).to.be.a("function")
	end)
	it("should animate a number", function()
		local motion = createMotion(0)
		motion:to(linear(1, {
			speed = 1
		}))
		motion:step(0.5)
		expect(motion:get()).to.equal(0.5)
		expect(motion:isComplete()).to.equal(false)
		motion:step(0.5)
		expect(motion:get()).to.equal(1)
		expect(motion:isComplete()).to.equal(true)
	end)
	it("should animate a vector", function()
		local motion = createMotion((Vector3.new()))
		motion:to(linear(createVector(0.5, 0.75, 1), {
			speed = 1
		}))
		motion:step(0.5)
		expect(motion:get()).to.equal(createVector(0.5, 0.5, 0.5))
		expect(motion:isComplete()).to.equal(false)
		motion:step(0.5)
		expect(motion:get()).to.equal(createVector(0.5, 0.75, 1))
		expect(motion:isComplete()).to.equal(true)
	end)
	it("should animate an array", function()
		local motion = createMotion({ 0, 0, 0 })
		motion:to(linear({ 0.5, 0.75, 1 }, {
			speed = 1
		}))
		motion:step(0.5)
		expect(motion:get()[1]).to.equal(0.5)
		expect(motion:get()[2]).to.equal(0.5)
		expect(motion:get()[3]).to.equal(0.5)
		motion:step(0.5)
		expect(motion:get()[1]).to.equal(0.5)
		expect(motion:get()[2]).to.equal(0.75)
		expect(motion:get()[3]).to.equal(1)
	end)
	describe("when calling 'step'", function()
		it("should call onStep", function()
			local motion = createMotion(0)
			local v = spy()
			motion:onStep(v.handle)
			motion:to(linear(1, {
				speed = 1
			}))
			motion:step(0.5)
			expect(v.calls).to.equal(1)
			expect(v.arguments[1][1]).to.equal(0.5)
			expect(v.arguments[1][2]).to.equal(0.5)
			motion:step(0.5)
			expect(v.calls).to.equal(2)
			expect(v.arguments[2][1]).to.equal(1)
			expect(v.arguments[2][2]).to.equal(0.5)
			motion:step(0.5)
			expect(v.calls).to.equal(2)
			motion:to(linear(0, {
				speed = 1
			}))
			motion:step(0.5)
			expect(v.calls).to.equal(3)
			expect(v.arguments[3][1]).to.equal(0.5)
			expect(v.arguments[3][2]).to.equal(0.5)
		end)
		it("should call onComplete", function()
			local motion = createMotion(0)
			local v = spy()
			motion:onComplete(v.handle)
			motion:to(linear(1, {
				speed = 1
			}))
			motion:step(0.5)
			expect(v.calls).to.equal(0)
			motion:step(0.5)
			expect(v.calls).to.equal(1)
			expect(v.arguments[1][1]).to.equal(1)
			motion:step(0.5)
			expect(v.calls).to.equal(1)
			motion:to(linear(0, {
				speed = 1
			}))
			motion:step(1)
			expect(v.calls).to.equal(2)
			expect(v.arguments[2][1]).to.equal(0)
		end)
		it("should not run completed solvers", function()
			local motion = createMotion({
				a = 0,
				b = 0
			})
			local v = spy()
			local v2 = spy()
			motion:to({
				a = v.handle,
				b = function(p, p2, p3)
					v2.handle(p, p2, p3)
					p2.value = 1
					p2.complete = true
				end
			})
			expect(motion.state.a.complete).to.equal(false)
			expect(motion.state.b.complete).to.equal(true)
			expect(v.calls).to.equal(1)
			expect(v2.calls).to.equal(1)
			motion:step(1)
			expect(motion.state.a.complete).to.equal(false)
			expect(motion.state.b.complete).to.equal(true)
			expect(v.calls).to.equal(2)
			expect(v2.calls).to.equal(1)
		end)
	end)
	describe("when calling 'to'", function()
		it("should destroy the old solver", function()
			local motion = createMotion(0)
			local v = spy()
			motion:to(function(_, p)
				p.destructor = v.handle
			end)
			motion:step(1)
			expect(v.calls).to.equal(0)
			motion:to(linear(1))
			expect(v.calls).to.equal(1)
		end)
		it("should accept solvers per key", function()
			local motion = createMotion({
				a = 0,
				b = 0
			})
			motion:to({
				a = linear(1, {
					speed = 1
				}),
				b = linear(1, {
					speed = 0.5
				})
			})
			motion:step(0.5)
			expect(motion:get().a).to.equal(0.5)
			expect(motion:get().b).to.equal(0.25)
			expect(motion:isComplete()).to.equal(false)
			motion:step(0.5)
			expect(motion:get().a).to.equal(1)
			expect(motion:get().b).to.equal(0.5)
			expect(motion:isComplete()).to.equal(false)
			motion:step(1)
			expect(motion:get().a).to.equal(1)
			expect(motion:get().b).to.equal(1)
			expect(motion:isComplete()).to.equal(true)
		end)
		it("should mount the solver", function()
			local motion = createMotion(0)
			local v = spy()
			motion:to(v.handle)
			expect(v.calls).to.equal(1)
			expect(v.arguments[1][1]).to.equal(1)
			expect(v.arguments[1][2]).to.be.a("table")
			expect(v.arguments[1][3]).to.equal(0)
		end)
		it("should accept complex solvers", function()
			local motion = createMotion({
				a = 0,
				b = 0
			})
			motion:to(linear({
				a = 1
			}, {
				speed = 1
			}))
			motion:to(linear({
				b = 1
			}, {
				speed = 1
			}))
			motion:step(0.5)
			expect(motion:get().a).to.equal(0.5)
			expect(motion:get().b).to.equal(0.5)
			expect(motion:isComplete()).to.equal(false)
			motion:step(0.5)
			expect(motion:get().a).to.equal(1)
			expect(motion:get().b).to.equal(1)
			expect(motion:isComplete()).to.equal(true)
		end)
	end)
	describe("when passing options", function()
		it("should accept heartbeat", function()
			local v = {}

			local function connect(_, p)
				table.insert(v, p)

				local function disconnect()
					table.remove(v, table.find(v, p) or -1)
				end

				return {
					Disconnect = disconnect
				}
			end

			local function step(p: number)
				for _, v2 in v do
					v2(p)
				end
			end

			local motion = createMotion(0, {
				heartbeat = {
					Connect = connect
				},
				start = true
			})
			motion:to(linear(1, {
				speed = 1
			}))

			for _, v2 in v do
				v2(0.5)
			end

			expect(motion:get()).to.equal(0.5)
			expect(motion:isComplete()).to.equal(false)

			for _, v2 in v do
				v2(0.5)
			end

			expect(motion:get()).to.equal(1)
			expect(motion:isComplete()).to.equal(true)
		end)
	end)
	describe("patching state", function()
		it("should set a value", function()
			local motion = createMotion({
				a = 0,
				b = 0
			})
			motion:to({
				a = linear(1, {
					speed = 1
				}),
				b = linear(1, {
					speed = 0.5
				})
			})
			motion:step(0.5)
			expect(motion:get().a).to.equal(0.5)
			expect(motion:get().b).to.equal(0.25)
			motion:set({
				a = 2
			})
			motion:step(0.5)
			expect(motion:get().a).to.equal(1.5)
			expect(motion:get().b).to.equal(0.5)
		end)
		it("should flag as incomplete", function()
			local motion = createMotion({
				a = 0,
				b = 0
			})
			motion:to({
				a = linear(1, {
					speed = 1
				}),
				b = linear(1, {
					speed = 1
				})
			})
			motion:step(1)
			expect(motion:isComplete()).to.equal(true)
			motion:set({
				a = 2
			})
			expect(motion:isComplete()).to.equal(false)
			motion:step(1)
			expect(motion:isComplete()).to.equal(true)
		end)
		it("should patch the state", function()
			local motion = createMotion({
				a = 0,
				b = 0
			})
			motion:patch({
				a = {
					value = 1
				}
			})
			expect(motion:get().a).to.equal(1)
			expect(motion:get().b).to.equal(0)
		end)
	end)
end