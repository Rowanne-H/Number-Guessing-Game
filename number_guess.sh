#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

SECRET_NUMBER=$(($RANDOM%1000+1))
echo -e "\nEnter your username:"
read USERNAME
USERNAME_F=$(echo $USERNAME | sed 's/ |/"/')

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
if [[ -z $USER_ID ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
  echo -e "\nWelcome, $USERNAME_F! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name='$USERNAME'")
  GAMES_PLAYED_F=$(echo $GAMES_PLAYED | sed 's/ |/"/')
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name='$USERNAME'")
  BEST_GAME_F=$(echo $BEST_GAME | sed 's/ |/"/')
  echo -e "\nWelcome back, $USERNAME_F! You have played $GAMES_PLAYED_F games, and your best game took $BEST_GAME_F guesses."
fi

UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE user_id=$USER_ID")

echo -e "\nGuess the secret number between 1 and 1000:"
TRIES=1
read GUESS

GUESS() {
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
   echo -e "That is not an integer, guess again:"
   GUESS_AGAIN
  else
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      TRIES=$(($TRIES+1))
      GUESS_AGAIN 
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:" 
      TRIES=$(($TRIES+1)) 
      GUESS_AGAIN
    else
      EXIT
    fi 
  fi 
}

EXIT() {
  if [[ $INSERT_USER_RESULT = 'INSERT 0 1' ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$TRIES")
  fi
  if [[ $TRIES -lt $BEST_GAME ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$TRIES")
  fi
  echo -e "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
}

GUESS_AGAIN() {
  read GUESS
  GUESS
}

GUESS
