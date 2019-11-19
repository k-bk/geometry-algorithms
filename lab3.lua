local lab = {}

function intersection(p, q)
   return orient(p[1], p[2], q[1]) ~= orient(p[1], p[2], q[2]) 
      and orient(q[1], q[2], p[1]) ~= orient(q[1], q[2], p[2]) 
end

function sweep(segments)

   local T = btree()
   local Q = btree()

   while #events > 0 do
      if segment_start then
         a,b = neighbours(T, s)
         if a and intersection(a, s) then
            Q:insert(intersection(a,s))
         end
         if b and intersection(b, s) then
            Q:insert(intersection(b,s))
         end
      end

      if segment_end then
         T:remove(s)
         a,b = neighbours(T, s)
         if a and b and intersection(a, b) then
            Q:insert(intersection(a,b))
         end
      end

      if segment_intersection then
         
      end
   end

end

function lab.load()
   range = v2(-100, 100)
   segments = rand.segments(range, range, 30)
   for _,seg in ipairs(segments) do 
      seg.style = "line"
      seg.color = graph.c.blue
   end
end

function lab.update()
end

function lab.draw()
   graph.graph { title = "Losowe odcinki w przedziale "..range, unpack(segments) }
end

return lab
