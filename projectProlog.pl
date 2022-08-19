
:- [codigo_comum].

%===============================================================================
%                       Predicado 3.1.1
%
%     combinacoes_soma(N, Els, Soma, Combs)
%         -Recebe um inteiro, uma lista de inteiros e um inteiro que e a Soma.
%         -Devolve uma lista ordenada cujos os elementos sao as combinacoes N a N.
%===============================================================================

combinacoes_soma(N,Els,Soma,Combs):-
	findall(X,(combinacao(N,Els,X),sumlist(X,Soma)),Combs).

%===============================================================================
%                       Predicado 3.1.2
%
%    permutacoes_soma(N, Els, Soma, Perms)
%         -Recebe um inteiro, uma lista de inteiros e um inteiro que e a Soma.
%         -Devolve uma lista ordenada cujos os elementos sao as permutacoes 
%		   das combinacoes  N a N.
%===============================================================================

permutacoes_soma(N,Els,Soma,Perms):-
	findall(X,(combinacao(N,Els,Perm),permutation(Perm,X),sumlist(X,Soma)),P),
	sort(P,Perms).

%===============================================================================
%                       Predicado 3.1.3
%
%     espaco_fila(Fila, Esp, H_V)
%          -Recebe uma Fila (linha ou coluna do puzzle) e um atomo h ou v, 
%			conforme se trate de uma fila horizontal ou vertical.
%          -Devolve um espaco(Soma,Variaveis).
%===============================================================================

espaco_fila(Fila,Esp,H_V):-
	elimina_0(Fila,Guar),
	proximo(Guar,Guar2,H_V,El),
	espaco_fila_aux(Guar2,Vars,0),
	Esp = espaco(El,Vars).
	
espaco_fila(Fila,Esp,H_V):-
	elimina_0(Fila,Guar),
	proximo(Guar,Guar2,H_V,_),
	espaco_fila(Guar2,Esp,H_V).

%%==============================================================================
%%
%%    elimina_aux(El)
%%		-Recebe uma lista.
%%
%%	  elimina_0(Fila,Guar)
%%	  	-Recebe uma lista. 
%%	  	-Devolve uma lista.
%%
%%==============================================================================
	
elimina_aux(El):- 
	is_list(El),   % verifica se o elemento da lista e uma lista.
	sumlist(El,0). % se for uma lista verifica se a soma dos seus elementos e 0.

elimina_0(Fila,Guar):-
	exclude(elimina_aux,Fila,Guar).% elimina o elemento [0,0] da lista


%%==============================================================================
%%
%%    proximo(Fila, Proximo)
%%    -Recebe uma fila.
%%    -Corta a fila ate depois da proxima lista.   
%%==============================================================================

proximo([H|T], T,H_V,El) :- % caso terminal, se for lista
   is_list(H), % se a cabeca da fila for uma lista, retorna a cauda
   transforma(H,H_V,El),!.
   

proximo([_|T], Acumulador,H_V,El) :-  % caso contrario, se for difente de uma lista
    proximo(T, Acumulador,H_V,El).  % chama-se a si mesma com a cauda da fila

%%==============================================================================
%%
%%    espaco_fila_aux(Fila, Espaco, Contador)
%%    -Recebe uma Fila.
%%    -Vai colocando os espacos e incrementando o contador ate um
%%     dos casos terminais for atingido.
%%==============================================================================

espaco_fila_aux([], [], Num) :- % caso terminal, se a fila estiver vazia
    Num >= 1.  

espaco_fila_aux([H|_], [], Num) :- % caso terminal, se a cabeca da fila for uma lista
    is_list(H), 
    Num >= 1.  

espaco_fila_aux([H|T], [H|T2], Num) :- % caso contrario, insere a cabeca no espaco
    var(H), 
    N is Num + 1, 
    espaco_fila_aux(T, T2, N).

%%==============================================================================
%%
%%    transforma(Fila, H_V, El)
%%    -Recebe uma Fila e um atomo h ou v.
%%    -Devolve o elemento correspondente o caso seja na vertical ou horizontal.
%%==============================================================================

transforma(Fila,H_V,El):- % caso onde seleciono o elemento da linha horizontal
	H_V = h,
	nth1(2,Fila,El).
	

transforma(Fila,H_V,El):- % caso onde seleciono o elemento da linha vertical
	H_V = v,
	nth1(1,Fila,El).
	


%===============================================================================
%                       Predicado 3.1.4
%
%     espacos_fila(H_V,Fila, Espacos)
%     -Recebe uma fila de uma grelha e um atomo h ou v.
%     -Devolve uma lista que contem todos os espacos possiveis , da esquerda 
%      para a direita.
%===============================================================================

espacos_fila(H_V,Fila, Espacos) :-
    bagof(X, espaco_fila(Fila, X,H_V), Espacos),!.

espacos_fila(_,_, []).

%===============================================================================
%                       Predicado 3.1.5
%
%     espacos_puzzle(Puzzle, Espacos)
%     -Recebe um puzzle de um Puzzle.
%     -Devolve a lista de espacos de Puzzle.
%===============================================================================

espacos_puzzle(Puzzle, Espacos) :-
    espacos_linha(Puzzle, Espacos1,h), % determina os espacos disponiveis em linha 
    								   % na horizontal.

    mat_transposta(Puzzle, Puzzle_T), % transpoe o Puzzle, agora as colunas do Puzzle,
                                      % sao as linhas da Puzzle_T.

    espacos_linha(Puzzle_T, Espacos2,v), % determina os espacos disponiveis em linha,
    									 % na vertical.
                                       
    append(Espacos1, Espacos2, Espacos).

%%=========================================================================
%%    espacos_linha(Puzzle, Espacos, H_V)
%%    -Recebe um Puzzle e um atomo h ou v.
%%    -Devolve os espacos disponiveis horizontalmente ou vertcalmente
%%     no Puzzle.
%%=========================================================================


espacos_linha([], [],_).

espacos_linha([H|T], Espacos,H_V) :- % percorre o Puzzle
    espacos_fila(H_V,H, Espaco1),     % usa a funcao espacos_fila para selecionar os espacos
    								  % um por um.
    espacos_linha(T, Espaco2,H_V),   
    append(Espaco1, Espaco2, Espacos). 


%===============================================================================
%                       Predicado 3.1.7
%
%    permutacoes_soma_espacos(Espacos, Perms_soma)
%         -Recebe uma lista de espacos.
%         -Devolve uma lista de listas em que o primeiro elemento e um espaco de
%          de Espacos e o segundo e a lista ordenada de permutacoes cuja a soma 
%          e igual a soma do espaco. 
%          
%===============================================================================

permutacoes_soma_espacos(Espacos, Perms_soma):- 
	permutacoes_soma_espacos_aux(Espacos,Perms_soma,[]).

%%==============================================================================
%%   permutacoes_soma_espacos_aux(Espaco,Permsoma,Acc)
%%    	-Recebe uma lista de espacos. 
%%   	-Devolve uma lista com o espaco e as respetivas permutacoes.  
%%==============================================================================

permutacoes_soma_espacos_aux([],Ac,Ac).

permutacoes_soma_espacos_aux([H|T],Permsoma,Acc):-
	H = espaco(Soma,Vars),         % Define que a cabeca da lista e um espaco.
	length(Vars,L),			% Ve o tamanho da lista das posicoes.
	permutacoes_soma(L,[1,2,3,4,5,6,7,8,9],Soma,Perms), % usa a funcao permutacoes_soma,
									% e consoante o tamanho da lista das posicoes,
									% da lista de inteiros e da Soma dos espaco,
									% da as permutacoes.
	append(Acc,[[H,Perms]],Acc_1),  % acumula as permutacoes ao espaco correspondente.
	permutacoes_soma_espacos_aux(T,Permsoma,Acc_1).


%===============================================================================
%                       Predicado 3.1.11
%
%     numeros_comuns(Lst_Perms, Numeros_comuns)
%     -Recebe uma lista de permutacoes.
%     -Retorna uma lista de pares (pos, numero),
%	   significando que todas as listas de Lst_Perms contem o numero na 
%      posicao pos.
%===============================================================================

numeros_comuns(Lst_Perms, Numeros_comuns):-
    findall((N,E), numeros_comuns_aux(N, E, Lst_Perms), Numeros_comuns).

%%==============================================================================
%%    numeros_comuns_aux(N, E, Perms)
%%    -Predicado auxliar que recebe um N e uma Lista de permutacoes
%%    -Averigua, utilizando E, se o numero na posicao N da permutacao eh e o mesmo que 
%%     nas restantes.
%%==============================================================================

numeros_comuns_aux(_, _, []).

numeros_comuns_aux(N, E, [H|T]):- 
    nth1(N, H, E),   % Ve se o numero na posicao N e o mesmo que nas restantes listas 
    numeros_comuns_aux(N, E, T).

%===============================================================================
%                       Predicado 3.1.12
%
%     atribui_comuns(Perms_Possiveis)
%     -Recebe uma lista de permutacoes possiveis
%     -Atualiza esta lista atribuindo a cada espaco numeros comuns 
%      a todas as permutacoes possiveis para esse espaco.
%===============================================================================

atribui_comuns([]).

atribui_comuns([[Espaco, Permutacoes] | Resto]) :-
  	 numeros_comuns(Permutacoes, Numeros_comuns), % usa a funcao numeros_comuns para, 
  	                                              % obter a posicao e o numero que, 
  	                                              % se repete em todas as permutacoes.
  	 atribui_comuns_aux(Espaco, Numeros_comuns),
  	 atribui_comuns(Resto).

%%==============================================================================
%%    atribui_comuns_aux(Espaco, Numeros_Comum)
%%    -Predicado auxiliar que percorre um espaco e substitui as posicoes por
%%     numeros
%%==============================================================================

atribui_comuns_aux(_, []).

atribui_comuns_aux(Espaco, [(N, E) | T]) :- % substitui o numero que se,
                                            % repete na respetiva posicao.
	nth1(N, Espaco, E),   
	atribui_comuns_aux(Espaco, T).



%===============================================================================
%                       Predicado 3.1.13
%
%     retira_impossiveis(Perms_Possiveis, Novas_Perms_Possiveis)
%     -Recebe uma lista de permutacoes possiveis
%     -Retira as permutacoes impossiveis de Perms_Possiveis.
%===============================================================================

retira_impossiveis([], []).

retira_impossiveis([[Espaco, Perms]|Resto], [[Espaco, Novas_perms]|Resto2]) :-
    retira_impossiveis_aux(Espaco, Perms, Novas_perms),
    Novas_perms \== [],
    retira_impossiveis(Resto, Resto2).

%%==============================================================================
%%    retira_impossiveis_aux(Espaco, Perms, Novas_perms)
%%    -Predicado auxiliar que recebe um espaco e as suas permutacoes possiveis
%%    -Adiciona as permutacoes possiveis ao Novas_perms.
%%==============================================================================

retira_impossiveis_aux(_, [], []).

retira_impossiveis_aux(Espaco, [H|T], [H|T2]) :-
    unifiable(Espaco, H, _), !,      
    retira_impossiveis_aux(Espaco, T, T2).

retira_impossiveis_aux(Espaco, [_|T], Resto) :-
    retira_impossiveis_aux(Espaco, T, Resto).

%===============================================================================
%                       Predicado 3.1.14
%
%    simplifica(Perms_Possiveis, Novas_Perms_Possiveis)
%     -Recebe uma lista de permutacoes possiveis
%     -Repete os predicados "atribui_comuns", "retira_impossiveis" 
%      ate nao haver mais mudancas possiveis
%===============================================================================

simplifica(Perms_Possiveis, Novas_Perms_Possiveis):- % Quando as permutacoes possiveis sao diferentes,
													 % das permutacoes sem as impossiveis.
	atribui_comuns(Perms_Possiveis),   % Ve quais sao os numeros comuns em todas as permutacoes,
	retira_impossiveis(Perms_Possiveis,Perms_Possiveis_novo), % Retira as combinacoes impossiveis, 
	Perms_Possiveis \== Perms_Possiveis_novo,!,   
	simplifica(Perms_Possiveis_novo,Novas_Perms_Possiveis).
	
simplifica(Perms_Possiveis, Novas_Perms_Possiveis):- % Caso contrario.
	atribui_comuns(Perms_Possiveis),
	retira_impossiveis(Perms_Possiveis,Novas_Perms_Possiveis).

%===============================================================================
%                       Predicado 3.2.1
%
%     escolhe_menos_alternativas(Perms_Possiveis, Escolha)
%     -Recebe uma lista de permutacoes possiveis
%     -Retorna  o elemento de Perms_Possiveis escolhido segundo o criterio do
%      enunciado.
%===============================================================================
escolhe_menos_alternativas([P_perm_possivel|R],Escolha):-
    escolhe_menos_alternativas_aux([P_perm_possivel|R],Escolha,P_perm_possivel).

%%==============================================================================
%%    escolhe_menos_alternativas_aux(Perms_Possiveis,Escolha,Temp)
%%    	-Recebe as permutacoes possiveis e o comprimento da lista de permutacoes.
%%    	-Devolve a lista de permutacoes igual ao comprimento.
%%==============================================================================

escolhe_menos_alternativas_aux([],Escolha,Temp):-
    nth1(2,Temp,Perms),
    length(Perms,N),
    N\==1,
    Escolha=Temp.
escolhe_menos_alternativas_aux([P_perm_possivel|R_per_possivel], Escolha,Temp):-
    nth1(2,P_perm_possivel,Perms),
    nth1(2,Temp,Temp_perm),
    length(Perms,N),
    length(Temp_perm,N_temp),   									
    (N==1
        ;		% se N for igual a 1 ou for maior que N_temp escolhe a regra de baixo
    N>=N_temp),!,
    escolhe_menos_alternativas_aux(R_per_possivel,Escolha,Temp).
escolhe_menos_alternativas_aux([P_perm_possivel|R_per_possivel],Escolha,_):-
    escolhe_menos_alternativas_aux(R_per_possivel,Escolha,P_perm_possivel).



%===============================================================================
%                       Predicado 3.2.2
%
%     experimenta_perm(Escolha, Perms_Possiveis,Novas_Perms_Possiveis)
%     	-Recebe uma lista de permutacoes possiveis e uma escolha dessa lista
%     	-Retorna a nova lista de permutacoes possiveis.
%===============================================================================

experimenta_perm([Esp, Lst_Perms], Perms_Possiveis, Novas_Perms_Possiveis) :-
    member(Perm, Lst_Perms),
    nth1(I, Perms_Possiveis, [Esp, Lst_Perms]),
    Esp = Perm,
    Escolha = [Esp, [Perm]],
    experimenta_perm_aux(Escolha, 1, I, Perms_Possiveis, Novas_Perms_Possiveis).

%%==============================================================================
%%    experimenta_perm_aux(Escolha, Perms_Possiveis,Novas_Perms_Possiveis)
%%    	-Recebe um elemento atualizado de permutacoes possiveis e a lista de permutacoes
%%     	 possiveis
%%    	-Retorna a nova lista de permutacoes possiveis atualizada com a nova escolha
%%==============================================================================

experimenta_perm_aux(_, _, _, [], []).

experimenta_perm_aux(Escolha, Cont, I, [_|T], [Escolha|T2]) :- % Quando o contador e igual ao I. 
    Cont == I,
    N is Cont + 1,
    experimenta_perm_aux(Escolha, N, I, T, T2).

experimenta_perm_aux(Escolha, Cont, I, [H|T], [H|T2]) :- % Caso contrario.
    N is Cont + 1,
    experimenta_perm_aux(Escolha, N, I, T, T2).



