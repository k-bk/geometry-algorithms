local lab = {}

function intersecting(p, q)
   local a,b,c,d = p[1],p[2],q[1],q[2]
   return orient(a, b, c) ~= orient(a, b, d) 
      and orient(c, d, a) ~= orient(c, d, b) 
end

function intersection_point(p, q)
   local a,b,c,d = p[1],p[2],q[1],q[2]
   local ab = a - b
   local cd = c - d
   local det_ab = det2(a, b)
   local det_cd = det2(c, d)
   local det_ab_cd = det2(ab, cd)

   local px = (det_ab * cd[1] - det_cd * ab[1]) / det_ab_cd
   local py = (det_ab * cd[2] - det_cd * ab[2]) / det_ab_cd
   return v2(px, py)
end


function sweep(segments)

   local T = btree()
   local Q = btree()

   while #events > 0 do
      if segment_start then
         a,b = neighbours(T, s)
         if a and intersecting(a, s) then
            Q:insert(intersection_point(a,s))
         end
         if b and intersecting(b, s) then
            Q:insert(intersection_point(b,s))
         end
      end

      if segment_end then
         T:remove(s)
         a,b = neighbours(T, s)
         if a and b and intersecting(a, b) then
            Q:insert(intersection_point(a,b))
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
