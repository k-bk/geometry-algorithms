function lab2()
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

   autorun = true
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

   autorun = false
   plot { s, p, title = "Algorytm Grahama, koniec" }
   autorun = true

   ----------------------
   -- Algorytm Jarvisa
   ----------------------

   local pivot = points[1]
   local s = { v2(pivot[1] - 50,pivot[2]), pivot, style = "line" }

   repeat
      local min_angle = math.huge
      local first, middle = s[#s-1], s[#s]
      local s1 = first - middle
      local s1_len = s1:len()

      for _,last in ipairs(points) do
         local s2 = last - middle 
         local angle = math.asin(s1:dot(s2) / (s1_len * s2:len()))
         if angle < min_angle then
            min_angle = angle
            min_p = last 
         end
      end

      table.insert(s, min_p)
      plot { s, points, title = "Algorytm Jarvisa" }
   until min_p == pivot 

   table.remove(s, 1)
   autorun = false
   while true do
      plot { s, p, title = "Algorytm Jarvisa, koniec" }
   end
end
