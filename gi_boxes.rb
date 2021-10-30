# Hier sind die Textboxen definiert.
# Der text wird in gi_main ausgegeben.

class BoxObj
	def initialize(image, text, faktor)
		@image = image
		@text = text
		@font = Gosu::Font.new(12,name:'./media/PressStart2P-Regular.ttf')
		@faktor = faktor
	end

	def draw(line)
		@image.draw(250*@faktor, (150 + 40 * line)* @faktor, 9, 1,1)
		@font.draw_text(@text, 300*@faktor, ((150 + 40 * line) + 20) * @faktor, 9, 1.0, 1.0, Gosu::Color::BLACK)
#		puts @text
	end
end

def generate_boxes
	@berrybox = BoxObj.new(Gosu::Image.new("media/gimmicks/pickup.png"), "(auto) Sammle #{@lab.count} Beere(n).", @faktor)
	@flowerbox = BoxObj.new(Gosu::Image.new("media/gimmicks/flower_2.png"), "(auto) - Sammle Blumen für deine Liebste.", @faktor)
	@sawbox = BoxObj.new(Gosu::Image.new("media/gimmicks/saege.png"), "R - Entferne Hindernisse.", @faktor)
	@lifebox = BoxObj.new(Gosu::Image.new("media/moving_objects/playerE.png"), "T - Tausche 1 Leben gegen 1 Säge.", @faktor)	
	@coinbox = BoxObj.new(Gosu::Image.new("media/gimmicks/coin.png"), "(auto) - Tausche #{@player.coincount} Münzen gegen 1 Leben.", @faktor)	
	@coinbox2 = BoxObj.new(Gosu::Image.new("media/gimmicks/coin.png"), "#{@player.coincount} Münzen gegen 1 Leben getauscht.", @faktor)
	@bonusbox = BoxObj.new(Gosu::Image.new("media/empty.png"), "1 Bonus-Leben bei #{@player.bonuslevel * BONUSSTAGE} Punkten.", @faktor)
	@levelbox = BoxObj.new(Gosu::Image.new("media/empty.png"), "LEVEL #{@player.level}: Bonus-Leben bei #{@player.bonuslevel * BONUSSTAGE} Punkten.", @faktor)
	@playbox = BoxObj.new(Gosu::Image.new("media/empty.png"), "S - Start/ Weiter", @faktor)
	@playbox2 = BoxObj.new(Gosu::Image.new("media/empty.png"), "P - Pause", @faktor)
	@playbox3 = BoxObj.new(Gosu::Image.new("media/empty.png"), "ESC - Spiel beenden", @faktor)
	@levelpassedbox = BoxObj.new(Gosu::Image.new("media/win.png"), "LEVEL #{@player.level} abgeschlossen.", @faktor)
	@levelfailbox = BoxObj.new(Gosu::Image.new("media/lose.png"), "LEVEL #{@player.level} nicht abgeschlossen.", @faktor)
	@deathbox = BoxObj.new(Gosu::Image.new("media/gimmicks/skull.png"), "Du hast 1 Leben verloren.", @faktor)
	@goodbyebox = BoxObj.new(Gosu::Image.new("media/gimmicks/skull.png"), "Du bist endgültig gestorben.", @faktor)
	@mushroombox = BoxObj.new(Gosu::Image.new("media/gimmicks/mushroom.png"), "Überraschung!", @faktor)
	@hatbox = BoxObj.new(Gosu::Image.new("media/gimmicks/bowler.png"), "3 verschiedene Hüte: Bonusrunde", @faktor)
end


def level_start_box
	event = "LEVEL_START"
	return event
	pausestr = ""
	pausestr += "LEVEL #{@player.level}"
	pausestr += ":\nNoch #{@lab.count} Grabs in "
	if @ticktock.time_left == nil then 
		pausestr += "#{@offset}"
	else
		pausestr += "#{@ticktock.timer}"
	end
	pausestr += " s zu erledigen.\n\n"
	pausestr += "Sammle alle Beeren.\n\n"
	pausestr += "Sammle Münzen und tausche sie gegen Leben.\n\n"
	pausestr += "Sammle Blüten, um Punkte zu bekommen.\n\n"
	pausestr += "Vorsicht vor Matschpfützen und Totenköpfen!\n\n"
	pausestr += "Pilze bergen Überraschungen!\n\n"
	pausestr += "Entferne Hindernisse mit Sägen. (Befehl: R).\n\n"
	pausestr += "Tausche notfalls 1 Leben gegen 1 Säge.\n\n"
	pausestr += "Starte/ weiter mit S\n"
	pausestr += "Pause mit P\n"
	pausestr += "Abbruch mit ESC\n\n"
	return pausestr
end

def level_fail_box
	event = "LEVEL_FAILED"
	return event
	pausestr = ""
	pausestr += "LEVEL #{@player.level} nicht abgeschlossen. "
	pausestr += ":\nNoch #{@lab.count} Grabs übrig.\n\n"
	pausestr += (@player.change! + "\n")
	pausestr += "Nächster Versuch mit S\n"
	pausestr += "Pause mit P\n"
	pausestr += "Abbruch mit ESC\n\n"
	return pausestr
end

def level_finish_box
	event = "LEVEL_PASSED"	
	return event	
	pausestr = ""
	pausestr += "LEVEL #{@player.level} erfolgreich abgeschlossen.\n\n"
	pausestr += (@player.change! + "\n")
#		if @player.change! then
#			pausestr += "Tausche #{@player.coincount} Coins \ngegen 1 Leben.\n"
#		end
	pausestr += "Starte/ weiter mit S\n"
	pausestr += "Pause mit P\n"
	pausestr += "Abbruch mit ESC\n\n"
	return pausestr
end

def game_finish_box
	event = "GAME_FINISHED"
	return event
	pausestr = ""
	pausestr += "Schade, das war's. \n\nDu hast #{@player.score} Punkte erreicht.\n"
	pausestr += "Beenden mit ESC\n\n"
	return pausestr
end

