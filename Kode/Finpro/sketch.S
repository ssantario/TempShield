#define __SFR_OFFSET 0x00 
#include "avr/io.h"

.global main

main:
    ; Set up fan control pin as output (Port D)
    LDI R16, 0xFF
    OUT DDRD, R16
    
    ; Set up Timer0 for PWM mode
    LDI R18, 0b10000011    ; Fast PWM mode
    OUT TCCR0A, R18
    LDI R18, 0b00000011    ; Prescaler = 64
    OUT TCCR0B, R18
    
    ; Initialize UART for serial communication
    RCALL init_serial
    
    ; Start with slow speed
    RJMP slow

; Initialize serial communication with specified parameters
init_serial:
    CLR R24                ; Clear register R24
    STS UCSR0A, R24        ; Reset USART status
    
    ; Set baud rate to 9600 bps
    ; For 16MHz crystal: 16000000/(16*9600) - 1 = 103
    STS UBRR0H, R24        ; Set high byte of baud rate to 0
    LDI R24, 103           ; Set low byte for 9600 baud
    STS UBRR0L, R24        ; Store baud rate
    
    ; Configure UART: enable TX and RX
    LDI R24, (1<<RXEN0) | (1<<TXEN0)  
    STS UCSR0B, R24        ; Enable transmitter and receiver
    
    ; Configure frame format: 8 data bits, 1 stop bit, no parity
    LDI R24, (3<<UCSZ00)
    STS UCSR0C, R24        ; Set 8 data bits, 1 stop bit, no parity
    
    RET

; Wait for the transmitter to be ready
wait_for_tx_ready:
    LDS R17, UCSR0A        ; Load USART status register
    SBRS R17, UDRE0        ; Skip if UDRE0 bit is set (buffer empty)
    RJMP wait_for_tx_ready ; Loop until buffer is empty
    RET

; Slow speed routine
slow:
    LDI R19, 40            ; Set low duty cycle (15%)
    OUT OCR0A, R19
    
    RCALL send_slow_message
    RCALL delay
    RJMP medium

; Medium speed routine
medium:
    LDI R19, 100           ; Set medium duty cycle (39%)
    OUT OCR0A, R19
    
    RCALL send_medium_message
    RCALL delay
    RJMP fast

; Fast speed routine
fast:
    LDI R19, 200           ; Set high duty cycle (78%)
    OUT OCR0A, R19
    
    RCALL send_fast_message
    RCALL delay
    RJMP slow

; Delay function
delay:
    LDI R24, 121           ; Outer loop counter
    LDI R25, 78            ; Middle loop counter
    LDI R26, 32            ; Inner loop counter
L1:
    DEC R26                ; Decrement inner counter
    BRNE L1                ; Loop until inner counter is zero
    DEC R25                ; Decrement middle counter
    BRNE L1                ; Loop until middle counter is zero
    DEC R24                ; Decrement outer counter
    BRNE L1                ; Loop until outer counter is zero
    NOP
    RET

; Send "Motor Speed : Low" message
send_slow_message:
    ; Send "Motor Speed : Low" character by character
    RCALL send_motor_speed_text  ; Send "Motor Speed : "
    
    ; Send "Low" part
    RCALL wait_for_tx_ready
    LDI R24, 'L'
    STS UDR0, R24
    
    RCALL wait_for_tx_ready
    LDI R24, 'o'
    STS UDR0, R24
    
    RCALL wait_for_tx_ready
    LDI R24, 'w'
    STS UDR0, R24
    
    RCALL send_newline
    RET

; Send "Motor Speed : Medium" message
send_medium_message:
    ; Send "Motor Speed : " part
    RCALL send_motor_speed_text  ; Send "Motor Speed : "
    
    ; Send "Medium" part
    RCALL wait_for_tx_ready
    LDI R24, 'M'
    STS UDR0, R24
    
    RCALL wait_for_tx_ready
    LDI R24, 'e'
    STS UDR0, R24
    
    RCALL wait_for_tx_ready
    LDI R24, 'd'
    STS UDR0, R24
    
    RCALL wait_for_tx_ready
    LDI R24, 'i'
    STS UDR0, R24
    
    RCALL wait_for_tx_ready
    LDI R24, 'u'
    STS UDR0, R24
    
    RCALL wait_for_tx_ready
    LDI R24, 'm'
    STS UDR0, R24
    
    RCALL send_newline
    RET

; Send "Motor Speed : High" message
send_fast_message:
    ; Send "Motor Speed : " part
    RCALL send_motor_speed_text  ; Send "Motor Speed : "
    
    ; Send "High" part
    RCALL wait_for_tx_ready
    LDI R24, 'H'
    STS UDR0, R24
    
    RCALL wait_for_tx_ready
    LDI R24, 'i'
    STS UDR0, R24
    
    RCALL wait_for_tx_ready
    LDI R24, 'g'
    STS UDR0, R24
    
    RCALL wait_for_tx_ready
    LDI R24, 'h'
    STS UDR0, R24
    
    RCALL send_newline
    RET

; Common routine to send "Motor Speed : " text
send_motor_speed_text:
    ; Send "Motor Speed : " character by character
    ; "M"
    RCALL wait_for_tx_ready
    LDI R24, 'M'
    STS UDR0, R24
    
    ; "o"
    RCALL wait_for_tx_ready
    LDI R24, 'o'
    STS UDR0, R24
    
    ; "t"
    RCALL wait_for_tx_ready
    LDI R24, 't'
    STS UDR0, R24
    
    ; "o"
    RCALL wait_for_tx_ready
    LDI R24, 'o'
    STS UDR0, R24
    
    ; "r"
    RCALL wait_for_tx_ready
    LDI R24, 'r'
    STS UDR0, R24
    
    ; " "
    RCALL wait_for_tx_ready
    LDI R24, ' '
    STS UDR0, R24
    
    ; "S"
    RCALL wait_for_tx_ready
    LDI R24, 'S'
    STS UDR0, R24
    
    ; "p"
    RCALL wait_for_tx_ready
    LDI R24, 'p'
    STS UDR0, R24
    
    ; "e"
    RCALL wait_for_tx_ready
    LDI R24, 'e'
    STS UDR0, R24

    ; "e"
    RCALL wait_for_tx_ready
    LDI R24, 'e'
    STS UDR0, R24
    
    ; "d"
    RCALL wait_for_tx_ready
    LDI R24, 'd'
    STS UDR0, R24
    
    ; " "
    RCALL wait_for_tx_ready
    LDI R24, ' '
    STS UDR0, R24
    
    ; ":"
    RCALL wait_for_tx_ready
    LDI R24, ':'
    STS UDR0, R24
    
    ; " "
    RCALL wait_for_tx_ready
    LDI R24, ' '
    STS UDR0, R24
    
    RET

; Send newline characters (CR+LF)
send_newline:
    RCALL wait_for_tx_ready
    LDI R24, '\r'
    STS UDR0, R24
    
    RCALL wait_for_tx_ready
    LDI R24, '\n'
    STS UDR0, R24
    
    RET