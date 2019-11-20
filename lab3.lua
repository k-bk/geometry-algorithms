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

function y_order(s, x)
   local a,b = s[1],s[2]
   local t = (x - b[1]) / (a[1] - b[1])
   return a*t + b*(1 - t)
end

function sweep(segments)

   local L = -math.huge

   local T = btree(function(p,q) 
      return y_order(p.key, L) < y_order(q.key, L)
   end)
   local Q = btree(function(p,q) return p.key[1] < q.key[1] end)

   for _,s in ipairs(segments) do
      Q:insert { key = s[1], value = s, type = "left" }
      Q:insert { key = s[2], value = s, type = "right" }
   end

   while not Q:empty() do
      e = Q:pop_min()
      L = e.key[1]

      local type = evt_type(e)

      if type == "left" then
         T:insert(e.value)
         a,b = neighbours(T, e.value)
         if a and intersecting(a, e.value) then
            Q:insert { key = intersection_point(a, e.value), value = { a, e.value }, type = "crossing" }
         end
         if b and intersecting(b, e.key) then
            Q:insert { key = intersection_point(b, e.value), value = { e.value, b }, type = "crossing" }
         end
      end

      if type == "right" then
         T:remove(e.value)
         a,b = neighbours(T, e.value)
         if a and b and intersecting(a, b) then
            Q:insert { key = intersection_point(a,b), value = { a,b }, type = "crossing" }
         end
      end

      if type == "crossing" then
         T:remove(e.value)
         a,b = e.value[1], e.value[2]
         w, _, _, s = neighbours(T, a), neighbours(T, b)
         if intersecting(w, a) then
            Q:insert { key = intersection_point(w, a), value = { w,a }, type = "crossing" }
         end
         if intersecting(s, b) then
            Q:insert { key = intersection_point(s, b), value = { s,b }, type = "crossing" }
         end
      end
   end

end

function lab.load()
   range = v2(-100, 100)
   segments = rand.segments(range, range, 30)
   sweep(segments)
   --[[
   for _,seg in ipairs(segments) do 
      seg.style = "line"
      seg.color = graph.c.blue
   end
   --]]
end

function lab.update()
end

function lab.draw()
   graph.graph { title = "Losowe odcinki w przedziale "..range, unpack(segments) }
end

return lab
