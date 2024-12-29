[English version](https://github-com.translate.goog/haykonus/BIC-A5105-Demos?_x_tr_sl=de&_x_tr_tl=en&_x_tr_hl=de&_x_tr_pto=wapp)
# INHALT

[GleEst für BIC-A5105](https://github.com/haykonus/BIC-A5105-Demos?tab=readme-ov-file#gleest-f%C3%BCr-bic-a5105)

<br>

# GleEst für BIC-A5105

![Demo](https://github.com/haykonus/BIC-A5105-Demos/blob/main/gleest_BIC/Bilder/gleest_BIC.gif)

Dieses Programm für den [BIC-A5105](https://www.robotrontechnik.de/index.htm?/html/computer/a5105.htm) basiert auf [GleEst](https://zxart.ee/eng/software/demoscene/intro/256b-intro/gleest/) für den ZX-Spectrum 128, programmiert von Oleg Senin (bfox, St.Petersburg, Russia). Seine 256 Byte-Demo enthält im Original eine Sound-Ausgabe über den AY-3-8912 und setzt die Farb-Attribute des ZX-Spectrum. Der Algorithmus wurde extrahiert, leicht modifiziert (RAM-Speicherbedarf optimiert) und der Grafik-Effekt, inkl. Farben, an den BIC-A5105 angepasst. Dafür wurde der 320x200 Pixel-Mode mit 16 Farben/Pixel gewählt. 

Der Sound-Effekt ist nicht implementiert. Der BIC besitzt einen Soundchip, der auch zur AY-Familie kompatibel sein soll, jedoch gab es immer wieder Hinweise, dass die Kompatibilität nicht in allen BIC-Ausführungen gegeben ist. In einer späteren Version könnte der Sound-Effekt noch implementiert werden. 

Zum Assemblieren wurde der [Arnold-Assembler](http://john.ccac.rwth-aachen.de:8000/as/) unter Windows 11 verwendet.

> [!TIP]
> Das Programm kann mit Drücken (2 mal) der STOP-Taste beendet werden.

## Vorausetzungen

- BIC-A5105
- oder [JKCEMU](http://www.jens-mueller.org/jkcemu/index.html)

## Schnellstart

> [!CAUTION]
> Die Links unten anklicken und danach den Download-Button (Download raw file) im Github klicken, um die Datei zu laden.

- [gleest_BIC_8100H.bin](https://github.com/haykonus/BIC-A5105-Demos/blob/main/gleest_BIC/gleest_BIC_8100H.bin)
im JKCEMU auf Adresse 8100H laden und starten mit:

```
defusr0=&H8100:x=usr0(0)
```
- [gleest_BIC_8100H.wav](https://github.com/haykonus/BIC-A5105-Demos/blob/main/gleest_BIC/gleest_BIC_8100H.wav)
im BIC oder JKCEMU als Audio-File laden und starten mit:

```
bload"cas:gleest",r
```

- [gleest.rmc](https://github.com/haykonus/BIC-A5105-Demos/blob/main/gleest_BIC/gleest.rmc)
im BIC oder JKCEMU über Diskette laden und starten mit:

```
bload"gleest.rmc",r
```

## Quellen

Dieses Projekt nutzt Infos und Software aus den u.g. Quellen. 

https://www.sax.de/~zander/bic/bic_hw.html

https://www.sax.de/~zander/bic/bic_bw.html

https://zxart.ee/eng/software/demoscene/intro/256b-intro/gleest/


