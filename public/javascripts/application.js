// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

Event.observe(window, 'load', function() {
	//find the current users location and show it in the Where form field.
	if ($('where')) {
		var client = new simplegeo.ContextClient('kGfq4LhbLtxj7d3Cmph3QHZyngUK7NGn');
		client.getLocation({enableHighAccuracy: true}, function(err, position) {
		    if (err) {
		        console.log(err);
		    } else {
						console.log(position);
						client.getContext(position.coords.latitude, position.coords.longitude, function(err, data) {
						    if (err) {
						        console.error(err);
						    } else {
						        console.log(data);
										$('where').value = data.features[0].name;
						    }
						});
		    }
		});
	}
})