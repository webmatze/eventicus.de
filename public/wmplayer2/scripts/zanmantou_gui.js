/**
 * zanmantou GUI v0.1
 * copyright 2007 by Mathias Karstädt
 */
 

//Wenn kein FireBug installiert, dann simulieren (nur für Debug Zwecke)
if (null == console) {
	var console = {
		log: function(text) {
			//alert(text);
		}
	};
}

 
/**
 * ZanmantouGUI Klasse.
 * Bildet alle Funktionen für den Player ab
 */
var ZanmantouGUI = Class.create({
	
	/**
	 * Konstruktor.
	 * playerId - Die id des DIVs, in welchem der Player dargestellt werden soll
	 * config - Ein Konfigurationsobjekt (siehe Beschreibung im Konstruktor)
	 */
	initialize: function(playerId, config)
	{
		this.container = $(playerId);
		
		//Hier werden die Standardwerte der Konfiguration initialisiert
		//Die einzelnen Werte könne durch das übergebene config Objekt
		//überschrieben werden.
		this.config = Object.extend({
		
			// autorender (true | false) soll der Player automatisch gerendert werden
			autorender: true,
			
			// autostart (true | false) soll der erste Song automatisch gestartet werden
			autostart: false,
			
			// repeat (single | all | false) soll der Song (alle Songs) wiederholt werden
			repeat: false,
			
			// width (Pixel) Breite des Players
			width: 200,
			
			// height (Pixel) Höhe des Players
			height: 300,
			
			// data (Array von Song Objekten) enthält Informationen zu allen Songs
			data: []
			
		}, config);
		
		//In jedem Song den Player bekannt machen
		this.config.data.invoke("setPlayer", this);
		
		if (this.config.autorender) {
			this.render(this.container);
		} 
	},

	/**
	 * Song aktivieren.
	 */
	activateSong: function(song)
	{
		var activate  = ((this.activeSong && this.activeSong != song) || (!this.activeSong));
		if (activate) {
			song.activate();
			if (this.activeSong) {
				this.deactivateSong(this.activeSong);
				this.onStopPressed();
			} else {
				this.playButton.setDisabled(false);
			}
			this.activeSong = song;
			this.playerTitle.update(song.title);
		}
	},

	/**
	 * Song aktivieren.
	 */
	deactivateSong: function(song)
	{
		song.deactivate();
	},

	/**
	 * auf Play gedrückt.
	 */
	onPlayPressed: function()
	{
		console.log("play");
		this.playerTitle.update(this.activeSong.title + " (playing)");
		this.playButton.setDisabled(true);
		this.stopButton.setDisabled(false);
		this.flashPlayer.start();
	},

	/**
	 * auf Stop gedrückt.
	 */
	onStopPressed: function()
	{
		console.log("stop");
		this.playerTitle.update(this.activeSong.title);
		this.playButton.setDisabled(false);
		this.stopButton.setDisabled(true);
		this.flashPlayer.stop();
	},
	
	/**
	 * initialisiert den FlashPlayer, nachdem die GUI gerendert wurde.
	 */
	initFlashPlayer: function()
	{
		this.flashPlayer = new Zanmantou(this.flashPlayerCont);
	},
	
	/**
	 * Rendert den Player in das angegebene Element.
	 */
	render: function(container)
	{
		$(container).update(this);
		this.initFlashPlayer();
	},
	
	/**
	 * Erstellt den Player und gibt ihn als HTMLElement zurück.
	 */
	toElement: function()
	{
		var cont = new Element("div", { class: "zanmantou" });
		cont.setStyle("width: " + this.config.width + "px; height: " + this.config.height + "px;");
		
		//PlayerNavigation rendern
		var player = new Element("div", { class: "player" });
		
		//Title
		this.playerTitle = new Element("div", { class: "title" });
		this.playerTitle.update("Bitte einen Song auswählen!");
		player.insert({bottom:this.playerTitle});

		//Play Button
		this.playButton = new Button("Play", this.onPlayPressed.bind(this));
		player.insert({bottom:this.playButton});
		this.playButton.setDisabled(true);

		//Stop Button
		this.stopButton = new Button("Stop", this.onStopPressed.bind(this));
		player.insert({bottom:this.stopButton});
		this.stopButton.setDisabled(true);
		
		player.insert({bottom: new Element("div", {style: "clear: both"})});
		
		//Songliste rendern
		var songs = new Element("div", { class: "songs" });
		this.config.data.each(function(song) {
			songs.insert({bottom: song})
		});
		
		cont.appendChild(player);
		cont.appendChild(songs);
		
		//den eigentlichen Player rendern
		this.flashPlayerCont = new Element("div", { class: "flash-player"});
		cont.appendChild(this.flashPlayerCont);
		
		return cont;
	}
	
});


/**
 * Button Klasse.
 * Wird verwendet um einen Button zu simulieren.
 */
var Button = Class.create({

	initialize: function(name, handler) 
	{
		this.name = name;
		this.handler = handler;
		this.disabled = false;
	},

	/**
	 * Song als aktiv markieren.
	 */
	activate: function()
	{
		if (!this.disabled) {
			this.button.removeClassName("over");
			this.button.addClassName("active");
		}
	},

	/**
	 * Button als inaktiv markieren.
	 */
	deactivate: function()
	{
		this.button.removeClassName("active");
	},
	
	/**
	 * Button als disabled markieren.
	 */
	setDisabled: function(disable)
	{
		this.disabled = disable;
		if (disable) {
			this.deactivate();
			this.button.removeClassName("over");
			this.button.addClassName("disabled");
		} else {
			this.button.removeClassName("disabled");
		}
	},

	/**
	 * Wird ausgeführt, wenn auf einen Button geklickt wird.
	 */
	onMouseClick: function(e)
	{
		if (!this.disabled) this.handler();
	},

	/**
	 * Wird ausgeführt, Maus über Button fährt.
	 */
	onMouseOver: function(e)
	{
		if (!this.disabled && !this.button.hasClassName("active")) this.button.addClassName("over");
	},

	/**
	 * Wird ausgeführt, wenn Maus vom Button runterfährt.
	 */
	onMouseOut: function(e)
	{
		if (!this.disabled && !this.button.hasClassName("active")) this.button.removeClassName("over");
	},
	
	toElement: function()
	{
		this.button = new Element("div", { class: "button" });
		this.button.update(this.name);
		Event.observe(this.button, "click", this.onMouseClick.bindAsEventListener(this));
		Event.observe(this.button, "mouseover", this.onMouseOver.bindAsEventListener(this));
		Event.observe(this.button, "mouseout", this.onMouseOut.bindAsEventListener(this));
		return this.button;
	}

});


/**
 * Song Klasse.
 * Wird verwendet um alle Daten zu einem Song abzubilden.
 */
var Song = Class.create({

	/**
	 * Konstruktor.
	 * title - Der Songtitel
	 * url - Die URL der MP3 Datei
	 * config - Ein Konfigurationsobjekt (siehe Beschreibung im Konstruktor)
	 */
	initialize: function(title, url, config)
	{
		this.title = title;
		this.url = url;
		
		//Hier werden die Standardwerte der Konfiguration initialisiert
		//Die einzelnen Werte könne durch das übergebene config Objekt
		//überschrieben werden.
		this.config = Object.extend({
			
			//startAt (Sekunden) die Postition an welcher der Song gestartet wird
			startAt: 0,
			
			//stopAt (Sekunden | false) die Position an welcher der Song gestopt wird
			stopAt: false
			
		}, config);
	},
	
	/**
	 * Setzt eine Referenz auf das Player Objekt, in dem dieser Song läuft.
	 */
	setPlayer: function(player)
	{
		this.player = player;
	},

	/**
	 * Song als aktiv markieren.
	 */
	activate: function()
	{
		this.song.removeClassName("over");
		this.song.addClassName("active");
	},

	/**
	 * Song als inaktiv markieren.
	 */
	deactivate: function()
	{
		this.song.removeClassName("active");
	},

	/**
	 * Wird ausgeführt, wenn auf einen Song geklickt wird.
	 */
	onMouseClick: function(e)
	{
		this.player.activateSong(this);
	},

	/**
	 * Wird ausgeführt, wenn auf einen Song geklickt wird.
	 */
	onMouseOver: function(e)
	{
		if (!this.song.hasClassName("active")) this.song.addClassName("over");
	},

	/**
	 * Wird ausgeführt, wenn auf einen Song geklickt wird.
	 */
	onMouseOut: function(e)
	{
		if (!this.song.hasClassName("active")) this.song.removeClassName("over");
	},
	
	/**
	 * Erstellt den Song und gibt ihn als HTMLElement zurück.
	 */
	toElement: function()
	{
		this.song = new Element("div", { class: "song"});
		this.song.update(this.title);
		Event.observe(this.song, "click", this.onMouseClick.bindAsEventListener(this));
		Event.observe(this.song, "mouseover", this.onMouseOver.bindAsEventListener(this));
		Event.observe(this.song, "mouseout", this.onMouseOut.bindAsEventListener(this));
		return this.song;
	}

});