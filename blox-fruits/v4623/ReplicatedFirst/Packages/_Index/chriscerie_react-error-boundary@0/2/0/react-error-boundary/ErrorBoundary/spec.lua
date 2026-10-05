local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local Sift = require(ReplicatedStorage.Packages.Sift)
local ErrorBoundary = require(script.Parent.ErrorBoundary)
require(script.Parent.types)
local createElement = React.createElement
return function()
	describe("ErrorBoundary", function()
		local folder = nil
		local v = nil
		local flag = true
		local v2 = nil

		local function fn(p)
			if flag then
				error(v2)
			end

			return p.children
		end

		beforeEach(function()
			folder = Instance.new("Folder")
			v = ReactRoblox.createRoot(folder)
			flag = false
			v2 = "💥💥💥"
		end)
		it("should render children", function()
			(function()
				v:render(createElement(ErrorBoundary, {}, {
					Content = createElement("TextLabel")
				}))
			end)()
			task.wait()
			expect(folder:FindFirstChild("Content")).to.be.ok()
		end)
		describe("callback props", function()
			local ref = nil
			beforeEach(function()
				ref = React.createRef()
			end)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function render(p)
				(function()
					v:render(createElement(ErrorBoundary, Sift.Dictionary.merge(p, {
						fallback = createElement("TextLabel", {
							Text = "Error"
						}),
						ref = ref
					}), {
						MaybeThrows = createElement(fn, nil, {
							Content = createElement("Frame")
						})
					}))
				end)()
				task.wait()
			end

			it("should call \"onError\" prop if one is provided", function()
				flag = true
				local count = 0
				local v3 = nil
				render({
					onError = function(p)
						count += 1
						v3 = p
					end
				}) -- equivalent call inferred; original call site unknown
				expect(count).to.equal(1)
				expect(v3.message).to.equal("💥💥💥")
			end)
			it("should call \"onReset\" when boundary reset via imperative API", function()
				flag = true
				local count = 0
				render({
					onReset = function()
						count += 1
					end
				}) -- equivalent call inferred; original call site unknown
				expect(count).to.equal(0)
				ref.current.resetErrorBoundary("abc", 123)
				expect(count).to.equal(1)
			end)
			it("should call \"onReset\" when boundary reset via \"resetKeys\"", function()
				flag = false
				local count = 0

				local function onReset()
					count += 1
				end

				render({
					onReset = onReset,
					resetKeys = { 1 }
				}) -- equivalent call inferred; original call site unknown
				expect(count).to.equal(0)
				render({
					onReset = onReset,
					resetKeys = { 2 }
				}) -- equivalent call inferred; original call site unknown
				expect(count).to.equal(0)
				flag = true
				render({
					onReset = onReset,
					resetKeys = { 2 }
				}) -- equivalent call inferred; original call site unknown
				expect(count).to.equal(0)
				flag = false
				render({
					onReset = onReset,
					resetKeys = { 3 }
				}) -- equivalent call inferred; original call site unknown
				expect(count).to.equal(1)
			end)
		end)
		describe("\"fallback\" element", function()
			-- equivalent calls inferred from this helper; original call sites unknown
			local function render(options)
				(function()
					options = options or {}
					v:render(createElement(ErrorBoundary, Sift.Dictionary.merge(options, {
						fallback = createElement("TextLabel", {
							key = "Fallback"
						})
					}), {
						MaybeThrows = createElement(fn, nil, {
							Content = createElement("Frame")
						})
					}))
				end)()
				task.wait()
			end

			it("should render fallback in the event of an error", function()
				flag = true
				render(nil) -- equivalent call inferred; original call site unknown
				expect(folder:FindFirstChild("Fallback")).to.be.ok()
			end)
			it("should re-render children if boundary is reset by reset keys", function()
				flag = true
				local v3 = {
					resetKeys = 0
				}
				v3.resetKeys = { 1 }
				(function()
					v3 = v3 or {}
					v:render(createElement(ErrorBoundary, Sift.Dictionary.merge(v3, {
						fallback = createElement("TextLabel", {
							key = "Fallback"
						})
					}), {
						MaybeThrows = createElement(fn, nil, {
							Content = createElement("Frame")
						})
					}))
				end)()
				task.wait()
				expect(folder:FindFirstChild("Fallback")).to.be.ok()
				flag = false
				local v4 = {
					resetKeys = 0
				}
				v4.resetKeys = { 2 }
				(function()
					v4 = v4 or {}
					v:render(createElement(ErrorBoundary, Sift.Dictionary.merge(v4, {
						fallback = createElement("TextLabel", {
							key = "Fallback"
						})
					}), {
						MaybeThrows = createElement(fn, nil, {
							Content = createElement("Frame")
						})
					}))
				end)()
				task.wait()
				expect(folder:FindFirstChild("Content")).to.be.ok()
			end)
		end)
		describe("\"FallbackComponent\"", function()
			local fn2
			local error2 = nil
			local resetErrorBoundary = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function render(p)
				(function()
					p = p or {
						FallbackComponent = nil
					}
					v:render(createElement(ErrorBoundary, Sift.Dictionary.merge(p, {
						FallbackComponent = fn2
					}), {
						MaybeThrows = createElement(fn, nil, {
							Content = createElement("Frame")
						})
					}))
				end)()
				task.wait()
			end

			beforeEach(function()
				error2 = nil
				resetErrorBoundary = nil

				fn2 = function(p)
					error2 = p.error
					resetErrorBoundary = p.resetErrorBoundary
					return createElement("Frame", {
						key = "Fallback"
					})
				end
			end)
			it("should render fallback in the event of an error", function()
				flag = true
				render(nil) -- equivalent call inferred; original call site unknown
				expect(error2.message).to.equal("💥💥💥")
				expect(folder:FindFirstChild("Fallback")).to.be.ok()
			end)
			it("should re-render children if boundary is reset via prop", function()
				flag = true
				render(nil) -- equivalent call inferred; original call site unknown
				expect(folder:FindFirstChild("Fallback")).to.be.ok()
				expect(resetErrorBoundary).to.be.ok()
				flag = false

				if not resetErrorBoundary then
					error("lastRenderedResetErrorBoundary is nil")
				end

				resetErrorBoundary()
				task.wait()
				expect(folder:FindFirstChild("Content")).to.be.ok()
			end)
			it("should re-render children if boundary is reset by reset keys", function()
				flag = true
				local v3 = {
					resetKeys = 0
				}
				v3.resetKeys = { 1 }
				(function()
					v3 = v3 or {
						FallbackComponent = nil
					}
					v:render(createElement(ErrorBoundary, Sift.Dictionary.merge(v3, {
						FallbackComponent = fn2
					}), {
						MaybeThrows = createElement(fn, nil, {
							Content = createElement("Frame")
						})
					}))
				end)()
				task.wait()
				expect(folder:FindFirstChild("Fallback")).to.be.ok()
				flag = false
				local v4 = {
					resetKeys = 0
				}
				v4.resetKeys = { 2 }
				(function()
					v4 = v4 or {
						FallbackComponent = nil
					}
					v:render(createElement(ErrorBoundary, Sift.Dictionary.merge(v4, {
						FallbackComponent = fn2
					}), {
						MaybeThrows = createElement(fn, nil, {
							Content = createElement("Frame")
						})
					}))
				end)()
				task.wait()
				expect(folder:FindFirstChild("Content")).to.be.ok()
			end)
		end)
		describe("\"fallbackRender\" render prop", function()
			local error2 = nil
			local resetErrorBoundary = nil
			local fn2
			local count = 0

			-- equivalent calls inferred from this helper; original call sites unknown
			local function render(p)
				(function()
					p = p or {
						FallbackComponent = nil
					}
					v:render(createElement(ErrorBoundary, Sift.Dictionary.merge(p, {
						fallbackRender = fn2
					}), {
						MaybeThrows = createElement(fn, nil, {
							Content = createElement("Frame")
						})
					}))
				end)()
				task.wait()
			end

			beforeEach(function()
				error2 = nil
				resetErrorBoundary = nil
				count = 0

				fn2 = function(p)
					error2 = p.error
					resetErrorBoundary = p.resetErrorBoundary
					count += 1
					return createElement("Frame", {
						key = "Fallback"
					})
				end
			end)
			it("should render fallback in the event of an error", function()
				flag = true
				render(nil) -- equivalent call inferred; original call site unknown
				expect(error2.message).to.equal("💥💥💥")
				expect(count).never.to.equal(0)
				expect(folder:FindFirstChild("Fallback")).to.be.ok()
			end)
			it("should re-render children if boundary is reset via prop", function()
				flag = true
				render(nil) -- equivalent call inferred; original call site unknown
				expect(error2.message).to.equal("💥💥💥")
				expect(count).never.to.equal(0)
				expect(folder:FindFirstChild("Fallback")).to.be.ok()
				flag = false

				if not resetErrorBoundary then
					error("lastRenderedResetErrorBoundary is nil")
				end

				resetErrorBoundary()
				task.wait()
				expect(folder:FindFirstChild("Content")).to.be.ok()
			end)
			it("should re-render children if boundary is reset reset keys", function()
				flag = true
				local v3 = {
					resetKeys = 0
				}
				v3.resetKeys = { 1 }
				(function()
					v3 = v3 or {
						FallbackComponent = nil
					}
					v:render(createElement(ErrorBoundary, Sift.Dictionary.merge(v3, {
						fallbackRender = fn2
					}), {
						MaybeThrows = createElement(fn, nil, {
							Content = createElement("Frame")
						})
					}))
				end)()
				task.wait()
				expect(error2.message).to.equal("💥💥💥")
				expect(count).never.to.equal(0)
				expect(folder:FindFirstChild("Fallback")).to.be.ok()
				flag = false
				local v4 = {
					resetKeys = 0
				}
				v4.resetKeys = { 2 }
				(function()
					v4 = v4 or {
						FallbackComponent = nil
					}
					v:render(createElement(ErrorBoundary, Sift.Dictionary.merge(v4, {
						fallbackRender = fn2
					}), {
						MaybeThrows = createElement(fn, nil, {
							Content = createElement("Frame")
						})
					}))
				end)()
				task.wait()
				expect(folder:FindFirstChild("Content")).to.be.ok()
			end)
		end)
		describe("thrown value", function()
			local error2 = nil
			local fn2
			local onError
			local count = 0

			-- equivalent calls inferred from this helper; original call sites unknown
			local function render()
				(function()
					v:render(createElement(ErrorBoundary, {
						fallbackRender = fn2,
						onError = onError
					}, {
						MaybeThrows = createElement(fn, nil, {
							Content = createElement("Frame")
						})
					}))
				end)()
				task.wait()
			end

			beforeEach(function()
				error2 = nil
				count = 0

				onError = function()
					count += 1
				end

				fn2 = function(p)
					error2 = p.error
					return createElement("Frame", {
						key = "Fallback"
					})
				end
			end)
			it("should support thrown strings", function()
				flag = true
				v2 = "String error"
				render() -- equivalent call inferred; original call site unknown
				expect(error2.message).to.equal("String error")
				expect(count).to.equal(1)
				expect(folder:FindFirstChild("Fallback")).to.be.ok()
			end)
		end)
	end)
end