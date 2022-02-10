;
.EQU s_1=0b0111110//przycisk 1
.EQU s_2=0b0111101//przycisk 2
.EQU s_3=0b0111011//przycisk 3
.EQU s_4=0b0110111// przycisk 4

.CSEG 
.ORG 0 
	rjmp prog_start //pocz�tek programu
.ORG 0x0008//przerwanie 
	rjmp przerwanie	   
.org 0x32  
	prime: .DB 0x7e, 0x30, 0x6d, 0x79, 0x33, 0x5b, 0x5f, 0x70, 0x7F, 0x7B, 0x77, 0x1f, 0x4e, 0x3d, 0x4f, 0x47	   
.DSEG 
.ORG 0x100 
	var1: .BYTE 1  
	var2: .BYTE 1  
	var3: .BYTE 1  
	nr_przycisku: .BYTE 1 
	nr_gracza: .BYTE 1
	pass_1: .BYTE 1
	pass_2: .BYTE 1
	wynik_1: .BYTE 1//wynik obecny
	wynik_2: .BYTE 1
	l_pkto: .BYTE 1
	win_1: .BYTE 1// liczba pkt za kilka rund
	win_2: .BYTE 1
	l_wyl: .BYTE 1
	wylosowana: .BYTE 1
	.CSEG  
////pocz�tek programu// stos //////////////////////////////////////////////////////////////////////////////////////////
prog_start: 
	ldi R16, HIGH(RAMEND)    
	out SPH, R16    
	ldi R16, LOW(RAMEND)    
	out SPL, R16    
//przerwanie/////////////////////////////////////////////////////////////////////////////////////////////
	ldi r20, (1<<pcint9)					
	sts pcmsk1, r20
	ldi r20, (1<<pcie1) 
	sts pcicr, r20
///ustawianie wej��/wyj�� ////////////////////////////////////////////////////////////////////////////////////////
	ldi r16, $ff    
	out ddrb, r16    
	out ddrd, r16  
	out portc, r16 
	ldi r16, $00    
	out ddrc, r16
//zerowanie zmiennych i rejestr�w �eby nie pojawia�y si� jakie� nieznane warto�ci//////////////////////////////////////////////////////////////////////////////////////////////////////////
	ldi r16, 0x00 
	ldi r17, 0x00 
	sts wynik_1, r16
	sts wynik_2, r16
	sts l_pkto, r16
	sts win_1, r16
	sts win_2, r16
//pocz�tek gry//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
main:  
	gracz_1:////////////////////////////instrukcje dla gracza pierwszego
		lds r16, pass_1///////////sprawdzam czy gracz 1 nie zpassowa� je�li tak to pomijany jest jego ruchy do momentu a� drugi przegra lub te� zpassuje lub trafi 21
		ldi r17, 0x01
		cp r16, r17
		breq gracz_2


		ldi r16, 0x01
		sts nr_gracza, r16////wy�wietlamy numer gracza na 7-segmentowym 
blad1:
		sei
		call sprawdzanie_wejsc//podprogram w kt�rym oczekujemy na decyzj� gracza i dokonywane jest losowanie 
		cli

		lds r16, nr_przycisku//sprawdzamy kt�ry przycisk zosta� wci�ni�ty i od razu podejmuemy odpowiednie dzia�ania
		ldi r17, s_1
		cp r16, r17
		brne przycisk_1///wci�ni�ty przycisk 1 przepuszcza ////oznacza pass 1 gracza a jak nie to idzie losowania
			ldi r16, 0x01
			sts pass_1, r16//pass dla 1 gracza ustawiany na jeden oznacza �e nie b�dzie m�g� wykonywa� ruchu do zako�czenia rundy

			ldi r17, 0x00///////////////////////na wy�wietlaczu wy�wietlana jest sekwencja liczb 4,3,4,3
			ldi r16, 0x04
			call wyswietlanie
			nop
			ldi r16, 0x03
			call wyswietlanie
			nop
			ldi r16, 0x04
			call wyswietlanie
			nop
			ldi r16, 0x03
			call wyswietlanie
			nop																													
			jmp gracz_2//jesli b�dzie 1 to juz dla 2  i skacze w sumie do gracza 2 przycisk_2 zamieniam na gracz_2
		przycisk_1:///nie wci�ni�ty przycisk 1 sprawdzamy czy wci�ni�ty jest 2 przycisk
		ldi r17, s_2
		cp r16, r17
		brne blad1////wcisniety przycisk 2 przepuszcza jesli nie to jeszcze raz trzeba wcisn�c przycisk bo nie jest to 1 ani 2
			lds r16, wynik_1//zapisany wynik w danej rundzie
			lds r17, wylosowana// wylosowana warto�� karty
			add r16, r17//dodajemy do zapisanego wyniku wylosowan� liczb�

			ldi r17, 0x00
			ldi r18, 5
			oczekiwanie12:
				call wyswietlanie//////////////wy�wietlam aktualny wynik gracza 1
				call wait_sec
			dec r18
			brne oczekiwanie12

			sts wynik_1, r16
			ldi r17, 0x15// to jest 21 :)
			cp r16, r17//sprawdzam czy wynik jest r�wny 21 bo je�li tak to gracz 1 wygra�
			brne nie_takie_same
				rjmp pierwszy_wygral//pierwszy_ma_21 wi�c wygra�
			nie_takie_same://je�li nie s� takie same to trzeba sprawdzi� czy to nie jest wi�cej ni� 21 bo wtedy przegrywa
				sub r17, r16//w tym celu odejmyj� od 21 obecny wynik bo je�li wynik tego dzia�ania b�dzie ujemny to znaczy �e nasz wynik>21
				brpl nie_ujemna //jesli ujemna to przepusci 
				rjmp drugi_wygral//	przegrywa_1 bo ma wi�cej ni� 21
			nie_ujemna:
		//przycisk_2: ///nie wcisniety przycisk2 usuwam przycisk_2

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////				
	gracz_2:
		lds r16, pass_2
		ldi r17, 0x01
		cp r16, r17
		breq nie_ujemnav//przycisk_2v


		ldi r16, 0x02
		sts nr_gracza, r16
blad2:
		sei
		call sprawdzanie_wejsc
		cli
		lds r16, nr_przycisku
		ldi r17, s_1
		cp r16, r17
		brne przycisk_1v///wci�ni�ty przycisk 1 przepuszcza
			ldi r16, 0x01
			sts pass_2, r16
			ldi r17, 0x00
			ldi r16, 0x03
			call wyswietlanie
			nop
			ldi r16, 0x04
			call wyswietlanie
			nop
			ldi r16, 0x03
			call wyswietlanie
			nop
			ldi r16, 0x04
			call wyswietlanie
			nop																													
			jmp nie_ujemnav//przycisk_2v//jesli b�dzie 1 to juz zeby 2 nie sprawzalo
		przycisk_1v:///nie wci�ni�ty przycisk 1
		ldi r17, s_2
		cp r16, r17
		brne blad2////wcisniety przycisk 2 przepuszcza
			lds r16, wynik_2
			lds r17, wylosowana
			add r16, r17

			ldi r17, 0x00
			ldi r18, 5
			oczekiwanie2:
				call wyswietlanie
				call wait_sec
			dec r18
			brne oczekiwanie2

			sts wynik_2, r16
			ldi r17, 0x15
			cp r16, r17
			brne nie_takie_samev
				rjmp drugi_wygral//rjmp drugi_ma_21
			nie_takie_samev:
				sub r17, r16
				brpl nie_ujemnav //jesli ujemna to przepusci chyba!!!!!!!!!!
				rjmp pierwszy_wygral//	rjmp przegrywa_2
			nie_ujemnav:
		//przycisk_2v: ///nie wcisniety przycisk2

lds r16, pass_1//////jesli b�d� dwa passy to koniec rundy i tu to sprawdzamy
lds r17, pass_2
ldi r18, 0x01
cp r16, r18
brne not_pass
	cp r17, r18
	brne not_pass
	rjmp dwa_passy
not_pass:

rjmp gracz_1///wracam do pocz�tku bo runda si� nie sko�czy�a
//sprawdzamy kto wygra�//////////////////////////////////////////////////////////////////////////////////////////////////////////
dwa_passy://///////////je�li s� dwa passy to trzeba sprawdzi� kto mia� wi�szy wynik lub czy nie mamy remisu
	lds r16, wynik_1
	lds r17, wynik_2
	cp r16, r17//por�wnujemy wyniki i je�li takie same to mamy remis
	brne rozne
		rjmp remis
	rozne://je�li r�ne to odejmujemy wynik gracza 1 od wyniku gracza 2
	sub r16, r17//je�li b�dzie ujemna to znaczy �e gracz 2 mia� wi�kszy wynik 
	brpl nieujemna //jesli ujemna to przepusci
		rjmp drugi_wygral
	nieujemna:
		rjmp pierwszy_wygral///je�li dodatnia to znaczy �e gracz 1 mia� wi�kszy wynik


	pierwszy_wygral:
			lds r16, win_1
			ldi r17, 0x01
			add r16, r17
			nop
			sts win_1, r16///pierwszy wygra� rund� wi�c dostaje punkt

			ldi r17, 0x01////na wy�wietlaczu wy�wietlaj� si� 0 i 1 na zmian� 
			ldi r16, 0x01
			call wyswietlanie
			nop
			ldi r17, 0x10
			ldi r16, 0x10
			call wyswietlanie
			nop
			ldi r17, 0x01
			ldi r16, 0x01
			call wyswietlanie
			nop
			ldi r17, 0x10
			ldi r16, 0x10
			call wyswietlanie
			nop	
			rjmp next
	drugi_wygral:
			lds r16, win_2
			ldi r17, 0x01
			add r16, r17
			nop
			sts win_2, r16//drugi wygra� runde wi�c dostaje punkt

			ldi r17, 0x02///na wy�wietlaczu wy�wietlaj� si� 0 i 2 na zmian� 
			ldi r16, 0x02
			call wyswietlanie
			nop
			ldi r17, 0x20
			ldi r16, 0x20
			call wyswietlanie
			nop
			ldi r17, 0x02
			ldi r16, 0x02
			call wyswietlanie
			nop
			ldi r17, 0x20
			ldi r16, 0x20
			call wyswietlanie
			nop	
			rjmp next
		remis:
			lds r16, win_1
			lds r18, win_2
			ldi r17, 0x01
			add r16, r17
			add r18, r17
			sts win_1, r16
			sts win_2, r18//dodawanie punkcik�w za rund� 1 i 2 

			ldi r17, 0x11///na wy�wietlaczu wy�wietlaj� si� 11 i 22 na zmian� 
			ldi r16, 0x22
			call wyswietlanie
			nop
			ldi r17, 0x22
			ldi r16, 0x11
			call wyswietlanie
			nop
			ldi r17, 0x11
			ldi r16, 0x22
			call wyswietlanie
			nop
			ldi r17, 0x22
			ldi r16, 0x11
			call wyswietlanie
			nop	
next:
			ldi r16, 0x01////wy�wietlamy numer gracza 1 i wy�wietlamy liczb� jego punkt�w trzeba klikn�� przycisk �eby przej�� dalej 
			sts nr_gracza, r16
			lds r16, win_1
			sts l_pkto, r16
			call sprawdzanie_wejsc

			ldi r16, 0x02//wy�wietlamy numer gracza 2 i wy�wietlamy liczb� jego punkt�w
			sts nr_gracza, r16
			lds r16, win_2
			sts l_pkto, r16

blad3:
			call sprawdzanie_wejsc
			//////////////////////////////////////sprawdzanie_wejsc jesli 3 to nowa gra zeruje liczniki jesli 4 to  stara gra nie kasuj� punkt�w 
			lds r16, nr_przycisku
			ldi r17, s_3
			cp r16, r17
			brne przycisk_3v///wci�ni�ty przycisk 3 przepuszcza
				ldi r16, 0x00
				sts win_1, r16
				sts win_2, r16///nowa gra usuwam punkty 
				jmp przycisk_4v//jesli b�dzie 3 to zeby juz 4 nie sprawzalo
			przycisk_3v:///nie wci�ni�ty przycisk 3
			ldi r17, s_4
			cp r16, r17
			brne blad3////wcisniety przycisk 4 przepuszcza
				nop/// stara gra nie usuwam punkt�w
			przycisk_4v: ///nie wcisniety przycisk4

ldi r16, 0x00//zeruje wszystko opr�cz liczby punkt�w bo czy zaczyna si� kolejna runda czy nowa gra to spratujemy od nowa
sts pass_1, r16
sts pass_2, r16
sts wynik_1, r16
sts wynik_2, r16
sts l_pkto, r16
sts l_wyl , r16
sts wylosowana, r16


rjmp main

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
stop: rjmp stop

sei
sprawdzanie_wejsc:////podprogram losuj�co czekaj�co decyzyjno wy�wietlaj�co 
push r16
push r17
push r18
push r19
push r20
push r21
	ldi r16, 0x00
	sts l_wyl, r16
	lds r16, l_pkto
	lds r17, nr_gracza
	ldi r20, 0x02
	ldi r21, 0x0F

	czekanienaodp:///je�li wci�niemy przycisk to wychodzimy z p�tli i zapisujemy kt�ry przycisk by� wci�ni�ty tylko dla drugiego aktywowane jest te� 
	sts l_wyl, r20//przerwanie i zczytuje wtedy aktualnie wylosowan� liczb� 
	inc r20
	cp r20, r21
	brne dalej
	ldi r20, 0x02
	dalej:
    call wyswietlanie
	
	ldi r18, 0b0111111	
	in r19, pinc
	cp r18, r19
	breq czekanienaodp
	sts nr_przycisku, r19
pop r21
pop r20
pop r19
pop r18
pop r17
pop r16
ret

wyswietlanie: 
push r16
push r17
push r18
push r19
push r20
	ldi r18, 60 
	call wait_sec 
	petla: 
//////////////////////seg1 
		ldi r19,0x01 
		ldi r20,0 
		sts var1, r19 
		sts var2, r20 
		sts var3, r17
		call seg1  
			call wait_sec 
///////////////////////seg2 
		ldi r19,0x02 
		ldi r20,1 
		sts var1, r19 
		sts var2, r20 
		sts var3, r17
		call seg1 
			call wait_sec 
////////////////////////////seg3 
		ldi r19,0x04 
		ldi r20,0 
		sts var1, r19 
		sts var2, r20 
		sts var3, r16
		call seg1 
			call wait_sec 
////////////////////////seg4 
		ldi r19,0x08 
		ldi r20,1 
		sts var1, r19 
		sts var2, r20	
		sts var3, r16 
		call seg1 
			call wait_sec 
		dec r18 
	brne petla 
pop r20
pop r19
pop r18
pop r17
pop r16
	ret  
///////////////////////////////////op�nienie 
wait_sec:   
	push r16   
	push r17   
	push r18   
	push r19   
	ldi r16,1  
		ldi r17,5
		opoznienie_1:   
		ldi r18, 26
			opoznienie_2:   
			ldi r19, 100
				opoznienie_3:   
				dec r19   
				brne opoznienie_3	   
			dec r18   
			brne opoznienie_2   
		dec r17  
		brne opoznienie_1   
	dec r16     
	brne wait_sec   
pop r19  
pop r18   
pop r17   
pop r16   
Ret  
/////////////////////////////////////////////////////////////////////////////////////  
seg1:							   
	push r16 
	push r17 
	push r18 
	ldi zl, low(2*prime) ;mno�enie przez dwa, celem uzyskania adresu w przestrzeni bajtowej 
	ldi zh, high(2*prime)     
	lds r16, var1 //////wybieranie wy�wietlacza 
	com r16                     
	out portb, r16  
	ldi r16, 0 /////////////wybieramy segmenty  
	lds r18, var2 
	cp r18, r16 
	lds r17, var3
	brne bezzamiany 
	swap r17  
bezzamiany: 
	andi r17, 0x0f  
	add zl, r17  
	adc zh, r16 
	lpm r16, z  
	com r16  
	out portd, r16 
	pop r18 
	pop r17  
	pop r16  
	ret
koniec: rjmp koniec
///////////////////////////////////////////////////////////////////////////////////
przerwanie:
push r16

	lds r16, l_wyl
	sts wylosowana, r16////w przerwaniu zczytywana jest liczna i zapisywana �eby mo�na j� by�o p�niej doda� do wyniku 

pop r16

reti