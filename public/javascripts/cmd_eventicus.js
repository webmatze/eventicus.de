CmdUtils.CreateCommand({
  name: "eventicus",
  homepage: "http://eventicus.com/",
  author: { name: "Mathias Karstädt", email: "mathias.karstaedt@gmail.com"},
  license: "MPL",
  description: "Extracts event data from page and creates a new event on eventicus.com.",
  help: "Find a page with event microformats and execute the command.",

  preview: function( pblock ) {
	var msg = 'Inserts event: "<i>${title}</i>"';
	pblock.innerHTML = CmdUtils.renderTemplate( msg, {title: Application.activeWindow.activeTab.document.title} );
  },

  execute: function() {
	Utils.openUrlInBrowser('http://www.eventicus.de/events/import/?url='+Application.activeWindow.activeTab.uri.spec);
  }
})