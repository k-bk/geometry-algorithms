local graph = require "love2d-graphs.graph"
local v2 = require "love2d-graphs.v2"

graph.FONT.body = love.graphics.newFont("Cantarell-Regular.otf", 12)
graph.FONT.title = love.graphics.newFont("Cantarell-Regular.otf", 18)

function rand_double(min, max)
   return love.math.random() * (max - min) + min
end

function det(a,b,c)
    return
      a[1]*b[2] + a[2]*c[1] + b[1]*c[2]
    - a[1]*c[2] - a[2]*b[1] - b[2]*c[1]
end

function orient(a,b,c)
   if a == b or b == c or c == a then return 0 end
   local d = det(a,b,c)
   local eps = 1e-10
   if d > eps then 
      return 1
   elseif d < -eps then 
      return -1
   else
      return 0 
   end
end

function main()
   local plot = coroutine.yield

   local points = { color = graph.c.blue }
   for i = 1,100 do
      local p = v2(rand_double(-1000, 1000), rand_double(-1000, 1000))
      table.insert(points, p)
   end
   plot { points, title = "Punkty z przedziału  <-1000,1000>" }

   table.sort(points, function (a,b) return a[1] < b[1] end)
   table.sort(points, function (a,b) return a[2] < b[2] end)
   local pivot = points[1]

   ----------------------
   -- Algorytm Grahama
   ----------------------

   table.sort(points, function (a,b) return orient(pivot, a, b) > 0 end)

   points.style = "line"
   plot { points, title = "Posortowane z przedziału  <-1000,1000>" }
   points.style = "point"

   run = true
   local p = points
   local s = { p[1], p[2], p[3], style = "line" }
   local i = #s + 1 
   local m = #p
   while i <= m do
      if orient(s[#s-1], s[#s], p[i]) > 0 then
         table.insert(s, p[i])
         i = i + 1
      else
         s[#s] = nil
      end
      plot { s, p, title = "Algorytm Grahama" }
   end

   table.insert(s, s[1])
   while true do
      plot { s, p, title = "Algorytm Grahama, koniec" }
   end

   ----------------------
   -- Algorytm Jarvisa
   ----------------------

   local start = p[1]
   local s = { v2(0,p[1][2]), p[1], style = "line" }
   repeat
      local min_i = 1
      local min_angle = math.huge
      for k = 2,#p do
         angle = det(s[#s-1], s[#s], p[k])
         if angle < min_angle then
            min_angle = angle
            min_i = k
         end
      end
      table.insert(s, p[min_i])
      i = min_i
      plot { s, p, title = "Algorytm Jarvisa" }
   until i == 1

   while true do
      plot { s, p, title = "Algorytm Jarvisa" }
   end
end

function love.load()
   run = false
   stoper = 0
   step = 0.1
   get_content = coroutine.wrap(main)
   content = get_content() 
end

function love.update(dt)
   stoper = stoper + dt
   if run and stoper > step then
      stoper = stoper - step 
      content = get_content()
   end
end

function love.mousepressed(x, y, button)
   if button == 1 then
      content = get_content()
   end
end

function love.draw()
   graph.graph(content)
end
