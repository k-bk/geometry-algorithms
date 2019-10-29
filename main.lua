local graph = require "love2d-graphs.graph"
local v2 = require "love2d-graphs.v2"

graph.FONT.body = love.graphics.newFont("Cantarell-Regular.otf", 12)
graph.FONT.title = love.graphics.newFont("Cantarell-Regular.otf", 18)

c = {
   blue = { .3,.3,1 },
   black = { 0,0,0 },
   red = { 1,0,0 },
   white = { 1,1,1 }
}

function rand_double(min, max)
   return love.math.random() * (max - min) + min
end

function main()
   local plot = coroutine.yield
   local points

   -- 1.a)
   points = { color = c.blue, title = "Punkty z przedziału  <-1000,1000>" }
   for i = 1,1e5 do
      local p = v2(rand_double(-1000, 1000), rand_double(-1000, 1000))
      table.insert(points, p)
   end
   plot(points)

   -- 1.b)
   points = { color = c.red, title = "Punkty z przedziału  <-1e14, 1e14>" }
   for i = 1,1e5 do
      local p = v2(rand_double(-1e14, 1e14), rand_double(-1e14, 1e14))
      table.insert(points, p)
   end
   plot(points)

   -- 1.c)
   points = { color = c.blue, title = "Punkty na okręgu o promieniu 100" }
   for i = 1,1e5 do
      local r = rand_double(0, 2 * math.pi)
      local p = v2(100 * math.cos(r), 100 * math.sin(r))
      table.insert(points, p)
   end
   plot(points)

   -- 1.d)
   points = { color = c.red, title = "Punkty na prostej a[-1,0],  b[1,0.1]" }

   local a = v2(-1.0, 0.0)
   local b = v2(1.0, 0.1)
   local t = v2(0,0)
   if math.abs(a[1]-b[1]) > math.abs(a[2]-b[2]) then
       t_min = (a[1] + 1000) / (a[1] - b[1])
       t_max = (a[1] - 1000) / (a[1] - b[1])
   else
       t_min = (a[2] + 1000) / (a[2] - b[2])
       t_max = (a[2] - 1000) / (a[2] - b[2])
   end

   for i = 1,1e3 do
      local t = rand_double(t_min, t_max)
      local p = (1-t)*a + t*b 
      table.insert(points, p)
   end
   plot(points)
end

function coroutine.loop(f)
   while true do
      co = coroutine.wrap(f)
      for ret in co do coroutine.yield(ret) end
   end
end

function love.load()
   get_content = coroutine.wrap(function() coroutine.loop(main) end)
   content = get_content() 
end

function love.mousepressed(x, y, button)
   if button == 1 then
      content = get_content()
   end
end

function love.draw()
   graph.graph(content)
end
