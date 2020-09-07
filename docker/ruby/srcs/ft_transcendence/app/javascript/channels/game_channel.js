import consumer from "./consumer"
import matchmaking from "./matchmaking_channel"
import { interval_matchmaking } from "./notifications_channel"
import Render from "../custom/render"
import Paddle from "../custom/paddle"
import Ball from "../custom/ball"

var sub;
var logKey;

document.addEventListener('turbolinks:load', () => {
	if (sub)
	{
		if (logKey)
			document.removeEventListener('keypress', logKey);
		sub.unsubscribe();
	}
	var render = new Render(document.querySelector('.myCanvas'));
	if (render.canvas)
	{
		var spectate;
		var mynick = $("#nav-nickname").attr("usernickname");
		var me = mynick == $('.player1').attr("value") ? 0 : 1;
		var other = me == 1 ? 0 : 1;

		if (window.location.href.indexOf("spectate") != -1) //spec
			spectate = true;
		else
			spectate = false;

		var paddles = [null, null];
		var ball = null;
		var inputs_id = 0;
		var unverified_inputs = [];

		logKey = function(e) {
			e.preventDefault();
			var input;
			if (e.key == 'w')
			{
				input = { type: "paddle_up", id: inputs_id };
				sub.perform('input', input);
				unverified_inputs.push(input);
				if (paddles[me])
					paddles[me].goUp();
			}
			else if (e.key == 's')
			{
				input = { type: "paddle_down", id: inputs_id };
				sub.perform('input', input);
				unverified_inputs.push(input);
				if (paddles[me])
					paddles[me].goDown();
			}
			else if (e.key == ' ')
				sub.perform('space', { id: inputs_id });
			inputs_id++;
		}

		var server_interval = 5;

		function interpolate(entity) {
			var render_timestamp = new Date() - (1000.0 / server_interval);

			// Find the two authoritative positions surrounding the rendering timestamp.
			var buffer = entity.position_buffer;

			// Drop older positions.
			while (buffer.length >= 2 && buffer[1].time <= render_timestamp) {
				buffer.shift();
			}

			// Interpolate between the two surrounding authoritative positions.
			if (buffer.length >= 2 && buffer[0].time <= render_timestamp && render_timestamp <= buffer[1].time) {
				entity.posX = buffer[0].x + (buffer[1].x - buffer[0].x) * (render_timestamp - buffer[0].time) / (buffer[1].time - buffer[0].time);
				entity.posY = buffer[0].y + (buffer[1].y - buffer[0].y) * (render_timestamp - buffer[0].time) / (buffer[1].time - buffer[0].time);
			}
		}

		function update() {
			if (ball)
				interpolate(ball);
			if (spectate)
				interpolate(paddles[me]);
			if (paddles[other])
				interpolate(paddles[other]);
			if (ball && paddles && paddles[me] && paddles[other])
				render.renderWorld(ball, paddles);
		}

		var update_interval;
		
		function setUpdateRate(update_rate) {
			clearInterval(update_interval);
			if (update_rate != 0)
				update_interval = setInterval(update, 1000 / update_rate);
		}
			
		sub = consumer.subscriptions.create({
			channel: "GameChannel",
			game: $('.GameInfo').attr("value")
			}, {
			connected() {
				if (!spectate)
				{
					document.addEventListener('keypress', logKey);
					if ($("#matchmaking-alert").length)
					{
						matchmaking.perform('unsubscribe_queue');
						$("#matchmaking-alert").remove();
						clearInterval(interval_matchmaking);
					}
					$(".alert").each(function(index) {
						$(this).hide();
						if (index != 0)
							$(this).remove();
					});
				}
				setUpdateRate(50);
			},

			disconnected() {
			},

			received(data) {
				if (data.config)
				{
					render.config(data.config);
					render.canvas.width = data.config.canvas.width;
					render.canvas.height = data.config.canvas.height;
					render.resetCanvas();
				}
				if (data.status == "waiting")
				{
					render.updateGameStatus(data.msg_status);
					render.updateSpecCount(data.spec_count);
				}
				else if (data.status == "running")
				{
					render.updateGameStatus(data.msg_status);
					render.updateSpecCount(data.spec_count);
					render.updatePts(data.players);

					if (ball == null)
						ball = new Ball(data.ball)
					if (paddles[me] == null)
						paddles[me] = new Paddle(data.paddles[me], render.canvas.heigth)
					if (paddles[other] == null)
						paddles[other] = new Paddle(data.paddles[other], render.canvas.heigth)

					if (!spectate)
					{
						var last_server_input = data.inputs[me][data.inputs[me].length - 1];
						var j = 0;
						while (j < unverified_inputs.length)
						{
							if (unverified_inputs[j].id <= last_server_input)
								unverified_inputs.splice(j, 1);
							else
								j++;
						}
					}

					ball.position_buffer.push({time: new Date(), x: data.ball.posX, y: data.ball.posY});
					if (spectate)
						paddles[me].position_buffer.push({time: new Date(), x: data.paddles[me].posX, y: data.paddles[me].posY});
					else
						paddles[me].correctPos(unverified_inputs, data.paddles[me]);
					paddles[other].position_buffer.push({time: new Date(), x: data.paddles[other].posX, y: data.paddles[other].posY});
				}
				else if (data.status == "finished")
				{
					render.updatePts(data.players);
					render.updateGameStatus(data.msg_status);
					setUpdateRate(0);
					render.resetCanvas();
					sub.unsubscribe();
					if (!spectate)
						document.removeEventListener('keypress', logKey);
				}
			}
		});
	}

});
