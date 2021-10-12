; Programa boot loader para la arquitectura x86 para cargar el segmento ubicado en 7E00h.
; Funcional en TASM 3.2 y en TLink 5.1
; Autor: Walter Morales Vásquez

_BootLoad SEGMENT PUBLIC USE16		; Se declara el segmento del programa
assume CS:_BootLoad, DS:_BootLoad	; Se definen los valores de algunos registros a utilizar
org 0					; Se indica el origen del código

; Punto inicial del programa
Entry:					; Ref: https://github.com/vmt/attic/tree/master/helloboot
	db 0EAh				; Se utiliza la instrucción para realizar un salto largo en TASM.
	dw OFFSET AfterData, 7C0h	; Se define el "offset" y el "segment" a saltar
					; Todo esto es equivalente a "jmp far SEG:OFS" en otros ensambladores.
					; Al inicio estamos en 0:7C00
					; Después del salto estamos en 07C0h:0

AfterData:

	cli			; Se desactivan las interrupciones
	MOV AX, 07C0h		; Se configuran los registros para que apunten a nuestro
	MOV DS, AX		; Se actualiza a DS para que sea 7C0h en lugar de 0
	MOV ES, AX

	ADD AX, 00h		; Se define el rango de la pila a utilizar
	MOV SS, AX		; Base de la pila
	MOV SP, 0FFFFh		; Altura de la pila
	sti			; Se restauran las interrupciones

	MOV AH, 00		; Reconfigura el drive
	int 13h

	read_sector:
		MOV BX, 07E0h
		MOV ES, BX	; ES = 07E0h
		XOR BX, BX	; BX = 0. ES:BX=07E0h:0
				; ES:BX = Dirección donde se van a leer los segmentos
		MOV AH, 02      ; Int 13h/AH=2 = Se leen los sectores en el drive
		MOV AL, 01      ; Sector a leer = 1
		MOV CH, 00      ; CH = Cilindro. Segundo sector del drive
		MOV CL, 02      ; Sector a leer = 2
		MOV DH, 00      ; Cabeza a leer = 0
				; DL número de drive
				; DL contiene el número pasado a nuestro bootloader pasado por el BIOS

		int 13h		; Interrupción para leer un sector

	JC read_sector

	push 07E0h		; Segment = 07E0h
	push 0000h		; Offset = 0
	retf			; Se realiza un far jmp a 7E0h:0

	cli			; Desabilita las interrupciones
	hlt			; Detiene completamente el procesador

; Final del boot

org 510    			; Se hace el código 510 de largo
dw 0AA55h			; Se coloca la firma del boot

_BootLoad ENDS			; Final del segmento
END
