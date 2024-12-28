;------------------------------------------------------------------------------
; Titel:                GleEst für BIC (320 x 200 | 16 Farben)
;
; Erstellt:             20.12.2024
; Letzte Änderung:      27.12.2024
;------------------------------------------------------------------------------ 

        cpu     z80

hi      function x,(x>>8)&255
lo      function x, x&255

        ifndef  BASE
                BASE:   set     8100H   
        endif   
        
        org     BASE
        
        call    initGleEst
        call    cls
        call    156H            ; LORIPU (Tastaturpuffer leeren)
       
;------------------------------------------------------------------------------
        
        ; Start GleEst
        
        ld      hl, 0001h       ; (stack) darf nicht 0 sein
        push    hl
        
        ld      hl, buffer1
        
        exx

        loop_ix:
                call    0BAH            ; STPTST (Stop-Taste prüfen)
                jr      nz, exit
                jr      noKey
        exit:
                call    cls
                pop     hl
                ret
        
        noKey:  
                ld      hl,buffer2
        
                loop:   
                        ld      bc,3F03h        ; BH = 3F -> max. 64 Punkte / 192-Byte-Block
                                                ; BL = 03 -> HL auf Anfang von nächstem 
                                                ;            192-Byte-Block setzen
                        d_loop:
                                ;
                                ; Pixel löschen
                                ;
                                
                                ld      e,(hl)          ;BWS lo holen
                                inc     hl
                                
                                ld      d,(hl)          ;BWS hi holen
                                inc     hl
                                                                                      
                                ld      a,(hl)          ;Bitpos + Farbindex
                                
                                push    hl
                                push    bc
                                
                                ld      h, d
                                ld      l, e

                                ;-------------------------------------------------------
                                ; BIC (320 x 200 | 16 Farben)                           
                                ;-------------------------------------------------------
                                ; in:   HL = VRAM-Adr
                                ;       A  = Bitpos (2Bit) [0-3], Farbindex(3Bit) [0-5] 
                                ;               
                                ; out:  Pixel in VRAM gelöscht  
                                ;-------------------------------------------------------
                                call    gdcResPixel
                                
                                pop     bc
                                pop     hl
                                
                                exx                     
                                
                                proc:   ld      a,L
                                
                                        ld      e,(hl)   
                                        inc     l
                                        
                                        ld      d,(hl) 
                                        inc     l
                                        
                                        inc     l
                                        inc     l
                                        
                                        ld      c,(hl)  
                                        inc     l
                                        
                                        ld      b,(hl)
                                        ex      de,hl
                                        add     hl,bc
                                        ex      de,hl
                                        srl     d
                                        rr      e
                                        ld      L,a
                                        
                                        ld      (hl),e
                                        inc     l
                                        
                                        ld      (hl),d
                                        inc     l
                                        
                                        push    de
                                        and     2       
                                        
                                jr      z, proc

                                pop     bc
                                ex      (sp),hl
                                
                                exx
                                
                                ld      a,b
                                
                                exx
                                
                                cp      10h
                                jr      c,dontplot
                                
                                ld      bc,0fd40h
                                add     hl,bc
                                srl     h
                                jr      nz,dontplot
                                
                                rr      l
                                ld      c,L
                                ld      a,d
                                add     a,b
                                srl     a
                                jr      nz,dontplot
                                
                        plot:
                                ld      a,e
                                rra
                                cp      200             ; Y max  
                                                                
                                ;
                                ; Pixel schreiben
                                ;
                                
                                ;-------------------------------
                                ; ZX Spectrum 
                                ;-------------------------------                                

                                ; THE 'PIXEL ADDRESS' SUBROUTINE
                                ; This subroutine is called by the POINT subroutine and by the PLOT command routine. 
                                ; Is is entered with the co-ordinates of a pixel in the BC register pair and returns 
                                ; with HL holding the address of the display file byte which contains that pixel 
                                ; and A pointing to the position of the pixel within the byte.
                
                                ;call   c,22b0h         -> Spectrum ROM
 
                                ; Vorbereitung Register für setPixel (GDC)
                                
                                push    af
                                
                                exx
                                ld      a, b            ; Farbindex holen
                                
                                rrca    
                                rrca    
                                rrca
                                and     00000111b       ; umrechnen zu 2-7
                                
                                sub     2               ; 2-7 -> 0-5
                                exx                             
                                ld      b, a            ; Farbindex [0-5] nach B
                                
                                pop     af
                                
                                ;-----------------------------------------------------------
                                ; BIC (320 x 200 | 16 Farben)
                                ;-----------------------------------------------------------    
                                ; in:   A = Y [0-199] 
                                ;       B = C [0-5]   Farbindex
                                ;       C = X [0-255]
                                ;       
                                ; out:  HL = VRAM-Adr
                                ;       A  = Bitpos (2Bit) [0-3], Farbindex(3Bit) [0-5]
                                ;
                                ; VRAM_ADR = 80*Y + X/4
                                ;------------------------------------------------------------
                                
                                jr      nc,x1           ; innerhalb 0-199 ?
                                call    setPixel        
                                jr      x2
                        x1:     ld      hl, dummy       ; nein -> HL = Dummy-BWS
                        x2:     push    hl
                                
                                exx
                                
                                pop     de              
                   
                                ld      (hl),a          ; Bitpos u. Farbindex merken
                                dec     hl
                                  
                                ld      (hl),d          ; BWS hi merken
                                dec     hl
                                
                                ld      (hl),e          ; BWS lo merken
                                inc     hl                      
                                inc     hl             
                                ld      a,b
                                
                                exx
        
                        dontplot:
                                pop     hl              
                                
                                exx
                                
                                inc     hl              

                        djnz    d_loop

                        add     hl,bc   
                        
                        exx                     
                        
                        random:
                                pop     de
                                ld      b,10h
                                
                                backw:  sla     e
                                        rl      d
                                        ld      a,d
                                        and     0c0h    
                                        jp      pe,forw
                                        inc     e
                                        
                        forw:   djnz    backw
                        
                                ld      a,d
                                push    de
                                rra
                                rr      b
                                and     07h
                                ld      (hl),b   
                                inc     l
                                ld      (hl),a  
                                inc     l
                        jr      nz,random
                        
                        exx                             
                        
                        ld      a,hi(buffer2_end)-1
                        cp      a,h
                        
                jp      nc,loop
                
        jp      loop_ix
       
       


;-----------------------------------------------------------------------------
; VIS/GDC - Grafik-Routinen
; 
; Anhang Programmierhandbuch: 
; https://www.sax.de/~zander/bic/bc_phba.pdf
;
; Systembeschreibung:
; https://www.sax.de/~zander/bic/bc_sys.pdf
;
; Serviceunterlagen Teil 1:
; https://www.sax.de/~zander/bic/bc_serv1.pdf
;-----------------------------------------------------------------------------
        
GDC_PAR_RW      equ     98h
GDC_CMD_RW      equ     99h
        
VIS_DAT_RW_ZG   equ     9Ch
VIS_MOD_WR      equ     9Dh
VIS_ADR_WR_ZG   equ     9Eh
        
;-----------------------------------------------------------------------------  
; in:   -
;       
; out:  Bildschirm Mode 5 (aktuelle Seite) gelöscht
;-----------------------------------------------------------------------------

cls:    ld      hl, 4000H

        ld      a, 49h                  ; CURS
        out     (GDC_CMD_RW), a
        ld      a, l                    ; EAD l 
        out     (GDC_PAR_RW), a         
        ld      a, h                    ; EAD h 
        out     (GDC_PAR_RW), a

        ld      a, 4Ah                  ; MASK
        out     (GDC_CMD_RW), a 
        ld      a, 0FFh                 ; alle Bits wählen
        out     (GDC_PAR_RW), a         ; G, B
        out     (GDC_PAR_RW), a         ; H, R

        ld      a, 20H                  ; WDAT replace word 
        out     (GDC_CMD_RW), a 
        
        ld      bc, 80*200              ; 80x4Bit x 200 Zeilen 
cls1:   xor     a                       ; alle Bits auf 0 setzen                
        out     (GDC_PAR_RW), a         ; G, B
        out     (GDC_PAR_RW), a         ; H, R  
        
        dec     bc
        ld      a, b
        or      c
        jr      nz,cls1
        
        ret

;-----------------------------------------------------------------------------  
; in:   A = Y [0-199] 
;       B = C [0-5]   Farbindex
;       C = X [0-255]
;       
; out:  HL = VRAM-Adr
;       A  = Bitpos (2Bit) [0-3], Farbindex(3Bit) [0-5]
;
; VRAM_ADR = 80*Y + X/4
;-----------------------------------------------------------------------------  

setPixel:
        
        ld      h, 0
        ld      l, A            ; HL = Y

        ; HL * 80
        add     hl, hl          ; *2
        add     hl, hl          ; *4
        add     hl, hl          ; *8
        add     hl, hl          ; *16
        ld      d, h
        ld      e, l
        add     hl, hl          ; *32   
        add     hl, hl          ; *64
        add     hl, de          ; *64 + *16 = *80

        push    hl              ; Bild mittig
        ld      h, 0
        ld      l, C
        ld      de, 32          ; X += 32
        add     hl, de
        ex      hl, de
        pop     hl
        
        srl     d               ; DE = X/4
        rr      e
        srl     d               
        rr      e 
        
        add     hl, de          ; 80*Y + X/4            
        ld      de, 4000H
        add     hl, de

        ld      a, C
        and     a, 00000011b    ; A = Bitpos (2Bit)
        rlc     b               ; B = Farbindex(3Bit) 2x links
        rlc     b
        or      b               ; A = Bitpos | Farbindex
        and     00011111b       
        call    gdcSetPixel
        ret

;-----------------------------------------------------------------------------  
; in:   HL = VRAM-Adr
;       A  = Bitpos (2Bit) [0-3], Farbindex(3Bit) [0-5]  
;
; out:  Pixel in VRAM   
;       HL = VRAM-Adr
;       A  = Bitpos (2Bit) [0-3], Farbindex(3Bit) [0-5]
;-----------------------------------------------------------------------------  

gdcSetPixel:

        push    hl
        push    af
              
        ld      b, a 
	
        ld      a, 49h                  ; CURS
        out     (GDC_CMD_RW), a
        ld      a, l                    ; EAD l 
        out     (GDC_PAR_RW), a         
        ld      a, h                    ; EAD h 
        out     (GDC_PAR_RW), a

        ;---
        
        ld      h, hi(pixtab)	
	ld	l, b
	rlc	l
	
        ;---
        
        ld      a, 4Ah                  ; MASK
        out     (GDC_CMD_RW), a
        
        ld      a, (hl)
        out     (GDC_PAR_RW), a         ; G, B
        inc     hl
        ld      a, (hl)
        out     (GDC_PAR_RW), a         ; H, R  
        
        dec     hl
        
        ;---
        
        ld      a, 20H                  ; WDAT replace word 
        out     (GDC_CMD_RW), a 
        
        ld      a, (hl)
        out     (GDC_PAR_RW), a         ; G, B
        inc     hl
        ld      a, (hl)
        out     (GDC_PAR_RW), a         ; H, R
        
        pop     af
        pop     hl
        ret

;-----------------------------------------------------------------------------  
; in:   HL = VRAM-Adr
;       A  = Bitpos (2Bit) [0-3], Farbindex(3Bit) [0-5]  
;
; out:  Pixel in VRAM gelöscht  
;-----------------------------------------------------------------------------

gdcResPixel:
     
        ld      b, a    
	
        ld      a, h
        cp      a, hi(dummy)            ; Dummy-BWS-Adr ?
        ret     z                       ; skipRes
        
        ld      a, 49h                  ; CURS
        out     (GDC_CMD_RW), a
        ld      a, l                    ; EAD l 
        out     (GDC_PAR_RW), a         
        ld      a, h                    ; EAD h 
        out     (GDC_PAR_RW), a

        ;---
        
        ld      h, hi(pixtab)	
	ld	l, b
	rlc	l	
	
        ;---
        
        ld      a, 4Ah                  ; MASK
        out     (GDC_CMD_RW), a
        
        ld      a, (hl)
        out     (GDC_PAR_RW), a         ; G, B
        inc     hl
        ld      a, (hl)
        out     (GDC_PAR_RW), a         ; H, R
        
        ;---
        
        ld      a, 20H                  ; WDAT replace word 
        out     (GDC_CMD_RW), a 
        ld      a, 0
        out     (GDC_PAR_RW), a         ; G, B
        out     (GDC_PAR_RW), a         ; H, R
        
        ret

;------------------------------------------------------------------------------
; Bildschirm in Mode 5 schalten (320 x 200 | 16 Farben) und buffer2 wird mit 
; Adresse von "dummy" und 00h initialisiert, damit beim Laufen von GleEst keine 
; undefinierten Schreibvorgänge im VRAM erfolgen können.
;------------------------------------------------------------------------------
        
initGleEst:

        ; Bildschirm-Mode 5 einschalten

        ld      b, 5    ; Mode  5 aktiv
        ld      c, 0    ; Seite 0 aktiv
        ld      d, b    ; Mode  5 visuell
        ld      e, c    ; Seite 0 visuell
        call    5Fh     ; SELSCR (BIC ROM-Code)
        
        ; ---
        
        ld      bc, (buffer2_end - buffer2)/3
        ld      hl, buffer2
        ld      de, dummy
        
fb1:    ld      (hl), e         ; Dummy-BWS hi
        inc     hl
        ld      (hl), d         ; Dummy-BWS lo
        inc     hl
        ld      (hl), 00h       ; Dummy Bitpos u. Farbindex
        inc     hl
        
        dec     bc
        ld      a, b
        or      c
        jr      nz, fb1 
        ret  
        
;-----------------------------------------------------------------------------  
        
        align   100h    
        
        ;Pixelnummer   | 1  | 2  | 3  | 4  |
        ;(H)ell        | B12| B13| B14| B15|
        ;(R)ot         | B8 | B9 | B10| B11|
        ;(G)rün        | B4 | B5 | B6 | B7 |
        ;(B)lau        | B0 | B1 | B2 | B3 |    

pixtab: 

        dw      0001000000010001b       ; H, R, G, B -> HGB
        dw      0010000000100010b
        dw      0100000001000100b
        dw      1000000010001000b

        dw      0001000000010000b       ; H, R, G, B -> HG
        dw      0010000000100000b
        dw      0100000001000000b
        dw      1000000010000000b

        dw      0000000100010000b       ; H, R, G, B -> GR
        dw      0000001000100000b
        dw      0000010001000000b
        dw      0000100010000000b

        dw      0000000100000000b       ; H, R, G, B -> R
        dw      0000001000000000b
        dw      0000010000000000b
        dw      0000100000000000b

        dw      0000000100000001b       ; H, R, G, B -> RB
        dw      0000001000000010b
        dw      0000010000000100b
        dw      0000010000001000b

        dw      0000000000000001b       ; H, R, G, B -> B
        dw      0000000000000010b
        dw      0000000000000100b
        dw      0000000000001000b

;------------------------------------------------------------------------------

        ; RAM für GleEst

dummy:  db      00h 
        
        align   100h
        
buffer1:        
        ds      100h        
buffer2:                ; 12 x 192 Bytes
        ds      0900h   ; 900h  
buffer2_end:    


        
        



