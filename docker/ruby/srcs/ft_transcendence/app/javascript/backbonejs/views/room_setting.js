window.app.views.RoomSetting = Backbone.View.extend({
	tagName: 'div',
	initialize: function() {
		this.template = _.template($('.room_settings-template').html());
	},
	events: {
		'click #modalSend': 'update',
		'click #modalDelete': 'delete',
		'change #no-password': 'hidePassField'
	},
	update: function() {
		this.model.set('name', $('#modal input.name').val());
		this.model.set('privacy', $('#modal select.privacy > option:selected').val());
		if ($("#modal #no-password").is(":checked")) {
			this.model.set('password', 'none');
		} else {
			this.model.set('password', $('#modal input.password').val());
		}

		Backbone.sync("update", this.model, {
			"url": "/api/room_settings/" + $('#room_message_room_id').val(),
			success: function(response) {
				$('#modal').modal('hide');
			},
			error: function(err) {
				$('#modalOutput').html('Failed to edit settings!');
				$.each(err.responseJSON, function(idx, item) {
					$('#modalOutput').append("<br>> " + idx + ": " + item);
				});
				$('#modalOutput').fadeIn();
			}
		});
	},
	delete: function() {
		Backbone.sync("delete", this.model, {
			"url": "/api/room_settings/" + $('#room_message_room_id').val()
		});
	},
	hidePassField: function() {
		if ($('#no-password').is(':checked'))
		{
			$('#modal input.password').fadeOut();
		}
		else
		{
			$('#modal input.password').fadeIn();
		}
	},
	render: function() {
		this.$el.html(this.template(this.model.attributes));
		if (this.model.attributes.password == "checked") {
			this.$el.find('input.password').hide();
		}
		return this;
	}
});

window.app.views.RoomSettings = Backbone.View.extend({
	model: window.app.collections.newRoomSettings,
	el: $('#modal'),
	initialize: function() {
		var self = this;
		this.model.on("add", this.render, this);
		this.model.fetch({"url": "/api/room_settings/" + $('#room_message_room_id').val()});
	},
	render: function() {
		var self = this;
		$('#modal').html('');
		_.each(this.model.toArray(), function(item) {
			$('#modal').html((new window.app.views.RoomSetting({model: item})).render().$el);
		});
		$('#modal').modal('show');
		return this;
	}
});
