import consumer from "./consumer"
import { interval_matchmaking, notif } from "./notifications_channel"

var matchmaking;

export default matchmaking = consumer.subscriptions.create("MatchmakingChannel", {
	connected() {
	},

	disconnected() {
	},

	received(data) {
		$("#matchmaking-alert").remove();
		clearInterval(interval_matchmaking);
		Turbolinks.visit("/game/" + data.game.id);
	}
});

document.addEventListener('turbolinks:load', () => {
	$("#play_matchmaking").click(function() {
		matchmaking.perform('register_to_queue');
		notif.perform('send_notif', {
			type: "play_matchmaking"
		});
	});
});
