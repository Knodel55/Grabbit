require 'gosu'
require './gi_labs.rb'
require './gi_boxes.rb'
require './gi_objects.rb'
require './gi_player.rb'

TILESIZE = 45
TIMEROFFSET = 75
LEVELOFFSET = 0
SCOREOFFSET = 0
BONUSSTAGE = 1500

Tile_Color = Gosu::Color.argb(0xff_779911)
Seam_Color = Gosu::Color.argb(0xff_664422)

def bildschirmgroesse
	x = ""
	puts("Displaygröße mind. 1200 x 800? (J/N)")
	x = gets.chop.to_s
	puts "-> #{x}"
	disparray=[]
	if x.to_s == "n" || x.to_s == "N" then
		puts "Klein"
		faktor = 0.8
	else
		faktor = 1.0
		puts "Groß"
	end
	puts("Starte mit Enter")
	start = gets
	faktor = 1.0
	return faktor
end

module ZOrder
  BACKGROUND, STARS, PLAYER, UI = *0..3
end


class Musicplayer
	def initialize(title, duration)
		@song = title
		@song.volume = 0.6
		@bell = Gosu::Sample.new("media/sounds/bell.wav")
		@duration = duration
		@loctime = Gosu.milliseconds
		@running = false	
		@counter = 0 
	end
	
	def activate!
		@running = true
	end

	def update(time)
		if time - @loctime > @duration && @running then
			@loctime = time
			@song.play
			@counter += 1
		end
	end

	def stop!
		@running = false
	end
end



class Info
	def initialize(player, faktor)
		@player = player
    @green = Gosu::Color.new(0xff_10CC10)
		@bigfont = Gosu::Font.new((15 * faktor).to_i,name:'./media/PressStart2P-Regular.ttf')
		@coinimage = Gosu::Image.new("media/gimmicks/coin.png")
		@sawimage = Gosu::Image.new("media/gimmicks/saege.png")
	end
	def write(time, faktor)
		if @player.special? then
			levelstr = "Bonuslevel (#{@player.level})"
		else 	
			levelstr = "Level: #{@player.level}"
		end
		@bigfont.draw_text(levelstr, 1000*faktor, 20, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLUE)

		timestr = "Time: #{time} s"
		timesize = timestr.size
		for i in 0..timesize-1 do
			if (time.to_f/TIMEROFFSET) <= ( i.to_f/timesize) then
				color = Gosu::Color::RED
			else
				color = @green
			end
			j = timesize - (i + 1)
			@bigfont.draw_text(timestr[j], (1000 + j * 15) * faktor, 50, ZOrder::UI, 1.0, 1.0, color)
		end
#		@bigfont.draw_text("Time: #{time} s", 1000*faktor, 50, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLUE)
		@bigfont.draw_text("Grabs: #{@player.collected}", 1000*faktor, 80, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLUE)
		@bigfont.draw_text("Points: #{@player.points}", 1000*faktor, 110, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLUE)
		@bigfont.draw_text("Score: #{@player.score}", 1000*faktor, 140, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLUE)
		for i in 0..@player.lives-1 do
			@player.image.draw(faktor * (1000 + (i % 3) * 50), 180+ (i / 3) * 40, 6, faktor, faktor)
		end
		for i in 0..@player.coins-1 do
			@coinimage.draw(faktor * (1000 + (i % 3) * 50), 180+ (1 + i / 3 + (@player.lives - 1) / 3) * 40, 6, faktor, faktor)
		end
		for i in 0..@player.saws.size-1 do
			@player.saws[i].image.draw(faktor * (1000 + (i % 3) * 50), 180 + (2 + i / 3 + ((@player.lives - 1) / 3) + ((@player.coins - 1) / 3)) * 40, 6, faktor, faktor)
		end
		for i in 0..@player.headpieces.size-1 do
			image = @player.headpieces[i].image
			image.draw(faktor * (1000 + (i % 3) * 50), 180 + (3 + i / 3 + ((@player.lives - 1) / 3) + ((@player.coins - 1) / 3) + ((@player.saws.size - 1) / 3)) * 40, 6, faktor, faktor)
		end
	end
end


class Clock
	def	initialize
		@start = Gosu.milliseconds
		@timer_run = false
		@level_failed = false
		@time_spent = 0
		@time_old = 0
		@time_new = 0
		@offset = 0
	end

	def seconds
		return ((Gosu.milliseconds - @start)/1000).to_i
	end

	def timer_pause
		@timer_run = false
	end

	def timer_set(offset)
		@offset = offset
	end

	def timer_stop
		@level_failed = true
	end

	def timer_resume
		@timer_run = true
		@timeold = Gosu.milliseconds.to_i
	end

	def timer
		if @timer_run then
			@time_new = Gosu.milliseconds.to_i
			if @time_new >= @time_old + 1000 then
				@time_spent += 1
				@time_old = @time_new
			end
		end
		@time_left = @offset - @time_spent
		if !@level_failed then
			return @time_left
		else
			return 0
		end
	end

	def time_left
		return @time_left
	end

end


class GameHandler
	def initialize(player, musicplayer, lab, faktor)	
		@lab = lab
		@player = player
		@musicplayer = musicplayer
		@offset = TIMEROFFSET
		@pause = false
		@pausebox = Gosu::Image.new("media/pausebox.png")
		@font = Gosu::Font.new((13 * faktor).to_i,name:'./media/PressStart2P-Regular.ttf')
		@boxstr = ""
		@faktor = faktor
		@event = ""
	end

	def delay(dur)
		timeloc = Gosu.milliseconds
		while (Gosu.milliseconds - timeloc) < dur do
			# Nullbefehl, um die Schleife zu füllen.
			nullvar = 0
		end 
	end

	def pausebox
		@pausebox.draw(240 * @faktor, 150 * @faktor, 8, @faktor, @faktor)
		pause_array = []
		if @event == "LEVEL_START" then
			pause_array.append(@levelbox)
			pause_array.append(@berrybox)
			pause_array.append(@flowerbox)
			pause_array.append(@sawbox)
			pause_array.append(@mushroombox)
			pause_array.append(@lifebox)
			pause_array.append(@coinbox)
			pause_array.append(@playbox)				
			pause_array.append(@playbox2)				
			pause_array.append(@playbox3)				
		end
		if @event == "LEVEL_FAILED" then
			pause_array.append(@levelfailbox)
			@levelfailbox2 = BoxObj.new(Gosu::Image.new("media/gimmicks/pickup.png"), "Noch #{@lab.count} Beere(n) zu sammeln.", @faktor)
			pause_array.append(@levelfailbox2)
			if @player.changecoins? then
				pause_array.append(@coinbox2)				
			end
			if @player.killed? then
				pause_array.append(@deathbox)						
			end
			if @player.lives >= 1 then 
				pause_array.append(@playbox)				
				pause_array.append(@playbox2)				
			else
				pause_array.append(@goodbyebox)				
			end
			pause_array.append(@playbox3)				
		end
		if @event == "LEVEL_PASSED" then
			pause_array.append(@levelpassedbox)
			if @player.changecoins? then
				pause_array.append(@coinbox2)				
			end
			if @player.changebonus? then
				pause_array.append(@bonusbox)				
			end
			if @player.changehats? then
				pause_array.append(@hatbox)
			end
			pause_array.append(@playbox)				
			pause_array.append(@playbox2)				
			pause_array.append(@playbox3)				
		end
		
#		@font.draw_text(@boxstr, 270 * @faktor, 170 * @faktor, z=9, 1.0, 1.0, Gosu::Color::BLACK)
		for i in 0..pause_array.size-1 do
			pause_array[i].draw(i+1)
		end
	end

	def gamestart
		start_round
		@musicplayer.activate!
	end

	def unpause!
		@musicplayer.activate!
		if @player.lives >= 1 then
			@pause = false
			if @level_passed then
				start_round
			elsif level_failed? then
				@player.die!
				next_try
			else
				@ticktock.timer_resume
			end
		end
	end

	def pause!
		@pause = true
		@ticktock.timer_pause
	end

	def pause?
		return @pause
	end	

	def update
#		puts "O: #{@objects.size}"
#		puts "M: #{@m_objects.size}"
		@boxstr = level_start_box
		if !@aim1 && @player.collected == 100 then
			@player.pointsplus(20)
			@aim1 = true
		end

		if !@aim2 && @player.collected == 150 then
			@player.pointsplus(20)
			@aim2 = true
		end

		if !@pause then
			
			# Update der statischen Objekte 
			for y in 0..@lab.matrix.size-1 do
				for x in 0..@lab.matrix[y].size-1 do
					@lab.matrix[y][x].update(@ticktock.seconds)
				end
			end

			# Kollision des Spielers mit statischen Objekten 
			collide(@lab.matrix[@player.y][@player.x])

			# Steuerung der beweglichen Objekte: Gehen nicht auf blockierte oder tödliche Felder,
			# also auch nicht auf andere tödliche bewegliche Objekte
			for obj in @m_objects do
				for obj2 in @m_objects do
					if obj != obj2 then
						if obj.target(obj.direction) == obj2.target(obj2.direction) || obj.targ_obj(obj.direction) == obj2 || obj2.targ_obj(obj2.direction) == obj then
							obj.turn!(obj.turnright(obj.turnright(obj.direction)))
						end
					end
				end

				# Kollision des Spielers mit beweglichen Objekten 
				obj.update(@ticktock.seconds)
				if @player.x == obj.x && @player.y == obj.y then
					collide(obj)
				end	
			end

			# Player-Update (insbes. Bewegung)
			@player.update(@ticktock.seconds)

			checkobjects
			check_saw_dir
			if level_failed? then
				@event = "LEVEL_FAILED"
				if @player.killed? then
#					Gosu::Sample.new("media/killed.sounds/ogg").play
					@musicplayer.stop!
				else
#					Gosu::Sample.new("media/failed.sounds/wav").play
					@musicplayer.stop!
				end
#				@player.kill!
				if @player.lives <= 0 then
					@boxstr = game_finish_box
				end
				pause!
			end
			if all_collected? then
				@player.scoreplus(@player.points)
				@player.scoreplus(@player.level * 10)
				@level_passed = true
				@event = "LEVEL_PASSED"
#					Gosu::Sample.new("media/passed.wav").play
					@musicplayer.stop!
				pause!
			end
		end
	end

	def check_saw_dir
		if @player.lastdirection != "" then
			targ_x = @player.target(@player.lastdirection)[1]
			targ_y = @player.target(@player.lastdirection)[0]
#			puts "DEBUG #{targ_y}, #{targ_x}"
			targ_obj = @lab.matrix[targ_y][targ_x]
			if targ_obj.player_on[0] == "OBSTACLE" && !targ_obj.border? then
				if @player.sawing? then
					@objects.append(targ_obj)
					targ_obj.saw!(@player.activesawclass)
				else
					@player.sawdirok!
				end
				if !targ_obj.recent? then
#					puts "Zersägt"
					remove(targ_obj)
					@player.sawreset!
				end
			end
		end
	end

	# Abgelaufene Objekte werden aus den Listen gelöscht.			
	def remove(obj)
		x = obj.x
		y = obj.y
		@lab.delete(y, x)
		@objects.delete(obj)
		@m_objects.delete(obj)	
	end


	# Update etc. für alle Objekte in der Objektliste
	def checkobjects
		for obj in @objects do
			obj.update(@ticktock.seconds)
			x = obj.x
			y = obj.y
			# Update von Totpilzen, bei abgelaufener Zeit Transformation in Load-Objekt
			if obj.class == DeadMushroom then
				if !obj.recent? then
					remove(obj)
					# Ersatzobjekte werden in den Listen platziert.
					nobj = obj.load.new(@lab)
#					puts "Erzeuge #{nobj.name} (#{obj.y}, #{obj.x}) bei t = #{@ticktock.seconds} s"
					nobj.locate(y, x)
					@lab.fill!(nobj)
				end
			# Punkteanzeiger werden nach 2 s nicht mehr angezeigt
			elsif obj.class == PointsIndex then
				if !obj.recent? then
					remove(obj)
				end			
			end
		end
	end


	# Kontrolliert,mit welchem Objekt der Player auf dem Feld steht, und was dann passiert.
	def collide(obj)
		if obj.class != Empty then
#			puts "Kollidiere mit #{obj.name} auf (#{obj.y}, #{obj.x}) bei t = #{@ticktock.seconds} s"
		end
		@player.pointsplus(obj.points)
		# COLLECT-Objekte werden gesammelt
		if obj.player_on[0] == "COLLECT" then
			@player.collect(obj)
			obj.playsound
			@lab.delete(obj.y, obj.x)
			if obj.points > 0 then
				nobj = PointsIndex.new(@lab, obj.points)
				nobj.locate(@player.y, @player.x)
				@lab.fill!(nobj)
				@objects.append(nobj)
			end
		end
		# Matschpfützen bremsen
		if obj.player_on[0] == "BRAKE" then
			@player.set_brake!(obj.player_on[1])
#			obj.playsound
		end
		# Tödliche Totenköpfe und Spinnen
		if obj.player_on[0] == "KILL" then		
			@lab.delete(obj.y, obj.x)	
			@player.kill!
			@ticktock.timer_stop
		end
		# Schlittschuhe beschleunigen
		if obj.player_on[0] == "WOOSH" then
			@player.woosh!(obj.player_on[1])
#			obj.playsound
		end
		# Pilze verwandeln sich 
		if obj.player_on[0] ==  "TRANSFORM" then
			load = obj.player_on[2]
			@lab.delete(obj.y, obj.x)
#			obj.playsound
			nobj = obj.player_on[1].new(@lab, load)
			nobj.locate(@player.y, @player.x)
			@lab.fill!(nobj)
			@objects.append(nobj)
		end
	end

	def level_failed?
		return @ticktock.timer == 0	
	end

	def time_left
		return @ticktock.timer
	end

	def all_collected?
		return @lab.count == 0 
	end

	def next_try
		@lab.un_set_special!
		# Holz, an dem gesägt wird, wird zurückgesetzt.
		for obj in @objects do
			obj.reset!
		end
		for obj in @m_objects do
			if rand > 0.5 then 
				obj.relocate!
			else
				remove(obj)
			end
		end
		@ticktock = Clock.new
		@ticktock.timer_set(@offset)
		@player.reset!
		pause!
#		puts "Nächster Versuch!"
	end

	def change_tools
		if @player.lives > 1 then
			@player.toolchange
		end
	end

	def objects
		return @objects
	end

	def m_objects
		return @m_objects
	end

	def start_round
		@lab.un_set_special!
		if @player.changehats? then
			@lab.set_special!
			@player.create!
			@player.collect(Chainsaw.new(@lab))
		end
		@objects = []
		@m_objects = []
		@ticktock = Clock.new
		@ticktock.timer_set(@offset)
		@player.uprank
		@level_passed = false
		@aim1 = false
		@aim2 = false
		@lab.newlab(@player.level)
		@gimmickarray = []
		# Putgimmicks befindet wich in gi_labs
		putgimmicks
		@boxstr = level_start_box

		generate_boxes
		@event = "LEVEL_START"
		pause!
#		puts "Start um #{@ticktock.seconds}"

	end

	def labobjects
		return @labobjects
	end
end

class Game < Gosu::Window	

	def initialize(faktor)
		puts "Neues Spiel."
		@faktor = faktor
		@breite = (1200 * @faktor).to_i
		@hoehe = (850 * @faktor).to_i
    super @breite, @hoehe
    self.caption = "GRAB IT!"
		@pausebox = Gosu::Image.new("media/pausebox.png")
    @hintergrundbild = Gosu::Image.new("media/background.png", :tileable => true)
		@newgame = true
		@lab = Lab.new(@faktor)
		@player = Player.new(@lab)
		@musicplayer = Musicplayer.new(Gosu::Song.new("media/sounds/rhodes.wav"), 4137)
		@handler = GameHandler.new(@player, @musicplayer, @lab, @faktor)
		@info = Info.new(@player, @faktor)
		@ticktock = Clock.new
		@handler.gamestart
		@startzeit = Gosu.milliseconds
  end

	def update
		anf = Gosu.milliseconds - @startzeit
		if !@handler.pause? then
			@musicplayer.update(Gosu.milliseconds)
			@handler.delay(10)
			@handler.update
			if Gosu.button_down? Gosu::KB_P then
				@handler.pause!
			end
		else
			if Gosu.button_down? Gosu::KB_T then
				@handler.change_tools
				@handler.delay(500)
			end
			if Gosu.button_down? Gosu::KB_S then
				@handler.unpause!
				@handler.delay(500)
			elsif Gosu.button_down? Gosu::KB_ESCAPE then
				gameclose
			end
		end
		ende = Gosu.milliseconds - @startzeit
#		puts "Update: #{anf} - #{ende} (#{ende-anf})"
	end

	def gameclose
		self.close
	end

  def draw
		anf = Gosu.milliseconds - @startzeit

		if @handler.pause? then
			@handler.pausebox
		end
		@hintergrundbild.draw(0,0, 0, @faktor, @faktor)

		# Lab wird mit Objekten wird gezeichnet, dann Spielfigur
		for y in 0..@lab.matrix.size-1 do
			for x in 0..@lab.matrix[y].size-1 do
				@lab.matrix[y][x].draw(@faktor)
			end
		end
		@player.draw(@faktor)
		for obj in @handler.objects do 
			obj.draw(@faktor)
		end
		for obj in @handler.m_objects do 
			obj.draw(@faktor)
		end
		@info.write(@handler.time_left, @faktor)
		ende = Gosu.milliseconds - @startzeit
#		puts "Draw: #{anf} - #{ende} (#{ende-anf})"
	end
end

Game.new(1.0).show
