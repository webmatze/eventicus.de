var eventicus = {
  description: "Add hCalendar data to eventicus.de",
  shortDescription: "eventicus.de",
  icon: "http://eventicus.de/favicon.ico",
  scope: {
    semantic: {
      "hCalendar" : "hCalendar"
    }
  },
  doAction: function(semanticObject, semanticObjectType) {
    return "http://localhost:3001/events/import?url=" + window.document.location.href;
  }
};
SemanticActions.add("eventicus", eventicus)