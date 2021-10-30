# Spieler-Objekt

class Player < Moving
	def initialize(lab)
		super(lab)
		@imageE = Gosu::Image.new("media/moving_objects/playerE.png")
		@imageW = Gosu::Image.new("media/moving_objects/playerW.png")
		@imageN = Gosu::Image.new("media/moving_objects/playerN.png")
		@imageS = Gosu::Image.new("media/moving_objects/playerS.png")
		@image = @imageE
		@lives = 3
		@killed = false
		@score = SCOREOFFSET
		@points = 0
		@level = LEVELOFFSET
		#-----------
		@v_0 = 0.1
		@v = @v_0
		@direction = ""
		@lastdirection = ""
		@brake = 0
		@woosh = 0
		#-----------
		@collected = 0
		@coins = 1
		@coincount = 2
		@changecoins = false
		@bonus = []
		@changebonus = false
		@activesaw = 0
		@sawing = false
		@saws = []
		@sawingdir = ""
		@sawdircheck = false
		@headpieces = []
		@changehats = false
	end

	def image
		return @imageE
	end

	# Token sammeln -------------------------------------
	def collected
		return @collected
	end

	def collect(obj)
		if obj.player_on[1] == 0 then
			@collected += 1
		elsif	obj.player_on[1] == 1 then
			@coins += 1
		elsif obj.player_on[1] == 2 then
			if obj.class == Chainsaw then
				@saws.prepend(obj)
			else
				@saws.append(obj)
			end
		elsif obj.player_on[1] == 4 then
			is_included = false
			i = 0
			for i in 0..@headpieces.size - 1 do
				if @headpieces[i].class == obj.class then
#					puts @headpieces[i].class
#					puts obj.class
					is_included = true
				end
			end
			if !is_included then
				@headpieces.append(obj)
			end
		end
	end

	def headpieces
		return @headpieces
	end

	# Leben und Sterben lassen ------------------------
	def killed?
		return @killed
	end

	def kill!
		@killed = true
	end

	def die!
		@lives -= 1
	end

	def create!
		@lives += 1
	end

	def lives
		return @lives
	end	
	# -----------------------------------

	# Index für Münzumtausch
	def coincount
		return @coincount
	end
	# Münzen werden in Leben umgetauscht
	def changecoins?
		if !@changecoins then
			if @coins >= @coincount then
				@coins -= @coincount
				@lives += 1
				@coincount += 1
				@changecoins = true
			end	
		end
		return @changecoins
	end

	# Index für Punktebonus
	def bonuslevel
		return @bonus.size + 1
	end

	# 1 Bonus-Leben alle 1000 P
	def changebonus?
		if !@changebonus then
			if (@score / BONUSSTAGE) > @bonus.size then
				@bonus.append(1)
				@lives += 1
				@changebonus = true
			end
		end
		return @changebonus
	end
	
	# Bonuslevel bei drei versch. Hüten
	def changehats?
		if !@changehats then
			if @headpieces.size >= 3 then
				@changehats = true	
			end
		end
		return @changehats
	end

	def special?
		return @lab.special?
	end

	# Tausche eine Säge gegen ein Leben
	def toolchange
		@lives -=1
		@saws.append(Saw.new(@lab))
	end

	# Punktemanagement -------------------------------------------
	def scoreplus(amount)
		@score += amount
		@points = 0
	end

	def pointsplus(amount)
		@points += amount
	end

	def score
		return @score
	end

	def points 
		return @points
	end

	def reset!
		puts "Player-Reset"
		@x = 1
		@y = 1
		@sawing = false
		@changecoins = false
		@changebonus = false
		if @changehats then
			@changehats = false
			@headpieces = []
		end
		@killed = false
		@loctime = 0		
	end
	def uprank 
		@level += 1
		@collected = 0
		reset!
	end

	def level
		return @level
	end

	# Numismatik -------------------------------
	def collect_coin!
		@coins += 1
	end
	def coins
		return @coins
	end

	# Sägerei -----------------------------------
	def sawdirok!
		@sawdirok = true
	end

	def saws
		return @saws
	end

	def sawreset!
#		puts "Hör auf mit dem Gesäge"
		@sawing = false
		@sawdirok = false
		@activesaw = 0
	end

	def sawing?
		return @sawing
	end

	def activesawclass 
		return @activesaw.class
	end
	
	def use_saw
		if (Gosu.button_down? Gosu::KB_R) && !@sawing && @sawdirok then
			img = 0
			if @saws.size >= 1 then
#				puts "Sägen startet..."
				@sawing = true
				if !@lab.special? then
					@activesaw = @saws.shift()
				else
					@activesaw = @saws.first
				end
			end
		end
	end

	# Rundenupdate --------------------------
	def update(clocktime)
		use_saw
		if clocktime > @loctime then
			@loctime = clocktime
			if @brake > 0 then
				@brake -= 1
			end
			if @woosh > 0 then
				@woosh -= 1
			end
		end
		if !@sawing then
			get_direction			
			move
		end
	end

	def get_direction
		dir = ""
		if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT then
			dir = "W"
		end
		if Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT then
			dir = "E"
		end
		if Gosu.button_down? Gosu::KB_UP or Gosu::button_down? Gosu::GP_UP then
			dir = "N"
		end
		if Gosu.button_down? Gosu::KB_DOWN or Gosu::button_down? Gosu::GP_DOWN then
			dir = "S"
		end
		@direction = dir
		if @direction != "" then
			@lastdirection = @direction
#			puts "Richtung: #{@direction}(#{@sawing})"
		end

	end


	# Bewegungs-Modi -----------------------------------------------
	def set_brake!(duration)
		if @woosh == 0 then
			@brake = duration
		else
			unwoosh!
		end
	end

	def release_brake!
		@v = @v_0
		@brake = 0
	end

	def woosh!(duration)
		if @brake == 0 then
			@woosh = duration
		else
			release_brake!
		end
	end

	def unwoosh!
		@woosh = 0
		@v = @v_0
	end

	def move
#		puts "Bewege tatsächlich."
		if @brake > 0 then
			@v = @v_0 / 3
		elsif @woosh > 0 then
			@v = @v_0 * 2
		else
			@v = @v_0	
		end
		if @lab.special? then
			@v *= 1.5
		end

		super

		if @lastdirection == "E" then
			@image = @imageE
		elsif @lastdirection == "W" then
			@image = @imageW
		elsif @lastdirection == "N" then
			@image = @imageN
		elsif @lastdirection == "S" then
			@image = @imageS
		end	
	end

end

