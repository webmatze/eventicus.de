/**
 * zanmantou API v0.1
 * copyright 2007 by Mathias Karstädt
 */

var Zanmantou = Class.create({

	/*
	 * Initialisiert den Player.
	 * Über den optionalen Config Parameter können weitere Einstellungen
	 * vorgenommen werden.
	 */
	initialize: function(container, config)
	{
		this.container = $(container);
		
		this.config = Object.extend({

			id: "zanmantou_" + (Math.random() * 100000000000000000),
			autorender: true,
			swfURL: "http://eventicus.de/wmplayer2/zanmantou.swf",
			xmlConfig: "http://eventicus.de/wmplayer2/config.xml",
			width: 320,
			height: 60,
			quality: "best",
			scale: "noscale",
			bgcolor: "#F1F1F1"

		}, config);
		
		if (this.config.autorender) {
			this.render(this.container);
		}
	},
	
	getPlayer: function()
	{
		return $(this.config.id);
	},
	
	init: function()
	{
		//this.getPlayer().JMAPI_init(this.config.id);
	},
	
	start: function(position)
	{
		if (!position) position = 0;
		this.getPlayer().JMAPI_start(position);
	},
	
	stop: function()
	{
		this.getPlayer().JMAPI_stop();
	},
	
	/*
	 * Rendert das OBJECT Element in den übergebenen Container.
	 */
	render: function(container)
	{
		$(container).update(this);
		this.init();
	},
	
	/*
	 * Erstellt das OBJECT Element mit den notwendigen Parametern.
	 */
	toElement: function() 
	{
		var flashPlayer = new Element("object",{ 
			id: this.config.id,
			type: "application/x-shockwave-flash",
			data: this.config.swfURL,
			height: this.config.height,
			width: this.config.width
		});
		flashPlayer.appendChild(
			new Element("param", {
				name: "allowScriptAccess",
				value: "sameDomain"
			})
		);
		flashPlayer.appendChild(
			new Element("param", {
				name: "movie",
				value: this.config.swfURL
			})
		);
		flashPlayer.appendChild(
			new Element("param", {
				name: "quality",
				value: this.config.quality
			})
		);
		flashPlayer.appendChild(
			new Element("param", {
				name: "scale",
				value: this.config.scale
			})
		);
		flashPlayer.appendChild(
			new Element("param", {
				name: "salign",
				value: "lt"
			})
		);
		flashPlayer.appendChild(
			new Element("param", {
				name: "bgcolor",
				value: this.config.bgcolor
			})
		);
		flashPlayer.appendChild(
			new Element("param", {
				name: "FlashVars",
				value: "config=" + this.config.xmlConfig
			})
		);
		return flashPlayer;
	}

});