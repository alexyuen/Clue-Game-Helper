% Alex Yuen
% 82562109
% h7p7

% Waley (Walt) Chen
% 86486107
% k5s7

% 1. Start game with predicate: clue. 
% 2. Follow the instructions on screen. Enter card names in lower case, single word: i.e. scarlet, kitchen, etc.
% 3. Once game is setup, you can enter the actions of every player for their turns.
% 4. Only on your own turn can you make a suggestion/add a known card/make an accusation.
% 5. On any turn, you can access information about the game (i.e. your hand, past suggestions, etc.).
% 6. Also, on any turn, you can get a recommended next suggestion to make.

:- dynamic player/1, turn_order/2, num_players/1, your_player/1, current_turn/1, unknown/1, hand/1, suggestion/1, my_suggestion/1, accusation/1.

suspect(scarlet).
suspect(mustard).
suspect(plum).
suspect(green).
suspect(white).
suspect(peacock).

weapon(rope).
weapon(pipe).
weapon(knife).
weapon(wrench).
weapon(candle).
weapon(pistol).

room(kitchen).
room(dining).
room(lounge).
room(hall).
room(study).
room(library).
room(billiard).
room(conservatory).
room(ball).

unknown(suspect(scarlet)).
unknown(suspect(mustard)).
unknown(suspect(plum)).
unknown(suspect(green)).
unknown(suspect(white)).
unknown(suspect(peacock)).
unknown(weapon(rope)).
unknown(weapon(pipe)).
unknown(weapon(knife)).
unknown(weapon(wrench)).
unknown(weapon(candle)).
unknown(weapon(pistol)).
unknown(room(kitchen)).
unknown(room(dining)).
unknown(room(lounge)).
unknown(room(hall)).
unknown(room(study)).
unknown(room(library)).
unknown(room(billiard)).
unknown(room(conservatory)).
unknown(room(ball)).

% is_known(X) :- not(unknown(suspect(X))),not(unknown(weapon(X))),not(unknown(room(X))).
add_to_known_np(X) :- unknown(suspect(X)), !, retract(unknown(suspect(X))).
add_to_known_np(X) :- unknown(weapon(X)), !, retract(unknown(weapon(X))).
add_to_known_np(X) :- unknown(room(X)), !, retract(unknown(room(X))).
add_to_known_np(_) :- !.

add_to_known(X) :- unknown(suspect(X)), !, retract(unknown(suspect(X))).
add_to_known(X) :- unknown(weapon(X)), !, retract(unknown(weapon(X))).
add_to_known(X) :- unknown(room(X)), !, retract(unknown(room(X))).
add_to_known(X) :-
  valid_card(X), !,
  writeln('Card has already been entered. Input any of: '),
  already_known.
add_to_known(X) :-
  not(valid_card(X)), !,
  writeln('Invalid card specified. Input any of: '),
  already_known.

add_to_hand(X) :- unknown(suspect(X)), !, retract(unknown(suspect(X))), assertz(hand(suspect(X))).
add_to_hand(X) :- unknown(weapon(X)), !, retract(unknown(weapon(X))), assertz(hand(weapon(X))).
add_to_hand(X) :- unknown(room(X)), !, retract(unknown(room(X))),  assertz(hand(room(X))).
add_to_hand(X) :-
  valid_card(X), !,
  writeln('Card has already been entered. Input any of: '),
  already_known.
add_to_hand(X) :-
  not(valid_card(X)), !,
  writeln('Invalid card specified. Input any of: '),
  already_known.

already_known :-
	setof(X, unknown(room(X)), Rooms),
	write(' - Rooms: '),
	writeln(Rooms),
	
	setof(X, unknown(suspect(X)), Suspects),
	write(' - Suspects: '),
	writeln(Suspects),

	setof(X, unknown(weapon(X)), Weapons),
	write(' - Weapons: '),
	writeln(Weapons).

valid(Room,Suspect,Weapon) :- suspect(Suspect), weapon(Weapon), room(Room).
valid_card(Card) :- suspect(Card), !.
valid_card(Card) :- weapon(Card), !.
valid_card(Card) :- room(Card), !.

suspect_option(none) :- !.
suspect_option(Card) :- suspect(Card).
card_option(none) :- !.
card_option(Card) :- valid_card(Card).

clue :- 
	writeln('Welcome to the Clue Solver!'),
	clue_setup_players,
  clue_setup_hand,
  cls,
	clue_game.
  
clue_setup_players :-
  % input all the players
  writeln('\nHow many players are playing?'),
	read(N),
	assertz(num_players(N)),
	clue_turn_order(N),
  % set scarlet to be first to start
	asserta(current_turn(player(scarlet))),
  cls,
  % input player character
  setof(X,player(X),Players),
  write('\nWhich suspect are you playing as? Choose one of: '),
  writeln(Players),
  read(Name),
  asserta(your_player(player(Name))).

clue_setup_hand :-
  writeln('Please input a card in your hand, or enter x. when finished'),
  read(Card),
  clue_add_card(Card).

clue_add_card(x) :- !.
clue_add_card(Card) :-
  add_to_hand(Card),
  clue_setup_hand.

clue_turn_order(0).
clue_turn_order(X) :-
	num_players(Z),
	N is Z - X + 1,
	write('Who goes #'),
	write(N),
	writeln('?'),
	read(Player),
	assertz(player(Player)),
  Y is N - 1,
  assertz(turn_order(player(Player),Y)),
	A is X - 1,
	clue_turn_order(A).

clue_next_turn(Next) :- 
	current_turn(C),
  turn_order(C, X),
	num_players(Z),
  Y is X + 1,
  A is Y mod Z,
	turn_order(Next, A).
  
clue_advance_turn :-
	clue_next_turn(Next),
  retract(current_turn(X)),
  asserta(current_turn(Next)).

same_player(player(X),player(X)).

player_name(player(X), X).

turn_info :-
  your_player(player(You)),
  current_turn(player(Current)),
  clue_next_turn(player(Next)),
  write('You are: '),
  writeln(You),
  write('Current Turn: '),
  writeln(Current),
  write('Next Turn: '),
  writeln(Next),
  write('\n').
  
clue_game :- 
  header,
  do_input,
	clue_game.

header :-
  cls,
  turn_info,
  options.

options :-
  current_turn(C),
  your_player(P),
  same_player(C,P), !,
  writeln('Check Information'),
  writeln('1. Cards in your hand'),
  writeln('2. Unknown Cards'),
  writeln('3. All Past Suggestions'),
	writeln('4. All Past Accusations'),
  writeln('5. Players'),
  writeln('6. Recommended Suggestion\n'),
  
  writeln('Your Actions'),
  writeln('a. Make Accusation'),
  writeln('k. Add Known Card'),
	writeln('s. Make Suggestion'),
	writeln('x. End Turn\n').

options :-
  current_turn(C),
  your_player(P),
  not(same_player(C,P)), !,
  writeln('Check Information'),
  writeln('1. Cards in your hand'),
  writeln('2. Unknown Cards'),
  writeln('3. All Past Suggestions'),
	writeln('4. All Past Accusations'),
  writeln('5. Players'),
  writeln('6. Recommended Suggestion\n'),
  
  writeln('Opponent Actions'),
  writeln('a. Make Accusation'),
	writeln('s. Make Suggestion'),
	writeln('x. End Turn\n').

do_input :-
  current_turn(C),
  your_player(P),
  same_player(C,P), !,
  
  read(X),
  input_player(X).

do_input :-
  current_turn(C),
  your_player(P),
  not(same_player(C,P)), !,
  
  read(X),
  input_opponent(X).

input_player(1) :- show_hand.
input_player(2) :- show_unknown.
input_player(3) :- show_suggestions.
input_player(4) :- show_accusations.
input_player(5) :- show_players.
input_player(6) :- hint.

input_player(a) :- make_accusation.
input_player(k) :- add_known.
input_player(s) :- make_suggestion_player.
input_player(x) :- clue_advance_turn.
input_player(_) :- do_input.

input_opponent(1) :- show_hand.
input_opponent(2) :- show_unknown.
input_opponent(3) :- show_suggestions.
input_opponent(4) :- show_accusations.
input_opponent(5) :- show_players.
input_opponent(6) :- hint.

input_opponent(a) :- make_accusation.
input_opponent(s) :- make_suggestion_opponent.
input_opponent(x) :- clue_advance_turn.
input_opponent(_) :- do_input.

valid_unknown(Room,Suspect,Weapon) :- unknown(suspect(Suspect)), unknown(weapon(Weapon)), unknown(room(Room)).

hint :-
	valid_unknown(Room, Suspect, Weapon),
	write('Room: '),
	write_ln(Room),
	write('Suspect: '),
	write_ln(Suspect),
	write('Weapon: '),
	write_ln(Weapon),
  writeln(''),
  do_input.

print_cards([]).
print_cards([H|T]) :- print_card(H), print_cards(T).

print_card(suspect(X)) :- writeln(X).
print_card(weapon(X)) :- writeln(X).
print_card(room(X)) :- writeln(X).
print_card(_) :- writeln('Invalid Card').

show_hand :-
  setof(X, hand(X), Cards),
  print_cards(Cards),
  writeln(''),
  do_input.

show_unknown :-
  setof(X, unknown(X), Cards),
  print_cards(Cards),
  writeln(''),
  do_input.

print_players([]).
print_players([H|T]) :- writeln(H), print_players(T).

show_players :-
  setof(X, player(X), Players),
  print_players(Players),
  writeln(''),
  do_input.  

print_my_suggestions([]).
print_my_suggestions([H|T]) :- print_my_suggestion(H), print_my_suggestions(T).

print_my_suggestion(X) :-
  X = [Player1, Player2, Card, Room, Suspect, Weapon],
  write('Player '),
  write(Player1),
  write(' suggests that '),
  write(Suspect),
	write(' committed the murder '),
	write(Room),
	write(' with a '),
	writeln(Weapon),
  proof_player(Player2,Card),
  writeln('').

print_suggestions([]).
print_suggestions([H|T]) :- print_suggestion(H), print_suggestions(T).

print_suggestion(X) :-
  X = [Player1, Player2, Room, Suspect, Weapon],
  write('Player '),
  write(Player1),
  write(' suggests that '),
  write(Suspect),
	write(' committed the murder '),
	write(Room),
	write(' with a '),
	writeln(Weapon),
  proof_opponent(Player2),
  writeln('').

show_suggestions :-
  setof(X, my_suggestion(X), MySuggestions),
  print_my_suggestions(MySuggestions),
  setof(Y, suggestion(Y), Suggestions),
  print_suggestions(Suggestions),
  do_input.

print_accusations([]).
print_accusations([H|T]) :- print_accusation(H), print_accusations(T).

print_accusation(X) :-
  X = [Player, Room, Suspect, Weapon],
  write('Player '),
  write(Player),
  write(' accuses '),
  write(Suspect),
	write(' of murder in '),
	write(Room),
	write(' with a '),
	writeln(Weapon).

show_accusations :-
  setof(X, accusation(X), Accusations),
  print_accusations(Accusations),
  do_input.

add_known :-
  write('Please enter a card that you are sure is known:'),
  read(Card),
  add_to_known(Card).

make_accusation :-
  current_turn(C),
  current_turn(player(Current)),
  write('Player '),
  write(Current),
  writeln(' makes an accusation:'),
  
	setof(X, room(X), Rooms),
	write(' - Which room? '),
	writeln(Rooms),
	read(Room),
	
	setof(X, suspect(X), Suspects),
	write(' - Who did it? '),
	writeln(Suspects),
	read(Suspect),

	setof(X, weapon(X), Weapons),
	write(' - Which weapon? '),
	writeln(Weapons),
	read(Weapon),
  
	valid(Room, Suspect, Weapon),
	assertz(accusation([C, Room, Suspect, Weapon])),
  
  write('Player '),
  write(Current),
  write(' accuses '),
  write(Suspect),
	write(' of murder in '),
	write(Room),
	write(' with a '),
	writeln(Weapon).

make_suggestion_player :-  
  current_turn(C),
  current_turn(player(Current)),
  write('Player '),
  write(Current),
  writeln(' makes a suggestion:'),
  
	setof(X, room(X), Rooms),
	write(' - Which room? '),
	writeln(Rooms),
	read(Room),
	
	setof(X, suspect(X), Suspects),
	write(' - Who did it? '),
	writeln(Suspects),
	read(Suspect),

	setof(X, weapon(X), Weapons),
	write(' - Which weapon? '),
	writeln(Weapons),
	read(Weapon),
  
  setof(X, player(X), Players),
	write('\nPlayer that showed a card? Enter none if nobody showed a card.'),
	writeln(Players),
	read(Player2),
  
  setof(X, valid_card(X), Cards),
  write('\nWhat card? Enter none. if nobody showed a card.'),
	writeln(Cards),
	read(Card),
  
	valid(Room, Suspect, Weapon),
  suspect_option(Player2),
  card_option(Card),
	assertz(my_suggestion([C, Player2, Card, Room, Suspect, Weapon])),
  
  write('Player '),
  write(Current),
  write(' suggests that '),
  write(Suspect),
	write(' committed the murder '),
	write(Room),
	write(' with a '),
	writeln(Weapon),
  proof_player(Player2,Card).

proof_player(Player2,Card) :-
  not(valid_card(Card)), !,
  writeln('Nobody showed me a card.').
  
proof_player(Player2,Card) :-
  valid_card(Card), !,
  add_to_known_np(Card),
  write('\nPlayer '),
  write(Player2),
  write(' proved it otherwise by showing me a '),
  write(card),
  writeln('.').

make_suggestion_opponent :-
  current_turn(C),
  current_turn(player(Current)),
  write('Player '),
  write(Current),
  writeln(' makes an suggestion:'),
  
	setof(X, room(X), Rooms),
	write(' - Which room? '),
	writeln(Rooms),
	read(Room),
	
	setof(X, suspect(X), Suspects),
	write(' - Who did it? '),
	writeln(Suspects),
	read(Suspect),

	setof(X, weapon(X), Weapons),
	write(' - Which weapon? '),
	writeln(Weapons),
	read(Weapon),
  
  setof(X, player(X), Players),
	write('\nPlayer that showed a card? Enter none if nobody showed a card.'),
	writeln(Players),
	read(Player2),
  
	valid(Room, Suspect, Weapon),
  suspect_option(Player2),
	assertz(suggestion([C, Player2, Room, Suspect, Weapon])),
  
  write('Player '),
  write(Current),
  write(' suggests that '),
  write(Suspect),
	write(' committed the murder '),
	write(Room),
	write(' with a '),
	writeln(Weapon),
  proof_opponent(Player2).

proof_opponent(Player2) :-
  not(valid_card(Player2)), !,
  writeln('Nobody showed a card.').
  
proof_opponent(Player2) :-
  valid_card(Player2), !,
  write('\nPlayer '),
  write(Player2),
  writeln(' proved it otherwise.').

% moves a clause to the top
movetotop(X) :-
	room(X) -> retract(room(X)), asserta(room(X)); true,
	suspect(X) -> retract(suspect(X)), asserta(suspect(X)); true,
	weapon(X) -> retract(weapon(X)), asserta(weapon(X)); true.

cls :- write('\e[2J').
