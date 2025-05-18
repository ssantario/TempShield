#define __SFR_OFFSET 0x00
#include "avr/io.h"

.global main

.section .data
    dht_temp: .byte 1
    dht_humid: .byte 1

.section .text

main:
    // Setup Stack Pointer - using explicit values for ATmega328P
    LDI R16, 0xFF
    OUT SPL, R16
    LDI R16, 0x08      // 0x08FF is RAMEND for ATmega328P
    OUT SPH, R16
    
    // Setup Port D untuk output kecuali PD7
    LDI R16, 0x7F      // 0111 1111 - All outputs except PD7
    OUT DDRD, R16

    // Setup Timer untuk PWM fan control
    LDI R18, 0b10000011
    OUT TCCR0A, R18
    LDI R18, 0b00000011
    OUT TCCR0B, R18

    RCALL init_serial
    
    // Wait for sensor to stabilize
    RCALL delay_2s

main_loop:
    // Baca sensor DHT11
    RCALL dht11_read
    
    // Tampilkan data suhu
    RCALL send_temp_message
    
    // Set fan speed based on temperature
    LDS R20, dht_temp
    CPI R20, 30
    BRSH set_fast
    CPI R20, 25
    BRSH set_medium
    RJMP set_slow

set_slow:
    LDI R19, 40
    OUT OCR0A, R19
    RCALL send_slow_message
    RCALL delay
    RJMP main_loop

set_medium:
    LDI R19, 100
    OUT OCR0A, R19
    RCALL send_medium_message
    RCALL delay
    RJMP main_loop

set_fast:
    LDI R19, 200
    OUT OCR0A, R19
    RCALL send_fast_message
    RCALL delay
    RJMP main_loop

init_serial:
    CLR R24
    STS UCSR0A, R24
    STS UBRR0H, R24
    LDI R24, 103       // 9600 baud @ 16MHz
    STS UBRR0L, R24
    LDI R24, (1<<RXEN0) | (1<<TXEN0)
    STS UCSR0B, R24
    LDI R24, (3<<UCSZ00)
    STS UCSR0C, R24
    RET

wait_for_tx_ready:
    LDS R17, UCSR0A
    SBRS R17, UDRE0
    RJMP wait_for_tx_ready
    RET

delay:
    // ~100ms delay
    LDI R24, 200
delay_outer:
    LDI R25, 200
delay_middle:
    LDI R26, 10
delay_inner:
    DEC R26
    BRNE delay_inner
    DEC R25
    BRNE delay_middle
    DEC R24
    BRNE delay_outer
    RET

// DHT11 reading routine based on reference code
dht11_read:
    // Preparation delay
    RCALL delay
    
    // Send start signal
    SBI DDRD, 7       // Pin PD7 as output
    CBI PORTD, 7      // Send low pulse
    RCALL delay_20ms  // for 20ms
    SBI PORTD, 7      // Then send high pulse
    
    // Wait for response
    CBI DDRD, 7       // Pin PD7 as input
w1: SBIC PIND, 7      // Skip if PD7 is clear (low)
    RJMP w1           // Wait for DHT11 low pulse
w2: SBIS PIND, 7      // Skip if PD7 is set (high)
    RJMP w2           // Wait for DHT11 high pulse
w3: SBIC PIND, 7      // Skip if PD7 is clear (low)
    RJMP w3           // Wait for DHT11 low pulse
    
    // Read humidity (1st byte)
    RCALL DHT11_reading
    STS dht_humid, R18
    
    // Read humidity decimal (2nd byte) - ignored
    RCALL DHT11_reading
    
    // Read temperature (3rd byte)
    RCALL DHT11_reading
    STS dht_temp, R18
    
    // Read temperature decimal (4th byte) - ignored
    RCALL DHT11_reading
    
    // Read checksum (5th byte) - no validation for simplicity
    RCALL DHT11_reading
    
    RET

DHT11_reading:
    LDI R17, 8        // Set counter for receiving 8 bits
    CLR R18           // Clear data register
    
w4: SBIS PIND, 7      // Skip if PD7 is set (high)
    RJMP w4           // Detect data bit (high pulse)
    RCALL delay_timer0  // Wait 50us & then check bit value
    
    SBIS PIND, 7      // If received bit=1, skip next instruction
    RJMP skp          // Else, received bit=0, jump to skp
    SEC               // Set carry flag (C=1)
    ROL R18           // Shift in 1 into LSB data register
    RJMP w5           // Jump & wait for low pulse
skp:
    LSL R18           // Shift in 0 into LSB data register
    
w5: SBIC PIND, 7      // Skip if PD7 is clear (low)
    RJMP w5           // Wait for DHT11 low pulse
    
    DEC R17           // Decrement counter
    BRNE w4           // Go back & detect next bit
    RET               // Return to calling subroutine

delay_20ms:           // Delay 20ms
    LDI R21, 255
l3: LDI R22, 210
l4: LDI R23, 2
l5: DEC R23
    BRNE l5
    DEC R22
    BRNE l4
    DEC R21
    BRNE l3
    RET

delay_2s:             // Delay 2s
    LDI R21, 255
l6: LDI R22, 255
l7: LDI R23, 164
l8: DEC R23
    BRNE l8
    DEC R22
    BRNE l7
    DEC R21
    BRNE l6
    RET

delay_timer0:         // 50 usec delay via Timer 0
    CLR R20
    OUT TCNT0, R20    // Initialize timer0 with count=0
    LDI R20, 100
    OUT OCR0A, R20    // OCR0A = 100
    LDI R20, 0b00001010
    OUT TCCR0B, R20   // Timer0: CTC mode, prescaler 8
    
l2: IN R20, TIFR0     // Get TIFR0 byte & check
    SBRS R20, OCF0A   // If OCF0A=1, skip next instruction
    RJMP l2           // Else, loop back & check OCF0A flag
    
    CLR R20
    OUT TCCR0B, R20   // Stop timer0
    
    LDI R20, (1<<OCF0A)
    OUT TIFR0, R20    // Clear OCF0A flag
    RET

send_temp_message:
    RCALL wait_for_tx_ready
    LDI R24, 'T'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'e'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'm'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'p'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, ':'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, ' '
    STS UDR0, R24
    
    // Convert temperature to ASCII
    LDS R24, dht_temp
    LDI R25, 10
    MOV R16, R24
    CLR R24
div_loop:
    CPI R16, 10
    BRLO div_done
    SUBI R16, 10
    INC R24
    RJMP div_loop
div_done:
    SUBI R24, -'0'
    RCALL wait_for_tx_ready
    STS UDR0, R24
    MOV R24, R16
    SUBI R24, -'0'
    RCALL wait_for_tx_ready
    STS UDR0, R24
    
    // Add °C
    RCALL wait_for_tx_ready
    LDI R24, ' '
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'C'
    STS UDR0, R24
    
    // Add humidity info
    RCALL wait_for_tx_ready
    LDI R24, ' '
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, ' '
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'H'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'u'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'm'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'i'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'd'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, ':'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, ' '
    STS UDR0, R24
    
    // Convert humidity to ASCII
    LDS R24, dht_humid
    LDI R25, 10
    MOV R16, R24
    CLR R24
humid_div_loop:
    CPI R16, 10
    BRLO humid_div_done
    SUBI R16, 10
    INC R24
    RJMP humid_div_loop
humid_div_done:
    SUBI R24, -'0'
    RCALL wait_for_tx_ready
    STS UDR0, R24
    MOV R24, R16
    SUBI R24, -'0'
    RCALL wait_for_tx_ready
    STS UDR0, R24
    
    // Add %
    RCALL wait_for_tx_ready
    LDI R24, '%'
    STS UDR0, R24
    
    RCALL send_newline
    RET

send_slow_message:
    RCALL send_motor_speed_text
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

send_medium_message:
    RCALL send_motor_speed_text
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

send_fast_message:
    RCALL send_motor_speed_text
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

send_motor_speed_text:
    RCALL wait_for_tx_ready
    LDI R24, 'M'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'o'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 't'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'o'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'r'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, ' '
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'S'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'p'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'e'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'e'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, 'd'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, ' '
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, ':'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, ' '
    STS UDR0, R24
    RET

send_newline:
    RCALL wait_for_tx_ready
    LDI R24, '\r'
    STS UDR0, R24
    RCALL wait_for_tx_ready
    LDI R24, '\n'
    STS UDR0, R24
    RET
