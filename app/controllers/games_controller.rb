require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    alphabet = %w[ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ]
    @letters = alphabet.shuffle[0..8]
  end

  def score
    letters = params[:letters]
    user_guess = params[:user_guess]
    real_word = real_word?(user_guess)
    letters_include_word = letters_include_word?(user_guess, letters)

    @result = game_result(real_word, letters_include_word, user_guess, letters)

    score = user_guess.length if real_word && letters_include_word
    @total_score = total_score(score)
  end

  def reset
    session.delete(:score)
    redirect_to '/new'
  end

  def real_word?(guess)
    JSON.parse(URI.open("https://wagon-dictionary.herokuapp.com/#{guess}").read)['found']
  end

  def letters_include_word?(word, letters)
    select_letters = word.chars.select{ |l| letters.chars.include?(l) }
    return true if select_letters.length == word.length
  end

  def game_result(real_word, letters_include_word, user_guess, letters)
    return "CONGRATULATION! #{user_guess} is an english word!" if real_word && letters_include_word
    return "Sorry, but #{user_guess.capitalize} can't be build with #{letters.split('')}" if !letters_include_word
    return "Sorry, but #{user_guess.capitalize} doesn't seem to be an english word" if !real_word
  end

  def total_score(score)
    session[:score].nil? ? session[:score] = score : session[:score] += (score || 0)
  end
end
