# Definition des Labyrinths.

=begin
		a = []
		a.append ("0000000000000000000000")
		a.append ("0111111111111111111110")
		a.append ("0100000000000000000010")
		a.append ("0101111111111111111010")
		a.append ("0101000000000000001010")
		a.append ("0101011111111111101010")
		a.append ("0101010000000000101010")
		a.append ("0101010111111110101010")
		a.append ("0101010000000000101010")
		a.append ("0101011111111111101010")
		a.append ("0101000000000000001010")
		a.append ("0101111111111111111010")
		a.append ("0100000000000000000010")
		a.append ("0111111111111111111110")
		a.append ("0000000000000000000000")

# ---------------------------------------------------
=end


class Lab
	def initialize(faktor)
		@faktor = faktor		
		@matrix = []
		@field = []
		@level = 0
		@special = false
	end

	def set_special!
		if !@special then
			@special = true
			puts "Lab speziell"
		end
	end

	def un_set_special!
		if @special then
			@special = false
			puts "Lab nicht speziell"
		end
	end

	def special?
		return @special
	end

	def newlab(level)
		@tree1 = Gosu::Image.new("./media/trees/tree0.png")
		@tree2 = Gosu::Image.new("./media/trees/tree1.png")
		@tree3 = Gosu::Image.new("./media/trees/tree2.png")
		@tree4 = Gosu::Image.new("./media/trees/tree3.png")
		@tree5 = Gosu::Image.new("./media/trees/tree4.png")
		@tree6 = Gosu::Image.new("./media/trees/tree5.png")
		@tree7 = Gosu::Image.new("./media/trees/tree6.png")
		@image2 = Gosu::Image.new("./media/gimmicks/pickup.png")
		@level = level
		puts "Generiere Matrix"
		a = []
		a.append ("######################")
		a.append ("#....................#")
		a.append ("#.#########d########x#")
		a.append ("#.#................#.#")
		a.append ("#.#.#.#####c######.#.#")
		a.append ("#.#.#............#.#.#")
		a.append ("#.#.#.#.########.#.#.#")
		a.append ("#.#.#.#........#.#.#.#")
		a.append ("#.#.#.#.######.#.#.#.#")
		a.append ("#.a.#.#........#.#.b.#")
		a.append ("#.#.#.###.######.#.#.#")
		a.append ("#.#.#.#........#.#.#.#")
		a.append ("#.#.#.#######z##.#.#.#")
		a.append ("#.#.#............#.#.#")
		a.append ("#.#.###.##########.#.#")
		a.append ("#.#............#...#.#")
		a.append ("#y##########.#.#.#.#.#")
		a.append ("#............#...#...#")
		a.append ("######################")

		# Mgl. vertikale Spiegelung.
		yrnd = rand * 2
		if yrnd > 1 then
			puts "Typ A"
			a.reverse!
		end
		# Mögliche horiz. Spiegelung.
		xrnd = rand * 2		
		if xrnd > 1 then		
			for i in 0..a.size-1 do
				a[i].reverse!
			end
		end

		# Nun  wird ein neues Array generiert und mit Baum oder Beere gefüllt
		@matrix = []
		@field = []
		for y in 0..a.size-1 do
			#b muss mit Nullen gefüllt werden!
			@matrix.append([Array.new(a[0].size, 0)])
			# Die Stellen # und * bilden Wände
			for x in 0..a[y].size-1 do
				if a[y][x] == "#" then
					obj = Tree.new(self)
				elsif a[y][x] == "x" &&  @level % 2 == 0 then
					obj = Tree.new(self)
				elsif a[y][y] == "y" && @level % 2 == 1 then
					obj = Tree.new(self)
				elsif a[y][x] == "z" && @level > 10 then
					obj = Tree.new(self)
				elsif a[y][x] == "a" && (@level % 3) == 0 then
					obj = Tree.new(self)
				elsif a[y][x] == "b" && (@level % 3) == 1 then
					obj = Tree.new(self)
				elsif a[y][x] == "c" && (@level % 3) == 2 then
					obj = Tree.new(self)
				elsif a[y][x] == "d" && @level > 10 then
					obj = Tree.new(self)
				else 
					obj = Berry.new(self)
					@field.append([y,x])
				end
				@matrix[y][x] = obj
				obj.locate(y,x)
			end
		end
		@matrix[1][1] = Empty.new(self)
		puts "Freie Felder: #{@field.size}"	
	end

	def matrix
		return @matrix
	end

	# Gibt die Gesamtheit der Felder ohne Baum oder Hindernis zurück.
	def field
		return @field
	end

	def level
		return @level
	end

	# Zählt alle mit pickups belegten Felder
	def count
		cnt = 0
		for y in 0..@matrix.size-1 do
			for x in 0..@matrix[y].size-1 do
				if @matrix[y][x].class == Berry then
					cnt +=1
				end
			end
		end
		return cnt
	end

	# Löscht ein Feld, d.h. füllt es mit Empty.
	def delete(y,x)
		@matrix[y][x].remove!
		obj = Empty.new(self)
		obj.locate(y,x)
		@matrix[y][x] = obj
	end

	# Setzt ein Obj auf das Feld.
	def fill! (obj)
#		puts "#{[obj.y,obj.x]}: #{obj.name}"
		@matrix[obj.y][obj.x] = obj		
	end
end


# ----------------------------------Aufgerufen aus gi_main/handler------------------------------
# Gimmicks wie Sägen, Münzn etc werden verteilt.

	def putgimmicks

		#Zum Testen
#		putgimmick(Saw, 3)
		# -----------------------	
		putgimmick(Coin, 1)
		putgimmick(Bigflower,1)
		putgimmick(Flower,4 + @player.level/2)										# 2,4,6,...
		putgimmick(Pit, ((@player.level + 4) / 6).to_i)						# 2, 7, 12, 17
#		putgimmick(Icepit, ((@player.level + 5) / 8).to_i)				# 5, 11, 16, 
		putgimmick(Bomb, ((@player.level + 2) / 8).to_i)								# 6, 14
		putgimmick(Woodpile,  ((@player.level + 4) / 8).to_i)			# 4, 10, 16
		putgimmick(Boris,  (@player.level / 10).to_i)							# 10, 20

		for i in 1..@player.level / 4 do
			j = (@player.level + i - 1) % 3
			if j == 0 then
				putmushroom(Coin)
			elsif j == 1 then
				putmushroom(headpiece)
			elsif j == 2 then
				putmushroom(Saw)
			end 
		end

		for i in 1..@player.level / 5 do
			j = (@player.level + i) % 7
			if j == 0 then
				putmushroom(Berry)
			elsif j == 1 then
				putmushroom(Pit)
			elsif j == 2 then
				putmushroom(Woodpile)
			elsif j == 3 then
				putmushroom(Berry)
			elsif j == 4 then
				putmushroom(Tree)
			elsif j == 5 then
				putmushroom(Bomb)
			elsif j == 6 then
				putmushroom(Berry)
			end 
		end
	end

	def putmushroom(type)
		fieldnr = (1+ rand * (@lab.field.size-1)).to_i
		obj = Mushroom.new(@lab, type)
#		puts "+Erzeuge Pilz mit #{type.name}"
		if !@gimmickarray.include?(fieldnr) then
			x = @lab.field[fieldnr][1]
			y = @lab.field[fieldnr][0]
			obj.locate(y,x)
			@lab.fill!(obj)
#			puts "auf #{y}, #{x}"
			@gimmickarray.append(fieldnr)
		end
	end

	def headpiece
		choice = ""
		rnd = (rand * 5).to_i
		if rnd == 0 then
			choice = Cappy
		elsif rnd == 1 then
			choice = Helmet
		elsif rnd == 2 then
			choice = Helmet
		elsif rnd == 3 then
			choice = Bowler
		elsif rnd == 4 then
			choice = Tricorne
		end
		return choice
	end


	def putgimmick(type, nr)
		distance = (@lab.field.size / (nr + 1)).to_i
		fieldnr = 1 + (rand * (distance-1)).to_i
		for i in 0..nr-1 do
			obj = type.new(@lab)
			fieldnr += distance
			if !@gimmickarray.include?(fieldnr) then
				x = @lab.field[fieldnr][1]
				y = @lab.field[fieldnr][0]
				obj.locate(y,x)
				if obj.class != Boris && obj.class != B2 then
					@lab.fill!(obj)
				else
					@lab.delete(obj.y_, obj.x_)
					@m_objects.append(obj)
				end
				@gimmickarray.append(fieldnr)
			end
		end
	end

