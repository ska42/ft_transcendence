window.app.views.RoomMember = Backbone.View.extend({
	tagName: 'div',
	initialize: function() {
		this.template = _.template($('.room_members-template').html());
	},
	events: {
		'click #modalSend': 'update',
		'click #modalDelete': 'delete',
		'change #no-password': 'hidePassField'
	},
	update: function() {
		this.model.set('name', $('#modal input.name').val());
		this.model.set('privacy', $('#modal input.privacy').val());
		if ($("#modal #no-password").is(":checked")) {
			this.model.set('password', 'none');
		} else {
			this.model.set('password', $('#modal input.password').val());
		}

		Backbone.sync("update", this.model,{
			"url": "/api/room_members/" + $('#room_message_room_id').val(),
			success: function(response) {
				$('#modal').modal('hide');
			},
			error: function(err) {
				$('#modalOutput').html('Failed to edit members!');
				$.each(err.responseJSON, function(idx, item) {
					$('#modalOutput').append("<br>> " + idx + ": " + item);
				});
				$('#modalOutput').fadeIn();
			}
		});
	},
	delete: function() {
		this.model.destroy({
			success: function(response) {
			},
			error: function(err) {
			}
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

window.app.views.RoomMembers = Backbone.View.extend({
	model: window.app.collections.newRoomMembers,
	el: $('#modal'),
	initialize: function() {
		var self = this;
		this.model.on("add", this.render, this);
		this.model.fetch({"url": "/api/room_members/" + $('#room_message_room_id').val()});
	},
	render: function() {
		var self = this;
		$('#modal').html('');
		_.each(this.model.toArray(), function(item) {
			$('#modal').html((new window.app.views.RoomMember({model: item})).render().$el);
		});
		$('#modal').modal('show');
		return this;
	}
});
