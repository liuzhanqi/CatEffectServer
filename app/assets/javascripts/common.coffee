auth = this.auth = {}

pageLoadHandlers = []

this.pageLoad = pageLoad = (handler)->
  pageLoadHandlers.push(handler)

this.javaPageLoad = javaPageLoad = ->
  while pageLoadHandlers.length > 0
    pageLoadHandlers.shift().call(this)

$(window).load ->
  if !javaMode()
    javaPageLoad()

# Auth Data
auth.getUsername = ->
  console.log "get username"
  if javaMode()
    return java.getUsername()
  else
    return "stall1"
auth.getPassword = ->
  if javaMode()
    return java.getPassword()
  else
    return "stall1"

# Pop up

this.showPopBox = showPopBox = (template, data, width, height) ->
  closePopBox();
  if data == undefined
    data = {}
  tmpl = _.template $(template).html()
  popBoxDiv = $('<div class="popbox"></div>')
  popBoxDiv.append tmpl(data)
  css =
    width:      width
    height:     height
    marginLeft: - width / 2
    marginTop:  - height / 2
    display:    "none"
  popBoxDiv.css css
  $("body").append popBoxDiv
  popBoxDiv.fadeIn(400)

this.closePopBox = closePopBox = () ->
  $('.popbox')
    .fadeOut(400, () -> $(this).remove())


# URL Router

this.params = params = {}

$(this).ready ->
  query = document.URL.split("#")[1]
  data = query.split('&')
  for item in data
    params[item.split('=')[0]] = item.split('=')[1]

_javamode = "undetected"

this.javaMode = javaMode = ->
  if _javamode == "undetected"
    _javamode = params['browser'] != "true"
    if _javamode
      console.log "enter java mode"
    else
      console.log "enter browser mode"
  return _javamode

this.newWindow = (target, width, height) ->
  if javaMode()
    this.java.open(target, width, height)
  else
    urls = target.split("#")
    if urls.length < 2
      this.open(target + "#browser=true")
    else
      this.open(target + "&browser=true")

this.displayTime = (timeStamp) ->
  month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  if timeStamp == null || timeStamp == 0
    return ""
  Date date = new Date(timeStamp)
  result = ""
  result += " " + date.getDate() + " " + month[date.getMonth()] + " " + date.getFullYear() + " "
  result += date.getHours() + ":"
  if (date.getMinutes() < 10)
    result += "0" + date.getMinutes()
  else
    result += date.getMinutes()
  return result

this.displayMoney = (money) ->
  neg = ""
  if money < 0
    money = - money
    neg = "-"
  result = ""
  result += Math.floor(money / 100)
  result += "."
  point = money % 100
  if point < 10
    result += "0" + point
  else
    result += point
  return neg + result