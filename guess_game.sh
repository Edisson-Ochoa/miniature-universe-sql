#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --tuples-only -c"
echo "Enter your username:"
read USERNAME
USER_QUERY=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME'")
if [[ -z $USER_QUERY ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "$USER_QUERY" | while read USER BAR GAMES_PLAYED BAR BEST_GAME
  do
    echo "Welcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi
NUMBER=$(($RANDOM % 1000 + 1))
echo "Guess the secret number between 1 and 1000:"
read GUESS
TRIES=1

while [ $GUESS != $NUMBER ]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS -gt $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
    ((TRIES+=1))
  fi
  read GUESS

done
if [[ $GUESS -eq $NUMBER ]]
then
  echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"
  if [[ -z $USER_QUERY ]]
  then
    INSERT_USER=$($PSQL "INSERT INTO users VALUES ('$USERNAME', 1, $TRIES)")
  else
    UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")
    if [[ $TRIES -lt $BEST_GAME ]]
    then
      UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $TRIES WHERE username = '$USERNAME'")
    fi
  fi
fi