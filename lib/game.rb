require 'yaml'

class Game
  attr_reader :hidden_word, :progress
  def initialize
    @hidden_word = select_appropriate_words.shuffle.first
    @progress = Array.new(@hidden_word.length, "_")
    @wrong_guesses = 0
  end
  
  def has_ended?
    if progress.none?{ |char| char == "_"}
      puts "The hidden word was |#{@hidden_word}|! You've won with #{@wrong_guesses} wrong guesses"
      true
    elsif @wrong_guesses == progress.length + 10
      puts "You've lost, the hidden word was |#{@hidden_word}| you've made too many wrong guesses (#{@wrong_guesses})"
      true
    else
      false
    end
  end

  def show_progress
    puts progress.join("")
  end 

  def make_a_guess 
    character = gets.chomp.downcase
    if character.length != 1 || progress.include?(character)
      puts "This character is already taken or isn't even character at all"
      make_a_guess
    elsif hidden_word.downcase.include?(character)
      hidden_word.split("").each_with_index{ |el,idx| progress[idx] = el if el.downcase == character}
    else
      @wrong_guesses += 1
    end
  end

  private

  def select_appropriate_words
    File.open("../dictionary.txt", "r").map{|x| x[0..-2]}.select{|x| x.length > 5 && x.length < 12 }
  end

end

def save_game(game)
  puts "Type in: save, to save your game, otherwise type anything"
  save_status = gets.chomp
  if save_status == 'save'
    save = File.open("../saves/current.yaml", "w")
    save.puts YAML.dump(game)
    save.close
  end
end

def start_game
  if File.empty?("../saves/current.yaml")
    Game.new
  else
    puts "It looks like you got existing save already, would you like to load it? (Y/N)"
    answer = gets.chomp.downcase
    start_game unless answer == "y" || answer == "n"
    answer == "y" ? YAML.load(File.read("../saves/current.yaml")) : Game.new
  end
end

game = start_game

until game.has_ended? do
  game.show_progress
  save_game(game)
  game.make_a_guess
end

