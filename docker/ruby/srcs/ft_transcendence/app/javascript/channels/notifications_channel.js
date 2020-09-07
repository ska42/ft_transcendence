import consumer from "./consumer"
import matchmaking from "./matchmaking_channel"

var timer_queue;
var interval_matchmaking;

var add_notif = function(text, new_id)
{
	let new_one = $(".alert").last().clone();
	new_one.attr("id", new_id);
	$("#alerts-div").append(new_one);
	new_one.find("#alert-text").html(text);
	return (new_one);	
}

var clear_matchmaking = function()
{
	matchmaking.perform("unsubscribe_queue");
	clearInterval(interval_matchmaking);
};

var notif = consumer.subscriptions.create("NotificationsChannel", {

	connected() {
	  	console.log("connected to notif");
	},

	disconnected() {
	},

	received(data) {
		console.log(data);
		if (data.type && data.type == "redirect")
			Turbolinks.visit("/game/" + data.game.id);
		else if (data.type && data.type == "invitation")
			add_notif(data.message + " <a href='/game/" + data.game.id + "'>Click to join</a>").show();
		else if (data.type && data.type == "in_queue")
		{
			if (!$("#matchmaking-alert").length)
			{
				var text = data.message + " - " + "<span id='time_queue'>00:00</span>";
				var new_notif = add_notif(text, "matchmaking-alert");
				var timer_start = Date.now();
				interval_matchmaking = setInterval(function() {
					console.log("interval");
					var res = (Date.now() - timer_start) / 1000;
					var minutes = Math.floor(res / 60) % 60;
					var seconds = Math.floor(res % 60);
					if (minutes < 10)
						minutes = "0" + minutes;
					if (seconds < 10)
						seconds = "0" + seconds;
					$("#time_queue").html(minutes+":"+seconds);
				}, 1000);
				new_notif.find(".close").click(clear_matchmaking);
				new_notif.show();
			}
		}
		else
		{
			createToast("New notification: " + data.title + "<br><a href=" + data.href + ">Open</a>");
		}
	}
});

document.addEventListener('turbolinks:load', () => {
	var button = $("#game_invite");
	var default_button = $("#default");
	if (button)
	{
		button.click(function() {
			console.log("clicked");
			var canvas_width = $("#cwidth").val();
			var canvas_height = $("#cheight").val();
			var ball_radius = $("#bradius").val();
			var max_points = $("#max_points").val();
			var to_nickname = $("#nickname").html();
			notif.perform('send_notif', {
				type: "play_casual",
				to: to_nickname,
				canvas: {
					width: canvas_width,
					height: canvas_height
				},
				ball: {
					radius: ball_radius
				},
				max_points: max_points
			});
		});
	}
	if (default_button)
	{
		default_button.click(function() {
			var canvas_width = $("#cwidth").val(600);
			var canvas_height = $("#cheight").val(600);
			var ball_radius = $("#bradius").val(10);
			var max_points = $("#max_points").val(5);
		});
	}
});

export { interval_matchmaking, notif };

