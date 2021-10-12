# Sistemas Operativos - Primera Tarea: MAC OS

Primera tarea del curso de Principios de Sistemas Operativos (código ic-6600) en la carrera de Ingeniería en Computación del Tecnológico de Costa Rica.

## Objetivo

El trabajo consiste en crear un programa capaz de ser ejecutado en un computador sin depender de ningún sistema operativo. El programa a poner en marcha se trata de una implementación del “falling code” escrita en ensamblador para x86. Para lograr lo anterior se deberá crear código que sea capaz de arrancar el programa principal utilizando un sistema como el de MBR. Esto deberá ser capaz de hacerlo en cualquier computador de arquitectura x86.

## Requerimientos

### MAC OS
Este programa consiste en una animación tipo falling code de la película The Matrix. MAC OS debe de recibir caracteres desde el teclado y luego pintar los caracteres en pantalla emulando el Falling Code de Matrix.

### Otras consideraciones
El desarrollo se debe de realizar utilizando el lenguaje de programación Ensamblador para x86. Se utilizará MBR como mecanismo de booteo, únicamente. En caso que el estudiante lo implemente con EFI, no se revisará la tarea.

Se deberá de poder correr MAC OS en un navegador web utilizando algún emulador de x86 que corra de forma nativa utilizando WebAssembly

## Funcionamiento del programa

### Ejecución del código MAC OS

Para ejecutar el programa primeramente se deberán ensamblar los programas “bootload.asm” y “MAC.asm”. Para esto se puede utilizar la herramienta DosBox junto con TASM (recomendablemente la versión 3.2) y TLink (preferiblemente la versión 5.1) con los siguientes comandos:

```console
tasm bootload.asm
tlink /t bootload,bootload.bin
tasm MAC.asm
tlink /t MAC,MAC.bin
```

Seguidamente se deberá crear el archivo binario que leerá el emulador QEmu. Para esto se utilizan los comandos de linux:

```console
dd if=/dev/zero of=MAC_OS.bin bs=1024 count=720
dd if=BOOTLOAD.BIN of=MAC_OS.bin bs=512 conv=notrunc
dd if=MAC.BIN of=MAC_OS.bin bs=512 seek=1 conv=notrunc
```

Finalmente se podrá utilizar QEmu para probar el sistema con el comando en la terminal:

```console
qemu−system−x86_64 −hda MAC_OS.bin
```

### Ejecución del código en WebAssembly

Es posible ejecutar el programa utilizando un navegador web al utilizar el programa v86, unicamente es necesario subir el archivo “MAC OS.bin” en la sección “Hard drive disk image” y comenzar a correr el sistema. El sitio web en cuestión es http://copy.sh/v86/

## Estado

El programa funciona de manera correcta, y fueron implementadas todas las funcionalidades solicitadas.

## Realizado por:

* Walter Morales Vásquez
