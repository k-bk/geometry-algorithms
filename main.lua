rand = require "rand"
btree = require "btree"
stack = require "stack"

UI = require "lib.UI"
graph = require "lib.graph"
v2 = require "lib.v2"

lab1 = require "lab1"
lab2 = require "lab2"
lab3 = require "lab3"
lab4 = require "lab4"

font_body = love.graphics.newFont("Cantarell-Regular.otf", 15)
font_title = love.graphics.newFont("Cantarell-Regular.otf", 18)

graph.FONT.body = font_body
graph.FONT.title = font_title
UI.font = font_body

function det2(a,b)
   return a[1]*b[2] - a[2]*b[1]
end

function det3(a,b,c)
    return (a[1]-c[1]) * (b[2]-c[2])
         - (a[2]-c[2]) * (b[1]-c[1])
end

function orient(a,b,c)
   if a == b or b == c or c == a then return 0 end
   local d = det3(a,b,c)
   local eps = 1e-10
   if d > eps then 
      return 1
   elseif d < -eps then 
      return -1
   else
      return 0 
   end
end

function array_min(t, lt)
   if not lt then lt = function(a,b) return a < b end end
   if #t < 1 then return nil end
   local min_i = 1
   for i = 2,#t do
      if lt(t[i], t[min_i]) then
         min_i = i
      end
   end
   return min_i, t[min_i]
end

function gcd(a, b)
   if b == 0 then return a end
   return gcd(b, a % b)
end

function array_rotate_left(t, d)
   local tmp,j,k
   for i = 1, gcd(#t, d) do
      tmp = t[i]
      j = i
      while true do
         k = j + d
         if k > #t then k = k - #t end
         if k == i then break end
         t[j] = t[k]
         j = k
      end
      t[j] = tmp
   end
end

function love.load()
   autorun = false
   stoper = 0
   step = 0.3
   love.graphics.setBackgroundColor{ 1,1,1 }
   love.graphics.setLineJoin("bevel")
   love.draw = draw_menu
end

function love.update(dt)
   if lab and autorun then
      stoper = stoper + dt
      if stoper > step then
         stoper = stoper - step 
         lab.update("stoper")
      end
   end
end

function love.mousepressed(x, y, button)
   if lab then
      if button == 1 then
         lab.update("click", x, y)
      end
   end
   if button == 1 then
      UI.mousepressed { x = x, y = y }
   end
end

function love.mousereleased(x, y, button)
   if button == 1 then
      UI.mousereleased { x = x, y = y }
   end
end

function love.mousemoved(x, y)
   mouse_position = v2(x,y)
   if lab and lab.mousemoved then lab.mousemoved(x, y) end

   UI.mousemoved { x = x, y = y }
end

function love.resize()
   lab.update("resize")
end

function love.keypressed(key)
   if key == "escape" then
      if love.draw == draw_menu then
         love.event.quit()
      else
         love.draw = draw_menu
      end
   elseif key == "enter" or key == "space" then
      lab.update("click")
   end
end

function draw_menu()
   UI.draw { x = 10, y = 10,
      {
         UI.button { "Lab 1", on_click = function () 
            lab = lab1
            lab.load()
            love.draw = lab.draw 
         end },
         UI.label { "Losowe punkty" },
      },
      {
         UI.button { "Lab 2", on_click = function () 
            lab = lab2
            lab.load()
            love.draw = lab.draw 
         end },
         UI.label { "Algorytmy Grahama i Jarvisa" },
      },
      {
         UI.button { "Lab 3", on_click = function () 
            lab = lab3
            lab.load()
            love.draw = lab.draw 
         end },
         UI.label { "Przecinające się odcinki, zamiatanie" }
      },
      {
         UI.button { "Lab 4", on_click = function () 
            lab = lab4
            lab.load()
            love.draw = lab.draw 
         end },
         UI.label { "Wielokąty y-monotoniczne" }
      },
   }
end
