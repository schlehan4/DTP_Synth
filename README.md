# DTP_Synth

# Inhalt

1. [Projektbeschreibung](#projektbeschreibung)
2. [Hardware](#hardwarebeschreibung)
3. [Komponenten](#komponenten)

# Projektbeschreibung

In dieser Dokumentation wird die Funktionsweise eines Synthesizers erklärt, welcher eine Umwandlung von Daten auf einem Embedded-Board DE2-115 vornimmt, um anschliessend die umgewandelten Daten als Klang über Lautsprecher wiederzugeben. Diese Daten stammen von den Tastenanschlägen eines Alesis Keyboards und werden via Kabel an das Embedded-Board gesendet. Um die empfangenen Daten zu verarbeiten muss ein universeller asynchroner Empfänger implementiert werden. Diese Schnittstelle wird UART (Universal-Asynchronous-Receiver-Transmitter) genannt. Die verarbeiteten Tastendaten werden dann über den Line-out Ausgang mit dem Lautsprecher verbunden. Der Synthesizer besteht aus verschiedenen VHDL-Blöcken, die unabhängig voneinander geschrieben wurden.
Es wird das Embedded-Board DE2-115 von Altera verwendet. Die Konfigurationsdatei wird mittels USB vom PC auf das Board geladen. Die Versorgungsspannung dieses Boards beträgt 12 V. Die Daten vom Keyboard werden seriell via Kabel an einen Adapter und von diesem durch ein Flachbandkabel an das Entwicklungsboard gesendet. Die Lautstärke sowie verschiedene Tonfasetten können durch zwei, beziehungsweise drei Schalter eingestellt werden. Nach jeder neuen Einstellung muss jedoch das Embedded-Board mit einer initialise-Taste neu initialisiert werden. Ausserdem kann durch eine reset-Taste die gesamte Schaltung auf den Anfangswert zurückgesetzt werden.

# Hardwarebeschreibung

Die Hardwarebeschreibung in dieser Dokumentation wird der Datenfolge nach erklärt. Die Daten werden vom Keyboard auf das Embedded-Board gesendet werden. Durch den Block Infrastruktur werden die seriellen Daten mit der Clock synchronisiert und an die jeweiligen Blöcke weitergegeben. Die Blöcke verarbeiten die Daten bis schlussendlich der gewollte Klang an den Lautsprecher gesendet wird.
![overview_img](/img/synth.png)

## Infrastructure

Dieser Block enthält vier weitere VHDL-Blöcke, welche in ihm zusammengeführt und verbunden werden. Dabei handelt es sich jedoch nicht um vier unabhängige VHDL-Blöcke, sondern nur um zwei. Der Block Modulo Divider wird einmal und der Block Sync wird dreimal instanziiert.

### Modulo Divider

Der Modulo Divider teilt die 50 MHz Clock durch vier, um die Frequenz 12.5 MHz zu erhalten. Diese verkleinerte Frequenz wird gebraucht, da der Codec nur mit dieser Frequenz betrieben werden kann. Dementsprechend werden die 12.5 MHz als interne Clock festgelegt. Die ganze Hardwarebeschreibung wird auf diese neue Frequenz abgestimmt.

### Sync

Wie bereits erwähnt wird dieser Block dreimal instanziiert um die verschiedenen Signalgruppen, KEY_0 - und 1, die SW-Signale und den GPIO_26, einzeln zu synchronisieren. Anschliessend werden die Signale aus dem Infrastructure hinaus und an die Blöcke Uart Top, Path Control, I2S Master und Codec Controller weitergegeben. Das Synchronisieren wird durch das Hintereinanderschalten von D-Flip-Flops erreicht. Die Anzahl der D-Flip-Flops entspricht der jeweiligen Länge der Signale

### Uart Top

Der Uart Top Baustein erhält, wenn auf dem Keyboard eine Taste gedrückt wird, ein serielles 10Bit Signal. Dieses Signal wird vom Uart Top asynchron zur Clock Periode parallelisiert und an den Midi Controller weitergeleitet. Das Start- und das Endbit der empfangenen Daten werden nicht weitergeleitet, da sie für den Midi Controller nicht relevant sind. Durch ein früheres Projekt, bei welchem der universelle asynchrone Empfänger bereits gebraucht wurde, konnte erheblich an Arbeit eingespart werden. Aus dem alten Projekt wurden die unnötigen Blöcke gelöscht, so dass Uart Top nur noch die Blöcke Flanken Detect, Baud Tick, Uart Controller FSM und Shiftreg S2P enthält. Die Funktion dieser Blöcke ist in genannter Arbeit nachzulesen. Die Bezeichnung 50 MHz-Clock wurde zusätzlich bei jedem der Blöcke in Clk geändert und die Baudrate im Block Baud Tick wurde auch angepasst.

### Midi Controller

Der Midi Controller erhält vom Uart-Empfänger die mit der Clock synchronisierten und parallelisierten MIDI-Befehle. Diese spaltet er in ihre relevanten Informationen auf, schreibt sie in ein Datenarray und sendet sie an den Tone Generator weiter.
Wird eine Taste auf dem Keyboard gedrückt oder losgelassen erhält der Midi-Controller vom Uart drei parallele Achtbitdatenpakete. Diese bestehen aus einem Statusbyte, welches angibt ob die Taste gedrückt oder entlastet wurde und zwei Datenbytes. Das erste Datenbyte übermittelt die Tonhöhe der gedrückten Taste und das zweite die Geschwindigkeit mit welcher die Taste gedrückt beziehungsweise entlastet wurde.
![data_flow](/img/data_flow.png)
Ob es sich um ein Status- oder ein Datenbyte handelt ist am MSB zu erkennen, welches nur beim Statusbyte den Wert high hat. Ändert sich nichts an der Eingabe der Daten, so fällt das Statusbyte weg und es werden nur die beiden Datenbytes übertragen.
Die Bits 6 bis 4 des Statusbytes geben an, wie die folgenden beiden Datenbytes zu interpretieren sind. Hat der Statusbefehl (Bit 6 bis 4) den Wert 000 so wurde eine neue Note gespielt. Hat er den Wert 001 wurde eine Taste entlastet, die Note wird nicht mehr gespielt.
![midi_controller](/img/midi_controller.png)

Die oben beschriebenen Daten sowie das Signal Data Valid, welches jeweils high ist, wenn die Parallelisierung im Uart Controller erfolgreich abgeschlossen ist, liegen am Eingang des Midi-Controllers an. Die zuvor beschriebenen Datenpakete werden aufgetrennt und in Speicherregistern zwischengespeichert.
![midi_fsm](/img/midi_fsm.png)
Eine State Machine steuert das Aufspalten des Datenstromes. Diese befindet sich nach dem reset im Zustand Wait Status. Alle weiteren Zustandsänderungen sind in Abbildung 5 ersichtlich. Bei jeder Zustandsänderung werden die Daten in einem von vier Speicherregister zwischengespeichert. Das Data Flag Register gibt an ob ein neues Statusbyte übertragen
wird, das Statusregister speichert den Statusbefehl des neuen Statusbytes, das Register Data 1 speichert die Tonhöhe und das Register Data 2 speichert wie Tastengeschwindigkeit.
Die Daten in den Speicherregistern werden durch eine Ausgangslogik in ein Array von zehn Ausgangsregistern verteilt. Ein Ausgangsregister besteht aus einem 1-Bit Schieberegister in dem die Information gespeichert wird, ob dieses Ausgangsregister bereits belegt ist, einem 7-Bit Datenregister in welchem die Tonhöhe gespeichert wird und einem 7-Bit Datenregister für die Tasten-geschwindigkeit.
Wird ein neues Statussignal gesendet, wird der Inhalt des Data 1 Speicherregister mit dem Ausgangsregister für die Tonhöhe verglichen. Gibt es eine Übereinstimmung, so wird der Statusbefehl überprüft, hat dieses Signal den Wert 000 wird der Inhalt des Ausgangsregisters gelöscht. Gibt es keine Übereinstimmung und hat der Statusbefehl den Wert 001 so wird die gespielte Note in ein freies Ausgangsregister geschrieben. Ist kein freies Ausgangsregister vorhanden, so wird der Inhalt des Ausgangsregister überschrieben, welches bereits am längsten belegt war. 

## Tone Generator

![tone_gen](/img/tone_gen.png)
Die Aufgabe des Tone Generators ist die Tonerzeugung. Dafür erhält er am Eingang ein 7-bit Signal (note_vector), welches die Tonhöhe angibt, sowie auch ein Signal (tone_on_i), welches sagt wann ein Ton zu erzeugen ist. Der note_vector, mit welchem schlussendlich 128 verschiedene Töne erstellt werden können, wird zu Beginn durch den lut_midi2dds Baustein geführt. Dort findet mithilfe einer Lookup Tabelle eine Umwandlung in ein 19-bit breites Signal namens phi_incr_i statt. Dieses entspricht nun der darzustellenden Frequenz und wird folglich an den DDS Baustein weitergegeben.

![dds](/img/dds.png)
Nebst phi_incr_i liegen noch weitere Steuersignale als Input an den DDS an. Diese werden zur Lautstärkeregelung (attenu_i), zur Änderung des Instrumentes (instr) sowie zur zeitlichen Synchronisation, genauer gesagt, wann ein Ton erzeugt werden muss (tone_on_i) gebraucht. Am Anfang des DDS Blocks wird phi_incr_i mithilfe des Counter Register und einer Lookup Tabelle zu einem 16-bit breitem Wert umgewandelt, welcher nun im zeitlichen Ablauf eine Sinuswelle darstellt. Dieser Wert wird anschliessend in den Attenuator Block gebracht, wo durch eine Amplitudenverschiebung die Lautstärke geregelt werden kann. Diese Regelung wird durch zwei Schalter des Embedded-Boards betrieben, dementsprechend kann zwischen vier verschiedenen Lautstärkeoptionen geschaltet werden. Ausserdem steuert das tone_on_i Signal im Attenuator zu welchem Zeitpunkt ein Ton ausgegeben werden muss.
Als zusätzliche Funktion kann die Lookup Tabelle, mit welcher im Normalzustand ein Sinus erzeugt wird, ausgetauscht werden. Dies wird durch das Signal instr gemacht, welches auf drei Schalter des Embedded-Boards führt. Nebst dem Sinus können auch eine Trompete, eine Oboe, ein Piano oder eine Orgel simuliert werden.
Zur Nutzung von bis zu zehn Tasten gleichzeitig wurden insgesamt zehn DDS implementiert. Sobald mehrere Tasten gedrückt werden sind also mehrere DDS im Einsatz. Die entsprechenden Ausgangssignale werden durch einen Addierer zu einem vereint, welches schlussendlich als Ausgang des Tone Generator dient (tone_gen_out).

## Path Control

Der Block Path Control besteht aus zwei Multiplexer und schaltet, abhängig vom Signal sw_sync(3), die vom Tone Generator erhaltenen Signale dds_l_i/dds_r_I oder die vom I2S Master erhaltenen Signale zu den Parallel- zu Seriellwandlern des I2s Masters durch.  So kann er entweder die mit dem Keyboard eingegebenen Töne weiterleiten oder ein Audiosignal vom Codec Controller via I2S Master wieder an den Codec Controller zurücksenden. Hat sw_sync(3) den Wert 0 so werden die vom DDS kommenden Signale durchgeschalten, hat es den Wert 1 werden die vom I2S Master kommenden Signal wieder zu diesem zurückgeführt.
![path_control](/img/path_control.png)

## I2S Master

![I2s-Master](/img/i2s_master.png)
Der I2S Master konvertiert serielle Signale vom Audio Codec zu parallelen Signalen, die er zum Path Control weiterleitet. Gleichzeitig konvertiert der I2S Master parallele Signale, die er vom Path Control erhält, in serielle Signale und leitet diese wiederum an den Audiocodec weiter (siehe Abbildung 9). Der Block besteht aus zwei Parallel- zu Seriell- und zwei Seriell- zu Parallelwandlern. Die Steuerung der Wandler besteht aus einer Bit Clock einem Aufwärtszähler (Bit Counter) und einem Decoder.

## Clock Divider und Bit Counter

Der Block Clock Divider teilt die Clockfrequenz durch zwei, indem es bei jeder steigenden Taktflanke das invertierte am Eingang liegende Ausgangssignal des Flip-Flops zum Ausgang durchschaltet.

Der Bit Counter zählt auf jede zweite Clockperiode in Einerschritten von 0 bis 127.

## I2S Decoder

Der I2S Decoder steuert die Seriell- zu Parallel- und Parallel- zu Seriellwandler. Abhängig vom Inhalt des Bit Counters lädt er Bits in die Seriell- zu Parallelwandler, sendet das Signal, welches die Schieberegister zum shiften bringt und steuert den Multiplexer, welcher die Daten der Parallel- zu Seriellwandler zum Audio Codec durchschaltet.
Der Decoder sendet an die Schieberegister folgende Signale: Load_i ist high, wenn der Bit-Counter 0 ausgibt, shift_l ist high zwischen 1 und 16, shift_r ist high, zwischen 65 und 80. Zwischen 81 und 127 sind alle drei Signale low. Zudem wird ein Signal mit dem Namen Ws generiert, welches dem sechsten Bit des Bitcountersignals entspricht. Das heisst Ws ist low, wenn Bit-count<64 und high, wenn Bit-count>=64.
Wenn load_i high ist, wird das vom Path Control kommende Signal auf die Eingänge der Beiden Seriell- zu Parallelwandler gelegt. Ist Shift_l high arbeiten je ein Seriell- zu Parallel- und ein Parallel- zu Seriellwandler. Ist shift_r high arbeiten die anderen beiden.
Das Signal Ws schaltet den Ausgang eines der beiden Parallel- zu Seriellwandlern zum Eingang des Audio Codecs durch. Ist das Signal Ws low arbeitet das linke Schieberegister, ist es high arbeitet das rechte.

## Codec Controller

![codec_controller](/img/codec_fsm.png)
Mit dem Codec Controller ist es möglich, den Audio Output komplett stumm zu schalten, sowie auch nur einzeln den linken oder rechten Output zu aktivieren. Dafür wird eine Zustandsmaschine sowie auch ein Case Statement benötigt. Die Zustandsmaschine besteht aus drei Zuständen. Nach dem reset oder wenn das Signal initialise low ist, befindet sie sich im Zustand idle. Sobald initialise high ist, geht die Zustandsmaschine in start_write über. In diesem Zustand wird dem I2C Master gesagt, dass Daten übertragen werden und in den nächsten Zustand wait gewechselt wird. Wenn die Daten im nächsten Zustand empfangen wurden, werden die Zustände start_write und wait noch achtmal wiederholt. Wenn die Daten nicht richtig ankommen wechselt die Zustandsmaschine wieder in idle.
Die gesendeten Daten werden als Datenvektor mit dem Case Statement zusammengesetzt. Anhand der Schalterstellung der ersten drei Schalter des Board wird entschieden ob der Ausgang stumm geschalten wird oder nicht. Der I2C Master verarbeitet anschliessend diese Daten und gibt sie an den Audio Codec weiter.

## Audio Codec

Der Audio Codec wird einige Male erwähnt jedoch kann über ihn nur gesagt werden, dass er ein Bestandteil des Embedded-Boards ist. Dementsprechend also eine Hardwarekomponente (siehe Abbildung 1).
