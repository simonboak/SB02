;;
;; Character LCD Module Routines
;; 
;; Taken from: http://6502.org/mini-projects/optrexlcd/lcd.htm
;; Credit to Chris Ward
;;
;; Modified by Simon Boak to assebmle on xa
;; Feb 2016
;; 




ZPDATA    EQU $00             ;zero-page data area
LCD       EQU $D300           ;LCD module address

          ORG LCD
LCD0      .ds 1
LCD1      .ds 1

          ORG ZPDATA
MSGBASE   .ds 2     ;address of message to print on LCD



; *** Wait for LCD busy bit to clear
; registers preserved
LCDBUSY   PHA
LCDBUSY0  LDA LCD0            ;read from LCD register 0
          AND #$80            ;check bit 7 (busy)
          BNE LCDBUSY0
          PLA
          RTS
          
; *** LCD initialisation
LINIT     LDX #$04            ;do function set 4 times
LINIT0    LDA #$38            ;function set: 8 bit, 2 lines, 5x7
          STA LCD0
          JSR LCDBUSY         ;wait for busy flag to clear
          DEX
          BNE LINIT0
          LDA #$06            ;entry mode set: increment, no shift
          STA LCD0
          JSR LCDBUSY
          LDA #$0E            ;display on, cursor on, blink off
          STA LCD0
          JSR LCDBUSY
          LDA #$01            ;clear display
          STA LCD0
          JSR LCDBUSY
          LDA #$80            ;DDRAM address set: $00
          STA LCD0
          JSR LCDBUSY
          RTS
LINITMSG  fcs "LCD init done. "
          .byte $00
          
; *** Clear LCD display and return cursor to home
; registers preserved
LCDCLEAR  PHA
          LDA #$01
          STA LCD0
          JSR LCDBUSY
          LDA #$80
          STA LCD0
          JSR LCDBUSY
          PLA
          RTS
          
; *** Print character on LCD (40 character)
; registers preserved
LCDPRINT  PHA
          STA LCD1            ;output the character
          JSR LCDBUSY
          LDA LCD0            ;get current DDRAM address
          AND #$7F
          CMP #$14            ;wrap from pos $13 (line 1 char 20)...
          BNE LCDPRINT0
          LDA #$C0            ;...to $40 (line 2 char 1)
          STA LCD0
          JSR LCDBUSY
LCDPRINT0 PLA
          RTS
          
; *** Print 2 digit hex number on LCD
; A, X registers preserved
LCDHEX    PHA
          LSR A               ;shift high nybble into low nybble
          LSR A
          LSR A
          LSR A
          TAY
          LDA HEXASCII,Y      ;convert to ASCII
          JSR LCDPRINT        ;print value on the LCD
          PLA                 ;restore original value
          PHA
          AND #$0F            ;select low nybble
          TAY
          LDA HEXASCII,Y      ;convert to ASCII
          JSR LCDPRINT        ;print value on the LCD
          PLA
          RTS

; *** Lookup table for HEX to ASCII
HEXASCII	fcs "0123456789ABCDEF"

