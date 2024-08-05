local M = {}

function M.greet(name)
	print("Hi, " .. name .. ", consider subscribing")
	return "Hi, " .. name .. ", consider subscribing"
	-- return "Hi, " .. name .. " consider subscribing"
end

return M
