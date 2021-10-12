; Programa MAC que recibe letras del usuario y simula como van cayendo en la pantalla.
; Fue creado para ejecutarse sin la necesidad de un sistema operativo, en la arquitectura de computadores x86.
; Funcional en TASM 3.2 y en TLink 5.1
; Autor: Walter Morales Vásquez

_MAC SEGMENT PUBLIC USE16		; Se declara el segmento del programa
assume CS:_MAC, DS:_MAC			; Se definen los valores de algunos registros a utilizar
org 0					; Se define el origen del programa

; Punto inicial del programa
Entry:					; Ref: https://github.com/vmt/attic/tree/master/helloboot
	db 0EAh				; Se utiliza la instrucción para realizar un salto largo en TASM.
	dw OFFSET AfterData, 7E0h	; Se define el "offset" y el "segment" a saltar
					; Todo esto es equivalente a "jmp far SEG:OFS" en otros ensambladores.
					; Al inicio estamos en 0:7E00
					; Después del salto estamos en 07E0:0

AfterData:

	cli                       	; Se desactivan las interrupciones
	mov     ax, 07E0h		; Se configuran los registros para que apunten a nuestro
	mov     ds, ax			; Se actualiza a DS para que sea 7E0h en lugar de 0
	mov     es, ax

	add ax, 800h			; Se define el rango de la pila a utilizar
	mov ss, ax			; Base de la pila
	mov sp, 0FFFFh			; Altura de la pila
	sti                       	; Se restauran las interrupciones

	CALL FALLING_CODE		; Se llama a la función que se encarga de llamar a las demás
	JMP SALIR			; Se salta al final del código

; Procedimiento para obtener un número al azar entre 0 y la cantidad de columnas.
; Ref: http://stackoverflow.com/questions/17855817/generating-a-random-number-within-range-of-0-9-in-x86-8086-assembly
COLUMNA_RANDOM PROC NEAR

	XOR AX, AX
	MOV AH,00h		; Obtener el tiempo del sistema   
	INT 1AH			; Se almacena en CX:DX

	MOV AL, DL		; Se pasa una parte del valor resultante a AL
	ADD AL, NUMRANDOM	; Se agrega el random anterior
	MOV CL, CANTCOLUMNAS	
	DIV CL			; Se divide por la cantidad de columnas
	MOV NUMRANDOM, AH	; Se guarda el módulo del resultado en NUMRANDOM

RET
COLUMNA_RANDOM ENDP

; Tiempo de espera en el programa.
; Ref: https://stackoverflow.com/questions/34089884/problems-with-bios-delay-function-int-15h-ah-86h
DELAY PROC NEAR

	MOV AL, 0
	MOV AH, 86h
	XOR CH, ch
	MOV CL, 2		; Cantidad grande de delay
	MOV DX, 2		; Cantidad pequeña de delay
	INT 15h

RET
DELAY ENDP

; Función para insertar en la columna correspondiente al número actual almacenado.
; el valor que recien a dado el usuario.
INSERTAR_CARACTER PROC NEAR

	XOR BX, BX
	MOV BL, NUMRANDOM
	MOV CL, CARACTERACTUAL
	MOV MATRIZ+BX, CL		; Se inserta en la posición que resultó del azar

RET
INSERTAR_CARACTER ENDP

; Función para mover todas las filas por un valor.
MOVER_FILA PROC NEAR
	
	XOR CX, CX
	MOV CL, CANTCOLUMNAS

	MOV BX, MAXCELDA		; Se van a recorrer todas las celdas
	DEC BX

	PRIMER_CICLO:			; Se elimina del todo la última fila

		MOV MATRIZ+BX, 20h
		DEC BX
	
		LOOP PRIMER_CICLO

	CICLO_MOVER:	

		CMP MATRIZ+BX, 20h	; Se va comprobando si el caracter es un espacio o no
		JE SEGUIR_CICLO
		
		MOV CL, MATRIZ+BX	; Se guarda el caracter
		XOR DX, DX
		MOV DL, CANTCOLUMNAS	
		ADD BX, DX		; Se le aumenta a BX la cantidad de columnas
		MOV MATRIZ+BX, CL	; Se escribe el caracter
		SUB BX, DX		; Se le disminuye a BX la cantidad de columnas

		MOV MATRIZ+BX, 20h

		SEGUIR_CICLO:

		DEC BX

		OR BX, BX
		JNZ CICLO_MOVER		; Si no se ha llegado al final se hace de nuevo

	MOV CL, MATRIZ+BX		; Caso de cuando la celda es 0
	XOR DX, DX
	MOV DL, CANTCOLUMNAS
	ADD BX, DX
	MOV MATRIZ+BX, CL
	SUB BX, DX
	MOV MATRIZ+BX, 20h

RET
MOVER_FILA ENDP

; Se limpia la pantalla.
LIMPIAR PROC NEAR

	MOV AH, 02h	; Se limpia la pantalla
	XOR DX, DX
	INT 10h

	MOV AX, 0003h
	XOR CX, CX 	; Desde donde inicia
	MOV DX, 184FH	; Hasta el final
	INT 10H

RET
LIMPIAR ENDP

; Se cambia el color a verde.
CONSOLA_VERDE PROC NEAR	

	MOV AX, 0600h
	MOV BH, 0Ah		;Se define el color a utilizar.

	MOV CX, 0000h		;Se define desde donde se comenzará a imprimir de cierto color.
	MOV DX, 9FFFh		;Definimos hasta donde se terminará de imprimir a color.
	INT 10h

RET
CONSOLA_VERDE ENDP

; Procedimiento para imprimir la matriz.
IMPRIMIR_MATRIZ PROC NEAR

	MOV SI, OFFSET MATRIZ	; Se utilizará SI

	XOR BX, BX
  	MOV AH, 0Eh		; Se le indica a AH que se imprimirán caracteres

	XOR CX, CX
	MOV CL, CANTFILAS

	CICLO_IMPRIMIR:		; Se hace un ciclo por la cantidad de filas
		
		PUSH CX
		XOR CX, CX
		MOV CL, CANTCOLUMNAS

		CICLO_IMPRIMIR_2:	; Se hace un ciclo por la cantidad de filas

			MOV AL, DS:[SI]
			INT 10H		; Se imprimer el caracter

			INC SI

			LOOP CICLO_IMPRIMIR_2

		MOV AL, 0AH
		INT 10H		; Se imprime un salto de linea

		MOV AL, 0DH	
		INT 10H		; Se retorna el cursor al inicio

		POP CX

		LOOP CICLO_IMPRIMIR

RET
IMPRIMIR_MATRIZ ENDP

; Procedimiento que se encarga de llamar a los demás procedimientos.
FALLING_CODE PROC NEAR

	CONTINUAR:

	MOV AH, 01h
	INT 16H				; Se comprueba si se tocó una tecla
	JZ AVANZAR

	MOV AH, 00h
	INT 16H				; Se recibe el caracter
	MOV CARACTERACTUAL, AL

	CMP CARACTERACTUAL, 1BH		; Si se recibe ESC termina el ciclo
	JE TERMINAR

	CALL MOVER_FILA

	CALL COLUMNA_RANDOM

	CALL INSERTAR_CARACTER

	JMP AVANZAR2

	AVANZAR:

	CALL MOVER_FILA

	AVANZAR2:

	CALL DELAY

	CALL LIMPIAR
	CALL CONSOLA_VERDE
	CALL IMPRIMIR_MATRIZ

	JMP CONTINUAR
	TERMINAR:

RET
FALLING_CODE ENDP

SALIR:

  jmp $				; Se deja al programa esperando

CANTCOLUMNAS DB 75		; Cantidad de columnas
CANTFILAS DB 23			; Cantidad de filas
MAXCELDA DW 1725		; Cantidad de celdas
MATRIZ DB 1725 DUP (20h)	; Matriz rellena de espacios

;NUMDELAY DB 2 			; Número para definir la cantidad de tiempo de espera

CARACTERACTUAL DB ?		; Variable que almacena el caracter a colocar
NUMRANDOM DB ?			; Variable que almacena la columna donde se colocará el caracter

_MAC ENDS			; Final del segmento
END
