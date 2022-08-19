

def eh_coordenada(coord):
    return isinstance(coord, int) and coord >= 0

def cria_posicao(x,y):
    if eh_coordenada(x) and eh_coordenada(y):
        return [x, y]
    else: raise ValueError("cria_posicao: argumentos invalidos")
    
def cria_copia_posicao(pos):
    return cria_posicao(obter_pos_x(pos),obter_pos_y(pos))
    
def obter_pos_x(pos):
    return pos[0]
    
def obter_pos_y(pos):
    return pos[1]
    
def eh_posicao(arg):
    return isinstance(arg, list) and len(arg) == 2 and\
    eh_coordenada(obter_pos_x(arg)) and eh_coordenada(obter_pos_y(arg))
    
def posicoes_iguais(p1, p2):
    return eh_posicao(p1) and eh_posicao(p2) and obter_pos_x(p1) == obter_pos_x(p2) and obter_pos_y(p1) == obter_pos_y(p2)

def posicao_para_str(pos):
    return "(" + str(obter_pos_x(pos)) + "," + str(obter_pos_y(pos)) + ")"
    
def obter_posicoes_adjacentes(pos):
    posAdj = []
    i = 0
    x_init = obter_pos_x(pos)
    y_init = obter_pos_y(pos)
    if eh_coordenada(x_init) and eh_coordenada(y_init-1):
        posAdj += tuple(cria_posicao(x_init,y_init-1)),
    if eh_coordenada(x_init+1) and eh_coordenada(y_init):
        posAdj += tuple(cria_posicao(x_init+1,y_init)),
    if eh_coordenada(x_init) and eh_coordenada(y_init+1):
        posAdj += tuple(cria_posicao(x_init,y_init+1)),
    if eh_coordenada(x_init-1) and eh_coordenada(y_init):
        posAdj += tuple(cria_posicao(x_init-1,y_init)),
        
    return tuple(posAdj)
        
def ordenar_posicoes(posTup):
    return sorted(posTup, key=lambda pos : (obter_pos_y(pos),obter_pos_x(pos)))
    
def cria_animal(s, r, a):
    if isinstance(s, str) and len(s)>0 and isinstance(r,int) and r>0 and isinstance(a,int) and a>=0:
        eh_predador = False
        if a > 0 : eh_predador = True
        return {"especie" : s , "reproducao" : r , "alimentacao" : a , "idade" : 0 , "fome" : 0 , "eh_predador" : eh_predador}
        
    else: raise ValueError("cria_animal: argumentos invalidos")
    
def cria_copia_animal(a):
    animal = cria_animal(obter_especie(a),obter_freq_reproducao(a),obter_freq_alimentacao(a))
    animal["idade"] = obter_idade(a)
    animal["fome"] = obter_fome(a)
    animal["eh_predador"] = obter_tipo(a)
    return animal

def obter_especie(animal):
    return animal["especie"]

def obter_freq_reproducao(animal):
    return animal["reproducao"] 
    
def obter_freq_alimentacao(animal):
    return animal["alimentacao"]
    
def obter_idade(animal):
    return animal["idade"]
    
def obter_fome(animal):
    return animal["fome"] 
    
def obter_tipo(animal):
    return animal["eh_predador"]
    
def aumenta_idade(animal):
    animal["idade"] += 1
    return animal
    
def reset_idade(animal):
    animal["idade"] = 0
    return animal 
    
def aumenta_fome(animal):
    if obter_tipo(animal):
        animal["fome"] += 1
    return animal
    
def reset_fome(animal):
    if obter_tipo(animal):
        animal["fome"] = 0
    return animal
    
def eh_animal(arg):
    keysList = ["especie", "reproducao", "alimentacao", "idade", "fome", "eh_predador"]
    
    if isinstance(arg, dict) and len(arg) == 6:
        for key in arg.keys():
            if key not in keysList:
                return False
        if isinstance(arg["especie"], str) and len(arg["especie"])>0\
        and isinstance(arg["reproducao"],int)and isinstance(arg["alimentacao"],int) and isinstance(arg["idade"],int)\
        and isinstance(arg["fome"],int)and isinstance(arg["eh_predador"],bool) and arg["alimentacao"] >= 0\
        and arg["idade"] >= 0 and arg["fome"] >= 0 and arg["reproducao"] > 0:
            return True
        
def eh_predador(arg):
    return eh_animal(arg) and obter_tipo(arg)
    
def eh_presa(arg):
    return not eh_predador(arg)
    
def animais_iguais(a1,a2):
    return eh_animal(a1) and eh_animal(a2) and obter_especie(a1) == obter_especie(a2)\
    and obter_freq_reproducao(a1) == obter_freq_reproducao(a2)\
    and obter_freq_alimentacao(a1) == obter_freq_alimentacao(a2)\
    and obter_idade(a1) == obter_idade(a2) and obter_fome(a1) == obter_fome(a2)\
    and obter_tipo(a1) == obter_tipo(a2)
    
def animal_para_char(animal):
    especie = obter_especie(animal)[0]
    if obter_tipo(animal):
        return especie.upper()
    else: return especie.lower()
    
def animal_para_str(a):
    if obter_tipo(a):
        fome_str = ";" + str(obter_fome(a)) + "/" + str(obter_freq_alimentacao(a)) + "]"
    else: fome_str = "]"
    return obter_especie(a) + " [" + str(obter_idade(a)) + "/" + str(obter_freq_reproducao(a))\
    + fome_str
    
def eh_animal_fertil(a):
    return obter_idade(a) == obter_freq_reproducao(a)
    
def eh_animal_faminto(a):
    if obter_tipo(a):
        return obter_fome(a) >= obter_freq_alimentacao(a)
    return False
    
def reproduz_animal(a):
    reset_idade(a)
    animal = cria_copia_animal(a)
    reset_idade(animal)
    reset_fome(animal)
    return animal
    
def cria_prado(dim, rochas, animais, pos_ani):
    if eh_posicao(dim):
        if isinstance(rochas, tuple) and len(rochas) >= 0\
        and isinstance(animais, tuple) and isinstance(pos_ani, tuple)\
        and len(animais) == len(pos_ani) > 0:
            for r in rochas:
                if not eh_posicao(r):
                    raise ValueError("cria_prado: argumentos invalidos")
            for a in animais:
                if not eh_animal(a):
                    raise ValueError("cria_prado: argumentos invalidos")
            for p in pos_ani:
                if not eh_posicao(p):
                    raise ValueError("cria_prado: argumentos invalidos")
        return [dim, rochas, animais, pos_ani]
        
def cria_copia_prado(prado):
    return cria_prado()
    
def obter_tamanho_x(prado):
    return obter_pos_x(prado[0]) + 1

def obter_tamanho_y(prado):
    return obter_pos_y(prado[0]) + 1
    
def obter_numero_predadores(prado):
    contador_pred = 0
    for animal in prado[2]:
        if eh_predador(animal):
            contador_pred += 1
    return contador_pred
    
def obter_numero_presas(prado):
    return len(prado[2]) - obter_numero_predadores(prado)
    
def obter_posicao_animais(prado):
    return ordenar_posicoes(prado[3])
    
def obter_animal(prado, pos):
    animal_index = 0
    for posicao in prado[3]:
        if posicao == pos:
            break
        animal_index += 1
    return prado[2][animal_index]
    
def eliminar_animal(prado, pos):
    prado[2].remove(obter_animal(prado, pos))
    prado[3].remove(pos)
    return prado
    
def mover_animal(prado, p1, p2):
    for pos in prado[3]:
        if pos == p1:
            pos = p2
            break
    return prado
    
def inserir_animal(prado, animal, pos):
    prado[2] += animal,
    prado[3] += pos,
    return prado
    
#FAZER OS RECONHECEDORES E OS COMPARADORES
    
def prado_para_str(prado):
    prado_str = ""
    for i in range(obter_tamanho_y(prado)):
        for j in range(obter_tamanho_x(prado)):
            if i == 0 or i == obter_tamanho_y(prado)-1:
                if j == 0 or j == obter_tamanho_x(prado)-1:
                    prado_str += "+"
                else: prado_str += "-"
            elif j == 0 or j == obter_tamanho_x(prado)-1:
                prado_str += "|"
            else:
                if cria_posicao(i,j) in prado[1]:
                    prado_str += "@"
                elif cria_posicao(i,j) in prado[3]:
                    prado_str += animal_para_char(obter_animal(prado, cria_posicao(i,j)))
                else: prado_str += "."
    
    return prado_str

def obter_valor_numerico(prado, pos):
    return obter_pos_y(pos)*obter_tamanho_x(prado) + obter_pos_x(pos)
                
