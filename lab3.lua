local lab = {}

local function plot(x) 
   autorun = false
   coroutine.yield(x) 
end
local function autoplot(x) 
   autorun = true
   coroutine.yield(x) 
end
local function as_lines(x)
   for _,s in ipairs(x) do
      s.style = "line"
      s.color = { 0.5, 0.5, 0.5 }
   end
end


function intersecting(p, q)
   if p == q then return false end
   local a,b,c,d = p[1],p[2],q[1],q[2]
   return orient(a, b, c) ~= orient(a, b, d) 
      and orient(c, d, a) ~= orient(c, d, b) 
end

function intersection_point(p, q)
   if p == q then return false end
   local a,b,c,d = p[1],p[2],q[1],q[2]
   local ab = a - b
   local cd = c - d
   local det_ab = det2(a, b)
   local det_cd = det2(c, d)
   local det_ab_cd = det2(ab, cd)

   local px = (det_ab * cd.x - det_cd * ab.x) / det_ab_cd
   local py = (det_ab * cd.y - det_cd * ab.y) / det_ab_cd
   return v2(px, py)
end

function y_order(s, x)
   local a,b = s[1],s[2]
   local t = (x - b.x) / (a.x - b.x)
   return a.y*t + b.y*(1 - t)
end

function neighbours(btree, value)
   for i,v in ipairs(btree) do
      if v == value then
         return btree[i-1], btree[i+1]
      end
   end
end

function rem(btree, value)
   for i,v in ipairs(btree) do
      if v == value then
         table.remove(btree, i)
         return
      end
   end
end

function sweep(segments)
   local ts = tostring

   local L = -math.huge

   local T = {}
   function redoT() 
      table.sort(T, function(p,q) 
         return y_order(p, L) < y_order(q, L)
      end)
   end

   local Q = btree(function(p,q) return p.key.x < q.key.x end)

   for _,s in ipairs(segments) do
      Q:insert { key = s[1], value = s, type = "left" }
      Q:insert { key = s[2], value = s, type = "right" }
   end

   local cross = { color = graph.c.red }

   function process_cross(a,b)
      local cross_point = intersection_point(a,b)
      if cross_point.x > L then
         table.insert(cross, cross_point)
         Q:insert { key = cross_point, value = { a,b }, type = "crossing" }
         print(("crossing: < %s, %s >  < %s, %s > in point %s"):format(ts(a[1]), ts(a[2]), ts(b[1]), ts(b[2]), ts(cross_point)))
      end
   end

   while not Q:empty() do
      e = Q:pop()
      L = e.key.x
      sweep_line = { v2(L,range[1]), v2(L,range[2]), color = graph.c.red, style = "line" }

      if e.type == "left" then
         table.insert(T, e.value)
         redoT()
         a,b = neighbours(T, e.value)
         if a and intersecting(a, e.value) then
            process_cross(a, e.value)
         end
         if b and intersecting(b, e.value) then
            process_cross(b, e.value)
         end
      end

      if e.type == "right" then
         a,b = neighbours(T, e.value)
         rem(T, e.value)
         if a and b and intersecting(a, b) then
            process_cross(a, b)
         end
      end

      if e.type == "crossing" then
         --[[
         redoT()
         a,b = e.value[1], e.value[2]
         w1, w2, w3, w4 = neighbours(T, a), neighbours(T, b)
         for w in ipairs { w1, w2, w3, w4 } do
            if w and a and intersecting(w, a) then
               process_cross(w, a)
            end
            if w and b and intersecting(w, b) then
               process_cross(w, b)
            end
         end
         --]]
      end

      print("size T:", #T)
      as_lines(T)
      to_plot = { unpack(T) }
      print("size toplot:", #to_plot)
      table.insert(to_plot, cross)
      table.insert(to_plot, sweep_line)
      plot(to_plot)
   end

end

function lab.load()
   graph_canvas_offset = 40
   graph_canvas = love.graphics.newCanvas(love.window.getDesktopDimensions())

   range = v2(-100, 100)
   segments = rand.segments(range, range, 20)
   for _,seg in ipairs(segments) do 
      seg.style = "line"
      seg.color = { 0,0,1 }
   end
   get_content = coroutine.wrap(function() sweep(segments) end)
   content = get_content()
   lab.update()
end

function lab.update(input)
   if input == "click" then
      content = get_content()
   elseif input == "stoper" then
      if autorun then
         content = get_content()
      end
   end

   local w, h = love.graphics.getDimensions()
   love.graphics.setCanvas(graph_canvas)

   local cc = { title = "Znajdowanie przecięć przez zamiatanie", unpack(segments) }
   for _,v in ipairs(content) do
      table.insert(cc,v)
   end
   graph.graph(cc, { width = w - graph_canvas_offset - 10, height = h })

   love.graphics.setCanvas()
end

function lab.draw()
   graph_canvas_offset, _ = UI.draw { x = 10, y = 10,
      UI.button( "Losuj", function() lab.load() end ),
      UI.button( "Start", function() animation = true end ),
      UI.button( "Stop", function() animation = false end ),
   }

   love.graphics.setColor(1,1,1)
   love.graphics.draw(graph_canvas, graph_canvas_offset + 10)
end

return lab
