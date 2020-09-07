$(function() {
	$('#new_room_message').on('ajax:success', function(a, b,c ) {
		$(this).find('input[type="text"]').val('');
	});
});

document.addEventListener("turbolinks:load", () => {
	$("time.timeago").timeago();
	$('[name=toast-alert]').toast('show').attr('name', 'toast-alert-printed');
	window.controller = JSON.parse($('body').attr('controller'));
	window.mutes = JSON.parse($('body').attr('mutes'));
});

window.reloadWithTurbolinks = (function () {
	var scrollPosition

	function reload () {
		scrollPosition = [window.scrollX, window.scrollY]
		Turbolinks.visit(window.location.toString(), { action: 'replace' })
	}

	document.addEventListener('turbolinks:load', function () {
		if (scrollPosition) {
			window.scrollTo.apply(window, scrollPosition)
			scrollPosition = null
		}
	})

	return reload
})()

window.createToast = function createToast(message) {
	var content = "<div name='toast-alert' class='toast' role='alert' aria-live='assertive' aria-atomic='true' data-delay='10000'><div class='toast-body'>" + message + "</div></div>"
	$('div#toast-container > div').prepend(content);
	$('[name=toast-alert]').toast('show').attr('name', 'toast-alert-printed');
}