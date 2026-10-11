:- use_module(library(random)).

:- dynamic testList/2.

% randomList(N, List) relates N to a list of N random integers in [0, 1000).
randomList(0, []).
randomList(N, [X|T]) :-
    N > 0,
    random(0, 1000, X),
    N1 is N - 1,
    randomList(N1, T).

% Generate and store the assignment's 50 test cases with IDs for retrieval.
% Lengths range from 5 to 500 and include values around typical thresholds.
storeTestLists :-
    retractall(testList(_, _)),
    testLengths(Lengths),
    storeTestLists_(Lengths, 1).

testLengths([5, 8, 12, 16, 20, 24, 28, 32, 36, 40,
             44, 48, 52, 56, 60, 64, 68, 72, 76, 80,
             84, 88, 92, 96, 100, 110, 120, 130, 140, 150,
             160, 170, 180, 190, 200, 220, 240, 260, 280, 300,
             320, 340, 360, 380, 400, 420, 440, 460, 480, 500]).

storeTestLists_([], _).
storeTestLists_([N|Ns], Id) :-
    randomList(N, List),
    assertz(testList(Id, List)),
    Id1 is Id + 1,
    storeTestLists_(Ns, Id1).

/* Swap the first two elements if they are out of order. */
swap([X, Y|T], [Y, X|T]) :-
    Y < X.
/* Otherwise, look for a swap in the tail. */
swap([H|T], [H|T1]) :-
    swap(T, T1).

% Repeatedly swaps adjacent inversions until no swap remains.
bubbleSort(L, SL) :-
    swap(L, L1),              % at least one swap is needed
    !,
    bubbleSort(L1, SL).
bubbleSort(L, L).             % no swap possible: the list is sorted

% ordered(List) holds when adjacent elements are nondecreasing throughout List.
ordered([]).
ordered([_X]).
ordered([H1, H2|T]) :-
    H1 =< H2,
    ordered([H2|T]).

% insert(E, Sorted, Result) inserts E into an ordered list, preserving order.
% An empty sorted list receives E as its only element.
insert(X, [], [X]).
% If E belongs before H, place it here; the cut commits to that position.
insert(E, [H|T], [E, H|T]) :-
    E =< H,
    !.
% Otherwise H precedes E, so retain H and continue in the tail.
insert(E, [H|T], [H|T1]) :-
    insert(E, T, T1).

% insertionSort recursively sorts the tail, then inserts its head.
insertionSort([], []).
insertionSort([H|T], SORTED) :-
    insertionSort(T, T1),
    insert(H, T1, SORTED).

% mergeSort sorts two halves recursively and merges their ordered results.
mergeSort([], []).             % the empty list is sorted
mergeSort([X], [X]) :- !.
mergeSort(L, SL) :-
    split_in_half(L, L1, L2),
    mergeSort(L1, S1),
    mergeSort(L2, S2),
    merge(S1, S2, SL).

% intDiv(N, D, Q) relates integers N and D to their integer quotient Q.
intDiv(N, N1, R) :- R is div(N, N1).

% split_in_half(List, Left, Right) divides List into halves differing by at most one.
split_in_half([], _, _) :- !, fail.
split_in_half([X], [], [X]).
split_in_half(L, L1, L2) :-
    length(L, N),
    intDiv(N, 2, N1),
    length(L1, N1),
    append(L1, L2, L).

% merge(A, B, M) merges two ordered lists into one ordered list.
% If either input is empty, the other list is the complete result.
merge([], L, L).
merge(L, [], L).
% When H1 is no greater than H2, emit H1 and continue with the first tail.
merge([H1|T1], [H2|T2], [H1|T]) :-
    H1 =< H2,
    merge(T1, [H2|T2], T).
% Otherwise emit H2 and continue with the second tail.
merge([H1|T1], [H2|T2], [H2|T]) :-
    H2 < H1,
    merge([H1|T1], T2, T).

% split(Pivot, List, Small, Big) partitions values around Pivot.
split(_, [], [], []).
split(X, [H|T], [H|SMALL], BIG) :-
    H =< X,
    split(X, T, SMALL, BIG).
split(X, [H|T], SMALL, [H|BIG]) :-
    X < H,
    split(X, T, SMALL, BIG).

% quickSort partitions around the head, sorts both partitions, then joins them.
quickSort([], []).
quickSort([H|T], LS) :-
    split(H, T, SMALL, BIG),
    quickSort(SMALL, S),
    quickSort(BIG, B),
    append(S, [H|B], LS).

% hybridSort uses SMALLALG below THRESHOLD and one BIGALG divide/combine step
% otherwise, routing each recursive subproblem back through hybridSort.
hybridSort(LIST, SMALLALG, _BIGALG, THRESHOLD, SLIST) :-
    integer(THRESHOLD), THRESHOLD > 0,
    length(LIST, N), N < THRESHOLD,
    call(SMALLALG, LIST, SLIST).
hybridSort(LIST, SMALLALG, BIGALG, THRESHOLD, SLIST) :-
    integer(THRESHOLD), THRESHOLD > 0,
    length(LIST, N), N >= THRESHOLD,
    hybridBig(BIGALG, LIST, SMALLALG, THRESHOLD, SLIST).

% Merge-style hybrid step: sort both halves recursively, then merge them.
hybridBig(mergeSort, LIST, SMALLALG, THRESHOLD, SLIST) :-
    split_in_half(LIST, L1, L2),
    hybridSort(L1, SMALLALG, mergeSort, THRESHOLD, S1),
    hybridSort(L2, SMALLALG, mergeSort, THRESHOLD, S2),
    merge(S1, S2, SLIST).
% Quick-style hybrid step: partition around the head and join sorted parts.
hybridBig(quickSort, [H|T], SMALLALG, THRESHOLD, SLIST) :-
    split(H, T, SMALL, BIG),
    hybridSort(SMALL, SMALLALG, quickSort, THRESHOLD, S),
    hybridSort(BIG, SMALLALG, quickSort, THRESHOLD, B),
    append(S, [H|B], SLIST).

