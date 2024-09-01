#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=users -t --no-align -c"

# Randomly generate a number that users have to guess
SECRET_NUMBER=$((RANDOM % 1000 + 1))

# Prompt the user for a username with "Enter your username:" and 'read' it as input. 
echo "Enter your username:"
read USERNAME

RETURNING_USER=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'")

if [[ -z $RETURNING_USER ]]
then
  # If username has not been used, print
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_NEW_PLAYER=$($PSQL "INSERT INTO players(username, games_played) VALUES('$USERNAME', 0)")

else 
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME'")

  # If username has been used before, print "Welcome back, <username>! You have played <games_played> games, and your best game took <best_game> guesses."
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Set number of guesses to 0 for current game
NUMBER_OF_GUESSES=0






# Prompt for a guess
echo "Guess the secret number between 1 and 1000:"


while [[ $GUESS -ne $SECRET_NUMBER ]]
do

  read GUESS

  # If guess is not an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    # continue
  fi


  # Increment number of guesses by 1
  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))


  # When the secret number is guessed, your script should print "You guessed it in <number_of_guesses> tries. The secret number was <secret_number>. Nice job!" and finish running
  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    # Increment number of games played by 1
    UPDATE_GAMES_PLAYED=$($PSQL "UPDATE players SET games_played=games_played+1 WHERE username='$USERNAME'")

    # If this game's number of guesses is lower than player's best game, update best game with new value
    if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
    then
      UPDATE_BEST_GAME=$($PSQL "UPDATE players SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
    fi

    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    exit 0

  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  fi
done
