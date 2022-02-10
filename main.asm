;
.EQU s_1=0b0111110//przycisk 1
.EQU s_2=0b0111101//przycisk 2
.EQU s_3=0b0111011//przycisk 3
.EQU s_4=0b0110111// przycisk 4

.CSEG 
.ORG 0 
	rjmp prog_start //pocz¹tek programu
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
////pocz¹tek programu// stos //////////////////////////////////////////////////////////////////////////////////////////
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
///ustawianie wejœæ/wyjœæ ////////////////////////////////////////////////////////////////////////////////////////
	ldi r16, $ff    
	out ddrb, r16    
	out ddrd, r16  
	out portc, r16 
	ldi r16, $00    
	out ddrc, r16
//zerowanie zmiennych i rejestrów ¿eby nie pojawia³y siê jakieœ nieznane wartoœci//////////////////////////////////////////////////////////////////////////////////////////////////////////
	ldi r16, 0x00 
	ldi r17, 0x00 
	sts wynik_1, r16
	sts wynik_2, r16
	sts l_pkto, r16
	sts win_1, r16
	sts win_2, r16
//pocz¹tek gry//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
main:  
	gracz_1:////////////////////////////instrukcje dla gracza pierwszego
		lds r16, pass_1///////////sprawdzam czy gracz 1 nie zpassowa³ jeœli tak to pomijany jest jego ruchy do momentu a¿ drugi przegra lub te¿ zpassuje lub trafi 21
		ldi r17, 0x01
		cp r16, r17
		breq gracz_2


		ldi r16, 0x01
		sts nr_gracza, r16////wyœwietlamy numer gracza na 7-segmentowym 
blad1:
		sei
		call sprawdzanie_wejsc//podprogram w którym oczekujemy na decyzjê gracza i dokonywane jest losowanie 
		cli

		lds r16, nr_przycisku//sprawdzamy który przycisk zosta³ wciœniêty i od razu podejmuemy odpowiednie dzia³ania
		ldi r17, s_1
		cp r16, r17
		brne przycisk_1///wciœniêty przycisk 1 przepuszcza ////oznacza pass 1 gracza a jak nie to idzie losowania
			ldi r16, 0x01
			sts pass_1, r16//pass dla 1 gracza ustawiany na jeden oznacza ¿e nie bêdzie móg³ wykonywaæ ruchu do zakoñczenia rundy

			ldi r17, 0x00///////////////////////na wyœwietlaczu wyœwietlana jest sekwencja liczb 4,3,4,3
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
			jmp gracz_2//jesli bêdzie 1 to juz dla 2  i skacze w sumie do gracza 2 przycisk_2 zamieniam na gracz_2
		przycisk_1:///nie wciœniêty przycisk 1 sprawdzamy czy wciœniêty jest 2 przycisk
		ldi r17, s_2
		cp r16, r17
		brne blad1////wcisniety przycisk 2 przepuszcza jesli nie to jeszcze raz trzeba wcisn¹c przycisk bo nie jest to 1 ani 2
			lds r16, wynik_1//zapisany wynik w danej rundzie
			lds r17, wylosowana// wylosowana wartoœæ karty
			add r16, r17//dodajemy do zapisanego wyniku wylosowan¹ liczbê

			ldi r17, 0x00
			ldi r18, 5
			oczekiwanie12:
				call wyswietlanie//////////////wyœwietlam aktualny wynik gracza 1
				call wait_sec
			dec r18
			brne oczekiwanie12

			sts wynik_1, r16
			ldi r17, 0x15// to jest 21 :)
			cp r16, r17//sprawdzam czy wynik jest równy 21 bo jeœli tak to gracz 1 wygra³
			brne nie_takie_same
				rjmp pierwszy_wygral//pierwszy_ma_21 wiêc wygra³
			nie_takie_same://jeœli nie s¹ takie same to trzeba sprawdziæ czy to nie jest wiêcej ni¿ 21 bo wtedy przegrywa
				sub r17, r16//w tym celu odejmyjê od 21 obecny wynik bo jeœli wynik tego dzia³ania bêdzie ujemny to znaczy ¿e nasz wynik>21
				brpl nie_ujemna //jesli ujemna to przepusci 
				rjmp drugi_wygral//	przegrywa_1 bo ma wiêcej ni¿ 21
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
		brne przycisk_1v///wciœniêty przycisk 1 przepuszcza
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
			jmp nie_ujemnav//przycisk_2v//jesli bêdzie 1 to juz zeby 2 nie sprawzalo
		przycisk_1v:///nie wciœniêty przycisk 1
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

lds r16, pass_1//////jesli bêd¹ dwa passy to koniec rundy i tu to sprawdzamy
lds r17, pass_2
ldi r18, 0x01
cp r16, r18
brne not_pass
	cp r17, r18
	brne not_pass
	rjmp dwa_passy
not_pass:

rjmp gracz_1///wracam do pocz¹tku bo runda siê nie skoñczy³a
//sprawdzamy kto wygra³//////////////////////////////////////////////////////////////////////////////////////////////////////////
dwa_passy://///////////jeœli s¹ dwa passy to trzeba sprawdziæ kto mia³ wiêszy wynik lub czy nie mamy remisu
	lds r16, wynik_1
	lds r17, wynik_2
	cp r16, r17//porównujemy wyniki i jeœli takie same to mamy remis
	brne rozne
		rjmp remis
	rozne://jeœli ró¿ne to odejmujemy wynik gracza 1 od wyniku gracza 2
	sub r16, r17//jeœli bêdzie ujemna to znaczy ¿e gracz 2 mia³ wiêkszy wynik 
	brpl nieujemna //jesli ujemna to przepusci
		rjmp drugi_wygral
	nieujemna:
		rjmp pierwszy_wygral///jeœli dodatnia to znaczy ¿e gracz 1 mia³ wiêkszy wynik


	pierwszy_wygral:
			lds r16, win_1
			ldi r17, 0x01
			add r16, r17
			nop
			sts win_1, r16///pierwszy wygra³ rundê wiêc dostaje punkt

			ldi r17, 0x01////na wyœwietlaczu wyœwietlaj¹ siê 0 i 1 na zmianê 
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
			sts win_2, r16//drugi wygra³ runde wiêc dostaje punkt

			ldi r17, 0x02///na wyœwietlaczu wyœwietlaj¹ siê 0 i 2 na zmianê 
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
			sts win_2, r18//dodawanie punkcików za rundê 1 i 2 

			ldi r17, 0x11///na wyœwietlaczu wyœwietlaj¹ siê 11 i 22 na zmianê 
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
			ldi r16, 0x01////wyœwietlamy numer gracza 1 i wyœwietlamy liczbê jego punktów trzeba klikn¹æ przycisk ¿eby przejœæ dalej 
			sts nr_gracza, r16
			lds r16, win_1
			sts l_pkto, r16
			call sprawdzanie_wejsc

			ldi r16, 0x02//wyœwietlamy numer gracza 2 i wyœwietlamy liczbê jego punktów
			sts nr_gracza, r16
			lds r16, win_2
			sts l_pkto, r16

blad3:
			call sprawdzanie_wejsc
			//////////////////////////////////////sprawdzanie_wejsc jesli 3 to nowa gra zeruje liczniki jesli 4 to  stara gra nie kasujê punktów 
			lds r16, nr_przycisku
			ldi r17, s_3
			cp r16, r17
			brne przycisk_3v///wciœniêty przycisk 3 przepuszcza
				ldi r16, 0x00
				sts win_1, r16
				sts win_2, r16///nowa gra usuwam punkty 
				jmp przycisk_4v//jesli bêdzie 3 to zeby juz 4 nie sprawzalo
			przycisk_3v:///nie wciœniêty przycisk 3
			ldi r17, s_4
			cp r16, r17
			brne blad3////wcisniety przycisk 4 przepuszcza
				nop/// stara gra nie usuwam punktów
			przycisk_4v: ///nie wcisniety przycisk4

ldi r16, 0x00//zeruje wszystko oprócz liczby punktów bo czy zaczyna siê kolejna runda czy nowa gra to spratujemy od nowa
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
sprawdzanie_wejsc:////podprogram losuj¹co czekaj¹co decyzyjno wyœwietlaj¹co 
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

	czekanienaodp:///jeœli wciœniemy przycisk to wychodzimy z pêtli i zapisujemy który przycisk by³ wciœniêty tylko dla drugiego aktywowane jest te¿ 
	sts l_wyl, r20//przerwanie i zczytuje wtedy aktualnie wylosowan¹ liczbê 
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
///////////////////////////////////opóŸnienie 
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
	ldi zl, low(2*prime) ;mno¿enie przez dwa, celem uzyskania adresu w przestrzeni bajtowej 
	ldi zh, high(2*prime)     
	lds r16, var1 //////wybieranie wyœwietlacza 
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
	sts wylosowana, r16////w przerwaniu zczytywana jest liczna i zapisywana ¿eby mo¿na j¹ by³o póŸniej dodaæ do wyniku 

pop r16

reti