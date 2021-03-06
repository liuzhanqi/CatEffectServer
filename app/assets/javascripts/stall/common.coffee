this.getStallId = (handler) ->
  that = this
  $.ajax
    url:      "/stall/auth"
    type:     "post"
    dataType: "json"
    data:
              auth_username: this.auth.getUsername()
              auth_password: this.auth.getPassword()
    success: (data) ->
      if (!data['error'])
        handler(data['currentManager']['stallId'])
      else
        alert "Cannot verify your account. Please log in again."
        if that.javaMode()
          that.java.exit()