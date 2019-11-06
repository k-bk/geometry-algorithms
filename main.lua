local graph = require "love2d-graphs.graph"
local v2 = require "love2d-graphs.v2"

graph.FONT.body = love.graphics.newFont("Cantarell-Regular.otf", 12)
graph.FONT.title = love.graphics.newFont("Cantarell-Regular.otf", 18)

function rand_double(min, max)
   return love.math.random() * (max - min) + min
end

function my_det(a,b,c, algo)
   m = { det = function () end }
   if algo == 1 or algo == 3 then
      return 
         a[1]*b[2] + a[2]*c[1] + b[1]*c[2]
       - a[1]*c[2] - a[2]*b[1] - b[2]*c[1]
   elseif algo == 2 or algo == 4 then
      return 
         ((a[1]-c[1]) * (b[2]-c[2]))
       - ((a[2]-c[2]) * (b[1]-c[1]))
   elseif algo == 3 then
      return m.det({ 
         { a[1], a[2], 1 },
         { b[1], b[2], 1 },
         { c[1], c[2], 1 }})
   elseif algo == 4 then
      return m.det({
         { a[1]-c[1], a[2]-c[2] },
         { b[1]-c[1], b[2]-c[2] }})
   end
end

function orient(a,b,c, algo)
   d = my_det(a,b,c, algo)
   eps = 1e-10
   if d > eps then 
      return 1
   elseif d < -eps then 
      return -1
   else
      return 0 
   end
end


-- MAIN PROGRAM --

function main()
   local plots = {}
   local plot = function (p) table.insert(plots, p) end

   -- 1.a)
   local points_a = { color = graph.c.blue }
   for i = 1,1e5 do
      local p = v2(rand_double(-1000, 1000), rand_double(-1000, 1000))
      table.insert(points_a, p)
   end
   plot { points_a, title = "Punkty z przedziału  <-1000,1000>" }

   -- 1.b)
   local points_b = { color = graph.c.red }
   for i = 1,1e5 do
      local p = v2(rand_double(-1e14, 1e14), rand_double(-1e14, 1e14))
      table.insert(points_b, p)
   end
   plot { points_b, title = "Punkty z przedziału  <-1e14, 1e14>" }

   -- 1.c)
   local points_c = { color = graph.c.blue }
   for i = 1,1e5 do
      local r = rand_double(0, 2 * math.pi)
      local p = v2(100 * math.cos(r), 100 * math.sin(r))
      table.insert(points_c, p)
   end
   plot { points_c, title = "Punkty na okręgu o promieniu 100" }

   -- 1.d)
   local points_d = { color = graph.c.red }

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
      table.insert(points_d, p)
   end
   plot { points_d, title = "Punkty na prostej a[-1,0],  b[1,0.1]" }

   local pp_left, pp_right, pp_on
   -- 3.a)
   for i,pp in ipairs{ points_a, points_b, points_c, points_d } do
      pp_left = { color = graph.c.blue }
      pp_right = { color = graph.c.red }
      pp_on = { color = graph.c.green }
      for _, p in ipairs(pp) do
         local o = orient(a,b,p, 1)
         if o == 1 then table.insert(pp_left, p) end
         if o ==-1 then table.insert(pp_right, p) end
         if o == 0 then table.insert(pp_on, p) end
      end
      plot { pp_right, pp_left, pp_on, title = "Orientacja "..i }
   end

   print("Summary:")
   print("  algo", "left", "right", "on")
   for i,pp in ipairs{ points_a, points_b, points_c, points_d } do
      print(" graph "..i)
      for alg = 1,4 do
         local left, right, on = 0,0,0
         for _, p in ipairs(pp) do
            local o = orient(a,b,p, alg)
            if o == 1 then left = left + 1 end
            if o ==-1 then right = right + 1 end
            if o == 0 then on = on + 1 end
         end
         print("  "..alg, left, right, on)
      end
   end

   print("\nAlgorithms:")
   print(" 1. determinant 3x3, my implementation")
   print(" 2. determinant 2x2, my implementation")
   print(" 3. determinant 3x3, library function")
   print(" 4. determinant 2x2, library function")

   while true do
      for _,p in ipairs(plots) do
         coroutine.yield(p)
      end
   end
end

function love.load()
   get_content = coroutine.wrap(main)
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
