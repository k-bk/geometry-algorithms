UI = require "UI"
graph = require "love2d-graphs.graph"
rand = require "rand"
v2 = require "love2d-graphs.v2"

require "lab1"
require "lab2"

graph.FONT.body = love.graphics.newFont("Cantarell-Regular.otf", 12)
graph.FONT.title = love.graphics.newFont("Cantarell-Regular.otf", 18)

function det(a,b,c)
    return (a[1]-c[1]) * (b[2]-c[2])
         - (a[2]-c[2]) * (b[1]-c[1])
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

function love.load()
   autorun = false
   stoper = 0
   step = 0.05
   love.graphics.setBackgroundColor{ 1,1,1 }
   love.draw = draw_menu
end

function love.update(dt)
   if autorun then
      stoper = stoper + dt
      if stoper > step then
         stoper = stoper - step 
         content = get_content()
      end
   end
end

function love.mousepressed (x, y, button)
   if get_content then
      if button == 1 then
         content = get_content()
      end
   end
   if button == 1 then
      UI.mousepressed { x = x, y = y }
   end
end

function love.mousereleased (x, y, button)
    if button == 1 then
        UI.mousereleased { x = x, y = y }
    end
end

function love.mousemoved (x, y)
    UI.mousemoved { x = x, y = y }
end

function love.keypressed (key)
   if key == "escape" then
      if love.draw == draw_menu then
         love.event.quit()
      else
         love.draw = draw_menu
      end
   end
end

function draw_menu()
   UI.draw { x = 10, y = 10,
      {
         UI.button( "Lab 1", function () 
            get_content = coroutine.wrap(lab1) 
            content = get_content()
            love.draw = draw_lab
         end),
         UI.label { "Losowe punkty" },
      },
      {
         UI.button( "Lab 2", function () 
            get_content = coroutine.wrap(lab2) 
            content = get_content()
            love.draw = draw_lab
         end),
         UI.label { "Algorytmy Grahama i Jarvisa" },
      },
   }
end

function draw_lab()
   graph.graph(content)
end
