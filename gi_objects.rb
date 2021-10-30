# Objektklassen

class LabObj
	def initialize(lab)
		@lab = lab
		@x = 1.0
		@y = 1.0
		@font = Gosu::Font.new(12,name:'./media/PressStart2P-Regular.ttf')		
		@smallfont = Gosu::Font.new(9,name:'./media/PressStart2P-Regular.ttf')
		@dir = ""
		@loctime = 0
		@player_on = ["NOTHING", 0]
		@name = self.to_s
	end

	def border?
		border = false
		if @y == 0 || @y == @lab.matrix.size-1 then
			border = true
		end
		if @x == 0 || @x == @lab.matrix[0].size-1 then
			border = true
		end
		return border
	end


	def name
		return @name
	end

	def remove!
		@x = 0.0
		@y = 0.0		
	end

	def locate(y,x)
		@x = x
		@y = y
	end

	def x
		return (@x + 0.5).to_i
	end

	def y
		return (@y + 0.5).to_i
	end

	def player_on
		return @player_on
	end

	def update(clocktime)
		nullvar = 0
	end

	def image
		return @image
	end

	def draw(faktor)
		pos_x = @x * TILESIZE * faktor
		pos_y = faktor * @y * TILESIZE + 5
  	@image.draw(pos_x, pos_y, 4, faktor, faktor)
  end
end

class Static < LabObj
	def initialize(lab)
		super(lab)
		@scrpoints = 0
		@sound = Gosu::Sample.new("media/sounds/sound01.wav")
		@loctime = 0
		@soundplay = false		
	end

	def update(clocktime)
		if clocktime > @loctime then
			@soundplay = false
			@loctime = clocktime
		end
	end

	def playsound
		if !@soundplay then
			@sound.play
			@soundplay = true
		end
	end

	def points
		return @scrpoints
	end
	def kill!
		@scrpoints = 0
	end
	def reset!
		@sawisrunning = false
	end
end

class Empty < Static
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("./media/empty.png")
		@player_on = ["NOTHING", 1]
		@name = "Empty field"		
	end
end


class PointsIndex < Static
	def initialize(lab, amount)
		super(lab)
		@player_on = ["NOTHING", 1]
		@name = "PointsIndex"	
		@amount = amount	
		@rounds = 3
	end

	# Zerfall
	def update(clocktime)
		if clocktime > @loctime then
			@loctime = clocktime
			@rounds -= 1	
		end
	end	

	# Nach Ablauf der Zerfallsdauer wird true ausgegeben.	
	def recent?
		return @rounds > 0
	end

	def draw(faktor)
		pos_x = (@x * TILESIZE + 10) * faktor
		pos_y = (@y * TILESIZE + 20) * faktor
		@font.draw_text(@amount.to_s, pos_x,pos_y, 7, 1.0, 1.0, Gosu::Color::BLACK)
  end

end




class Flower < Static
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/flower_2.png")
		@scrpoints = 5
		@player_on = ["COLLECT", 3]
		@name = "Flower"
		@sound = Gosu::Sample.new("media/sounds/smallflowersound.wav")
	end
end


class Bigflower < Static
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/flower_3.png")
#		@image = Gosu::Image::load_tiles("media/mushflower.png", 45, 45)
		@scrpoints = 20
		@player_on = ["COLLECT", 3]
		@name = "Flower"
		@sound = Gosu::Sample.new("media/sounds/flowersound.wav")
	end

	def draw(faktor)
		pos_x = @x * TILESIZE * faktor
		pos_y = faktor * @y * TILESIZE + 5
		img = @image
  	img.draw(pos_x, pos_y, 4, faktor, faktor)
  end


end

class Berry < Static
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("./media/gimmicks/pickup.png")
		@scrpoints = 0
		@player_on = ["COLLECT", 0]
		@name = "Berry"
#  	@sound = Gosu::Sample.new("media/sounds/bite.wav")
#		@sound = Gosu::Sample.new("media/sounds/flowersound.wav")
		@sound = Gosu::Sample.new("media/sounds/sound01.wav")
	end
end

class Bomb < Static
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/skull.png")
		@scrpoints = 0
		@player_on = ["KILL", 3]
		@name = "Bomb"
	end
end


class Headpiece < Static
	def initialize(lab)
		super(lab)
		@scrpoints = 25
		@player_on = ["COLLECT", 4]
	end

	def image
		return @image
	end

end

class Cappy < Headpiece
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/cappy.png")
		@name = "Cappy"
	end
end

class Tricorne < Headpiece
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/tricorne.png")
		@name = "Tricorne"
	end
end

class Bowler < Headpiece
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/bowler.png")
		@name = "Bowler Hat"
	end
end

class Helmet < Headpiece
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/helmet1.png")
		@name = "Helmet"
	end
end

class Helmet2 < Headpiece
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/cappy.png")
		@name = "Cappy"
	end
end

class Mushroom < Static
	def initialize(lab, load)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/mushroom.png")
		@scrpoints = 10
		@player_on = ["TRANSFORM", DeadMushroom, load]
		@name = "Pilz"
		@sound = Gosu::Sample.new("media/sounds/fartsound.wav")
	end
end


class DeadMushroom < Static
	def initialize(lab, load)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/deadmushroom.png")
		@scrpoints = 0
		@rounds = 5
		@player_on = ["NOTHING", 0]
		@load = load
		@name = "Totpilz"
	end
	
	# Totpilz wird mit Zerfallsobjekt beladen, das nach Zerfall erscheint.
	def load
		return @load
	end

	def update(clocktime)
		if clocktime > @loctime then
			@loctime = clocktime
			@rounds -= 1		
		end
	end	

	# Nach Ablauf der Zerfallsdauer wird true ausgegeben.	
	def recent? 
		if @rounds == 0 then
			return false
		end
		return true
	end
end

class Pit < Static
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/pfuetze.png")
		@scrpoints = 0
		@player_on = ["BRAKE", 3]
		@name = "Mudpit"
		@sound = Gosu::Sample.new("media/sounds/mudsound.wav")
	end
end


class Icepit < Static
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/icepit.png")
		@scrpoints = 0
		@player_on = ["WOOSH", 3]
		@name = "Woosh"
		@sound = Gosu::Sample.new("media/sounds/woosh.wav")
	end
end


class Coin < Static
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/coin.png")
		@scrpoints = 0
		@player_on = ["COLLECT", 1]
		@name = "Coin"
		@sound = Gosu::Sample.new("media/sounds/coinsound.wav")
	end
end


class Saw < Static
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/saege.png")
		@scrpoints = 0
		@player_on = ["COLLECT", 2]
		@name = "Saw"
	end
end


class Chainsaw < Saw
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/chainsaw.png")
		@name = "Chainsaw"
	end
end


class Obstacle < Static
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/obstacle.png")
		@scrpoints = 0
		@player_on = ["OBSTACLE", 0]
		@sawisrunning = 0
		@sound1 = Gosu::Sample.new("media/sounds/sawing.flac")
		@sound2 = Gosu::Sample.new("media/sounds/chainsaw.wav")
	end

	def hardness
		return @hardness
	end

	def saw!(type)
	 @sawisrunning = type
	end

	def update(clocktime)
		if clocktime > @loctime && !(@sawisrunning == 0) then
			@loctime = clocktime
			@rounds -= 1
#			puts "Nur noch #{@rounds} s"
			if @sawisrunning == Saw then
				@sound1.play
			elsif @sawisrunning == Chainsaw then
				@sound2.play
				if rand > 0.5 then
					@rounds -= 1
				end
			end				
		end
	end

	def rounds
		return @rounds
	end

	def recent?
		return rounds > 0
	end

	def draw(faktor)
#		puts "#{self.name} #{y} #{@x}"
		super(faktor)
		if !(@sawisrunning == 0) then
			pos_x = @x * TILESIZE * faktor
			pos_y = @y * TILESIZE * faktor
			@smallfont.draw_text("Chr...", pos_x,pos_y, 7, 1.0, 1.0, Gosu::Color::BLACK)
		end
  end
end

class Woodpile < Obstacle
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/gimmicks/obstacle.png")
		@rounds = 3
		@name = "Woodpile"
	end
end

class Tree < Obstacle
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/trees/tree1.png")
		@rounds = 5
		@name = "Tree"
	end
end

# Klasse für bewegliche Objekte
class Moving < LabObj
	def initialize(lab)
		super(lab)
		@lab = lab
		@v = 0.1
		@v_x = 0
		@v_y = 0
		@smallfont = Gosu::Font.new(18)
		@direction = ""
		@lastdirection = ""
		@sawdirok = false
	end

	def x_
		return (@x + 0.5).to_i
	end

	def y_
		return (@y + 0.5).to_i
	end

	def direction 
		return @direction
	end

	def lastdirection 
		return @lastdirection
	end

	def target(dir)
		if dir == "E" then
			y_t = (@y + 0.5).to_i
			x_t = (@x + 1).to_i
		end
		if dir == "W" then
			y_t = (@y + 0.5).to_i
			x_t = (@x - 0.1).to_i
		end
		if dir == "N" then 			
			x_t = (@x + 0.5).to_i
			y_t = (@y - 0.1).to_i
		end
		if dir == "S" then
			x_t = (@x + 0.5).to_i
			y_t = (@y + 1).to_i
		end
		return [y_t, x_t]
	end

	def targ_obj(dir)
		targ = target(dir)		
		t_obj = @lab.matrix[targ[0]][targ[1]]
		return t_obj
	end

	def move
		if @direction != "" then
			targ = targ_obj(@direction) 
			if targ.player_on[0] != "OBSTACLE" then
				@sawdirok = false
				if @direction == "E" then
					@y = y_
					@v_x = @v
					@v_y = 0
				end
				if @direction == "W" then
					@y = y_
					@v_x = -@v
					@v_y = 0
				end
				if @direction == "N" then 			
					@x = x_
					@v_x = 0
					@v_y = -@v
				end
				if @direction == "S" then
					@x = x_
					@v_x = 0
					@v_y = @v
				end
				@x += @v_x
				@y += @v_y
			end
		end
	end 		

	def image
		return @image
	end

end


# ----------------------------- Spinne ----------------------

class Boris < Moving

	def initialize(lab)
		super(lab)
		@imageE = Gosu::Image::load_tiles("media/moving_objects/borisE.png", 45,45)
		@imageS = Gosu::Image::load_tiles("media/moving_objects/borisS.png", 45,45)
		@imageN = Gosu::Image::load_tiles("media/moving_objects/borisN.png", 45,45)
		@imageW = Gosu::Image::load_tiles("media/moving_objects/borisW.png", 45,45)
#		@image = Gosu::Image.new("media/boris.png")		
		@player_on = ["KILL", 5]
		@name = "Boris the Spider"
		@direction = "N"
		@y = 17.0
		@x = 20.0
		@keepdir = 3
		@loctime = 0
		if @lab.level > 4 then
			@v_0 = ((@lab.level - 4) * 0.004).to_f
		else
			@v_0 = 0.004.to_f
		end			
	end

	def points
		return 0
	end

	def turnright(dir)
		if dir == "S" then 
			ndir_ = "W"
		elsif dir == "W" then
			ndir_ = "N"
		elsif dir == "N" then
			ndir_ = "E"
		else
			ndir_ = "S"
		end
#		puts ndir_
		return ndir_
	end	
			
	def turnleft(dir)
		if dir == "S" then 
			ndir = "E"
		elsif dir == "W" then
			ndir = "S"
		elsif dir == "N"
			ndir = "W"
		else
			ndir = "N"
		end
		return ndir		
	end

	def turn!(dir)
		@direction = dir
#		puts "Neue Richtung: #{@direction}"
	end

	def direction
		return @direction
	end

	def update(clocktime)
		if clocktime > @loctime then
			@loctime = clocktime
			if @keepdir > 0 then
				@keepdir -= 1
			end	
		end

		s_block = (targ_obj("S").player_on[0] == "OBSTACLE" || targ_obj("S").player_on[0] == "KILL")
		n_block = (targ_obj("N").player_on[0] == "OBSTACLE" || targ_obj("N").player_on[0] == "KILL")
		e_block = (targ_obj("E").player_on[0] == "OBSTACLE" || targ_obj("E").player_on[0] == "KILL")
		w_block = (targ_obj("W").player_on[0] == "OBSTACLE" || targ_obj("W").player_on[0] == "KILL")

		r_block = ((@direction == "E" && s_block) || (@direction == "W" && n_block) || (@direction == "N" && e_block) ||  (@direction == "S" && w_block))
		l_block = ((@direction == "E" && n_block) || (@direction == "W" && s_block) || (@direction == "N" && w_block) ||  (@direction == "S" && e_block))
		f_block = ((@direction == "E" && e_block) || (@direction == "W" && w_block) || (@direction == "N" && n_block) ||  (@direction == "S" && s_block))

		if f_block then
			if !r_block then
				@direction = turnright(@direction)
			else
				@direction = turnleft(@direction)
			end				
		end
		
		if !l_block && (rand * 10) > 7 && @keepdir == 0 then
			@direction = turnleft(@direction)
			@keepdir = 3
		end
		if !r_block && (rand * 10) > 7 && @keepdir == 0 then
			@direction = turnright(@direction)
			@keepdir = 3
		end
		@v = @v_0
		move
	end

	def draw(faktor)

		if @direction == "E" then
			image = @imageE
		elsif @direction == "W" then
			image = @imageW
		elsif @direction == "N" then
			image = @imageN
		elsif @direction == "S" then
			image = @imageS
		end

		pos_x = @x * TILESIZE * faktor
		pos_y = faktor * @y * TILESIZE + 5
		img = image[Gosu.milliseconds / 200 % 4]
  	img.draw(pos_x, pos_y, 4, faktor, faktor)
  end

	def relocate!
		rnd = 50 + (rand * 100).to_i
		@y = @lab.field[rnd][0]
		@x = @lab.field[rnd][1]
	end
end


class B2 < Boris
	def initialize(lab)
		super(lab)
		@image = Gosu::Image.new("media/moving_objects/boris2.png")
	end
end
