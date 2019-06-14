%  File       : proj2.hs
%  Author     : Chuan Yang
%  Purpose    : Declarative Programming Project 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% Define a predicate puzzle_solution/1:
%%	puzzle_solution(Puzzle) 
%%  Puzzle, a square grid of squares, 
%% each to be filled in with a single digit 1-9 
%% (zero is not permitted) satisfying these constraints:
%%     • each row and each column contains no repeated digits;
%%     • all squares on the diagonal line from upper left to lower 
%%       right contain the same value; and
%%     • the heading of reach row and column (leftmost square in a 
%%       row and topmost square in a column) 
%%       holds either the sum or the product of all the digits in 
%%       that row or column
%% 
%% The row and column headings are not considered to be part of the row
%% or column, and so may be filled with a number larger than a single digit.
%% The upper left corner of the puzzle is not meaningful.
%% The goal of the puzzle is to fill in all the squares according to the rules.
%% A proper maths puzzle will have at most one solution.
%%
%%
%% First, check if the puzzle is a square by 
%% maplist(same_length(Puzzle), Puzzle), then, validate all rows and columns 
%% with check_rows/1, check_columns/1 (check columns by checking the rows of 
%% the transposed puzzle discarding the first row), 
%% and all the squares on the diagonal by unify_diagonal/3. 
%% validate the basic constraints of the puzzle when it is given, 
%% then begin to fill the puzzle. 
%% The search space can be enormously constrained by predicates 
%% like sum_List/2 and multiply_list/2.
%% After setting all the  limits, it is very efficient to backtrack 
%% over the possible values for each puzzle square. 
%% Then each empty square in the puzzle is labeled by maplist(label, puzzle).
%% The predicate ground(Puzzle) will return true if the puzzle has been bound 
%% to a valid solution.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


:- ensure_loaded(library(clpfd)).

%% puzzle_solution(Puzzle) 
%% holds when Puzzle is the representation of a solved maths puzzle.
%% The puzzle is a proper list of proper lists, 
%% and all the header squares of the puzzle 
%% (plus the ignored corner square) are bound to integers. 
%% Some of the other squares in the puzzle may also be bound to integers, 
%% but the others will be unbound. 
puzzle_solution(Puzzle) :- 
    maplist(same_length(Puzzle), Puzzle),
    Puzzle = [HeadRow|TailRows],
    unify_diagonal(TailRows, 1, _), 
    check_rows(TailRows), 
    check_columns(Puzzle),
    maplist(label, Puzzle),
    ground(Puzzle).
	
%% unify_diagonal(TailRows, N, Square)
%% Unify all the squares on the diagonal line from upper left to lower right.
%% [L|Ls] is the list of list, Square is used to keep the value and compare
%% N is the index of diagonal square in a given list, it starts from N = 1.
%% all squares on diagnoal (at position Nx) are the same.
unify_diagonal([], _, _).
unify_diagonal([L|Ls], N, Square) :-
    nth0(N, L, Square),
    N1 #= N + 1,
    unify_diagonal(Ls, N1, Square).

%% add(E1, E2, Sum)
%% let Sum be the sum of E1 and E2
add(E1, E2, Sum) :-
    Sum #= E1+E2.

%% sum_List(L, Sum)
%% Sum all elements of a given list
%% foldl/4 is a predicate in A.3 library
%% use foldl to implement sum, by parsing a add function to foldl.
sum_List(L, Sum) :-
    foldl(add, L, 0, Sum).
	
%% multiply(E1, E2, Product)
%% let Product be the product of E1 and E2
multiply(E1, E2, Product) :-
    Product #= E1*E2.
	
%% multiply_list(L, Product)
%% Multiply all elements in the input list,
%% buse foldl to implement sum, by parsing a multiply function to foldl.
multiply_list(L, Product) :- 
    foldl(multiply, L, 1, Product).


	
%% check_row(List)
%% check the list elements within the range of 1 to 9
%% and no repeated elements in the list.
%% Then check if the head element of a given list is equal to the sum or 
%% product of the rest elements. 
check_row([Header|Tail]) :-
    Tail ins 1..9,
    all_distinct(Tail),
    ( sum_List(Tail, Header)
    ; multiply_list(Tail, Header)
    ).



%% check_rows(TailRows)
%% Check if the all rows except first one of the puzzle are valid,
%% with maplist(check_row, TailRows) to validate each row in the tail rows.
check_rows(TailRows) :-
    maplist(check_row, TailRows).


%% check_columns(Puzzle)
%% Transpose the puzzle to make the columns become rows, 
%% so the original columns can be checked 
%% by checking the rows of the new transposed puzzle. 
%% when transposing, ignore the head row of transposed puzzle.
check_columns(Puzzle) :-
    transpose(Puzzle, [_|TailRows]),
    check_rows(TailRows).