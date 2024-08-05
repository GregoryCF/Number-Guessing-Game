#!/bin/bash
RANDOM_NUMBER=$((1 + RANDOM % 1000))
NUMBER_OF_GUESSES=0
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN_MENU () {
  echo Enter your username:
  read USERNAME
  USER=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")
  if [[ -z $USER ]]
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    ADDED_USER_OUTPUT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  else
    IFS=$'|' read -r GAMES_PLAYED BEST_GAME <<< $USER
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
  echo -e "\nGuess the secret number between 1 and 1000:"
  PLAY
}

PLAY () {
  read GUESSED_NUMBER
  if [[ "$GUESSED_NUMBER" =~ ^[0-9]+$ ]]
  then
    ((NUMBER_OF_GUESSES++))
    if [[ $GUESSED_NUMBER -gt $RANDOM_NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
      PLAY
    elif [[ $GUESSED_NUMBER -lt $RANDOM_NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      PLAY
    else
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
      UPDATED_GAMES_OUTPUT=$($PSQL "UPDATE users SET games_played=games_played + 1 WHERE username='$USERNAME';")
      BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")
      if [ -z $BEST_GAME ] || [ $NUMBER_OF_GUESSES -lt $BEST_GAME ]
      then
        UPDATED_BEST_OUTPUT=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME';")
      fi
    fi
  else
    echo -e "\nThat is not an integer, guess again:"
    PLAY
  fi
}

MAIN_MENU
