local lab = {}

function lab.my_det(a,b,c, algo)
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

function lab.load()

    -- 1.a)
   local points_a = { color = graph.c.blue }
   rand.in_range(v2(-1000,1000), v2(-1000,1000), 1e5, points_a)
   coroutine.yield { points_a, title = "Punkty z przedziału  <-1000,1000>" }

   -- 1.b)
   local points_b = { color = graph.c.red }
   rand.in_range(v2(-1e14,1e14), v2(-1e14,1e14), 1e5, points_b)
   coroutine.yield { points_b, title = "Punkty z przedziału  <-1e14, 1e14>" }

   -- 1.c)
   local points_c = { color = graph.c.blue }
   rand.on_circle(v2(100,100), 100, 100, points_c)
   coroutine.yield { points_c, title = "Punkty na okręgu o promieniu 100" }

   -- 1.d)
   local points_d = { color = graph.c.red }
   local a = v2(-1000, 0)
   local b = v2(1000, 100)
   rand.on_segment(a, b, 1e5, points_d)
   coroutine.yield { points_d, title = "Punkty na prostej a[-1,0],  b[1,0.1]" }

   -- 3.a)
   local pp_left, pp_right, pp_on
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
      coroutine.yield { pp_right, pp_left, pp_on, title = "Orientacja "..i }
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

   lab.load()
end

function lab.update()
end

function lab.draw()
end

return lab
